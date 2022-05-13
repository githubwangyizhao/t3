%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2018, GAME BOY
%%%%% @doc        百度
%%%%% Created : 4. 十二月 2018 9:54
%%%%%-------------------------------------------------------------------
-module(baidu_charge_handler).
%%-author("home").
%%
%%-export([
%%    init/2,
%%    terminate/2
%%]).
%%
%%-include("gen/db.hrl").
%%-include("logger.hrl").
%%-include("platform.hrl").
%%-include("gen/table_enum.hrl").
%%
%%init(Req, Opts) ->
%%    NewReq = handle_request(Req, Opts),
%%    {ok, NewReq, Opts}.
%%
%%%% @fun 根据请求 切换不同的操作
%%handle_request(Req, Opts) ->
%%    Method = cowboy_req:method(Req),
%%    case Method of
%%        <<"GET">> ->
%%            handle_body(Req, Opts);
%%        <<"POST">> ->
%%            handle_body(Req, Opts);
%%        _ ->
%%            ?ERROR("错误handle_request Method: ~p ~n", [Method])
%%    end.
%%
%%handle_body(Req, _Opts) ->
%%    Method = cowboy_req:method(Req),
%%    {IP, _} = cowboy_req:peer(Req),
%%    Ip = inet_parse:ntoa(IP),
%%    Path = cowboy_req:path(Req),
%%    {_, ParamStr} = get_req_param_str(Req),
%%    {ErrorCode, Msg, Data} =
%%        case catch path_request(Path, Method, Ip, Req) of
%%            ok ->
%%                logger2:write(game_charge_info, util:to_list(ParamStr)),
%%                {0, success, 2};
%%            {ok, L} ->
%%                logger2:write(game_charge_info, util:to_list(ParamStr)),
%%                {L, success, 2};
%%            {'EXIT', R} ->
%%                ?ERROR("EXIT: ~p ~n ", [R]),
%%                Result = charge_result(R),
%%                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R, result_msg(R)}),
%%                {Result, R, 1};
%%            R1 ->
%%                ?ERROR("未知错误: ~p ~n ", [R1]),
%%                Result = charge_result(R1),
%%                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
%%                {Result, result_msg(R1), 1}
%%        end,
%%    ErrorList =
%%        case is_list(ErrorCode) of
%%            true ->
%%                ErrorCode;
%%            _ ->
%%                [{errno, ErrorCode}, {msg, Msg}, {data, [{isConsumed, Data}]}]
%%        end,
%%    Req2 = web_http_util:output_error_code(Req, ErrorList),
%%    Req2.
%%terminate(_Reason, _Req) ->
%%    ok.
%%%% @doc     百度平台充值
%%path_request(<<"/charge_baidu">>, <<"POST">>, Ip, Req) ->
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("百度平台充值:~p ~n", [ParamStr]),
%%    Pf = ?PLATFORM_BAIDU,
%%    mod_signature:check_param_list(ParamList, Pf),
%%    PayStatus = util:to_int(get_list_value(<<"status">>, ParamList)),    % 充值状态
%%    OrderId = util:to_list(get_list_value(<<"tpOrderId">>, ParamList)),    % 订单号
%%    if
%%        PayStatus == 2 ->
%%            UserId = util:to_list(get_list_value(<<"userId">>, ParamList)),                % 账号
%%            Money = util:to_int(get_list_value(<<"totalMoney">>, ParamList)) / 100,          % 人民币
%%            GameOrderNoStr = util:to_list(get_list_value(<<"returnData">>, ParamList)),   % 游戏参数
%%            ?INFO("百度平台返回-成功~p~n", [{GameOrderNoStr, OrderId}]),
%%            mod_charge_server:server_charge(UserId, OrderId, Money, GameOrderNoStr, Ip, util_time:timestamp());
%%        true ->
%%            ?INFO("百度平台返回-无效 ~p~n", [{OrderId, PayStatus}]),
%%            exit(null_object)
%%    end;
%%%% @doc     百度平台退款审核
%%path_request(<<"/charge_baidu_refund_order_audit">>, <<"POST">>, _Ip, Req) ->
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("百度退款审核:~p ~n", [ParamStr]),
%%    Pf = ?PLATFORM_BAIDU,
%%    mod_signature:check_param_list(ParamList, Pf),
%%    OrderId = util:to_list(get_list_value(<<"tpOrderId">>, ParamList)),    % 订单号
%%    RefundMoney = util:to_int(get_list_value(<<"applyRefundMoney">>, ParamList)) / 100,    % 退款金额，单位：分
%%    AuditStatus = % auditStatus 枚举值1:审核通过可退款; 2:审核不通过,不能退款; 3:审核结果不确定，待重试
%%    case mod_charge_server:get_charge_info_record(OrderId) of
%%        #db_charge_info_record{money = Money} ->
%%            if
%%                Money >= RefundMoney -> 1;
%%                true ->
%%                    ?ERROR("百度退款审核金额不符:~p  p~n", [OrderId, {Money, RefundMoney}]),
%%                    2
%%            end;
%%        _ ->
%%            ?ERROR("百度退款审核未找到订单号:~p~n", [OrderId]),
%%            2
%%    end,
%%    ResultList = [{errno, 0}, {msg, success}, {data, [{auditStatus, AuditStatus}, {calculateRes, {refundPayMoney, RefundMoney}}]}],
%%    {ok, ResultList};
%%%% @doc     百度平台充值退款通知
%%path_request(<<"/charge_baidu_refund_order_notice">>, <<"POST">>, _Ip, Req) ->
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("百度退款通知:~p ~n", [ParamStr]),
%%    Pf = ?PLATFORM_BAIDU,
%%    mod_signature:check_param_list(ParamList, Pf),
%%    PayStatus = util:to_int(get_list_value(<<"refundStatus">>, ParamList)),    % 充值状态
%%    if
%%        PayStatus == 1 ->
%%            ?INFO("百度退款通知-成功~p~n", [ParamList]);
%%        true ->
%%            ?INFO("百度退款通知-失败~p~n", [ParamList])
%%    end,
%%    ResultList = [{errno, 0}, {msg, success}, {data, {}}],
%%    {ok, ResultList};
%%
%%%%%% @doc     百度平台充值
%%%%path_request(<<"/charge_baidu">>, <<"POST">>, Ip, Req) ->
%%%%    {_ParamList, ParamStr} = get_req_param_str(Req),
%%%%    ?INFO("百度平台充测试服跳转:~p ~n", [ParamStr]),
%%%%    Type = "application/x-www-form-urlencoded",
%%%%    HTTPOptions = [{timeout, 6000}],
%%%%    Options = [],
%%%%    Url = "http://charge-bd-rxxx.szfyhd.com:9999/charge_baidu",
%%%%    Method = post,
%%%%    case httpc:request(Method, {Url, [], Type, ParamStr}, HTTPOptions, Options) of
%%%%        {error, Reason} ->
%%%%            ?ERROR("百度平台充测试服跳转{error, Reason} ~p~n ", [Reason]),
%%%%            exit(undefined);
%%%%        {ok, {Re1, _HeadList, HtmlResultJson}} ->
%%%%            {_, HtmlResult, _} = Re1,
%%%%            if
%%%%                HtmlResult == 200 ->
%%%%                    NewHtmlResultJson = jsone:decode(util:to_binary(HtmlResultJson), [{object_format, proplist}]),
%%%%                    ListJson = [{util:to_atom(Code), Value} || {Code, Value} <- NewHtmlResultJson],
%%%%                    ?ERROR("百度平台充测试服跳转 ~p~n ", [NewHtmlResultJson]),
%%%%                    {ok, ListJson};
%%%%                true ->
%%%%                    ?ERROR("{ok, Result} ~p~n ", [{HtmlResult, HtmlResultJson}]),
%%%%                    exit(undefined)
%%%%            end;
%%%%        R ->
%%%%            ?ERROR("百度平台充测试服跳转other ~p~n ", [R]),
%%%%            exit(undefined)
%%%%    end;
%%path_request(Path, Month, Ip, _Req) ->
%%    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
%%    not_path.
%%
%%%% @fun 返回内容转换
%%charge_result(Result) ->
%%    case Result of
%%        sid ->
%%%%            ?DEBUG("无效服务器编号"),
%%            -100;
%%        null_server ->
%%%%            ?DEBUG("服务器不存在"),
%%            -100;
%%        null_player_id ->
%%%%            ?DEBUG("无效玩家账号"),
%%            -101;
%%        error_order_id ->
%%%%            ?DEBUG("订单号已存在"),
%%            -102;
%%        orderSerial ->
%%%%            ?DEBUG("无效订单类型"),
%%            -103;
%%        old_time ->
%%%%            ?DEBUG("无效时间戳"),
%%            -104;
%%        money ->
%%%%            ?DEBUG("充值金额错误"),
%%            -105;
%%        money_ingot ->
%%%%            ?DEBUG("充值金额大于游戏币"),
%%            -106;
%%        gold ->
%%%%            ?DEBUG("游戏币数量错误"),
%%            -106;
%%        error_md5 ->
%%%%            ?DEBUG("校验码错误"),
%%            -107;
%%        not_ip ->
%%%%            ?DEBUG("ip 不合法"),
%%            -109;
%%        _ ->
%%%%            ?DEBUG("其他错误: ~p ", [Result]),
%%            -108
%%    end.
%%%% @fun 返回内容转换msg
%%result_msg(Result) ->
%%    case Result of
%%        ok ->
%%            "success";
%%        not_exists ->
%%            "用户不存在";
%%        error_sha ->
%%            "订单不存在";
%%        none ->
%%            "订单不存在";
%%        already_have ->
%%            "订单重复";
%%        sid ->
%%            "无效服务器编号";
%%        null_server ->
%%            "服务器不存在";
%%        null_player_id ->
%%            "无效玩家账号";
%%        error_order_id ->
%%            "订单号已存在";
%%        orderSerial ->
%%            "无效订单类型";
%%        old_time ->
%%            "无效时间戳";
%%        money ->
%%            "充值金额错误";
%%        money_ingot ->
%%            "充值金额大于游戏币";
%%        gold ->
%%            "游戏币数量错误";
%%        error_md5 ->
%%            "校验码错误";
%%        not_ip ->
%%            "ip 不合法";
%%        _ ->
%%            ?DEBUG("result_msg errror: ~p~n", [Result]),
%%            "其他错误"
%%    end.
%%
%%%% @fun 参数解析
%%get_list_value(Key, ParamList) ->
%%    charge_handler:get_list_value(Key, ParamList).
%%
%%%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
%%get_req_param_str(Req) ->
%%    charge_handler:get_req_param_str(Req).
%%
