%%% Generated automatically, no need to modify.
-module(t_treasure_hunt_type).
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
     [{1},{2}].


get({1}) ->
     {t_treasure_hunt_type,{1},1,[[1,4,100],[5,4,500]],[1,200,1],101,[[5,[[2,10000],[201,2],[202,2]]],[15,[[2,20000],[201,3],[202,3]]],[35,[[2,30000],[201,4],[202,4]]],[65,[[2,40000],[201,6],[202,6]]],[125,[[2,50000],[201,8],[202,8]]],[200,[[2,60000],[201,10],[202,10]]]]};
get({2}) ->
     {t_treasure_hunt_type,{2},2,[[1,4,100],[5,4,500]],[1,200,1],101,[[5,[[2,10000],[201,2],[202,2]]],[15,[[2,20000],[201,3],[202,3]]],[35,[[2,30000],[201,4],[202,4]]],[65,[[2,40000],[201,6],[202,6]]],[125,[[2,50000],[201,8],[202,8]]],[200,[[2,60000],[201,10],[202,10]]]]};
get(_Id) ->
    null.
