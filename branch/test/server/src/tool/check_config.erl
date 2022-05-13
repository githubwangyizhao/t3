%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 10月 2021 下午 04:01:01
%%%-------------------------------------------------------------------
-module(check_config).
-author("Administrator").

%% API
-export([
    start/0
]).

start() ->
    logic_code:check_scene_config_pos().