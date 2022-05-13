%%%-------------------------------------------------------------------
%%% @author rbz
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. Apr 2019 11:16 PM
%%%-------------------------------------------------------------------
-module(util_http_url).

%% API
-export([
    sign/2,             %% 签名
    sign_and_encode/4,  %% 返回签名过的 query string
    encode/1,           %% 返回 query string
    urlencode/1,
    try_urldecode/1
]).

%% @doc 签名
%%  e.g. [{key, value}] => string()
sign(Props, Type) ->
    sign(Props, Type, "").
sign(Props, Type, Key) when is_list(Props) andalso is_list(Key)->
    S = encode(lists:sort(Props)),
    sign_string(S, Type, Key).

%% @private
sign_string(S, Type, Key) ->
    case Type of
        md5 ->
            encrypt:md5(S ++ Key);
        _ ->
            exit({sign_type_no_match, Type})
    end.

%% @doc 返回签名过的 query string
%%  e.g. [{name, "xiaoming"}, {age, 9}] => "name=xiaoming&age=9&sign=?"
sign_and_encode(Props, Type, SignName, Key) when is_list(Props) andalso is_list(SignName) andalso is_list(Key)->
    QueryString = encode(lists:sort(Props)),
    QueryString ++ "&" ++ SignName ++ "=" ++ sign_string(QueryString, Type, Key).

%% @doc 返回 query string
%%  e.g. [{key, value}] => query string
%%       [{name, "xiaoming"}, {age, 9}] => "name=xiaomi&age=9"
encode(Props) when is_list(Props)->
    mochiweb_util:urlencode(Props).
%%    Pairs = lists:foldr(
%%        fun ({K, V}, Acc) ->
%%            [util:to_list(K) ++ "=" ++ util:to_list(V) | Acc]
%%        end, [], Props),
%%    string:join(Pairs, "&").

%% @doc urlencode
urlencode(Url) ->
    http_uri:encode(Url).

%% @doc urlencode
try_urldecode(Url) ->
    try_urldecode(Url, 3).
try_urldecode(Url, 0) ->
    Url;
try_urldecode(Url, N) ->
    Url1 = http_uri:decode(Url),
    case string:find(Url1, "%") of
        'nomatch' ->
            Url1;
        _ ->
            try_urldecode(Url1, N - 1)
    end.