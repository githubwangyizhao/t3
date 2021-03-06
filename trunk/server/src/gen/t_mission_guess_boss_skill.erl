%%% Generated automatically, no need to modify.
-module(t_mission_guess_boss_skill).
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
     [{1},{4},{10001},{10002},{10003},{10004},{10005},{10006},{20001},{20002},{20003},{20004},{20005},{20006}].


get({1}) ->
     {t_mission_guess_boss_skill,{1},1,[232,139,177,233,155,132],1,200,100,600,0,1,1,200,1,50,100,[25,75],[75,225],2000,1000};
get({4}) ->
     {t_mission_guess_boss_skill,{4},4,[232,139,177,233,155,132],2,2600,2000,600,200,2,1,600,1,3000,6000,[1500,4500],[4500,13500],2000,1000};
get({10001}) ->
     {t_mission_guess_boss_skill,{10001},10001,[231,129,171],1,1200,600,200,0,1,1,200,1,120,240,[60,180],[180,540],2000,1000};
get({10002}) ->
     {t_mission_guess_boss_skill,{10002},10002,[229,134,176],1,1400,600,200,0,1,1,200,1,140,280,[70,210],[210,630],2000,1000};
get({10003}) ->
     {t_mission_guess_boss_skill,{10003},10003,[233,155,183],1,1200,600,200,0,1,1,200,1,120,240,[60,180],[180,540],2000,1000};
get({10004}) ->
     {t_mission_guess_boss_skill,{10004},10004,[230,175,146],1,1400,600,200,0,1,1,200,1,140,280,[70,210],[210,630],2000,1000};
get({10005}) ->
     {t_mission_guess_boss_skill,{10005},10005,[230,154,151],1,1200,600,200,0,1,1,200,1,120,240,[60,180],[180,540],2000,1000};
get({10006}) ->
     {t_mission_guess_boss_skill,{10006},10006,[229,133,137],1,1400,600,200,0,1,1,200,1,140,280,[70,210],[210,630],2000,1000};
get({20001}) ->
     {t_mission_guess_boss_skill,{20001},20001,[231,129,171],2,2600,2000,200,200,2,1,200,1,3100,6200,[1550,4650],[4650,13950],2000,1000};
get({20002}) ->
     {t_mission_guess_boss_skill,{20002},20002,[229,134,176],2,1600,1000,200,200,2,1,200,1,3000,6000,[1500,4500],[4500,13500],2000,1000};
get({20003}) ->
     {t_mission_guess_boss_skill,{20003},20003,[233,155,183],2,2600,2000,200,200,2,1,200,1,3100,6200,[1550,4650],[4650,13950],2000,1000};
get({20004}) ->
     {t_mission_guess_boss_skill,{20004},20004,[230,175,146],2,1600,2000,200,200,2,2,200,1,3000,6000,[1500,4500],[4500,13500],2000,1000};
get({20005}) ->
     {t_mission_guess_boss_skill,{20005},20005,[230,154,151],2,2600,2000,200,200,2,1,200,1,3100,6200,[1550,4650],[4650,13950],2000,1000};
get({20006}) ->
     {t_mission_guess_boss_skill,{20006},20006,[229,133,137],2,1600,2000,200,200,2,1,200,1,3000,6000,[1500,4500],[4500,13500],2000,1000};
get(_Id) ->
    null.
