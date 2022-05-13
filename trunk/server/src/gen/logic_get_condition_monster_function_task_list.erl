%%% Generated automatically, no need to modify.
-module(logic_get_condition_monster_function_task_list).
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


get(kill_monster_count) ->
     [6,15,22,2,18,14,9,10,16,23,13,11,24,1,17,21,12,7,4,3,8,20,5,19];
get(_Id) ->
    null.
