%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         卡牌图鉴系统
%%% @end
%%% Created : 07. 五月 2021 下午 05:25:42
%%%-------------------------------------------------------------------
-module(api_card).
-author("Administrator").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").

%% API
-export([
    api_get_card_book_list/1,           %% API 获得卡牌图鉴列表

    get_award/2,                        %% 获得奖励

    notice_card_update/3,               %% 通知 卡牌更新

    pack_pb_card_book/3,                %% 结构化 卡牌图鉴
    pack_pb_card_title/3,               %% 结构化 卡牌标题
    pack_pb_card/3                      %% 结构化 卡牌
]).

%% @doc API 获得卡牌图鉴列表
api_get_card_book_list(PlayerId) ->
    mod_card:get_player_card_book_list(PlayerId).

%% @doc 获得奖励
get_award(
    #m_card_get_award_tos{type = Type, id = Id},
    State = #conn{player_id = PlayerId}
) ->
    {Result, PropList} =
        case catch mod_card:get_award(PlayerId, Type, Id) of
            {ok, PropList1} ->
                {?P_SUCCESS, api_prop:pack_prop_list(PropList1)};
            {'EXIT', ERROR} ->
                {api_common:api_result_to_enum(ERROR), []}
        end,
    Out = proto:encode(#m_card_get_award_toc{
        result = Result,
        type = Type,
        id = Id,
        prop_list = PropList
    }),
    mod_socket:send(Out),
    State.

%% @doc 通知 卡牌更新
notice_card_update(PlayerId, CardId, Num) ->
    Out = proto:encode(#m_card_notice_card_update_toc{
        card_id = CardId,
        num = Num
    }),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

%% @doc 结构化 卡牌图鉴
pack_pb_card_book(CardBookId, State, PbCardTitleList) ->
    #cardbook{
        card_book_id = CardBookId,
        state = State,
        card_title_list = PbCardTitleList
    }.

%% @doc 结构化 卡牌标题
pack_pb_card_title(CardTitleId, State, PbCardList) ->
    #cardtitle{
        card_title_id = CardTitleId,
        state = State,
        card_list = PbCardList
    }.

%% @doc 结构化 卡牌
pack_pb_card(CardId, State, Num) ->
    #card{
        card_id = CardId,
        state = State,
        num = Num
    }.
