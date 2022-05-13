%%% Generated automatically, no need to modify.
-module(t_monster_function_shenlongzhufu).
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
     [{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{5,1},{5,2},{5,3},{5,4},{5,5},{5,6},{6,1},{6,2},{6,3},{6,4},{6,5},{6,6}].


get({1,1}) ->
     {t_monster_function_shenlongzhufu,{1,1},1,1,[61,1],1,1000,2006};
get({1,2}) ->
     {t_monster_function_shenlongzhufu,{1,2},1,2,[9010,1],0,15,2005};
get({1,3}) ->
     {t_monster_function_shenlongzhufu,{1,3},1,3,[4,1],0,10,2005};
get({1,4}) ->
     {t_monster_function_shenlongzhufu,{1,4},1,4,[2,3000],0,5,0};
get({1,5}) ->
     {t_monster_function_shenlongzhufu,{1,5},1,5,[2,1500],0,17,0};
get({1,6}) ->
     {t_monster_function_shenlongzhufu,{1,6},1,6,[2,1000],0,45,0};
get({2,1}) ->
     {t_monster_function_shenlongzhufu,{2,1},2,1,[61,1],1,1000,2006};
get({2,2}) ->
     {t_monster_function_shenlongzhufu,{2,2},2,2,[9010,1],0,15,2005};
get({2,3}) ->
     {t_monster_function_shenlongzhufu,{2,3},2,3,[4,10],0,10,2005};
get({2,4}) ->
     {t_monster_function_shenlongzhufu,{2,4},2,4,[2,30000],0,5,0};
get({2,5}) ->
     {t_monster_function_shenlongzhufu,{2,5},2,5,[2,15000],0,17,0};
get({2,6}) ->
     {t_monster_function_shenlongzhufu,{2,6},2,6,[2,10000],0,45,0};
get({3,1}) ->
     {t_monster_function_shenlongzhufu,{3,1},3,1,[61,1],1,1000,2006};
get({3,2}) ->
     {t_monster_function_shenlongzhufu,{3,2},3,2,[9010,1],0,15,2005};
get({3,3}) ->
     {t_monster_function_shenlongzhufu,{3,3},3,3,[4,100],0,10,2005};
get({3,4}) ->
     {t_monster_function_shenlongzhufu,{3,4},3,4,[2,300000],0,5,0};
get({3,5}) ->
     {t_monster_function_shenlongzhufu,{3,5},3,5,[2,150000],0,17,0};
get({3,6}) ->
     {t_monster_function_shenlongzhufu,{3,6},3,6,[2,100000],0,45,0};
get({4,1}) ->
     {t_monster_function_shenlongzhufu,{4,1},4,1,[61,1],1,1000,2006};
get({4,2}) ->
     {t_monster_function_shenlongzhufu,{4,2},4,2,[9010,1],0,15,2005};
get({4,3}) ->
     {t_monster_function_shenlongzhufu,{4,3},4,3,[4,1000],0,10,2005};
get({4,4}) ->
     {t_monster_function_shenlongzhufu,{4,4},4,4,[2,3000000],0,5,0};
get({4,5}) ->
     {t_monster_function_shenlongzhufu,{4,5},4,5,[2,1500000],0,17,0};
get({4,6}) ->
     {t_monster_function_shenlongzhufu,{4,6},4,6,[2,1000000],0,45,0};
get({5,1}) ->
     {t_monster_function_shenlongzhufu,{5,1},5,1,[61,1],1,1000,2006};
get({5,2}) ->
     {t_monster_function_shenlongzhufu,{5,2},5,2,[9010,1],0,15,2005};
get({5,3}) ->
     {t_monster_function_shenlongzhufu,{5,3},5,3,[4,2000],0,10,2005};
get({5,4}) ->
     {t_monster_function_shenlongzhufu,{5,4},5,4,[2,6000000],0,5,0};
get({5,5}) ->
     {t_monster_function_shenlongzhufu,{5,5},5,5,[2,3000000],0,17,0};
get({5,6}) ->
     {t_monster_function_shenlongzhufu,{5,6},5,6,[2,2000000],0,45,0};
get({6,1}) ->
     {t_monster_function_shenlongzhufu,{6,1},6,1,[61,1],1,1000,2006};
get({6,2}) ->
     {t_monster_function_shenlongzhufu,{6,2},6,2,[9010,1],0,15,2005};
get({6,3}) ->
     {t_monster_function_shenlongzhufu,{6,3},6,3,[4,100],0,10,0};
get({6,4}) ->
     {t_monster_function_shenlongzhufu,{6,4},6,4,[4,300],0,5,2005};
get({6,5}) ->
     {t_monster_function_shenlongzhufu,{6,5},6,5,[4,150],0,17,0};
get({6,6}) ->
     {t_monster_function_shenlongzhufu,{6,6},6,6,[4,100],0,45,0};
get(_Id) ->
    null.
