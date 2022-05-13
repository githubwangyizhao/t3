%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 5月 2021 下午 02:31:10
%%%-------------------------------------------------------------------
-module(chk_google_order_sup).
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
                {chk_google_order_srv, {chk_google_order_srv, start_link, []}, transient, brutal_kill, worker, [activity_srv]}

            ]

        }
    }.
