%%% Generated automatically, no need to modify.
-module(t_monster_function_fanpai).
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
     [{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{1,7},{1,8},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{2,7},{2,8},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{3,7},{3,8},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{4,7},{4,8},{5,1},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{5,8},{6,1},{6,2},{6,3},{6,4},{6,5},{6,6},{6,7},{6,8}].


get({1,1}) ->
     {t_monster_function_fanpai,{1,1},1,1,500000,[],0,[1,1]};
get({1,2}) ->
     {t_monster_function_fanpai,{1,2},1,2,400000,[],0,[4,4]};
get({1,3}) ->
     {t_monster_function_fanpai,{1,3},1,3,300000,[],0,[9,9]};
get({1,4}) ->
     {t_monster_function_fanpai,{1,4},1,4,250000,[],0,[15,15]};
get({1,5}) ->
     {t_monster_function_fanpai,{1,5},1,5,200000,[],0,[15,15]};
get({1,6}) ->
     {t_monster_function_fanpai,{1,6},1,6,150000,[],0,[15,15]};
get({1,7}) ->
     {t_monster_function_fanpai,{1,7},1,7,100000,[],0,[15,15]};
get({1,8}) ->
     {t_monster_function_fanpai,{1,8},1,8,50000,[],0,[15,15]};
get({2,1}) ->
     {t_monster_function_fanpai,{2,1},2,1,500000,[],0,[1,1]};
get({2,2}) ->
     {t_monster_function_fanpai,{2,2},2,2,400000,[],0,[4,4]};
get({2,3}) ->
     {t_monster_function_fanpai,{2,3},2,3,300000,[],0,[9,9]};
get({2,4}) ->
     {t_monster_function_fanpai,{2,4},2,4,250000,[],0,[15,15]};
get({2,5}) ->
     {t_monster_function_fanpai,{2,5},2,5,200000,[],0,[15,15]};
get({2,6}) ->
     {t_monster_function_fanpai,{2,6},2,6,150000,[],0,[15,15]};
get({2,7}) ->
     {t_monster_function_fanpai,{2,7},2,7,100000,[],0,[15,15]};
get({2,8}) ->
     {t_monster_function_fanpai,{2,8},2,8,50000,[],0,[15,15]};
get({3,1}) ->
     {t_monster_function_fanpai,{3,1},3,1,500000,[],0,[1,1]};
get({3,2}) ->
     {t_monster_function_fanpai,{3,2},3,2,400000,[],0,[4,4]};
get({3,3}) ->
     {t_monster_function_fanpai,{3,3},3,3,300000,[],0,[9,9]};
get({3,4}) ->
     {t_monster_function_fanpai,{3,4},3,4,250000,[],0,[15,15]};
get({3,5}) ->
     {t_monster_function_fanpai,{3,5},3,5,200000,[],0,[15,15]};
get({3,6}) ->
     {t_monster_function_fanpai,{3,6},3,6,150000,[],0,[15,15]};
get({3,7}) ->
     {t_monster_function_fanpai,{3,7},3,7,100000,[],0,[15,15]};
get({3,8}) ->
     {t_monster_function_fanpai,{3,8},3,8,50000,[],0,[15,15]};
get({4,1}) ->
     {t_monster_function_fanpai,{4,1},4,1,500000,[],0,[1,1]};
get({4,2}) ->
     {t_monster_function_fanpai,{4,2},4,2,400000,[],0,[4,4]};
get({4,3}) ->
     {t_monster_function_fanpai,{4,3},4,3,300000,[],0,[9,9]};
get({4,4}) ->
     {t_monster_function_fanpai,{4,4},4,4,250000,[],0,[15,15]};
get({4,5}) ->
     {t_monster_function_fanpai,{4,5},4,5,200000,[],0,[15,15]};
get({4,6}) ->
     {t_monster_function_fanpai,{4,6},4,6,150000,[],0,[15,15]};
get({4,7}) ->
     {t_monster_function_fanpai,{4,7},4,7,100000,[],0,[15,15]};
get({4,8}) ->
     {t_monster_function_fanpai,{4,8},4,8,50000,[],0,[15,15]};
get({5,1}) ->
     {t_monster_function_fanpai,{5,1},5,1,500000,[],0,[1,1]};
get({5,2}) ->
     {t_monster_function_fanpai,{5,2},5,2,400000,[],0,[4,4]};
get({5,3}) ->
     {t_monster_function_fanpai,{5,3},5,3,300000,[],0,[9,9]};
get({5,4}) ->
     {t_monster_function_fanpai,{5,4},5,4,250000,[],0,[15,15]};
get({5,5}) ->
     {t_monster_function_fanpai,{5,5},5,5,200000,[],0,[15,15]};
get({5,6}) ->
     {t_monster_function_fanpai,{5,6},5,6,150000,[],0,[15,15]};
get({5,7}) ->
     {t_monster_function_fanpai,{5,7},5,7,100000,[],0,[15,15]};
get({5,8}) ->
     {t_monster_function_fanpai,{5,8},5,8,50000,[],0,[15,15]};
get({6,1}) ->
     {t_monster_function_fanpai,{6,1},6,1,500000,[],0,[1,1]};
get({6,2}) ->
     {t_monster_function_fanpai,{6,2},6,2,400000,[],0,[4,4]};
get({6,3}) ->
     {t_monster_function_fanpai,{6,3},6,3,300000,[],0,[9,9]};
get({6,4}) ->
     {t_monster_function_fanpai,{6,4},6,4,250000,[],0,[15,15]};
get({6,5}) ->
     {t_monster_function_fanpai,{6,5},6,5,200000,[],0,[15,15]};
get({6,6}) ->
     {t_monster_function_fanpai,{6,6},6,6,150000,[],0,[15,15]};
get({6,7}) ->
     {t_monster_function_fanpai,{6,7},6,7,100000,[],0,[15,15]};
get({6,8}) ->
     {t_monster_function_fanpai,{6,8},6,8,50000,[],0,[15,15]};
get(_Id) ->
    null.
