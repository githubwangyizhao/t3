%%% Generated automatically, no need to modify.
-module(t_monster_function_task_rand_list).
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
     [{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{1,7},{1,8},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{2,7},{2,8},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{3,7},{3,8},{3,9},{3,10},{3,11},{3,12},{3,13},{3,14},{3,15},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{4,7},{4,8},{4,9},{4,10},{4,11},{4,12},{4,13},{4,14},{4,15},{5,1},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{5,8},{5,9},{5,10},{5,11},{5,12},{5,13},{5,14},{5,15},{6,1},{6,2},{6,3},{6,4},{6,5},{6,6},{6,7},{6,8},{6,9},{6,10},{6,11},{6,12},{6,13},{6,14},{6,15}].


get({1,1}) ->
     {t_monster_function_task_rand_list,{1,1},1,1,0,[],[863295,863295],0};
get({1,2}) ->
     {t_monster_function_task_rand_list,{1,2},1,2,0,[[202,1]],[30000,30000],0};
get({1,3}) ->
     {t_monster_function_task_rand_list,{1,3},1,3,0,[[201,1]],[30000,30000],0};
get({1,4}) ->
     {t_monster_function_task_rand_list,{1,4},1,4,0,[[2,500]],[70000,70000],0};
get({1,5}) ->
     {t_monster_function_task_rand_list,{1,5},1,5,0,[[2,1000]],[5000,5000],0};
get({1,6}) ->
     {t_monster_function_task_rand_list,{1,6},1,6,0,[[2,2500]],[1600,1600],0};
get({1,7}) ->
     {t_monster_function_task_rand_list,{1,7},1,7,0,[[2,10000]],[100,100],0};
get({1,8}) ->
     {t_monster_function_task_rand_list,{1,8},1,8,0,[[2,500000]],[5,5],0};
get({2,1}) ->
     {t_monster_function_task_rand_list,{2,1},2,1,0,[],[863295,863295],0};
get({2,2}) ->
     {t_monster_function_task_rand_list,{2,2},2,2,0,[[202,1]],[30000,30000],0};
get({2,3}) ->
     {t_monster_function_task_rand_list,{2,3},2,3,0,[[201,1]],[30000,30000],0};
get({2,4}) ->
     {t_monster_function_task_rand_list,{2,4},2,4,0,[[2,5000]],[70000,70000],0};
get({2,5}) ->
     {t_monster_function_task_rand_list,{2,5},2,5,0,[[2,10000]],[5000,5000],0};
get({2,6}) ->
     {t_monster_function_task_rand_list,{2,6},2,6,0,[[2,25000]],[1600,1600],0};
get({2,7}) ->
     {t_monster_function_task_rand_list,{2,7},2,7,0,[[2,100000]],[100,100],0};
get({2,8}) ->
     {t_monster_function_task_rand_list,{2,8},2,8,0,[[2,5000000]],[5,5],0};
get({3,1}) ->
     {t_monster_function_task_rand_list,{3,1},3,1,0,[],[616000,579290],0};
get({3,2}) ->
     {t_monster_function_task_rand_list,{3,2},3,2,0,[[202,1]],[50000,50000],0};
get({3,3}) ->
     {t_monster_function_task_rand_list,{3,3},3,3,0,[[201,1]],[50000,50000],0};
get({3,4}) ->
     {t_monster_function_task_rand_list,{3,4},3,4,0,[[202,1]],[14000,14000],0};
get({3,5}) ->
     {t_monster_function_task_rand_list,{3,5},3,5,0,[[201,1]],[12000,12000],0};
get({3,6}) ->
     {t_monster_function_task_rand_list,{3,6},3,6,0,[[202,1]],[12000,12000],0};
get({3,7}) ->
     {t_monster_function_task_rand_list,{3,7},3,7,0,[[201,1]],[12000,12000],0};
get({3,8}) ->
     {t_monster_function_task_rand_list,{3,8},3,8,0,[[2,5000]],[100000,100000],0};
get({3,9}) ->
     {t_monster_function_task_rand_list,{3,9},3,9,0,[[2,10000]],[72000,94500],0};
get({3,10}) ->
     {t_monster_function_task_rand_list,{3,10},3,10,0,[[2,25000]],[40000,45000],0};
get({3,11}) ->
     {t_monster_function_task_rand_list,{3,11},3,11,0,[[2,50000]],[20000,25000],0};
get({3,12}) ->
     {t_monster_function_task_rand_list,{3,12},3,12,0,[[2,100000]],[2000,4000],0};
get({3,13}) ->
     {t_monster_function_task_rand_list,{3,13},3,13,0,[[2,250000]],[0,2000],0};
get({3,14}) ->
     {t_monster_function_task_rand_list,{3,14},3,14,0,[[2,1000000]],[0,200],0};
get({3,15}) ->
     {t_monster_function_task_rand_list,{3,15},3,15,0,[[2,50000000]],[0,10],0};
get({4,1}) ->
     {t_monster_function_task_rand_list,{4,1},4,1,0,[],[547684,518450],0};
get({4,2}) ->
     {t_monster_function_task_rand_list,{4,2},4,2,0,[[202,2]],[50000,50000],0};
get({4,3}) ->
     {t_monster_function_task_rand_list,{4,3},4,3,0,[[201,2]],[50000,50000],0};
get({4,4}) ->
     {t_monster_function_task_rand_list,{4,4},4,4,0,[[202,2]],[14000,14000],0};
get({4,5}) ->
     {t_monster_function_task_rand_list,{4,5},4,5,0,[[201,2]],[12000,12000],0};
get({4,6}) ->
     {t_monster_function_task_rand_list,{4,6},4,6,0,[[202,2]],[12000,12000],0};
get({4,7}) ->
     {t_monster_function_task_rand_list,{4,7},4,7,0,[[201,2]],[12000,12000],0};
get({4,8}) ->
     {t_monster_function_task_rand_list,{4,8},4,8,0,[[2,50000]],[150000,150000],0};
get({4,9}) ->
     {t_monster_function_task_rand_list,{4,9},4,9,0,[[2,100000]],[90000,100000],0};
get({4,10}) ->
     {t_monster_function_task_rand_list,{4,10},4,10,0,[[2,250000]],[40000,50000],0};
get({4,11}) ->
     {t_monster_function_task_rand_list,{4,11},4,11,0,[[2,500000]],[20000,25000],0};
get({4,12}) ->
     {t_monster_function_task_rand_list,{4,12},4,12,0,[[2,1000000]],[2300,4340],0};
get({4,13}) ->
     {t_monster_function_task_rand_list,{4,13},4,13,0,[[2,2500000]],[16,2000],0};
get({4,14}) ->
     {t_monster_function_task_rand_list,{4,14},4,14,0,[[2,10000000]],[0,200],0};
get({4,15}) ->
     {t_monster_function_task_rand_list,{4,15},4,15,0,[[2,500000000]],[0,10],0};
get({5,1}) ->
     {t_monster_function_task_rand_list,{5,1},5,1,0,[],[546767,517557],0};
get({5,2}) ->
     {t_monster_function_task_rand_list,{5,2},5,2,0,[[202,3]],[50000,50000],0};
get({5,3}) ->
     {t_monster_function_task_rand_list,{5,3},5,3,0,[[201,3]],[50000,50000],0};
get({5,4}) ->
     {t_monster_function_task_rand_list,{5,4},5,4,0,[[202,3]],[14000,14000],0};
get({5,5}) ->
     {t_monster_function_task_rand_list,{5,5},5,5,0,[[201,3]],[12000,12000],0};
get({5,6}) ->
     {t_monster_function_task_rand_list,{5,6},5,6,0,[[202,3]],[12000,12000],0};
get({5,7}) ->
     {t_monster_function_task_rand_list,{5,7},5,7,0,[[201,3]],[12000,12000],0};
get({5,8}) ->
     {t_monster_function_task_rand_list,{5,8},5,8,0,[[4,10]],[150000,150000],0};
get({5,9}) ->
     {t_monster_function_task_rand_list,{5,9},5,9,0,[[4,20]],[90000,100000],0};
get({5,10}) ->
     {t_monster_function_task_rand_list,{5,10},5,10,0,[[4,50]],[40000,50000],0};
get({5,11}) ->
     {t_monster_function_task_rand_list,{5,11},5,11,0,[[4,100]],[20000,25000],0};
get({5,12}) ->
     {t_monster_function_task_rand_list,{5,12},5,12,0,[[4,200]],[3200,5200],0};
get({5,13}) ->
     {t_monster_function_task_rand_list,{5,13},5,13,0,[[4,500]],[33,2033],0};
get({5,14}) ->
     {t_monster_function_task_rand_list,{5,14},5,14,0,[[4,2000]],[0,200],0};
get({5,15}) ->
     {t_monster_function_task_rand_list,{5,15},5,15,0,[[4,100000]],[0,10],0};
get({6,1}) ->
     {t_monster_function_task_rand_list,{6,1},6,1,0,[],[546615,517345],0};
get({6,2}) ->
     {t_monster_function_task_rand_list,{6,2},6,2,0,[[202,5]],[50000,50000],0};
get({6,3}) ->
     {t_monster_function_task_rand_list,{6,3},6,3,0,[[201,5]],[50000,50000],0};
get({6,4}) ->
     {t_monster_function_task_rand_list,{6,4},6,4,0,[[202,5]],[14000,14000],0};
get({6,5}) ->
     {t_monster_function_task_rand_list,{6,5},6,5,0,[[201,5]],[12000,12000],0};
get({6,6}) ->
     {t_monster_function_task_rand_list,{6,6},6,6,0,[[202,5]],[12000,12000],0};
get({6,7}) ->
     {t_monster_function_task_rand_list,{6,7},6,7,0,[[201,5]],[12000,12000],0};
get({6,8}) ->
     {t_monster_function_task_rand_list,{6,8},6,8,0,[[4,100]],[150000,150000],0};
get({6,9}) ->
     {t_monster_function_task_rand_list,{6,9},6,9,0,[[4,200]],[90000,100000],0};
get({6,10}) ->
     {t_monster_function_task_rand_list,{6,10},6,10,0,[[4,500]],[40015,50015],0};
get({6,11}) ->
     {t_monster_function_task_rand_list,{6,11},6,11,0,[[4,1000]],[20000,25000],0};
get({6,12}) ->
     {t_monster_function_task_rand_list,{6,12},6,12,0,[[4,2000]],[3310,5410],0};
get({6,13}) ->
     {t_monster_function_task_rand_list,{6,13},6,13,0,[[4,5000]],[60,2020],0};
get({6,14}) ->
     {t_monster_function_task_rand_list,{6,14},6,14,0,[[4,20000]],[0,200],0};
get({6,15}) ->
     {t_monster_function_task_rand_list,{6,15},6,15,0,[[4,1000000]],[0,10],0};
get(_Id) ->
    null.
