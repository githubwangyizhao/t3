%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 03. 四月 2018 18:12
%%%-------------------------------------------------------------------
-module(api_vip).
-author("home").

%% API
-export([
    get_vip_award/2,
    notice_vip_data/1
]).

-export([
    api_get_info/1
]).

-include("common.hrl").
-include("p_message.hrl").

%% @fun api获得vip信息
api_get_info(PlayerId) ->
    {VipLevel, VipExp, AwardList} = mod_vip:get_vip_info(PlayerId),
    pack_vip_data(VipLevel, VipExp, AwardList).

%% @doc     获得vip奖励
get_vip_award(
    #m_vip_get_vip_award_tos{vip_level = VipLevel},
    #conn{player_id = PlayerId} = Stat
) ->
    Result = api_common:api_result_to_enum(catch mod_vip:get_vip_award(PlayerId, VipLevel)),
    Out = proto:encode(#m_vip_get_vip_award_toc{result = Result, vip_level = VipLevel}),
    mod_socket:send(Out),
    Stat.

%% @doc     通知vip数据
notice_vip_data(PlayerId) ->
    Out = proto:encode(#m_vip_notice_vip_data_toc{vip_data = api_get_info(PlayerId)}),
    mod_socket:send(PlayerId, Out).

pack_vip_data(VipLevel, VipExp, AwardList) ->
    #vipdata{
        vip_level = VipLevel,
        vip_exp = VipExp,
        vip_award_info = [#vipawardinfo{vip_level = Level, state = State} || {Level, State} <- AwardList]
    }.
