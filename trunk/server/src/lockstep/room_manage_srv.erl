%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		房间管理服务进程
%%% @end
%%% Created : 18. 11月 2021 15:14
%%%-------------------------------------------------------------------
-module(room_manage_srv).
-author("yizhao.wang").
-behaviour(gen_server).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-export([start_link/0]).

%% API
-export([
	get_room_list_by_type/1,
	enter_room/6,
	leave_room/1,
	try_bind_room_if_exist/3
]).

-include("common.hrl").
-include("error.hrl").
-include("room.hrl").
-include("gen/table_db.hrl").

-define(SERVER, ?MODULE).
-record(state, {}).

get_room_list_by_type(Type) ->
	mod_server_rpc:gen_server_call_war(?SERVER, {get_room_list, Type}).

enter_room(PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker, Type, RoomId) ->
	mod_server_rpc:gen_server_call_war(?SERVER, {enter_room, PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker, Type, RoomId}).

try_bind_room_if_exist(PlayerId, ClientWorker, SenderWorker) ->
	mod_server_rpc:gen_server_call_war(?SERVER, {try_bind_room_if_exist, PlayerId, ClientWorker, SenderWorker}).

leave_room(PlayerId) ->
	mod_server_rpc:gen_server_call_war(?SERVER, {leave_room, PlayerId}).

%% ----------------------------------
%% @doc 	获取玩家旧房间进程
%% @throws 	none
%% @end
%% ----------------------------------
get_ori_room_worker(PlayerId) ->
	case ets:lookup(?ETS_ROOM_INFO, PlayerId) of
		[] -> null;
		[Rec] ->
			RoomWorker = Rec#ets_room_info.room_worker,
			case RoomWorker /= null andalso util:is_pid_alive(RoomWorker) of
				true ->
					{ok, RoomWorker};
				false ->
					?ERROR("ori room worker ~p is not exist.", [RoomWorker]),
					null
			end
	end.

%% ----------------------------------
%% @doc 	ETS添加房间信息
%% @throws 	none
%% @end
%% ----------------------------------
ets_add_room_worker(PlayerIdList, RoomWorker) ->
	[ets_add_player(PlayerId, RoomWorker) || PlayerId <- PlayerIdList].

ets_add_player(PlayerId, RoomWorker) ->
	ets:insert(?ETS_ROOM_INFO, #ets_room_info{
		playerid = PlayerId,
		room_worker = RoomWorker
	}).

%% ----------------------------------
%% @doc 	ETS删除房间信息
%% @throws 	none
%% @end
%% ----------------------------------
ets_del_room_worker(RoomWorker) ->
	ets:select_delete(?ETS_ROOM_INFO, [{#ets_room_info{room_worker = RoomWorker, _='_'}, [], [true]}]).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% CALLBACKS
%%%===================================================================
init([]) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_ROOM_INFO, ?ETS_INIT_ARGS(#ets_room_info.playerid)),
	mod_server_rpc:cast_all_game_server(mod_room, handle_room_list_change, []),
	{ok, #state{}}.

handle_call({enter_room, PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker, Type, RoomId}, _From, State) ->
	?DEBUG("enter_room => PlayerId:~p, clientworker:~p, senderworker:~p, type:~p, roomid:~p", [PlayerId, ClientWorker, SenderWorker, Type, RoomId]),
	Result =
		case get_ori_room_worker(PlayerId) of
			null ->
				?TRY_CATCH2(enterRoom(PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker, Type, RoomId));
			{ok, _OriRoomWorker} ->
				?DEBUG("repeat enter, player is in room already!"),
				room_already_started
		end,
	{reply, Result, State};
handle_call({leave_room, PlayerId}, _From, State) ->
	?DEBUG("leave_room => PlayerId:~p", [PlayerId]),
	Result =
		case get_ori_room_worker(PlayerId) of
			null ->
				leaveRoom(PlayerId);
			{ok, _OriRoomWorker} ->
				?ERROR("cannot leave room, room already started!"),
				room_already_started
		end,
	{reply, Result, State};
handle_call({try_bind_room_if_exist, PlayerId, ClientWorker, SenderWorker}, _From, State) ->
	?DEBUG("try_bind_room_if_exist => PlayerId:~p", [PlayerId]),
	Result =
		case get_ori_room_worker(PlayerId) of
			null ->
				player_not_in_room;
			{ok, OriRoomWorker} ->
				catch room_worker:call(OriRoomWorker, {?MSG_ROOM_PLAYER_REBIND_ROOM, PlayerId, ClientWorker, SenderWorker})
		end,
	{reply, Result, State};
handle_call({get_room_list, Type}, _From, State) ->
	{reply, {ok, ?TRY_CATCH2(getRoomInfoListByType(Type))}, State};
handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Request, State) ->
	{noreply, State}.

handle_info({'DOWN', _Ref, process, Pid, _Reason}, State) ->
	case get(Pid) of
		{senderworker, PlayerId} ->
			?DEBUG("senderworker ~p down! playerid:~p", [Pid, PlayerId]),
			leaveRoom(PlayerId);
		{roomworker, Type, RoomId} ->
			?INFO("roomworker ~p close! roomtype:~p, roomid:~p", [Pid, Type, RoomId]),
			delRoomInfo(Pid, Type, RoomId),
			push_room_info_2_game_server(Type, RoomId);
		_ ->
			noop
	end,
	erase(Pid),
	{noreply, State};
handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% ----------------------------------
%% @doc 	进入房间
%% @throws 	none
%% @end
%% ----------------------------------
enterRoom(PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker, Type, RoomId) ->
	OriPlayerInfoList = getRoomInfo(Type, RoomId),
	case lists:keymember(PlayerId, 1, OriPlayerInfoList) of
		true -> player_already_in_room;
		false ->
			OriPlayerCount = length(OriPlayerInfoList),
			case OriPlayerCount < ?ROOM_MAX_PLAYER of
				true ->
					if
						OriPlayerCount + 1 == ?ROOM_MAX_PLAYER ->
							%% 取消监控玩家发送进程
							NowPlayerInfoList =
								[begin
									 erlang:demonitor(OneMonitorRef),
									 erase(OneSenderWorker),
									 {OnePlayerId, OnePlayerBaseInfo, OneClientWorker, OneSenderWorker, null}
								 end || {OnePlayerId, OnePlayerBaseInfo, OneClientWorker, OneSenderWorker, OneMonitorRef} <- OriPlayerInfoList] ++ [{PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker, null}],
							%% 加入房间
							ParamPlayerInfoList = [{OnePlayerId, OnePlayerBaseInfo, OneClientWorker, OneSenderWorker} || {OnePlayerId, OnePlayerBaseInfo, OneClientWorker, OneSenderWorker, _OneMonitorRef} <- NowPlayerInfoList],
							{ok, NewRoomWorker} = room_worker:start(Type, RoomId, ParamPlayerInfoList),
							%% 监控房间进程
							erlang:monitor(process, NewRoomWorker),
							PlayerIdList = [OnePlayerId || {OnePlayerId, _OnePlayerBaseInfo, _OneClientWorker, _OneSenderWorker} <- ParamPlayerInfoList],
							ets_add_room_worker(PlayerIdList, NewRoomWorker),
							put(NewRoomWorker, {roomworker, Type, RoomId}),
							ok;
						true ->
							%% 监控玩家发送进程
							put(SenderWorker, {senderworker, PlayerId}),
							MonitorRef = erlang:monitor(process, SenderWorker),
							NowPlayerInfoList = [{PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker, MonitorRef} | OriPlayerInfoList],
							setPlayerRoomMap(PlayerId, {Type, RoomId})
					end,
					setRoomInfo(Type, RoomId, NowPlayerInfoList),
					push_room_info_2_game_server(Type, RoomId),
					ok;
				%% 满员
				false ->
					member_full
			end
	end.

%% ----------------------------------
%% @doc 	离开房间
%% @throws 	none
%% @end
%% ----------------------------------
leaveRoom(PlayerId) ->
	case getPlayerRoomMap(PlayerId) of
		?UNDEFINED -> noop;
		{Type, RoomId} ->
			PlayerInfoList = getRoomInfo(Type, RoomId),
			case lists:keytake(PlayerId, 1, PlayerInfoList) of
				false ->
					skip;
				{value, {PlayerId, _PlayerBaseInfo, _ClientWorker, SenderWorker, MonitorRef}, LeftPlayerInfoList} ->
					if
						MonitorRef /= null ->
							erlang:demonitor(MonitorRef);
						true ->
							noop
					end,
					erase(SenderWorker),
					setRoomInfo(Type, RoomId, LeftPlayerInfoList),
					push_room_info_2_game_server(Type, RoomId)
			end,
			delPlayerRoomMap(PlayerId)
	end,
	ok.

%% ----------------------------------
%% @doc 	删除房间信息
%% @throws 	none
%% @end
%% ----------------------------------
getRoomInfoKey(Type, RoomId) -> {room_info, Type, RoomId}.
getRoomInfo(Type, RoomId) -> case get(getRoomInfoKey(Type, RoomId)) of undefined -> []; L -> L end.
setRoomInfo(Type, RoomId, PlayerInfoList) -> put(getRoomInfoKey(Type, RoomId), PlayerInfoList).
delRoomInfo(RoomWorker, Type, RoomId) ->
	setRoomInfo(Type, RoomId, []),
	ets_del_room_worker(RoomWorker).

getPlayerRoomMapKey(PlayerId) -> {player_room_map, PlayerId}.
getPlayerRoomMap(PlayerId) -> get(getPlayerRoomMapKey(PlayerId)).
setPlayerRoomMap(PlayerId, Value) -> put(getPlayerRoomMapKey(PlayerId), Value).
delPlayerRoomMap(PlayerId) -> erase(getPlayerRoomMapKey(PlayerId)).

%% ----------------------------------
%% @doc 	推送房间信息到游戏服
%% @throws 	none
%% @end
%% ----------------------------------
push_room_info_2_game_server(Type, RoomId) ->
	PlayerBaseInfoList = [OnePlayerBaseInfo || {_OnePlayerId, OnePlayerBaseInfo, _OneClientWorker, _OneSenderWorker, _OneMonitorRef} <- getRoomInfo(Type, RoomId)],
	mod_server_rpc:cast_all_game_server(mod_room, handle_room_info_push, [Type, RoomId, PlayerBaseInfoList]).

%% ----------------------------------
%% @doc 	获取房间列表信息
%% @throws 	none
%% @end
%% ----------------------------------
 getRoomInfoListByType(Type) ->
	#t_eat_monster_battle{
		amount = RoomNum
	} = t_eat_monster_battle:assert_get({Type}),
	lists:map(
		fun(TmpRoomId) ->
			PlayerBaseInfoList = [OnePlayerBaseInfo || {_OnePlayerId, OnePlayerBaseInfo, _ClientWorker, _SenderWorker, _OneMonitorRef} <- getRoomInfo(Type, TmpRoomId)],
			{TmpRoomId, PlayerBaseInfoList}
		end,
		lists:seq(1, RoomNum)
	).