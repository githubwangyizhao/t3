%%% Generated automatically, no need to modify.
-module(logic_get_shop_charge_shop_id).
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


get(251) ->
     true;
get(241) ->
     true;
get(231) ->
     true;
get(221) ->
     true;
get(211) ->
     true;
get(201) ->
     true;
get(_Id) ->
    null.
