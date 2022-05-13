%%% Generated automatically, no need to modify.
-module(t_seven_login).
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
     [{1},{2},{3},{4},{5},{6},{7}].


get({1}) ->
     {t_seven_login,{1},1,[[201,20]],0};
get({2}) ->
     {t_seven_login,{2},2,[[2,50000]],0};
get({3}) ->
     {t_seven_login,{3},3,[[2,50000]],0};
get({4}) ->
     {t_seven_login,{4},4,[[6003,1]],0};
get({5}) ->
     {t_seven_login,{5},5,[[2,50000]],0};
get({6}) ->
     {t_seven_login,{6},6,[[2,50000]],0};
get({7}) ->
     {t_seven_login,{7},7,[[202,20]],0};
get(_Id) ->
    null.
