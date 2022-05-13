%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2019, GAME BOY
%%% @doc        平台accessToken
%%% Created : 18. 六月 2019 13:07
%%%-------------------------------------------------------------------
-module(access_token_handler).
-author("home").

-export([
    init/2,
    terminate/2
]).

-export([
    get_access_token/1,                 % 获得accessToken
    insert_access_token/1               % 插入新的token
]).


-include("common.hrl").
-include("gen/table_enum.hrl").

-define(GET_INTERVAL_TIME, 6900). % 上一次和这一次获取的间隔时间内s (理论2小时过期,操作提前5分钟过期)
-define(REQUEST_INTERVAL_TIME, 5400). % 上一次请求和这一次请求的间隔时间内s

%% @doc api 获得accessToken
get_access_token(Pf) ->
    PlatformId = mod_server_config:get_platform_id(),
    Url =
        if
            PlatformId == ?PLATFORM_LOCAL ->
                mod_server_config:get_game_web_url();
%%            Pf == ?PLATFORM_WX orelse Pf == ?PLATFORM_VM orelse Pf == ?PLATFORM_QQ ->
%%                "https://web-rxxx.szfyhd.com";
            true ->
                exit(not_url)
        end,
    WebUrl = Url ++ "/get_pf_access_token",
    ParamList = [
        {"pf", Pf},
        {"currTime", util_time:timestamp()}
    ],
    SignaturePlatformId = ?PLATFORM_LOCAL,
    SignStr = mod_signature:sign_str(ParamList, SignaturePlatformId),
    KeyAtom = mod_signature:get_signature(SignaturePlatformId),
    ParamStr = util_list:change_list_url([{KeyAtom, SignStr} | ParamList]),
    case util_http:post(WebUrl, form, ParamStr) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            Code = util:to_int(maps:get(<<"Code">>, Response)),
            ReturnMsg = maps:get(<<"Msg">>, Response),
            if
                Code == 0 ->
                    util:to_list(ReturnMsg);
                true ->
                    ?ERROR("获得accessToken==fail>>~p ~ts~n ", [Code, ReturnMsg]),
                    exit(not_token)
            end;
        ErrorReason ->
            ?ERROR("获得accessToken==error:~p", [{WebUrl, ErrorReason}]),
            exit(ErrorReason)
    end.

%% @doc fun 去平台拿accessToken内容处理
get_pf_access_token(Pf) ->
    CacheKey = {access_token_handler, Pf},
    case mod_cache:get(CacheKey) of
        null ->
            djs_data_srv:call({insert_access_token, {Pf, CacheKey}});
        OldToken ->
            ?INFO("旧accessToken~p：~p~n",[Pf, OldToken]),
            OldToken
    end.

%% @doc fun 插入新的token
insert_access_token({Pf, CacheKey}) ->
    Fun =
        fun() ->
            ResultTuple =
                case Pf of
%%                    ?PLATFORM_WX ->
%%                        ?TRY_CATCH2(weixin:get_access_token());
%%                    ?PLATFORM_VM ->
%%                        ?TRY_CATCH2(platform_tt:get_access_token());
%%                    ?PLATFORM_QQ ->
%%                        ?TRY_CATCH2(platform_qq_game:get_access_token());
                    _ ->
                        exit(null_platform_id)
                end,
            ?INFO("更新新的token:~p~n", [ResultTuple]),
            ResultTuple
        end,
    mod_cache:cache_data(CacheKey, Fun, ?GET_INTERVAL_TIME).

%%
%%    Ets = get_ets_platform_token_data(Pf),
%%    #ets_platform_token_data{
%%        token = OldToken,
%%        last_get_time = LastGetTime
%%    } = Ets,
%%    CurrTime = util_time:timestamp(),
%%    if
%%        CurrTime - ?GET_INTERVAL_TIME > LastGetTime ->
%%            ?INFO("更新更新平台token:~p  ~p~n", [{Pf, OldToken}, util_time:local_datetime()]),
%%            RequestTime = util_time:milli_timestamp(),
%%            {Result, NewToken} =
%%                case Pf of
%%                    ?PLATFORM_WX ->
%%                        ?TRY_CATCH2(weixin:get_access_token());
%%                    ?PLATFORM_VM ->
%%                        ?TRY_CATCH2(platform_tt:get_access_token());
%%                    ?PLATFORM_QQ ->
%%                        ?TRY_CATCH2(platform_qq_game:get_access_token());
%%                    _ ->
%%                        exit(null_platform_id)
%%                end,
%%            ?INFO("获得最新的平台token:~p  ~p~n", [{Pf, Result}, NewToken]),
%%            if
%%                Result == ok ->
%%                    case djs_data_srv:call({insert_access_token, {Pf, NewToken, CurrTime, RequestTime}}) of
%%                        ok ->
%%                            {Result, NewToken};
%%                        _ ->
%%                            {Result, OldToken}
%%                    end;
%%                true ->
%%                    {ok, OldToken}
%%            end;
%%        true ->         % 在获取时间范围内不重新请求
%%            ?INFO("获得平台旧token:~p  ~p~n", [Pf, OldToken]),
%%            {ok, OldToken}
%%    end.

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
            {ok, Token1} ->
                {0, Token1};
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
    ErrorList = [{'Code', ErrorCode}, {'Msg', util:to_binary(Msg)}],
    Req2 = web_http_util:output_error_code(Req, ErrorList),
    Req2.
terminate(_Reason, _Req) ->
    ok.

path_request(<<"/get_pf_access_token">>, <<"POST">>, _Ip, Req) ->     % 获得平台accessToken
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("http获得平台accessToken:~p", [ParamStr]),
    mod_signature:check_param_list(ParamList, ?PLATFORM_LOCAL),
    Pf = util:to_list(get_list_value(<<"pf">>, ParamList)),         % 平台参数
    get_pf_access_token(Pf);
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
%%%% @fun 返回内容转换msg
%%result_msg(Result) ->
%%    case Result of
%%        ok ->
%%            "游戏支付成功";
%%        null_platform_id ->
%%            "平台不存在";
%%        not_exists ->
%%            "用户不存在";
%%        error_sha ->
%%            "检验码不一致";
%%        not_sign ->
%%            "没有sign字段";
%%        not_path ->
%%            "没找到url地址";
%%        error_md5 ->
%%            "校验码错误";
%%        not_ip ->
%%            "ip 不合法";
%%        _ ->
%%            ?DEBUG("result_msg errror: ~p~n", [Result]),
%%            "其他错误"
%%    end.

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).

