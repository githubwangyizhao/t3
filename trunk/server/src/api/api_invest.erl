%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         投资计划
%%% @end
%%% Created : 15. 三月 2021 下午 03:38:14
%%%-------------------------------------------------------------------
-module(api_invest).
-author("Administrator").

-include("p_message.hrl").
-include("common.hrl").

%% API
-export([
    init_notice_data/1,                         %% 初始化通知

    get_invest_award/2,                         %% 获得投资奖励

    notice_invest_type_data_update/4            %% 通知投资计划类型数据改变
]).

%% @doc 初始化通知
init_notice_data(PlayerId) ->
    PlayerInvestTypeDataList = mod_invest:get_player_invest_type_data_list(PlayerId),
    PbInvestTypeDataList = pack_pb_invest_type_data_list(PlayerInvestTypeDataList),
    Out = proto:encode(#m_invest_init_notice_toc{invest_type_data_list = PbInvestTypeDataList}),
    mod_socket:send(PlayerId, Out).

%% @doc 获得投资奖励
get_invest_award(
    #m_invest_get_invest_award_tos{type = Type, id = Id},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_invest:get_award(PlayerId, Type, Id)),
    Out = proto:encode(#m_invest_get_invest_award_toc{result = Result, type = Type, id = Id}),
    mod_socket:send(Out),
    State.

%% @doc 通知投资计划类型数据改变
notice_invest_type_data_update(PlayerId, Type, IsBuy, InvestDataList) ->
    Out = proto:encode(#m_invest_notice_invest_type_data_update_toc{invest_type_data = pack_pb_invest_type_data(Type, IsBuy, InvestDataList)}),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

%% @doc PB 结构化
pack_pb_invest_type_data_list(PlayerInvestTypeDataList) ->
    [pack_pb_invest_type_data(Type, IsBuy, InvestDataList) || {Type, IsBuy, InvestDataList} <- PlayerInvestTypeDataList].
pack_pb_invest_type_data(Type, IsBuy, InvestDataList) ->
    #investtypedata{
        type = Type,
        is_buy = IsBuy,
        invest_data = pack_pb_invest_data_list(InvestDataList)
    }.
pack_pb_invest_data_list(PlayerInvestList) ->
    [pack_pb_invest_data(Id, Status) || {Id, Status} <- PlayerInvestList].
pack_pb_invest_data(Id, Status) ->
    #investdata{
        id = Id,
        state = Status
    }.