%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            测试
%%% @end
%%% Created : 15. 六月 2016 上午 9:23
%%%-------------------------------------------------------------------

%开始记录
-define(START_RECORD,
    {Time1, _} = statistics(runtime),
    {Time2, _} = statistics(wall_clock)
).

%停止记录
-define(STOP_RECORD,
    ?STOP_RECORD("")
).
-define(STOP_RECORD(Title),
    {Time3, _} = statistics(runtime),
    {Time4, _} = statistics(wall_clock),
    Sec1 = (Time3 - Time1) / 1000.0,
    Sec2 = (Time4 - Time2) / 1000.0,
    case Title of
        "" ->
            io:format("CPU: ~p, Program :~p seconds~n", [Sec1, Sec2]);
        _ ->
            case erlang:is_list(Title) of
                true ->
                    io:format("[~s] CPU: ~p, Program :~p seconds~n", [Title, Sec1, Sec2]);
                _ ->
                    io:format("[~p] CPU: ~p, Program :~p seconds~n", [Title, Sec1, Sec2])
            end
    end
).
