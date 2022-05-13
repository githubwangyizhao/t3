%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 11月 2021 17:19
%%%-------------------------------------------------------------------
-module(mod_room).
-author("yizhao.wang").

-include("common.hrl").
-include("client.hrl").
-include("room.hrl").
-include("player_game_data.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
	% API
	get_room_list/2,
	leave_room_list/1,
	enter_room/3,
	leave_room/1,
	ready/1,
	fight_result/2,
	add_frame_action/2,

	player_leave_room/1,
	try_enter_room_if_exist/1,

	after_room_start/9,
	after_room_fight/3,
	after_room_close/4,
	after_player_ready/3,

	handle_room_info_push/3,
	handle_room_list_change/0
]).

-record(?MODULE, {
	subscribe_flag = false
}).

%% ----------------------------------
%% @doc 	向战区服拉取房间列表数据
%% @throws 	none
%% @end
%% ----------------------------------
handle_pull_room_list({Type}) ->
	{ok, RoomList} = room_manage_srv:get_room_list_by_type(Type),
	mod_cache:update({roomlist, Type}, RoomList),
	RoomList.

%% ----------------------------------
%% @doc 	房间信息变更推送（战区服推给game服）
%% @throws 	none
%% @end
%% ----------------------------------
handle_room_info_push(Type, RoomId, PlayerBaseInfoList) ->
	?ASSERT(mod_server:is_game_server(), handle_must_game_server),
	case mod_cache:get({roomlist, Type}) of
		null -> noop;
		OriRoomList ->
			mod_cache:update({roomlist, Type}, lists:keyreplace(RoomId, 1, OriRoomList, {RoomId, PlayerBaseInfoList}))
	end,
	case ets:select(?ETS_ROOM_SUBSCRIBE, [{#ets_room_subscribe{roomtype = Type, playerid = '$1'}, [], ['$1']}]) of
		[] -> noop;
		SubscribePlayerIdList ->
			lists:foreach(
				fun(SubscribePlayerId) ->
					api_room:notice_room_list_change(SubscribePlayerId, Type, RoomId, PlayerBaseInfoList)
				end,
				SubscribePlayerIdList
			)
	end.

%% ----------------------------------
%% @doc 	房间列表更新推送（战区服推给game服）
%% @throws 	none
%% @end
%% ----------------------------------
handle_room_list_change() ->
	?ASSERT(mod_server:is_game_server(), handle_must_game_server),
	lists:foreach(fun handle_pull_room_list/1, t_eat_monster_battle:get_keys()).

%% ----------------------------------
%% @doc 	获取房间列表信息
%% @throws 	none
%% @end
%% ----------------------------------
get_room_list(PlayerId, Type) ->
	%% 订阅
	subscribe(PlayerId, Type),
	case mod_cache:get({roomlist, Type}) of
		null ->
			handle_pull_room_list({Type});
		RoomList ->
			RoomList
	end.

%% ----------------------------------
%% @doc 	退出房间列表
%% @throws 	none
%% @end
%% ----------------------------------
leave_room_list(PlayerId) ->
	%% 取消订阅
	unSubscribe(PlayerId).

%% ----------------------------------
%% @doc 	进入房间
%% @throws 	none
%% @end
%% ----------------------------------
enter_room(PlayerId, Type, RoomId) ->
	ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
	#ets_obj_player{
		sender_worker = SenderWorker,
		client_worker = ClientWorker,
		room_type = OriRoomType,
		room_id = OriRoomId,
		room_worker = OriRoomWorker
	} = ObjPlayer,
	?ASSERT(OriRoomWorker == null, room_already_started),
	?ASSERT(not (OriRoomType == Type andalso OriRoomId == RoomId), player_already_in_room),
	if
	%% 离开旧房间
		OriRoomType /= 0 andalso OriRoomId /= 0 ->
			Ret = room_manage_srv:leave_room(PlayerId),
			?ASSERT(Ret == ok, Ret);
		true ->
			noop
	end,
	%% 进入新房间
	PlayerBaseInfo = api_player:pack_model_head_figure(PlayerId),
	case room_manage_srv:enter_room(PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker, Type, RoomId) of
		ok ->
			mod_obj_player:update_obj_player(ObjPlayer#ets_obj_player{room_type = Type, room_id = RoomId});
		Other ->
			mod_obj_player:update_obj_player(ObjPlayer#ets_obj_player{room_type = 0, room_id = 0}),
			exit(Other)
	end.

%% ----------------------------------
%% @doc 	主动离开房间
%% @throws 	none
%% @end
%% ----------------------------------
leave_room(PlayerId) ->
	ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
	#ets_obj_player{
		room_type = OriRoomType,
		room_id = OriRoomId
	} = ObjPlayer,
	if
		OriRoomType /= 0 andalso OriRoomId /= 0 ->
			case catch room_manage_srv:leave_room(PlayerId) of
				ok ->
					mod_obj_player:update_obj_player(ObjPlayer#ets_obj_player{room_type = 0, room_id = 0});
				_ ->
					noop
			end;
		true ->
			noop
	end,
	%% 取消订阅
	unSubscribe(PlayerId).

%% ----------------------------------
%% @doc 	房间开始
%% @throws 	none
%% @end
%% ----------------------------------
after_room_start(ClientWorker, RoomWorker, Type, RoomId, Seed, ReadyEndTime, PlayerBaseInfoList, ReadyPlayerIdList, Index) ->
	case self() == ClientWorker of
		true ->
			PlayerId = get(?DICT_PLAYER_ID),
			ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
			mod_obj_player:update_obj_player(
				ObjPlayer#ets_obj_player{
					room_worker = RoomWorker,
					room_type = Type,
					room_id = RoomId
				}
			),
			?INFO("notify ~p room start ===> ~w ", [PlayerId, {Type, RoomId, Seed, ReadyEndTime, PlayerBaseInfoList, ReadyPlayerIdList, Index}]),
			%% 取消订阅
			unSubscribe(PlayerId),
			%% 通知房间开始
			api_room:push_init_room_data(PlayerId, Type, RoomId, Seed, ReadyEndTime, PlayerBaseInfoList, ReadyPlayerIdList, Index);
		false ->
			mod_apply:apply_to_online_player(ClientWorker, mod_room, after_room_start, [ClientWorker, RoomWorker, Type, RoomId, Seed, ReadyEndTime, PlayerBaseInfoList, ReadyPlayerIdList, Index])
	end.

%% ----------------------------------
%% @doc 	房间战斗开始
%% @throws 	none
%% @end
%% ----------------------------------
after_room_fight(ClientWorker, PlayerId, EndTime) ->
	case self() == ClientWorker of
		true ->
			?DEBUG("notify ~p room fighting ===> ~p ", [PlayerId, EndTime]),
			api_room:push_room_fight_data(PlayerId, EndTime);
		false ->
			mod_apply:apply_to_online_player(ClientWorker, mod_room, after_room_fight, [ClientWorker, PlayerId, EndTime])
	end.

%% ----------------------------------
%% @doc 	房间关闭
%% @throws 	none
%% @end
%% ----------------------------------
after_room_close(ClientWorker, PlayerId, RoomWorker, WinnerPlayerId) ->
	case self() == ClientWorker of
		true ->
			?DEBUG("notify ~p room close ===> ~p ", [PlayerId, RoomWorker]),
			ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
			case ObjPlayer#ets_obj_player.room_worker of
				RoomWorker ->
					api_room:notice_fight_result(PlayerId, WinnerPlayerId),
					mod_obj_player:update_obj_player(ObjPlayer#ets_obj_player{room_type = 0, room_id = 0, room_worker = null});
				_ ->
					noop
			end;
		false ->
			mod_apply:apply_to_online_player(ClientWorker, mod_room, after_room_close, [ClientWorker, PlayerId, RoomWorker, WinnerPlayerId])
	end.

%% ----------------------------------
%% @doc 	玩家完成准备
%% @throws 	none
%% @end
%% ----------------------------------
after_player_ready(ClientWorker, PlayerId, ReadyPlayerId) ->
	case self() == ClientWorker of
		true ->
			?DEBUG("notify ~p player ~p ready.", [PlayerId, ReadyPlayerId]),
			api_room:notice_player_ready(PlayerId, ReadyPlayerId);
		false ->
			mod_apply:apply_to_online_player(ClientWorker, mod_room, after_player_ready, [ClientWorker, PlayerId, ReadyPlayerId])
	end.

%% ----------------------------------
%% @doc 	尝试进入房间
%% @throws 	none
%% @end
%% ----------------------------------
try_enter_room_if_exist(PlayerId) ->
	case ets:lookup(?ETS_OFFLINE_PLAYER_ROOM_CACHE, PlayerId) of
		[] -> false;
		[R] ->
			#ets_offline_player_room_cache{
				room_worker = RoomWorker
			} = R,
			ets:delete_object(?ETS_OFFLINE_PLAYER_ROOM_CACHE, R),
			case util:is_pid_alive(RoomWorker) of
				true ->
					#ets_obj_player{
						sender_worker = SenderWorker,
						client_worker = ClientWorker
					} = mod_obj_player:get_obj_player(PlayerId),
					case catch room_manage_srv:try_bind_room_if_exist(PlayerId, ClientWorker, SenderWorker) of
						ok ->
							true;
						_ ->
							false
					end;
				false ->
					false
			end
	end.

%% ----------------------------------
%% @doc 	玩家离开游戏
%% @throws 	none
%% @end
%% ----------------------------------
player_leave_room(PlayerId) ->
	unSubscribe(PlayerId),
	ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
	#ets_obj_player{
		room_worker = RoomWorker,
		room_type = RoomType,
		room_id = RoomId
	} = ObjPlayer,
	case RoomWorker /= null andalso util:is_pid_alive(RoomWorker) of
		true ->
			ets:insert(?ETS_OFFLINE_PLAYER_ROOM_CACHE,
				#ets_offline_player_room_cache{
					player_id = PlayerId,
					room_worker = RoomWorker,
					room_type = RoomType,
					room_id = RoomId,
					timestamp = util_time:timestamp()
				});
		false ->
			noop
	end,
	mod_obj_player:update_obj_player(ObjPlayer#ets_obj_player{room_type = 0, room_id = 0, room_worker = null}),
	ok.

%% ----------------------------------
%% @doc 	玩家准备
%% @throws 	none
%% @end
%% ----------------------------------
ready(PlayerId) ->
	ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
	#ets_obj_player{
		room_worker = RoomWorker
	} = ObjPlayer,
	room_worker:cast(RoomWorker, {?MSG_ROOM_PLAYER_READY, PlayerId}).

%% ----------------------------------
%% @doc 	上报战斗结果
%% @throws 	none
%% @end
%% ----------------------------------
fight_result(PlayerId, WinnerPlayerId) ->
	ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
	#ets_obj_player{
		room_worker = RoomWorker
	} = ObjPlayer,
	room_worker:cast(RoomWorker, {?MSG_ROOM_FIGHT_RESULT, PlayerId, WinnerPlayerId}).

%% ----------------------------------
%% @doc 	更新客户端操作
%% @throws 	none
%% @end
%% ----------------------------------
add_frame_action(PlayerId, Action) ->
	ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
	#ets_obj_player{
		room_worker = RoomWorker
	} = ObjPlayer,
	room_worker:cast(RoomWorker, {?MSG_ROOM_PLAYER_ADD_FRAME_ACTION, PlayerId, Action}).

%% ----------------------------------
%% @doc 	订阅类型房间
%% @throws 	none
%% @end
%% ----------------------------------
subscribe(PlayerId, Type) ->
	?DEBUG("subscribe, player:~p, type:~p", [PlayerId, Type]),
	?setModDict(subscribe_flag, true),
	ets:insert(?ETS_ROOM_SUBSCRIBE, #ets_room_subscribe{playerid = PlayerId, roomtype = Type}).

%% ----------------------------------
%% @doc 	取消订阅类型房间
%% @throws 	none
%% @end
%% ----------------------------------
unSubscribe(PlayerId) ->
	case ?getModDict(subscribe_flag) of
		true ->
			?setModDict(subscribe_flag, false),
			?DEBUG("unSubscribe ~p", [PlayerId]),
			ets:select_delete(?ETS_ROOM_SUBSCRIBE, [{#ets_room_subscribe{playerid = PlayerId, _ = '_'}, [], [true]}]);
		false ->
			noop
	end.

