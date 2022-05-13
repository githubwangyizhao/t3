%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 12月 2020 下午 03:37:28
%%%-------------------------------------------------------------------
-module(ip_srv_mod).
-author("Administrator").

-include("common.hrl").

%% API
-export([
  before_init_time/0,
  update_ip_list/0
]).

%% @fun 初始数据前记录数据
before_init_time() ->
  CheckTime = util_time:get_next_tidy_minute_timestamp(?UPDATE_BLACK_IP_LIST_INTERVAL) - util_time:timestamp(),
  CheckRef = erlang:send_after(CheckTime * ?SECOND_MS, self(), ?UPDATE_BLACK_IP_LIST_TIMER),
  util:update_timer_value(?UPDATE_BLACK_IP_LIST_TIMER, CheckRef),
  SubPid = spawn(fun () -> ?DEBUG("spawn gen_ip_list_txt"), mod_ip:gen_ip_list_txt() end),
  ?DEBUG("开始更新ip列表<pid: ~p>", [SubPid]).

%% @fun 检查初始活动列表
update_ip_list() ->
  CheckTime = util_time:get_next_tidy_minute_timestamp(?UPDATE_BLACK_IP_LIST_INTERVAL) - util_time:timestamp(),
  CheckRef = erlang:send_after(CheckTime * ?SECOND_MS, self(), ?UPDATE_BLACK_IP_LIST_TIMER),
  util:update_timer_value(?UPDATE_BLACK_IP_LIST_TIMER, CheckRef),
%%  mod_ip:gen_ip_list_txt(),
  SubPid = spawn(fun () -> ?DEBUG("spawn update_ip_list_txt"), mod_ip:gen_ip_list_txt() end),
  ?DEBUG("更新ip列表<pid: ~p>", [SubPid]).
