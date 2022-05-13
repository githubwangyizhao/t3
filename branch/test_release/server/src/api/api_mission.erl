%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            副本
%%% @end
%%% Created : 02. 十二月 2017 上午 10:21
%%%-------------------------------------------------------------------
-module(api_mission).
-include("common.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("error.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("mission.hrl").
-include("scene.hrl").
-include("system.hrl").
%% API
-export([
    challenge_mission/2,
    exit_mission/2,
    get_award/2,
    boss_rebirth/2,

    guess_get_record/2,     %% 猜一猜获得记录
    notice_shi_shi_settle/8,    %% 时时副本通知结果
    notice_shi_shi_time/4,      %% 时时副本时间(玩家进入副本时给)
    notice_shi_shi_value/2      %% 时时副本总积分值
]).

-export([
    notice_challenge_mission/3,
    notice_mission_result/5,
    notice_passed_mission/3,
    notice_mission_close_time/2,
    notice_mission_round/1,
    notice_mission_schedule/2,
    notice_total_award/1,
    notice_equip_mission_hurt_ranking_list/2,
    notice_guess_boss_mission_result/6,
    notice_guess_boss_mission_time/3
]).

-export([
    pack_passed_mission_list/1
]).

-export([
    either_either/2,
    either_notice_result/3,
    either_notice_state/5
]).

-export([
    scene_boss_bet/2,
    scene_boss_bet_reset/2,
    notice_scene_boss_bet/2,
    notice_scene_boss_step/3,
    notice_scene_boss_result/7,
    notice_scene_boss_dao_num_change/2,
    notice_scene_boss_boss_update_pos/2
]).

-export([
    lucky_boss_status/2,
    lucky_boss_bet/2,
    lucky_boss_bet_reset/2,
    notice_lucky_boss_result/3
]).

-export([
    notice_one_on_one/4,
    notice_hero_versus_boss/2
]).

-export([
    hero_versus_boss_bet/2,
    hero_versus_boss_bet_reset/2,
    get_hero_versus_boss_record/2,
    test_get_hero_versus_boss_record/2
]).

%% ----------------------------------
%% @doc 	挑战副本
%% @throws 	none
%% @end
%% ----------------------------------
challenge_mission(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_mission_challenge_mission_tos{mission_type = MissionType, mission_id = MissionId} = Msg,
    ?DEBUG("挑战副本:~p~n", [{MissionType, MissionId}]),
%%    RealMissionId =
%%        if MissionType == ?MISSION_TYPE_DIGONG ->
%%            1;
%%            true ->
%%                MissionId
%%        end,
    Result =
        try mod_mission:challenge_mission(PlayerId, MissionType, MissionId) of
            _ ->
                ?P_SUCCESS
        catch
            _:Error ->
                api_common:api_result_to_enum_2(Error)
%%            _:?ERROR_INTERFACE_CD_TIME ->
%%                ?P_FAIL;
%%            _:?ERROR_FUNCTION_NO_OPEN ->
%%                ?DEBUG("功能未开启"),
%%                ?P_FUNCTION_NO_OPEN;
%%            _:?ERROR_ACTIVITY_NO_OPEN ->
%%                ?P_ACTIVITY_NO_OPEN;
%%            _:?ERROR_NOT_ONLINE ->
%%                ?P_NOT_ONLINE;
%%            _:?ERROR_TIMES_LIMIT ->
%%                ?P_TIMES_LIMIT;
%%            _:?ERROR_TIME_LIMIT ->
%%                ?P_TIME_LIMIT;
%%            _:?ERROR_NOT_AUTHORITY ->
%%                ?P_NOT_AUTHORITY;
%%%%            _:?ERROR_NO_FACTION ->
%%%%                ?P_NO_FACTION;
%%%%            _:already_wait_enter_scene ->
%%%%                ?P_FAIL;
%%            _:Other ->
%%                ?DEBUG("挑战副本失败:~p", [{MissionType, MissionId, Other, erlang:get_stacktrace()}]),
%%                ?P_FAIL
        end,
    Out = proto:encode(#m_mission_challenge_mission_toc{result = Result, mission_type = MissionType, mission_id = MissionId}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	boss 复活
%% @throws 	none
%% @end
%% ----------------------------------
boss_rebirth(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_mission_boss_rebirth_tos{mission_type = MissionType, mission_id = MissionId} = Msg,
    ?DEBUG("boss 复活:~p~n", [{MissionType, MissionId}]),
    Result =
        try mod_mission:boss_rebirth(PlayerId, MissionType, MissionId) of
            _ ->
                ?P_SUCCESS
        catch
            _:Other ->
                ?ERROR("boss 复活:~p", [{MissionType, MissionId, Other, erlang:get_stacktrace()}]),
                ?P_FAIL
        end,
    Out = proto:encode(#m_mission_boss_rebirth_toc{result = Result, mission_type = MissionType, mission_id = MissionId}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	挑战副本
%% @throws 	none
%% @end
%% ----------------------------------
get_award(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_mission_get_award_tos{type = Type} = Msg,
    Result =
        try mod_mission:get_cache_mission_award(PlayerId, Type) of
            _ ->
                ?P_SUCCESS
        catch
            _:?ERROR_NOT_ENOUGH_GRID ->
                ?P_NOT_ENOUGH_GRID;
            _:?ERROR_NO_ENOUGH_PROP ->
                ?P_NO_ENOUGH_PROP;
            _:Other ->
                ?ERROR("get_cache_mission_award:~p", [{Other, Type, erlang:get_stacktrace()}]),
                ?P_FAIL
        end,
    Out = proto:encode(#m_mission_get_award_toc{result = Result}),
    mod_socket:send(Out),
    State.


%% ----------------------------------
%% @doc 	通知挑战副本
%% @throws 	none
%% @end
%% ----------------------------------
notice_challenge_mission(PlayerId, MissionType, MissionId) ->
    Out = proto:encode(#m_mission_challenge_mission_toc{result = ?P_SUCCESS, mission_type = MissionType, mission_id = MissionId}),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知副本结果
%% @throws 	none
%% @end
%% ----------------------------------
notice_mission_result(PlayerId, MissionType, MissionId, Result, PropList) ->
    Out = proto:encode(#m_mission_notice_mission_result_toc{
        result = Result,
        mission_type = MissionType,
        mission_id = MissionId,
        add_prop_list = api_prop:pack_prop_list(PropList)
    }),
    mod_socket:send(PlayerId, Out).


%% ----------------------------------
%% @doc 	通知通关副本
%% @throws 	none
%% @end
%% ----------------------------------
notice_passed_mission(PlayerId, MissionType, MissionId) ->
    Out = proto:encode(#m_mission_notice_passed_mission_toc{
        passed_mission = #passed_mission{mission_type = MissionType, mission_id = MissionId}
    }),
    mod_socket:send(PlayerId, Out).


%% ----------------------------------
%% @doc 	通知副本结束时间
%% @throws 	none
%% @end
%% ----------------------------------
notice_mission_close_time(PlayerId, CloseTimestamp) ->
    ?DEBUG("通知副本结束时间:~p~n", [{CloseTimestamp}]),
    Out = proto:encode(#m_mission_notice_mission_close_time_toc{
        time = CloseTimestamp
    }),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知副本波次
%% @throws 	none
%% @end
%% ----------------------------------
notice_mission_round(Round) ->
%%    ?DEBUG("通知副本波次:~p~n", [{Round}]),
%%    mod_scene_player_manager:get_all_obj_scene_player_id(),
    Out = proto:encode(#m_mission_notice_mission_round_toc{
        total_round = 20,
        round = Round
    }),
    mod_socket:send_to_all_online_player(Out).

%% ----------------------------------
%% @doc 	通知副本进度
%% @throws 	none
%% @end
%% ----------------------------------
notice_mission_schedule(Total, Now) ->
%%    ?DEBUG("通知副本进度:~p~n", [{Total, Now}]),
%%    mod_scene_player_manager:get_all_obj_scene_player_id(),
    Out = proto:encode(#m_mission_notice_mission_schedule_toc{
        total_value = Total,
        now_value = Now
    }),
    mod_socket:send_to_all_online_player(Out).

%% ----------------------------------
%% @doc 	通知累计奖励
%% @throws 	none
%% @end
%% ----------------------------------
notice_total_award(TotalPropList) ->
    ?DEBUG("通知累计奖励:~p~n", [{TotalPropList}]),
%%    ?DEBUG("notice_total_award:~p~n", [TotalPropList]),
    api_prop:pack_prop_list(TotalPropList),
    Out = proto:encode(#m_mission_notice_total_award_toc{
        total_prop_list = api_prop:pack_prop_list(TotalPropList)
    }),
    mod_socket:send_to_all_online_player(Out).

%% ----------------------------------
%% @doc 	通知伤害排行榜列表
%% @throws 	none
%% @end
%% ----------------------------------
notice_equip_mission_hurt_ranking_list(List, SelfHurt) ->
    ?DEBUG("notice_equip_mission_hurt_ranking_list:~p~n", [{List, SelfHurt}]),
    Out = proto:encode(#m_mission_notice_mission_ranking_toc{
        self_hurt = SelfHurt,
        hurt_ranking_list = List,
        mission_type = get(?DICT_MISSION_TYPE)
    }),
    mod_socket:send_to_all_online_player(Out).

%% ----------------------------------
%% @doc 	挑战副本
%% @throws 	none
%% @end
%% ----------------------------------
exit_mission(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_mission_exit_mission_tos{} = Msg,
    mod_mission:exit_mission(PlayerId),
    State.

pack_passed_mission_list(PlayerId) ->
    [
        begin
            #db_player_mission_data{
                mission_type = MissionType,
                mission_id = PassedMissionId
            } = E,
            #passed_mission{
                mission_type = MissionType,
                mission_id = PassedMissionId
            }
        end ||
        E <- mod_mission:get_all_player_mission_data(PlayerId)
    ].

%% ----------------------------------
%% @doc 	获得猜一猜boss记录
%% @throws 	none
%% @end
%% ----------------------------------
guess_get_record(
    #m_mission_guess_get_record_tos{},
    State = #conn{player_id = PlayerId}
) ->
%%    mod_boss_one_on_one:get_record(PlayerId),
    mod_hero_versus_boss:get_record(PlayerId),
    State.
%%    RecordList = mod_mission_guess_boss:get_record(),
%%    ?DEBUG("EquipMissionBossList:~p~n", [EquipMissionBossList]),
%%    {RateList, RecordList} = mod_boss_one_on_one:get_record(PlayerId),
%%    Out = proto:encode(#m_mission_guess_get_record_toc{
%%        guess_boss_record_list = [#guessbossrecord{id = Id, boss_id = BossId} || {Id, BossId} <- RecordList]
%%    }),
%%    mod_socket:send(Out),
%%    Out2 = #m_mission_notice_one_on_one_rate_toc{
%%        winne_rate = [#winnerrate{boss_id = BossId, rate = Rate} || {BossId, Rate} <- RateList]
%%    },
%%    ?DEBUG("Out2: ~p", [Out2]),
%%    State.

%% ----------------------------------
%% @doc 	通知猜Boss副本结果
%% @throws 	none
%% @end
%% ----------------------------------
notice_guess_boss_mission_result(PlayerId, BossId, AwardList, BossIdList, ResultFightList, PlayerTotalCost) ->
    Out = proto:encode(#m_mission_notice_guess_boss_mission_result_toc{
        boss_id = BossId,
        award_list = api_prop:pack_prop_list(AwardList),
        guess_boss_result_fight_list = [
            #guessbossresultfight{
                round_id = Round,
                attack_id = AttackId,
                die_id_list = DieIdList
            } || {Round, AttackId, DieIdList} <- ResultFightList
        ],
        boss_id_list = BossIdList,
        total_cost_value = PlayerTotalCost
    }),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知猜一猜副本时间
%% @throws 	none
%% @end
%% ----------------------------------
notice_guess_boss_mission_time(PlayerId, State, CloseTimestamp) ->
    ?DEBUG("通知副本结束时间:~p~n", [{CloseTimestamp}]),
    Out = proto:encode(#m_mission_notice_guess_boss_mission_time_toc{
        state = State,
        timestamp = CloseTimestamp div ?SECOND_MS
    }),
    mod_socket:send(PlayerId, Out).

%% 时时副本通知结果
notice_shi_shi_settle(PlayerId, WinPlayerId, WinPlayerNameBin, Value, NextStep, Step, NextSettleTime, PlayerTotalCost) ->
    List =
        if
            Step =:= 1 ->
                [#'m_mission_notice_shi_shi_settle_toc.last_data'{lastWinName = list_to_binary(Key), lastValue = LastValue} || {Key, LastValue} <- util:get_dict(last_win_player_list, [])];
            true ->
                []
        end,
    Out = proto:encode(#m_mission_notice_shi_shi_settle_toc{
        winPlayerId = WinPlayerId,
        winName = WinPlayerNameBin,
        value = Value,
        next_type = NextStep,
        type = Step,
        nextEndTime = NextSettleTime,
        last_data_list = List,
        total_cost_value = PlayerTotalCost
    }),
    mod_socket:send(PlayerId, Out).
%% 时时副本时间(玩家进入副本时给)
notice_shi_shi_time(PlayerId, Step, NextSettleTime, Value) ->
    Out = proto:encode(#m_mission_notice_shi_shi_time_toc{type = Step, nextEndTime = NextSettleTime, value = Value}),
    mod_socket:send(PlayerId, Out).
%% 时时副本总积分值
notice_shi_shi_value(PlayerId, Value) ->
    Out = proto:encode(#m_mission_notice_shi_shi_value_toc{value = Value}),
    mod_socket:send(PlayerId, Out).

%%----------------------选择副本 begin -----------------------------
%% @doc 选择副本通知状态
either_notice_state(PlayerId, Round, Type, AwardValue, EndTime) ->
    Out = proto:encode(#m_mission_either_notice_state_toc{round = Round, type = Type, award_value = AwardValue, end_time = EndTime}),
    mod_socket:send(PlayerId, Out).

%% @doc 选择副本选择
either_either(
    #m_mission_either_either_tos{either_value = EitherValue},
    State = #conn{player_id = PlayerId}
) ->
    catch mod_mission_either:either_either(PlayerId, EitherValue),
    State.

%% @doc 选择副本通知结果
either_notice_result(PlayerId, ResultState, AwardValue) ->
    Out = proto:encode(#m_mission_either_notice_result_toc{result_state = ResultState, award_value = AwardValue}),
    mod_socket:send(PlayerId, Out).
%%----------------------选择副本 end -----------------------------

%%----------------------场景副本 begin -----------------------------
%% @doc 场景副本 竞猜
scene_boss_bet(
    #m_mission_scene_boss_bet_tos{type = Type, id = Id, num = Num},
    State = #conn{player_id = PlayerId}
) ->
    catch mod_mission_scene_boss:scene_boss_bet(PlayerId, Type, Id, Num),
    State.

%% @doc 场景副本 重置
scene_boss_bet_reset(
    #m_mission_scene_boss_bet_reset_tos{type = Type},
    State = #conn{player_id = PlayerId}
) ->
    catch mod_mission_scene_boss:scene_boss_bet_reset(PlayerId, Type),
    State.

%% @doc 通知场景副本 竞猜改变
notice_scene_boss_bet(PlayerId, SceneBossPosBetList) ->
    List = [#scenebossbet{type = Type, id = Id, my_num = MyValue, total_num = TotalValue} || {Type, Id, MyValue, TotalValue} <- SceneBossPosBetList],
    Out = proto:encode(#m_mission_notice_scene_boss_bet_toc{scene_boss_bet_list = List}),
    mod_socket:send(PlayerId, Out).

%% @doc 通知场景副本 阶段改变
notice_scene_boss_step(PlayerId, Step, Time) ->
    Out = proto:encode(#m_mission_notice_scene_boss_step_toc{step = Step, time = Time}),
    mod_socket:send(PlayerId, Out).

%% @doc 通知场景boss结果
notice_scene_boss_result(PlayerId, Result, WinPlayerName, WinAwardValue, BetAwardList, WinPlayerId, WinPropList) ->
    List = [#scenebossbetaward{type = Type, id = Id, num = AwardValue} || {Type, Id, AwardValue} <- BetAwardList],
    Out = proto:encode(#m_mission_notice_scene_boss_result_toc{result = Result, win_name = WinPlayerName, win_award_value = WinAwardValue, scene_boss_bet_award = List, player_id = WinPlayerId, prop_list = api_prop:pack_prop_list(WinPropList)}),
    mod_socket:send(PlayerId, Out).

%% @doc 通知场景boss刀数改变
notice_scene_boss_dao_num_change(PlayerIdList, Value) ->
    Out = proto:encode(#m_mission_notice_scene_boss_dao_num_change_toc{value = Value}),
    mod_socket:send_to_player_list(PlayerIdList, Out).

%% @doc 通知场景boss位置改变
notice_scene_boss_boss_update_pos(PlayerIdList, PosId) ->
    Out = proto:encode(#m_mission_notice_scene_boss_boss_update_pos_toc{pos_id = PosId}),
    mod_socket:send_to_player_list(PlayerIdList, Out).


%%----------------------猜位置场景副本 end -----------------------------

%% ------------------------------------------- 2021-05-27 猜一猜boss start ----------------------------------------------

notice_hero_versus_boss(PlayerId, {Players, Time, Status, PreviousTime}) ->
    Out = #m_mission_hero_versus_boss_status_toc{
        state = Status, timestamp = Time, players = Players, operation = 2, previous_timestamp = PreviousTime
    },
    ?DEBUG("notice_hero_versus_boss status: ~p", [Out]),
    mod_socket:send(PlayerId, proto:encode(Out)).

notice_one_on_one(PlayerId, Players, Time, GuessStatus) ->
    Out = #m_mission_lucky_boss_status_toc{
        state = GuessStatus, timestamp = Time, players = Players, operation = 2
    },
    ?DEBUG("notice_one_on_one status: ~p", [Out]),
    mod_socket:send(PlayerId, proto:encode(Out)).

lucky_boss_status(
    #m_mission_lucky_boss_status_tos{operation = Operation},
    State = #conn{player_id = PlayerId}
) ->
    Out =
        if
            Operation =:= 1 ->
                case catch mod_bet:player_into_bet(?MISSION_TYPE_GUESS_BOSS, PlayerId) of
                    {Players, GuessStatus, Time} ->
                        ?INFO("~p - Players: ~p, GuessStatus: ~p, Time: ~p", [Operation, Players, GuessStatus, Time]),
                        #m_mission_lucky_boss_status_toc{
                            state = GuessStatus, timestamp = Time,
                            players = Players, operation = Operation
                        };
                    {'EXIT', not_exists} ->
                        #m_mission_lucky_boss_status_toc{
                            state = 1, timestamp = util_time:timestamp(), players = 0, operation = Operation
                        };
                    {'EXIT', unknown} ->
                        #m_mission_lucky_boss_status_toc{
                            state = 1, timestamp = util_time:timestamp(), players = 0, operation = Operation
                        };
                    {'EXIT', Other} ->
                        ?ERROR("luck_boss_status非预期结果: ~p", [Other]),
                        #m_mission_lucky_boss_status_toc{
                            state = 1, timestamp = util_time:timestamp(), players = 0, operation = Operation
                        }
                end;
            true ->
                case catch mod_bet:player_leave_bet(PlayerId, ?MISSION_TYPE_GUESS_BOSS) of
                    {Players, GuessStatus, Time} ->
                        ?DEBUG("~p - Players: ~p, GuessStatus: ~p, Time: ~p", [Operation, Players, GuessStatus, Time]),
                        #m_mission_lucky_boss_status_toc{
                            state = GuessStatus, timestamp = Time, players = Players, operation = Operation
                        };
                    {'EXIT', not_exists} ->
                        #m_mission_lucky_boss_status_toc{
                            state = 1, timestamp = util_time:timestamp(), players = 0, operation = Operation
                        };
                    {'EXIT', unknown} ->
                        #m_mission_lucky_boss_status_toc{
                            state = 1, timestamp = util_time:timestamp(), players = 0, operation = Operation
                        };
                    {'EXIT', Other} ->
                        ?ERROR("luck_boss_status非预期结果 leave: ~p", [Other]),
                        #m_mission_lucky_boss_status_toc{
                            state = 1, timestamp = util_time:timestamp(), players = 0, operation = Operation
                        }
                end

        end,
    ?DEBUG("Out: ~p", [Out]),
    %% 不同步返回猜一猜副本的状态
    mod_socket:send(proto:encode(Out)),
    State.

lucky_boss_bet(
    #m_mission_lucky_boss_bet_tos{pos = Pos, bet = Bet},
    State = #conn{player_id = PlayerId}
) ->
    Out =
%%        case catch mod_mission_scene_boss:scene_boss_bet(PlayerId, 3, Pos, Bet) of
    case catch mod_bet:player_bet_in_scene(?MISSION_TYPE_GUESS_BOSS, PlayerId, Pos, Bet) of
%%        case catch mod_bet:player_into_bet(?MISSION_TYPE_GUESS_BOSS, PlayerId, Pos, Bet) of
        ok ->
            ?DEBUG("Players: ~p, Pos: ~p, Bet: ~p", [PlayerId, Pos, Bet]),
            #m_mission_lucky_boss_bet_toc{result = 1};
        {'EXIT', unknown} ->
            #m_mission_lucky_boss_bet_toc{result = 3};
        {'EXIT', R} ->
            ?ERROR("报错了: ~p", [R]),
            #m_mission_lucky_boss_bet_toc{result = 2}
    end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(proto:encode(Out)),
    State.

lucky_boss_bet_reset(
    #m_mission_lucky_boss_bet_reset_tos{},
    State = #conn{player_id = PlayerId}
) ->
    Out =
        case catch mod_bet:player_reset_bet(?MISSION_TYPE_GUESS_BOSS, PlayerId) of
            ok ->
                ?DEBUG("Players(~p) reset bet", [PlayerId]),
                #m_mission_lucky_boss_bet_reset_toc{result = 1};
            {'EXIT', unknown} ->
                #m_mission_lucky_boss_bet_reset_toc{result = 3};
            {'EXIT', R} ->
                ?ERROR("报错了: ~p", [R]),
                #m_mission_lucky_boss_bet_reset_toc{result = 2}
        end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(proto:encode(Out)),
    State.

notice_lucky_boss_result(PlayerId, BossId, AwardList) ->
    Proto = #m_mission_notice_lucky_boss_result_toc{
        boss_id = BossId,
        award_list = api_prop:pack_prop_list(AwardList)
    },
    ?DEBUG("notice_lucky_boss_result_toc protp:~p", [Proto]),
    Out = proto:encode(Proto),
    mod_socket:send(PlayerId, Out).
%% --------------------------------------------- 2021-05-27 猜一猜boss end ----------------------------------------------

%% ------------------------------------------- 2021-07-20 猜一猜boss start ----------------------------------------------
hero_versus_boss_bet(
    #m_mission_hero_versus_boss_bet_tos{pos = Pos, bet = Bet},
    State = #conn{player_id = PlayerId}
) ->
    Out =
        case catch mod_bet:player_bet_in_scene(?MISSION_TYPE_MISSION_HERO_PK_BOSS, PlayerId, Pos, Bet) of
            ok ->
                ?DEBUG("Players: ~p, Pos: ~p, Bet: ~p", [PlayerId, Pos, Bet]),
                #m_mission_lucky_boss_bet_toc{result = 1};
            {'EXIT', unknown} ->
                #m_mission_lucky_boss_bet_toc{result = 3};
            {'EXIT', R} ->
                ?ERROR("报错了: ~p", [R]),
                #m_mission_lucky_boss_bet_toc{result = 2}
        end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(proto:encode(Out)),
    State.

hero_versus_boss_bet_reset(
    #m_mission_hero_versus_boss_bet_reset_tos{},
    State = #conn{player_id = PlayerId}
) ->
    Out =
        case catch mod_bet:player_reset_bet(?MISSION_TYPE_MISSION_HERO_PK_BOSS, PlayerId) of
            ok ->
                ?DEBUG("Players(~p) reset bet", [PlayerId]),
                #m_mission_hero_versus_boss_bet_reset_toc{result = 1};
            {'EXIT', unknown} ->
                #m_mission_hero_versus_boss_bet_reset_toc{result = 3};
            {'EXIT', R} ->
                ?ERROR("报错了: ~p", [R]),
                #m_mission_hero_versus_boss_bet_reset_toc{result = 2}
        end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(proto:encode(Out)),
    State.

get_hero_versus_boss_record(
    #m_mission_get_hero_versus_boss_record_tos{hero_id = HeroId},
    State = #conn{player_id = PlayerId}
) ->
    mod_hero_versus_boss:get_record(PlayerId, HeroId),
    State.
test_get_hero_versus_boss_record(PlayerId, HeroId) ->
    mod_hero_versus_boss:get_record(PlayerId, HeroId).

%% --------------------------------------------- 2021-07-20 猜一猜boss end ----------------------------------------------