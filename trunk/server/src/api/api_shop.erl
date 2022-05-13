%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 10. 二月 2018 9:49
%%%-------------------------------------------------------------------
-module(api_shop).
-author("home").

-include("error.hrl").
-include("common.hrl").
-include("p_message.hrl").
-include("gen/db.hrl").
-include("p_enum.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").

%% API
-export([
    get_shop_info/2,                %%获得商店信息
    shop_item/2,                    %%购买物品
    notice_shop_state/3             %% 通知商品id状态
]).

-export([
    pack_shop_data/1
]).

%%获得商店信息
get_shop_info(
    #m_shop_get_shop_info_tos{shop_type = ShopType},
    State = #conn{player_id = PlayerId}
) ->
    ?REQUEST_INFO("获得商店信息"),
    List = mod_shop:get_shop_info(PlayerId, ShopType),
    Out = proto:encode(#m_shop_get_shop_info_toc{shop_data = pack_shop_data(List), shop_type = ShopType}),
    mod_socket:send(Out),
    State.

%%购买物品
shop_item(
    #m_shop_shop_item_tos{id = Id, buy_count = BuyCount},
    State = #conn{player_id = PlayerId}
) ->
    ?REQUEST_INFO("购买物品"),
    Result = api_common:api_result_to_enum(catch mod_shop:buy_item(PlayerId, Id, BuyCount)),
    Out = proto:encode(#m_shop_shop_item_toc{result = Result, id = Id, buy_count = BuyCount}),
    mod_socket:send(Out),
    State.

%% @doc     通知商品id状态
notice_shop_state(PlayerId, Id, State) ->
    Out = proto:encode(#m_shop_notice_shop_state_toc{id = Id, state = State}),
    mod_socket:send(PlayerId, Out).

%% @fun 打包商店数据
pack_shop_data(List) ->
    lists:foldl(
        fun(Tuple, L) ->
            {Id, BuyCount, State} =
                case Tuple of
                    {Id1, BuyCount1} ->
                        {Id1, BuyCount1, 0};
                    _ ->
                        Tuple
                end,
            [#shopdata{id = Id, buy_count = BuyCount, state = State} | L]
        end, [], List).
