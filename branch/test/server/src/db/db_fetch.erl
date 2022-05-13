%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc         数据库执行进程
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(db_fetch).
-include("logger.hrl").
-include("mysql.hrl").
-include("db_config.hrl").
-export([
    fetch/1,             %% 执行sql
    fetch/2

]).

-export([start_link/1, init/1]).

start_link(Name) ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, [Name]).

init(Name) ->
    register(Name, self()),
    process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
    proc_lib:init_ack({ok, self()}),
    loop().

%% ----------------------------------
%% @doc 	执行sql
%% @throws 	none
%% @end
%% ----------------------------------
fetch(ignore) ->
    ignore;
fetch(Sql) ->
    do_fetch(Sql).

fetch(_Pid, ignore) ->
    ignore;
fetch(Pid, Sql) ->
%%    ?DEBUG("Pid:~p", [Pid]),
    Pid ! {fetch, Sql}.


%% ----------------------------------
%% @doc 	主循环
%% @throws 	none
%% @end
%% ----------------------------------
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
        {fetch, Sql} ->
            do_fetch(Sql),
            handle_msg(T);
        {'EXIT', _, Reason} ->
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

do_fetch(Sql) ->
    case catch mysql:fetch(?GAME_DB, Sql, 10000) of
        {'EXIT', Reason} ->
            ?DB_ERROR("reason:~p, sql:~s", [Reason, binary_to_list(Sql)]);
        {data, _Res} -> noop;
%%            ?DB_LOG("~s", [binary_to_list(Sql)]);
        {updated, _Res} -> noop;
%%            ?DB_LOG("~s", [binary_to_list(Sql)]);
        {error, Res} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Res, {Sql, erlang:get_stacktrace()}])
    end.
