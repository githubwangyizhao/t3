%%% Generated automatically, no need to modify.
-module(logic_get_condition_txz_daily_task_list).
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


get(attack_count) ->
     [15,16];
get(sticker) ->
     [9];
get(dash_count) ->
     [10];
get(freeze_skill_count) ->
     [13,20];
get(item_shop_buy_count) ->
     [3];
get(change_head_frame) ->
     [7];
get(chat_count) ->
     [8];
get(kill_get_gold) ->
     [4,5];
get(speed_skill_count) ->
     [14,21];
get(kill_monster_count) ->
     [18,11,17,19];
get(change_head) ->
     [6];
get(_Id) ->
    null.
