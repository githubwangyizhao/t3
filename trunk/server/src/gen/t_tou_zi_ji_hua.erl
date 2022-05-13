%%% Generated automatically, no need to modify.
-module(t_tou_zi_ji_hua).
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
     [{1,1},{1,2},{1,3},{1,4},{1,5}].


get({1,1}) ->
     {t_tou_zi_ji_hua,{1,1},1,1,1,[login_day,1],[[4,500],[2,1000000],[201,100]]};
get({1,2}) ->
     {t_tou_zi_ji_hua,{1,2},1,2,1,[login_day,2],[[905,1],[4,500],[2,1000000],[202,100]]};
get({1,3}) ->
     {t_tou_zi_ji_hua,{1,3},1,3,1,[login_day,3],[[4,500],[2,1000000],[201,100]]};
get({1,4}) ->
     {t_tou_zi_ji_hua,{1,4},1,4,1,[login_day,4],[[4,500],[2,1000000],[202,100]]};
get({1,5}) ->
     {t_tou_zi_ji_hua,{1,5},1,5,1,[login_day,5],[[6208,1],[4,500],[2,1000000],[201,100]]};
get(_Id) ->
    null.
