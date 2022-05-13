%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         %% 转盘抽奖
%%% @end
%%% Created : 08. 三月 2021 下午 02:50:25
%%%-------------------------------------------------------------------
-module(api_turn_table).
-author("Administrator").

-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").

%% API
-export([
    draw/2,             %% 抽奖
    get_award/2,        %% 获得进度值奖励

    notice_reset/1      %% 通知重置
]).

%% @doc 抽奖
draw(
    #m_turn_table_draw_tos{times = Times},
    State = #conn{player_id = PlayerId}
) ->
    {Result, IdList, Value} =
        case catch mod_turn_table:draw(PlayerId, Times) of
            {ok, IdList1, Value1} ->
                {?P_SUCCESS, IdList1, Value1};
            R ->
                R1 = api_common:api_result_to_enum(R),
                {R1, [], 0}
        end,
    Out = proto:encode(#m_turn_table_draw_toc{result = Result, times = Times, id_list = IdList, value = Value}),
    mod_socket:send(Out),
    State.

%% @doc 抽奖
get_award(
    #m_turn_table_get_award_tos{},
    State = #conn{player_id = PlayerId}
) ->
    {Result, PropList} =
        case catch mod_turn_table:get_award(PlayerId) of
            {ok, PropList1} ->
                {?P_SUCCESS, PropList1};
            R ->
                R1 = api_common:api_result_to_enum(R),
                {R1, []}
        end,
    Out = proto:encode(#m_turn_table_get_award_toc{result = Result, prop_list = api_prop:pack_prop_list(PropList)}),
    mod_socket:send(Out),
    State.

%% @doc 通知重置
notice_reset(PlayerId) ->
    Out = proto:encode(#m_turn_table_notice_reset_toc{}),
    mod_socket:send(PlayerId, Out).