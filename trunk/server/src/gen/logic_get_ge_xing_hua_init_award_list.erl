%%% Generated automatically, no need to modify.
-module(logic_get_ge_xing_hua_init_award_list).
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
     [{7112,1},{2111,1},{6001,1},{7113,1},{7906,1},{7905,1},{6201,1},{6002,1}];
get(_Id) ->
    null.
