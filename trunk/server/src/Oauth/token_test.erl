%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 1月 2021 下午 02:42:11
%%%-------------------------------------------------------------------
-module(token_test).
-author("Administrator").

-compile(export_all).

%% API
-export([]).

-define(Private_key, <<"supas3cri7">>).

get_token() ->
    Claims = [
        {user_id, 42},
        {user_name, <<"Bob">>}
    ],
    get_token(Claims).

get_token(Claims) ->
    jwt:encode(<<"HS256">>,Claims,?Private_key).

get_token2(Claims) ->
    ExpirationSeconds = 86400,
    jwt:encode(<<"HS256">>,Claims,ExpirationSeconds,?Private_key).

test() ->
    Claims = [
        {<<"iss">>,"gasdasda"},
        {<<"user_id">>, 42},
        {<<"user_name">>, "Bob"}
    ],
%%    Map = #{<<"iss">> => <<"gasdasda">>,<<"user_id">> => 42,<<"user_name">> => <<"Bob">>},
%%    {ok,Token} = jwt:encode(<<"HS256">>,Claims,?Private_key),
    {ok,Token} = jwt:encode(<<"HS512">>,Claims,10,?Private_key),
    io:format("Token  ~p",[Token]),
    timer:sleep(2000),
    Data = jwt:decode(Token, ?Private_key),
    io:format("Data ~p",[Data]).
%%    Claims = maps:to_list(Data).

test1() ->
    Claims = [
        {<<"iss">>,"gasdasda"},
        {<<"user_id">>, 42},
        {<<"user_name">>, "Bob"}
    ],
    {ok,Token} = jwt:encode(<<"HS512">>,Claims,60,?Private_key),
    Token.
%%test() ->
%%    Claims = [
%%        {iss,"gasdasda"},
%%            {user_id, 42},
%%            {user_name, <<"Bob">>}
%%    ],
%%%%    Map = lists:foldl(
%%%%        fun({Key,Value},MapsTmp) ->
%%%%            maps:put(Key,Value,MapsTmp)
%%%%            end,
%%%%        maps:new(),Claims
%%%%    ),
%%    {ok,Token} = jwt:encode(<<"HS256">>,Claims,?Private_key),
%%    {ok,Data} = jwt:decode(Token, ?Private_key),
%%    io:format("Data ~p",[Data]).