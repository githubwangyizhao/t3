%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 4月 2021 下午 03:04:03
%%%-------------------------------------------------------------------
-module(customer_charge_handle).
-author("Administrator").

%% API
-export([
    init/2,
    terminate/2
]).

-include("gen/table_enum.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").

init(Req, Opts) ->
    ?DEBUG("Req : ~p ", [Req]),
    ?DEBUG("Opts : ~p ", [Opts]),
    NewReq = handle_request(Req, Opts),
    {ok, NewReq, Opts}.

%% @fun 根据请求 切换不同的操作
handle_request(Req, Opts) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"GET">> ->
            handle_body(Req, Opts);
        <<"POST">> ->
            handle_body(Req, Opts);
        _ ->
            ?ERROR("错误handle_request Method: ~p ~n", [Method])
    end.

handle_body(Req, _Opts) ->
    Method = cowboy_req:method(Req),
    {IP, _} = cowboy_req:peer(Req),
    Ip = inet_parse:ntoa(IP),
    Path = cowboy_req:path(Req),
    {_, ParamStr} = get_req_param_str(Req),
    {ErrorCode, Msg} =
        case catch path_request(Path, Method, Ip, Req) of
            R when is_list(R) ->
                {true, R};
            ok ->
                logger2:write(game_charge_info, util:to_list(ParamStr)),
                {0, result_msg(ok)};
            {'EXIT', R} ->
                ?ERROR("EXIT: ~p ~n ", [R]),
                Result = charge_result(R),
                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R, result_msg(R)}),
                {Result, result_msg(R)};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {1, result_msg(R1)}
        end,
    ?DEBUG("ErrCode: ~p ~p", [ErrorCode, Msg]),
    Req2 =
        if
            ErrorCode =:= true ->
                ?DEBUG("Msg: ~p", [Msg]),
                web_http_util:output_json(Req, [{'error_code', 0}, {'error_msg', Msg}]);
            true ->
%%                ErrorList = [{'error_code:', ErrorCode}, {'error_msg:', util:to_binary(util_string:to_utf8("订单创建失败"))}],
%%                web_http_util:output_error_code(Req, ErrorList)
                web_http_util:output_json(Req, [{'error_code', ErrorCode}, {'error_msg', util:to_binary(util_string:to_utf8("订单创建失败"))}])
%%                web_http_util:output_json(Req, ErrorList)
        end,
    Req2.

terminate(_Reason, _Req) ->
    ok.

chk_sign(Data, StringSign) ->
    DataMd5 = encrypt:md5(util:to_list(Data) ++ ?GM_SALT),
    ?DEBUG("~p~n", [{StringSign, DataMd5}]),
    ?ASSERT(StringSign == DataMd5, sign_error),
    ?DEBUG("StringSign: ~p", [StringSign]).

path_request(<<"/customer/items">>, <<"POST">>, _Ip, Req) ->
    ?INFO("接收来自后台加密的平台数据，返回其商品信息与第三方支付平台"),
    {ParamList, _ParamStr} = get_req_param_str(Req),
    ?INFO("ParamList: ~p", [ParamList]),
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?INFO("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    PlatformId = util:to_list(proplists:get_value(<<"platform">>, Params)),
    ?DEBUG("Params: ~p", [Params]),
    Items =
        lists:filtermap(
            fun(Ele) ->
                #t_recharge{
                    id = ItemId,
                    type = Type,
                    remove_pf_list = RemovePfList,
                    recharge_type = RechargeType,
                    is_show = IsShow
                } = t_recharge:get(Ele),
                Judgment = ?IF(RechargeType =:= 0 andalso Type =:= 0 andalso IsShow =:= 1 andalso (length(RemovePfList) =< 0 orelse not lists:member(PlatformId, RemovePfList)), ?TRUE, ?FALSE),
                if
                    Judgment =:= ?TRUE ->
                        {true, integer_to_list(ItemId)};
                    true ->
                        false
                end
            end,
            t_recharge:get_keys()
        ),
    ?DEBUG("Items: ~p", [Items]),
    [{'items', binary_to_list(list_to_binary(lists:join(",", Items)))}];
path_request(<<"/customer/decodePlayerId">>, <<"POST">>, _Ip, Req) ->
    ?INFO("接收来自后台加密玩家编号数据，返回其原始玩家编号"),
    {ParamList, _ParamStr} = get_req_param_str(Req),
    ?INFO("ParamList: ~p", [ParamList]),
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?INFO("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    DecodePlayerId = util:to_list(proplists:get_value(<<"decodePlayerId">>, Params)),
    ?INFO("DecodePlayerId: ~p", [DecodePlayerId]),
    PlayerId = mod_unique_invitation_code:decode(DecodePlayerId),
    ?INFO("PlayerId: ~p", [PlayerId]),
    util:to_list(PlayerId);
%% @doc     接收来自后台的客服为玩家充值数据
path_request(<<"/customer/charge">>, <<"POST">>, _Ip, Req) ->
    ?INFO("接收来自后台的充值请求，并根据参数生成对应的支付链接，最后返回给后台"),
    {ParamList, _ParamStr} = get_req_param_str(Req),
    ?INFO("ParamList: ~p", [ParamList]),
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?INFO("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?DEBUG("params: ~p", [Params]),
    PlatformId = util:to_list(proplists:get_value(<<"platformId">>, Params)),
    PlayerId = util:to_int(proplists:get_value(<<"playerId">>, Params)),
    ServerId = util:to_list(proplists:get_value(<<"serverId">>, Params)),
    PlatformItemId = util:to_int(proplists:get_value(<<"itemId">>, Params)),
    case catch mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, charge_platform_item, [PlayerId, PlatformItemId, 1, _Ip, ?UNDEFINED]) of
        {'EXIT', R} ->
            ?ERROR("call_game_server failure: ~p", [R]);
        {ok, PayInfo} ->
            ?DEBUG("PayInfo: ~p", [PayInfo]),
            PayInfo;
        ERROR ->
            ?ERROR("pay platform failure: ~p", [ERROR])
    end.
%%path_request(Path, Month, Ip, _Req) ->
%%    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
%%    not_path.

%% @fun 返回内容转换
charge_result(Result) ->
    case Result of
        sid ->
            ?DEBUG("无效服务器编号"),
            -100;
        null_server ->
            ?DEBUG("服务器不存在"),
            -100;
        null_player_id ->
            ?DEBUG("无效玩家账号"),
            -101;
        error_order_id ->
            ?DEBUG("订单号已存在"),
            -102;
        orderSerial ->
            ?DEBUG("无效订单类型"),
            -103;
        old_time ->
            ?DEBUG("无效时间戳"),
            -104;
        money ->
            ?DEBUG("充值金额错误"),
            -105;
        money_ingot ->
            ?DEBUG("充值金额大于游戏币"),
            -106;
        gold ->
            ?DEBUG("游戏币数量错误"),
            -106;
        error_md5 ->
            ?DEBUG("校验码错误"),
            -107;
        not_ip ->
            ?DEBUG("ip 不合法"),
            -109;
        _ ->
            ?DEBUG("其他错误: ~p ", [Result]),
            -108
    end.
%% @fun 返回内容转换msg
result_msg(Result) ->
    case Result of
        ok ->
            "游戏支付成功";
        not_exists ->
            "用户不存在";
        error_sha ->
            "订单不存在";
        none ->
            "订单不存在";
        already_have ->
            "订单重复";
        sid ->
            "无效服务器编号";
        null_server ->
            "服务器不存在";
        null_player_id ->
            "无效玩家账号";
        error_order_id ->
            "订单号已存在";
        orderSerial ->
            "无效订单类型";
        old_time ->
            "无效时间戳";
        money ->
            "充值金额错误";
        money_ingot ->
            "充值金额大于游戏币";
        gold ->
            "游戏币数量错误";
        error_md5 ->
            "校验码错误";
        not_ip ->
            "ip 不合法";
        _ ->
            ?DEBUG("result_msg errror: ~p~n", [Result]),
            "其他错误"
    end.

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).


