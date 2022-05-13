%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2019, GAME BOY
%%% @doc        平台accessToken
%%% Created : 18. 六月 2019 13:07
%%%-------------------------------------------------------------------
-module(handler_game_time).
-author("home").

-export([
    init/2,
    terminate/2
]).

-include("common.hrl").

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
    {ErrorCode, Msg} =
        case catch path_request(Path, Method, Ip, Req) of
            {ok, Result1} ->
                {0, Result1};
            {'EXIT', R} ->
                Result = charge_result(R),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(access_token_error, {Result, {ip, IP}, util:to_list(ParamStr), R}),
                {Result, R};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
                Result = charge_result(R1),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(access_token_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {Result, R1}
        end,
    ?INFO("Msg: ~p ~n ", [Msg]),
    ErrorList = [{'Code', ErrorCode}, {'Msg', util:to_binary(Msg)}],
    Req2 = web_http_util:output_error_code(Req, ErrorList),
    Req2.
terminate(_Reason, _Req) ->
    ok.

path_request(<<"/get_server_time">>, <<"GET">>, _Ip, _Req) ->        % 获得服务器时间
    ?ASSERT(?IS_DEBUG, not_debug),
    {ok, util_time:format_datetime()};
path_request(<<"/set_server_time">>, <<"POST">>, _Ip, Req) ->       % 设置服务器时间
    ?ASSERT(?IS_DEBUG, not_debug),
    {ParamList, _ParamStr} = get_req_param_str(Req),
    ?INFO("http改变服务器时间:~p", [ParamList]),
    Time = util:to_int(get_list_value("time", ParamList)),         % 平台参数
    util_time:update_offset_time(Time),
    ?INFO("设置服务器时间...~p ", [util_time:timestamp_to_datetime(Time)]),
    init:restart(),
    {ok, "ok"};
path_request(Path, Month, Ip, _Req) ->
    ?ERROR("path_request Path: ~p ;Month ~p; ip ~p ~n", [Path, Month, Ip]),
    not_path.

%% @fun 返回内容转换
charge_result(Result) ->
    case Result of
        sid ->
%%            ?DEBUG("无效服务器编号"),
            -100;
        null_platform_id ->
%%            ?DEBUG("平台不存在"),
            -101;
        error_sha ->
%%            ?DEBUG("检验码不一致"),
            -102;
        not_sign ->
%%            ?DEBUG("没有sign字段"),
            -103;
        not_path ->
%%            ?DEBUG("没找到url地址"),
            -104;
        error_md5 ->
%%            ?DEBUG("校验码错误"),
            -105;
        not_ip ->
%%            ?DEBUG("ip 不合法"),
            -109;
        _ ->
%%            ?DEBUG("其他错误: ~p ", [Result]),
            -108
    end.

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).

