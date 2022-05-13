%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%      API 奖金池
%%% @end
%%% Created : 25. 五月 2021 上午 11:20:42
%%%-------------------------------------------------------------------
-module(api_jiangjinchi).
-author("yizhao.wang").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("player_game_data.hrl").
-include("gen/db.hrl").

%% API
-export([
	do_draw/2,
	reward_double/2,
	result/2,
	get_info/2
]).

-export([notice_info/4]).

%% ====================================================================
%% Api functions
%% ====================================================================
do_draw(
    #m_jiangjinchi_do_draw_tos{},
    State = #conn{player_id = PlayerId}
) ->
	SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
	case catch mod_jiangjinchi:do_draw(PlayerId, SceneId) of
		{ok, AwardNum, MissedNumList, IsCanDoubled, NextDoubledAwardNum, NewDoubledTimes} ->
			Result = ?P_SUCCESS;
		{'EXIT', Error} ->
			Result = Error,
			AwardNum = 0,
			MissedNumList = [],
			IsCanDoubled = false,
			NextDoubledAwardNum = 0,
			NewDoubledTimes = 0
	end,
%%	?DEBUG("--- do_draw: ~w",[{Result, AwardNum, MissedNumList, IsCanDoubled, NextDoubledNum}]),
    Out = proto:encode(#m_jiangjinchi_do_draw_toc{
        result = Result,
		draw_num = AwardNum,
        missed_nums = MissedNumList,
		is_can_double = IsCanDoubled,
		double_num = NextDoubledAwardNum,
		doubled_times = NewDoubledTimes
    }),
    mod_socket:send(Out),
    State.

reward_double(
	#m_jiangjinchi_reward_double_tos{},
	State = #conn{player_id = PlayerId}
) ->
	SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
	case catch mod_jiangjinchi:do_reward_double(PlayerId, SceneId) of
		{Result, NewAwardNum, ExtraAwardNum, IsCanDoubled, NextDoubledAwardNum, NewDoubledTimes} ->
			ok;
		{'EXIT', Error} ->
			Result = Error,
			NewAwardNum = 0,
			ExtraAwardNum = 0,
			IsCanDoubled = false,
			NextDoubledAwardNum = 0,
			NewDoubledTimes = 0
	end,
%%	?DEBUG("--- reward_double: ~w",[{Result, NewAwardNum, ExtraAwardNum, IsCanDoubled, NextDoubledAwardNum}]),
	Out = proto:encode(#m_jiangjinchi_reward_double_toc{
		result = Result,
		draw_num = NewAwardNum,
		extra_num = ExtraAwardNum,
		is_can_double = IsCanDoubled,
		double_num = NextDoubledAwardNum,
		doubled_times = NewDoubledTimes
	}),
	mod_socket:send(Out),
	State.

result(
	#m_jiangjinchi_result_tos{},
	State = #conn{player_id = PlayerId}
) ->
	SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
	case catch mod_jiangjinchi:do_result(PlayerId, SceneId) of
		{ok, AwardNum, ExtraAwardNum} ->
			Result = ?P_SUCCESS;
		{'EXIT', Error} ->
			Result = Error,
			AwardNum = 0,
			ExtraAwardNum = 0
	end,
%%	?DEBUG("--- result: ~w",[{Result, AwardNum, ExtraAwardNum}]),
	Out = proto:encode(#m_jiangjinchi_result_toc{
		result = Result,
		draw_num = AwardNum,
		extra_num = ExtraAwardNum
	}),
	mod_socket:send(Out),
	State.

get_info(
	#m_jiangjinchi_get_info_tos{},
	State = #conn{player_id = PlayerId}
) ->
	SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
	{ok, Pool} = mod_jiangjinchi:get_pool_info(PlayerId, SceneId),
	Out = proto:encode(#m_jiangjinchi_get_info_toc{
		pool = Pool
	}),
	mod_socket:send(Out),
	State.

%%%===================================================================
%%% Extra functions
%%%===================================================================
notice_info(PlayerId, SceneId, State, AckTimes) ->
	Out =  proto:encode(#m_jiangjinchi_info_notice_toc{
		state = State,
		atk_times = AckTimes,
		scene_id = SceneId
	}),
	mod_socket:send(PlayerId, Out).