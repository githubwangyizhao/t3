%%% Generated automatically, no need to modify.
-module(logic_get_all_war_map_id).
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
     [1001,1002,1003,1004,2001,3001,9901,9903];
get(_Id) ->
    null.
