%%% Generated automatically, no need to modify.
-module(logic_get_all_world_scene_id_by_server_type).
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


get(1) ->
     [1006,10000,1001,1008,1000,1007,999,1005,1003,1002,1004];
get(_Id) ->
    null.
