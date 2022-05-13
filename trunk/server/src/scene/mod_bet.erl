%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 5月 2021 下午 12:11:37
%%%-------------------------------------------------------------------
-module(mod_bet).
-author("Administrator").

-include("common.hrl").
-include("mission.hrl").
-include("gen/table_enum.hrl").
-include("error.hrl").
-include("guess_boss.hrl").

%% API
-export([
    player_into_bet/2,
    player_into_bet/4,   %% 玩家投注
    player_leave_bet/2,     %% 玩家退出所有投注界面队列
%%    player_leave_bet/2,
    player_reset_bet/2,     %% 清空玩家投注

    handle_notice/3,

    player_bet_in_scene/4
]).

-include("p_message.hrl").

%% 接收战区服的数据，并下发给指定客户端
handle_notice(PlayerId, Params, NoticeType) ->
    ?INFO("handle_bet_notice: ~p ~p ~p", [PlayerId, Params, NoticeType]),
    Out =
        case NoticeType of
            %% boss互搂结束后，给投注界面内玩家推送战斗结果
            ?MSG_NOTICE_PLAYER_IN_BET_RESULT ->
                [WinnerBossId, AwardTupleList] = Params,
                ?DEBUG("给~p推送战斗结果: ~p", [WinnerBossId, AwardTupleList]),
                #m_mission_notice_hero_versus_boss_result_toc{
                    boss_id = WinnerBossId, award_list = [#prop{prop_id = PropId, num = Num} || {PropId, Num} <- AwardTupleList]
                };
%%                #m_mission_notice_lucky_boss_result_toc{
%%                    boss_id = WinnerBossId, award_list = [#prop{prop_id = PropId, num = Num} || {PropId, Num} <- AwardTupleList]
%%                };
            %% 玩家进入投注界面
            ?MSG_PLAYER_INTO_GUESS_MISSION_BET ->
                [BetPlayersList, LeaveBetPlayersList, GuessStatus, Time] = Params,
                ?DEBUG("MSG_PLAYER_INTO_GUESS_MISSION_BET: ~p ~p ~p", [PlayerId, GuessStatus, Time]),
%%                ?DEBUG("MSG_PLAYER_INTO_GUESS_MISSION_BET: ~p ~p", [GuessStatus, Time]),
                Count = ?IF(is_list(BetPlayersList) andalso is_list(LeaveBetPlayersList),
                    length(BetPlayersList) - length(LeaveBetPlayersList), 0),
                #m_mission_hero_versus_boss_status_toc{state = GuessStatus, timestamp = Time div ?SECOND_MS, players = Count, operation = 2};
            %% 玩家离开投注界面
            ?MSG_PLAYER_LEAVE_GUESS_MISSION_BET ->
                [BetPlayersList, LeaveBetPlayersList, GuessStatus, Time] = Params,
                ?DEBUG("离开投注界面：~p", [{PlayerId, GuessStatus, util_time:timestamp_to_datetime(Time div ?SECOND_MS)}]),
                Count = ?IF(is_list(BetPlayersList) andalso is_list(LeaveBetPlayersList),
                    length(BetPlayersList) - length(LeaveBetPlayersList), 0),
                #m_mission_hero_versus_boss_status_toc{state = GuessStatus, timestamp = Time div ?SECOND_MS, players = Count};
            %% 玩家投注
            ?MSG_PLAYER_BET ->
                Params;
            ?MSG_PLAYER_RESET_BET ->
                ?DEBUG("player reset bet: ~p", [{NoticeType, Params}]),
                Params;
            %% 通知玩家猜一猜的状态与时间
            ?MSG_NOTICE_PLAYER_IN_BET ->
                [BetPlayersList, LeaveBetPlayersList, GuessStatus, Time] = Params,
                ?DEBUG("MSG_NOTICE_PLAYER_IN_BET: ~p ~p ~p ~p", [GuessStatus, util_time:timestamp_to_datetime(Time div ?SECOND_MS), length(BetPlayersList), length(LeaveBetPlayersList)]),
                if
                    GuessStatus =:= 2 ->
                        OutToc =
                            #m_mission_hero_versus_boss_status_toc{
                                players = ?IF(is_list(BetPlayersList) andalso is_list(LeaveBetPlayersList),
                                    length(BetPlayersList) - length(LeaveBetPlayersList), 0),
                                state = GuessStatus,
                                timestamp = Time div ?SECOND_MS,
                                operation = 3
                            },
                        ?DEBUG("toc: ~p", [OutToc]),
                        OutToc;
                    true ->
                        #m_mission_hero_versus_boss_status_toc{
                            players = ?IF(is_list(BetPlayersList) andalso is_list(LeaveBetPlayersList),
                                length(BetPlayersList) - length(LeaveBetPlayersList), 0),
                            state = GuessStatus,
                            timestamp = Time div ?SECOND_MS
                        }
                end
        end,
    ?INFO("Out ok? ~p", [{PlayerId, mod_socket:send(PlayerId, proto:encode(Out))}]),
    ok.

get_scene_worker(SceneId) ->
    case scene_master:get_scene_worker(SceneId) of
        null -> ?ERROR("多人副本不存在"), exit(?ERROR_NOT_EXISTS);
        {ok, SceneWorker} -> SceneWorker;
        Other -> ?ERROR("获取多人副本非预期错误: ~p", [Other]), exit(unknown)
    end.

player_leave_bet(PlayerId, ClearBet) when is_atom(ClearBet) ->
    lists:foreach(
        fun (MissionType) ->
            if
                ClearBet =:= true -> ?DEBUG("清理玩家(~p)在~p的投注数据", [PlayerId, MissionType]);
                true -> ?DEBUG("不清理玩家(~p)在~p的投注数据", [PlayerId, MissionType])
            end,
            player_leave_bet(PlayerId, MissionType)
        end,
        logic_get_can_bet_mission_id:get(1)
    );
player_leave_bet(PlayerId, MissionType) when is_integer(MissionType) ->
%%    ?DEBUG("PlayerId: ~p MissionType: ~p ~p", [PlayerId, MissionType, lists:member(MissionType, logic_get_can_bet_mission_id:get(1))]),
    ?ASSERT(lists:member(MissionType, logic_get_can_bet_mission_id:get(1)) =:= true, ?ERROR_NOT_CAN_BE_BET),
    SceneId = mod_mission:get_scene_id_by_mission(MissionType, 1),
    SceneWorker = get_scene_worker(SceneId),
%%    case gen_server:call(SceneWorker, {?MSG_PLAYER_LEAVE_GUESS_MISSION_BET, PlayerId}) of
    case gen_server:cast(SceneWorker, {?MSG_PLAYER_LEAVE_GUESS_MISSION_BET, PlayerId}) of
        {error, Reason} ->
            exit(Reason);
        Result when is_tuple(Result) ->
            {BetPlayersList, LeaveBetPlayersList, GuessStatus, Time} = Result,
%%            ?DEBUG("Result: ~p", [Result]),
            {
                ?IF(is_list(BetPlayersList) andalso is_list(LeaveBetPlayersList),
                    length(BetPlayersList) - length(LeaveBetPlayersList), 0),
                GuessStatus,
                Time div ?SECOND_MS
            };
        O ->
            ?ERROR("非预期接口: ~p", [O]), exit(unknown)
    end.

player_bet_in_scene(MissionType, PlayerId, Pos, Bet) ->
    %% 获取投注所消耗的道具
    Fun =
        fun() ->
            BetTupleList =
                lists:foldl(
                    fun ([StaticDataPos, _Rate], Tmp) ->
                        ?DEBUG("PlayerId: ~p", [{PlayerId, StaticDataPos, Pos}]),
                        if
                            Pos =:= StaticDataPos andalso Bet > 0 ->
                                ItemIdList =
                                    lists:filtermap(
                                        fun([ItemId, Cost]) ->
                                            ?IF(Pos =:= StaticDataPos andalso Bet =:= Cost, {true, {ItemId, Cost}}, false)
                                        end,
                                        ?SD_GUESS_COST_LIST
                                    ),
                                if
                                    length(ItemIdList) >= 1 ->
                                        {RealItemId, RealCost} = hd(ItemIdList),
                                        mod_prop:decrease_player_prop(PlayerId, [RealItemId, RealCost], ?LOG_TYPE_GUESS_BOSS);
                                    true -> ?ERROR("玩家非法投注：~p ~p", [StaticDataPos, Bet]),exit(invalid_bet)
                                end;
                            true ->
                                ?DEBUG("玩家没有对StaticDataPos的boss进行投注")
                        end,
                        [{StaticDataPos, ?IF(StaticDataPos =:= Pos, Bet, 0)} | Tmp]
                    end,
                    [],
                    ?SD_GUESS_RATE_LIST
                ),
            SceneId = mod_mission:get_scene_id_by_mission(MissionType, 1),
            SceneWorker = get_scene_worker(SceneId),
            case gen_server:call(SceneWorker, {?MSG_PLAYER_BET, {PlayerId, BetTupleList}}) of
                {error, Reason} ->
                    exit(Reason);
                Result ->
                    ?DEBUG("Result: ~p ", [Result])
%%                    {_BetPlayersList, _LeaveBetPlayersList, GuessStatus, Time} = Result,
%%                    ?DEBUG("Result: ~p GuessStatus: ~p Time: ~p", [Result, GuessStatus, Time])
            end
        end,
    R = db:do(Fun),
    ?DEBUG("投注事务执行结果: ~p", [R]),
    ok.

player_into_bet(MissionType, PlayerId) ->
    BetTupleList = [ {Pos, 0} || [Pos, _, _] <- ?SD_GUESS_RATE_LIST],
%%    ?DEBUG("BetTupleList: ~p", [BetTupleList]),

    SceneId = mod_mission:get_scene_id_by_mission(MissionType, 1),
    SceneWorker = get_scene_worker(SceneId),
    case gen_server:call(SceneWorker, {?MSG_PLAYER_INTO_GUESS_MISSION_BET, {PlayerId, BetTupleList}}) of
        {error, Reason} ->
            exit(Reason);
        Result ->
            {BetPlayersList, LeaveBetPlayersList, GuessStatus, Time} = Result,
%%            ?DEBUG("length: ~p PlayerList: ~p", [length(BetPlayersList), BetPlayersList]),
%%            ?DEBUG("length: ~p PlayerLeavelist: ~p", [length(LeaveBetPlayersList), LeaveBetPlayersList]),
%%            ?DEBUG("Result: ~p", [Result]),
            {
                ?IF(is_list(BetPlayersList) andalso is_list(LeaveBetPlayersList),
                    length(BetPlayersList) - length(LeaveBetPlayersList), 0),
                GuessStatus,
                Time div ?SECOND_MS
            }
%%        O ->
%%            ?ERROR("非预期接口: ~p", [O]), exit(unknown)
    end.
player_into_bet(MissionType, PlayerId, Pos, Bet) ->
    %% 获取投注所消耗的道具
    Fun =
        fun() ->
            BetTupleList =
                lists:foldl(
                    fun ([StaticDataPos, _, _], Tmp) ->
                        if
                            Pos =:= StaticDataPos andalso Bet > 0 ->
                                ItemIdList =
                                    lists:filtermap(
                                        fun([ItemId, Cost]) ->
                                            ?IF(Pos =:= StaticDataPos andalso Bet =:= Cost, {true, {ItemId, Cost}}, false)
                                        end,
                                        ?SD_GUESS_COST_LIST
                                    ),
%%                                ?DEBUG("StaticDataPos: ~p, Bet: ~p, ItemIdList: ~p", [StaticDataPos, Bet, ItemIdList]),
                                if
                                    length(ItemIdList) >= 1 ->
                                        {RealItemId, RealCost} = hd(ItemIdList),
                                        mod_prop:decrease_player_prop(PlayerId, [RealItemId, RealCost], ?LOG_TYPE_GUESS_BOSS);
                                    true -> ?ERROR("玩家非法投注：~p ~p", [StaticDataPos, Bet]),exit(invalid_bet)
                                end;
                            true ->
                                ?DEBUG("玩家没有对StaticDataPos的boss进行投注")
                        end,
                        [{StaticDataPos, ?IF(StaticDataPos =:= Pos, Bet, 0)} | Tmp]
                    end,
                    [],
                    ?SD_GUESS_RATE_LIST
                ),
%%            ?DEBUG("BetTupleList: ~p", [BetTupleList]),
            SceneId = mod_mission:get_scene_id_by_mission(MissionType, 1),
            SceneWorker = get_scene_worker(SceneId),
            case gen_server:call(SceneWorker, {?MSG_PLAYER_BET, {PlayerId, BetTupleList}}) of
                {error, Reason} ->
                    exit(Reason);
                Result ->
                    {_BetPlayersList, _LeaveBetPlayersList, GuessStatus, Time} = Result,
%%                    ?DEBUG("length: ~p PlayerList: ~p", [length(BetPlayersList), BetPlayersList]),
%%                    ?DEBUG("length: ~p PlayerLeavelist: ~p", [length(LeaveBetPlayersList), LeaveBetPlayersList]),
                    ?DEBUG("Result: ~p GuessStatus: ~p Time: ~p", [Result, GuessStatus, Time])
%%                ok;
%%            O ->
%%                ?ERROR("非预期接口: ~p", [O]), exit(unknown)
            end
        end,
    R = db:do(Fun),
    ?DEBUG("投注事务执行结果: ~p", [R]),
    ok.

player_reset_bet(MissionType, PlayerId) ->
    SceneId = mod_mission:get_scene_id_by_mission(MissionType, 1),
    SceneWorker = get_scene_worker(SceneId),
    case gen_server:call(SceneWorker, {?MSG_PLAYER_RESET_BET, PlayerId}) of
        {error, Reason} -> exit(Reason);
        Result -> ?DEBUG("Result: ~p", [Result])
    end.
