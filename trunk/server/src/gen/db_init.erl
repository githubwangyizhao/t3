%%% Generated automatically, no need to modify.
-module(db_init).
-include("gen/db.hrl").
%% API
-export([init/0, init/1]).

init() ->
    ets:new(auto_increment,[set, named_table, public]),
    util_file:ensure_dir("../data/dets/"),
    InitTables = [account,account_charge_white,account_share_data,
                  activity_award,activity_info,boss_one_on_one,brave_one,
                  c_game_server,c_server_node,charge_info_record,
                  charge_ip_white_record,charge_order_request_record,
                  client_versin,consume_statistics,gift_code,gift_code_type,
                  jiangjinchi,laba_adjust,login_notice,match_scene_data,
                  mission_guess_boss,mission_ranking,oauth_order_log,
                  one_vs_one_rank_data,player,player_achievement,
                  player_activity_condition,player_activity_game,
                  player_activity_game_info,player_activity_info,
                  player_activity_task,player_adjust_rebound,
                  player_bounty_task,player_card,player_card_book,
                  player_card_summon,player_card_title,player_charge_activity,
                  player_charge_info_record,player_charge_record,
                  player_charge_shop,player_chat_data,player_client_data,
                  player_condition_activity,player_conditions_data,
                  player_daily_points,player_daily_task,player_data,
                  player_everyday_charge,player_everyday_sign,
                  player_fight_adjust,player_finish_share_task,
                  player_first_charge,player_first_charge_day,player_function,
                  player_game_config,player_game_data,player_gift_code,
                  player_gift_mail,player_gift_mail_log,player_hero,
                  player_hero_parts,player_hero_use,player_invest,
                  player_invest_type,player_invite_friend,
                  player_invite_friend_log,player_jiangjinchi,
                  player_laba_data,player_leichong,player_mail,
                  player_mission_data,player_offline_apply,
                  player_online_award,player_online_info,player_passive_skill,
                  player_platform_award,player_prerogative_card,player_prop,
                  player_send_gamebar_msg,player_server_data,
                  player_seven_login,player_share,player_share_friend,
                  player_share_task,player_share_task_award,player_shen_long,
                  player_shop,player_special_prop,player_sys_attr,
                  player_sys_common,player_task,player_task_share_award,
                  player_times_data,player_title,player_vip,player_vip_award,
                  promote,promote_info,promote_record,rank_info,
                  red_packet_condition,robot_player_data,
                  robot_player_scene_cache,scene_adjust,scene_boss_adjust,
                  scene_log,server_data,server_fight_adjust,
                  server_game_config,server_player_fight_adjust,server_state,
                  test,timer_data,tongxingzheng_daily_task,
                  tongxingzheng_month_task,unique_id_data,
                  wheel_player_bet_record,wheel_player_bet_record_today,
                  wheel_pool,wheel_result_record,
                  wheel_result_record_accumulate],
    lists:foreach(
        fun(Table) ->
            init(Table)
        end,
        InitTables
    ),
    io:format("~nAll table init success!~n~n"),
    ok.


init(wheel_result_record_accumulate) ->
    io:format("Init table : wheel_result_record_accumulate..............."),
    ets:new(wheel_result_record_accumulate, [set, named_table, public, {keypos, 2}]),
    ets:new(wheel_result_record_accumulate_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_wheel_result_record_accumulate_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(wheel_result_record) ->
    io:format("Init table : wheel_result_record.........................."),
    ets:new(wheel_result_record, [set, named_table, public, {keypos, 2}]),
    ets:new(wheel_result_record_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_wheel_result_record_by_type, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(wheel_pool) ->
    io:format("Init table : wheel_pool..................................."),
    ets:new(wheel_pool, [set, named_table, public, {keypos, 2}]),
    ets:new(wheel_pool_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(wheel_player_bet_record_today) ->
    io:format("Init table : wheel_player_bet_record_today................"),
    ets:new(wheel_player_bet_record_today, [set, named_table, public, {keypos, 2}]),
    ets:new(wheel_player_bet_record_today_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_wheel_player_bet_record_today_by_player, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(wheel_player_bet_record) ->
    io:format("Init table : wheel_player_bet_record......................"),
    ets:new(wheel_player_bet_record, [set, named_table, public, {keypos, 2}]),
    ets:new(wheel_player_bet_record_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_wheel_player_bet_record_by_id, [bag, named_table, public, {keypos, 1}]),
    ets:new(idx_wheel_player_bet_record_by_type_and_player, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(unique_id_data) ->
    io:format("Init table : unique_id_data..............................."),
    ets:new(unique_id_data, [set, named_table, public, {keypos, 2}]),
    ets:new(unique_id_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(tongxingzheng_month_task) ->
    io:format("Init table : tongxingzheng_month_task....................."),
    ets:new(tongxingzheng_month_task, [set, named_table, public, {keypos, 2}]),
    ets:new(tongxingzheng_month_task_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(tongxingzheng_daily_task) ->
    io:format("Init table : tongxingzheng_daily_task....................."),
    ets:new(tongxingzheng_daily_task, [set, named_table, public, {keypos, 2}]),
    ets:new(tongxingzheng_daily_task_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(timer_data) ->
    io:format("Init table : timer_data..................................."),
    ets:new(timer_data, [set, named_table, public, {keypos, 2}]),
    ets:new(timer_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(test) ->
    io:format("Init table : test........................................."),
    ets:new(test, [set, named_table, public, {keypos, 2}]),
    ets:new(test_bin_log, [set, named_table, public, {keypos, 1}]),
    {data, Res2} = mysql:fetch(game_db, <<"SELECT max(id) FROM `test` ">>, infinity),
    [[MaxId]] = lib_mysql:get_rows(Res2),
    case is_integer(MaxId) of
        true ->
            ets:insert(auto_increment,[{test, MaxId}]);
        false ->
            ets:insert(auto_increment,[{test, 0}])
    end,
    io:format(" [ok] \n");

init(server_state) ->
    io:format("Init table : server_state................................."),
    ets:new(server_state, [set, named_table, public, {keypos, 2}]),
    ets:new(server_state_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(server_player_fight_adjust) ->
    io:format("Init table : server_player_fight_adjust..................."),
    ets:new(server_player_fight_adjust, [set, named_table, public, {keypos, 2}]),
    ets:new(server_player_fight_adjust_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(server_game_config) ->
    io:format("Init table : server_game_config..........................."),
    ets:new(server_game_config, [set, named_table, public, {keypos, 2}]),
    ets:new(server_game_config_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(server_fight_adjust) ->
    io:format("Init table : server_fight_adjust.........................."),
    ets:new(server_fight_adjust, [set, named_table, public, {keypos, 2}]),
    ets:new(server_fight_adjust_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(server_data) ->
    io:format("Init table : server_data.................................."),
    ets:new(server_data, [set, named_table, public, {keypos, 2}]),
    ets:new(server_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(scene_log) ->
    io:format("Init table : scene_log...................................."),
    ets:new(scene_log, [set, named_table, public, {keypos, 2}]),
    ets:new(scene_log_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(scene_boss_adjust) ->
    io:format("Init table : scene_boss_adjust............................"),
    ets:new(scene_boss_adjust, [set, named_table, public, {keypos, 2}]),
    ets:new(scene_boss_adjust_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(scene_adjust) ->
    io:format("Init table : scene_adjust................................."),
    ets:new(scene_adjust, [set, named_table, public, {keypos, 2}]),
    ets:new(scene_adjust_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(robot_player_scene_cache) ->
    io:format("Init table : robot_player_scene_cache....................."),
    ets:new(robot_player_scene_cache, [set, named_table, public, {keypos, 2}]),
    ets:new(robot_player_scene_cache_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_robot_player_scene_cache_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(robot_player_data) ->
    io:format("Init table : robot_player_data............................"),
    ets:new(robot_player_data, [set, named_table, public, {keypos, 2}]),
    ets:new(robot_player_data_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_robot_player_data_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(red_packet_condition) ->
    io:format("Init table : red_packet_condition........................."),
    ets:new(red_packet_condition, [set, named_table, public, {keypos, 2}]),
    ets:new(red_packet_condition_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(rank_info) ->
    io:format("Init table : rank_info...................................."),
    ets:new(rank_info, [set, named_table, public, {keypos, 2}]),
    ets:new(rank_info_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_rank_info_1_rank_id, [bag, named_table, public, {keypos, 1}]),
    ets:new(idx_rank_info_2, [bag, named_table, public, {keypos, 1}]),
    ets:new(idx_rank_info_3_old_rank, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(promote_record) ->
    io:format("Init table : promote_record..............................."),
    ets:new(promote_record, [set, named_table, public, {keypos, 2}]),
    ets:new(promote_record_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_promote_record_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(promote_info) ->
    io:format("Init table : promote_info................................."),
    ets:new(promote_info, [set, named_table, public, {keypos, 2}]),
    ets:new(promote_info_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(promote) ->
    io:format("Init table : promote......................................"),
    ets:new(promote, [set, named_table, public, {keypos, 2}]),
    ets:new(promote_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_vip_award) ->
    io:format("Init table : player_vip_award............................."),
    ets:new(player_vip_award, [set, named_table, public, {keypos, 2}]),
    ets:new(player_vip_award_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_vip) ->
    io:format("Init table : player_vip..................................."),
    ets:new(player_vip, [set, named_table, public, {keypos, 2}]),
    ets:new(player_vip_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_title) ->
    io:format("Init table : player_title................................."),
    ets:new(player_title, [set, named_table, public, {keypos, 2}]),
    ets:new(player_title_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_title_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_times_data) ->
    io:format("Init table : player_times_data............................"),
    ets:new(player_times_data, [set, named_table, public, {keypos, 2}]),
    ets:new(player_times_data_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_times_data, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_task_share_award) ->
    io:format("Init table : player_task_share_award......................"),
    ets:new(player_task_share_award, [set, named_table, public, {keypos, 2}]),
    ets:new(player_task_share_award_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_task) ->
    io:format("Init table : player_task.................................."),
    ets:new(player_task, [set, named_table, public, {keypos, 2}]),
    ets:new(player_task_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_sys_common) ->
    io:format("Init table : player_sys_common............................"),
    ets:new(player_sys_common, [set, named_table, public, {keypos, 2}]),
    ets:new(player_sys_common_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_sys_common_by_player, [bag, named_table, public, {keypos, 1}]),
    ets:new(idx_player_sys_common_by_state, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_sys_attr) ->
    io:format("Init table : player_sys_attr.............................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "player_sys_attr"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(player_sys_attr, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(player_sys_attr_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_sys_attr_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_special_prop) ->
    io:format("Init table : player_special_prop.........................."),
    ets:new(player_special_prop, [set, named_table, public, {keypos, 2}]),
    ets:new(player_special_prop_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_special_prop_by_player, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_shop) ->
    io:format("Init table : player_shop.................................."),
    ets:new(player_shop, [set, named_table, public, {keypos, 2}]),
    ets:new(player_shop_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_shen_long) ->
    io:format("Init table : player_shen_long............................."),
    ets:new(player_shen_long, [set, named_table, public, {keypos, 2}]),
    ets:new(player_shen_long_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_share_task_award) ->
    io:format("Init table : player_share_task_award......................"),
    ets:new(player_share_task_award, [set, named_table, public, {keypos, 2}]),
    ets:new(player_share_task_award_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_share_task) ->
    io:format("Init table : player_share_task............................"),
    ets:new(player_share_task, [set, named_table, public, {keypos, 2}]),
    ets:new(player_share_task_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_share_friend) ->
    io:format("Init table : player_share_friend.........................."),
    ets:new(player_share_friend, [set, named_table, public, {keypos, 2}]),
    ets:new(player_share_friend_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_share) ->
    io:format("Init table : player_share................................."),
    ets:new(player_share, [set, named_table, public, {keypos, 2}]),
    ets:new(player_share_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_seven_login) ->
    io:format("Init table : player_seven_login..........................."),
    ets:new(player_seven_login, [set, named_table, public, {keypos, 2}]),
    ets:new(player_seven_login_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_server_data) ->
    io:format("Init table : player_server_data..........................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "player_server_data"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(player_server_data, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(player_server_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_send_gamebar_msg) ->
    io:format("Init table : player_send_gamebar_msg......................"),
    ets:new(player_send_gamebar_msg, [set, named_table, public, {keypos, 2}]),
    ets:new(player_send_gamebar_msg_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_prop) ->
    io:format("Init table : player_prop.................................."),
    ets:new(player_prop, [set, named_table, public, {keypos, 2}]),
    ets:new(player_prop_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_prop_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_prerogative_card) ->
    io:format("Init table : player_prerogative_card......................"),
    ets:new(player_prerogative_card, [set, named_table, public, {keypos, 2}]),
    ets:new(player_prerogative_card_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_prerogative_card_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_platform_award) ->
    io:format("Init table : player_platform_award........................"),
    ets:new(player_platform_award, [set, named_table, public, {keypos, 2}]),
    ets:new(player_platform_award_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_passive_skill) ->
    io:format("Init table : player_passive_skill........................."),
    ets:new(player_passive_skill, [set, named_table, public, {keypos, 2}]),
    ets:new(player_passive_skill_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_passive_skill_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_online_info) ->
    io:format("Init table : player_online_info..........................."),
    ets:new(player_online_info, [set, named_table, public, {keypos, 2}]),
    ets:new(player_online_info_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_online_award) ->
    io:format("Init table : player_online_award.........................."),
    ets:new(player_online_award, [set, named_table, public, {keypos, 2}]),
    ets:new(player_online_award_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_offline_apply) ->
    io:format("Init table : player_offline_apply........................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "player_offline_apply"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(player_offline_apply, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(player_offline_apply_bin_log, [set, named_table, public, {keypos, 1}]),
    {data, Res2} = mysql:fetch(game_db, <<"SELECT max(id) FROM `player_offline_apply` ">>, infinity),
    [[MaxId]] = lib_mysql:get_rows(Res2),
    case is_integer(MaxId) of
        true ->
            ets:insert(auto_increment,[{player_offline_apply, MaxId}]);
        false ->
            ets:insert(auto_increment,[{player_offline_apply, 0}])
    end,
    ets:new(idx_player_offline_apply_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_mission_data) ->
    io:format("Init table : player_mission_data.........................."),
    ets:new(player_mission_data, [set, named_table, public, {keypos, 2}]),
    ets:new(player_mission_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_mail) ->
    io:format("Init table : player_mail.................................."),
    ets:new(player_mail, [set, named_table, public, {keypos, 2}, compressed]),
    ets:new(player_mail_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_mail_1_player_id, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_leichong) ->
    io:format("Init table : player_leichong.............................."),
    ets:new(player_leichong, [set, named_table, public, {keypos, 2}]),
    ets:new(player_leichong_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_laba_data) ->
    io:format("Init table : player_laba_data............................."),
    ets:new(player_laba_data, [set, named_table, public, {keypos, 2}]),
    ets:new(player_laba_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_jiangjinchi) ->
    io:format("Init table : player_jiangjinchi..........................."),
    ets:new(player_jiangjinchi, [set, named_table, public, {keypos, 2}]),
    ets:new(player_jiangjinchi_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_invite_friend_log) ->
    io:format("Init table : player_invite_friend_log....................."),
    ets:new(player_invite_friend_log, [set, named_table, public, {keypos, 2}]),
    ets:new(player_invite_friend_log_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_invite_friend) ->
    io:format("Init table : player_invite_friend........................."),
    ets:new(player_invite_friend, [set, named_table, public, {keypos, 2}]),
    ets:new(player_invite_friend_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_invest_type) ->
    io:format("Init table : player_invest_type..........................."),
    ets:new(player_invest_type, [set, named_table, public, {keypos, 2}]),
    ets:new(player_invest_type_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_invest) ->
    io:format("Init table : player_invest................................"),
    ets:new(player_invest, [set, named_table, public, {keypos, 2}]),
    ets:new(player_invest_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_hero_use) ->
    io:format("Init table : player_hero_use.............................."),
    ets:new(player_hero_use, [set, named_table, public, {keypos, 2}]),
    ets:new(player_hero_use_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_hero_parts) ->
    io:format("Init table : player_hero_parts............................"),
    ets:new(player_hero_parts, [set, named_table, public, {keypos, 2}]),
    ets:new(player_hero_parts_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_hero_parts_by_player, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_hero) ->
    io:format("Init table : player_hero.................................."),
    ets:new(player_hero, [set, named_table, public, {keypos, 2}]),
    ets:new(player_hero_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_hero_by_player, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_gift_mail_log) ->
    io:format("Init table : player_gift_mail_log........................."),
    ets:new(player_gift_mail_log, [set, named_table, public, {keypos, 2}]),
    ets:new(player_gift_mail_log_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_gift_mail) ->
    io:format("Init table : player_gift_mail............................."),
    ets:new(player_gift_mail, [set, named_table, public, {keypos, 2}]),
    ets:new(player_gift_mail_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_gift_mail_by_player, [bag, named_table, public, {keypos, 1}]),
    ets:new(idx_player_gift_mail_by_sender, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_gift_code) ->
    io:format("Init table : player_gift_code............................."),
    ets:new(player_gift_code, [set, named_table, public, {keypos, 2}]),
    ets:new(player_gift_code_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_game_data) ->
    io:format("Init table : player_game_data............................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "player_game_data"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(player_game_data, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(player_game_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_game_config) ->
    io:format("Init table : player_game_config..........................."),
    ets:new(player_game_config, [set, named_table, public, {keypos, 2}]),
    ets:new(player_game_config_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_function) ->
    io:format("Init table : player_function.............................."),
    ets:new(player_function, [set, named_table, public, {keypos, 2}]),
    ets:new(player_function_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_function_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_first_charge_day) ->
    io:format("Init table : player_first_charge_day......................"),
    ets:new(player_first_charge_day, [set, named_table, public, {keypos, 2}]),
    ets:new(player_first_charge_day_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_first_charge) ->
    io:format("Init table : player_first_charge.........................."),
    ets:new(player_first_charge, [set, named_table, public, {keypos, 2}]),
    ets:new(player_first_charge_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_finish_share_task) ->
    io:format("Init table : player_finish_share_task....................."),
    ets:new(player_finish_share_task, [set, named_table, public, {keypos, 2}]),
    ets:new(player_finish_share_task_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_fight_adjust) ->
    io:format("Init table : player_fight_adjust.........................."),
    ets:new(player_fight_adjust, [set, named_table, public, {keypos, 2}]),
    ets:new(player_fight_adjust_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_everyday_sign) ->
    io:format("Init table : player_everyday_sign........................."),
    ets:new(player_everyday_sign, [set, named_table, public, {keypos, 2}]),
    ets:new(player_everyday_sign_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_everyday_charge) ->
    io:format("Init table : player_everyday_charge......................."),
    ets:new(player_everyday_charge, [set, named_table, public, {keypos, 2}]),
    ets:new(player_everyday_charge_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_data) ->
    io:format("Init table : player_data.................................."),
    ets:new(player_data, [set, named_table, public, {keypos, 2}]),
    ets:new(player_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_daily_task) ->
    io:format("Init table : player_daily_task............................"),
    ets:new(player_daily_task, [set, named_table, public, {keypos, 2}]),
    ets:new(player_daily_task_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_daily_task_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_daily_points) ->
    io:format("Init table : player_daily_points.........................."),
    ets:new(player_daily_points, [set, named_table, public, {keypos, 2}]),
    ets:new(player_daily_points_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_daily_points_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_conditions_data) ->
    io:format("Init table : player_conditions_data......................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "player_conditions_data"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(player_conditions_data, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(player_conditions_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_condition_activity) ->
    io:format("Init table : player_condition_activity...................."),
    ets:new(player_condition_activity, [set, named_table, public, {keypos, 2}]),
    ets:new(player_condition_activity_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_client_data) ->
    io:format("Init table : player_client_data..........................."),
    ets:new(player_client_data, [set, named_table, public, {keypos, 2}]),
    ets:new(player_client_data_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_client_data_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_chat_data) ->
    io:format("Init table : player_chat_data............................."),
    ets:new(player_chat_data, [set, named_table, public, {keypos, 2}]),
    ets:new(player_chat_data_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_chat_data_by_player, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_charge_shop) ->
    io:format("Init table : player_charge_shop..........................."),
    ets:new(player_charge_shop, [set, named_table, public, {keypos, 2}]),
    ets:new(player_charge_shop_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_charge_record) ->
    io:format("Init table : player_charge_record........................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "player_charge_record"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(player_charge_record, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(player_charge_record_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_charge_record_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_charge_info_record) ->
    io:format("Init table : player_charge_info_record...................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "player_charge_info_record"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(player_charge_info_record, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(player_charge_info_record_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_charge_activity) ->
    io:format("Init table : player_charge_activity......................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "player_charge_activity"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(player_charge_activity, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(player_charge_activity_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_card_title) ->
    io:format("Init table : player_card_title............................"),
    ets:new(player_card_title, [set, named_table, public, {keypos, 2}]),
    ets:new(player_card_title_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_card_summon) ->
    io:format("Init table : player_card_summon..........................."),
    ets:new(player_card_summon, [set, named_table, public, {keypos, 2}]),
    ets:new(player_card_summon_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_card_book) ->
    io:format("Init table : player_card_book............................."),
    ets:new(player_card_book, [set, named_table, public, {keypos, 2}]),
    ets:new(player_card_book_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_card) ->
    io:format("Init table : player_card.................................."),
    ets:new(player_card, [set, named_table, public, {keypos, 2}]),
    ets:new(player_card_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_bounty_task) ->
    io:format("Init table : player_bounty_task..........................."),
    ets:new(player_bounty_task, [set, named_table, public, {keypos, 2}]),
    ets:new(player_bounty_task_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_bounty_task_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_adjust_rebound) ->
    io:format("Init table : player_adjust_rebound........................"),
    ets:new(player_adjust_rebound, [set, named_table, public, {keypos, 2}]),
    ets:new(player_adjust_rebound_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_activity_task) ->
    io:format("Init table : player_activity_task........................."),
    ets:new(player_activity_task, [set, named_table, public, {keypos, 2}]),
    ets:new(player_activity_task_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_activity_info) ->
    io:format("Init table : player_activity_info........................."),
    ets:new(player_activity_info, [set, named_table, public, {keypos, 2}]),
    ets:new(player_activity_info_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_activity_info_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_activity_game_info) ->
    io:format("Init table : player_activity_game_info...................."),
    ets:new(player_activity_game_info, [set, named_table, public, {keypos, 2}]),
    ets:new(player_activity_game_info_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_activity_game) ->
    io:format("Init table : player_activity_game........................."),
    ets:new(player_activity_game, [set, named_table, public, {keypos, 2}]),
    ets:new(player_activity_game_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_activity_game_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_activity_condition) ->
    io:format("Init table : player_activity_condition...................."),
    ets:new(player_activity_condition, [set, named_table, public, {keypos, 2}]),
    ets:new(player_activity_condition_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player_achievement) ->
    io:format("Init table : player_achievement..........................."),
    ets:new(player_achievement, [set, named_table, public, {keypos, 2}]),
    ets:new(player_achievement_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(player) ->
    io:format("Init table : player......................................."),
    ets:new(player, [set, named_table, public, {keypos, 2}, compressed]),
    ets:new(player_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_player_1, [bag, named_table, public, {keypos, 1}]),
    ets:new(idx_player_2, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(one_vs_one_rank_data) ->
    io:format("Init table : one_vs_one_rank_data........................."),
    ets:new(one_vs_one_rank_data, [set, named_table, public, {keypos, 2}]),
    ets:new(one_vs_one_rank_data_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_one_vs_one_rank_data_by_type, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(oauth_order_log) ->
    io:format("Init table : oauth_order_log.............................."),
    ets:new(oauth_order_log, [set, named_table, public, {keypos, 2}]),
    ets:new(oauth_order_log_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(mission_ranking) ->
    io:format("Init table : mission_ranking.............................."),
    ets:new(mission_ranking, [set, named_table, public, {keypos, 2}]),
    ets:new(mission_ranking_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_mission_ranking_1, [bag, named_table, public, {keypos, 1}]),
    ets:new(idx_mission_ranking_by_rank_id, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(mission_guess_boss) ->
    io:format("Init table : mission_guess_boss..........................."),
    ets:new(mission_guess_boss, [set, named_table, public, {keypos, 2}]),
    ets:new(mission_guess_boss_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(match_scene_data) ->
    io:format("Init table : match_scene_data............................."),
    ets:new(match_scene_data, [set, named_table, public, {keypos, 2}]),
    ets:new(match_scene_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(login_notice) ->
    io:format("Init table : login_notice................................."),
    ets:new(login_notice, [set, named_table, public, {keypos, 2}]),
    ets:new(login_notice_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(laba_adjust) ->
    io:format("Init table : laba_adjust.................................."),
    ets:new(laba_adjust, [set, named_table, public, {keypos, 2}]),
    ets:new(laba_adjust_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(jiangjinchi) ->
    io:format("Init table : jiangjinchi.................................."),
    ets:new(jiangjinchi, [set, named_table, public, {keypos, 2}]),
    ets:new(jiangjinchi_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(gift_code_type) ->
    io:format("Init table : gift_code_type..............................."),
    ets:new(gift_code_type, [set, named_table, public, {keypos, 2}]),
    ets:new(gift_code_type_bin_log, [set, named_table, public, {keypos, 1}]),
    {data, Res2} = mysql:fetch(game_db, <<"SELECT max(type) FROM `gift_code_type` ">>, infinity),
    [[MaxId]] = lib_mysql:get_rows(Res2),
    case is_integer(MaxId) of
        true ->
            ets:insert(auto_increment,[{gift_code_type, MaxId}]);
        false ->
            ets:insert(auto_increment,[{gift_code_type, 0}])
    end,
    ets:new(idx_gift_code_type_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(gift_code) ->
    io:format("Init table : gift_code...................................."),
    ets:new(gift_code, [set, named_table, public, {keypos, 2}]),
    ets:new(gift_code_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(consume_statistics) ->
    io:format("Init table : consume_statistics..........................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "consume_statistics"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(consume_statistics, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(consume_statistics_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(client_versin) ->
    io:format("Init table : client_versin................................"),
    ets:new(client_versin, [set, named_table, public, {keypos, 2}]),
    ets:new(client_versin_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(charge_order_request_record) ->
    io:format("Init table : charge_order_request_record.................."),
    ets:new(charge_order_request_record, [set, named_table, public, {keypos, 2}]),
    ets:new(charge_order_request_record_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(charge_ip_white_record) ->
    io:format("Init table : charge_ip_white_record......................."),
    ets:new(charge_ip_white_record, [set, named_table, public, {keypos, 2}]),
    ets:new(charge_ip_white_record_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(charge_info_record) ->
    io:format("Init table : charge_info_record..........................."),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "charge_info_record"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(charge_info_record, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(charge_info_record_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(c_server_node) ->
    io:format("Init table : c_server_node................................"),
    ets:new(c_server_node, [set, named_table, public, {keypos, 2}]),
    ets:new(c_server_node_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(c_game_server) ->
    io:format("Init table : c_game_server................................"),
    ets:new(c_game_server, [set, named_table, public, {keypos, 2}]),
    ets:new(c_game_server_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(brave_one) ->
    io:format("Init table : brave_one...................................."),
    ets:new(brave_one, [set, named_table, public, {keypos, 2}]),
    ets:new(brave_one_bin_log, [set, named_table, public, {keypos, 1}]),
    ets:new(idx_brave_one_1, [bag, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(boss_one_on_one) ->
    io:format("Init table : boss_one_on_one.............................."),
    ets:new(boss_one_on_one, [set, named_table, public, {keypos, 2}]),
    ets:new(boss_one_on_one_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(activity_info) ->
    io:format("Init table : activity_info................................"),
    ets:new(activity_info, [set, named_table, public, {keypos, 2}]),
    ets:new(activity_info_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(activity_award) ->
    io:format("Init table : activity_award..............................."),
    ets:new(activity_award, [set, named_table, public, {keypos, 2}]),
    ets:new(activity_award_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(account_share_data) ->
    io:format("Init table : account_share_data..........................."),
    ets:new(account_share_data, [set, named_table, public, {keypos, 2}]),
    ets:new(account_share_data_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(account_charge_white) ->
    io:format("Init table : account_charge_white........................."),
    ets:new(account_charge_white, [set, named_table, public, {keypos, 2}]),
    ets:new(account_charge_white_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n");

init(account) ->
    io:format("Init table : account......................................"),
    File = filename:join(["../data/dets/", util:get_node_shot_name() ++ "_" ++ "account"  ++ ".dat"]),
    file:delete(File),
    {ok, _} = dets:open_file(account, [{type, set}, {keypos, 2}, {file, File}]),
    ets:new(account_bin_log, [set, named_table, public, {keypos, 1}]),
    io:format(" [ok] \n").

