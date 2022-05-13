%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         场景蓄力技能
%%% @end
%%% Created : 13. 7月 2021 上午 10:59:11
%%%-------------------------------------------------------------------
-module(scene_wait_skill).
-author("Administrator").

-include("scene.hrl").
-include("fight.hrl").
-include("common.hrl").
-include("msg.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("error.hrl").

%% API
-export([
    handle_msg/2,
    pack_msg/1
]).
-export([handle_monster_use_skill/2]).

handle_msg(Msg, State) ->
    case Msg of
        {?MSG_SCENE_PLAN_USE_WAIT_SKILL, RequestFightParam} ->
            plan_use_wait_skill(RequestFightParam, State);
        {?MSG_SCENE_WAIT_SKILL_TRIGGER, PlayerId, SkillId} ->
            wait_skill_trigger(PlayerId, SkillId, State);
        {?MSG_SCENE_USE_WAIT_SKILL, RequestFightParam, Time} ->
            use_wait_skill(RequestFightParam, Time, State);
        {?MSG_SCENE_CANCEL_CANNOT_BE_ATTACK, ObjType, ObjId} ->
            cancel_cannot_be_attack(ObjType, ObjId)
    end.

pack_msg(Msg) ->
    {?MSG_SCENE_WAIT_SKILL, Msg}.

cancel_cannot_be_attack(ObjType, ObjId) ->
    ObjSceneActor = ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId),
    if
        ObjSceneActor == ?UNDEFINED ->
            noop;
        true ->
            #obj_scene_actor{
                is_cannot_be_attack = IsCannotBeAttack
            } = ObjSceneActor,
            if
                IsCannotBeAttack == false ->
                    noop;
                true ->
                    ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor#obj_scene_actor{is_cannot_be_attack = false})
            end
    end.

%% @doc 计划使用蓄力技能
plan_use_wait_skill(#request_fight_param{obj_type = ?OBJ_TYPE_PLAYER, skill_id = ?ACTIVE_SKILL_4} = RequestFightParam, _State) ->
    #request_fight_param{
        obj_type = ObjType,
        obj_id = ObjId,
        skill_id = SkillId,
        dir = Dir
    } = RequestFightParam,
    ChargeTime = 1000,
    ObjSceneActor = ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId),
    ?ASSERT(ObjSceneActor =/= ?UNDEFINED andalso ChargeTime > 0 andalso is_record(ObjSceneActor, obj_scene_actor)),
    #obj_scene_actor{
        wait_skill_info = WaitSkillInfo,
        can_use_skill_time = CanUseSkillTime,
        can_action_time = CanActionTime,
        dizzy_close_time = DizzyCloseTime,
        surface = #surface{
            hero_id = HeroId
        }
    } = ObjSceneActor,
    Now = util_time:milli_timestamp(),

    IsCanUseWaitSkill =
        case WaitSkillInfo of
            ?UNDEFINED ->
                true;
            #wait_skill{end_time = EndTime} ->
                Now > EndTime
        end,

%%    ?DEBUG("查看数据 ： ~p", [{WaitSkillInfo, Now, CanUseSkillTime, CanActionTime, DizzyCloseTime}]),
    ?ASSERT(IsCanUseWaitSkill andalso Now >= CanUseSkillTime andalso Now >= CanActionTime andalso Now >= DizzyCloseTime),
    match_scene:handle_use_skill(ObjId, ?ACTIVE_SKILL_4),
    NewWaitSkillInfo = #wait_skill{
        skill_id = SkillId,
        dir = Dir,
        end_time = Now + ChargeTime,
        request_fight_param = RequestFightParam
    },
    case mod_scene_event_manager:get_state() of
        %% 盲盒箱子期间，玩家不能释放大招
        {State, _} when State =:= ?SCENE_MASTER_STATE_BOX andalso ObjSceneActor#obj_scene_actor.obj_type =:= ?OBJ_TYPE_PLAYER ->
            exit(?ERROR_FAIL);
        _ ->
            ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor#obj_scene_actor{wait_skill_info = NewWaitSkillInfo, is_cannot_be_attack = true}),
            #t_hero{
                hero_skill_time_cd = HeroSkillTimeCd
            } = t_hero:get({HeroId}),
            erlang:send_after(HeroSkillTimeCd, self(), pack_msg({?MSG_SCENE_CANCEL_CANNOT_BE_ATTACK, ObjType, ObjId})),
            erlang:send_after(ChargeTime, self(), pack_msg({?MSG_SCENE_USE_WAIT_SKILL, RequestFightParam, Now + ChargeTime}))
    end,
    ok;
plan_use_wait_skill(RequestFightParam, _State) ->
    #request_fight_param{
        obj_type = ObjType,
        obj_id = ObjId,
        skill_id = SkillId,
        dir = Dir
    } = RequestFightParam,
    #t_active_skill{
        charge_time = ChargeTime
    } = mod_active_skill:get_t_active_skill(SkillId),
    ObjSceneActor = ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId),
    case ObjSceneActor of
        ?UNDEFINED ->
            noop;
        ObjSceneActor when ChargeTime > 0 andalso is_record(ObjSceneActor, obj_scene_actor) ->
            #obj_scene_actor{
                wait_skill_info = WaitSkillInfo,
                can_use_skill_time = CanUseSkillTime,
                can_action_time = CanActionTime,
                dizzy_close_time = DizzyCloseTime
            } = ObjSceneActor,

            Now = util_time:milli_timestamp(),

            IsCanUseWaitSkill =
                case WaitSkillInfo of
                    ?UNDEFINED ->
                        true;
                    #wait_skill{end_time = EndTime} ->
                        Now > EndTime
                end,

            if
                IsCanUseWaitSkill andalso Now >= CanUseSkillTime andalso Now >= CanActionTime andalso Now >= DizzyCloseTime ->
                    NewWaitSkillInfo = #wait_skill{
                        skill_id = SkillId,
                        dir = Dir,
                        end_time = Now + ChargeTime,
                        request_fight_param = RequestFightParam
                    },
                    ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor#obj_scene_actor{wait_skill_info = NewWaitSkillInfo}),
                    erlang:send_after(ChargeTime, self(), pack_msg({?MSG_SCENE_USE_WAIT_SKILL, RequestFightParam, Now + ChargeTime}));
                true ->
                    noop
            end;
        _ ->
            noop
    end.

%% @doc 蓄力技能触发
wait_skill_trigger(PlayerId, 4, #scene_state{scene_id = SceneId}) ->
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            noop;
        ObjScenePlayer ->
            #obj_scene_actor{
                wait_skill_info = WaitSkillInfo
            } = ObjScenePlayer,
            case WaitSkillInfo of
                ?UNDEFINED ->
                    noop;
                #wait_skill{skill_id = ?ACTIVE_SKILL_4, request_fight_param = RequestFightParam} ->
                    ?UPDATE_OBJ_SCENE_ACTOR(ObjScenePlayer#obj_scene_actor{wait_skill_info = ?UNDEFINED}),
                    Self = self(),
                    Fun =
                        fun() ->
                            PropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
                            RequestFightParam0 =
                                RequestFightParam#request_fight_param{
                                    player_left_coin = mod_prop:get_player_prop_num(PlayerId, PropId),
                                    single_goal_attack_num = ?SD_SKILL_ATTACK_NUMBER
                                },
                            case catch gen_server:call(Self, {?MSG_FIGHT, RequestFightParam0}) of
                                {success, CostMano} ->
                                    if CostMano > 0 ->
                                        ?INFO("~p大招攻击，消耗 : ~p", [PlayerId, CostMano]),
                                        ?TRY_CATCH2(mod_prop:decrease_player_prop(PlayerId, [{PropId, CostMano}], ?LOG_TYPE_FIGHT));
                                        true ->
                                            noop
                                    end;
                                _Error ->
                                    ?INFO("~p大招攻击失败，消耗 : ~p", [PlayerId, RequestFightParam#request_fight_param.cost]),
                                    noop
                            end
                        end,
                    Node = mod_player:get_game_node(PlayerId),
                    mod_apply:apply_to_online_player(Node, PlayerId, util, run, [Fun, 1], normal)
            end
    end;
wait_skill_trigger(_PlayerId, _SkillId, _State) ->
    noop.

%% @doc 使用蓄力技能
use_wait_skill(#request_fight_param{obj_type = ?OBJ_TYPE_PLAYER, skill_id = ?ACTIVE_SKILL_4} = RequestFightParam, Time, #scene_state{scene_id = SceneId} = _State) ->
    #request_fight_param{
        obj_type = ObjType,
        obj_id = ObjId
    } = RequestFightParam,
    case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
        ?UNDEFINED ->
            noop;
        ObjSceneActor ->
            #obj_scene_actor{
                wait_skill_info = WaitSkillInfo
            } = ObjSceneActor,
            IsWaitSkill = is_record(WaitSkillInfo, wait_skill),
            if
                IsWaitSkill ->
                    #wait_skill{
                        end_time = EndTime
                    } = WaitSkillInfo,
                    if
                        EndTime =:= Time ->
                            ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor#obj_scene_actor{wait_skill_info = ?UNDEFINED}),
                            Self = self(),
                            Fun =
                                fun() ->
                                    PropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
                                    RequestFightParam0 =
                                        RequestFightParam#request_fight_param{
                                            player_left_coin = mod_prop:get_player_prop_num(ObjId, PropId),
                                            single_goal_attack_num = ?SD_SKILL_ATTACK_NUMBER
                                        },
                                    case catch gen_server:call(Self, {?MSG_FIGHT, RequestFightParam0}) of
                                        {success, CostMano} ->
                                            if CostMano > 0 ->
                                                ?INFO("~p大招攻击，消耗 : ~p", [ObjId, CostMano]),
                                                mod_conditions:add_conditions(ObjId, {?CON_ENUM_ANGER_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1}),
                                                ?TRY_CATCH2(mod_prop:decrease_player_prop(ObjId, [{PropId, CostMano}], ?LOG_TYPE_FIGHT));
                                                true ->
                                                    noop
                                            end;
                                        _Error ->
                                            ?INFO("~p大招攻击失败，消耗 : ~p", [ObjId, RequestFightParam#request_fight_param.cost]),
                                            noop
                                    end
                                end,
                            Node = mod_player:get_game_node(ObjId),
                            mod_apply:apply_to_online_player(Node, ObjId, util, run, [Fun, 1], normal);
                        true ->
                            ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor#obj_scene_actor{wait_skill_info = ?UNDEFINED})
                    end;
                true ->
                    ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor#obj_scene_actor{wait_skill_info = ?UNDEFINED})
            end
    end;
use_wait_skill(RequestFightParam, Time, State) ->
    #request_fight_param{
        obj_type = ObjType,
        obj_id = ObjId
    } = RequestFightParam,
    case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
        ?UNDEFINED ->
            noop;
        ObjSceneActor ->
            #obj_scene_actor{
                wait_skill_info = WaitSkillInfo
            } = ObjSceneActor,
            IsWaitSkill = is_record(WaitSkillInfo, wait_skill),
            if
                IsWaitSkill ->
                    #wait_skill{
                        end_time = EndTime
                    } = WaitSkillInfo,
                    if
                        EndTime =:= Time ->
                            ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor#obj_scene_actor{wait_skill_info = ?UNDEFINED}),
                            mod_fight:fight(RequestFightParam, State);
                        true ->
                            noop
                    end;
                true ->
                    noop
            end
    end.

%% 处理怪物使用技能
handle_monster_use_skill(RequestFightParam, State) ->
    #request_fight_param{
        obj_type = ObjType,
        obj_id = ObjId
    } = RequestFightParam,
    case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
        ?UNDEFINED -> skip;
        _ -> mod_fight:fight(RequestFightParam, State)
    end,
    ok.
