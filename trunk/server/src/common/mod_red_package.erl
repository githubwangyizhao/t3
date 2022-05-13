%%%%%-------------------------------------------------------------------
%%%%% @author
%%%%% @copyright (C) 2016, THYZ
%%%%% @doc        红包
%%%%% @end
%%%%% Created : 27. 五月 2016 下午 3:39
%%%%%-------------------------------------------------------------------
-module(mod_red_package).
%%
%%%% API
%%-export([
%%    init/1,                 %% 初始化红包
%%    start_balance_timer/1,  %% 启动红包结算定时器
%%    get_balance_time/1     %% 获取红包结算时间
%%%%    handle_balance/1        %% 结算红包
%%]).
%%-include("gen/table_enum.hrl").
%%-include("player_game_data.hrl").
%%-include("common.hrl").
%%-include("client.hrl").
%%init(PlayerId) ->
%%    Now = util_time:timestamp(),
%%    PlatformId = mod_server_config:get_platform_id(),
%%    if PlatformId == ?PLATFORM_WX orelse PlatformId == ?PLATFORM_LOCAL->
%%        T1 = Now + 7 * ?DAY_S,
%%        T2 = util_time:get_today_zero_timestamp(T1),
%%        T3 = T2 + ?DAY_S - 1,
%%        mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_REG_PACKAGE_BALANCE_TIME, T3);
%%        true ->
%%            noop
%%    end.
%%
%%
%%start_balance_timer(PlayerId) ->
%%    BalanceTime = get_balance_time(PlayerId),
%%    if BalanceTime > 0 ->
%%        ?DEBUG("启动红包定时器"),
%%        Now = util_time:timestamp(),
%%        util_timer:start_timer(?CLIENT_WORKER_TIMER_BALANCE_REG_PACKAGE, max(0, BalanceTime - Now) * 1000);
%%        true ->
%%            noop
%%    end.
%%
%%
%%get_balance_time(PlayerId) ->
%%    mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_REG_PACKAGE_BALANCE_TIME).
%%
%%
%%%%handle_balance(PlayerId) ->
%%%%    JinBi = mod_prop:get_player_prop_num(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_JINBI),
%%%%    ?INFO("结算红包:~p", [JinBi]),
%%%%    Ingot = JinBi,
%%%%    Tran = fun() ->
%%%%        mod_prop:decrease_player_prop(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_JINBI, JinBi, ?LOG_TYPE_RED_PACKAGE),
%%%%        if
%%%%            Ingot > 0 ->
%%%%                mod_mail:add_mail_param_item_list(PlayerId, ?MAIL_RED_PACKAGE, [[?PROP_TYPE_RESOURCES, ?RES_INGOT, Ingot]], [Ingot], ?LOG_TYPE_RED_PACKAGE);
%%%%            true ->
%%%%                noop
%%%%        end,
%%%%        mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_REG_PACKAGE_BALANCE_TIME, 0)
%%%%           end,
%%%%    db:do(Tran).
%%
