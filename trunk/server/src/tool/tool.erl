%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            工具
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(tool).
-compile(export_all).
%%-include("gen/table_enum.hrl").
-include("common.hrl").
%% 获取系统进程数
get_system_process_num() ->
    erlang:system_info(process_count).
get_system_memory_info() ->
    erlang:memory().

%%开启etop监控
start_etop_image() ->
    start_etop_image(runtime).
start_etop_image(Sort) ->
    spawn(fun() -> etop:start([{interval, 1}, {sort, Sort}]) end).

start_etop_text() ->
    start_etop_text(runtime).
start_etop_text(Sort) ->
    start_etop([{output, text}, {interval, 1}, {lines, 20}, {sort, Sort}]).

start_etop(Options) ->
    spawn(fun() -> etop:start(Options) end).

stop_etop() ->
    etop:stop().

%%webtool http://localhost:8888/
start_webtool() ->
    webtool:start().
%%获取所有应用
get_all_running_applications() ->
    lists:keyfind(running, 1, application:info()).
%%交叉检测
xref() ->
    Context = xref_runner:check("../config/xref.config"),
    util_file:save_term("xref.txt", Context).


get_max_memory_ets(Num) ->
    L = ets:all(),
    L1 = lists:foldl(
        fun(E, Tmp) ->
            M = util_list:opt(memory, ets:info(E)),
            S = util_list:opt(size, ets:info(E)),
            case is_atom(E) of
                true ->
                    case lists:prefix("map_mark_", util:to_list(E)) of
                        true ->
                            Tmp;
                        false ->
                            [{E, M div 1024, S} | Tmp]
                    end;
                false ->
                    Tmp
            end
        end,
        [],
        L
    ),
    L2 = lists:reverse(lists:keysort(2, L1)),
    lists:sublist(L2, Num).


%%进程信息
processes_info() ->
    processes_info([{sort, red}, {num, 5}]).
%% red mem mes_len
processes_info(Option) ->
    processes_info(Option, erlang:processes()).
processes_info(Option, Processes) ->
    Sort = opt(sort, Option),
    Num = opt(num, Option),
    A = lists:foldl(
        fun(Pid, Tmp) ->
            {_, MesLen} = erlang:process_info(Pid, message_queue_len),
            {_, Red} = erlang:process_info(Pid, reductions),
            {_, Mem} = erlang:process_info(Pid, memory),
            %% 如果是按mes_len排序，过滤mes_len =< 1 的进程 2017/11/15 0015 上午 9:46
            if (Sort == red andalso Red > 10000000) orelse %% red > 10000000
            (Sort == mem andalso Mem > 1024 * 1024 * 1) orelse %% 内存 > 1M
            (Sort == mes_len andalso MesLen > 2) -> %% 消息长度 > 2
                RegName = case erlang:process_info(Pid, registered_name) of
                              "" ->
                                  "";
                              {_, Name} ->
                                  Name
                          end,
                {_, Stack} =
                    if Sort == mes_len ->
                        erlang:process_info(Pid, current_stacktrace);
                        true ->
                            erlang:process_info(Pid, current_location)
                    end,
                [
                    {
                        Pid,
                        {name, RegName},
                        {red, Red},
                        {mem, Mem},
                        {mes_len, MesLen},
                        {stack, Stack}
                    }
                    | Tmp
                ];
                true ->
                    Tmp
            end
        end,
        [],
        Processes
    ),
    F = fun({_, _, Red1, Mem1, MesLen1, _}, {_, _, Red2, Mem2, MesLen2, _}) ->
        case Sort of
            red ->
                if Red1 > Red2 ->
                    true;
                    true ->
                        false
                end;
            mem ->
                if Mem1 > Mem2 ->
                    true;
                    true ->
                        false
                end;
            mes_len ->
                if MesLen1 > MesLen2 ->
                    true;
                    true ->
                        false
                end
        end
        end,
    lists:sublist(lists:sort(F, A), Num).
%%processes_info(Option, Processes) ->
%%    Sort = opt(sort, Option),
%%    Num = opt(num, Option),
%%    A = lists:foldl(
%%        fun(Pid, Tmp) ->
%%            [
%%                {
%%                    Pid,
%%                    erlang:process_info(Pid, registered_name),
%%                    erlang:process_info(Pid, reductions),
%%                    erlang:process_info(Pid, memory),
%%                    erlang:process_info(Pid, message_queue_len)
%%                }
%%                | Tmp
%%            ]
%%        end,
%%        [],
%%        Processes
%%    ),
%%    F = fun({_, _, Red1, Mem1, MesLen1}, {_, _, Red2, Mem2, MesLen2}) ->
%%        case Sort of
%%            red ->
%%                if Red1 > Red2 ->
%%                    true;
%%                    true ->
%%                        false
%%                end;
%%            mem ->
%%                if Mem1 > Mem2 ->
%%                    true;
%%                    true ->
%%                        false
%%                end;
%%            mes_len ->
%%                if MesLen1 > MesLen2 ->
%%                    true;
%%                    true ->
%%                        false
%%                end
%%        end
%%        end,
%%    lists:sublist(lists:sort(F, A), Num).


opt(Key, Options) ->
    opt(Key, Options, undefined).
opt(Key, [{Key, Value} | _], _Default) ->
    Value;
opt(Key, [_ | Options], Default) ->
    opt(Key, Options, Default);
opt(_, [], Default) ->
    Default.

get_pids_by_memory(Memory) ->
    PList = erlang:processes(),
    lists:filter(
        fun(T) ->
            case erlang:process_info(T, memory) of
                {_, VV} ->
                    if VV > Memory -> true;
                        true -> false
                    end;
                _ -> true
            end
        end, PList).
%% GC
gc(Memory) ->
    S = util_time:milli_timestamp(),
    ?INFO("开始GC(~pkb)...", [Memory div 1024]),
    lists:foreach(
        fun(PID) ->
            Status = erlang:process_info(PID, status),
            if {status, waiting} == Status ->
                erlang:garbage_collect(PID);
                true ->
                    noop
            end
        end,
        get_pids_by_memory(Memory)
    ),
    E = util_time:milli_timestamp(),
    CostTime = E - S,
    ?INFO("GC(~pkb)完毕, 耗时 ~p ms.", [Memory div 1024, CostTime]).

%%分析erl_crash.dump 文件
analyse_crash_dump() ->
    crashdump_viewer:start().

eprof_all(TimeoutSec) ->
    eprof(processes() -- [whereis(eprof)], TimeoutSec).

eprof(Pids, TimeoutSec) ->
    eprof:start(),
    eprof:start_profiling(Pids),
    timer:sleep(TimeoutSec),
    eprof:stop_profiling(),
    eprof:analyze(total),
    eprof:stop().

scheduler_stat() ->
    scheduler_stat(1000).

scheduler_stat(RunMs) ->
    erlang:system_flag(scheduling_statistics, enable),
    Ts0 = erlang:system_info(total_scheduling_statistics),
    timer:sleep(RunMs),
    Ts1 = erlang:system_info(total_scheduling_statistics),
    erlang:system_flag(scheduling_statistics, disable),
    lists:map(fun({{Key, In0, Out0}, {Key, In1, Out1}}) ->
        {Key, In1 - In0, Out1 - Out0} end, lists:zip(Ts0, Ts1)).

proc_mem_all(SizeLimitKb) ->
    Procs = [{undefined, Pid} || Pid <- erlang:processes()],
    proc_mem(Procs, SizeLimitKb).

proc_mem(SizeLimitKb) ->
    Procs = [{Name, Pid} || {_, Name, Pid, _} <- release_handler_1:get_supervised_procs(),
        is_process_alive(Pid)],
    proc_mem(Procs, SizeLimitKb).

proc_mem(Procs, SizeLimitKb) ->
    SizeLimit = SizeLimitKb * 1024,
    {R, Total} = lists:foldl(fun({Name, Pid}, {Acc, TotalSize}) ->
        case erlang:process_info(Pid, total_heap_size) of
            {_, Size0} ->
                Size = Size0 * 8,
                case Size > SizeLimit of
                    true -> {[{Name, Pid, Size} | Acc], TotalSize + Size};
                    false -> {Acc, TotalSize}
                end;
            _ -> {Acc, TotalSize}
        end
                             end, {[], 0}, Procs),
    R1 = lists:keysort(3, R),
    {Total, lists:reverse(R1)}.

%% 项目助手
project_helper(Action) ->
    if Action == "restart" ->
        game:restart();
        true ->
            case os:type() of
                {unix, _} ->
                    CmdOut = os:cmd("./helper.sh " ++ Action),
                    case string:str(CmdOut, "All finished") of
                        0 ->
                            io:format("~s~n", [CmdOut]),
                            fail;
                        _ ->
                            reloader:reload_changes(),
                            ok
                    end;
                {win32, _} ->
                    CmdOut = os:cmd("项目工具.bat " ++ Action),
                    case string:str(CmdOut, "All finished") of
                        0 ->
                            io:format("~s~n", [CmdOut]),
                            fail;
                        _ ->
                            reloader:reload_changes(),
                            ok
                    end
            end
    end.

give_prop(PlayerId, _PropType, PropId, Num) ->
    IntPlayerId = util:to_int(PlayerId),
    IntPropId = util:to_int(PropId),
    IntNum = util:to_int(Num),
    ?DEBUG("~p~n", [{IntPlayerId, IntPropId, IntNum}]),

    ?ASSERT(mod_player:get_player(IntPlayerId) =/= null, {player_no_exists, PlayerId}),
    mod_apply:apply_to_online_player(IntPlayerId, mod_award, give, [IntPlayerId, [{IntPropId, IntNum}], 1], store),
%%    mod_award:give(IntPlayerId, [{IntPropType, IntPropId, IntNum}], ?LOG_TYPE_GM_SEND),
    ok.

debug_set_task(ArgsPlayerId, ArgsTaskId) ->
    PlayerId = util:to_int(ArgsPlayerId),
    TaskId = util:to_int(ArgsTaskId),
    ?ASSERT(mod_player:get_player(PlayerId) =/= null, {player_no_exists, PlayerId}),
    mod_apply:apply_to_online_player(PlayerId, mod_task, debug_set_task, [PlayerId, TaskId], store),
    ok.

finish_branch_task(ArgsPlayerId) ->
    PlayerId = util:to_int(ArgsPlayerId),
    ?ASSERT(mod_player:get_player(PlayerId) =/= null, {player_no_exists, PlayerId}),
    mod_apply:apply_to_online_player(PlayerId, mod_branch_task, get_award, [PlayerId, false]),
    ok.

active_function(ArgsPlayerId, ArgsFunctionId, ArgsParam, ArgsValue) ->
    PlayerId = util:to_int(ArgsPlayerId),
    FunctionId = util:to_int(ArgsFunctionId),
    Param = util:to_int(ArgsParam),
    Value = util:to_int(ArgsValue),
    ?ASSERT(mod_player:get_player(PlayerId) =/= null, {player_no_exists, PlayerId}),
    mod_apply:apply_to_online_player(PlayerId, mod_function, test_change_fun, [PlayerId, FunctionId, Param, Value], store),
    ok.

finish_mission(ArgsPlayerId, ArgsMissionType, ArgsMissionId) ->
    PlayerId = util:to_int(ArgsPlayerId),
    MissionType = util:to_int(ArgsMissionType),
    MissionId = util:to_int(ArgsMissionId),
    ?ASSERT(mod_player:get_player(PlayerId) =/= null, {player_no_exists, PlayerId}),
    mod_apply:apply_to_online_player(PlayerId, mod_mission, direct_finish, [PlayerId, MissionType, MissionId], store),
    ok.

