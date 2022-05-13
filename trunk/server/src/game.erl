%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(game).
-export([start/0, stop/0, restart/0]).

-include("system.hrl").

start() ->
    ok = application:start(game).

stop() ->
%%    stop(false).
%%stop(IsBackupDatabase) ->
%%    case mod_server_config:get_server_type() of
%%        ?SERVER_TYPE_GAME ->
%%            ok = cowboy:stop_listener(game_web_listener),
%%            ok = application:stop(cowboy),
%%            supervisor:terminate_child(game_sup, acceptor_sup),
%%            mod_online:wait_all_online_player_exit(15);
%%        ?SERVER_TYPE_CHARGE ->
%%            ok = cowboy:stop_listener(charge_listener),
%%            ok = application:stop(cowboy);
%%        _ ->
%%            noop
%%    end,
%%    db_sync:sync(300000), %% 5分钟
%%    timer:sleep(3000),
%%    if IsBackupDatabase ->
%%        %% 备份数据库
%%        db_backup:backup();
%%        true ->
%%            noop
%%    end,
    ok = application:stop(game),
    ok = application:unload(game).

restart() ->
    stop(),
    start().

%%shutdown() ->
%%    try
%%        stop()
%%    catch
%%        _:Reason ->
%%            io:format("Shutdown error:~p", [{Reason, erlang:get_stacktrace()}])
%%    end,
%%    io:format("Shutdown finish!~n"),
%%    init:stop(),
%%    ok.
