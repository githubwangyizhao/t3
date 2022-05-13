-module(socket_router).
-export([handle/2]).
-include("common.hrl").
-include("prof.hrl").

-include("p_message.hrl").



handle(<<>>, State = #conn{player_id  = _PlayerId}) ->
    State;
handle(<<_IsZip:8, Method:32/unsigned, Data/binary>>, State = #conn{status = Status, player_id  = _PlayerId}) ->
    %%Data1 = if IsZip == 1 -> zlib:uncompress(Data); true -> Data end,
    ?START_PROF,
    NewState = handle(Method, Data, State),
    ?STOP_PROF(?MODULE, receive_proto, Method),
    NewState.

handle(1, Bin, State = #conn{player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_login_login_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_login:login(Msg, State);
handle(3, Bin, State = #conn{status = ?CLIENT_STATE_WAIT_CREATE_ROLE, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_login_create_role_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_login:create_role(Msg, State);
handle(5, Bin, State = #conn{status = ?CLIENT_STATE_WAIT_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_login_enter_game_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_login:enter_game(Msg, State);
handle(6, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_login_heart_beat_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_login:heart_beat(Msg, State);
handle(106, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_change_pk_mode_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:change_pk_mode(Msg, State);
handle(108, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_get_player_attr_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:get_player_attr(Msg, State);
handle(110, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_change_name_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:change_name(Msg, State);
handle(112, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_change_sex_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:change_sex(Msg, State);
handle(114, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_update_client_data_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:update_client_data(Msg, State);
handle(115, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_delete_client_data_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:delete_client_data(Msg, State);
handle(116, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_adjust_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:adjust(Msg, State);
handle(118, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_customer_url_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:customer_url(Msg, State);
handle(120, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_visitor_binding_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:visitor_binding(Msg, State);
handle(122, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_get_server_time_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:get_server_time(Msg, State);
handle(124, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_modify_nickname_gender_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:modify_nickname_gender(Msg, State);
handle(126, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_set_player_data_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:set_player_data(Msg, State);
handle(129, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_collect_delay_rewards_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:collect_delay_rewards(Msg, State);
handle(130, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_level_upgrade_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:level_upgrade(Msg, State);
handle(132, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_bind_mobile_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:bind_mobile(Msg, State);
handle(135, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_get_level_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:get_level_award(Msg, State);
handle(137, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_update_player_signature_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:update_player_signature(Msg, State);
handle(139, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_get_player_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:get_player_info(Msg, State);
handle(141, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_world_tree_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player:world_tree_award(Msg, State);
handle(201, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_enter_scene_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:enter_scene(Msg, State);
handle(204, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_load_scene_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:load_scene(Msg, State);
handle(209, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_player_rebirth_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:player_rebirth(Msg, State);
handle(211, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_player_move_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:player_move(Msg, State);
handle(212, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_player_move_step_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:player_move_step(Msg, State);
handle(213, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_player_stop_move_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:player_stop_move(Msg, State);
handle(227, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_query_player_pos_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:query_player_pos(Msg, State);
handle(231, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_transmit_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:transmit(Msg, State);
handle(235, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_get_monster_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:get_monster_list(Msg, State);
handle(240, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_notice_fanpai_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:notice_fanpai(Msg, State);
handle(243, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_challenge_boss_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:challenge_boss(Msg, State);
handle(244, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_send_msg_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:send_msg(Msg, State);
handle(247, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_player_collect_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:player_collect(Msg, State);
handle(250, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_show_action_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:show_action(Msg, State);
handle(261, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_enter_single_scene_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene:enter_single_scene(Msg, State);
handle(301, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_fight_fight_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_fight:fight(Msg, State);
handle(306, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_fight_use_item_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_fight:use_item(Msg, State);
handle(311, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_fight_wait_skill_trigger_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_fight:wait_skill_trigger(Msg, State);
handle(312, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_fight_dizzy_time_reduce_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_fight:dizzy_time_reduce(Msg, State);
handle(401, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_times_add_times_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_times:add_times(Msg, State);
handle(502, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_prop_use_item_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_prop:use_item(Msg, State);
handle(504, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_prop_sell_item_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_prop:sell_item(Msg, State);
handle(506, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_prop_merge_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_prop:merge(Msg, State);
handle(601, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_chat_channel_chat_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_chat:channel_chat(Msg, State);
handle(701, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_challenge_mission_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:challenge_mission(Msg, State);
handle(704, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_exit_mission_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:exit_mission(Msg, State);
handle(710, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:get_award(Msg, State);
handle(713, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_boss_rebirth_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:boss_rebirth(Msg, State);
handle(718, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_guess_get_record_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:guess_get_record(Msg, State);
handle(725, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_either_either_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:either_either(Msg, State);
handle(727, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_scene_boss_bet_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:scene_boss_bet(Msg, State);
handle(728, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_scene_boss_bet_reset_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:scene_boss_bet_reset(Msg, State);
handle(735, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_lucky_boss_bet_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:lucky_boss_bet(Msg, State);
handle(737, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_lucky_boss_bet_reset_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:lucky_boss_bet_reset(Msg, State);
handle(741, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_lucky_boss_status_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:lucky_boss_status(Msg, State);
handle(747, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_hero_versus_boss_bet_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:hero_versus_boss_bet(Msg, State);
handle(749, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_hero_versus_boss_bet_reset_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:hero_versus_boss_bet_reset(Msg, State);
handle(757, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mission_get_hero_versus_boss_record_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mission:get_hero_versus_boss_record(Msg, State);
handle(801, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mail_get_mail_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mail:get_mail_info(Msg, State);
handle(803, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mail_read_mail_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mail:read_mail(Msg, State);
handle(805, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mail_get_item_mail_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mail:get_item_mail(Msg, State);
handle(807, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_mail_delete_mail_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_mail:delete_mail(Msg, State);
handle(901, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_vip_get_vip_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_vip:get_vip_award(Msg, State);
handle(10001, Bin, State = #conn{player_id = _PlayerId}) ->
    ?ASSERT(?IS_DEBUG, {proto_no_debug, 10001}),
    Msg = p_message:decode_msg(Bin, m_debug_debug_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_debug:debug(Msg, State);
handle(1001, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_client_log_client_log_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_client_log:client_log(Msg, State);
handle(1101, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_achievement_get_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_achievement:get_info(Msg, State);
handle(1103, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_achievement_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_achievement:get_award(Msg, State);
handle(1201, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_rank_get_rank_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_rank:get_rank_info(Msg, State);
handle(1301, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shop_get_shop_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shop:get_shop_info(Msg, State);
handle(1303, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shop_shop_item_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shop:shop_item(Msg, State);
handle(1502, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_charge_charge_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_charge:charge(Msg, State);
handle(1505, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_charge_get_charge_type_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_charge:get_charge_type(Msg, State);
handle(1602, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_invest_get_invest_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_invest:get_invest_award(Msg, State);
handle(1701, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_everyday_sign_everyday_sign_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_everyday_sign:everyday_sign(Msg, State);
handle(1801, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_seven_login_give_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_seven_login:give_award(Msg, State);
handle(1901, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_platform_function_share_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_platform_function:share(Msg, State);
handle(1903, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_platform_function_get_share_friend_give_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_platform_function:get_share_friend_give(Msg, State);
handle(1908, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_platform_function_get_platform_award_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_platform_function:get_platform_award_info(Msg, State);
handle(1910, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_platform_function_get_share_task_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_platform_function:get_share_task_info(Msg, State);
handle(1912, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_platform_function_get_share_task_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_platform_function:get_share_task_award(Msg, State);
handle(1915, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_platform_function_refresh_open_key_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_platform_function:refresh_open_key(Msg, State);
handle(2001, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_gift_code_gift_code_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_gift_code:gift_code(Msg, State);
handle(2101, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_video_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_video:get_award(Msg, State);
handle(2201, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_get_room_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:get_room_list(Msg, State);
handle(2203, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_join_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:join_room(Msg, State);
handle(2205, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_create_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:create_room(Msg, State);
handle(2207, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_start_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:start(Msg, State);
handle(2209, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_participate_in_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:participate_in(Msg, State);
handle(2211, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_kick_out_player_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:kick_out_player(Msg, State);
handle(2212, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_set_is_all_ready_start_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:set_is_all_ready_start(Msg, State);
handle(2214, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_ready_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:ready(Msg, State);
handle(2216, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_many_people_boss_leave_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_many_people_boss:leave_room(Msg, State);
handle(2301, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_sys_common_change_state_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_sys_common:change_state(Msg, State);
handle(2401, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_daily_task_get_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_daily_task:get_info(Msg, State);
handle(2403, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_daily_task_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_daily_task:get_award(Msg, State);
handle(2407, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_daily_task_get_points_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_daily_task:get_points_award(Msg, State);
handle(2501, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_promote_get_promote_record_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_promote:get_promote_record(Msg, State);
handle(2503, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_promote_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_promote:get_award(Msg, State);
handle(2507, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_promote_invitation_code_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_promote:invitation_code(Msg, State);
handle(2601, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_task_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_task:get_award(Msg, State);
handle(2604, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_task_bounty_query_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_task:bounty_query_info(Msg, State);
handle(2606, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_task_bounty_accept_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_task:bounty_accept(Msg, State);
handle(2608, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_task_bounty_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_task:bounty_get_award(Msg, State);
handle(2610, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_task_bounty_refresh_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_task:bounty_refresh(Msg, State);
handle(2702, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_red_packet_get_red_packet_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_red_packet:get_red_packet(Msg, State);
handle(2801, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_brave_one_get_info_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_brave_one:get_info_list(Msg, State);
handle(2803, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_brave_one_create_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_brave_one:create(Msg, State);
handle(2805, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_brave_one_enter_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_brave_one:enter(Msg, State);
handle(2807, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_brave_one_clean_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_brave_one:clean(Msg, State);
handle(2901, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_step_by_step_sy_enter_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_step_by_step_sy:enter(Msg, State);
handle(2903, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_step_by_step_sy_fight_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_step_by_step_sy:fight(Msg, State);
handle(2905, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_step_by_step_sy_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_step_by_step_sy:get_award(Msg, State);
handle(3001, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_turn_table_draw_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_turn_table:draw(Msg, State);
handle(3003, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_turn_table_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_turn_table:get_award(Msg, State);
handle(3101, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shi_shi_room_get_room_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shi_shi_room:get_room_list(Msg, State);
handle(3103, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shi_shi_room_create_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shi_shi_room:create_room(Msg, State);
handle(3105, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shi_shi_room_join_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shi_shi_room:join_room(Msg, State);
handle(3107, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shi_shi_room_start_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shi_shi_room:start(Msg, State);
handle(3109, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shi_shi_room_kick_out_player_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shi_shi_room:kick_out_player(Msg, State);
handle(3110, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shi_shi_room_ready_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shi_shi_room:ready(Msg, State);
handle(3112, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shi_shi_room_leave_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shi_shi_room:leave_room(Msg, State);
handle(3201, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_hero_charge_hero_parts_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_hero:charge_hero_parts(Msg, State);
handle(3203, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_hero_unlock_hero_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_hero:unlock_hero(Msg, State);
handle(3205, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_hero_hero_up_star_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_hero:hero_up_star(Msg, State);
handle(3301, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_card_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_card:get_award(Msg, State);
handle(3402, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_seize_treasure_get_treasure_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_seize_treasure:get_treasure(Msg, State);
handle(3404, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_seize_treasure_get_extra_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_seize_treasure:get_extra_award(Msg, State);
handle(3406, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_seize_treasure_get_extra_award_status_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_seize_treasure:get_extra_award_status(Msg, State);
handle(3501, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_card_summon_do_summon_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_card_summon:do_summon(Msg, State);
handle(3601, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_shen_long_draw_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_shen_long:draw(Msg, State);
handle(3701, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_skill_use_skill_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_skill:use_skill(Msg, State);
handle(3804, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_tongxingzheng_task_daily_reward_collect_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_tongxingzheng:task_daily_reward_collect(Msg, State);
handle(3806, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_tongxingzheng_task_month_reward_collect_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_tongxingzheng:task_month_reward_collect(Msg, State);
handle(3808, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_tongxingzheng_purchase_unlock_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_tongxingzheng:purchase_unlock(Msg, State);
handle(3811, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_tongxingzheng_purchase_level_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_tongxingzheng:purchase_level(Msg, State);
handle(3813, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_tongxingzheng_collect_level_reward_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_tongxingzheng:collect_level_reward(Msg, State);
handle(3902, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_jiangjinchi_get_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_jiangjinchi:get_info(Msg, State);
handle(3904, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_jiangjinchi_do_draw_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_jiangjinchi:do_draw(Msg, State);
handle(3906, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_jiangjinchi_reward_double_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_jiangjinchi:reward_double(Msg, State);
handle(3908, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_jiangjinchi_result_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_jiangjinchi:result(Msg, State);
handle(4001, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_leichong_info_query_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_leichong:info_query(Msg, State);
handle(4003, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_leichong_get_reward_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_leichong:get_reward(Msg, State);
handle(4103, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_special_prop_special_prop_merge_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_special_prop:special_prop_merge(Msg, State);
handle(4105, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_special_prop_sell_special_prop_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_special_prop:sell_special_prop(Msg, State);
handle(4201, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_event_do_laba_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene_event:do_laba(Msg, State);
handle(4203, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_event_do_turntable_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene_event:do_turntable(Msg, State);
handle(4205, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_event_do_money_three_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene_event:do_money_three(Msg, State);
handle(4209, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_scene_event_query_balls_data_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_scene_event:query_balls_data(Msg, State);
handle(4301, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_get_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene:get_info(Msg, State);
handle(4303, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_match_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene:match(Msg, State);
handle(4305, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_cancel_match_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene:cancel_match(Msg, State);
handle(4403, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_first_charge_get_award_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_first_charge:get_award(Msg, State);
handle(4501, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_verify_code_sms_code_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_verify_code:sms_code(Msg, State);
handle(4503, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_verify_code_get_area_code_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_verify_code:get_area_code(Msg, State);
handle(4602, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_room_get_room_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene_room:get_room_list(Msg, State);
handle(4604, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_room_exit_room_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene_room:exit_room_list(Msg, State);
handle(4608, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_room_create_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene_room:create_room(Msg, State);
handle(4610, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_room_world_recruit_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene_room:world_recruit(Msg, State);
handle(4612, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_room_recruit_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene_room:recruit(Msg, State);
handle(4614, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_room_join_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene_room:join_room(Msg, State);
handle(4616, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_match_scene_room_leave_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_match_scene_room:leave_room(Msg, State);
handle(4701, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_gift_select_player_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_gift:select_player(Msg, State);
handle(4703, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_gift_give_gift_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_gift:give_gift(Msg, State);
handle(4706, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_gift_read_mail_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_gift:read_mail(Msg, State);
handle(4708, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_gift_get_item_mail_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_gift:get_item_mail(Msg, State);
handle(4710, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_gift_delete_mail_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_gift:delete_mail(Msg, State);
handle(4714, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_gift_gift_mail_record_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_gift:gift_mail_record(Msg, State);
handle(4801, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_wheel_join_wheel_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_wheel:join_wheel(Msg, State);
handle(4803, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_wheel_bet_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_wheel:bet(Msg, State);
handle(4806, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_wheel_get_record_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_wheel:get_record(Msg, State);
handle(4808, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_wheel_get_bet_record_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_wheel:get_bet_record(Msg, State);
handle(4810, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_wheel_get_player_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_wheel:get_player_list(Msg, State);
handle(4813, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_wheel_exit_wheel_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_wheel:exit_wheel(Msg, State);
handle(4814, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_wheel_use_last_bet_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_wheel:use_last_bet(Msg, State);
handle(4901, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_laba_spin_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_laba:spin(Msg, State);
handle(4903, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_laba_spin2_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_laba:spin2(Msg, State);
handle(4905, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_laba_get_adjust_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_laba:get_adjust_info(Msg, State);
handle(5001, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_one_vs_one_get_room_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_one_vs_one:get_room_list(Msg, State);
handle(5003, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_one_vs_one_exit_room_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_one_vs_one:exit_room_list(Msg, State);
handle(5004, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_one_vs_one_join_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_one_vs_one:join_room(Msg, State);
handle(5101, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_chat_channel_chat_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player_chat:channel_chat(Msg, State);
handle(5104, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_chat_get_player_chat_info_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player_chat:get_player_chat_info(Msg, State);
handle(5106, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_player_chat_get_player_list_online_status_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_player_chat:get_player_list_online_status(Msg, State);
handle(5201, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_room_get_room_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_room:get_room_list(Msg, State);
handle(5203, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_room_leave_room_list_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_room:leave_room_list(Msg, State);
handle(5205, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_room_enter_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_room:enter_room(Msg, State);
handle(5207, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_room_leave_room_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_room:leave_room(Msg, State);
handle(5210, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_room_ready_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_room:ready(Msg, State);
handle(5212, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_room_add_frame_action_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_room:add_frame_action(Msg, State);
handle(5214, Bin, State = #conn{status = ?CLIENT_STATE_ENTER_GAME, player_id = _PlayerId}) ->
    Msg = p_message:decode_msg(Bin, m_room_fight_result_tos),
    mod_log:write_player_receive_proto_log(_PlayerId, Msg),
    api_room:fight_result(Msg, State);
handle(MsgNum, _, #conn{status = Status}) ->
    exit({unexpected_proto_num, MsgNum, Status}).
