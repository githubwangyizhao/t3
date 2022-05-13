%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 19. 六月 2018 10:56
%%%-------------------------------------------------------------------
-module(mod_game_charge).
-author("home").

%% API
-export([
    gm_charge/7
]).

-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").


%% @doc     gm充值
gm_charge(PlayerId, ChargeType, _GameChargeId0, ChargeItemId, ItemCount, Ip, GmId) ->
    {GameChargeId, Money, ChargeIngot} =
        if
            ChargeItemId > 0 ->
                #t_recharge{
                    recharge_type = GameChargeId1,
                    cash = SingleMoney,
                    ingot = SingleValue
                } = mod_charge:try_get_t_recharge(ChargeItemId),
                {GameChargeId1, SingleMoney, SingleValue};
            true ->
                {0, ItemCount / ?INGOT_RATE_MONEY, ItemCount}
        end,
    OrderId = lists:flatten(io_lib:format("~2..0w~13..0w~13..0w", [ChargeType, PlayerId, util_time:milli_timestamp()])),
    ?INFO("后台gm充值：~p~n", [{PlayerId, ChargeType, _GameChargeId0, ChargeItemId, ItemCount, Ip, GmId}]),
    mod_charge:common_game_charge(PlayerId, GameChargeId, ChargeItemId, ChargeType, util:to_float(Money), ChargeIngot, OrderId, Ip, GmId).


