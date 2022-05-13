%%% Generated automatically, no need to modify.
-module(t_mission_many_people_boss).
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
     [{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}].


get({1}) ->
     {t_mission_many_people_boss,{1},1,4,[vip_level,5],500,1,1000,5000,[0,0,0.6],[0,0,0.4]};
get({2}) ->
     {t_mission_many_people_boss,{2},2,4,[vip_level,6],1000,2,2000,5001,[0,0,0.6],[0,0,0.4]};
get({3}) ->
     {t_mission_many_people_boss,{3},3,4,[vip_level,7],1500,3,3000,5002,[0,0,0.6],[0,0,0.4]};
get({4}) ->
     {t_mission_many_people_boss,{4},4,4,[vip_level,8],2000,4,4000,5003,[0,0,0.6],[0,0,0.4]};
get({5}) ->
     {t_mission_many_people_boss,{5},5,4,[vip_level,9],2500,5,5000,5004,[0,0,0.6],[0,0,0.4]};
get({6}) ->
     {t_mission_many_people_boss,{6},6,4,[vip_level,10],3000,6,6000,5005,[0,0,0.6],[0,0,0.4]};
get({7}) ->
     {t_mission_many_people_boss,{7},7,4,[vip_level,11],3500,7,7000,5006,[0,0,0.6],[0,0,0.4]};
get({8}) ->
     {t_mission_many_people_boss,{8},8,4,[vip_level,12],4000,8,8000,5007,[0,0,0.6],[0,0,0.4]};
get({9}) ->
     {t_mission_many_people_boss,{9},9,4,[vip_level,12],4500,9,9000,5008,[0,0,0.6],[0,0,0.4]};
get({10}) ->
     {t_mission_many_people_boss,{10},10,4,[vip_level,12],5000,10,10000,5009,[0,0,0.6],[0,0,0.4]};
get(_Id) ->
    null.
