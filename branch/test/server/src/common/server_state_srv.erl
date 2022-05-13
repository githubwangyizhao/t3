%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器数据统计追踪
%%% @end
%%% Created : 30. 六月 2016 下午 2:54
%%%-------------------------------------------------------------------
-module(server_state_srv).

-behaviour(gen_server).

-export([
    start_link/0
%%    get_all_total_online_time/2,
%%    get_level_one_player_count/0,
%%    get_valid_player_count/0
]).
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-include("gen/db.hrl").
-include("system.hrl").
-include("common.hrl").

-define(SERVER, ?MODULE).
-define(MSG_TEN_MINUTE_STATICS, msg_ten_minute_statics). %% 每10分钟统计
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init(_) ->
    trigger_server_monitor(),
    trigger_gc(?MINUTE_MS * 3),
    IsGameServer = mod_server:is_game_server(),
    if IsGameServer ->
        trigger_ten_minute_statics();
%%        trigger_server_trace_daily_log();
        true ->
            noop
    end,
    {ok, noop}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(server_monitor, State) ->
    trigger_server_monitor(),
    case mod_server:is_game_server() of
        true ->
            ?TRY_CATCH(mod_log:write_online_statistics_log());
        false ->
            noop
    end,

    ?TRY_CATCH(mod_log:write_system_monitor_log()),
    ?TRY_CATCH(mod_log:write_process_monitor_log()),
%%    %% 更新最高在线人数
%%    ?TRY_CATCH(mod_max_online_count:handle_update()),
    {noreply, State};
handle_info(gc, State) ->
    trigger_gc(),
%%    ?DEBUG("GC: ~p", [?PROCESS_GC_VALUE]),
    ?TRY_CATCH(tool:gc(?PROCESS_GC_VALUE)),
    {noreply, State};
handle_info({?MSG_TEN_MINUTE_STATICS, _Time}, State) ->
    trigger_ten_minute_statics(),
%%    ?TRY_CATCH(handle_record_ten_minute_statics(Time)),
    {noreply, State};
%%handle_info({server_trace_daily_log, Time}, State) ->
%%    trigger_server_trace_daily_log(),
%%%%    ?TRY_CATCH(handle_record_server_trace_daily_data(Time)),
%%    {noreply, State};
handle_info(_, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    State.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

trigger_gc() ->
    trigger_gc(?PROCESS_GC_MS).
trigger_gc(Time) ->
    erlang:send_after(Time, self(), gc).

trigger_server_monitor() ->
    erlang:send_after(?SERVER_MONITOR_LOG_MS, self(), server_monitor).


trigger_ten_minute_statics() ->
    Now = util_time:timestamp(),
    Diff = util_time:get_next_tidy_minute_timestamp(Now, 10) - Now,
    erlang:send_after(Diff * 1000, self(), {?MSG_TEN_MINUTE_STATICS, Now + Diff}).

%%trigger_server_trace_daily_log() ->
%%    Now = util_time:timestamp(),
%%    {Date, _} = util_time:datetime(Now),
%%    TodayZeroTimestamp = util_time:timestamp({Date, {0, 0, 0}}),
%%    NextDataTimestamp = TodayZeroTimestamp + 86400,
%%    Diff = NextDataTimestamp - Now,
%%    erlang:send_after(Diff * 1000, self(), {server_trace_daily_log, TodayZeroTimestamp}).
%%
%%
%% 每10分钟 记录 服务器追踪信息
%%handle_record_ten_minute_statics(Time) ->
%%    PlatformId = mod_server_config:get_platform_id(),
%%    ChannelList = mod_server:get_channel_list_by_platform_id(PlatformId),
%%    Node = atom_to_list(node()),
%%    lists:foreach(
%%        fun(ChannelId) ->
%%            OnlineCount = mod_online:get_online_count_by_channel(ChannelId),
%%            Data =
%%                [
%%                    Node,
%%                    ChannelId,
%%                    Time,
%%                    OnlineCount,
%%                    get_time_range_login_num(ChannelId, Time - ?MINUTE_S * 10, Time)
%%                ],
%%            ?INFO("10分钟统计数据:~p", [Data]),
%%            mod_server_rpc:cast_center(
%%                mod_log,
%%                write_ten_minute_statics,
%%                Data
%%            )
%%        end,
%%        ChannelList
%%    ).

%%handle_record_ten_minute_statics(Time) ->
%%    OnlineCount = mod_online:get_online_count(),
%%    Node = atom_to_list(node()),
%%    Data =
%%        [
%%            Node,
%%            Time,
%%            OnlineCount,
%%            get_time_range_login_num(Time - ?MINUTE_S * 10, Time)
%%        ],
%%%%    ?INFO("10分钟统计数据:~p", [Data]),
%%    mod_server_rpc:cast_center(
%%        mod_log,
%%        write_ten_minute_statics,
%%        Data
%%    ).

%%%% 每日 记录 服务器追踪信息
%%handle_record_server_trace_daily_data(Time) ->
%%    {{Y, M, D}, _} = util_time:timestamp_to_datetime(Time),
%%    Node = atom_to_list(node()),
%%    {ConnectTimes, EnterRoleTimes} = get_no_role_account_info(),
%%    %% Node, Y, M, D, OneLevelCount, ValidCount, ConnectTimes, EnterCreateRole, LoginNum TotalOnlineTIme
%%    Data =
%%        [
%%            Node,
%%            Y,
%%            M,
%%            D,
%%            get_level_one_player_count(),
%%            get_valid_player_count(),
%%            ConnectTimes,
%%            EnterRoleTimes,
%%            get_login_num(Time, Time + 86400),
%%            get_all_total_online_time(Time, Time + 86400)
%%        ],
%%    ?INFO("每日 记录 服务器追踪信息:~p", [Data]),
%%    mod_server_rpc:cast_center(
%%        mod_log,
%%        write_server_trace_daily_log,
%%        Data
%%    ).
%%
%% ----------------------------------
%% @doc 	获取时间范围内注册人数
%% @throws 	none
%% @end
%% ----------------------------------
%%get_time_range_login_num(ChannelId, A, B) ->
%%    L = db:select(player,
%%        [
%%            {#db_player{reg_time = '$1', channel = '$2', _ = '_'},
%%                [{'andalso', {'andalso', {'>=', '$1', A}, {'<', '$1', B}}, {'==', '$2', ChannelId}}],
%%                ['$1']}
%%        ]),
%%    length(L).
%%
%%get_no_role_account_info() ->
%%    L = ets:tab2list(no_role_account),
%%    {ConnectTimes, EnterRoleTimes} = lists:foldl(
%%        fun(R, {A, B}) ->
%%            {A + R#no_role_account.connect_times, B + R#no_role_account.enter_create_role}
%%        end,
%%        {0, 0},
%%        L
%%    ),
%%    {ConnectTimes, EnterRoleTimes}.
%%
%%get_level_one_player_count() ->
%%    L = mod_player:get_all_player_id(),
%%    lists:foldl(
%%        fun(PlayerId, N) ->
%%            case mod_player:is_common_account(PlayerId) of
%%                true ->
%%                    N + 1;
%%                false ->
%%                    N
%%            end
%%        end,
%%        0,
%%        L
%%    ).
%%
%%get_valid_player_count() ->
%%    L = mod_player:get_all_player_id(),
%%    lists:foldl(
%%        fun(PlayerId, N) ->
%%            case mod_player:is_common_account(PlayerId) of
%%                true ->
%%                    case mod_player:get_player_data(PlayerId) of
%%                        null ->
%%                            N;
%%                        PlayerData ->
%%                            if PlayerData#player_data.level > 1 ->
%%                                N + 1;
%%                                true ->
%%                                    N
%%                            end
%%                    end;
%%                false ->
%%                    N
%%            end
%%        end,
%%        0,
%%        L
%%    ).
%%
%%get_all_total_online_time(T1, T2) ->
%%    Sql = io_lib:format("select * from player_online_log where login_time between ~p and  ~p;", [T1, T2]),
%%    {data, Res} = mysql:fetch(game_db, Sql, 10000),
%%    L = lib_mysql:get_rows(Res),
%%    lists:foldl(
%%        fun(R, T) ->
%%            T + lists:nth(5, R)
%%        end,
%%        0,
%%        L
%%    ).
