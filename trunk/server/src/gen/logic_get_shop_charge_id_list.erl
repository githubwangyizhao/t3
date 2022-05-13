%%% Generated automatically, no need to modify.
-module(logic_get_shop_charge_id_list).
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


get([101,1]) ->
     [{101,1011},{101,1012},{101,1013},{101,1014},{101,1015},{101,1016},{102,1021},{102,1022},{102,1023},{102,1024},{102,1025},{102,1026}];
get([52,50000]) ->
     [{20,301}];
get([52,5000]) ->
     [{20,302}];
get([52,1000]) ->
     [{1,4},{20,303}];
get("4È") ->
     [{1,3}];
get("42") ->
     [{1,2}];
get("4\n") ->
     [{1,1}];
get([4,100000]) ->
     [{3,24}];
get([4,20000]) ->
     [{3,23}];
get([4,5000]) ->
     [{3,22}];
get([4,1000]) ->
     [{1,8},{3,21}];
get([4,200]) ->
     [{1,7},{1,9},{3,20}];
get([4,50]) ->
     [{1,6},{3,19}];
get([4,10]) ->
     [{1,5},{3,18}];
get([4,2]) ->
     [{1,10},{1,11}];
get(40241) ->
     [{10,231}];
get(40231) ->
     [{10,221}];
get(10031) ->
     [{10,251}];
get(10021) ->
     [{10,241}];
get(51) ->
     [{10,211}];
get(41) ->
     [{10,201}];
get(_Id) ->
    null.
