%%% Generated automatically, no need to modify.
-module(logic_get_shop_type_id_list).
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


get(102) ->
     [1025,1021,1022,1026,1023,1024];
get(101) ->
     [1012,1014,1015,1011,1013,1016];
get(20) ->
     [302,301,303];
get(10) ->
     [221,201,231,211,241,251];
get(3) ->
     [22,18,23,24,21,20,19];
get(1) ->
     [6,2,9,10,11,1,7,4,3,8,5];
get(_Id) ->
    null.
