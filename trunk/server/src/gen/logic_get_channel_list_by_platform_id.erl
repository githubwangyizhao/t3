%%% Generated automatically, no need to modify.
-module(logic_get_channel_list_by_platform_id).
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


get("local") ->
     [[108,111,99,97,108,95,116,101,115,116]];
get("moy") ->
     [[109,111,121]];
get("djs") ->
     [[116,101,115,116]];
get("indonesia") ->
     [[102,98]];
get(_Id) ->
    null.
