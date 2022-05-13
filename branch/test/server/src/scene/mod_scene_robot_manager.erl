%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            场景机器人
%%% @end
%%% Created : 27. 十一月 2017 上午 1:08
%%%-------------------------------------------------------------------
-module(mod_scene_robot_manager).
-include("scene.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").
-include("error.hrl").
-include("msg.hrl").
-include("p_enum.hrl").
-include("skill.hrl").
-include("fight.hrl").

%% API
-export([
    init_scene/1,
    handle_check_robot/1,

    create_robot/2,
    handle_robot_death/1
]).

%% HEART
-export([
    handle_robot_heart_beat/2,
    handle_navigate_result/2
]).

%% PROP
-export([
    award_prop/2,           %% 奖励道具
    decrease_prop/2         %% 扣除道具
]).

%% EVENT
-export([
    player_enter_scene/1,

    handle_start_boss_event/1
]).

-define(DICT_SCENE_NEXT_ROBOT_HEART_TIME, robot_next_heart_beat).

%% @doc 初始化场景
init_scene(SceneId) ->
    InitRobotNum = util_random:get_probability_item(?SD_ROBOT_INIT_COUNT_LIST),
    util:run(
        fun() ->
            RobotConfigId = get_random_robot_config_id(SceneId),
            RobotId = get_random_robot_id(),
%%            ?DEBUG("初始化创建机器人 ： ~p", [{RobotConfigId, RobotId}]),
            create_robot(RobotConfigId, RobotId)
        end,
        InitRobotNum
    ),
    erlang:send_after(util_random:random_number(2, 5) * 1000, self(), ?MSG_SCENE_CHECK_ROBOT).

%% @doc 机器人检测
handle_check_robot(#scene_state{is_hook_scene = IsHookScene, scene_id = SceneId}) ->
    #t_scene{
        type = SType
    } = t_scene:assert_get({SceneId}),
    IsCreateRobot = mod_server_config:is_create_robot(),
    if
        SType == ?SCENE_TYPE_WORLD_SCENE andalso IsHookScene andalso IsCreateRobot ->
            {{PlayerNum, _PlayerIdList}, {RobotNum, RobotIdList}} = mod_scene_player_manager:get_player_info(),
%%            if
%%                PlayerNum == 0 ->
%%                    noop;
%%                true ->
            MaxPlayerNum = get(?DICT_MAX_PLAYER_NUM),
            OldTotalNum1 = PlayerNum + RobotNum,
            OldTotalNum =
                if
                    OldTotalNum1 > MaxPlayerNum ->
                        MaxPlayerNum;
                    true ->
                        OldTotalNum1
                end,
            Data = util_list:key_find(OldTotalNum, 1, ?SD_ROBOT_COUNT_CHANGE_LIST),
%%            ?ASSERT(Data =/= false, {num_error, PlayerNum, RobotNum, PlayerIdList, RobotIdList, ?SD_ROBOT_COUNT_CHANGE_LIST}),
            [_, _TimeMin, _TimeMax, TotalNumList] = Data,
            TotalNum = util_random:get_list_random_member(TotalNumList),
            NewTotalNum =
                if
                    TotalNum > MaxPlayerNum ->
                        ?ERROR("机器人数量错误 ： ~p", [{TotalNum, MaxPlayerNum, OldTotalNum, PlayerNum, RobotNum}]),
                        noop;
                    TotalNum > OldTotalNum ->
                        util:run(
                            fun() ->
                                erlang:send_after(500, self(), {?MSG_SCENE_CREATE_ROBOT, get_random_robot_config_id(SceneId), get_random_robot_id()})
                            end,
                            TotalNum - OldTotalNum
                        ),
                        TotalNum;
                    TotalNum == OldTotalNum ->
                        TotalNum;
                    TotalNum < OldTotalNum ->
                        DeathNum = min(OldTotalNum - TotalNum, RobotNum),
                        {DeathRobotList, _} = lists:split(DeathNum, util_list:shuffle(RobotIdList)),
                        lists:foreach(
                            fun(DeathRobotId) ->
                                handle_robot_death(DeathRobotId)
                            end,
                            DeathRobotList
                        ),
                        OldTotalNum - DeathNum
                end,
            [_, TimeMin, TimeMax, _TotalNumList] = util_list:key_find(NewTotalNum, 1, ?SD_ROBOT_COUNT_CHANGE_LIST),
            erlang:send_after(util_random:random_number(TimeMin, TimeMax) * 1000, self(), ?MSG_SCENE_CHECK_ROBOT);
%%            end;
        true ->
            noop
    end.

%% @doc 创建机器人
create_robot(ConfigRobotId, RobotId) ->
    IsCanCreateRobot = scene_worker:is_allow_enter_scene_worker(RobotId, get(?DICT_MAX_PLAYER_NUM), self()),
    case ?GET_OBJ_SCENE_PLAYER(RobotId) of
        ?UNDEFINED when IsCanCreateRobot ->
            #t_robot{
                hero_list = HeroList,
                vip_level = VipLevel,
                level_list = LevelList,
                head_list = HeadList,
                head_frame_list = HeadFrameList,
                cost_list = CostList,
                item_list = ItemList,
                leave_list = [LeavePropId, LeaveNumMin, LeaveNumMax, LeaveTimeMin, LeaveTimeMax]
            } = get_t_robot(ConfigRobotId),
            Sex = util_random:random_number(?SEX_MAN, ?SEX_WOMEN),
            {_, RandomName} = random_name:get_name(Sex),
            NickName = mod_server:get_server_id() ++ "." ++ RandomName,
            {RobotHeroId, RobotHeroArms, RobotHeroOrnaments} = util_random:get_probability_item([{{HeroId, HeroArms, HeroOrnaments}, Weights} || [HeroId, HeroArms, HeroOrnaments, _, Weights] <- HeroList]),
            Level = util_random:random_number(util_random:get_probability_item([{[MinLevel, MaxLevel], Weights} || [MinLevel, MaxLevel, Weights] <- LevelList])),
            HeadId = util_random:get_probability_item(HeadList),
            HeadFrameId = util_random:get_probability_item(HeadFrameList),
            Surface = #surface{
                hero_id = RobotHeroId,
                hero_arms = RobotHeroArms,
                hero_ornaments = RobotHeroOrnaments,
                head_id = HeadId,
                head_frame_id = HeadFrameId
            },
            {BirthX, BirthY} = mod_scene:get_scene_birth_pos(get(?DICT_SCENE_ID)),
            RActiveSkillList =
                lists:foldl(
                    fun({SkillId, SkillLevel, _LastTime}, TmpActive) ->
                        RActiveSkill = mod_active_skill:tran_r_active_skill(SkillId, SkillLevel, 0, Sex),
                        [RActiveSkill | TmpActive]
                    end,
                    [],
                    mod_active_skill:pack_all_equip_active_skill(RobotId)
                ),
            LeaveTime = util_random:random_number(LeaveTimeMin, LeaveTimeMax),
            ObjSceneRobot = #obj_scene_actor{
                key = {?OBJ_TYPE_PLAYER, RobotId},
                obj_type = ?OBJ_TYPE_PLAYER,
                obj_id = RobotId,
                base_id = ConfigRobotId,
                client_worker = null,
                move_path = [],
                nickname = erlang:list_to_binary(NickName),
                is_robot = true,
                level = Level,
                vip_level = VipLevel,
                max_hp = 1,
                hp = 1,
                x = BirthX,
                y = BirthY,
                sex = Sex,
                grid_id = ?PIX_2_GRID_ID(BirthX, BirthY),
                surface = Surface,
                init_move_speed = ?SD_INIT_SPEED,
                move_speed = ?SD_INIT_SPEED,
                subscribe_list = mod_scene_grid_manager:get_subscribe_grid_id_list_by_px(600, 600),
                pk_mode = ?PK_MODE_PK_PEACE,
                r_active_skill_list = RActiveSkillList,
                robot_data = #robot_data{
                    robot_item_list = lists:foldl(
                        fun([PropId, NumMin, NumMax], TmpL) ->
                            PropNum = util_random:random_number(NumMin, NumMax),
                            if
                                PropNum == 0 ->
                                    TmpL;
                                true ->
                                    [{PropId, PropNum} | TmpL]
                            end
                        end,
                        [], ItemList
                    ),
                    robot_leave_list = [LeavePropId, LeaveNumMin, LeaveNumMax, LeaveTime]
                },
                cost = [{Num, Weights} || [_, Num, Weights] <- CostList],
                is_can_add_anger = true,
                server_id = mod_server:get_server_id()
            },
            ?INIT_PLAYER_SENDER_WORKER(RobotId, null),
            mod_scene_player_manager:add_obj_scene_player(ObjSceneRobot),
            mod_scene_grid_manager:handle_player_enter_grid(ObjSceneRobot),
            mod_scene_player_manager:try_add_scene_worker_stay_player(RobotId),
            erlang:send_after(util_random:random_number(1000, 5000), self(), {?MSG_SCENE_ROBOT_HEART_BEAT, RobotId});
        _ ->
            noop
    end.


%% @doc 机器人死亡
handle_robot_death(RobotId) ->
    case ?GET_OBJ_SCENE_PLAYER(RobotId) of
        ?UNDEFINED ->
            noop;
        ObjSceneRobot ->
            #robot_data{
                robot_task_context = RobotTaskContext
            } = ObjSceneRobot#obj_scene_actor.robot_data,
%%            ?DEBUG("机器人死亡:~p~n", [{RobotId}]),
            mod_scene_player_manager:delete_obj_scene_player(RobotId),
            ?ERASE_PLAYER_SENDER_WORKER(RobotId),
            erase({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}),
            mod_scene_grid_manager:handle_player_leave_grid(ObjSceneRobot),
            case mod_scene:is_hook_scene(get(?DICT_SCENE_ID)) of
                true ->
                    case RobotTaskContext of
                        {kill, _LastMonsterId, _} ->
                            noop;
%%                            monster_point:leave_monster_point(LastMonsterId, RobotId);
                        _ ->
                            noop
                    end;
                false ->
                    noop
            end
    end.

%% ----------------------------------
%% @doc 	获取随机config_robot_id
%% @throws 	none
%% @end
%% ----------------------------------
get_random_robot_config_id(SceneId) ->
    util_random:get_probability_item(logic_get_scene_robot_weights_list:get(SceneId)).

%% ----------------------------------
%% @doc 	获取随机robot_id
%% @throws 	none
%% @end
%% ----------------------------------
get_random_robot_id() ->
    util_random:random_number(1, 9999).

%% ----------------------------------
%% @doc 	机器人心跳
%% @throws 	none
%% @end
%% ----------------------------------
handle_robot_heart_beat(RobotId, State = #scene_state{is_mission = IsMission, scene_id = SceneId}) ->
    IsContinue =
        if
            IsMission ->
                is_heart_beat_continue();
            true ->
                true
        end,
    if
        IsContinue ->
            case ?GET_OBJ_SCENE_PLAYER(RobotId) of
                ?UNDEFINED ->
                    noop;
                ObjSceneRobot ->
                    #obj_scene_actor{
                        is_wait_navigate = IsWaitNavigate,
                        hp = Hp,
                        can_action_time = CanActionTime,
                        robot_data = RobotData
                    } = ObjSceneRobot,
                    #robot_data{
                        robot_destroy_time_ms = DestroyTime
                    } = RobotData,
                    NowMS = util_time:milli_timestamp(),
                    put(?DICT_NOW_MS, NowMS),
                    if NowMS >= CanActionTime ->
                        if
                            (DestroyTime > 0 andalso NowMS >= DestroyTime) orelse Hp =< 0 ->
                                ?DEBUG("时间到， 销毁机器人:~p", [{RobotId}]),
                                handle_robot_death(RobotId);
                            IsWaitNavigate ->
                                ?ERROR("WaitNavigate!!!!!:~p", [{RobotId, SceneId}]),
                                erlang:send_after(3000, self(), {?MSG_SCENE_ROBOT_HEART_BEAT, RobotId});
                            true ->
                                if IsMission ->
                                    put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, 300);
                                    true ->
                                        put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, 1200)
                                end,


                                Robot = mod_scene:deal_move_step(ObjSceneRobot, NowMS, State),
                                case do_heart_beat(Robot, NowMS, State) of
                                    remove ->
                                        noop;
                                    _ ->
                                        NextTime = get({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}),
                                        erlang:send_after(NextTime, self(), {?MSG_SCENE_ROBOT_HEART_BEAT, RobotId})
                                end
                        end;
                        true ->
                            erlang:send_after(CanActionTime - NowMS + 50, self(), {?MSG_SCENE_ROBOT_HEART_BEAT, RobotId})
                    end


            end;
        true ->
            erlang:send_after(1000, self(), {?MSG_SCENE_ROBOT_HEART_BEAT, RobotId})
    end.
do_heart_beat(Robot, NowMS, State = #scene_state{scene_id = SceneId, scene_type = SceneType}) ->
    #obj_scene_actor{
        obj_id = RobotId
    } = Robot,
    if
    %% 世界场景
        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
            Robot_0 = update_task(Robot),
            #obj_scene_actor{
                robot_data = RobotData,
                track_info = #track_info{obj_type = TraceObjType, obj_id = TraceObjId}
            } = Robot_0,
            #robot_data{
                robot_task_context = NowTask,
                robot_task_num = NowTaskNum
            } = RobotData,
            NewRobot =
                case NowTask of
                    none ->
                        %% 没有任务 等待下一心跳 销毁机器人
                        Robot_0#obj_scene_actor{
                            robot_data = RobotData#robot_data{
                                robot_destroy_time_ms = NowMS
                            }
                        };
                    null ->
                        Robot_0#obj_scene_actor{
                            robot_data = RobotData#robot_data{
                                robot_destroy_time_ms = NowMS
                            }
                        };
                    {sleep, SleepTime} ->
                        put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, SleepTime),
                        Robot_0#obj_scene_actor{
                            robot_data = RobotData#robot_data{
                                robot_task_status = ?TRUE
                            }
                        };
%%                    {kill_player, PlayerId} ->
%%                        case ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_PLAYER, PlayerId) of
%%                            ?UNDEFINED ->
%%                                Robot_0#obj_scene_actor{
%%                                    robot_data = RobotData#robot_data{
%%                                        robot_task_context = null
%%                                    }
%%                                };
%%                            TraceObjSceneActor ->
%%                                if TraceObjSceneActor#obj_scene_actor.hp > 0 ->
%%                                    fight(Robot_0, TraceObjSceneActor, State);
%%                                    true ->
%%                                        Robot_0#obj_scene_actor{
%%                                            robot_data = RobotData#robot_data{
%%                                                robot_task_context = null
%%                                            }
%%                                        }
%%                                end
%%                        end;
                    {kill, _MonsterId, NeedNum} ->

                        if
                            NowTaskNum >= NeedNum ->
                                put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, 500),
                                Robot_0#obj_scene_actor{
                                    robot_data = RobotData#robot_data{
                                        robot_task_status = ?TRUE
                                    }
                                };
                            true ->
                                put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, 1000),
                                case ?GET_OBJ_SCENE_ACTOR(TraceObjType, TraceObjId) of
                                    ?UNDEFINED ->
                                        case util_random:p(2000) of
                                            true ->
                                                Robot_0#obj_scene_actor{
                                                    robot_data = RobotData#robot_data{
                                                        robot_task_status = ?TRUE
                                                    }
                                                };
                                            false ->
                                                case search_monster(Robot_0, State) of
                                                    {Robot_1, true, null} ->
                                                        Robot_1#obj_scene_actor{
                                                            robot_data = RobotData#robot_data{
                                                                robot_task_status = ?TRUE
                                                            }
                                                        };
                                                    {Robot_1, _, TraceObjSceneActor} ->
                                                        fight(Robot_1, TraceObjSceneActor, State)
                                                end
                                        end;
                                    TraceObjSceneActor ->
                                        fight(Robot_0, TraceObjSceneActor, State)
                                end
                        end;
                    {dialog, NpcId} ->
                        if NowTaskNum >= 1 ->
                            put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, 1000),
                            Robot_0#obj_scene_actor{
                                robot_data = RobotData#robot_data{
                                    robot_task_status = ?TRUE
                                }
                            };
                            true ->
                                {NpcX, NpcY} = mod_scene:get_scene_npc_pos(SceneId, NpcId),
                                {Robot_1, IsReach} = go_target_pos(Robot_0, NpcX, NpcY, 100, 120, State),
                                if IsReach ->
                                    put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, util_random:random_number(2000, 8000)),
                                    Robot_1#obj_scene_actor{
                                        robot_data = RobotData#robot_data{
                                            robot_task_num = NowTaskNum + 1
                                        }
                                    };
                                    true ->
                                        Robot_1
                                end
                        end;
                    Other ->
                        ?ERROR("机器人任务未匹配:~p", [{Other}])
                end,
            ?UPDATE_OBJ_SCENE_PLAYER(NewRobot);
        true ->
%%            {?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId},
            #obj_scene_actor{
                track_info = #track_info{obj_type = TraceObjType, obj_id = TraceObjId},
                robot_data = #robot_data{
                    robot_delay_time_ms = DelayTimeMS,
                    robot_destroy_time_ms = DestroyTimeMS
                }
            } = Robot,
            NewRobot =
                if
                    DelayTimeMS > 0 andalso NowMS >= DelayTimeMS andalso NowMS < DestroyTimeMS ->
                        put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, DestroyTimeMS - NowMS),
                        Robot;
                    true ->
                        %% 副本
                        {Robot_1, FightObjSceneActor} =
                            case ?GET_OBJ_SCENE_ACTOR(TraceObjType, TraceObjId) of
                                ?UNDEFINED ->
                                    search_target_player(Robot);
                                TraceObjSceneActor ->
                                    if TraceObjSceneActor#obj_scene_actor.hp > 0 ->
                                        {Robot, TraceObjSceneActor};
                                        true ->
                                            %% 目标已死亡
                                            search_target_player(Robot#obj_scene_actor{
                                                track_info = #track_info{obj_type = 0, obj_id = 0}
                                            })
                                    end
                            end,
                        fight(Robot_1, FightObjSceneActor, State)
                end,
            ?UPDATE_OBJ_SCENE_PLAYER(NewRobot)
    end.

%% ----------------------------------
%% @doc 	更新任务
%% @throws 	none
%% @end
%% ----------------------------------
update_task(Robot) ->
    #obj_scene_actor{
        be_attacked_obj_id = BeAttackedObjId,
        be_attacked_obj_type = BeAttackedObjType,
        robot_data = RobotData
    } = Robot,
    #robot_data{
        robot_task_context = NowTask
    } = RobotData,
    if
        BeAttackedObjType == ?OBJ_TYPE_PLAYER ->
            %% 反击
            if
                NowTask == {kill_player, BeAttackedObjId} ->
                    Robot;
                true ->
                    FightTarget = ?GET_OBJ_SCENE_PLAYER(BeAttackedObjId),
                    if
                        FightTarget =/= ?UNDEFINED andalso FightTarget#obj_scene_actor.hp > 0 ->
                            Robot#obj_scene_actor{
                                robot_data = RobotData#robot_data{
                                    robot_task_context = {kill_player, BeAttackedObjId},
                                    robot_task_status = ?FALSE,
                                    robot_task_num = 0
                                },
                                track_info = #track_info{}
                            };
                        true ->
                            update_task_1(Robot#obj_scene_actor{
                                be_attacked_obj_type = 0,
                                be_attacked_obj_id = 0
                            })
                    end
            end;
        true ->
            update_task_1(Robot)
    end.

update_task_1(Robot) ->
    #obj_scene_actor{
        obj_id = RobotId,
        robot_data = RobotData
    } = Robot,
    #robot_data{
        robot_task_context = NowTask,
        robot_task_status = TaskStatus
    } = RobotData,
    SceneId = get(?DICT_SCENE_ID),
    if %% 下个任务
        TaskStatus == ?TRUE orelse NowTask == null ->
            {NewTaskContext, NewTaskId} = get_new_task(SceneId, RobotId),
%%            ?DEBUG("~p~n", [{RobotId, NowTask, TaskStatus, NewTaskContext}]),
            Robot#obj_scene_actor{
                robot_data = RobotData#robot_data{
                    robot_task_context = NewTaskContext,
                    robot_task_num = 0,
                    robot_task_id = NewTaskId,
                    robot_task_status = ?FALSE
                },
                track_info = #track_info{}
            };
        true ->
            Robot
    end.

get_new_task(_SceneId, _RobotId) ->
    case get(?DICT_SCENE_TYPE) of
        ?SCENE_TYPE_WORLD_SCENE ->
            MonsterIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
            if
                MonsterIdList == [] ->
                    {null, 0};
                true ->
                    #obj_scene_actor{
                        base_id = MonsterId
                    } = ?GET_OBJ_SCENE_MONSTER(hd(util_list:shuffle(MonsterIdList))),
                    {{kill, MonsterId, 1}, 0}
            end;
        _ ->
            {null, 0}
    end.

is_heart_beat_continue() ->
    mod_mission:is_balance() == false andalso mod_mission:is_start() == true.

%% ----------------------------------
%% @doc 	前往目标位置
%% @throws 	none
%% @end
%% ----------------------------------
go_target_pos(Robot, TargetX, TargetY, Diff, Range, State) ->
    #obj_scene_actor{
        x = X,
        y = Y,
        move_path = MovePath
    } = Robot,
    Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
    if
        Distance =< Range ->
            NewRobot = stop_move(Robot),
            {NewRobot, true};
        true ->
            NewRobot =
                if MovePath == [] ->
                    find_path(Robot, {TargetX, TargetY}, true, Diff, ?MOVE_TYPE_NORMAL, State);
                    true ->
                        Robot
                end,
            {NewRobot, false}
    end.

%% ----------------------------------
%% @doc 	搜索打怪点的怪物
%% @throws 	none
%% @end
%% ----------------------------------
search_monster(Robot, State) ->
    #obj_scene_actor{
        robot_data = RobotData,
        x = X,
        y = Y
    } = Robot,
    #robot_data{
        robot_task_context = {kill, FightMonsterId, _}
    } = RobotData,
    case get_near_monster(FightMonsterId, X, Y) of
        null ->
            {Robot, false, null};
        ObjSceneMonster ->
            #obj_scene_actor{
                obj_id = TargetObjId,
                x = MonsterX,
                y = MonsterY
            } = ObjSceneMonster,
            Robot_1 = Robot#obj_scene_actor{
                track_info = #track_info{
                    obj_type = ?OBJ_TYPE_MONSTER,
                    obj_id = TargetObjId
                }
            },
            {Robot_2, IsReach} = go_target_pos(Robot_1, MonsterX, MonsterY, 0, 300, State),
            {Robot_2, IsReach, ObjSceneMonster}
    end.

search_target_player(Robot) ->
    #obj_scene_actor{
        obj_id = RobotId,
        x = X,
        y = Y,
        track_info = #track_info{obj_type = TraceObjType, obj_id = TraceObjId}
    } = Robot,
    case ?GET_OBJ_SCENE_ACTOR(TraceObjType, TraceObjId) of
        ?UNDEFINED ->
            MissionType = get(?DICT_MISSION_TYPE),
            F =
                if MissionType == ?MISSION_TYPE_SHISHI_BOSS ->
                    fun(#filter_target{this_obj_type = ThisObjType, is_robot = _IsRobot}) ->
                        if
                            ThisObjType == ?OBJ_TYPE_MONSTER ->
                                true;
                            true ->
                                false
                        end
                    end;
                    true ->
                        fun(#filter_target{this_obj_type = ThisObjType, this_obj_id = ThisObjId}) ->
                            if
                                ThisObjType == ?OBJ_TYPE_PLAYER andalso ThisObjId == RobotId ->
                                    false;
                                true ->
                                    true
                            end
                        end
                end,

            case mod_fight_target:get_attack_target_list(mod_scene_monster_manager:get_all_obj_scene_monster_id(), [], X, Y, F, 0) of
                [] ->
                    {Robot, null};
                L ->
                    ObjSceneActor = hd(L),
                    #obj_scene_actor{
                        obj_id = TargetObjId,
                        obj_type = TargetObjType
                    } = ObjSceneActor,
                    Robot_1 = Robot#obj_scene_actor{
                        track_info = #track_info{
                            obj_type = TargetObjType,
                            obj_id = TargetObjId
                        }
                    },
                    {Robot_1, ObjSceneActor}
            end;
        ObjSceneActor ->
            {Robot, ObjSceneActor}
    end.

fight(Robot, null, _State) ->
    put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, Robot#obj_scene_actor.obj_id}, 200),
    Robot;
fight(Robot, Target, State) ->
    put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, Robot#obj_scene_actor.obj_id}, 200),
    #obj_scene_actor{
        obj_type = TargetObjType,
        obj_id = TargetObjId,
        x = TargetX,
        y = TargetY,
        go_x = TargetGoX,
        go_y = TargetGoY,
        hp = TargetHp,
        move_path = TargetMovePath
    } = Target,
    #obj_scene_actor{
        obj_id = RobotId,
        x = X,
        y = Y,
        move_path = MovePath,
        last_fight_time_ms = LastFightTime,
        last_fight_skill_id = LastSkillId,
        r_active_skill_list = RActiveSkillList,
        move_type = MoveType,
        track_info = #track_info{x = TrackX, y = TrackY},
        can_use_skill_time = CanUseSkillTime,
        anger = Anger,
        robot_data = #robot_data{
            robot_fight_cost_mana = Mana,
            robot_item_list = RobotItemList
        },
        cost = CostList
    } = Robot,
    MissionType = get(?DICT_MISSION_TYPE),
    {SceneMasterState, _} = mod_scene_event_manager:get_state(),
    if
        TargetHp > 0 ->
            IsServerControlScene = get(?DICT_SCENE_IS_SERVER_CONTROL_SCENE),
            Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
%%            ?DEBUG("机器人坐标 ： ~p ， 目标坐标 ： ~p ， 距离 ： ~p ~n", [{X, Y}, {TargetX, TargetY}, Distance]),
            {SkillDistance, DiffDistance} = {320, 180},
            {Cost, Rate} =
                case MissionType of
                    ?MISSION_TYPE_SHISHI_BOSS ->
                        mod_mission_shi_shi:get_cost_mana(Mana);
                    _ ->
                        {util_random:get_probability_item(CostList), 1}
                end,
            ScenePropId = get(?DICT_SCENE_COST_PROP_ID),
            RobotLeftPropNum = util_list:opt(ScenePropId, RobotItemList),
            if
                Distance =< SkillDistance andalso RobotLeftPropNum >= Cost ->
                    Robot_1 = stop_move(Robot),
                    NowMS = get(?DICT_NOW_MS),
                    Dir = util_math:get_direction({X, Y}, {TargetX, TargetY}),
                    case get_skill_info(CanUseSkillTime, NowMS, LastSkillId, LastFightTime, RActiveSkillList, Anger, SceneMasterState) of
                        null ->
                            Robot_1;
                        RActiveSkill ->
                            #r_active_skill{
                                id = SkillId,
                                force_wait_time = ForceWaitTime
                            } = RActiveSkill,
                            RequestFightParam =
                                #request_fight_param{
                                    attack_type = ?OBJ_TYPE_PLAYER,
                                    obj_type = ?OBJ_TYPE_PLAYER,
                                    obj_id = RobotId,
                                    skill_id = SkillId,
                                    dir = Dir,
                                    target_type = TargetObjType,
                                    target_id = TargetObjId,
                                    player_left_coin = RobotLeftPropNum,
                                    cost = Cost,
                                    rate = Rate
                                },
                            self() ! {?MSG_FIGHT, RequestFightParam},
                            put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, RobotId}, ForceWaitTime + 100),
                            decrease_prop(Robot_1#obj_scene_actor{last_fight_skill_id = SkillId}, [{ScenePropId, Cost}])
                    end;
                Distance < 400 andalso (IsServerControlScene orelse (TargetMovePath == [] andalso TargetGoX == 0 andalso TargetGoY == 0)) ->
                    put({?DICT_SCENE_NEXT_ROBOT_HEART_TIME, Robot#obj_scene_actor.obj_id}, 50),
                    if
                        MovePath == [] orelse MoveType == ?MOVE_TYPE_NORMAL ->
                            RealDiffDistance =
                                if IsServerControlScene ->
                                    DiffDistance + 30;
                                    true ->
                                        DiffDistance
                                end,
                            find_path(Robot, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_NORMAL, State);
%%                        find_path(Robot, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_MOMENT, State);
                        true ->
                            Robot
                    end;
                true ->
                    TargetMoveDis = util_math:get_distance({TargetX, TargetY}, {TrackX, TrackY}),
                    if MovePath == [] orelse TargetMoveDis > 80 ->
                        Robot_1 = find_path(Robot, {TargetX, TargetY}, true, DiffDistance, ?MOVE_TYPE_NORMAL, State),
                        Robot_1#obj_scene_actor{
                            track_info = #track_info{
                                obj_type = TargetObjType,
                                obj_id = TargetObjId,
                                x = TargetX,
                                y = TargetY
                            }
                        };
                        true ->
                            Robot
                    end
            end;
        true ->
            Robot
    end.

stop_move(Robot = #obj_scene_actor{obj_id = ObjId, move_path = MovePath, go_x = GoX, go_y = GoY, x = X, y = Y}) ->
    if MovePath =/= [] orelse GoX =/= 0 orelse GoY =/= 0 ->
%%        api_scene:notice_player_stop_move(mod_scene_grid_manager:get_subscribe_player_id_list(GridId), ObjId, X, Y),
        api_scene:notice_player_stop_move(mod_scene_player_manager:get_all_obj_scene_player_id(), ObjId, X, Y),
        Robot#obj_scene_actor{
            move_path = [],
            go_y = 0,
            go_x = 0
        };
        true ->
            Robot
    end.

find_path(Robot, {TargetX, TargetY}, IsFloyd, Diff, MoveType, #scene_state{scene_id = _SceneId, scene_navigate_worker = NavigateWorker}) ->
    #obj_scene_actor{
        obj_id = ObjId,
        x = X,
        y = Y
    } = Robot,
    MaxNavigateNode = 1500,
%%    ?DEBUG("机器人寻路：~p", [Robot#obj_scene_actor.obj_id]),
    scene_navigate_worker:request_navigate(NavigateWorker, ?OBJ_TYPE_PLAYER, ObjId, {X, Y}, {TargetX, TargetY}, IsFloyd, true, MaxNavigateNode, Diff),
    Robot#obj_scene_actor{
        is_wait_navigate = true,
        move_type = MoveType
    }.

get_skill_info(CanUseSkillTime, Now, LastSkillId, LastFightTime, SkillList, Anger, SceneMasterState) ->
    IsCanUseSkill = Now >= CanUseSkillTime,
    SkillInfo =
        if IsCanUseSkill ->
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
            );
            true ->
                null
        end,
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

get_near_monster(MonsterId, X, Y) ->
    {SceneMonster, _} =
        lists:foldl(
            fun(ObjSceneMonsterId, {TmpMonster, TmpDis}) ->
                ObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId),
                #obj_scene_actor{
                    base_id = ThisBaseId,
                    x = ThisX,
                    y = ThisY,
                    is_boss = IsBoss
                } = ObjSceneMonster,
                if
                    MonsterId == 0 orelse ThisBaseId == MonsterId orelse IsBoss ->
                        ThisDis = util_math:get_distance({X, Y}, {ThisX, ThisY}),
                        if TmpMonster == null ->
                            {ObjSceneMonster, ThisDis};
                            true ->
                                if ThisDis < TmpDis ->
                                    {ObjSceneMonster, ThisDis};
                                    true ->
                                        {TmpMonster, TmpDis}
                                end
                        end;
                    true ->
                        {TmpMonster, TmpDis}
                end
            end,
            {null, 0},
            mod_scene_monster_manager:get_all_obj_scene_monster_id()
        ),
    SceneMonster.

%% ----------------------------------
%% @doc 	寻路结果回调
%% @throws 	none
%% @end
%% ----------------------------------
handle_navigate_result({Result, RobotId, {TargetX, TargetY}, NewMovePath}, _) ->
    case ?GET_OBJ_SCENE_PLAYER(RobotId) of
        ?UNDEFINED ->
            noop;
        ObjMonster ->
            #obj_scene_actor{
                is_wait_navigate = IsWaitNavigate,
                hp = Hp,
                move_type = MoveType,
                x = X,
                y = Y
            } = ObjMonster,
            if
                Hp > 0 andalso IsWaitNavigate == true ->
                    NewObjMonster =
                        if
                            Result == success orelse Result == max_node ->
                                if NewMovePath =/= [] ->
%%                                    api_scene:notice_player_move(mod_scene_grid_manager:get_subscribe_player_id_list(GridId), RobotId, TargetX, TargetY, MoveType, NewMovePath, 0, 0, "");
                                    api_scene:notice_player_move(mod_scene_player_manager:get_all_obj_scene_player_id(), RobotId, TargetX, TargetY, MoveType, NewMovePath, 0, 0, "");
                                    true ->
                                        noop
                                end,
                                ObjMonster#obj_scene_actor{
                                    is_wait_navigate = false,
                                    move_path = NewMovePath,
                                    last_move_time = util_time:milli_timestamp(),
                                    go_x = TargetX,
                                    go_y = TargetY
                                };
                            true ->
                                ?ERROR("寻路失败:~p~n", [{get(?DICT_SCENE_ID), RobotId, {X, Y}, {TargetX, TargetY}, NewMovePath}]),
                                ObjMonster#obj_scene_actor{
                                    is_wait_navigate = false,
                                    next_can_heart_time = util_time:milli_timestamp() + 10000,
                                    track_info = #track_info{}
                                }
                        end,
                    ?UPDATE_OBJ_SCENE_PLAYER(NewObjMonster);
                true ->
                    noop
            end
    end.

award_prop(ObjRobot, []) ->
    ObjRobot;
award_prop(ObjRobot, PropList) ->
    #obj_scene_actor{
        can_action_time = CanActionTime,
        robot_data = RobotData
    } = ObjRobot,
    #robot_data{
        robot_item_list = ItemList,
        robot_leave_list = [LeavePropId, LeaveNumMin, LeaveNumMax, LeaveTime],
        robot_destroy_time_ms = RobotDestroyTimeMs
    } = RobotData,
    NewItemList = do_award_prop(ItemList, PropList),
    LeavePropNum =
        case lists:keyfind(LeavePropId, 1, NewItemList) of
            false ->
                0;
            {LeavePropId, LeavePropNum1} ->
                LeavePropNum1
        end,
    {NewRobotDestroyTimeMs, NewCanActionTime} =
        if
            LeaveNumMin > LeavePropNum orelse (LeavePropNum > LeaveNumMax andalso LeavePropNum > 0) ->
                {get(?DICT_NOW_MS) + LeaveTime * ?SECOND_MS, get(?DICT_NOW_MS) + LeaveTime * ?SECOND_MS};
            true ->
                {RobotDestroyTimeMs, CanActionTime}
        end,
    ObjRobot#obj_scene_actor{
        can_action_time = NewCanActionTime,
        robot_data = RobotData#robot_data{
            robot_item_list = NewItemList,
            robot_destroy_time_ms = NewRobotDestroyTimeMs
        }
    }.
do_award_prop(ItemList, []) ->
    ItemList;
do_award_prop(ItemList, [{_PropId, 0} | PropList]) ->
    do_award_prop(ItemList, PropList);
do_award_prop(ItemList, [{PropId, Num} | PropList]) ->
    NewItemList =
        case lists:keytake(PropId, 1, ItemList) of
            false ->
                [{PropId, Num} | ItemList];
            {value, {PropId, OldNum}, ItemList1} ->
                [{PropId, OldNum + Num} | ItemList1]
        end,
    do_award_prop(NewItemList, PropList).

decrease_prop(ObjRobot, []) ->
    ObjRobot;
decrease_prop(ObjRobot, PropList) ->
    #obj_scene_actor{
        robot_data = RobotData,
        can_action_time = CanActionTime
    } = ObjRobot,
    #robot_data{
        robot_item_list = ItemList,
        robot_leave_list = [LeavePropId, LeaveNumMin, LeaveNumMax, LeaveTime],
        robot_destroy_time_ms = RobotDestroyTimeMs
    } = RobotData,
    NewItemList = do_decrease_prop(ItemList, PropList),
    LeavePropNum =
        case lists:keyfind(LeavePropId, 1, NewItemList) of
            false ->
                0;
            {LeavePropId, LeavePropNum1} ->
                LeavePropNum1
        end,
    {NewRobotDestroyTimeMs, NewCanActionTime} =
        if
            LeaveNumMin > LeavePropNum orelse (LeavePropNum > LeaveNumMax andalso LeavePropNum > 0) ->
                {get(?DICT_NOW_MS) + LeaveTime * ?SECOND_MS, get(?DICT_NOW_MS) + LeaveTime * ?SECOND_MS};
            true ->
                {RobotDestroyTimeMs, CanActionTime}
        end,
    ObjRobot#obj_scene_actor{
        can_action_time = NewCanActionTime,
        robot_data = RobotData#robot_data{
            robot_item_list = NewItemList,
            robot_destroy_time_ms = NewRobotDestroyTimeMs
        }
    }.
do_decrease_prop(ItemList, []) ->
    ItemList;
do_decrease_prop(ItemList, [{_PropId, 0} | PropList]) ->
    do_decrease_prop(ItemList, PropList);
do_decrease_prop(ItemList, [{PropId, Num} | PropList]) ->
    NewItemList =
        case lists:keytake(PropId, 1, ItemList) of
            false ->
                exit({robot_prop_error, ItemList, {PropId, Num}});
            {value, {PropId, OldNum}, ItemList1} ->
                if
                    OldNum >= Num ->
                        NewNum = OldNum - Num,
                        [{PropId, NewNum} | ItemList1];
                    true ->
                        exit({robot_prop_error, ItemList, OldNum, {PropId, Num}})
                end
        end,
    do_decrease_prop(NewItemList, PropList).

%% @doc 玩家进入场景
player_enter_scene(_PlayerId) ->
    {{PlayerNum, _PlayerIdList}, {RobotNum, RobotIdList}} = mod_scene_player_manager:get_player_info(),
    TotalNum = PlayerNum + RobotNum,
    MaxPlayerNum = get(?DICT_MAX_PLAYER_NUM),
    if
        TotalNum > MaxPlayerNum ->
            {List, _} = lists:split(min(RobotNum, TotalNum - MaxPlayerNum), util_list:shuffle(RobotIdList)),
            lists:foreach(
                fun(RobotId) ->
                    handle_robot_death(RobotId)
                end, List
            );
        true ->
            noop
    end.

%% @doc 机器人开启boss事件
handle_start_boss_event(BossMonsterId) ->
    RobotIdList = [PlayerId || PlayerId <- mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId < 10000],
    lists:foreach(
        fun(RobotId) ->
            ObjActor = ?GET_OBJ_SCENE_PLAYER(RobotId),
            #obj_scene_actor{
                robot_data = RobotData
            } = ObjActor,
            NewRobot = RobotData#robot_data{
                robot_task_context = {kill, BossMonsterId, 1},
                robot_task_num = 0,
                robot_task_id = 0,
                robot_task_status = ?FALSE
            },
%%            ?DEBUG("机器人 ： ~p,开启击杀 boss 任务 ： ~p", [RobotId, BossMonsterId]),
            BossObjId = get_boss(mod_scene_monster_manager:get_all_obj_scene_monster_id()),
            ?UPDATE_OBJ_SCENE_ACTOR(ObjActor#obj_scene_actor{robot_data = NewRobot, track_info = #track_info{obj_type = ?OBJ_TYPE_MONSTER, obj_id = BossObjId}})
        end,
        RobotIdList
    ).
get_boss([]) ->
    0;
get_boss([MonsterObjId | MonsterObjIdList]) ->
    #obj_scene_actor{
        is_boss = IsBoss
    } = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
    if
        IsBoss ->
            MonsterObjId;
        true ->
            get_boss(MonsterObjIdList)
    end.

%% ================================================ 模板操作 ================================================

get_t_robot(Id) ->
    t_robot:assert_get({Id}).