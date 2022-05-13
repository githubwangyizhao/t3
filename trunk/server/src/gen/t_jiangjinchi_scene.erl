%%% Generated automatically, no need to modify.
-module(t_jiangjinchi_scene).
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
     [{1001},{1002},{1003},{1004}].


get({1001}) ->
     {t_jiangjinchi_scene,{1001},1001,1000,2700,1,5,4,[[0,0,3500],[10,10,2500],[10,10,2500],[20,20,1500]]};
get({1002}) ->
     {t_jiangjinchi_scene,{1002},1002,500,27000,4,5,4,[[0,0,3500],[8,12,2500],[5,15,2500],[15,25,1500]]};
get({1003}) ->
     {t_jiangjinchi_scene,{1003},1003,300,270000,24,5,4,[[0,0,3500],[8,12,2500],[5,15,2500],[15,25,1500]]};
get({1004}) ->
     {t_jiangjinchi_scene,{1004},1004,200,2700000,160,5,4,[[0,0,3500],[8,12,2500],[5,15,2500],[15,25,1500]]};
get(_Id) ->
    null.
