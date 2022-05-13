%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            场景管理进程
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(scene_master).
-behaviour(gen_server).
-include("scene.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("scene_master.hrl").
-include("system.hrl").
-include("msg.hrl").
%% API
-export([
    start_link/0,
    get_scene_worker/1,             %% 获取场景进程
    get_scene_worker/2,             %% 获取场景进程
    get_scene_worker/3,
    get_scene_worker/4,
    destroy_scene_worker/1,         %% 销毁场景进程
    create_mulit_mission_worker/2,  %% 创建多人副本进程
    update_scene_player_count/2,    %% 更新场景进程人数
    get_scene_worker_map/1,         %% 获取场景进程映射
    get_all_scene_worker_map/0      %% 获取所有场景进程映射
]).

-export([
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3
]).
-define(SERVER, ?MODULE).
-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
    gen_server:start_link({local, ?SCENE_MASTER}, ?MODULE, [], []).

%% ----------------------------------
%% @doc     获取场景进程
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_worker(SceneId) ->
    get_scene_worker(SceneId, []).
get_scene_worker(SceneId, ExtraDataList) ->
    get_scene_worker(0, SceneId, ExtraDataList).
get_scene_worker(PlayerId, SceneId, ExtraDataList) ->
    get_scene_worker(PlayerId, SceneId, ExtraDataList, false).
get_scene_worker(PlayerId, SceneId, ExtraDataList, IsSingle) ->
    try do_get_scene_worker(PlayerId, SceneId, ExtraDataList, IsSingle)
    catch
        _:Reason ->
            ?ERROR(
                "获取场景进程失败: \n"
                "args:~p \n"
                "reason:~p \n"
                "stacktrace:~p",
                [
                    {SceneId, ExtraDataList},
                    Reason,
                    erlang:get_stacktrace()
                ]),
            exit(get_scene_worker_fail)
    end.

%%do_get_scene_worker(PlayerId, SceneId, ExtraDataList) ->
%%    do_get_scene_worker(PlayerId, SceneId, ExtraDataList, false).
do_get_scene_worker(PlayerId, SceneId, ExtraDataList, IsSingle) ->
    #t_scene{
        id = SceneId,
        type = SceneType,
        server_type = SceneServerType,
        mission_type = MissionType
    } = mod_scene:get_t_scene(SceneId),
    ServerType = mod_server_config:get_server_type(),
    if
    %% 世界场景
        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
            if
                IsSingle == true ->
                    %% 单人副本
                    scene_worker:start(SceneId, self(), [{is_single, true}, ExtraDataList]);
                SceneServerType == ServerType ->
                    gen_server:call(?SERVER, {?MSG_GET_SCENE_WORKER, PlayerId, SceneId, ExtraDataList});
                true ->
                    ?ASSERT(mod_server:is_game_server(), {not_game_server, SceneId, node()}),
                    %% 本服
                    case SceneServerType of
                        ?SERVER_TYPE_WAR_ZONE ->
                            %% 跨服
                            mod_server_rpc:call_zone(?MODULE, get_scene_worker, [PlayerId, SceneId, ExtraDataList]);
                        ?SERVER_TYPE_WAR_AREA ->
                            %% 战区
                            mod_server_rpc:call_war(?MODULE, get_scene_worker, [PlayerId, SceneId, ExtraDataList])
                    end
            end;
    %% 副本
        SceneType == ?SCENE_TYPE_MISSION ->
            MissionKind = mod_mission:get_mission_kind(MissionType),
            if
                MissionKind == ?MISSION_KIND_SINGLE ->
                    %% 单人副本
                    scene_worker:start(SceneId, self(), ExtraDataList);
                true ->
                    if
                        SceneServerType == ServerType ->
                            gen_server:call(?SERVER, {?MSG_GET_SCENE_WORKER, PlayerId, SceneId, ExtraDataList});
                        true ->
                            ?ASSERT(mod_server:is_game_server(), {not_game_server, SceneId, node()}),
                            %% 本服
                            case SceneServerType of
                                ?SERVER_TYPE_WAR_ZONE ->
                                    %% 跨服
                                    mod_server_rpc:call_zone(?MODULE, get_scene_worker, [PlayerId, SceneId, ExtraDataList]);
                                ?SERVER_TYPE_WAR_AREA ->
                                    %% 战区
                                    mod_server_rpc:call_war(?MODULE, get_scene_worker, [PlayerId, SceneId, ExtraDataList])
                            end
                    end
            end
    end.

%% ----------------------------------
%% @doc     创建多人副本进程
%% @throws 	none
%% @end
%% ----------------------------------
create_mulit_mission_worker(SceneId, ExtraDataList) ->
    ?DEBUG("创建多人副本进程:~p~n", [SceneId]),
    #t_scene{
        id = SceneId,
        type = SceneType,
        server_type = SceneServerType,
        mission_type = MissionType
    } = mod_scene:get_t_scene(SceneId),
    ?ASSERT(SceneType == ?SCENE_TYPE_MISSION, not_mission),
    MissionKind = mod_mission:get_mission_kind(MissionType),
    ?ASSERT(MissionKind == ?MISSION_KIND_UNIQUE_MULTIPLE orelse MissionKind == ?MISSION_KIND_MULTIPLE, {mission_kind_error, SceneId, MissionType, MissionKind}),
    ServerType = mod_server_config:get_server_type(),
    if
        SceneServerType == ServerType ->
            case get_scene_worker(SceneId, ExtraDataList) of
                null ->
                    gen_server:call(?SERVER, {?MSG_CREATE_SCENE_WORKER, SceneId, ExtraDataList});
                {ok, SceneWorker} ->
                    ?WARNING("多人副本已经存在:~p", [SceneId]),
                    {ok, SceneWorker}
            end;
        true ->
            ?ASSERT(mod_server:is_game_server(), {not_game_server, SceneId, node()}),
            %% 本服
            case SceneServerType of
                ?SERVER_TYPE_WAR_ZONE ->
                    %% 跨服
                    mod_server_rpc:call_zone(?MODULE, create_mulit_mission_worker, [SceneId, ExtraDataList]);
                ?SERVER_TYPE_WAR_AREA ->
                    %% 战区
                    mod_server_rpc:call_war(?MODULE, create_mulit_mission_worker, [SceneId, ExtraDataList])
            end
    end.

%% ----------------------------------
%% @doc     销毁进程
%% @throws 	none
%% @end
%% ----------------------------------
destroy_scene_worker(SceneId) ->
    ?INFO("销毁场景进程:~p~n", [SceneId]),
    #t_scene{
        id = SceneId,
        server_type = SceneServerType
    } = mod_scene:get_t_scene(SceneId),
    ServerType = mod_server_config:get_server_type(),
    if
        SceneServerType == ServerType ->
            gen_server:call(?SERVER, {?MSG_DESTROY_SCENE_WORKER, SceneId});
        true ->
            ?ASSERT(mod_server:is_game_server(), {not_game_server, SceneId, node()}),
            %% 本服
            case SceneServerType of
                ?SERVER_TYPE_WAR_ZONE ->
                    %% 跨服
                    mod_server_rpc:call_zone(?MODULE, destroy_scene_worker, [SceneId]);
                ?SERVER_TYPE_WAR_AREA ->
                    %% 战区
                    mod_server_rpc:call_war(?MODULE, destroy_scene_worker, [SceneId])
            end
    end.

%% ----------------------------------
%% @doc     更新场景玩家数量
%% @throws 	none
%% @end
%% ----------------------------------
update_scene_player_count(SceneWorker, PlayerCount) ->
    gen_server:cast(?MODULE, {?MSG_UPDATE_SCENE_PLAYER_COUNT, SceneWorker, PlayerCount}).


%% ----------------------------------
%% @doc     获取所有场景进程映射
%% @throws 	none
%% @end
%% ----------------------------------
get_all_scene_worker_map() ->
    ets:tab2list(?ETS_SCENE_WORKER_MAP).

%% ----------------------------------
%% @doc     获取场景进程映射
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_worker_map(SceneId) ->
    case ets:lookup(?ETS_SCENE_WORKER_MAP, SceneId) of
        [] ->
            null;
        [R] ->
            R
    end.

update_scene_worker_map(SceneWorkerMap) ->
    ets:insert(?ETS_SCENE_WORKER_MAP, SceneWorkerMap).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    erlang:process_flag(priority, high),
    ServerType = mod_server_config:get_server_type(),
    case ServerType of
        ?SERVER_TYPE_GAME ->
            mod_map:init_all();
        ?SERVER_TYPE_WAR_ZONE ->
            mod_map:init_zone();
        ?SERVER_TYPE_WAR_AREA ->
            mod_map:init_war()
    end,
    trigger_check_close(),
%%    trigger_add_energy(),
    {ok, #state{}}.

handle_call({?MSG_GET_SCENE_WORKER, PlayerId, SceneId, ExtraDataList}, _From, State) ->
    try handle_get_scene_worker(PlayerId, SceneId, ExtraDataList) of
        Reply ->
            {reply, Reply, State}
    catch
        _:Reason ->
            ?ERROR("GET_SCENE_WORKER ~p error: ~p", [SceneId, {Reason, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_CREATE_SCENE_WORKER, SceneId, ExtraDataList}, _From, State) ->
    try handle_create_scene(SceneId, ExtraDataList) of
        {ok, Pid} ->
            {reply, {ok, Pid}, State}
    catch
        _:Reason ->
            ?ERROR("CREATE_SCENE_WORKER ~p error: ~p", [SceneId, Reason]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_DESTROY_SCENE_WORKER, SceneId}, _From, State) ->
    try handle_destroy_scene(SceneId) of
        _ ->
            {reply, ok, State}
    catch
        _:Reason ->
            ?ERROR("DESTROY_SCENE_WORKER ~p error: ~p", [SceneId, Reason]),
            {reply, {error, Reason}, State}
    end;
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({?MSG_UPDATE_SCENE_PLAYER_COUNT, SceneWorker, PlayerCount}, State) ->
    ?TRY_CATCH(handle_update_scene_player_count(SceneWorker, PlayerCount)),
    {noreply, State};
handle_cast(_Request, State) ->
    {noreply, State}.

%% 定时清理没用的场景进程
handle_info(check_close, State) ->
    ?TRY_CATCH(handle_check_close()),
    {noreply, State};
%% 定时增加能量值
%%handle_info(?MSG_ADD_ENERGY, State) ->
%%    ?TRY_CATCH(handle_add_energy()),
%%    {noreply, State};
%%handle_info({?MSG_SCENE_STATE_CHANGE, SceneId, NewStatus}, State) ->
%%    ?TRY_CATCH(handle_state_charge(SceneId, NewStatus)),
%%    {noreply, State};
handle_info({'DOWN', _Ref, process, SceneWorker, Reason}, State) ->
    ?TRY_CATCH(handle_scene_worker_down(SceneWorker, Reason)),
    {noreply, State};
handle_info(_Info, State) ->
    ?WARNING("scene_master unexpected_msg:~p", [_Info]),
    {noreply, State}.
terminate(_Reason, _State) ->
    ok.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%%===================================================================
%%% Internal functions
%%%===================================================================

%% ----------------------------------
%% @doc 	定时检测场景
%% @throws 	none
%% @end
%% ----------------------------------
trigger_check_close() ->
    erlang:send_after(?CHECK_CLOSE_SCENE_TIME, self(), check_close).

%% ----------------------------------
%% @doc 	定时增加能量值
%% @throws 	none
%% @end
%%%% ----------------------------------
%%trigger_add_energy() ->
%%    erlang:send_after(1000, self(), ?MSG_ADD_ENERGY).

%% ----------------------------------
%% @doc 	增加能量值
%% @throws 	none
%% @end
%% ----------------------------------
%%handle_add_energy() ->
%%    lists:foreach(
%%        fun(SceneId) ->
%%            case get_scene_worker_map(SceneId) of
%%                null ->
%%                    noop;
%%                SceneWorkerMap ->
%%                    #ets_scene_worker_map{
%%                        energy = Energy,
%%                        energy_list = EnergyList,
%%                        state = State,
%%                        scene_worker_info_list = SceneWorkerInfoList
%%%%                        boss_data = BossData
%%                    } = SceneWorkerMap,
%%                    #t_scene{
%%%%                        boss_mission_list = BossMissionList,
%%%%                        monster_energy = MonsterEnergy,
%%%%                        boss_energy = BossEnergy,
%%                        yuchao_time = YuChaoTime,
%%                        energy_up_time_list = EnergyUpTimeList,
%%                        energy_list = ConfigEnergyList,
%%                        boss_x_y_list = BossXYList
%%                    } = mod_scene:get_t_scene(SceneId),
%%
%%                    EnergyList1 =
%%                        if
%%                            EnergyList == [] ->
%%                                lists:keysort(1, [{NeedEnergy1, Type1, ConfigList1} || [NeedEnergy1, Type1, ConfigList1] <- ConfigEnergyList]);
%%                            true ->
%%                                EnergyList
%%                        end,
%%
%%                    if
%%                        EnergyList1 == [] ->
%%                            noop;
%%                        true ->
%%                            [{NeedEnergy, Type, ConfigList} | EnergyList2] = EnergyList1,
%%                            case State of
%%                                ?SCENE_MASTER_STATE_MONSTER ->
%%                                    TotalCount = lists:sum([Count || #scene_worker_info{count = Count} <- SceneWorkerInfoList]),
%%                                    AddEnergy = util_list:get_value_from_range_list(TotalCount, EnergyUpTimeList),
%%                                    NewEnergy = Energy + AddEnergy,
%%                                    Now = util_time:milli_timestamp(),
%%                                    NewSceneWorkerMap =
%%                                        if
%%                                            NewEnergy >= NeedEnergy ->
%%                                                case Type of
%%                                                    %% 鱼潮
%%                                                    1 ->
%%                                                        ?DEBUG("鱼潮"),
%%                                                        lists:foreach(
%%                                                            fun(#scene_worker_info{scene_worker = SceneWorker}) ->
%%                                                                SceneWorker ! {?MSG_SCENE_STATE_CHANGE, ?SCENE_MASTER_STATE_YU_CHAO, Now}
%%                                                            end, SceneWorkerInfoList
%%                                                        ),
%%                                                        erlang:send_after(YuChaoTime + 10000, self(), {?MSG_SCENE_STATE_CHANGE, SceneId, ?SCENE_MASTER_STATE_MONSTER}),
%%                                                        SceneWorkerMap#ets_scene_worker_map{
%%                                                            energy = ?IF(EnergyList2 == [], 0, NeedEnergy),
%%                                                            state = ?SCENE_MASTER_STATE_YU_CHAO,
%%                                                            state_start_time = Now,
%%                                                            energy_list = EnergyList2
%%                                                        };
%%                                                    %% 主场景boss
%%                                                    2 ->
%%                                                        ?DEBUG("主场景boss"),
%%                                                        BossId = util_random:get_probability_item(ConfigList),
%%                                                        #t_monster{
%%                                                            destroy_time = DestroyTime
%%                                                        } = mod_scene_monster_manager:get_t_monster(BossId),
%%                                                        BossList = util_random:get_list_random_member(BossXYList),
%%                                                        lists:foreach(
%%                                                            fun(#scene_worker_info{scene_worker = SceneWorker}) ->
%%                                                                SceneWorker ! {?MSG_SCENE_STATE_CHANGE, ?SCENE_MASTER_STATE_BOSS, {BossId, BossList}, Now}
%%                                                            end, SceneWorkerInfoList
%%                                                        ),
%%                                                        erlang:send_after(DestroyTime, self(), {?MSG_SCENE_STATE_CHANGE, SceneId, ?SCENE_MASTER_STATE_MONSTER}),
%%                                                        SceneWorkerMap#ets_scene_worker_map{
%%                                                            energy = ?IF(EnergyList2 == [], 0, NeedEnergy),
%%                                                            state = ?SCENE_MASTER_STATE_BOSS,
%%                                                            state_start_time = Now,
%%                                                            energy_list = EnergyList2,
%%                                                            boss_data = {BossId, BossList}
%%                                                        }
%%                                                end;
%%                                            true ->
%%                                                SceneWorkerMap#ets_scene_worker_map{
%%                                                    energy = NewEnergy
%%                                                }
%%                                        end,
%%                                    update_scene_worker_map(NewSceneWorkerMap);
%%%%                                ?SCENE_MASTER_STATE_COMMON2 ->
%%%%                                    TotalCount = lists:sum([Count || #scene_worker_info{count = Count} <- SceneWorkerInfoList]),
%%%%                                    AddEnergy = util_list:get_value_from_range_list(TotalCount, EnergyUpTimeList),
%%%%                                    NewEnergy = Energy + AddEnergy,
%%%%                                    NewSceneWorkerMap =
%%%%                                        if
%%%%                                            NewEnergy >= BossEnergy ->
%%%%                                                RandomBossDataList =
%%%%                                                    if
%%%%                                                        BossData == ?UNDEFINED ->
%%%%                                                            [{[ThisMissionType, ThisMissionId, ThisWaitTime, Weight], Weight} || [ThisMissionType, ThisMissionId, ThisWaitTime, Weight] <- BossMissionList];
%%%%                                                        true ->
%%%%                                                            [{[ThisMissionType, ThisMissionId, ThisWaitTime, Weight], Weight} || [ThisMissionType, ThisMissionId, ThisWaitTime, Weight] <- lists:delete(BossData, BossMissionList)]
%%%%                                                    end,
%%%%                                                NewBossData = util_random:get_probability_item(RandomBossDataList),
%%%%                                                [MissionType, _MissionId, WaitTime, _] = NewBossData,
%%%%                                                Now = util_time:milli_timestamp(),
%%%%                                                #t_mission_type{
%%%%                                                    continue_time = ContinueTime,
%%%%                                                    delay_time = DelayTune
%%%%                                                } = mod_mission:get_t_mission_type(MissionType),
%%%%                                                scene_boss_master:cast({open_boss, SceneId, Now + ContinueTime + DelayTune, Now + WaitTime * 1000}),
%%%%                                                erlang:send_after(ContinueTime + DelayTune, self(), {?MSG_SCENE_STATE_CHANGE, SceneId, ?SCENE_MASTER_STATE_COMMON1}),
%%%%                                                lists:foreach(
%%%%                                                    fun(#scene_worker_info{scene_worker = SceneWorker}) ->
%%%%                                                        SceneWorker ! {?MSG_SCENE_STATE_CHANGE, ?SCENE_MASTER_STATE_BOSS, NewBossData, Now}
%%%%                                                    end, SceneWorkerInfoList
%%%%                                                ),
%%%%                                                SceneWorkerMap#ets_scene_worker_map{
%%%%                                                    energy = 0,
%%%%                                                    state = ?SCENE_MASTER_STATE_BOSS,
%%%%                                                    state_start_time = Now,
%%%%                                                    boss_data = NewBossData
%%%%                                                };
%%%%                                            true ->
%%%%                                                SceneWorkerMap#ets_scene_worker_map{
%%%%                                                    energy = NewEnergy
%%%%                                                }
%%%%                                        end,
%%%%                                    update_scene_worker_map(NewSceneWorkerMap);
%%                                _ ->
%%                                    noop
%%                            end
%%                    end
%%            end
%%        end, logic_get_all_hook_scene_id:get(0)
%%    ),
%%    trigger_add_energy().

%% ----------------------------------
%% @doc 	场景状态改变
%% @throws 	none
%% @end
%% ----------------------------------
%%handle_state_charge(SceneId, NewStatus) ->
%%    case get_scene_worker_map(SceneId) of
%%        null ->
%%            noop;
%%        SceneWorkerMap ->
%%            update_scene_worker_map(SceneWorkerMap#ets_scene_worker_map{state = NewStatus, state_start_time = util_time:milli_timestamp()}),
%%            case NewStatus of
%%                ?SCENE_MASTER_STATE_MONSTER ->
%%                    #ets_scene_worker_map{
%%                        scene_worker_info_list = SceneWorkerInfoList
%%                    } = SceneWorkerMap,
%%                    lists:foreach(
%%                        fun(#scene_worker_info{scene_worker = SceneWorker}) ->
%%                            SceneWorker ! {?MSG_SCENE_STATE_CHANGE, ?SCENE_MASTER_STATE_MONSTER, util_time:milli_timestamp()}
%%                        end, SceneWorkerInfoList
%%                    );
%%                _ ->
%%                    noop
%%            end
%%    end.

%% ----------------------------------
%% @doc 	处理场景进程down
%% @throws 	none
%% @end
%% ----------------------------------
handle_scene_worker_down(SceneWorker, Reason) ->
    SceneId = erase(SceneWorker),
    if Reason =/= normal ->
        ?ERROR("Scene mgr receive scene(~p) down:~p", [SceneId, Reason]);
        true ->
            noop
    end,
    case get_scene_worker_map(SceneId) of
        null ->
            ?ERROR("No found:~p!", [SceneId]);
        R ->
            ?WARNING("handle_scene_worker_down:~p", [{SceneWorker, Reason}]),
            NewSceneWorkerList =
                lists:keydelete(
                    SceneWorker,
                    #scene_worker_info.scene_worker,
                    R#ets_scene_worker_map.scene_worker_info_list
                ),
            update_scene_worker_map(R#ets_scene_worker_map{scene_worker_info_list = NewSceneWorkerList})
    end.

%% ----------------------------------
%% @doc 	定时检测关闭
%% @throws 	none
%% @end
%% ----------------------------------
handle_check_close() ->
    SceneWorkerMapList = ets:tab2list(?ETS_SCENE_WORKER_MAP),
    lists:foreach(
        fun(SceneWorkerMap) ->
            #ets_scene_worker_map{
                scene_id = SceneId,
                scene_worker_info_list = SceneWorkerInfoList
            } = SceneWorkerMap,
            #t_scene{
                type = SceneType,
                mission_type = MissionType,
                max_player = MaxPlayerCount
            } = mod_scene:get_t_scene(SceneId),

            NewSceneWorkerInfoList =
                if
                %% 世界场景
                    SceneType == ?SCENE_TYPE_WORLD_SCENE ->
                        %% 人数最多的分线不会被检测
                        [Head | Left] = util_list:rkeysort(#scene_worker_info.count, SceneWorkerInfoList),
%%                        LeftSceneWorkerInfo = erlang:hd(SceneWorkerInfoList1),
%%                        SceneWorkerInfoList2 = SceneWorkerInfoList1 -- [LeftSceneWorkerInfo],
                        Left2 =
                            lists:foldl(
                                fun(SceneWorkerStatus, TmpList) ->
                                    #scene_worker_info{
                                        scene_worker = SceneWorker,
                                        count = PlayerCount,
                                        status = Status,
                                        monitor_ref = MonitorRef
                                    } = SceneWorkerStatus,

                                    if
                                    %% 关闭没人的分线
                                        PlayerCount =< 0 andalso MaxPlayerCount > 0 ->
                                            case Status of
                                                ?SCENE_WORKER_STATUS_NORMAL ->
                                                    [
                                                        %% 设置为不可连接状态
                                                        SceneWorkerStatus#scene_worker_info{
                                                            status = ?SCENE_WORKER_STATUS_WAIT_CLOSE
                                                        }
                                                        | TmpList
                                                    ];
                                                ?SCENE_WORKER_STATUS_WAIT_CLOSE ->
                                                    %% 执行关闭
                                                    erlang:demonitor(MonitorRef),
                                                    scene_worker:stop(SceneWorker),
                                                    TmpList
                                            end;
                                        true ->
                                            [SceneWorkerStatus | TmpList]
                                    end
                                end,
                                [],
                                Left
                            ),
                        [Head | Left2];
                    true ->
                        lists:foldl(
                            fun(SceneWorkerStatus, TmpList) ->
                                #scene_worker_info{
                                    scene_worker = SceneWorker,
                                    count = PlayerCount,
                                    status = Status,
                                    monitor_ref = MonitorRef
                                } = SceneWorkerStatus,
                                MissionKind = mod_mission:get_mission_kind(MissionType),
                                %% 注 多人唯一副本 和 多人副本 不会检测
                                if PlayerCount =< 0 andalso MissionKind =/= ?MISSION_KIND_UNIQUE_MULTIPLE andalso MissionKind =/= ?MISSION_KIND_MULTIPLE ->
                                    case Status of
                                        ?SCENE_WORKER_STATUS_NORMAL ->
                                            [
                                                SceneWorkerStatus#scene_worker_info{
                                                    status = ?SCENE_WORKER_STATUS_WAIT_CLOSE
                                                }
                                                | TmpList
                                            ];
                                        ?SCENE_WORKER_STATUS_WAIT_CLOSE ->
                                            erlang:demonitor(MonitorRef),
                                            scene_worker:stop(SceneWorker),
                                            TmpList
                                    end;
                                    true ->
                                        [SceneWorkerStatus | TmpList]
                                end
                            end,
                            [],
                            SceneWorkerInfoList
                        )
                end,
            update_scene_worker_map(SceneWorkerMap#ets_scene_worker_map{scene_worker_info_list = NewSceneWorkerInfoList})
        end,
        SceneWorkerMapList
    ),
    trigger_check_close().

%% ----------------------------------
%% @doc 	更新场景玩家数量
%% @throws 	none
%% @end
%% ----------------------------------
handle_update_scene_player_count(SceneWorker, PlayerCount) ->
    SceneId = get(SceneWorker),
    case get_scene_worker_map(SceneId) of
        null ->
            noop;
        SceneWorkerMap ->
            SceneWorkerInfoList = SceneWorkerMap#ets_scene_worker_map.scene_worker_info_list,
            NewSceneWorkerList =
                case lists:keytake(SceneWorker, #scene_worker_info.scene_worker, SceneWorkerInfoList) of
                    {value, SceneWorkerInfo, Left} ->
                        [
                            SceneWorkerInfo#scene_worker_info{
                                count = PlayerCount
                            }
                            |
                            Left
                        ];
                    false ->
                        ?ERROR("none map:~p~n", [{SceneId, SceneWorker, PlayerCount}]),
                        [
                            #scene_worker_info{
                                scene_worker = SceneWorker,
                                count = PlayerCount,
                                status = ?SCENE_WORKER_STATUS_NORMAL
                            }
                            |
                            SceneWorkerInfoList
                        ]
                end,
            update_scene_worker_map(SceneWorkerMap#ets_scene_worker_map{scene_worker_info_list = NewSceneWorkerList})
    end.

%% ----------------------------------
%% @doc 	获取场景进程
%% @throws 	none
%% @end
%% ----------------------------------
handle_get_scene_worker(PlayerId, SceneId, ExtraDataList) ->
    SceneWorkerMap =
        case get_scene_worker_map(SceneId) of
            null ->
                SceneWorkerMap_ = #ets_scene_worker_map{
                    scene_id = SceneId,
                    scene_worker_info_list = []
                },
                update_scene_worker_map(SceneWorkerMap_),
                SceneWorkerMap_;
            SceneWorkerMap_ ->
                SceneWorkerMap_
        end,
    #ets_scene_worker_map{
        scene_worker_info_list = SceneWorkerInfoList
    } = SceneWorkerMap,

    #t_scene{
        type = SceneType,
        mission_type = MissionType,
        max_player = MaxPlayerCount
%%        is_rember_line = IsRememberLine
    } = mod_scene:get_t_scene(SceneId),
    IsRememberLine = ?FALSE,
    LineFun =
        fun() ->
            {MatchSceneWorker, NewSceneWorkerInfoList} =
                lists:foldl(
                    fun(SceneWorkerInfo, {TmpSceneWorker, TmpSceneWorkerInfoList}) ->
                        #scene_worker_info{
                            scene_worker = ThisSceneWorker,
                            count = ThisPlayerCount,
                            status = ThisStatus,
                            player_id_list = PlayerIdList
                        } = SceneWorkerInfo,
                        if
                            TmpSceneWorker == null ->
                                case IsRememberLine of
                                    ?TRUE ->
                                        %% 记忆分线
                                        ?t_assert(PlayerId > 0),
                                        case lists:member(PlayerId, PlayerIdList) of
                                            true ->
                                                {ThisSceneWorker, [SceneWorkerInfo | TmpSceneWorkerInfoList]};
                                            false ->
                                                if
                                                %% 寻找状态正常 并且 人数<最大人数的分线
                                                    ThisStatus == ?SCENE_WORKER_STATUS_NORMAL andalso
                                                        (MaxPlayerCount == 0 orelse ThisPlayerCount < MaxPlayerCount) ->
                                                        NewSceneWorkerInfo = SceneWorkerInfo#scene_worker_info{
                                                            player_id_list = [PlayerId | PlayerIdList]
                                                        },
                                                        {ThisSceneWorker, [NewSceneWorkerInfo | TmpSceneWorkerInfoList]};
                                                    true ->
                                                        {null, [SceneWorkerInfo | TmpSceneWorkerInfoList]}
                                                end
                                        end;
                                    _ ->
                                        %% 分线是否允许加入
                                        case scene_worker:is_allow_enter_scene_worker(PlayerId, MaxPlayerCount, ThisSceneWorker) of
                                            true ->
                                                if
                                                %% 寻找状态正常 并且 人数<最大人数的分线
                                                    ThisStatus == ?SCENE_WORKER_STATUS_NORMAL andalso
                                                        (MaxPlayerCount == 0 orelse ThisPlayerCount < MaxPlayerCount) ->
                                                        {ThisSceneWorker, [SceneWorkerInfo | TmpSceneWorkerInfoList]};
                                                    true ->
                                                        {null, [SceneWorkerInfo | TmpSceneWorkerInfoList]}
                                                end;
                                            false ->
                                                {null, [SceneWorkerInfo | TmpSceneWorkerInfoList]}
                                        end
                                end;
                            true ->
                                {TmpSceneWorker, [SceneWorkerInfo | TmpSceneWorkerInfoList]}
                        end
                    end,
                    {null, []},
                    %% 优先匹配 人数最多的分线
                    util_list:rkeysort(#scene_worker_info.count, SceneWorkerInfoList)
                ),
            if
            %% 没有找到合适的分线
                MatchSceneWorker == null ->
                    %% 创建新的分线
%%                    handle_create_scene(PlayerId, SceneId, [{scene_master_state, {State, StateStartTime}},{scene_master_boss_data,BossData} | ExtraDataList]);
                    handle_create_scene(PlayerId, SceneId, ExtraDataList);
                true ->
                    NewSceneWorkerMap =
                        SceneWorkerMap#ets_scene_worker_map{
                            scene_worker_info_list = NewSceneWorkerInfoList
                        },
                    update_scene_worker_map(NewSceneWorkerMap),
                    {ok, MatchSceneWorker}
            end
        end,
    if
    %% 世界场景
        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
            LineFun();
    %% 副本
        SceneType == ?SCENE_TYPE_MISSION ->
            MissionKind = mod_mission:get_mission_kind(MissionType),
            if
            %% 多人副本
                MissionKind == ?MISSION_KIND_MULTIPLE ->
                    handle_create_scene(SceneId, ExtraDataList);
            %% 多人分线副本
                MissionKind == ?MISSION_KIND_LINE_MULTIPLE ->
                    LineFun();
            %% 多人唯一副本
                MissionKind == ?MISSION_KIND_UNIQUE_MULTIPLE ->
                    if
                        SceneWorkerInfoList == [] -> %% 不自动创建
                            null;
                        true ->
                            #scene_worker_info{
                                scene_worker = SceneWorker
                            } = hd(SceneWorkerInfoList),
                            {ok, SceneWorker}
                    end
            end
    end.

%% ----------------------------------
%% @doc     创建场景进程
%% @throws 	none
%% @end
%% ----------------------------------
handle_create_scene(SceneId, ExtraDataList) ->
    handle_create_scene(0, SceneId, ExtraDataList).
handle_create_scene(PlayerId, SceneId, ExtraDataList) ->
%%    #t_scene{
%%%%        is_rember_line = IsRememberLine
%%    } = mod_scene:get_t_scene(SceneId),
    IsRememberLine = ?FALSE,

    %% 启动场景进程
    {ok, SceneWorker} = scene_worker:start(SceneId, self(), ExtraDataList),

    %%  存放 进程 和 场景id 的映射
    put(SceneWorker, SceneId),
    MonitorRef = erlang:monitor(process, SceneWorker),

    SceneWorkerInfo = #scene_worker_info{
        scene_worker = SceneWorker,
        monitor_ref = MonitorRef,
        count = 0,
        status = ?SCENE_WORKER_STATUS_NORMAL
    },
    SceneWorkerInfo_1 =
        case IsRememberLine of
            ?TRUE ->
%%        if
%%            IsRememberLine == ?TRUE ->
                ?t_assert(PlayerId > 0),
                SceneWorkerInfo#scene_worker_info{
                    player_id_list = [PlayerId]
                };
            _ ->
                SceneWorkerInfo
        end,
    NewSceneWorkerMap =
        case get_scene_worker_map(SceneId) of
            null ->
                #ets_scene_worker_map{
                    scene_id = SceneId,
                    scene_worker_info_list = [SceneWorkerInfo_1]
                };
            R ->
                NewL = [SceneWorkerInfo_1 | R#ets_scene_worker_map.scene_worker_info_list],
                R#ets_scene_worker_map{scene_worker_info_list = NewL}
        end,
    update_scene_worker_map(NewSceneWorkerMap),
    {ok, SceneWorker}.

%% ----------------------------------
%% @doc     销毁场景进程
%% @throws 	none
%% @end
%% ----------------------------------
handle_destroy_scene(SceneId) ->
    case get_scene_worker_map(SceneId) of
        null ->
            noop;
        R ->
            lists:foreach(
                fun(SceneWorkerInfo) ->
                    #scene_worker_info{
                        scene_worker = SceneWorker,
                        monitor_ref = MonitorRef
                    } = SceneWorkerInfo,
                    erlang:demonitor(MonitorRef),
%%                    erlang:unlink(SceneWorker),
                    scene_worker:stop(SceneWorker)
                end,
                R#ets_scene_worker_map.scene_worker_info_list
            ),
            update_scene_worker_map(R#ets_scene_worker_map{scene_worker_info_list = []})
    end.
