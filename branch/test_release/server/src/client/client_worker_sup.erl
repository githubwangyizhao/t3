%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(client_worker_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([
    kill_all_client_worker/1,
    kill_all_client_worker/0
]).

-export([init/1]).

-export([start_child/2, count_child/0]).
-define(SERVER, ?MODULE).
-include("common.hrl").
-include("system.hrl").
-include("socket.hrl").

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
%%    process_flag(trap_exit, true),
    SupFlags = {simple_one_for_one, 10, 10},
    Child = {client_worker, {client_worker, start_link, []},
        temporary, 30000, worker, [client_worker]},
    {ok, {SupFlags, [Child]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
start_child(SockMod, Socket) ->
    MaxCount = ?MAX_CLIENT_COUNT,
    case count_child() of
        MaxCount ->
            {error, max_conn};
        _ ->
            supervisor:start_child(?SERVER, [SockMod, Socket])
    end.


count_child() ->
    [{specs, _}, {active, _}, {supervisors, _}, {workers, Num}] = supervisor:count_children(?SERVER),
    Num.
%%kill_client_worker(Child)->
%%    kill_client_worker(Child, 0).
kill_client_worker(Child, Reason) when is_pid(Child) ->
    client_worker:kill_async(Child, Reason).

kill_all_client_worker() ->
    kill_all_client_worker(?CSR_SYSTEM_MAINTENANCE).
kill_all_client_worker(Reason) ->
    ChildInfoList = supervisor:which_children(?SERVER),
    [kill_client_worker(Child, Reason) || {_Id, Child, _Type, _Modules} <- ChildInfoList],
    ok.
