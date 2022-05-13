%%% Generated automatically, no need to modify.
-module(logic_get_shenlongzhufu_weights_list).
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


get(6) ->
     [{1,1000},{2,15},{3,10},{4,5},{5,17},{6,45}];
get(5) ->
     [{1,1000},{2,15},{3,10},{4,5},{5,17},{6,45}];
get(4) ->
     [{1,1000},{2,15},{3,10},{4,5},{5,17},{6,45}];
get(3) ->
     [{1,1000},{2,15},{3,10},{4,5},{5,17},{6,45}];
get(2) ->
     [{1,1000},{2,15},{3,10},{4,5},{5,17},{6,45}];
get(1) ->
     [{1,1000},{2,15},{3,10},{4,5},{5,17},{6,45}];
get(_Id) ->
    null.
