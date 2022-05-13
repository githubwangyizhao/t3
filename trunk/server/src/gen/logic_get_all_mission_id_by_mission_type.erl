%%% Generated automatically, no need to modify.
-module(logic_get_all_mission_id_by_mission_type).
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


get(103) ->
     [1,2];
get(999) ->
     [1];
get(202) ->
     [1,2,3,4,5,6];
get(102) ->
     [1];
get(108) ->
     [1];
get(201) ->
     [1,2,3,4,5,6];
get(_Id) ->
    null.
