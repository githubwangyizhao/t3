%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 26. 九月 2018 11:28
%%%-------------------------------------------------------------------
-module(api_red_packet).
-author("home").

%% API
-export([
    get_red_packet/2,   %% 领取红包
    notice_player_red_packet/2, %%
    notice_player_red_packet_clear/2    %%
]).

-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").

%% 领取红包
get_red_packet(#m_red_packet_get_red_packet_tos{r_id = RId},
    State = #conn{player_id = PlayerId}) ->
    ?REQUEST_INFO("领取红包"),
    {Result, AwardList} =
        case catch mod_red_packet:get_red_packet(PlayerId, RId) of
            {ok, AwardL} ->
                {?P_SUCCESS, AwardL};
            R ->
                R1 = api_common:api_result_to_enum(R),
                {R1, []}
        end,
    ?DEBUG("领取红包_toc:~p~n", [{Result, RId, AwardList}]),
    Out = proto:encode(#m_red_packet_get_red_packet_toc{result = Result, r_id = RId, prop_list = api_prop:pack_prop_list(AwardList)}),
    mod_socket:send(Out),
    State.

%% 通知发放红包
notice_player_red_packet(PlayerIdList, RedPacketConditionData) ->
%%    ?DEBUG("通知发放红包：~p~n", [{PlayerIdList, RedPacketConditionData}]),
    Out = proto:encode(#m_red_packet_notice_player_red_packet_toc{red_packet = pack_red_packet_condition_data(RedPacketConditionData)}),
    notice_player_out(PlayerIdList, Out).

%% 通知红包清除
notice_player_red_packet_clear(PlayerIdList, RIdList) ->
%%    ?DEBUG("通知红包清除：~p~n", [{PlayerIdList, RIdList}]),
    Out = proto:encode(#m_red_packet_notice_player_red_packet_clear_toc{r_id_list = RIdList}),
    notice_player_out(PlayerIdList, Out).

notice_player_out(PlayerIdList, Out) ->
    [mod_socket:send(PlayerId, Out) || PlayerId <- PlayerIdList].

%%
pack_red_packet_condition_data({RedConditionId, RedPacketList, ParamList}) ->
    #redpacketconditiondata{id = RedConditionId, red_packet_data = pack_red_packet_data_list(RedPacketList), param_list = [util:to_binary(Param) || Param <- ParamList]}.


pack_red_packet_data_list(RedPacketList) ->
    [#redpacketdata{red_packet_id = RedId, r_id = RId, clear_time = ClearTime} || {RedId, RId, ClearTime} <- RedPacketList].
