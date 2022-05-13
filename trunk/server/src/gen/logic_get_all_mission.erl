%%% Generated automatically, no need to modify.
-module(logic_get_all_mission).
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
     [{201,1},{202,5},{201,4},{103,2},{999,1},{202,1},{201,3},{201,6},{201,5},{102,1},{108,1},{202,3},{202,6},{202,4},{202,2},{103,1},{201,2}];
get(_Id) ->
    null.
