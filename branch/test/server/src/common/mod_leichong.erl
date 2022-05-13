%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         累充奖励
%%% @end
%%% Created : 07. 五月 2021 下午 05:53:15
%%%-------------------------------------------------------------------
-module(mod_leichong).
-author("yizhao.wang").

-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("error.hrl").
-include("client.hrl").
-include("server_data.hrl").
-include("player_game_data.hrl").
-include("p_message.hrl").

%% API
-export([info_query/1,
	get_reward/3]).

-export([ready_activity/1,
	open_activity/1,
	close_activity/1,
	clean_activity/1,
	get_global_activity_id/0,
	refresh_task/2,
	on_before_enter_game/1,
	on_info/2]).

-define(default_activity_id, 0).

%%%===================================================================
%%% API
%%%===================================================================
%% 查询累充奖励列表
info_query(PlayerId) ->
	ActivityId = get_global_activity_id(),
	List =
		lists:map(fun(R) ->
			#t_activity_lei_chong{
				id = Id,
				value = Target,
				reward_list = RewardList
			} = R,
			DbPlayerLeichong = get_db_player_leichong_or_init(PlayerId, ActivityId, Id),
			#db_player_leichong{
				done = Done,
				state = State
			} = DbPlayerLeichong,
			{Id, Done, Target, State, RewardList}
		end, get_t_activity_lei_chong_list(ActivityId)),
	{ok, List}.

%% 领取累充任务奖励
get_reward(PlayerId, ActivityId, Id) ->
	DbPlayerLeichong = get_db_player_leichong_or_init(PlayerId, ActivityId, Id),
	#db_player_leichong{
		state = State
	} = DbPlayerLeichong,
	?ASSERT(State /= ?AWARD_NONE, undone),
	?ASSERT(State /= ?AWARD_ALREADY, already_get),
	#t_activity_lei_chong{
		reward_list = PropList
	} = assert_get_t_activity_lei_chong(ActivityId, Id),
	Tran =
		fun() ->
			mod_award:give(PlayerId, PropList, ?LOG_TYPE_LEICHONG_REWARD),
			db:write(DbPlayerLeichong#db_player_leichong{state = ?AWARD_ALREADY})
		end,
	db:do(Tran),
	{ok, PropList}.

%%%===================================================================
%%% Extra API
%%%===================================================================
ready_activity(_ActivityId) ->
	ok.

open_activity(ActivityId) ->
	?DEBUG("open_activity ~p !!!", [ActivityId]),
	mod_server_data:set_int_data(?SERVER_DATA_LEI_CHONG_ACTIVITY_ID, ActivityId),
	mod_apply:apply_to_all_online_player_2(?MODULE, on_info, change_activity),
	ok.

close_activity(_ActivityId) ->
	?DEBUG("close_activity ~p !!!", [_ActivityId]),
	mod_server_data:set_int_data(?SERVER_DATA_LEI_CHONG_ACTIVITY_ID, ?default_activity_id),
	mod_apply:apply_to_all_online_player_2(?MODULE, on_info, change_activity),
	ok.

clean_activity(_ActivityId) ->
	ok.

on_before_enter_game(PlayerId) ->
	refresh_activity_id(PlayerId, get_global_activity_id()),
	ok.

on_info(PlayerId, change_activity) ->
	refresh_activity_id(PlayerId, get_global_activity_id()),
	ok.

get_global_activity_id() ->
	mod_server_data:get_int_data(?SERVER_DATA_LEI_CHONG_ACTIVITY_ID).

%% 刷新累充任务
refresh_task(PlayerId, AddNum) ->
	case get_global_activity_id() of
		?default_activity_id -> skip;
		ActivityId  ->
			Tran =
				fun() ->
					lists:foreach(fun(R) ->
						#t_activity_lei_chong{
							id = Id,
							value = Target
						} = R,
						DbPlayerLeichong = get_db_player_leichong_or_init(PlayerId, ActivityId, Id),
						#db_player_leichong{
							done = OriDone,
							state = OriState
						} = DbPlayerLeichong,
						NewDone = min(OriDone + AddNum, Target),
						NewState = ?IF(OriState =:= ?AWARD_NONE andalso NewDone >= Target, ?AWARD_CAN, OriState),
						if
							NewState /= OriState orelse NewDone /= OriDone ->
								db:write(DbPlayerLeichong#db_player_leichong{
									done = NewDone,
									state = NewState
								});
							true ->
								skip
						end
					end, get_t_activity_lei_chong_list(ActivityId))
				end,
			db:do(Tran)
	end,
	ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
refresh_activity_id(PlayerId, GlobalActivityId) ->
	PlayerActivityId = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_LEI_CHONG_ACTIVITY_ID, ?default_activity_id),
	case PlayerActivityId /= GlobalActivityId of
		true when PlayerActivityId =:= ?default_activity_id ->
			mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_LEI_CHONG_ACTIVITY_ID, GlobalActivityId),
			skip;
		true ->
			Tran =
				fun() ->
					Fun =
						fun(R, Acc) ->
							#t_activity_lei_chong{
								id = Id,
								reward_list = RewardList
							} = R,
							DbPlayerLeichong = get_db_player_leichong_or_init(PlayerId, PlayerActivityId, Id),
							#db_player_leichong{
								state = State
							} = DbPlayerLeichong,
							db:delete(DbPlayerLeichong),
							if
								State =:= ?AWARD_CAN -> Acc ++ RewardList;
								true -> Acc
							end
						end,
					TotalRewardList = lists:foldl(Fun, [], get_t_activity_lei_chong_list(PlayerActivityId)),
					%% 邮件补发奖励
					case TotalRewardList of
						[] -> skip;
						_ -> mod_mail:add_mail_item_list(PlayerId, ?MAIL_ACTIVITY_LEI_CHONG, TotalRewardList, ?LOG_TYPE_LEICHONG_REWARD)
					end,
					%% 重置玩家活动id
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_LEI_CHONG_ACTIVITY_ID, GlobalActivityId)
				end,
			db:do(Tran),
			ok;
		false ->
			skip
	end,
	ok.

%%%===================================================================
%%% database functions
%%%===================================================================
get_db_player_leichong_or_init(PlayerId, ActivityId, TaskId) ->
	case db:read(#key_player_leichong{player_id = PlayerId, activity_id = ActivityId, task_id = TaskId}) of
		null -> #db_player_leichong{player_id = PlayerId, activity_id = ActivityId, task_id = TaskId};
		R when is_record(R, db_player_leichong) -> R
	end.

%%%===================================================================
%%% config functions
%%%===================================================================
get_t_activity_lei_chong_list(ActivityId) ->
	case t_activity_lei_chong@group:get(ActivityId) of
		undefined -> [];
		L -> L
	end.

assert_get_t_activity_lei_chong(ActivityId, Id) ->
	case t_activity_lei_chong:assert_get({ActivityId, Id}) of
		null -> [];
		L -> L
	end.
