%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. 8月 2021 10:14
%%%-------------------------------------------------------------------
-module(api_scene_event).
-author("yizhao.wang").

-include("error.hrl").
-include("common.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("scene.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
	do_laba/2,
	do_turntable/2,
	do_money_three/2,

	notice_task_info/0,
	notice_three_result_info/1,

	query_balls_data/2,
	notice_drop_ball/5,
	notice_ball_result_info/3
]).

%% 请求拉霸
do_laba(
	#m_scene_event_do_laba_tos{},
	State = #conn{player_id = PlayerId}
) ->
	SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
	{Result, Id, PropList} =
		case catch mod_scene_event:do_laba(PlayerId, SceneId) of
			{ok, Id_, PropList_} ->
				{?P_SUCCESS, Id_, PropList_};
			{'EXIT', Error} ->
				{Error, 0, []}
		end,
	Out = proto:encode(#m_scene_event_do_laba_toc{
		result = Result,
		id = Id,
		prop_list = api_prop:pack_prop_list(PropList)
	}),
	mod_socket:send(Out),
	State.

%% 请求转盘
do_turntable(
	#m_scene_event_do_turntable_tos{},
	State = #conn{player_id = PlayerId}
) ->
	SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
	{Result, Id, PropList} =
		case catch mod_scene_event:do_turntable(PlayerId, SceneId) of
			{ok, Id_, PropList_} ->
				{?P_SUCCESS, Id_, PropList_};
			{'EXIT', Error} ->
				{Error, 0, []}
		end,
	Out = proto:encode(#m_scene_event_do_turntable_toc{
		result = Result,
		id = Id,
		prop_list = api_prop:pack_prop_list(PropList)
	}),
	mod_socket:send(Out),
	State.

%% 摇钱树
do_money_three(
	#m_scene_event_do_money_three_tos{},
	State = #conn{player_id = PlayerId}
) ->
	SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
	{Result, Id, PropList} =
		case catch mod_scene_event:do_money_three(PlayerId, SceneId) of
			{ok, Id_, PropList_} ->
				{?P_SUCCESS, Id_, PropList_};
			{'EXIT', Error} ->
				{Error, 0, []}
		end,
	Out = proto:encode(#m_scene_event_do_money_three_toc{
		result = Result,
		id = Id,
		prop_list = api_prop:pack_prop_list(PropList)
	}),
	mod_socket:send(Out),
	State.

%%%%%%%%%%%%%%%%%%% 任务事件相关
%% 通知任务信息
notice_task_info() ->
	ScenePid = self(),
	case mod_cache:get({scene_worker_event_task, ScenePid}) of
		#r_event_task{stage = 1, done = Num} ->
			Notice = #m_scene_event_notice_task_toc{
				num = Num
			},
			PlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
			mod_socket:send_to_player_list(PlayerIdList, proto:encode(Notice));
		_ ->
			skip
	end.

%% 通知摇钱树结算清单
notice_three_result_info(Results) ->
	PlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
	Data =
		[begin
			 #'m_scene_event_notice_money_three_result_toc.resultinfo'{
				 player_info = api_player:pack_player_base_data(PlayerId),
				 prop_list = api_prop:pack_prop_list(Rewards)
			 }
		 end || {PlayerId, Rewards} <- Results, lists:member(PlayerId, PlayerIdList)],
	Notice = #m_scene_event_notice_money_three_result_toc{
		results = Data
	},
	mod_socket:send_to_all_online_player(proto:encode(Notice)).

%%%%%%%%%%%%%%%%%% 彩球事件相关
%% 查询彩球数据请求
query_balls_data(
	#m_scene_event_query_balls_data_tos{},
	State = #conn{player_id = PlayerId}
) ->
	Data =
		case mod_scene_event:query_balls_data(PlayerId) of
			{ok, Data0} -> Data0;
			_ -> []
		end,
	Out = proto:encode(#m_scene_event_query_balls_data_toc{
		balls = Data
	}),
	mod_socket:send(Out),
	State.

%% 通知掉落彩球 undo!
notice_drop_ball(PLayerIdList, Number, OwnPlayerId, X, Y) ->
	Notice =
		proto:encode(#m_scene_event_notice_drop_ball_toc{
			number = Number,
			own_player_id = OwnPlayerId,
			x = X,
			y = Y
		}),
	mod_socket:send_to_player_list(PLayerIdList, Notice).

%% 通知彩球结算
notice_ball_result_info(LuckId, PlayerId, Rewards) ->
	Notice =
		case PlayerId of
			null ->
				#m_scene_event_notice_balls_result_toc{
					luck = LuckId
				};
			_ ->
				Result = [#'m_scene_event_notice_balls_result_toc.resultinfo'{
							player_info = mod_scene_event:get_scene_player_base_data(PlayerId),
							prop_list = api_prop:pack_prop_list(Rewards)
						}],
				#m_scene_event_notice_balls_result_toc{
					luck = LuckId,
					results = Result
				}
		end,
	mod_socket:send_to_all_online_player(proto:encode(Notice)).
