%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(logger2).

-include("logger.hrl").
%%-include("logger_cfg.hrl").
%% API
-export([write/2, write/3]).
-export([start_link/0, init/0]).

start_link() ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, []).

init() ->
    register(?MODULE, self()),
    proc_lib:init_ack({ok, self()}),
    loop().

write(LogName, Data) ->
    ?MODULE ! {write, LogName, Data, false}.

%% 玩家日志， 分时
write(PlayerId, LogName, Data) ->
    case is_integer(PlayerId) of
        true ->
            ?MODULE ! {write, LogName, Data, true};
        false ->
            noop
    end.


loop() ->
    handle_msg(lists:reverse(drain([]))).
handle_msg([]) ->
    handle_msg(
        receive
            Msg ->
                lists:reverse(drain([Msg]))
        end
    );
handle_msg([Msg | T]) ->
    case Msg of
        {write, LogName, Data, IsDivisionHour} ->
            {{YY, MM, DD}, {H, M, S}} = erlang:localtime(),
            File = get_log_file({YY, MM, DD, H}, LogName, IsDivisionHour),
            Out = io_lib:format("~s:~s:~s ~100000p~n", [
                format_integer(H),
                format_integer(M),
                format_integer(S),
                Data
            ]),
            do_write_log(File, Out),
            handle_msg(T);
        {'EXIT', _, Reason} ->
            exit(Reason);
        Other ->
            io:format("~p unexpected msg:~p", [?MODULE, Other]),
            handle_msg(T)
    end.
drain(Msg) ->
    receive
        Input -> drain([Input | Msg])
    after 0 ->
        Msg
    end.
%%loop() ->
%%    receive
%%        {write, LogName, Data} ->
%%            {{YY, MM, DD}, {H, M, S}} = erlang:localtime(),
%%            File = get_log_file({YY, MM, DD}, LogName),
%%            Out = io_lib:format("~s:~s:~s ~w~n", [
%%                format_integer(H),
%%                format_integer(M),
%%                format_integer(S),
%%                Data
%%            ]),
%%            do_write_log(File, Out),
%%            loop();
%%        Other ->
%%            ?ERROR("~p unexpected msg:~p", [?MODULE, Other]),
%%            loop()
%%    end.

do_write_log(File, Data) ->
    file:write(File, Data).

get_log_file({YY, MM, DD, H}, LogName, IsDivisionHour) ->
    case get(LogName) of
        undefined ->
            {ok, File} = open_log_file({YY, MM, DD, H}, LogName, IsDivisionHour),
            put(LogName, {File, {YY, MM, DD, H}}),
            File;
        {File, {F_YY, F_MM, F_DD, F_H}} ->
            IsChangeFile =
                if IsDivisionHour ->
                    {YY, MM, DD, H} =/= {F_YY, F_MM, F_DD, F_H};
                    true ->
                        {YY, MM, DD} =/= {F_YY, F_MM, F_DD}
                end,
            if
                IsChangeFile ->
                    file:close(File),
                    {ok, NewFile} = open_log_file({YY, MM, DD, H}, LogName, IsDivisionHour),
                    put(LogName, {NewFile, {YY, MM, DD, H}}),
                    NewFile;
                true ->
                    File
            end
    end.

open_log_file({YY, MM, DD, H}, LogName, IsDivisionHour) ->
    FileName =
        if IsDivisionHour ->
            filename:join([?LOG_DIR, lists:concat([YY, "_", MM, "_", DD]), util:to_list(H), util:to_list(LogName) ++ ".log"]);
            true ->
                filename:join([?LOG_DIR, lists:concat([YY, "_", MM, "_", DD]), util:to_list(LogName) ++ ".log"])
        end,

    case filelib:is_regular(FileName) of
        true -> noop;
        false -> ok = filelib:ensure_dir(FileName)
    end,
    file:open(FileName, [append, raw, {delayed_write, 1024 * 100, 700}]).

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

