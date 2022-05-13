%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            场景寻路进程
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(scene_navigate_worker).

-behaviour(gen_server).
-include("common.hrl").
-include("scene.hrl").
-include("msg.hrl").
%% API
-export([
    start/2,
    request_navigate/9
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {map_id, scene_worker}).

%%%===================================================================
%%% API
%%%===================================================================

start(SceneWorker, MapId) ->
    gen_server:start(?MODULE, [SceneWorker, MapId], []).

request_navigate(Pid, ObjType, ObjId, {X, Y}, {TargetX, TargetY}, IsFloyd, IsJump, MaxNavigateNode, Diff) ->
    Pid ! {?MSG_SCENE_REQUEST_NAVIGATE, ObjType, ObjId, {X, Y}, {TargetX, TargetY}, IsFloyd, IsJump, MaxNavigateNode, Diff}.


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([SceneWorker, MapId]) ->
    erlang:monitor(process, SceneWorker),
    mod_map:load(MapId),
    erlang:process_flag(priority, high),
    erlang:process_flag(min_heap_size, 500),
    erlang:process_flag(min_bin_vheap_size, 100000),
    {ok, #state{map_id = MapId, scene_worker = SceneWorker}}.
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({?MSG_SCENE_REQUEST_NAVIGATE, ObjType, ObjId, {X, Y}, {TargetX, TargetY}, IsFloyd, IsJump, MaxNavigateNode, Diff} = _Msg, State = #state{map_id = MapId, scene_worker = SceneWorker}) ->
    try navigate:start_2(MapId, {X, Y}, {TargetX, TargetY}, IsFloyd, IsJump, MaxNavigateNode, Diff) of
        {Result, NewMovePath} ->
            SceneWorker ! {?MSG_SCENE_NAVIGATE_RESULT, {Result, ObjType, ObjId, {TargetX, TargetY}, NewMovePath}}
    catch
        _:Reason ->
            ?ERROR("navigate fail:~p", [{Reason, {map_id, MapId}, {obj_type, ObjType}, {obj_id, ObjId}, {X, Y}, {TargetX, TargetY}, IsFloyd, MaxNavigateNode, Diff}]),
            SceneWorker ! {?MSG_SCENE_NAVIGATE_RESULT, {fail, ObjType, ObjId, {TargetX, TargetY}, []}}
    end,
    {noreply, State};
handle_info({'DOWN', _Ref, process, _, Reason}, State) ->
    {stop, Reason, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason,  #state{scene_worker = SceneWorker}) ->
    ?DEBUG("场景寻路进程销毁:~p", [{SceneWorker, _Reason}]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
