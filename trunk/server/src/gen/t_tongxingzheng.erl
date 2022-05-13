%%% Generated automatically, no need to modify.
-module(t_tongxingzheng).
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
     {t_tongxingzheng,{1},1,[4,800],[4,1000],20,[4,20],[[2022,1,1],[2022,1,31]],500,1,[2,20000]};
get({2}) ->
     {t_tongxingzheng,{2},2,[4,800],[4,1000],20,[4,20],[[2021,12,1],[2021,12,31]],500,2,[2,20000]};
get(_Id) ->
    null.
