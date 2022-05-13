%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		通行证
%%% @end
%%% Created : 11. 6月 2021 15:45
%%%-------------------------------------------------------------------
-module(mod_tongxingzheng).
-author("yizhao.wang").

-include("common.hrl").
-include("p_enum.hrl").
-include("error.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").

%% api
-export([collect_task_daily_reward/2, collect_task_month_reward/2]).
-export([collect_level_reward/3, purchase_level/1, purchase_unlock/2]).

%% extra api
-export([on_before_enter_game/1, on_after_enter_game/1, on_date_cut/1]).
-export([upgrade_level/3]).
-export([trigger_task_daily/3, trigger_task_month/3]).
-export([trans_2_already_collect_list/1, get_player_txz_id/1, get_task_month_end_time/1]).

%% database api
-export([get_db_daily_task_info/1, get_db_daily_task_list/1, get_db_month_task_info/1, get_db_month_task_list/1]).

%% config api
-export([get_cfg_tongxingzheng_task_month_unlock_day/1, get_cfg_tongxingzheng_task_type/1]).

-define(type_silver, 1).		% 白银通行证奖励
-define(type_diamond, 2).		% 钻石通行证奖励
-define(type_extra_box, 3).		% 大宝箱奖励

-define(txz_max_level(TxzId), length(t_tongxingzheng_level@group:get(TxzId)) - 1).		% 通行证最大等级

-define(buy_ordinary, 1).		% 购买钻石通行证
-define(buy_advanced, 2).		% 购买钻石通行证礼包

-define(default_txz_id, 0).		% 默认通行证id

%% ====================================================================
%% Client Api functions
%% ====================================================================

%% 每日任务奖励
collect_task_daily_reward(PlayerId, TaskId) ->
	DbTaskRec = get_db_daily_task_info(PlayerId),
	#db_tongxingzheng_daily_task{
		task_list = TasksStr
	} = DbTaskRec,
	TaskList = util_string:string_to_term(TasksStr),
	case lists:keytake(TaskId, 1, TaskList) of
		false ->
			exit(?ERROR_NOT_AUTHORITY);
		{value, {TaskId, _Done, ?AWARD_NONE}, _T} ->
			exit(?ERROR_NO_FINISH);
		{value, {TaskId, _Done, ?AWARD_ALREADY}, _T} ->
			exit(?ERROR_ALREADY_GET);
		{value, {TaskId, Done, ?AWARD_CAN}, T} ->
			NewTaskList = [{TaskId, Done, ?AWARD_ALREADY} | T],
			Tran =
				fun() ->
					db:write(
						DbTaskRec#db_tongxingzheng_daily_task{
							task_list = util_string:term_to_string(NewTaskList)
						}
					),
					PropList = get_cfg_tongxingzheng_task_daily_reward_list(TaskId),
					mod_award:give(PlayerId, PropList, ?LOG_TYPE_TXZ_TASK_DAILY_AWARD),
					{ok, [PropList]}
				end,
			db:do(Tran)
	end.

%% 月度奖励
collect_task_month_reward(PlayerId, TaskId) ->
	DbTaskRec = get_db_month_task_info(PlayerId),
	#db_tongxingzheng_month_task{
		task_list = TasksStr
	} = DbTaskRec,
	TaskList = util_string:string_to_term(TasksStr),
	case lists:keytake(TaskId, 1, TaskList) of
		false ->
			exit(?ERROR_NOT_AUTHORITY);
		{value, {TaskId, _Done, ?AWARD_NONE}, _T} ->
			exit(?ERROR_NO_FINISH);
		{value, {TaskId, _Done, ?AWARD_ALREADY}, _T} ->
			exit(?ERROR_ALREADY_GET);
		{value, {TaskId, _Done, ?AWARD_CAN}, T} ->
			Tran =
				fun() ->
					db:write(
						DbTaskRec#db_tongxingzheng_month_task{
							task_list = util_string:term_to_string(T)
						}
					),
					PropList = get_cfg_tongxingzheng_task_month_reward_list(TaskId),
					mod_award:give(PlayerId, PropList, ?LOG_TYPE_TXZ_TASK_MONTH_AWARD),
					{ok, [PropList]}
				end,
			db:do(Tran)
	end.

%% 领取通行证等级奖励
collect_level_reward(PlayerId, Lv, Type) ->
	TxzId = get_player_txz_id(PlayerId),
	BestLv = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV),
	{PropList, AwardStr} =
		case Type of
			?type_silver ->
				?ASSERT(Lv =< BestLv, ?ERROR_NOT_AUTHORITY),
				{get_cfg_tongxingzheng_upgrade_reward1_list(TxzId, Lv), mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_SILVER_AWARD_STR)};
			?type_diamond ->
				?ASSERT(Lv =< BestLv, ?ERROR_NOT_AUTHORITY),
				?ASSERT(mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_IS_BUY) =:= 1, ?ERROR_FAIL),
				{get_cfg_tongxingzheng_upgrade_reward2_list(TxzId, Lv), mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_DIAMOND_AWARD_STR)};
			?type_extra_box ->
				?ASSERT(mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXTRA_BOX_NUM) >= 0, ?ERROR_NOT_AUTHORITY),
				{get_cfg_tongxingzheng_max_level_item_list(TxzId), empty}
		end,
	?ASSERT(PropList /= [], ?ERROR_NOT_EXISTS),
	?ASSERT(AwardStr =:= empty orelse check_is_collect(Lv, AwardStr) =:= false, ?ERROR_ALREADY_GET),
	Tran =
		fun() ->
			case Type of
				?type_silver ->
					mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_SILVER_AWARD_STR, trans_reward_str(Lv, AwardStr));
				?type_diamond ->
					mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_DIAMOND_AWARD_STR, trans_reward_str(Lv, AwardStr));
				?type_extra_box ->
					mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXTRA_BOX_NUM, -1)
			end,
			GivePropList = mod_award:give(PlayerId, PropList, ?LOG_TYPE_TXZ_LEVEL_AWARD),
			{ok, GivePropList}
		end,
	db:do(Tran).

%% 购买等级
purchase_level(PlayerId) ->
	TxzId = get_player_txz_id(PlayerId),
	CostPropList = get_cfg_tongxingzheng_buy_level_cost(TxzId),
	mod_prop:assert_prop_num(PlayerId, CostPropList),
	?ASSERT(mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV) < ?txz_max_level(TxzId), ?ERROR_NOT_AUTHORITY),
	Tran =
		fun() ->
			mod_prop:decrease_player_prop(PlayerId, CostPropList, ?LOG_TYPE_TXZ_PURCHASE_LEVEL),
			mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV),
			mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXP, 0),
			mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_TONGXINGZHENG_LVL_BUY_COUNT),
			api_tongxingzheng:notice_level_reward_data(PlayerId)
		end,
	db:do(Tran),
	ok.

%% 购买钻石通行证
purchase_unlock(PlayerId, Type) ->
	TxzId = get_player_txz_id(PlayerId),
	CostPropList =
		case Type of
			?buy_ordinary ->
				get_cfg_tongxingzheng_buy1_list(TxzId);
			?buy_advanced ->
				get_cfg_tongxingzheng_buy2_list(TxzId)
		end,
	IsBuy = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_IS_BUY),
	?ASSERT(IsBuy /= 1, already_buy),
	mod_prop:assert_prop_num(PlayerId, CostPropList),
	Tran =
		fun() ->
			case Type of
				?buy_ordinary ->
					skip;
				?buy_advanced ->
					AddLv = get_cfg_tongxingzheng_buy2_add_level(TxzId),
					upgrade_level(add_level, PlayerId, AddLv)
			end,
			mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_IS_BUY, 1),
			mod_prop:decrease_player_prop(PlayerId, CostPropList, ?LOG_TYPE_TXZ_PURCHASE_UNLOCK),
			api_tongxingzheng:notice_level_reward_data(PlayerId),
			mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_TONGXINGZHENG_BUY_COUNT),
			%% 系统广播
			mod_chat:send_system_template_message(?NOTICE_TONGXINGZHENG, [mod_player:get_player_name(PlayerId)])
		end,
	db:do(Tran),
	ok.

%%%===================================================================
%%% Extra Api functions
%%%===================================================================
on_before_enter_game(PlayerId) ->
%%	?INFO("--- on_before_enter_game !!!"),
	refresh_txz_info(PlayerId),
	ok.

on_after_enter_game(PlayerId) ->
%%	?INFO("--- on_after_enter_game !!!"),
	api_tongxingzheng:notice_level_reward_data(PlayerId),
	api_tongxingzheng:notice_task_info(PlayerId),
	ok.

on_date_cut(PlayerId) ->
%%	?INFO("--- on_date_cut !!!"),
	refresh_txz_info(PlayerId),
	api_tongxingzheng:notice_level_reward_data(PlayerId),
	api_tongxingzheng:notice_task_info(PlayerId),
	ok.

upgrade_level(add_level, _PlayerId, 0) -> skip;
upgrade_level(add_level, PlayerId, AddLv) ->
	TxzId = get_player_txz_id(PlayerId),
	MaxLv = ?txz_max_level(TxzId),
	OriLv = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV),
	Func =
		fun(This, Lv, Add) ->
			case Add of
				0 ->
					Lv;
				_ when Lv >= MaxLv ->
					mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXTRA_BOX_NUM),
					This(This, Lv + 1, Add - 1);
				_ ->
					This(This, Lv + 1, Add - 1)
			end
		end,
	NewLv = Func(Func, OriLv, AddLv),
	Trans =
		fun() ->
			mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV, NewLv),
			api_tongxingzheng:notice_level_reward_data(PlayerId)
		end,
	db:do(Trans);

upgrade_level(add_exp, _PlayerId, 0) -> skip;
upgrade_level(add_exp, PlayerId, AddExp) ->
	TxzId = get_player_txz_id(PlayerId),
	OriExp = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXP),
	OriLv = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV),
	Func =
		fun(This, Lv, Exp) ->
			MaxLvNeedExp = get_cfg_tongxingzheng_max_level_need_exp(TxzId),
			case get_cfg_tongxingzheng_upgrade_need_exp(TxzId, Lv) of
				0 when Exp >= MaxLvNeedExp ->  %% 满级
					mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXTRA_BOX_NUM),
					This(This, Lv + 1, Exp - MaxLvNeedExp);
				0 ->
					{Lv, Exp};
				NeedExp when Exp >= NeedExp ->
					This(This, Lv + 1, Exp - NeedExp);
				_ ->
					{Lv, Exp}
			end
		end,
	{NewLv, NewExp} = Func(Func, OriLv, OriExp + AddExp),
	Trans =
		fun() ->
			case OriLv == NewLv of
				true -> skip;
				false ->
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV, NewLv)
			end,
			mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXP, NewExp),
			api_tongxingzheng:notice_level_reward_data(PlayerId)
		end,
	db:do(Trans).

%% 触发任务更新
trigger_task_daily(_PlayerId, [], _AddNum) -> skip;
trigger_task_daily(PlayerId, TriggerTaskList, AddNum) ->
	case get_db_daily_task_info(PlayerId) of
		null -> skip;
		R ->
			#db_tongxingzheng_daily_task{
				task_list = OriTaskListStr
			} = R,
			OriTaskList = util_string:string_to_term(OriTaskListStr),
			FilterTaskIds = [TaskId || {TaskId, _Done, ?AWARD_NONE} <- OriTaskList, lists:member(TaskId, TriggerTaskList)],	%% 筛选未完成的任务
			{NewTaskList, NoticeList} = adjust_foldl(fun trigger_task_daily_one/3, {OriTaskList, []}, FilterTaskIds, AddNum),
			case NoticeList /= [] of
				true ->
					Tran =
						fun() ->
							db:write(
								R#db_tongxingzheng_daily_task{
									task_list = util_string:term_to_string(NewTaskList)
								}
							),
							api_tongxingzheng:notice_update_daily_task_info(PlayerId, NoticeList)
						end,
					db:do(Tran);
				false ->
					skip
			end
	end.

trigger_task_month(_PlayerId, [], _AddNum) -> skip;
trigger_task_month(PlayerId, TriggerTaskList, AddNum) ->
	case get_db_month_task_info(PlayerId) of
		null -> skip;
		R ->
			#db_tongxingzheng_month_task{
				task_list = OriTaskListStr
			} = R,
			OriTaskList = util_string:string_to_term(OriTaskListStr),
			IsBuy = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_IS_BUY),	%% 是否购买
			{_, _, CurDay} = util_time:local_date(),
			FilterTaskIds = [TaskId || {TaskId, _Done, ?AWARD_NONE} <- OriTaskList, get_cfg_tongxingzheng_task_month_unlock_day(TaskId) =< CurDay, lists:member(TaskId, TriggerTaskList)],
			{NewTaskList, NoticeList} = adjust_foldl(fun trigger_task_month_one/3, {OriTaskList, []}, FilterTaskIds, {AddNum, ?TRAN_INT_2_BOOL(IsBuy)}),
			case NoticeList /= [] of
				true ->
					Tran =
						fun() ->
							db:write(
								R#db_tongxingzheng_month_task{
									task_list = util_string:term_to_string(NewTaskList)
								}
							),
							api_tongxingzheng:notice_update_month_task_info(PlayerId, NoticeList)
						end,
					db:do(Tran);
				false ->
					skip
			end
	end.

%% 是否已领取
check_is_collect(Idx, AwardStr) ->
	Len = length(AwardStr),
	?IF(Idx >= Len, false, lists:nth(Idx + 1, AwardStr) =:= $1).

%% 已领取列表
trans_2_already_collect_list(AwardStr) ->
	Len = length(AwardStr),
	lists:filtermap(fun(Idx) ->
		case lists:nth(Idx, AwardStr) of
			$0 -> false;
			$1 -> {true, Idx - 1}
		end
	end, lists:seq(1, Len)).

%% 更新领奖记录
trans_reward_str(Idx, AwardStr) ->
	Len = length(AwardStr),
	case Idx - Len of
		N when N =< 0 ->
			case lists:split(Idx, AwardStr) of
				{A, [_ | B]} -> lists:append(A, [$1 | B]);
				{A, B} -> lists:append(A, [$1 | B])
			end,
			lists:append(A, [$1 | B]);
		N ->
			AwardStr ++ lists:duplicate(N, $0) ++ [$1]
	end.

get_current_txz_id() ->
	NowSec = util_time:timestamp(),
	get_tongxingzheng_id_by_time(NowSec).

%% 玩家通行证id
get_player_txz_id(PlayerId) ->
	mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_TXZ_ID, ?default_txz_id).

%% 月度任务结束时间
get_task_month_end_time(PlayerId) ->
	TxzId = get_player_txz_id(PlayerId),
	case get_cfg_tongxingzheng_time_list(TxzId) of
		undefined -> 0;
		[_, EndDate] ->
			util_time:datetime_to_timestamp({EndDate, [24,0,0]})
	end.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_tongxingzheng_id_by_time(TimeSec) -> get_tongxingzheng_id_by_time(TimeSec, get_cfg_tongxingzheng_id_list()).
get_tongxingzheng_id_by_time(_TimeSec, []) -> ?default_txz_id;
get_tongxingzheng_id_by_time(TimeSec, [{Id} | T]) ->
	#t_tongxingzheng{
		time_list = [StartDate, EndDate]
	} = t_tongxingzheng:get({Id}),
	StartTimeSec = util_time:datetime_to_timestamp({StartDate, [0,0,0]}),
	EndTimeSec = util_time:datetime_to_timestamp({EndDate, [24,0,0]}),
	case TimeSec >= StartTimeSec andalso TimeSec =< EndTimeSec of
		true -> Id;
		false -> get_tongxingzheng_id_by_time(TimeSec, T)
	end.

trigger_task_daily_one(TaskId, {TaskList, NoticeList}, AddNum) ->
	#t_tongxingzheng_daily_task{
		condition_list = ConditionList
	} = get_cfg_tongxingzheng_task_daily_info(TaskId),
	{value, {TaskId, OriDone, ?AWARD_NONE}, RestTaskList} = lists:keytake(TaskId, 1, TaskList),
	[_TaskType, Target] = logic_code:tran_condition_list(ConditionList),
	{NewDone, NewStatus} =
		case OriDone + AddNum >= Target of
			true ->
				{min(OriDone + AddNum, Target), ?AWARD_CAN};
			false ->
				{OriDone + AddNum, ?AWARD_NONE}
		end,
	NewTaskInfo = {TaskId, NewDone, NewStatus},
	{[NewTaskInfo | RestTaskList], [NewTaskInfo | NoticeList]}.

trigger_task_month_one(TaskId, {TaskList, NoticeList}, {AddNum, IsBuy}) ->
	#t_tongxingzheng_task{
		is_need_buy = IsNeedBuy,
		condition_list = ConditionList
	} = get_cfg_tongxingzheng_task_month_info(TaskId),
	IsOk = (IsNeedBuy == 1 andalso IsBuy) orelse IsNeedBuy /= 1,
	{value, {TaskId, OriDone, ?AWARD_NONE}, RestTaskList} = lists:keytake(TaskId, 1, TaskList),
	case logic_code:tran_condition_list(ConditionList) of
		[_TaskType, Target] when IsOk ->
			{NewDone, NewStatus} =
				case OriDone + AddNum >= Target of
					true ->
						{min(OriDone + AddNum, Target), ?AWARD_CAN};
					false ->
						{OriDone + AddNum, ?AWARD_NONE}
				end,
			NewTaskInfo = {TaskId, NewDone, NewStatus},
			{[NewTaskInfo | RestTaskList], [NewTaskInfo | NoticeList]};
		_ ->
			{TaskList, NoticeList}
	end.

refresh_txz_info(PlayerId) ->
	PlayerTxzId = get_player_txz_id(PlayerId),
	CurTxzId = get_current_txz_id(),
	case PlayerTxzId /= CurTxzId of
		false -> skip;
		true when PlayerTxzId =:= ?default_txz_id ->
			refresh_db_month_task_info(PlayerId),
			mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_ID, CurTxzId);
		true ->
			Tran =
				fun() ->
					%% 收集未领取奖励
					BestLv = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV),
					IsBuy = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_IS_BUY),
					BoxNum = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXTRA_BOX_NUM),
					SilverAwardStr = mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_SILVER_AWARD_STR),
					DiamondAwardStr = mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_DIAMOND_AWARD_STR),

					OneBoxRewards = get_cfg_tongxingzheng_max_level_item_list(PlayerTxzId),
					BoxRewards = mod_prop:rate_prop(OneBoxRewards, BoxNum),

					Func =
						fun(Lv, Acc, {AlreadyCollectList, GetRewardsFunc, IsUnlock}) ->
							case lists:member(Lv, AlreadyCollectList) of
								false when IsUnlock ->
									Prop = GetRewardsFunc(PlayerTxzId, Lv),
									case Prop of
										[] -> Acc;
										_ -> [mod_prop:tran_prop(Prop) | Acc]
									end;
								_ ->
									Acc
							end
						end,
					SilverRewards = adjust_foldl(Func, [], lists:seq(0, min(BestLv, ?txz_max_level(PlayerTxzId))), {trans_2_already_collect_list(SilverAwardStr), fun get_cfg_tongxingzheng_upgrade_reward1_list/2, true}),
					DiamondRewards = adjust_foldl(Func, [], lists:seq(0, min(BestLv, ?txz_max_level(PlayerTxzId))), {trans_2_already_collect_list(DiamondAwardStr), fun get_cfg_tongxingzheng_upgrade_reward2_list/2, ?TRAN_INT_2_BOOL(IsBuy)}),

					%% 未领取奖励通过邮件发放
					AwardList = mod_prop:merge_prop_list(lists:flatten(BoxRewards ++ SilverRewards ++ DiamondRewards)),
					case AwardList of
						[] -> skip;
						_ ->
							?DEBUG("~p 通行证邮件奖励 ~p, BestLv ~p, SilverRewards ~w, DiamondRewards ~w, BoxRewards ~w", [PlayerId, AwardList, BestLv, SilverRewards, DiamondRewards, BoxRewards]),
							mod_mail:add_mail_item_list(PlayerId, ?MAIL_TONGXINGZHENG_MAIL, AwardList, ?LOG_TYPE_TXZ_LEVEL_AWARD)
					end,

					%% 重置数据
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXP, 0),
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_BEST_LV, 0),
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_IS_BUY, 0),
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_EXTRA_BOX_NUM, 0),
					mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_SILVER_AWARD_STR, ""),
					mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_DIAMOND_AWARD_STR, ""),
					mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_ID, CurTxzId),

					%% 月度任务更新
					refresh_db_month_task_info(PlayerId)
				end,
			db:do(Tran)
	end,
	LastDate = mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_LAST_DATE),
	NowDate = util_time:timestamp_to_datestr(util_time:timestamp()),
	case LastDate of
		NowDate -> skip;
		_ ->
			%% 刷新每日任务
			refresh_db_daily_task_info(PlayerId),
			mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_TXZ_LAST_DATE, NowDate)
	end,
	ok.

%%%%
%%dec_2_bin(Val) -> integer_to_list(Val, 2).      % 十进制转二进制
%%bin_2_dec(Val) -> list_to_integer(Val, 2).      % 二进制转十进制

adjust_foldl(F, Acc, [Hd | Tail], Params) ->
	NewAcc = F(Hd, Acc, Params),
	adjust_foldl(F, NewAcc, Tail, Params);
adjust_foldl(F, Acc, [], _Params) when is_function(F, 3) -> Acc.

%%%===================================================================
%%% database functions
%%%===================================================================
refresh_db_daily_task_info(PlayerId) ->
	Tran =
		fun() ->
			R =
				case get_db_daily_task_info(PlayerId) of
					null -> #db_tongxingzheng_daily_task{};
					R0 -> R0
				end,
			db:write(
				R#db_tongxingzheng_daily_task{
					player_id = PlayerId,
					task_list = get_cfg_tongxingzheng_task_daily_list()
				}
			)
		end,
	db:do(Tran).

refresh_db_month_task_info(PlayerId) ->
	Tran =
		fun() ->
			R =
				case get_db_month_task_info(PlayerId) of
					null -> #db_tongxingzheng_month_task{};
					R0 -> R0
				end,
			db:write(
				R#db_tongxingzheng_month_task{
					player_id = PlayerId,
					task_list = get_cfg_tongxingzheng_task_month_list()
				}
			)
		end,
	db:do(Tran).

get_db_daily_task_info(PlayerId) ->
	 db:read(#key_tongxingzheng_daily_task{player_id = PlayerId}).

get_db_daily_task_list(PlayerId) ->
	R = get_db_daily_task_info(PlayerId),
	util_string:string_to_term(R#db_tongxingzheng_daily_task.task_list).

get_db_month_task_info(PlayerId) ->
	db:read(#key_tongxingzheng_month_task{player_id = PlayerId}).

get_db_month_task_list(PlayerId) ->
	R = get_db_month_task_info(PlayerId),
	util_string:string_to_term(R#db_tongxingzheng_month_task.task_list).

%%%===================================================================
%%% config functions
%%%===================================================================
%% ### 通行证配置 ###########
get_cfg_tongxingzheng_info(Id) -> t_tongxingzheng:assert_get({Id}).

get_cfg_tongxingzheng_id_list() -> t_tongxingzheng:get_keys().

get_cfg_tongxingzheng_max_level_need_exp(Id) ->
	R = get_cfg_tongxingzheng_info(Id),
	R#t_tongxingzheng.max_level_exp.

get_cfg_tongxingzheng_buy_level_cost(Id) ->
	R = get_cfg_tongxingzheng_info(Id),
	R#t_tongxingzheng.buy_level_list.

get_cfg_tongxingzheng_time_list(?default_txz_id) -> undefined;
get_cfg_tongxingzheng_time_list(Id) ->
	R = get_cfg_tongxingzheng_info(Id),
	R#t_tongxingzheng.time_list.

get_cfg_tongxingzheng_max_level_item_list(Id) ->
	R = get_cfg_tongxingzheng_info(Id),
	R#t_tongxingzheng.max_level_item_list.

get_cfg_tongxingzheng_buy1_list(Id) ->
	R = get_cfg_tongxingzheng_info(Id),
	R#t_tongxingzheng.buy1_list.

get_cfg_tongxingzheng_buy2_list(Id) ->
	R = get_cfg_tongxingzheng_info(Id),
	R#t_tongxingzheng.buy2_list.

get_cfg_tongxingzheng_buy2_add_level(Id) ->
	R = get_cfg_tongxingzheng_info(Id),
	R#t_tongxingzheng.buy2_add_level.

get_cfg_tongxingzheng_task_type(?default_txz_id) -> undefined;
get_cfg_tongxingzheng_task_type(Id) ->
	R = t_tongxingzheng:get({Id}),
	R#t_tongxingzheng.task_type.

%% ### 通行证等级配置 #######
get_cfg_tongxingzheng_level_info(Id, Lv) ->
	t_tongxingzheng_level:assert_get({Id, Lv}).

get_cfg_tongxingzheng_upgrade_need_exp(Id, Lv) ->
	R = t_tongxingzheng_level:get({Id, Lv}),
	?IF(is_record(R, t_tongxingzheng_level), R#t_tongxingzheng_level.need_exp, 0).

get_cfg_tongxingzheng_upgrade_reward1_list(Id, Lv) ->
	R = get_cfg_tongxingzheng_level_info(Id, Lv),
	R#t_tongxingzheng_level.reward1_list.

get_cfg_tongxingzheng_upgrade_reward2_list(Id, Lv) ->
	R = get_cfg_tongxingzheng_level_info(Id, Lv),
	R#t_tongxingzheng_level.reward2_list.

%% ### 每日任务配置 #########
get_cfg_tongxingzheng_task_daily_list() ->
	TaskList =
		case get_current_txz_id() of
			?default_txz_id -> [];
			_ ->
				List = [{rand:uniform(get_cfg_tongxingzheng_task_daily_weight(Id)), Id} || {Id} <- t_tongxingzheng_daily_task:get_keys()],
				SubList = lists:sublist(util_list:rkeysort(1, List), 2),
				[{Id, 0, ?AWARD_NONE} || {_, Id} <- SubList]
		end,
	util_string:term_to_string(TaskList).

get_cfg_tongxingzheng_task_daily_info(TaskId) -> t_tongxingzheng_daily_task:assert_get({TaskId}).

get_cfg_tongxingzheng_task_daily_reward_list(TaskId) ->
	R = get_cfg_tongxingzheng_task_daily_info(TaskId),
	R#t_tongxingzheng_daily_task.reward_list.

get_cfg_tongxingzheng_task_daily_weight(TaskId) ->
	R = get_cfg_tongxingzheng_task_daily_info(TaskId),
	R#t_tongxingzheng_daily_task.weights.

%% ### 月度任务配置 ##########
get_cfg_tongxingzheng_task_month_list() ->
	TaskList =
		case get_current_txz_id() of
			?default_txz_id -> [];
			TxzId ->
				Type = get_cfg_tongxingzheng_task_type(TxzId),
				MaxDay = util_time:get_month_days(),
				Func =
					fun(Day) ->
						logic_get_tongxingzheng_month_tasks_by_type_and_day:get({Type, Day})
					end,
				NewTaskIds = lists:concat(lists:map(Func, lists:seq(1, MaxDay))),
				[{TaskId, 0, ?AWARD_NONE} || TaskId <- NewTaskIds]
		end,
	util_string:term_to_string(TaskList).

get_cfg_tongxingzheng_task_month_info(TaskId) -> t_tongxingzheng_task:assert_get({TaskId}).

get_cfg_tongxingzheng_task_month_reward_list(TaskId) ->
	R = get_cfg_tongxingzheng_task_month_info(TaskId),
	R#t_tongxingzheng_task.reward_list.

get_cfg_tongxingzheng_task_month_unlock_day(TaskId) ->
	R = get_cfg_tongxingzheng_task_month_info(TaskId),
	R#t_tongxingzheng_task.day.