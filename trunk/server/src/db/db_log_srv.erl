%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(db_log_srv).

-include("logger.hrl").
-include("db_config.hrl").
%%-include("logger_cfg.hrl").
%% API
-export([write_log/2]).
-export([start_link/0, init/0]).

start_link() ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, []).

init() ->
    process_flag(trap_exit, true),
    {{Year, Month, Day}, _} = erlang:localtime(),
    {ok, File} = open_log_file({Year, Month, Day}),
    register(?MODULE, self()),
    proc_lib:init_ack({ok, self()}),
    loop(File, {Year, Month, Day}).

write_log(Format, Args) ->
    ?DB_LOG_SRV ! {write, io_lib:format(Format, Args)}.

loop(File, Date) ->
    receive
        {write, Data} ->
            {{YY, MM, DD}, {H, M, S}} = erlang:localtime(),
            Out = io_lib:format("~s:~s:~s ~s~n", [
                format_integer(H),
                format_integer(M),
                format_integer(S),
                Data
            ]),
            if
                {YY, MM, DD} > Date ->
                    file:close(File),
                    {ok, NewFile} = open_log_file({YY, MM, DD}),
                    do_write_log(NewFile, Out),
                    loop(NewFile, {YY, MM, DD});
                true ->
                    do_write_log(File, Out),
                    loop(File, Date)
            end;
        {'EXIT', _, Reason} ->
            file:close(File),
            exit(Reason);
        Other ->
            file:close(File),
            io:format("~p unexpected msg:~p", [?MODULE, Other])
    end.

do_write_log(File, Data) ->
    file:write(File, Data).


open_log_file({YY, MM, DD}) ->
    FileName = filename:join([?LOG_DIR, lists:concat([YY, "_", MM, "_", DD]), "db.log"]),
    case filelib:is_regular(FileName) of
        true -> true;
        false -> ok = filelib:ensure_dir(FileName), false
    end,
    {ok, File} = file:open(FileName, [append, raw, {delayed_write, 1024 * 100, 2000}]),
    {ok, File}.

format_integer(N) ->
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
