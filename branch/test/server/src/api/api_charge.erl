%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 24. 五月 2018 17:10
%%%-------------------------------------------------------------------
-module(api_charge).
-author("home").

%% API
-export([
%%    get_charge_http_param_info/2,
    notice_is_open_charge/2             % 通知是否开启充值状态
]).

-export([
    api_get_charge_shop_data/1,

    charge/2,
    api_charge/2,
    get_charge_type/2,

    notice_charge_data/3,
    notice_charge_data/4
]).

-include("common.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("error.hrl").
-include("gen/db.hrl").

%% @doc     请求充值http参数
%%get_charge_http_param_info(
%%    #m_charge_get_charge_http_param_info_tos{},
%%    #conn{player_id = PlayerId} = State
%%) ->
%%    ?REQUEST_INFO("请求充值http参数"),
%%    {Result, ParamList} =
%%        case catch mod_charge:get_charge_http_param_info(PlayerId) of
%%            {ok, ParamList1} when is_list(ParamList1) ->
%%                {api_common:api_result_to_enum(ok), ParamList1};
%%            R ->
%%                R1 = api_common:api_result_to_enum(R),
%%                {R1, []}
%%        end,
%%    Out = proto:encode(#m_charge_get_charge_http_param_info_toc{result = Result, charge_request_data = pack_charge_request_data(ParamList)}),
%%    mod_socket:send(Out),
%%    State.

%% @doc     通知是否开启充值状态
notice_is_open_charge(PlayerId, IsOpen) ->
    Out = proto:encode(#m_charge_notice_is_open_charge_toc{is_open = IsOpen}),
    mod_socket:send(PlayerId, Out).

%% @fun 打包充值web请求数据
pack_charge_request_data(List) ->
    [#chargerequestdata{key = util:to_binary(Key), value = util:to_binary(Value)} || {Key, Value} <- List].

%% @doc  充值
charge(
    #m_charge_charge_tos{item_id = ItemId, count = Count, charge_type_idx = ChargeTypeIdx},
    State = #conn{player_id = PlayerId, ip = IP}
) ->
    ?REQUEST_INFO("购买平台商品:" ++ util:to_list(ItemId)),
    {Result, ChargeValue, List} =
        case catch mod_charge:charge_platform_item(PlayerId, ItemId, Count, IP, ChargeTypeIdx) of
            ok ->
                {?P_SUCCESS, 0, []};
            {ok, ChargeValue1} when is_integer(ChargeValue1) ->
                {?P_NO_ENOUGH_PROP, ChargeValue1, []};
            {ok, ParamList} when is_list(ParamList) ->
                ?INFO("ParamList: ~p", [ParamList]),
                {?P_NO_ENOUGH_PROP, 0, ParamList};
            {'EXIT', ?ERROR_INTERFACE_CD_TIME} ->
                ?WARNING("购买平台商品操作过快:~p~n", [{PlayerId, ItemId, Count}]),
                {?P_FAIL, 0, []};
            R ->
                ?INFO("平台充值商品失败:~p~n", [{ItemId, Count, R}]),
                R1 = api_common:api_result_to_enum(R),
                {R1, 0, []}
        end,
    api_charge(PlayerId, Result, ItemId, Count, ChargeValue, List, ChargeTypeIdx),
    State.

%% @doc  獲取充值類型
get_charge_type(
    #m_charge_get_charge_type_tos{},
    State
) ->
    {Status, List} = mod_charge:get_charge_type(),
    proto:encode(#m_charge_get_charge_type_toc{status = Status, charge_type_data = pack_charge_type_data_list(List)}),
    State.

pack_charge_type_data_list(List) ->
    [#chargetypedata{idx = Key, name = list_to_binary(util_string:to_utf8(Value))} || {Key, Value} <- List].

%% @doc fun api平台商品结果
api_charge(PlayerId, ItemId) ->
    api_charge(PlayerId, ?P_SUCCESS, ItemId, 1, 0, [], ?UNDEFINED).
api_charge(PlayerId, Result, ItemId, Count, ChargeValue, List, ChargeTypeIdx) ->
    Proto = #m_charge_charge_toc{result = Result, item_id = ItemId, count = Count, charge_value = ChargeValue, charge_request_data = pack_charge_request_data(List), charge_type_idx = ChargeTypeIdx},
    ?INFO("proto: ~p", [Proto]),
    Out = proto:encode(Proto),
    mod_socket:send(PlayerId, Out).

%% @fun 通知充值成功后的数据
notice_charge_data(PlayerId, Id, Count) ->
    Out = proto:encode(#m_charge_notice_charge_data_toc{item_id = Id, count = Count}),
    mod_socket:send(PlayerId, Out).
%% @fun 通知充值成功后的数据
notice_charge_data(PlayerId, Result, Id, Count) ->
    Out = proto:encode(#m_charge_notice_charge_data_toc{result = Result, item_id = Id, count = Count}),
    mod_socket:send(PlayerId, Out).

%% @fun api获得qq平台充值商店列表
api_get_charge_shop_data(PlayerId) ->
    List = mod_charge:get_charge_shop_data_list(PlayerId),
%%    ?DEBUG("api_get_charge_shop_data: ~p", [List]),
    api_shop:pack_shop_data(List).

%% ================================================ 充值 ================================================
