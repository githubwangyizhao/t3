%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 5月 2021 下午 02:22:10
%%%-------------------------------------------------------------------
-module(chk_google_order_srv).
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
    %% 启动定时器 更新谷歌支付订单状态
    chk_google_order_srv_mod:before_init_timer(),
    {ok, #state{}}.

% 检测初始活动时间
handle_info(update_google_pay_order_timer, State) ->
    chk_google_order_srv_mod:update_google_pay_order(),
    {noreply, #state{}}.