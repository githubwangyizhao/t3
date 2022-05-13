%%% Generated automatically, no need to modify.
-module(logic_get_slot_id_by_type).
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
     [2,1,4,3];
get(10) ->
     [5];
get(9) ->
     [6];
get(_Id) ->
    null.
