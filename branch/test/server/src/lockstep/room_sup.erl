%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 11月 2021 16:03
%%%-------------------------------------------------------------------
-module(room_sup).
-author("yizhao.wang").

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================
start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================
init([]) ->
	{ok, {{simple_one_for_one, 5, 60}, [{room_worker,
		{room_worker, start_link, []},
		temporary,
		2000,
		worker,
		[room_worker]}]
	}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
