%%% Generated automatically, no need to modify.
-module(t_monster_function_task).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18},{19},{20},{21},{22},{23},{24}].


get({1}) ->
     {t_monster_function_task,{1},1,[kill_monster_count,15],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[0,1],1001,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({2}) ->
     {t_monster_function_task,{2},2,[kill_monster_count,20],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[2],1001,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({3}) ->
     {t_monster_function_task,{3},3,[kill_monster_count,25],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[3],1001,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({4}) ->
     {t_monster_function_task,{4},4,[kill_monster_count,30],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[4,5],1001,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({5}) ->
     {t_monster_function_task,{5},5,[kill_monster_count,15],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[0,1],1002,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({6}) ->
     {t_monster_function_task,{6},6,[kill_monster_count,20],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[2],1002,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({7}) ->
     {t_monster_function_task,{7},7,[kill_monster_count,25],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[3],1002,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({8}) ->
     {t_monster_function_task,{8},8,[kill_monster_count,30],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[4,5],1002,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({9}) ->
     {t_monster_function_task,{9},9,[kill_monster_count,15],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[0,1],1003,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({10}) ->
     {t_monster_function_task,{10},10,[kill_monster_count,20],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[2],1003,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({11}) ->
     {t_monster_function_task,{11},11,[kill_monster_count,25],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[3],1003,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({12}) ->
     {t_monster_function_task,{12},12,[kill_monster_count,30],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[4,5],1003,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({13}) ->
     {t_monster_function_task,{13},13,[kill_monster_count,15],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[0,1],1004,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({14}) ->
     {t_monster_function_task,{14},14,[kill_monster_count,20],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[2],1004,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({15}) ->
     {t_monster_function_task,{15},15,[kill_monster_count,25],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[3],1004,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({16}) ->
     {t_monster_function_task,{16},16,[kill_monster_count,30],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[4,5],1004,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({17}) ->
     {t_monster_function_task,{17},17,[kill_monster_count,15],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[0,1],1005,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({18}) ->
     {t_monster_function_task,{18},18,[kill_monster_count,20],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[2],1005,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({19}) ->
     {t_monster_function_task,{19},19,[kill_monster_count,25],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[3],1005,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({20}) ->
     {t_monster_function_task,{20},20,[kill_monster_count,30],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[4,5],1005,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({21}) ->
     {t_monster_function_task,{21},21,[kill_monster_count,15],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[0,1],1006,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({22}) ->
     {t_monster_function_task,{22},22,[kill_monster_count,20],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[2],1006,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({23}) ->
     {t_monster_function_task,{23},23,[kill_monster_count,25],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[3],1006,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get({24}) ->
     {t_monster_function_task,{24},24,[kill_monster_count,30],[229,135,187,230,157,128,230,128,170,231,137,169],1000,[4,5],1006,1,[[1001,1,2,50],[1002,2,2,500],[1003,3,2,5000],[1004,4,2,50000],[1005,5,4,10],[1006,6,4,100]],0,40000,20000,1};
get(_Id) ->
    null.
