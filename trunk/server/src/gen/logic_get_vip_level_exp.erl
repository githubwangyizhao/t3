%%% Generated automatically, no need to modify.
-module(logic_get_vip_level_exp).
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
     [{12,1280000},{11,698000},{10,468000},{9,258000},{8,128000},{7,64800},{6,32800},{5,12800},{4,6800},{3,2800},{2,799},{1,99}];
get(_Id) ->
    null.
