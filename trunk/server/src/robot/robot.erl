-module(robot).

-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("gen/db.hrl").
-include("common.hrl").
-include("scene.hrl").
-include("robot.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("skill.hrl").
-include("fight.hrl").
-compile(export_all).

%%-define(PLAYER, 1015970880).

start() ->
%%    ServerId = hd(util:shuffle(mod_server:get_server_id_list())),
    ServerId = mod_server:get_server_id(),
    AccId = create_acc_id(),
    start(AccId, ServerId, util_random:random_number(50 * ?MINUTE_MS, 240 * ?MINUTE_MS)).

create_acc_id() ->
    AccId = util:get_dict(dict_robot_acc_uid, 0) + 1,
    put(dict_robot_acc_uid, AccId),
    "robot_" ++ integer_to_list(AccId).

check_robot_create_name() ->
    check_robot_create_name(50).

check_robot_create_name(0) ->
    exit(null_check_robot_create_name);
check_robot_create_name(NoopCont) ->
    {Sex, NickName} = random_name:get_name(),
    case mod_player:get_player_list_by_nickname(NickName) of
        [] ->
            {Sex, NickName};
        _ ->
            check_robot_create_name(NoopCont - 1)
    end.

%%start(PlayerId) ->
%%    start(PlayerId, util_random:random_number(50 * ?MINUTE_MS, 120 * ?MINUTE_MS)).
%%start(PlayerId, LiveTime) ->
%%    ?INFO("调用机器人:~p~n", [{PlayerId, LiveTime, mod_online:is_online(PlayerId), mod_online:get_robot_online_count()}]),
%%    case mod_online:is_online(PlayerId) of
%%        true ->
%%            case mod_obj_player:get_obj_player(PlayerId) of
%%                null ->
%%                    ?WARNING("no obj_player:~p", [PlayerId]);
%%                ObjPlayer ->
%%                    if ObjPlayer#obj_player.robot_worker == null ->
%%                        ?WARNING("no robot_worker:~p", [PlayerId]);
%%                        true ->
%%                            ObjPlayer#obj_player.robot_worker ! {reset_stop_timer, LiveTime}
%%                    end
%%            end,
%%            already_online;
%%        false ->
%%            Player = mod_player:get_db_player(PlayerId),
%%            #db_player{
%%                acc_id = AccId,
%%                server_id = ServerId
%%            } = Player,
%%            start(AccId, ServerId, LiveTime)
%%    end.

start(AccId, ServerId, LiveTime) ->
    Port = mod_server_config:get_tcp_listen_port(),
    PlatformId = mod_server_config:get_platform_id(),
    spawn(fun() -> do_start("localhost", Port, PlatformId, ServerId, AccId, LiveTime) end).


do_start(Host, Port, PlatformId, ServerId, AccId, LiveTime) ->
    ?INIT_PROCESS_TYPE(?PROCESS_TYPE_ROBOT_WORKER),
    init_acc_id(AccId),
    put(server_id, ServerId),
    put(platform_id, PlatformId),
    init_stop_timer(LiveTime),
    {ok, Socket} = gen_tcp:connect(Host, Port, [binary, {packet, 0}, {active, 200}]),
    put(socket, Socket),
    put(?ROBOT_DICT_SEQ, 0),
    robot_socket:ws_request(),
    util:sleep(4000),
    robot_socket:request_login(),
    erlang:send_after(10 * ?SECOND_MS, self(), socket_heart_beat),
    put(?ROBOT_DICT_IS_START, false),
    put(?ROBOT_DICT_TOUCH_DISTANCE, util_random:random_number(85, 105)),
    erlang:send_after(5 * ?MINUTE_MS, self(), gc),

    ScenePlayerTid = ets:new(?ROBOT_DICT_SCENE_PLAYER_TABLE, [set, public, {keypos, #scene_player.id}]),
    put(?ROBOT_DICT_SCENE_PLAYER_TABLE, ScenePlayerTid),
    SceneMonsterTid = ets:new(?ROBOT_DICT_SCENE_MONSTER_TABLE, [set, public, {keypos, #scene_monster.id}]),
    put(?ROBOT_DICT_SCENE_MONSTER_TABLE, SceneMonsterTid),
    SceneItemTid = ets:new(?ROBOT_DICT_SCENE_ITEM_TABLE, [set, public, {keypos, #scene_item.id}]),
    put(?ROBOT_DICT_SCENE_ITEM_TABLE, SceneItemTid),

    robot_loop:loop(Socket, #state{}).

init_stop_timer(LiveTime) ->
    StopTimerRef = erlang:start_timer(LiveTime, self(), stop),
    put(stop_timer_ref, StopTimerRef).

reset_stop_timer(LiveTime) ->
    StopTimerRef = get(stop_timer_ref),
    erlang:cancel_timer(StopTimerRef),
    init_stop_timer(LiveTime).

stop(Pid) ->
    Pid ! stop.

handle_check_close(PlayerId) ->
    LastFightTime = get(?ROBOT_DICT_LAST_FIGHT_TIME),
    Now = util_time:timestamp(),
    if Now - LastFightTime > 60 * 10 ->
        Robot = get_robot(PlayerId),
        #robot{
            player_id = PlayerId
        } = Robot,
        ?ERROR("no_fight_too_long_time:~p~n",
            [{
                PlayerId,
                Robot
            }]),
        clock_check_close(PlayerId);
        true ->
            clock_check_close(PlayerId)
    end.

clock_check_close(PlayerId) ->
    erlang:send_after(5 * ?MINUTE_MS, self(), {check_close, PlayerId}).

%%move(Robot, Now, MapId, {FX, FY}, {TX, TY}) ->
%%    move(Robot, Now, MapId, {FX, FY}, {TX, TY}, ?MOVE_TYPE_NORMAL).
%%
%%move(Robot, Now, MapId, {FX, FY}, {TX, TY}, Type) ->
%%    move(Robot, Now, MapId, {FX, FY}, {TX, TY}, Type, 0).
move(Robot, _Now, _MapId, {FX, FY}, {FX, FY}, _Type, _Diff) ->
    Robot;
move(Robot, Now, MapId, {FX, FY}, {TX, TY}, Type, Diff) ->
    case catch navigate:start_2(MapId, {FX, FY}, {TX, TY}, true, 5000, Diff) of
        {'EXIT', Reason} ->
            ?ERROR("no_find_path:~p~n", [{Reason, MapId, {FX, FY}, {TX, TY}}]),
            exit(Reason);
        [] ->
            ?ERROR("no_find_path:~p~n", [{MapId, {FX, FY}, {TX, TY}}]),
            exit(no_find_path);
        {false, [{NewX, NewY}]} ->
            Robot#robot{
                move_path = [],
                last_move_time = Now,
                go_x = NewX,
                go_y = NewY
            };
        {success, Path} ->
            robot_socket:request_move(Type, TX, TY),
            put(?ROBOT_DICT_MOVE_TYPE, Type),
            if Robot#robot.player_id == ?PLAYER ->
                ?DEBUG("寻路:~p ~n", [{MapId, {FX, FY}, {TX, TY}}]);
                true ->
                    noop
            end,
            Robot#robot{
                move_path = Path,
                last_move_time = Now,
                go_x = TX,
                go_y = TY
            };
        {max_node, Path} ->
            Robot#robot{
                move_path = [],
                last_move_time = Now + 1500,
                go_x = FX,
                go_y = FY
            }
    end.

%%update_robot(PlayerId) ->
%%    case ?PROCESS_TYPE of
%%        ?PROCESS_TYPE_SCENE_WORKER ->
%%%%            Now = util:milli_timestamp(),
%%            Robot = get_robot(PlayerId),
%%            #robot{
%%                player_id = PlayerId
%%            } = Robot,
%%            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%                ?UNDEFINED ->
%%                    noop;
%%                ObjScenePlayer ->
%%                    #obj_scene_player{
%%                        hp = Hp,
%%                        real_move_speed = MoveSpeed,
%%                        mount_status = MountStatus
%%%%                        x = X,
%%%%                        y = Y
%%                    } = ObjScenePlayer,
%%                    Robot1 = Robot#robot{
%%                        speed = MoveSpeed,
%%                        mount_status = MountStatus,
%%                        hp = Hp
%%                    },
%%%%                    Robot2 =
%%%%                        if Robot#robot.x == 0 ->
%%%%                            Robot1#robot{
%%%%                                x = X,
%%%%                                y = Y,
%%%%                                fight_player_id = 0
%%%%                            };
%%%%                            true ->
%%%%                                Robot1
%%%%                        end,
%%                    update_obj_robot(Robot1)
%%            end;
%%        _ ->
%%            noop
%%    end.

handle_heart_beat(PlayerId) ->
%%    update_robot(PlayerId),
    put(?ROBOT_DICT_NEXT_HEART_BEAT, ?ROBOT_HEART_BEAT_TIME),

    Now = util_time:milli_timestamp(),
    put(?DICT_NOW_MS, Now),

    deal_move_step(PlayerId),
    ProcessType = ?PROCESS_TYPE,
    case ProcessType of
        ?PROCESS_TYPE_ROBOT_WORKER ->
            deal_monster_move(),
            deal_player_move();
        ?PROCESS_TYPE_SCENE_WORKER ->
            noop
    end,

    Robot = get_robot(PlayerId),
    #robot{
        player_id = PlayerId,
        next_can_heart_beat_time = NextHeartBeatTime,
        force_wait_time = ForceWaitTime,
        dizzy_close_time = DizzyCloseTime,
        scene_id = SceneId,
        move_path = MovePath,
        x = X,
        y = Y
    } = Robot,

    IsCanAction =
        case ProcessType of
            ?PROCESS_TYPE_ROBOT_WORKER ->
                Now >= max(ForceWaitTime, DizzyCloseTime);
            ?PROCESS_TYPE_SCENE_WORKER ->
                true
        end,
    if
        IsCanAction ->
            if
                Now >= NextHeartBeatTime andalso Now >= ForceWaitTime ->
%%                    if PlayerId == ?PLAYER ->
%%                    ?DEBUG("执行心跳:~p, ...............~n", [{pos, SceneId, X, Y, MovePath}]),
%%                        true ->
%%                            noop
%%                    end,
                    NewRobot = handle_do_task(Robot),
                    update_obj_robot(NewRobot);
%%                    if
%%                        TargetObjType > 0 andalso TargetObjId > 0 ->
%%                            handle_do_task(Robot, [fight, TargetObjType, TargetObjId]);
%%                        true ->
%%
%%                            get_scene_all_monster()
%%                    end;
                true ->
                    put(?ROBOT_DICT_NEXT_HEART_BEAT, max(200, trunc(max(NextHeartBeatTime - Now, ForceWaitTime - Now)) + 100))
            end;
        true ->
            noop
    end,
    if PlayerId == ?PLAYER ->
        ?DEBUG("下次心跳:~p~n", [get(?ROBOT_DICT_NEXT_HEART_BEAT)]);
        true ->
            noop
    end.

%%go_target_pos(Now, Robot, GoSceneId, GoX, GoY, TolerateDistance, Range, FlyP) ->
%%    #robot{
%%        move_path = MovePath,
%%        map_id = MapId,
%%        scene_id = SceneId,
%%        player_id = PlayerId,
%%%%        mount_steps = MountSteps,
%%        x = X,
%%        y = Y
%%%%        go_x = LastGoX,
%%%%        go_y = LastGoY,
%%%%        mount_status = MountStatus
%%    } = Robot,
%%    if SceneId == GoSceneId ->
%%        Distance = util_math:get_distance({X, Y}, {GoX, GoY}),
%%        if
%%            Distance =< TolerateDistance andalso MovePath == [] ->
%%                {true, Robot};
%%            true ->
%%                if
%%                    MovePath == [] ->
%%                        if
%%                            Distance > 800 andalso MountSteps > 0 ->
%%                                robot_socket:request_change_mount_status(PlayerId, 1),
%%                                put(?ROBOT_DICT_NEXT_HEART_BEAT, 1000),
%%                                {false, Robot};
%%                            true ->
%%                                NewRobot = move(Robot, Now, MapId, {X, Y}, {GoX, GoY}, ?NORMAL, Range),
%%                                update_obj_robot(NewRobot),
%%                                {false, NewRobot}
%%                        end;
%%                    true ->
%%                        {false, Robot}
%%                end
%%        end;
%%        true ->
%%%%            case util:p(FlyP) of
%%%%                true ->
%%%%                    noop;
%%%%                false ->
%%%%                    noop
%%%%            end,
%%            NewRobot = handle_change_scene(Robot, GoSceneId),
%%            {false, NewRobot}
%%    end.


%%handle_change_scene(Robot, TaskSceneId) ->
%%    #robot{
%%        map_id = MapId,
%%        player_id = PlayerId,
%%        scene_id = SceneId,
%%        x = X,
%%        y = Y,
%%        move_path = MovePath
%%    } = Robot,
%%    if
%%        SceneId == ?SCENE_TENG_YUN_GUAN ->
%%            put(?ROBOT_DICT_NEXT_HEART_BEAT, 1500),
%%            Robot;
%%        TaskSceneId == ?SCENE_TENG_YUN_GUAN ->
%%            ?ERROR("go_1001_scene:~p~n", [{PlayerId, SceneId, TaskSceneId}]),
%%            exit(go_1001_scene);
%%        SceneDoorId == 0 ->
%%%%        L = mod_scene:get_to_scene_info_list(SceneId, TaskSceneId), %%
%%            case catch mod_scene:get_change_scene_scene_list(SceneId, TaskSceneId) of
%%                {'EXIT', _} ->
%%                    ?ERROR("robot_change_scene:~p~n", [{SceneId, TaskSceneId}]),
%%                    robot_socket:robot_change_scene(TaskSceneId),
%%                    put(?ROBOT_DICT_NEXT_HEART_BEAT, 1500),
%%                    Robot;
%%                L ->
%%                    NextSceneId = hd(L),
%%                    {ToSceneDoorId, ToX, ToY, _, _} = mod_scene:get_change_scene_scene_door_info(SceneId, NextSceneId),
%%%%        io:format("{ToSceneDoorId, ToX, ToY}:~p~n", [{ToSceneDoorId, ToX, ToY}]),
%%                    Now = util:milli_timestamp(),
%%                    Robot_1 = move(Robot, Now, MapId, {X, Y}, {ToX, ToY}),
%%
%%                    NewRobot =
%%                        Robot_1#robot{
%%                            trace_scene_door = {ToSceneDoorId, ToX, ToY}
%%                        },
%%                    update_obj_robot(NewRobot),
%%                    NewRobot
%%            end;
%%        true ->
%%            Distance = util:get_distance({X, Y}, {SceneDoorX, SceneDoorY}),
%%            if
%%                Distance < 100 ->
%%                    robot_socket:request_enter_scene(SceneDoorId),
%%                    Robot;
%%                true ->
%%                    if Distance > 800 andalso MountSteps > 0 andalso MountStatus == 0 ->
%%                        robot_socket:request_change_mount_status(PlayerId, 1),
%%                        put(?ROBOT_DICT_NEXT_HEART_BEAT, 1200),
%%                        Robot;
%%                        true ->
%%                            if
%%                                MovePath == [] ->
%%                                    Now = util:milli_timestamp(),
%%                                    NewRobot = move(Robot, Now, MapId, {X, Y}, {SceneDoorX, SceneDoorY}),
%%                                    update_obj_robot(NewRobot),
%%                                    NewRobot;
%%                                true ->
%%                                    Robot
%%                            end
%%                    end
%%            end
%%    end.

%%get_near_gather_pos(SceneId, GatherId, X, Y) ->
%%    L = mod_scene:get_scene_gather_list(SceneId),
%%    {Gather, _} = lists:foldl(
%%        fun(E, {Tmp, TmpDis}) ->
%%            #r_scene_gather{
%%                x = ThisX,
%%                y = ThisY,
%%                gather_id = ThisGatherId
%%            } = E,
%%            if ThisGatherId == GatherId ->
%%                Dis = util:get_distance({X, Y}, {ThisX, ThisY}),
%%                if Tmp == null ->
%%                    {E, Dis};
%%                    true ->
%%                        if Dis < TmpDis ->
%%                            {E, Dis};
%%                            true ->
%%                                {Tmp, TmpDis}
%%                        end
%%                end;
%%                true ->
%%                    {Tmp, TmpDis}
%%            end
%%        end,
%%        {null, 0},
%%        L
%%    ),
%%    {Gather#r_scene_gather.x, Gather#r_scene_gather.y}.


%%select_collect_scene_item(PlayerId, X, Y) ->
%%    case ?PROCESS_TYPE of
%%        ?PROCESS_TYPE_ROBOT_WORKER ->
%%            {SceneItem, _} = lists:foldl(
%%                fun(E, {Tmp, TmpDis}) ->
%%                    #scene_item{
%%                        id = SceneItemId,
%%                        x = ThisX,
%%                        y = ThisY,
%%                        player_id = ThisPlayerId,
%%                        type = Type,
%%                        data_id = DataId
%%                    } = E,
%%%%            if ThisPlayerId == PlayerId ->
%%                    if Type == ?SCENE_ITEM_TYPE_ITEM andalso (ThisPlayerId == 0 orelse ThisPlayerId == PlayerId) ->
%%                        case mod_collect:check_can_collect_item(PlayerId, DataId, 1) of
%%                            true ->
%%                                Dis = util:get_distance({X, Y}, {ThisX, ThisY}),
%%                                if Tmp == null ->
%%                                    {E, Dis};
%%                                    true ->
%%                                        if Dis < TmpDis ->
%%                                            {E, Dis};
%%                                            true ->
%%                                                {Tmp, TmpDis}
%%                                        end
%%                                end;
%%                            false ->
%%                                delete_scene_item(SceneItemId),
%%                                {Tmp, TmpDis}
%%                        end;
%%                        true ->
%%                            {Tmp, TmpDis}
%%                    end
%%                end,
%%                {null, 0},
%%                ets:tab2list(get(?ROBOT_DICT_SCENE_ITEM_TABLE))
%%            ),
%%            SceneItem;
%%        _ ->
%%            null
%%    end.

%%%% 采集
%%handle_do_collect(Now, Robot, SceneItem) ->
%%    handle_do_collect(Now, Robot, SceneItem, false).
%%handle_do_collect(Now, Robot, SceneItem, Check) ->
%%    #robot{
%%        move_path = MovePath,
%%        map_id = MapId,
%%        scene_id = _SceneId,
%%        player_id = PlayerId,
%%        x = X,
%%        y = Y,
%%        collect_info = {LastSceneItemId, LastCollectTime},
%%        mount_status = MountStatus
%%    } = Robot,
%%
%%    #scene_item{
%%        need_time = NeedTime,
%%        x = ItemX,
%%        y = ItemY
%%    } = SceneItem,
%%
%%
%%    SceneItemId = SceneItem#scene_item.id,
%%    Distance = util:get_distance({X, Y}, {ItemX, ItemY}),
%%
%%    if Distance =< ?SSD_AUTO_COLLECT_RANGE orelse Check ->
%%
%%        if
%%            LastSceneItemId == SceneItemId ->
%%                if Now - LastCollectTime > NeedTime ->
%%                    robot_socket:request_do_collect(SceneItemId),
%%                    NewRobot = Robot#robot{
%%                        collect_info = {0, 0}
%%                    },
%%                    update_obj_robot(NewRobot);
%%                    true ->
%%                        noop
%%                end;
%%            true ->
%%                if MountStatus > 0 ->
%%                    robot_socket:request_change_mount_status(PlayerId, 0);
%%                    true ->
%%                        noop
%%                end,
%%                if
%%                    NeedTime == 0 ->
%%                        robot_socket:request_do_collect(SceneItemId),
%%                        NewRobot = Robot#robot{
%%                            collect_info = {0, 0}
%%                        },
%%                        update_obj_robot(NewRobot);
%%                    true ->
%%                        robot_socket:request_start_collect(SceneItemId),
%%                        NewRobot = Robot#robot{
%%                            collect_info = {SceneItemId, Now + 1000}
%%                        },
%%                        update_obj_robot(NewRobot)
%%                end
%%        end;
%%        true ->
%%            if MovePath == [] ->
%%                NewRobot = move(Robot, Now, MapId, {X, Y}, {ItemX, ItemY}, ?NORMAL),
%%                update_obj_robot(NewRobot);
%%                true ->
%%                    noop
%%            end
%%    end.

%%handle_do_task(Robot, ContentList) ->
handle_do_task(Robot) ->
%%    Now = get(?DICT_NOW_MS),
    #robot{
        x = X,
        y = Y,
        target_obj_type = TargetObjType,
        target_obj_id = TargetObjId
    } = Robot,
    if
        TargetObjType == ?OBJ_TYPE_MONSTER andalso TargetObjId > 0 ->
            case get_scene_monster(TargetObjId) of
                null ->
%%                    ?DEBUG("null"),
                    MonsterList = get_scene_all_monster(),
                    if
                        MonsterList == [] ->
                            Robot#robot{
                                target_obj_type = 0,
                                target_obj_id = 0
                            };
                        true ->
                            put(?ROBOT_DICT_NEXT_HEART_BEAT, 200),
                            #scene_monster{
                                id = NewTargetMonsterObjId
                            } = get_near_monster(MonsterList, X, Y),
                            Robot#robot{
                                target_obj_type = ?OBJ_TYPE_MONSTER,
                                target_obj_id = NewTargetMonsterObjId
                            }
                    end;
                TargetSceneMonster ->
                    fight(Robot, TargetSceneMonster)
            end;
        true ->
            MonsterList = get_scene_all_monster(),
            #scene_monster{
                id = NewTargetMonsterObjId
            } = get_near_monster(MonsterList, X, Y),
            Robot#robot{
                target_obj_type = ?OBJ_TYPE_MONSTER,
                target_obj_id = NewTargetMonsterObjId
            }
    end.
%%    case ContentList of
%%        [fight, ?OBJ_TYPE_PLAYER, _] ->
%%            Robot;
%%        [fight, ?OBJ_TYPE_MONSTER, MonsterObjId] ->
%%            case get_scene_monster(MonsterObjId) of
%%                null ->
%%                    MonsterList = get_scene_all_monster(),
%%                    if
%%                        MonsterList == [] ->
%%                            Robot#robot{
%%                                target_obj_type = 0,
%%                                target_obj_id = 0
%%                            };
%%                        true ->
%%                            #scene_monster{
%%                                id = NewTargetMonsterObjId
%%                            } = get_near_monster(MonsterList, X, Y),
%%                            Robot#robot{
%%                                target_obj_type = ?OBJ_TYPE_MONSTER,
%%                                target_obj_id = NewTargetMonsterObjId
%%                            }
%%                    end;
%%                TargetSceneMonster ->
%%                    fight(Robot, TargetSceneMonster)
%%            end;
%%        [near_monster] ->
%%            noop;
%%        _ ->
%%            random_leave(500, task_no_match)
%%    end.

%%fight(Robot, null, _State) ->
%%    put({?ROBOT_DICT_NEXT_HEART_BEAT, Robot#obj_scene_actor.obj_id}, 200),
%%    Robot;
fight(Robot, Target) ->
    put(?ROBOT_DICT_NEXT_HEART_BEAT, 200),
    #scene_monster{
        id = TargetObjId,
        x = TargetX,
        y = TargetY,
%%        go_x = TargetGoX,
%%        go_y = TargetGoY,
        hp = TargetHp,
        move_path = TargetMovePath
    } = Target,
    #robot{
        player_id = PlayerId,
        scene_id = SceneId,
        map_id = MapId,
        x = X,
        y = Y,
        move_path = MovePath,
        last_fight_time = LastFightTime,
        last_fight_skill_id = LastSkillId,
        anger = Anger,
        prop_list = PropList,
        skill_list = SkillList
    } = Robot,
    #t_scene{
        mana_attack_list = [PropId, [MinCost | _CostList]]
%%        is_server_control_player = IsServerControlPlayer
    } = mod_scene:get_t_scene(SceneId),
%%    {SceneMasterState, _} = mod_scene_event_manager:get_state(),
    %% @todo 暂时写死
    SceneMasterState = ?SCENE_MASTER_STATE_MONSTER,
    NowMS = get(?DICT_NOW_MS),
    if
        TargetHp > 0 ->
            Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
%%            ?DEBUG("机器人坐标 ： ~p ， 目标坐标 ： ~p ， 距离 ： ~p ~n", [{X, Y}, {TargetX, TargetY}, Distance]),
            {SkillDistance, DiffDistance} = {320, 180},
            RobotLeftPropNum = util_list:opt(PropId, PropList, 0),
            if
                Distance =< SkillDistance andalso RobotLeftPropNum >= MinCost andalso TargetMovePath == [] ->
                    Robot_1 = robot_socket:try_request_stop_move(PlayerId, MovePath, SceneId, X, Y),
                    Dir = util_math:get_direction({X, Y}, {TargetX, TargetY}),
                    case get_skill_info(NowMS, LastSkillId, LastFightTime, SkillList, Anger, SceneMasterState) of
                        null ->
                            Robot_1;
                        RActiveSkill ->
                            #r_active_skill{
                                id = SkillId,
                                force_wait_time = ForceWaitTime
                            } = RActiveSkill,
                            if
                                SkillId == 4 ->
                                    robot_socket:request_fight_use_item(SkillId, MinCost);
                                SkillId == 5 ->
                                    robot_socket:request_fight_use_skill(?CHARGE_SKILL_SINGLE_GOAL, ?OBJ_TYPE_MONSTER, TargetObjId, MinCost);
                                true ->
                                    robot_socket:request_fight(SkillId, Dir, ?OBJ_TYPE_MONSTER, TargetObjId, ?OBJ_TYPE_PLAYER, MinCost)
                            end,
                            case lists:keytake(SkillId, #r_active_skill.id, SkillList) of
                                {value, Skill, SkillList1} ->
                                    [Skill#r_active_skill{last_time_ms = NowMS}, SkillList1]
                            end,
                            Robot#robot{
                                last_fight_time = NowMS,
                                last_fight_skill_id = SkillId
                            }
%%                            RequestFightParam =
%%                                #request_fight_param{
%%                                    attack_type = ?OBJ_TYPE_PLAYER,
%%                                    obj_type = ?OBJ_TYPE_PLAYER,
%%                                    obj_id = RobotId,
%%                                    skill_id = SkillId,
%%                                    dir = Dir,
%%                                    target_type = TargetObjType,
%%                                    target_id = TargetObjId,
%%                                    player_left_coin = RobotLeftPropNum,
%%                                    cost = Cost,
%%                                    rate = Rate
%%                                },
%%                            self() ! {?MSG_FIGHT, RequestFightParam},
%%                            put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, ForceWaitTime + 100),
%%                            decrease_prop(Robot_1#obj_scene_actor{last_fight_skill_id = SkillId}, [{ScenePropId, Cost}])
                    end;
%%                Distance < 400 andalso (not IsServerControlPlayer orelse (TargetMovePath == [] andalso TargetGoX == 0 andalso TargetGoY == 0)) ->
                Distance > SkillDistance andalso TargetMovePath == [] ->
                    put(?ROBOT_DICT_NEXT_HEART_BEAT, 100),
                    if
                        MovePath == [] ->
                            RealDiffDistance = DiffDistance + 30,
                            move(Robot, NowMS, MapId, {X, Y}, {TargetX, TargetY}, ?MOVE_TYPE_NORMAL, RealDiffDistance);
%%                            find_path(Robot, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_NORMAL, State);
%%                        find_path(Robot, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_MOMENT, State);
                        true ->
                            Robot
                    end;
                true ->
                    Robot
%%                    move(Robot, NowMS, MapId, {X, Y}, {TargetX, TargetY})
%%                    TargetMoveDis = util_math:get_distance({X, Y},{TargetX, TargetY}),
%%                    if MovePath == [] orelse TargetMoveDis > 80 ->
%%                        Robot_1 = find_path(Robot, {TargetX, TargetY}, true, DiffDistance, ?MOVE_TYPE_NORMAL, State),
%%                        Robot_1#obj_scene_actor{
%%                            track_info = #track_info{
%%                                obj_type = TargetObjType,
%%                                obj_id = TargetObjId,
%%                                x = TargetX,
%%                                y = TargetY
%%                            }
%%                        };
%%                        true ->
%%                            Robot
%%                    end
            end;
        true ->
            Robot
    end.
get_skill_info(Now, LastSkillId, LastFightTime, SkillList, Anger, SceneMasterState) ->
    SkillInfo =
        lists:foldl(
            fun(ThisSkillInfo, TmpSKillInfo) ->
                if TmpSKillInfo == null ->
                    #r_active_skill{
                        id = SkillId,
                        is_common_skill = IsCommonSkill,
                        last_time_ms = LastTime
                    } = ThisSkillInfo,
                    if
                        IsCommonSkill == false ->
                            #t_active_skill{
                                cd_time = CdTime
                            } = mod_active_skill:get_t_active_skill(SkillId),
                            if
                                Now > LastTime + CdTime andalso SkillId == ?ACTIVE_SKILL_4 andalso (Anger >= ?SD_SKILL_ANGER_TOTAL andalso SceneMasterState =/= ?SCENE_MASTER_STATE_BOX) ->
                                    ThisSkillInfo;
                                Now > LastTime + CdTime + 5 * ?SECOND_MS andalso SkillId == ?ACTIVE_SKILL_5 ->
                                    case util_random:p(2000) of
                                        true ->
                                            ThisSkillInfo;
                                        false ->
                                            TmpSKillInfo
                                    end;
%%                                    Now > LastTime + CdTime andalso IsCommonSkill ->
%%                                        ThisSkillInfo;
                                true ->
                                    TmpSKillInfo
                            end;
                        true ->
                            TmpSKillInfo
                    end;
                    true ->
                        TmpSKillInfo
                end
            end,
            null,
            util_list:rkeysort(#r_active_skill.id, SkillList)
        ),
    RealSkillInfo =
        if
            SkillInfo == null ->
                if
                    Now > LastFightTime + 2000 orelse LastSkillId >= 903 orelse LastSkillId < 901 ->
                        {value, RActiveSkill, _Left} = lists:keytake(901, #r_active_skill.id, SkillList),
                        RActiveSkill;
                    true ->
                        {value, RActiveSkill, _Left} = lists:keytake(LastSkillId + 1, #r_active_skill.id, SkillList),
                        RActiveSkill
                end;
            true ->
                SkillInfo
        end,
    RealSkillInfo.

%%get_skill_info(Now, LastFightTime, SKillList, CommonSKillList) ->
%%    SkillInfo =
%%        lists:foldl(
%%            fun(ThisSkillInfo, TmpSKillInfo) ->
%%                if TmpSKillInfo == null ->
%%                    #skill_info{
%%                        cd_time = CdTime,
%%                        last_time = LastTime
%%                    } = ThisSkillInfo,
%%
%%                    if Now > LastTime + CdTime ->
%%                        ThisSkillInfo;
%%                        true ->
%%                            TmpSKillInfo
%%                    end;
%%                    true ->
%%                        TmpSKillInfo
%%                end
%%            end,
%%            null,
%%            util_list:rkeysort(#skill_info.skill_id, SKillList)
%%        ),
%%    if
%%        SkillInfo == null ->
%%            RealCommonSkillList =
%%                if Now > LastFightTime + 2000 ->
%%                    lists:keysort(#skill_info.skill_id, CommonSKillList);
%%                    true ->
%%                        CommonSKillList
%%                end,
%%            lists:foldl(
%%                fun(ThisSkillInfo, TmpSKillInfo) ->
%%                    if TmpSKillInfo == null ->
%%                        #skill_info{
%%                            cd_time = CdTime,
%%                            last_time = LastTime
%%                        } = ThisSkillInfo,
%%
%%                        if Now > LastTime + CdTime ->
%%                            ThisSkillInfo;
%%                            true ->
%%                                TmpSKillInfo
%%                        end;
%%                        true ->
%%                            TmpSKillInfo
%%                    end
%%                end,
%%                null,
%%                RealCommonSkillList
%%            );
%%        true ->
%%            SkillInfo
%%    end.

%%do_fight(Now, Robot, TargetType, TargetId, TargetX, TargetY, AllowHurtDistance) ->
%%    #robot{
%%        player_id = PlayerId,
%%        move_path = MovePath,
%%        map_id = MapId,
%%        x = X,
%%        y = Y,
%%        scene_id = SceneId,
%%        skill_list = SkillList,
%%        common_skill_list = CommonSkillList,
%%        trace_target_info = #trace_target_info{obj_type = OldTraceObjType, obj_id = OldTraceObjId, x = OldTraceX, y = OldTraceY},
%%        last_fight_time = LastFightTime,
%%        mount_status = MountStatus,
%%        mount_steps = MountSteps,
%%        next_can_fight_time = NextCanFightTime
%%    } = Robot,
%%    Distance = util:get_distance({X, Y}, {TargetX, TargetY}),
%%%%    ?DEBUG("~p~n", [[S#skill_info.skill_id || S <- SkillList]]),
%%    SkillInfo = get_skill_info(Now, LastFightTime, SkillList, CommonSkillList),
%%    if
%%        SkillInfo == null ->
%%            put(?ROBOT_DICT_NEXT_HEART_BEAT, 1500);
%%        true ->
%%            #skill_info{
%%                skill_id = SkillId,
%%                distance = SkillDistance,
%%                continue_time = ContinueTime
%%            } = SkillInfo,
%%            IsCanFight = Now >= NextCanFightTime,
%%            RealSkillDistance =
%%                if IsCanFight ->
%%                    SkillDistance + AllowHurtDistance;
%%                    true ->
%%                        40 + AllowHurtDistance
%%                end,
%%            GoDistance = max(RealSkillDistance - 60, 0),
%%            if
%%                Distance =< RealSkillDistance ->
%%                    if
%%                        IsCanFight ->
%%                            Dir = util:get_target_dir({X, Y}, {TargetX, TargetY}),
%%                            robot_socket:try_request_stop_move(PlayerId, MovePath, SceneId, X, Y),
%%                            if
%%                                MountStatus > 0 ->
%%                                    robot_socket:request_change_mount_status(PlayerId, 0),
%%                                    robot_socket:request_fight(PlayerId, 0, 0, ?AS_REN_WU_PU_GONG_SI, X, Y, Dir, X, Y, ?FALSE),
%%
%%                                    NewRobot = Robot#robot{
%%                                        mount_status = 0
%%                                    },
%%                                    update_obj_robot(NewRobot),
%%                                    put(?ROBOT_DICT_NEXT_HEART_BEAT, 1000);
%%                                true ->
%%                                    robot_socket:request_fight(PlayerId, TargetType, TargetId, SkillId, X, Y, Dir, TargetX, TargetY, ?FALSE),
%%                                    NextActionTime = SkillInfo#skill_info.force_wait_time,
%%
%%                                    NewRobot =
%%                                        case mod_skill:is_common_skill(SkillId) of
%%                                            true ->
%%                                                NextHeartBeatTime = max(600, NextActionTime + 300),
%%                                                put(?ROBOT_DICT_NEXT_HEART_BEAT, NextHeartBeatTime),
%%                                                Robot#robot{
%%                                                    move_path = [],
%%%%                                                    trace_target_info = #trace_target_info{},
%%                                                    last_fight_time = Now,
%%                                                    last_fight_info = {TargetType, TargetId},
%%                                                    common_skill_list = lists:keydelete(SkillId, #skill_info.skill_id, CommonSkillList) ++ [SkillInfo#skill_info{last_time = Now}]
%%                                                };
%%                                            false ->
%%                                                NextHeartBeatTime = max(600, NextActionTime + 300),
%%                                                put(?ROBOT_DICT_NEXT_HEART_BEAT, NextHeartBeatTime),
%%                                                Robot1 = skill_move(Robot, MapId, SkillId, {X, Y}, {TargetX, TargetY}, NextHeartBeatTime),
%%                                                Robot1#robot{
%%                                                    move_path = [],
%%%%                                                    trace_target_info = #trace_target_info{},
%%                                                    last_fight_time = Now,
%%                                                    last_fight_info = {TargetType, TargetId},
%%                                                    skill_list = [SkillInfo#skill_info{last_time = Now} | lists:keydelete(SkillId, #skill_info.skill_id, SkillList)],
%%                                                    next_can_fight_time = Now + ContinueTime
%%                                                }
%%                                        end,
%%                                    update_obj_robot(NewRobot)
%%                            end;
%%                        true ->
%%                            put(?ROBOT_DICT_NEXT_HEART_BEAT, 600)
%%                    end;
%%                true ->
%%%%            ?DEBUG("long"),
%%                    if Distance > 800 andalso MountSteps > 0 andalso MountStatus == 0 ->
%%                        robot_socket:request_change_mount_status(PlayerId, 1);
%%                        true ->
%%                            noop
%%                    end,
%%                    if
%%                        SceneId == ?SCENE_LUN_JIAN_TA ->
%%                            put(?ROBOT_DICT_NEXT_HEART_BEAT, 300);
%%                        true ->
%%                            put(?ROBOT_DICT_NEXT_HEART_BEAT, 1000)
%%                    end,
%%                    Dis = util_math:get_distance({OldTraceX, OldTraceY}, {TargetX, TargetY}),
%%                    if MovePath == []
%%                        orelse {OldTraceObjType, OldTraceObjId} =/= {TargetType, TargetId}
%%                        orelse Dis > 100 ->
%%                        Robot_1 = move(Robot, Now, MapId, {X, Y}, {TargetX, TargetY}, ?NORMAL, GoDistance),
%%
%%                        NewRobot =
%%                            Robot_1#robot{
%%                                trace_target_info = #trace_target_info{obj_type = TargetType, obj_id = TargetId, x = TargetX, y = TargetY}
%%                            },
%%                        update_obj_robot(NewRobot);
%%                        true ->
%%                            noop
%%                    end
%%            end
%%    end.

get_near_monster(MonsterList, X, Y) ->
    {NewTargetMonsterObj, _} =
        lists:foldl(
            fun(SceneMonster, {TmpMonster, TmpDis}) ->
                #scene_monster{
                    x = MonsterX,
                    y = MonsterY,
                    is_boss = IsBoss
                } = SceneMonster,
                Dis = util_math:get_direction({X, Y}, {MonsterX, MonsterY}),
                if
                    TmpMonster == null orelse Dis < TmpDis orelse IsBoss ->
                        {SceneMonster, Dis};
                    true ->
                        {TmpMonster, TmpDis}
                end
            end,
            {null, 0}, MonsterList
        ),
    NewTargetMonsterObj.

deal_monster_move() ->
    SceneMonsterList = ets:tab2list(get(?ROBOT_DICT_SCENE_MONSTER_TABLE)),
    lists:foreach(
        fun(SceneMonster) ->
            do_deal_monster_move(SceneMonster)
        end,
        SceneMonsterList
    ).
do_deal_monster_move(_SceneMonster = #scene_monster{move_path = []}) ->
    _SceneMonster;
do_deal_monster_move(SceneMonster) ->
    #scene_monster{
        move_path = MovePath,
        speed = MoveSpeed,
        x = X,
        y = Y,
        last_move_time = LastMoveTime
    } = SceneMonster,
    Now = get(?DICT_NOW_MS),
%%    ?DEBUG("查看移动参数 : ~p", [{Now, LastMoveTime, MovePath, {X, Y}, util:speed_point_2_speed(MoveSpeed)}]),
    {LeftMovePath, {NewX, NewY}, ForbidTime} = mod_scene:deal_move((Now - LastMoveTime), MovePath, {X, Y}, 1000 / (util:speed_point_2_speed(MoveSpeed) * ?TILE_LEN)),
    Tile = ?PIX_2_TILE(NewX, NewY),
    MapId = get(robot_map_id),
    case mod_map:can_walk({MapId, Tile}) of
        true ->
            NewSceneMonster =
                if ForbidTime == 0 andalso LeftMovePath == [] ->
                    SceneMonster#scene_monster{
                        x = NewX,
                        y = NewY,
                        move_path = LeftMovePath,
                        last_move_time = Now
                    };
                    true ->
                        NextHeartBeatTime = Now + ForbidTime,
                        SceneMonster#scene_monster{
                            x = NewX,
                            y = NewY,
                            move_path = LeftMovePath,
                            last_move_time = NextHeartBeatTime,
                            force_wait_time = NextHeartBeatTime
                        }
                end,
            ets:insert(get(?ROBOT_DICT_SCENE_MONSTER_TABLE), NewSceneMonster),
            NewSceneMonster;
        false ->
            SceneMonster
    end.


deal_player_move() ->
    ScenePlayerList = ets:tab2list(get(?ROBOT_DICT_SCENE_PLAYER_TABLE)),
    lists:foreach(
        fun(ScenePlayer) ->
            do_deal_player_move(ScenePlayer)
        end,
        ScenePlayerList
    ).
do_deal_player_move(_ScenePlayer = #scene_player{move_path = []}) ->
    _ScenePlayer;
do_deal_player_move(ScenePlayer) ->
    #scene_player{
        move_path = MovePath,
        speed = MoveSpeed,
        x = X,
        y = Y,
        last_move_time = LastMoveTime
    } = ScenePlayer,
    Now = get(?DICT_NOW_MS),
%%    ?DEBUG("查看移动参数 : ~p", [{Now, LastMoveTime, MovePath, {X, Y}, util:speed_point_2_speed(MoveSpeed)}]),
    {LeftMovePath, {NewX, NewY}, ForbidTime} = mod_scene:deal_move((Now - LastMoveTime), MovePath, {X, Y}, 1000 / (util:speed_point_2_speed(MoveSpeed) * ?TILE_LEN)),
    Tile = ?PIX_2_TILE(NewX, NewY),
    MapId = get(robot_map_id),
    case mod_map:can_walk({MapId, Tile}) of
        true ->
            NewScenePlayer =
                if ForbidTime == 0 andalso LeftMovePath == [] ->
                    ScenePlayer#scene_player{
                        x = NewX,
                        y = NewY,
                        move_path = LeftMovePath,
                        last_move_time = Now
                    };
                    true ->
                        NextHeartBeatTime = Now + ForbidTime,
                        ScenePlayer#scene_player{
                            x = NewX,
                            y = NewY,
                            move_path = LeftMovePath,
                            last_move_time = NextHeartBeatTime,
                            force_wait_time = NextHeartBeatTime
                        }
                end,
            ets:insert(get(?ROBOT_DICT_SCENE_PLAYER_TABLE), NewScenePlayer),
            NewScenePlayer;
        false ->
            ScenePlayer
    end.


deal_move_step(PlayerId) when is_integer(PlayerId) ->
    deal_move_step(get_robot(PlayerId));
deal_move_step(Robot = #robot{move_path = []}) ->
    Robot;
deal_move_step(
    Robot = #robot{player_id = PlayerId, map_id = MapId, x = X, y = Y, speed = MoveSpeed, move_path = MovePath, last_move_time = LastMoveTime}
) ->
    Now = get(?DICT_NOW_MS),
    {LeftMovePath, {NewX, NewY}, ForbidTime} =
        case get(?ROBOT_DICT_MOVE_TYPE) of
%%            ?MOVE_TYPE_MOMENT ->
%%                mod_scene:deal_move((Now - LastMoveTime), MovePath, {X, Y}, 1000 / (util:speed_point_2_speed(MoveSpeed) * ?TILE_LEN));
            _ ->
                mod_scene:deal_move((Now - LastMoveTime), MovePath, {X, Y}, 1000 / (util:speed_point_2_speed(MoveSpeed) * ?TILE_LEN))
        end,

    if
        NewX =/= X orelse NewY =/= Y orelse LeftMovePath =/= MovePath ->

            Tile = ?PIX_2_TILE(NewX, NewY),
            NewRobot =
                case mod_map:can_walk({MapId, Tile}) of
                    true ->
                        robot_socket:request_move_step(PlayerId, NewX, NewY, LeftMovePath, trunc(ForbidTime)),
                        if
                            ForbidTime == 0 ->
                                Robot#robot{
                                    x = NewX,
                                    y = NewY,
                                    move_path = LeftMovePath,
                                    last_move_time = Now
                                };
                            true ->
                                NextHeartBeatTime = Now + ForbidTime,
                                Robot#robot{
                                    x = NewX,
                                    y = NewY,
                                    move_path = LeftMovePath,
                                    last_move_time = NextHeartBeatTime,
                                    next_can_heart_beat_time = NextHeartBeatTime + 1
                                }
                        end;
                    false ->
                        Robot
                end,
            update_obj_robot(NewRobot);
        true ->
            Robot
    end.

random_leave(P, Reason) ->
    case util_random:p(P) of
        true ->
            ?DEBUG("机器人离开原因:~p~n", [Reason]),
            exit(leave);
        false ->
            noop
    end.

get_scene_player_table() ->
    get(?ROBOT_DICT_SCENE_PLAYER_TABLE).
get_scene_monster_table() ->
    get(?ROBOT_DICT_SCENE_MONSTER_TABLE).
get_scene_item_table() ->
    get(?ROBOT_DICT_SCENE_ITEM_TABLE).

get_scene_player(PlayerId) ->
    case ets:lookup(get_scene_player_table(), PlayerId) of
        [] ->
            null;
        [R] ->
            R
    end.

get_scene_player_count() ->
    ets:info(get_scene_player_table(), size).

get_scene_all_monster() ->
    ets:tab2list(get_scene_monster_table()).
get_scene_monster(0) ->
    null;
get_scene_monster(SceneMonsterId) ->
    case ?PROCESS_TYPE of
        ?PROCESS_TYPE_ROBOT_WORKER ->
            case ets:lookup(get_scene_monster_table(), SceneMonsterId) of
                [] ->
                    null;
                [R] ->
                    R
            end;
        ?PROCESS_TYPE_SCENE_WORKER ->
            mod_scene_monster_manager:get_obj_scene_monster(SceneMonsterId)
    end.

get_scene_item(SceneItemId) ->
    case ets:lookup(get_scene_item_table(), SceneItemId) of
        [] ->
            null;
        [R] ->
            R
    end.

delete_scene_player(ScenePlayerId) ->
    ets:delete(get_scene_player_table(), ScenePlayerId).
delete_scene_monster(SceneMonsterId) ->
    ets:delete(get_scene_monster_table(), SceneMonsterId).
delete_scene_item(SceneItemId) ->
    ets:delete(get_scene_item_table(), SceneItemId).

drop_all_scene_player() ->
    ets:delete_all_objects(get_scene_player_table()).
drop_all_scene_monster() ->
    ets:delete_all_objects(get_scene_monster_table()).
drop_all_scene_item() ->
    ets:delete_all_objects(get_scene_item_table()).

update_scene_player(ScenePlayer) ->
    ets:insert(get_scene_player_table(), ScenePlayer).
update_scene_monster(SceneMonster) ->
    ets:insert(get_scene_monster_table(), SceneMonster).
update_scene_item(SceneItem) ->
    ets:insert(get_scene_item_table(), SceneItem).

get_robot() ->
    PlayerId = get(player_id),
%%    ?DEBUG("机器人玩家id ： ~p",[PlayerId]),
    get_robot(PlayerId).
get_robot(PlayerId) ->
    get({?ROBOT_DICT_OBJ_ROBOT, PlayerId}).

update_obj_robot(Robot) ->
    #robot{
        player_id = PlayerId
    } = Robot,
    put({?ROBOT_DICT_OBJ_ROBOT, PlayerId}, Robot).

init_acc_id(AccId) ->
    put(?ROBOT_DICT_ACC_ID, AccId).
get_acc_id() ->
    get(?ROBOT_DICT_ACC_ID).