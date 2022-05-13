%%% Generated automatically, no need to modify.
-module(logic_get_conditions_sign_id).
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


get(cumulative_prop_num) ->
     9999;
get(anger_skill_count) ->
     104;
get(shenlong_count) ->
     103;
get(prop_merge) ->
     102;
get(weapon_replace) ->
     101;
get(attack_shishicai_count) ->
     75;
get(wujinduijue_count) ->
     74;
get(laba_count) ->
     73;
get(complete_reward_task) ->
     72;
get(kill_scene_kind_count) ->
     71;
get(card) ->
     70;
get(attack_kind_count) ->
     69;
get(kill_kind_count) ->
     68;
get(card_title) ->
     67;
get(single_skill_count) ->
     66;
get(use_hero_parts) ->
     65;
get(speed_skill_count) ->
     64;
get(use_hero) ->
     63;
get(jiangjinchi_count) ->
     62;
get(kill_scene_monster_count) ->
     61;
get(dash_count) ->
     60;
get(use_sticker) ->
     59;
get(chat_count) ->
     58;
get(change_head_frame) ->
     57;
get(change_head) ->
     56;
get(auto_skill_count) ->
     55;
get(freeze_skill_count) ->
     54;
get(attack_count) ->
     53;
get(kill_effect_count) ->
     52;
get(hero_star) ->
     50;
get(kill_get_gold) ->
     43;
get(shishi_boss_win) ->
     42;
get(guess_boss_win) ->
     41;
get(sys_common_fun_count) ->
     40;
get(share_count) ->
     39;
get(charge_count) ->
     38;
get(get_gold) ->
     37;
get(mission_type_count) ->
     36;
get(withdrawal_money) ->
     35;
get(activity_turn_layer) ->
     34;
get(activity_turn_score) ->
     33;
get(world_boss_challenge_count) ->
     32;
get(server_day_num) ->
     31;
get(use_item_num) ->
     30;
get(login_day_activity) ->
     29;
get(recharge_money) ->
     28;
get(activity_turn_count) ->
     27;
get(recharge_money_daliy) ->
     25;
get(fun_id) ->
     24;
get(kill_boss_count) ->
     22;
get(kill_monster_count) ->
     21;
get(consumption_of_mana) ->
     20;
get(consumption_of_gold) ->
     19;
get(login_day) ->
     18;
get(item_shop_buy_count) ->
     17;
get(mystery_shop_buy_count) ->
     16;
get(go_scene) ->
     11;
get(mission) ->
     10;
get(dialog) ->
     8;
get(kill) ->
     7;
get(vip_level) ->
     3;
get(task) ->
     2;
get(level) ->
     1;
get(_Id) ->
    null.
