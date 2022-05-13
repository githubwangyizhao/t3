%%% Generated automatically, no need to modify.
-module(logic_get_can_bet_mission_id).
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
     [102,108];
get(0) ->
     [104,201,107,105,103,1,202,999,100,99,106,101];
get(_Id) ->
    null.
