%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            通用定时器
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_timer).

-include("common.hrl").
-include("timer.hrl").
-include("gen/db.hrl").
-export([
    start/0,
    stop/0,
    reload/0            %% 重新加载定时器
]).
%%callback
-export([
    init/0,
    handle_apply_timer/3,
    reset_timer_data/1
]).


%% ----------------------------------
%% @doc 	重新加载定时器
%% @throws 	none
%% @end
%% ----------------------------------
reload() ->
    ?TIME_SERVER ! reload.

start() ->
    ?TIME_SERVER ! start.

stop() ->
    ?TIME_SERVER ! stop.

handle_apply_timer(Timer, ClockTimestamp, Ref) ->
    #timer_meta{
        id = TimerId,
        m = M,
        f = F,
        a = A
    } = Timer,
    init_next(Timer, ClockTimestamp, Ref),
    apply_timer(TimerId, M, F, A, ClockTimestamp).

init_next(Timer, ClockTimestamp, Ref) ->
    #timer_meta{
        type = Type,
        time = Time
    } = Timer,
    case Type of
        ?TIMER_TYPE_ONE ->
            noop;
        ?TIMER_TYPE_INTERVAL ->
            NewClockTimestamp = ClockTimestamp + Time,
            erlang:send_after(Time * ?SECOND_MS, self(), {apply, Timer, NewClockTimestamp, Ref});
        ?TIMER_TYPE_EVERYDAY ->
            NewClockTimestamp = ClockTimestamp + ?DAY_S,
            Diff = NewClockTimestamp - util_time:timestamp(),
            erlang:send_after(Diff * ?SECOND_MS, self(), {apply, Timer, NewClockTimestamp, Ref});
        {?TIMER_TYPE_WEEKLY, _Week} ->
            NewClockTimestamp = ClockTimestamp + ?WEEK_S,
            Diff = NewClockTimestamp - util_time:timestamp(),
            erlang:send_after(Diff * ?SECOND_MS, self(), {apply, Timer, NewClockTimestamp, Ref})
    end.
init() ->
    Ref = erlang:make_ref(),
    init(mod_timer_config:get_timers(), Ref).
init([], Ref) ->
    Ref;
init([Timer | T], Ref) ->
    try do_init(Timer, Ref)
    catch
        _:Reason ->
            ?ERROR("通用定时器启动失败:~p~n", [{Timer, Reason, erlang:get_stacktrace()}])
    end,
    init(T, Ref).

do_init(Timer, Ref) ->
    #timer_meta{
        id = TimerId,
        type = Type,
        time = Time,
        is_check = IsCheck,
        m = M,
        f = F,
        a = A
    } = Timer,
    case Type of
        ?TIMER_TYPE_ONE ->
            ClockTimestamp = util_time:datetime_to_timestamp(Time),
            NowTimestamp = util_time:timestamp(),
            Diff = ClockTimestamp - NowTimestamp,
            if Diff >= 0 ->
                erlang:send_after(Diff * ?SECOND_MS, self(), {apply, Timer, ClockTimestamp, Ref});
                true ->
                    if IsCheck ->
                        case get_timer_data(TimerId) of
                            null ->
                                apply_timer(TimerId, M, F, A, NowTimestamp);
                            _ ->
                                noop
                        end;
                        true ->
                            noop
                    end
            end;
        ?TIMER_TYPE_INTERVAL ->
            ?t_assert(is_integer(Time)),
            ClockTimestamp = util_time:timestamp() + Time,
            erlang:send_after(Time * ?SECOND_MS, self(), {apply, Timer, ClockTimestamp, Ref});
        ?TIMER_TYPE_EVERYDAY ->
            {NowDate, NowTime} = util_time:local_datetime(),
            ClockTimestamp = util_time:datetime_to_timestamp({NowDate, Time}),
            NowTimestamp = util_time:datetime_to_timestamp({NowDate, NowTime}),
            if NowTimestamp > ClockTimestamp ->
                if IsCheck ->
                    case get_timer_data(TimerId) of
                        null ->
                            apply_timer(TimerId, M, F, A, NowTimestamp);
                        R ->
                            #db_timer_data{
                                last_time = LastTime
                            } = R,
                            {LastDate, _} = util_time:timestamp_to_datetime(LastTime),
                            if LastDate =/= NowDate ->
                                apply_timer(TimerId, M, F, A, NowTimestamp);
                                true ->
                                    noop
                            end
                    end;
                    true ->
                        noop
                end,
                RealClockTimestamp = ClockTimestamp + ?DAY_S,
                Diff = RealClockTimestamp - NowTimestamp,
                erlang:send_after(Diff * ?SECOND_MS, self(), {apply, Timer, RealClockTimestamp, Ref});
                true ->
                    Diff = ClockTimestamp - NowTimestamp,
                    erlang:send_after(Diff * ?SECOND_MS, self(), {apply, Timer, ClockTimestamp, Ref})
            end;
        {?TIMER_TYPE_WEEKLY, Week} ->
            {NowDate, NowTime} = util_time:local_datetime(),
            NowTimestamp = util_time:datetime_to_timestamp({NowDate, NowTime}),
            ClockTimestamp = util_time:get_monday_zero_timestamp(NowDate) + (Week - 1) * ?DAY_S + calendar:time_to_seconds(Time),
            if NowTimestamp > ClockTimestamp ->
                if IsCheck ->
                    case get_timer_data(TimerId) of
                        null ->
                            apply_timer(TimerId, M, F, A, NowTimestamp);
                        R ->
                            #db_timer_data{
                                last_time = LastTime
                            } = R,
                            {LastDate, _} = util_time:timestamp_to_datetime(LastTime),
                            LastWeek = calendar:iso_week_number(LastDate),
                            NowWeek = calendar:iso_week_number(NowDate),
                            if LastWeek =/= NowWeek ->
                                apply_timer(TimerId, M, F, A, NowTimestamp);
                                true ->
                                    noop
                            end
                    end;
                    true ->
                        noop
                end,
                RealClockTimestamp = ClockTimestamp + ?WEEK_S,
                Diff = RealClockTimestamp - NowTimestamp,
                erlang:send_after(Diff * ?SECOND_MS, self(), {apply, Timer, RealClockTimestamp, Ref});
                true ->
                    Diff = ClockTimestamp - NowTimestamp,
                    erlang:send_after(Diff * ?SECOND_MS, self(), {apply, Timer, ClockTimestamp, Ref})
            end
    end.

apply_timer(TimerId, M, F, A, NowTimestamp) ->
    util:catch_apply(M, F, A),
    update_timer_data(TimerId, NowTimestamp).
%%    mod_log:write_timer_log(TimerId, NowTimestamp).

get_timer_data(TimerId) ->
    db:read(#key_timer_data{timer_id = TimerId}).

update_timer_data(TimerId, Time) ->
    Tran =
        fun() ->
            case get_timer_data(TimerId) of
                null ->
                    db:write(#db_timer_data{timer_id = TimerId, last_time = Time});
                R ->
                    db:write(R#db_timer_data{last_time = Time})
            end
        end,
    db:do(Tran).

reset_timer_data(TimerId) ->
    Tran =
        fun() ->
            case get_timer_data(TimerId) of
                null ->
                    noop;
                R ->
                    db:write(R#db_timer_data{last_time = 0})
            end
        end,
    db:do(Tran).
