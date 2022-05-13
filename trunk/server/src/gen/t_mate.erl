%%% Generated automatically, no need to modify.
-module(t_mate).
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
     [{1},{2},{3}].


get({1}) ->
     {t_mate,{1},1,[52,1000],[[1,50001],[2,50002],[3,0],[4,0],[5,0]],210000,6000,100000,100000,54,5001,52,3200,320};
get({2}) ->
     {t_mate,{2},2,[52,5000],[[1,50005],[2,50006],[3,0],[4,0],[5,0]],210000,6000,100000,1000000,54,5002,52,16000,1600};
get({3}) ->
     {t_mate,{3},3,[52,20000],[[1,50009],[2,50010],[3,0],[4,0],[5,0]],210000,6000,100000,10000000,54,5003,52,64000,6400};
get(_Id) ->
    null.
