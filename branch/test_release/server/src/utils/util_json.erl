%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            json封装
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(util_json).

%% API
-export([
    encode/1,
    encode/2,
    try_encode/1,
    try_encode/2,

    decode/1,
    decode/2,
    decode_to_map/1,
    decode_to_proplist/1,
    try_decode/1,
    try_decode/2,
    try_decode_to_map/1,
    try_decode_to_proplist/1
]).

%% NOTE: 字符串必须用atom或者binary

%% util_json:encode([{<<"name">>,<<"jack">>}]) => <<"{\"name\":\"jack\"}">>
%% util_json:decode(<<"{\"name\":\"jack\"}">>) => #{<<"name">> => <<"v">>}

%% return: binary
encode(Data) ->
    encode(Data, []).
encode(Data, Options) ->
    jsone:encode(Data, Options).

%% return: 默认返回map
decode(Data) ->
    decode(Data, []).
decode(Data, Options) ->
    jsone:decode(util:to_binary(Data), Options).

decode_to_map(Data) ->
    decode(Data, [{object_format, map}]).

decode_to_proplist(Data) ->
    decode(Data, [{object_format, proplist}]).

%% return: {ok, binary} | {error, term}
try_encode(Data) ->
    try_encode(Data, []).

try_encode(Data, Options) ->
    jsone:try_encode(Data, Options).

%% return: {ok, map} | {error, term}
try_decode(Data) ->
    try_decode(Data, []).

try_decode(Data, Options) ->
    case jsone:try_decode(util:to_binary(Data), Options) of
        {ok, Json, _Remain} ->
            {ok, Json};
        {error, {Reason, Stack}} ->
            {error, {Reason, Stack}}
    end.

try_decode_to_map(Data) ->
    try_decode(Data).

try_decode_to_proplist(Data) ->
    try_decode(Data, [{object_format, proplist}]).
