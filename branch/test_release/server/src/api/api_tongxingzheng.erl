%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%      API 通行证
%%% @end
%%% Created : 25. 五月 2021 上午 11:20:42
%%%-------------------------------------------------------------------
-module(api_tongxingzheng).
-author("yizhao.wang").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("player_game_data.hrl").
-include("gen/db.hrl").

%% API
-export([
    task_daily_reward_collect/2,
	task_month_reward_collect/2,
	purchase_unlock/2,
	purchase_level/2,
	collect_level_reward/2
]).
-export([
    notice_update_daily_task_info/2,
    notice_update_month_task_info/2,
    notice_task_info/1,
    notice_level_reward_data/1
]).

%% ====================================================================
%% Api functions
%% ====================================================================
task_daily_reward_collect(
    #m_tongxingzheng_task_daily_reward_collect_tos{
        id = TaskId
    },
    State = #conn{player_id = PlayerId}
) ->
    {Result, PropList} =
        case catch mod_tongxingzheng:collect_task_daily_reward(PlayerId, TaskId) of
            {ok, PropList1} ->
                {?P_SUCCESS, PropList1};
            {'EXIT', Error} ->
                {api_common:api_error_to_enum(Error), []}
        end,
    Out = proto:encode(#m_tongxingzheng_task_daily_reward_collect_toc{
        result = Result,
		id = TaskId,
        prop_list = api_prop:pack_prop_list(PropList)
    }),
    mod_socket:send(Out),
    State.

task_month_reward_collect(
    #m_tongxingzheng_task_month_reward_collect_tos{
        id = TaskId
    },
    State = #conn{player_id = PlayerId}
) ->
    {Result, PropList} =
        case catch mod_tongxingzheng:collect_task_month_reward(PlayerId, TaskId) of
            {ok, PropList1} ->
                {?P_SUCCESS, PropList1};
            {'EXIT', Error} ->
                {api_common:api_error_to_enum(Error), []}
        end,
    Out = proto:encode(#m_tongxingzheng_task_month_reward_collect_toc{
        result = Result,
		id = TaskId,
        prop_list = api_prop:pack_prop_list(PropList)
    }),
    mod_socket:send(Out),
    State.

purchase_unlock(
	#m_tongxingzheng_purchase_unlock_tos{
		type = Type
	},
	State = #conn{player_id = PlayerId}
) ->
	Result =
		case catch mod_tongxingzheng:purchase_unlock(PlayerId, Type) of
			ok ->
				?P_SUCCESS;
			{'EXIT', Error} ->
				Error
		end,
	Out = proto:encode(#m_tongxingzheng_purchase_unlock_toc{
		result = Result,
		type = Type
	}),
	mod_socket:send(Out),
	State.

purchase_level(
	#m_tongxingzheng_purchase_level_tos{},
	State = #conn{player_id = PlayerId}
) ->
	Result =
		case catch mod_tongxingzheng:purchase_level(PlayerId) of
			ok ->
				?P_SUCCESS;
			{'EXIT', Error} ->
				api_common:api_error_to_enum(Error)
		end,
	Out = proto:encode(#m_tongxingzheng_purchase_level_toc{
		result = Result
	}),
	mod_socket:send(Out),
	State.

collect_level_reward(
	#m_tongxingzheng_collect_level_reward_tos{
		lv = Lv,
		type = Type
	},
	State = #conn{player_id = PlayerId}
) ->
	{Result, PropList} =
		case catch mod_tongxingzheng:collect_level_reward(PlayerId, Lv, Type) of
			{ok, PropList1} ->
				{?P_SUCCESS, PropList1};
			{'EXIT', Error} ->
				{api_common:api_error_to_enum(Error), []}
		end,
	Out = proto:encode(#m_tongxingzheng_collect_level_reward_toc{
		result = Result,
		lv = Lv,
		type = Type,
		prop_list = api_prop:pack_prop_list(PropList)
	}),
	mod_socket:send(Out),
	State.

%%%===================================================================
%%% Extra functions
%%%===================================================================
%% 每日任务更新推送
notice_update_daily_task_info(PlayerId, TaskList) ->
    Tasks = [#taskinfo{task_id = Id, num = Done, status = Status} || {Id, Done, Status} <- TaskList],
    Out = proto:encode(#m_tongxingzheng_task_daily_update_notice_toc{tasks = Tasks}),
    mod_socket:send(PlayerId, Out).

%% 月度任务更新推送
notice_update_month_task_info(PlayerId, TaskList) ->
    Tasks = [#taskinfo{task_id = Id, num = Done, status = Status} || {Id, Done, Status} <- TaskList],
    Out = proto:encode(#m_tongxingzheng_task_month_update_notice_toc{tasks = Tasks}),
    mod_socket:send(PlayerId, Out).

%% 通行证任务信息推送
notice_task_info(PlayerId) ->
    {_, _, Day} = util_time:local_date(),
	MaxDay = util_time:get_month_days(),

    DailyTaskList =  mod_tongxingzheng:get_db_daily_task_list(PlayerId),
	MonthTaskList = mod_tongxingzheng:get_db_month_task_list(PlayerId),

    Out = proto:encode(#m_tongxingzheng_task_info_notice_toc{
        day = Day,
        time = mod_tongxingzheng:get_task_month_end_time(PlayerId),
        daily_tasks = [#taskinfo{task_id = Id, num = Done, status = Status} || {Id, Done, Status} <- DailyTaskList],
        month_tasks = [
			#taskinfo{
				task_id = Id,
				num = Done,
				status = Status
			} || {Id, Done, Status} <- MonthTaskList, Status /= ?AWARD_ALREADY, mod_tongxingzheng:get_cfg_tongxingzheng_task_month_unlock_day(Id) =< min(Day+1, MaxDay)
		]
    }),
    mod_socket:send(PlayerId, Out).

%% 通行证等级信息推送
notice_level_reward_data(PlayerId) ->
    SilverLvAwardStr = mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_SILVER_AWARD_STR),
    DiamondLvAwardStr = mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_DIAMOND_AWARD_STR),
	IsBuy = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_IS_BUY),
    Exp = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXP),
    Out = proto:encode(#m_tongxingzheng_reward_info_notice_toc{
        exp = Exp,
        lv = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV),
        box_num = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXTRA_BOX_NUM),
        is_buy = ?TRAN_INT_2_BOOL(IsBuy),
        txz_id = mod_tongxingzheng:get_player_txz_id(PlayerId),
        silver_rewards = mod_tongxingzheng:trans_2_already_collect_list(SilverLvAwardStr),
        diamond_rewards = mod_tongxingzheng:trans_2_already_collect_list(DiamondLvAwardStr)
    }),
    mod_socket:send(PlayerId, Out).