%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(db_sup).
-behaviour(supervisor).
-include("db_config.hrl").
-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
    GameDbFetchSpecList =
        [
            {
                db_fetch,
                {db_fetch, start_link, [db_fetch]},
                permanent,
                infinity,
                worker,
                [db_fetch]
            } |
            lists:foldl(
                fun(Id, L) ->
                    Name = list_to_atom(lists:concat(["db_fetch_", Id])),
                    T = {Name,
                        {db_fetch, start_link, [Name]},
                        permanent,
                        infinity,
                        worker,
                        [db_fetch]},
                    [T | L]
                end,
                [],
                lists:seq(0, ?DB_WORKER_NUM - 1)
            )],
    {ok, {{one_for_one, 10, 10}, GameDbFetchSpecList ++ [
        {db_load_proxy, {db_load_proxy, start_link, []}, permanent, infinity, worker, [db_load_proxy]},
        {db_log_srv, {db_log_srv, start_link, []}, permanent, infinity, worker, [db_log_srv]},
        {db_sync, {db_sync, start_link, []}, permanent, infinity, worker, [db_sync]}
    ]}}.
