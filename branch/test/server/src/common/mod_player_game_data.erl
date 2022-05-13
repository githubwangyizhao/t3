%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家游戏数据
%%% @end
%%% Created : 13. 六月 2016 下午 2:38
%%%-------------------------------------------------------------------
-module(mod_player_game_data).

-include("gen/db.hrl").
-include("player_game_data.hrl").
-export([
	get_int_data/2,
get_int_data_default/3,
	get_str_data/2,
	set_int_data/3,
	set_str_data/3,
	get_player_game_data/2,
	incr_int_data/2,
	incr_int_data/3
]).

-export([
	add_player_global_record/4,            %% 全局自增数据处理
	add_1_player_global_value/2,           %% 全局数据 +1 处理
	update_player_global_data/4            %% 更新玩家全局数据信息
]).

%% @doc     全局自增数据处理
add_player_global_record(PlayerId, GlobalId, GlobalCount, MaxCount) ->
	NewGlobalId = add_1_player_global_value(PlayerId, GlobalId),
	Count = update_player_global_data(PlayerId, GlobalCount, add_int_value, 1, false),
	State =
		if
			Count#db_player_game_data.int_data > MaxCount ->
				del;    % 删除最后的一个数据
			true ->
				db:write(Count)
		end,
	{State, NewGlobalId}.

%% 增加玩家全局数据信息 +1
add_1_player_global_value(PlayerId, GlobalId) ->
	PlayerGlobal = update_player_global_data(PlayerId, GlobalId, add_int_value, 1),
	PlayerGlobal#db_player_game_data.int_data.

%% 更新玩家全局数据信息 TranState:是否直接存事务
update_player_global_data(PlayerId, GlobalEnum, Type, Value) ->
	update_player_global_data(PlayerId, GlobalEnum, Type, Value, true).
update_player_global_data(PlayerId, GlobalEnum, Type, Value, TranState) ->
	G = get_player_global_data_init(PlayerId, GlobalEnum),
	PlayerGlobal =
		case Type of
			int_value ->
				G#db_player_game_data{int_data = Value};
			add_int_value ->
				G#db_player_game_data{int_data = G#db_player_game_data.int_data + Value};
			del_int_value ->
				IntValue = G#db_player_game_data.int_data,
				NewValue =
					if
						IntValue > Value ->
							IntValue - Value;
						true ->
							0
					end,
				G#db_player_game_data{int_data = NewValue};
			str_value ->
				G#db_player_game_data{str_data = Value}
		end,
	case TranState of
		true ->
			Tran =
				fun() ->
					db:write(PlayerGlobal)
				end,
			db:do(Tran);
		_ ->
			ok
	end,
	PlayerGlobal.

get_int_data(PlayerId, DataId) ->
	case get_player_game_data(PlayerId, DataId) of
		null ->
			0;
		R ->
			R#db_player_game_data.int_data
	end.

get_int_data_default(PlayerId, DataId, Default) ->
	case get_player_game_data(PlayerId, DataId) of
		null ->
			Default;
		R ->
			R#db_player_game_data.int_data
	end.

get_str_data(PlayerId, DataId) ->
	case get_player_game_data(PlayerId, DataId) of
		null ->
			"";
		R ->
			R#db_player_game_data.str_data
	end.

set_int_data(PlayerId, DataId, IntData) when is_integer(IntData) ->
	Tran =
		fun() ->
			case get_player_game_data(PlayerId, DataId) of
				null ->
					db:write(#db_player_game_data{player_id = PlayerId, data_id = DataId, int_data = IntData});
				R ->
					db:write(R#db_player_game_data{int_data = IntData})
			end
		end,
	db:do(Tran).

set_str_data(PlayerId, DataId, StrData) when is_list(StrData) ->
	Tran =
		fun() ->
			case get_player_game_data(PlayerId, DataId) of
				null ->
					db:write(#db_player_game_data{player_id = PlayerId, data_id = DataId, str_data = StrData});
				R ->
					db:write(R#db_player_game_data{str_data = StrData})
			end
		end,
	db:do(Tran).

incr_int_data(PlayerId, DataId) -> incr_int_data(PlayerId, DataId, 1).
incr_int_data(PlayerId, DataId, IncrData) when is_integer(IncrData) ->
	Tran =
		fun() ->
			case get_player_game_data(PlayerId, DataId) of
				null ->
					db:write(#db_player_game_data{player_id = PlayerId, data_id = DataId, int_data = IncrData});
				R ->
					OriIntData = R#db_player_game_data.int_data,
					db:write(R#db_player_game_data{int_data = OriIntData + IncrData})
			end
		end,
	db:do(Tran).

%% ================================================ 数据操作 ================================================
get_player_game_data(PlayerId, DataId) ->
	db:read(#key_player_game_data{player_id = PlayerId, data_id = DataId}).
get_player_global_data_init(PlayerId, DataId) ->
	case get_player_game_data(PlayerId, DataId) of
		PlayerGame when is_record(PlayerGame, db_player_game_data) ->
			PlayerGame;
		_ ->
			#db_player_game_data{player_id = PlayerId, data_id = DataId}
	end.
