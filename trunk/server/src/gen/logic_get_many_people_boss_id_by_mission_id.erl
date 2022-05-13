%%% Generated automatically, no need to modify.
-module(logic_get_many_people_boss_id_by_mission_id).
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


get(10) ->
     10;
get(9) ->
     9;
get(8) ->
     8;
get(7) ->
     7;
get(6) ->
     6;
get(5) ->
     5;
get(4) ->
     4;
get(3) ->
     3;
get(2) ->
     2;
get(1) ->
     1;
get(_Id) ->
    null.
