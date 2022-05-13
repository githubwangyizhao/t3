%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             空 进程
%%% @end
%%% Created : 27. 六月 2016 上午 11:48
%%%-------------------------------------------------------------------
-module(null_worker).
%% API
-export([
    start_link/0
]).
-export([init/0]).
start_link() ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, []).
init() ->
    proc_lib:init_ack({ok, self()}),
    register(?MODULE, self()),
    loop().

loop() ->
    receive
        _ ->
            noop
    end,
    loop().
