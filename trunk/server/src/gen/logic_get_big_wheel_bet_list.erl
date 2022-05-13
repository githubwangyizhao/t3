%%% Generated automatically, no need to modify.
-module(logic_get_big_wheel_bet_list).
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


get({4,8}) ->
     [{8,50000}];
get({4,7}) ->
     [{7,50000}];
get({4,6}) ->
     [{6,50000}];
get({4,5}) ->
     [{5,50000}];
get({4,4}) ->
     [{4,100000}];
get({4,3}) ->
     [{3,150000}];
get({4,2}) ->
     [{2,300000}];
get({4,1}) ->
     [{1,400000}];
get({3,8}) ->
     [{8,50000}];
get({3,7}) ->
     [{7,50000}];
get({3,6}) ->
     [{6,50000}];
get({3,5}) ->
     [{5,50000}];
get({3,4}) ->
     [{4,100000}];
get({3,3}) ->
     [{3,150000}];
get({3,2}) ->
     [{2,300000}];
get({3,1}) ->
     [{1,400000}];
get({2,10}) ->
     [{10,250000}];
get({2,9}) ->
     [{2,20000},{11,120000}];
get({2,8}) ->
     [{2,20000},{6,80000}];
get({2,7}) ->
     [{2,20000},{7,80000}];
get({2,6}) ->
     [{2,20000},{8,60000}];
get({2,5}) ->
     [{10,510000}];
get({2,4}) ->
     [{1,20000},{3,60000}];
get({2,3}) ->
     [{1,20000},{4,80000}];
get({2,2}) ->
     [{1,20000},{5,80000}];
get({2,1}) ->
     [{1,20000},{9,120000}];
get({1,10}) ->
     [{10,250000}];
get({1,9}) ->
     [{2,20000},{11,120000}];
get({1,8}) ->
     [{2,20000},{6,80000}];
get({1,7}) ->
     [{2,20000},{7,80000}];
get({1,6}) ->
     [{2,20000},{8,60000}];
get({1,5}) ->
     [{10,510000}];
get({1,4}) ->
     [{1,20000},{3,60000}];
get({1,3}) ->
     [{1,20000},{4,80000}];
get({1,2}) ->
     [{1,20000},{5,80000}];
get({1,1}) ->
     [{1,20000},{9,120000}];
get(_Id) ->
    null.
