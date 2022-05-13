%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 21. 三月 2018 20:41
%%%-------------------------------------------------------------------
-module(web_http_util).
-author("home").

%% API
-export([
    output_error_code/2,
    output_xml/2,
    output_text/2,
    output_html/2,
    output_json/2
]).

output_json(Req, Int) when is_integer(Int) ->
    io:format("Int: ~p~n", [Int]),
    if
        Int == 400 ->
            Resp = {'msg', util:to_binary(util_string:to_utf8("Invalid Parameters"))};
        Int == 401 ->
            Resp = {'msg', util:to_binary(util_string:to_utf8("Unauthorized"))};
        Int == 403 ->
            Resp = {'msg', util:to_binary(util_string:to_utf8("Access Denined"))};
        Int == 404 ->
            Resp = {'msg', util:to_binary(util_string:to_utf8("Not Found"))};
        Int == 204 ->
            Resp = {'msg', util:to_binary(util_string:to_upper_char("Resource Has Deleted"))};
        Int == 405 ->
            Resp = {'msg', util:to_binary(util_string:to_upper_char("Method Not Allowed"))};
        Int == 422 ->
            Resp = {'msg', util:to_binary(util_string:to_upper_char("unabled to operate"))};
        true ->
            Resp = {'msg', util:to_binary(util_string:to_upper_char("Resource unavailable"))}
    end,
    cowboy_req:reply(
        Int,
        #{<<"content-type">> => <<"application/json">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"Access-Control-Allow-Origin">> => <<"*">>},
        lib_json:encode([{'code', Int}] ++ [Resp]),
        Req
    );
%% @fun 返回数据结果
output_json(Req, Map) when is_map(Map)  ->
    cowboy_req:reply(
        200,
%%        #{<<"content-type">> => <<"text/plain">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"access-control-allow-origin">> => <<"*">>},
        #{<<"content-type">> => <<"application/json">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"Access-Control-Allow-Origin">> => <<"*">>},
        jsone:encode(Map),
        Req
    );
output_json(Req, Tuple) when is_tuple(Tuple) ->
    Url = tuple_to_list(Tuple),
    io:format("redirect: ~p~n", [Url]),
    cowboy_req:reply(
        302,
        #{<<"Location">> => list_to_binary(Url)},
        <<"Redirecting with Header">>,
        Req
    );
output_json(Req, List) when is_list(List) ->
%%    Resp = jsone:encode(List),
    Resp = lib_json:encode(List),
%%    Obj = {obj, List},
%%    Resp = rfc4627:encode(List),
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"application/json">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"Access-Control-Allow-Origin">> => <<"*">>},
        Resp,
        Req
    ).

%% @fun 返回数据结果
output_error_code(Req, List) when is_list(List)  ->
    cowboy_req:reply(
        200,
%%        #{<<"content-type">> => <<"text/plain">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"access-control-allow-origin">> => <<"*">>},
        #{<<"content-type">> => <<"text/plain">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"Access-Control-Allow-Origin">> => <<"*">>},
        jsone:encode(List),
        Req
    );
%% @fun 返回数据结果
output_error_code(Req, ErrorCode) ->
    cowboy_req:reply(
        200,
%%        #{<<"content-type">> => <<"text/plain">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"access-control-allow-origin">> => <<"*">>},
        #{<<"content-type">> => <<"text/plain">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"Access-Control-Allow-Origin">> => <<"*">>},
        jsone:encode([{'ErrorCode', ErrorCode}]),
        Req
    ).

output_html(Req, Body) ->
    cowboy_req:reply(
        200,
        #{<<"Content-type">> => <<"text/html">>, <<"Connection">> => <<"close">>},
        Body,
        Req
    ).

%% @fun 返回数据内容
output_text(Req, Body) ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"access-control-allow-origin">> => <<"*">>},
        Body,
        Req
    ).

%% @fun 返回数据内容
output_xml(Req, List) when is_list(List)  ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>, <<"connection">> => <<"close">>, <<"accept-charset">> => <<"utf-8">>, <<"access-control-allow-origin">> => <<"*">>},
        xml:encode(List),
        Req
    ).