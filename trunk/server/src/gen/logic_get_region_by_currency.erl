%%% Generated automatically, no need to modify.
-module(logic_get_region_by_currency).
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


get("VND") ->
     [[]];
get("TWD") ->
     [[229,143,176,231,129,163]];
get("THB") ->
     [[]];
get("SGD") ->
     [[]];
get("MYR") ->
     [[]];
get("MMK") ->
     [[]];
get("LAK") ->
     [[]];
get("KHR") ->
     [[]];
get("IDR") ->
     [[]];
get([]) ->
     [[]];
get(_Id) ->
    null.
