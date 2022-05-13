%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 8月 2021 下午 05:21:25
%%%-------------------------------------------------------------------
-module(util_cowboy).

%% API
-export([
    reply_json/2,
    reply_html/2,
    reply_text/2,
    reply_success/1,
    reply_error_code/2,
    reply_error_code/3,
    get_request_data/1,
    get_request_data/2,
    encode_data/1,
    decode_data/1,
    handle_request/2,
    handle_request/3,
    handle_request_or_failFun/3,    % 请求操作并且处理失败时操作
    get_ip/1        %% 获取客户端ip(反向代理)
%%    get_ip/1                %% 获取客户端ip
]).

-include("common.hrl").
%% @doc 获取http请求数据
%% @return {ok, [{binary(), binary()} ...]} % 表单 => 列表
%%         | {ok, map}                      % json => 字典
%%         | {error, Reason}
get_request_data(Req_0) ->
    get_request_data(Req_0, false).
get_request_data(Req_0, IsForceUrlDecode) ->
    Method = cowboy_req:method(Req_0),
    case Method of
        <<"GET">> ->
            FormParams =
                if IsForceUrlDecode ->
%%                ?INFO("Req:~p~n", [cowboy_req:parse_qs(Req_0)]),
%%                ?INFO("Req:~p~n", [cow_qs:parse_qs(http_uri:decode(cowboy_req:qs(Req_0)))]),
                    cow_qs:parse_qs(util_http_url:try_urldecode(cowboy_req:qs(Req_0)));
                    true ->
                        cowboy_req:parse_qs(Req_0)
                end,
            {ok, FormParams};
        <<"POST">> ->
            case cowboy_req:has_body(Req_0) of
                true ->
                    {ok, Body, Req_1} = cowboy_req:read_body(Req_0, #{length => 64000, period => 5000}),
                    Head0 = erlang:binary_to_list(cowboy_req:header(<<"content-type">>, Req_1)),
                    Head = hd(string:tokens(Head0, ";")),
                    case Head of
                        "application/json" ->
                            {ok, util_json:decode(Body)};
                        "application/x-www-form-urlencoded" ->
                            FormParams = cow_qs:parse_qs(Body),
                            {ok, FormParams};
                        Other ->
                            {error, {content_type_error, Other}}
                    end;
                false ->
                    {error, mission_body}
            end;
        Other ->
            {error, {method_not_allowed, Other}}
    end.


reply_html(Req, Html) ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/html">>},
        Html,
        Req
    ).

reply_json(Req, Json) ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"application/json">>, <<"access-control-allow-origin">> => <<"*">>},
        Json,
        Req
    ).


reply_text(Req, Text) ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>, <<"access-control-allow-origin">> => <<"*">>},
        Text,
        Req
    ).

reply_success(Req) ->
    reply_error_code(Req, 0, <<"">>).

reply_error_code(Req, ErrorCode) ->
    reply_error_code(Req, ErrorCode, <<"">>).
reply_error_code(Req, ErrorCode, Msg) when is_integer(ErrorCode) andalso is_binary(Msg) ->
    reply_json(
        Req,
        util_json:encode([{error_code, ErrorCode}, {error_msg, Msg}])
    ).

encode_data(Data) ->
    Data0 = util_json:encode([{util:to_binary(Key), util:to_binary(Value)} || {Key, Value} <- Data]),
    Base64Data = cow_base64url:encode(Data0),
    case lists:keyfind(time, 1, Data) of
        false ->
            Sign = encrypt:md5(util:to_list(Data0) ++ ?GM_SALT),
            [{data, util:to_list(Base64Data)}, {sign, Sign}];
        {time, Time} ->
            Sign = encrypt:md5(util:to_list(Data0) ++ util:to_list(Time) ++ ?GM_SALT),
            [{data, util:to_list(Base64Data)}, {time, Time}, {sign, Sign}]
    end.

decode_data(FormParams) ->
    Base64Data = util_list:opt(<<"data">>, FormParams),
    Data = cow_base64url:decode(Base64Data),
    Time = util:to_int(util_list:opt(<<"time">>, FormParams)),
    Now = util_time:timestamp(),
    %% 3分钟过期
    case ?IS_DEBUG of
        true ->
            noop;
        _ ->
            ?ASSERT(erlang:abs(Now - Time) < 60 * 3, {time_expire, Now, Time})
    end,
    Sign = util:to_list(util_list:opt(<<"sign">>, FormParams)),
    GenSign = encrypt:md5(util:to_list(Data) ++ util:to_list(Time) ++ ?GM_SALT),
    ?ASSERT(Sign == GenSign, sign_error),
    Data.

%% @doc fun 请求操作
handle_request(Req, Fun) ->
    handle_request(Req, Fun, false).
handle_request(Req, Fun, IsForceUrlDecode) ->
    FailFun =
        fun(FailReq, _RequestDataStr, _ErrorType, Reason) ->
            util_cowboy:reply_error_code(
                FailReq,
                1,
                util:to_binary(util_string:term_to_string(Reason))
            )
        end,
    handle_request_or_failFun(Req, Fun, FailFun, IsForceUrlDecode).
%% @doc fun 请求操作并且处理失败时操作
handle_request_or_failFun(Req, Fun, FailFun) ->
    handle_request_or_failFun(Req, Fun, FailFun, false).
handle_request_or_failFun(Req, Fun, FailFun, IsForceUrlDecode) ->
    case get_req_param_data(Req, IsForceUrlDecode) of
        {ok, RequestParamList, RequestDataStr} ->
            try
                Fun(Req, RequestParamList, RequestDataStr) of
                _ ->
                    ?INFO(
                        "Request success:~s; IP:~s; data:~1000p\n",
                        [
                            cowboy_req:uri(Req),
                            get_remote_ip(Req),
                            RequestParamList
                        ]
                    )
            catch
                _:Reason ->
                    ?ERROR(
                        "Request fail!!!!!\n"
                        "  uri:~s~n"
                        "  method:~p~n"
                        "  headers:~p~n"
                        "  ip:~s~n"
                        "  reason:~p~n"
                        "  data:~1000p~n"
                        "  stack:~p~n",
                        [
                            cowboy_req:uri(Req),
                            cowboy_req:method(Req),
                            cowboy_req:headers(Req),
                            get_remote_ip(Req),
                            Reason,
                            RequestParamList,
                            erlang:get_stacktrace()
                        ]
                    ),
                    FailFun(Req, RequestDataStr, 'EXIT', Reason)
%%                    util_cowboy:reply_error_code(
%%                        Req,
%%                        1,
%%                        util:to_binary(util_string:term_to_string(Reason))
%%                    )
            end;
        {error, Reason} ->
            ?ERROR(
                "Get request data fail!!!\n"
                "  uri:~s~n"
                "  ip:~s~n"
                "  reason:~p~n",
                [
                    cowboy_req:uri(Req),
                    get_ip(Req),
                    util:to_binary(util_string:term_to_string(Reason))
                ]
            ),
            FailFun(Req, "", error, "decode data error")
%%            util_cowboy:reply_error_code(
%%                Req,
%%                1,
%%                <<"decode data error">>
%%            )
    end.


%% @doc fun 获得ip
get_ip(Req) ->
    get_remote_ip(Req).

%% @doc 获取客户端ip
get_req_ip(Req) ->
    {PeerAddress, _} = cowboy_req:peer(Req),
    inet_parse:ntoa(PeerAddress).

%% @doc 获取客户端ip(支持反向代理)
get_remote_ip(Req) ->
    case cowboy_req:header(<<"x-forwarded-for">>, Req) of
        undefined ->
            get_req_ip(Req);
        Ip ->
            util_string:trim(hd(string:split(util:to_list(Ip), ",")))
    end.

%% @fun 获得参数数据  {[{<<"key">>, <<"value">>...], "key=value&..."}
% xml:[key,value]  key：原子 {money, 7}, {orderId, "asdfaf"}
%%get_req_param_data(Req) ->
%%    get_req_param_data(Req, false).
get_req_param_data(Req, IsForceUrlDecode) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"GET">> ->
            GetParamBin1 = cowboy_req:qs(Req),
            GetParamBin2 =
                if IsForceUrlDecode ->
                    cow_qs:parse_qs(util_http_url:try_urldecode(GetParamBin1));
                    true ->
                        cowboy_req:parse_qs(Req)
                end,
            {ok, GetParamBin2, util:to_list(GetParamBin1)};
        <<"POST">> ->
            {ok, ParamBodyBin, Req_1} = cowboy_req:read_body(Req),
            Head0 = util:to_list(cowboy_req:header(<<"content-type">>, Req_1)),
            Head = hd(string:tokens(Head0, ";")),
            ParamList =
                try
                    case string:tokens(Head, "/") of
                        [_, "x-www-form-urlencoded"] ->
                            cow_qs:parse_qs(ParamBodyBin);
                        [_, "json"] ->
                            jsone:decode(ParamBodyBin, [{object_format, proplist}]);
                        [_, "xml"] ->
                            xml:decode(ParamBodyBin);
                        _ ->
                            Path = cowboy_req:path(Req),
                            ?ERROR("未处理数据格式path:~p ;Head:~p~n", [Path, Head]),
                            exit(not_head_data)
                    end
                catch
                    _: R ->
%%                        Path = cowboy_req:path(Req),
                        ?ERROR("获取参数~p错误error Head:~p ; param:~p~n", [Head, {ParamBodyBin, R}]),
                        []
                end,
%%                    ?INFO("Head: ~p~n", [ParamList]),
            {ok, ParamList, util:to_list(ParamBodyBin)};
        _ ->
            ?ERROR("错误handle_request Method: ~p ~n", [Method]),
            exit(not_err_method)
%%            end
%%        {ok, ParamList, ParamStr} ->
%%            {ok, ParamList, ParamStr}
    end.

