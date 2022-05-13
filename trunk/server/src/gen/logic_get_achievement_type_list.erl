%%% Generated automatically, no need to modify.
-module(logic_get_achievement_type_list).
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
     [101,102,103,104,105,107,108,109,111,112,113,114,9999];
get(_Id) ->
    null.
