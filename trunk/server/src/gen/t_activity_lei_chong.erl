%%% Generated automatically, no need to modify.
-module(t_activity_lei_chong).
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
     [{1001,1},{1001,2},{1001,3},{1001,4},{1001,5},{1001,6},{1001,7}].


get({1001,1}) ->
     {t_activity_lei_chong,{1001,1},1001,1,10,[[2,100000],[201,5],[202,5]]};
get({1001,2}) ->
     {t_activity_lei_chong,{1001,2},1001,2,20,[[2,200000],[201,10],[202,10]]};
get({1001,3}) ->
     {t_activity_lei_chong,{1001,3},1001,3,50,[[2,300000],[201,15],[202,15]]};
get({1001,4}) ->
     {t_activity_lei_chong,{1001,4},1001,4,100,[[2,500000],[201,20],[202,20]]};
get({1001,5}) ->
     {t_activity_lei_chong,{1001,5},1001,5,200,[[2,1000000],[201,30],[202,30]]};
get({1001,6}) ->
     {t_activity_lei_chong,{1001,6},1001,6,500,[[2,3000000],[201,40],[202,40]]};
get({1001,7}) ->
     {t_activity_lei_chong,{1001,7},1001,7,1000,[[2,5000000],[201,50],[202,50]]};
get(_Id) ->
    null.
