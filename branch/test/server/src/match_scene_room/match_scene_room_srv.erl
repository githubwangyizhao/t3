%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(match_scene_room_srv).

-behaviour(gen_server).

-include("common.hrl").
-include("system.hrl").
-include("match_scene.hrl").

-export([
    start_link/0
]).
-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-export([call/1, cast/1]).

-define(SERVER, ?MODULE).

-record(match_scene_room_srv_state, {}).

call(Request) ->
    CallNode =
        case mod_match_scene_room:get_server_type() of
            ?SERVER_TYPE_WAR_AREA ->
                WarNode = mod_server_config:get_war_area_node(),
                {?MODULE, WarNode};
            ?SERVER_TYPE_GAME ->
                ?MODULE
        end,
    gen_server:call(CallNode, Request).
%%call(Request) ->
%%    gen_server:call(?MODULE, Request).

cast(Request) ->
    case mod_match_scene_room:get_server_type() of
        ?SERVER_TYPE_WAR_AREA ->
            WarNode = mod_server_config:get_war_area_node(),
            gen_server:cast({?MODULE, WarNode}, Request);
        ?SERVER_TYPE_GAME ->
            gen_server:cast(?MODULE, Request)
    end.
%%cast(Request) ->
%%    gen_server:cast(?MODULE, Request).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    put(?DICT_ROOM_ID, 0),
    put(?DICT_WORLD_RECRUIT_LIST, []),
    put(?DICT_OBSERVER_LIST, []),
    ets:new(?ETS_ROOM_DATA, ?ETS_INIT_ARGS(#ets_room_data.room_id)),
    {ok, #match_scene_room_srv_state{}}.

handle_call({get_unread_room_num, PlayerId}, _From, State = #match_scene_room_srv_state{}) ->
    Result = ?CATCH(mod_match_scene_room:handle_get_unread_room_num(PlayerId)),
    {reply, Result, State};
handle_call({get_player_room_list, PlayerId}, _From, State = #match_scene_room_srv_state{}) ->
    Result = ?CATCH(mod_match_scene_room:handle_get_player_room_list(PlayerId)),
    {reply, Result, State};
handle_call({create_room, PlayerId, Password, CostNum, ModelHeadFigure}, _From, State = #match_scene_room_srv_state{}) ->
    Result = ?CATCH(mod_match_scene_room:handle_create_room(PlayerId, Password, CostNum, ModelHeadFigure)),
    {reply, Result, State};
handle_call({world_recruit, PlayerId}, _From, State = #match_scene_room_srv_state{}) ->
    Result = ?CATCH(mod_match_scene_room:handle_world_recruit(PlayerId)),
    {reply, Result, State};
handle_call({recruit, PlayerId, ServerId, RecruitPlayerId}, _From, State = #match_scene_room_srv_state{}) ->
    Result = ?CATCH(mod_match_scene_room:handle_recruit(PlayerId, ServerId, RecruitPlayerId)),
    {reply, Result, State};
handle_call({join_room, PlayerId, RoomId, Password,PlayerPropNum}, _From, State = #match_scene_room_srv_state{}) ->
    Result = ?CATCH(mod_match_scene_room:handle_join_room(PlayerId, RoomId, Password,PlayerPropNum)),
    {reply, Result, State};
handle_call({leave_room, PlayerId}, _From, State = #match_scene_room_srv_state{}) ->
    Result = ?CATCH(mod_match_scene_room:handle_leave_room(PlayerId)),
    {reply, Result, State};
handle_call(_Request, _From, State = #match_scene_room_srv_state{}) ->
    {reply, ok, State}.

handle_cast({exit_room_list, PlayerId}, State = #match_scene_room_srv_state{}) ->
    ?CATCH(mod_match_scene_room:handle_exit_room_list(PlayerId)),
    {noreply, State};
handle_cast(_Request, State = #match_scene_room_srv_state{}) ->
    {noreply, State}.

handle_info(_Info, State = #match_scene_room_srv_state{}) ->
    {noreply, State}.

terminate(_Reason, _State = #match_scene_room_srv_state{}) ->
    ok.

code_change(_OldVsn, State = #match_scene_room_srv_state{}, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
