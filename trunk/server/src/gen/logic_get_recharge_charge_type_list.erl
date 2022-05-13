%%% Generated automatically, no need to modify.
-module(logic_get_recharge_charge_type_list).
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


get(5) ->
     [31,32,10011,10012,40211,40221];
get(3) ->
     [101,100001];
get(2) ->
     [41,51,10021,10031,40231,40241];
get(1) ->
     [10,21,22,100,201,202,40100,40121,40122];
get(0) ->
     [1,2,3,4,5,6,7,8,990,1000,2000,3000,4000,5000,6000,7000,8000,9000,100201,400001,400011,400021,400031,400041,400051,400061,400071];
get(_Id) ->
    null.
