%%% Generated automatically, no need to modify.
-module(db_load).
-include("gen/db.hrl").

-ifdef(debug).
-define(IS_DEBUG, true).
-else.
-define(IS_DEBUG, false).
-endif.

%% API
-export([
    load_power_data/0,
    load_hot_data/1,
    unload_hot_data/1,
    safe_load_hot_data/1,
    safe_unload_hot_data/1,
    load/1,
    load/2,
    unload/2
]).

load_power_data() ->
    {_, S, _} = os:timestamp(),
    LoadTables = [account,account_charge_white,account_share_data,
                  activity_award,activity_info,boss_one_on_one,brave_one,
                  c_game_server,c_server_node,charge_info_record,
                  charge_ip_white_record,charge_order_request_record,
                  client_versin,consume_statistics,gift_code,gift_code_type,
                  jiangjinchi,laba_adjust,login_notice,match_scene_data,
                  mission_guess_boss,mission_ranking,oauth_order_log,
                  one_vs_one_rank_data,player,player_charge_activity,
                  player_charge_info_record,player_charge_record,
                  player_chat_data,player_conditions_data,player_data,
                  player_function,player_game_data,player_gift_mail,
                  player_gift_mail_log,player_mail,player_offline_apply,
                  player_prop,player_server_data,player_sys_attr,
                  player_times_data,promote,promote_info,promote_record,
                  rank_info,red_packet_condition,robot_player_data,
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
            load(Table)
        end,
        LoadTables
    ),
    {_, S1, _} = os:timestamp(),
    S2 = S1 - S,
    io:format("~nAll table load success, used ~p minute, ~p second!~n~n", [S2 div 60, S2 rem 60]),
    ok.

safe_load_hot_data(PlayerId) ->
    case get(is_load_hot_data) of
        true ->
            already_load;
        _ ->
            db_load_proxy:load(PlayerId),
            put(is_load_hot_data, true),
            ok
    end.

load_hot_data(PlayerId) ->
    lists:foreach(
        fun(Table) ->
            load(Table, PlayerId)
        end,
        [player_achievement,player_activity_condition,player_activity_game,
         player_activity_game_info,player_activity_info,player_activity_task,
         player_adjust_rebound,player_bounty_task,player_card,
         player_card_book,player_card_summon,player_card_title,
         player_charge_shop,player_client_data,player_condition_activity,
         player_daily_points,player_daily_task,player_everyday_charge,
         player_everyday_sign,player_fight_adjust,player_finish_share_task,
         player_first_charge,player_first_charge_day,player_game_config,
         player_gift_code,player_hero,player_hero_parts,player_hero_use,
         player_invest,player_invest_type,player_invite_friend,
         player_invite_friend_log,player_jiangjinchi,player_laba_data,
         player_leichong,player_mission_data,player_online_award,
         player_online_info,player_passive_skill,player_platform_award,
         player_prerogative_card,player_send_gamebar_msg,player_seven_login,
         player_share,player_share_friend,player_share_task,
         player_share_task_award,player_shen_long,player_shop,
         player_special_prop,player_sys_common,player_task,
         player_task_share_award,player_title,player_vip,player_vip_award]
    ),
    ok.

safe_unload_hot_data(PlayerId) ->
    db_load_proxy:unload(PlayerId).

unload_hot_data(PlayerId) ->
    lists:foreach(
        fun(Table) ->
            unload(Table, PlayerId)
        end,
        [player_achievement,player_activity_condition,player_activity_game,
         player_activity_game_info,player_activity_info,player_activity_task,
         player_adjust_rebound,player_bounty_task,player_card,
         player_card_book,player_card_summon,player_card_title,
         player_charge_shop,player_client_data,player_condition_activity,
         player_daily_points,player_daily_task,player_everyday_charge,
         player_everyday_sign,player_fight_adjust,player_finish_share_task,
         player_first_charge,player_first_charge_day,player_game_config,
         player_gift_code,player_hero,player_hero_parts,player_hero_use,
         player_invest,player_invest_type,player_invite_friend,
         player_invite_friend_log,player_jiangjinchi,player_laba_data,
         player_leichong,player_mission_data,player_online_award,
         player_online_info,player_passive_skill,player_platform_award,
         player_prerogative_card,player_send_gamebar_msg,player_seven_login,
         player_share,player_share_friend,player_share_task,
         player_share_task_award,player_shen_long,player_shop,
         player_special_prop,player_sys_common,player_task,
         player_task_share_award,player_title,player_vip,player_vip_award]
    ),
    ok.

load(wheel_result_record_accumulate) ->
    io:format("Load table : wheel_result_record_accumulate..............."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `wheel_result_record_accumulate`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `wheel_result_record_accumulate` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_wheel_result_record_accumulate{
                    row_key = {R#db_wheel_result_record_accumulate.type, R#db_wheel_result_record_accumulate.u_id, R#db_wheel_result_record_accumulate.record_type, R#db_wheel_result_record_accumulate.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_wheel_result_record_accumulate, record_info(fields, db_wheel_result_record_accumulate), Fun),
            ets:insert(wheel_result_record_accumulate, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(wheel_result_record) ->
    io:format("Load table : wheel_result_record.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `wheel_result_record`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `wheel_result_record` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_wheel_result_record{
                    row_key = {R#db_wheel_result_record.type, R#db_wheel_result_record.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_wheel_result_record, record_info(fields, db_wheel_result_record), Fun),
            ets:insert(wheel_result_record, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(wheel_pool) ->
    io:format("Load table : wheel_pool..................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `wheel_pool`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `wheel_pool` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_wheel_pool{
                    row_key = {R#db_wheel_pool.type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_wheel_pool, record_info(fields, db_wheel_pool), Fun),
            ets:insert(wheel_pool, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(wheel_player_bet_record_today) ->
    io:format("Load table : wheel_player_bet_record_today................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `wheel_player_bet_record_today`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `wheel_player_bet_record_today` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_wheel_player_bet_record_today{
                    row_key = {R#db_wheel_player_bet_record_today.player_id, R#db_wheel_player_bet_record_today.type, R#db_wheel_player_bet_record_today.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_wheel_player_bet_record_today, record_info(fields, db_wheel_player_bet_record_today), Fun),
            ets:insert(wheel_player_bet_record_today, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(wheel_player_bet_record) ->
    io:format("Load table : wheel_player_bet_record......................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `wheel_player_bet_record`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `wheel_player_bet_record` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_wheel_player_bet_record{
                    row_key = {R#db_wheel_player_bet_record.player_id, R#db_wheel_player_bet_record.type, R#db_wheel_player_bet_record.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_wheel_player_bet_record, record_info(fields, db_wheel_player_bet_record), Fun),
            ets:insert(wheel_player_bet_record, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(unique_id_data) ->
    io:format("Load table : unique_id_data..............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `unique_id_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `unique_id_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_unique_id_data{
                    row_key = {R#db_unique_id_data.type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_unique_id_data, record_info(fields, db_unique_id_data), Fun),
            ets:insert(unique_id_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(tongxingzheng_month_task) ->
    io:format("Load table : tongxingzheng_month_task....................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `tongxingzheng_month_task`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `tongxingzheng_month_task` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_tongxingzheng_month_task{
                    row_key = {R#db_tongxingzheng_month_task.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_tongxingzheng_month_task, record_info(fields, db_tongxingzheng_month_task), Fun),
            ets:insert(tongxingzheng_month_task, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(tongxingzheng_daily_task) ->
    io:format("Load table : tongxingzheng_daily_task....................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `tongxingzheng_daily_task`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `tongxingzheng_daily_task` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_tongxingzheng_daily_task{
                    row_key = {R#db_tongxingzheng_daily_task.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_tongxingzheng_daily_task, record_info(fields, db_tongxingzheng_daily_task), Fun),
            ets:insert(tongxingzheng_daily_task, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(timer_data) ->
    io:format("Load table : timer_data..................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `timer_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `timer_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_timer_data{
                    row_key = {R#db_timer_data.timer_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_timer_data, record_info(fields, db_timer_data), Fun),
            ets:insert(timer_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(test) ->
    io:format("Load table : test........................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `test`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `test` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_test{
                    row_key = {R#db_test.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_test, record_info(fields, db_test), Fun),
            ets:insert(test, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(server_state) ->
    io:format("Load table : server_state................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `server_state`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `server_state` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_server_state{
                    row_key = {R#db_server_state.time}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_server_state, record_info(fields, db_server_state), Fun),
            ets:insert(server_state, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(server_player_fight_adjust) ->
    io:format("Load table : server_player_fight_adjust..................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `server_player_fight_adjust`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `server_player_fight_adjust` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_server_player_fight_adjust{
                    row_key = {R#db_server_player_fight_adjust.player_id, R#db_server_player_fight_adjust.prop_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_server_player_fight_adjust, record_info(fields, db_server_player_fight_adjust), Fun),
            ets:insert(server_player_fight_adjust, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(server_game_config) ->
    io:format("Load table : server_game_config..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `server_game_config`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `server_game_config` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_server_game_config{
                    row_key = {R#db_server_game_config.config_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_server_game_config, record_info(fields, db_server_game_config), Fun),
            ets:insert(server_game_config, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(server_fight_adjust) ->
    io:format("Load table : server_fight_adjust.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `server_fight_adjust`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `server_fight_adjust` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_server_fight_adjust{
                    row_key = {R#db_server_fight_adjust.prop_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_server_fight_adjust, record_info(fields, db_server_fight_adjust), Fun),
            ets:insert(server_fight_adjust, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(server_data) ->
    io:format("Load table : server_data.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `server_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `server_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_server_data{
                    row_key = {R#db_server_data.id, R#db_server_data.key2}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_server_data, record_info(fields, db_server_data), Fun),
            ets:insert(server_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(scene_log) ->
    io:format("Load table : scene_log...................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `scene_log`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `scene_log` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_scene_log{
                    row_key = {R#db_scene_log.scene_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_scene_log, record_info(fields, db_scene_log), Fun),
            ets:insert(scene_log, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(scene_boss_adjust) ->
    io:format("Load table : scene_boss_adjust............................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `scene_boss_adjust`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `scene_boss_adjust` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_scene_boss_adjust{
                    row_key = {R#db_scene_boss_adjust.scene_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_scene_boss_adjust, record_info(fields, db_scene_boss_adjust), Fun),
            ets:insert(scene_boss_adjust, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(scene_adjust) ->
    io:format("Load table : scene_adjust................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `scene_adjust`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `scene_adjust` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_scene_adjust{
                    row_key = {R#db_scene_adjust.scene_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_scene_adjust, record_info(fields, db_scene_adjust), Fun),
            ets:insert(scene_adjust, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(robot_player_scene_cache) ->
    io:format("Load table : robot_player_scene_cache....................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `robot_player_scene_cache`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `robot_player_scene_cache` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_robot_player_scene_cache{
                    row_key = {R#db_robot_player_scene_cache.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_robot_player_scene_cache, record_info(fields, db_robot_player_scene_cache), Fun),
            ets:insert(robot_player_scene_cache, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(robot_player_data) ->
    io:format("Load table : robot_player_data............................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `robot_player_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `robot_player_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_robot_player_data{
                    row_key = {R#db_robot_player_data.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_robot_player_data, record_info(fields, db_robot_player_data), Fun),
            ets:insert(robot_player_data, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(red_packet_condition) ->
    io:format("Load table : red_packet_condition........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `red_packet_condition`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `red_packet_condition` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_red_packet_condition{
                    row_key = {R#db_red_packet_condition.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_red_packet_condition, record_info(fields, db_red_packet_condition), Fun),
            ets:insert(red_packet_condition, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(rank_info) ->
    io:format("Load table : rank_info...................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `rank_info`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `rank_info` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_rank_info{
                    row_key = {R#db_rank_info.rank_id, R#db_rank_info.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_rank_info, record_info(fields, db_rank_info), Fun),
            ets:insert(rank_info, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(promote_record) ->
    io:format("Load table : promote_record..............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `promote_record`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `promote_record` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_promote_record{
                    row_key = {R#db_promote_record.real_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_promote_record, record_info(fields, db_promote_record), Fun),
            ets:insert(promote_record, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(promote_info) ->
    io:format("Load table : promote_info................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `promote_info`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `promote_info` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_promote_info{
                    row_key = {R#db_promote_info.platform_id, R#db_promote_info.acc_id, R#db_promote_info.level}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_promote_info, record_info(fields, db_promote_info), Fun),
            ets:insert(promote_info, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(promote) ->
    io:format("Load table : promote......................................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `promote`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `promote` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_promote{
                    row_key = {R#db_promote.platform_id, R#db_promote.acc_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_promote, record_info(fields, db_promote), Fun),
            ets:insert(promote, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_vip_award) ->
    io:format("Load table : player_vip_award............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_vip_award`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_vip_award` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_vip_award{
                    row_key = {R#db_player_vip_award.player_id, R#db_player_vip_award.level}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_vip_award, record_info(fields, db_player_vip_award), Fun),
            ets:insert(player_vip_award, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_vip) ->
    io:format("Load table : player_vip..................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_vip`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_vip` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_vip{
                    row_key = {R#db_player_vip.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_vip, record_info(fields, db_player_vip), Fun),
            ets:insert(player_vip, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_title) ->
    io:format("Load table : player_title................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_title`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_title` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_title{
                    row_key = {R#db_player_title.player_id, R#db_player_title.title_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_title, record_info(fields, db_player_title), Fun),
            ets:insert(player_title, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_times_data) ->
    io:format("Load table : player_times_data............................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_times_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_times_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_times_data{
                    row_key = {R#db_player_times_data.player_id, R#db_player_times_data.times_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_times_data, record_info(fields, db_player_times_data), Fun),
            ets:insert(player_times_data, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_task_share_award) ->
    io:format("Load table : player_task_share_award......................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_task_share_award`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_task_share_award` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_task_share_award{
                    row_key = {R#db_player_task_share_award.player_id, R#db_player_task_share_award.task_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_task_share_award, record_info(fields, db_player_task_share_award), Fun),
            ets:insert(player_task_share_award, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_task) ->
    io:format("Load table : player_task.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_task`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_task` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_task{
                    row_key = {R#db_player_task.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_task, record_info(fields, db_player_task), Fun),
            ets:insert(player_task, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_sys_common) ->
    io:format("Load table : player_sys_common............................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_sys_common`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_sys_common` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_sys_common{
                    row_key = {R#db_player_sys_common.player_id, R#db_player_sys_common.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_sys_common, record_info(fields, db_player_sys_common), Fun),
            ets:insert(player_sys_common, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_sys_attr) ->
    io:format("Load table : player_sys_attr.............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_sys_attr`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_sys_attr` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_sys_attr{
                    row_key = {R#db_player_sys_attr.player_id, R#db_player_sys_attr.fun_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_sys_attr, record_info(fields, db_player_sys_attr), Fun),
            dets:insert(player_sys_attr, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_special_prop) ->
    io:format("Load table : player_special_prop.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_special_prop`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_special_prop` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_special_prop{
                    row_key = {R#db_player_special_prop.player_id, R#db_player_special_prop.prop_obj_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_special_prop, record_info(fields, db_player_special_prop), Fun),
            ets:insert(player_special_prop, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_shop) ->
    io:format("Load table : player_shop.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_shop`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_shop` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_shop{
                    row_key = {R#db_player_shop.player_id, R#db_player_shop.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_shop, record_info(fields, db_player_shop), Fun),
            ets:insert(player_shop, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_shen_long) ->
    io:format("Load table : player_shen_long............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_shen_long`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_shen_long` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_shen_long{
                    row_key = {R#db_player_shen_long.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_shen_long, record_info(fields, db_player_shen_long), Fun),
            ets:insert(player_shen_long, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_share_task_award) ->
    io:format("Load table : player_share_task_award......................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_share_task_award`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_share_task_award` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_share_task_award{
                    row_key = {R#db_player_share_task_award.player_id, R#db_player_share_task_award.task_type, R#db_player_share_task_award.task_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_share_task_award, record_info(fields, db_player_share_task_award), Fun),
            ets:insert(player_share_task_award, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_share_task) ->
    io:format("Load table : player_share_task............................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_share_task`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_share_task` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_share_task{
                    row_key = {R#db_player_share_task.player_id, R#db_player_share_task.task_type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_share_task, record_info(fields, db_player_share_task), Fun),
            ets:insert(player_share_task, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_share_friend) ->
    io:format("Load table : player_share_friend.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_share_friend`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_share_friend` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_share_friend{
                    row_key = {R#db_player_share_friend.player_id, R#db_player_share_friend.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_share_friend, record_info(fields, db_player_share_friend), Fun),
            ets:insert(player_share_friend, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_share) ->
    io:format("Load table : player_share................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_share`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_share` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_share{
                    row_key = {R#db_player_share.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_share, record_info(fields, db_player_share), Fun),
            ets:insert(player_share, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_seven_login) ->
    io:format("Load table : player_seven_login..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_seven_login`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_seven_login` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_seven_login{
                    row_key = {R#db_player_seven_login.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_seven_login, record_info(fields, db_player_seven_login), Fun),
            ets:insert(player_seven_login, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_server_data) ->
    io:format("Load table : player_server_data..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_server_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_server_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_server_data{
                    row_key = {R#db_player_server_data.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_server_data, record_info(fields, db_player_server_data), Fun),
            dets:insert(player_server_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_send_gamebar_msg) ->
    io:format("Load table : player_send_gamebar_msg......................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_send_gamebar_msg`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_send_gamebar_msg` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_send_gamebar_msg{
                    row_key = {R#db_player_send_gamebar_msg.player_id, R#db_player_send_gamebar_msg.msg_type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_send_gamebar_msg, record_info(fields, db_player_send_gamebar_msg), Fun),
            ets:insert(player_send_gamebar_msg, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_prop) ->
    io:format("Load table : player_prop.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_prop`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_prop` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_prop{
                    row_key = {R#db_player_prop.player_id, R#db_player_prop.prop_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_prop, record_info(fields, db_player_prop), Fun),
            ets:insert(player_prop, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_prerogative_card) ->
    io:format("Load table : player_prerogative_card......................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_prerogative_card`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_prerogative_card` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_prerogative_card{
                    row_key = {R#db_player_prerogative_card.player_id, R#db_player_prerogative_card.type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_prerogative_card, record_info(fields, db_player_prerogative_card), Fun),
            ets:insert(player_prerogative_card, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_platform_award) ->
    io:format("Load table : player_platform_award........................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_platform_award`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_platform_award` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_platform_award{
                    row_key = {R#db_player_platform_award.player_id, R#db_player_platform_award.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_platform_award, record_info(fields, db_player_platform_award), Fun),
            ets:insert(player_platform_award, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_passive_skill) ->
    io:format("Load table : player_passive_skill........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_passive_skill`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_passive_skill` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_passive_skill{
                    row_key = {R#db_player_passive_skill.player_id, R#db_player_passive_skill.passive_skill_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_passive_skill, record_info(fields, db_player_passive_skill), Fun),
            ets:insert(player_passive_skill, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_online_info) ->
    io:format("Load table : player_online_info..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_online_info`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_online_info` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_online_info{
                    row_key = {R#db_player_online_info.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_online_info, record_info(fields, db_player_online_info), Fun),
            ets:insert(player_online_info, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_online_award) ->
    io:format("Load table : player_online_award.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_online_award`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_online_award` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_online_award{
                    row_key = {R#db_player_online_award.player_id, R#db_player_online_award.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_online_award, record_info(fields, db_player_online_award), Fun),
            ets:insert(player_online_award, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_offline_apply) ->
    io:format("Load table : player_offline_apply........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_offline_apply`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_offline_apply` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_offline_apply{
                    row_key = {R#db_player_offline_apply.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_offline_apply, record_info(fields, db_player_offline_apply), Fun),
            dets:insert(player_offline_apply, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_mission_data) ->
    io:format("Load table : player_mission_data.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_mission_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_mission_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_mission_data{
                    row_key = {R#db_player_mission_data.player_id, R#db_player_mission_data.mission_type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_mission_data, record_info(fields, db_player_mission_data), Fun),
            ets:insert(player_mission_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_mail) ->
    io:format("Load table : player_mail.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_mail`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_mail` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_mail{
                    row_key = {R#db_player_mail.player_id, R#db_player_mail.mail_real_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_mail, record_info(fields, db_player_mail), Fun),
            ets:insert(player_mail, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_leichong) ->
    io:format("Load table : player_leichong.............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_leichong`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_leichong` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_leichong{
                    row_key = {R#db_player_leichong.player_id, R#db_player_leichong.activity_id, R#db_player_leichong.task_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_leichong, record_info(fields, db_player_leichong), Fun),
            ets:insert(player_leichong, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_laba_data) ->
    io:format("Load table : player_laba_data............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_laba_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_laba_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_laba_data{
                    row_key = {R#db_player_laba_data.player_id, R#db_player_laba_data.laba_id, R#db_player_laba_data.cost_rate}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_laba_data, record_info(fields, db_player_laba_data), Fun),
            ets:insert(player_laba_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_jiangjinchi) ->
    io:format("Load table : player_jiangjinchi..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_jiangjinchi`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_jiangjinchi` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_jiangjinchi{
                    row_key = {R#db_player_jiangjinchi.player_id, R#db_player_jiangjinchi.scene_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_jiangjinchi, record_info(fields, db_player_jiangjinchi), Fun),
            ets:insert(player_jiangjinchi, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_invite_friend_log) ->
    io:format("Load table : player_invite_friend_log....................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_invite_friend_log`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_invite_friend_log` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_invite_friend_log{
                    row_key = {R#db_player_invite_friend_log.player_id, R#db_player_invite_friend_log.acc_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_invite_friend_log, record_info(fields, db_player_invite_friend_log), Fun),
            ets:insert(player_invite_friend_log, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_invite_friend) ->
    io:format("Load table : player_invite_friend........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_invite_friend`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_invite_friend` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_invite_friend{
                    row_key = {R#db_player_invite_friend.acc_id, R#db_player_invite_friend.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_invite_friend, record_info(fields, db_player_invite_friend), Fun),
            ets:insert(player_invite_friend, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_invest_type) ->
    io:format("Load table : player_invest_type..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_invest_type`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_invest_type` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_invest_type{
                    row_key = {R#db_player_invest_type.player_id, R#db_player_invest_type.type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_invest_type, record_info(fields, db_player_invest_type), Fun),
            ets:insert(player_invest_type, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_invest) ->
    io:format("Load table : player_invest................................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_invest`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_invest` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_invest{
                    row_key = {R#db_player_invest.player_id, R#db_player_invest.type, R#db_player_invest.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_invest, record_info(fields, db_player_invest), Fun),
            ets:insert(player_invest, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_hero_use) ->
    io:format("Load table : player_hero_use.............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_hero_use`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_hero_use` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_hero_use{
                    row_key = {R#db_player_hero_use.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_hero_use, record_info(fields, db_player_hero_use), Fun),
            ets:insert(player_hero_use, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_hero_parts) ->
    io:format("Load table : player_hero_parts............................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_hero_parts`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_hero_parts` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_hero_parts{
                    row_key = {R#db_player_hero_parts.player_id, R#db_player_hero_parts.parts_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_hero_parts, record_info(fields, db_player_hero_parts), Fun),
            ets:insert(player_hero_parts, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_hero) ->
    io:format("Load table : player_hero.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_hero`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_hero` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_hero{
                    row_key = {R#db_player_hero.player_id, R#db_player_hero.hero_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_hero, record_info(fields, db_player_hero), Fun),
            ets:insert(player_hero, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_gift_mail_log) ->
    io:format("Load table : player_gift_mail_log........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_gift_mail_log`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_gift_mail_log` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_gift_mail_log{
                    row_key = {R#db_player_gift_mail_log.sender, R#db_player_gift_mail_log.create_time}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_gift_mail_log, record_info(fields, db_player_gift_mail_log), Fun),
            ets:insert(player_gift_mail_log, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_gift_mail) ->
    io:format("Load table : player_gift_mail............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_gift_mail`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_gift_mail` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_gift_mail{
                    row_key = {R#db_player_gift_mail.player_id, R#db_player_gift_mail.mail_real_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_gift_mail, record_info(fields, db_player_gift_mail), Fun),
            ets:insert(player_gift_mail, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_gift_code) ->
    io:format("Load table : player_gift_code............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_gift_code`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_gift_code` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_gift_code{
                    row_key = {R#db_player_gift_code.player_id, R#db_player_gift_code.gift_code_type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_gift_code, record_info(fields, db_player_gift_code), Fun),
            ets:insert(player_gift_code, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_game_data) ->
    io:format("Load table : player_game_data............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_game_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_game_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_game_data{
                    row_key = {R#db_player_game_data.player_id, R#db_player_game_data.data_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_game_data, record_info(fields, db_player_game_data), Fun),
            dets:insert(player_game_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_game_config) ->
    io:format("Load table : player_game_config..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_game_config`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_game_config` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_game_config{
                    row_key = {R#db_player_game_config.player_id, R#db_player_game_config.config_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_game_config, record_info(fields, db_player_game_config), Fun),
            ets:insert(player_game_config, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_function) ->
    io:format("Load table : player_function.............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_function`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_function` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_function{
                    row_key = {R#db_player_function.player_id, R#db_player_function.function_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_function, record_info(fields, db_player_function), Fun),
            ets:insert(player_function, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_first_charge_day) ->
    io:format("Load table : player_first_charge_day......................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_first_charge_day`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_first_charge_day` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_first_charge_day{
                    row_key = {R#db_player_first_charge_day.player_id, R#db_player_first_charge_day.type, R#db_player_first_charge_day.day}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_first_charge_day, record_info(fields, db_player_first_charge_day), Fun),
            ets:insert(player_first_charge_day, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_first_charge) ->
    io:format("Load table : player_first_charge.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_first_charge`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_first_charge` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_first_charge{
                    row_key = {R#db_player_first_charge.player_id, R#db_player_first_charge.type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_first_charge, record_info(fields, db_player_first_charge), Fun),
            ets:insert(player_first_charge, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_finish_share_task) ->
    io:format("Load table : player_finish_share_task....................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_finish_share_task`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_finish_share_task` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_finish_share_task{
                    row_key = {R#db_player_finish_share_task.acc_id, R#db_player_finish_share_task.task_type, R#db_player_finish_share_task.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_finish_share_task, record_info(fields, db_player_finish_share_task), Fun),
            ets:insert(player_finish_share_task, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_fight_adjust) ->
    io:format("Load table : player_fight_adjust.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_fight_adjust`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_fight_adjust` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_fight_adjust{
                    row_key = {R#db_player_fight_adjust.player_id, R#db_player_fight_adjust.prop_id, R#db_player_fight_adjust.fight_type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_fight_adjust, record_info(fields, db_player_fight_adjust), Fun),
            ets:insert(player_fight_adjust, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_everyday_sign) ->
    io:format("Load table : player_everyday_sign........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_everyday_sign`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_everyday_sign` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_everyday_sign{
                    row_key = {R#db_player_everyday_sign.player_id, R#db_player_everyday_sign.today}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_everyday_sign, record_info(fields, db_player_everyday_sign), Fun),
            ets:insert(player_everyday_sign, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_everyday_charge) ->
    io:format("Load table : player_everyday_charge......................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_everyday_charge`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_everyday_charge` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_everyday_charge{
                    row_key = {R#db_player_everyday_charge.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_everyday_charge, record_info(fields, db_player_everyday_charge), Fun),
            ets:insert(player_everyday_charge, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_data) ->
    io:format("Load table : player_data.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_data{
                    row_key = {R#db_player_data.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_data, record_info(fields, db_player_data), Fun),
            ets:insert(player_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_daily_task) ->
    io:format("Load table : player_daily_task............................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_daily_task`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_daily_task` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_daily_task{
                    row_key = {R#db_player_daily_task.player_id, R#db_player_daily_task.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_daily_task, record_info(fields, db_player_daily_task), Fun),
            ets:insert(player_daily_task, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_daily_points) ->
    io:format("Load table : player_daily_points.........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_daily_points`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_daily_points` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_daily_points{
                    row_key = {R#db_player_daily_points.player_id, R#db_player_daily_points.bid}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_daily_points, record_info(fields, db_player_daily_points), Fun),
            ets:insert(player_daily_points, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_conditions_data) ->
    io:format("Load table : player_conditions_data......................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_conditions_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_conditions_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_conditions_data{
                    row_key = {R#db_player_conditions_data.player_id, R#db_player_conditions_data.conditions_id, R#db_player_conditions_data.type, R#db_player_conditions_data.type2}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_conditions_data, record_info(fields, db_player_conditions_data), Fun),
            dets:insert(player_conditions_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_condition_activity) ->
    io:format("Load table : player_condition_activity...................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_condition_activity`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_condition_activity` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_condition_activity{
                    row_key = {R#db_player_condition_activity.player_id, R#db_player_condition_activity.activity_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_condition_activity, record_info(fields, db_player_condition_activity), Fun),
            ets:insert(player_condition_activity, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_client_data) ->
    io:format("Load table : player_client_data..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_client_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_client_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_client_data{
                    row_key = {R#db_player_client_data.player_id, R#db_player_client_data.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_client_data, record_info(fields, db_player_client_data), Fun),
            ets:insert(player_client_data, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_chat_data) ->
    io:format("Load table : player_chat_data............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_chat_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_chat_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_chat_data{
                    row_key = {R#db_player_chat_data.player_id, R#db_player_chat_data.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_chat_data, record_info(fields, db_player_chat_data), Fun),
            ets:insert(player_chat_data, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_charge_shop) ->
    io:format("Load table : player_charge_shop..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_charge_shop`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_charge_shop` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_charge_shop{
                    row_key = {R#db_player_charge_shop.player_id, R#db_player_charge_shop.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_charge_shop, record_info(fields, db_player_charge_shop), Fun),
            ets:insert(player_charge_shop, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_charge_record) ->
    io:format("Load table : player_charge_record........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_charge_record`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_charge_record` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_charge_record{
                    row_key = {R#db_player_charge_record.order_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_charge_record, record_info(fields, db_player_charge_record), Fun),
            dets:insert(player_charge_record, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_charge_info_record) ->
    io:format("Load table : player_charge_info_record...................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_charge_info_record`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_charge_info_record` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_charge_info_record{
                    row_key = {R#db_player_charge_info_record.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_charge_info_record, record_info(fields, db_player_charge_info_record), Fun),
            dets:insert(player_charge_info_record, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_charge_activity) ->
    io:format("Load table : player_charge_activity......................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_charge_activity`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_charge_activity` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_charge_activity{
                    row_key = {R#db_player_charge_activity.player_id, R#db_player_charge_activity.type, R#db_player_charge_activity.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_charge_activity, record_info(fields, db_player_charge_activity), Fun),
            dets:insert(player_charge_activity, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_card_title) ->
    io:format("Load table : player_card_title............................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_card_title`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_card_title` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_card_title{
                    row_key = {R#db_player_card_title.player_id, R#db_player_card_title.card_title_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_card_title, record_info(fields, db_player_card_title), Fun),
            ets:insert(player_card_title, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_card_summon) ->
    io:format("Load table : player_card_summon..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_card_summon`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_card_summon` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_card_summon{
                    row_key = {R#db_player_card_summon.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_card_summon, record_info(fields, db_player_card_summon), Fun),
            ets:insert(player_card_summon, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_card_book) ->
    io:format("Load table : player_card_book............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_card_book`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_card_book` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_card_book{
                    row_key = {R#db_player_card_book.player_id, R#db_player_card_book.card_book_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_card_book, record_info(fields, db_player_card_book), Fun),
            ets:insert(player_card_book, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_card) ->
    io:format("Load table : player_card.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_card`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_card` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_card{
                    row_key = {R#db_player_card.player_id, R#db_player_card.card_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_card, record_info(fields, db_player_card), Fun),
            ets:insert(player_card, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_bounty_task) ->
    io:format("Load table : player_bounty_task..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_bounty_task`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_bounty_task` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_bounty_task{
                    row_key = {R#db_player_bounty_task.player_id, R#db_player_bounty_task.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_bounty_task, record_info(fields, db_player_bounty_task), Fun),
            ets:insert(player_bounty_task, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_adjust_rebound) ->
    io:format("Load table : player_adjust_rebound........................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_adjust_rebound`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_adjust_rebound` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_adjust_rebound{
                    row_key = {R#db_player_adjust_rebound.player_id, R#db_player_adjust_rebound.rebound_type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_adjust_rebound, record_info(fields, db_player_adjust_rebound), Fun),
            ets:insert(player_adjust_rebound, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_activity_task) ->
    io:format("Load table : player_activity_task........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_activity_task`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_activity_task` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_activity_task{
                    row_key = {R#db_player_activity_task.player_id, R#db_player_activity_task.activity_id, R#db_player_activity_task.task_type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_activity_task, record_info(fields, db_player_activity_task), Fun),
            ets:insert(player_activity_task, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_activity_info) ->
    io:format("Load table : player_activity_info........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_activity_info`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_activity_info` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_activity_info{
                    row_key = {R#db_player_activity_info.player_id, R#db_player_activity_info.activity_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_activity_info, record_info(fields, db_player_activity_info), Fun),
            ets:insert(player_activity_info, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_activity_game_info) ->
    io:format("Load table : player_activity_game_info...................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_activity_game_info`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_activity_game_info` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_activity_game_info{
                    row_key = {R#db_player_activity_game_info.player_id, R#db_player_activity_game_info.activity_id, R#db_player_activity_game_info.game_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_activity_game_info, record_info(fields, db_player_activity_game_info), Fun),
            ets:insert(player_activity_game_info, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_activity_game) ->
    io:format("Load table : player_activity_game........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_activity_game`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_activity_game` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_activity_game{
                    row_key = {R#db_player_activity_game.player_id, R#db_player_activity_game.activity_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_activity_game, record_info(fields, db_player_activity_game), Fun),
            ets:insert(player_activity_game, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_activity_condition) ->
    io:format("Load table : player_activity_condition...................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_activity_condition`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_activity_condition` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_activity_condition{
                    row_key = {R#db_player_activity_condition.player_id, R#db_player_activity_condition.activity_id, R#db_player_activity_condition.condition_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_activity_condition, record_info(fields, db_player_activity_condition), Fun),
            ets:insert(player_activity_condition, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player_achievement) ->
    io:format("Load table : player_achievement..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player_achievement`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player_achievement` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player_achievement{
                    row_key = {R#db_player_achievement.player_id, R#db_player_achievement.type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player_achievement, record_info(fields, db_player_achievement), Fun),
            ets:insert(player_achievement, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(player) ->
    io:format("Load table : player......................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `player`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `player` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_player{
                    row_key = {R#db_player.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_player, record_info(fields, db_player), Fun),
            ets:insert(player, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(one_vs_one_rank_data) ->
    io:format("Load table : one_vs_one_rank_data........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `one_vs_one_rank_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `one_vs_one_rank_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_one_vs_one_rank_data{
                    row_key = {R#db_one_vs_one_rank_data.type, R#db_one_vs_one_rank_data.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_one_vs_one_rank_data, record_info(fields, db_one_vs_one_rank_data), Fun),
            ets:insert(one_vs_one_rank_data, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(oauth_order_log) ->
    io:format("Load table : oauth_order_log.............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `oauth_order_log`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `oauth_order_log` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_oauth_order_log{
                    row_key = {R#db_oauth_order_log.order_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_oauth_order_log, record_info(fields, db_oauth_order_log), Fun),
            ets:insert(oauth_order_log, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(mission_ranking) ->
    io:format("Load table : mission_ranking.............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `mission_ranking`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `mission_ranking` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_mission_ranking{
                    row_key = {R#db_mission_ranking.mission_type, R#db_mission_ranking.mission_id, R#db_mission_ranking.id, R#db_mission_ranking.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_mission_ranking, record_info(fields, db_mission_ranking), Fun),
            ets:insert(mission_ranking, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(mission_guess_boss) ->
    io:format("Load table : mission_guess_boss..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `mission_guess_boss`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `mission_guess_boss` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_mission_guess_boss{
                    row_key = {R#db_mission_guess_boss.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_mission_guess_boss, record_info(fields, db_mission_guess_boss), Fun),
            ets:insert(mission_guess_boss, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(match_scene_data) ->
    io:format("Load table : match_scene_data............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `match_scene_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `match_scene_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_match_scene_data{
                    row_key = {R#db_match_scene_data.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_match_scene_data, record_info(fields, db_match_scene_data), Fun),
            ets:insert(match_scene_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(login_notice) ->
    io:format("Load table : login_notice................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `login_notice`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `login_notice` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_login_notice{
                    row_key = {R#db_login_notice.platform_id, R#db_login_notice.channel_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_login_notice, record_info(fields, db_login_notice), Fun),
            ets:insert(login_notice, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(laba_adjust) ->
    io:format("Load table : laba_adjust.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `laba_adjust`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `laba_adjust` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_laba_adjust{
                    row_key = {R#db_laba_adjust.laba_id, R#db_laba_adjust.cost_rate}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_laba_adjust, record_info(fields, db_laba_adjust), Fun),
            ets:insert(laba_adjust, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(jiangjinchi) ->
    io:format("Load table : jiangjinchi.................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `jiangjinchi`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `jiangjinchi` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_jiangjinchi{
                    row_key = {R#db_jiangjinchi.scene_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_jiangjinchi, record_info(fields, db_jiangjinchi), Fun),
            ets:insert(jiangjinchi, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(gift_code_type) ->
    io:format("Load table : gift_code_type..............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `gift_code_type`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `gift_code_type` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_gift_code_type{
                    row_key = {R#db_gift_code_type.type}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_gift_code_type, record_info(fields, db_gift_code_type), Fun),
            ets:insert(gift_code_type, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(gift_code) ->
    io:format("Load table : gift_code...................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `gift_code`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `gift_code` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_gift_code{
                    row_key = {R#db_gift_code.gift_code}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_gift_code, record_info(fields, db_gift_code), Fun),
            ets:insert(gift_code, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(consume_statistics) ->
    io:format("Load table : consume_statistics..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `consume_statistics`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `consume_statistics` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_consume_statistics{
                    row_key = {R#db_consume_statistics.player_id, R#db_consume_statistics.prop_id, R#db_consume_statistics.type, R#db_consume_statistics.log_type, R#db_consume_statistics.scene_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_consume_statistics, record_info(fields, db_consume_statistics), Fun),
            dets:insert(consume_statistics, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(client_versin) ->
    io:format("Load table : client_versin................................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `client_versin`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `client_versin` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_client_versin{
                    row_key = {R#db_client_versin.version}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_client_versin, record_info(fields, db_client_versin), Fun),
            ets:insert(client_versin, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(charge_order_request_record) ->
    io:format("Load table : charge_order_request_record.................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `charge_order_request_record`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `charge_order_request_record` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_charge_order_request_record{
                    row_key = {R#db_charge_order_request_record.order_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_charge_order_request_record, record_info(fields, db_charge_order_request_record), Fun),
            ets:insert(charge_order_request_record, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(charge_ip_white_record) ->
    io:format("Load table : charge_ip_white_record......................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `charge_ip_white_record`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `charge_ip_white_record` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_charge_ip_white_record{
                    row_key = {R#db_charge_ip_white_record.ip}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_charge_ip_white_record, record_info(fields, db_charge_ip_white_record), Fun),
            ets:insert(charge_ip_white_record, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(charge_info_record) ->
    io:format("Load table : charge_info_record..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `charge_info_record`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `charge_info_record` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_charge_info_record{
                    row_key = {R#db_charge_info_record.order_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_charge_info_record, record_info(fields, db_charge_info_record), Fun),
            dets:insert(charge_info_record, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(c_server_node) ->
    io:format("Load table : c_server_node................................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `c_server_node`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `c_server_node` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_c_server_node{
                    row_key = {R#db_c_server_node.node}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_c_server_node, record_info(fields, db_c_server_node), Fun),
            ets:insert(c_server_node, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(c_game_server) ->
    io:format("Load table : c_game_server................................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `c_game_server`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `c_game_server` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_c_game_server{
                    row_key = {R#db_c_game_server.platform_id, R#db_c_game_server.sid}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_c_game_server, record_info(fields, db_c_game_server), Fun),
            ets:insert(c_game_server, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(brave_one) ->
    io:format("Load table : brave_one...................................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `brave_one`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `brave_one` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_brave_one{
                    row_key = {R#db_brave_one.player_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_brave_one, record_info(fields, db_brave_one), Fun),
            ets:insert(brave_one, Rows),
            db_index:insert_indexs(Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(boss_one_on_one) ->
    io:format("Load table : boss_one_on_one.............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `boss_one_on_one`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `boss_one_on_one` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_boss_one_on_one{
                    row_key = {R#db_boss_one_on_one.id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_boss_one_on_one, record_info(fields, db_boss_one_on_one), Fun),
            ets:insert(boss_one_on_one, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(activity_info) ->
    io:format("Load table : activity_info................................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `activity_info`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `activity_info` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_activity_info{
                    row_key = {R#db_activity_info.activity_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_activity_info, record_info(fields, db_activity_info), Fun),
            ets:insert(activity_info, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(activity_award) ->
    io:format("Load table : activity_award..............................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `activity_award`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `activity_award` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_activity_award{
                    row_key = {R#db_activity_award.activity_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_activity_award, record_info(fields, db_activity_award), Fun),
            ets:insert(activity_award, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(account_share_data) ->
    io:format("Load table : account_share_data..........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `account_share_data`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `account_share_data` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_account_share_data{
                    row_key = {R#db_account_share_data.platform_id, R#db_account_share_data.account}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_account_share_data, record_info(fields, db_account_share_data), Fun),
            ets:insert(account_share_data, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(account_charge_white) ->
    io:format("Load table : account_charge_white........................."),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `account_charge_white`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `account_charge_white` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_account_charge_white{
                    row_key = {R#db_account_charge_white.platform_id, R#db_account_charge_white.account}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_account_charge_white, record_info(fields, db_account_charge_white), Fun),
            ets:insert(account_charge_white, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n");
load(account) ->
    io:format("Load table : account......................................"),
    {data, Res} = mysql:fetch(game_db, <<"SELECT count(1) FROM `account`">>, infinity),
    [[RowNum]] = lib_mysql:get_rows(Res),
    lists:foreach(
        fun(Page) ->
            Sql = "SELECT * FROM `account` LIMIT " ++ integer_to_list(Page * 50000) ++ ", 50000;",
            {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), infinity),
            Fun = fun(R) ->
                R#db_account{
                    row_key = {R#db_account.acc_id, R#db_account.server_id}
                }
            end,
            Rows = lib_mysql:as_record(Res1, db_account, record_info(fields, db_account), Fun),
            dets:insert(account, Rows)
        end,
        lists:seq(0, erlang:ceil(RowNum / 50000) - 1)
    ),
    io:format(" [ok] \n").

load(player_vip_award, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_vip_award` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_vip_award{
            row_key = {R#db_player_vip_award.player_id, R#db_player_vip_award.level}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_vip_award, record_info(fields, db_player_vip_award), Fun),
    EtsTable = player_vip_award,
    ets:insert(EtsTable, Rows);
load(player_vip, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_vip` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_vip{
            row_key = {R#db_player_vip.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_vip, record_info(fields, db_player_vip), Fun),
    EtsTable = player_vip,
    ets:insert(EtsTable, Rows);
load(player_title, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_title` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_title{
            row_key = {R#db_player_title.player_id, R#db_player_title.title_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_title, record_info(fields, db_player_title), Fun),
    EtsTable = player_title,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_task_share_award, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_task_share_award` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_task_share_award{
            row_key = {R#db_player_task_share_award.player_id, R#db_player_task_share_award.task_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_task_share_award, record_info(fields, db_player_task_share_award), Fun),
    EtsTable = player_task_share_award,
    ets:insert(EtsTable, Rows);
load(player_task, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_task` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_task{
            row_key = {R#db_player_task.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_task, record_info(fields, db_player_task), Fun),
    EtsTable = player_task,
    ets:insert(EtsTable, Rows);
load(player_sys_common, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_sys_common` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_sys_common{
            row_key = {R#db_player_sys_common.player_id, R#db_player_sys_common.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_sys_common, record_info(fields, db_player_sys_common), Fun),
    EtsTable = player_sys_common,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_special_prop, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_special_prop` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_special_prop{
            row_key = {R#db_player_special_prop.player_id, R#db_player_special_prop.prop_obj_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_special_prop, record_info(fields, db_player_special_prop), Fun),
    EtsTable = player_special_prop,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_shop, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_shop` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_shop{
            row_key = {R#db_player_shop.player_id, R#db_player_shop.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_shop, record_info(fields, db_player_shop), Fun),
    EtsTable = player_shop,
    ets:insert(EtsTable, Rows);
load(player_shen_long, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_shen_long` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_shen_long{
            row_key = {R#db_player_shen_long.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_shen_long, record_info(fields, db_player_shen_long), Fun),
    EtsTable = player_shen_long,
    ets:insert(EtsTable, Rows);
load(player_share_task_award, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_share_task_award` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_share_task_award{
            row_key = {R#db_player_share_task_award.player_id, R#db_player_share_task_award.task_type, R#db_player_share_task_award.task_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_share_task_award, record_info(fields, db_player_share_task_award), Fun),
    EtsTable = player_share_task_award,
    ets:insert(EtsTable, Rows);
load(player_share_task, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_share_task` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_share_task{
            row_key = {R#db_player_share_task.player_id, R#db_player_share_task.task_type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_share_task, record_info(fields, db_player_share_task), Fun),
    EtsTable = player_share_task,
    ets:insert(EtsTable, Rows);
load(player_share_friend, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_share_friend` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_share_friend{
            row_key = {R#db_player_share_friend.player_id, R#db_player_share_friend.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_share_friend, record_info(fields, db_player_share_friend), Fun),
    EtsTable = player_share_friend,
    ets:insert(EtsTable, Rows);
load(player_share, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_share` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_share{
            row_key = {R#db_player_share.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_share, record_info(fields, db_player_share), Fun),
    EtsTable = player_share,
    ets:insert(EtsTable, Rows);
load(player_seven_login, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_seven_login` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_seven_login{
            row_key = {R#db_player_seven_login.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_seven_login, record_info(fields, db_player_seven_login), Fun),
    EtsTable = player_seven_login,
    ets:insert(EtsTable, Rows);
load(player_send_gamebar_msg, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_send_gamebar_msg` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_send_gamebar_msg{
            row_key = {R#db_player_send_gamebar_msg.player_id, R#db_player_send_gamebar_msg.msg_type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_send_gamebar_msg, record_info(fields, db_player_send_gamebar_msg), Fun),
    EtsTable = player_send_gamebar_msg,
    ets:insert(EtsTable, Rows);
load(player_prerogative_card, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_prerogative_card` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_prerogative_card{
            row_key = {R#db_player_prerogative_card.player_id, R#db_player_prerogative_card.type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_prerogative_card, record_info(fields, db_player_prerogative_card), Fun),
    EtsTable = player_prerogative_card,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_platform_award, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_platform_award` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_platform_award{
            row_key = {R#db_player_platform_award.player_id, R#db_player_platform_award.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_platform_award, record_info(fields, db_player_platform_award), Fun),
    EtsTable = player_platform_award,
    ets:insert(EtsTable, Rows);
load(player_passive_skill, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_passive_skill` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_passive_skill{
            row_key = {R#db_player_passive_skill.player_id, R#db_player_passive_skill.passive_skill_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_passive_skill, record_info(fields, db_player_passive_skill), Fun),
    EtsTable = player_passive_skill,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_online_info, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_online_info` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_online_info{
            row_key = {R#db_player_online_info.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_online_info, record_info(fields, db_player_online_info), Fun),
    EtsTable = player_online_info,
    ets:insert(EtsTable, Rows);
load(player_online_award, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_online_award` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_online_award{
            row_key = {R#db_player_online_award.player_id, R#db_player_online_award.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_online_award, record_info(fields, db_player_online_award), Fun),
    EtsTable = player_online_award,
    ets:insert(EtsTable, Rows);
load(player_mission_data, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_mission_data` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_mission_data{
            row_key = {R#db_player_mission_data.player_id, R#db_player_mission_data.mission_type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_mission_data, record_info(fields, db_player_mission_data), Fun),
    EtsTable = player_mission_data,
    ets:insert(EtsTable, Rows);
load(player_leichong, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_leichong` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_leichong{
            row_key = {R#db_player_leichong.player_id, R#db_player_leichong.activity_id, R#db_player_leichong.task_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_leichong, record_info(fields, db_player_leichong), Fun),
    EtsTable = player_leichong,
    ets:insert(EtsTable, Rows);
load(player_laba_data, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_laba_data` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_laba_data{
            row_key = {R#db_player_laba_data.player_id, R#db_player_laba_data.laba_id, R#db_player_laba_data.cost_rate}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_laba_data, record_info(fields, db_player_laba_data), Fun),
    EtsTable = player_laba_data,
    ets:insert(EtsTable, Rows);
load(player_jiangjinchi, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_jiangjinchi` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_jiangjinchi{
            row_key = {R#db_player_jiangjinchi.player_id, R#db_player_jiangjinchi.scene_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_jiangjinchi, record_info(fields, db_player_jiangjinchi), Fun),
    EtsTable = player_jiangjinchi,
    ets:insert(EtsTable, Rows);
load(player_invite_friend_log, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_invite_friend_log` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_invite_friend_log{
            row_key = {R#db_player_invite_friend_log.player_id, R#db_player_invite_friend_log.acc_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_invite_friend_log, record_info(fields, db_player_invite_friend_log), Fun),
    EtsTable = player_invite_friend_log,
    ets:insert(EtsTable, Rows);
load(player_invite_friend, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_invite_friend` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_invite_friend{
            row_key = {R#db_player_invite_friend.acc_id, R#db_player_invite_friend.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_invite_friend, record_info(fields, db_player_invite_friend), Fun),
    EtsTable = player_invite_friend,
    ets:insert(EtsTable, Rows);
load(player_invest_type, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_invest_type` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_invest_type{
            row_key = {R#db_player_invest_type.player_id, R#db_player_invest_type.type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_invest_type, record_info(fields, db_player_invest_type), Fun),
    EtsTable = player_invest_type,
    ets:insert(EtsTable, Rows);
load(player_invest, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_invest` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_invest{
            row_key = {R#db_player_invest.player_id, R#db_player_invest.type, R#db_player_invest.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_invest, record_info(fields, db_player_invest), Fun),
    EtsTable = player_invest,
    ets:insert(EtsTable, Rows);
load(player_hero_use, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_hero_use` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_hero_use{
            row_key = {R#db_player_hero_use.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_hero_use, record_info(fields, db_player_hero_use), Fun),
    EtsTable = player_hero_use,
    ets:insert(EtsTable, Rows);
load(player_hero_parts, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_hero_parts` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_hero_parts{
            row_key = {R#db_player_hero_parts.player_id, R#db_player_hero_parts.parts_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_hero_parts, record_info(fields, db_player_hero_parts), Fun),
    EtsTable = player_hero_parts,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_hero, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_hero` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_hero{
            row_key = {R#db_player_hero.player_id, R#db_player_hero.hero_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_hero, record_info(fields, db_player_hero), Fun),
    EtsTable = player_hero,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_gift_code, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_gift_code` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_gift_code{
            row_key = {R#db_player_gift_code.player_id, R#db_player_gift_code.gift_code_type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_gift_code, record_info(fields, db_player_gift_code), Fun),
    EtsTable = player_gift_code,
    ets:insert(EtsTable, Rows);
load(player_game_config, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_game_config` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_game_config{
            row_key = {R#db_player_game_config.player_id, R#db_player_game_config.config_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_game_config, record_info(fields, db_player_game_config), Fun),
    EtsTable = player_game_config,
    ets:insert(EtsTable, Rows);
load(player_first_charge_day, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_first_charge_day` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_first_charge_day{
            row_key = {R#db_player_first_charge_day.player_id, R#db_player_first_charge_day.type, R#db_player_first_charge_day.day}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_first_charge_day, record_info(fields, db_player_first_charge_day), Fun),
    EtsTable = player_first_charge_day,
    ets:insert(EtsTable, Rows);
load(player_first_charge, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_first_charge` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_first_charge{
            row_key = {R#db_player_first_charge.player_id, R#db_player_first_charge.type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_first_charge, record_info(fields, db_player_first_charge), Fun),
    EtsTable = player_first_charge,
    ets:insert(EtsTable, Rows);
load(player_finish_share_task, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_finish_share_task` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_finish_share_task{
            row_key = {R#db_player_finish_share_task.acc_id, R#db_player_finish_share_task.task_type, R#db_player_finish_share_task.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_finish_share_task, record_info(fields, db_player_finish_share_task), Fun),
    EtsTable = player_finish_share_task,
    ets:insert(EtsTable, Rows);
load(player_fight_adjust, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_fight_adjust` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_fight_adjust{
            row_key = {R#db_player_fight_adjust.player_id, R#db_player_fight_adjust.prop_id, R#db_player_fight_adjust.fight_type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_fight_adjust, record_info(fields, db_player_fight_adjust), Fun),
    EtsTable = player_fight_adjust,
    ets:insert(EtsTable, Rows);
load(player_everyday_sign, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_everyday_sign` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_everyday_sign{
            row_key = {R#db_player_everyday_sign.player_id, R#db_player_everyday_sign.today}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_everyday_sign, record_info(fields, db_player_everyday_sign), Fun),
    EtsTable = player_everyday_sign,
    ets:insert(EtsTable, Rows);
load(player_everyday_charge, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_everyday_charge` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_everyday_charge{
            row_key = {R#db_player_everyday_charge.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_everyday_charge, record_info(fields, db_player_everyday_charge), Fun),
    EtsTable = player_everyday_charge,
    ets:insert(EtsTable, Rows);
load(player_daily_task, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_daily_task` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_daily_task{
            row_key = {R#db_player_daily_task.player_id, R#db_player_daily_task.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_daily_task, record_info(fields, db_player_daily_task), Fun),
    EtsTable = player_daily_task,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_daily_points, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_daily_points` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_daily_points{
            row_key = {R#db_player_daily_points.player_id, R#db_player_daily_points.bid}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_daily_points, record_info(fields, db_player_daily_points), Fun),
    EtsTable = player_daily_points,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_condition_activity, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_condition_activity` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_condition_activity{
            row_key = {R#db_player_condition_activity.player_id, R#db_player_condition_activity.activity_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_condition_activity, record_info(fields, db_player_condition_activity), Fun),
    EtsTable = player_condition_activity,
    ets:insert(EtsTable, Rows);
load(player_client_data, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_client_data` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_client_data{
            row_key = {R#db_player_client_data.player_id, R#db_player_client_data.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_client_data, record_info(fields, db_player_client_data), Fun),
    EtsTable = player_client_data,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_charge_shop, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_charge_shop` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_charge_shop{
            row_key = {R#db_player_charge_shop.player_id, R#db_player_charge_shop.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_charge_shop, record_info(fields, db_player_charge_shop), Fun),
    EtsTable = player_charge_shop,
    ets:insert(EtsTable, Rows);
load(player_card_title, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_card_title` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_card_title{
            row_key = {R#db_player_card_title.player_id, R#db_player_card_title.card_title_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_card_title, record_info(fields, db_player_card_title), Fun),
    EtsTable = player_card_title,
    ets:insert(EtsTable, Rows);
load(player_card_summon, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_card_summon` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_card_summon{
            row_key = {R#db_player_card_summon.player_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_card_summon, record_info(fields, db_player_card_summon), Fun),
    EtsTable = player_card_summon,
    ets:insert(EtsTable, Rows);
load(player_card_book, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_card_book` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_card_book{
            row_key = {R#db_player_card_book.player_id, R#db_player_card_book.card_book_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_card_book, record_info(fields, db_player_card_book), Fun),
    EtsTable = player_card_book,
    ets:insert(EtsTable, Rows);
load(player_card, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_card` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_card{
            row_key = {R#db_player_card.player_id, R#db_player_card.card_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_card, record_info(fields, db_player_card), Fun),
    EtsTable = player_card,
    ets:insert(EtsTable, Rows);
load(player_bounty_task, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_bounty_task` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_bounty_task{
            row_key = {R#db_player_bounty_task.player_id, R#db_player_bounty_task.id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_bounty_task, record_info(fields, db_player_bounty_task), Fun),
    EtsTable = player_bounty_task,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_adjust_rebound, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_adjust_rebound` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_adjust_rebound{
            row_key = {R#db_player_adjust_rebound.player_id, R#db_player_adjust_rebound.rebound_type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_adjust_rebound, record_info(fields, db_player_adjust_rebound), Fun),
    EtsTable = player_adjust_rebound,
    ets:insert(EtsTable, Rows);
load(player_activity_task, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_activity_task` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_activity_task{
            row_key = {R#db_player_activity_task.player_id, R#db_player_activity_task.activity_id, R#db_player_activity_task.task_type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_activity_task, record_info(fields, db_player_activity_task), Fun),
    EtsTable = player_activity_task,
    ets:insert(EtsTable, Rows);
load(player_activity_info, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_activity_info` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_activity_info{
            row_key = {R#db_player_activity_info.player_id, R#db_player_activity_info.activity_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_activity_info, record_info(fields, db_player_activity_info), Fun),
    EtsTable = player_activity_info,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_activity_game_info, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_activity_game_info` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_activity_game_info{
            row_key = {R#db_player_activity_game_info.player_id, R#db_player_activity_game_info.activity_id, R#db_player_activity_game_info.game_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_activity_game_info, record_info(fields, db_player_activity_game_info), Fun),
    EtsTable = player_activity_game_info,
    ets:insert(EtsTable, Rows);
load(player_activity_game, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_activity_game` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_activity_game{
            row_key = {R#db_player_activity_game.player_id, R#db_player_activity_game.activity_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_activity_game, record_info(fields, db_player_activity_game), Fun),
    EtsTable = player_activity_game,
    ets:insert_new(EtsTable, Rows),
    db_index:insert_indexs(Rows);
load(player_activity_condition, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_activity_condition` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_activity_condition{
            row_key = {R#db_player_activity_condition.player_id, R#db_player_activity_condition.activity_id, R#db_player_activity_condition.condition_id}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_activity_condition, record_info(fields, db_player_activity_condition), Fun),
    EtsTable = player_activity_condition,
    ets:insert(EtsTable, Rows);
load(player_achievement, PlayerId) when is_integer(PlayerId) -> 
    Sql = io_lib:format("SELECT * from `player_achievement` WHERE player_id = ~p; ", [PlayerId]),
    {data, Res} = mysql:fetch(game_db, list_to_binary(Sql), 30000),
    Fun = fun(R) ->
        R#db_player_achievement{
            row_key = {R#db_player_achievement.player_id, R#db_player_achievement.type}
        }
    end,
    Rows = lib_mysql:as_record(Res, db_player_achievement, record_info(fields, db_player_achievement), Fun),
    EtsTable = player_achievement,
    ets:insert(EtsTable, Rows).

unload(player_vip_award, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_vip_award, [{#db_player_vip_award{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_vip, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_vip, [{#db_player_vip{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_title, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_title, [{#db_player_title{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_title, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_task_share_award, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_task_share_award, [{#db_player_task_share_award{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_task, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_task, [{#db_player_task{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_sys_common, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_sys_common, [{#db_player_sys_common{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_sys_common, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_special_prop, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_special_prop, [{#db_player_special_prop{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_special_prop, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_shop, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_shop, [{#db_player_shop{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_shen_long, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_shen_long, [{#db_player_shen_long{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_share_task_award, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_share_task_award, [{#db_player_share_task_award{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_share_task, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_share_task, [{#db_player_share_task{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_share_friend, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_share_friend, [{#db_player_share_friend{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_share, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_share, [{#db_player_share{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_seven_login, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_seven_login, [{#db_player_seven_login{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_send_gamebar_msg, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_send_gamebar_msg, [{#db_player_send_gamebar_msg{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_prerogative_card, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_prerogative_card, [{#db_player_prerogative_card{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_prerogative_card, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_platform_award, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_platform_award, [{#db_player_platform_award{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_passive_skill, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_passive_skill, [{#db_player_passive_skill{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_passive_skill, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_online_info, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_online_info, [{#db_player_online_info{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_online_award, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_online_award, [{#db_player_online_award{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_mission_data, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_mission_data, [{#db_player_mission_data{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_leichong, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_leichong, [{#db_player_leichong{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_laba_data, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_laba_data, [{#db_player_laba_data{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_jiangjinchi, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_jiangjinchi, [{#db_player_jiangjinchi{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_invite_friend_log, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_invite_friend_log, [{#db_player_invite_friend_log{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_invite_friend, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_invite_friend, [{#db_player_invite_friend{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_invest_type, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_invest_type, [{#db_player_invest_type{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_invest, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_invest, [{#db_player_invest{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_hero_use, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_hero_use, [{#db_player_hero_use{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_hero_parts, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_hero_parts, [{#db_player_hero_parts{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_hero_parts, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_hero, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_hero, [{#db_player_hero{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_hero, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_gift_code, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_gift_code, [{#db_player_gift_code{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_game_config, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_game_config, [{#db_player_game_config{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_first_charge_day, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_first_charge_day, [{#db_player_first_charge_day{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_first_charge, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_first_charge, [{#db_player_first_charge{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_finish_share_task, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_finish_share_task, [{#db_player_finish_share_task{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_fight_adjust, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_fight_adjust, [{#db_player_fight_adjust{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_everyday_sign, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_everyday_sign, [{#db_player_everyday_sign{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_everyday_charge, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_everyday_charge, [{#db_player_everyday_charge{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_daily_task, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_daily_task, [{#db_player_daily_task{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_daily_task, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_daily_points, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_daily_points, [{#db_player_daily_points{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_daily_points, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_condition_activity, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_condition_activity, [{#db_player_condition_activity{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_client_data, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_client_data, [{#db_player_client_data{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_client_data, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_charge_shop, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_charge_shop, [{#db_player_charge_shop{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_card_title, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_card_title, [{#db_player_card_title{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_card_summon, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_card_summon, [{#db_player_card_summon{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_card_book, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_card_book, [{#db_player_card_book{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_card, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_card, [{#db_player_card{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_bounty_task, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_bounty_task, [{#db_player_bounty_task{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_bounty_task, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_adjust_rebound, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_adjust_rebound, [{#db_player_adjust_rebound{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_activity_task, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_activity_task, [{#db_player_activity_task{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_activity_info, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_activity_info, [{#db_player_activity_info{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_activity_info, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_activity_game_info, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_activity_game_info, [{#db_player_activity_game_info{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_activity_game, PlayerId) when is_integer(PlayerId) ->
    RecordList = ets:select(player_activity_game, [{#db_player_activity_game{player_id = PlayerId, _ = '_'}, [], ['$_']}]),
    [ets:delete_object(player_activity_game, Record) || Record <- RecordList],
    db_index:erase_indexs(RecordList);
unload(player_activity_condition, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_activity_condition, [{#db_player_activity_condition{player_id = PlayerId, _ = '_'}, [], [true]}]);
unload(player_achievement, PlayerId) when is_integer(PlayerId) ->
    ets:select_delete(player_achievement, [{#db_player_achievement{player_id = PlayerId, _ = '_'}, [], [true]}]).

