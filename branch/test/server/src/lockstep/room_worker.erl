%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		房间进程
%%% @end
%%% Created : 18. 11月 2021 15:14
%%%-------------------------------------------------------------------
-module(room_worker).
-author("yizhao.wang").

-behaviour(gen_server).

-include("common.hrl").
-include("system.hrl").
-include("p_message.hrl").
-include("room.hrl").

%% API
-export([start/3, start_link/3]).
-export([call/2, cast/2]).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-define(SERVER, ?MODULE).
-define(READY_TIME, 10000).
-define(FIGHT_TIME, 120000).
-define(CLOSE_ROOM_TIMEOUT, 10000).
-define(LOCKSTEP_MILSECOND, 33).

-record(?MODULE, {
	type,
	roomid,
	playerList,				%% 房间内的玩家列表 [{玩家id，玩家进程，玩家发送进程}|...]
	readyPlayerIdList = [],	%% 准备好了的玩家id列表
	randomSeed,
	etsTabId,

	frame_seq = 0,			%% 帧序列id
	frame_actions = [],		%% 帧操作列表 [{玩家索引，操作}|...]
	fight_results = [],		%% 战斗结果列表 [{上报玩家id，获胜玩家id}|...]
	is_fighting = false,	%% 是否开始战斗了
	is_result = false,		%% 是否结算过了
	readyEndTime = 0,		%% 准备阶段结束时间
	fightEndTime = 0,		%% 房间结束时间
	readyTimeRef = null		%% 准备阶段定时器
}).

-record(state, {close_time_ref}).

%%%===================================================================
%%% API
%%%===================================================================
start(Type, RoomId, PlayerInfoList) ->
	supervisor:start_child(room_sup, [Type, RoomId, PlayerInfoList]).

start_link(Type, RoomId, PlayerInfoList) ->
	gen_server:start_link(?MODULE, [Type, RoomId, PlayerInfoList], []).

call(RoomWorker, Request) ->
	gen_server:call(RoomWorker, Request, 5000).

cast(RoomWorker, Request) ->
	gen_server:cast(RoomWorker, Request).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([Type, RoomId, PlayerInfoList]) ->
	?DEBUG("create room ~w ... ", [{Type, RoomId, PlayerInfoList}]),
	?setModDict(type, Type),
	?setModDict(roomid, RoomId),
	?setModDict(playerList, PlayerInfoList),
	%% 设置随机种子
	RandomSeed = rand:uniform(65536),
	?setModDict(randomSeed, RandomSeed),
	EtsTabId = ets:new(ets_frame_info, [ordered_set, private]),
	?setModDict(etsTabId, EtsTabId),

	%% 准备阶段倒计时定时器
	TimerRef = erlang:send_after(?READY_TIME, self(), ready_timeout),
	ReadyEndTime = util_time:milli_timestamp() + ?READY_TIME,
	?setModDict(readyTimeRef, TimerRef),
	?setModDict(readyEndTime, ReadyEndTime),

	%% 监听客户端连接
	PlayerBaseInfoList = [OnePlayerBaseInfo || {_OnePlayerId, OnePlayerBaseInfo, _OneClientWorker, _OneSenderWorker} <- ?getModDict(playerList)],
	lists:foldl(
		fun({OnePlayerId, _OnePlayerBaseInfo, OneClientWorker, OneSenderWorker}, Index) ->
			erlang:monitor(process, OneSenderWorker),
			setPlayerIndex(OnePlayerId, Index),
			mod_room:after_room_start(OneClientWorker, self(), Type, RoomId, RandomSeed, ReadyEndTime, PlayerBaseInfoList, [], Index),
			Index + 1
		end,
		1,
		PlayerInfoList
	),
	initFrame(),
	{ok, #state{}}.

handle_call({?MSG_ROOM_PLAYER_REBIND_ROOM, PlayerId, ClientWorker, SenderWorker}, _From, State) ->
	?DEBUG("~p player rebind roomworker ~p, clientworker:~p, senderworker:~p", [PlayerId, self(), ClientWorker, SenderWorker]),
	?TRY_CATCH2(handle_player_rebind_room(PlayerId, ClientWorker, SenderWorker)),
	{reply, ok, State};

handle_call(_Request, _From, State) ->
	?ERROR("unkown call request ~p", [_Request]),
	{reply, ok, State}.

handle_cast({?MSG_ROOM_PLAYER_ADD_FRAME_ACTION, PlayerId, Action}, State) ->
	addFrameAction(PlayerId, Action),
	{noreply, State};

handle_cast({?MSG_ROOM_PLAYER_READY, PlayerId}, State) ->
	?TRY_CATCH2(handle_player_ready(PlayerId)),
	{noreply, State};

handle_cast({?MSG_ROOM_FIGHT_RESULT, PlayerId, WinnerPlayerId}, OriState = #state{close_time_ref = OriCloseTimeRef}) ->
	?TRY_CATCH2(handle_fight_result(PlayerId, WinnerPlayerId)),
	ForceCloseRoom = length(?getModDict(playerList)) =:= length(?getModDict(fight_results)),
	NewState =
	if
		ForceCloseRoom ->
			self() ! close_room,
			OriState;
		true ->
			if
				OriCloseTimeRef == undefined ->
					CloseTimeRef = erlang:send_after(?CLOSE_ROOM_TIMEOUT, self(), close_room),
					OriState#state{close_time_ref = CloseTimeRef};
				true ->
					OriState
			end
	end,
	{noreply, NewState};

handle_cast(_Request, State) ->
	?ERROR("unkown cast request ~p", [_Request]),
	{noreply, State}.

handle_info(ready_timeout, State) ->
	?TRY_CATCH2(init_fight()),
	{noreply, State};

handle_info(frame, State) ->
	?TRY_CATCH2(handle_sync_frame()),
	{noreply, State};

handle_info(fight_end, State) ->
	CloseTimeRef = erlang:send_after(?CLOSE_ROOM_TIMEOUT, self(), close_room),
	{noreply, State#state{close_time_ref = CloseTimeRef}};

handle_info(close_room, State) ->
	?INFO("close room ~p...", [self()]),
	?TRY_CATCH2(handle_close_room()),
	{stop, normal, State};

handle_info({'DOWN', _Ref, process, SenderWorker, _Reason}, State) ->
	OriPlayerInfoList = ?getModDict(playerList),
	OriReadyPlayerIdList = ?getModDict(readyPlayerIdList),
	case lists:keyfind(SenderWorker, 4, OriPlayerInfoList) of
		false ->
			noop;
		{PlayerId, PlayerBaseInfo, _, _} ->
			?DEBUG("senderworker ~p down! playerid:~p", [SenderWorker, PlayerId]),
			?setModDict(readyPlayerIdList, lists:delete(PlayerId, OriReadyPlayerIdList)),
			?setModDict(playerList, lists:keyreplace(SenderWorker, 4, OriPlayerInfoList, {PlayerId, PlayerBaseInfo, null, null}))
	end,
	{noreply, State};

handle_info(_Info, State) ->
	?ERROR("unkown info ~p", [_Info]),
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% ----------------------------------
%% @doc 	初始化战斗
%% @throws 	none
%% @end
%% ----------------------------------
init_fight() ->
	case ?getModDict(is_fighting) of
		true -> noop;
		false ->
			%% 定时器设置关闭房间倒计时
			erlang:send_after(?FIGHT_TIME, self(), fight_end),
			FightEndTime = util_time:milli_timestamp() + ?FIGHT_TIME,
			?setModDict(fightEndTime, FightEndTime),
			?setModDict(is_fighting, true),

			%% 通知已经准备好的玩家战斗开始
			ReadyPlayerIdList = ?getModDict(readyPlayerIdList),
			[
				begin
					case lists:member(OnePlayerId, ReadyPlayerIdList) of
						false -> noop;
						true ->
							mod_room:after_room_fight(OneClientWorker, OnePlayerId, FightEndTime)
					end
				end
				|| {OnePlayerId, _OnePlayerBaseInfo, OneClientWorker, _OneSenderWorker} <- ?getModDict(playerList)
			],

			timer:send_interval(?LOCKSTEP_MILSECOND, self(), frame)
	end,
	ok.

%% ----------------------------------
%% @doc 	初始化帧
%% @throws 	none
%% @end
%% ----------------------------------
initFrame() ->
	?setModDict(frame_seq, 1),
	?setModDict(frame_actions, lists:map(fun(Index) -> {Index, -1} end, lists:seq(1, ?ROOM_MAX_PLAYER))).

nextFrame()->
	?setModDict(frame_seq, ?getModDict(frame_seq) + 1).

addFrameAction(PlayerId, Action)->
	Index = getPlayerIndex(PlayerId),
	?setModDict(frame_actions, lists:keyreplace(Index, 1, ?getModDict(frame_actions), {Index, Action})).

%% ----------------------------------
%% @doc 	处理玩家断线重连
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_rebind_room(PlayerId, ClientWorker, SenderWorker) ->
	OriPlayerInfoList = ?getModDict(playerList),
	case lists:keyfind(PlayerId, 1, OriPlayerInfoList) of
		{PlayerId, PlayerBaseInfo, null, null} ->
			%% 监听新的玩家进程
			erlang:monitor(process, SenderWorker),
			PlayerBaseInfoList = [OnePlayerBaseInfo || {_, OnePlayerBaseInfo, _, _} <- ?getModDict(playerList)],
			mod_room:after_room_start(ClientWorker, self(), ?getModDict(type), ?getModDict(roomid), ?getModDict(randomSeed), ?getModDict(readyEndTime), PlayerBaseInfoList, ?getModDict(readyPlayerIdList), getPlayerIndex(PlayerId)),
			?setModDict(playerList, lists:keyreplace(PlayerId, 1, OriPlayerInfoList, {PlayerId, PlayerBaseInfo, ClientWorker, SenderWorker})),
			ok;
		_ ->
			skip
	end.

%% ----------------------------------
%% @doc 	处理玩家准备
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_ready(PlayerId) ->
	OriReadyPlayerIdList = ?getModDict(readyPlayerIdList),
	PlayerInfoList = ?getModDict(playerList),
	{_, _, ClientWorker, _} = lists:keyfind(PlayerId, 1, PlayerInfoList),
	IsFightStart = ?getModDict(is_fighting),
	NowReadyPlayerIdList =
		case lists:member(PlayerId, OriReadyPlayerIdList) of
			false -> [PlayerId | OriReadyPlayerIdList];
			_ -> OriReadyPlayerIdList
		end,
	case NowReadyPlayerIdList of
		OriReadyPlayerIdList ->
			noop;
		_ ->
			if
				not IsFightStart ->
					?setModDict(readyPlayerIdList, NowReadyPlayerIdList),
					[mod_room:after_player_ready(OneClientWorker, OnePlayerId, PlayerId) || {OnePlayerId, _OnePlayerBaseInfo, OneClientWorker, _OneSenderWorker} <- ?getModDict(playerList)],
					case length(NowReadyPlayerIdList) == length(PlayerInfoList) of
						true ->
							erlang:cancel_timer(?getModDict(readyTimeRef)),
							% 所有玩家都准备好了，直接开始战斗
							init_fight();
						false ->
							noop
					end;
				true ->
					% 战斗已经开始，重置玩家帧序号
					setPlayerReConnectInfo(PlayerId, 1),
					?setModDict(readyPlayerIdList, NowReadyPlayerIdList),
					mod_room:after_room_fight(ClientWorker, PlayerId, ?getModDict(fightEndTime)),
					noop
			end
	end.

%% ----------------------------------
%% @doc 	同步帧数据
%% @throws 	none
%% @end
%% ----------------------------------
handle_sync_frame() ->
	FrameSeq = ?getModDict(frame_seq),
	FrameActions = ?getModDict(frame_actions),
	RealFrameActions = lists:map(fun({_Index, Action}) -> Action end, FrameActions),
%%	?DEBUG("frame........~p ~p ~p", [util_time:milli_timestamp(), FrameSeq, RealFrameActions]),

	%% ets表记录当前帧数据
	EtsTabName = ?getModDict(etsTabId),
	ets:insert(EtsTabName, {FrameSeq, RealFrameActions}),
	ReadyPlayerIdList = ?getModDict(readyPlayerIdList),
	[begin
		case lists:member(OnePlayerId, ReadyPlayerIdList) of
			%% 玩家还没准备好，不同步数据
			false ->
				noop;
			true ->
				FrameDataList =
					case getPlayerReConnectInfo(OnePlayerId) of
						%% 发送当前帧数据
						?UNDEFINED ->
							[{FrameSeq, RealFrameActions}];
						%% 分发历史帧数据
						StartFrameSeq ->
							EndFrameSeq = min(FrameSeq, StartFrameSeq + ?SECOND_MS div ?LOCKSTEP_MILSECOND * 4),
							if
								EndFrameSeq + 1 > FrameSeq ->
									setPlayerReConnectInfo(OnePlayerId, ?UNDEFINED);
								true ->
									setPlayerReConnectInfo(OnePlayerId, EndFrameSeq + 1)
							end,
							[{OneFrameSeq, ets:lookup_element(EtsTabName, OneFrameSeq, 2)} || OneFrameSeq <- lists:seq(StartFrameSeq, EndFrameSeq)]
					end,
				api_room:push_frame_data(OneSenderWorker, FrameDataList)
		end
	 end || {OnePlayerId, _OnePlayerBaseInfo, _OneClientWorker, OneSenderWorker} <- ?getModDict(playerList), OneSenderWorker /= null],
	%% 更新帧序列
	nextFrame().

%% ----------------------------------
%% @doc 	处理客户端上报战斗结果
%% @throws 	none
%% @end
%% ----------------------------------
handle_fight_result(PlayerId, WinnerPlayerId) ->
	OriFightResults = ?getModDict(fight_results),
	case lists:keyfind(PlayerId, 1, OriFightResults) of
		false ->
			NowFightResults =
				case OriFightResults of
					[] ->
						[{PlayerId, WinnerPlayerId}];
					_ ->
						lists:keystore(PlayerId, 1, OriFightResults, {PlayerId, WinnerPlayerId})
				end,
			?setModDict(fight_results, NowFightResults);
		_ ->
			noop
	end.

%% ----------------------------------
%% @doc 	关闭房间
%% @throws 	none
%% @end
%% ----------------------------------
handle_close_room() ->
	WinnerPlayerId = check_fight_result(),

	Self = self(),
	PlayerInfoList = ?getModDict(playerList),
	[mod_room:after_room_close(OneClientWorker, OnePlayerId, Self, WinnerPlayerId) || {OnePlayerId, _OnePlayerBaseInfo, OneClientWorker, _OneSenderWorker} <- PlayerInfoList],
	BattleHistoryTerm = {battle_history_info, [
		{type, ?getModDict(type)},
		{roomid, ?getModDict(roomid)},
		{players, ?getModDict(playerList)},
		{randomseed, ?getModDict(randomSeed)},
		{indexs, [{OnePlayerId, getPlayerIndex(OnePlayerId)} || {OnePlayerId, _, _, _} <- PlayerInfoList]},
		{time, util_time:timestamp()},
		{frames, ets:tab2list(?getModDict(etsTabId))}
	]},
	{{YY, MM, DD}, _} = erlang:localtime(),
	FileName = io_lib:format("../log/game/~s/~p~6.10.0B.battle", [lists:concat([YY, "_", MM, "_", DD]), util_time:milli_timestamp(), rand:uniform(999999)]),
	util_file:save_term(FileName, BattleHistoryTerm),
	ets:delete(?getModDict(etsTabId)),
	ok.

%% ----------------------------------
%% @doc 	检查战斗结果(判断是否有玩家作弊)
%% @throws 	none
%% @end
%% ----------------------------------
check_fight_result() ->
	FightResults = ?getModDict(fight_results),
	case FightResults of
		[] -> 0;
		[{_, WinnerPlayerId} | Rest] ->
			IsOk = lists:all(fun({_, WPlayerId}) -> WPlayerId =:= WinnerPlayerId end, Rest),
			if
				IsOk -> WinnerPlayerId;
				true ->
					?WARNING("Some players cheated!!! FightResults:~w", FightResults),
					0
			end
	end.

%% ----------------------------------
%% @doc 	进程字典
%% @throws 	none
%% @end
%% ----------------------------------
getPlayerReConnectInfoKey(PlayerId) -> {playerreconnectinfo, PlayerId}.
getPlayerReConnectInfo(PlayerId) -> get(getPlayerReConnectInfoKey(PlayerId)).
setPlayerReConnectInfo(PlayerId, FrameSeq) -> put(getPlayerReConnectInfoKey(PlayerId), FrameSeq).

getPlayerIndexKey(PlayerId) -> {playerindex, PlayerId}.
getPlayerIndex(PlayerId) -> get(getPlayerIndexKey(PlayerId)).
setPlayerIndex(PlayerId, Index) -> put(getPlayerIndexKey(PlayerId), Index).