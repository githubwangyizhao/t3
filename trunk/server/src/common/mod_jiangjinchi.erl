%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		奖金池
%%% @end
%%% Created : 11. 6月 2021 15:45
%%%-------------------------------------------------------------------
-module(mod_jiangjinchi).
-author("yizhao.wang").

-include("common.hrl").
-include("p_enum.hrl").
-include("error.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").

%% api
-export([do_draw/2, do_reward_double/2, do_result/2, get_pool_info/2]).
%% extra api
-export([general_atk/3,
	after_enter_scene/2,
	before_leave_game/1,
	activate_fun/2]).

-define(state_close, -1).	% 功能已关闭
-define(state_none, 0).		% 抽奖条件未满足
-define(state_draw, 1).		% 抽奖阶段
-define(state_doubled, 2).	% 翻倍阶段

%% ====================================================================
%% Client Api functions
%% ====================================================================
%% 抽奖
do_draw(PlayerId, SceneId) ->
	?ASSERT(get_t_jiangjinchi_scene_info(SceneId) /= null, not_open),
	?ASSERT(mod_function:is_open(PlayerId, ?FUNCTION_JIANGJINCHI_SYS) /= null, not_open),

	DbPlayerJJC = get_db_player_jjc_info(PlayerId, SceneId),
	#db_player_jiangjinchi{
		state = State,
		atk_cost = AtkCostTotal,
		doubled_times = OriDoubledTimes
	} = DbPlayerJJC,
	NewDoubledTimes = OriDoubledTimes + 1,

	?ASSERT(State /= ?state_doubled, already_draw),
	?ASSERT(State == ?state_draw, error_state),

	AwardWeightList = assert_get_t_jiangjinchi_scene_reward_list(SceneId),
	WeightList = [Weight || [_, _, Weight] <- AwardWeightList],
	LuckIdx = util_random:get_rand_idx(WeightList),
	{AwardNum, MissedNumList} =
		lists:foldl(fun(Idx, {A, Acc}) ->
			[Min, Max, _] = lists:nth(Idx, AwardWeightList),
			MinNum = floor(AtkCostTotal * Min / 200000),
			MaxNum = floor(AtkCostTotal * Max / 200000),
			Rand = rand:uniform(MaxNum - MinNum + 1) + MinNum - 1,
			case Idx == LuckIdx of
				true -> {Rand, Acc};
				false -> {A, [Rand | Acc]}
			end
		end, {0, []}, lists:seq(1, length(AwardWeightList))),
	
	IsCanDoubled = is_can_doubled(PlayerId, NewDoubledTimes),
	NextDoubledAwardNum =
		case IsCanDoubled of
			true -> AwardNum * get_t_jiangjinchi_times_multi_rate(NewDoubledTimes);
			false -> 0
		end,
	Tran =
		fun() ->
			db:write(DbPlayerJJC#db_player_jiangjinchi{
				state = ?state_doubled,
				atk_cost = 0,
				atk_times = 0,
				award_num = AwardNum,
				init_award_num = AwardNum
			}),
			mod_conditions:add_conditions(PlayerId, {?CON_ENUM_JIANGJINCHI_COUNT, ?CONDITIONS_VALUE_ADD, 1}),
			api_jiangjinchi:notice_info(PlayerId, SceneId, ?state_doubled, 0),
			{ok, AwardNum, util_list:shuffle(MissedNumList), IsCanDoubled, NextDoubledAwardNum, NewDoubledTimes}
		end,
	db:do(Tran).

%% 翻倍
do_reward_double(PlayerId, SceneId) ->
	CfgSceneInfo = get_t_jiangjinchi_scene_info(SceneId),
	?ASSERT(CfgSceneInfo /= null, not_open),
	?ASSERT(mod_function:is_open(PlayerId, ?FUNCTION_JIANGJINCHI_SYS) /= null, not_open),

	DbPlayerJJC = get_db_player_jjc_info(PlayerId, SceneId),
	#db_player_jiangjinchi{
		state = State,
		init_award_num = InitAwardNum,
		doubled_times = OriDoubleTimes,
		award_num = OriAwardNum
	} = DbPlayerJJC,
	NewDoubledTimes = OriDoubleTimes + 1,

	?ASSERT(State == ?state_doubled, error_state),
	?ASSERT(is_can_doubled(PlayerId, NewDoubledTimes), not_chance),

	case check_doubled_success(NewDoubledTimes) of
		false ->	%% 翻倍失败
			Tran =
				fun() ->
					reset_db_player_jjc_info(DbPlayerJJC, State),
					update_db_pool(SceneId, InitAwardNum)		%% 玩家奖励归入总奖池
				end,
			Result = ?P_FAIL, NewAwardNum = 0, ExtraAwardNum = 0, IsCanDoubled = false, NextDoubledAwardNum = 0;
		true ->
			NewAwardNum = OriAwardNum * get_t_jiangjinchi_times_multi_rate(NewDoubledTimes),
			ExtraAwardNum =
				case is_can_divide_pool(PlayerId, SceneId, InitAwardNum, NewDoubledTimes) of
					false -> 0;
					true ->
						{ok, Pool} = get_pool_info(PlayerId, SceneId),
						floor(Pool * get_jiangjinchi_extra_award_rate_by_award(SceneId, NewAwardNum) / 10000)
				end,
			IsCanDoubled = is_can_doubled(PlayerId, NewDoubledTimes + 1),
			NextDoubledAwardNum =
				case IsCanDoubled of
					true -> NewAwardNum * get_t_jiangjinchi_times_multi_rate(NewDoubledTimes + 1);
					false -> 0
				end,
			Tran =
				fun() ->
					db:write(DbPlayerJJC#db_player_jiangjinchi{
						award_num = NewAwardNum,
						extra_award_num = ExtraAwardNum,
						doubled_times = NewDoubledTimes,
						change_time = util_time:timestamp()
					})
				end,
			Result = ?P_SUCCESS
	end,
	db:do(Tran),
	{Result, NewAwardNum, ExtraAwardNum, IsCanDoubled, NextDoubledAwardNum, NewDoubledTimes}.

%% 结算
do_result(PlayerId, SceneId) ->
	CfgSceneInfo = get_t_jiangjinchi_scene_info(SceneId),
	?ASSERT(CfgSceneInfo /= null, not_open),
	?ASSERT(mod_function:is_open(PlayerId, ?FUNCTION_JIANGJINCHI_SYS) /= null, not_open),

	DbPlayerJJC = get_db_player_jjc_info(PlayerId, SceneId),
	#db_player_jiangjinchi{
		state = State,
		award_num = AwardNum,
		extra_award_num = ExtraAwardNum,
		atk_times = AtkTimes
	} = DbPlayerJJC,
	?ASSERT(State == ?state_doubled, error_state),

	Tran =
		fun() ->
			NewState = ?IF(AtkTimes >= assert_get_t_jiangjinchi_scene_need_times(SceneId), ?state_draw, ?state_none),
			ItemId = assert_get_t_jiangjinchi_scene_award_item_id(SceneId),
			reset_db_player_jjc_info(DbPlayerJJC, NewState),
			update_db_pool(SceneId, -ExtraAwardNum),
			api_jiangjinchi:notice_info(PlayerId, SceneId, NewState, AtkTimes),
			mod_award:give(PlayerId, [{ItemId, AwardNum + ExtraAwardNum}], ?LOG_TYPE_JIANGJINCHI_REWARD)
		end,
	db:do(Tran),
	{ok, AwardNum, ExtraAwardNum}.

%% 奖池信息
get_pool_info(_PlayerId, SceneId) ->
	case get_t_jiangjinchi_scene_info(SceneId) of
		null -> {ok, 0};
		R when is_record(R, t_jiangjinchi_scene) ->
			{ok, (get_db_jjc_info(SceneId))#db_jiangjinchi.pool}
	end.

%%%===================================================================
%%% Extra Api functions
%%%===================================================================
%% 初始化功能数据
activate_fun(PlayerId, SceneInitList) ->
%%	?INFO("--- activate_fun !!!"),
	Tran =
		fun() ->
			[begin
				 NeedActTimes = assert_get_t_jiangjinchi_scene_need_times(SceneId),
				 State = ?IF(InitActTimes >= NeedActTimes, ?state_draw, ?state_none),
				 DbPlayerJJC = get_db_player_jjc_info(PlayerId, SceneId),
				 db:write(DbPlayerJJC#db_player_jiangjinchi{
					 atk_cost = InitActCost,
					 atk_times = InitActTimes,
					 state = State
				 }),
				 api_jiangjinchi:notice_info(PlayerId, SceneId, State, InitActTimes)
			 end
			|| [SceneId, InitActTimes, InitActCost] <- SceneInitList]
		end,
	db:do(Tran).

%% 普攻
general_atk(PlayerId, SceneId, AtkCost) ->
	IsPlayerFuncOpen = mod_function:is_open(PlayerId, ?FUNCTION_JIANGJINCHI_SYS),
	case get_t_jiangjinchi_scene_info(SceneId) of
		null ->
			skip;
		R when IsPlayerFuncOpen ->
			DbPlayerJJC = get_db_player_jjc_info(PlayerId, SceneId),
			#db_player_jiangjinchi{
				state = OriState,
				atk_cost = OriAtkCost,
				atk_times = OriAtkTimes
			} = DbPlayerJJC,
			Tran =
				fun() ->
					#t_jiangjinchi_scene{need_times = NeedAckTimes} = R,
					NewAtkTimes = OriAtkTimes + 1,
					NewState =
						case NewAtkTimes >= NeedAckTimes of
							false -> ?IF(OriState == ?state_none, ?state_none, OriState);
							true -> ?IF(OriState == ?state_none, ?state_draw, OriState)
						end,
					api_jiangjinchi:notice_info(PlayerId, SceneId, NewState, NewAtkTimes),
					db:write(DbPlayerJJC#db_player_jiangjinchi{
						state = NewState,
						atk_cost = OriAtkCost + AtkCost,
						atk_times = NewAtkTimes
					})
				end,
			db:do(Tran);
		_ ->
			skip
	end,
	ok.

%% 进场景
after_enter_scene(PlayerId, SceneId) ->
%%	?INFO("--- after_enter_scene !!!"),
	IsPlayerFuncOpen = mod_function:is_open(PlayerId, ?FUNCTION_JIANGJINCHI_SYS),
	case get_t_jiangjinchi_scene_info(SceneId) of
		null ->
			api_jiangjinchi:notice_info(PlayerId, SceneId, ?state_close, 0);
		_ when IsPlayerFuncOpen == false ->
			api_jiangjinchi:notice_info(PlayerId, SceneId, ?state_close, 0);
		R ->
			DbPlayerJJC = get_db_player_jjc_info(PlayerId, SceneId),
			#db_player_jiangjinchi{
				state = OriState,
				atk_times = AtkTimes
			} = DbPlayerJJC,

			#t_jiangjinchi_scene{need_times = NeedAckTimes} = R,
			NewState = ?IF(AtkTimes >= NeedAckTimes, ?state_draw, ?state_none),		%% 重新判断下状态，避免人为改表造成状态不一致
			case OriState =:= NewState of
				true ->
					skip;
				false ->
					db:do(fun() ->
						reset_db_player_jjc_info(DbPlayerJJC, NewState)
					end)
			end,
			api_jiangjinchi:notice_info(PlayerId, SceneId, NewState, AtkTimes)
	end,
	ok.

%% 未结算的奖励自动结算
before_leave_game(PlayerId) ->
%%	?INFO("--- before_leave_game !!!"),
	SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
	case get_t_jiangjinchi_scene_info(SceneId) of
		null -> skip;
		_R ->
			IsSceneOpen = get_t_jiangjinchi_scene_info(SceneId) /= null,
			DbPlayerJJC = get_db_player_jjc_info(PlayerId, SceneId),
			#db_player_jiangjinchi{
				state = State,
				award_num = AwardNum,
				extra_award_num = ExtraAwardNum,
				atk_times = AtkTimes
			} = DbPlayerJJC,
			case State of
				?state_none -> skip;
				?state_draw -> skip;
				_ when not IsSceneOpen -> skip;
				_ ->
					Tran =
						fun() ->
							case AwardNum + ExtraAwardNum of
								Num when Num > 0 ->
									update_db_pool(SceneId, -ExtraAwardNum),
									ItemId = assert_get_t_jiangjinchi_scene_award_item_id(SceneId),
									mod_award:give(PlayerId, [{ItemId, Num}], ?LOG_TYPE_JIANGJINCHI_REWARD);
								_ ->
									skip
							end,
							NewState = ?IF(AtkTimes >= assert_get_t_jiangjinchi_scene_need_times(SceneId), ?state_draw, ?state_none),
							reset_db_player_jjc_info(DbPlayerJJC, NewState)
						end,
					db:do(Tran)

			end
	end,
	ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_jiangjinchi_extra_award_rate_by_award(SceneId, AwardNum) ->
	case t_jiangjinchi_award@group_compare:get(SceneId, AwardNum) of
		R when is_record(R, t_jiangjinchi_award) ->
			R#t_jiangjinchi_award.award_per;
		_ -> 0
	end.

%% 是否可以翻倍
is_can_doubled(PlayerId, DoubledTimes) ->
	case get_t_jiangjinchi_times_info(DoubledTimes) of
		null -> false;
		R ->
			#t_jiangjinchi_time_pro{
				need_vip = NeedVipLv
			} = R,
			PlayerVipLv = mod_vip:get_vip_level(PlayerId),
			case PlayerVipLv >= NeedVipLv of
				true -> true;
				false -> false
			end
	end.

%% 是否瓜分奖池
is_can_divide_pool(PlayerId, SceneId, InitAwardNum, DoubledTimes) ->
	case get_t_jiangjinchi_scene_info(SceneId) of
		null -> false;
		R ->
			#t_jiangjinchi_scene{
				vip_limit = NeedVipLv,
				limit_init = LimitInit
			} = R,
			PlayerVipLv = mod_vip:get_vip_level(PlayerId),
			PlayerVipLv >= NeedVipLv andalso InitAwardNum >= LimitInit andalso get_t_jiangjinchi_times_is_divide_pool(DoubledTimes) =:= ?TRUE
	end.

%% 翻倍是否成功
check_doubled_success(DoubledTimes) ->
	Rate =
		case get_t_jiangjinchi_times_info(DoubledTimes) of
			null -> 0;
			R -> R#t_jiangjinchi_time_pro.success_pro
		end,
	rand:uniform(10000) =< Rate.	%% 万分比概率

%%%===================================================================
%%% database functions
%%%===================================================================
get_db_jjc_info(SceneId) ->
	case db:read(#key_jiangjinchi{scene_id = SceneId}) of
		R when is_record(R, db_jiangjinchi) -> R;
		null ->
			#db_jiangjinchi{scene_id = SceneId, pool = assert_get_t_jiangjinchi_scene_init_pool(SceneId)}		%% 初始奖池
	end.

%% 更新奖池
update_db_pool(_SceneId, 0) -> skip;
update_db_pool(SceneId, Change) ->
	case get_t_jiangjinchi_scene_info(SceneId) of
		null -> skip;
		_R ->
			DbJJCRec = get_db_jjc_info(SceneId),
			#db_jiangjinchi{
				pool = OriPool
			} = DbJJCRec,
			NewPool =
				case OriPool + Change of
					N when N =< 0 -> assert_get_t_jiangjinchi_scene_init_pool(SceneId);
					N -> N
				end,
			Tran =
				fun() ->
					db:write(DbJJCRec#db_jiangjinchi{
						pool = NewPool,
						change_time = util_time:timestamp()
					})
				end,
			db:do(Tran)
	end.

get_db_player_jjc_info(PlayerId, SceneId) ->
	case db:read(#key_player_jiangjinchi{player_id = PlayerId, scene_id = SceneId}) of
		null -> #db_player_jiangjinchi{player_id = PlayerId, scene_id = SceneId};
		R when is_record(R, db_player_jiangjinchi) -> R
	end.

reset_db_player_jjc_info(DbPlayerJJC, NewState) ->
	db:write(DbPlayerJJC#db_player_jiangjinchi{
		init_award_num = 0,
		award_num = 0,
		extra_award_num = 0,
		doubled_times = 0,
		state = NewState,
		change_time = util_time:timestamp()
	}).

%%%===================================================================
%%% config functions
%%%===================================================================
%% ### 翻倍次数表 ###########
get_t_jiangjinchi_times_info(Cnt) -> t_jiangjinchi_time_pro:get({Cnt}).
get_t_jiangjinchi_times_multi_rate(Cnt) ->
	R = get_t_jiangjinchi_times_info(Cnt),
	?IF(is_record(R, t_jiangjinchi_time_pro), R#t_jiangjinchi_time_pro.multi_time, 0).
get_t_jiangjinchi_times_is_divide_pool(Cnt) ->
	R = get_t_jiangjinchi_times_info(Cnt),
	?IF(is_record(R, t_jiangjinchi_time_pro), R#t_jiangjinchi_time_pro.jiangchi_isopen, ?FALSE).

%% ### 奖金池场景配置表 ###########
get_t_jiangjinchi_scene_info(SceneId) -> t_jiangjinchi_scene:get({SceneId}).
assert_get_t_jiangjinchi_scene_info(SceneId) -> t_jiangjinchi_scene:assert_get({SceneId}).
assert_get_t_jiangjinchi_scene_reward_list(SceneId) ->
	R = assert_get_t_jiangjinchi_scene_info(SceneId),
	R#t_jiangjinchi_scene.reward_list.
assert_get_t_jiangjinchi_scene_init_pool(SceneId) ->
	R = assert_get_t_jiangjinchi_scene_info(SceneId),
	R#t_jiangjinchi_scene.init_award.
assert_get_t_jiangjinchi_scene_award_item_id(SceneId) ->
	R = assert_get_t_jiangjinchi_scene_info(SceneId),
	R#t_jiangjinchi_scene.itemid.
assert_get_t_jiangjinchi_scene_need_times(SceneId) ->
	R = assert_get_t_jiangjinchi_scene_info(SceneId),
	R#t_jiangjinchi_scene.need_times.