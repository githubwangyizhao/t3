%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 11月 2021 下午 03:32:42
%%%-------------------------------------------------------------------
-module(mod_wheel).
-author("Administrator").

-include("wheel.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
-include("error.hrl").

%% API
-export([
    join_wheel/2,               %% 加入无尽对决
    bet/3,                      %% 投注
    get_record/1,               %% 获得走势图记录
    get_bet_record/1,           %% 获得投注记录
    exit_wheel/1,               %% 退出无尽对决
    get_player_list/0,          %% 获得玩家列表
    use_last_bet/1
]).

%% @doc 加入无尽对决
join_wheel(PlayerId, Type) ->
%%    mod_function:assert_open(PlayerId,?FUNCTION_),
    PlatformId = mod_server_config:get_platform_id(),
    ServerId = mod_player:get_player_data(PlayerId, server_id),
    ModelHeadFigure = api_player:pack_model_head_figure(PlayerId),
    wheel_srv:call({?WHEEL_MSG_JOIN_WHEEL, PlayerId, Type, PlatformId, ServerId, ModelHeadFigure}).

%% @doc 投注
bet(PlayerId, BetId, Num) ->
    WheelType = get(wheel_type),
    #t_big_wheel{
        odds_list = OddsList,
        betting_list = [PropId, _]
    } = wheel_srv_mod:get_t_big_wheel(WheelType),
    ?ASSERT(util_list:opt(BetId, OddsList) =/= ?UNDEFINED),
%%    logic_get_big_wheel_bet_list:assert_get({WheelType, BetId}),
%%    GoldNum = mod_prop:get_player_prop_num(PlayerId,?ITEM_GOLD),
%%    GoldNum = mod_prop:get_player_prop_num(PlayerId,?ITEM_RUCHANGJUAN),
%%    PropId =
%%        case WheelType of
%%            1 ->
%%                ?ITEM_GOLD;
%%            2 ->
%%                ?ITEM_RUCHANGJUAN
%%        end,
    PropList = [{PropId, Num}],
    mod_prop:assert_prop_num(PlayerId, PropList),
    Tran =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, PropList, ?LOG_TYPE_BIG_WHEEL),
            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_WUJINDUIJUE_COUNT, ?CONDITIONS_VALUE_ADD, 1}),
            wheel_srv:call({?WHEEL_MSG_BET, PlayerId, BetId, Num})
        end,
    db:do(Tran).

%% @doc 获得走势图记录
get_record(RecordType) ->
    WheelType = get(wheel_type),
    ?ASSERT(WheelType =/= ?UNDEFINED),
    mod_server_rpc:call_war(wheel_srv_mod, handle_get_record, [WheelType, RecordType]).
%%    rpc:call(node(), wheel_srv_mod, handle_get_record, [WheelType]).

%% @doc 获得投注记录
get_bet_record(PlayerId) ->
    WheelType = get(wheel_type),
    ?ASSERT(WheelType =/= ?UNDEFINED),
    mod_server_rpc:call_war(wheel_srv_mod, handle_get_bet_record, [PlayerId, WheelType]).
%%    rpc:call(node(), wheel_srv_mod, handle_get_bet_record, [PlayerId]).

%% @doc 获得玩家列表
get_player_list() ->
    WheelType = get(wheel_type),
    wheel_srv:call({?WHEEL_MSG_GET_PLAYER_LIST, WheelType}).
%%    mod_server_rpc:call_war(wheel_srv_mod, handle_get_player_list, [WheelType]).
%%    rpc:call(node(), wheel_srv_mod, handle_get_player_list, [WheelType]).

%% @doc 退出无尽对决
exit_wheel(PlayerId) ->
    WheelType = erase(wheel_type),
    case WheelType of
        ?UNDEFINED ->
            noop;
        _ ->
            wheel_srv:cast({?WHEEL_MSG_EXIT_WHEEL, PlayerId})
    end.

%% @doc 延续上把
use_last_bet(PlayerId) ->
%%    WheelType = get(wheel_type),
%%    ?ASSERT(WheelType =/= ?UNDEFINED),
    {ok, WheelType, LastBetList} = wheel_srv:call({?WHEEL_MSG_GET_LAST_BET_LIST, PlayerId}),
    ?ASSERT(LastBetList =/= [], ?ERROR_NONE),
    TotalNum = lists:sum([BetNum || {_BetId, BetNum} <- LastBetList]),
    #t_big_wheel{
        betting_list = [PropId, _]
    } = wheel_srv_mod:get_t_big_wheel(WheelType),
    PropList = [{PropId, TotalNum}],
    mod_prop:assert_prop_num(PlayerId, PropList),
    Tran =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, PropList, ?LOG_TYPE_BIG_WHEEL),
            wheel_srv:call({?WHEEL_MSG_USE_LAST_BET_LIST, PlayerId, LastBetList})
        end,
    db:do(Tran),
    ok.