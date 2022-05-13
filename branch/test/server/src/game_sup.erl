%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(game_sup).
-behaviour(supervisor).

%% API
-export([
    start_link/0,
    stop_child/1,
    restart_child/1
]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    {ok, {{one_for_one, 10, 10}, []}}.

stop_child(Child) ->
    supervisor:terminate_child(game_sup, Child).

restart_child(Child) ->
    stop_child(Child),
    supervisor:restart_child(game_sup, Child).
