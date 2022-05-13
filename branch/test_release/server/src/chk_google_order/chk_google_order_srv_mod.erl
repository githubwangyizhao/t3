%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 5月 2021 下午 02:23:51
%%%-------------------------------------------------------------------
-module(chk_google_order_srv_mod).
-author("Administrator").

%% API
-export([
    before_init_timer/0,
    update_google_pay_order/0
]).
-include("common.hrl").

%% @fun 初始数据前记录数据
before_init_timer() ->
    CheckTime = util_time:get_next_tidy_minute_timestamp(?UPDATE_GOOGLE_PAY_ORDER_INTERVAL) - util_time:timestamp(),
    CheckRef = erlang:send_after(CheckTime * ?SECOND_MS, self(), ?UPDATE_GOOGLE_PAY_ORDER_INTERVAL),
    util:update_timer_value(?UPDATE_GOOGLE_PAY_ORDER_TIMER, CheckRef),
    SubPid = spawn(fun () -> ?DEBUG("spawn check google pay order"), mod_google_pay:chk_google_order_specified_date() end),
    ?DEBUG("开始检测谷歌订单是否退款<pid: ~p>", [SubPid]).

%% @fun 检查初始活动列表
update_google_pay_order() ->
    CheckTime = util_time:get_next_tidy_minute_timestamp(?UPDATE_GOOGLE_PAY_ORDER_INTERVAL) - util_time:timestamp(),
    CheckRef = erlang:send_after(CheckTime * ?SECOND_MS, self(), ?UPDATE_GOOGLE_PAY_ORDER_INTERVAL),
    util:update_timer_value(?UPDATE_GOOGLE_PAY_ORDER_TIMER, CheckRef),
%%  mod_ip:gen_ip_list_txt(),
    SubPid = spawn(fun () -> ?DEBUG("spawn check google pay order"), mod_google_pay:chk_google_order_specified_date() end),
    ?DEBUG("开始检测谷歌订单是否退款<pid: ~p>", [SubPid]).
