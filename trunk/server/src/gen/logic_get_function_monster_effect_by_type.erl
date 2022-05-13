%%% Generated automatically, no need to modify.
-module(logic_get_function_monster_effect_by_type).
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


get({3}) ->
     [105,111,109];
get({2}) ->
     [107,112,110,106];
get({1}) ->
     [103,102];
get(_Id) ->
    null.
