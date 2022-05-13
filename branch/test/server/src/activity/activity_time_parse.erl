%%%-------------------------------------------------------------------
%%% @author        home
%%% @copyright (C) 2016, THYZ
%%% @doc            活动时间解析
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(activity_time_parse).

%% API
-export([
    parse_activity_time/2,
    is_server_limit/1
]).
-include("common.hrl").
-include("gen/table_db.hrl").
-include("system.hrl").

%% @doc 解析活动时间
%% @private
%% return {StartTime, EndTime}
parse_activity_time(ActivityId, NowTimestamp) ->
    #t_activity_info{
        time_list = TimeList,
        week_list = WeekList,
        open_server_day_limit_list = OpenServerDayLimitList,
        merge_server_day_limit_list = MergeServerDayLimitList
    } = t_activity_info:assert_get({ActivityId}),
    {{NOW_Y, NOW_M, NOW_D}, {_NOW_HH, _NOW_MM, _NOW_SS}} = util_time:timestamp_to_datetime(NowTimestamp),

    [StartTime, EndTime] =
        case TimeList of
            [] ->
                %% 永久开启
                case mod_server_config:get_server_type() of
                    ?SERVER_TYPE_GAME ->
                        %% 开服时间限制
                        case OpenServerDayLimitList of
                            [] ->
                                case MergeServerDayLimitList of
                                    [] ->
                                        [0, 0];
                                    [MS, ME] ->
                                        MergeStartTime = mod_server:get_server_merge_day_timestamp(MS) ,
                                        MergeEndTime =
                                            if ME == 0 ->
                                                0;
                                                true ->
                                                    mod_server:get_server_merge_day_timestamp(ME) +  86400 - 1
                                            end,
                                        [MergeStartTime, MergeEndTime]
                                end;
                            [OS, OE] ->
                                OpenStartTime = mod_server:get_server_open_day_timestamp(OS) ,
                                OpenEndTime =
                                    if OE == 0 ->
                                        0;
                                        true ->
                                            mod_server:get_server_open_day_timestamp(OE) +  86400 - 1
                                    end,
                                [OpenStartTime, OpenEndTime]
                        end;
                    _ ->
                        [0,0]
                end;
            [[S_HH, S_MM, S_SS], [E_HH, E_MM, E_SS]] ->
                ?ASSERT(util_time:is_valid_time({S_HH, S_MM, S_SS}) andalso util_time:is_valid_time({E_HH, E_MM, E_SS}), {not_valid_activity_time, ActivityId, TimeList}),
                if
                    WeekList == [] ->
                        %% 每天时间段内开启活动
                        S = util_time:datetime_to_timestamp({{NOW_Y, NOW_M, NOW_D}, {S_HH, S_MM, S_SS}}),
                        E = util_time:datetime_to_timestamp({{NOW_Y, NOW_M, NOW_D}, {E_HH, E_MM, E_SS}}),
                        if NowTimestamp >= E ->
                            [S + ?DAY_S, E + ?DAY_S];
                            true ->
                                [S, E]
                        end;
                    true ->
                        %% 每周几时间段内开启活动
                        ?ASSERT(lists:all(fun(ThisW) ->
                            is_integer(ThisW) andalso ThisW >= 1 andalso ThisW =< 7 end, WeekList)),

                        NowWeek = util_time:get_week(NowTimestamp),
                        MondayZeroTimestamp = util_time:get_monday_zero_timestamp(NowTimestamp),
                        SortWeekList = lists:sort(WeekList),
                        MatchWeek =
                            lists:foldl(
                                fun(ThisWeek, MatchWeek0) ->
                                    if
                                        MatchWeek0 == 0 ->
                                            if
                                                ThisWeek >= NowWeek ->
                                                    ThisWeek;
                                                true ->
                                                    0
                                            end;
                                        true ->
                                            MatchWeek0
                                    end
                                end,
                                0,
                                SortWeekList
                            ),
                        NextTime =
                            if MatchWeek == 0 ->
                                NextWeek = hd(SortWeekList),
                                MondayZeroTimestamp + (NextWeek - 1) * ?DAY_S + 7 * ?DAY_S;
                                true ->
                                    NextWeek = MatchWeek,
                                    MondayZeroTimestamp + (NextWeek - 1) * ?DAY_S
                            end,
                        {NextDate, _} = util_time:timestamp_to_datetime(NextTime),
                        S = util_time:datetime_to_timestamp({NextDate, {S_HH, S_MM, S_SS}}),
                        E = util_time:datetime_to_timestamp({NextDate, {E_HH, E_MM, E_SS}}),
%%            ?DEBUG("everyweek:~p~n", [{TimeList, NowWeek, {util_time:timestamp_to_datetime(S), util_time:timestamp_to_datetime(E)}}]),
                        [S, E]
                end;
            [[[S_Y, S_M, S_D], [S_HH, S_MM, S_SS]], [[E_Y, E_M, E_D], [E_HH, E_MM, E_SS]]] ->
                ?ASSERT(util_time:is_valid_datetime({{S_Y, S_M, S_D}, {S_HH, S_MM, S_SS}}), {not_valid_activity_time, ActivityId, TimeList}),
                ?ASSERT(util_time:is_valid_datetime({{E_Y, E_M, E_D}, {E_HH, E_MM, E_SS}}), {not_valid_activity_time, ActivityId, TimeList}),
                %% S_Y年S_M月S_D日 S_HH时S_MM分S_SS秒 -> E_Y年E_M月E_D日 E_HH时E_MM分E_SS秒
                S = util_time:datetime_to_timestamp({{S_Y, S_M, S_D}, {S_HH, S_MM, S_SS}}),
                E = util_time:datetime_to_timestamp({{E_Y, E_M, E_D}, {E_HH, E_MM, E_SS}}),
                [S, E];
            Other ->
                ?ERROR("parse time config no match:~p", [Other]),
                exit({parse_activity_time_no_match, Other})
        end,
    ?ASSERT((StartTime == 0 orelse EndTime == 0) orelse (StartTime < EndTime), {parse_activity_time_error_1, {ActivityId, NowTimestamp, WeekList, TimeList}, [StartTime, EndTime]}),

    {StartTime, EndTime}.


%% @doc 是否开服合服限制
is_server_limit(ActivityId) ->
    ServerType = mod_server_config:get_server_type(),
    if ServerType == ?SERVER_TYPE_GAME ->
        #t_activity_info{
            open_server_day_limit_list = OpenServerDayLimitList,
            merge_server_day_limit_list = MergeServerDayLimitList
        } = activity:get_t_activity_info(ActivityId),
        OpenServerDay = mod_server:get_server_open_day_number(),
        MergeServerDay = mod_server:get_server_merge_day_number(),
        %% 开服时间限制
        IsOpenServerDayLimit =
            case OpenServerDayLimitList of
                [] ->
                    false;
                [OS, OE] ->
                    ?t_assert(OE >= OS orelse OE == 0, {open_server_day_error, OpenServerDayLimitList}),
                    (OS =< OpenServerDay andalso (OpenServerDay =< OE orelse OE == 0)) == false
            end,
        %% 合服时间限制
        IsMergeServerDayList =
            case MergeServerDayLimitList of
                [] ->
                    false;
                [MS, ME] ->
                    ?t_assert(ME >= MS orelse ME == 0, {merge_server_day_error, MergeServerDayLimitList}),
                    (MS =< MergeServerDay andalso (MergeServerDay =< ME orelse ME == 0)) == false
            end,
        IsOpenServerDayLimit orelse IsMergeServerDayList;
        true ->
            false
    end.