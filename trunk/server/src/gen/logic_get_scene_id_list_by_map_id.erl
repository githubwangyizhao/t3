%%% Generated automatically, no need to modify.
-module(logic_get_scene_id_list_by_map_id).
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


get(4201) ->
     [4203,4206,4202,4204,4201,4205];
get(1000) ->
     [1000];
get(9903) ->
     [9904];
get(1001) ->
     [1001,5001,6001];
get(1005) ->
     [1005];
get(999) ->
     [1,999];
get(1002) ->
     [6002,5002,1002];
get(4101) ->
     [4101,4106,4104,4102,4105,4103];
get(1004) ->
     [5004,1008,1004];
get(1003) ->
     [5003,1007,1003,6003];
get(9901) ->
     [9902,9901];
get(3001) ->
     [3001];
get(2001) ->
     [2001];
get(10000) ->
     [10000];
get(1006) ->
     [1006];
get(_Id) ->
    null.
