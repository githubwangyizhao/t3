%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2019, GAME BOY
%%%%% @doc    华为平台充值
%%%%% Created : 21. 二月 2019 10:21
%%%%%-------------------------------------------------------------------
-module(huawei_change_handler).
%%-author("home").
%%
%%-export([
%%    init/2,
%%    terminate/2
%%]).
%%
%%-include("logger.hrl").
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
%%    {ErrorCode, _Error} =
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
%%    ErrorList = [{'result', ErrorCode}],
%%%%        if
%%%%            ErrorCode == ok ->
%%%%                Error;
%%%%            true ->
%%%%                [{'result', ErrorCode}, {'message', util:to_binary(util_string:to_utf8(result_msg(Error)))}]
%%%%        end,
%%    Req2 = web_http_util:output_error_code(Req, ErrorList),
%%    Req2.
%%terminate(_Reason, _Req) ->
%%    ok.
%%
%%%% @fun 地址请求
%%path_request(<<"/game_charge_huawei">>, <<"POST">>, Ip, Req) ->     % 华为平台返回游戏服充值
%%    {ParamList, ParamStr} = get_req_param_str(Req),
%%    ?INFO("华为平台返回游戏服充值:~s~n", [ParamStr]),
%%    mod_signature:check_param_list(lists:keydelete(<<"signType">>, 1,ParamList), ?CHANNEL_HUAWEI),
%%    PayStatus = util:to_int(get_list_value(<<"result">>, ParamList)),    % 充值状态
%%    if
%%        PayStatus == 0 ->
%%            GameOrderNoStr = util:to_list(get_list_value(<<"extReserved">>, ParamList)),         % 游戏服参数
%%            OrderId = util:to_list(get_list_value(<<"requestId">>, ParamList)),                  % 平台订单号
%%            Money = util:str_to_float(get_list_value(<<"amount">>, ParamList)),    % 人民币
%%            ?INFO("华为平台返回成功:~p~n", [{GameOrderNoStr, OrderId}]),
%%            mod_charge:web_game_charge(Ip, OrderId, GameOrderNoStr, Money, ?CHANNEL_HUAWEI);
%%        true ->
%%            ?INFO("华为平台返回无效:~p~n", [ParamStr]),
%%            exit(null_object)
%%    end;
%%path_request(Path, Month, Ip, _Req) ->
%%    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
%%    not_path.
%%
%%%% @fun 返回内容转换
%%charge_result(Result) ->
%%    case Result of
%%        error_sha ->
%%            1;
%%        already_have -> %文档要求 注：对于重复的订单，要求返回0；
%%            0;
%%        not_path ->
%%            96;
%%        {param_type_error, _} ->
%%            98;
%%        _ ->
%%            99
%%    end.
%%%%%% @fun 返回内容转换msg
%%%%result_msg(Result) ->
%%%%    case Result of
%%%%        ok ->
%%%%            "游戏支付成功";
%%%%        null_object ->
%%%%            "取消支付";
%%%%        times_limit ->
%%%%            "已充值过当前活动";
%%%%        not_exists ->
%%%%            "用户不存在";
%%%%        error_sha ->
%%%%            "校验码错误";
%%%%        none ->
%%%%            "订单不存在";
%%%%        already_have ->
%%%%            "订单重复";
%%%%        sid ->
%%%%            "无效服务器编号";
%%%%        null_server ->
%%%%            "服务器不存在";
%%%%        null_player_id ->
%%%%            "无效玩家账号";
%%%%        error_order_id ->
%%%%            "订单号已存在";
%%%%        orderSerial ->
%%%%            "无效订单类型";
%%%%        old_time ->
%%%%            "无效时间戳";
%%%%        money ->
%%%%            "充值金额错误";
%%%%        money_ingot ->
%%%%            "充值金额大于游戏币";
%%%%        gold ->
%%%%            "游戏币数量错误";
%%%%        error_md5 ->
%%%%            "校验码错误";
%%%%        not_ip ->
%%%%            "ip 不合法";
%%%%        not_sign ->
%%%%            "没有sign字段";
%%%%        {param_type_error, _} ->
%%%%            "参数错误";
%%%%        not_path ->
%%%%            "错误的url";
%%%%        _ ->
%%%%            ?ERROR("result_msg errror: ~p~n", [Result]),
%%%%            "其他错误"
%%%%    end.
%%
%%%% @fun 参数解析
%%get_list_value(Key, ParamList) ->
%%    charge_handler:get_list_value(Key, ParamList).
%%
%%%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
%%get_req_param_str(Req) ->
%%    charge_handler:get_req_param_str(Req).
