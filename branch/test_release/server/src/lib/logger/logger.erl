%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            日志服务
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(logger).
-include("logger.hrl").

-ifdef(debug).
-define(IS_DEBUG, true).
-else.
-define(IS_DEBUG, false).
-endif.

%% API
-export([
    warning/2,
    warning/1,
    debug/2,
    debug/1,
    info/2,
    info/1,
    error/2,
    error/1,
    fatal_error/1,
    fatal_error/2,
    echo_player_id/0,
    do_write/3,
    open_log_file/1
]).
-export([start_link/0, init/0]).

-export([
    handle_clean_expire_log/0
]).
start_link() ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, []).

init() ->
    register(?MODULE, self()),
    process_flag(trap_exit, true),
    clock_clean_expire_log(),
    logger_loop:loop().


clock_clean_expire_log() ->
    Now = util_time:timestamp(),
    Today3Hour = util_time:get_today_timestamp({3, 0, 0}),
    T =
        if Now >= Today3Hour ->
            Today3Hour + 86400 - Now;
            true ->
                Today3Hour - Now
        end,
    erlang:send_after(T * 1000, self(), clean_expire_log).

handle_clean_expire_log() ->
    clock_clean_expire_log(),
    try
        logger_clean:clean_expire_log()
    catch
        _:Reason ->
            ?ERROR("clean_expire_log:~p", [{Reason, erlang:get_stacktrace()}])
    end.



debug(Format, Args) ->
    case ?LOG_LEVEL_DEBUG >= ?LOG_LEVEL of
        true ->
            write_format("[DEBUG]# " ++ Format ++ "~n", Args);
        false ->
            noop
    end.
debug(String) ->
    case ?LOG_LEVEL_DEBUG >= ?LOG_LEVEL of
        true ->
            write_format("[DEBUG]# " ++ "~ts~n", [String]);
        false ->
            noop
    end.

info(Format, Args) ->
    case ?LOG_LEVEL_INFO >= ?LOG_LEVEL of
        true ->
            write_format("[INFO]# " ++ Format ++ "~n", Args);
        false ->
            noop
    end.
info(String) ->
    case ?LOG_LEVEL_INFO >= ?LOG_LEVEL of
        true ->
            write_format("[INFO]# " ++ "~ts~n", [String]);
        false ->
            noop
    end.

warning(Format, Args) ->
    case ?LOG_LEVEL_WARNING >= ?LOG_LEVEL of
        true ->
            write_format("[WARNING]# " ++ Format ++ "~n", Args);
        false ->
            noop
    end.
warning(String) ->
    case ?LOG_LEVEL_WARNING >= ?LOG_LEVEL of
        true ->
            write_format("[WARNING]# " ++ "~ts~n", [String]);
        false ->
            noop
    end.

error(Format, Args) ->
    case ?LOG_LEVEL_ERROR >= ?LOG_LEVEL of
        true ->
            write_format("[ERROR]# " ++ Format ++ "~n", Args);
        false ->
            noop
    end.
error(String) ->
    case ?LOG_LEVEL_ERROR >= ?LOG_LEVEL of
        true ->
            write_format("[ERROR]# " ++ "~ts~n", [String]);
        false ->
            noop
    end.

fatal_error(Format, Args) ->
    case ?LOG_LEVEL_FETAL_ERROR >= ?LOG_LEVEL of
        true ->
            write_format("[FETAL_ERROR]# " ++ Format ++ "~n", Args);
        false ->
            noop
    end.
fatal_error(String) ->
    case ?LOG_LEVEL_FETAL_ERROR >= ?LOG_LEVEL of
        true ->
            write_format("[FETAL_ERROR]# " ++ "~ts~n", [String]);
        false ->
            noop
    end.

echo_player_id() ->
    case client_worker:get_player_id() of
        undefined -> "";
        PlayerId -> "(" ++ erlang:integer_to_list(PlayerId) ++ ") "
    end.

write_format(Format, Args) ->
    Data = io_lib:format(Format, Args),
    case ?IS_DEBUG of
        true ->
        io:format(Data);
        _ ->
            noop
    end,
    submit(Data),
    ok.

submit(Data) when is_list(Data) ->
    ?MODULE ! {write, util_string:string_to_list(Data)}.%%


do_write(File, Data, {{_YY, _MM, _DD}, {H, M, S}}) ->
    Prefix = lists:concat([H, ":", M, ":", S, " "]),
    Text = io_lib:format("~s~s", [Prefix, Data]),
    file:write(File, Text).

open_log_file({YY, MM, DD}) ->
    FileName = filename:join([?LOG_DIR, lists:concat([YY, "_", MM, "_", DD]), ?LOG_FILE_NAME]),
    case filelib:is_file(FileName) of
        true -> ok;
        false -> ok = filelib:ensure_dir(FileName)
    end,
    file:open(FileName, [append, raw, {delayed_write, 1024 * 100, 800}]). %% 字节bytes 毫秒milliseconds
