%%% Generated automatically, no need to modify.
-module(t_mission_brave_one).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15}].


get({1}) ->
     {t_mission_brave_one,{1},1,[[2,1000]],[[2,1800]],[vip_level,2],1,1301,1302,1303,30};
get({2}) ->
     {t_mission_brave_one,{2},2,[[2,2000]],[[2,3600]],[vip_level,2],1,1301,1302,1303,30};
get({3}) ->
     {t_mission_brave_one,{3},3,[[2,4000]],[[2,7200]],[vip_level,2],1,1301,1302,1303,30};
get({4}) ->
     {t_mission_brave_one,{4},4,[[2,6000]],[[2,10800]],[vip_level,2],1,1301,1302,1303,30};
get({5}) ->
     {t_mission_brave_one,{5},5,[[2,8000]],[[2,14400]],[vip_level,2],1,1301,1302,1303,30};
get({6}) ->
     {t_mission_brave_one,{6},6,[[2,10000]],[[2,18000]],[vip_level,4],2,1301,1302,1303,30};
get({7}) ->
     {t_mission_brave_one,{7},7,[[2,20000]],[[2,36000]],[vip_level,4],2,1301,1302,1303,30};
get({8}) ->
     {t_mission_brave_one,{8},8,[[2,40000]],[[2,72000]],[vip_level,4],2,1301,1302,1303,30};
get({9}) ->
     {t_mission_brave_one,{9},9,[[2,60000]],[[2,108000]],[vip_level,4],2,1301,1302,1303,30};
get({10}) ->
     {t_mission_brave_one,{10},10,[[2,80000]],[[2,144000]],[vip_level,4],2,1301,1302,1303,30};
get({11}) ->
     {t_mission_brave_one,{11},11,[[2,100000]],[[2,180000]],[vip_level,6],3,1301,1302,1303,30};
get({12}) ->
     {t_mission_brave_one,{12},12,[[2,200000]],[[2,360000]],[vip_level,6],3,1301,1302,1303,30};
get({13}) ->
     {t_mission_brave_one,{13},13,[[2,400000]],[[2,720000]],[vip_level,6],3,1301,1302,1303,30};
get({14}) ->
     {t_mission_brave_one,{14},14,[[2,600000]],[[2,1080000]],[vip_level,6],3,1301,1302,1303,30};
get({15}) ->
     {t_mission_brave_one,{15},15,[[2,800000]],[[2,1440000]],[vip_level,6],3,1301,1302,1303,30};
get(_Id) ->
    null.
