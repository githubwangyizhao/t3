%%% Generated automatically, no need to modify.
-module(logic_get_conditions_daily_task_list).
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


get(freeze_skill_count) ->
     [2];
get(complete_reward_task) ->
     [9];
get(charge_count) ->
     [13];
get(login_day) ->
     [1];
get({kill_effect_count,5}) ->
     [7];
get(speed_skill_count) ->
     [3];
get({kill_effect_count,12}) ->
     [5];
get({kill_effect_count,14}) ->
     [8];
get(kill_get_gold) ->
     [4];
get({kill_effect_count,8}) ->
     [12];
get({kill_effect_count,7}) ->
     [11];
get({kill_effect_count,17}) ->
     [10];
get(share_count) ->
     [14];
get({kill_effect_count,13}) ->
     [6];
get(_Id) ->
    null.
