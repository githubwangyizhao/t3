%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		场景事件
%%% @end
%%% Created : 05. 8月 2021 18:28
%%%-------------------------------------------------------------------
-module(mod_scene_event).
-author("yizhao.wang").

-include("common.hrl").
-include("p_enum.hrl").
-include("error.hrl").
-include("scene.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("msg.hrl").

-export([
	do_laba/2,
	do_turntable/2,
	do_money_three/2
]).

-export([
	scene_task_start/2,					% 场景任务事件开启
	scene_task_close/2,					% 场景任务事件关闭
	on_scene_worker_info/2,				% 处理场景进程模块消息
	get_rand_result/2,

	scene_ball_start/3,					% 彩球事件开启
	scene_ball_close/0,					% 彩球事件结算
	handle_kill_ball_monster/2,			% 击杀彩球怪概率掉落彩球
	query_balls_data/1,					% 获取彩球数据

	get_scene_player_base_data/1
]).

-record(?MODULE, {
	%% 摇钱树相关
	three_reward_records = [],			%% 摇钱树奖励记录 [{玩家id, 奖励列表} | ...]

	%% 彩球事件相关
	ball_data = [],						%% 彩球数据 [{玩家id, 已获得列表} | ...]
	ball_max_num = 0,					%% 彩球最大数字
	ball_monster_num = 0,				%% 彩球怪剩余个数
	ball_rewards = [],					%% 彩球大奖奖励
	temp_x_y_list = [],					%% 怪物出生位置临时表

	robots_map = #{}					%% 机器人信息映射
}).

%% ----------------------------------
%% @doc 	拉霸请求
%% @throws 	none
%% @end
%% ----------------------------------
do_laba(PlayerId, SceneId) ->
	SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
	?ASSERT(SceneId /= 0 andalso SceneWorker /= null, ?P_FAILURE),
	[SceneId, LaBaType, ItemId, CostItemNum] = getCfgLabaInfo(SceneId),

	assert_event_is_open(util_time:milli_timestamp(), SceneWorker, ?SCENE_TIME_EVENT_TYPE_LA_BA),
	mod_prop:assert_prop_num(PlayerId, ItemId, CostItemNum),

	SceneAdjustValue = scene_adjust:get_scene_adjust_rate_value(SceneId),
	WeightList = logic_get_function_monster_laba_weights_list:assert_get(LaBaType),
	[Id, Rate, Rewards] = get_rand_result(WeightList, SceneAdjustValue),
	Num =
		case Rewards of
			[] -> 0;
			[_, ThisNum] -> ThisNum
		end,
	AwardNum = floor(CostItemNum * Rate / 10000) + Num,

	Tran =
		fun() ->
			mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_SLOTS_PLAYER_PARTICIPATION_COUNT),
			mod_prop:decrease_player_prop(PlayerId, ItemId, CostItemNum, ?LOG_TYPE_FUNCTION_MONSTER_LABA),
			mod_award:give(PlayerId, [{ItemId, AwardNum}], ?LOG_TYPE_FUNCTION_MONSTER_LABA),
	
            scene_adjust:cast_add_room_pool_value(PlayerId, {ItemId, CostItemNum}),
            scene_adjust:cast_cost_room_pool_value(PlayerId, {ItemId, AwardNum}),
			{ok, Id, [{ItemId, AwardNum}]}
		end,
	db:do(Tran).

%% ----------------------------------
%% @doc 	转盘请求
%% @throws 	none
%% @end
%% ----------------------------------
do_turntable(PlayerId, SceneId) ->
	SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
	?ASSERT(SceneId /= 0 andalso SceneWorker /= null, ?P_FAILURE),
	[SceneId, TurnType, ItemId, CostItemNum] = getCfgTurntableInfo(SceneId),

	assert_event_is_open(util_time:milli_timestamp(), SceneWorker, ?SCENE_TIME_EVENT_TYPE_ZHUAN_PAN),
	mod_prop:assert_prop_num(PlayerId, ItemId, CostItemNum),

	SceneAdjustValue = scene_adjust:get_scene_adjust_rate_value(SceneId),
	WeightList = logic_get_function_monster_zhuanpan_weights_list:assert_get(TurnType),
	[Id, Rate, Rewards] = get_rand_result(WeightList, SceneAdjustValue),
	Num =
		case Rewards of
			[] -> 0;
			[_, ThisNum] -> ThisNum
		end,
	AwardNum = floor(CostItemNum * Rate / 10000) + Num,

	Tran =
		fun() ->
			mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_TURNTABLE_PLAYER_PARTICIPATION_COUNT),
			mod_prop:decrease_player_prop(PlayerId, ItemId, CostItemNum, ?LOG_TYPE_FUNCTION_MONSTER_ZHUANPAN),
			mod_award:give(PlayerId, [{ItemId, AwardNum}], ?LOG_TYPE_FUNCTION_MONSTER_ZHUANPAN),
            scene_adjust:cast_add_room_pool_value(PlayerId, {ItemId, CostItemNum}),
            scene_adjust:cast_cost_room_pool_value(PlayerId, {ItemId, AwardNum}),
			{ok, Id, [{ItemId, AwardNum}]}
		end,
	db:do(Tran).

%% ----------------------------------
%% @doc 	摇钱树请求
%% @throws 	none
%% @end
%% ----------------------------------
do_money_three(PlayerId, SceneId) ->
	SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
	?ASSERT(SceneId /= 0 andalso SceneWorker /= null, ?P_FAILURE),
	case mod_cache:get({scene_worker_event_task, SceneWorker}) of
		#r_event_task{type = 1, stage = 2, id = TaskId} ->	%% 活动开启
			#t_monster_function_task{
				expend_list = ExpendList
			} = t_monster_function_task:assert_get({TaskId}),
			[SceneId, ThreeType, ItemId, CostItemNum] = getCfgMoneyThreeInfo(SceneId, ExpendList),
			mod_prop:assert_prop_num(PlayerId, ItemId, CostItemNum),

			SceneAdjustValue = scene_adjust:get_scene_adjust_rate_value(SceneId),
			WeightList = logic_get_function_monster_task_reward_weights_list:assert_get(ThreeType),
			[Id, Rate, RewardsList] = get_rand_result(WeightList, SceneAdjustValue),

			Tran =
				fun() ->
					GiveRewards0 =
						[begin
							 [TmpItemId, TmpItemNum] = Rewards,
							 AwardNum = floor(CostItemNum * Rate / 10000) + TmpItemNum,
							 {TmpItemId, AwardNum}
						 end || Rewards <- RewardsList],
					GiveRewards = mod_prop:merge_prop_list(GiveRewards0),
					if
						GiveRewards /= [] ->
							scene_adjust:cast_add_room_pool_value(PlayerId, CostItemNum),
							scene_adjust:cast_cost_room_pool_value(PlayerId, GiveRewards),
							mod_award:give(PlayerId, GiveRewards, ?LOG_TYPE_MONEY_THREE),
							SceneWorker ! {notify, {?MODULE, {refresh_money_three_awards, PlayerId, GiveRewards}}};
						true ->
							skip
					end,
					mod_prop:decrease_player_prop(PlayerId, ItemId, CostItemNum, ?LOG_TYPE_MONEY_THREE),
					{ok, Id, GiveRewards}
				end,
			db:do(Tran);
		_ ->
			exit(not_open)
	end.

%% ----------------------------------
%% @doc 	场景任务事件开启（场景进程）
%% @throws 	none
%% @end
%% ----------------------------------
scene_task_start(_TaskType = 1, _Stage) ->	% 摇钱树
	?setModDict(three_reward_records, []);
scene_task_start(_TaskType, _Stage) ->
	noop.

%% ----------------------------------
%% @doc 	场景任务事件关闭（场景进程）
%% @throws 	none
%% @end
%% ----------------------------------
scene_task_close(_TaskType = 1, _Stage = 2) ->	% 摇钱树
	Results = ?getModDict(three_reward_records),
	api_scene_event:notice_three_result_info(Results),
	ok;
scene_task_close(_TaskType, _Stage) ->
	noop.

%% ----------------------------------
%% @doc    	彩球事件开启（场景进程）
%% @throws 	none
%% @end
%% ----------------------------------
scene_ball_start(BallNum, CostRate, #scene_state{scene_id = SceneId}) ->
	#t_scene{
		mana_attack_list = [ItemId, [MinAtkCost | _]]
	} = t_scene:get({SceneId}),

	?setModDict(ball_monster_num, BallNum),      	   				%% 初始化彩球怪数量
	?setModDict(ball_max_num, BallNum),								%% 初始化最大的彩球数字
	?setModDict(ball_data, []),										%% 初始化彩球数据
	?setModDict(ball_rewards, [{ItemId, MinAtkCost * CostRate}]),	%% 大奖奖励
	?setModDict(robots_map, #{}),

	%% 生成怪出生位置列表
	#t_scene{
		new_monster_x_y_list = MonsterXYList
	} = mod_scene:get_t_scene(SceneId),
	[_, _, _, XYList] = util_list:key_find(?SD_MONSTER_FUNCTION_CAIQIU_X_Y_GROUP, 1, MonsterXYList),
	Length = length(XYList),
	AllXYList =
		case Length >= BallNum of
			true ->
				XYList;
			false ->
				lists:merge(lists:duplicate(BallNum div Length + 1, XYList))
		end,
	?setModDict(temp_x_y_list, util_list:shuffle(AllXYList)),

	%% 创建彩球怪
	util:run(
		fun() ->
			[[X, Y] | RestXYList] = ?getModDict(temp_x_y_list),
			?setModDict(temp_x_y_list, RestXYList),
			MonsterId = util_random:get_probability_item(?SD_MONSTER_FUNCTION_CAIQIU_MINSTER_ID_LIST),
			mod_scene_event_manager:send_msg({?MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, mod_scene_event_manager:get_state(), MonsterId, X, Y})
		end,
		BallNum
	),
	ok.

%% ----------------------------------
%% @doc 	彩球事件结算（场景进程）
%% @throws 	none
%% @end
%% ----------------------------------
scene_ball_close() ->
	BallDataList = ?getModDict(ball_data),
	LuckBallId = util_random:random_number(?ITEM_CAIQIU_1, ?ITEM_CAIQIU_1 + ?getModDict(ball_max_num) - 1),

	LuckPlayerId =
		lists:foldl(
			fun({PlayerId, BallIdList}, Acc) ->
				case lists:member(LuckBallId, BallIdList) of
					true -> PlayerId;
					false -> Acc
				end
			end, null, BallDataList
		),
	Rewards = ?getModDict(ball_rewards),
	case LuckPlayerId == null orelse LuckPlayerId < 10000 of
		true ->
			skip;
		false ->
			SceneWorker = self(),
			case mod_obj_player:get_obj_player(LuckPlayerId) of
				%% 玩家在当前场景进程内
				#ets_obj_player{scene_worker = SceneWorker, client_worker = ClientWorker} when is_pid(ClientWorker) ->
					client_worker:apply(ClientWorker, mod_award, give, [LuckPlayerId, Rewards, ?LOG_TYPE_COLOR_BALL_REWARD]);
				%% 掉线或不在当前场景进程内
				_ ->
					mod_mail:add_mail_param_item_list(LuckPlayerId, ?MAIL_LUCKY_BALL, Rewards, [LuckBallId], ?LOG_TYPE_COLOR_BALL_REWARD)
			end
	end,
	api_scene_event:notice_ball_result_info(LuckBallId, LuckPlayerId, Rewards),
	ok.

%% ----------------------------------
%% @doc 	击杀彩球怪概率掉落彩球（场景进程）
%% @throws 	none
%% @end
%% ----------------------------------
handle_kill_ball_monster(AttObjSceneActor, DefObjSceneActor) ->
	#obj_scene_actor{
		obj_id = PlayerId
	} = AttObjSceneActor,

	#obj_scene_actor{
		obj_id = MonsterId,
		x = DefX,
		y = DefY
	} = DefObjSceneActor,

	P = 10000,
	Result = util_random:p(P),
	if
		Result ->	% 掉落一个彩球
			OriBallData = ?getModDict(ball_data),

			ExcludeIdList = lists:merge([L || {_, L} <- OriBallData]),
			AllIdList = lists:seq(?ITEM_CAIQIU_1, ?ITEM_CAIQIU_1 + ?getModDict(ball_max_num) - 1),
			LeftIdList = AllIdList -- ExcludeIdList,
			DropBallId = lists:nth(rand:uniform(length(LeftIdList)), LeftIdList),
			mod_scene_item_manager:drop_item_list(MonsterId, PlayerId, [{DropBallId, 1}], DefX, DefY),
			update_balls_data(PlayerId, DropBallId);
		true ->
			skip
	end,

	case ?incrModDict(ball_monster_num, - 1) =< 0 of
		true -> %% 所有彩球怪打完
			mod_scene_event_manager:send_msg(?MSG_SCENE_LOOP_BALL_FINISHED);
		false ->
			skip
	end,
	ok.

%% ----------------------------------
%% @doc     获取彩球数据
%% @throws 	none
%% @end
%% ----------------------------------
query_balls_data(PlayerId) ->
	SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
	scene_worker:sync_to_scene_worker(SceneWorker, {?MODULE, {get_player_balls_data, PlayerId}}).

%% ----------------------------------
%% @doc 	更新彩球数据
%% @throws 	none
%% @end
%% ----------------------------------
update_balls_data(PlayerId, BallId) ->
	OriBallData = ?getModDict(ball_data),
	case lists:keyfind(PlayerId, 1, OriBallData) of
		false ->
			?setModDict(ball_data, [{PlayerId, [BallId]} | OriBallData]);
		{_, OriIdList} ->
			?setModDict(ball_data, lists:keyreplace(PlayerId, 1, OriBallData, {PlayerId, [BallId | OriIdList]}))
	end,
	try_save_robot_base_data(PlayerId),
	ok.

%% ----------------------------------
%% @doc 	尝试保留机器人基础信息
%% @throws 	none
%% @end
%% ----------------------------------
try_save_robot_base_data(PlayerId) when PlayerId < 10000 ->
	Map = ?getModDict(robots_map),
	case maps:get(PlayerId, Map, null) of
		null ->
			PlayerBaseData = api_player:pack_player_base_data(PlayerId),
			?setModDict(robots_map, maps:put(PlayerId, PlayerBaseData, Map));
		_ ->
			noop
	end;
try_save_robot_base_data(_) -> noop.

%% ----------------------------------
%% @doc 	获取场景玩家基础信息
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_player_base_data(PlayerId) when PlayerId < 10000 ->
	Map = ?getModDict(robots_map),
	case maps:get(PlayerId, Map, null) of
		null ->
			api_player:pack_player_base_data(PlayerId);
		Value ->
			Value
	end;
get_scene_player_base_data(PlayerId) ->
	api_player:pack_player_base_data(PlayerId).

%% ----------------------------------
%% @doc 	处理场景进程模块消息
%% @throws 	none
%% @end
%% ----------------------------------
on_scene_worker_info({refresh_money_three_awards, PlayerId, AddRewards}, _SceneState) ->
	OldResults = ?getModDict(three_reward_records),
	case lists:keytake(PlayerId, 1, OldResults) of
		false ->
			?setModDict(three_reward_records, [{PlayerId, AddRewards} | OldResults]);
		{value, {PlayerId, OldRewards}, RestResults} ->
			?setModDict(three_reward_records, [{PlayerId, mod_prop:merge_prop_list(OldRewards ++ AddRewards)} | RestResults])
	end;
on_scene_worker_info({get_player_balls_data, PlayerId}, _SceneState) ->		%% 获取玩家彩球数据
	case lists:keyfind(PlayerId, 1, ?getModDict(ball_data)) of
		false ->
			{ok, []};
		{_, Data} ->
			{ok, Data}
	end.

%% ----------------------------------
%% @doc 	获取随机奖励结果
%% @throws 	none
%% @end
%% ----------------------------------
get_rand_result(WeightList, SceneAdjustValue) ->
	RndResult = util_random:p(30000-5*SceneAdjustValue/2),
	[Id, RewardRate, Rewards] = util_random:get_probability_item([
		begin
			TmpWeight =
				case RndResult of	%% 按随机结果取不同的权值
					true -> TmpWeight1;
					false -> TmpWeight2
				end,
			{[TmpId, TmpRate, TmpRewards], TmpWeight}
		end
		|| {TmpId, TmpRate, TmpRewards, TmpWeight1, TmpWeight2} <- WeightList
	]),
	[Id, RewardRate, Rewards].

%%%===================================================================
%%% 获取配置
%%%===================================================================
getCfgLabaInfo(SceneId) -> getCfgLabaInfo(SceneId, ?SD_MONSTER_FUNCTION_EVENT_LABA_LIST).
getCfgLabaInfo(SceneId, [[SceneId, _, _, _] = Info | _Rest]) -> Info;
getCfgLabaInfo(SceneId, [_Head | Rest]) -> getCfgLabaInfo(SceneId, Rest).

getCfgTurntableInfo(SceneId) -> getCfgTurntableInfo(SceneId, ?SD_MONSTER_FUNCTION_EVENT_ZHUANPAN_LIST).
getCfgTurntableInfo(SceneId, [[SceneId, _, _, _] = Info | _Rest]) -> Info;
getCfgTurntableInfo(SceneId, [_Head | Rest]) -> getCfgTurntableInfo(SceneId, Rest).

getCfgMoneyThreeInfo(SceneId, [[SceneId, _, _, _] = Info | _Rest]) -> Info;
getCfgMoneyThreeInfo(SceneId, [_Head | Rest]) -> getCfgMoneyThreeInfo(SceneId, Rest).

assert_event_is_open(NowMilSec, SceneWorker, EventType) ->
	EndMilSec = mod_scene_event_manager:get_event_type_end_time(EventType, SceneWorker),
	?ASSERT(NowMilSec =< EndMilSec + 1000, not_open).
