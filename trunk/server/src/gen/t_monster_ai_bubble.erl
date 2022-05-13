%%% Generated automatically, no need to modify.
-module(t_monster_ai_bubble).
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
     {t_monster_ai_bubble,{1},1,0,2,10000,3,4,5000,10000};
get({2}) ->
     {t_monster_ai_bubble,{2},2,0,0,10000,6,5,5000,10000};
get({3}) ->
     {t_monster_ai_bubble,{3},3,0,0,10000,8,7,5000,10000};
get({4}) ->
     {t_monster_ai_bubble,{4},4,0,0,10000,9,10,5000,10000};
get({5}) ->
     {t_monster_ai_bubble,{5},5,0,0,10000,11,12,5000,10000};
get({6}) ->
     {t_monster_ai_bubble,{6},6,0,0,10000,13,14,5000,10000};
get({7}) ->
     {t_monster_ai_bubble,{7},7,0,0,10000,0,15,5000,10000};
get(_Id) ->
    null.
