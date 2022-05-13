%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2018, THYZ
%%% @doc
%%% @end
%%% Created : 02. 一月 2018 上午 10:15
%%%-------------------------------------------------------------------
-module(util_time).

%% API 基础函数
-export([
    init_offset/0,                      %% 初始化时间偏移量
    update_offset_time/1,
    local_time/0,                       %% 获取服务器时间
    local_date/0,                       %% 获取服务器日期
    local_datetime/0,                   %% 获取服务器日期时间
    timestamp/0,                        %% 获取服务器时间戳(秒)
    milli_timestamp/0,                  %% 获取服务器时间戳(微秒)
    timestamp_to_datetime/1,            %% 时间戳转换日期
    datetime_to_timestamp/1,            %% 日期转换时间戳
    timestamp_to_datestr/1,
    timestamp_to_monthstr/1
]).

%% API
-export([
    is_today/1,                         %% 是否是今天
    is_today/2,                         %% 是否是今天
    is_today_date/2,                    %% 是否是Date的时间段 {H, MM, S}
    is_yesterday/1,                     %% 是否是昨天
    is_this_week/1,                     %% 是否是同一周
    get_week/0,                         %% 获取星期几
    get_week/1,
    get_end_date_timestamp/1,           %% 获得结束时间 Date:{H, MM, S}
    get_interval_day/1,                 %% 获取间隔天数
    get_interval_day_add_1/1,           %% 获取间隔天数
    get_abs_interval_day/1,             %% 获取绝对间隔天数
    get_today_timestamp/1,              %% 获取今日某个时间时间戳
    get_tomorrow_timestamp/1,           %% 获取明日某个时间时间戳
    get_monday_zero_timestamp/0,        %% 获取本周星期一0点的时间戳
    get_monday_zero_timestamp/1,
    get_next_hour_timestamp/0,          %% 获取下一个小时时间戳
    get_next_hour_timestamp/1,
    get_next_tidy_minute_timestamp/1,   %% 获取下一个整数分钟时间戳
    get_next_tidy_minute_timestamp/2,
    get_format_datetime_string/0,       %% 获取时间字符串
    get_format_datetime_string/1,
    get_format_datetime_string_simple/0,% 获得时间字符串简易版
    get_format_datetime_string_simple/1,% 获得时间字符串简易版
    format_datetime/0,
    format_datetime/1,
    get_next_date_h_timestamp/1,        %% 获得明天几点的时间
    get_next_date_h_differ_s/1,         %% 获得明天时间相差秒
    get_next_month_1_day_times/1,       %% 获得下个月1号的时间戳
    get_next_month_1_day_times/2,       %% 获得下个月1号的时间戳
    get_before_month_1_day_times/2,     %% 获得上个月一号时间戳
    get_before_month_1_day_times/1,
    get_today_zero_timestamp/0,         %% 今天0点的时间
    get_today_zero_timestamp/1,         %% 获得时间戳的0点时间
    get_date_h_timestamp/2,             %% 获得指定天的几点的时间
    get_month_1_day_times/1,            %% 获得这个月1号的时间戳
    get_month_1_day_times/2,             %% 获得这个月1号的时间戳
    get_month_days/0,
    get_month_days/2,
    is_valid_datetime/1,
    is_valid_time/1
]).

-export([
    datetime_string_to_datetime/1
]).

-ifdef(debug).
-define(IS_DEBUG, true).
-else.
-define(IS_DEBUG, false).
-endif.

%% ----------------------------------
%% @doc 	是否是今天
%% @throws 	none
%% @end
%% ----------------------------------
is_today({Y, M, D}) ->
    {Y, M, D} =:= local_date();
is_today({{Y, M, D}, {_HH, _MM, _SS}}) ->
    is_today({Y, M, D}, local_date());
is_today(Timestamp) ->
    is_today(Timestamp, local_date()).
is_today(Timestamp, Timestamp1) when is_integer(Timestamp) andalso is_integer(Timestamp1) ->
    {Date1, {_HH, _MM, _SS}} = timestamp_to_datetime(Timestamp),
    is_today(Timestamp, Date1);
is_today(Timestamp, Date1) when is_integer(Timestamp) ->
    {Date, {_HH, _MM, _SS}} = timestamp_to_datetime(Timestamp),
    is_today(Date, Date1);
is_today(Date, Date1) ->
    Date =:= Date1.

%% ----------------------------------
%% @doc 	是否是昨天
%% @throws 	none
%% @end
%% ----------------------------------
is_yesterday(CheckTimestamp) when is_integer(CheckTimestamp) ->
    TodayDate = local_date(),
    {CheckDate, _} = timestamp_to_datetime(CheckTimestamp + 86400),
    TodayDate == CheckDate.

%% 是否是Date的时间段 {H, MM, S}
is_today_date(Timestamp, Date) ->
    {CurrDay, CurrDate} = local_datetime(),
    DateTime = datetime_to_timestamp({CurrDay, Date}),
    CurrDate < Date andalso DateTime - 86400 < Timestamp andalso Timestamp < DateTime
        orelse Date =< CurrDate andalso DateTime < Timestamp.

%% 获得结结束时间 Date:{H, MM, S}
get_end_date_timestamp(Date) ->
    {CurrDay, CurrDate} = local_datetime(),
    DateTime = datetime_to_timestamp({CurrDay, Date}),
    if
        CurrDate < Date ->
            DateTime;
        true ->
            DateTime + 86400
    end.

%% ----------------------------------
%% @doc 	是否是同一周
%% @throws 	none
%% @end
%% ----------------------------------
is_this_week(Timestamp) when is_integer(Timestamp) ->
    {Date, _} = timestamp_to_datetime(Timestamp),
    is_this_week(Date);
is_this_week({Date, _Time}) ->
    is_this_week(Date);
is_this_week({Year, Month, Day}) ->
    {_, CurrWeekCount} = calendar:iso_week_number(local_date()),
    {_, WeekCount} = calendar:iso_week_number({Year, Month, Day}),
%%    NowWeek = get_week(),
%%    ThatWeek = get_week({Year, Month, Day}),
    CurrWeekCount == WeekCount.

%% ----------------------------------
%% @doc 	获取time
%% @throws 	none
%% @end
%% ----------------------------------
%%time() ->
%%    erlang:time().


local_time() ->
    case ?IS_DEBUG of
        true ->
            {_Date, Time} = timestamp_to_datetime(timestamp()),
            Time;
        _ ->
            erlang:time()
    end.

local_date() ->
    case ?IS_DEBUG of
        true ->
            {Date, _Time} = timestamp_to_datetime(timestamp()),
            Date;
        _ ->
            erlang:date()
    end.

%% ----------------------------------
%% @doc 	获取 datetime
%% @throws 	none
%% @end
%% ----------------------------------
local_datetime() ->
    case ?IS_DEBUG of
        true ->
            timestamp_to_datetime(timestamp());
        _ ->
            erlang:localtime()
    end.

%% ----------------------------------
%% @doc 	初始化时间偏移量
%% @throws 	none
%% @end
%% ----------------------------------
init_offset() ->
    case ?IS_DEBUG of
        true ->
            case catch (util_file:load_term(offset_time_config_file())) of
                [{timestamp, Timestamp}] ->
                    if
                        Timestamp > 0 ->
                            Offset = Timestamp - timestamp(),
                            env:set('timestamp_offset', Offset),
                            logger:info("初始化时间偏移量:~p", [{Offset, timestamp_to_datetime(Timestamp)}]);
                        true ->
                            noop
                    end;
                _ ->
                    noop
            end;
        false ->
            noop
    end.

update_offset_time(Time) ->
    FileName = offset_time_config_file(),
    util_file:save_term(FileName, [{timestamp, Time}]).

offset_time_config_file() ->
    io_lib:format("../config/~p_time.config", [node()]).

%% ----------------------------------
%% @doc 	获取当前时间戳 (秒)
%% @throws 	none
%% @end
%% ----------------------------------
timestamp() ->
    {MegaSecs, Secs, _MicroSecs} = os:timestamp(),
    Timestamp = MegaSecs * 1000000 + Secs,
    case ?IS_DEBUG of
        true ->
            Timestamp + env:get('timestamp_offset', 0);
        _ ->
            Timestamp
    end.

%% ----------------------------------
%% @doc 	获取当前时间戳 (毫秒)
%% @throws 	none
%% @end
%% ----------------------------------
milli_timestamp() ->
    {MegaSecs, Secs, MicroSecs} = os:timestamp(),
    MilliTimestamp = MegaSecs * 1000000000 + Secs * 1000 + MicroSecs div 1000,
    case ?IS_DEBUG of
        true ->
            MilliTimestamp + env:get('timestamp_offset', 0) * 1000;
        _ ->
            MilliTimestamp
    end.

%% ----------------------------------
%% @doc 	datetime(按照+、T、-、/拆分日期格式字符串) -> [YYYY, MM, DD, H, i, s]
%% @doc     目前支持格式: 2021-09-01 02:03:04、2021/09/01 02:03:04、2021-09-01T02:03:04+08:00
%% @throws 	none
%% @end
%% ----------------------------------
datetime_string_to_datetime(DatetimeString) ->
    datetime_string_to_datetime(DatetimeString, {"-", "/"}).
datetime_string_to_datetime(DatetimeString, Spec) when is_tuple(Spec) ->
    lists:foldl(
        fun(SingleSpec, Tmp) ->
            case string:str(DatetimeString, SingleSpec) of
                0 -> Tmp;
                Exists when is_integer(Exists) andalso length(DatetimeString) >= Exists ->
                    if
                        Tmp =:= [] -> datetime_string_to_datetime(DatetimeString, SingleSpec);
                        true -> [Tmp | datetime_string_to_datetime(DatetimeString, SingleSpec)]
                    end;
                _ -> Tmp
            end
        end,
        [],
        tuple_to_list(Spec)
    );
datetime_string_to_datetime(DatetimeString, Spec) ->
    case Spec of
        "-" ->
            case string:tokens(DatetimeString, Spec) of
                [Y, M, Others] -> [Y, M | datetime_string_to_datetime(Others, {" ", "T"})];
                O -> O
            end;
        "/" ->
            case string:tokens(DatetimeString, Spec) of
                [Y, M, Others] -> [Y, M | datetime_string_to_datetime(Others, {" ", "T"})];
                O -> O
            end;
        " " ->
            case string:tokens(DatetimeString, Spec) of
                [D, Hms] -> [D | datetime_string_to_datetime(Hms, ":")];
                O -> O
            end;
        "T" ->
            case string:tokens(DatetimeString, Spec) of
                [D, Hms] -> [D | datetime_string_to_datetime(Hms, "+")];
                O -> O
            end;
        "+" ->
            case string:tokens(DatetimeString, Spec) of
                [Hms, _TimeZone] -> datetime_string_to_datetime(Hms, ":");
                O -> O
            end;
        ":" ->
            string:tokens(DatetimeString, Spec)
    end.

%% ----------------------------------
%% @doc 	datetime -> 时间戳
%% @throws 	none
%% @end
%% ----------------------------------
datetime_to_timestamp({[Y, M, D], [HH, MM, SS]}) ->
    datetime_to_timestamp({{Y, M, D}, {HH, MM, SS}});
datetime_to_timestamp([[Y, M, D], [HH, MM, SS]]) ->
    datetime_to_timestamp({{Y, M, D}, {HH, MM, SS}});
datetime_to_timestamp([{Y, M, D}, {HH, MM, SS}]) ->
    datetime_to_timestamp({{Y, M, D}, {HH, MM, SS}});
datetime_to_timestamp({Date, Time}) ->
    calendar:datetime_to_gregorian_seconds({Date, Time}) - 62167248000.

%% ----------------------------------
%% @doc 	时间戳 -> datetime
%% @throws 	none
%% @end
%% ----------------------------------
timestamp_to_datetime(Timestamp) when is_integer(Timestamp) ->
    calendar:gregorian_seconds_to_datetime(Timestamp + 62167248000).

timestamp_to_monthstr(Seconds) ->
    {{Y, M, _}, _} = timestamp_to_datetime(Seconds),
    lists:append([format_2(I) || I <- [Y, M]]).

timestamp_to_datestr(Seconds) ->
    {{Y, M, D}, _} = timestamp_to_datetime(Seconds),
    lists:append([format_2(I) || I <- [Y, M, D]]).

%% ----------------------------------
%% @doc 	获取周几
%% @throws 	none
%% @end
%% ----------------------------------
get_week() ->
    get_week(local_date()).
get_week(Timestamp) when is_integer(Timestamp) ->
    {Date, _} = timestamp_to_datetime(Timestamp),
    get_week(Date);
get_week({Date, _Time}) ->
    get_week(Date);
get_week({Year, Month, Day}) ->
    calendar:day_of_the_week(Year, Month, Day).


%%today_left_second() ->
%%    {_, {Hour, Minute, Second}} = erlang:localtime(),
%%    86400 - (Hour * 60 * 60 + Minute * 60 + Second).
%%%% 距{H, MM, S}剩余几秒
%%today_left_second({H, MM, S}) ->
%%    {Hour, Minute, Second} = erlang:time(),
%%    if
%%        H > Hour ->
%%            (H * 60 * 60 + MM * 60 + S) - (Hour * 60 * 60 + Minute * 60 + Second);
%%        true ->
%%            86400 + (H * 60 * 60 + MM * 60 + S) - (Hour * 60 * 60 + Minute * 60 + Second)
%%    end.

%% ----------------------------------
%% @doc 	获取绝对间隔天数
%% @throws 	none
%% @end
%% ----------------------------------
get_abs_interval_day(Timestamp) when is_integer(Timestamp) ->
    {Data, _Time} = timestamp_to_datetime(Timestamp),
    NowTimestamp = timestamp(),
    abs(NowTimestamp - datetime_to_timestamp({Data, {0, 0, 0}})) div 86400.

%% ----------------------------------
%% @doc 	获取间隔天数
%% @throws 	none
%% @end
%% ----------------------------------
get_interval_day(Timestamp) ->
    {Data, _Time} = timestamp_to_datetime(Timestamp),
    floor((timestamp() - datetime_to_timestamp({Data, {0, 0, 0}})) / 86400).
%% @fun 获取间隔天数 + 1
get_interval_day_add_1(Timestamp) ->
    get_interval_day(Timestamp) + 1.

format_datetime() ->
    {{YY, MM, DD}, {H, M, S}} = local_datetime(),
    format_datetime({{YY, MM, DD}, {H, M, S}}).

format_datetime(Timestamp) when is_integer(Timestamp) ->
    format_datetime(timestamp_to_datetime(Timestamp));
format_datetime({{YY, MM, DD}, {H, M, S}}) ->
    lists:concat([YY, "-", format_2(MM), "-", format_2(DD), " ", format_2(H), ":", format_2(M), ":", format_2(S)]).


%% return eg: "20160514144751"
get_format_datetime_string() ->
    get_format_datetime_string(local_datetime()).
get_format_datetime_string({{Y, M, D}, {HH, MM, SS}}) ->
    integer_to_list(Y) ++ format_2(M) ++ format_2(D) ++
        format_2(HH) ++ format_2(MM) ++ format_2(SS);
get_format_datetime_string({Y, M, D}) ->
    integer_to_list(Y) ++ format_2(M) ++ format_2(D).
format_2(N) ->
    case N of
        0 -> "00";
        1 -> "01";
        2 -> "02";
        3 -> "03";
        4 -> "04";
        5 -> "05";
        6 -> "06";
        7 -> "07";
        8 -> "08";
        9 -> "09";
        N ->
            integer_to_list(N)
    end.

%% @doc fun 获得时间字符串简易版
get_format_datetime_string_simple() ->
    get_format_datetime_string_simple(local_datetime()).
get_format_datetime_string_simple(Timestamp) when is_integer(Timestamp) ->
    get_format_datetime_string_simple(timestamp_to_datetime(Timestamp));
get_format_datetime_string_simple({{Y, M, D}, {HH, MM, SS}}) ->
    integer_to_list(Y rem 100) ++ format_2(M) ++ format_2(D) ++
        format_2(HH) ++ format_2(MM) ++ format_2(SS).

get_next_tidy_minute_timestamp(N) ->
    get_next_tidy_minute_timestamp(timestamp(), N).
get_next_tidy_minute_timestamp(Timestamp, N) when N >= 1 ->
    {{_Y, _M, _D}, {_HH, MM, _SS}} = timestamp_to_datetime(Timestamp),
    datetime_to_timestamp({{_Y, _M, _D}, {_HH, MM div N * N, 0}}) + 60 * N.

%% ----------------------------------
%% @doc 	获取下一个小时时间戳
%% @throws 	none
%% @end
%% ----------------------------------
get_next_hour_timestamp() ->
    get_next_hour_timestamp(timestamp()).
get_next_hour_timestamp(Timestamp) ->
    {{_Y, _M, _D}, {HH, _MM, _SS}} = timestamp_to_datetime(Timestamp),
    datetime_to_timestamp({{_Y, _M, _D}, {HH, 0, 0}}) + 3600.

%% ----------------------------------
%% @doc 	获取今日某个时间时间戳
%% @throws 	none
%% @end
%% ----------------------------------
get_today_timestamp({Hour, Minute, Second}) ->
    datetime_to_timestamp({local_date(), {Hour, Minute, Second}}).

%% ----------------------------------
%% @doc 	获取明日某个时间时间戳
%% @throws 	none
%% @end
%% ----------------------------------
get_tomorrow_timestamp({Hour, Minute, Second}) ->
    datetime_to_timestamp({local_date(), {Hour, Minute, Second}}) + 86400.


%% ----------------------------------
%% @doc 	获取本周星期一0点的时间戳
%% @throws 	none
%% @end
%% ----------------------------------
get_monday_zero_timestamp() ->
    get_monday_zero_timestamp(local_date()).
get_monday_zero_timestamp(Timestamp) when is_integer(Timestamp) ->
    {Date, _} = timestamp_to_datetime(Timestamp),
    get_monday_zero_timestamp(Date);
get_monday_zero_timestamp(Date) ->
    TodayZeroTimestamp = datetime_to_timestamp({Date, {0, 0, 0}}),
    Week = get_week(Date),
    TodayZeroTimestamp - 86400 * (Week - 1).

%% @fun 今天0点的时间
get_today_zero_timestamp() ->
    get_date_h_timestamp(0).
get_today_zero_timestamp(Timestamp) ->
    {Date, _} = timestamp_to_datetime(Timestamp),
    get_date_h_timestamp(Date, 0).

%% 获得今天几点的时间
get_date_h_timestamp(H) ->
    get_date_h_timestamp(local_date(), H).
%% 获得明天几点的时间
get_next_date_h_timestamp(H) ->
    get_date_h_timestamp(H) + 86400.
%% 获得指定天的几点的时间
get_date_h_timestamp(Date, H) when is_integer(H) andalso 0 =< H andalso H =< 23 ->
    datetime_to_timestamp({Date, {H, 0, 0}});
get_date_h_timestamp(Date, {_H, _M, _S} = Time) ->
    datetime_to_timestamp({Date, Time}).


%% 获得上个月一号时间戳
get_before_month_1_day_times({Year, Month, _Day}) ->
    get_next_month_1_day_times(Year, Month).
get_before_month_1_day_times(Year, Month) ->
    Date =
        if
            Month > 1 ->
                {Year, Month - 1, 1};
            true ->
                {Year - 1, 12, 1}
        end,
    get_date_h_timestamp(Date, 0).

%% 获得下个月一号时间戳
get_next_month_1_day_times({Year, Month, _Day}) ->
    get_next_month_1_day_times(Year, Month).
get_next_month_1_day_times(Year, Month) ->
    Date =
        if
            Month < 12 ->
                {Year, Month + 1, 1};
            true ->
                {Year + 1, 1, 1}
        end,
    get_date_h_timestamp(Date, 0).

%% 获得明天时间相差秒
get_next_date_h_differ_s(H) ->
    get_next_date_h_timestamp(H) - timestamp().

%% 获得本月一号时间戳
get_month_1_day_times({Year, Month, _Day}) ->
    get_month_1_day_times(Year, Month).
get_month_1_day_times(Year, Month) ->
    Date = {Year, Month, 1},
    get_date_h_timestamp(Date, 0).

%% 判断当前月多少天
get_month_days() ->
    {{Year, Month, _}, {_, _, _}} = timestamp_to_datetime(timestamp()),
    get_month_days(Year, Month).

%% 根据年月判断当月多少天
get_month_days(_Year, 1) -> 31;
get_month_days(Year, 2) when Year rem 4 =:= 0, Year rem 100 /= 0 orelse Year rem 400 =:= 0 -> 29;
get_month_days(_Year, 2) -> 28;
get_month_days(_Year, 3) -> 31;
get_month_days(_Year, 4) -> 30;
get_month_days(_Year, 5) -> 31;
get_month_days(_Year, 6) -> 30;
get_month_days(_Year, 7) -> 31;
get_month_days(_Year, 8) -> 31;
get_month_days(_Year, 9) -> 30;
get_month_days(_Year, 10) -> 31;
get_month_days(_Year, 11) -> 30;
get_month_days(_Year, 12) -> 31.

%% @doc 是否有效日期时间
is_valid_datetime({{Y, M, D}, {HH, MM, SS}}) ->
    is_valid_date({Y, M, D}) andalso is_valid_time({HH, MM, SS}).

%% @doc 是否有效日期
is_valid_date({Y, M, D}) ->
    calendar:valid_date({Y, M, D}).

%% @doc 是否有效时间
is_valid_time({HH, MM, SS}) when is_integer(HH), is_integer(MM), is_integer(SS) ->
    HH >= 0 andalso HH =< 23 andalso
        MM >= 0 andalso MM =< 59 andalso
        SS >= 0 andalso SS =< 59.
