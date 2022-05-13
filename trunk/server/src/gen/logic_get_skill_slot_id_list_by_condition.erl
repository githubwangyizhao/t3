%%% Generated automatically, no need to modify.
-module(logic_get_skill_slot_id_list_by_condition).
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


get([level,1]) ->
     [1,2,3,4];
get([fun_id,112]) ->
     [5];
get([fun_id,120]) ->
     [6];
get(_Id) ->
    null.
