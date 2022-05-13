-module(web_server).
%% API
-export([start/0]).

start() ->
    {ok, _} = application:ensure_all_started(cowboy),
    ok = application:start(web_server).
