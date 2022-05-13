%%% Generated automatically, no need to modify.
-module(t_treasure_hunt).
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
     [{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{1,7},{1,8},{1,9},{1,10},{1,11},{1,12},{1,13},{1,14},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{2,7},{2,8},{2,9},{2,10},{2,11},{2,12},{2,13},{2,14}].


get({1,1}) ->
     {t_treasure_hunt,{1,1},1,1,[[101,1]],20,0};
get({1,2}) ->
     {t_treasure_hunt,{1,2},1,2,[[1008,5]],250,0};
get({1,3}) ->
     {t_treasure_hunt,{1,3},1,3,[[2,50000]],2000,0};
get({1,4}) ->
     {t_treasure_hunt,{1,4},1,4,[[201,5]],2000,0};
get({1,5}) ->
     {t_treasure_hunt,{1,5},1,5,[[4,200]],100,0};
get({1,6}) ->
     {t_treasure_hunt,{1,6},1,6,[[2,200000]],300,0};
get({1,7}) ->
     {t_treasure_hunt,{1,7},1,7,[[1008,10]],250,0};
get({1,8}) ->
     {t_treasure_hunt,{1,8},1,8,[[91,1]],300,0};
get({1,9}) ->
     {t_treasure_hunt,{1,9},1,9,[[4,50]],1000,0};
get({1,10}) ->
     {t_treasure_hunt,{1,10},1,10,[[2,50000]],2000,0};
get({1,11}) ->
     {t_treasure_hunt,{1,11},1,11,[[202,5]],2000,0};
get({1,12}) ->
     {t_treasure_hunt,{1,12},1,12,[[1008,5]],250,0};
get({1,13}) ->
     {t_treasure_hunt,{1,13},1,13,[[90,1]],3000,0};
get({1,14}) ->
     {t_treasure_hunt,{1,14},1,14,[[2,100000]],2000,0};
get({2,1}) ->
     {t_treasure_hunt,{2,1},2,1,[[101,1]],20,0};
get({2,2}) ->
     {t_treasure_hunt,{2,2},2,2,[[1008,5]],250,0};
get({2,3}) ->
     {t_treasure_hunt,{2,3},2,3,[[2,50000]],2000,0};
get({2,4}) ->
     {t_treasure_hunt,{2,4},2,4,[[201,5]],2000,0};
get({2,5}) ->
     {t_treasure_hunt,{2,5},2,5,[[4,200]],100,0};
get({2,6}) ->
     {t_treasure_hunt,{2,6},2,6,[[2,200000]],300,0};
get({2,7}) ->
     {t_treasure_hunt,{2,7},2,7,[[1008,10]],250,0};
get({2,8}) ->
     {t_treasure_hunt,{2,8},2,8,[[91,1]],300,0};
get({2,9}) ->
     {t_treasure_hunt,{2,9},2,9,[[4,50]],1000,0};
get({2,10}) ->
     {t_treasure_hunt,{2,10},2,10,[[2,50000]],2000,0};
get({2,11}) ->
     {t_treasure_hunt,{2,11},2,11,[[202,5]],2000,0};
get({2,12}) ->
     {t_treasure_hunt,{2,12},2,12,[[1008,5]],250,0};
get({2,13}) ->
     {t_treasure_hunt,{2,13},2,13,[[90,1]],3000,0};
get({2,14}) ->
     {t_treasure_hunt,{2,14},2,14,[[2,100000]],2000,0};
get(_Id) ->
    null.
