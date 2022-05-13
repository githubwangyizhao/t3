%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 12月 2020 下午 03:18:41
%%%-------------------------------------------------------------------
-module(ip_sup).
-author("Administrator").

%% API
-export([
  start_link/0,
  init/1
]).

start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  {
    ok,
    {
      {one_for_one, 10, 10},
      [
        {ip_srv, {ip_srv, start_link, []}, transient, brutal_kill, worker, [activity_srv]}

      ]

    }
  }.
