-module(util_maps).

%% API
-export([
    try_get/2,
    get/2,

    get_string/2,
    try_get_string/2,
    get_string_default/3,

    try_get_integer/2,
    get_integer/2,
    get_integer_default/3
]).

%% return {ok, term} | error
try_get(Key, Map) ->
    maps:find(Key, Map).

%% return term | exit()
get(Key, Map) ->
    case try_get(Key, Map) of
        {ok, Value} ->
            Value;
        error ->
            io:format("~n[ERROR] maps key no exists:~p~n", [Key]),
            exit({maps_key_no_exists, Key})
    end.

%% return {ok, string} | error
try_get_string(Key, Map) ->
    case maps:find(Key, Map) of
        {ok, Value} ->
            {ok, util:to_list(Value)};
        error ->
            error
    end.

%% return string | exit()
get_string(Key, Map) ->
    case try_get_string(Key, Map) of
        {ok, Value} ->
            Value;
        error ->
            io:format("~n[ERROR] maps key no exists:~p~n", [Key]),
            exit({maps_key_no_exists, Key})
    end.

%% return string
get_string_default(Key, Map, Default) ->
    util:to_list(maps:get(Key, Map, Default)).

%% return {ok, integer} | error
try_get_integer(Key, Map) ->
    case maps:find(Key, Map) of
        {ok, Value} ->
            {ok, util:to_int(Value)};
        error ->
            error
    end.

%% return integer | exit()
get_integer(Key, Map) ->
    case try_get_integer(Key, Map) of
        {ok, Value} ->
            Value;
        error ->
            io:format("~n[ERROR] maps key no exists:~p~n", [Key]),
            exit({maps_key_no_exists, Key})
    end.

%% return integer
get_integer_default(Key, Map, Default) ->
    util:to_int(maps:get(Key, Map, Default)).