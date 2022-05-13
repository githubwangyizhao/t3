%%% Generated automatically, no need to modify.
-module(logic_get_all_world_scene_id).
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
     [1004,1002,1003,1005,999,1007,1000,1008,1001,10000,1006];
get(_Id) ->
    null.
