%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		拉霸服务进程逻辑
%%% @end
%%% Created : 11. 11月 2021 10:44
%%%-------------------------------------------------------------------
-module(laba_handle).
-author("yizhao.wang").

-include("common.hrl").
-include("laba.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").

%% API
-export([
	handle_player_join/4,
	handle_player_leave/1,
	handle_update_laba_data/3,

	get_laba_player_count/2,
	get_db_laba_pool/2,

	clear_timeout_player/0
]).

%% ----------------------------------
%% @doc 	清理在拉霸机中超时的玩家
%% @throws 	none
%% @end
%% ----------------------------------
clear_timeout_player() ->
	NowSec = util_time:timestamp(),
	LaBaPlayerDataList = ets:tab2list(?ETS_LABA_PLAYER_DATA),
	lists:foreach(
		fun(#ets_laba_player_data{player_id = PlayerId, time = UpTime}) when NowSec - UpTime >= 60 ->
			%% 超时自动离开拉霸机
			handle_player_leave(PlayerId);
			(_R) ->
				noop
		end,
		LaBaPlayerDataList
	),
	ok.

%% ----------------------------------
%% @doc 	玩家参与拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_join(PlayerId, ClientWorker, LaBaId, CostRate) ->
	NowSec = util_time:timestamp(),
	case get_laba_player_data(PlayerId) of
		null ->
			MonitorRef = erlang:monitor(process, ClientWorker),
			PlayerData = #ets_laba_player_data{
				player_id = PlayerId,
				client_worker = ClientWorker,
				monitor_ref = MonitorRef,
				laba_id = LaBaId,
				cost_rate = CostRate,
				time = NowSec
			},
			%% 玩家进程与玩家id之间的映射
			put(ClientWorker, PlayerId),
			change_laba_player_count(LaBaId, CostRate, 1),
			update_laba_player_data(PlayerData);
		#ets_laba_player_data{laba_id = LaBaId, cost_rate = CostRate} = OriPlayerData ->
			update_laba_player_data(OriPlayerData#ets_laba_player_data{time = NowSec});
		#ets_laba_player_data{laba_id = OriLaBaId, cost_rate = OriCostRate} = OriPlayerData ->
			change_laba_player_count(OriLaBaId, OriCostRate, -1),
			change_laba_player_count(LaBaId, CostRate, 1),
			update_laba_player_data(OriPlayerData#ets_laba_player_data{
				laba_id = LaBaId,
				cost_rate = CostRate,
				time = NowSec
			})
	end.

%% ----------------------------------
%% @doc 	更新拉霸奖池
%% @throws 	none
%% @end
%% ----------------------------------
handle_update_laba_data(LaBaId, CostRate, PoolChangeVal) ->
	update_db_laba_data(LaBaId, CostRate, PoolChangeVal).

%% ----------------------------------
%% @doc 	玩家离开拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_leave(PlayerId) ->
	case get_laba_player_data(PlayerId) of
		null ->
			noop;
		R when is_record(R, ets_laba_player_data) ->
			#ets_laba_player_data{
				laba_id = LaBaId,
				cost_rate = CostRate,
				monitor_ref = MonitorRef
			} = R,
			erlang:demonitor(MonitorRef),
			change_laba_player_count(LaBaId, CostRate, -1),
			delete_laba_player_data(R)
	end.

%% ----------------------------------
%% @doc 	更新玩家参与拉霸数据
%% @throws 	none
%% @end
%% ----------------------------------
update_laba_player_data(PlayerLaBaData) ->
	ets:insert(?ETS_LABA_PLAYER_DATA, PlayerLaBaData).

get_laba_player_data(PlayerId) ->
	case ets:lookup(?ETS_LABA_PLAYER_DATA, PlayerId) of
		[] -> null;
		[R] -> R
	end.

delete_laba_player_data(PlayerLaBaData) ->
	ets:delete_object(?ETS_LABA_PLAYER_DATA, PlayerLaBaData).

%% ----------------------------------
%% @doc 	更新奖池人数
%% @throws 	none
%% @end
%% ----------------------------------
change_laba_player_count(LaBaId, CostRate, ChangeCount) ->
	OriPlayerCount = get_laba_player_count(LaBaId, CostRate),
	ets:insert(?ETS_LABA_DATA, #ets_laba_data{
		key = {LaBaId, CostRate},
		player_count = max(OriPlayerCount + ChangeCount, 0)
	}).

get_laba_player_count(LaBaId, CostRate) ->
	case ets:lookup(?ETS_LABA_DATA, {LaBaId, CostRate}) of
		[] -> 0;
		[R] -> R#ets_laba_data.player_count
	end.

%% ----------------------------------
%% @doc 	更新奖池数据
%% @throws 	none
%% @end
%% ----------------------------------
update_db_laba_data(LaBaId, CostRate, PoolChangeVal) ->
	db:do(
		fun() ->
			DbLaBaData = get_db_laba_data_init(LaBaId, CostRate),
			#db_laba_adjust{
				pool = OriPoolVal
			} = DbLaBaData,
			db:write(DbLaBaData#db_laba_adjust{pool = OriPoolVal + PoolChangeVal})
		end
	).

get_db_laba_data_init(LaBaId, CostRate) ->
	case db:read(#key_laba_adjust{laba_id = LaBaId, cost_rate = CostRate}) of
		null ->
			#db_laba_adjust{
				laba_id = LaBaId,
				cost_rate = CostRate
			};
		R ->
			R
	end.

get_db_laba_pool(LaBaId, CostRate) ->
	R = get_db_laba_data_init(LaBaId, CostRate),
	R#db_laba_adjust.pool.