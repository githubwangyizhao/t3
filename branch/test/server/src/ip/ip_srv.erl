%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 12月 2020 下午 03:18:32
%%%-------------------------------------------------------------------
-module(ip_srv).
-author("Administrator").

-include("common.hrl").
-record(state, {}).

%% API
-export([start_link/0, init/1,
  handle_info/2
]).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
  %% 启动定时器 更新black ip list
  ip_srv_mod:before_init_time(),
  {ok, #state{}}.

% 检测初始活动时间
handle_info(update_ip_list_timer, State) ->
  ip_srv_mod:update_ip_list(),
  {noreply, #state{}}.