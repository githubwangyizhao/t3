%%% Generated automatically, no need to modify.
-module(logic_get_times_id_by_function_id).
-export([get/1, get/2, assert_get/1, get_keys/0]).

get(Key, Default) ->
    case ?MODULE:get(Key) of
        null -> Default;
        Result -> Result
    end.

assert_get(Key) ->
    case ?MODULE:get(Key) of
        null -> exit({got_null, ?MODULE, Key});
        Result -> Result
    end.

get_keys() ->
     [].


get(999) ->
     [2100];
get(1073) ->
     [2000];
get(171) ->
     [101];
get(9001) ->
     [2200];
get(1071) ->
     [1008];
get(1061) ->
     [1001];
get(_Id) ->
    null.
