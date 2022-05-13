%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            副本回调
%%% @end
%%% Created : 10. 八月 2016 上午 11:37
%%%-------------------------------------------------------------------
-module(mission_handle).
-include("scene.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("scene_monster.hrl").
-include("mission.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("msg.hrl").

%% API
-export([
    handle_msg/2,                       %% 处理副本消息
    handle_player_death/3,              %% 玩家死亡
    handle_monster_death/13,            %% 怪物死亡
    handle_init_mission/2,              %% 初始化副本
    handle_player_enter_mission/2,      %% 玩家进入副本
    handle_monster_enter_mission/2,     %% 怪物进入副本
    handle_balance/1,                   %% 副本结算
    handle_hurt/3,                      %% 处理伤害
    handle_leave_mission/2,              %% 玩家退出副本
    handle_start_mission/1,             %% 副本启动
    handle_round_end/1,                 %% 回合结束
    handle_round_end/2,
    trigger_next_round/1,               %% 触发新回合
    trigger_next_round/2,
    handle_cost_mano/4,                 %% 战斗消耗灵力值
    handle_assert_fight/6
%%    handle_round_end/3                  %% 副本回合结束
]).

%% @doc 校验是否可以战斗
handle_assert_fight(ObjType, ObjId, TargetObjType, TargetObjId, _Cost, SkillId0) ->
    MissionType = get(?DICT_MISSION_TYPE),
    if
        MissionType =:= ?MISSION_TYPE_GUESS_BOSS ->
            if
                ObjType =:= ?OBJ_TYPE_PLAYER andalso TargetObjType =:= ?OBJ_TYPE_MONSTER ->
                    mod_mission_guess_boss:handle_assert_fight(ObjId, TargetObjId);
                true ->
                    noop
            end;
        MissionType =:= ?MISSION_TYPE_SHISHI_BOSS ->
            mod_mission_shi_shi:handle_assert_fight(SkillId0);
%%            if
%%                ObjType =:= ?OBJ_TYPE_PLAYER andalso TargetObjType =:= ?OBJ_TYPE_MONSTER ->
%%                    mod_mission_shi_shi:handle_assert_fight();
%%                true ->
%%                    noop
%%            end;
        MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS -> %% 勇敢者副本
            if
                ObjType =:= ?OBJ_TYPE_PLAYER ->
                    mod_mission_brave_one:handle_assert_fight(ObjId);
                true ->
                    noop
            end;
        MissionType == ?MISSION_TYPE_STEP_BY_STEP_SYS -> %% 步步紧逼
            if
                ObjType =:= ?OBJ_TYPE_PLAYER ->
                    mod_mission_step_by_step_sy:handle_assert_fight(ObjId);
                true ->
                    noop
            end;
        true ->
            noop
    end.

%% 战斗消耗灵力值
handle_cost_mano(AttObjSceneActor, Cost, DefObjType, DefObjId) ->
    #obj_scene_actor{
        obj_id = AttObjId,
        nickname = AttNickName,
        obj_type = AttObjType
    } = AttObjSceneActor,
    DefObjSceneActor = ?GET_OBJ_SCENE_ACTOR(DefObjType, DefObjId),

    if
        DefObjSceneActor == ?UNDEFINED ->
            noop;
        true ->
            #obj_scene_actor{
                obj_id = DefObjId,
                obj_type = DefObjType,
                base_id = DefBaseId
            } = DefObjSceneActor,
            MissionType = get(?DICT_MISSION_TYPE),
            if AttObjType == ?OBJ_TYPE_PLAYER andalso DefObjType == ?OBJ_TYPE_MONSTER ->
                case MissionType of
                    ?MISSION_TYPE_MANY_PEOPLE_BOSS ->
                        %% 多人boss副本记录消耗灵力值
                        mod_mission_many_people_boss:handle_deal_cost(AttObjId, AttNickName, Cost);
                    ?MISSION_TYPE_GUESS_BOSS ->
                        %% 猜一猜副本
                        mod_mission_guess_boss:handle_deal_cost(AttObjId, DefObjId, DefBaseId, Cost);
                    ?MISSION_TYPE_SHISHI_BOSS ->
                        %% 时时副本
                        mod_mission_shi_shi:handle_deal_cost(AttObjId, AttNickName, Cost);
                    ?MISSION_TYPE_MANY_PEOPLE_SHISHI ->
                        %% 时时房间副本
                        mod_mission_shi_shi_room:handle_deal_cost(AttObjId, AttNickName, Cost);
                    ?MISSION_TYPE_MISSION_EITHER_OR ->
                        %% 二选一副本
                        mod_mission_either:handle_deal_cost(DefObjId, Cost);
                    ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
                        %% 场景boss猜刀数副本
                        mod_mission_scene_boss:handle_deal_cost(DefObjId);
                    _ ->
                        noop
                end;
                true ->
                    noop
            end
    end.

%% ----------------------------------
%% @doc 	处理伤害
%% @throws 	none
%% @end
%% ----------------------------------
handle_hurt(DefObjSceneActor, AttObjSceneActor, Hurt) ->
    #obj_scene_actor{
        obj_id = _DefObjId,
        hp = _DefHp,
        obj_type = DefObjType,
        max_hp = _MaxHp,
        base_id = _MonsterId
    } = DefObjSceneActor,
    #obj_scene_actor{
        obj_type = AttObjType,
        obj_id = AttObjId,
        nickname = AttNickName
    } = AttObjSceneActor,

    MissionType = get(?DICT_MISSION_TYPE),
%%    _MissionId = get(?DICT_MISSION_ID),

%%    ?DEBUG("副本详情处理伤害~p", [{MissionType, _MissionId, Hurt, get(cost)}]),

    case MissionType of
        ?MISSION_TYPE_WORLD_BOSS ->%% 世界boss
            if AttObjType == ?OBJ_TYPE_PLAYER andalso DefObjType == ?OBJ_TYPE_MONSTER ->
                mission_ranking:update_hurt(0, AttObjId, AttNickName, Hurt);
                true ->
                    noop
            end;
        _ ->
            noop
    end.

%% ----------------------------------
%% @doc 	处理玩家死亡
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_death(_PlayerId, _AttObjType, _AttObjId) ->
    MissionKind = get(?DICT_MISSION_KIND),
%%    MissionType = get(?DICT_MISSION_TYPE),
%%    _MissionId = get(?DICT_MISSION_ID),
    if MissionKind == ?MISSION_KIND_SINGLE ->
%%        case MissionType of
%%%%            ?MISSION_TYPE_TEMPLE_OF_WAR ->
%%%%                %% 战神殿
%%%%                mod_mission_zhan_shen_dian:handle_player_death(PlayerId);
%%            _ ->
        %% 单人副本 玩家死亡 结算副本
        ?DEBUG("单人副本玩家死亡，结算副本~p", [{get(?DICT_MISSION_TYPE), get(?DICT_MISSION_ID)}]),
        mod_mission:send_msg(?MSG_MISSION_BALANCE);
%%        end;
        true ->
%%            case MissionType of
%%                ?MISSION_TYPE_DALUANDOU ->
%%                    mod_mission_da_luan_dou:handle_player_death(PlayerId, AttObjType, AttObjId);
%%%%                ?MISSION_TYPE_HUNTING_BOSS ->
%%%%                    mod_mission_hunting_boss:handle_player_death(MissionId, PlayerId, AttObjType, AttObjId);
%%%%                ?MISSION_TYPE_DREAMLAND_BOSS ->
%%%%                    mod_mission_txhj:handle_player_death(MissionId, PlayerId, AttObjType, AttObjId);
%%                ?MISSION_TYPE_SHENGSHOU ->
%%                    mod_mission_sheng_shou:handle_player_death(PlayerId);
%%                _ ->
            noop
%%            end
    end.

%% ----------------------------------
%% @doc 	处理怪物死亡
%% @throws 	none
%% @end
%% ----------------------------------
handle_monster_death(ObjMonsterId, _MonsterId, _AttObjType, AttObjId, _BelongPlayerId, _CreateTime, _RebirthTime, X, Y, _BirthX, _BirthY, _HurtList, AttObjNickName) ->
    MissionType = get(?DICT_MISSION_TYPE),
%%    MissionId = get(?DICT_MISSION_ID),
%%    put({?DICT_MONSTER_BELONG_PLAYER_ID, MonsterId}, BelongPlayerId),
%%    CommonRebirthFun =
%%        fun() ->
%%            [Min, M, Rate] =
%%                if
%%%%                    MissionType == ?MISSION_TYPE_DIGONG ->
%%%%                    ?SD_DIGONG_BOSS_ARGS;
%%                    true ->
%%                        ?SD_BOSS_ARGS
%%                end,
%%
%%            Diff = M - max(0, util_time:timestamp() - CreateTime) div 60,
%%            RealRebirthTime =
%%                if Diff > 0 ->
%%                    max(Min * 60 * 1000, erlang:trunc(RebirthTime - RebirthTime * Rate * Diff));
%%                    true ->
%%                        RebirthTime
%%                end,
%%            ?DEBUG("BOSS复活时间动态计算:~p~n", [{RealRebirthTime, RebirthTime, util_time:timestamp(), CreateTime, Diff}]),
%%%%            if MissionType == ?MISSION_TYPE_ZHUANG_BEI orelse MissionType == ?MISSION_TYPE_HUNTING_BOSS orelse MissionType == ?MISSION_TYPE_DREAMLAND_BOSS orelse MissionType == ?MISSION_TYPE_MING_YU ->
%%%%                %% 装备 猎杀副本 玩家可以召唤复活， 需要用到start_timer 定时器
%%%%                mod_scene_monster_manager:start_timer_2_create_monster(RealRebirthTime, MonsterId, BirthX, BirthY);
%%%%                true ->
%%                    erlang:send_after(RealRebirthTime, self(), {?MSG_SCENE_CREATE_MONSTER, MonsterId, BirthX, BirthY}),
%%%%            end,
%%            RealRebirthTime
%%        end,
    if
        MissionType == ?MISSION_TYPE_WORLD_BOSS     %% 世界boss
            orelse MissionType == ?MISSION_TYPE_MANY_PEOPLE_BOSS            % 多人boss
            orelse MissionType == ?MISSION_TYPE_MANY_PEOPLE_SHISHI          % 时时房间副本
            ->
            put(?DICT_KILL_DIE_LAST, AttObjId),
            ?DEBUG("怪物死亡导致结算~p", [MissionType]),
            mod_mission:send_msg(?MSG_MISSION_BALANCE);
        MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS -> %% 勇敢者副本
            mod_mission_brave_one:handle_monster_death(AttObjId, ObjMonsterId);
        MissionType == ?MISSION_TYPE_STEP_BY_STEP_SYS -> %% 步步紧逼副本
            mod_mission_step_by_step_sy:handle_monster_death(AttObjId, ObjMonsterId);
        MissionType == ?MISSION_TYPE_MISSION_EITHER_OR -> %% 二选一副本
            mod_mission_either:handle_next_end();
        MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION
            orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT
            -> %% 场景boss位置
            put(scene_boss_die_data, {X, Y, AttObjNickName}),
            mod_mission:send_msg(?MSG_MISSION_BALANCE);
        true ->
            noop
    end,

    case mod_mission:get_notice_round_type(MissionType) of
        ?NOTICE_ROUND_TYPE_MONSTER ->
            %% 通知副本进度
            TotalMonsterNum = get(?DICT_MONSTER_TOTAL_NUM),
            NewKillNum = min(get(?DICT_KILL_MONSTER_NUM) + 1, TotalMonsterNum),
            put(?DICT_KILL_MONSTER_NUM, NewKillNum),
            api_mission:notice_mission_schedule(TotalMonsterNum, NewKillNum);
        _ ->
            noop
    end.


%% ----------------------------------
%% @doc 	处理副本消息
%% @throws 	none
%% @end
%% ----------------------------------
handle_msg(Msg, State = #scene_state{mission_type = MissionType}) ->
    case Msg of
        ?MSG_MISSION_BALANCE ->
            %% 副本结算
            handle_balance(State);
        ?MSG_MISSION_START ->
            %% 启动副本
            handle_start_mission(State);
        {refresh_ranking} ->
            %% 刷新副本排行榜
            mission_ranking:handle_refresh_ranking();
        {refresh_ranking, MissionType, MissionId, Id} ->
            %% 刷新副本排行榜
            mission_ranking:handle_refresh_ranking(MissionType, MissionId, Id);
        notice_shi_shi_value ->
            mod_mission_shi_shi:notice_shi_shi_value();
        shi_shi_single_settle ->
            mod_mission_shi_shi:handle_balance_single(State);
        shi_shi_destroy_all_monster ->
            mod_mission_shi_shi:handle_destroy_all_monster();
        ?MSG_GUESS_MISSION_REFRESH_COST ->
            mod_mission_guess_boss:handle_refresh_cost();
        ?MSG_HERO_VERSUS_BOSS_ROUND ->
            mod_mission_hero_versus_boss:handle_round(State);
%%        ?MSG_ONE_ON_ONE_ROUND_BALANCE ->
%%            mod_mission_one_on_one:handle_round(State);
%%        ?MSG_GUESS_MISSION_ROUND_BALANCE ->
%%            mod_mission_guess_boss:handle_round_new(State);
%%            mod_mission_guess_boss:handle_round(State);
        ?MSG_SHI_SHI_MISSION_ROBOT ->
            mod_mission_shi_shi:handle_robot();
        ?MSG_BRAVE_ONE_INIT_CHECK_SCENE ->
            mod_mission_brave_one:ready_start();
        ?MSG_BRAVE_ONE_NEXT_FIGHT_PLAYER ->
            mod_mission_brave_one:notice_start_fight();
        notice_shi_shi_room_cost ->
            mod_mission_shi_shi_room:notice_shi_shi_room_cost_mana();
        {?MSG_EITHER_TIMER, OldRound, OldType} ->
            mod_mission_either:handle_timer(OldRound, OldType);
        {?MSG_SCENE_BOSS_BET, PlayerId, Type, Id, Num} ->
            mod_mission_scene_boss:handle_scene_boss_bet(PlayerId, Type, Id, Num, State);
        {?MSG_SCENE_BOSS_BET_RESET, PlayerId, Type} ->
            mod_mission_scene_boss:handle_scene_boss_bet_reset(PlayerId, Type);
        ?MSG_SCENE_BOSS_POS_OPEN_BOSS ->
            mod_mission_scene_boss:handle_open_boss(State);
        ?MSG_SCENE_BOSS_POS_BOSS_TELEPORT ->
            mod_mission_scene_boss:handle_boss_teleport(State);
        ?MSG_NOTICE_PLAYER_IN_BET ->
            mod_mission_guess_boss:handle_notice_bet_player_new(State);
%%            mod_mission_guess_boss:handle_notice_bet_player(State);
        _ ->
            exit({no_match, Msg, MissionType})
    end.

%%handle_boss_rebirth(BossId, State) ->
%%    L = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
%%    lists:foreach(
%%        fun(ObjSceneMonsterId) ->
%%            ObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId),
%%            if ObjSceneMonster#obj_scene_actor.base_id == BossId ->
%%                exit(already_live);
%%                true ->
%%                    noop
%%            end
%%        end,
%%        L
%%    ),
%%    {TimerRef, BirthX, BirthY} = get({?DICT_SCENE_MONSTER_REBIRTH_REF, BossId}),
%%    ?ASSERT(TimerRef =/= ?UNDEFINED),
%%    erlang:cancel_timer(TimerRef),
%%    mod_scene_monster_manager:create_monster(BossId, BirthX, BirthY, State).

%% ----------------------------------
%% @doc 	初始化副本
%% @throws 	none
%% @end
%% ----------------------------------
handle_init_mission(MissionType, ExtraDataList) ->
    NowMs = util_time:milli_timestamp(),
    MissionId = util_list:opt(mission_id, ExtraDataList),
    put(?DICT_MISSION_TYPE, MissionType),
    put(?DICT_MISSION_KIND, mod_mission:get_mission_kind(MissionType)),
    put(?DICT_MISSION_ID, MissionId),
    put(?DICT_ACTIVITY_ID, util_list:opt(?DICT_ACTIVITY_ID, ExtraDataList, 0)),
    put(?DICT_ACTIVITY_START_TIME, util_list:opt(?DICT_ACTIVITY_START_TIME, ExtraDataList, 0)),
    mod_mission:set_is_start(false),
    mod_mission:set_is_balance(false),
    mod_mission:set_mission_result(?P_FAIL),
    #t_mission_type{
        continue_time = ContinueTimeMs_0,
        delay_time = DelayTimeMs_0
    } = mod_mission:get_t_mission_type(MissionType),

    {ContinueTimeMs, DelayTimeMs} =
        if MissionType =:= ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType =:= ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
            {util_list:opt(?DICT_MISSION_SCENE_BOSS_BALANCE_MS, ExtraDataList) - NowMs, 0};
            true ->
                {ContinueTimeMs_0, DelayTimeMs_0}
        end,

    put(?DICT_ROUND_AWARD_LIST, []),

    %% 定时器  副本结算
    if ContinueTimeMs > 0 ->
        mod_mission:set_mission_balance_time_ms(NowMs + ContinueTimeMs + DelayTimeMs),
        ?DEBUG("定时器副本结算~p", [{MissionType, MissionId, ContinueTimeMs + DelayTimeMs}]),
        mod_mission:send_msg_delay(?MSG_MISSION_BALANCE, ContinueTimeMs + DelayTimeMs);
        true ->
            mod_mission:set_mission_balance_time_ms(0)
    end,

    %% 定时器  副本启动
    mod_mission:send_msg_delay(?MSG_MISSION_START, DelayTimeMs),
    %% 副本启动时间
    mod_mission:set_mission_start_time_ms(NowMs + DelayTimeMs),

    %% 执行特殊副本初始化逻辑
    if
%%        MissionType == ?MISSION_TYPE_WORLD_BOSS -> %% 世界boss
%%            mod_mission_world_boss:handle_init_mission(ExtraDataList, MissionType, MissionId);
        MissionType == ?MISSION_TYPE_SHISHI_BOSS ->  %% 时时boss
            mod_mission_shi_shi:handle_init_mission(ExtraDataList);
        MissionType == ?MISSION_TYPE_MANY_PEOPLE_SHISHI ->  %% 时时boss
            mod_mission_shi_shi_room:handle_init_mission(ExtraDataList);
        MissionType == ?MISSION_TYPE_MISSION_HERO_PK_BOSS ->
            mod_mission_hero_versus_boss:handle_init_mission(ExtraDataList);
%%        MissionType == ?MISSION_TYPE_GUESS_BOSS ->
%%            mod_mission_one_on_one:handle_init_mission(ExtraDataList);
%%            mod_mission_guess_boss:handle_init_mission_new(ExtraDataList);
%%            mod_mission_guess_boss:handle_init_mission(ExtraDataList);
        MissionType == ?MISSION_TYPE_MANY_PEOPLE_BOSS ->
            %% 多人boss
            mod_mission_many_people_boss:handle_init_mission(ExtraDataList);
        MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS -> %% 勇敢者副本
            mod_mission_brave_one:handle_init_mission(ExtraDataList);
        MissionType == ?MISSION_TYPE_STEP_BY_STEP_SYS -> %% 步步紧逼副本
            mod_mission_step_by_step_sy:handle_init_mission(ExtraDataList);
        MissionType == ?MISSION_TYPE_MISSION_EITHER_OR -> %% 二选一副本
            mod_mission_either:handle_init_mission(ExtraDataList);
        MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
            %% 场景boss副本
            mod_mission_scene_boss:handle_init_mission(ExtraDataList);

        true ->
            noop
    end,
    case mod_mission:get_notice_round_type(MissionType) of
        ?NOTICE_ROUND_TYPE_ROUND ->
            %% 需要通知回合的副本
            noop;
        ?NOTICE_ROUND_TYPE_MONSTER ->
            %% 需要通知副本怪物数量
            %% 怪物总数
            put(?DICT_MONSTER_TOTAL_NUM, mod_mission:get_mission_monster_total_num(MissionType, MissionId) - 1),
            %% 击杀的怪物数量
            put(?DICT_KILL_MONSTER_NUM, 0);
        _ ->
            noop
    end,
    MissionId.

%% ----------------------------------
%% @doc 	开启副本
%% @throws 	none
%% @end
%% ----------------------------------
handle_start_mission(#scene_state{mission_type = MissionType, mission_id = MissionId}) ->
    case mod_mission:is_start() of
        true ->
            noop;
        false ->
            ?DEBUG("副本启动:~p", [{MissionType, MissionId}]),
            mod_mission:set_is_start(true),
            if
%%                MissionType == ?MISSION_TYPE_WORLD_BOSS ->
%%                    mod_mission_world_boss:handle_init_mission_monster();
                true ->
                    noop
            end
    end.

%% ----------------------------------
%% @doc 	玩家进入副本
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_enter_mission(PlayerId, State = #scene_state{mission_type = MissionType, mission_id = MissionId}) ->
    ?DEBUG("handle_player_enter_mission:~p", [{PlayerId, MissionType, MissionId, self()}]),
    mod_scene_player_manager:apply_to_client_worker(PlayerId, hook, after_enter_mission, [PlayerId, MissionType, MissionId]),
    api_mission:notice_mission_close_time(PlayerId, mod_mission:get_mission_balance_time_ms() div 1000),
    case mod_mission:get_notice_round_type(MissionType) of
        ?NOTICE_ROUND_TYPE_ROUND ->
            %% 通知回合
            api_mission:notice_mission_schedule(get_total_round(), get(?DICT_MISSION_ROUND));
        ?NOTICE_ROUND_TYPE_MONSTER ->
            %% 通知怪物数量
            api_mission:notice_mission_schedule(get(?DICT_MONSTER_TOTAL_NUM), get(?DICT_KILL_MONSTER_NUM));
        _ ->
            noop
    end,
    if
%%        MissionType == ?MISSION_TYPE_WORLD_BOSS ->  %% 世界boss
%%            mod_mission_world_boss:handle_enter_mission(PlayerId, State);
        MissionType == ?MISSION_TYPE_SHISHI_BOSS ->  %% 时时boss
            mod_mission_shi_shi:handle_enter_mission(PlayerId, State);
        MissionType == ?MISSION_TYPE_MANY_PEOPLE_SHISHI ->  %% 多人时时房间
            mod_mission_shi_shi_room:handle_enter_mission(PlayerId, State);
        MissionType == ?MISSION_TYPE_MANY_PEOPLE_BOSS ->
            %% 多人boss
            mod_mission_many_people_boss:handle_enter_mission(PlayerId, State);
        MissionType == ?MISSION_TYPE_MISSION_HERO_PK_BOSS ->
            mod_mission_hero_versus_boss:handle_player_enter_mission(PlayerId);
        MissionType == ?MISSION_TYPE_GUESS_BOSS ->
%%            mod_mission_guess_boss:handle_enter_mission(PlayerId);
            mod_mission_one_on_one:handle_enter_mission(PlayerId);
        MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS -> %% 勇敢者副本
            mod_mission_brave_one:handle_enter_mission(PlayerId);
        MissionType == ?MISSION_TYPE_STEP_BY_STEP_SYS -> %% 步步紧逼副本
            mod_mission_step_by_step_sy:handle_enter_mission(PlayerId);
        MissionType == ?MISSION_TYPE_MISSION_EITHER_OR -> %% 二选一副本
            mod_mission_either:handle_enter_mission(PlayerId);
        MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
            %% 场景boss副本
            mod_mission_scene_boss:handle_enter_mission(PlayerId, State);
        true ->
            noop
    end,
    mod_log:enter_mission(PlayerId).

%% ----------------------------------
%% @doc 	怪物进入副本
%% @throws 	none
%% @end
%% ----------------------------------
handle_monster_enter_mission(ObjSceneMonster, _State = #scene_state{mission_type = MissionType, mission_id = _MissionId}) ->
    #obj_scene_actor{
        obj_id = ObjSceneMonsterId
    } = ObjSceneMonster,
    if
        MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS -> %% 勇敢者副本
            mod_mission_brave_one:monster_enter_mission(ObjSceneMonsterId);
        true ->
            noop
    end.

%%%% ----------------------------------
%%%% @doc 	玩家离开副本
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_player_leave_mission(PlayerId) ->
%%    noop.

%% ----------------------------------
%% @doc 	结算副本
%% @throws 	none
%% @end
%% ----------------------------------
handle_balance(State = #scene_state{mission_type = MissionType, mission_id = MissionId}) ->
    ?DEBUG("结算副本:~p", [{MissionType, MissionId}]),
    CommonBalanceFun = fun() ->
        lists:foreach(
            fun(PlayerId) ->
                case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                    ?UNDEFINED ->
                        noop;
                    ObjScenePlayer ->
                        #t_mission{
                            award_id = AwardId
                        } = mod_mission:get_t_mission(MissionType, MissionId),
                        MissionResult = mod_mission:get_mission_result(),
                        #obj_scene_actor{
                            client_node = ClientNode
                        } = ObjScenePlayer,

%%                        #t_mission{
%%                            award_id = AwardId
%%                        } = mod_mission:get_t_mission(MissionType, MissionId),
                        PropList =
                            case get(boss_prop_list) of
                                ?UNDEFINED ->
                                    [];
                                PropList_ ->
                                    PropList_
                            end,

                        TotalAwardList =
                            case MissionType of
%%                                ?MISSION_TYPE_ROLE_BREACH_MISSION ->
%%                                    mod_mission_du_jie:get_mission_award_list(MissionId);
                                _ ->
                                    []
                            end ++ get(?DICT_ROUND_AWARD_LIST) ++ mod_award:decode_award(AwardId),

                        RealAwardList = TotalAwardList ++ PropList,

%%                        ?DEBUG("~p~n", [{TotalAwardList, PropList}]),
%%                        if TotalAwardList =/= [] ->
%%                            mod_apply:apply_to_online_player(ClientNode, PlayerId, mod_award, give, [PlayerId, TotalAwardList, ?LOG_TYPE_MISSION_GET], store);
%%                            true ->
%%                                noop
%%                        end,
%%                        ?DEBUG("副本奖励:~p~n", [{ClientNode, PropList, PlayerId, PropList}]),
                        api_mission:notice_mission_result(PlayerId, MissionType, MissionId, MissionResult, RealAwardList),
                        hook:after_mission_balance(ClientNode, PlayerId, MissionType, MissionId, MissionResult, TotalAwardList)
                end
            end,
            mod_scene_player_manager:get_all_obj_scene_player_id()
        )
                       end,
    case mod_mission:is_balance() of
        false ->
            mod_mission:set_is_balance(true),
            if
%%                MissionType == ?MISSION_TYPE_WORLD_BOSS ->  %% 世界boss
%%                    mod_mission_world_boss:handle_balance(State);
                MissionType == ?MISSION_TYPE_MANY_PEOPLE_BOSS ->
                    %% 多人boss副本
                    mod_mission_many_people_boss:handle_balance(State);
                MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS -> %% 勇敢者副本
                    mod_mission_brave_one:handle_balance(State);
                MissionType == ?MISSION_TYPE_STEP_BY_STEP_SYS -> %% 步步紧逼副本
                    mod_mission_step_by_step_sy:handle_balance(State);
                MissionType == ?MISSION_TYPE_MANY_PEOPLE_SHISHI ->
                    %% 时时房间副本
                    mod_mission_shi_shi_room:handle_balance(State);
                MissionType == ?MISSION_TYPE_MISSION_EITHER_OR ->
                    %% 二选一副本
                    mod_mission_either:handle_balance(State);
                MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
                    %% 场景boss副本
                    mod_mission_scene_boss:handle_balance(State);
                true ->
                    %% 通用结算
                    CommonBalanceFun()
            end,
            %% 销毁所有怪物
            self() ! ?MSG_SCENE_DESTROY_ALL_MONSTER;
        true ->
%%            ?WARNING("副本已经结算:~p~n", [{MissionType, MissionId}]),
            noop
    end.


%% ----------------------------------
%% @doc 	退出副本
%% @throws 	none
%% @end
%% ----------------------------------
handle_leave_mission(PlayerId, _State = #scene_state{mission_type = MissionType, mission_id = _MissionId}) ->
    if
        MissionType == ?MISSION_TYPE_MANY_PEOPLE_BOSS ->
            %% 多人boss
            mod_mission_many_people_boss:handle_leave_mission(PlayerId);
        MissionType == ?MISSION_TYPE_MANY_PEOPLE_SHISHI ->
            %% 时时房间
            mod_mission_shi_shi_room:handle_leave_mission(PlayerId);
        MissionType == ?MISSION_TYPE_MISSION_HERO_PK_BOSS ->
            %% hero versus boss
            mod_mission_hero_versus_boss:handle_leave_mission(PlayerId);
        MissionType == ?MISSION_TYPE_GUESS_BOSS ->
            %% 猜一猜副本
%%            mod_mission_guess_boss:handle_leave_mission(PlayerId),
            mod_mission_one_on_one:handle_leave_mission(PlayerId);
        MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS -> %% 勇敢者副本
            mod_mission_brave_one:handle_leave_mission(PlayerId);
        MissionType == ?MISSION_TYPE_STEP_BY_STEP_SYS -> %% 步步紧逼副本
            mod_mission_step_by_step_sy:handle_leave_mission(PlayerId);
        MissionType == ?MISSION_TYPE_MISSION_EITHER_OR ->
            mod_mission_either:handle_leave_mission(PlayerId);%% 二选一副本
        MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
            mod_mission_scene_boss:handle_leave_mission(PlayerId);%% 场景boss副本
        true ->
            noop
    end,
    mod_log:leave_mission(PlayerId).


%% ----------------------------------
%% @doc 	回合结束
%% @throws 	none
%% @end
%% ----------------------------------
handle_round_end(State) ->
    NowRound = get(?DICT_MISSION_ROUND),
    handle_round_end(NowRound, State).

handle_round_end(EndRound, State) ->
    NowRound = get(?DICT_MISSION_ROUND),
    IsBalance = mod_mission:is_balance(),
    if
        IsBalance == false andalso EndRound == NowRound ->
            ?DEBUG("回合结束:~p", [{NowRound}]),
%%            case mod_mission:is_round_award(MissionType) of
%%                true ->
%%                    %% 回合奖励
%%                    case mod_mission:get_mission_round_award(MissionType, MissionId, NowRound) of
%%                        null ->
%%                            noop;
%%                        R ->
%%                            #t_mission_award{
%%                                award_id = AwardId
%%                            } = R,
%%                            PropList =
%%                                if
%%%%                                    MissionType == ?MISSION_TYPE_XIANYUAN_GEREN orelse MissionType == ?MISSION_TYPE_XIANYUAN_QINGLV ->
%%%%                                    mod_prop:merge_prop_list(mod_award:decode_award(AwardId) ++ get(?DICT_ROUND_AWARD_LIST));
%%                                    true ->
%%                                        mod_award:decode_award(AwardId)
%%                                end,
%%                            put(?DICT_ROUND_AWARD_LIST, PropList),
%%                            api_mission:notice_total_award(PropList)
%%                    end;
%%                _ ->
%%                    noop
%%            end,
            NextRound = NowRound + 1,
            %% 触发下一回合
            trigger_next_round(NextRound, State);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	触发下一回合
%% @throws 	none
%% @end
%% ----------------------------------
trigger_next_round(State) ->
    NowRound = get(?DICT_MISSION_ROUND),
    trigger_next_round(NowRound + 1, State).
trigger_next_round(TriggerRound, #scene_state{scene_id = SceneId, mission_type = MissionType, mission_id = MissionId, is_mission = IsMission}) ->
    NowRound = get(?DICT_MISSION_ROUND),
    ?DEBUG("触发回合:~p", [{TriggerRound}]),
    if
        TriggerRound == NowRound + 1 ->

            SceneMonsterList =
                case lists:member(MissionType, logic_get_can_bet_mission_id:get(1)) of
                    true ->
                        case MissionType of
                            ?MISSION_TYPE_GUESS_BOSS -> ?SD_GUESS_MISSION_BOSS_LIST;
                            ?MISSION_TYPE_MISSION_HERO_PK_BOSS -> ?SD_HERO_VS_BOSS_MISSION_BOSS_LIST
                        end;
                    false -> scene_data:get_scene_monster_list_by_round({SceneId, MissionId, TriggerRound})
                end,
            if
                SceneMonsterList == [] ->
                    if TriggerRound == 1 ->
                        ?DEBUG("副本回合怪物未配置:~p~n", [[{mission_type, MissionType}, {mission_id, MissionId}, {scene_id, SceneId}]]);
                        true ->
                            if MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
                                noop;
                                true ->
                                    %% 场景里面没有怪物， 则结算副本
                                    ?DEBUG("没有怪物, 开始结算副本:~p~n", [{SceneId, MissionId, TriggerRound}]),
                                    mod_mission:set_mission_result(?P_SUCCESS),
                                    mod_mission:send_msg(?MSG_MISSION_BALANCE)
                            end
                    end;
                true ->
                    ?DEBUG("trigger_next_round:~p~n", [{TriggerRound, SceneId, MissionType, MissionId, SceneMonsterList}]),
                    case mod_mission:get_notice_round_type(MissionType) of
                        1 ->
                            TotalRound = get_total_round(),
                            api_mission:notice_mission_schedule(TotalRound, TriggerRound);
%%                        2 ->
%%                            TotalMonsterNum = length(SceneMonsterList),
%%                            put(mission_rounc_monster_total_num, TotalMonsterNum),
%%                            put(mission_rounc_monster_kill_num, 0),
%%                            api_mission:notice_mission_schedule(TotalMonsterNum, 0);
                        _ ->
                            noop
                    end,
%%                    case mod_mission:is_notice_round(MissionType) of
%%                        true ->
%%                            put(mission_rounc_monster_num, length(SceneMonsterList)),
%%                            api_mission:notice_mission_round(TriggerRound),
%%                            api_mission:notice_mission_schedule(20, TriggerRound);
%%                        _ ->
%%                            noop
%%                    end,
                    put(?DICT_MISSION_ROUND, TriggerRound),
                    if IsMission ->
                        if
                            MissionType =:= ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse
                                MissionType =:= ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
                                noop;
                            MissionType =:= ?MISSION_TYPE_MISSION_HERO_PK_BOSS ->
%%                                mod_mission_hero_versus_boss:create_scene_obj(SceneId),
%%                                ?DEBUG("hero_versus_boss: ~p", [{MissionType, ?MISSION_TYPE_MISSION_HERO_PK_BOSS}]);
                                noop;
                            true ->
                                BossPosList =
                                    if
                                        MissionType =:= ?MISSION_TYPE_GUESS_BOSS ->
                                            #t_scene{
                                                monster_x_y_list = MonsterPosList
                                            } = t_scene:get({SceneId}),
%%                                            [{[X, Y], 100} || [X, Y] <- MonsterPosList];
                                            RealMonsterPosList = util_list:shuffle(MonsterPosList),
%%                                            BossListWithWeight = [{Boss, 1} || Boss <- util_list:shuffle(SceneMonsterList)],
%%                                            RealMonsterPosList = MonsterPosList,
                                            BossListWithWeight = [{Boss, 1} || Boss <- SceneMonsterList],
                                            BossList = util_random:get_probability_item_count(BossListWithWeight, 2),
                                            lists:zip(lists:sort(BossList), RealMonsterPosList);
                                        true -> []
                                    end,
                                ?DEBUG("BossPosList: ~p", [{BossPosList, MissionId}]),
                                lists:foreach(
                                    fun(SceneMonsterId) ->
%%                                        #r_scene_monster{
%%                                            delay = Delay
%%                                        } = mod_scene:get_r_scene_monster({SceneId, SceneMonsterId}),
%%                                        ?DEBUG("SceneId: ~p SceneMonsterId: ~p", [SceneId, SceneMonsterId]),
%%                                        ?DEBUG("Res: ~p", [mod_scene:get_r_scene_monster({SceneId, SceneMonsterId})]),
%%                                        erlang:send_after(Delay, self(), {?MSG_SCENE_CREATE_MONSTER, SceneMonsterId})
                                        case length(BossPosList) > 0 of
                                            true ->
                                                ?DEBUG("BossPosList: ~p", [BossPosList]),
                                                ?DEBUG("SceneMonsterId: ~p", [{SceneMonsterId, lists:keyfind(SceneMonsterId, 1, BossPosList)}]),
                                                case lists:keyfind(SceneMonsterId, 1, BossPosList) of
                                                    false -> ok;
                                                    {_, [BirthX, BirthY]} ->
                                                        %% static_data.scv读取猜一猜boss的出生坐标偏移量，并生成新的坐标
                                                        [OffsetMinX, OffsetMaxX, OffsetMinY, OffsetMaxY] = ?SD_GUESS_BOSS_BIRTH_POSITION_RANGE_LIST,
                                                        RealBirthX = BirthX + util_random:random_number(OffsetMinX, OffsetMaxX),
                                                        RealBirthY = BirthY + util_random:random_number(OffsetMinY, OffsetMaxY),
                                                        ?DEBUG("GuessBoss: ~p (~p, ~p) real (~p, ~p)", [SceneMonsterId, BirthX, BirthY, RealBirthX, RealBirthY]),
                                                        ?DEBUG("Res: ~p", [mod_scene:get_r_scene_monster({SceneId, SceneMonsterId})]),
                                                        {RealX, RealY} =
                                                            case mod_map:can_walk_pix(SceneId, RealBirthX, RealBirthY) of
                                                                true -> {RealBirthX, RealBirthY};
                                                                false ->
                                                                    ?WARNING("修正位置:~p", [{SceneId, BirthX, BirthY}]),
                                                                    {BirthX, BirthY}
                                                            end,
                                                        erlang:send_after(100, self(), {?MSG_SCENE_CREATE_MONSTER, SceneMonsterId, RealX, RealY})
                                                end;
%%                                                [[BirthX, BirthY]] = util_random:get_probability_item_count(BossPosList, 1),
                                            %% static_data.scv读取猜一猜boss的出生坐标偏移量，并生成新的坐标
%%                                                [OffsetMinX, OffsetMaxX, OffsetMinY, OffsetMaxY] = ?SD_GUESS_BOSS_BIRTH_POSITION_RANGE_LIST,
%%                                                RealBirthX = BirthX + util_random:random_number(OffsetMinX, OffsetMaxX),
%%                                                RealBirthY = BirthY + util_random:random_number(OffsetMinY, OffsetMaxY),
%%                                                ?DEBUG("GuessBoss: ~p (~p, ~p) real (~p, ~p)", [SceneMonsterId, BirthX, BirthY, RealBirthX, RealBirthY]),
%%                                                ?DEBUG("Res: ~p", [mod_scene:get_r_scene_monster({SceneId, SceneMonsterId})]),
%%                                                {RealX, RealY} =
%%                                                    case mod_map:can_walk_pix(SceneId, RealBirthX, RealBirthY) of
%%                                                        true -> {RealBirthX, RealBirthY};
%%                                                        false -> ?WARNING("修正位置:~p", [{SceneId, BirthX, BirthY}]), {BirthX, BirthY}
%%                                                    end,
%%                                                erlang:send_after(100, self(), {?MSG_SCENE_CREATE_MONSTER, SceneMonsterId,  RealX, RealY});
                                            false ->
                                                #r_scene_monster{
                                                    delay = Delay
                                                } = mod_scene:get_r_scene_monster({SceneId, SceneMonsterId}),
%%                                                ?DEBUG("SceneId: ~p SceneMonsterId: ~p", [SceneId, SceneMonsterId]),
%%                                                ?DEBUG("Res: ~p", [mod_scene:get_r_scene_monster({SceneId, SceneMonsterId})]),
                                                erlang:send_after(Delay, self(), {?MSG_SCENE_CREATE_MONSTER, SceneMonsterId})
                                        end
                                    end,
                                    SceneMonsterList
                                )
                        end;
                        true ->
                            lists:foreach(
                                fun(SceneMonsterId) ->
                                    erlang:send_after(1000, self(), {?MSG_SCENE_CREATE_MONSTER, SceneMonsterId})
                                end,
                                SceneMonsterList
                            )
                    end,
                    case MissionType of
%%                        ?MISSION_TYPE_SHOU_WEI ->
%%                            RoundEndTimeS = lists:nth(TriggerRound, ?SD_SHOU_WEI_ROUND_DELAY),
%%                            erlang:send_after(RoundEndTimeS * 1000, self(), {?MSG_SCENE_MISSION_ROUND_END, TriggerRound});
                        _ ->
                            noop
                    end
            end;
        true ->
            ignore
    end.


get_total_round() ->
    20.

