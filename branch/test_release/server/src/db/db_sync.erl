%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc         数据库同步进程
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(db_sync).
-include("logger.hrl").
-include("mysql.hrl").
-include("db_config.hrl").
-export([
    save_bin_log/1,     %% 保存日志
    sync/0,             %% 同步磁盘
    sync/1
]).

-export([start_link/0, init/0]).

start_link() ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, []).

init() ->
    process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    erlang:process_flag(min_heap_size, 500),
    erlang:process_flag(min_bin_vheap_size, 100000),
    register(?GAME_DB_SYNC, self()),
    proc_lib:init_ack({ok, self()}),
    clock_sync_bin_log(),
    loop().

%% ----------------------------------
%% @doc 	保存日志
%% @throws 	none
%% @end
%% ----------------------------------
save_bin_log(Action) ->
    ?GAME_DB_SYNC ! {save_bin_log, Action}.

%% ----------------------------------
%% @doc 	同步磁盘
%% @throws 	none
%% @end
%% ----------------------------------
sync() ->
    ?GAME_DB_SYNC ! sync_bin_log.

sync(TimeOut) -> %% 带超时
    Ref = erlang:make_ref(),
    ?GAME_DB_SYNC ! {sync_bin_log, self(), Ref},
    receive
        {ok, Ref} ->
            ok
    after
        TimeOut ->
            timeout
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
        {save_bin_log, Action} ->
            handle_save_bin_log(Action),
            handle_msg(T);
        sync_bin_log ->
            sync_bin_log(true),
            handle_msg(T);
        {sync_bin_log, From, Ref} ->
            sync_bin_log(true),
            From ! {ok, Ref},
            handle_msg(T);
        clock_sync_bin_log ->
            sync_bin_log(false),
            clock_sync_bin_log(),
            handle_msg(T);
        {'EXIT', _, Reason} ->
%%            ?INFO("sync db ~p~n", [Reason]),
            sync_bin_log(true),
            timer:sleep(100),
            exit(Reason);
        Other ->
            ?WARNING("~p unexpected msg:~p", [?MODULE, Other]),
            handle_msg(T)
    end.

drain(Msg) ->
    receive
        Input -> drain([Input | Msg])
    after 0 ->
        Msg
    end.


clock_sync_bin_log() ->
    erlang:send_after(?DB_BIN_LOG_SYNC_TIME, self(), clock_sync_bin_log).

sync_bin_log(IsLog) ->
    if IsLog ->
        ?INFO("同步 db bin log ......");
        true ->
            noop
    end,
    lists:foreach(
        fun(TableName) ->
            do_sync_bin_log(TableName)
        end,
        db:get_incremental_tables()
    ),
    if IsLog ->
        ?INFO("同步 db bin log 成功!");
        true ->
            noop
    end.

do_sync_bin_log(TableName) ->
    BinLogTable = db:get_bin_log_table(TableName),
    ets:foldl(
        fun(Element, _) ->
            case catch db:tran_bin_log(TableName, Element) of
                {'EXIT', Reason} ->
                    ?DB_ERROR("tran_bin_log_error:~p", [{Reason, Element}]);
                noop ->
                    ok;
                Sql ->
                    db_fetch:fetch(Sql)
            end
        end,
        ok,
        BinLogTable
    ),
    ets:delete_all_objects(BinLogTable).

handle_save_bin_log(Action) ->
    try db:save_bin_log(Action) of
        _ ->
            ok
    catch
        _:Reason ->
            ?DB_ERROR("save_bin_log_error:~p", [{Reason, Action}])
    end.
