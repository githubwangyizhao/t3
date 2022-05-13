%%% Generated automatically, no need to modify.
-module(t_monster_function_zhuanpan).
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
     [{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{1,7},{1,8},{1,9},{1,10},{1,11},{1,12},{1,13},{1,14},{1,15},{1,16},{1,17},{1,18},{1,19},{1,20},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{2,7},{2,8},{2,9},{2,10},{2,11},{2,12},{2,13},{2,14},{2,15},{2,16},{2,17},{2,18},{2,19},{2,20},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{3,7},{3,8},{3,9},{3,10},{3,11},{3,12},{3,13},{3,14},{3,15},{3,16},{3,17},{3,18},{3,19},{3,20},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{4,7},{4,8},{4,9},{4,10},{4,11},{4,12},{4,13},{4,14},{4,15},{4,16},{4,17},{4,18},{4,19},{4,20},{5,1},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{5,8},{5,9},{5,10},{5,11},{5,12},{5,13},{5,14},{5,15},{5,16},{5,17},{5,18},{5,19},{5,20},{6,1},{6,2},{6,3},{6,4},{6,5},{6,6},{6,7},{6,8},{6,9},{6,10},{6,11},{6,12},{6,13},{6,14},{6,15},{6,16},{6,17},{6,18},{6,19},{6,20},{7,1},{7,2},{7,3},{7,4},{7,5},{7,6},{7,7},{7,8},{7,9},{7,10},{7,11},{7,12},{7,13},{7,14},{7,15},{7,16},{7,17},{7,18},{7,19},{7,20}].


get({1,1}) ->
     {t_monster_function_zhuanpan,{1,1},1,1,2000000,[],[1200,1200],0};
get({1,2}) ->
     {t_monster_function_zhuanpan,{1,2},1,2,400000,[],[1200,1200],0};
get({1,3}) ->
     {t_monster_function_zhuanpan,{1,3},1,3,500000,[],[960,960],0};
get({1,4}) ->
     {t_monster_function_zhuanpan,{1,4},1,4,300000,[],[720,720],0};
get({1,5}) ->
     {t_monster_function_zhuanpan,{1,5},1,5,1000000,[],[1600,1600],0};
get({1,6}) ->
     {t_monster_function_zhuanpan,{1,6},1,6,600000,[],[1200,1200],0};
get({1,7}) ->
     {t_monster_function_zhuanpan,{1,7},1,7,400000,[],[1200,1200],0};
get({1,8}) ->
     {t_monster_function_zhuanpan,{1,8},1,8,500000,[],[960,960],0};
get({1,9}) ->
     {t_monster_function_zhuanpan,{1,9},1,9,300000,[],[1600,1600],0};
get({1,10}) ->
     {t_monster_function_zhuanpan,{1,10},1,10,800000,[],[1200,1200],0};
get({1,11}) ->
     {t_monster_function_zhuanpan,{1,11},1,11,400000,[],[720,720],0};
get({1,12}) ->
     {t_monster_function_zhuanpan,{1,12},1,12,1000000,[],[1200,1200],0};
get({1,13}) ->
     {t_monster_function_zhuanpan,{1,13},1,13,500000,[],[960,960],0};
get({1,14}) ->
     {t_monster_function_zhuanpan,{1,14},1,14,300000,[],[1600,1600],0};
get({1,15}) ->
     {t_monster_function_zhuanpan,{1,15},1,15,800000,[],[1600,1600],0};
get({1,16}) ->
     {t_monster_function_zhuanpan,{1,16},1,16,600000,[],[1200,1200],0};
get({1,17}) ->
     {t_monster_function_zhuanpan,{1,17},1,17,400000,[],[1200,1200],0};
get({1,18}) ->
     {t_monster_function_zhuanpan,{1,18},1,18,500000,[],[960,960],0};
get({1,19}) ->
     {t_monster_function_zhuanpan,{1,19},1,19,300000,[],[1600,1600],0};
get({1,20}) ->
     {t_monster_function_zhuanpan,{1,20},1,20,600000,[],[3,3],0};
get({2,1}) ->
     {t_monster_function_zhuanpan,{2,1},2,1,0,[2,100000],[0,12],0};
get({2,2}) ->
     {t_monster_function_zhuanpan,{2,2},2,2,0,[2,500],[4500,3600],0};
get({2,3}) ->
     {t_monster_function_zhuanpan,{2,3},2,3,0,[2,1000],[4494,3609],0};
get({2,4}) ->
     {t_monster_function_zhuanpan,{2,4},2,4,0,[2,0],[6600,3600],0};
get({2,5}) ->
     {t_monster_function_zhuanpan,{2,5},2,5,0,[2,20000],[12,72],0};
get({2,6}) ->
     {t_monster_function_zhuanpan,{2,6},2,6,0,[2,2000],[5960,8016],0};
get({2,7}) ->
     {t_monster_function_zhuanpan,{2,7},2,7,0,[2,500],[4500,3600],0};
get({2,8}) ->
     {t_monster_function_zhuanpan,{2,8},2,8,0,[2,1000],[4494,3609],0};
get({2,9}) ->
     {t_monster_function_zhuanpan,{2,9},2,9,0,[2,0],[6600,3600],0};
get({2,10}) ->
     {t_monster_function_zhuanpan,{2,10},2,10,0,[2,5000],[120,936],0};
get({2,11}) ->
     {t_monster_function_zhuanpan,{2,11},2,11,0,[2,500],[4500,3600],0};
get({2,12}) ->
     {t_monster_function_zhuanpan,{2,12},2,12,0,[2,20000],[12,72],0};
get({2,13}) ->
     {t_monster_function_zhuanpan,{2,13},2,13,0,[2,1000],[4494,3609],0};
get({2,14}) ->
     {t_monster_function_zhuanpan,{2,14},2,14,0,[2,0],[6600,3600],0};
get({2,15}) ->
     {t_monster_function_zhuanpan,{2,15},2,15,0,[2,5000],[120,936],0};
get({2,16}) ->
     {t_monster_function_zhuanpan,{2,16},2,16,0,[2,2000],[5960,8016],0};
get({2,17}) ->
     {t_monster_function_zhuanpan,{2,17},2,17,0,[2,500],[4500,3600],0};
get({2,18}) ->
     {t_monster_function_zhuanpan,{2,18},2,18,0,[2,1000],[4494,3609],0};
get({2,19}) ->
     {t_monster_function_zhuanpan,{2,19},2,19,0,[2,0],[6600,3600],0};
get({2,20}) ->
     {t_monster_function_zhuanpan,{2,20},2,20,0,[2,2000],[5960,8016],0};
get({3,1}) ->
     {t_monster_function_zhuanpan,{3,1},3,1,0,[2,1000000],[0,12],0};
get({3,2}) ->
     {t_monster_function_zhuanpan,{3,2},3,2,0,[2,5000],[4500,3600],0};
get({3,3}) ->
     {t_monster_function_zhuanpan,{3,3},3,3,0,[2,10000],[4494,3609],0};
get({3,4}) ->
     {t_monster_function_zhuanpan,{3,4},3,4,0,[2,0],[6600,3600],0};
get({3,5}) ->
     {t_monster_function_zhuanpan,{3,5},3,5,0,[2,200000],[12,72],0};
get({3,6}) ->
     {t_monster_function_zhuanpan,{3,6},3,6,0,[2,20000],[5960,8016],0};
get({3,7}) ->
     {t_monster_function_zhuanpan,{3,7},3,7,0,[2,5000],[4500,3600],0};
get({3,8}) ->
     {t_monster_function_zhuanpan,{3,8},3,8,0,[2,10000],[4494,3609],0};
get({3,9}) ->
     {t_monster_function_zhuanpan,{3,9},3,9,0,[2,0],[6600,3600],0};
get({3,10}) ->
     {t_monster_function_zhuanpan,{3,10},3,10,0,[2,50000],[120,936],0};
get({3,11}) ->
     {t_monster_function_zhuanpan,{3,11},3,11,0,[2,5000],[4500,3600],0};
get({3,12}) ->
     {t_monster_function_zhuanpan,{3,12},3,12,0,[2,200000],[12,72],0};
get({3,13}) ->
     {t_monster_function_zhuanpan,{3,13},3,13,0,[2,10000],[4494,3609],0};
get({3,14}) ->
     {t_monster_function_zhuanpan,{3,14},3,14,0,[2,0],[6600,3600],0};
get({3,15}) ->
     {t_monster_function_zhuanpan,{3,15},3,15,0,[2,50000],[120,936],0};
get({3,16}) ->
     {t_monster_function_zhuanpan,{3,16},3,16,0,[2,20000],[5960,8016],0};
get({3,17}) ->
     {t_monster_function_zhuanpan,{3,17},3,17,0,[2,5000],[4500,3600],0};
get({3,18}) ->
     {t_monster_function_zhuanpan,{3,18},3,18,0,[2,10000],[4494,3609],0};
get({3,19}) ->
     {t_monster_function_zhuanpan,{3,19},3,19,0,[2,0],[6600,3600],0};
get({3,20}) ->
     {t_monster_function_zhuanpan,{3,20},3,20,0,[2,20000],[5960,8016],0};
get({4,1}) ->
     {t_monster_function_zhuanpan,{4,1},4,1,0,[2,10000000],[0,12],0};
get({4,2}) ->
     {t_monster_function_zhuanpan,{4,2},4,2,0,[2,50000],[4500,3600],0};
get({4,3}) ->
     {t_monster_function_zhuanpan,{4,3},4,3,0,[2,100000],[4494,3609],0};
get({4,4}) ->
     {t_monster_function_zhuanpan,{4,4},4,4,0,[2,0],[6600,3600],0};
get({4,5}) ->
     {t_monster_function_zhuanpan,{4,5},4,5,0,[2,2000000],[12,72],0};
get({4,6}) ->
     {t_monster_function_zhuanpan,{4,6},4,6,0,[2,200000],[5960,8016],0};
get({4,7}) ->
     {t_monster_function_zhuanpan,{4,7},4,7,0,[2,50000],[4500,3600],0};
get({4,8}) ->
     {t_monster_function_zhuanpan,{4,8},4,8,0,[2,100000],[4494,3609],0};
get({4,9}) ->
     {t_monster_function_zhuanpan,{4,9},4,9,0,[2,0],[6600,3600],0};
get({4,10}) ->
     {t_monster_function_zhuanpan,{4,10},4,10,0,[2,500000],[120,936],0};
get({4,11}) ->
     {t_monster_function_zhuanpan,{4,11},4,11,0,[2,50000],[4500,3600],0};
get({4,12}) ->
     {t_monster_function_zhuanpan,{4,12},4,12,0,[2,2000000],[12,72],0};
get({4,13}) ->
     {t_monster_function_zhuanpan,{4,13},4,13,0,[2,100000],[4494,3609],0};
get({4,14}) ->
     {t_monster_function_zhuanpan,{4,14},4,14,0,[2,0],[6600,3600],0};
get({4,15}) ->
     {t_monster_function_zhuanpan,{4,15},4,15,0,[2,500000],[120,936],0};
get({4,16}) ->
     {t_monster_function_zhuanpan,{4,16},4,16,0,[2,200000],[5960,8016],0};
get({4,17}) ->
     {t_monster_function_zhuanpan,{4,17},4,17,0,[2,50000],[4500,3600],0};
get({4,18}) ->
     {t_monster_function_zhuanpan,{4,18},4,18,0,[2,100000],[4494,3609],0};
get({4,19}) ->
     {t_monster_function_zhuanpan,{4,19},4,19,0,[2,0],[6600,3600],0};
get({4,20}) ->
     {t_monster_function_zhuanpan,{4,20},4,20,0,[2,200000],[5960,8016],0};
get({5,1}) ->
     {t_monster_function_zhuanpan,{5,1},5,1,0,[2,100000000],[0,12],0};
get({5,2}) ->
     {t_monster_function_zhuanpan,{5,2},5,2,0,[2,500000],[4500,3600],0};
get({5,3}) ->
     {t_monster_function_zhuanpan,{5,3},5,3,0,[2,1000000],[4494,3609],0};
get({5,4}) ->
     {t_monster_function_zhuanpan,{5,4},5,4,0,[2,0],[6600,3600],0};
get({5,5}) ->
     {t_monster_function_zhuanpan,{5,5},5,5,0,[2,20000000],[12,72],0};
get({5,6}) ->
     {t_monster_function_zhuanpan,{5,6},5,6,0,[2,2000000],[5960,8016],0};
get({5,7}) ->
     {t_monster_function_zhuanpan,{5,7},5,7,0,[2,500000],[4500,3600],0};
get({5,8}) ->
     {t_monster_function_zhuanpan,{5,8},5,8,0,[2,1000000],[4494,3609],0};
get({5,9}) ->
     {t_monster_function_zhuanpan,{5,9},5,9,0,[2,0],[6600,3600],0};
get({5,10}) ->
     {t_monster_function_zhuanpan,{5,10},5,10,0,[2,5000000],[120,936],0};
get({5,11}) ->
     {t_monster_function_zhuanpan,{5,11},5,11,0,[2,500000],[4500,3600],0};
get({5,12}) ->
     {t_monster_function_zhuanpan,{5,12},5,12,0,[2,20000000],[12,72],0};
get({5,13}) ->
     {t_monster_function_zhuanpan,{5,13},5,13,0,[2,1000000],[4494,3609],0};
get({5,14}) ->
     {t_monster_function_zhuanpan,{5,14},5,14,0,[2,0],[6600,3600],0};
get({5,15}) ->
     {t_monster_function_zhuanpan,{5,15},5,15,0,[2,5000000],[120,936],0};
get({5,16}) ->
     {t_monster_function_zhuanpan,{5,16},5,16,0,[2,2000000],[5960,8016],0};
get({5,17}) ->
     {t_monster_function_zhuanpan,{5,17},5,17,0,[2,500000],[4500,3600],0};
get({5,18}) ->
     {t_monster_function_zhuanpan,{5,18},5,18,0,[2,1000000],[4494,3609],0};
get({5,19}) ->
     {t_monster_function_zhuanpan,{5,19},5,19,0,[2,0],[6600,3600],0};
get({5,20}) ->
     {t_monster_function_zhuanpan,{5,20},5,20,0,[2,2000000],[5960,8016],0};
get({6,1}) ->
     {t_monster_function_zhuanpan,{6,1},6,1,0,[4,20000],[0,12],0};
get({6,2}) ->
     {t_monster_function_zhuanpan,{6,2},6,2,0,[4,100],[4500,3600],0};
get({6,3}) ->
     {t_monster_function_zhuanpan,{6,3},6,3,0,[4,200],[4494,3609],0};
get({6,4}) ->
     {t_monster_function_zhuanpan,{6,4},6,4,0,[4,0],[6600,3600],0};
get({6,5}) ->
     {t_monster_function_zhuanpan,{6,5},6,5,0,[4,4000],[12,72],0};
get({6,6}) ->
     {t_monster_function_zhuanpan,{6,6},6,6,0,[4,400],[5960,8016],0};
get({6,7}) ->
     {t_monster_function_zhuanpan,{6,7},6,7,0,[4,100],[4500,3600],0};
get({6,8}) ->
     {t_monster_function_zhuanpan,{6,8},6,8,0,[4,200],[4494,3609],0};
get({6,9}) ->
     {t_monster_function_zhuanpan,{6,9},6,9,0,[4,0],[6600,3600],0};
get({6,10}) ->
     {t_monster_function_zhuanpan,{6,10},6,10,0,[4,1000],[120,936],0};
get({6,11}) ->
     {t_monster_function_zhuanpan,{6,11},6,11,0,[4,100],[4500,3600],0};
get({6,12}) ->
     {t_monster_function_zhuanpan,{6,12},6,12,0,[4,4000],[12,72],0};
get({6,13}) ->
     {t_monster_function_zhuanpan,{6,13},6,13,0,[4,200],[4494,3609],0};
get({6,14}) ->
     {t_monster_function_zhuanpan,{6,14},6,14,0,[4,0],[6600,3600],0};
get({6,15}) ->
     {t_monster_function_zhuanpan,{6,15},6,15,0,[4,1000],[120,936],0};
get({6,16}) ->
     {t_monster_function_zhuanpan,{6,16},6,16,0,[4,400],[5960,8016],0};
get({6,17}) ->
     {t_monster_function_zhuanpan,{6,17},6,17,0,[4,100],[4500,3600],0};
get({6,18}) ->
     {t_monster_function_zhuanpan,{6,18},6,18,0,[4,200],[4494,3609],0};
get({6,19}) ->
     {t_monster_function_zhuanpan,{6,19},6,19,0,[4,0],[6600,3600],0};
get({6,20}) ->
     {t_monster_function_zhuanpan,{6,20},6,20,0,[4,400],[5960,8016],0};
get({7,1}) ->
     {t_monster_function_zhuanpan,{7,1},7,1,0,[4,200000],[0,12],0};
get({7,2}) ->
     {t_monster_function_zhuanpan,{7,2},7,2,0,[4,1000],[4500,3600],0};
get({7,3}) ->
     {t_monster_function_zhuanpan,{7,3},7,3,0,[4,2000],[4494,3609],0};
get({7,4}) ->
     {t_monster_function_zhuanpan,{7,4},7,4,0,[4,0],[6600,3600],0};
get({7,5}) ->
     {t_monster_function_zhuanpan,{7,5},7,5,0,[4,40000],[12,72],0};
get({7,6}) ->
     {t_monster_function_zhuanpan,{7,6},7,6,0,[4,4000],[5960,8016],0};
get({7,7}) ->
     {t_monster_function_zhuanpan,{7,7},7,7,0,[4,1000],[4500,3600],0};
get({7,8}) ->
     {t_monster_function_zhuanpan,{7,8},7,8,0,[4,2000],[4494,3609],0};
get({7,9}) ->
     {t_monster_function_zhuanpan,{7,9},7,9,0,[4,0],[6600,3600],0};
get({7,10}) ->
     {t_monster_function_zhuanpan,{7,10},7,10,0,[4,10000],[120,936],0};
get({7,11}) ->
     {t_monster_function_zhuanpan,{7,11},7,11,0,[4,1000],[4500,3600],0};
get({7,12}) ->
     {t_monster_function_zhuanpan,{7,12},7,12,0,[4,40000],[12,72],0};
get({7,13}) ->
     {t_monster_function_zhuanpan,{7,13},7,13,0,[4,2000],[4494,3609],0};
get({7,14}) ->
     {t_monster_function_zhuanpan,{7,14},7,14,0,[4,0],[6600,3600],0};
get({7,15}) ->
     {t_monster_function_zhuanpan,{7,15},7,15,0,[4,10000],[120,936],0};
get({7,16}) ->
     {t_monster_function_zhuanpan,{7,16},7,16,0,[4,4000],[5960,8016],0};
get({7,17}) ->
     {t_monster_function_zhuanpan,{7,17},7,17,0,[4,1000],[4500,3600],0};
get({7,18}) ->
     {t_monster_function_zhuanpan,{7,18},7,18,0,[4,2000],[4494,3609],0};
get({7,19}) ->
     {t_monster_function_zhuanpan,{7,19},7,19,0,[4,0],[6600,3600],0};
get({7,20}) ->
     {t_monster_function_zhuanpan,{7,20},7,20,0,[4,4000],[5960,8016],0};
get(_Id) ->
    null.
