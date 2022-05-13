-module(robot_socket).
-include("p_message.hrl").
-include("p_enum.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("scene.hrl").
-include("robot.hrl").
-include("common.hrl").
-include("skill.hrl").
-include("msg.hrl").
-include("system.hrl").
-include("client.hrl").

%% API
-compile(export_all).

%%%% 登录后协议通信：
%%{m_login_enter_game_tos}
%%{m_login_heart_beat_tos,<<>>}
%%{m_player_init_player_data_toc, ---}
%%{m_scene_notice_prepare_scene_toc,10000}
%%{m_tongxingzheng_reward_info_notice_toc,7,200,[0,1,2,3,4,5,6,7],[],0,false,1}]
%%{m_tongxingzheng_task_info_notice_toc
%%{m_scene_load_scene_tos,1204,640}
%%{m_scene_load_scene_toc,10000,

%% 进入场景流程
%% {m_scene_enter_scene_tos,1001}
%% {m_scene_notice_prepare_scene_toc,1001}
%% {m_scene_load_scene_tos,1202,640}
%% {m_scene_load_scene_toc,1001,
%%

handle_tcp_data(Data1) ->
%%    ?DEBUG("机器人接受数据 ： ~p", [Data1]),
    DataRecord = try proto:decode(Data1)
                 catch
                     _E:_RE ->
                         ok
                 end,
%%    ?DEBUG("机器人接受数据1 ： ~p", [DataRecord]),
    case DataRecord of
        %% 登录
        #m_login_login_toc{} = R ->
            ?DEBUG("压测 ： 登录"),
            handle_login(R);
        %% 创角
        #m_login_create_role_toc{} = R ->
            ?DEBUG("压测 ： 创角"),
            handle_create_role(R);
        %% 初始化玩家数据
        #m_player_init_player_data_toc{} = R ->
            ?DEBUG("压测 ： 初始化玩家数据"),
            handle_init_player_data(R);
%%        %% 通知准备加载场景
        #m_scene_notice_prepare_scene_toc{} = R ->
            ?DEBUG("压测 ： 通知准备加载场景"),
            handle_notice_prepare_scene(R);
        %% 读取场景
        #m_scene_load_scene_toc{} = R ->
            ?DEBUG("压测 ： 读取场景"),
            handle_load_scene(R);
        %% @todo 进入场景 好像不走这个
        #m_scene_enter_scene_toc{} = R ->
            ?DEBUG("压测 ： 进入场景"),
            handle_enter_scene_toc(R);
        %% 玩家 PLAYER SCENE MSG
        %% 通知玩家移动
        #m_scene_notice_player_move_toc{} = R ->
%%            ?DEBUG("压测 ： 通知玩家移动"),
            handle_player_move(R);
        %% 通知修复玩家位置
        #m_scene_notice_correct_player_pos_toc{} = R ->
            ?DEBUG("压测 ： 通知修复玩家位置"),
            handle_correct_player_pos(R);
        %% 怪物 MONSTER SCENE MSG
        #m_scene_notice_monster_enter_toc{} = R ->
%%            ?DEBUG("压测 ： 通知怪物进入"),
            handle_monster_enter(R);
        #m_scene_notice_monster_leave_toc{} = R ->
%%            ?DEBUG("压测 ： 通知怪物离开"),
            handle_monster_leave(R);
        #m_scene_notice_monster_move_toc{} = R ->
%%            ?DEBUG("压测 ： 通知怪物移动"),
            handle_monster_move(R);
        #m_scene_notice_monster_stop_move_toc{} = R ->
%%            ?DEBUG("压测 ： 通知怪物停止移动"),
            handle_monster_stop_move(R);
        #m_scene_notice_monster_teleport_toc{} = R ->
%%            ?DEBUG("压测 ： 通知怪物闪现"),
            handle_monster_teleport(R);
%%        #m_broadcast_other_player_attr_change_toc{} = R ->
%%            handle_other_player_attr_change(R);
        %% 物品 ITEM SCENE MSG
        #m_scene_notice_item_enter_toc{} = R ->
            handle_item_enter(R);
        #m_scene_notice_item_leave_toc{} = R ->
            handle_item_leave(R);
        #m_scene_notice_player_stop_move_toc{} = R ->
            handle_player_stop_move(R);
        #m_scene_notice_scene_player_enter_toc{} = R ->
            handle_player_enter(R);
        #m_scene_notice_scene_player_leave_toc{} = R ->
            handle_player_leave(R);
        #m_scene_load_scene_toc{} = _R ->
            request_load_scene();
        #m_scene_sync_scene_toc{} = R ->
            handle_sync_scene(R);
        %% 怒气变更
        #m_scene_notice_anger_change_toc{} = R ->
            handle_anger_charge(R);
        #m_prop_notice_update_prop_toc{} = R ->
            handle_update_prop(R);
%%        #m_notice_task_update_toc{} = R ->
%%            handle_update_task(R);
        #m_player_notice_player_attr_change_toc{} = R ->
            handle_player_attr_change(R);
%%        #m_notice_scene_monster_attr_change_toc{} = R ->
%%            handle_monster_attr_change(R);
%%        #m_broadcast_obj_hp_change_toc{} = R ->
%%            handle_broadcast_obj_hp_change(R);
        #m_fight_notice_fight_result_toc{} = R ->
%%            ?DEBUG("压测 ： 收到战斗结果"),
            handle_fight_result(R);
%%        #m_notice_player_active_skill_upgrade_toc{} = R ->
%%            handle_active_skill_upgrade(R);
%%        #m_player_fight_toc{} ->
%%            put(?ROBOT_DICT_IS_REQUEST_FIGHT, false);
%%        #m_notice_result_toc{} = R ->
%%            handle_mission_result();
%%        #m_challenge_mission_toc{} = R ->
%%            handle_challenge_mission_toc(R);
%%        #m_notice_result_toc{} = R ->
%%            handle_notice_mission_result_toc(R);
%%        %% 玩家
%%        #m_notice_player_exp_change_toc{} = R ->
%%            handle_level_change(R);
        _Other ->
%%            ?DEBUG("机器人接受其他数据 ： ~p", [_Other]),
            noop
    end,
    ok.

ws_request() ->
    Data =
        [
            "HTTP/1.1\r\n",
            "Host: 192.168.31.160:13101\r\n",
            "Connection: Upgrade\r\n",
            "Pragma: no-cache\r\n",
            "Cache-Control: no-cache\r\n",
            "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36\r\n",
            "Upgrade: websocket\r\n",
            "Origin: http://192.168.31.100\r\n",
            "Sec-WebSocket-Version: 13\r\n",
            "Accept-Encoding: gzip, deflate\r\n",
            "Accept-Language: zh-CN,zh;q=0.9\r\n",
            "Sec-WebSocket-Key: GDQwVLxryON5WpY2vf6E2w==\r\n",
            "Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits\r\n",
            "\r\n"
        ],
    gen_tcp:send(get(socket), Data).

try_request_charge() ->
    request_charge(util_random:get_list_random_member([3000, 4000, 5000])).
request_charge(ItemId) ->
    send(proto:encode(
        #m_charge_charge_tos{
            item_id = ItemId,
            count = 1
        }
    )).

handle_login(R) ->
    Result = R#m_login_login_toc.result,
    case Result of
        ?P_SUCCESS ->
            request_enter_game();
        ?P_NO_ROLE ->
            request_create_role();
        Other ->
            exit({login_fail, Other})
    end.

handle_create_role(R) ->
    Result = R#m_login_create_role_toc.result,
    case Result of
        ?P_SUCCESS ->
            request_login();
        Other ->
            exit({create_role_fail, Other})
    end.
request_login() ->
    Time = util_time:timestamp(),
    LoginTicket = login_server:create_login_ticket(robot:get_acc_id(), Time),
    send(proto:encode(
        #m_login_login_tos{
            server_id = get(server_id),
            login_type = 0,
            ticket = LoginTicket,
            acc_id = robot:get_acc_id(),
            pf = "fb",
            platform = 0,
            entry = 0,
            qua = "3636",
            time = Time,
            platform_id = get(platform_id),
            via = "Windows PC",
            is_gm_login = 0,
            gm_account = ""
        })).

handle_init_player_data(PbPlayerInitPlayerData) ->
    #m_player_init_player_data_toc{
        role_data = RoleData,
        anger = Anger,
        pk_mode = PkMode,
        prop_list = PropList
    } = PbPlayerInitPlayerData,
    #roledata{
        player_id = PlayerId,
        sex = Sex
    } = RoleData,
    put(?DICT_PLAYER_ID, PlayerId),
    put(player_id, PlayerId),
    put(role_data, RoleData),
    put(anger, Anger),

    ObjRobot = #robot{
        player_id = PlayerId,
        pk_mode = PkMode,
        sex = Sex,
        skill_list = mod_active_skill:tran_r_active_skill_list(),
        prop_list = [{PropId, Num} || #prop{prop_id = PropId, num = Num} <- PropList]
    },
    robot:update_obj_robot(ObjRobot),
%%    #ets_obj_player{
%%        client_worker = ClientWorker
%%    } = mod_obj_player:get_obj_player(PlayerId),
%%    put(?ROBOT_DICT_CLIENT_WORKER, ClientWorker),
%%    Self = self(),
    robot:clock_check_close(PlayerId).
%%    client_worker:init_robot_worker(ClientWorker, self()),
%%    client_sender:init_socket_receiver(SenderWorker, Self).

handle_notice_prepare_scene(R) ->
    #m_scene_notice_prepare_scene_toc{
        scene_id = SceneId
    } = R,
    request_load_scene(),
    request_update_client_data([{"k_last_scene", SceneId}]).

request_update_client_data(List) ->
    send(
        proto:encode(
            #m_player_update_client_data_tos{
                client_data_list = [#clientdata{id = util:to_binary(Key), value = util:to_binary(Value)} || {Key, Value} <- List]
            }
        )
    ).

request_load_scene() ->
    send(
        proto:encode(
            #m_scene_load_scene_tos{
                screen_width = 1250,
                screen_high = 650
            }
        )
    ).

handle_load_scene(R) ->
    #m_scene_load_scene_toc{
        scene_id = SceneId,
        scene_player_list = ScenePlayerList,
        scene_monster_list = SceneMonsterList,
        scene_item_list = SceneItemList
    } = R,
    put(?ROBOT_DICT_IS_REQUEST_ENTER_SCENE, false),
    if
        SceneId == ?SD_MY_MAIN_SCENE ->
            try_request_charge(),
            request_enter_scene(1001, 3 * ?SECOND_MS);
        SceneId == 1000 ->
            request_update_client_data([{"k_guide_select", 1}]),
            request_update_client_data([{"k_guide_over", 1}]),
            request_enter_scene(?SD_MY_MAIN_SCENE);
        true ->
            #t_scene{
                map_id = MapId
            } = mod_scene:get_t_scene(SceneId),
%%    put(?ROBOT_DICT_IS_REQUEST_REBIRTH, false),
%%    io:format("进入场景:~p~n", [SceneId]),
%%    Now = util:milli_timestamp(),
%%    SceneGridTable = get(?DICT_SCENE_GRID_TABLE),
%%    mod_scene_grid:erase_jump_grid(),
%%    mod_scene_grid:erase_scene_grid(SceneGridTable),
            mod_map:unload(),
            mod_map:load(MapId),
%%    mod_scene_grid:init_jump_tile(SceneId),
%%    mod_scene_grid:init_scene_grid(SceneId, SceneGridTable),
            robot:drop_all_scene_item(),
            robot:drop_all_scene_monster(),
            robot:drop_all_scene_player(),

            lists:foreach(
                fun(CScenePlayer) ->
                    EtsScenePlayer = decode_c_scene_player(CScenePlayer),
                    robot:update_scene_player(EtsScenePlayer)
                end,
                ScenePlayerList
            ),
            lists:foreach(
                fun(CSceneMonster) ->
                    EtsSceneMonster = decode_c_scene_monster(CSceneMonster),
                    robot:update_scene_monster(EtsSceneMonster)
                end,
                SceneMonsterList
            ),

            lists:foreach(
                fun(CSceneItem) ->
                    EtsSceneItem = decode_c_scene_item(CSceneItem),
                    robot:update_scene_item(EtsSceneItem)
                end,
                SceneItemList
            ),
            Robot = robot:get_robot(),
%%
%%    KeyS = erlang:get_keys(),
%%    lists:foreach(
%%        fun(Key) ->
%%            case Key of
%%                {monster_id, _} ->
%%                    erlang:erase(Key);
%%                _ ->
%%                    noop
%%            end
%%        end,
%%        KeyS
%%    ),
%%    lists:foreach(
%%        fun(E) ->
%%            put({monster_id, util:opt(monster_id, E)},
%%                {
%%                    util:opt(x, E),
%%                    util:opt(y, E)
%%                })
%%        end,
%%        TMonsterList
%%    ),
            #robot{
                player_id = PlayerId
            } = Robot,

%%    if OldSceneId > 0 ->
%%        mod_scene_event_manager:erase_scene_event(OldSceneId);
%%        true ->
%%            noop
%%    end,
%%    mod_scene_event_manager:load_scene_event(SceneId),

            ServerRobot = lists:keyfind(PlayerId, #sceneplayer.player_id, ScenePlayerList),
            put(robot_map_id, MapId),
            NewRobot = update_robot_from_c_scene_player(Robot#robot{scene_id = SceneId}, ServerRobot),
            robot:update_obj_robot(NewRobot),


%%    if
%%        Type == 2 ->
%%            #t_mission_type{
%%                delay_time = MissionDelayTime
%%            } = mod_mission:get_mission_type(MissionType),
%%            Now = util:milli_timestamp(),
%%            put(?DICT_CAN_ROBOT_ACTION_TIME, Now + MissionDelayTime);
%%        true ->
%%            noop
%%    end,
%%    case mod_scene:is_mission_scene(SceneId) of
%%        true ->
%%            util:sleep(5000),
%%            case mod_scene_event:get_scene_event_id_list(SceneId) of
%%                [] ->
%%                    noop;
%%                EventIdList ->
%%                    request_trigger_event(EventIdList)
%%            end;
%%        false ->
%%            noop
%%    end,
            case get(?ROBOT_DICT_IS_START) of
                true ->
                    noop;
                false ->
                    put(?ROBOT_DICT_IS_START, true),
                    erlang:send_after(10000, self(), {heart_beat, PlayerId})
%%            if Self#sceneplayer.pet_steps > 0 ->
%%                erlang:send_after(?ROBOT_PET_HEART_BEAT_TIME, self(), {pet_heart_beat, PlayerId});
%%                true ->
%%                    noop
            end
%%            end
    end.
update_robot_from_c_scene_player(Robot, ScenePlayer) ->
    #sceneplayer{
        x = X,
        y = Y,
        move_speed = MoveSpeed,
        buff_list = BuffList,
        move_path = MovePath,
        go_x = GoX,
        go_y = GoY,
        anger = Anger,
        dizzy_close_time = DizzyCloseTime,
        kuangbao_time = KuangBaoTime,
        level = Level,
        vip_level = VipLevel
    } = ScenePlayer,
    Robot#robot{
        x = X,
        y = Y,
        speed = MoveSpeed,
        buff_list = BuffList,
        move_path = MovePath,
        go_x = GoX,
        go_y = GoY,
        anger = Anger,
        dizzy_close_time = DizzyCloseTime,
        kuangbao_time = KuangBaoTime,
        level = Level,
        vip_level = VipLevel
    }.

%%request_assassinate_pos(AssassinatePlayerId) ->
%%    LastRequestTime =
%%        case get(?ROBOT_DICT_LAST_REQUEST_PLAYER_POS_TIME) of
%%            ?UNDEFINED ->
%%                0;
%%            Time ->
%%                Time
%%        end,
%%    Now = util:timestamp(),
%%    if Now - LastRequestTime > 5 ->
%%%%        ?DEBUG("request_assassinate_pos:~p~n", [AssassinatePlayerId]),
%%        put(?ROBOT_DICT_LAST_REQUEST_PLAYER_POS_TIME, Now),
%%        send(proto:encode(#m_get_player_pos_tos{type = 3, pos_player_id = AssassinatePlayerId}));
%%        true ->
%%            noop
%%    end.

%%request_get_assassinate() ->
%%    case get(?ROBOT_DICT_IS_REQUEST_GET_ASSASSINATE) of
%%        true ->
%%            noop;
%%        _ ->
%%            put(?ROBOT_DICT_IS_REQUEST_GET_ASSASSINATE, true),
%%            request_assassinate_panel_info(),
%%            send(p_assassinate:encode(#m_get_assassinate_tos{}))
%%    end.


%%request_remove_assassinate_player() ->
%%    send(p_assassinate:encode(#m_remove_assassinate_player_tos{})).
%%
%%request_assassinate_panel_info() ->
%%    send(p_assassinate:encode(#m_assassinate_panel_info_tos{})).

%%handle_get_assassinate(R) ->
%%    #m_get_assassinate_toc{enum = Enum, get_list = List} = R,
%%    put(?ROBOT_DICT_IS_REQUEST_GET_ASSASSINATE, false),
%%    if
%%        Enum == ?SUCCESS ->
%%%%        ?DEBUG("List:~p~n", [List]),
%%            [{_, _, AssassinatePlayerId, _}] = List,
%%            Robot = robot:get_robot(),
%%            robot:update_obj_robot(
%%                Robot#robot{
%%                    assassinate_player_id = AssassinatePlayerId,
%%                    assassinate_scene_id = 0,
%%                    assassinate_scene_y = 0,
%%                    assassinate_scene_x = 0,
%%                    request_get_assassinate_pos_times = 0
%%                }
%%            );
%%        true ->
%%            Robot = robot:get_robot(),
%%            #robot{
%%                task_id = TaskId
%%            } = Robot,
%%            Task = mod_task:get_task(TaskId),
%%            if Task == null ->
%%                ?ERROR("null task:~p", [TaskId]);
%%                true ->
%%                    noop
%%            end,
%%            #t_task{
%%                content_list = ContentList
%%            } = Task,
%%
%%            case ContentList of
%%                [?TASK_CONTENT_TYPE_AN_SHA, _] ->
%%                    robot_socket:request_auto_finish_task(TaskId);
%%                _ ->
%%                    noop
%%            end
%%%%            exit({assassinate_fail, Enum})
%%    end.

%%handle_notice_assassinate_state() ->
%%    Robot = robot:get_robot(),
%%    robot:update_obj_robot(
%%        Robot#robot{
%%            assassinate_player_id = 0,
%%            assassinate_scene_id = 0,
%%            assassinate_scene_y = 0,
%%            assassinate_scene_x = 0,
%%            request_get_assassinate_pos_times = 0
%%        }
%%    ).
%%handle_get_player_pos(R) ->
%%    #m_get_player_pos_toc{
%%        pos_player_id = PlayerId,
%%        scene_id = SceneId,
%%        x = X,
%%        y = Y
%%    } = R,
%%
%%    Robot = robot:get_robot(),
%%%%    ?DEBUG("handle_get_player_pos:~p~n", [{PlayerId, SceneId, Robot#robot.assassinate_player_id}]),
%%    if
%%        PlayerId == Robot#robot.assassinate_player_id ->
%%            robot:update_obj_robot(Robot#robot{
%%                assassinate_scene_id = SceneId,
%%                assassinate_scene_x = X,
%%                assassinate_scene_y = Y,
%%                request_get_assassinate_pos_times = Robot#robot.request_get_assassinate_pos_times + 1
%%            });
%%        true ->
%%            noop
%%    end.

%%request_random_set_eight(Robot, Now) ->
%%    if
%%        Robot#robot.scene_id == ?SCENE_LUN_JIAN_TA orelse Robot#robot.level < 30 ->
%%            noop;
%%        true ->
%%            LastTime =
%%                case get(?ROBOT_DICT_LAST_REQUEST_CHANGE_SWORD_TIME) of
%%                    ?UNDEFINED ->
%%                        0;
%%                    Time_ ->
%%                        Time_
%%                end,
%%            if
%%                Now - LastTime > 5 * ?MINUTE_MS ->
%%                    put(?ROBOT_DICT_LAST_REQUEST_CHANGE_SWORD_TIME, Now),
%%                    send(p_eight_sword:encode(#m_player_random_set_eight_tos{}), util:random_number(3000, 20000));
%%                true ->
%%                    noop
%%            end
%%    end.

%%handle_trigger_event_id_list(EventIdList) ->
%%    lists:foreach(
%%        fun(EventId) ->
%%            #t_game_event{
%%                handle_list = ActionIdList
%%%%                scene_id = EventSceneId,
%%%%                is_trigger_one = IsTriggerOne,
%%%%                last_event_id = LastEventId,
%%%%                task_id = NeedTaskId
%%            } = mod_scene_event_manager:get_t_game_event(EventId),
%%            lists:foreach(
%%                fun(ActionId) ->
%%                    Action = db_t_game_event_handle:get({ActionId}),
%%
%%                    ?ASSERT(Action =/= null, {action_no_defined, EventId, ActionId}),
%%
%%                    #t_game_event_handle{
%%                        delay_time = _Delay,
%%                        handle_type = Type,
%%                        param_list = ParamList
%%                    } = Action,
%%                    AtomType = erlang:list_to_atom(Type),
%%                    case AtomType of
%%                        ?SCENE_EVENT_MAINPLAYER_MOVE ->
%%                            [GoX, GoY, _Type] = ParamList,
%%                            Robot = robot:get_robot(),
%%                            Now = util:milli_timestamp(),
%%                            #robot{
%%                                x = X,
%%                                y = Y,
%%                                player_id = PlayerId,
%%                                map_id = MapId,
%%                                speed = _MoveSpeed
%%                            } = Robot,
%%                            MovePath = navigate:start_2(MapId, {X, Y}, {GoX, GoY}, true, 500, 0),
%%                            Len = util:get_distance_from_path([{X, Y} | MovePath]),
%%                            Time = trunc(Len / ?SSD_CHONGCI_SPEED * 1000),
%%                            robot_socket:request_move(PlayerId, ?MOMENT, MovePath),
%%%%                            if MapId == 1004 ->
%%%%                                ?DEBUG("事件 :~p", [{}]);
%%%%                                true ->
%%%%                                    noop
%%%%                            end,
%%                            robot_socket:request_move_step(PlayerId, GoX, GoY, [], Time),
%%                            NewRobot = Robot#robot{
%%                                next_can_heart_beat_time = Now + Time
%%                            },
%%                            robot:update_obj_robot(NewRobot);
%%                        _ ->
%%                            noop
%%                    end
%%                end,
%%                ActionIdList
%%            )
%%        end,
%%        EventIdList
%%    ).

handle_player_attr_change(R) ->
    #m_player_notice_player_attr_change_toc{
        player_id = PlayerId,
        list = L
    } = R,
    Robot = robot:get_robot(),
    #robot{
        player_id = RobotId
    } = Robot,
    if
        RobotId == PlayerId ->
            NewRobot =
                lists:foldl(
                    fun(#'m_player_notice_player_attr_change_toc.attr_change'{attr = AttrId, value = Value}, TmpRobot) ->
                        case AttrId of
                            ?P_VIP_LEVEL ->
                                TmpRobot#robot{
                                    vip_level = Value
                                };
                            ?P_LEVEL ->
                                TmpRobot#robot{
                                    level = Value
                                };
                            ?P_MOVE_SPEED ->
                                TmpRobot#robot{
                                    speed = Value
                                };
                            _ ->
                                TmpRobot
                        end
                    end,
                    Robot,
                    L
                ),
            robot:update_obj_robot(NewRobot);
        true ->
            noop
    end.


%%handle_other_player_attr_change(R) ->
%%    PlayerId = R#m_broadcast_other_player_attr_change_toc.player_id,
%%    L = R#m_broadcast_other_player_attr_change_toc.attr_list,
%%    case robot:get_scene_player(PlayerId) of
%%        null ->
%%            ?ERROR("没有发现玩家:~p", [{get(player_id), PlayerId}]);
%%        ScenePlayer ->
%%            NewScenePlayer =
%%                lists:foldl(
%%                    fun({AttrId, Value}, TmpPlayer) ->
%%                        case AttrId of
%%                            ?HP ->
%%                                TmpPlayer#scene_player{
%%                                    hp = Value
%%                                };
%%                            ?MOVE_SPEED ->
%%                                TmpPlayer#scene_player{
%%                                    speed = Value
%%                                };
%%%%                            ?LEVEL ->
%%%%                                handle_level_change(0),
%%%%                                TmpPlayer#scene_player{
%%%%                                    level = Value
%%%%                                };
%%%%                            ?IS_MOUNT ->
%%%%                                TmpPlayer#scene_player{
%%%%                                    mount_status = Value
%%%%                                };
%%                            _ ->
%%                                TmpPlayer
%%                        end
%%                    end,
%%                    ScenePlayer,
%%                    L
%%                ),
%%            robot:update_scene_player(NewScenePlayer)
%%    end.


%%request_change_mount_status(PlayerId, Status) ->
%%    case ?PROCESS_TYPE of
%%        ?PROCESS_TYPE_ROBOT_WORKER ->
%%            send(p_player:encode(#m_change_mount_status_tos{is_mount = Status}));
%%        ?PROCESS_TYPE_SCENE_WORKER ->
%%            self() ! {?MSG_SYNC_PLAYER_DATA, PlayerId, [{?MSG_SYNC_MOUNT_STATUS, Status}]}
%%    end.


%%handle_start_collect_toc(R) ->
%%    #m_start_collect_toc{result = Result, scene_item_id = SceneItemId} = R,
%%    Robot = robot:get_robot(),
%%    if
%%        Result == ?SUCCESS ->
%%            {SceneItemId, _} = Robot#robot.collect_info,
%%            NewRobot = Robot#robot{
%%                collect_info = {SceneItemId, util:milli_timestamp()}
%%            },
%%            robot:update_obj_robot(NewRobot);
%%        Result == ?NOT_EXISTS ->
%%%%            ?DEBUG("~p~n", [66666666]),
%%            robot:delete_scene_item(SceneItemId);
%%        true ->
%%            NewRobot = Robot#robot{
%%                collect_info = {0, 0}
%%            },
%%            robot:update_obj_robot(NewRobot)
%%    end.

handle_update_prop(R) ->
    #m_prop_notice_update_prop_toc{
        prop_list = UpdatePropList
    } = R,
    Robot = robot:get_robot(),
    #robot{
        prop_list = PropList
    } = Robot,
    NewPropList = lists:foldl(
        fun(UpdateProp, TmpPropList) ->
            #prop{
                prop_id = PropId,
                num = Num
            } = UpdateProp,
            if
                Num == 0 ->
                    lists:keydelete(PropId, 1, TmpPropList);
                true ->
                    case lists:keytake(PropId, 1, TmpPropList) of
                        false ->
                            [{PropId, Num} | TmpPropList];
                        {value, _, PropList1} ->
                            [{PropId, Num} | PropList1]
                    end
            end
        end,
        PropList, UpdatePropList
    ),
    robot:update_obj_robot(Robot#robot{prop_list = NewPropList}).
%%    case robot:get_scene_item(SceneItemId) of
%%        null ->
%%            noop;
%%        SceneItem ->
%%            #scene_item{
%%                type = Type
%%            } = SceneItem,
%%            if Type == ?SCENE_ITEM_TYPE_ITEM ->
%%                robot:delete_scene_item(SceneItemId);
%%                true ->
%%                    noop
%%            end
%%    end.

%%handle_request_create_faction() ->
%%    Name = random_name:get(),
%%%%    io:format("create_faction:~p~n~n", [Name]),
%%    send(p_faction:encode(#m_create_faction_tos{faction_name = Name})).
%%handle_monster_attr_change(P) ->
%%    #m_notice_scene_monster_attr_change_toc{
%%        scene_monster_id = SceneMonsterId,
%%        attr_list = AttrList
%%    } = P,
%%    case robot:get_scene_monster(SceneMonsterId) of
%%        null ->
%%            noop;
%%        R ->
%%            NewMonster =
%%                lists:foldl(
%%                    fun({AttrId, Value}, Tmp) ->
%%                        case AttrId of
%%                            ?HP ->
%%                                Tmp#scene_monster{
%%                                    hp = Value
%%                                };
%%                            ?MOVE_SPEED ->
%%                                Tmp#scene_monster{
%%                                    speed = Value
%%                                };
%%                            _ ->
%%                                Tmp
%%                        end
%%                    end,
%%                    R,
%%                    AttrList
%%                ),
%%            if
%%                NewMonster#scene_monster.hp > 0 ->
%%                    robot:update_scene_monster(NewMonster);
%%                true ->
%%                    robot:delete_scene_monster(SceneMonsterId)
%%            end
%%    end.
%%
%%handle_broadcast_obj_hp_change(P) ->
%%    #m_broadcast_obj_hp_change_toc{
%%        type = ObjType,
%%        id = ObjId,
%%        now_hp = Hp
%%    } = P,
%%    if ObjType == ?OBJ_TYPE_MONSTER ->
%%        case robot:get_scene_monster(ObjId) of
%%            null ->
%%                noop;
%%            R ->
%%                if
%%                    Hp > 0 ->
%%                        NewMonster = R#scene_monster{
%%                            hp = Hp
%%                        },
%%                        robot:update_scene_monster(NewMonster);
%%                    true ->
%%                        robot:delete_scene_monster(ObjId)
%%                end
%%        end;
%%        ObjType == ?OBJ_TYPE_PLAYER ->
%%            Robot = robot:get_robot(),
%%            if Robot#robot.player_id == ObjId ->
%%                robot:update_obj_robot(Robot#robot{
%%                    hp = Hp
%%                });
%%                true ->
%%                    noop
%%            end;
%%        true ->
%%            noop
%%    end.



handle_player_leave(R) ->
    PlayerId = R#m_scene_notice_scene_player_leave_toc.player_id,
    robot:delete_scene_player(PlayerId).
%%
handle_player_enter(R) ->
    ScenePlayer = R#m_scene_notice_scene_player_enter_toc.scene_player,
    EtsScenePlayer = #scene_player{
        id = ScenePlayer#sceneplayer.player_id,
        x = ScenePlayer#sceneplayer.x,
        y = ScenePlayer#sceneplayer.y,
        hp = ScenePlayer#sceneplayer.hp,
        speed = ScenePlayer#sceneplayer.move_speed
    },
    robot:update_scene_player(EtsScenePlayer).

handle_monster_leave(R) ->
    SceneMonsterId = R#m_scene_notice_monster_leave_toc.scene_monster_id,
    robot:delete_scene_monster(SceneMonsterId).

handle_monster_enter(R) ->
    #m_scene_notice_monster_enter_toc{
        scene_monster_list = SceneMonsterList
    } = R,
    lists:foreach(
        fun(SceneMonster) ->
            #scenemonster{
                scene_monster_id = SceneMonsterId,
                monster_id = MonsterId,
                move_path = MovePath,
                move_speed = MoveSpeed,
                x = X,
                y = Y
            } = SceneMonster,
            EtsSceneMonster = #scene_monster{
                id = SceneMonsterId,
                monster_id = MonsterId,
                move_path = [{X, Y} || #movepath{x = X, y = Y} <- MovePath],
                speed = MoveSpeed,
                x = X,
                y = Y
            },
            robot:update_scene_monster(EtsSceneMonster)
        end,
        SceneMonsterList
    ).

handle_monster_move(R) ->
    #m_scene_notice_monster_move_toc{
        scene_monster_id = SceneMonsterId,
        move_path = MovePath
    } = R,
    case robot:get_scene_monster(SceneMonsterId) of
        null ->
%%            Robot = robot:get_robot(),
            noop;
        SceneMonster ->
            List = [{X, Y} || #movepath{x = X, y = Y} <- MovePath],
%%            SceneMonster1 = robot:do_deal_monster_move(SceneMonster),
            NewSceneMonster = SceneMonster#scene_monster{
                move_path = List,
                last_move_time = util_time:milli_timestamp()
            },
            robot:update_scene_monster(NewSceneMonster)
    end.

handle_player_move(R) ->
    #m_scene_notice_player_move_toc{
        player_id = PlayerId,
        move_path = MovePath
    } = R,
    case robot:get_scene_player(PlayerId) of
        null ->
%%            Robot = robot:get_robot();
            ?ERROR("玩家不在场景 ： ~p", [{PlayerId}]),
            noop;
        ScenePlayer ->
            put(?DICT_NOW_MS, util_time:milli_timestamp()),
            List = [{X, Y} || #movepath{x = X, y = Y} <- MovePath],
            ScenePlayer1 = robot:do_deal_player_move(ScenePlayer),
            NewScenePlayer = ScenePlayer1#scene_player{
                move_path = List,
                last_move_time = util_time:milli_timestamp()
            },
            robot:update_scene_player(NewScenePlayer)
    end.


handle_monster_stop_move(R) ->
    #m_scene_notice_monster_stop_move_toc{
        scene_monster_id = SceneMonsterId,
        x = X,
        y = Y
    } = R,
    case robot:get_scene_monster(SceneMonsterId) of
        null ->
            ?ERROR("没找到怪物:~p~n", [{get(player_id), SceneMonsterId}]);
        SceneMonster ->
            NewSceneMonster = SceneMonster#scene_monster{
                move_path = [],
                x = X,
                y = Y
            },
            robot:update_scene_monster(NewSceneMonster)
    end.

handle_monster_teleport(R) ->
    #m_scene_notice_monster_teleport_toc{
        scene_monster_id = SceneMonsterId,
        x = X,
        y = Y
    } = R,
    case robot:get_scene_monster(SceneMonsterId) of
        null ->
            ?ERROR("没找到怪物:~p~n", [{get(player_id), SceneMonsterId}]);
        SceneMonster ->
            NewSceneMonster = SceneMonster#scene_monster{
                move_path = [],
                x = X,
                y = Y
            },
            robot:update_scene_monster(NewSceneMonster)
    end.

handle_player_stop_move(R) ->
    #m_scene_notice_player_stop_move_toc{
        player_id = PlayerId,
        x = X,
        y = Y
    } = R,
    case robot:get_scene_player(PlayerId) of
        null ->
            ?ERROR("没有找到玩家:~p~n", [{get(player_id), PlayerId}]);
        ScenePlayer ->
            NewScenePlayer = ScenePlayer#scene_player{
                move_path = [],
                x = X,
                y = Y
            },
            robot:update_scene_player(NewScenePlayer)
    end.

decode_c_scene_player(CScenePlayer) ->
    #sceneplayer{
        player_id = PlayerId,
        x = X,
        y = Y,
        hp = Hp,
        move_path = MovePath,
        move_speed = MoveSpeed
    } = CScenePlayer,
    #scene_player{
        id = PlayerId,
        x = X,
        y = Y,
        hp = Hp,
        move_path = [{X, Y} || #movepath{x = X, y = Y} <- MovePath],
        speed = MoveSpeed
    }.
decode_c_scene_monster(CSceneMonster) ->
    #scene_monster{
        id = CSceneMonster#scenemonster.scene_monster_id,
        x = CSceneMonster#scenemonster.x,
        y = CSceneMonster#scenemonster.y,
        monster_id = CSceneMonster#scenemonster.monster_id,
        hp = CSceneMonster#scenemonster.hp,
        move_path = [{X, Y} || #movepath{x = X, y = Y} <- CSceneMonster#scenemonster.move_path],
        speed = CSceneMonster#scenemonster.move_speed,
        last_move_time = util_time:milli_timestamp()
    }.
decode_c_scene_item(SceneItem) ->
    #sceneitem{
        id = Id,
        base_id = BaseId,
        x = X,
        y = Y,
        scene_monsrer_id = SceneMonsterId,
        owner_player_id = OwnerPlayerId
    } = SceneItem,
    #scene_item{
        id = Id,
        base_id = BaseId,
        x = X,
        y = Y,
        scene_monster_id = SceneMonsterId,
        owner_player_id = OwnerPlayerId
    }.
handle_sync_scene(R) ->
    #m_scene_sync_scene_toc{
        scene_player_list = ScenePlayerList,
        scene_monster_list = SceneMonsterList,
        scene_item_list = SceneItemList,
        remove_scene_player_id_list = RemovePlayerList,
        remove_scene_monster_id_list = RemoveMonsterList,
        remove_scene_item_id_list = RemoveItemList
    } = R,
    PlayerId = get(player_id),
    lists:foreach(
        fun(Id) ->
            robot:delete_scene_player(Id)
        end,
        RemovePlayerList
    ),
    lists:foreach(
        fun(Id) ->
            robot:delete_scene_monster(Id)
        end,
        RemoveMonsterList
    ),
    lists:foreach(
        fun(Id) ->
            robot:delete_scene_item(Id)
        end,
        RemoveItemList
    ),
%%    Now = util:milli_timestamp(),
    lists:foreach(
        fun(CScenePlayer) ->
            EtsScenePlayer = decode_c_scene_player(CScenePlayer),
            robot:update_scene_player(EtsScenePlayer),
            if
                CScenePlayer#sceneplayer.player_id == PlayerId ->
                    Robot = robot:get_robot(),
                    NewRobot = update_robot_from_c_scene_player(Robot, CScenePlayer),
                    robot:update_obj_robot(NewRobot);
                true ->
                    noop
            end
        end,
        ScenePlayerList
    ),
    lists:foreach(
        fun(CSceneMonster) ->
            EtsSceneMonster = decode_c_scene_monster(CSceneMonster),
            robot:update_scene_monster(EtsSceneMonster)
        end,
        SceneMonsterList
    ),
    lists:foreach(
        fun(CSceneItem) ->
            EtsSceneItem = decode_c_scene_item(CSceneItem),
            robot:update_scene_item(EtsSceneItem)
        end,
        SceneItemList
    ).

handle_anger_charge(R) ->
    #m_scene_notice_anger_change_toc{anger = Anger} = R,
    Robot = robot:get_robot(),
    Robot1 = Robot#robot{
        anger = Anger
    },
    robot:update_obj_robot(Robot1).

%%handle_fight_result(R) ->
%%    noop.
handle_fight_result(R) ->
%%    FightResult = R#m_fight_notice_fight_result_toc.fight_result,
    Now = util_time:milli_timestamp(),
    #m_fight_notice_fight_result_toc{
        attacker_type = AttackerType,
        attacker_id = AttackerId,
        defender_result_list = DefenderResultList,
        skill_id = SkillId,
        anger = Anger
    } = R,
    Robot = robot:get_robot(),
    #robot{
        player_id = PlayerId,
        skill_list = SkillList,
        buff_list = BuffList
    } = Robot,
    Robot1 =
        if
            AttackerId == PlayerId andalso AttackerType == ?OBJ_TYPE_PLAYER ->
%%                WaitSkill = get(?ROBOT_DICT_WAIT_SKILL),
%%                if WaitSkill == SkillId ->
%%                    put(?ROBOT_DICT_IS_REQUEST_FIGHT, false);
%%                    true ->
%%                        noop
%%                end,
                Robot#robot{
                    anger = Anger
                };
            true ->
                Robot
        end,
    NewRobot =
        lists:foldl(
            fun(DefenderResult, TmpRobot) ->
                #defenderresult{
                    defender_type = DefenderType,
                    defender_id = DefenderId,
                    hp = DefHp,
                    dizzy_close_time = DefDizzyCloseTime,
                    x = DefX,
                    y = DefY
                } = DefenderResult,
                if
                    DefenderType == ?OBJ_TYPE_PLAYER ->
                        if
                            DefenderId == PlayerId ->
                                TmpRobot1 =
                                    if
                                        DefX > 0 andalso DefY > 0 ->
                                            TmpRobot#robot{
                                                x = DefX,
                                                y = DefY,
                                                dizzy_close_time = DefDizzyCloseTime
%%                                                buff_list = tran_c_buff_list_2_buff_list(DefAddBuffList, TmpRobot#robot.buff_list)
                                            };
                                        true ->
                                            TmpRobot#robot{
                                                dizzy_close_time = DefDizzyCloseTime
%%                                                buff_list = tran_c_buff_list_2_buff_list(DefAddBuffList, TmpRobot#robot.buff_list)
                                            }
                                    end,

%%                                    if
%%                                        IsBeatBack == ?TRUE ->
%%                                            TmpRobot#robot{
%%                                                x = DefX,
%%                                                y = DefY,
%%                                                hp = DefHp,
%%                                                buff_list = tran_c_buff_list_2_buff_list(DefAddBuffList, TmpRobot#robot.buff_list)
%%                                            };
%%                                        true ->
%%                                            TmpRobot#robot{
%%                                                hp = DefHp,
%%                                                buff_list = tran_c_buff_list_2_buff_list(DefAddBuffList, TmpRobot#robot.buff_list)
%%                                            }
%%                                    end,
                                if
                                    AttackerType == ?OBJ_TYPE_PLAYER ->
                                        ?ERROR("玩家攻击玩家"),
                                        TmpRobot1;
%%                                        IsBackAttack = util:p(2000),
%%                                        if IsBackAttack ->
%%                                            TmpRobot1#robot{
%%                                                fight_player_id = Attacker,
%%                                                fight_player_id_time = Now + ?SSD_COUNTER_ATTACK_BUFF_TIME * 1000
%%                                            };
%%                                            true ->
%%                                                TmpRobot1
%%                                        end;
                                    true ->
                                        TmpRobot1
                                end;
                            true ->
%%                                if
%%                                    DefHp == 0 ->
%%                                        robot:delete_scene_player(DefenderId);
%%                                    true ->
%%                                        case robot:get_scene_player(DefenderId) of
%%                                            null -> noop;
%%%%                                            io:format("[ERROR] 没找到玩家:~p~n", [{PlayerId, ?LINE, DefenderId}]);
%%                                            ScenePlayer ->
%%                                                NewScenePlayer = ScenePlayer#scene_player{
%%                                                    x = DefX,
%%                                                    y = DefY,
%%                                                    hp = DefHp
%%                                                },
%%                                                robot:update_scene_player(NewScenePlayer)
%%                                        end
%%                                end,
                                TmpRobot
                        end;
                    DefenderType == ?OBJ_TYPE_MONSTER ->
                        if
                            DefHp == 0 ->
                                robot:delete_scene_monster(DefenderId);
                            true ->
                                case robot:get_scene_monster(DefenderId) of
                                    null -> noop;
                                    SceneMonster ->
                                        if
                                            DefX > 0 andalso DefY > 0 ->
                                                NewSceneMonster = SceneMonster#scene_monster{
                                                    x = DefX,
                                                    y = DefY,
                                                    hp = DefHp
                                                },
                                                robot:update_scene_monster(NewSceneMonster);
                                            true ->
                                                noop
                                        end
                                end
                        end,
                        TmpRobot
                end
            end,
            Robot1,
            DefenderResultList
        ),
    robot:update_obj_robot(NewRobot).


%%request_server_time() ->
%%    put(get_server_time, util:milli_timestamp()),
%%%%    io:format("request:~p~n", [util:milli_timestamp()]),
%%    send(
%%        p_common:encode(#m_get_server_time_tos{})
%%    ).
%%    send(
%%        p_common:encode(#m_get_server_time_tos{})
%%    ).

%%handle_server_time(R) ->
%%    #m_get_server_time_toc{time = Time} = R,
%%%%    Str = io_lib:format("server_time:~p, use:~p ~n",[Time, util:milli_timestamp() - get(get_server_time)]),
%%    logger2:write(test, [Time, util:milli_timestamp() - get(get_server_time)]),
%%    request_server_time().

tran_c_buff_list_2_buff_list(CBuffList, BuffList) ->
    Now = util_time:milli_timestamp(),
    lists:foldl(
        fun(CBuff, Tmp) ->
            tran_c_buff_2_buff_list(Now, CBuff, Tmp)
        end,
        BuffList,
        CBuffList
    ).

tran_c_buff_2_buff_list(Now, CBuff, BuffList) ->
    noop.
%%    #c_buff{
%%        buff_id = BuffId,
%%        remain_time = RemainTime
%%    } = CBuff,
%%    [
%%        #buff{
%%            buff_id = BuffId,
%%            invalid_time = Now + RemainTime
%%        }
%%        |
%%        lists:keydelete(BuffId, #buff.buff_id, BuffList)
%%    ].

try_request_stop_move(_PlayerId, [], _SceneId, _X, _Y) ->
    noop;
try_request_stop_move(_PlayerId, _MovePath, _SceneId, X, Y) ->
    send(proto:encode(
        #m_scene_player_stop_move_tos{
            x = X,
            y = Y
        })).

request_enter_game() ->
    send(proto:encode(#m_login_enter_game_tos{})).

request_create_role() ->
    {Sex, NickName} = random_name:get_name(),
    send(proto:encode(#m_login_create_role_tos{
        server_id = get(server_id),
        acc_id = robot:get_acc_id(),
        nickname = NickName,
        sex = Sex,
        from = ""
    })).
%%        true ->
%%            RandomName1 = random_name:get(),
%%            case lib_string:is_match(RandomName1) of
%%                false ->
%%                    send(p_http:encode(#m_create_role_1_tos{
%%                        token = "",
%%                        server_id = get(server_id),
%%                        acc_id = robot:get_acc_id(),
%%                        nickname = RandomName1,
%%                        sex = util:random_number(0, 1)
%%                    }));
%%                true ->
%%                    exit(name_error)
%%            end
%%    end.

request_enter_scene(SceneId, Time) ->
    IsRequestEnterScene = get(?ROBOT_DICT_IS_REQUEST_ENTER_SCENE),
    if
        IsRequestEnterScene == true ->
            noop;
        true ->
            put(?ROBOT_DICT_IS_REQUEST_ENTER_SCENE, true),
            send(
                proto:encode(
                    #m_scene_enter_scene_tos{
                        scene_id = SceneId
                    }
                ),
                Time
            )
    end.
request_enter_scene(SceneId) ->
    IsRequestEnterScene = get(?ROBOT_DICT_IS_REQUEST_ENTER_SCENE),
    if
        IsRequestEnterScene == true ->
            noop;
        true ->
            put(?ROBOT_DICT_IS_REQUEST_ENTER_SCENE, true),
            send(
                proto:encode(
                    #m_scene_enter_scene_tos{
                        scene_id = SceneId
                    }
                )
            )
    end.

handle_enter_scene_toc(R) ->
%%    put(?ROBOT_DICT_IS_REQUEST_ENTER_SCENE, false),
    #m_scene_enter_scene_toc{result = Result, scene_id = SceneId} = R,
    Robot = robot:get_robot(),
    %% 进入场景失败
    if
        Result == ?P_SUCCESS ->
            robot:update_obj_robot(Robot#robot{scene_id = SceneId}),
            case SceneId of
                %% 主城
                10000 ->
                    request_enter_scene
            end,
            noop;
%%        Result == ?P_LEVEL_LIMIT ->
%%            exit(enter_scene_error);
        true ->
            ?ERROR("handle_enter_scene_toc:~p~n", [{Result, SceneId, Robot#robot.scene_id}]),
            exit(enter_scene_error)
    end.

request_fight(SkillId, Dir, TargetType, TargetId, AttackType, Cost) ->
    send(
        proto:encode(
            #m_fight_fight_tos{
                skill_id = SkillId,
                dir = Dir,
                target_type = TargetType,
                target_id = TargetId,
                attack_type = AttackType,
                mano_value = Cost
            }
        )
    ).

request_fight_use_item(SkillId, Cost) ->
    send(
        proto:encode(
            #m_fight_use_item_tos{
                item_id = SkillId,
                mano_value = Cost
            }
        )
    ).

request_fight_use_skill(SkillId, TargetType, TargetId, Cost) ->
    send(
        proto:encode(
            #m_skill_use_skill_tos{
                active_skill_id = SkillId,
                dir = 0,
                params = [TargetType, TargetId, Cost]
            }
        )
    ).
%%request_fight(PlayerId, TargetType, TargetId, SkillId, X, Y, Dir, TargetX, TargetY, IsPet) ->
%%    case ?PROCESS_TYPE of
%%        ?PROCESS_TYPE_ROBOT_WORKER ->
%%            IsRequest =
%%                if
%%                    IsPet == ?TRUE ->
%%                        false;
%%                    true ->
%%                        case get(?ROBOT_DICT_IS_REQUEST_FIGHT) of
%%                            undefined ->
%%                                put(?ROBOT_DICT_IS_REQUEST_FIGHT, false),
%%                                false;
%%                            Bool ->
%%                                Bool
%%                        end
%%                end,
%%            if IsRequest == false ->
%%                if IsPet == ?TRUE ->
%%                    false;
%%                    true ->
%%                        put(?ROBOT_DICT_IS_REQUEST_FIGHT, true),
%%                        put(?ROBOT_DICT_WAIT_SKILL, SkillId)
%%                end,
%%
%%                put(?ROBOT_DICT_LAST_FIGHT_TIME, util:timestamp()),
%%                send(
%%                    proto:encode(
%%                        #m_player_fight_tos{
%%                            skill_id = SkillId,
%%                            x = X,
%%                            y = Y,
%%                            dir = Dir,
%%                            target_id = TargetId,
%%                            target_type = TargetType,
%%                            target_x = TargetX,
%%                            target_y = TargetY,
%%                            is_pet = IsPet
%%                        }
%%                    )
%%                );
%%                true ->
%%                    noop
%%            end;
%%        ?PROCESS_TYPE_SCENE_WORKER ->
%%            noop
%%%%            self() ! {?MSG_PLAYER_FIGHT, util:milli_timestamp(), PlayerId, X, Y, Dir, SkillId, TargetId, TargetType, TargetX, TargetY, IsPet}
%%    end.

%%request_start_collect(SceneItemId) ->
%%    send(
%%        p_scene:encode(
%%            #m_start_collect_tos{
%%                scene_item_id = SceneItemId
%%            }
%%        )
%%    ).
%%request_do_collect(SceneItemId) ->
%%    send(
%%        p_scene:encode(
%%            #m_do_collect_tos{
%%                scene_item_id = SceneItemId
%%            }
%%        )
%%    ).
%%handle_do_collect_toc(R) ->
%%    #m_do_collect_toc{scene_item_id = SceneItemId, result = Result} = R,
%%    if Result == ?NOT_EXISTS ->
%%        robot:delete_scene_item(SceneItemId);
%%        true ->
%%            noop
%%    end.

request_move_step(PlayerId, X, Y, MovePath) ->
    request_move_step(PlayerId, X, Y, MovePath, 0).

request_move_step(_PlayerId, X, Y, _MovePath, Delay) ->
    case ?PROCESS_TYPE of
        ?PROCESS_TYPE_ROBOT_WORKER ->
            send(proto:encode(
                #m_scene_player_move_step_tos{
                    x = X,
                    y = Y
                }
            ), Delay);
        ?PROCESS_TYPE_SCENE_WORKER ->
            noop
%%            if Delay > 0 ->
%%                erlang:send_after(Delay, self(), {?MSG_PLAYER_MOVE_STEP, PlayerId, X, Y, MovePath});
%%                true ->
%%                    self() ! {?MSG_PLAYER_MOVE_STEP, PlayerId, X, Y, MovePath}
%%            end
    end.
%%request_trigger_scene_event(SceneEventIdList) ->
%%    request_trigger_scene_event(SceneEventIdList, 0).
%%request_trigger_scene_event(SceneEventIdList, Delay) ->
%%    send(p_scene:encode(
%%        #m_trigger_scene_event_tos{
%%            event_id_list = SceneEventIdList
%%        }
%%    ), Delay).

%%handle_notice_pet_appear(R) ->
%%    #m_notice_pet_appear_toc{player_id = PlayerId, x = X, y = Y} = R,
%%    Robot = robot:get_robot(),
%%    if PlayerId == Robot#robot.player_id ->
%%        NewRobot = Robot#robot{
%%            pet_x = X,
%%            pet_y = Y,
%%            pet_steps = 1
%%        },
%%        robot:update_obj_robot(NewRobot),
%%        erlang:send_after(500, self(), {pet_heart_beat, PlayerId});
%%        true ->
%%            noop
%%    end.

handle_correct_player_pos(R) ->
    #m_scene_notice_correct_player_pos_toc{x = X, y = Y} = R,
    Robot = robot:get_robot(),
    robot:update_obj_robot(
        Robot#robot{
            x = X,
            y = Y,
            move_path = []
        }
    ).

handle_item_leave(R) ->
    #m_scene_notice_item_leave_toc{scene_item_id_list = SceneItemIdList, type = _Type} = R,
    lists:foreach(
        fun(SceneItemId) ->
            robot:delete_scene_item(SceneItemId)
        end,
        SceneItemIdList
    ).

handle_item_enter(R) ->
    #m_scene_notice_item_enter_toc{scene_item_list = SceneItemList} = R,
    SceneItemIdList = lists:map(
        fun(SceneItem) ->
            EtsSceneItem = decode_c_scene_item(SceneItem),
            robot:update_scene_item(EtsSceneItem),
            SceneItem#sceneitem.id
        end,
        SceneItemList
    ),
    request_player_collect(SceneItemIdList).

%% @doc 请求场景道具
request_player_collect(SceneItemIdList) ->
    Msg = #m_scene_player_collect_tos{scene_item_id = SceneItemIdList},
    send(proto:encode(Msg), 2000).


%%request_pet_move(PlayerId, X, Y, Type) ->
%%    case ?PROCESS_TYPE of
%%        ?PROCESS_TYPE_ROBOT_WORKER ->
%%            send(p_scene:encode(
%%                #m_pet_move_tos{
%%                    x = X,
%%                    y = Y,
%%                    type = Type
%%                }
%%            ));
%%        ?PROCESS_TYPE_SCENE_WORKER ->
%%            self() ! {?MSG_PET_MOVE, PlayerId, Type, X, Y}
%%    end.
%%request_move(Path) ->
%%    request_move(?NORMAL, Path).
%%request_move(PlayerId, Type, Path) ->
%%    request_move(PlayerId, Type, 0, 0, 0, "", 0, Path, 0).
request_move(Type, X, Y) ->
    request_move(Type, X, Y, 0, 0,"move", 0).
request_move(Type, X, Y, High, Time, ActionId, Delay) ->
    case ?PROCESS_TYPE of
        ?PROCESS_TYPE_ROBOT_WORKER ->
            send(
                proto:encode(#m_scene_player_move_tos{
                    x = X,
                    y = Y,
%%                    move_type = ?MOVE_TYPE_NORMAL,
                    move_type = Type,
                    high = High,
                    time = Time,
                    action_id = ActionId
                }),
                Delay
            );
        ?PROCESS_TYPE_SCENE_WORKER ->
            noop
%%            if Delay > 0 ->
%%                erlang:send_after(Delay, self(), {?MSG_PLAYER_MOVE, PlayerId, Type, 0, 0, Path, ActionId, Time, High});
%%                true ->
%%                    self() ! {?MSG_PLAYER_MOVE, PlayerId, Type, 0, 0, Path, ActionId, Time, High}
%%            end
    end.


%%handle_update_task(R) ->
%%    #c_task_info{
%%        task_id = TaskId,
%%        status = Status,
%%        now_num = NowNum
%%    } = R#m_notice_task_update_toc.task_info,
%%    Task = mod_task:get_task(TaskId),
%%    #t_task{
%%        type = Type
%%    } = Task,
%%%%    io:format("任务更新:~p~n", [{TaskId, Status}]),
%%    if Type == ?TASK_TYPE_MAIN ->
%%        Robot = robot:get_robot(),
%%        #robot{
%%            move_path = MovePath,
%%            scene_id = SceneId,
%%            task_id = OldTaskId,
%%            player_id = PlayerId,
%%            x = X,
%%            y = Y
%%        } = Robot,
%%%%        put(?DICT_IS_REQUEST_ACCEPT_TASK, false),
%%        try_request_stop_move(PlayerId, MovePath, SceneId, X, Y),
%%        NewRobot =
%%            if Robot#robot.task_id == TaskId ->
%%                Robot#robot{
%%                    task_id = TaskId,
%%                    task_status = Status,
%%                    move_path = [],
%%                    task_num = NowNum,
%%                    assassinate_player_id = 0,
%%                    assassinate_scene_id = 0,
%%                    assassinate_scene_x = 0,
%%                    assassinate_scene_y = 0
%%                };
%%                true ->
%%                    if OldTaskId > 0 ->
%%                        #t_task{
%%                            robot_trigger_event_list = TriggerEventList
%%                        } = mod_task:get_task(OldTaskId),
%%                        if TriggerEventList == [] ->
%%                            noop;
%%                            true ->
%%                                lists:foreach(
%%                                    fun({Delay, EventList}) ->
%%                                        request_trigger_scene_event(EventList, Delay)
%%                                    end,
%%                                    TriggerEventList
%%                                )
%%                        end;
%%                        true ->
%%                            noop
%%                    end,
%%                    Robot#robot{
%%                        task_id = TaskId,
%%                        task_status = Status,
%%                        move_path = [],
%%                        task_num = NowNum,
%%                        trace_target_info = #trace_target_info{},
%%                        trace_scene_door = {0, 0, 0},
%%                        assassinate_player_id = 0,
%%                        assassinate_scene_id = 0,
%%                        assassinate_scene_x = 0,
%%                        assassinate_scene_y = 0
%%                    }
%%            end,
%%        robot:update_obj_robot(NewRobot);
%%        true ->
%%            noop
%%    end.

%%decode_task(TaskInfoList) ->
%%    lists:foldl(
%%        fun(R, Tmp) ->
%%            #c_task_info{
%%                task_id = TaskId,
%%                status = Status
%%            } = R,
%%            Task = mod_task:get_task(TaskId),
%%            #t_task{
%%                type = Type
%%            } = Task,
%%            if Type == ?TASK_TYPE_MAIN ->
%%                {TaskId, Status};
%%                true ->
%%                    Tmp
%%            end
%%        end,
%%        null,
%%        TaskInfoList
%%    ).
%%request_accept_task(TaskId) ->
%%%%    case get({?ROBOT_DICT_IS_REQUEST_ACCEPT_TASK, TaskId}) of
%%%%        true ->
%%%%            noop;
%%%%        _ ->
%%%%            put({?ROBOT_DICT_IS_REQUEST_ACCEPT_TASK, TaskId}, true),
%%    send(
%%        p_task:encode(
%%            #m_accept_task_tos{
%%                task_id = TaskId
%%            }
%%        )
%%    ).
%%%%    end.
%%request_finish_task(TaskId) ->
%%%%    case get({?ROBOT_DICT_IS_REQUEST_FINISH_TASK, TaskId}) of
%%%%        true ->
%%%%            noop;
%%%%        _ ->
%%%%            put({?ROBOT_DICT_IS_REQUEST_FINISH_TASK, TaskId}, true),
%%    send(
%%        p_task:encode(
%%            #m_finish_task_tos{
%%                task_id = TaskId
%%            }
%%        )
%%    ).
%%%%    end.
%%
%%request_auto_finish_mission(MissionType, MissionId) ->
%%    send(
%%        p_mission:encode(
%%            #m_auto_finish_mission_tos{
%%                key = ?NODE_KEY,
%%                mission_type = MissionType,
%%                mission_id = MissionId
%%            }
%%        )
%%    ).

%%request_auto_finish_task(TaskId) ->
%%    send(
%%        p_task:encode(
%%            #m_auto_finish_task_tos{
%%                key = ?NODE_KEY,
%%                task_id = TaskId
%%            }
%%        )
%%    ).


%%request_set_fight_mode(Mode) ->
%%    send(p_player:encode(#m_set_fight_mode_tos{mode = Mode})).

%%set_watch(Bool) ->
%%    send(
%%        p_scene:encode(
%%            #m_set_watch_tos{
%%                bool = Bool
%%            }
%%        )
%%    ).

%%robot_leave_scene() ->
%%    send(
%%        proto:encode(
%%            #m_robot_leave_scene_tos{
%%                key = ?NODE_KEY
%%            }
%%        )
%%    ).
%%
%%robot_enter_scene(Time) ->
%%    send(
%%        proto:encode(
%%            #m_robot_enter_scene_tos{
%%                key = ?NODE_KEY
%%            }
%%        ),
%%        Time
%%    ).

%%robot_change_scene(SceneId) ->
%%    send(
%%        proto:encode(
%%            #m_robot_change_scene_tos{
%%                key = ?NODE_KEY,
%%                scene_id = SceneId
%%            }
%%        )
%%    ).


socket_heart_beat() ->
    send(proto:encode(#m_login_heart_beat_tos{})),
    erlang:send_after(10000, self(), socket_heart_beat).

send(Data) ->
    send(Data, 0).
send(Data, Delay) ->
    if Delay == 0 ->
        do_send(get(socket), Data);
%%        self() ! {send, Data};
        true ->
            erlang:send_after(Delay, self(), {send, Data})
    end.

%%send_after(Data, Time) ->
%%    erlang:send_after(Time, self(), {send, Data}).

do_send(Socket, Data) ->
    Seq = get(?ROBOT_DICT_SEQ),
    if Seq >= 127 ->
        put(?ROBOT_DICT_SEQ, 0);
        true ->
            put(?ROBOT_DICT_SEQ, Seq + 1)
    end,
%%    gen_tcp:send(Socket, Data).
    SendData = repacket(Data, Seq),
%%    ?DEBUG("SendData : ~p", [SendData]),
    gen_tcp:send(Socket, SendData).
%%    case get(?ROBOT_DICT_CLIENT_WORKER) of
%%        ?UNDEFINED ->
%%%%            ?DEBUG("000"),
%%            gen_tcp:send(Socket, repacket(Data, Seq));
%%        ClientWorker ->
%%            client_worker:send_simulation_socket(ClientWorker, repacket(Data, Seq))
%%    end.

%%repacket(Bin, _Seq) ->
%%%%    <<_:8, ModuleId:8, FuncId:8, Data/binary>> = Bin,
%%    <<Head, _Len,0, Data/binary>> = Bin,
%%%%    <<Seq:8, ModuleId:8, FuncId:8, Data/binary>>.
%%    <<Head, Data/binary>>.
repacket(<<_Head, _Len, Bin/binary>>, _Seq) ->
%%    RandomNum = util_random:random_number(2147483647),
    Binary = util_websocket:unmask(Bin, 2147483647, 0),
    Len = iolist_size(Binary),
    BinLen = case Len of
                 N when N =< 125 -> <<N:7>>;
                 N when N =< 16#ffff -> <<126:7, N:16>>;
                 N when N =< 16#7fffffffffffffff -> <<127:7, N:64>>
             end,
    <<130, 1:1, BinLen/bits, 2147483647:32, Binary/binary>>.
%%    {Data, _List} = util_websocket:parse_frames(Bin),
%%    Data.

%%test_1() ->
%%    Data = <<130, 126, 8, 32, 0, 0, 0, 0, 101, 10, 50, 10, 18,
%%        228, 188, 175, 230, 129, 169, 230, 150, 175,
%%        229, 159, 131, 231, 177, 179, 231, 136, 190, 16,
%%        0, 24, 1, 32, 0, 64, 0, 74, 4, 115, 49, 54, 48, 80,
%%        247, 127, 88, 4, 98, 9, 8, 191, 16, 16, 241, 46,
%%        24, 185, 48, 18, 13, 49, 54, 51, 50, 54, 52, 55,
%%        50, 48, 57, 55, 48, 55, 24, 100, 24, 102, 24, 103,
%%        24, 104, 24, 105, 24, 110, 24, 111, 24, 120, 24,
%%        130, 1, 24, 140, 1, 24, 170, 1, 24, 202, 1, 24,
%%        203, 1, 24, 204, 1, 24, 173, 2, 24, 144, 3, 24,
%%        150, 3, 24, 151, 3, 24, 152, 3, 24, 153, 3, 24,
%%        154, 3, 24, 155, 3, 24, 159, 3, 24, 164, 3, 24,
%%        246, 3, 24, 216, 4, 24, 226, 4, 24, 246, 4, 24,
%%        128, 5, 24, 189, 5, 24, 160, 6, 24, 132, 7, 24,
%%        133, 7, 24, 134, 7, 24, 231, 7, 24, 243, 7, 24,
%%        135, 8, 24, 165, 8, 24, 166, 8, 24, 167, 8, 24,
%%        174, 8, 24, 175, 8, 24, 176, 8, 24, 178, 8, 24,
%%        185, 8, 24, 204, 8, 34, 5, 8, 191, 16, 16, 1, 34, 5,
%%        8, 241, 46, 16, 1, 34, 5, 8, 242, 46, 16, 1, 34, 5,
%%        8, 185, 48, 16, 1, 34, 5, 8, 225, 61, 16, 1, 34, 5,
%%        8, 226, 61, 16, 1, 42, 15, 8, 180, 16, 16, 0, 24, 0,
%%        32, 0, 40, 0, 48, 0, 56, 0, 42, 15, 8, 240, 7, 16, 0,
%%        24, 0, 32, 0, 40, 0, 48, 0, 56, 0, 42, 15, 8, 233, 7,
%%        16, 0, 24, 0, 32, 0, 40, 0, 48, 0, 56, 0, 64, 1, 90,
%%        19, 8, 233, 7, 16, 128, 164, 185, 137, 6, 24, 255,
%%        189, 215, 138, 6, 32, 2, 40, 0, 98, 8, 8, 101, 16,
%%        1, 24, 1, 32, 0, 98, 8, 8, 102, 16, 1, 24, 0, 32, 0,
%%        98, 8, 8, 103, 16, 1, 24, 0, 32, 0, 98, 8, 8, 104,
%%        16, 1, 24, 0, 32, 0, 98, 8, 8, 105, 16, 1, 24, 0, 32,
%%        0, 98, 8, 8, 107, 16, 1, 24, 0, 32, 0, 98, 8, 8, 108,
%%        16, 1, 24, 0, 32, 0, 98, 8, 8, 109, 16, 1, 24, 0, 32,
%%        0, 98, 8, 8, 111, 16, 1, 24, 0, 32, 0, 98, 8, 8, 112,
%%        16, 1, 24, 0, 32, 0, 98, 8, 8, 113, 16, 1, 24, 0, 32,
%%        0, 98, 8, 8, 114, 16, 1, 24, 0, 32, 0, 98, 9, 8, 143,
%%        78, 16, 1, 24, 0, 32, 0, 104, 0, 114, 4, 8, 0, 16, 0,
%%        122, 2, 16, 1, 138, 1, 4, 8, 1, 24, 1, 144, 1, 215,
%%        157, 249, 132, 6, 152, 1, 0, 160, 1, 0, 178, 1, 7,
%%        8, 222, 7, 16, 0, 24, 0, 178, 1, 7, 8, 232, 7, 16, 0,
%%        24, 0, 178, 1, 7, 8, 208, 15, 16, 0, 24, 0, 178, 1,
%%        7, 8, 184, 23, 16, 0, 24, 0, 178, 1, 7, 8, 160, 31,
%%        16, 0, 24, 0, 178, 1, 7, 8, 136, 39, 16, 0, 24, 0,
%%        178, 1, 8, 8, 161, 141, 6, 16, 0, 24, 0, 184, 1, 0,
%%        192, 1, 0, 200, 1, 0, 218, 1, 6, 8, 1, 16, 1, 24, 1,
%%        218, 1, 6, 8, 2, 16, 0, 24, 0, 218, 1, 6, 8, 3, 16, 0,
%%        24, 0, 218, 1, 6, 8, 4, 16, 0, 24, 0, 218, 1, 6, 8, 5,
%%        16, 0, 24, 0, 218, 1, 6, 8, 6, 16, 0, 24, 0, 218, 1,
%%        6, 8, 7, 16, 0, 24, 0, 218, 1, 6, 8, 8, 16, 0, 24, 0,
%%        218, 1, 6, 8, 9, 16, 0, 24, 0, 218, 1, 6, 8, 10, 16,
%%        0, 24, 0, 218, 1, 6, 8, 11, 16, 0, 24, 0, 218, 1, 6,
%%        8, 12, 16, 0, 24, 0, 218, 1, 6, 8, 13, 16, 0, 24, 0,
%%        226, 1, 7, 8, 233, 7, 16, 0, 24, 0, 234, 1, 24, 8, 1,
%%        16, 0, 26, 8, 8, 1, 16, 0, 24, 0, 32, 0, 26, 8, 8, 2,
%%        16, 0, 24, 0, 32, 0, 242, 1, 5, 8, 3, 16, 233, 7,
%%        248, 1, 0, 138, 2, 24, 104, 116, 116, 112, 115,
%%        58, 47, 47, 119, 119, 119, 46, 102, 97, 99, 101,
%%        98, 111, 111, 107, 46, 99, 111, 109, 146, 2, 8, 8,
%%        101, 16, 21, 24, 0, 32, 0, 146, 2, 8, 8, 101, 16,
%%        20, 24, 0, 32, 0, 146, 2, 8, 8, 101, 16, 19, 24, 0,
%%        32, 0, 146, 2, 8, 8, 101, 16, 18, 24, 0, 32, 0, 146,
%%        2, 8, 8, 101, 16, 17, 24, 0, 32, 0, 146, 2, 8, 8,
%%        101, 16, 16, 24, 0, 32, 0, 146, 2, 8, 8, 101, 16,
%%        15, 24, 0, 32, 0, 146, 2, 8, 8, 101, 16, 14, 24, 0,
%%        32, 0, 146, 2, 8, 8, 101, 16, 13, 24, 0, 32, 0, 146,
%%        2, 8, 8, 101, 16, 12, 24, 0, 32, 0, 146, 2, 8, 8,
%%        101, 16, 11, 24, 0, 32, 0, 146, 2, 8, 8, 101, 16,
%%        10, 24, 0, 32, 0, 146, 2, 8, 8, 101, 16, 9, 24, 0,
%%        32, 0, 146, 2, 8, 8, 101, 16, 8, 24, 0, 32, 0, 146,
%%        2, 8, 8, 101, 16, 7, 24, 0, 32, 0, 146, 2, 8, 8, 101,
%%        16, 6, 24, 0, 32, 0, 146, 2, 8, 8, 101, 16, 5, 24, 0,
%%        32, 0, 146, 2, 8, 8, 101, 16, 4, 24, 0, 32, 0, 146,
%%        2, 8, 8, 101, 16, 3, 24, 0, 32, 0, 146, 2, 8, 8, 101,
%%        16, 2, 24, 0, 32, 0, 146, 2, 8, 8, 101, 16, 1, 24, 0,
%%        32, 0, 154, 2, 16, 8, 11, 16, 205, 8, 24, 0, 32,
%%        205, 8, 42, 4, 8, 11, 16, 0, 162, 2, 146, 4, 8, 1,
%%        16, 0, 26, 95, 8, 201, 1, 16, 0, 26, 7, 8, 177, 63,
%%        16, 0, 24, 0, 26, 7, 8, 175, 63, 16, 0, 24, 0, 26, 7,
%%        8, 174, 63, 16, 0, 24, 0, 26, 7, 8, 173, 63, 16, 0,
%%        24, 0, 26, 7, 8, 171, 63, 16, 0, 24, 0, 26, 7, 8,
%%        170, 63, 16, 0, 24, 0, 26, 7, 8, 169, 63, 16, 0, 24,
%%        0, 26, 7, 8, 167, 63, 16, 0, 24, 0, 26, 7, 8, 166,
%%        63, 16, 0, 24, 0, 26, 7, 8, 165, 63, 16, 0, 24, 0,
%%        26, 131, 1, 8, 202, 1, 16, 0, 26, 7, 8, 150, 64, 16,
%%        0, 24, 0, 26, 7, 8, 149, 64, 16, 0, 24, 0, 26, 7, 8,
%%        148, 64, 16, 0, 24, 0, 26, 7, 8, 147, 64, 16, 0, 24,
%%        0, 26, 7, 8, 146, 64, 16, 0, 24, 0, 26, 7, 8, 145,
%%        64, 16, 0, 24, 0, 26, 7, 8, 144, 64, 16, 0, 24, 0,
%%        26, 7, 8, 143, 64, 16, 0, 24, 0, 26, 7, 8, 142, 64,
%%        16, 0, 24, 0, 26, 7, 8, 141, 64, 16, 0, 24, 0, 26, 7,
%%        8, 140, 64, 16, 0, 24, 0, 26, 7, 8, 139, 64, 16, 0,
%%        24, 0, 26, 7, 8, 138, 64, 16, 0, 24, 0, 26, 7, 8,
%%        137, 64, 16, 0, 24, 0, 26, 140, 1, 8, 203, 1, 16, 0,
%%        26, 7, 8, 251, 64, 16, 0, 24, 0, 26, 7, 8, 250, 64,
%%        16, 0, 24, 0, 26, 7, 8, 249, 64, 16, 0, 24, 0, 26, 7,
%%        8, 248, 64, 16, 0, 24, 0, 26, 7, 8, 247, 64, 16, 0,
%%        24, 0, 26, 7, 8, 246, 64, 16, 0, 24, 0, 26, 7, 8,
%%        245, 64, 16, 0, 24, 0, 26, 7, 8, 244, 64, 16, 0, 24,
%%        0, 26, 7, 8, 243, 64, 16, 0, 24, 0, 26, 7, 8, 242,
%%        64, 16, 0, 24, 0, 26, 7, 8, 241, 64, 16, 0, 24, 0,
%%        26, 7, 8, 240, 64, 16, 0, 24, 0, 26, 7, 8, 239, 64,
%%        16, 0, 24, 0, 26, 7, 8, 238, 64, 16, 0, 24, 0, 26, 7,
%%        8, 237, 64, 16, 0, 24, 0, 26, 149, 1, 8, 204, 1, 16,
%%        0, 26, 7, 8, 224, 65, 16, 0, 24, 0, 26, 7, 8, 223,
%%        65, 16, 0, 24, 0, 26, 7, 8, 222, 65, 16, 0, 24, 0,
%%        26, 7, 8, 221, 65, 16, 0, 24, 0, 26, 7, 8, 220, 65,
%%        16, 0, 24, 0, 26, 7, 8, 219, 65, 16, 0, 24, 0, 26, 7,
%%        8, 218, 65, 16, 0, 24, 0>>,
%%%%    proto:decode(parse_frames(Data)).
%%    parse_frames(Data).
%%
%%test_2() ->
%%    Data = <<188, 26, 15, 228, 186, 158, 229, 141, 161, 232, 191,
%%        170, 229, 184, 140, 230, 139, 137, 26, 18, 229, 133,
%%        139, 232, 163, 143, 229, 143, 178, 230, 132, 155,
%%        230, 153, 174, 232, 139, 165, 26, 18, 230, 162, 173,
%%        231, 190, 133, 232, 165>>,
%%    parse_frames(Data).