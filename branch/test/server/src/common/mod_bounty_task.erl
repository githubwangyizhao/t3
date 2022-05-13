%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         赏金任务
%%% @end
%%% Created : 11. 十月 2021 下午 03:27:27
%%%-------------------------------------------------------------------
-module(mod_bounty_task).

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("server_data.hrl").
-include("player_game_data.hrl").

-export([
	on_before_enter_game/1,
	on_date_cut/1
]).

-export([
	get_award/1,
	refresh_bounty_task_data/1,
	get_player_bounty_task_data_list/1,
	do_accept_bounty_task/2,
	do_refresh_bounty_task/1,
    try_update_player_task/3
]).

%% ----------------------------------
%% @doc 	钩子进入游戏前
%% @throws 	none
%% @end
%% ----------------------------------
on_before_enter_game(PlayerId) ->
	NowDateStr = util_time:timestamp_to_datestr(util_time:timestamp()),
	IsTaskLineCompleted = mod_task:is_task_line_completed(PlayerId),
	case mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_LAST_DATE) of
		NowDateStr ->
			noop;
		_ when IsTaskLineCompleted ->
			refresh_bounty_task_data(PlayerId, true);
		_ ->
			noop
	end,
	ok.

%% ----------------------------------
%% @doc 	跨天时
%% @throws 	none
%% @end
%% ----------------------------------
on_date_cut(PlayerId) ->
	case mod_task:is_task_line_completed(PlayerId) of
		true ->
			refresh_bounty_task_data(PlayerId, true);
		false ->
			noop
	end,
	ok.

%% ----------------------------------
%% @doc 	刷新赏金任务
%% @throws 	none
%% @end
%% ----------------------------------
refresh_bounty_task_data(PlayerId) -> refresh_bounty_task_data(PlayerId, false).
refresh_bounty_task_data(PlayerId, DateChange) ->
	TaskCompletedTimes = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_COMPLETED_TIMES, 0),
	[IdMin, IdMax] = util_list:get_value_from_range_list(TaskCompletedTimes, ?SD_MONEY_REWARD_TYPE),
	NewTaskIdList = lists:sublist(util_list:shuffle(lists:seq(IdMin, IdMax)), ?SD_MONEY_REWARD_TASK),

	NowSec = util_time:timestamp(),
	Tran =
		fun() ->
			%% 删除旧任务数据
			db:select_delete(player_bounty_task, [{#db_player_bounty_task{player_id = '$1', _ = '_'}, [{'=:=','$1',PlayerId}], ['$_']}]),
			mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID, 0),
			if
				DateChange ->
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_TIMES, 0),
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_RESET_TIMES, 0);
				true ->
					noop
			end,
			mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_LAST_DATE, util_time:timestamp_to_datestr(NowSec)),
			%% 写入新任务数据
			[db:write(#db_player_bounty_task{player_id = PlayerId, id = Id, change_time = NowSec}) || Id <- NewTaskIdList],
			%% 通知任务刷新
			db:tran_apply(fun() -> api_task:notice_bounty_task_reset(PlayerId) end)
		end,
	db:do(Tran).

%% ----------------------------------
%% @doc 	查询赏金任务数据
%% @throws 	none
%% @end
%% ----------------------------------
get_player_bounty_task_data_list(PlayerId) ->
	{AcceptState, TaskIdList} =
		case mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID) of
			0 ->
				{?FALSE, get_player_all_bounty_task_id_list(PlayerId)};
			AcceptTaskId ->
				{?TRUE, [AcceptTaskId]}
		end,

	{AcceptState,
	lists:foldl(
		fun(Id,TmpL) ->
			case get_db_player_bounty_task(PlayerId, Id) of
				null ->
					TmpL;
				R ->
					[R|TmpL]
			end
		end,
		[], TaskIdList
	)}.

%% ----------------------------------
%% @doc 	获取玩家所有赏金任务id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_player_all_bounty_task_id_list(PlayerId) ->
	[R#db_player_bounty_task.id || R <- db_index:get_rows(#idx_player_bounty_task_1{player_id = PlayerId})].

%% ----------------------------------
%% @doc 	获取赏金任务数据
%% @throws 	none
%% @end
%% ----------------------------------
get_db_player_bounty_task(PlayerId, Id) ->
	db:read(#key_player_bounty_task{player_id = PlayerId, id = Id}).

%% ----------------------------------
%% @doc 	接受赏金任务
%% @throws 	none
%% @end
%% ----------------------------------
do_accept_bounty_task(PlayerId, TaskId) ->
	AcceptTaskId = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID, 0),
	?ASSERT(AcceptTaskId == 0, already_exists),

	AcceptTimes = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_TIMES, 0),
	?ASSERT(AcceptTimes < ?SD_NUMBER_TIMES, ?ERROR_NOT_ENOUGH_TIMES),

	DbPlayerTaskIdList = get_player_all_bounty_task_id_list(PlayerId),
	?ASSERT(lists:member(TaskId, DbPlayerTaskIdList), ?ERROR_FAIL),

	mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID, TaskId),
	mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_TIMES),
	ok.

%% ----------------------------------
%% @doc 	领取奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_award(PlayerId) ->
	AcceptTaskId = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID, 0),
	?ASSERT(AcceptTaskId /= 0, not_exists),

    DbPlayerTask = get_db_player_bounty_task(PlayerId, AcceptTaskId),
    #db_player_bounty_task{
        player_id = PlayerId,
        state = Status
    } = DbPlayerTask,
    ?ASSERT(Status /= ?AWARD_NONE, ?ERROR_NO_FINISH),
    ?ASSERT(Status /= ?AWARD_ALREADY, ?ERROR_ALREADY_GET),
    ?ASSERT(Status == ?AWARD_CAN, ?ERROR_FAIL),

    #t_money_reward{
        award_list = AwardId
    } = t_money_reward:get({AcceptTaskId}),
    Tran =
        fun() ->
			db:write(DbPlayerTask#db_player_bounty_task{state = ?AWARD_ALREADY}),
            mod_award:give(PlayerId, AwardId, ?LOG_TYPE_FINISH_BOUNTY_TASK),
			mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_COMPLETED_TIMES),
			mod_conditions:add_conditions(PlayerId, {?CON_ENUM_COMPLETE_REWARD_TASK, ?CONDITIONS_VALUE_ADD, 1}),
			refresh_bounty_task_data(PlayerId)
        end,
    db:do(Tran),
    ok.

%% ----------------------------------
%% @doc 	刷新赏金任务
%% @throws 	none
%% @end
%% ----------------------------------
do_refresh_bounty_task(PlayerId) ->
	mod_interface_cd:assert({?MODULE, refresh_bounty_task}, ?SD_MONEY_REWARD_CD),

	ResetTimes = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_RESET_TIMES, 0),
	CostItems =
		case ResetTimes < ?SD_NUMBER_OF_TIMES of
			true ->
				[];
			false ->
				mod_prop:assert_prop_num(PlayerId, ?SD_MONEY_REWARD_RENOVATE),
				?SD_MONEY_REWARD_RENOVATE
		end,

	AcceptTaskId = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID, 0),
	IsOk =
	case AcceptTaskId of
		0 -> true;
		_ ->
			%% 已经接受的任务必须先完成
			case get_db_player_bounty_task(PlayerId, AcceptTaskId) of
				null -> true;
				R ->
					#db_player_bounty_task{
						state = State
					} = R,
					State == ?AWARD_ALREADY
			end
	end,
	?ASSERT(IsOk andalso mod_task:is_task_line_completed(PlayerId), not_authority),

	db:do(
		fun()->
			refresh_bounty_task_data(PlayerId),
			mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_RESET_TIMES),
			mod_prop:decrease_player_prop(PlayerId, CostItems, ?LOG_TYPE_RESET_BOUNTY_TASK)
		end
	),
	ok.

%% ----------------------------------
%% @doc 	触发完成任务
%% @throws 	none
%% @end
%% ----------------------------------
try_update_player_task(_PlayerId, [], _E) ->
    noop;
try_update_player_task(PlayerId, TaskIdList, E) when is_list(TaskIdList) ->
	AcceptTaskId = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID, 0),
    case lists:member(AcceptTaskId, TaskIdList) of
        true ->
			DbPlayerTask = get_db_player_bounty_task(PlayerId, AcceptTaskId),
            try_update_player_task(DbPlayerTask, E);
        false ->
            noop
    end.
try_update_player_task(DbPlayerTask, {Type, Value}) when is_integer(Value) ->
    #db_player_bounty_task{
        player_id = PlayerId,
        id = TaskId,
        value = OldNum,
        state = Status
    } = DbPlayerTask,
    if
        Status == ?AWARD_NONE ->
            #t_money_reward{
				approach_list = ConditionList
            } = t_money_reward:get({TaskId}),
            [_, NeedNum] = logic_code:tran_condition_list(ConditionList),
            RealNum =
                if Type == ?CONDITIONS_VALUE_ADD ->
                    OldNum + Value;
                    true ->
                        Value
                end,
            {NewNum, NewStatus} =
				if RealNum >= NeedNum ->
					{NeedNum, ?AWARD_CAN};
					true ->
						{RealNum, ?AWARD_NONE}
				end,
            Tran =
                fun() ->
                    NewPlayerTask = DbPlayerTask#db_player_bounty_task{value = NewNum, state = NewStatus, change_time = util_time:timestamp()},
                    db:write(NewPlayerTask),
					db:tran_apply(fun() -> api_task:notice_bounty_task_change(PlayerId, NewPlayerTask) end)
				end,
            db:do(Tran);
        true ->
            noop
    end.