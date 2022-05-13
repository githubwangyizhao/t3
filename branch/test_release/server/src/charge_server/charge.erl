-module (charge).

-export ([
	start/0,
	stop/0
%%	restart/0
	]).

start() ->
%%    {ok, _} = application:ensure_all_started(cowboy),
    application:start(game).


stop() ->
    stop(false).
stop(IsBackupDatabase) ->
    db_sync:sync(300000), %% 5分钟
    timer:sleep(3000),
    if IsBackupDatabase ->
        %% 备份数据库
        db_backup:backup();
        true ->
            noop
    end,
    ok = application:stop(game),
    ok = application:unload(game).
%%	ok = cowboy:stop_listener(charge_listener),
%%    ok = application:stop(cowboy),
%%	db_sync:sync(300000), %% 5分钟
%%    timer:sleep(3000),
%%    ok = application:stop(charge).
%%
%%
%%restart() ->
%%	stop(),
%%	start().

