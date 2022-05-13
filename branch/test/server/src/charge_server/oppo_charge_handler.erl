%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2019, GAME BOY
%%%%% @doc
%%%%% Created : 14. 一月 2019 15:51
%%%%%-------------------------------------------------------------------
-module(oppo_charge_handler).
%%-author("home").
%%
%%-export([
%%    init/2,
%%    terminate/2
%%]).
%%
%%-include("logger.hrl").
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
%%    {ErrorCode, Error} =
%%        case catch path_request(Path, Method, Ip, Req) of
%%            ok ->
%%                {0, ok};
%%            {'EXIT', R} ->
%%                Result = charge_result(R),
%%                {_, ParamStr} = get_req_param_str(Req),
%%                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R}),
%%                {Result, R};
%%            R1 ->
%%                ?ERROR("未知错误: ~p ~n ", [R1]),
%%                {_, ParamStr} = get_req_param_str(Req),
%%                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
%%                {-3, R1}
%%        end,
%%    ResultCode =
%%        if
%%            ErrorCode == 0 orelse ErrorCode == -102 ->
%%                'OK';
%%            true ->
%%                'FAIL'
%%        end,
%%%%    ErrorList = [{result, ResultCode}, {resultMsg, util:to_binary(util_string:to_utf8(result_msg(Error)))}],
%%%%    Req2 = web_http_util:output_error_code(Req, ErrorList),
%%    ErrorList = [{result, ResultCode}, {resultMsg, util_string:to_utf8(result_msg(Error))}],
%%    Req2 = web_http_util:output_text(Req, util_list:change_list_url(ErrorList)),
%%    Req2.
%%
%%terminate(_Reason, _Req) ->
%%    ok.
%%
%%%% @fun oppo平台地址请求
%%path_request(<<"/game_charge_oppo">>, <<"POST">>, Ip, Req) ->     % oppo平台返回游戏服充值
%%    {ParamInfoList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("oppo平台返回游戏服充值 ~p~n", [ParamStr]),
%%    mod_signature:check_param_list(lists:keydelete(<<"userId">>, 1,ParamInfoList)),
%%%%    PayStatus = util:to_int(get_list_value(pay_status, ParamList)),    % 充值状态
%%%%    if
%%%%        PayStatus == 1 ->
%%    Money = util:to_int(get_list_value(<<"price">>, ParamInfoList)) / 100,      % 人民币（分）
%%    OrderId = util:to_list(get_list_value(<<"partnerOrder">>, ParamInfoList)),           % 订单号
%%    GameOrderNoStr = util:to_list(get_list_value(<<"attach">>, ParamInfoList)),   % 游戏参数
%%%%    ?INFO("oppo平台返回成功 ~p~n", [{GameOrderNoStr, OrderId}]),
%%    mod_charge:web_game_charge(Ip, OrderId, GameOrderNoStr, Money);
%%%%        true ->
%%%%            ?INFO("oppo平台返回 无效 ~p~n", [ParamStr]),
%%%%            exit(null_object)
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
%%            504;
%%        already_have ->
%%%%            ?DEBUG("订单号已存在"),
%%            -102;
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
%%            502;
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
%%            "成功";
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
%%%% @fun 参数解析
%%get_list_value(Key, ParamList) ->
%%    charge_handler:get_list_value(Key, ParamList).
%%
%%%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
%%get_req_param_str(Req) ->
%%    charge_handler:get_req_param_str(Req).
