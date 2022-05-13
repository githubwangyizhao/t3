%%% Generated automatically, no need to modify.
-module(t_monster_intellect).
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
     {t_monster_intellect,{1},1,500,4000,3500,4000};
get({2}) ->
     {t_monster_intellect,{2},2,1000,3500,3000,3500};
get({3}) ->
     {t_monster_intellect,{3},3,1500,3000,2500,3000};
get({4}) ->
     {t_monster_intellect,{4},4,2000,2500,2000,2500};
get({5}) ->
     {t_monster_intellect,{5},5,2500,2000,1500,2000};
get({6}) ->
     {t_monster_intellect,{6},6,2500,1500,1000,1000};
get(_Id) ->
    null.
