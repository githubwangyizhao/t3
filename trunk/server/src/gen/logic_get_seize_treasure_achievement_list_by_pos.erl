%%% Generated automatically, no need to modify.
-module(logic_get_seize_treasure_achievement_list_by_pos).
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


get({2,0}) ->
     {5,[[2,10000],[201,2],[202,2]]};
get({2,1}) ->
     {15,[[2,20000],[201,3],[202,3]]};
get({2,2}) ->
     {35,[[2,30000],[201,4],[202,4]]};
get({2,3}) ->
     {65,[[2,40000],[201,6],[202,6]]};
get({2,4}) ->
     {125,[[2,50000],[201,8],[202,8]]};
get({2,5}) ->
     {200,[[2,60000],[201,10],[202,10]]};
get({1,0}) ->
     {5,[[2,10000],[201,2],[202,2]]};
get({1,1}) ->
     {15,[[2,20000],[201,3],[202,3]]};
get({1,2}) ->
     {35,[[2,30000],[201,4],[202,4]]};
get({1,3}) ->
     {65,[[2,40000],[201,6],[202,6]]};
get({1,4}) ->
     {125,[[2,50000],[201,8],[202,8]]};
get({1,5}) ->
     {200,[[2,60000],[201,10],[202,10]]};
get(_Id) ->
    null.
