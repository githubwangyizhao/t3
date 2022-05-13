-module(proto).
-export([encode/1, decode/1]).
-include("p_message.hrl").

-ifdef(debug).
-define(ENCODE_OPTS, [{verify, true}]).
-else.
-define(ENCODE_OPTS, []).
-endif.



encode(#m_login_login_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1, Bin);
encode(#m_login_login_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2, Bin);
encode(#m_login_create_role_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3, Bin);
encode(#m_login_create_role_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4, Bin);
encode(#m_login_enter_game_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5, Bin);
encode(#m_login_heart_beat_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(6, Bin);
encode(#m_login_heart_beat_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(7, Bin);
encode(#m_login_notice_logout_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(8, Bin);
encode(#m_player_init_player_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(101, Bin);
encode(#m_player_notice_player_attr_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(102, Bin);
encode(#m_player_notice_player_string_attr_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(103, Bin);
encode(#m_player_notice_fun_active_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(104, Bin);
encode(#m_player_notice_server_time_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(105, Bin);
encode(#m_player_change_pk_mode_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(106, Bin);
encode(#m_player_change_pk_mode_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(107, Bin);
encode(#m_player_get_player_attr_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(108, Bin);
encode(#m_player_get_player_attr_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(109, Bin);
encode(#m_player_change_name_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(110, Bin);
encode(#m_player_change_name_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(111, Bin);
encode(#m_player_change_sex_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(112, Bin);
encode(#m_player_change_sex_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(113, Bin);
encode(#m_player_update_client_data_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(114, Bin);
encode(#m_player_delete_client_data_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(115, Bin);
encode(#m_player_adjust_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(116, Bin);
encode(#m_player_adjust_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(117, Bin);
encode(#m_player_customer_url_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(118, Bin);
encode(#m_player_customer_url_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(119, Bin);
encode(#m_player_visitor_binding_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(120, Bin);
encode(#m_player_visitor_binding_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(121, Bin);
encode(#m_player_get_server_time_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(122, Bin);
encode(#m_player_get_server_time_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(123, Bin);
encode(#m_player_modify_nickname_gender_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(124, Bin);
encode(#m_player_modify_nickname_gender_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(125, Bin);
encode(#m_player_set_player_data_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(126, Bin);
encode(#m_player_set_player_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(127, Bin);
encode(#m_player_notice_player_xiu_zhen_value_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(128, Bin);
encode(#m_player_collect_delay_rewards_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(129, Bin);
encode(#m_player_level_upgrade_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(130, Bin);
encode(#m_player_level_upgrade_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(131, Bin);
encode(#m_player_bind_mobile_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(132, Bin);
encode(#m_player_bind_mobile_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(133, Bin);
encode(#m_player_bind_res_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(134, Bin);
encode(#m_player_get_level_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(135, Bin);
encode(#m_player_get_level_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(136, Bin);
encode(#m_player_update_player_signature_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(137, Bin);
encode(#m_player_update_player_signature_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(138, Bin);
encode(#m_player_get_player_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(139, Bin);
encode(#m_player_get_player_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(140, Bin);
encode(#m_player_world_tree_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(141, Bin);
encode(#m_player_world_tree_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(142, Bin);
encode(#m_scene_enter_scene_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(201, Bin);
encode(#m_scene_enter_scene_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(202, Bin);
encode(#m_scene_notice_prepare_scene_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(203, Bin);
encode(#m_scene_load_scene_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(204, Bin);
encode(#m_scene_load_scene_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(205, Bin);
encode(#m_scene_sync_scene_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(206, Bin);
encode(#m_scene_notice_scene_player_enter_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(207, Bin);
encode(#m_scene_notice_scene_player_leave_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(208, Bin);
encode(#m_scene_player_rebirth_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(209, Bin);
encode(#m_scene_player_rebirth_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(210, Bin);
encode(#m_scene_player_move_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(211, Bin);
encode(#m_scene_player_move_step_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(212, Bin);
encode(#m_scene_player_stop_move_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(213, Bin);
encode(#m_scene_notice_player_move_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(214, Bin);
encode(#m_scene_notice_player_stop_move_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(215, Bin);
encode(#m_scene_notice_player_teleport_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(216, Bin);
encode(#m_scene_notice_correct_player_pos_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(217, Bin);
encode(#m_scene_notice_monster_enter_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(218, Bin);
encode(#m_scene_notice_monster_leave_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(219, Bin);
encode(#m_scene_notice_monster_move_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(220, Bin);
encode(#m_scene_notice_monster_stop_move_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(221, Bin);
encode(#m_scene_notice_monster_teleport_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(222, Bin);
encode(#m_scene_notice_item_enter_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(223, Bin);
encode(#m_scene_notice_item_leave_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(224, Bin);
encode(#m_scene_notice_scene_item_owner_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(225, Bin);
encode(#m_scene_notice_player_death_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(226, Bin);
encode(#m_scene_query_player_pos_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(227, Bin);
encode(#m_scene_query_player_pos_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(228, Bin);
encode(#m_scene_notice_obj_hp_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(229, Bin);
encode(#m_scene_notice_monster_attr_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(230, Bin);
encode(#m_scene_transmit_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(231, Bin);
encode(#m_scene_notice_prepare_transmit_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(232, Bin);
encode(#m_scene_update_npc_date_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(233, Bin);
encode(#m_scene_notice_simplify_monster_pos_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(234, Bin);
encode(#m_scene_get_monster_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(235, Bin);
encode(#m_scene_notice_monster_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(236, Bin);
encode(#m_scene_notice_anger_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(237, Bin);
encode(#m_scene_notice_special_skill_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(238, Bin);
encode(#m_scene_notice_show_fanpai_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(239, Bin);
encode(#m_scene_notice_fanpai_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(240, Bin);
encode(#m_scene_notice_fanpai_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(241, Bin);
encode(#m_scene_notice_boss_state_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(242, Bin);
encode(#m_scene_challenge_boss_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(243, Bin);
encode(#m_scene_send_msg_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(244, Bin);
encode(#m_scene_notice_send_msg_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(245, Bin);
encode(#m_scene_notice_scene_jbxy_state_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(246, Bin);
encode(#m_scene_player_collect_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(247, Bin);
encode(#m_scene_get_gold_ranking_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(248, Bin);
encode(#m_scene_notice_monster_restore_hp_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(249, Bin);
encode(#m_scene_show_action_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(250, Bin);
encode(#m_scene_show_action_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(251, Bin);
encode(#m_scene_player_kuangbao_info_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(252, Bin);
encode(#m_scene_notice_boss_die_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(253, Bin);
encode(#m_scene_notice_monster_speak_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(254, Bin);
encode(#m_scene_notice_time_stop_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(255, Bin);
encode(#m_scene_notice_init_time_event_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(256, Bin);
encode(#m_scene_notice_add_time_event_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(257, Bin);
encode(#m_scene_notice_time_event_list_sleep_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(258, Bin);
encode(#m_scene_notice_time_event_list_start_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(259, Bin);
encode(#m_scene_notice_rank_event_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(260, Bin);
encode(#m_scene_enter_single_scene_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(261, Bin);
encode(#m_scene_enter_single_scene_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(262, Bin);
encode(#m_fight_fight_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(301, Bin);
encode(#m_fight_notice_fight_fail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(302, Bin);
encode(#m_fight_notice_fight_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(303, Bin);
encode(#m_fight_notice_add_buff_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(304, Bin);
encode(#m_fight_notice_remove_buff_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(305, Bin);
encode(#m_fight_use_item_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(306, Bin);
encode(#m_fight_use_item_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(307, Bin);
encode(#m_fight_notice_bin_dong_skill_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(308, Bin);
encode(#m_fight_notice_get_function_monster_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(309, Bin);
encode(#m_fight_notice_fight_wait_skill_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(310, Bin);
encode(#m_fight_wait_skill_trigger_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(311, Bin);
encode(#m_fight_dizzy_time_reduce_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(312, Bin);
encode(#m_fight_dizzy_time_reduce_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(313, Bin);
encode(#m_fight_notice_add_effect_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(314, Bin);
encode(#m_fight_blind_box_reward_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(315, Bin);
encode(#m_times_add_times_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(401, Bin);
encode(#m_times_add_times_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(402, Bin);
encode(#m_times_notice_times_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(403, Bin);
encode(#m_prop_notice_update_prop_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(501, Bin);
encode(#m_prop_use_item_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(502, Bin);
encode(#m_prop_use_item_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(503, Bin);
encode(#m_prop_sell_item_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(504, Bin);
encode(#m_prop_sell_item_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(505, Bin);
encode(#m_prop_merge_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(506, Bin);
encode(#m_prop_merge_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(507, Bin);
encode(#m_chat_channel_chat_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(601, Bin);
encode(#m_chat_channel_chat_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(602, Bin);
encode(#m_chat_broadcast_channel_msg_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(603, Bin);
encode(#m_chat_broadcast_channel_msg_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(604, Bin);
encode(#m_mission_challenge_mission_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(701, Bin);
encode(#m_mission_challenge_mission_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(702, Bin);
encode(#m_mission_notice_mission_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(703, Bin);
encode(#m_mission_exit_mission_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(704, Bin);
encode(#m_mission_notice_passed_mission_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(705, Bin);
encode(#m_mission_notice_mission_close_time_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(706, Bin);
encode(#m_mission_notice_mission_round_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(707, Bin);
encode(#m_mission_notice_total_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(708, Bin);
encode(#m_mission_notice_mission_ranking_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(709, Bin);
encode(#m_mission_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(710, Bin);
encode(#m_mission_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(711, Bin);
encode(#m_mission_notice_mission_schedule_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(712, Bin);
encode(#m_mission_boss_rebirth_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(713, Bin);
encode(#m_mission_boss_rebirth_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(714, Bin);
encode(#m_mission_notice_shi_shi_settle_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(715, Bin);
encode(#m_mission_notice_shi_shi_time_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(716, Bin);
encode(#m_mission_notice_shi_shi_value_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(717, Bin);
encode(#m_mission_guess_get_record_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(718, Bin);
encode(#m_mission_guess_get_record_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(719, Bin);
encode(#m_mission_notice_guess_boss_cost_my_mana_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(720, Bin);
encode(#m_mission_notice_guess_boss_cost_total_mana_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(721, Bin);
encode(#m_mission_notice_guess_boss_mission_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(722, Bin);
encode(#m_mission_notice_guess_boss_mission_time_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(723, Bin);
encode(#m_mission_either_notice_state_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(724, Bin);
encode(#m_mission_either_either_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(725, Bin);
encode(#m_mission_either_notice_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(726, Bin);
encode(#m_mission_scene_boss_bet_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(727, Bin);
encode(#m_mission_scene_boss_bet_reset_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(728, Bin);
encode(#m_mission_notice_scene_boss_bet_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(729, Bin);
encode(#m_mission_notice_scene_boss_step_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(730, Bin);
encode(#m_mission_notice_scene_boss_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(731, Bin);
encode(#m_mission_notice_scene_boss_dao_num_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(732, Bin);
encode(#m_mission_notice_scene_boss_boss_update_pos_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(733, Bin);
encode(#m_mission_notice_new_guess_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(734, Bin);
encode(#m_mission_lucky_boss_bet_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(735, Bin);
encode(#m_mission_lucky_boss_bet_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(736, Bin);
encode(#m_mission_lucky_boss_bet_reset_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(737, Bin);
encode(#m_mission_lucky_boss_bet_reset_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(738, Bin);
encode(#m_mission_lucky_boss_bet_modification_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(739, Bin);
encode(#m_mission_lucky_boss_bet_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(740, Bin);
encode(#m_mission_lucky_boss_status_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(741, Bin);
encode(#m_mission_lucky_boss_status_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(742, Bin);
encode(#m_mission_notice_lucky_boss_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(743, Bin);
encode(#m_mission_notice_lucky_boss_fight_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(744, Bin);
encode(#m_mission_notice_one_on_one_rate_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(745, Bin);
encode(#m_mission_notice_ready_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(746, Bin);
encode(#m_mission_hero_versus_boss_bet_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(747, Bin);
encode(#m_mission_hero_versus_boss_bet_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(748, Bin);
encode(#m_mission_hero_versus_boss_bet_reset_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(749, Bin);
encode(#m_mission_hero_versus_boss_bet_reset_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(750, Bin);
encode(#m_mission_hero_versus_boss_bet_modification_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(751, Bin);
encode(#m_mission_hero_versus_boss_bet_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(752, Bin);
encode(#m_mission_notice_hero_versus_boss_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(753, Bin);
encode(#m_mission_hero_versus_boss_status_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(754, Bin);
encode(#m_mission_notice_hero_versus_boss_fight_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(755, Bin);
encode(#m_mission_notice_hero_versus_boss_rate_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(756, Bin);
encode(#m_mission_get_hero_versus_boss_record_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(757, Bin);
encode(#m_mission_get_hero_versus_boss_record_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(758, Bin);
encode(#m_mail_get_mail_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(801, Bin);
encode(#m_mail_get_mail_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(802, Bin);
encode(#m_mail_read_mail_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(803, Bin);
encode(#m_mail_read_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(804, Bin);
encode(#m_mail_get_item_mail_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(805, Bin);
encode(#m_mail_get_item_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(806, Bin);
encode(#m_mail_delete_mail_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(807, Bin);
encode(#m_mail_delete_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(808, Bin);
encode(#m_mail_add_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(809, Bin);
encode(#m_mail_remove_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(810, Bin);
encode(#m_vip_get_vip_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(901, Bin);
encode(#m_vip_get_vip_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(902, Bin);
encode(#m_vip_notice_vip_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(903, Bin);
encode(#m_debug_debug_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(10001, Bin);
encode(#m_debug_debug_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(10002, Bin);
encode(#m_client_log_client_log_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1001, Bin);
encode(#m_achievement_get_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1101, Bin);
encode(#m_achievement_get_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1102, Bin);
encode(#m_achievement_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1103, Bin);
encode(#m_achievement_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1104, Bin);
encode(#m_achievement_notice_update_achievement_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1105, Bin);
encode(#m_rank_get_rank_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1201, Bin);
encode(#m_rank_get_rank_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1202, Bin);
encode(#m_shop_get_shop_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1301, Bin);
encode(#m_shop_get_shop_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1302, Bin);
encode(#m_shop_shop_item_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1303, Bin);
encode(#m_shop_shop_item_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1304, Bin);
encode(#m_shop_notice_shop_state_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1305, Bin);
encode(#m_activity_restart_all_activity_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1401, Bin);
encode(#m_activity_update_activity_time_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1402, Bin);
encode(#m_charge_notice_is_open_charge_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1501, Bin);
encode(#m_charge_charge_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1502, Bin);
encode(#m_charge_charge_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1503, Bin);
encode(#m_charge_notice_charge_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1504, Bin);
encode(#m_charge_get_charge_type_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1505, Bin);
encode(#m_charge_get_charge_type_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1506, Bin);
encode(#m_invest_init_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1601, Bin);
encode(#m_invest_get_invest_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1602, Bin);
encode(#m_invest_get_invest_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1603, Bin);
encode(#m_invest_notice_invest_type_data_update_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1604, Bin);
encode(#m_everyday_sign_everyday_sign_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1701, Bin);
encode(#m_everyday_sign_everyday_sign_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1702, Bin);
encode(#m_everyday_sign_notice_day_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1703, Bin);
encode(#m_seven_login_give_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1801, Bin);
encode(#m_seven_login_give_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1802, Bin);
encode(#m_seven_login_update_cumulative_day_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1803, Bin);
encode(#m_platform_function_share_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1901, Bin);
encode(#m_platform_function_share_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1902, Bin);
encode(#m_platform_function_get_share_friend_give_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1903, Bin);
encode(#m_platform_function_get_share_friend_give_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1904, Bin);
encode(#m_platform_function_notice_share_friend_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1905, Bin);
encode(#m_platform_function_notice_share_count_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1906, Bin);
encode(#m_platform_function_notice_platform_vip_level_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1907, Bin);
encode(#m_platform_function_get_platform_award_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1908, Bin);
encode(#m_platform_function_get_platform_award_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1909, Bin);
encode(#m_platform_function_get_share_task_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1910, Bin);
encode(#m_platform_function_get_share_task_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1911, Bin);
encode(#m_platform_function_get_share_task_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1912, Bin);
encode(#m_platform_function_get_share_task_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1913, Bin);
encode(#m_platform_function_notice_share_task_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1914, Bin);
encode(#m_platform_function_refresh_open_key_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1915, Bin);
encode(#m_platform_function_refresh_open_key_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(1916, Bin);
encode(#m_gift_code_gift_code_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2001, Bin);
encode(#m_gift_code_gift_code_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2002, Bin);
encode(#m_video_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2101, Bin);
encode(#m_video_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2102, Bin);
encode(#m_many_people_boss_get_room_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2201, Bin);
encode(#m_many_people_boss_get_room_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2202, Bin);
encode(#m_many_people_boss_join_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2203, Bin);
encode(#m_many_people_boss_join_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2204, Bin);
encode(#m_many_people_boss_create_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2205, Bin);
encode(#m_many_people_boss_create_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2206, Bin);
encode(#m_many_people_boss_start_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2207, Bin);
encode(#m_many_people_boss_start_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2208, Bin);
encode(#m_many_people_boss_participate_in_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2209, Bin);
encode(#m_many_people_boss_participate_in_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2210, Bin);
encode(#m_many_people_boss_kick_out_player_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2211, Bin);
encode(#m_many_people_boss_set_is_all_ready_start_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2212, Bin);
encode(#m_many_people_boss_set_is_all_ready_start_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2213, Bin);
encode(#m_many_people_boss_ready_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2214, Bin);
encode(#m_many_people_boss_ready_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2215, Bin);
encode(#m_many_people_boss_leave_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2216, Bin);
encode(#m_many_people_boss_notice_leave_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2217, Bin);
encode(#m_many_people_boss_notice_player_join_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2218, Bin);
encode(#m_many_people_boss_notice_player_leave_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2219, Bin);
encode(#m_many_people_boss_notice_player_ready_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2220, Bin);
encode(#m_many_people_boss_notice_player_fight_start_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2221, Bin);
encode(#m_many_people_boss_notice_player_fight_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2222, Bin);
encode(#m_many_people_boss_notice_owner_fight_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2223, Bin);
encode(#m_sys_common_change_state_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2301, Bin);
encode(#m_sys_common_change_state_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2302, Bin);
encode(#m_sys_common_notice_sys_common_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2303, Bin);
encode(#m_daily_task_get_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2401, Bin);
encode(#m_daily_task_get_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2402, Bin);
encode(#m_daily_task_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2403, Bin);
encode(#m_daily_task_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2404, Bin);
encode(#m_daily_task_notice_update_daily_task_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2405, Bin);
encode(#m_daily_task_notice_reset_daily_task_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2406, Bin);
encode(#m_daily_task_get_points_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2407, Bin);
encode(#m_daily_task_get_points_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2408, Bin);
encode(#m_daily_task_notice_update_task_show_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2409, Bin);
encode(#m_promote_get_promote_record_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2501, Bin);
encode(#m_promote_get_promote_record_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2502, Bin);
encode(#m_promote_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2503, Bin);
encode(#m_promote_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2504, Bin);
encode(#m_promote_notice_player_promote_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2505, Bin);
encode(#m_promote_notice_promote_times_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2506, Bin);
encode(#m_promote_invitation_code_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2507, Bin);
encode(#m_promote_invitation_code_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2508, Bin);
encode(#m_task_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2601, Bin);
encode(#m_task_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2602, Bin);
encode(#m_task_notice_task_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2603, Bin);
encode(#m_task_bounty_query_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2604, Bin);
encode(#m_task_bounty_query_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2605, Bin);
encode(#m_task_bounty_accept_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2606, Bin);
encode(#m_task_bounty_accept_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2607, Bin);
encode(#m_task_bounty_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2608, Bin);
encode(#m_task_bounty_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2609, Bin);
encode(#m_task_bounty_refresh_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2610, Bin);
encode(#m_task_bounty_refresh_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2611, Bin);
encode(#m_task_bounty_notice_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2612, Bin);
encode(#m_task_bounty_notice_reset_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2613, Bin);
encode(#m_red_packet_notice_player_red_packet_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2701, Bin);
encode(#m_red_packet_get_red_packet_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2702, Bin);
encode(#m_red_packet_get_red_packet_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2703, Bin);
encode(#m_red_packet_notice_player_red_packet_clear_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2704, Bin);
encode(#m_brave_one_get_info_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2801, Bin);
encode(#m_brave_one_get_info_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2802, Bin);
encode(#m_brave_one_create_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2803, Bin);
encode(#m_brave_one_create_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2804, Bin);
encode(#m_brave_one_enter_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2805, Bin);
encode(#m_brave_one_enter_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2806, Bin);
encode(#m_brave_one_clean_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2807, Bin);
encode(#m_brave_one_clean_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2808, Bin);
encode(#m_brave_one_notice_fight_scene_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2809, Bin);
encode(#m_brave_one_wait_scene_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2810, Bin);
encode(#m_brave_one_ready_start_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2811, Bin);
encode(#m_brave_one_fight_player_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2812, Bin);
encode(#m_brave_one_win_player_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2813, Bin);
encode(#m_step_by_step_sy_enter_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2901, Bin);
encode(#m_step_by_step_sy_enter_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2902, Bin);
encode(#m_step_by_step_sy_fight_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2903, Bin);
encode(#m_step_by_step_sy_fight_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2904, Bin);
encode(#m_step_by_step_sy_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2905, Bin);
encode(#m_step_by_step_sy_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2906, Bin);
encode(#m_step_by_step_sy_fight_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(2907, Bin);
encode(#m_turn_table_draw_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3001, Bin);
encode(#m_turn_table_draw_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3002, Bin);
encode(#m_turn_table_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3003, Bin);
encode(#m_turn_table_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3004, Bin);
encode(#m_turn_table_notice_reset_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3005, Bin);
encode(#m_shi_shi_room_get_room_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3101, Bin);
encode(#m_shi_shi_room_get_room_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3102, Bin);
encode(#m_shi_shi_room_create_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3103, Bin);
encode(#m_shi_shi_room_create_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3104, Bin);
encode(#m_shi_shi_room_join_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3105, Bin);
encode(#m_shi_shi_room_join_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3106, Bin);
encode(#m_shi_shi_room_start_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3107, Bin);
encode(#m_shi_shi_room_start_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3108, Bin);
encode(#m_shi_shi_room_kick_out_player_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3109, Bin);
encode(#m_shi_shi_room_ready_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3110, Bin);
encode(#m_shi_shi_room_ready_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3111, Bin);
encode(#m_shi_shi_room_leave_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3112, Bin);
encode(#m_shi_shi_room_notice_leave_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3113, Bin);
encode(#m_shi_shi_room_notice_player_join_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3114, Bin);
encode(#m_shi_shi_room_notice_player_leave_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3115, Bin);
encode(#m_shi_shi_room_notice_player_ready_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3116, Bin);
encode(#m_shi_shi_room_notice_player_fight_start_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3117, Bin);
encode(#m_shi_shi_room_notice_room_owner_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3118, Bin);
encode(#m_shi_shi_room_notice_player_fight_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3119, Bin);
encode(#m_shi_shi_room_notice_shi_shi_value_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3120, Bin);
encode(#m_hero_charge_hero_parts_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3201, Bin);
encode(#m_hero_charge_hero_parts_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3202, Bin);
encode(#m_hero_unlock_hero_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3203, Bin);
encode(#m_hero_unlock_hero_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3204, Bin);
encode(#m_hero_hero_up_star_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3205, Bin);
encode(#m_hero_hero_up_star_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3206, Bin);
encode(#m_hero_notice_hero_unlock_parts_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3207, Bin);
encode(#m_hero_notice_unlock_hero_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3208, Bin);
encode(#m_card_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3301, Bin);
encode(#m_card_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3302, Bin);
encode(#m_card_notice_card_update_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3303, Bin);
encode(#m_seize_treasure_currency_seize_treasure_type_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3401, Bin);
encode(#m_seize_treasure_get_treasure_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3402, Bin);
encode(#m_seize_treasure_get_treasure_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3403, Bin);
encode(#m_seize_treasure_get_extra_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3404, Bin);
encode(#m_seize_treasure_get_extra_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3405, Bin);
encode(#m_seize_treasure_get_extra_award_status_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3406, Bin);
encode(#m_seize_treasure_get_extra_award_status_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3407, Bin);
encode(#m_card_summon_do_summon_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3501, Bin);
encode(#m_card_summon_do_summon_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3502, Bin);
encode(#m_shen_long_draw_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3601, Bin);
encode(#m_shen_long_draw_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3602, Bin);
encode(#m_shen_long_notice_scene_shen_long_state_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3603, Bin);
encode(#m_skill_use_skill_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3701, Bin);
encode(#m_skill_use_skill_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3702, Bin);
encode(#m_skill_notice_active_skill_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3703, Bin);
encode(#m_tongxingzheng_task_info_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3801, Bin);
encode(#m_tongxingzheng_task_daily_update_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3802, Bin);
encode(#m_tongxingzheng_task_month_update_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3803, Bin);
encode(#m_tongxingzheng_task_daily_reward_collect_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3804, Bin);
encode(#m_tongxingzheng_task_daily_reward_collect_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3805, Bin);
encode(#m_tongxingzheng_task_month_reward_collect_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3806, Bin);
encode(#m_tongxingzheng_task_month_reward_collect_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3807, Bin);
encode(#m_tongxingzheng_purchase_unlock_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3808, Bin);
encode(#m_tongxingzheng_purchase_unlock_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3809, Bin);
encode(#m_tongxingzheng_reward_info_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3810, Bin);
encode(#m_tongxingzheng_purchase_level_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3811, Bin);
encode(#m_tongxingzheng_purchase_level_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3812, Bin);
encode(#m_tongxingzheng_collect_level_reward_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3813, Bin);
encode(#m_tongxingzheng_collect_level_reward_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3814, Bin);
encode(#m_jiangjinchi_info_notice_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3901, Bin);
encode(#m_jiangjinchi_get_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3902, Bin);
encode(#m_jiangjinchi_get_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3903, Bin);
encode(#m_jiangjinchi_do_draw_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3904, Bin);
encode(#m_jiangjinchi_do_draw_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3905, Bin);
encode(#m_jiangjinchi_reward_double_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3906, Bin);
encode(#m_jiangjinchi_reward_double_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3907, Bin);
encode(#m_jiangjinchi_result_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3908, Bin);
encode(#m_jiangjinchi_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(3909, Bin);
encode(#m_leichong_info_query_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4001, Bin);
encode(#m_leichong_info_query_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4002, Bin);
encode(#m_leichong_get_reward_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4003, Bin);
encode(#m_leichong_get_reward_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4004, Bin);
encode(#m_special_prop_notice_init_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4101, Bin);
encode(#m_special_prop_notice_update_special_prop_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4102, Bin);
encode(#m_special_prop_special_prop_merge_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4103, Bin);
encode(#m_special_prop_special_prop_merge_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4104, Bin);
encode(#m_special_prop_sell_special_prop_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4105, Bin);
encode(#m_special_prop_sell_special_prop_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4106, Bin);
encode(#m_scene_event_do_laba_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4201, Bin);
encode(#m_scene_event_do_laba_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4202, Bin);
encode(#m_scene_event_do_turntable_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4203, Bin);
encode(#m_scene_event_do_turntable_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4204, Bin);
encode(#m_scene_event_do_money_three_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4205, Bin);
encode(#m_scene_event_do_money_three_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4206, Bin);
encode(#m_scene_event_notice_money_three_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4207, Bin);
encode(#m_scene_event_notice_task_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4208, Bin);
encode(#m_scene_event_query_balls_data_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4209, Bin);
encode(#m_scene_event_query_balls_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4210, Bin);
encode(#m_scene_event_notice_drop_ball_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4211, Bin);
encode(#m_scene_event_notice_balls_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4212, Bin);
encode(#m_match_scene_get_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4301, Bin);
encode(#m_match_scene_get_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4302, Bin);
encode(#m_match_scene_match_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4303, Bin);
encode(#m_match_scene_match_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4304, Bin);
encode(#m_match_scene_cancel_match_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4305, Bin);
encode(#m_match_scene_cancel_match_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4306, Bin);
encode(#m_match_scene_notice_match_num_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4307, Bin);
encode(#m_match_scene_notice_match_fail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4308, Bin);
encode(#m_match_scene_notice_rank_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4309, Bin);
encode(#m_match_scene_notice_time_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4310, Bin);
encode(#m_match_scene_notice_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4311, Bin);
encode(#m_first_charge_init_data_first_recharge_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4401, Bin);
encode(#m_first_charge_notice_data_update_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4402, Bin);
encode(#m_first_charge_get_award_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4403, Bin);
encode(#m_first_charge_get_award_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4404, Bin);
encode(#m_verify_code_sms_code_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4501, Bin);
encode(#m_verify_code_sms_code_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4502, Bin);
encode(#m_verify_code_get_area_code_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4503, Bin);
encode(#m_verify_code_get_area_code_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4504, Bin);
encode(#m_verify_code_get_my_sms_code_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4505, Bin);
encode(#m_match_scene_room_notice_unread_num_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4601, Bin);
encode(#m_match_scene_room_get_room_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4602, Bin);
encode(#m_match_scene_room_get_room_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4603, Bin);
encode(#m_match_scene_room_exit_room_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4604, Bin);
encode(#m_match_scene_room_add_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4605, Bin);
encode(#m_match_scene_room_delete_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4606, Bin);
encode(#m_match_scene_room_notice_room_people_num_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4607, Bin);
encode(#m_match_scene_room_create_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4608, Bin);
encode(#m_match_scene_room_create_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4609, Bin);
encode(#m_match_scene_room_world_recruit_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4610, Bin);
encode(#m_match_scene_room_world_recruit_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4611, Bin);
encode(#m_match_scene_room_recruit_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4612, Bin);
encode(#m_match_scene_room_recruit_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4613, Bin);
encode(#m_match_scene_room_join_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4614, Bin);
encode(#m_match_scene_room_join_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4615, Bin);
encode(#m_match_scene_room_leave_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4616, Bin);
encode(#m_match_scene_room_leave_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4617, Bin);
encode(#m_match_scene_room_notice_people_num_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4618, Bin);
encode(#m_gift_select_player_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4701, Bin);
encode(#m_gift_select_player_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4702, Bin);
encode(#m_gift_give_gift_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4703, Bin);
encode(#m_gift_give_gift_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4704, Bin);
encode(#m_gift_init_mail_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4705, Bin);
encode(#m_gift_read_mail_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4706, Bin);
encode(#m_gift_read_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4707, Bin);
encode(#m_gift_get_item_mail_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4708, Bin);
encode(#m_gift_get_item_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4709, Bin);
encode(#m_gift_delete_mail_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4710, Bin);
encode(#m_gift_delete_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4711, Bin);
encode(#m_gift_add_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4712, Bin);
encode(#m_gift_remove_mail_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4713, Bin);
encode(#m_gift_gift_mail_record_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4714, Bin);
encode(#m_gift_gift_mail_record_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4715, Bin);
encode(#m_wheel_join_wheel_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4801, Bin);
encode(#m_wheel_join_wheel_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4802, Bin);
encode(#m_wheel_bet_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4803, Bin);
encode(#m_wheel_bet_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4804, Bin);
encode(#m_wheel_notice_bet_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4805, Bin);
encode(#m_wheel_get_record_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4806, Bin);
encode(#m_wheel_get_record_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4807, Bin);
encode(#m_wheel_get_bet_record_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4808, Bin);
encode(#m_wheel_get_bet_record_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4809, Bin);
encode(#m_wheel_get_player_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4810, Bin);
encode(#m_wheel_get_player_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4811, Bin);
encode(#m_wheel_balance_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4812, Bin);
encode(#m_wheel_exit_wheel_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4813, Bin);
encode(#m_wheel_use_last_bet_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4814, Bin);
encode(#m_wheel_use_last_bet_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4815, Bin);
encode(#m_laba_spin_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4901, Bin);
encode(#m_laba_spin_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4902, Bin);
encode(#m_laba_spin2_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4903, Bin);
encode(#m_laba_spin2_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4904, Bin);
encode(#m_laba_get_adjust_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4905, Bin);
encode(#m_laba_get_adjust_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(4906, Bin);
encode(#m_one_vs_one_get_room_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5001, Bin);
encode(#m_one_vs_one_get_room_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5002, Bin);
encode(#m_one_vs_one_exit_room_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5003, Bin);
encode(#m_one_vs_one_join_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5004, Bin);
encode(#m_one_vs_one_join_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5005, Bin);
encode(#m_one_vs_one_notice_update_room_data_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5006, Bin);
encode(#m_one_vs_one_notice_scene_skill_limit_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5007, Bin);
encode(#m_player_chat_channel_chat_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5101, Bin);
encode(#m_player_chat_channel_chat_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5102, Bin);
encode(#m_player_chat_broadcast_channel_msg_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5103, Bin);
encode(#m_player_chat_get_player_chat_info_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5104, Bin);
encode(#m_player_chat_get_player_chat_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5105, Bin);
encode(#m_player_chat_get_player_list_online_status_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5106, Bin);
encode(#m_player_chat_get_player_list_online_status_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5107, Bin);
encode(#m_room_get_room_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5201, Bin);
encode(#m_room_get_room_list_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5202, Bin);
encode(#m_room_leave_room_list_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5203, Bin);
encode(#m_room_notice_room_list_change_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5204, Bin);
encode(#m_room_enter_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5205, Bin);
encode(#m_room_enter_room_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5206, Bin);
encode(#m_room_leave_room_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5207, Bin);
encode(#m_room_notice_room_start_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5208, Bin);
encode(#m_room_notice_fighting_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5209, Bin);
encode(#m_room_ready_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5210, Bin);
encode(#m_room_notice_player_ready_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5211, Bin);
encode(#m_room_add_frame_action_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5212, Bin);
encode(#m_room_push_frame_info_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5213, Bin);
encode(#m_room_fight_result_tos{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5214, Bin);
encode(#m_room_fight_result_toc{} = Msg) ->
    Bin = p_message:encode_msg(Msg, ?ENCODE_OPTS),
    encode(5215, Bin);
encode(Other) -> exit({unknow_msg, Other}).


encode(MethodNum, Bin) ->
      util_websocket:pack_packet(<<0, MethodNum:32, Bin/binary>>).


decode(<<_IsZip:8, Method:32/unsigned, Data/binary>>) ->
  decode(Method, Data).
decode(1, Bin) ->
  p_message:decode_msg(Bin, m_login_login_tos);
decode(2, Bin) ->
  p_message:decode_msg(Bin, m_login_login_toc);
decode(3, Bin) ->
  p_message:decode_msg(Bin, m_login_create_role_tos);
decode(4, Bin) ->
  p_message:decode_msg(Bin, m_login_create_role_toc);
decode(5, Bin) ->
  p_message:decode_msg(Bin, m_login_enter_game_tos);
decode(6, Bin) ->
  p_message:decode_msg(Bin, m_login_heart_beat_tos);
decode(7, Bin) ->
  p_message:decode_msg(Bin, m_login_heart_beat_toc);
decode(8, Bin) ->
  p_message:decode_msg(Bin, m_login_notice_logout_toc);
decode(101, Bin) ->
  p_message:decode_msg(Bin, m_player_init_player_data_toc);
decode(102, Bin) ->
  p_message:decode_msg(Bin, m_player_notice_player_attr_change_toc);
decode(103, Bin) ->
  p_message:decode_msg(Bin, m_player_notice_player_string_attr_change_toc);
decode(104, Bin) ->
  p_message:decode_msg(Bin, m_player_notice_fun_active_toc);
decode(105, Bin) ->
  p_message:decode_msg(Bin, m_player_notice_server_time_toc);
decode(106, Bin) ->
  p_message:decode_msg(Bin, m_player_change_pk_mode_tos);
decode(107, Bin) ->
  p_message:decode_msg(Bin, m_player_change_pk_mode_toc);
decode(108, Bin) ->
  p_message:decode_msg(Bin, m_player_get_player_attr_tos);
decode(109, Bin) ->
  p_message:decode_msg(Bin, m_player_get_player_attr_toc);
decode(110, Bin) ->
  p_message:decode_msg(Bin, m_player_change_name_tos);
decode(111, Bin) ->
  p_message:decode_msg(Bin, m_player_change_name_toc);
decode(112, Bin) ->
  p_message:decode_msg(Bin, m_player_change_sex_tos);
decode(113, Bin) ->
  p_message:decode_msg(Bin, m_player_change_sex_toc);
decode(114, Bin) ->
  p_message:decode_msg(Bin, m_player_update_client_data_tos);
decode(115, Bin) ->
  p_message:decode_msg(Bin, m_player_delete_client_data_tos);
decode(116, Bin) ->
  p_message:decode_msg(Bin, m_player_adjust_tos);
decode(117, Bin) ->
  p_message:decode_msg(Bin, m_player_adjust_toc);
decode(118, Bin) ->
  p_message:decode_msg(Bin, m_player_customer_url_tos);
decode(119, Bin) ->
  p_message:decode_msg(Bin, m_player_customer_url_toc);
decode(120, Bin) ->
  p_message:decode_msg(Bin, m_player_visitor_binding_tos);
decode(121, Bin) ->
  p_message:decode_msg(Bin, m_player_visitor_binding_toc);
decode(122, Bin) ->
  p_message:decode_msg(Bin, m_player_get_server_time_tos);
decode(123, Bin) ->
  p_message:decode_msg(Bin, m_player_get_server_time_toc);
decode(124, Bin) ->
  p_message:decode_msg(Bin, m_player_modify_nickname_gender_tos);
decode(125, Bin) ->
  p_message:decode_msg(Bin, m_player_modify_nickname_gender_toc);
decode(126, Bin) ->
  p_message:decode_msg(Bin, m_player_set_player_data_tos);
decode(127, Bin) ->
  p_message:decode_msg(Bin, m_player_set_player_data_toc);
decode(128, Bin) ->
  p_message:decode_msg(Bin, m_player_notice_player_xiu_zhen_value_toc);
decode(129, Bin) ->
  p_message:decode_msg(Bin, m_player_collect_delay_rewards_tos);
decode(130, Bin) ->
  p_message:decode_msg(Bin, m_player_level_upgrade_tos);
decode(131, Bin) ->
  p_message:decode_msg(Bin, m_player_level_upgrade_toc);
decode(132, Bin) ->
  p_message:decode_msg(Bin, m_player_bind_mobile_tos);
decode(133, Bin) ->
  p_message:decode_msg(Bin, m_player_bind_mobile_toc);
decode(134, Bin) ->
  p_message:decode_msg(Bin, m_player_bind_res_toc);
decode(135, Bin) ->
  p_message:decode_msg(Bin, m_player_get_level_award_tos);
decode(136, Bin) ->
  p_message:decode_msg(Bin, m_player_get_level_award_toc);
decode(137, Bin) ->
  p_message:decode_msg(Bin, m_player_update_player_signature_tos);
decode(138, Bin) ->
  p_message:decode_msg(Bin, m_player_update_player_signature_toc);
decode(139, Bin) ->
  p_message:decode_msg(Bin, m_player_get_player_info_tos);
decode(140, Bin) ->
  p_message:decode_msg(Bin, m_player_get_player_info_toc);
decode(141, Bin) ->
  p_message:decode_msg(Bin, m_player_world_tree_award_tos);
decode(142, Bin) ->
  p_message:decode_msg(Bin, m_player_world_tree_award_toc);
decode(201, Bin) ->
  p_message:decode_msg(Bin, m_scene_enter_scene_tos);
decode(202, Bin) ->
  p_message:decode_msg(Bin, m_scene_enter_scene_toc);
decode(203, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_prepare_scene_toc);
decode(204, Bin) ->
  p_message:decode_msg(Bin, m_scene_load_scene_tos);
decode(205, Bin) ->
  p_message:decode_msg(Bin, m_scene_load_scene_toc);
decode(206, Bin) ->
  p_message:decode_msg(Bin, m_scene_sync_scene_toc);
decode(207, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_scene_player_enter_toc);
decode(208, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_scene_player_leave_toc);
decode(209, Bin) ->
  p_message:decode_msg(Bin, m_scene_player_rebirth_tos);
decode(210, Bin) ->
  p_message:decode_msg(Bin, m_scene_player_rebirth_toc);
decode(211, Bin) ->
  p_message:decode_msg(Bin, m_scene_player_move_tos);
decode(212, Bin) ->
  p_message:decode_msg(Bin, m_scene_player_move_step_tos);
decode(213, Bin) ->
  p_message:decode_msg(Bin, m_scene_player_stop_move_tos);
decode(214, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_player_move_toc);
decode(215, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_player_stop_move_toc);
decode(216, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_player_teleport_toc);
decode(217, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_correct_player_pos_toc);
decode(218, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_enter_toc);
decode(219, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_leave_toc);
decode(220, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_move_toc);
decode(221, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_stop_move_toc);
decode(222, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_teleport_toc);
decode(223, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_item_enter_toc);
decode(224, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_item_leave_toc);
decode(225, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_scene_item_owner_change_toc);
decode(226, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_player_death_toc);
decode(227, Bin) ->
  p_message:decode_msg(Bin, m_scene_query_player_pos_tos);
decode(228, Bin) ->
  p_message:decode_msg(Bin, m_scene_query_player_pos_toc);
decode(229, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_obj_hp_change_toc);
decode(230, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_attr_change_toc);
decode(231, Bin) ->
  p_message:decode_msg(Bin, m_scene_transmit_tos);
decode(232, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_prepare_transmit_toc);
decode(233, Bin) ->
  p_message:decode_msg(Bin, m_scene_update_npc_date_toc);
decode(234, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_simplify_monster_pos_toc);
decode(235, Bin) ->
  p_message:decode_msg(Bin, m_scene_get_monster_list_tos);
decode(236, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_list_toc);
decode(237, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_anger_change_toc);
decode(238, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_special_skill_change_toc);
decode(239, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_show_fanpai_toc);
decode(240, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_fanpai_tos);
decode(241, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_fanpai_toc);
decode(242, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_boss_state_toc);
decode(243, Bin) ->
  p_message:decode_msg(Bin, m_scene_challenge_boss_tos);
decode(244, Bin) ->
  p_message:decode_msg(Bin, m_scene_send_msg_tos);
decode(245, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_send_msg_toc);
decode(246, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_scene_jbxy_state_toc);
decode(247, Bin) ->
  p_message:decode_msg(Bin, m_scene_player_collect_tos);
decode(248, Bin) ->
  p_message:decode_msg(Bin, m_scene_get_gold_ranking_toc);
decode(249, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_restore_hp_toc);
decode(250, Bin) ->
  p_message:decode_msg(Bin, m_scene_show_action_tos);
decode(251, Bin) ->
  p_message:decode_msg(Bin, m_scene_show_action_notice_toc);
decode(252, Bin) ->
  p_message:decode_msg(Bin, m_scene_player_kuangbao_info_notice_toc);
decode(253, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_boss_die_toc);
decode(254, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_monster_speak_toc);
decode(255, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_time_stop_toc);
decode(256, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_init_time_event_list_toc);
decode(257, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_add_time_event_list_toc);
decode(258, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_time_event_list_sleep_toc);
decode(259, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_time_event_list_start_toc);
decode(260, Bin) ->
  p_message:decode_msg(Bin, m_scene_notice_rank_event_toc);
decode(261, Bin) ->
  p_message:decode_msg(Bin, m_scene_enter_single_scene_tos);
decode(262, Bin) ->
  p_message:decode_msg(Bin, m_scene_enter_single_scene_toc);
decode(301, Bin) ->
  p_message:decode_msg(Bin, m_fight_fight_tos);
decode(302, Bin) ->
  p_message:decode_msg(Bin, m_fight_notice_fight_fail_toc);
decode(303, Bin) ->
  p_message:decode_msg(Bin, m_fight_notice_fight_result_toc);
decode(304, Bin) ->
  p_message:decode_msg(Bin, m_fight_notice_add_buff_toc);
decode(305, Bin) ->
  p_message:decode_msg(Bin, m_fight_notice_remove_buff_toc);
decode(306, Bin) ->
  p_message:decode_msg(Bin, m_fight_use_item_tos);
decode(307, Bin) ->
  p_message:decode_msg(Bin, m_fight_use_item_toc);
decode(308, Bin) ->
  p_message:decode_msg(Bin, m_fight_notice_bin_dong_skill_toc);
decode(309, Bin) ->
  p_message:decode_msg(Bin, m_fight_notice_get_function_monster_award_toc);
decode(310, Bin) ->
  p_message:decode_msg(Bin, m_fight_notice_fight_wait_skill_toc);
decode(311, Bin) ->
  p_message:decode_msg(Bin, m_fight_wait_skill_trigger_tos);
decode(312, Bin) ->
  p_message:decode_msg(Bin, m_fight_dizzy_time_reduce_tos);
decode(313, Bin) ->
  p_message:decode_msg(Bin, m_fight_dizzy_time_reduce_toc);
decode(314, Bin) ->
  p_message:decode_msg(Bin, m_fight_notice_add_effect_toc);
decode(315, Bin) ->
  p_message:decode_msg(Bin, m_fight_blind_box_reward_toc);
decode(401, Bin) ->
  p_message:decode_msg(Bin, m_times_add_times_tos);
decode(402, Bin) ->
  p_message:decode_msg(Bin, m_times_add_times_toc);
decode(403, Bin) ->
  p_message:decode_msg(Bin, m_times_notice_times_change_toc);
decode(501, Bin) ->
  p_message:decode_msg(Bin, m_prop_notice_update_prop_toc);
decode(502, Bin) ->
  p_message:decode_msg(Bin, m_prop_use_item_tos);
decode(503, Bin) ->
  p_message:decode_msg(Bin, m_prop_use_item_toc);
decode(504, Bin) ->
  p_message:decode_msg(Bin, m_prop_sell_item_tos);
decode(505, Bin) ->
  p_message:decode_msg(Bin, m_prop_sell_item_toc);
decode(506, Bin) ->
  p_message:decode_msg(Bin, m_prop_merge_tos);
decode(507, Bin) ->
  p_message:decode_msg(Bin, m_prop_merge_toc);
decode(601, Bin) ->
  p_message:decode_msg(Bin, m_chat_channel_chat_tos);
decode(602, Bin) ->
  p_message:decode_msg(Bin, m_chat_channel_chat_toc);
decode(603, Bin) ->
  p_message:decode_msg(Bin, m_chat_broadcast_channel_msg_toc);
decode(604, Bin) ->
  p_message:decode_msg(Bin, m_chat_broadcast_channel_msg_list_toc);
decode(701, Bin) ->
  p_message:decode_msg(Bin, m_mission_challenge_mission_tos);
decode(702, Bin) ->
  p_message:decode_msg(Bin, m_mission_challenge_mission_toc);
decode(703, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_mission_result_toc);
decode(704, Bin) ->
  p_message:decode_msg(Bin, m_mission_exit_mission_tos);
decode(705, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_passed_mission_toc);
decode(706, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_mission_close_time_toc);
decode(707, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_mission_round_toc);
decode(708, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_total_award_toc);
decode(709, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_mission_ranking_toc);
decode(710, Bin) ->
  p_message:decode_msg(Bin, m_mission_get_award_tos);
decode(711, Bin) ->
  p_message:decode_msg(Bin, m_mission_get_award_toc);
decode(712, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_mission_schedule_toc);
decode(713, Bin) ->
  p_message:decode_msg(Bin, m_mission_boss_rebirth_tos);
decode(714, Bin) ->
  p_message:decode_msg(Bin, m_mission_boss_rebirth_toc);
decode(715, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_shi_shi_settle_toc);
decode(716, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_shi_shi_time_toc);
decode(717, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_shi_shi_value_toc);
decode(718, Bin) ->
  p_message:decode_msg(Bin, m_mission_guess_get_record_tos);
decode(719, Bin) ->
  p_message:decode_msg(Bin, m_mission_guess_get_record_toc);
decode(720, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_guess_boss_cost_my_mana_toc);
decode(721, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_guess_boss_cost_total_mana_toc);
decode(722, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_guess_boss_mission_result_toc);
decode(723, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_guess_boss_mission_time_toc);
decode(724, Bin) ->
  p_message:decode_msg(Bin, m_mission_either_notice_state_toc);
decode(725, Bin) ->
  p_message:decode_msg(Bin, m_mission_either_either_tos);
decode(726, Bin) ->
  p_message:decode_msg(Bin, m_mission_either_notice_result_toc);
decode(727, Bin) ->
  p_message:decode_msg(Bin, m_mission_scene_boss_bet_tos);
decode(728, Bin) ->
  p_message:decode_msg(Bin, m_mission_scene_boss_bet_reset_tos);
decode(729, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_scene_boss_bet_toc);
decode(730, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_scene_boss_step_toc);
decode(731, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_scene_boss_result_toc);
decode(732, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_scene_boss_dao_num_change_toc);
decode(733, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_scene_boss_boss_update_pos_toc);
decode(734, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_new_guess_result_toc);
decode(735, Bin) ->
  p_message:decode_msg(Bin, m_mission_lucky_boss_bet_tos);
decode(736, Bin) ->
  p_message:decode_msg(Bin, m_mission_lucky_boss_bet_toc);
decode(737, Bin) ->
  p_message:decode_msg(Bin, m_mission_lucky_boss_bet_reset_tos);
decode(738, Bin) ->
  p_message:decode_msg(Bin, m_mission_lucky_boss_bet_reset_toc);
decode(739, Bin) ->
  p_message:decode_msg(Bin, m_mission_lucky_boss_bet_modification_toc);
decode(740, Bin) ->
  p_message:decode_msg(Bin, m_mission_lucky_boss_bet_info_toc);
decode(741, Bin) ->
  p_message:decode_msg(Bin, m_mission_lucky_boss_status_tos);
decode(742, Bin) ->
  p_message:decode_msg(Bin, m_mission_lucky_boss_status_toc);
decode(743, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_lucky_boss_result_toc);
decode(744, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_lucky_boss_fight_toc);
decode(745, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_one_on_one_rate_toc);
decode(746, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_ready_notice_toc);
decode(747, Bin) ->
  p_message:decode_msg(Bin, m_mission_hero_versus_boss_bet_tos);
decode(748, Bin) ->
  p_message:decode_msg(Bin, m_mission_hero_versus_boss_bet_toc);
decode(749, Bin) ->
  p_message:decode_msg(Bin, m_mission_hero_versus_boss_bet_reset_tos);
decode(750, Bin) ->
  p_message:decode_msg(Bin, m_mission_hero_versus_boss_bet_reset_toc);
decode(751, Bin) ->
  p_message:decode_msg(Bin, m_mission_hero_versus_boss_bet_modification_toc);
decode(752, Bin) ->
  p_message:decode_msg(Bin, m_mission_hero_versus_boss_bet_info_toc);
decode(753, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_hero_versus_boss_result_toc);
decode(754, Bin) ->
  p_message:decode_msg(Bin, m_mission_hero_versus_boss_status_toc);
decode(755, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_hero_versus_boss_fight_toc);
decode(756, Bin) ->
  p_message:decode_msg(Bin, m_mission_notice_hero_versus_boss_rate_toc);
decode(757, Bin) ->
  p_message:decode_msg(Bin, m_mission_get_hero_versus_boss_record_tos);
decode(758, Bin) ->
  p_message:decode_msg(Bin, m_mission_get_hero_versus_boss_record_toc);
decode(801, Bin) ->
  p_message:decode_msg(Bin, m_mail_get_mail_info_tos);
decode(802, Bin) ->
  p_message:decode_msg(Bin, m_mail_get_mail_info_toc);
decode(803, Bin) ->
  p_message:decode_msg(Bin, m_mail_read_mail_tos);
decode(804, Bin) ->
  p_message:decode_msg(Bin, m_mail_read_mail_toc);
decode(805, Bin) ->
  p_message:decode_msg(Bin, m_mail_get_item_mail_tos);
decode(806, Bin) ->
  p_message:decode_msg(Bin, m_mail_get_item_mail_toc);
decode(807, Bin) ->
  p_message:decode_msg(Bin, m_mail_delete_mail_tos);
decode(808, Bin) ->
  p_message:decode_msg(Bin, m_mail_delete_mail_toc);
decode(809, Bin) ->
  p_message:decode_msg(Bin, m_mail_add_mail_toc);
decode(810, Bin) ->
  p_message:decode_msg(Bin, m_mail_remove_mail_toc);
decode(901, Bin) ->
  p_message:decode_msg(Bin, m_vip_get_vip_award_tos);
decode(902, Bin) ->
  p_message:decode_msg(Bin, m_vip_get_vip_award_toc);
decode(903, Bin) ->
  p_message:decode_msg(Bin, m_vip_notice_vip_data_toc);
decode(10001, Bin) ->
  p_message:decode_msg(Bin, m_debug_debug_tos);
decode(10002, Bin) ->
  p_message:decode_msg(Bin, m_debug_debug_toc);
decode(1001, Bin) ->
  p_message:decode_msg(Bin, m_client_log_client_log_tos);
decode(1101, Bin) ->
  p_message:decode_msg(Bin, m_achievement_get_info_tos);
decode(1102, Bin) ->
  p_message:decode_msg(Bin, m_achievement_get_info_toc);
decode(1103, Bin) ->
  p_message:decode_msg(Bin, m_achievement_get_award_tos);
decode(1104, Bin) ->
  p_message:decode_msg(Bin, m_achievement_get_award_toc);
decode(1105, Bin) ->
  p_message:decode_msg(Bin, m_achievement_notice_update_achievement_data_toc);
decode(1201, Bin) ->
  p_message:decode_msg(Bin, m_rank_get_rank_info_tos);
decode(1202, Bin) ->
  p_message:decode_msg(Bin, m_rank_get_rank_info_toc);
decode(1301, Bin) ->
  p_message:decode_msg(Bin, m_shop_get_shop_info_tos);
decode(1302, Bin) ->
  p_message:decode_msg(Bin, m_shop_get_shop_info_toc);
decode(1303, Bin) ->
  p_message:decode_msg(Bin, m_shop_shop_item_tos);
decode(1304, Bin) ->
  p_message:decode_msg(Bin, m_shop_shop_item_toc);
decode(1305, Bin) ->
  p_message:decode_msg(Bin, m_shop_notice_shop_state_toc);
decode(1401, Bin) ->
  p_message:decode_msg(Bin, m_activity_restart_all_activity_toc);
decode(1402, Bin) ->
  p_message:decode_msg(Bin, m_activity_update_activity_time_toc);
decode(1501, Bin) ->
  p_message:decode_msg(Bin, m_charge_notice_is_open_charge_toc);
decode(1502, Bin) ->
  p_message:decode_msg(Bin, m_charge_charge_tos);
decode(1503, Bin) ->
  p_message:decode_msg(Bin, m_charge_charge_toc);
decode(1504, Bin) ->
  p_message:decode_msg(Bin, m_charge_notice_charge_data_toc);
decode(1505, Bin) ->
  p_message:decode_msg(Bin, m_charge_get_charge_type_tos);
decode(1506, Bin) ->
  p_message:decode_msg(Bin, m_charge_get_charge_type_toc);
decode(1601, Bin) ->
  p_message:decode_msg(Bin, m_invest_init_notice_toc);
decode(1602, Bin) ->
  p_message:decode_msg(Bin, m_invest_get_invest_award_tos);
decode(1603, Bin) ->
  p_message:decode_msg(Bin, m_invest_get_invest_award_toc);
decode(1604, Bin) ->
  p_message:decode_msg(Bin, m_invest_notice_invest_type_data_update_toc);
decode(1701, Bin) ->
  p_message:decode_msg(Bin, m_everyday_sign_everyday_sign_tos);
decode(1702, Bin) ->
  p_message:decode_msg(Bin, m_everyday_sign_everyday_sign_toc);
decode(1703, Bin) ->
  p_message:decode_msg(Bin, m_everyday_sign_notice_day_toc);
decode(1801, Bin) ->
  p_message:decode_msg(Bin, m_seven_login_give_award_tos);
decode(1802, Bin) ->
  p_message:decode_msg(Bin, m_seven_login_give_award_toc);
decode(1803, Bin) ->
  p_message:decode_msg(Bin, m_seven_login_update_cumulative_day_toc);
decode(1901, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_share_tos);
decode(1902, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_share_toc);
decode(1903, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_get_share_friend_give_tos);
decode(1904, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_get_share_friend_give_toc);
decode(1905, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_notice_share_friend_toc);
decode(1906, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_notice_share_count_toc);
decode(1907, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_notice_platform_vip_level_toc);
decode(1908, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_get_platform_award_info_tos);
decode(1909, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_get_platform_award_info_toc);
decode(1910, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_get_share_task_info_tos);
decode(1911, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_get_share_task_info_toc);
decode(1912, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_get_share_task_award_tos);
decode(1913, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_get_share_task_award_toc);
decode(1914, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_notice_share_task_toc);
decode(1915, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_refresh_open_key_tos);
decode(1916, Bin) ->
  p_message:decode_msg(Bin, m_platform_function_refresh_open_key_toc);
decode(2001, Bin) ->
  p_message:decode_msg(Bin, m_gift_code_gift_code_tos);
decode(2002, Bin) ->
  p_message:decode_msg(Bin, m_gift_code_gift_code_toc);
decode(2101, Bin) ->
  p_message:decode_msg(Bin, m_video_get_award_tos);
decode(2102, Bin) ->
  p_message:decode_msg(Bin, m_video_get_award_toc);
decode(2201, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_get_room_list_tos);
decode(2202, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_get_room_list_toc);
decode(2203, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_join_room_tos);
decode(2204, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_join_room_toc);
decode(2205, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_create_room_tos);
decode(2206, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_create_room_toc);
decode(2207, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_start_tos);
decode(2208, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_start_toc);
decode(2209, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_participate_in_tos);
decode(2210, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_participate_in_toc);
decode(2211, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_kick_out_player_tos);
decode(2212, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_set_is_all_ready_start_tos);
decode(2213, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_set_is_all_ready_start_toc);
decode(2214, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_ready_tos);
decode(2215, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_ready_toc);
decode(2216, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_leave_room_tos);
decode(2217, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_notice_leave_room_toc);
decode(2218, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_notice_player_join_toc);
decode(2219, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_notice_player_leave_toc);
decode(2220, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_notice_player_ready_toc);
decode(2221, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_notice_player_fight_start_toc);
decode(2222, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_notice_player_fight_result_toc);
decode(2223, Bin) ->
  p_message:decode_msg(Bin, m_many_people_boss_notice_owner_fight_result_toc);
decode(2301, Bin) ->
  p_message:decode_msg(Bin, m_sys_common_change_state_tos);
decode(2302, Bin) ->
  p_message:decode_msg(Bin, m_sys_common_change_state_toc);
decode(2303, Bin) ->
  p_message:decode_msg(Bin, m_sys_common_notice_sys_common_toc);
decode(2401, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_get_info_tos);
decode(2402, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_get_info_toc);
decode(2403, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_get_award_tos);
decode(2404, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_get_award_toc);
decode(2405, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_notice_update_daily_task_data_toc);
decode(2406, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_notice_reset_daily_task_data_toc);
decode(2407, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_get_points_award_tos);
decode(2408, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_get_points_award_toc);
decode(2409, Bin) ->
  p_message:decode_msg(Bin, m_daily_task_notice_update_task_show_toc);
decode(2501, Bin) ->
  p_message:decode_msg(Bin, m_promote_get_promote_record_tos);
decode(2502, Bin) ->
  p_message:decode_msg(Bin, m_promote_get_promote_record_toc);
decode(2503, Bin) ->
  p_message:decode_msg(Bin, m_promote_get_award_tos);
decode(2504, Bin) ->
  p_message:decode_msg(Bin, m_promote_get_award_toc);
decode(2505, Bin) ->
  p_message:decode_msg(Bin, m_promote_notice_player_promote_data_toc);
decode(2506, Bin) ->
  p_message:decode_msg(Bin, m_promote_notice_promote_times_toc);
decode(2507, Bin) ->
  p_message:decode_msg(Bin, m_promote_invitation_code_tos);
decode(2508, Bin) ->
  p_message:decode_msg(Bin, m_promote_invitation_code_toc);
decode(2601, Bin) ->
  p_message:decode_msg(Bin, m_task_get_award_tos);
decode(2602, Bin) ->
  p_message:decode_msg(Bin, m_task_get_award_toc);
decode(2603, Bin) ->
  p_message:decode_msg(Bin, m_task_notice_task_change_toc);
decode(2604, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_query_info_tos);
decode(2605, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_query_info_toc);
decode(2606, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_accept_tos);
decode(2607, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_accept_toc);
decode(2608, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_get_award_tos);
decode(2609, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_get_award_toc);
decode(2610, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_refresh_tos);
decode(2611, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_refresh_toc);
decode(2612, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_notice_change_toc);
decode(2613, Bin) ->
  p_message:decode_msg(Bin, m_task_bounty_notice_reset_toc);
decode(2701, Bin) ->
  p_message:decode_msg(Bin, m_red_packet_notice_player_red_packet_toc);
decode(2702, Bin) ->
  p_message:decode_msg(Bin, m_red_packet_get_red_packet_tos);
decode(2703, Bin) ->
  p_message:decode_msg(Bin, m_red_packet_get_red_packet_toc);
decode(2704, Bin) ->
  p_message:decode_msg(Bin, m_red_packet_notice_player_red_packet_clear_toc);
decode(2801, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_get_info_list_tos);
decode(2802, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_get_info_list_toc);
decode(2803, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_create_tos);
decode(2804, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_create_toc);
decode(2805, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_enter_tos);
decode(2806, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_enter_toc);
decode(2807, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_clean_tos);
decode(2808, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_clean_toc);
decode(2809, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_notice_fight_scene_toc);
decode(2810, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_wait_scene_toc);
decode(2811, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_ready_start_toc);
decode(2812, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_fight_player_toc);
decode(2813, Bin) ->
  p_message:decode_msg(Bin, m_brave_one_win_player_toc);
decode(2901, Bin) ->
  p_message:decode_msg(Bin, m_step_by_step_sy_enter_tos);
decode(2902, Bin) ->
  p_message:decode_msg(Bin, m_step_by_step_sy_enter_toc);
decode(2903, Bin) ->
  p_message:decode_msg(Bin, m_step_by_step_sy_fight_tos);
decode(2904, Bin) ->
  p_message:decode_msg(Bin, m_step_by_step_sy_fight_toc);
decode(2905, Bin) ->
  p_message:decode_msg(Bin, m_step_by_step_sy_get_award_tos);
decode(2906, Bin) ->
  p_message:decode_msg(Bin, m_step_by_step_sy_get_award_toc);
decode(2907, Bin) ->
  p_message:decode_msg(Bin, m_step_by_step_sy_fight_result_toc);
decode(3001, Bin) ->
  p_message:decode_msg(Bin, m_turn_table_draw_tos);
decode(3002, Bin) ->
  p_message:decode_msg(Bin, m_turn_table_draw_toc);
decode(3003, Bin) ->
  p_message:decode_msg(Bin, m_turn_table_get_award_tos);
decode(3004, Bin) ->
  p_message:decode_msg(Bin, m_turn_table_get_award_toc);
decode(3005, Bin) ->
  p_message:decode_msg(Bin, m_turn_table_notice_reset_toc);
decode(3101, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_get_room_list_tos);
decode(3102, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_get_room_list_toc);
decode(3103, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_create_room_tos);
decode(3104, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_create_room_toc);
decode(3105, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_join_room_tos);
decode(3106, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_join_room_toc);
decode(3107, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_start_tos);
decode(3108, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_start_toc);
decode(3109, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_kick_out_player_tos);
decode(3110, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_ready_tos);
decode(3111, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_ready_toc);
decode(3112, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_leave_room_tos);
decode(3113, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_notice_leave_room_toc);
decode(3114, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_notice_player_join_toc);
decode(3115, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_notice_player_leave_toc);
decode(3116, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_notice_player_ready_toc);
decode(3117, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_notice_player_fight_start_toc);
decode(3118, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_notice_room_owner_change_toc);
decode(3119, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_notice_player_fight_result_toc);
decode(3120, Bin) ->
  p_message:decode_msg(Bin, m_shi_shi_room_notice_shi_shi_value_toc);
decode(3201, Bin) ->
  p_message:decode_msg(Bin, m_hero_charge_hero_parts_tos);
decode(3202, Bin) ->
  p_message:decode_msg(Bin, m_hero_charge_hero_parts_toc);
decode(3203, Bin) ->
  p_message:decode_msg(Bin, m_hero_unlock_hero_tos);
decode(3204, Bin) ->
  p_message:decode_msg(Bin, m_hero_unlock_hero_toc);
decode(3205, Bin) ->
  p_message:decode_msg(Bin, m_hero_hero_up_star_tos);
decode(3206, Bin) ->
  p_message:decode_msg(Bin, m_hero_hero_up_star_toc);
decode(3207, Bin) ->
  p_message:decode_msg(Bin, m_hero_notice_hero_unlock_parts_toc);
decode(3208, Bin) ->
  p_message:decode_msg(Bin, m_hero_notice_unlock_hero_toc);
decode(3301, Bin) ->
  p_message:decode_msg(Bin, m_card_get_award_tos);
decode(3302, Bin) ->
  p_message:decode_msg(Bin, m_card_get_award_toc);
decode(3303, Bin) ->
  p_message:decode_msg(Bin, m_card_notice_card_update_toc);
decode(3401, Bin) ->
  p_message:decode_msg(Bin, m_seize_treasure_currency_seize_treasure_type_toc);
decode(3402, Bin) ->
  p_message:decode_msg(Bin, m_seize_treasure_get_treasure_tos);
decode(3403, Bin) ->
  p_message:decode_msg(Bin, m_seize_treasure_get_treasure_toc);
decode(3404, Bin) ->
  p_message:decode_msg(Bin, m_seize_treasure_get_extra_award_tos);
decode(3405, Bin) ->
  p_message:decode_msg(Bin, m_seize_treasure_get_extra_award_toc);
decode(3406, Bin) ->
  p_message:decode_msg(Bin, m_seize_treasure_get_extra_award_status_tos);
decode(3407, Bin) ->
  p_message:decode_msg(Bin, m_seize_treasure_get_extra_award_status_toc);
decode(3501, Bin) ->
  p_message:decode_msg(Bin, m_card_summon_do_summon_tos);
decode(3502, Bin) ->
  p_message:decode_msg(Bin, m_card_summon_do_summon_toc);
decode(3601, Bin) ->
  p_message:decode_msg(Bin, m_shen_long_draw_tos);
decode(3602, Bin) ->
  p_message:decode_msg(Bin, m_shen_long_draw_toc);
decode(3603, Bin) ->
  p_message:decode_msg(Bin, m_shen_long_notice_scene_shen_long_state_toc);
decode(3701, Bin) ->
  p_message:decode_msg(Bin, m_skill_use_skill_tos);
decode(3702, Bin) ->
  p_message:decode_msg(Bin, m_skill_use_skill_toc);
decode(3703, Bin) ->
  p_message:decode_msg(Bin, m_skill_notice_active_skill_change_toc);
decode(3801, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_task_info_notice_toc);
decode(3802, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_task_daily_update_notice_toc);
decode(3803, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_task_month_update_notice_toc);
decode(3804, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_task_daily_reward_collect_tos);
decode(3805, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_task_daily_reward_collect_toc);
decode(3806, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_task_month_reward_collect_tos);
decode(3807, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_task_month_reward_collect_toc);
decode(3808, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_purchase_unlock_tos);
decode(3809, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_purchase_unlock_toc);
decode(3810, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_reward_info_notice_toc);
decode(3811, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_purchase_level_tos);
decode(3812, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_purchase_level_toc);
decode(3813, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_collect_level_reward_tos);
decode(3814, Bin) ->
  p_message:decode_msg(Bin, m_tongxingzheng_collect_level_reward_toc);
decode(3901, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_info_notice_toc);
decode(3902, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_get_info_tos);
decode(3903, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_get_info_toc);
decode(3904, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_do_draw_tos);
decode(3905, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_do_draw_toc);
decode(3906, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_reward_double_tos);
decode(3907, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_reward_double_toc);
decode(3908, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_result_tos);
decode(3909, Bin) ->
  p_message:decode_msg(Bin, m_jiangjinchi_result_toc);
decode(4001, Bin) ->
  p_message:decode_msg(Bin, m_leichong_info_query_tos);
decode(4002, Bin) ->
  p_message:decode_msg(Bin, m_leichong_info_query_toc);
decode(4003, Bin) ->
  p_message:decode_msg(Bin, m_leichong_get_reward_tos);
decode(4004, Bin) ->
  p_message:decode_msg(Bin, m_leichong_get_reward_toc);
decode(4101, Bin) ->
  p_message:decode_msg(Bin, m_special_prop_notice_init_data_toc);
decode(4102, Bin) ->
  p_message:decode_msg(Bin, m_special_prop_notice_update_special_prop_toc);
decode(4103, Bin) ->
  p_message:decode_msg(Bin, m_special_prop_special_prop_merge_tos);
decode(4104, Bin) ->
  p_message:decode_msg(Bin, m_special_prop_special_prop_merge_toc);
decode(4105, Bin) ->
  p_message:decode_msg(Bin, m_special_prop_sell_special_prop_tos);
decode(4106, Bin) ->
  p_message:decode_msg(Bin, m_special_prop_sell_special_prop_toc);
decode(4201, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_do_laba_tos);
decode(4202, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_do_laba_toc);
decode(4203, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_do_turntable_tos);
decode(4204, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_do_turntable_toc);
decode(4205, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_do_money_three_tos);
decode(4206, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_do_money_three_toc);
decode(4207, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_notice_money_three_result_toc);
decode(4208, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_notice_task_toc);
decode(4209, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_query_balls_data_tos);
decode(4210, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_query_balls_data_toc);
decode(4211, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_notice_drop_ball_toc);
decode(4212, Bin) ->
  p_message:decode_msg(Bin, m_scene_event_notice_balls_result_toc);
decode(4301, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_get_info_tos);
decode(4302, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_get_info_toc);
decode(4303, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_match_tos);
decode(4304, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_match_toc);
decode(4305, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_cancel_match_tos);
decode(4306, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_cancel_match_toc);
decode(4307, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_notice_match_num_change_toc);
decode(4308, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_notice_match_fail_toc);
decode(4309, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_notice_rank_toc);
decode(4310, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_notice_time_toc);
decode(4311, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_notice_result_toc);
decode(4401, Bin) ->
  p_message:decode_msg(Bin, m_first_charge_init_data_first_recharge_toc);
decode(4402, Bin) ->
  p_message:decode_msg(Bin, m_first_charge_notice_data_update_toc);
decode(4403, Bin) ->
  p_message:decode_msg(Bin, m_first_charge_get_award_tos);
decode(4404, Bin) ->
  p_message:decode_msg(Bin, m_first_charge_get_award_toc);
decode(4501, Bin) ->
  p_message:decode_msg(Bin, m_verify_code_sms_code_tos);
decode(4502, Bin) ->
  p_message:decode_msg(Bin, m_verify_code_sms_code_toc);
decode(4503, Bin) ->
  p_message:decode_msg(Bin, m_verify_code_get_area_code_tos);
decode(4504, Bin) ->
  p_message:decode_msg(Bin, m_verify_code_get_area_code_toc);
decode(4505, Bin) ->
  p_message:decode_msg(Bin, m_verify_code_get_my_sms_code_toc);
decode(4601, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_notice_unread_num_toc);
decode(4602, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_get_room_list_tos);
decode(4603, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_get_room_list_toc);
decode(4604, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_exit_room_list_tos);
decode(4605, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_add_room_toc);
decode(4606, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_delete_room_toc);
decode(4607, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_notice_room_people_num_change_toc);
decode(4608, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_create_room_tos);
decode(4609, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_create_room_toc);
decode(4610, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_world_recruit_tos);
decode(4611, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_world_recruit_toc);
decode(4612, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_recruit_tos);
decode(4613, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_recruit_toc);
decode(4614, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_join_room_tos);
decode(4615, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_join_room_toc);
decode(4616, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_leave_room_tos);
decode(4617, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_leave_room_toc);
decode(4618, Bin) ->
  p_message:decode_msg(Bin, m_match_scene_room_notice_people_num_change_toc);
decode(4701, Bin) ->
  p_message:decode_msg(Bin, m_gift_select_player_tos);
decode(4702, Bin) ->
  p_message:decode_msg(Bin, m_gift_select_player_toc);
decode(4703, Bin) ->
  p_message:decode_msg(Bin, m_gift_give_gift_tos);
decode(4704, Bin) ->
  p_message:decode_msg(Bin, m_gift_give_gift_toc);
decode(4705, Bin) ->
  p_message:decode_msg(Bin, m_gift_init_mail_info_toc);
decode(4706, Bin) ->
  p_message:decode_msg(Bin, m_gift_read_mail_tos);
decode(4707, Bin) ->
  p_message:decode_msg(Bin, m_gift_read_mail_toc);
decode(4708, Bin) ->
  p_message:decode_msg(Bin, m_gift_get_item_mail_tos);
decode(4709, Bin) ->
  p_message:decode_msg(Bin, m_gift_get_item_mail_toc);
decode(4710, Bin) ->
  p_message:decode_msg(Bin, m_gift_delete_mail_tos);
decode(4711, Bin) ->
  p_message:decode_msg(Bin, m_gift_delete_mail_toc);
decode(4712, Bin) ->
  p_message:decode_msg(Bin, m_gift_add_mail_toc);
decode(4713, Bin) ->
  p_message:decode_msg(Bin, m_gift_remove_mail_toc);
decode(4714, Bin) ->
  p_message:decode_msg(Bin, m_gift_gift_mail_record_tos);
decode(4715, Bin) ->
  p_message:decode_msg(Bin, m_gift_gift_mail_record_toc);
decode(4801, Bin) ->
  p_message:decode_msg(Bin, m_wheel_join_wheel_tos);
decode(4802, Bin) ->
  p_message:decode_msg(Bin, m_wheel_join_wheel_toc);
decode(4803, Bin) ->
  p_message:decode_msg(Bin, m_wheel_bet_tos);
decode(4804, Bin) ->
  p_message:decode_msg(Bin, m_wheel_bet_toc);
decode(4805, Bin) ->
  p_message:decode_msg(Bin, m_wheel_notice_bet_toc);
decode(4806, Bin) ->
  p_message:decode_msg(Bin, m_wheel_get_record_tos);
decode(4807, Bin) ->
  p_message:decode_msg(Bin, m_wheel_get_record_toc);
decode(4808, Bin) ->
  p_message:decode_msg(Bin, m_wheel_get_bet_record_tos);
decode(4809, Bin) ->
  p_message:decode_msg(Bin, m_wheel_get_bet_record_toc);
decode(4810, Bin) ->
  p_message:decode_msg(Bin, m_wheel_get_player_list_tos);
decode(4811, Bin) ->
  p_message:decode_msg(Bin, m_wheel_get_player_list_toc);
decode(4812, Bin) ->
  p_message:decode_msg(Bin, m_wheel_balance_toc);
decode(4813, Bin) ->
  p_message:decode_msg(Bin, m_wheel_exit_wheel_tos);
decode(4814, Bin) ->
  p_message:decode_msg(Bin, m_wheel_use_last_bet_tos);
decode(4815, Bin) ->
  p_message:decode_msg(Bin, m_wheel_use_last_bet_toc);
decode(4901, Bin) ->
  p_message:decode_msg(Bin, m_laba_spin_tos);
decode(4902, Bin) ->
  p_message:decode_msg(Bin, m_laba_spin_toc);
decode(4903, Bin) ->
  p_message:decode_msg(Bin, m_laba_spin2_tos);
decode(4904, Bin) ->
  p_message:decode_msg(Bin, m_laba_spin2_toc);
decode(4905, Bin) ->
  p_message:decode_msg(Bin, m_laba_get_adjust_info_tos);
decode(4906, Bin) ->
  p_message:decode_msg(Bin, m_laba_get_adjust_info_toc);
decode(5001, Bin) ->
  p_message:decode_msg(Bin, m_one_vs_one_get_room_list_tos);
decode(5002, Bin) ->
  p_message:decode_msg(Bin, m_one_vs_one_get_room_list_toc);
decode(5003, Bin) ->
  p_message:decode_msg(Bin, m_one_vs_one_exit_room_list_tos);
decode(5004, Bin) ->
  p_message:decode_msg(Bin, m_one_vs_one_join_room_tos);
decode(5005, Bin) ->
  p_message:decode_msg(Bin, m_one_vs_one_join_room_toc);
decode(5006, Bin) ->
  p_message:decode_msg(Bin, m_one_vs_one_notice_update_room_data_toc);
decode(5007, Bin) ->
  p_message:decode_msg(Bin, m_one_vs_one_notice_scene_skill_limit_toc);
decode(5101, Bin) ->
  p_message:decode_msg(Bin, m_player_chat_channel_chat_tos);
decode(5102, Bin) ->
  p_message:decode_msg(Bin, m_player_chat_channel_chat_toc);
decode(5103, Bin) ->
  p_message:decode_msg(Bin, m_player_chat_broadcast_channel_msg_list_toc);
decode(5104, Bin) ->
  p_message:decode_msg(Bin, m_player_chat_get_player_chat_info_tos);
decode(5105, Bin) ->
  p_message:decode_msg(Bin, m_player_chat_get_player_chat_info_toc);
decode(5106, Bin) ->
  p_message:decode_msg(Bin, m_player_chat_get_player_list_online_status_tos);
decode(5107, Bin) ->
  p_message:decode_msg(Bin, m_player_chat_get_player_list_online_status_toc);
decode(5201, Bin) ->
  p_message:decode_msg(Bin, m_room_get_room_list_tos);
decode(5202, Bin) ->
  p_message:decode_msg(Bin, m_room_get_room_list_toc);
decode(5203, Bin) ->
  p_message:decode_msg(Bin, m_room_leave_room_list_tos);
decode(5204, Bin) ->
  p_message:decode_msg(Bin, m_room_notice_room_list_change_toc);
decode(5205, Bin) ->
  p_message:decode_msg(Bin, m_room_enter_room_tos);
decode(5206, Bin) ->
  p_message:decode_msg(Bin, m_room_enter_room_toc);
decode(5207, Bin) ->
  p_message:decode_msg(Bin, m_room_leave_room_tos);
decode(5208, Bin) ->
  p_message:decode_msg(Bin, m_room_notice_room_start_toc);
decode(5209, Bin) ->
  p_message:decode_msg(Bin, m_room_notice_fighting_toc);
decode(5210, Bin) ->
  p_message:decode_msg(Bin, m_room_ready_tos);
decode(5211, Bin) ->
  p_message:decode_msg(Bin, m_room_notice_player_ready_toc);
decode(5212, Bin) ->
  p_message:decode_msg(Bin, m_room_add_frame_action_tos);
decode(5213, Bin) ->
  p_message:decode_msg(Bin, m_room_push_frame_info_toc);
decode(5214, Bin) ->
  p_message:decode_msg(Bin, m_room_fight_result_tos);
decode(5215, Bin) ->
  p_message:decode_msg(Bin, m_room_fight_result_toc);
decode(MsgNum, _) ->
    exit({unexpected_proto_num, MsgNum}).
