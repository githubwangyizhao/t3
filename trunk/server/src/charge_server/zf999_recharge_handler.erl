%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 2月 2021 上午 10:53:27
%%%-------------------------------------------------------------------
-module(zf999_recharge_handler).
-author("Administrator").

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
                {0, result_msg(ok)};
            {'EXIT', R} ->
                ?ERROR("EXIT: ~p ~n ", [R]),
                Result = charge_result(R),
%%                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R, result_msg(R)}),
                {Result, result_msg(R)};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
%%                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {1, result_msg(R1)}
        end,
    Req2 =
        if
            Path == <<"/zf999/notify">> ->
                ResultText =
                    if
                        ErrorCode == 0 ->
                            "SUCCESS";
                        true ->
                            "FAIL"
                    end,
                web_http_util:output_text(Req, ResultText);
            true ->
                if
                    ErrorCode =:= true ->
                        web_http_util:output_json(Req, Msg);
                    true ->
                        ErrorList = [{'errcode:', ErrorCode}, {'errmsg:', Msg}],
                        web_http_util:output_error_code(Req, ErrorList)
                end
        end,
    Req2.
terminate(_Reason, _Req) ->
    ok.
%% @doc     接收zf999的异步回调
path_request(<<"/zf999/notify">>, <<"POST">>, _Ip, Req) ->
    ?INFO("接收zf999的异步回调"),
    {ParamList, _ParamStr} = get_req_param_str(Req),
    ?INFO("ParamList: ~p", [ParamList]),
    %% 解析请求参数
    %% 验签
    %% 根据返回结果中的trade_state调用对应方法：
    %% trade_state: NOTPAY -> zf999:failure(OrderId, Customer)
    %% trade_state: SUCCESS -> zf999:confirm(OrderId, Customer)
    %% trade_state: FAILURE -> zf999:refuse(OrderId, Customer)
    %% 最后根据上述三个方法的返回结果来输出结果
    %% ok时输出success，failure时输出failure（三方会在60s内分6次发起异步回调）
%%    Timestamp = util:to_list(util_list:opt(<<"timestamp">>, ParamList)),
    TradeState = util:to_list(util_list:opt(<<"trade_state">>, ParamList)),
    OrderId = util:to_list(util_list:opt(<<"orderno">>, ParamList)),
    Customer = util:to_list(util_list:opt(<<"customer">>, ParamList)),
%%    MchId = util:to_list(util_list:opt(<<"mchid">>, ParamList)),
%%    Amount = util:to_list(util_list:opt(<<"amount">>, ParamList)),
    Sign = util:to_list(util_list:opt(<<"sign">>, ParamList)),

%%    TxOrderNo = util:to_list(util_list:opt(<<"tx_orderno">>, ParamList)),

%%    List = lists:sort([
%%        {"mchid", ?ZF999_MCHID},
%%        {"timestamp", Timestamp},
%%        {"amount", Amount},
%%        {"orderno", OrderId},
%%        {"notifyurl", ?PAY_NOTIFY_URL},
%%        {"customername", Customer},
%%        {"customermobile", "123"},
%%        {"order_intro", "order_intro"},
%%        {TradeState}
%%    ]),
%%
%%    ?DEBUG("List : ~p",[List]),
%%    StringSign = util_list:change_list_url(ParamList),
    StringSign =
        lists:foldl(
            fun(Param, Tmp) ->
                {Key0, Value0} = Param,
                Key = util:to_list(Key0),
                Value = util:to_list(Value0),
                if
                    Key =:= "sign" ->
                        Tmp;
                    Value =/= "" ->
                        Tmp ++ (?IF(Tmp =/= "", "&", "")) ++ Key ++ "=" ++ Value;
                    true ->
                        Tmp
                end
            end,
            "", lists:sort(ParamList)
        ),
    ?INFO("StringSign: ~p", [StringSign]),
    ?INFO("StringSign: ~p", [StringSign ++ "&key=" ++ ?ZF999_API_KEY]),
    AssertSign = string:to_upper(encrypt:md5(lists:concat([StringSign, "&key=", ?ZF999_API_KEY]))),
    ?INFO("StringSign: ~p ~p ~p", [AssertSign, Sign, Sign =:= AssertSign]),
    ?ASSERT(Sign =:= AssertSign,sign_error),

    case TradeState of
        "NOTPAY" ->
            zf999:failure(OrderId, Customer);
        "SUCCESS" ->
            zf999:confirm(OrderId, Customer);
        "FAILURE" ->
            zf999:refuse(OrderId, Customer)
    end;
%% @doc     测试用，模拟zf999的支付接口
path_request(<<"/zf999/pay">>, <<"POST">>, _Ip, Req) ->
    ?INFO("测试用，模拟zf999的支付接口"),
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("ParamStr: ~p", [ParamStr]),
    MchId = util:to_list(get_list_value(<<"mchid">>, ParamList)),
%%    Timestamp = util:to_list(get_list_value(<<"timestamp">>, ParamList)),
    Amount = util:to_list(get_list_value(<<"amount">>, ParamList)),
    OrderNo = util:to_list(get_list_value(<<"orderno">>, ParamList)),
    NotifyUrl = util:to_list(get_list_value(<<"notifyurl">>, ParamList)),
%%    CallbackUrl = util:to_list(get_list_value(<<"callbackurl">>, ParamList)),
    Customer = util:to_list(get_list_value(<<"customername">>, ParamList)),
%%    CustomerMobile = util:to_list(get_list_value(<<"customermobile">>, ParamList)),
%%    OrderIntro = util:to_list(get_list_value(<<"order_intro">>, ParamList)),

%%    Timestamp = util_time:timestamp(),
%%    {Date, Time} = util_time:timestamp_to_datetime(Timestamp),
    [
        {'code', 1},
        {'msg', util_string:to_utf8("请求成功")},
        {'data', [
            {"mchid", util_string:to_utf8(MchId)},
            {"amount", util_string:to_utf8(Amount)},
            {"orderno", util_string:to_utf8(OrderNo)},
            {"tx_orderno", util_string:to_utf8("tx_orderno")},
%%            {"create_time", util_string:to_utf8(Date ++ Time)},
%%            {"timestamp", util_string:to_utf8(integer_to_list(Timestamp))},
            {"notifyurl", util_string:to_utf8(NotifyUrl)},
%%            {"callbackurl", util_string:to_utf8(CallbackUrl)},
            {"trade_state", util_string:to_utf8("NOTPAY")},
            {"pay_type", util_string:to_utf8("1")},
            {"customer", util_string:to_utf8(Customer)},
            {"pay_info", util_string:to_utf8("pay_info")}
        ]}
    ];
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

