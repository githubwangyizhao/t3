%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc    本地平台
%%% Created : 10. 八月 2018 10:39
%%%-------------------------------------------------------------------
-module(local).
-author("home").

%% API
-export([
    buy_playzone_item/7
]).

-include("error.hrl").
-include("client.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").

%% @fun 本地充值
buy_playzone_item(PlayerId, ChargeType, Id, GameChargeId, Money, ChargeIngot, PlatformId) ->
    Ip = "127.0.0.1",
    OrderId = lists:flatten(io_lib:format("~2..0w~13..0w~13..0w~s", [ChargeType, PlayerId, util_time:milli_timestamp(), PlatformId])),
    MoneyFloat = util:to_float(Money),
    mod_charge:common_game_charge(PlayerId, GameChargeId, Id, ChargeType, MoneyFloat, ChargeIngot, OrderId, Ip, ""),
    ok.