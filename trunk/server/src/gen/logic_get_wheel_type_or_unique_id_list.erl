%%% Generated automatically, no need to modify.
-module(logic_get_wheel_type_or_unique_id_list).
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


get(type_list) ->
     [{1,[1,2,3,4]},{2,[1,2,3,4]},{3,[0]},{4,[0]}];
get(id_list) ->
     [{1,[1,2,3,4,5,6,7,8,9,10]},{2,[1,2,3,4,5,6,7,8,9,10]},{3,[1,2,3,4,5,6,7,8]},{4,[1,2,3,4,5,6,7,8]}];
get(_Id) ->
    null.
