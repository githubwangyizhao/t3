%%% Generated automatically, no need to modify.
-module(logic_get_charge_http_type_list).
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
     [{0,[230,153,174,233,128,154,40,233,146,187,231,159,179,41],0},{1,[233,166,150,229,133,133],0}];
get(_Id) ->
    null.
