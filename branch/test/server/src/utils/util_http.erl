%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2019, THYZ
%%% @doc            http请求封装
%%% @end
%%% Created : 21. 一月 2018 下午 1:51
%%%-------------------------------------------------------------------
-module(util_http).

%% API
-export([
    get/1,
    get/3,
    post/3,
    post/5
]).
-include("common.hrl").
%% @doc get 请求
%% @return {ok, Response} | {error, Reason}
get(Url) ->
    get(Url, [], []).

get(Url, Header, HTTPOptions) ->
    do_request(get, Url, "", "", Header, HTTPOptions).

%% @doc post 请求
%% @return {ok, Response} | {error, Reason}
post(Url, ContentType, Body) ->
    post(Url, ContentType, Body, [], []).
post(Url, ContentType_0, Body, Header, HTTPOptions) ->
    {ContentType_1, NewBody} =
        case ContentType_0 of
            xml ->
                ParamList = Body,
                JsonBody = xml:encode(ParamList),
                {"application/xml", JsonBody};
            json ->
                ParamList = Body,
                JsonBody = jsone:encode([{util:to_atom(Key), ?IF(is_integer(Val), Val, util:to_binary(Val))} || {Key, Val} <- ParamList]),
                {"application/json;charset=utf-8", JsonBody};
            form ->
                {"application/x-www-form-urlencoded", Body};
            _ ->
                exit({post_contentType_error, ContentType_0})
        end,
    do_request(post, Url, ContentType_1, NewBody, Header, HTTPOptions).

do_request(Method, Url, ContentType, Body, Header, HTTPOptions) ->
    do_request_1(Method, Url, ContentType, Body, Header, HTTPOptions, true).

do_request_1(Method, Url, ContentType, Body, Header, HTTPOptions, IsFailRetry) ->
    RequestResult = case Method of
                        get ->
                            ?DEBUG(
                                "\nHttp get request =>\n"
                                "  url: ~ts\n"
                                "  header: ~p\n"
                                "  httpOptions: ~p\n",
                                [Url, Header, HTTPOptions]),
                            httpc:request(get, {Url, Header}, HTTPOptions, []);
                        post ->
                            ?INFO(
                                "\nHttp post request =>\n"
                                "  url: ~ts\n"
                                "  header: ~p\n"
                                "  contentType: ~p\n"
                                "  body: ~p\n"
                                "  httpOptions: ~p\n",
                                [Url, Header, ContentType, Body, HTTPOptions]),
                            httpc:request(post, {Url, Header, ContentType, Body}, HTTPOptions, [])
                    end,
    case RequestResult of
        {error, socket_closed_remotely} ->
            if
                IsFailRetry ->
                    ?WARNING("http retry:~p", [{socket_closed_remotely, Method, Url, ContentType, Body, Header, HTTPOptions}]),
                    do_request_1(Method, Url, ContentType, Body, Header, HTTPOptions, false);
                true ->
                    {error, socket_closed_remotely}
            end;
        {error, Reason} ->
            ?DEBUG("{error, Reason}:~p~n",[Reason]),
            {error, Reason};
        {ok, {{HTTPVersion, StatusCode, ReasonPhrase}, Headers, Result}} ->
            ?DEBUG(
                "Http ~p respone =>\n"
                "  httpVersion: ~s\n"
                "  status: ~p\n"
                "  headers: ~p\n"
                "  result: ~s\n",
                [Method, HTTPVersion, {StatusCode, ReasonPhrase}, Headers, Result]),
            if StatusCode == 200 ->
                {ok, Result};
                true ->
                    {error, {statusCodeError, StatusCode, Result}}
            end

    end.
