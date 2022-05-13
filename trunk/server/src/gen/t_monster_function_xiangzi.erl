%%% Generated automatically, no need to modify.
-module(t_monster_function_xiangzi).
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
     [{1,1},{1,2},{1,3},{1,4},{1,5},{1,6},{1,7},{2,1},{2,2},{2,3},{2,4},{2,5},{2,6},{2,7},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6},{3,7},{4,1},{4,2},{4,3},{4,4},{4,5},{4,6},{4,7},{5,1},{5,2},{5,3},{5,4},{5,5},{5,6},{5,7},{6,1},{6,2},{6,3},{6,4},{6,5},{6,6},{6,7},{100,1},{101,1},{102,1},{103,1},{104,1},{105,1},{106,1},{107,1},{200,1},{201,1},{202,1},{203,1},{204,1},{205,1},{206,1},{207,1},{208,1},{209,1},{210,1},{211,1}].


get({1,1}) ->
     {t_monster_function_xiangzi,{1,1},1,1,0,[],0,[200,200]};
get({1,2}) ->
     {t_monster_function_xiangzi,{1,2},1,2,0,[[202,1]],0,[80,80]};
get({1,3}) ->
     {t_monster_function_xiangzi,{1,3},1,3,0,[[201,1]],0,[80,80]};
get({1,4}) ->
     {t_monster_function_xiangzi,{1,4},1,4,30000,[],0,[220,220]};
get({1,5}) ->
     {t_monster_function_xiangzi,{1,5},1,5,50000,[],0,[180,180]};
get({1,6}) ->
     {t_monster_function_xiangzi,{1,6},1,6,100000,[],0,[60,60]};
get({1,7}) ->
     {t_monster_function_xiangzi,{1,7},1,7,1000000,[],0,[2,2]};
get({2,1}) ->
     {t_monster_function_xiangzi,{2,1},2,1,0,[[]],0,[200,200]};
get({2,2}) ->
     {t_monster_function_xiangzi,{2,2},2,2,0,[[202,1]],0,[80,80]};
get({2,3}) ->
     {t_monster_function_xiangzi,{2,3},2,3,0,[[201,1]],0,[80,80]};
get({2,4}) ->
     {t_monster_function_xiangzi,{2,4},2,4,30000,[],0,[220,220]};
get({2,5}) ->
     {t_monster_function_xiangzi,{2,5},2,5,50000,[],0,[180,180]};
get({2,6}) ->
     {t_monster_function_xiangzi,{2,6},2,6,100000,[],0,[60,60]};
get({2,7}) ->
     {t_monster_function_xiangzi,{2,7},2,7,1000000,[],0,[2,2]};
get({3,1}) ->
     {t_monster_function_xiangzi,{3,1},3,1,0,[[]],0,[200,200]};
get({3,2}) ->
     {t_monster_function_xiangzi,{3,2},3,2,0,[[202,2]],0,[80,80]};
get({3,3}) ->
     {t_monster_function_xiangzi,{3,3},3,3,0,[[201,2]],0,[80,80]};
get({3,4}) ->
     {t_monster_function_xiangzi,{3,4},3,4,30000,[],0,[220,220]};
get({3,5}) ->
     {t_monster_function_xiangzi,{3,5},3,5,50000,[],0,[180,180]};
get({3,6}) ->
     {t_monster_function_xiangzi,{3,6},3,6,100000,[],0,[60,60]};
get({3,7}) ->
     {t_monster_function_xiangzi,{3,7},3,7,1000000,[],0,[2,2]};
get({4,1}) ->
     {t_monster_function_xiangzi,{4,1},4,1,0,[[]],0,[200,200]};
get({4,2}) ->
     {t_monster_function_xiangzi,{4,2},4,2,0,[[202,5]],0,[80,80]};
get({4,3}) ->
     {t_monster_function_xiangzi,{4,3},4,3,0,[[201,5]],0,[80,80]};
get({4,4}) ->
     {t_monster_function_xiangzi,{4,4},4,4,30000,[],0,[220,220]};
get({4,5}) ->
     {t_monster_function_xiangzi,{4,5},4,5,50000,[],0,[180,180]};
get({4,6}) ->
     {t_monster_function_xiangzi,{4,6},4,6,100000,[],0,[60,60]};
get({4,7}) ->
     {t_monster_function_xiangzi,{4,7},4,7,1000000,[],0,[2,2]};
get({5,1}) ->
     {t_monster_function_xiangzi,{5,1},5,1,0,[[]],0,[200,200]};
get({5,2}) ->
     {t_monster_function_xiangzi,{5,2},5,2,0,[[202,5]],0,[80,80]};
get({5,3}) ->
     {t_monster_function_xiangzi,{5,3},5,3,0,[[201,5]],0,[80,80]};
get({5,4}) ->
     {t_monster_function_xiangzi,{5,4},5,4,30000,[],0,[220,220]};
get({5,5}) ->
     {t_monster_function_xiangzi,{5,5},5,5,50000,[],0,[180,180]};
get({5,6}) ->
     {t_monster_function_xiangzi,{5,6},5,6,100000,[],0,[60,60]};
get({5,7}) ->
     {t_monster_function_xiangzi,{5,7},5,7,1000000,[],0,[2,2]};
get({6,1}) ->
     {t_monster_function_xiangzi,{6,1},6,1,0,[[]],0,[200,200]};
get({6,2}) ->
     {t_monster_function_xiangzi,{6,2},6,2,0,[[202,200]],0,[80,80]};
get({6,3}) ->
     {t_monster_function_xiangzi,{6,3},6,3,0,[[201,200]],0,[80,80]};
get({6,4}) ->
     {t_monster_function_xiangzi,{6,4},6,4,30000,[],0,[220,220]};
get({6,5}) ->
     {t_monster_function_xiangzi,{6,5},6,5,50000,[],0,[180,180]};
get({6,6}) ->
     {t_monster_function_xiangzi,{6,6},6,6,100000,[],0,[60,60]};
get({6,7}) ->
     {t_monster_function_xiangzi,{6,7},6,7,1000000,[],0,[2,2]};
get({100,1}) ->
     {t_monster_function_xiangzi,{100,1},100,1,0,[],0,[100,100]};
get({101,1}) ->
     {t_monster_function_xiangzi,{101,1},101,1,5000,[],0,[100,100]};
get({102,1}) ->
     {t_monster_function_xiangzi,{102,1},102,1,10000,[],0,[100,100]};
get({103,1}) ->
     {t_monster_function_xiangzi,{103,1},103,1,30000,[],0,[100,100]};
get({104,1}) ->
     {t_monster_function_xiangzi,{104,1},104,1,40000,[],0,[100,100]};
get({105,1}) ->
     {t_monster_function_xiangzi,{105,1},105,1,50000,[],0,[100,100]};
get({106,1}) ->
     {t_monster_function_xiangzi,{106,1},106,1,100000,[],0,[100,100]};
get({107,1}) ->
     {t_monster_function_xiangzi,{107,1},107,1,1000000,[],0,[100,100]};
get({200,1}) ->
     {t_monster_function_xiangzi,{200,1},200,1,0,[[202,1]],0,[100,100]};
get({201,1}) ->
     {t_monster_function_xiangzi,{201,1},201,1,0,[[202,1]],0,[100,100]};
get({202,1}) ->
     {t_monster_function_xiangzi,{202,1},202,1,0,[[202,2]],0,[100,100]};
get({203,1}) ->
     {t_monster_function_xiangzi,{203,1},203,1,0,[[202,5]],0,[100,100]};
get({204,1}) ->
     {t_monster_function_xiangzi,{204,1},204,1,0,[[202,5]],0,[100,100]};
get({205,1}) ->
     {t_monster_function_xiangzi,{205,1},205,1,0,[[202,200]],0,[100,100]};
get({206,1}) ->
     {t_monster_function_xiangzi,{206,1},206,1,0,[[201,1]],0,[100,100]};
get({207,1}) ->
     {t_monster_function_xiangzi,{207,1},207,1,0,[[201,1]],0,[100,100]};
get({208,1}) ->
     {t_monster_function_xiangzi,{208,1},208,1,0,[[201,2]],0,[100,100]};
get({209,1}) ->
     {t_monster_function_xiangzi,{209,1},209,1,0,[[201,5]],0,[100,100]};
get({210,1}) ->
     {t_monster_function_xiangzi,{210,1},210,1,0,[[201,5]],0,[100,100]};
get({211,1}) ->
     {t_monster_function_xiangzi,{211,1},211,1,0,[[201,200]],0,[100,100]};
get(_Id) ->
    null.
