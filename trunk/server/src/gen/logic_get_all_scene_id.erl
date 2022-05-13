%%% Generated automatically, no need to modify.
-module(logic_get_all_scene_id).
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
     [1004,6003,1002,4205,1003,1005,999,4103,6001,5001,4201,9904,4105,5002,9901,4204,1007,4202,1,1000,4102,4104,4206,4106,6002,5003,9902,4101,3001,1008,5004,2001,1001,10000,4203,1006];
get(_Id) ->
    null.
