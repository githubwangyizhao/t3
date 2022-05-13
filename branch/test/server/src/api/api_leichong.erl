%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%       累充奖励
%%% @end
%%% Created : 27. 5月 2021 12:00
%%%-------------------------------------------------------------------
-module(api_leichong).

-include("common.hrl").
-include("p_message.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("gen/db.hrl").

%% API
-export([
	info_query/2,
	get_reward/2
]).

%% 获取累充奖励列表
info_query(
	#m_leichong_info_query_tos{},
	State = #conn{player_id = PlayerId}
) ->
	{ok, List} = mod_leichong:info_query(PlayerId),
	Reply =
		proto:encode(#m_leichong_info_query_toc{
			activity_id = mod_leichong:get_global_activity_id(),
			list = pack_lei_chong_info(List)
		}),
	mod_socket:send(Reply),
	State.

%% 领取奖励
get_reward(
	#m_leichong_get_reward_tos{
		activity_id = ActivityId,
		id = Id
	},
	State = #conn{player_id = PlayerId}
)->
	{Result, PropList} =
		case catch mod_leichong:get_reward(PlayerId, ActivityId, Id) of
			{ok, PropList0} ->
				{?P_SUCCESS, PropList0};
			{'EXIT', Error} ->
				{Error, []}
		end,
	Reply =
		proto:encode(#m_leichong_get_reward_toc{
			result = Result,
			activity_id = ActivityId,
			id = Id,
			prop_list = api_prop:pack_prop_list(PropList)
		}),
	mod_socket:send(Reply),
	State.

%%%===================================================================
%%% Internal functions
%%%===================================================================
pack_lei_chong_info(List) ->
	[#'m_leichong_info_query_toc.leichong'{
		id = Id,
		done = Done,
		state = State,
		target = Target,
		award_list = api_prop:pack_prop_list(RewardList)
	} || {Id, Done, Target, State, RewardList} <- List].