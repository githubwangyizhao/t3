%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 十一月 2020 下午 06:08:11
%%%-------------------------------------------------------------------
-module(many_people_boss_srv).
-author("Administrator").

-behaviour(gen_server).

-include("many_people_boss.hrl").
-include("common.hrl").
-include("system.hrl").

%% API
-export([start_link/0]).

-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-export([
    call/1,
    cast/1,
    rpc_call/2,
    player_enter_game/1
]).

-define(SERVER, ?MODULE).

-record(state, {}).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    ets:new(?ETS_MANY_PEOPLE_BOSS_ROOM_DATA, ?ETS_INIT_ARGS(#ets_many_people_boss_room_data.room_id)),
    put(?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID, 0),
    many_people_boss_srv_mod:init_many_people_boss_room(),
    {ok, #state{}}.

call(Request) ->
    CallNode =
        case mod_server_config:get_server_type() of
            ?SERVER_TYPE_WAR_AREA ->
                ?MODULE;
            ?SERVER_TYPE_GAME ->
                WarNode = mod_server_config:get_war_area_node(),
                {?MODULE, WarNode}
        end,
    case catch gen_server:call(CallNode, Request) of
        {'EXIT', Reason} ->
            exit(Reason);
        Result ->
            Result
    end.

cast(Request) ->
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_WAR_AREA ->
            gen_server:cast(?MODULE, Request);
        ?SERVER_TYPE_GAME ->
            WarNode = mod_server_config:get_war_area_node(),
            gen_server:cast({?MODULE, WarNode}, Request)
    end.

rpc_call(Function, Args) ->
    rpc:call(mod_server_config:get_war_area_node(), many_people_boss_srv_mod, Function, Args).

try_get_result(Fun) ->
    try Fun()
    catch
        _:_Reason_ ->
            ?DEBUG("错误~p", [{_Reason_, erlang:get_stacktrace()}]),
%%            {'DOWN', _Reason_}
            {'EXIT', _Reason_}
    end.

player_enter_game(PlayerId) ->
    CallNode =
        case mod_server_config:get_server_type() of
            ?SERVER_TYPE_WAR_AREA ->
                ?MODULE;
            ?SERVER_TYPE_GAME ->
                WarNode = mod_server_config:get_war_area_node(),
                {?MODULE, WarNode}
        end,
    gen_server:call(CallNode, {?MANY_PEOPLE_BOSS_LOGIN_GAME, PlayerId}, 1000).


handle_call({?MANY_PEOPLE_BOSS_JOIN_ROOM, PlayerId, RoomId, Password, InvitationCode, PlayerConditionMap, PlayerData}, _From, State) ->
    Result = try_get_result(fun() ->
        many_people_boss_srv_mod:handle_join_room(PlayerId, RoomId, Password, InvitationCode, PlayerConditionMap, PlayerData) end),
    {reply, Result, State};
handle_call({?MANY_PEOPLE_BOSS_CREATE_ROOM, PlayerId, BossId, IsLock, Password, PlayerConditionMap, PlayerData}, _From, State) ->
    Result = try_get_result(fun() ->
        many_people_boss_srv_mod:handle_create_room(PlayerId, BossId, IsLock, Password, PlayerConditionMap, PlayerData) end),
    {reply, Result, State};
handle_call({?MANY_PEOPLE_BOSS_START, PlayerId}, _From, State) ->
    Result = try_get_result(fun() ->
        many_people_boss_srv_mod:handle_start(PlayerId) end),
    {reply, Result, State};
handle_call({?MANY_PEOPLE_BOSS_READY, PlayerId, IsReady, PlayerConditionMap}, _From, State) ->
    Result = try_get_result(fun() ->
        many_people_boss_srv_mod:handle_ready(PlayerId, IsReady, PlayerConditionMap) end),
    {reply, Result, State};
handle_call({?MANY_PEOPLE_BOSS_PARTICIPATE_IN, PlayerId, IsParticipateIn, PlayerConditionMap}, _From, State) ->
    Result = try_get_result(fun() ->
        many_people_boss_srv_mod:handle_participate_in(PlayerId, IsParticipateIn, PlayerConditionMap) end),
    {reply, Result, State};
handle_call({?MANY_PEOPLE_BOSS_MISSION_BALANCE, RoomId, PlayerIdList, KillBossPlayerId, RankList,PlayerNameStr}, _From, State) ->
    Result = try_get_result(fun() ->
        many_people_boss_srv_mod:handle_mission_balance(RoomId, PlayerIdList, KillBossPlayerId, RankList,PlayerNameStr) end),
    {reply, Result, State};
handle_call({?MANY_PEOPLE_BOSS_MISSION_LEAVE, RoomId, PlayerId}, _From, State) ->
    Result = try_get_result(fun() ->
        many_people_boss_srv_mod:handle_mission_leave(RoomId, PlayerId) end),
    {reply, Result, State};
handle_call({?MANY_PEOPLE_BOSS_LOGIN_GAME, PlayerId}, _From, State) ->
    Result = try_get_result(fun() ->
        many_people_boss_srv_mod:handle_login_game(PlayerId) end),
    {reply, Result, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({?MANY_PEOPLE_BOSS_KICK_OUT_PLAYER, PlayerId, PosId}, State) ->
    try_get_result(fun() ->
        many_people_boss_srv_mod:handle_kick_out_player(PlayerId, PosId) end),
    {noreply, State};
handle_cast({?MANY_PEOPLE_BOSS_LEAVE_ROOM, PlayerId, IsLeaveGame}, State) ->
    try_get_result(fun() ->
        many_people_boss_srv_mod:handle_leave_room(PlayerId, IsLeaveGame) end),
    {noreply, State};
handle_cast({?MANY_PEOPLE_BOSS_SET_ALL_READY_START, PlayerId, IsAllReadyStart}, State) ->
    try_get_result(fun() ->
        many_people_boss_srv_mod:handle_set_is_all_ready_start(PlayerId, IsAllReadyStart) end),
    {noreply, State};
%%handle_cast({?MANY_PEOPLE_BOSS_READY, PlayerId}, State) ->
%%    try_get_result(fun() ->
%%        many_people_boss_srv_mod:handle_ready(PlayerId) end),
%%    {noreply, State};
handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
