%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 10ζ 2021 δΈε 04:01:01
%%%-------------------------------------------------------------------
-module(check_config).
-author("Administrator").

%% API
-export([
    start/0
]).

start() ->
    logic_code:check_scene_config_pos().