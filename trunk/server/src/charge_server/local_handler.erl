%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 10. 八月 2018 14:26
%%%-------------------------------------------------------------------
-module(local_handler).
-author("home").


-export([
    init/2,
    terminate/2
]).

-include("logger.hrl").

init(Req, Opts) ->
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
    {ErrorCode, Error} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                {0, ok};
            {ok, MsgL} ->
                {ok, MsgL};
            {'EXIT', R} ->
                Result = charge_result(R),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R}),
                {Result, R};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {-3, R1}
        end,
    ErrorList =
        if
            ErrorCode == ok ->
                Error;
            true ->
                [{'ret', ErrorCode}, {'msg', util:to_binary(util_string:to_utf8(result_msg(Error)))}]
        end,
    Req2 = web_http_util:output_error_code(Req, ErrorList),
    Req2.
terminate(_Reason, _Req) ->
    ok.

%% @fun 地址请求
path_request(<<"/send_gamebar_msg">>, _, _Ip, Req) ->     % 平台条件上报
    {ParamInfoList, _ParamStr} = get_req_param_str(Req),
    ParamList = [{util:to_atom(Key), util:to_list(Value)} || {Key, Value} <- ParamInfoList],
    MsgType = get_list_value(msgtype, ParamList),   % 消息类型
    Content = get_list_value(content, ParamList),   % 消息内容
    ?INFO("send_gamebar_msg>>" ++ MsgType ++ ":"++ Content),
    ok;
path_request(Path, Month, Ip, _Req) ->
    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
    not_path.

%% @fun 返回内容转换
charge_result(Result) ->
    case Result of
        not_exists ->
            -1;
        already_have ->
            -2;
        error_sha ->
            -3;
        none ->
            -3;
        _ ->
            -3
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