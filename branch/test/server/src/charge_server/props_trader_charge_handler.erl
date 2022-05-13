%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 8月 2021 上午 11:22:53
%%%-------------------------------------------------------------------
-module(props_trader_charge_handler).
-author("Administrator").

%% API
-export([
    init/2,
    terminate/2
]).

-include("gen/table_enum.hrl").
-include("common.hrl").

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
                {1, 'OK'};
            {'EXIT', R} ->
                ?ERROR("EXIT: ~p ~n ", [R]),
                Result = charge_result(R),
                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R, result_msg(R)}),
                {Result, result_msg(R)};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {0, result_msg(R1)}
        end,
    ?DEBUG("ErrorCode: ~p", [ErrorCode]),
    Req2 =
        if
            Path == <<"/props_trader/notify">> ->
                ErrorList =
                    if
                        ErrorCode == 1 ->
                            [{'error_code:', 200}, {'error_msg:', Msg}];
                        true ->
                            [{'error_code:', 0}, {'error_msg:', util:to_binary(Msg)}]
                    end,
                web_http_util:output_json(Req, ErrorList);
            true ->
                if
                    ErrorCode =:= true ->
                        web_http_util:output_json(Req, Msg);
                    true ->
                        ErrorList = [{'error_code:', ErrorCode}, {'error_msg:', Msg}],
                        web_http_util:output_error_code(Req, ErrorList)
                end
        end,
    Req2.
terminate(_Reason, _Req) ->
    ok.
%% @doc     接收szfu的异步回调
path_request(<<"/props_trader/notify">>, <<"POST">>, _Ip, Req) ->
    ?INFO("接收props_trader的异步回调"),
    {ParamInfoList, _ParamStr} = get_req_param_str(Req),
    ?INFO("props_trader异步回调ParamList: ~p", [ParamInfoList]),
    %% 解析请求参数
    %% 验签
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = util:to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    ?DEBUG("Base64Data: ~p", [Base64Data]),
    ?DEBUG("StringSign: ~p", [StringSign]),
    Data = cow_base64url:decode(Base64Data),
    ?DEBUG("Data: ~p", [Data]),
    handle_update_version:chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?INFO("Params: ~p", [{is_list(Params), is_map(Params)}]),               %% 回傳訊息
    Status = util:to_int(proplists:get_value(<<"status">>, Params)),
    OrderId = util:to_list(proplists:get_value(<<"order_no">>, Params)),
    CustomerName = util:to_list(proplists:get_value(<<"customer_name">>, Params)),
    TxOrderId = util:to_list(proplists:get_value(<<"props_trader_order_no">>, Params)),
    case Status of
        1 ->
            props_trader:confirm(OrderId, CustomerName, TxOrderId);
        _ ->
            ?ERROR("异步回调显示,订单充值失败: ~p", [{OrderId, TxOrderId, Status}]),
            props_trader:refuse(OrderId, CustomerName, TxOrderId)
    end;
path_request(Path, Month, Ip, _Req) ->
    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
    not_path.

%% @fun 返回内容转换
charge_result(Result) ->
    case Result of
        sid ->
%%            ?DEBUG("无效服务器编号"),
            -100;
        null_server ->
%%            ?DEBUG("服务器不存在"),
            -100;
        null_player_id ->
%%            ?DEBUG("无效玩家账号"),
            -101;
        error_order_id ->
%%            ?DEBUG("订单号已存在"),
            -102;
        orderSerial ->
%%            ?DEBUG("无效订单类型"),
            -103;
        old_time ->
%%            ?DEBUG("无效时间戳"),
            -104;
        money ->
%%            ?DEBUG("充值金额错误"),
            -105;
        money_ingot ->
%%            ?DEBUG("充值金额大于游戏币"),
            -106;
        gold ->
%%            ?DEBUG("游戏币数量错误"),
            -106;
        error_md5 ->
%%            ?DEBUG("校验码错误"),
            -107;
        not_ip ->
%%            ?DEBUG("ip 不合法"),
            -109;
        _ ->
%%            ?DEBUG("其他错误: ~p ", [Result]),
            -108
    end.
%% @fun 返回内容转换msg
result_msg(Result) ->
    case Result of
        ok ->
            "success";
        not_exists ->
            "player not exists";
        error_sha ->
            "order not exists";
        none ->
            "order not exists！";
        already_have ->
            "order is existsed";
        sid ->
            "invalid server";
        null_server ->
            "server not exists";
        null_player_id ->
            "invalid player";
        error_order_id ->
            "order no is exists";
        orderSerial ->
            "invalid type";
        old_time ->
            "invalid time";
        money ->
            "invalid money";
        money_ingot ->
            "invalid money!";
        gold ->
            "invalid money!!";
        error_md5 ->
            "invalid signature";
        not_ip ->
            "invalid ip";
        _ ->
            ?DEBUG("result_msg errror: ~p~n", [Result]),
            "errors"
    end.

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).

