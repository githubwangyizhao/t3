%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 9月 2021 下午 12:09:09
%%%-------------------------------------------------------------------
-module(api_first_charge).
-author("Administrator").

-include("p_message.hrl").
-include("common.hrl").

%% API
-export([
    get_award/2,
    send_get_award_result/4,

    notice_init_data/1,
    notice_update_data/2
]).

%% ----------------------------------
%% @doc 	获得奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_award(
    #m_first_charge_get_award_tos{type = Type, day = Day},
    #conn{player_id = PlayerId} = State
) ->
    Result = api_common:api_result_to_enum(catch mod_first_charge:get_award(PlayerId, Type, Day)),
    send_get_award_result(PlayerId, Result, Type, Day),
    State.
send_get_award_result(PlayerId, Result, Type, Day) ->
    Out = proto:encode(#m_first_charge_get_award_toc{
        result = Result,
        type = Type,
        day = Day
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知初始化数据
notice_init_data(PlayerId) ->
    Out = proto:encode(#m_first_charge_init_data_first_recharge_toc{
        first_charge_list = mod_first_charge:get_data_list(PlayerId)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知更新数据
notice_update_data(PlayerId, Type) ->
    Out = proto:encode(#m_first_charge_notice_data_update_toc{
        first_charge = mod_first_charge:get_data(PlayerId, Type)
    }),
    mod_socket:send(PlayerId, Out).