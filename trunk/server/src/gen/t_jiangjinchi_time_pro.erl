%%% Generated automatically, no need to modify.
-module(t_jiangjinchi_time_pro).
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
     [{1},{2},{3},{4},{5},{6},{7},{8}].


get({1}) ->
     {t_jiangjinchi_time_pro,{1},1,9000,2,0,0};
get({2}) ->
     {t_jiangjinchi_time_pro,{2},2,9000,2,0,0};
get({3}) ->
     {t_jiangjinchi_time_pro,{3},3,9000,2,0,0};
get({4}) ->
     {t_jiangjinchi_time_pro,{4},4,9000,2,0,1};
get({5}) ->
     {t_jiangjinchi_time_pro,{5},5,9000,2,0,1};
get({6}) ->
     {t_jiangjinchi_time_pro,{6},6,9000,2,0,1};
get({7}) ->
     {t_jiangjinchi_time_pro,{7},7,9000,2,0,1};
get({8}) ->
     {t_jiangjinchi_time_pro,{8},8,9000,2,0,1};
get(_Id) ->
    null.
