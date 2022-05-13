%%% Generated automatically, no need to modify.
-module(logic_get_all_platform_id).
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
     [[108,97,111,115],[116,101,115,116],[109,121,97,110,109,97,114],[118,105,101,116,110,97,109],[116,97,105,119,97,110],[116,101,115,116,50],[115,105,110,103,97,112,111,114,101],[116,104,97,105,108,97,110,100],[105,110,100,111,110,101,115,105,97],[109,111,121],[99,97,109,98,111,100,105,97],[108,111,99,97,108],[109,97,108,97,121,115,105,97]];
get(_Id) ->
    null.
