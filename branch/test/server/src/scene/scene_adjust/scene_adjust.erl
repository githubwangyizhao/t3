%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         SCENE_WORKER
%%% @end
%%% Created : 12. 8ζ 2021 δΈε 03:40:18
%%%-------------------------------------------------------------------
-module(scene_adjust).
-author("Administrator").

-include("scene_adjust.hrl").
-include("common.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("gen/db.hrl").
-include("scene.hrl").
-include("player_game_data.hrl").

%% API
-export([
    call/2,

    send_msg/1,
    send_msg/2,

    send_msg_pid/2,
    send_msg_pid/3,

    handle_msg/2
]).

-export([
    init_scene/1,

    handle_timer/1,

    player_enter/1,
    player_leave/1
]).

-export([
    add_room_pool_value/2,
    cost_room_pool_value/2,
    cost_room_pool_value/3,
    call_get_player_adjust_state/1,
    get_player_adjust_state/1,

    cast_add_room_pool_value/2,
    cast_cost_room_pool_value/2,

    get_player_adjust/1,
    get_scene_worker_state/0,

    get_scene_adjust_rate_value/1
]).

-export([
    is_newbee/1,
    get_newbee_adjust_value/2,
%%    init_fight_novice_adjust/3,
%%    get_fight_novice_adjust/0,
    try_add_exp/4
%%    del_fight_novice_adjust/0
]).

-export([
    test_log/0,
    test_value/2
]).

-export([
    player_enter_init_rebound/1,
    player_leave_clear_rebound/1,

    add_player_total_cost/2,
    add_player_total_award/2
]).

test_value(SceneId, PoolValue) ->
    InitRoomValue = util_list:opt(SceneId, ?SD_ROOMJACKPOT_JINE),
    Value = trunc((PoolValue / InitRoomValue + 1) * 10000),
    PlayerState = get_one_player_state(Value),
    PlayerRate = util:float_num(util_random:random_number(util_list:opt(PlayerState, ?SD_PLAYERLABELLIMIT_DAKUI)) / 10000),
    {PlayerState, PlayerRate}.

test_log() ->
    Pid = self(),
    PoolValue = get_scene_worker_pool_value(),
    {SceneAdjustState, _AdjustValue} = get_scene_worker_state(),
    PlayerIdList = get_scene_player_id_list(),
    logger2:write(player_test_prop_log_4,
        [
            {room_id, Pid},
            {scene_id, get(?DICT_SCENE_ID)},                %% εΊζ―id
            {pool_value, PoolValue},                        %% ηδΊεΌ
            {state, SceneAdjustState},
            {player_list, PlayerIdList}
        ]
    ),
    lists:foreach(
        fun(PlayerId) ->
            PlayerRmbNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_RMB),
            PlayerGoldNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_GOLD),
            {_, PlayerRate} = get_scene_worker_player_state(PlayerId),
            logger2:write(player_test_prop_log_2,
                [
                    {p, PlayerId},                  %% η©ε?Άid
                    {rmb_num, PlayerRmbNum},        %% η η³ζ°ι
                    {gold_num, PlayerGoldNum},      %% ιεΈζ°ι
                    {total_cost, mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TEST_COST_TOTAL_RMB)},
                    {rate, PlayerRate}
                ]
            )
        end,
        PlayerIdList
    ).

%% =============================================== MSG START =======================================================
%% @doc ζεζΆζ―
pack_msg(Msg) ->
    {?SCENE_ADJUST_MSG, Msg}.

%% @doc CALL
call(Pid, Msg) ->
    gen_server:call(Pid, pack_msg(Msg)).

%% @doc ειζΆζ―
send_msg(Msg) ->
    erlang:send(self(), pack_msg(Msg)).
send_msg(DelayTime, Msg) ->
    erlang:send_after(DelayTime, self(), pack_msg(Msg)).

%% @doc ειζΆζ―ε°θΏη¨
send_msg_pid(Pid, Msg) ->
    erlang:send(Pid, pack_msg(Msg)).
send_msg_pid(DelayTime, Pid, Msg) ->
    erlang:send_after(DelayTime, Pid, pack_msg(Msg)).

%% @doc ζΆζ―εθ°
handle_msg(Msg, _SceneState) ->
    case Msg of
        %% CALL
        ?SCENE_ADJUST_MSG_RESET_ROOM_POOL_VALUE ->
            reset_room_pool_value();
        %% INFO
        {?SCENE_ADJUST_MSG_SET_ROOM_STATE, RoomState, RoomRate, Value} ->
            handle_set_scene_worker_state(RoomState, RoomRate, Value);
        {?SCENE_ADJUST_MSG_CHANGE_POOL_VALUE, add, PlayerId, Value} ->
            add_room_pool_value(PlayerId, Value);
        {?SCENE_ADJUST_MSG_CHANGE_POOL_VALUE, cost, PlayerId, Value} ->
            cost_room_pool_value(PlayerId, Value);
        {?SCENE_ADJUST_MSG_PLAYER_BANKRUPTRY, PlayerId} ->
            player_leave(PlayerId);
        {?SCENE_ADJUST_MSG_PLAYER_DEVELOP, PlayerId} ->
            player_enter(PlayerId);
        %% REBOUND εεΌΉ
        ?SCENE_ADJUST_MSG_TRY_REBOUND ->
            send_msg(5000, ?SCENE_ADJUST_MSG_TRY_REBOUND),
%%            ?DEBUG("ζ₯ηεΊζ―id οΌ~p", [get(?DICT_SCENE_ID)]),
            try_rebound();
        {?SCENE_ADJUST_MSG_REBOUND_END, PlayerId, State, Ref} ->
            rebound_end(PlayerId, State, Ref);
        {?SCENE_ADJUST_MSG_REBOUND_CD_END, PlayerId, State} ->
            rebound_cd_end(PlayerId, State);
        _ ->
            ?ERROR("~p ζζΆζ―δΈεΉι οΌ ~p", [?MODULE, Msg])
    end.

%% ============================================= MSG END =======================================================

%% ========================================== FUNCTION START ===================================================

%% @doc εε§εεΊζ―
init_scene(SceneId) ->
    Time = util_random:random_number(util_list:opt(SceneId, ?SD_PLAYERRANDOMPROFITLOSS_ZHOUQI)) * ?SECOND_MS,
    util_timer:start_timer(?SCENE_ADJUST_TIMER, Time),
    send_msg(5000, ?SCENE_ADJUST_MSG_TRY_REBOUND),
%%    scene_adjust_srv:cast({?SCENE_ADJUST_MSG_CREATE_ROOM, get(?DICT_SCENE_ID), self()}),
    set_scene_worker_pool_value(0),
    set_scene_worker_state({?SCENE_WORKER_ADJUST_STATE_5, 1}).

%% @doc θ?Ύη½?εΊζ―ηΆζ
handle_set_scene_worker_state(RoomState, RoomRate, Value) ->
    set_scene_worker_pool_value(get_scene_worker_pool_value() + Value),
    set_scene_worker_state({RoomState, RoomRate + 1}).

%% @doc η©ε?ΆθΏε₯εΊζ―
player_enter(PlayerId) ->
    OldPlayerIdList = get_scene_player_id_list(),
    case lists:member(PlayerId, OldPlayerIdList) of
        true ->
            noop;
        false ->
            PlayerIdList = [PlayerId | OldPlayerIdList],
            set_scene_player_id_list(PlayerIdList),
            PlayerNum = length(PlayerIdList),
            reset_player_adjust_state(PlayerIdList, PlayerNum),
            if
                PlayerNum == 1 ->
                    scene_adjust_srv:cast({?SCENE_ADJUST_MSG_CREATE_ROOM, get(?DICT_SCENE_ID), self()});
                true ->
                    noop
            end
    end.

%% @doc η©ε?Άη¦»εΌεΊζ―
player_leave(PlayerId) ->
    OldPlayerIdList = get_scene_player_id_list(),
    case lists:member(PlayerId, OldPlayerIdList) of
        true ->
            PlayerIdList = lists:delete(PlayerId, OldPlayerIdList),
            set_scene_player_id_list(PlayerIdList),
            PlayerNum = length(PlayerIdList),
            delete_scene_worker_player_state(PlayerId),

            %% ζΈηεεΌΉηΈε³ηε­εΈ
%%            del_player_total_cost(PlayerId),
%%            del_player_total_award(PlayerId),
%%            del_player_is_open_rebound(PlayerId),
%%            del_player_rebound_invalid_value(PlayerId),
%%            del_player_rebound_state_list(PlayerId),

            if
                PlayerNum == 0 ->
                    PoolValue = get_scene_worker_pool_value(),
                    set_scene_worker_pool_value(0),
                    set_scene_worker_state({?SCENE_WORKER_ADJUST_STATE_5, 1}),
                    scene_adjust_srv:cast({?SCENE_ADJUST_MSG_CLOSE_ROOM, get(?DICT_SCENE_ID), self(), PoolValue});
                true ->
                    reset_player_adjust_state(PlayerIdList, PlayerNum)
            end;
        false ->
            noop
    end.

%% @doc ε?ζΆε¨εθ°
handle_timer(TimerRef) ->
    case util_timer:handle_timeout(TimerRef, ?SCENE_ADJUST_TIMER) of
        ok ->
            PlayerIdList = get_scene_player_id_list(),
            PlayerNum = length(PlayerIdList),
            reset_player_adjust_state(PlayerIdList, PlayerNum);
        _ ->
            noop
    end.

%% @doc ιη½?ζΏι΄εΌ
reset_room_pool_value() ->
    PoolValue = get_scene_worker_pool_value(),
    set_scene_worker_pool_value(0),
    set_scene_worker_state({?SCENE_WORKER_ADJUST_STATE_5, 1}),
    {ok, PoolValue}.

%% @doc ιη½?η©ε?ΆadjustηΆζ
reset_player_adjust_state(PlayerIdList, PlayerNum) ->
    Time = util_random:random_number(util_list:opt(get(?DICT_SCENE_ID), ?SD_PLAYERRANDOMPROFITLOSS_ZHOUQI)) * ?SECOND_MS,
    util_timer:start_timer(?SCENE_ADJUST_TIMER, Time),
    put(timer_time_scene_adjust, util_time:milli_timestamp() + Time),
    {SceneAdjustState, _AdjustValue} = get_scene_worker_state(),
    if
        PlayerNum == 0 ->
            noop;
        PlayerNum == 1 ->
            PoolValue = get_scene_worker_pool_value(),
            InitRoomValue = util_list:opt(get(?DICT_SCENE_ID), ?SD_ROOMJACKPOT_JINE),
            Value = trunc((PoolValue / InitRoomValue + 1) * 10000),
            PlayerState = get_one_player_state(Value),
            PlayerRate = util:float_num(util_random:random_number(util_list:opt(PlayerState, ?SD_PLAYERLABELLIMIT_DAKUI)) / 10000),
            [PlayerId] = PlayerIdList,
            set_scene_worker_player_state(PlayerId, {PlayerState, PlayerRate});
        true ->
            put(player_adjust_ying_num, 0),
            put(player_adjust_kui_num, 0),
            List = util_list:opt(SceneAdjustState, ?SD_PLAYERLABELPROBABILITY_DAKUI),
            lists:foreach(
                fun(PlayerId) ->
                    PlayerState = get_random_state(List),
                    PlayerRate = util:float_num(util_random:random_number(util_list:opt(PlayerState, ?SD_PLAYERLABELLIMIT_DAKUI)) / 10000),
                    set_scene_worker_player_state(PlayerId, {PlayerState, PlayerRate})
                end,
                util_list:shuffle(PlayerIdList)
            )
    end.
get_random_state(List) ->
%%    ?DEBUG("ζΏι΄ηΆζ :~p", [RoomState]),
    YingNum = get(player_adjust_ying_num),
    KuiNum = get(player_adjust_kui_num),
    State =
        if
            YingNum == 0 ->
                put(player_adjust_ying_num, 1),
                [_Value1, Value2, Value3, Value4, Value5] = List,
                NewList = [Value3, Value4, Value5],
                get_random_state(util_random:random_number(Value2, Value5), NewList, 3);
            KuiNum == 0 ->
                put(player_adjust_kui_num, 1),
                [Value1, Value2, _Value3, _Value4, _Value5] = List,
                NewList = [Value1, Value2],
                get_random_state(util_random:random_number(0, Value2), NewList, 1);
            true ->
                get_random_state(util_random:random_number(0, 10000), List, 1)
        end,
    case State of
        1 ->
            ?SCENE_WORKER_ADJUST_STATE_4;
        2 ->
            ?SCENE_WORKER_ADJUST_STATE_3;
        3 ->
            ?SCENE_WORKER_ADJUST_STATE_5;
        4 ->
            ?SCENE_WORKER_ADJUST_STATE_2;
        5 ->
            ?SCENE_WORKER_ADJUST_STATE_1
    end.
get_random_state(RandomValue, [Value | List], Nth) ->
    if
        RandomValue =< Value ->
            Nth;
        true ->
            get_random_state(RandomValue, List, Nth + 1)
    end.

%% @doc η©ε?ΆζΆθιε·ζΆθ°η¨
cast_add_room_pool_value(PlayerId, _) when PlayerId < 10000 ->
    noop;
cast_add_room_pool_value(PlayerId, {PropId, PropNum}) ->
    cast_add_room_pool_value(PlayerId, [PropId, PropNum]);
cast_add_room_pool_value(PlayerId, [PropId, PropNum]) when is_integer(PropId) andalso is_integer(PropNum) ->
    #ets_obj_player{
        scene_id = SceneId
    } = mod_obj_player:get_obj_player(PlayerId),
    ScenePropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
    if
        ScenePropId == PropId ->
            cast_add_room_pool_value(PlayerId, PropNum);
        true ->
            noop
    end;
cast_add_room_pool_value(PlayerId, PropList) when is_list(PropList) ->
    #ets_obj_player{
        scene_id = SceneId
    } = mod_obj_player:get_obj_player(PlayerId),
    ScenePropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
    PropNum = lists:foldl(
        fun(Prop, TmpNum) ->
            case Prop of
                [ScenePropId, Num] ->
                    TmpNum + Num;
                {ScenePropId, Num} ->
                    TmpNum + Num;
                _ ->
                    TmpNum
            end
        end,
        0, PropList
    ),
    cast_add_room_pool_value(PlayerId, PropNum);
cast_add_room_pool_value(_PlayerId, 0) ->
    noop;
cast_add_room_pool_value(PlayerId, Value) ->
    #db_player_data{
        level = PlayerLevel
    } = mod_player:get_db_player_data(PlayerId),
    #t_role_experience{
        newbee_xiuzheng_list = NewBeeXiuZhengList
    } = mod_player:get_t_level(PlayerLevel),
    ScenePropId = get(?DICT_SCENE_COST_PROP_ID),
%%    ?DEBUG("ε’ε ζΏι΄εΌ οΌ ~p", [{PlayerId, Value}]),
    if
        NewBeeXiuZhengList =/= [] andalso ScenePropId == ?ITEM_GOLD ->
            noop;
        true ->
            SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
            send_msg_pid(SceneWorker, {?SCENE_ADJUST_MSG_CHANGE_POOL_VALUE, add, PlayerId, Value})
    end.

add_room_pool_value(PlayerId, _) when PlayerId < 10000 ->
    noop;
add_room_pool_value(_PlayerId, 0) ->
    noop;
add_room_pool_value(PlayerId, Value) ->
    set_player_total_cost(PlayerId, get_player_total_cost(PlayerId) + Value),
%%    try_rebound(PlayerId),
    add_room_pool_value(Value).
add_room_pool_value(Value) ->
%%    ?DEBUG("η»η©ε?Άζ£ι±οΌε ζΏι΄ζ± ε­εΌ : ~p",[Value * util_list:opt(get(?DICT_SCENE_ID), ?SD_CHOUSHUI_LIST) / 10000]),
    set_scene_worker_pool_value(get_scene_worker_pool_value() + Value * get_scene_adjust_rate_value(get(?DICT_SCENE_ID)) / 10000).


%% @doc η©ε?Άε₯ε±ιε·ζΆθ°η¨
cast_cost_room_pool_value(PlayerId, _) when PlayerId < 10000 ->
    noop;
cast_cost_room_pool_value(PlayerId, {PropId, PropNum}) ->
    cast_cost_room_pool_value(PlayerId, [PropId, PropNum]);
cast_cost_room_pool_value(PlayerId, [PropId, PropNum]) when is_integer(PropId) andalso is_integer(PropNum) ->
    #ets_obj_player{
        scene_id = SceneId
    } = mod_obj_player:get_obj_player(PlayerId),
    ScenePropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
    if
        ScenePropId == PropId ->
            cast_cost_room_pool_value(PlayerId, PropNum);
        true ->
            noop
    end;
cast_cost_room_pool_value(PlayerId, PropList) when is_list(PropList) ->
    #ets_obj_player{
        scene_id = SceneId
    } = mod_obj_player:get_obj_player(PlayerId),
    ScenePropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
    PropNum = lists:foldl(
        fun(Prop, TmpNum) ->
            case Prop of
                [ScenePropId, Num] ->
                    TmpNum + Num;
                {ScenePropId, Num} ->
                    TmpNum + Num;
                _ ->
                    TmpNum
            end
        end,
        0, PropList
    ),
    cast_cost_room_pool_value(PlayerId, PropNum);
cast_cost_room_pool_value(_PlayerId, 0) ->
    noop;
cast_cost_room_pool_value(PlayerId, Value) ->
    #db_player_data{
        level = PlayerLevel
    } = mod_player:get_db_player_data(PlayerId),
    #t_role_experience{
        newbee_xiuzheng_list = NewBeeXiuZhengList
    } = mod_player:get_t_level(PlayerLevel),
    ScenePropId = get(?DICT_SCENE_COST_PROP_ID),
    if
        NewBeeXiuZhengList =/= [] andalso ScenePropId == ?ITEM_GOLD ->
            noop;
        true ->
            %% ?DEBUG("εε°ζΏι΄εΌ οΌ ~p", [{PlayerId, Value}]),
            SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
            send_msg_pid(SceneWorker, {?SCENE_ADJUST_MSG_CHANGE_POOL_VALUE, cost, PlayerId, Value})
    end.

cost_room_pool_value(PlayerId, _Level, _) when PlayerId < 10000 ->
    noop;
cost_room_pool_value(_PlayerId, _Level, 0) ->
    noop;
cost_room_pool_value(PlayerId, Level, Value) ->
    #t_role_experience{
        newbee_xiuzheng_list = NewBeeXiuZhengList
    } = mod_player:get_t_level(Level),
    ScenePropId = get(?DICT_SCENE_COST_PROP_ID),
    if
        NewBeeXiuZhengList =/= [] andalso ScenePropId == ?ITEM_GOLD ->
            noop;
        true ->
            cost_room_pool_value(PlayerId, Value)
    end.
cost_room_pool_value(PlayerId, _) when PlayerId < 10000 ->
    noop;
cost_room_pool_value(_PlayerId, 0) ->
    noop;
cost_room_pool_value(PlayerId, Value) ->
    set_player_total_award(PlayerId, get_player_total_award(PlayerId) + Value),
%%    try_rebound(PlayerId),
    cost_room_pool_value(Value).
cost_room_pool_value(Value) ->
%%    ?DEBUG("η»η©ε?Άε₯ε±οΌζ£ζΏι΄ζ± ε­εΌ : ~p",[Value]),
    set_scene_worker_pool_value(get_scene_worker_pool_value() - Value).

call_get_player_adjust_state(PlayerId) ->
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    gen_server:call(SceneWorker, {?SCENE_ADJUST_MSG_GET_PLAYER_STATE, PlayerId}).
get_player_adjust_state(PlayerId) ->
    case get_scene_worker_player_state(PlayerId) of
        {PlayerAdjustState, _PlayerAdjustRate} ->
            PlayerAdjustState;
        _ ->
            ?UNDEFINED
    end.
get_player_adjust(PlayerId) ->
    case get_player_is_open_rebound(PlayerId) of
        {true, _State, Adjust, _Ref} ->
            Adjust / 10000;
        _ ->
            PoolValue = get_scene_worker_pool_value(),
            {PlayerAdjustState, PlayerAdjustRate} = get_scene_worker_player_state(PlayerId),
            PlayerNum = length([ThisPlayerId || ThisPlayerId <- mod_scene_player_manager:get_all_obj_scene_player_id(), ThisPlayerId > 10000]),
            if
                PlayerNum == 1 ->
                    PlayerAdjustRate;
                true ->
                    if
                        PoolValue >= 0 ->
                            if
                                PlayerAdjustState == ?SCENE_WORKER_ADJUST_STATE_1 orelse PlayerAdjustState == ?SCENE_WORKER_ADJUST_STATE_2 ->
                                    PlayerAdjustRate;
                                PlayerAdjustState == ?SCENE_WORKER_ADJUST_STATE_5 ->
                                    PlayerAdjustRate;
                                true ->
                                    1
                            end;
                        true ->
                            if
                                PlayerAdjustState == ?SCENE_WORKER_ADJUST_STATE_3 orelse PlayerAdjustState == ?SCENE_WORKER_ADJUST_STATE_4 ->
                                    PlayerAdjustRate;
                                PlayerAdjustState == ?SCENE_WORKER_ADJUST_STATE_5 ->
                                    PlayerAdjustRate;
                                true ->
                                    1
                            end
                    end
            end
    end.

get_one_player_state(Value) ->
    get_one_player_state(Value, ?SD_ONEPLAYERLABELLIMIT_DAKUI).
get_one_player_state(Value, []) ->
    exit({value_error, Value});
get_one_player_state(Value, [[[Min, Max], StateList] | List]) ->
    if
        Value >= Min andalso Value =< Max ->
            util_random:get_probability_item(StateList);
        true ->
            get_one_player_state(Value, List)
    end.

%% @doc θ·εΎεΊζ―adjustζ½ζ°΄εΌ
get_scene_adjust_rate_value(SceneId) ->
    case game_config:get_config_scene_adjust_chou_shui_value(SceneId) of
        null ->
            util_list:opt(SceneId, ?SD_CHOUSHUI_LIST, 10000);
        Value ->
%%            ?DEBUG("θ·εΎεΌ οΌ ~p", [Value]),
            Value
    end.

%% =========================================== FUNCTION END ===================================================

%% ============================================= DICT START ===================================================

%% @doc εΊζ―ζΏι΄ε₯ζ± 
set_scene_worker_pool_value(Value) ->
%%    ?DEBUG("δΏ?ζΉζΏι΄ε₯ζ± εΌ οΌ ~p", [Value]),
    put({?MODULE, ?DICT_SCENE_WORKER_POOL_VALUE}, Value).
get_scene_worker_pool_value() ->
    get({?MODULE, ?DICT_SCENE_WORKER_POOL_VALUE}).

%% @doc εΊζ―ζΏι΄ηδΊηΆζεηδΊεΌ
set_scene_worker_state(Data) ->
    put({?MODULE, ?DICT_SCENE_WORKER_STATE}, Data).
get_scene_worker_state() ->
    get({?MODULE, ?DICT_SCENE_WORKER_STATE}).

%% @doc θ?Ύη½?η©ε?ΆηδΊηΆζεηδΊεΌ
set_scene_worker_player_state(PlayerId, Data) ->
    put({?MODULE, ?DICT_SCENE_WORKER_STATE, PlayerId}, Data).
get_scene_worker_player_state(PlayerId) ->
    get({?MODULE, ?DICT_SCENE_WORKER_STATE, PlayerId}).
delete_scene_worker_player_state(PlayerId) ->
    erase({?MODULE, ?DICT_SCENE_WORKER_STATE, PlayerId}).

%% @doc θ·εΎζδΏ?ζ­£ηεΊζ―η©ε?Άεθ‘¨
get_scene_player_id_list() ->
    util:get_dict({?MODULE, ?DICT_SCENE_WORKER_PLAYER_ID_LIST}, []).
set_scene_player_id_list(PlayerIdList) ->
    put({?MODULE, ?DICT_SCENE_WORKER_PLAYER_ID_LIST}, PlayerIdList).


%% ============================================== DICT END ===================================================

%% ============================================== REBOUND START ===================================================
%% ============================================== δΏ?ζ­£εεΌΉ ===================================================
%% @doc η©ε?ΆθΏε₯εΊζ―εε§εεεΌΉ
player_enter_init_rebound(PlayerId) ->
    SceneId = get(?DICT_SCENE_ID),
    PropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
    PropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
    SceneValue = util_list:opt(SceneId, ?SD_ROOMJACKPOT_JINE),
    IsOpenRebound = PropNum >= SceneValue * util_list:opt(SceneId, ?SD_OPENREBOUNDCORRECT) / 10000,
    PlayerReboundInvalidValue = util_random:random_number(util_random:get_probability_item([{B, A} || [A, B] <- ?SD_CORRECTEND_LIST])),
    set_player_rebound_invalid_value(PlayerId, PlayerReboundInvalidValue / 10000),
    set_player_is_open_rebound(PlayerId, IsOpenRebound).
%%    set_player_prop_num(PlayerId, PropNum).

%% @doc η©ε?Άη¦»εΌεΊζ―ζΈηεεΌΉ
player_leave_clear_rebound(PlayerId) ->
%%     ζΈηεεΌΉηΈε³ηε­εΈ
    del_player_total_cost(PlayerId),
    del_player_total_award(PlayerId),
    del_player_is_open_rebound(PlayerId),
    del_player_rebound_invalid_value(PlayerId),
    del_player_rebound_state_list(PlayerId).

get_player_is_open_rebound(PlayerId) ->
    get({scene_adjust_is_open_rebound, PlayerId}).
set_player_is_open_rebound(PlayerId, IsOpenRebound) ->
    put({scene_adjust_is_open_rebound, PlayerId}, IsOpenRebound).
del_player_is_open_rebound(PlayerId) ->
    erase({scene_adjust_is_open_rebound, PlayerId}).

%% @doc θ·εΎη©ε?Άιε·εΊη‘ζ°ι
%%get_player_prop_num(PlayerId) ->
%%    util:get_dict({scene_adjust_rebound_prop_num, PlayerId}, 0).
%%set_player_prop_num(PlayerId, PropNum) ->
%%    put({scene_adjust_rebound_prop_num, PlayerId}, PropNum).
%%del_player_prop_num(PlayerId) ->
%%    erase({scene_adjust_rebound_prop_num, PlayerId}).

add_player_total_cost(_PlayerId, 0) ->
    noop;
add_player_total_cost(PlayerId, _AddNum) when PlayerId < 10000 ->
    noop;
add_player_total_cost(PlayerId, AddNum) ->
    set_player_total_cost(PlayerId, get_player_total_cost(PlayerId) + AddNum).

%% @doc θ·εΎη©ε?Άζζη΄―θ?‘ζΆθ
get_player_total_cost(PlayerId) ->
    util:get_dict({scene_adjust_rebound_total_cost, PlayerId}, 0).
set_player_total_cost(PlayerId, Cost) ->
    put({scene_adjust_rebound_total_cost, PlayerId}, Cost).
del_player_total_cost(PlayerId) ->
    erase({scene_adjust_rebound_total_cost, PlayerId}).

add_player_total_award(_PlayerId, 0) ->
    noop;
add_player_total_award(PlayerId, _AddNum) when PlayerId < 10000 ->
    noop;
add_player_total_award(PlayerId, AddNum) ->
    set_player_total_award(PlayerId, get_player_total_award(PlayerId) + AddNum).

%% @doc θ·εΎη©ε?Άζζη΄―θ?‘ε₯ε±
get_player_total_award(PlayerId) ->
    util:get_dict({scene_adjust_rebound_total_award, PlayerId}, 0).
set_player_total_award(PlayerId, Award) ->
    put({scene_adjust_rebound_total_award, PlayerId}, Award).
del_player_total_award(PlayerId) ->
    erase({scene_adjust_rebound_total_award, PlayerId}).

%% @doc θ·εΎη©ε?ΆεεΌΉε€±ζεΌ
get_player_rebound_invalid_value(PlayerId) ->
    util:get_dict({scene_adjust_rebound_invalid_value, PlayerId}, 0).
set_player_rebound_invalid_value(PlayerId, Value) ->
    put({scene_adjust_rebound_invalid_value, PlayerId}, Value).
del_player_rebound_invalid_value(PlayerId) ->
    erase({scene_adjust_rebound_invalid_value, PlayerId}).

%% @doc θ·εΎη©ε?ΆεεΌΉηΆζεθ‘¨[θ§¦εΊεεΌΉζ―ε¦ε―δ»₯εΌε―οΌζ΄ε―εεΌΉζ―ε¦ε―δ»₯εΌε―]
get_player_rebound_state_list(PlayerId) ->
    util:get_dict({scene_adjust_rebound_state_list, PlayerId}, [true, true]).
set_player_rebound_state_list(PlayerId, List) ->
%%    if
%%        List == [false, false] ->
%%            set_player_is_open_rebound(PlayerId, false);
%%        true ->
%%            noop
%%    end,
    put({scene_adjust_rebound_state_list, PlayerId}, List).
del_player_rebound_state_list(PlayerId) ->
    erase({scene_adjust_rebound_state_list, PlayerId}).

try_rebound() ->
    lists:foreach(
        fun(PlayerId) ->
            if
                PlayerId >= 10000 ->
                    %%            ?DEBUG("εεΌΉ οΌ ~p", [{PlayerId}]),
                    try_rebound(PlayerId);
                true ->
                    noop
            end
        end,
        mod_scene_player_manager:get_all_obj_scene_player_id()
    ).
try_rebound(PlayerId) ->
    %% ζ―ε¦εΌε―εεΌΉ false | true ζ­£εΈΈδΏ?ζ­£ | {true,ε½εηΆζ(0:θ§¦εΊ,1:ζ΄ε―)}
    Data = get_player_is_open_rebound(PlayerId),
%%    ?DEBUG("εεΌΉζ°ζ? οΌ ~p", [Data]),
    case Data of
        true ->
            List = get_player_rebound_state_list(PlayerId),
            if
                List == [false, false] ->
                    noop;
                true ->
                    do_try_rebound(PlayerId)
            end;
        {true, State, _Adjust, _Ref} ->
            ReboundInvalidValue = get_player_rebound_invalid_value(PlayerId),
            TotalCost = get_player_total_cost(PlayerId),
            TotalAward = get_player_total_award(PlayerId),
            PlayerPropNum = mod_prop:get_player_prop_num(PlayerId, get(?DICT_SCENE_COST_PROP_ID)),
            PropNum = PlayerPropNum + trunc(TotalCost * get_scene_adjust_rate_value(get(?DICT_SCENE_ID)) / 10000) - TotalAward,
            [ChuDiList, BaoFuList] = ?SD_REBOUND_LIST,
            if
                (TotalCost - TotalAward) / PropNum < (1 - ReboundInvalidValue) andalso State == 0 ->
                    ?DEBUG("εεΌΉε€±ζ οΌ ~p", [{PlayerId, TotalCost, TotalAward, PlayerPropNum, PropNum, ReboundInvalidValue}]),
                    [_ChuDiIsCanOpen, BaoFuIsCanOpen] = get_player_rebound_state_list(PlayerId),
                    [[_ChuDiValueMin, _ChuDiValueMax], _ChuDiTimesLimit, _ChuDiDuration, ChuDiCdTime, [_ChuDiAdjustMin, _ChuDiAdjustMax]] = ChuDiList,
                    %% θ§¦εΊεεΌΉη»ζ
                    set_player_rebound_state_list(PlayerId, [false, BaoFuIsCanOpen]),
                    send_msg(ChuDiCdTime * ?SECOND_MS, {?SCENE_ADJUST_MSG_REBOUND_CD_END, PlayerId, 0}),
                    set_player_is_open_rebound(PlayerId, true);
                (TotalCost - TotalAward) / PropNum > (1 - ReboundInvalidValue) andalso State == 1 ->
                    ?DEBUG("εεΌΉε€±ζ οΌ ~p", [{PlayerId, TotalCost, TotalAward, PlayerPropNum, PropNum, ReboundInvalidValue}]),
                    [ChuDiIsCanOpen, _BaoFuIsCanOpen] = get_player_rebound_state_list(PlayerId),
                    [[_BaoFuValueMin, _BaoFuValueMax], _BaoFuTimesLimit, _BaoFuDuration, BaoFuCdTime, [_BaoFuAdjustMin, _BaoFuAdjustMax]] = BaoFuList,
                    %% ζ΄ε―εεΌΉη»ζ
                    set_player_rebound_state_list(PlayerId, [ChuDiIsCanOpen, false]),
                    send_msg(BaoFuCdTime * ?SECOND_MS, {?SCENE_ADJUST_MSG_REBOUND_CD_END, PlayerId, 1}),
                    set_player_is_open_rebound(PlayerId, true);
                true ->
                    noop
            end;
        false ->
            noop
    end.
do_try_rebound(PlayerId) ->
    TotalCost = get_player_total_cost(PlayerId),
    TotalAward = get_player_total_award(PlayerId),
    PlayerPropNum = mod_prop:get_player_prop_num(PlayerId, get(?DICT_SCENE_COST_PROP_ID)),
    PropNum =
        case PlayerPropNum + trunc(TotalCost * get_scene_adjust_rate_value(get(?DICT_SCENE_ID)) / 10000) - TotalAward of
            0 ->
                1;
            PropNum1 ->
                PropNum1
        end,
    ReboundStateList = get_player_rebound_state_list(PlayerId),
    [ChuDiIsCanOpen, BaoFuIsCanOpen] = ReboundStateList,
    %% εεΌΉη³»ζ°
%%    ?DEBUG("ζ₯ηζ°ζ? οΌ ~p", [{PlayerId, TotalCost, TotalAward, PropNum, PlayerPropNum}]),
    Value = (TotalCost - TotalAward) / PropNum * 10000,
    PlayerAdjustState = get_player_adjust_state(PlayerId),
%%    80000 920000 0 1000000 9200
%%    ?DEBUG("εεΌΉ οΌ ~p", [{PlayerId, PlayerPropNum, TotalCost, TotalAward, PropNum, Value, PlayerAdjustState, ChuDiIsCanOpen}]),
    [ChuDiList, BaoFuList] = ?SD_REBOUND_LIST,
    [[ChuDiValueMin, ChuDiValueMax], ChuDiTimesLimit, ChuDiDuration, _ChuDiCdTime, [ChuDiAdjustMin, ChuDiAdjustMax]] = ChuDiList,
    [[BaoFuValueMin, BaoFuValueMax], BaoFuTimesLimit, BaoFuDuration, _BaoFuCdTime, [BaoFuAdjustMin, BaoFuAdjustMax]] = BaoFuList,
    PoolValue = get_scene_worker_pool_value(),
    if
    %% ε¨θ§¦εΊθε΄εοΌεΉΆδΈη©ε?ΆδΈε€ε¨ηε©ζ θ?°ηζζΆοΌε―δ»₯θ§¦εθ§¦εΊεεΌΉ
        ChuDiValueMin =< Value andalso Value =< ChuDiValueMax andalso ((PlayerAdjustState =/= ?SCENE_WORKER_ADJUST_STATE_1 andalso PlayerAdjustState =/= ?SCENE_WORKER_ADJUST_STATE_2) orelse PoolValue < 0) andalso ChuDiIsCanOpen ->
            %% θ§¦εΊεεΌΉ
%%            ?DEBUG("θ§¦εΊεεΌΉ οΌ ~p", [{PlayerId, PlayerPropNum, TotalCost, TotalAward, PropNum, Value}]),
            DbPlayerAdjustRebound = get_db_player_adjust_rebound(PlayerId, 0),
            #db_player_adjust_rebound{
                trigger_times = TriggerTimes
            } = DbPlayerAdjustRebound,
            if
                TriggerTimes < ChuDiTimesLimit ->
                    ReboundAdjust = util_random:random_number(ChuDiAdjustMin, ChuDiAdjustMax),
                    Tran =
                        fun() ->
                            db:write(DbPlayerAdjustRebound#db_player_adjust_rebound{trigger_times = TriggerTimes + 1, trigger_time = util_time:timestamp()})
                        end,
                    db:do(Tran),
                    Ref = erlang:make_ref(),
                    set_player_is_open_rebound(PlayerId, {true, 0, ReboundAdjust, Ref}),
                    send_msg(ChuDiDuration * ?SECOND_MS, {?SCENE_ADJUST_MSG_REBOUND_END, PlayerId, 0, Ref});
                true ->
                    set_player_rebound_state_list(PlayerId, [false, BaoFuIsCanOpen])
            end;
        BaoFuValueMin =< Value andalso Value =< BaoFuValueMax andalso BaoFuIsCanOpen ->
            %% ζ΄ε―
%%            ?DEBUG("ζ΄ε―εεΌΉ οΌ ~p", [{PlayerId, PlayerPropNum, TotalCost, TotalAward, PropNum, Value}]),
            DbPlayerAdjustRebound = get_db_player_adjust_rebound(PlayerId, 1),
            #db_player_adjust_rebound{
                trigger_times = TriggerTimes
            } = DbPlayerAdjustRebound,
            if
                TriggerTimes < BaoFuTimesLimit ->
                    ReboundAdjust = util_random:random_number(BaoFuAdjustMin, BaoFuAdjustMax),
                    Tran =
                        fun() ->
                            db:write(DbPlayerAdjustRebound#db_player_adjust_rebound{trigger_times = TriggerTimes + 1, trigger_time = util_time:timestamp()})
                        end,
                    db:do(Tran),
                    Ref = erlang:make_ref(),
                    set_player_is_open_rebound(PlayerId, {true, 1, ReboundAdjust, Ref}),
                    send_msg(BaoFuDuration * ?SECOND_MS, {?SCENE_ADJUST_MSG_REBOUND_END, PlayerId, 1, Ref});
                true ->
                    set_player_rebound_state_list(PlayerId, [ChuDiIsCanOpen, false])
            end;
        true ->
            noop
    end.

%% @doc θ§¦εΊεεΌΉη»ζ
rebound_end(PlayerId, State, Ref) ->
    case get_player_is_open_rebound(PlayerId) of
        {true, State, _Adjust, Ref} ->
            [ChuDiList, BaoFuList] = ?SD_REBOUND_LIST,
            [[_ChuDiValueMin, _ChuDiValueMax], _ChuDiTimesLimit, _ChuDiDuration, ChuDiCdTime, [_ChuDiAdjustMin, _ChuDiAdjustMax]] = ChuDiList,
            [[_BaoFuValueMin, _BaoFuValueMax], _BaoFuTimesLimit, _BaoFuDuration, BaoFuCdTime, [_BaoFuAdjustMin, _BaoFuAdjustMax]] = BaoFuList,
            set_player_is_open_rebound(PlayerId, true),
            [ChuDiIsCanOpen, BaoFuIsCanOpen] = get_player_rebound_state_list(PlayerId),
            case State of
                0 ->
                    %% θ§¦εΊεεΌΉη»ζ
                    set_player_rebound_state_list(PlayerId, [false, BaoFuIsCanOpen]),
                    send_msg(ChuDiCdTime * ?SECOND_MS, {?SCENE_ADJUST_MSG_REBOUND_CD_END, PlayerId, 0});
                1 ->
                    %% ζ΄ε―εεΌΉη»ζ
                    set_player_rebound_state_list(PlayerId, [ChuDiIsCanOpen, false]),
                    send_msg(BaoFuCdTime * ?SECOND_MS, {?SCENE_ADJUST_MSG_REBOUND_CD_END, PlayerId, 1})
            end;
        _ ->
            noop
    end.

%% @doc θ§¦εΊεεΌΉcdη»ζ
rebound_cd_end(PlayerId, State) ->
    case get_player_is_open_rebound(PlayerId) of
        ?UNDEFINED ->
            noop;
        _ ->
            [ChuDiIsCanOpen, BaoFuIsCanOpen] = get_player_rebound_state_list(PlayerId),
            case State of
                0 ->
                    %% θ§¦εΊεεΌΉη»ζ
                    set_player_rebound_state_list(PlayerId, [true, BaoFuIsCanOpen]);
                1 ->
                    %% ζ΄ε―εεΌΉη»ζ
                    set_player_rebound_state_list(PlayerId, [ChuDiIsCanOpen, true])
            end
    end.

%% @doc DB θ·εΎη©ε?ΆδΏ?ζ­£εεΌΉ
get_db_player_adjust_rebound(PlayerId, ReboundType) ->
    case db:read(#key_player_adjust_rebound{player_id = PlayerId, rebound_type = ReboundType}) of
        null ->
            #db_player_adjust_rebound{
                player_id = PlayerId,
                rebound_type = ReboundType,
                trigger_times = 0,
                trigger_time = 0
            };
        DbPlayerAdjustRebound ->
            #db_player_adjust_rebound{
                trigger_time = TriggerTime
            } = DbPlayerAdjustRebound,
            case util_time:is_today(TriggerTime) of
                true ->
                    DbPlayerAdjustRebound;
                false ->
                    DbPlayerAdjustRebound#db_player_adjust_rebound{
                        trigger_times = 0,
                        trigger_time = 0
                    }
            end
    end.

%% ============================================== REBOUND END ===================================================

%% ============================================== NOVICE START ===================================================
%% ============================================== ζ°ζδΏ?ζ­£ ===================================================

%% ============================================== NOVICE END ===================================================

%% @doc εε§εη©ε?Άζζζ°ζδΏ?ζ­£
%%init_fight_novice_adjust(?OBJ_TYPE_PLAYER, ObjId, Level) ->
%%    #t_role_experience{
%%        newbee_xiuzheng_list = NewBeeXiuZhengList
%%    } = mod_player:get_t_level(Level),
%%    ScenePropId = get(?DICT_SCENE_COST_PROP_ID),
%%    Data =
%%        if
%%            NewBeeXiuZhengList =/= [] andalso ScenePropId == ?ITEM_GOLD ->
%%                {value, util_list:opt(ObjId rem 5, NewBeeXiuZhengList)};
%%            true ->
%%                false
%%        end,
%%    put(fight_scene_adjust_novice_adjust, Data);
%%init_fight_novice_adjust(_, _, _) ->
%%    noop.

%% @doc θ·εΎζζζ°ζδΏ?ζ­£
%%get_fight_novice_adjust() ->
%%    util:get_dict(fight_scene_adjust_novice_adjust, false).

%%del_fight_novice_adjust() ->
%%    erase(fight_scene_adjust_novice_adjust).

%% @doc ζ―ε¦εΌε―ζ°ζδΏ?ζ­£
is_newbee(PlayerId) ->
    Value = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?TRUE),
    ?TRAN_INT_2_BOOL(Value).
get_newbee_adjust_value(?OBJ_TYPE_PLAYER, PlayerId) when PlayerId >= 10000 ->
    case is_newbee(PlayerId) of
        true ->
            PlayerGameDataGetExpNum = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_GET_EXP_NUM),
%%            ?DEBUG("η»ιͺζ°ι οΌ ~p", [{PlayerId, PlayerGameDataGetExpNum}]),
            get_newbee_adjust_value(PlayerId, PlayerGameDataGetExpNum, ?SD_NOVICECORRECTION_LIST);
        false ->
            false
    end;
get_newbee_adjust_value(_, _) ->
    false.
get_newbee_adjust_value(PlayerId, _PlayerGameDataGetExpNum, []) ->
    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?FALSE),
    false;
get_newbee_adjust_value(PlayerId, _PlayerGameDataGetExpNum, [[[_MinExpNum, _MaxExpNum], [0]] | _List]) ->
    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?FALSE),
    false;
get_newbee_adjust_value(PlayerId, PlayerGameDataGetExpNum, [[[MinExpNum, MaxExpNum], AdjustList] | List]) ->
    if
        MinExpNum =< PlayerGameDataGetExpNum andalso (PlayerGameDataGetExpNum =< MaxExpNum orelse MaxExpNum == 0) ->
            {value, util_list:opt(PlayerId rem 5, AdjustList)};
        true ->
            get_newbee_adjust_value(PlayerId, PlayerGameDataGetExpNum, List)
    end.

try_add_exp(PlayerId, PropId, OldNum, NewNum) ->
    case PropId == ?ITEM_EXP andalso NewNum > OldNum andalso is_newbee(PlayerId) of
        true ->
            PlayerGameDataGetExpNum = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_GET_EXP_NUM),
            case get_newbee_adjust_value(PlayerId, PlayerGameDataGetExpNum, ?SD_NOVICECORRECTION_LIST) of
                false ->
                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?FALSE);
                _ ->
                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_GET_EXP_NUM, PlayerGameDataGetExpNum + NewNum - OldNum)
            end;
        false ->
            noop
    end.