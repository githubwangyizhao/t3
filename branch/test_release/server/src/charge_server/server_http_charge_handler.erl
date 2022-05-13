%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2019, GAME BOY
%%% @doc    充值服http充值
%%% Created : 28. 十月 2019 11:43
%%%-------------------------------------------------------------------
-module(server_http_charge_handler).
-author("home").

%% API
-export([
    init/2
]).

-export([
    get_ip/1,               % 获得ip
    get_req_param_data/1,   % 获得参数数据
    get_param_list_value/2  % 获得参数列表值
]).

-export([
    multipart_form_data_get_list/2
]).

-include("common.hrl").

init(Req, Opts) ->
    Path = cowboy_req:path(Req),
    case request_router(Path, Req, Opts) of
        noop -> noop;  % 不是充值或之前的充值
        ok ->   % 最新的充值
            {_, ParamStr} = get_req_param_data(Req),
            logger2:write(game_charge_info, {Path, ParamStr});
        {'EXIT', Exit} ->
            {_, ParamStr} = get_req_param_data(Req),
            ?ERROR("充值EXIT: ~p ~n ", [Exit]),
            logger2:write(game_charge_error, {Path, ParamStr, Exit});
        Result ->
            {_, ParamStr} = get_req_param_data(Req),
            ?ERROR("充值未知错误: ~p ~n ", [Result]),
            logger2:write(game_charge_other_error, {Path, ParamStr, Result})
    end,
    {ok, Req, Opts}.

%%request_router(<<"/charge_baidu">>, Req, Opts) -> baidu_charge_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_baidu_refund_order_audit">>, Req, Opts) -> baidu_charge_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_baidu_refund_order_notice">>, Req, Opts) -> baidu_charge_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_ylw">>, Req, Opts) -> ylw_charge_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_awy">>, Req, Opts) -> awy_charge_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_fk">>, Req, Opts) -> awy_charge_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_djs">>, Req, Opts) -> awy_charge_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_meizu">>, Req, Opts) -> meizu_charge_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_lanbao">>, Req, Opts) -> lanbao_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_qq_game">>, Req, Opts) -> qq_handler:init(Req, Opts), noop;
%%request_router(<<"/charge_gat">>, Req, Opts) -> gat_charge_handler:init(Req, Opts), noop;
request_router(<<"/appply/agentMoney">>, Req, Opts) -> douluo_gm_charge_handler:init(Req, Opts), noop;
request_router(<<"/appply/sponsorMoney">>, Req, Opts) -> douluo_gm_charge_handler:init(Req, Opts), noop;
request_router(<<"/change_white_ip">>, Req, Opts) -> charge_handler:init(Req, Opts), noop;
request_router(<<"/md5_key">>, Req, Opts) -> charge_handler_md5_key:init(Req, Opts), noop;
request_router(<<"/http_list">>, Req, Opts) -> charge_handler_md5_key:init(Req, Opts), noop;
%%request_router(<<"/charge_h5_6873">>, Req, _Opts) -> platform_6873:charge_path_request(Req);
%%request_router(<<"/charge_zj_h5">>, Req, _Opts) -> platform_zjh5:charge_path_request(Req);
%%request_router(<<"/charge_moy">>, Req, _Opts) -> platform_moy:charge_path_request(Req);
%% 模拟ZF999的支付接口
request_router(<<"/zf999/pay">>, Req, Opts) -> zf999_recharge_handler:init(Req, Opts), noop;
%% 模拟ZF999的异步回调
request_router(<<"/zf999_notify">>, Req, Opts) -> zf999_recharge_handler:init(Req, Opts), noop;
%% 接收ZF999的异步回调
request_router(<<"/zf999/notify">>, Req, Opts) -> zf999_recharge_handler:init(Req, Opts), noop;
%% 接收越南支付的异步回调
request_router(<<"/vietnam/notify">>, Req, Opts) -> vietnam_recharge_handler:init(Req, Opts), noop;
%% 谷歌支付客户端回调地址
request_router(<<"/google/pay_validation">>, Req, Opts) -> ios_android_charge_handle:init(Req, Opts), noop;
%% 苹果支付客户端回调地址
request_router(<<"/apple/pay_validation">>, Req, Opts) -> ios_android_charge_handle:init(Req, Opts), noop;
%% 通过后台为玩家发起充值
request_router(<<"/customer/charge">>, Req, Opts) -> customer_charge_handle:init(Req, Opts), noop;
%% 通过后台为解密玩家编号
request_router(<<"/customer/decodePlayerId">>, Req, Opts) -> customer_charge_handle:init(Req, Opts), noop;
%% 后台获取指定platformId的第三方支付信息
request_router(<<"/customer/items">>, Req, Opts) -> customer_charge_handle:init(Req, Opts), noop;
%% 接收szfu的异步回调
request_router(<<"/szfu/notify">>, Req, Opts) -> szfu_charge_handle:init(Req, Opts), noop;
%% 接收prop_trader的异步回调
request_router(<<"/props_trader/notify">>, Req, Opts) -> props_trader_charge_handler:init(Req, Opts), noop;
request_router(Path, Req, Opts) ->
    ?WARNING("path_request Path:~p ;ip: ~p ;opts:~p~n", [Path, get_ip(Req), Opts]),
    web_http_util:output_text(Req, "null_path"),
    noop.


%% @doc fun 获得ip
get_ip(Req) ->
    get_req_ip(Req).
get_req_ip(Req) ->
    {IP, _} = cowboy_req:peer(Req),
    inet_parse:ntoa(IP).

%% @doc fun 获得参数列表值
get_param_list_value(Key, ParamList) ->
    Value =
%%        case get_data_type() of
%%            "application/json" ->
    try
%%                    maps:get(Key, ParamList)
        util_list:opt(Key, ParamList)
    catch
        _ ->
%%                        util_list:opt(Key, ParamList)
            maps:get(Key, ParamList)
    end,
%%            _ ->
%%                util_list:opt(Key, ParamList)
%%        end,
    case Value of
        {'EXIT', Exit} ->
            ?ERROR("参数解析错误 : ~p~n", [Exit]),
            exit({param_type_error, Key});
        ?UNDEFINED ->
            exit({param_type_error, Key});
        _ ->
            Value
    end.
get_data_type() ->
    case get("data_type") of
        ?UNDEFINED ->
            "str";
        DataType ->
            DataType
    end.

%% @fun 获得参数数据  {[{<<"key">>, <<"value">>...], "key=value&..."}
% xml:[key,value]
get_req_param_data(Req) ->
    Path = cowboy_req:path(Req),
    case get(Path) of
        ?UNDEFINED ->
            Method = cowboy_req:method(Req),
            case Method of
                <<"GET">> ->
                    GetParamBin1 = cowboy_req:qs(Req),
                    Tuple = {cow_qs:parse_qs(GetParamBin1), util:to_list(GetParamBin1)},
                    put(Path, Tuple),
                    Tuple;
                <<"POST">> ->
                    {ok, ParamBodyBin, Req_1} = cowboy_req:read_body(Req),
                    Head0 = util:to_list(cowboy_req:header(<<"content-type">>, Req_1)),
                    [Head | OtherDataList] = string:tokens(Head0, ";"),
                    put("data_type", Head),
                    ?DEBUG("Head: ~p", [Head]),
                    ParamList =
                        try
                            case Head of
                                "application/x-www-form-urlencoded" ->
                                    cow_qs:parse_qs(ParamBodyBin);
                                "application/json" ->
                                    jsone:decode(ParamBodyBin, [{object_format, proplist}]);
                                "application/xml" ->
                                    xml:decode(ParamBodyBin);
                                "text/xml" ->
                                    xml:decode(ParamBodyBin);
                                "multipart/form-data" ->
                                    Boundary = get_boundary(OtherDataList),
                                    ?DEBUG("Boundary : ~p", [Boundary]),
                                    Data = multipart_form_data_get_list(ParamBodyBin, Boundary),
                                    ?DEBUG("Data : ~p", [Data]),
                                    Data;
                                _ ->
                                    ?ERROR("未处理数据格式path:~p ;Head:~p~n", [Path, Head]),
                                    exit(not_head_data)
                            end
                        catch
                            _: R ->
                                ?ERROR("获取参数~p错误error Head:~p ; param:~p~n", [Path, Head, {ParamBodyBin, R}]),
                                []
                        end,
                    ?INFO("Head: ~p~n", [ParamList]),
                    Tuple = {ParamList, util:to_list(ParamBodyBin)},
                    put(Path, Tuple),
                    Tuple;
                <<"PUT">> ->
                    {ok, ParamBodyBin, Req_1} = cowboy_req:read_body(Req),
                    Head0 = util:to_list(cowboy_req:header(<<"content-type">>, Req_1)),
                    Head = hd(string:tokens(Head0, ";")),
                    put("data_type", Head),
                    ParamList =
                        try
                            case Head of
                                "application/x-www-form-urlencoded" ->
                                    cow_qs:parse_qs(ParamBodyBin);
                                "application/json" ->
                                    jsone:decode(ParamBodyBin, [{object_format, proplist}]);
                                "application/xml" ->
                                    xml:decode(ParamBodyBin);
                                "text/xml" ->
                                    xml:decode(ParamBodyBin);
                                _ ->
                                    ?ERROR("未处理数据格式path:~p ;Head:~p~n", [Path, Head]),
                                    exit(not_head_data)
                            end
                        catch
                            _: R ->
                                ?ERROR("获取参数~p错误error Head:~p ; param:~p~n", [Path, Head, {ParamBodyBin, R}]),
                                []
                        end,
%%                    ?INFO("Head: ~p~n", [ParamList]),
                    Tuple = {ParamList, util:to_list(ParamBodyBin)},
                    put(Path, Tuple),
                    Tuple;
                _ ->
                    ?ERROR("错误handle_request Method: ~p ~n", [Method]),
                    exit(not_err_method)
            end;
        {ParamList, ParamStr} ->
            {ParamList, ParamStr}
    end.

get_boundary([]) ->
    exit(error_boundary);
get_boundary([Str | DataList]) ->
    [Key, Value] = string:tokens(Str, "="),
    if
        Key == " boundary" ->
            util:to_binary(Value);
        true ->
            get_boundary([DataList])
    end.

multipart_form_data_get_list(ParamBodyBin, Boundary) ->
    {_, List} = cow_multipart:parse_content_disposition(ParamBodyBin),
    {_, NewList} = lists:foldl(
        fun({Rest, Key}, {TmpKey, TmpList}) ->
            if
                TmpKey =:= null ->
                    {Key, TmpList};
                true ->
                    {done, Body, _} = cow_multipart:parse_body(Rest, Boundary),
                    {Key, [{util:to_list(TmpKey), util:to_list(Body) -- "\r\n\r\n"} | TmpList]}
            end
        end,
        {null, []}, List
    ),
    NewList.
