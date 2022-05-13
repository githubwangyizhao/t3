%%% Generated automatically, no need to modify.
-module(t_online_award).
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
     [{1},{2},{3},{4},{5},{6}].


get({1}) ->
     {t_online_award,{1},1,[[2,50000]],120};
get({2}) ->
     {t_online_award,{2},2,[[2,50000],[10001,50]],300};
get({3}) ->
     {t_online_award,{3},3,[[2,50000],[10201,10]],600};
get({4}) ->
     {t_online_award,{4},4,[[2,50000],[10101,15]],1200};
get({5}) ->
     {t_online_award,{5},5,[[2,50000],[20501,1],[10272,5]],1800};
get({6}) ->
     {t_online_award,{6},6,[[2,100000],[40001,1],[2,100]],3600};
get(_Id) ->
    null.
