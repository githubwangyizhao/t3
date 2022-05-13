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

-export([
    withdraw/2,
    withdraw_history/2,
    test_withdraw/0,
    test_withdraw_history/0,
    notice_player/2
]).

test_withdraw() ->
    ?REQUEST_INFO("回收装备信息"),
    PlayerId = 11197,
    ItemId = 1,
    Out =
        case catch mod_withdraw:player_withdraw(PlayerId, ItemId) of
            {'EXIT', function_no_open} ->
                ?ERROR("回收报错: ~p ~p", [function_no_open, PlayerId]),
                proto:encode(#m_shop_withdraw_toc{result = 6, url = ""});
%%            {'EXIT', ErrorAtom} ->
%%                proto:encode(#m_shop_withdraw_toc{result = ErrorAtom});
            {'EXIT', vip_limit} ->
                ?ERROR("回收报错2: ~p ~p", [vip_limit, PlayerId]),
                proto:encode(#m_shop_withdraw_toc{result = 3, url = ""});
            {'EXIT', not_authority} ->
                ?ERROR("回收报错3: ~p ~p", [not_authority, PlayerId]),
                proto:encode(#m_shop_withdraw_toc{result = 4, url = ""});
            {'EXIT', times_limit} ->
                proto:encode(#m_shop_withdraw_toc{result = 5, url = ""});
            {'EXIT', unknown} ->
                proto:encode(#m_shop_withdraw_toc{result = 6, url = ""});
            Url ->
                proto:encode(#m_shop_withdraw_toc{result = 1, url = Url})
        end,
    ?DEBUG("Out: ~p", [Out]).

notice_player(PlayerId, Result) ->
    Msg = proto:encode(#m_shop_withdraw_notify_toc{status = Result}),
    mod_socket:send(PlayerId, Msg).

withdraw(
    #m_shop_withdraw_tos{id = ItemId},
    State = #conn{player_id = PlayerId}
) ->
    ?REQUEST_INFO("回收装备信息"),
    Out =
        case catch mod_withdraw:player_withdraw(PlayerId, ItemId) of
            {'EXIT', function_no_open} ->
                ?ERROR("回收报错1: ~p ~p", [function_no_open, PlayerId]),
                proto:encode(#m_shop_withdraw_toc{result = 6, url = ""});
%%            {'EXIT', ErrorAtom} ->
%%                proto:encode(#m_shop_withdraw_toc{result = ErrorAtom});
            {'EXIT', vip_limit} ->
                ?ERROR("回收报错2: ~p ~p", [vip_limit, PlayerId]),
                proto:encode(#m_shop_withdraw_toc{result = 3, url = ""});
            {'EXIT', not_authority} ->
                ?ERROR("回收报错3: ~p ~p", [not_authority, PlayerId]),
                proto:encode(#m_shop_withdraw_toc{result = 4, url = ""});
            {'EXIT', times_limit} ->
                ?ERROR("回收报错4: ~p ~p", [times_limit, PlayerId]),
                proto:encode(#m_shop_withdraw_toc{result = 5, url = ""});
            {'EXIT', unknown} ->
                ?ERROR("回收报错5: ~p ~p", [unknown, PlayerId]),
                proto:encode(#m_shop_withdraw_toc{result = 6, url = ""});
            {'EXIT', R} ->
                ?DEBUG("R: ~p", [R]),
                proto:encode(#m_shop_withdraw_toc{result = 6, url = ""});
            Url ->
                proto:encode(#m_shop_withdraw_toc{result = 1, url = Url})
        end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(Out),
    State.

test_withdraw_history() ->
    Amount = 3,
    [RealItemId] =
        lists:filtermap(
            fun (E) ->
                ?DEBUG("E: ~p", [E]),
                #t_draw_money{
                    money = MatchMoney,
                    id = ItemId
                } = t_draw_money:get(E),
                if
                    Amount =:= MatchMoney ->
                        {true, ItemId};
                    true ->
                        false
                end
            end,
            t_draw_money:get_keys()
        ),
    RealItemId.

withdraw_history(
    #m_shop_withdraw_history_tos{},
    State = #conn{player_id = PlayerId}
) ->
    SingleWithdrawInfo =
        case mod_server_rpc:call_center(ets, select, [?OAUTH_ORDER_LOG, [{#db_oauth_order_log{player_id = PlayerId, prop_id = ?ITEM_GOLD, _ = '_'}, [], ['$_']}]]) of
            R when is_list(R) ->
                lists:filtermap(
                    fun (Ele) ->
                        if
                            is_record(Ele, db_oauth_order_log) ->
                                #db_oauth_order_log{
                                    amount = Amount,
                                    create_time = CreateTime,
                                    status = Status
                                } = Ele,
                                [RealItemId] =
                                    lists:filtermap(
                                        fun (E) ->
                                            #t_draw_money{
                                                money = MatchMoney,
                                                id = ItemId
                                            } = t_draw_money:get(E),
                                            ?INFO("Amount: ~p, MatchMoney: ~p ~p ~p ~p", [Amount, MatchMoney, Amount =:= MatchMoney, is_float(Amount), is_integer(MatchMoney)]),
                                            Amount2Int = ?IF(is_integer(Amount), Amount, util:to_int(Amount)),
                                            if
                                                Amount2Int =:= MatchMoney ->
                                                    {true, ItemId};
                                                true ->
                                                    false
                                            end
                                        end,
                                        t_draw_money:get_keys()
                                    ),
                                ?INFO("withdraw history: ~p", [#singlewithdrawinfo{id = RealItemId, time = CreateTime, status = Status}]),
                                {true, #singlewithdrawinfo{id = RealItemId, time = util:to_list(CreateTime), status = Status}};
                            true ->
                                false
                        end
                    end,
                    R
                );
            _ -> []
        end,
    ?DEBUG("SingleWithdrawInfo: ~p", [SingleWithdrawInfo]),
    Out = proto:encode(#m_shop_withdraw_history_toc{
        single_withdraw_info = SingleWithdrawInfo
    }),
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(Out),
    State.


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
