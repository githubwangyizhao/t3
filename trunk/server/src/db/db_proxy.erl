%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc         数据库代理进程
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(db_proxy).
-include("logger.hrl").
-include("mysql.hrl").
-include("db_config.hrl").
%%-include("dict.hrl").
-export([
    submit/1,           %% 提交事务
    fetch/1             %% 执行sql
]).

-export([
    init/1
]).
%% ----------------------------------
%% @doc 	提交事务
%% @throws 	none
%% @end
%% ----------------------------------
submit([]) ->
    ok;
submit([Action | T]) ->
    Table = erlang:element(2, Action),
    case db:is_incremental_sync(Table) of
        false ->
            fetch(db:tran_to_sql(Action));
        true ->
            db_sync:save_bin_log(Action)
    end,
    submit(T).

%% ----------------------------------
%% @doc 	执行sql
%% @throws 	none
%% @end
%% ----------------------------------
fetch(ignore) ->
    ignore;
fetch(Sql) ->
    case get(dict_db_fetch_worker) of
        undefined ->
%%            Id = util:random_number(0, ?GAME_DB_WORKER_NUM - 1),
%%            Worker = list_to_atom("game_db_fetch_" ++ integer_to_list(Id)),
            db_fetch:fetch(db_fetch, Sql);
        Worker ->
            db_fetch:fetch(Worker, Sql)
    end.

%% ----------------------------------
%% @doc 	分配数据库进程
%% @throws 	none
%% @end
%% ----------------------------------
init(PlayerId) ->
    Id = PlayerId rem ?DB_WORKER_NUM,
    Worker = list_to_atom("db_fetch_" ++ integer_to_list(Id)),
    put(dict_db_fetch_worker, Worker).

