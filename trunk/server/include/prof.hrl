%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 15. 六月 2016 上午 9:23
%%%-------------------------------------------------------------------
-define(TABLE_NAME, prof_data).
-record(prof_data, {
    key,
    times = 1,
    runtime = 0,
    wallclock = 0
}).

-ifdef(debug).
-define(START_PROF,
    {Time1, _} = statistics(runtime),
    {Time2, _} = statistics(wall_clock)
).
-define(STOP_PROF(Module, Function, Argument),
    {Time3, _} = statistics(runtime),
    {Time4, _} = statistics(wall_clock),
    Sec1 = (Time3 - Time1) / 1000.0,
    Sec2 = (Time4 - Time2) / 1000.0,
    prof_srv:set_info(Module, Function, Argument, Sec1, Sec2)
).
-else.
-define(START_PROF, noop).
-define(STOP_PROF(Module, Function, Argument), noop).
-endif.
