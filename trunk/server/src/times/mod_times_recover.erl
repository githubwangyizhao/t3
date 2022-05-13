%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            次数恢复
%%% @end
%%% Created : 28. 十二月 2017 上午 11:47
%%%-------------------------------------------------------------------
-module(mod_times_recover).

-include("gen/table_db.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("msg.hrl").
%% API
-export([
    try_trigger_all_times_recover_timer/1,
    trigger_recover_times_timer/2,
    trigger_recover_times_timer/3,
    handle_recover_times/2,
    get_times_recover_time/1
]).

%% ----------------------------------
%% @doc 	尝试恢复玩家次数
%% @throws 	none
%% @end
%% ----------------------------------
try_trigger_all_times_recover_timer(PlayerId) ->
    lists:foreach(
        fun(R) ->
            trigger_recover_times_timer(PlayerId, R#db_player_times_data.times_id)
        end,
        mod_times:get_player_all_times_data(PlayerId)
    ).

%% ----------------------------------
%% @doc 	触发次数恢复定时器
%% @throws 	none
%% @end
%% ----------------------------------
trigger_recover_times_timer(PlayerId, TimesId) ->
    trigger_recover_times_timer(PlayerId, TimesId, false).
trigger_recover_times_timer(PlayerId, TimesId, IsResetRecoverTime) ->
    #t_times{
        recover_interval_time = RecoverIntervalTime
    } = mod_times:get_t_times(TimesId),
    if
        RecoverIntervalTime > 0 ->
%%            ?DEBUG("~p~n", [{PlayerId, TimesId, IsResetRecoverTime, RecoverIntervalTime}]),
            PlayerTimesData = mod_times:get_player_times_data(PlayerId, TimesId),
            #db_player_times_data{
                left_times = LeftTimes,
                last_recover_time = LastRecoverTime,
                times_id = TimesId
            } = PlayerTimesData,

            MaxFreeTimes = mod_times:get_init_free_times(PlayerId, TimesId),

            if
                LeftTimes >= MaxFreeTimes ->
                    %% 已达最大免费次数， 取消定时器
                    erase_recover_times_timer(TimesId);
                true ->
                    case get_recover_times_timer(TimesId) of
                        ?UNDEFINED ->
                            %% 启动定时器
                            NowS = util_time:timestamp(),
                            RealLastRecoverTime =
                                if
                                    IsResetRecoverTime == true ->
                                        %% 设置上次恢复时间为当前时间
                                        Tran = fun() ->
                                            db:write(PlayerTimesData#db_player_times_data{
                                                last_recover_time = NowS
                                            })
                                               end,
                                        db:do(Tran),
                                        NowS;
                                    true ->
                                        LastRecoverTime
                                end,
                            PassedTime = NowS - RealLastRecoverTime,
                            Time = max(1, RecoverIntervalTime - PassedTime) * 1000,
                            ?DEBUG("下次恢复次数:~p", [[TimesId, {left_times, LeftTimes}, {left_time, Time div 1000}]]),
                            start_recover_times_timer(TimesId, Time);
                        _ ->
                            noop
                    end
            end;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	记录次数恢复时间戳
%% @throws 	none
%% @end
%% ----------------------------------
update_times_recover_time(TimesId, RecoverTime) ->
    put({times_recover_time, TimesId}, RecoverTime).

%% ----------------------------------
%% @doc 	获取次数恢复时间戳
%% @throws 	none
%% @end
%% ----------------------------------
get_times_recover_time(TimesId) ->
    case get({times_recover_time, TimesId}) of
        ?UNDEFINED ->
            0;
        Time ->
            Time
    end.

%% ----------------------------------
%% @doc 	处理恢复次数
%% @throws 	none
%% @end
%% ----------------------------------
handle_recover_times(PlayerId, TimesId) ->
    erase_recover_times_timer(TimesId),
    #t_times{
        recover_interval_time = RecoverIntervalTime
    } = mod_times:get_t_times(TimesId),
    ?ASSERT(RecoverIntervalTime > 0),
    PlayerTimesData = mod_times:get_player_times_data(PlayerId, TimesId),
    #db_player_times_data{
        left_times = LeftTimes,
        last_recover_time = LastRecoverTime,
        times_id = TimesId
    } = PlayerTimesData,

    MaxFreeTimes = mod_times:get_init_free_times(PlayerId, TimesId),
    if
        LeftTimes >= MaxFreeTimes ->
            %% 已达恢复次数上限
            noop;
        true ->
            NowS = util_time:timestamp(),
            PassedTime = NowS - LastRecoverTime,
            %% 恢复的次数
            RecoverTimes = PassedTime div RecoverIntervalTime,
            if
                RecoverTimes > 0 ->
                    NewLeftTimes = min(MaxFreeTimes, LeftTimes + RecoverTimes),
                    ?INFO("恢复次数:~p", [[TimesId, {add_times, RecoverTimes}, {now_times, NewLeftTimes}, LastRecoverTime]]),
                    Tran = fun() ->
                        db:write(PlayerTimesData#db_player_times_data{
                            last_recover_time = LastRecoverTime + RecoverTimes * RecoverIntervalTime,
                            left_times = NewLeftTimes
                        }),
                        mod_times:hook_times_change(PlayerId, TimesId, false)
                           end,
                    db:do(Tran);
                true ->
                    noop
            end,
            trigger_recover_times_timer(PlayerId, TimesId)
    end.

%% ----------------------------------
%% @doc 	启动定时器
%% @throws 	none
%% @end
%% ----------------------------------
start_recover_times_timer(TimesId, Time) ->
    TimerRef = client_worker:send_msg(self(), {?MSG_CLIENT_RECOVER_TIMES, TimesId}, Time),
%%    TimerRef = erlang:send_after(Time, self(), {?MSG_RECOVER_TIMES, TimesId}),
    put({times_recover_timer, TimesId}, TimerRef),
    update_times_recover_time(TimesId, util_time:timestamp() + Time div 1000).

%% ----------------------------------
%% @doc 	获取定时器
%% @throws 	none
%% @end
%% ----------------------------------
get_recover_times_timer(TimesId) ->
    get({times_recover_timer, TimesId}).

%% ----------------------------------
%% @doc 	清除定时器
%% @throws 	none
%% @end
%% ----------------------------------
erase_recover_times_timer(TimesId) ->
    case get_recover_times_timer(TimesId) of
        ?UNDEFINED ->
            noop;
        TimerRef ->
            erase({times_recover_timer, TimesId}),
            erlang:cancel_timer(TimerRef)
    end,
    update_times_recover_time(TimesId, 0).

