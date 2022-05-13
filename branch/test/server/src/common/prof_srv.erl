%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            性能监控
%%% @end
%%% Created : 15. 六月 2016 上午 9:23
%%%-------------------------------------------------------------------
-module(prof_srv).
-include("prof.hrl").
-define(SERVER, prof_srv).

-export([start_link/0, init/0]).

-export([
    set_info/5,
    get_info/0,
    get_info/1,
    get_info/2,
    get_info/3,
    profile/2,
    profile/0,
    cleanup/0
]).



start_link() ->
    {ok, Pid} = proc_lib:start_link(?MODULE, init, []),
    {ok, Pid}.

init() ->
    register(?SERVER, self()),
    proc_lib:init_ack({ok, self()}),
    ets:new(?TABLE_NAME, [named_table, set, protected, {keypos, #prof_data.key}]),
    loop().

loop() ->
    receive
        {set_info, Key, Runtime, Wallclock} ->
            case ets:lookup(?TABLE_NAME, Key) of
                [] ->
                    ets:insert(?TABLE_NAME,
                        #prof_data{
                            key = Key,
                            times = 1,
                            runtime = Runtime,
                            wallclock = Wallclock
                        });

                [Data] ->
                    ets:insert(?TABLE_NAME,
                        Data#prof_data{
                            times = Data#prof_data.times + 1,
                            runtime = Data#prof_data.runtime + Runtime,
                            wallclock = Data#prof_data.wallclock + Wallclock
                        })
            end;
        {get_info, From} ->
                catch From ! {prof, ets:tab2list(?TABLE_NAME)};
        {get_info, From, Module, Action, Argument} ->
                catch From ! {prof, ets:lookup(?TABLE_NAME, {Module, Action, Argument})};
        {get_info, From, Module, Action} ->
                catch From ! {prof, ets:select(?TABLE_NAME, [
                #prof_data{key = {Module, Action, '_'}, _ = '_'}, [], {'$_'}
            ])};
        {get_info, From, Module} ->
                catch From ! {prof, ets:select(?TABLE_NAME, [
                #prof_data{key = {Module, '_', '_'}, _ = '_'}, [], {'$_'}
            ])};
        cleanup ->
            ets:delete_all_objects(?TABLE_NAME)
    end,
    loop().

set_info(Module, Action, Argument, Runtime, Wallclock) ->
    ?SERVER ! {set_info, {Module, Action, Argument}, Runtime, Wallclock},
    ok.

cleanup() ->
    ?SERVER ! cleanup,
    ok.

get_info() ->
    ?SERVER ! {get_info, self()},
    receive
        {prof, Result} -> Result
    end.

get_info(Module) ->
    ?SERVER ! {get_info, self(), Module},
    receive
        {prof, Result} -> Result
    end.

get_info(Module, Function) ->
    ?SERVER ! {get_info, self(), Module, Function},
    receive
        {prof, Result} -> Result
    end.

get_info(Module, Function, Argument) ->
    ?SERVER ! {get_info, self(), Module, Function, Argument},
    receive
        {prof, Result} -> Result
    end.

profile() ->
    {{YY, MM, DD}, {H, M, S}} = util_time:local_datetime(),
    FileName = lists:concat(["prof-",YY, "_", MM, "_", DD, "-", H, "_", M, "_", S, ".txt"]),
    profile(FileName, total_runtime).

profile(FileName, Mode) ->
    {ok, File} = file:open(FileName, [write, raw]),
    List = get_info(),
    List2 = lists:sort(fun(A, B) ->
        case Mode of
            wallclock ->
                RateA = A#prof_data.wallclock / A#prof_data.times,
                RateB = B#prof_data.wallclock / B#prof_data.times,
                RateA > RateB;
            runtime ->
                RateA = A#prof_data.runtime / A#prof_data.times,
                RateB = B#prof_data.runtime / B#prof_data.times,
                RateA > RateB;
            times ->
                RateA = A#prof_data.times,
                RateB = B#prof_data.times,
                RateA > RateB;
            total_wallclock ->
                RateA = A#prof_data.wallclock,
                RateB = B#prof_data.wallclock,
                RateA > RateB;
            total_runtime ->
                RateA = A#prof_data.runtime,
                RateB = B#prof_data.runtime,
                RateA > RateB
        end
                       end, List),
    file:write(File, io_lib:format("+-------------------------------------------------------+-----------+--------------------+--------------------+--------------------+--------------------+~n", [])),
    file:write(File, io_lib:format("| Module:Function.Argument                              | Times     | Total Runtime      | Total Wallclock    | Runtime            | Wallclock          |~n", [])),
    file:write(File, io_lib:format("+-------------------------------------------------------+-----------+--------------------+--------------------+--------------------+--------------------+~n", [])),
    profile_loop(File, List2).

profile_loop(File, []) ->
    ok = file:close(File);
profile_loop(File, [#prof_data{key = {Module, Function, Argument}, times = Times, runtime = Runtime, wallclock = Wallclock} | List]) ->
    file:write(File, io_lib:format("|~55.s|~11.b|~20.f|~20.f|~20.f|~20.f|~n", [util:to_list(Module) ++ ":" ++ util:to_list(Function) ++ "." ++ util:to_list(Argument), Times, Runtime, Wallclock, Runtime / Times, Wallclock / Times])),
    file:write(File, io_lib:format("+-------------------------------------------------------+-----------+--------------------+--------------------+--------------------+--------------------+~n", [])),
    profile_loop(File, List).
