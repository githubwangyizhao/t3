%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            战斗
%%% @end
%%% Created : 27. 十一月 2017 下午 9:02
%%%-------------------------------------------------------------------
-module(api_fight).

-include("error.hrl").
-include("fight.hrl").
-include("common.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("scene.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("msg.hrl").
-include("scene_monster.hrl").

%% API
-export([
    fight/2,
    use_item/2,
    wait_skill_trigger/2
]).

-export([
    notice_fight_fail/2,
    notice_fight_result/2,
    notice_remove_buff/4,
    notice_get_function_monster_award/4,
    notice_fight_wait_skill/7,
    notice_frozen_monster/3,
    pack_buff_list/1,
    pack_effect_list/1
]).

-export([
    get_item_id/2
]).

-export([
    test_fight/2
]).

-export([
    dizzy_time_reduce/2,
    test_dizzy_time_reduce/2
]).

get_item_id(SceneId, PropId) ->
    if
        PropId =:= ?ITEM_GOLD ->
            #t_scene{
                mana_attack_list = ManaAttackList
            } = mod_scene:get_t_scene(SceneId),
            case ManaAttackList of
                [NewPropId, _AttackCostList] ->
                    NewPropId;
                _ ->
                    ?ITEM_GOLD
            end;
        true ->
            PropId
    end.

test_fight(PlayerId, SkillId) ->
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    RequestFightParam =
        #request_fight_param{
            attack_type = ?OBJ_TYPE_FUNCTION_MONSTER_SKILL,
            obj_type = ?OBJ_TYPE_PLAYER,
            obj_id = PlayerId,
            skill_id = SkillId,
            skill_level = 1,
            dir = ?DIR_LEFT,
            target_type = 0,
            target_id = 0,
            cost = 20
        },
    SceneWorker ! {?MSG_FIGHT, RequestFightParam}.

%% ----------------------------------
%% @doc 	战斗
%% @throws 	none
%% @end
%% ----------------------------------
fight(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_fight_fight_tos{
        skill_id = SkillId,
        dir = Dir,
        target_type = TargetType,
        target_id = TargetId,
        mano_value = Cost
    } = Msg,
    #ets_obj_player{
        scene_id = SceneId,
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    #t_scene{
        type = SceneType,
        mission_type = MissionType,
        mana_attack_list = [PropId, AttackCostList]
    } = t_scene:assert_get({SceneId}),
    if
        SceneWorker == null ->
            ?DEBUG("fight null scene_worker"),
            noop;
        true ->
            mod_scene:assert_not_server_control(),

            #t_cost{
                coin_conditions_limit_list = CoinConditionsLimitList,
                diamond_conditions_limit_list = DiamondConditionsLimitList
            } = t_cost:assert_get({Cost}),
            ConditionsLimitList =
                case PropId of
                    ?ITEM_GOLD ->
                        CoinConditionsLimitList;
                    ?ITEM_RMB ->
                        DiamondConditionsLimitList;
                    ?ITEM_ZIDAN ->
                        [];
                    ?ITEM_RUCHANGJUAN ->
                        []
                end,

            ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, ConditionsLimitList), cost_error),
            ?IF(SceneType == ?SCENE_TYPE_WORLD_SCENE, ?ASSERT(lists:member(Cost, AttackCostList), cost_error), noop),
            ?ASSERT(SkillId /= ?ACTIVE_SKILL_4 andalso SkillId /= ?ACTIVE_SKILL_5),

            RequestFightParam =
                #request_fight_param{
                    attack_type = ?OBJ_TYPE_PLAYER,
                    obj_type = ?OBJ_TYPE_PLAYER,
                    obj_id = PlayerId,
                    skill_id = SkillId,
                    dir = Dir,
                    target_type = TargetType,
                    target_id = TargetId,
                    cost = Cost,
                    rate = 1
                },

            mod_prop:assert_prop_num(PlayerId, [{PropId, Cost}]),

            Tran = fun() ->
                case gen_server:call(SceneWorker, {?MSG_FIGHT, RequestFightParam}) of
                    {success, _ExtraCostNum} ->
                        %% 不可以放在这里，这样boss的消耗也会进普通池子
%%                        scene_adjust:cast_add_room_pool_value(PlayerId, Cost),
                        hook:after_fight(PlayerId, SceneId, Cost);
                    Error ->
                        exit(Error)
                end,
                if
                    MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS ->
                        noop;
                    MissionType == ?MISSION_TYPE_SHISHI_BOSS ->
                        mod_conditions:add_conditions(PlayerId, {?CON_ENUM_ATTACK_SHISHICAI_COUNT, ?CONDITIONS_VALUE_ADD, 1});
                    true ->
                        mod_prop:decrease_player_prop(PlayerId, [{PropId, Cost}], ?LOG_TYPE_FIGHT)
                end
                   end,
            catch db:do(Tran),
            State
    end.

use_item(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_fight_use_item_tos{
        item_id = ItemId,
        mano_value = Cost
    } = Msg,
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
    #t_scene{
        is_hook = IsHook,
        mana_attack_list = [PropId, AttackCostList]
    } = mod_scene:get_t_scene(SceneId),
    Result =
        try
            Tran =
                fun() ->
                    ?ASSERT(SceneWorker =/= null, no_scene),

                    case ItemId of
                        ?ITEM_SKILL_BOOK_1 ->
                            %% 加速
                            case logic_get_bettle_skill_data:get({SceneId, ItemId}) of
                                null ->
                                    mod_prop:decrease_player_prop(PlayerId, ItemId, 1, ?LOG_TYPE_FIGHT),
                                    mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_RAGE_SKILLS_USE_COUNT);
                                _ ->
                                    noop
                            end,
                            if
                                IsHook == ?TRUE ->
                                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_SPEED_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1});
                                true ->
                                    noop
                            end,
                            SceneWorker ! {?MSG_SCENE_USE_FIGHT_ITEM, ItemId, PlayerId};
                        ?ITEM_SKILL_BOOK_2 ->
                            %% 冰冻
                            case logic_get_bettle_skill_data:get({SceneId, ItemId}) of
                                null ->
                                    mod_prop:decrease_player_prop(PlayerId, ItemId, 1, ?LOG_TYPE_FIGHT),
                                    mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_FROZEN_SKILLS_USE_COUNT);
                                _ ->
                                    noop
                            end,
                            if
                                IsHook == ?TRUE ->
                                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_FREEZE_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1});
                                true ->
                                    noop
                            end,
                            SceneWorker ! {?MSG_SCENE_USE_FIGHT_ITEM, ItemId, PlayerId};
                        ?ITEM_SKILL_BOOK_3 ->
                            %% 自动
                            case logic_get_bettle_skill_data:get({SceneId, ItemId}) of
                                null ->
                                    mod_prop:decrease_player_prop(PlayerId, ItemId, 1, ?LOG_TYPE_FIGHT);
                                _ ->
                                    noop
                            end,
                            if
                                IsHook == ?TRUE ->
                                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_AUTO_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1});
                                true ->
                                    noop
                            end,
                            mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_AUTOMATIC_COMBAT_USE_COUNT);
                        ?ACTIVE_SKILL_4 ->
                            #t_cost{
                                coin_conditions_limit_list = CoinConditionsLimitList,
                                diamond_conditions_limit_list = DiamondConditionsLimitList
                            } = t_cost:assert_get({Cost}),
                            ConditionsLimitList =
                                case PropId of
                                    ?ITEM_GOLD ->
                                        CoinConditionsLimitList;
                                    ?ITEM_RMB ->
                                        DiamondConditionsLimitList;
                                    _ ->
                                        []
                                end,

                            ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, ConditionsLimitList), cost_error),
                            ?ASSERT(lists:member(Cost, AttackCostList), cost_error),
                            Tran1 =
                                fun() ->
                                    RequestFightParam =
                                        #request_fight_param{
                                            attack_type = ?OBJ_TYPE_PLAYER,
                                            obj_type = ?OBJ_TYPE_PLAYER,
                                            obj_id = PlayerId,
                                            skill_id = ?ACTIVE_SKILL_4,
                                            dir = ?DIR_LEFT,
                                            target_type = 0,
                                            target_id = 0,
                                            cost = Cost
                                        },
                                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_ANGER_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1}),
                                    case gen_server:call(SceneWorker, scene_wait_skill:pack_msg({?MSG_SCENE_PLAN_USE_WAIT_SKILL, RequestFightParam})) of
                                        ok ->
                                            mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_BIG_RECRUIT_SKILLS_USE_COUNT);
                                        ERROR ->
                                            exit(ERROR)
                                    end
                                end,
                            db:do(Tran1)
                    end
                end,
            db:do(Tran)
        of
            _ ->
                ?P_SUCCESS
        catch
            _:Error ->
                ?ERROR("大招失敗:~p", [{Error, erlang:get_stacktrace()}]),
                api_common:api_result_to_enum(Error)
        end,
    Out = proto:encode(#m_fight_use_item_toc{item_id = ItemId, reason = Result}),
    mod_socket:send(Out),
    State.

%% @doc 蓄力技能触发
wait_skill_trigger(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_fight_wait_skill_trigger_tos{
        skill_id = SkillId
    } = Msg,
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    erlang:send(SceneWorker, scene_wait_skill:pack_msg({?MSG_SCENE_WAIT_SKILL_TRIGGER, PlayerId, SkillId})),
    State.

%% ----------------------------------
%% @doc 	通知战斗失败
%% @throws 	none
%% @end
%% ----------------------------------
notice_fight_fail(PlayerId, Reason) ->
    Out = proto:encode(#m_fight_notice_fight_fail_toc{
        reason = Reason
    }),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知战斗结果
%% @throws 	none
%% @end
%% ----------------------------------
notice_fight_result(PlayerIdList, FightResult) ->
    #m_fight_notice_fight_result_toc{
        attacker_id = AttackerId,
        skill_id = SkillId,
        skill_effect = SkillEffect,
        defender_result_list = DefList
    } = FightResult,
    case ?IS_DEBUG of
        true ->
            lists:foreach(
                fun(PlayerId) ->
                    mod_apply:apply_to_online_player(PlayerId, api_player, notice_player_xiu_zhen_value, [PlayerId, []])
                end,
                PlayerIdList
            );
        false ->
            noop
    end,
    TotalManaFun =
        fun() ->
            lists:sum(lists:map(
                fun(Def) ->
                    #defenderresult{
                        mano_award = ManoAward
                    } = Def,
                    ManoAward
                end,
                DefList
            ))
        end,
    if
        SkillId =:= 4 ->
            TotalMana = TotalManaFun(),
            api_scene:notice_rank_event(3, TotalMana, AttackerId);
%%            ?INFO("~p大招攻击，收益~p", [AttackerId, TotalMana]);
        SkillEffect == ?MONSTER_EFFECT_SKILL_105 ->
            TotalMana = TotalManaFun(),
            api_scene:notice_rank_event(1, TotalMana, AttackerId);
%%            ?INFO("~p炸弹攻击，收益~p", [AttackerId, TotalMana]);
        SkillEffect == ?MONSTER_EFFECT_SKILL_109 ->
            TotalMana = TotalManaFun(),
            api_scene:notice_rank_event(4, TotalMana, AttackerId);
%%            ?INFO("~p陨石攻击，收益~p", [AttackerId, TotalMana]);
        SkillEffect == 111 ->
            TotalMana = TotalManaFun(),
            api_scene:notice_rank_event(5, TotalMana, AttackerId);
%%            ?INFO("~p飓风攻击，收益~p", [AttackerId, TotalMana]);
        true ->
            noop
    end,
    lists:foreach(
        fun(Def) ->
            #defenderresult{
                special_event = SpecialEvent,
                mano_award = ManoAward
            } = Def,
            if
                SpecialEvent == ?MONSTER_EFFECT_17 ->
                    %% 通知金币排行榜事件 击杀赏金怪
                    api_scene:notice_rank_event(2, ManoAward, AttackerId);
                SpecialEvent == ?MONSTER_EFFECT_15 ->
                    %% 通知金币排行榜事件 击杀金币小妖
                    api_scene:notice_rank_event(6, ManoAward, AttackerId);
                true ->
                    noop
            end
        end,
        DefList
    ),
    Out = proto:encode(FightResult),
    mod_socket:send_to_player_list(PlayerIdList, Out).

%% ----------------------------------
%% @doc 	通知移除buff
%% @throws 	none
%% @end
%% ----------------------------------
notice_remove_buff(PlayerIdIdList, ObjType, ObjId, BuffIdList) ->
    Out = proto:encode(#m_fight_notice_remove_buff_toc{
        obj_type = ObjType,
        obj_id = ObjId,
        buff_id_list = BuffIdList
    }),
    mod_socket:send_to_player_list(PlayerIdIdList, Out).

%% ----------------------------------
%% @doc 	通知获得功能怪奖励
%% @throws 	none
%% @end
%% ----------------------------------
notice_get_function_monster_award(PlayerId, SpecialEvent, SpecialEventType, List) ->
    Out = proto:encode(#m_fight_notice_get_function_monster_award_toc{
        special_event = SpecialEvent,
        special_event_type = SpecialEventType,
        award_list = [#'m_fight_notice_get_function_monster_award_toc.functionmonsteraward'{id = Id, prop_list = api_prop:pack_prop_list(PropList)} || {Id, PropList} <- List]
    }),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知战斗蓄力技能
%% @throws 	none
%% @end
%% ----------------------------------
notice_fight_wait_skill(NoticePlayerIdList, ObjType, ObjId, SkillId, Dir, EndTime, SkillPointList) ->
    Out = proto:encode(#m_fight_notice_fight_wait_skill_toc{
        obj_type = ObjType,
        obj_id = ObjId,
        skill_id = SkillId,
        end_time = EndTime,
        wait_skill = [#waitskill{x = X, y = Y, dir = Dir} || {X, Y} <- SkillPointList]
    }),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% 通知玩家冰冻怪物
notice_frozen_monster(NoticePlayerIdList, PlayerId, FrozenMonsterList) ->
    Out = proto:encode(#m_fight_notice_bin_dong_skill_toc{
        player_id = PlayerId,
        list = [
            #'m_fight_notice_bin_dong_skill_toc.attr_change'{
                scene_monster_id = MonsterId,
                destroy_time = ?IF(DestroyTimeMs > 0, trunc(DestroyTimeMs / 1000), 0),
                end_time = trunc(EndTime / 1000)
            } || {MonsterId, DestroyTimeMs, EndTime} <- FrozenMonsterList
        ]
    }),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

pack_buff_list([]) ->
    [];
pack_buff_list(RBuffList) ->
    Now = util_time:milli_timestamp(),
    [pack_buff(RBuff, Now) || RBuff <- RBuffList].
pack_buff(RBuff, Now) ->
    #r_buff{
        id = Id,
        level = Level,
        invalid_ms = InvalidMs,
        data = _Data
    } = RBuff,
    #buff{
        id = Id,
        level = Level,
        left_time = max(0, InvalidMs - Now)
    }.

pack_effect_list([]) ->
    [];
pack_effect_list(REffectList) ->
    [pack_effect(Effect) || Effect <- REffectList].
pack_effect(Effect) ->
    #r_effect{
        id = Id,
        data = Data
    } = Effect,
    #effect{
        id = Id,
        data = Data
    }.

dizzy_time_reduce(
    #m_fight_dizzy_time_reduce_tos{
        times = Times
    } = _Msg,
    State = #conn{player_id = PlayerId}
) ->
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    case gen_server:call(SceneWorker, {?MSG_DIZZY_TIME_REDUCE, PlayerId, Times}) of
        success -> ok;
        Error -> ?ERROR("Error: ~p", [Error])
    end,
    State.

test_dizzy_time_reduce(PlayerId, Times) ->
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    case gen_server:call(SceneWorker, {?MSG_DIZZY_TIME_REDUCE, PlayerId, Times}) of
        success -> ok;
        Error -> ?ERROR("Error: ~p", [Error])
    end.