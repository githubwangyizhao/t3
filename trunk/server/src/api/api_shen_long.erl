%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 五月 2021 下午 03:52:51
%%%-------------------------------------------------------------------
-module(api_shen_long).
-author("Administrator").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").

%% API
-export([
    draw/2,                                 %% 抽奖

    notice_scene_shen_long_state/6          %% 通知场景神龙状态
]).

%% @doc 抽奖
draw(
    #m_shen_long_draw_tos{},
    #conn{player_id = PlayerId}
) ->
    {PbResult, PbType, PbId} =
        case catch mod_shen_long:draw(PlayerId) of
            {ok, Type, Id} ->
                {?P_SUCCESS, Type, Id};
            {'EXIT', Error} ->
%%                ?DEBUG("神龙Error ： ~p" ,[Error]),
                {api_common:api_error_to_enum(Error), 0, 0}
        end,
    Out = proto:encode(#m_shen_long_draw_toc{
        result = PbResult,
        type = PbType,
        id = PbId
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知场景神龙状态
notice_scene_shen_long_state(PlayerIdList, State, Type, CloseTime, PlayerName, PlayerId) ->
    Out = proto:encode(#m_shen_long_notice_scene_shen_long_state_toc{state = State, type = Type, close_time = CloseTime, player_name = PlayerName, player_id = PlayerId}),
    mod_socket:send_to_player_list(PlayerIdList, Out).
