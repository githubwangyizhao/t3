%%% Generated automatically, no need to modify.
-module(t_turntable).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}].


get({1}) ->
     {t_turntable,{1},1,[[135,1]],20};
get({2}) ->
     {t_turntable,{2},2,[[2,30000]],100};
get({3}) ->
     {t_turntable,{3},3,[[131,1]],60};
get({4}) ->
     {t_turntable,{4},4,[[133,1]],40};
get({5}) ->
     {t_turntable,{5},5,[[2,20000]],200};
get({6}) ->
     {t_turntable,{6},6,[[136,1]],10};
get({7}) ->
     {t_turntable,{7},7,[[2,10000]],500};
get({8}) ->
     {t_turntable,{8},8,[[132,1]],50};
get({9}) ->
     {t_turntable,{9},9,[[134,1]],30};
get({10}) ->
     {t_turntable,{10},10,[[2,5000]],1000};
get(_Id) ->
    null.
