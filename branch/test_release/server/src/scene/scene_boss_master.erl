%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         场景boss管理者
%%% @end
%%% Created : 14. 五月 2021 下午 04:43:31
%%%-------------------------------------------------------------------
-module(scene_boss_master).
-author("Administrator").

-behaviour(gen_server).

-include("msg.hrl").
-include("common.hrl").
-include("scene.hrl").
-include("gen/table_db.hrl").
-include("mission.hrl").

%% API
-export([
    start_link/0
]).

%% gen_server callbacks
-export([
    init/1,
    call/1,
    cast/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).

-export([
    notice_player_scene_boss_state/3
]).

-define(SERVER, ?MODULE).

-record(state, {scene_boss_list = []}).

-spec(start_link() ->
    {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

-spec(init(Args :: term()) ->
    {ok, State :: #state{}} | {ok, State :: #state{}, timeout() | hibernate} |
    {stop, Reason :: term()} | ignore).
init([]) ->
    {ok, #state{}}.

call(Msg) ->
    gen_server:call(?MODULE, Msg).
cast(Msg) ->
    gen_server:cast(?MODULE, Msg).

%%handle_call({?MSG_SCENE_CHALLENGE_BOSS, PlayerId, SceneId, MissionType, MissionId}, _From, State) ->
%%    try handle_challenge_boss(PlayerId, SceneId, MissionType, MissionId, State) of
%%        {Reply, NewState} ->
%%            {reply, Reply, NewState}
%%    catch
%%        _:Reason ->
%%            ?ERROR("CHALLENGE_BOSS ~p error: ~p", [{SceneId, MissionType, MissionId}, {Reason, erlang:get_stacktrace()}]),
%%            {reply, {error, Reason}, State}
%%    end;
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%handle_cast({?MSG_SCENE_PLAYER_SCENE_BOSS_STATE, PlayerId, SceneId, Out}, State) ->
%%    try handle_player_scene_boss_state(PlayerId, SceneId, Out, State) of
%%        _ ->
%%            {noreply, State}
%%    catch
%%        _:Reason ->
%%            ?ERROR("PLAYER_SCENE_BOSS_STATE ~p error: ~p", [{PlayerId, SceneId, Out}, {Reason, erlang:get_stacktrace()}]),
%%            {noreply, State}
%%    end;
handle_cast({open_boss, SceneId, CloseTime, WaitTime}, State) ->
    try handle_open_boss(SceneId, CloseTime, WaitTime, State) of
        NewState ->
            {noreply, NewState}
    catch
        _:Reason ->
            ?ERROR("open_boss ~p error: ~p", [{SceneId, CloseTime}, {Reason, erlang:get_stacktrace()}]),
            {noreply, State}
    end;
handle_cast({close_boss_mission, SceneWorker, SceneId, PlayerIdList}, State) ->
    try handle_close_boss_mission(SceneId, SceneWorker, PlayerIdList, State) of
        NewState ->
            {noreply, NewState}
    catch
        _:Reason ->
            ?ERROR("close_boss_mission ~p error: ~p", [{SceneId, SceneWorker, PlayerIdList}, {Reason, erlang:get_stacktrace()}]),
            {noreply, State}
    end;
handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

handle_open_boss(SceneId, CloseTime, WaitTime, State) ->
    SceneBossList = State#state.scene_boss_list,
    NewSceneBossList =
        case lists:keytake(SceneId, 1, SceneBossList) of
            false ->
                [{SceneId, {?UNDEFINED, 0, [], CloseTime, WaitTime}} | SceneBossList];
            {value, _Tuple, List2} ->
                [{SceneId, {?UNDEFINED, 0, [], CloseTime, WaitTime}} | List2]
        end,
    State#state{scene_boss_list = NewSceneBossList}.

notice_player_scene_boss_state(PlayerId, SceneId, ?UNDEFINED) ->
    ?ERROR("不通知boss状态~p", [{PlayerId, SceneId, util_time:timestamp()}]),
    noop;
notice_player_scene_boss_state(PlayerId, _SceneId, Out) ->
    mod_socket:send(PlayerId, Out).
%%notice_player_scene_boss_state(PlayerId, SceneId, Out) ->
%%    cast({?MSG_SCENE_PLAYER_SCENE_BOSS_STATE, PlayerId, SceneId, Out}).
%%handle_player_scene_boss_state(PlayerId, SceneId, Out, State) ->
%%    SceneBossList = State#state.scene_boss_list,
%%    IsSend = get_is_can_challenge_boss(PlayerId, SceneId, SceneBossList),
%%    if
%%        IsSend ->
%%            mod_socket:send(PlayerId, Out);
%%        true ->
%%            noop
%%    end.
get_is_can_challenge_boss(PlayerId, SceneId, SceneBossList) ->
%%    ?DEBUG("data ~p", [{PlayerId, SceneId, SceneBossList}]),
    case lists:keytake(SceneId, 1, SceneBossList) of
        false ->
            false;
        {value, Tuple, _List2} ->
            {_, {_SceneWorker, _Num, PlayerList, CloseTime, _}} = Tuple,
            case CloseTime > util_time:milli_timestamp() of
                true ->
                    case lists:keytake(PlayerId, 1, PlayerList) of
                        false ->
                            true;
                        {value, {PlayerId, _ThisPlayerSceneWorker, IsCanChallenge}, _PlayerList2} ->
                            IsCanChallenge
                    end;
                false ->
                    false
            end
    end.

%% @doc 关闭场景boss副本
handle_close_boss_mission(SceneId, CloseSceneWorker, ClosePlayerIdList, State) ->
%%    ?DEBUG("关闭场景boss副本~p",[{SceneId, CloseSceneWorker, ClosePlayerIdList, State}]),
    SceneBossList = State#state.scene_boss_list,
    NewSceneBossList =
        case lists:keytake(SceneId, 1, SceneBossList) of
            false ->
                SceneBossList;
            {value, Tuple, List2} ->
                {SceneId, {SceneWorker, Num, PlayerList, CloseTime, A}} = Tuple,
                NewPlayerList =
                    lists:foldl(
                        fun(ClosePlayerId, TmpList) ->
                            case lists:keytake(ClosePlayerId, 1, TmpList) of
                                false ->
                                    ?ERROR("不应该出现的错误 ~p", [{SceneId, CloseSceneWorker, ClosePlayerIdList, State, ClosePlayerId}]),
                                    [{ClosePlayerId, CloseSceneWorker, false} | TmpList];
                                {value, {ClosePlayerId, ThisPlayerSceneWorker, _IsCanChallenge}, PlayerList2} ->
                                    [{ClosePlayerId, ThisPlayerSceneWorker, false} | PlayerList2]
                            end
                        end, PlayerList,
                        ClosePlayerIdList
                    ),
                if
                    CloseSceneWorker =:= SceneWorker ->
                        [{SceneId, {?UNDEFINED, 0, NewPlayerList, CloseTime, A}} | List2];
                    true ->
                        [{SceneId, {SceneWorker, Num, NewPlayerList, CloseTime, A}} | List2]
                end
        end,
    State#state{scene_boss_list = NewSceneBossList}.

handle_challenge_boss(PlayerId, SceneId, MissionType, MissionId, State) ->
%%    ?DEBUG("chanllenge_boss_data ~p", [{PlayerId, SceneId, MissionType, MissionId}]),
    SceneBossList = State#state.scene_boss_list,

    MissionSceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
    #t_scene{
        max_player = MaxPlayerNum
    } = mod_scene:get_t_scene(MissionSceneId),
    IsCanChallengeBoss = get_is_can_challenge_boss(PlayerId, SceneId, SceneBossList),
    if
        IsCanChallengeBoss ->
            case lists:keytake(SceneId, 1, SceneBossList) of
                false ->
                    {?UNDEFINED, State};
                {value, Tuple, List2} ->
                    {_, {SceneWorker, Num, PlayerList, CloseTime, WaitTime}} = Tuple,
                    if
                        SceneWorker == ?UNDEFINED ->
                            {ok, NewSceneWorker} = scene_worker:start(MissionSceneId, self(), [{mission_id, MissionId}, {?DICT_MISSION_SCENE_BOSS_BALANCE_MS, CloseTime}, {?DICT_MISSION_SCENE_BOSS_WAIT_TIME, WaitTime}, {scene_boss_master_boss_id, SceneId}]),
                            {NewSceneWorker, State#state{scene_boss_list = [{SceneId, {NewSceneWorker, 1, [{PlayerId, NewSceneWorker, true} | PlayerList], CloseTime, WaitTime}} | List2]}};
                        Num + 1 >= MaxPlayerNum ->
                            {SceneWorker, State#state{scene_boss_list = [{SceneId, {?UNDEFINED, 0, [{PlayerId, SceneWorker, true} | PlayerList], CloseTime, WaitTime}} | List2]}};
                        true ->
                            {SceneWorker, State#state{scene_boss_list = [{SceneId, {SceneWorker, Num + 1, [{PlayerId, SceneWorker, true} | PlayerList], CloseTime, WaitTime}} | List2]}}
                    end
            end;
        true ->
            {?UNDEFINED, State}
    end.
