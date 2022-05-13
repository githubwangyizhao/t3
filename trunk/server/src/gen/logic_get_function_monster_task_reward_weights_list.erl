%%% Generated automatically, no need to modify.
-module(logic_get_function_monster_task_reward_weights_list).
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
     [].


get(6) ->
     [{1,0,[],546615,517345},{2,0,[[202,5]],50000,50000},{3,0,[[201,5]],50000,50000},{4,0,[[202,5]],14000,14000},{5,0,[[201,5]],12000,12000},{6,0,[[202,5]],12000,12000},{7,0,[[201,5]],12000,12000},{8,0,[[4,100]],150000,150000},{9,0,[[4,200]],90000,100000},{10,0,[[4,500]],40015,50015},{11,0,[[4,1000]],20000,25000},{12,0,[[4,2000]],3310,5410},{13,0,[[4,5000]],60,2020},{14,0,[[4,20000]],0,200},{15,0,[[4,1000000]],0,10}];
get(5) ->
     [{1,0,[],546767,517557},{2,0,[[202,3]],50000,50000},{3,0,[[201,3]],50000,50000},{4,0,[[202,3]],14000,14000},{5,0,[[201,3]],12000,12000},{6,0,[[202,3]],12000,12000},{7,0,[[201,3]],12000,12000},{8,0,[[4,10]],150000,150000},{9,0,[[4,20]],90000,100000},{10,0,[[4,50]],40000,50000},{11,0,[[4,100]],20000,25000},{12,0,[[4,200]],3200,5200},{13,0,[[4,500]],33,2033},{14,0,[[4,2000]],0,200},{15,0,[[4,100000]],0,10}];
get(4) ->
     [{1,0,[],547684,518450},{2,0,[[202,2]],50000,50000},{3,0,[[201,2]],50000,50000},{4,0,[[202,2]],14000,14000},{5,0,[[201,2]],12000,12000},{6,0,[[202,2]],12000,12000},{7,0,[[201,2]],12000,12000},{8,0,[[2,50000]],150000,150000},{9,0,[[2,100000]],90000,100000},{10,0,[[2,250000]],40000,50000},{11,0,[[2,500000]],20000,25000},{12,0,[[2,1000000]],2300,4340},{13,0,[[2,2500000]],16,2000},{14,0,[[2,10000000]],0,200},{15,0,[[2,500000000]],0,10}];
get(3) ->
     [{1,0,[],616000,579290},{2,0,[[202,1]],50000,50000},{3,0,[[201,1]],50000,50000},{4,0,[[202,1]],14000,14000},{5,0,[[201,1]],12000,12000},{6,0,[[202,1]],12000,12000},{7,0,[[201,1]],12000,12000},{8,0,[[2,5000]],100000,100000},{9,0,[[2,10000]],72000,94500},{10,0,[[2,25000]],40000,45000},{11,0,[[2,50000]],20000,25000},{12,0,[[2,100000]],2000,4000},{13,0,[[2,250000]],0,2000},{14,0,[[2,1000000]],0,200},{15,0,[[2,50000000]],0,10}];
get(2) ->
     [{1,0,[],863295,863295},{2,0,[[202,1]],30000,30000},{3,0,[[201,1]],30000,30000},{4,0,[[2,5000]],70000,70000},{5,0,[[2,10000]],5000,5000},{6,0,[[2,25000]],1600,1600},{7,0,[[2,100000]],100,100},{8,0,[[2,5000000]],5,5}];
get(1) ->
     [{1,0,[],863295,863295},{2,0,[[202,1]],30000,30000},{3,0,[[201,1]],30000,30000},{4,0,[[2,500]],70000,70000},{5,0,[[2,1000]],5000,5000},{6,0,[[2,2500]],1600,1600},{7,0,[[2,10000]],100,100},{8,0,[[2,500000]],5,5}];
get(_Id) ->
    null.
