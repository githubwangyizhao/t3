%%% Generated automatically, no need to modify.
-module(logic_get_all_world_map_id).
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


get(0) ->
     [999,1000,1001,1002,1003,1004,1005,1006,10000];
get(_Id) ->
    null.
