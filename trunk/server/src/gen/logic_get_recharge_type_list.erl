%%% Generated automatically, no need to modify.
-module(logic_get_recharge_type_list).
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


get(2) ->
     [40100,40121,40122,40211,40221,40231,40241,100201,400001,400011,400021,400031,400041,400051,400061,400071];
get(1) ->
     [1,2,3,4,5,6,7,8,10,21,22,31,32,41,51,101];
get(0) ->
     [100,201,202,990,1000,2000,3000,4000,5000,6000,7000,8000,9000,10011,10012,10021,10031,100001];
get(_Id) ->
    null.
