%%% Generated automatically, no need to modify.
-module(t_skill_slot).
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
     {t_skill_slot,{1},1,1,[level,1],1};
get({2}) ->
     {t_skill_slot,{2},2,1,[level,1],1};
get({3}) ->
     {t_skill_slot,{3},3,1,[level,1],1};
get({4}) ->
     {t_skill_slot,{4},4,1,[level,1],1};
get({5}) ->
     {t_skill_slot,{5},5,2,[fun_id,112],10};
get({6}) ->
     {t_skill_slot,{6},6,3,[fun_id,120],9};
get(_Id) ->
    null.
