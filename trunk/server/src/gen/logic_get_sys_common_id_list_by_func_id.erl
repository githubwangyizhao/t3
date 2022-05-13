%%% Generated automatically, no need to modify.
-module(logic_get_sys_common_id_list_by_func_id).
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


get(105) ->
     [601,602,603,604,605,606];
get(_Id) ->
    null.
