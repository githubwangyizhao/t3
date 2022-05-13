%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 20. 十二月 2020 下午 04:54:26
%%%-------------------------------------------------------------------
-module(mod_mission_guess_boss).
-author("Administrator").

-include("msg.hrl").
-include("error.hrl").
-include("scene.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("mission.hrl").
-include("p_message.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("guess_boss.hrl").

%% API
-export([
%%    init/0,                             %% 初始化

    get_record/0,                       %% 获得记录
    open_mission/0,
%%    open_action/1,                      %% 开启活动
%%    close_action/1,                     %% 关闭活动
%%    guess_boss_mission_result/4,
    is_enter_mission/2,                 %% 是否进入副本

    handle_init_mission/1,              %% 初始化副本
    handle_init_mission_new/1,          %% 新的初始化副本
    handle_deal_cost/4,                 %% 处理消耗
    handle_refresh_cost/0,              %% 刷新消耗
    handle_enter_mission/1,             %% 进入副本
    handle_balance/1,                   %% 结算
    handle_assert_fight/2,              %% 校验战斗
    handle_leave_mission/1,             %% 离开副本
    handle_round/1,                     %% 轮询
    handle_round_new/1,                 %% 新轮询

    get_db_mission_guess_boss_list/0,
    handle_notice_bet_player/1,         %% 通知投注界面玩家副本状态变化
    handle_notice_bet_player_new/1,     %% 新通知投注界面玩家副本状态变化
    get_player_id_list/0                %% 获取场景内的玩家列表
]).

%% ================================================ FUNCTION ================================================

%% @doc 获得记录
get_record() ->
    DbMissionGuessBossList = rpc:call(mod_server_config:get_war_area_node(), ?MODULE, get_db_mission_guess_boss_list, []),
    ?DEBUG("DbMissionGuessBossList: ~p", [DbMissionGuessBossList]),
    [{Id, BossId} || #db_mission_guess_boss{id = Id, boss_id = BossId} <- DbMissionGuessBossList].

%%init() ->
%%    ActivityIdList = lists:filter(
%%        fun(ActivityId) ->
%%            mod_activity:is_open(ActivityId)
%%        end,
%%        logic_get_activity_id_list_by_mod_name:get(?MODULE)
%%    ),
%%    Length = length(ActivityIdList),
%%    if
%%        Length > 0 ->
%%            open_action(hd(ActivityIdList));
%%        true ->
%%            noop
%%    end,
%%    ok.

%%%% @doc 活动开始
%%open_action(Id) ->
%%    MissionType = ?MISSION_TYPE_GUESS_BOSS,
%%    MissionId = 1,
%%    SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
%%    {_StartTime, EndTime} = mod_activity:get_activity_start_and_end_time(Id),
%%    Time = util_time:milli_timestamp() + ?SD_GUESS_MISSION_TIME - ?SD_GUESS_MISSION_WAIT_TIME,
%%    if
%%        EndTime * ?SECOND_MS > Time ->
%%            scene_master:create_mulit_mission_worker(SceneId, [{mission_id, MissionId}, {?DICT_ACTIVITY_ID, Id}]);
%%        true ->
%%            activity_srv_mod:gm_close_activity(Id)
%%    end.

%% @doc 副本开始
open_mission() ->
    ?DEBUG("open_mission"),
    MissionType = ?MISSION_TYPE_GUESS_BOSS,
    MissionId = 1,
    SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
%%    {_StartTime, EndTime} = mod_activity:get_activity_start_and_end_time(Id),
%%    Time = util_time:milli_timestamp() + ?SD_GUESS_MISSION_TIME - ?SD_GUESS_MISSION_WAIT_TIME,
%%    if
%%        EndTime * ?SECOND_MS > Time ->
    scene_master:create_mulit_mission_worker(SceneId, [{mission_id, MissionId}]),
    ok.
%%        true ->
%%            activity_srv_mod:gm_close_activity(Id)
%%    end.


%%%% @doc 活动结束 关闭副本场景进程
%%close_action({_ActivityId, _ActivityStartTime}) ->
%%    ActivityIdList = lists:filter(
%%        fun(ActivityId) ->
%%            mod_activity:is_open(ActivityId)
%%        end,
%%        logic_get_activity_id_list_by_mod_name:get(?MODULE)
%%    ),
%%    Length = length(ActivityIdList),
%%    if
%%        Length > 0 ->
%%            noop;
%%        true ->
%%            MissionType = ?MISSION_TYPE_GUESS_BOSS,
%%            MissionId = 1,
%%            SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
%%            case scene_master:get_scene_worker(SceneId) of
%%                {ok, SceneWorker} ->
%%                    scene_worker:stop(SceneWorker, ?SCENE_STOP_TIME);
%%                _ ->
%%                    noop
%%            end
%%    end.

%% @doc 战斗结束 回调到玩家进程处理
%%guess_boss_mission_result(PlayerId, BossId, AwardMana, {State, NextTime}) ->
%%    AwardList = [{?PROP_TYPE_RESOURCES, ?RES_MANA, AwardMana}],
%%    if
%%        AwardMana > 0 ->
%%            Tran =
%%                fun() ->
%%                    mod_award:give(PlayerId, [{?PROP_TYPE_RESOURCES, ?RES_MANA, AwardMana}], ?LOG_TYPE_GUESS_BOSS),
%%                    api_mission:notice_guess_boss_mission_time(PlayerId, State, NextTime)
%%                end,
%%            db:do(Tran);
%%        true ->
%%            noop
%%    end,
%%    api_mission:notice_guess_boss_mission_result(PlayerId, BossId, AwardList).

%% @fun 是否能进入副本
is_enter_mission(_PlayerId, MissionId) ->
%%    ?ASSERT(lists:any(
%%        fun(ActivityId) ->
%%            mod_activity:is_open(ActivityId)
%%        end,
%%        logic_get_activity_id_list_by_mod_name:get(?MODULE)), ?ERROR_ACTIVITY_NO_OPEN),
    ?ASSERT(MissionId =:= 1).

%% ================================================ HANDLE ================================================

%% @doc 处理初始化副本
handle_init_mission_new(_ExtraDataList) ->
%%    Time = ?SD_GUESS_MISSION_TIME - ?SD_GUESS_MISSION_ROUND_TIME,
%%    Time = ?SD_GUESS_MISSION_ROUND_TIME,
    %% 3s 后让初始化的boss开始搂
    Time = ?SD_GUESS_MISSION_BET_TIME,
%%    Time = 3000,
    put(?GUESS_MISSION_STATE, {?TRUE, util_time:milli_timestamp() + Time}),
%%    Time = ?SD_GUESS_MISSION_STAND_TIME,
%%    put(?GUESS_MISSION_STATE, {?FALSE, util_time:milli_timestamp() + Time}),
    ?DEBUG("TIME: ~p", [Time]),
    ?DEBUG("put: ~p", [get(?GUESS_MISSION_STATE)]),
    mod_mission:send_msg_delay(?MSG_NOTICE_PLAYER_IN_BET, Time),
    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_ROUND_BALANCE, Time),
    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_REFRESH_COST, 2000).

%% @doc 处理初始化副本
handle_init_mission(_ExtraDataList) ->
    Time = ?SD_GUESS_MISSION_TIME - ?SD_GUESS_MISSION_WAIT_TIME,
    ?DEBUG("TIME: ~p", [Time]),
    put(?GUESS_MISSION_STATE, {?TRUE, util_time:milli_timestamp() + Time}),
    ?DEBUG("put: ~p", [get(?GUESS_MISSION_STATE)]),
    mod_mission:send_msg_delay(?MSG_NOTICE_PLAYER_IN_BET, Time),
    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_ROUND_BALANCE, Time),
    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_REFRESH_COST, 2000).

%% @doc 校验是否可以战斗
handle_assert_fight(ObjId, TargetObjId) ->
    PlayerCostManaList = get_player_cost_mana_list(ObjId),
    PlayerCost = util_list:opt(TargetObjId, PlayerCostManaList, 0),
    ?ASSERT(PlayerCost < ?SD_GUESS_MAX_LIMIT).

%% @doc 处理消耗
handle_deal_cost(PlayerId, ObjId, _BossId, Cost) ->
    mod_log:add_mission_cost(PlayerId, Cost),
    PlayerCostManaList = get_player_cost_mana_list(PlayerId),
    {OldTotalValue, _} = get_guess_boss_player_cost_total_mana(ObjId),
%%    ?DEBUG("猜一猜副本处理消耗~p", [{PlayerId, ObjId, BossId, Cost, PlayerCostManaList}]),
    NewCost =
        case util_list:opt(ObjId, PlayerCostManaList) of
            ?UNDEFINED ->
                put_player_cost_mana_list(PlayerId, [{ObjId, Cost} | PlayerCostManaList]),
                put_guess_boss_player_cost_total_mana(ObjId, {Cost + OldTotalValue, true}),
                Cost;
            OldValue ->
                NewValue =
                    if
                        Cost + OldValue > ?SD_GUESS_MAX_LIMIT ->
                            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                                ?UNDEFINED ->
                                    noop;
                                ObjPlayer ->
                                    rpc:cast(ObjPlayer#obj_scene_actor.client_node, mod_award, give, [PlayerId, [{?ITEM_GOLD, Cost + OldValue - ?SD_GUESS_MAX_LIMIT}], ?LOG_TYPE_GUESS_BOSS])
                            end,
                            ?SD_GUESS_MAX_LIMIT;
                        true ->
                            Cost + OldValue
                    end,
                {value, _Value, NewList} = lists:keytake(ObjId, 1, PlayerCostManaList),
                put_player_cost_mana_list(PlayerId, [{ObjId, NewValue} | NewList]),
                put_guess_boss_player_cost_total_mana(ObjId, {NewValue - OldValue + OldTotalValue, true}),
                NewValue
        end,
    Out = proto:encode(#m_mission_notice_guess_boss_cost_my_mana_toc{
        guess_boss_cost = [#guessbosscost{boss_id = ObjId, num = NewCost}]
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 刷新消耗回调
handle_refresh_cost() ->
%%    ?DEBUG("handle_refresh_cost"),
    PlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
%%    BossIdList = scene_data:get_scene_monster_id_list(9902),
    SceneMonsterRIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
%%    BossIdList = get_boss_id_list(),
    TotalCostList =
        lists:foldl(
            fun(MonsterRId, TmpL) ->
                case get_guess_boss_player_cost_total_mana(MonsterRId) of
                    {Cost, IsCanRefresh} ->
                        case IsCanRefresh of
                            false ->
                                TmpL;
                            true ->
                                put_guess_boss_player_cost_total_mana(MonsterRId, {Cost, false}),
                                [#guessbosscost{boss_id = MonsterRId, num = Cost} | TmpL]
                        end;
                    _ ->
                        TmpL
                end
            end,
            [], SceneMonsterRIdList
        ),
    if
        TotalCostList =:= [] ->
            noop;
        true ->
            lists:foreach(
                fun(PlayerId) ->
                    Out = proto:encode(#m_mission_notice_guess_boss_cost_total_mana_toc{
                        guess_boss_cost = TotalCostList
                    }),
                    mod_socket:send(PlayerId, Out)
                end,
                PlayerIdList
            )
    end,
    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_REFRESH_COST, 1000).

%% @doc 进入副本
handle_enter_mission(PlayerId) ->
%%    ?DEBUG("猜一猜副本玩家进入~p", [PlayerId]),
    List = get_player_id_list(),
    case lists:member(PlayerId, List) of
        true ->
            noop;
        false ->
            put_player_id_list([PlayerId | List])
    end,
    PlayerCostList = get_player_cost_mana_list(PlayerId),
    SceneMonsterRIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
    if
        PlayerCostList =:= [] ->
            noop;
        true ->
            Out1 = proto:encode(#m_mission_notice_guess_boss_cost_my_mana_toc{
                guess_boss_cost = [#guessbosscost{boss_id = ObjId, num = Cost} || {ObjId, Cost} <- PlayerCostList]
            }),
            mod_socket:send(PlayerId, Out1)
    end,
    TotalCostList =
        lists:foldl(
            fun(MonsterRId, TmpL) ->
                case get_guess_boss_player_cost_total_mana(MonsterRId) of
                    {Cost, _IsCanRefresh} ->
                        [#guessbosscost{boss_id = MonsterRId, num = Cost} | TmpL];
                    _ ->
                        TmpL
                end
            end,
            [], SceneMonsterRIdList
        ),
    if
        TotalCostList =:= [] ->
            noop;
        true ->
            Out2 = proto:encode(#m_mission_notice_guess_boss_cost_total_mana_toc{
                guess_boss_cost = TotalCostList
            }),
            mod_socket:send(PlayerId, Out2)
    end,
    {State, EndTimestamp} = get(?GUESS_MISSION_STATE),
    api_mission:notice_guess_boss_mission_time(PlayerId, State, EndTimestamp).

%% @doc 离开副本
handle_leave_mission(PlayerId) ->
    IsDelete =
%%        lists:any(
%%        fun(BossId) ->
%%            case util_list:opt(BossId, get_player_cost_mana_list(PlayerId)) of
%%                ?UNDEFINED ->
%%                    false;
%%                _Cost ->
%%                    true
%%            end
    case get_player_cost_mana_list(PlayerId) of
        [] ->
            true;
        _ ->
            false
    end,
%%        end,
%%        get_boss_id_list()
%%    ),
    if
        IsDelete ->
            put_player_id_list(lists:delete(PlayerId, get_player_id_list()));
        true ->
            noop
    end.

handle_notice_bet_player(State) ->
    {GuessState, _Time} = get(?GUESS_MISSION_STATE),
    Time = util_time:milli_timestamp(),
    {NewState, NewTime} =
        case GuessState of
            ?TRUE ->
                Time1 = Time + (2 * ?SD_GUESS_MISSION_WAIT_TIME),
                {?FALSE, Time1};
            ?FALSE ->
                Time1 = Time + ?SD_GUESS_MISSION_TIME - (2 * ?SD_GUESS_MISSION_WAIT_TIME),
                {?TRUE, Time1}
        end,
    bet_handle:handle_notice_player_mission_status({NewState, NewTime, ?MSG_NOTICE_PLAYER_IN_BET}, State),
    mod_mission:send_msg_delay(?MSG_NOTICE_PLAYER_IN_BET, Time),
    mod_mission:send_msg_delay(?MSG_NOTICE_PLAYER_IN_BET, NewTime - Time).

handle_notice_bet_player_new(_State) ->
    {GuessState, _OldTime} = get(?GUESS_MISSION_STATE),
    Time = util_time:milli_timestamp(),
    {_NewState, NewTime} =
        case GuessState of
            ?TRUE ->
%%                Time1 = Time + ?SD_GUESS_MISSION_STAND_TIME,
%%                {?FALSE, Time1};
                Time1 = Time + ?SD_GUESS_MISSION_ROUND_TIME,
                {3, Time1};
            ?FALSE ->
                Time1 = Time + ?SD_GUESS_MISSION_BET_TIME,
                {?TRUE, Time1};
            2 ->
                Time1 = Time + ?SD_GUESS_MISSION_STAND_TIME,
                {?FALSE, Time1};
            3 ->
                Time1 = Time + ?SD_GUESS_MISSION_ROUND_TIME,
                {2, Time1}
        end,
%%    bet_handle:handle_notice_player_mission_status({NewState, NewTime, ?MSG_NOTICE_PLAYER_IN_BET}, State),
%%    bet_handle:handle_notice_player_mission_status({GuessState, NewTime, ?MSG_NOTICE_PLAYER_IN_BET}, State),
%%    mod_mission:send_msg_delay(?MSG_NOTICE_PLAYER_IN_BET, Time),
    mod_mission:send_msg_delay(?MSG_NOTICE_PLAYER_IN_BET, NewTime - Time).

handle_round_new(State) ->
%%    {_StartTime, EndTime} = get(?GUESS_MISSION_ACTIVITY_TIME),
    {GuessState, _Time} = get(?GUESS_MISSION_STATE),
    ?DEBUG("handle_round GuessState: ~p", [GuessState]),
    Time = util_time:milli_timestamp(),
%%    ?DEBUG("查看时间1~p", [{Time, util_time:milli_timestamp()}]),
    {NewState, NewTime} =
        case GuessState of
            ?TRUE ->
                C = Time div ?SECOND_MS,
                ?INFO("下注结束开始互搂。~p的~p后准备结算",
                    [util_time:timestamp_to_datetime(C), ?SD_GUESS_MISSION_ROUND_TIME / ?SECOND_MS]),
                handle_fight(State),
                Time1 = Time + ?SD_GUESS_MISSION_ROUND_TIME,
                {?TRUE, Time1};
%%            3 ->
%%                D = Time div ?SECOND_MS,
%%                ?DEBUG("boss正在互搂,再延长~p", [D]),
%%                Time1 = Time + ?SD_GUESS_MISSION_ROUND_TIME,
%%                {2, Time1};
            2 ->
                CurrentTime = util_time:milli_timestamp(),
                ?DEBUG("CurrentTime: ~p ~p", [CurrentTime, _Time]),
                Time1 =
                    if
                        _Time >= CurrentTime -> Time + ?SD_GUESS_MISSION_STAND_TIME;
                        true -> Time + ?SD_GUESS_MISSION_STAND_TIME
                    end,
                ?INFO("boss互搂结束开始结算。~p的(~p)后开始新的一轮",
                    [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS), (Time1 - Time) div ?SECOND_MS]),
                %% 1010 = 1100 - 100 + 10
                handle_balance_new(State),
                {?FALSE, Time1};
            ?FALSE ->
                A = Time div ?SECOND_MS,
                ?INFO("新的一轮开始了,玩家开始下注 ~p的~p后玩家下注结束", [
                    util_time:timestamp_to_datetime(A), ?SD_GUESS_MISSION_BET_TIME / ?SECOND_MS
                ]),
                handle_start(State),
                %% 1010 + 30 = 1140
                Time1 = Time + ?SD_GUESS_MISSION_BET_TIME,
                {?TRUE, Time1}
        end,
%%    ?INFO("new handle_round GuessState: ~p ~p ~p", [NewState, NewTime, GuessState]),
    if
        NewState =:= ?TRUE andalso GuessState =:= ?TRUE ->
            %% boss开始搂了，可观战
%%            bet_handle:handle_notice_player_mission_status({?FALSE, NewTime, ?MSG_NOTICE_PLAYER_IN_BET}, State);
            bet_handle:handle_notice_player_mission_status({2, NewTime, ?MSG_NOTICE_PLAYER_IN_BET}, State);
        true ->
            put(?GUESS_MISSION_STATE, {NewState, NewTime}),
            ?DEBUG("mission round: ~p ~p ~p ~p", [NewState, NewTime, State, NewTime - Time]),
            mod_mission:send_msg_delay(?MSG_GUESS_MISSION_ROUND_BALANCE, NewTime - Time),
            if
                NewState =:= ?TRUE andalso GuessState =:= ?FALSE-> ?DEBUG("新的一轮开始: ~p", [{NewState, NewTime, ?MSG_NOTICE_PLAYER_IN_BET}]);
                true -> true
            end,
            ?INFO("给玩家推送六选一状态变化: ~p", [{NewState, NewTime}]),
            bet_handle:handle_notice_player_mission_status({NewState, NewTime, ?MSG_NOTICE_PLAYER_IN_BET}, State)
    end.
%%    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_ROUND_BALANCE, NewTime - Time),
%%    lists:foreach(
%%        fun(PlayerId) ->
%%            api_mission:notice_guess_boss_mission_time(PlayerId, NewState, NewTime)
%%            Out = proto:encode(#m_mission_notice_guess_boss_mission_time_toc{
%%                state = NewState,
%%                timestamp = NewTime div ?SECOND_MS
%%            }),
%%            mod_socket:send(PlayerId, Out)
%%        end,
%%        mod_scene_player_manager:get_all_obj_scene_player_id()
%%    ).

%% @doc 轮询
handle_round(State) ->
%%    {_StartTime, EndTime} = get(?GUESS_MISSION_ACTIVITY_TIME),
    {GuessState, _Time} = get(?GUESS_MISSION_STATE),
    Time = util_time:milli_timestamp(),
%%    ?DEBUG("查看时间1~p", [{Time, util_time:milli_timestamp()}]),
    {NewState, NewTime} =
        case GuessState of
            ?TRUE ->
                handle_balance(State),
                Time1 = Time + (2 * ?SD_GUESS_MISSION_WAIT_TIME),
                {?FALSE, Time1};
            ?FALSE ->
                handle_start(State),
                Time1 = Time + ?SD_GUESS_MISSION_TIME - (2 * ?SD_GUESS_MISSION_WAIT_TIME),
                {?TRUE, Time1}
        end,
%%    ?DEBUG("查看时间2~p", [{NewTime, Time, util_time:milli_timestamp()}]),
%%    if
%%        EndTime > NewTime ->
%%            ?DEBUG("猜一猜副本开始轮询,~p", [{util_time:format_datetime(), NewState, NewTime}]),
    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_ROUND_BALANCE, NewTime - Time),
    put(?GUESS_MISSION_STATE, {NewState, NewTime}),
    lists:foreach(
        fun(PlayerId) ->
            api_mission:notice_guess_boss_mission_time(PlayerId, NewState, NewTime)
        end,
        mod_scene_player_manager:get_all_obj_scene_player_id()
    ).
%%        true ->
%%            activity_srv_mod:gm_close_activity(?DICT_ACTIVITY_ID)
%%    end.

handle_start(State) ->
%%    ?DEBUG("猜一猜副本开始,~p", [util_time:format_datetime()]),
%%     生成怪物之前，先清理掉之前生成的怪物
%%    self() ! ?MSG_SCENE_DESTROY_ALL_MONSTER,
%%    mod_scene_monster_manager:destroy_all_monster(),
%%    #t_mission{
%%        scene_id = SceneId
%%    } = mod_mission:get_t_mission(?MISSION_TYPE_GUESS_BOSS, 1),
%%    SceneMonsterIdList = scene_data:get_scene_monster_id_list(SceneId),
    SceneMonsterIdList = ?SD_GUESS_MISSION_BOSS_LIST,
    case get(guess_boss_notice_chat) of
        ?UNDEFINED ->
            noop;
        {ArgList, NoticeType} ->
            api_chat:notice_system_template_message(?NOTICE_GUESS_MISSION_RESULT_NOTICE, ArgList, NoticeType)
    end,
    mod_scene_monster_manager:create_monster_list(SceneMonsterIdList, State).

handle_winner() ->
    WinnerBossPosId = 10003,
    ?DEBUG("根据大盘指定获胜者"),
    WinnerBossPosId.

handle_fight(_State = #scene_state{mission_type = _MissionType, scene_id = _SceneId, mission_id = _MissionId}) ->
    put(fighting, ?TRUE),
    R = mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER),
%%    ?DEBUG("R: ~p ~p", [R, util_time:get_format_datetime_string()]),
    %% 指定获胜的boss的位置id
    put(guess_boss_winner, handle_winner()),
    erlang:send_after(3000, self(), {?MSG_SCENE_ROBOT_FIGHT}).
%%    mod_scene_monster_manager:get_all_obj_scene_monster_id(State).

handle_balance_new(State) ->
    ?DEBUG("handle_balance_new"),
    GuessBossList = mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER),
    WinnerPosId = util_random:get_list_random_member(GuessBossList),
    #scene_state{
        mission_type = MissionType
    } = State,
    #obj_scene_actor{
        base_id = WinnerBossId
    } = mod_scene_monster_manager:get_obj_scene_monster(WinnerPosId),
    ?DEBUG("WinnerBossId: ~p", [{MissionType, GuessBossList, WinnerBossId}]),
    PosRateTupleList =
        lists:filtermap(
            fun([Pos, BossIdList, Rate]) ->
                case lists:member(WinnerBossId, BossIdList) of
                    true -> {true, {Pos, Rate}};
                    false -> false
                end
            end,
            ?SD_GUESS_RATE_LIST
        ),
    PlayerBetList = mod_bet_player_manager:get_bet_player_list(MissionType),
%%    ?DEBUG("PlayerBetList: ~p", [PlayerBetList]),
    TotalBetLists =
        if
            is_list(PlayerBetList) andalso length(PlayerBetList) >= 1 ->
                lists:foldl(
                    fun({BetPlayerId, BetList}, Tmp) ->
                        SinglePlayerBetList =
                            lists:filtermap(
                                fun({BossPos, Bet}) ->
                                    if
                                        Bet > 0 ->
                                            case lists:keyfind(BossPos, 1, PosRateTupleList) of
                                                {_, Rate} -> {true, {BetPlayerId, util:to_int(Bet * Rate / 10000)}};
                                                false -> false
                                            end;
                                        true -> false
                                    end
                                end,
                                BetList
                            ),
%%                        ?DEBUG("SinglePlayerBetList: ~w", [SinglePlayerBetList]),
                        if
                            length(SinglePlayerBetList) =< 0 -> Tmp;
                            true ->
                                lists:merge(SinglePlayerBetList, Tmp)
                        end
                    end,
                    [],
                    PlayerBetList
                );
            true -> []
        end,
    ?DEBUG("TotalBetLists: ~p ~p", [length(TotalBetLists), TotalBetLists]),

    DoesAnyPlayersBet = length(PlayerBetList),
%%    PlayersInScene = get_player_id_list(),
%%    if
%%        length(PlayersInScene) > 0 ->
%%            lists:foreach(
%%                fun(PlayerId) ->
%%                    NoticeTupleList = [{Pos, Bet} || {Pos, Bet} <- PosRateTupleList],
%%                    ?DEBUG("notify to players in scene: ~p ~p ~p", [PlayerId, WinnerBossId, NoticeTupleList]),
%%                    api_mission:notice_lucky_boss_result(PlayerId, WinnerBossId, NoticeTupleList)
%%                end,
%%                get_player_id_list()
%%            );
%%        true -> ?DEBUG("nobody in guess boss scene.no needs to notificate the result")
%%    end,
    PlayerHasBeenLeaved = mod_bet_player_manager:get_bet_player_leave_list(MissionType),
%%    ?DEBUG("PlayerHasBeenLeaved: ~p", [PlayerHasBeenLeaved]),
%%    ?DEBUG("players in secene: ~p", [get_player_id_list()]),
%%    ?DEBUG("DoesAnyPlayersBet: ~p", [DoesAnyPlayersBet]),
    if
        DoesAnyPlayersBet > 0 ->
%%            ?DEBUG("PlayerHasBeenLeaved: ~p", [PlayerHasBeenLeaved]),
%%            ?DEBUG("PlayerInBet: ~p", [[PlayerId || {PlayerId, _Bet} <- PlayerBetList]]),
            lists:foreach(
                fun({BetPlayerId, BetList}) ->
                    NoticePlayerId =
                        case lists:member({BetPlayerId}, PlayerHasBeenLeaved) of
                            false -> BetPlayerId;
                            true ->
                                lists:member(BetPlayerId, get_player_id_list())
                                %% 不在投注队列，但在场景里。表明玩家是从投注页面进入场景的
                                %% 为保证其退出场景后，投注界面能正常接收推送消息，因此将其加入投注队列
%%                                mod_bet_player_manager:add_bet_player_list(MissionType, {BetPlayerId, BetList})
                        end,
                    if
                        NoticePlayerId =/= false ->
                            NoticeTupleList =
                                lists:filtermap(
                                    fun({Pos, Rate}) ->
                                        case lists:keyfind(Pos, 1, BetList) of
                                            {_, Bet} ->
                                                {true, {?ITEM_RMB, util:to_int(Rate * Bet / 10000)}};
                                            false -> {true, {?ITEM_RMB, 0}}
                                        end
                                    end,
                                    PosRateTupleList
                                ),
                            Node = mod_player:get_game_node(BetPlayerId),
%%                            ?DEBUG("NoticeTupleList: ~p", [NoticeTupleList]),
                            ?DEBUG("notify to players who in bet page: ~p(~p)", [
                                mod_apply:apply_to_online_player(Node, BetPlayerId, mod_bet, handle_notice,
                                    [BetPlayerId, [WinnerBossId, NoticeTupleList], ?MSG_NOTICE_PLAYER_IN_BET_RESULT], store),
                                Node]);
                        true -> true % ?DEBUG("不推送中奖信息: ~p", [NoticePlayerId])
                    end
                end,
                PlayerBetList
            );
        true -> true % ?DEBUG("nobody in bet page.no needs to notificate the result")
    end,

    %% 没人下注，不做结算
    AwardList =
        if
            length(TotalBetLists) >= 1 ->
                RealBetLists = ?IF(length(TotalBetLists) == 1, TotalBetLists, mod_prop:merge_prop_list(TotalBetLists)),
%%                ?DEBUG("RealBetLists: ~p", [RealBetLists]),
%%                ?DEBUG("clear players bet"),
                RealBetLists;
            true -> []
        end,
    {AwardPlayers, TotalAward} =
        if
            length(AwardList) > 0 ->
                TotalAwardList =
                    lists:filtermap(
                        fun ({PlayerId, Award}) ->
                            Node = mod_player:get_game_node(PlayerId),
%%                            ?DEBUG("Node: ~p PlayerId: ~p Award: ~p ~p", [Node, PlayerId, Award, lists:member({PlayerId}, PlayerHasBeenLeaved)]),
                            Mailing =
                                case lists:member({PlayerId}, PlayerHasBeenLeaved) of
                                    false -> ?FALSE;
                                    true ->
                                        case lists:member(PlayerId, get_player_id_list()) of
                                            false -> ?TRUE;
                                            _MatchPlayerId -> ?FALSE
                                        end
                                end,
%%                            ?DEBUG("~p Mailing: ~p ~p", [PlayerId, Mailing, {lists:member(PlayerId, get_player_id_list()), lists:member({PlayerId}, PlayerHasBeenLeaved)}]),
                            if
                                Mailing =:= ?TRUE ->
                                    mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list,
                                        [PlayerId, ?MAIL_GUESS_BOSS_BALANCE, [{?ITEM_RMB, Award}], [WinnerBossId, Award], ?LOG_TYPE_GUESS_BOSS], store);
                                true ->
                                    mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give,
                                        [PlayerId, [{?ITEM_RMB, Award}], ?LOG_TYPE_GUESS_BOSS], store)
                            end,
                            %% 离开投注界面的玩家用发邮件的方式给奖励
%%                            api_mission:notice_lucky_boss_result(PlayerId, WinnerBossId, [{?ITEM_GOLD, 0}]),
                            {true, Award}
                        end,
                        AwardList
                    ),
                {length(AwardList), lists:sum(TotalAwardList)};
            true -> ?DEBUG("没人猜中"), {0, 0}
        end,
    TotalCostList =
        lists:filtermap(
            fun({PlayerId, BetsInfoList}) ->
                SinglePlayerBets = [ Cost || {_, Cost} <- BetsInfoList],
                {true, {PlayerId, lists:sum(SinglePlayerBets)}}
            end,
            PlayerBetList
        ),
    TotalCost = ?IF(length(TotalCostList) >= 1, lists:sum([SingleTotalCost || {_, SingleTotalCost} <- TotalCostList]), 0),
    bet_handle:handle_destroy_player_list(State),
    #t_notice{
        notice_type = NoticeType
    } = t_notice:assert_get({?NOTICE_GUESS_MISSION_RESULT_NOTICE}),
    ArgList = [util:to_binary(Arg) || Arg <- [AwardPlayers, TotalAward]],

%%    api_chat:notice_system_template_message(?NOTICE_GUESS_MISSION_RESULT_NOTICE, ArgList, NoticeType),
    put(guess_boss_notice_chat, {ArgList, NoticeType}),

    NewNumber = mod_server_data:get_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER) + 1,
    NewDbMissionGuessBoss =
        #db_mission_guess_boss{
            id = NewNumber,
            boss_id = WinnerBossId,
            player_total_cost = TotalCost,
            player_total_award = TotalAward,
            time = util_time:timestamp()
        },
    Tran =
        fun() ->
            mod_server_data:set_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER, NewNumber),
            db:write(NewDbMissionGuessBoss),
            if
                NewNumber > 50 ->
                    db:delete(get_db_mission_guess_boss(NewNumber - 50));
                true ->
                    noop
            end
        end,
    db:do(Tran),
%%    ?TRY_CATCH(mod_log:balance_mission(?MISSION_TYPE_GUESS_BOSS, 1, ?LOG_TYPE_GUESS_BOSS)).
    ?TRY_CATCH(mod_log:balance_mission(?MISSION_TYPE_GUESS_BOSS, 1, ?LOG_TYPE_GUESS_BOSS)),
    mod_mission_boss_fight:reset_boss_skill(),
%%    self() ! ?MSG_SCENE_DESTROY_ALL_MONSTER,
%%    self() ! shot_all_player.
    erlang:send_after(5000, self(), ?MSG_SCENE_DESTROY_ALL_MONSTER),
    erlang:send_after(8000, self(), shot_all_player).

%% @doc 副本结算
handle_balance(_State) ->
    SceneMonsterRIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
    {MonsterObjId, BossIdList, ResultFightList} = get_result_fight(SceneMonsterRIdList),
    #obj_scene_actor{
        base_id = RandomBossId
    } = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
    PlayerIdList = get_player_id_list(),
    TotalPeopleNum = lists:foldl(
        fun(PlayerId, TmpTotalPeopleNum) ->
            case lists:keymember(MonsterObjId, 1, get_player_cost_mana_list(PlayerId)) of
                true ->
                    TmpTotalPeopleNum + 1;
                false ->
                    TmpTotalPeopleNum
            end
        end,
        0, PlayerIdList
    ),
    lists:foreach(
        fun(PlayerId) ->
            PlayerCostManaList = get_player_cost_mana_list(PlayerId),
            CostMana = case util_list:opt(MonsterObjId, PlayerCostManaList) of
                           ?UNDEFINED ->
                               0;
                           CostMana1 ->
                               CostMana1
                       end,
            delete_player_cost_mana_list(PlayerId),
%%            AwardMana = CostMana * ?SD_GUESS_RATE div 10000,
            AwardMana = CostMana,
            ParamList = [RandomBossId, CostMana, AwardMana],
            Node = mod_player:get_game_node(PlayerId),
            ?IF(
                AwardMana > 0,
                mod_apply:apply_to_online_player(Node, PlayerId, mod_conditions, add_conditions, [PlayerId, {?CON_ENUM_GUESS_BOSS_WIN, ?CONDITIONS_VALUE_ADD, 1}], store),
                noop
            ),
            mod_log:add_mission_award(PlayerId, AwardMana),
            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                ?UNDEFINED ->
                    if
                        AwardMana > 0 ->
                            rpc:cast(Node, mod_mail, add_mail_param_item_list, [PlayerId, ?MAIL_GUESS_BOSS_BALANCE, [{?ITEM_GOLD, AwardMana}], ParamList, ?LOG_TYPE_GUESS_BOSS]);
                        true ->
                            noop
%%                            rpc:cast(Node, mod_mail, add_mail_param, [PlayerId, ?MAIL_GUESS_BOSS_BALANCE, ParamList, ?LOG_TYPE_GUESS_BOSS])
                    end,
                    put_player_id_list(lists:delete(PlayerId, get_player_id_list()));
                _ObjActor ->
                    ?IF(CostMana > 0, mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give, [PlayerId, [{?ITEM_GOLD, AwardMana}], ?LOG_TYPE_GUESS_BOSS], store), noop),
                    PlayerTotalCost = lists:sum([Cost || {_, Cost} <- PlayerCostManaList]),
                    api_mission:notice_guess_boss_mission_result(PlayerId, RandomBossId, [{?ITEM_GOLD, AwardMana}], BossIdList, ResultFightList, PlayerTotalCost)
            end
        end,
        PlayerIdList
    ),
    TotalAward =
        case delete_guess_boss_player_cost_total_mana(MonsterObjId) of
            ?UNDEFINED ->
                0;
            {ThisValue, _} ->
%%                ThisValue * ?SD_GUESS_RATE div 10000
                ThisValue
        end,
    TotalCost =
        lists:foldl(
            fun(ThisMonsterObjId, Cost) ->
                case delete_guess_boss_player_cost_total_mana(ThisMonsterObjId) of
                    ?UNDEFINED ->
                        Cost;
                    {Value, _} ->
                        Cost + Value
                end
            end,
            0, SceneMonsterRIdList
        ),
    #t_notice{
        notice_type = NoticeType
    } = t_notice:assert_get({?NOTICE_GUESS_MISSION_RESULT_NOTICE}),
    ArgList = [util:to_binary(Arg) || Arg <- [TotalPeopleNum, TotalAward]],

%%    api_chat:notice_system_template_message(?NOTICE_GUESS_MISSION_RESULT_NOTICE, ArgList, NoticeType),
    put(guess_boss_notice_chat, {ArgList, NoticeType}),

    NewNumber = mod_server_data:get_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER) + 1,
    NewDbMissionGuessBoss =
        #db_mission_guess_boss{
            id = NewNumber,
            boss_id = RandomBossId,
            player_total_cost = TotalCost,
            player_total_award = TotalAward,
            time = util_time:timestamp()
        },
    Tran =
        fun() ->
            mod_server_data:set_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER, NewNumber),
            db:write(NewDbMissionGuessBoss),
            if
                NewNumber > 50 ->
                    db:delete(get_db_mission_guess_boss(NewNumber - 50));
                true ->
                    noop
            end
        end,
    db:do(Tran),
%%    ?TRY_CATCH(mod_log:balance_mission(?MISSION_TYPE_GUESS_BOSS, 1, ?LOG_TYPE_GUESS_BOSS)).
    ?TRY_CATCH(mod_log:balance_mission(?MISSION_TYPE_GUESS_BOSS, 1, ?LOG_TYPE_GUESS_BOSS)),
    self() ! ?MSG_SCENE_DESTROY_ALL_MONSTER.

get_result_fight(IdList) ->
    NewIdList = util_list:shuffle(IdList),
    NewIdList2 = util_list:shuffle(IdList),
    get_result_fight(NewIdList, NewIdList, {NewIdList2, []}, 1).
get_result_fight([Id], _CanAttackIdList, {IdList, ResultFightList}, _Round) ->
    Fun =
        fun(MonsterObjId) ->
            #obj_scene_actor{
                base_id = RandomBossId
            } = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
            RandomBossId
        end,
    FunList =
        fun(MonsterObjIdList) ->
            [Fun(MonsterObjId) || MonsterObjId <- MonsterObjIdList]
        end,
    {Id, FunList(IdList), [{Round, Fun(AttackId), FunList(DieBossIdList)} || {Round, AttackId, DieBossIdList} <- ResultFightList]};
get_result_fight(AliveIdList, CanAttackIdList, {IdList, ResultFightList}, Round) ->
%%    ?DEBUG("轮次~p,存活列表~p ，可攻击列表~p，上次的结果列表~p，队列~p", [Round, AliveIdList, CanAttackIdList, ResultFightList, IdList]),
    AttackId = lists:nth(util_random:random_number(length(CanAttackIdList)), CanAttackIdList),
    TargetIdList = AliveIdList -- [AttackId],
    DieNum =
        if
            Round < 5 ->
                case util_random:p(5000) of
                    true ->
                        1;
                    false ->
                        0
                end;
            true ->
                P = 10000 * length(TargetIdList) div (11 - Round),
                DieNum1 = P div 10000,
                P2 = P rem 10000,
                DieNum2 =
                    case util_random:p(P2) of
                        true ->
                            1;
                        false ->
                            0
                    end,
                DieNum1 + DieNum2
        end,

    {DieBossIdList, NewCanAttackList} = lists:split(DieNum, TargetIdList),
    get_result_fight(NewCanAttackList ++ [AttackId], NewCanAttackList, {IdList, [{Round, AttackId, DieBossIdList} | ResultFightList]}, Round + 1).

%%get_result_fight(SceneMonsterRIdList) ->
%%    BossIdList = [
%%        begin
%%            #obj_scene_actor{
%%                base_id = BossId
%%            } = ?GET_OBJ_SCENE_MONSTER(SceneMonsterRId),
%%            BossId
%%        end
%%        || SceneMonsterRId <- SceneMonsterRIdList
%%    ],
%%    get_result_fight_1(BossIdList).

%% @TODO  旧的版本，一般打二到三轮，新版要打五轮到十轮
%%get_result_fight(IdList) ->
%%    NewIdList = util_list:shuffle(IdList),
%%    NewIdList2 = util_list:shuffle(IdList),
%%    get_result_fight(NewIdList, NewIdList, {NewIdList2, []}, 1).
%%get_result_fight([Id], _CanAttackIdList, {IdList, ResultFightList}, _Round) ->
%%    Fun =
%%        fun(MonsterObjId) ->
%%            #obj_scene_actor{
%%                base_id = RandomBossId
%%            } = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
%%            RandomBossId
%%        end,
%%    FunList =
%%        fun(MonsterObjIdList) ->
%%            [Fun(MonsterObjId) || MonsterObjId <- MonsterObjIdList]
%%        end,
%%    {Id, FunList(IdList), [{Round, Fun(AttackId), FunList(DieBossIdList)} || {Round, AttackId, DieBossIdList} <- ResultFightList]};
%%get_result_fight(AliveIdList, CanAttackIdList, {IdList, ResultFightList}, Round) ->
%%%%    ?DEBUG("轮次~p,存活列表~p ，可攻击列表~p，上次的结果列表~p，队列~p", [Round, AliveIdList, CanAttackIdList, ResultFightList, IdList]),
%%    AttackId = lists:nth(util_random:random_number(length(CanAttackIdList)), CanAttackIdList),
%%    TargetIdList = AliveIdList -- [AttackId],
%%    DieNum = util_random:random_number(0, length(TargetIdList)),
%%
%%    {DieBossIdList, NewCanAttackList} = lists:split(DieNum, TargetIdList),
%%    get_result_fight(NewCanAttackList ++ [AttackId], NewCanAttackList, {IdList, [{Round, AttackId, DieBossIdList} | ResultFightList]}, Round + 1).

%%get_result_fight(LastBossId,SceneMonsterRIdList) ->
%%    BossIdList = [
%%        begin
%%            #obj_scene_actor{
%%                base_id = BossId
%%            } = ?GET_OBJ_SCENE_MONSTER(SceneMonsterRId),
%%            BossId
%%        end
%%        || SceneMonsterRId <- SceneMonsterRIdList
%%    ],
%%    RoundNum = util_random:get_probability_item([{Key,Value} ||[Key,Value]<- ?SD_GUESS_BOSS_TIMES_WEIGHTS]),
%%    NewBossIdList  = util_list:shuffle(BossIdList -- [LastBossId]),
%%    Num = util_random:random_number(0,length(NewBossIdList) - RoundNum + 1),
%%    {L1,L2} = lists:split(Num,NewBossIdList),
%%    List = [{RoundNum,LastBossId,L1}],
%%    AccBossIdList =
%%    get_result_fight(RoundNum - 1,List,L2,NewBossIdList).
%%get_result_fight(RoundNum,List,DieBossIdList,AccBossIdList) ->
%%    NewAccBossIdList =
%%    if
%%        AccBossIdList =:= [] ->
%%            [
%%                begin
%%                    #obj_scene_actor{
%%                        base_id = BossId
%%                    } = ?GET_OBJ_SCENE_MONSTER(SceneMonsterRId),
%%                    BossId
%%                end
%%                || SceneMonsterRId <- mod_scene_monster_manager:get_all_obj_scene_monster_id()
%%            ];
%%        true ->
%%            AccBossIdList
%%    end,
%%    Num = util_random:random_number(0,length(NewBossIdList) - RoundNum + 1),
%%    {L1,L2} = lists:split(Num,NewBossIdList),
%%    NewList = [{RoundNum,LastBossId,L1}|List],
%%get_result_fight(LastBossId,SceneMonsterRIdList) ->
%%    BossIdList = [
%%        begin
%%            #obj_scene_actor{
%%                base_id = BossId
%%            } = ?GET_OBJ_SCENE_MONSTER(SceneMonsterRId),
%%            BossId
%%        end
%%        || SceneMonsterRId <- SceneMonsterRIdList
%%    ],
%%    RoundNum = util_random:get_probability_item([{Key,Value} ||[Key,Value]<- ?SD_GUESS_BOSS_TIMES_WEIGHTS]),
%%    get_result_fight(LastBossId,SceneMonsterRIdList).


%% @doc 获得boss——id列表
%%get_boss_id_list() ->
%%    #t_mission{
%%        scene_id = SceneId
%%    } = mod_mission:get_t_mission(?MISSION_TYPE_GUESS_BOSS, 1),
%%    SceneMonsterIdList = scene_data:get_scene_monster_id_list(SceneId),
%%    lists:map(
%%        fun(SceneMonsterId) ->
%%            #r_scene_monster{
%%                monster_id = MonsterId
%%            } = scene_data:get_scene_monster({SceneId, SceneMonsterId}),
%%            MonsterId
%%        end,
%%        SceneMonsterIdList
%%    ).

%% ================================================ UTIL ================================================
get_guess_boss_player_cost_total_mana(BossId) ->
    case get({guess_boss_player_cost_total_mana, BossId}) of
        undefined ->
            {0, false};
        _Value ->
            _Value
    end.
put_guess_boss_player_cost_total_mana(BossId, Data) ->
    put({guess_boss_player_cost_total_mana, BossId}, Data).
delete_guess_boss_player_cost_total_mana(BossId) ->
    erase({guess_boss_player_cost_total_mana, BossId}).

get_player_cost_mana_list(PlayerId) ->
    case get({guess_boss_player_cost_mana_list, PlayerId}) of
        undefined ->
            [];
        _Value ->
            _Value
    end.
put_player_cost_mana_list(PlayerId, List) ->
    put({guess_boss_player_cost_mana_list, PlayerId}, List).
delete_player_cost_mana_list(PlayerId) ->
    erase({guess_boss_player_cost_mana_list, PlayerId}).

get_player_id_list() ->
    case get(guess_boss_player_id_list) of
        undefined ->
            [];
        _Value ->
            _Value
    end.
put_player_id_list(List) ->
    put(guess_boss_player_id_list, List).
%%delete_player_id_list() ->
%%    erase(guess_boss_player_id_list).

%% ================================================ 数据操作 ================================================
%% @doc DB 获得猜一猜副本
get_db_mission_guess_boss(Id) ->
    db:read(#key_mission_guess_boss{id = Id}).
get_db_mission_guess_boss_list() ->
    ets:tab2list(mission_guess_boss).
