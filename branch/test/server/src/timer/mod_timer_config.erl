%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            定时器 配置
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_timer_config).

-include("common.hrl").
-include("gen/table_db.hrl").
-include("timer.hrl").
-include("system.hrl").
-include("gen/table_enum.hrl").
-include("scene_adjust.hrl").

-export([
    get_timers/0,
    online_player_0_game_worker/1,
    online_player_0/1,
    online_player_2/1,
    online_player_interval_60/1,
    online_player_interval_10/1
]).
%% 定时器回调
-export([
    timer_everyday_0_time/0,        %% 每天0点
    timer_everyday_2_time/0,        %% 每天2点
    timer_everyday_5_time/0,        %% 每天5点
    timer_every_monday_0_time/0,    %% 每周一早上0点
    timer_everyday_0_time_1_minute/0,%% 每天0点1分
    timer_interval_60_time/0,       %% 每60秒执行一次
    timer_interval_10_time/0        %% 每10秒执行一次
]).
-export([
    online_player_monday_0/1        %% 每周一早上0点
]).

%% ----------------------------------
%% @doc 	定时器配置
%% @throws 	none
%% @end
%% ----------------------------------
-define(TIMERS,
    [
%% -------------------------------------------------- [Example] -----------------------------------------------------------
%%  1.  {2016, 7, 19}, {21, 45, 0} 执行一次
%%      timer_data{id = 1, type = ?TIMER_TYPE_ONE, time = {{2016, 7, 19}, {21, 45, 0}}, m = module, f = method, a = []},
%%  2.  间隔3分钟执行
%%      #timer_data{id = 2, type = ?TIMER_TYPE_INTERVAL, time = 3 * 60, m = module, f = method, a = []},
%%  3.  每天5点执行
%%      #timer_data{id = 3, type = ?TIMER_TYPE_EVERYDAY, time = {05, 00, 0}, m = module, f = method, a = []},
%%  4.  每周日2点执行
%%      #timer_data{id = 4, type = {?TIMER_TYPE_WEEKLY, ?SUNDAY}, time = {2, 0, 0}, m = module, f = method, a = [], is_check = true},
%% ------------------------------------------------------------------------------------------------------------------------

        %% id 不能重复

        %% 每天0点
        #timer_meta{id = 1, type = ?TIMER_TYPE_EVERYDAY, time = {0, 0, 0}, m = ?MODULE, f = timer_everyday_0_time, a = [], is_check = true},

        %% 每天5点
        #timer_meta{id = 2, type = ?TIMER_TYPE_EVERYDAY, time = {05, 00, 0}, m = ?MODULE, f = timer_everyday_5_time, a = [], is_check = true},

        %% 每天0点1分
        #timer_meta{id = 3, type = ?TIMER_TYPE_EVERYDAY, time = {0, 01, 0}, m = ?MODULE, f = timer_everyday_0_time_1_minute, a = [], is_check = true},

        %% 每周一早0点
        #timer_meta{id = 4, type = {?TIMER_TYPE_WEEKLY, ?MONDAY}, time = {0, 0, 0}, m = ?MODULE, f = timer_every_monday_0_time, a = [], is_check = true},

        %% 每天2点
        #timer_meta{id = 5, type = ?TIMER_TYPE_EVERYDAY, time = {2, 0, 0}, m = ?MODULE, f = timer_everyday_2_time, a = [], is_check = true},

        %% 每分钟一次
        #timer_meta{id = 6, type = ?TIMER_TYPE_INTERVAL, time = 60, m = ?MODULE, f = timer_interval_60_time, a = []},

        %% 每10秒钟一次
        #timer_meta{id = 7, type = ?TIMER_TYPE_INTERVAL, time = 10, m = ?MODULE, f = timer_interval_10_time, a = []}
    ]
).

get_timers() ->
    ?TIMERS.

%% ----------------------------------
%% @doc 	每周一早上0点
%% @throws 	none
%% @end
%% ----------------------------------
timer_every_monday_0_time() ->
    ServerType = mod_server_config:get_server_type(),
    if
        ServerType == ?SERVER_TYPE_WAR_ZONE ->
            ?INFO("timer_every_monday_0_time");
        ServerType =:= ?SERVER_TYPE_GAME ->
            ?INFO("每周一0点清理所有在线玩家的数据"),
            %% 每周一0点处理数据
            mod_apply:apply_to_all_online_player_args(mod_timer_config, online_player_monday_0, []);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	每天0点
%% @throws 	none
%% @end
%% ----------------------------------
timer_everyday_0_time() ->
    ServerType = mod_server_config:get_server_type(),
    if
        ServerType == ?SERVER_TYPE_GAME ->
            ?INFO("date_cut ..."),
            %% 资源找回(必须放在重置次数前面!!!!!!)
%%            ?TRY_CATCH(mod_apply:apply_to_all_online_player_args(mod_resource_get_back, refresh, [])),
            %% 重置次数
            ?TRY_CATCH(mod_apply:apply_to_all_online_player_2(mod_times, flush_player_times_data, true)),
            %% 0点处理数据
            mod_apply:apply_to_all_online_player_args(mod_timer_config, online_player_0, []),
            %% 0点处理数据一定处理
            mod_apply:apply_to_all_online_player_args(mod_timer_config, online_player_0_game_worker, [], game_worker),
            ok;
        ServerType == ?SERVER_TYPE_WAR_AREA ->
            wheel_srv:cast(clear_record),
            ok;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	每天5点
%% @throws 	none
%% @end
%% ----------------------------------
timer_everyday_5_time() ->
    ServerType = mod_server_config:get_server_type(),
    if
        ServerType == ?SERVER_TYPE_GAME ->
            ?INFO("timer_everyday_5_time"),
            %% 5点清除祝福值
%%            ?TRY_CATCH(mod_apply:apply_to_all_online_player_2(mod_sys_common, clear_wish_num, []));
            ok;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	每天2点
%% @throws 	none
%% @end
%% ----------------------------------
timer_everyday_2_time() ->
    ServerType = mod_server_config:get_server_type(),
    if
        ServerType == ?SERVER_TYPE_GAME ->
            ?INFO("timer_everyday_2_time"),
            %% 2点处理数据
            mod_apply:apply_to_all_online_player_args(mod_timer_config, online_player_2, []),
            ok;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	每天0点1分
%% @throws 	none
%% @end
%% ----------------------------------
timer_everyday_0_time_1_minute() ->
    ServerType = mod_server_config:get_server_type(),
    if
        ServerType == ?SERVER_TYPE_GAME ->
            ?INFO("timer_everyday_0_time_1_minute"),
            ok;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	每60秒执行一次
%% @throws 	none
%% @end
%% ----------------------------------
timer_interval_60_time() ->
    ServerType = mod_server_config:get_server_type(),
    if
        ServerType == ?SERVER_TYPE_GAME ->
            %% 每60秒执行一次
            mod_apply:apply_to_all_online_player_args(?MODULE, online_player_interval_60, []),
            ok;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	每10秒执行一次
%% @throws 	none
%% @end
%% ----------------------------------
timer_interval_10_time() ->
    ServerType = mod_server_config:get_server_type(),
    if
        ServerType == ?SERVER_TYPE_GAME ->
            %% 每60秒执行一次
            mod_apply:apply_to_all_online_player_args(?MODULE, online_player_interval_10, []),
            scene_adjust_srv:cast(?SCENE_ADJUST_MSG_TEST_LOG),
            ok;
        true ->
            noop
    end.

%% @fun 0点处理玩家数据
online_player_0(PlayerId) ->
%%    ?TRY_CATCH(mod_xiu_xian:flush_player_xiu_xian_data(PlayerId)),  %% 重置修仙数据
    ?TRY_CATCH(mod_everyday_sign:notice_day(PlayerId, [])),     %% 每日签到
    ?TRY_CATCH(mod_online_award:zero_reset_online_award(PlayerId, [])),     %% 重置在线奖励
    ?TRY_CATCH(api_platform_function:api_notice_share_count(PlayerId, 0)),  %% 0点通知分享次数
    ?TRY_CATCH(mod_seven_login:time_0_set_day(PlayerId)),                   %% 七天登錄
    ?TRY_CATCH(mod_tongxingzheng:on_date_cut(PlayerId)),
    ?TRY_CATCH(mod_daily_task:on_date_cut(PlayerId)),
    ?TRY_CATCH(mod_bounty_task:on_date_cut(PlayerId)),
    ?TRY_CATCH(mod_first_charge:add_login_day(PlayerId, true)),             %% 首充增加登录天数
    ok.

%% @fun 0点处理数据一定处理
online_player_0_game_worker(_PlayerId) ->
%%    ?TRY_CATCH(mod_shop:close_day_activity_shop(PlayerId)),
    ok.

online_player_2(PlayerId) ->
    ?TRY_CATCH(api_promote:notice_promote_times(PlayerId)),                 %% 推广奖励领取次数通知重置
    ok.

%% @fun 每周0点清理玩家数据
online_player_monday_0(PlayerId) ->
    ?TRY_CATCH(mod_seize_treasure:flush_seize_times_first_login_per_week(PlayerId)),        %% 清理夺宝数据
    ok.

%% @doc 每60秒执行一次
online_player_interval_60(PlayerId) ->
    ?TRY_CATCH(mod_log:write_player_fight_monster_log(PlayerId)),
    ?TRY_CATCH(mod_log:write_monster_cost_log(PlayerId)),
    ?TRY_CATCH(mod_log:write_player_prop_log(PlayerId)),
    ?TRY_CATCH(mod_service_player_log:write_log(PlayerId)),
    ok.

%% @doc 每10秒执行一次
online_player_interval_10(PlayerId) ->
    ?TRY_CATCH(mod_log:write_player_prop_log_2(PlayerId)),
    ok.