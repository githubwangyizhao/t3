%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 1月 2021 下午 04:55:06
%%%-------------------------------------------------------------------
-module(util_token).
-author("Administrator").

%% API
-export([
    get_token/1,
    get_token/2,
    get_token/3,
    get_token/4,

    chk_token/1,
    chk_token/2
]).

-define(Private_key, <<"supas3cri7">>).

%% @doc 获得Token
%% Alg 如 <<"HS256">>，<<"HS384">>，<<"HS512">>，<<"RS256">>，<<"ES256">>
%% Claims 如 [{<<"iss">>,"gasdasda"},{<<"user_id">>, 42},{<<"user_name">>, "Bob"}]等
%% @end
get_token(Claims) ->
    get_token(<<"HS256">>, Claims).
get_token(Alg, Claims) ->
    get_token(Alg, Claims, ?Private_key).
get_token(Alg, Claims, Key) ->
    {ok, Token} = jwt:encode(Alg, Claims, Key),
    Token.
get_token(Alg, Claims, Key, ExpirationSeconds) ->
    {ok, Token} = jwt:encode(Alg, Claims, ExpirationSeconds, Key),
    Token.

chk_token(Token) ->
    chk_token(Token, ?Private_key).
chk_token(Token, Key) ->
    case jwt:decode(Token, Key) of
        {ok, MapData} ->
            {ok, MapData};
        {error, invalid_signature} ->
            invalid_signature;
        {error,expired} ->
            expired
    end.
%%    {ok, _} = jwt:decode(Token, Key),
%%    ok.