%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 8月 2021 上午 09:56:50
%%%-------------------------------------------------------------------
-module(handle_scene_adjust_srv).
-author("Administrator").

-include("gen/table_enum.hrl").
-include("gen/db.hrl").
-include("scene_adjust.hrl").
-include("common.hrl").

%% API
-export([
    update_room/2,

    create_room/3,
    close_room/4,

    get_pool_value/1
]).

-export([
    test_log/1
]).

%% BOSS ADJUST
-export([
    add_boss_adjust_value/3,
    get_boss_adjust_value/1,

    handle_add_boss_adjust_value/2
]).

test_log(SceneDataList) ->
    lists:foreach(
        fun(SceneData) ->
            #scene_adjust_scene_data{
                scene_id = SceneId,
                scene_room_pid_list = SceneRoomPidList
            } = SceneData,
            PoolValue = get_pool_value(SceneId),
            if
                SceneRoomPidList == [] ->
                    noop;
                true ->
                    lists:foreach(
                        fun(Pid) ->
                            erlang:send(Pid, {apply, scene_adjust, test_log, []})
                        end,
                        SceneRoomPidList
                    ),
                    logger2:write(player_test_prop_log_3,
                        [
                            {scene_id, SceneId},                %% 场景id
                            {pool_value, PoolValue},            %% 盈亏值
                            {room_id_list, SceneRoomPidList}
                        ]
                    )
            end
        end,
        SceneDataList
    ).

create_room(SceneId, Pid, SceneDataList) ->
    case lists:keytake(SceneId, #scene_adjust_scene_data.scene_id, SceneDataList) of
        false ->
            NewPidList = [Pid],
            [#scene_adjust_scene_data{scene_id = SceneId, scene_room_pid_list = NewPidList} | SceneDataList];
        {value, OldSceneAdjustSceneData = #scene_adjust_scene_data{scene_room_pid_list = OldPidList}, SceneDataList1} ->
            NewPidList = [Pid | OldPidList],
            [OldSceneAdjustSceneData#scene_adjust_scene_data{scene_room_pid_list = NewPidList} | SceneDataList1]
    end.

close_room(SceneId, Pid, SceneDataList, PoolValue) ->
    DbSceneAdjust = get_db_scene_adjust(SceneId),
    #db_scene_adjust{
        pool_value = OldPoolValue
    } = DbSceneAdjust,
    Tran =
        fun() ->
            db:write(DbSceneAdjust#db_scene_adjust{pool_value = trunc(OldPoolValue + PoolValue)})
        end,
    db:do(Tran),
    case lists:keytake(SceneId, #scene_adjust_scene_data.scene_id, SceneDataList) of
        false ->
            NewPidList = [Pid],
            [#scene_adjust_scene_data{scene_id = SceneId, scene_room_pid_list = NewPidList} | SceneDataList];
        {value, OldSceneAdjustSceneData = #scene_adjust_scene_data{scene_room_pid_list = OldPidList}, SceneDataList1} ->
            NewPidList = lists:delete(Pid, OldPidList),
            [OldSceneAdjustSceneData#scene_adjust_scene_data{scene_room_pid_list = NewPidList} | SceneDataList1]
    end.

update_room(SceneId, SceneDataList) ->
    Time = util_random:random_number(util_list:opt(SceneId, ?SD_RANDOMPROFITLOSS_ZHOUQI)) * ?SECOND_MS,
    erlang:send_after(Time, self(), {?SCENE_ADJUST_MSG_UPDATE_ROOM, SceneId}),
    #scene_adjust_scene_data{scene_room_pid_list = ScenePidList} = lists:keyfind(SceneId, #scene_adjust_scene_data.scene_id, SceneDataList),
    update_room_1(SceneId, ScenePidList).
update_room_1(_, []) ->
    noop;
update_room_1(SceneId, ScenePidList) ->
    InitValue = util_list:opt(SceneId, ?SD_ROOMJACKPOT_JINE),
    RoomNum = length(ScenePidList),
%%    Tran1 =
%%        fun() ->
%%            lists:foreach(
%%                fun(Pid) ->
%%                    {ok, RoomPoolValue} = scene_adjust:call(Pid, ?SCENE_ADJUST_MSG_RESET_ROOM_POOL_VALUE),
%%%%                    ?DEBUG("房间池子值 ： ~p", [{SceneId, RoomPoolValue, Pid}]),
%%                    DbSceneAdjust = get_db_scene_adjust(SceneId),
%%                    #db_scene_adjust{
%%                        pool_value = PoolValue
%%                    } = DbSceneAdjust,
%%%%                    ?DEBUG("房间池子值 ： ~p", [{SceneId, PoolValue, PoolValue + RoomPoolValue}]),
%%                    db:write(DbSceneAdjust#db_scene_adjust{pool_value = trunc(PoolValue + RoomPoolValue)})
%%                end,
%%                ScenePidList
%%            )
%%        end,
%%    db:do(Tran1),
%%    ?DEBUG("查看数据 ： ~p", [{InitValue, RoomNum}]),
    InitTotalValue = InitValue * (RoomNum + 1),
    DbSceneAdjust = get_db_scene_adjust(SceneId),
    #db_scene_adjust{
        pool_value = PoolValue
    } = DbSceneAdjust,
    %% 0.92
    RealValue = get_scene_market_real_bo_dong_value(SceneId, PoolValue, InitTotalValue),
    %% 大亏 4
    YingKuiState = get_yingkui_state(RealValue * 10000),
    IsYing = (YingKuiState == ?SCENE_WORKER_ADJUST_STATE_1 orelse YingKuiState == ?SCENE_WORKER_ADJUST_STATE_2),
%%    List = get_scene_room_data_list(),
    StateValueList = util_list:opt(YingKuiState, ?SD_LABELPROBABILITY_DAKUI),
    put(ying_room_num, 0),
    put(kui_room_num, 0),
    {TotalRateAbs, TotalYingRateAbs, TotalKuiRateAbs, TotalYingRate, TotalKuiRate, AllRoomList} =
        lists:foldl(
            fun(ScenePid, {TmpRateAbs, TmpYingRateAbs, TmpKuiRateAbs, TmpYingRate, TmpKuiRate, TmpL}) ->
                YingRoomNum = get(ying_room_num),
                KuiRoomNum = get(kui_room_num),
                RandomValue =
                    if
                        IsYing == false andalso KuiRoomNum =< YingRoomNum + 1 ->
                            [_, Value, _, _] = StateValueList,
                            util_random:random_number(0, Value);
%%                        IsYing andalso YingRoomNum =< KuiRoomNum + 1 ->
%%                            [_, Value, _, _] = StateValueList,
%%                            util_random:random_number(Value + 1, 10000);
                        true ->
                            util_random:random_number(10000)
                    end,
                %% 三个房间，肯定两个亏
                RoomState = get_state_by_value(RandomValue, StateValueList, ?SCENE_WORKER_ADJUST_STATE_4),
                RoomRate1 = util_random:random_number(util_list:opt(RoomState, ?SD_ROOMLABELLIMIT_DAKUI)),
                %% 亏的负，赚的正
                RoomRate = util:float_num((RoomRate1 - 10000) / 10000),
                RoomRateAbs = abs(RoomRate),
                {NewTmpYingRateAbs, NewTmpKuiRateAbs, NewTmpYingRate, NewTmpKuiRate} =
                    if
                        RoomState == ?SCENE_WORKER_ADJUST_STATE_1 orelse RoomState == ?SCENE_WORKER_ADJUST_STATE_2 ->
                            put(ying_room_num, YingRoomNum + 1),
                            {TmpYingRateAbs + RoomRateAbs, TmpKuiRateAbs, TmpYingRate + RoomRate, TmpKuiRate};
                        true ->
                            put(kui_room_num, KuiRoomNum + 1),
                            {TmpYingRateAbs, TmpKuiRateAbs + RoomRateAbs, TmpYingRate, TmpKuiRate + RoomRate}
                    end,
                {RoomRateAbs + TmpRateAbs, NewTmpYingRateAbs, NewTmpKuiRateAbs, NewTmpYingRate, NewTmpKuiRate, [{ScenePid, RoomState, RoomRate} | TmpL]}
            end,
            {0, 0, 0, 0, 0, []},
            util_list:shuffle(ScenePidList)
        ),
    %% 0.92 * 800000 - 800000 = -64000
    NewRealValue = RealValue * InitTotalValue - InitTotalValue,
%%    ?DEBUG("125 ： data ： ~p", [{RealValue, InitTotalValue, NewRealValue}]),
    NewTotalValue =
        if
            IsYing ->
                lists:foldl(
                    fun({ScenePid, RoomState, RoomRate}, TmpTotal) ->
                        Value = trunc(if
                                          RoomState == ?SCENE_WORKER_ADJUST_STATE_1 orelse RoomState == ?SCENE_WORKER_ADJUST_STATE_2 ->
                                              %% 真实大盘波动值*（1+亏损房间盈亏波动绝对值和/所有房间盈亏波动绝对值和）*对应房间盈亏波动值/盈利房间盈亏波动值和
                                              %% 0.06 * (1 + 0 / 0.08) * 0.08 / 0.08
                                              %% -62000 * （1 + 0.2 / 0.3） * -0.1 / -0.2
                                              NewRealValue * (1 + TotalKuiRateAbs / TotalRateAbs) * RoomRate / TotalYingRate;
                                          true ->
                                              %% 负真实大盘波动值*亏损房间盈亏波动绝对值和/所有房间盈亏波动绝对值和*对应房间盈亏波动值/亏损房间盈亏波动值和
                                              %% -62000 * 0.2 / 0.3 * -0.1 / -0.3
                                              -NewRealValue * TotalKuiRateAbs / TotalRateAbs * RoomRate / TotalKuiRate
                                      end),
%%                        ?DEBUG("查看大盘下发数据1 : ~p", [{Value, IsYing, RoomState, NewRealValue, TotalYingRateAbs, TotalKuiRateAbs, TotalRateAbs, RoomRate, TotalYingRate, TotalKuiRate}]),
                        scene_adjust:send_msg_pid(ScenePid, {?SCENE_ADJUST_MSG_SET_ROOM_STATE, RoomState, RoomRate, Value}),
                        TmpTotal + Value
                    end,
                    0, AllRoomList
                );
            true ->
                lists:foldl(
                    fun({ScenePid, RoomState, RoomRate}, TmpTotal) ->
                        Value = trunc(if
                                          RoomState == ?SCENE_WORKER_ADJUST_STATE_1 orelse RoomState == ?SCENE_WORKER_ADJUST_STATE_2 ->
                                              %% 负真实大盘波动值*盈利房间盈亏波动绝对值和/所有房间盈亏波动绝对值和*对应房间盈亏波动值/盈利房间盈亏波动值和
                                              %% 62000 * 0.1 / 0.3 * 0.1 / 0.1
                                              -NewRealValue * TotalYingRateAbs / TotalRateAbs * RoomRate / TotalYingRate;
                                          true ->
                                              %% -120000 * (1 + 0 / 0.3) * -0.1 / -0.3
                                              %% 真实大盘波动值*(1+盈利房间盈亏波动绝对值和/所有房间盈亏波动绝对值和）*对应房间盈亏波动值/负房间盈亏波动值和
                                              NewRealValue * (1 + TotalYingRateAbs / TotalRateAbs) * RoomRate / TotalKuiRate
                                      end),
%%                        ?DEBUG("查看大盘下发数据2 : ~p", [{Value, IsYing, RoomState, NewRealValue, TotalYingRateAbs, TotalKuiRateAbs, TotalRateAbs, RoomRate, TotalYingRate, TotalKuiRate}]),
                        scene_adjust:send_msg_pid(ScenePid, {?SCENE_ADJUST_MSG_SET_ROOM_STATE, RoomState, RoomRate, Value}),
                        TmpTotal + Value
                    end,
                    0, AllRoomList
                )
        end,
%%    ?DEBUG("NewTotalValue : ~p", [NewTotalValue]),
    Tran =
        fun() ->
            db:write(DbSceneAdjust#db_scene_adjust{pool_value = trunc(PoolValue - NewTotalValue)})
        end,
    db:do(Tran).
%%    RandomNum = util_random:random_number(4),
%%    %% 数字4是大亏，3是小亏，2是小赚，1是大赚       但在PList是反过来的
%%    P = lists:nth(5 - RandomNum, PList),
%%    Rate =
%%        case util_random:p(P) of
%%            true ->
%%                util_random:random_number(util_list:opt(RandomNum, ?SD_ROOMLABELLIMIT_DAKUI));
%%            false ->
%%                10000
%%        end,
%%    RandomYingKuiValue = ceil(RealValue * Rate / 10000).
get_scene_init_value(SceneId) ->
    util_random:random_number(util_list:opt(SceneId, ?SD_MARKET_BODONG)).
get_state_by_value(RandomValue, [Value | List], State) ->
    if
        RandomValue =< Value ->
            State;
        true ->
            get_state_by_value(RandomValue, List, State - 1)
    end.

%% -200000 800000
get_scene_market_real_bo_dong_value(SceneId, PoolValue, InitTotalValue) ->
    Value = util:float_num(get_scene_init_value(SceneId) / 10000 + PoolValue / InitTotalValue),
    [Min, Max] = ?SD_MARKET_BODONGLIMIT,
    RealValue =
        if
            Value =< Min / 10000 -> Min / 10000;
            Value >= Max / 10000 -> Max / 10000;
            true -> Value
        end,
    RealValue.

get_yingkui_state(Value) ->
    get_yingkui_state(Value, ?SD_RANGE_DAPANYINGKUI).
get_yingkui_state(Value, [[State, [Min, Max]] | List]) ->
    if
        Value >= Min andalso (Value =< Max orelse Max == 0) ->
            State;
        true ->
            get_yingkui_state(Value, List)
    end.

get_pool_value(SceneId) ->
    #db_scene_adjust{
        pool_value = PoolValue
    } = get_db_scene_adjust(SceneId),
    PoolValue.

%% ================================================ 数据操作 ================================================

%% @doc DB
get_db_scene_adjust(SceneId) ->
    case db:read(#key_scene_adjust{scene_id = SceneId}) of
        null ->
            #db_scene_adjust{scene_id = SceneId, pool_value = 0};
        R ->
            R
    end.

%% @doc DB
get_db_scene_boss_adjust(SceneId) ->
    case db:read(#key_scene_boss_adjust{scene_id = SceneId}) of
        null ->
            #db_scene_boss_adjust{scene_id = SceneId, pool_value = 0};
        R ->
            R
    end.

%% ================================================ BOSS修正 ================================================

add_boss_adjust_value(PlayerId, _SceneId, _AddValue) when PlayerId < 10000 ->
    noop;
add_boss_adjust_value(_PlayerId, _SceneId, 0) ->
    noop;
add_boss_adjust_value(_PlayerId, SceneId, AddValue) ->
    add_boss_adjust_value(SceneId, AddValue).
add_boss_adjust_value(SceneId, AddValue) ->
    scene_adjust_srv:cast({?SCENE_ADJUST_MSG_ADD_BOSS_ADJUST_VALUE, SceneId, AddValue}).

get_boss_adjust_value(SceneId) ->
    #db_scene_boss_adjust{
        pool_value = PoolValue
    } = get_db_scene_boss_adjust(SceneId),
    PoolValue.

%% @doc BOSS修正
handle_add_boss_adjust_value(SceneId, AddValue) ->
    DbSceneBossAdjust = get_db_scene_boss_adjust(SceneId),
    #db_scene_boss_adjust{
        pool_value = PoolValue
    } = DbSceneBossAdjust,
    NewValue = PoolValue + AddValue,
    case ?IS_DEBUG of
         true ->
            logger2:write(player_test_prop_log_boss,
                [
                    {scene_id, SceneId},                %% 场景id
                    {value, NewValue}                   %% 盈亏值
                ]
            );
        false ->
            noop
    end,
    Tran =
        fun() ->
            db:write(DbSceneBossAdjust#db_scene_boss_adjust{pool_value = NewValue})
        end,
    db:do(Tran),
    ok.