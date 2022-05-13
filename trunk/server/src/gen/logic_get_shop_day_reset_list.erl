%%% Generated automatically, no need to modify.
-module(logic_get_shop_day_reset_list).
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
     [{0,[{201,41},{211,51},{221,40231},{231,40241},{241,10021},{251,10031}]}];
get(_Id) ->
    null.
