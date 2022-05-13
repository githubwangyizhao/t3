%%% Generated automatically, no need to modify.
-module(logic_get_conditions_id_to_sign).
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


get(9999) ->
     cumulative_prop_num;
get(104) ->
     anger_skill_count;
get(103) ->
     shenlong_count;
get(102) ->
     prop_merge;
get(101) ->
     weapon_replace;
get(75) ->
     attack_shishicai_count;
get(74) ->
     wujinduijue_count;
get(73) ->
     laba_count;
get(72) ->
     complete_reward_task;
get(71) ->
     kill_scene_kind_count;
get(70) ->
     card;
get(69) ->
     attack_kind_count;
get(68) ->
     kill_kind_count;
get(67) ->
     card_title;
get(66) ->
     single_skill_count;
get(65) ->
     use_hero_parts;
get(64) ->
     speed_skill_count;
get(63) ->
     use_hero;
get(62) ->
     jiangjinchi_count;
get(61) ->
     kill_scene_monster_count;
get(60) ->
     dash_count;
get(59) ->
     use_sticker;
get(58) ->
     chat_count;
get(57) ->
     change_head_frame;
get(56) ->
     change_head;
get(55) ->
     auto_skill_count;
get(54) ->
     freeze_skill_count;
get(53) ->
     attack_count;
get(52) ->
     kill_effect_count;
get(50) ->
     hero_star;
get(43) ->
     kill_get_gold;
get(42) ->
     shishi_boss_win;
get(41) ->
     guess_boss_win;
get(40) ->
     sys_common_fun_count;
get(39) ->
     share_count;
get(38) ->
     charge_count;
get(37) ->
     get_gold;
get(36) ->
     mission_type_count;
get(35) ->
     withdrawal_money;
get(34) ->
     activity_turn_layer;
get(33) ->
     activity_turn_score;
get(32) ->
     world_boss_challenge_count;
get(31) ->
     server_day_num;
get(30) ->
     use_item_num;
get(29) ->
     login_day_activity;
get(28) ->
     recharge_money;
get(27) ->
     activity_turn_count;
get(25) ->
     recharge_money_daliy;
get(24) ->
     fun_id;
get(22) ->
     kill_boss_count;
get(21) ->
     kill_monster_count;
get(20) ->
     consumption_of_mana;
get(19) ->
     consumption_of_gold;
get(18) ->
     login_day;
get(17) ->
     item_shop_buy_count;
get(16) ->
     mystery_shop_buy_count;
get(11) ->
     go_scene;
get(10) ->
     mission;
get(8) ->
     dialog;
get(7) ->
     kill;
get(3) ->
     vip_level;
get(2) ->
     task;
get(1) ->
     level;
get(_Id) ->
    null.
