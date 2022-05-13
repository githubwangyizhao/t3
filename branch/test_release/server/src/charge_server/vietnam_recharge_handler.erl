%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         %% 越南充值回调
%%% @end
%%% Created : 07. 四月 2021 上午 11:17:06
%%%-------------------------------------------------------------------
-module(vietnam_recharge_handler).
-author("Administrator").

-include("gen/table_enum.hrl").
-include("common.hrl").

-export([
    init/2,
    terminate/2
]).

%%-export([
%%    test/0
%%]).

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

%%test() ->
%%    ParamList =
%%        [{<<"memberid">>,
%%            <<"210385326">>},
%%            {<<"orderid">>,
%%                <<"vie6pb7XSeD00AyTmr62">>},
%%            {<<"transaction_id">>,
%%                <<"20210417172811985755">>},
%%            {<<"amount">>,
%%                <<"46130.0000">>},
%%            {<<"datetime">>,
%%                <<"20210417173237">>},
%%            {<<"returncode">>, <<"00">>},
%%            {<<"sign">>,
%%                <<"B7977AA6946F22F89456CC09FA19C964">>},
%%            {<<"attach">>, <<>>}],
%%    StringSign =
%%        lists:foldl(
%%            fun(Param, Tmp) ->
%%                {Key0, Value0} = Param,
%%                Key = util:to_list(Key0),
%%                Value = util:to_list(Value0),
%%                IsSign = lists:member(Key, ["memberid", "orderid", "amount", "transaction_id", "datetime", "returncode"]),
%%                if
%%                    IsSign ->
%%%%                    Value =/= "" ->
%%                        Tmp ++ (?IF(Tmp =/= "", "&", "")) ++ Key ++ "=" ++ Value;
%%                    true ->
%%                        Tmp
%%                end
%%            end,
%%            "", lists:sort(ParamList)
%%        ),
%%    ?DEBUG("StringSign ： ~p", [StringSign]),
%%    string:to_upper(encrypt:md5(lists:concat([StringSign, "&key=", ?VIETNAM_API_KEY]))).

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
                {0, 'OK'};
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
            Path == <<"/viernam/notify">> ->
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
%% @doc     接收越南的异步回调
path_request(<<"/vietnam/notify">>, <<"POST">>, _Ip, Req) ->
    ?INFO("接收越南的异步回调"),
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
%%    MemberId = util:to_list(util_list:opt(<<"memberid">>, ParamList)),
    OrderId = util:to_list(util_list:opt(<<"orderid">>, ParamList)),
%%    Amount = util:to_list(util_list:opt(<<"amount">>, ParamList)),
%%    TransactionId = util:to_list(util_list:opt(<<"transaction_id">>, ParamList)),
%%    DateTime = util:to_list(util_list:opt(<<"datetime">>, ParamList)),
    ReturnCode = util:to_list(util_list:opt(<<"returncode">>, ParamList)),

    Attach = util:to_list(util_list:opt(<<"attach">>, ParamList)),
    ?INFO("越南支付商店附加数据 : ~p", [Attach]),
    Sign = util:to_list(util_list:opt(<<"sign">>, ParamList)),

    StringSign =
        lists:foldl(
            fun(Param, Tmp) ->
                {Key0, Value0} = Param,
                Key = util:to_list(Key0),
                Value = util:to_list(Value0),
                IsSign = lists:member(Key, ["memberid", "orderid", "amount", "transaction_id", "datetime", "returncode"]),
                if
                    IsSign ->
%%                    Value =/= "" ->
                        Tmp ++ (?IF(Tmp =/= "", "&", "")) ++ Key ++ "=" ++ Value;
                    true ->
                        Tmp
                end
            end,
            "", lists:sort(ParamList)
        ),
    AssertSign = string:to_upper(encrypt:md5(lists:concat([StringSign, "&key=", ?VIETNAM_API_KEY]))),
    ?INFO("StringSign: ~p ~p ~p", [AssertSign, Sign, Sign =:= AssertSign]),
    ?ASSERT(Sign =:= AssertSign, sign_error),

    case ReturnCode of
%%        "NOTPAY" ->
%%            vietnam:failure(OrderId);
        "00" ->
            vietnam:confirm(OrderId);
%%        "FAILURE" ->
%%            vietnam:refuse(OrderId);
        _ ->
            ?ERROR("越南充值回调失败 : ~p", [{ReturnCode, OrderId}])
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
