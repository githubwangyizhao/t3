%%% Generated automatically, no need to modify.
-module(logic_get_platform_id_by_channel).
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


get("moy") ->
     [109,111,121];
get("test") ->
     [100,106,115];
get("local_test") ->
     [108,111,99,97,108];
get("fb") ->
     [105,110,100,111,110,101,115,105,97];
get(_Id) ->
    null.
