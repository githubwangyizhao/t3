%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            场景玩家管理
%%% @end
%%% Created : 20. 十一月 2017 上午 11:10
%%%-------------------------------------------------------------------
-module(mod_scene_player_manager).

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
-include("system.hrl").
-include("player_game_data.hrl").
-export([
%%    get_obj_scene_player/1,
    get_all_obj_scene_player_id/0,
    get_all_obj_scene_player/0,
    get_obj_scene_player_count/0,
    get_all_live_obj_scene_player_count/0,
    get_player_info/0,
    correct_player_pos/1,
    apply_to_all_client_worker/3,
    apply_to_all_client_worker/4,
    apply_to_client_worker/4,
    apply_to_client_worker/5            %% 玩家进程apply
]).
-export([
    add_obj_scene_player/1,
%%    update_obj_scene_player/1,
    delete_obj_scene_player/1,
    try_add_scene_worker_stay_player/1,
    tran_player_enter_scene_data_2_obj_scene_actor/1
]).
%% API
-export([
    handle_player_enter_scene/2,        %% 玩家进入场景
    handle_player_leave/2,              %% 玩家离开场景
%%    handle_msg_player_rebirth/3,        %% 玩家复活
    handle_msg_player_move/8,           %% 玩家移动
    handle_msg_sync_player_data/3,      %% 同步玩家数据
    handle_join_monster_point/2,
    handle_msg_get_player_pos/2,        %% 获取玩家位置
    handle_get_player_id_list/1,        %% 获取场景玩家id列表
    handle_get_player_id_list/2,
    handle_msg_player_move_step/4,      %% 玩家移动step
    handle_msg_player_transmit/5,       %% 玩家传送
    handle_msg_player_stop_move/4       %% 玩家停止移动
%%    handle_player_death/2,              %% 处理玩家死亡
%%    handle_recover_hp/1                 %% 定时恢复玩家血量
]).

%% ----------------------------------
%% @doc 	获取场景玩家对象
%% @throws 	none
%% @end
%% ----------------------------------
%%get_obj_scene_player(PlayerId) ->
%%    ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_PLAYER, PlayerId).

%% ----------------------------------
%% @doc 	获取所有场景玩家id
%% @throws 	none
%% @end
%% ----------------------------------
get_all_obj_scene_player_id() ->
    mod_scene_actor:get_actor_id_list(?OBJ_TYPE_PLAYER).

%% ----------------------------------
%% @doc 	获取所有场景玩家
%% @throws 	none
%% @end
%% ----------------------------------
get_all_obj_scene_player() ->
    [?GET_OBJ_SCENE_PLAYER(ThisPlayerId) || ThisPlayerId <- get_all_obj_scene_player_id()].


%% ----------------------------------
%% @doc 	获取所有场景玩家数量
%% @throws 	none
%% @end
%% ----------------------------------
get_all_live_obj_scene_player_count() ->
    lists:foldl(
        fun(PlayerId, N) ->
            R = ?GET_OBJ_SCENE_PLAYER(PlayerId),
            if R#obj_scene_actor.hp > 0 ->
                N + 1;
                true ->
                    N
            end
        end,
        0,
        get_all_obj_scene_player_id()
    ).


%% ----------------------------------
%% @doc 	获取场景玩家数量
%% @throws 	none
%% @end
%% ----------------------------------
get_obj_scene_player_count() ->
    erlang:length(get_all_obj_scene_player_id()).

%% ----------------------------------
%% @doc 	获取玩家和机器人的数量
%% @throws 	none
%% @end
%% ----------------------------------
get_player_info() ->
    case get_all_obj_scene_player_id() of
        null -> {{0, []}, {0, []}};
        L ->
            lists:foldl(
                fun(PlayerId, {{TmpPlayerNum, TmpPlayerIdList}, {TmpRobotNum, TmpRobotIdList}}) ->
                    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                        ?UNDEFINED ->
                            ?ERROR("get_count: null~p~n", [PlayerId]);
                        R ->
                            #obj_scene_actor{
                                obj_id = Id,
                                is_robot = IsRobot
                            } = R,
                            if IsRobot ->
                                {{TmpPlayerNum, TmpPlayerIdList}, {TmpRobotNum + 1, [Id | TmpRobotIdList]}};
                                true ->
                                    {{TmpPlayerNum + 1, [Id | TmpPlayerIdList]}, {TmpRobotNum, TmpRobotIdList}}
                            end
                    end
                end,
                {{0, []}, {0, []}},
                L
            )
    end.
%%    L = get_all_obj_scene_player_id(),
%%    lists:foldl(
%%        fun(PlayerId, {{TmpPlayerNum, TmpPlayerIdList}, {TmpRobotNum, TmpRobotIdList}}) ->
%%            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%                ?UNDEFINED ->
%%                    ?ERROR("get_count: null~p~n", [PlayerId]);
%%                R ->
%%                    #obj_scene_actor{
%%                        obj_id = Id,
%%                        is_robot = IsRobot
%%                    } = R,
%%                    if IsRobot ->
%%                        {{TmpPlayerNum, TmpPlayerIdList}, {TmpRobotNum + 1, [Id | TmpRobotIdList]}};
%%                        true ->
%%                            {{TmpPlayerNum + 1, [Id | TmpPlayerIdList]}, {TmpRobotNum, TmpRobotIdList}}
%%                    end
%%            end
%%        end,
%%        {{0, []}, {0, []}},
%%        L
%%    ).


%%%% ----------------------------------
%%%% @doc 	更新场景玩家对象
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%update_obj_scene_player(ObjScenePlayer) ->
%%    ?UPDATE_OBJ_SCENE_ACTOR(ObjScenePlayer).

add_obj_scene_player(ObjScenePlayer) ->
    mod_scene_actor:add_obj_scene_actor(ObjScenePlayer).

delete_obj_scene_player(PlayerId) ->
    mod_scene_actor:delete_obj_scene_actor(?OBJ_TYPE_PLAYER, PlayerId).

%% ----------------------------------
%% @doc 	尝试将玩家滞留在场景内
%% @throws 	none
%% @end
%% ----------------------------------
try_add_scene_worker_stay_player(PlayerId) ->
    SceneWorker = self(),
    case mod_cache:get({scene_worker_stay_player_list, SceneWorker}) of
        null ->
            skip;
        ScenePlayerIdList ->
            %% 更新场景滞留的玩家列表
            mod_cache:update({scene_worker_stay_player_list, SceneWorker}, lists:umerge([[PlayerId], ScenePlayerIdList]))
    end.

%% ----------------------------------
%% @doc     玩家进入场景
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_enter_scene(PlayerEnterSceneData, State = #scene_state{
    scene_id = SceneId,
    mission_type = MissionType,
    scene_type = SceneType,
    mission_id = MissionId,
    extra_data_list = ExtraDataList,
    is_hook_scene = IsHookScene
}) ->
    #player_enter_scene_data{
        player_id = PlayerId,
        obj_player = ObjPlayer,
        passive_skill_list = _PassiveSkillList
    } = PlayerEnterSceneData,

    if
        SceneType == ?SCENE_TYPE_MISSION ->
            ?INFO("玩家(~p)进入副本:~p~n", [PlayerId, {SceneId, MissionType, MissionId}]);
        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
            ?INFO("玩家(~p)进入世界场景:~p~n", [PlayerId, SceneId]);
        SceneType == ?SCENE_TYPE_MATCH_SCENE ->
            ?INFO("玩家(~p)进入匹配场:~p~n", [PlayerId, SceneId])
    end,

    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            MonitorRef = erlang:monitor(process, ObjPlayer#ets_obj_player.client_worker),
            ObjScenePlayer_0 = tran_player_enter_scene_data_2_obj_scene_actor(PlayerEnterSceneData),
            AttrRate = util_list:opt(attr_rate, ExtraDataList, 1),
            ObjScenePlayer_1 =
                if AttrRate == 1 ->
                    ObjScenePlayer_0;
                    true ->
                        mod_scene:change_obj_scene_attr_attr(ObjScenePlayer_0, AttrRate)
                end,
%%            ObjScenePlayer_1 = mod_buff:handle_add_passive_skill_list(ObjScenePlayer_0,
%%                [{PassiveSkill#db_player_passive_skill.passive_skill_id, PassiveSkill#db_player_passive_skill.level} || PassiveSkill <- PassiveSkillList, PassiveSkill#db_player_passive_skill.is_equip == 1]
%%            ),
            ObjScenePlayer = ObjScenePlayer_1#obj_scene_actor{
                monitor_ref = MonitorRef,
                create_time = util_time:timestamp()
%%                grid_id = ?PIX_2_GRID_ID(ObjScenePlayer_0#obj_scene_actor.x, ObjScenePlayer_0#obj_scene_actor.y)
            },
            put({client_worker_map, ObjPlayer#ets_obj_player.client_worker}, PlayerId),
            add_obj_scene_player(ObjScenePlayer),

            try
                #obj_scene_actor{
                    level = PlayerLevel, vip_level = PlayerVipLevel
                } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
                IsSingle =
                    case lists:keyfind(is_single, 1, ExtraDataList) of
                        false -> 0;
                        {is_single, IsSingle1} ->
                            ?DEBUG("IsSingle: ~p", [IsSingle1]),
                            1
                    end,
                mod_scene:write_scene_log(
                    [
                        {player_id, PlayerId},
                        {level, PlayerLevel},
                        {vip_level, PlayerVipLevel},
                        {scene_id, SceneId},
                        {scene_type, SceneType},
                        {mission_id, MissionId},
                        {mission_type, MissionType},
                        {is_single, IsSingle}
                    ],
                    enter_scene_log)
            catch
                _: Reason ->
                    ?WARNING("enter scene log warning: ~p", [Reason])
            end,

            put({?DICT_CACHE_OBJ_SCENE_PLAYER, PlayerId}, ObjScenePlayer),
            ?INIT_PLAYER_SENDER_WORKER(PlayerId, ObjPlayer#ets_obj_player.sender_worker),
            mod_scene_grid_manager:handle_player_enter_grid(ObjScenePlayer),
            case mod_scene_event_manager:get_scene_event_value() of
                {true, {16, EventArg, EventCloseTime}} ->
                    api_shen_long:notice_scene_shen_long_state([PlayerId], ?TRUE, EventArg, round(EventCloseTime / 1000), ?UNDEFINED, ?UNDEFINED);
                {true, {15, EventArg, EventCloseTime}} ->
                    api_scene:notice_scene_jbxy_state([PlayerId], true, EventArg, round(EventCloseTime / 1000), ?UNDEFINED);
                _ ->
                    noop
            end,
            case SceneType of
                ?SCENE_TYPE_MISSION ->
                    %% 副本
                    mission_handle:handle_player_enter_mission(PlayerId, State);
                ?SCENE_TYPE_WORLD_SCENE ->
                    if
                        SceneId =:= ?SD_MY_MAIN_SCENE ->
                            PlayerEnterWorldScene = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_FIRST_INTO_WORLD_SCENE),
                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_FIRST_INTO_WORLD_SCENE, PlayerEnterWorldScene + 1),
                            ?IF(IsHookScene, ?CATCH(scene_notice:player_enter_scene(PlayerId, SceneId)), noop);
                        true -> noop
                    end,
                    if
                        IsHookScene ->
                            mod_scene_event_manager:player_enter_scene(PlayerId),
                            scene_adjust:player_enter(PlayerId),
                            scene_adjust:player_enter_init_rebound(PlayerId),
                            scene_gold_rank:handle_notice_gold_rank(),
                            mod_scene_robot_manager:player_enter_scene(PlayerId);
                        true ->
                            noop
                    end;
%%                    scene_worker:try_notice_yu_chao_start_time(PlayerId);
                ?SCENE_TYPE_MATCH_SCENE ->
                    %% 匹配场
                    mod_scene_event_manager:player_enter_scene(PlayerId),
                    match_scene:handle_player_enter(PlayerId);
                _ ->
                    noop
            end,
            try_add_scene_worker_stay_player(PlayerId);
        _R ->
            exit(?ERROR_ALREADY_IN_SCENE_WORKER)
    end.

%% ----------------------------------
%% @doc 	转换进入场景的玩家数据
%% @throws 	none
%% @end
%% ----------------------------------
tran_player_enter_scene_data_2_obj_scene_actor(PlayerEnterSceneData) ->
    #player_enter_scene_data{
        x = X,
        y = Y,
        player_id = PlayerId,
        player = Player,
        player_data = PlayerData,
        obj_player = ObjPlayer,
        player_name = PlayerName,
        dir = Dir,
        active_skill_list = ActiveSkillList,
        subscribe_list = SubscribeList,
        magic_weapon_id = MagicWeaponId,
        passive_skill_list = PassiveSkillList,
        is_robot = IsRobot,
        hero = #db_player_hero_use{
            hero_id = HeroId,
            arms = HeroArms,
            ornaments = HeroOrnaments
        },
        is_use_anger = IsUseAnger,
        is_can_add_anger = IsCanAddAnger
    } = PlayerEnterSceneData,

%%    PlayerId = Player#db_player.id,
    Sex = Player#db_player.sex,
    RActiveSkillList =
        lists:foldl(
            fun({SkillId, Level, _LastTime}, TmpActive) ->
                RActiveSkill = mod_active_skill:tran_r_active_skill(SkillId, Level, 0, Sex),
                [RActiveSkill | TmpActive]
            end,
            [],
            ActiveSkillList
%%                    [{101, 1},{102, 1},{103, 1},{104, 1},{901, 1}, {902, 1}, {903, 1}, {904, 1}]
        ),
%%    MonitorRef = erlang:monitor(process, ObjPlayer#ets_obj_player.client_worker),
%%            ?DEBUG("~p~n", [{PlayerData#player_data.max_hp, PlayerData#player_data.hp}]),
    ObjSceneActor_1 =
        #obj_scene_actor{
            key = {?OBJ_TYPE_PLAYER, PlayerId},
            obj_type = ?OBJ_TYPE_PLAYER,
            obj_id = PlayerId,
            nickname = erlang:list_to_binary(PlayerName),
            client_node = ObjPlayer#ets_obj_player.client_node,
            client_worker = ObjPlayer#ets_obj_player.client_worker,
            server_id = Player#db_player.server_id,
            level = PlayerData#db_player_data.level,
            vip_level = PlayerData#db_player_data.vip_level,
            r_active_skill_list = RActiveSkillList,
            grid_id = ?PIX_2_GRID_ID(X, Y),
            sex = Sex,
            dir = Dir,
            x = X,
            y = Y,
            max_hp = 1,
            hp = 1,
%%            max_hp = PlayerData#db_player_data.max_hp,
%%            hp = ?IF(PlayerData#db_player_data.hp =< 0, PlayerData#db_player_data.max_hp, PlayerData#db_player_data.hp),
            attack = PlayerData#db_player_data.attack,
            move_speed = ?IF(PlayerData#db_player_data.speed == 0, ?SD_INIT_SPEED, PlayerData#db_player_data.speed),
            init_move_speed = ?IF(PlayerData#db_player_data.speed == 0, ?SD_INIT_SPEED, PlayerData#db_player_data.speed),
            defense = PlayerData#db_player_data.defense,
            hit = PlayerData#db_player_data.hit,
            dodge = PlayerData#db_player_data.dodge,
            anger = ?IF(IsUseAnger, PlayerData#db_player_data.anger, 0),
            tenacity = PlayerData#db_player_data.tenacity,
            critical = PlayerData#db_player_data.critical,
            hurt_add = PlayerData#db_player_data.hurt_add,
            crit_hurt_add = PlayerData#db_player_data.crit_hurt_add,
            pk_mode = PlayerData#db_player_data.fight_mode,
            crit_hurt_reduce = PlayerData#db_player_data.crit_hurt_reduce,
            hurt_reduce = PlayerData#db_player_data.hurt_reduce,
            rate_resist_block = PlayerData#db_player_data.rate_resist_block,          %% 破击
            rate_block = PlayerData#db_player_data.rate_block,                 %% 格挡
            power = PlayerData#db_player_data.power,
            subscribe_list = SubscribeList,
%%            transport_goods_id = TransportGoodsId,
%%            faction_id = FactionId,
            surface = #surface{
                title_id = PlayerData#db_player_data.title_id,
                magic_weapon_id = MagicWeaponId,
                hero_id = HeroId,
                hero_arms = HeroArms,
                hero_ornaments = HeroOrnaments,
                head_id = PlayerData#db_player_data.head_id,
                head_frame_id = PlayerData#db_player_data.head_frame_id,
                chat_qi_pao_id = PlayerData#db_player_data.chat_qi_pao_id
            },
            is_robot = IsRobot,
            is_can_add_anger = IsCanAddAnger
        },
    ObjScenePlayer_2 = mod_scene:update_move_speed(ObjSceneActor_1),
    ObjScenePlayer_3 = mod_buff:handle_add_passive_skill_list(ObjScenePlayer_2,
        [{PassiveSkill#db_player_passive_skill.passive_skill_id, PassiveSkill#db_player_passive_skill.level} || PassiveSkill <- PassiveSkillList, PassiveSkill#db_player_passive_skill.is_equip == 1]
    ),
    ObjScenePlayer_3.

%% ----------------------------------
%% @doc     玩家离开场景
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_leave(
    PlayerId,
    State = #scene_state{
        scene_id = _SceneId,
        scene_type = SceneType,
        is_hook_scene = IsHookScene,
        owner = Owner,
        fight_type = FightType
    }
) ->
    case SceneType of
        ?SCENE_TYPE_MISSION ->
            ?TRY_CATCH(mission_handle:handle_leave_mission(PlayerId, State));
        ?SCENE_TYPE_WORLD_SCENE when IsHookScene andalso FightType == 1 ->
            ?TRY_CATCH(mod_scene_monster_manager:player_leave_recover_monster_hp(PlayerId));
        ?SCENE_TYPE_WORLD_SCENE when IsHookScene ->
            ?TRY_CATCH(scene_adjust:player_leave(PlayerId)),
            ?TRY_CATCH(scene_adjust:player_leave_clear_rebound(PlayerId));
        ?SCENE_TYPE_MATCH_SCENE ->
            ?TRY_CATCH(match_scene:handle_player_leave());
        _ ->
            noop
    end,
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            exit(?ERROR_NO_OBJ_SCENE_PLAYER);
        R ->
            ?DEBUG("离开场景:~p", [PlayerId]),
            #obj_scene_actor{
                x = X,
                y = Y,
                hp = Hp,
                max_hp = _MaxHp,
                r_active_skill_list = RActiveSkillList,
                monitor_ref = MonitorRef,
                client_worker = ClientWorker,
%%                join_monster_point = JoinMonsterPoint,
                anger = Anger
            } = R,

            %% 属主退出场景  场景关闭
            if Owner == ClientWorker ->
                scene_worker:stop(self());
                true ->
                    noop
            end,
            %% 删除玩家对象
            delete_obj_scene_player(PlayerId),
            %% 移除监控
            if
                MonitorRef =/= null andalso MonitorRef =/= ?UNDEFINED ->
                    erlang:demonitor(MonitorRef);
                true ->
                    noop
            end,
            %% 删除发送进程字典
            ?ERASE_PLAYER_SENDER_WORKER(PlayerId),
            %% 删除模块字典
            mod_fight:delete_player_mod_dict(PlayerId),
            %% 移除玩家在场景进程内所有技能buff
            mod_scene_skill_manager:delete_player_all_skill_buff(PlayerId),
            %%　离开格子
            mod_scene_grid_manager:handle_player_leave_grid(R),

            erase({?DICT_CACHE_OBJ_SCENE_PLAYER, PlayerId}),
%%            if JoinMonsterPoint > 0 ->
%%                %% 取消监听刷怪点
%%                ?TRY_CATCH(monster_point:leave_monster_point(JoinMonsterPoint, PlayerId));
%%                true ->
%%                    noop
%%            end,
            mod_scene_monster_manager:unlink_belong(PlayerId),
            [{pos, {X, Y}}, {hp, Hp}, {anger, Anger}, {r_active_skill_list, RActiveSkillList}]
%%            if
%%                SceneType =:= ?SCENE_TYPE_WORLD_SCENE ->
%%                    if
%%                        SceneId =:= 1000 ->
%%                            [{pos, {X, Y}}, {hp, Hp}, {anger, Anger}, {r_active_skill_list, RActiveSkillList}];
%%                        true ->
%%                            [{pos, {X, Y}}, {hp, Hp}, {anger, 0}, {r_active_skill_list, RActiveSkillList}]
%%                    end;
%%                true ->
%%                    [{pos, {X, Y}}, {hp, Hp}, {r_active_skill_list, RActiveSkillList}]
%%            end
    end.

%% ----------------------------------
%% @doc 	获取场景玩家id列表
%% @throws 	none
%% @end
%% ----------------------------------
handle_get_player_id_list(player) ->
    [
        E#obj_scene_actor.obj_id
        || E <- get_all_obj_scene_player(), E#obj_scene_actor.is_robot == false
    ];
handle_get_player_id_list(robot) ->
    [
        E#obj_scene_actor.obj_id
        || E <- get_all_obj_scene_player(), E#obj_scene_actor.is_robot == true
    ];
handle_get_player_id_list(all) ->
    get_all_obj_scene_player_id().

%% ----------------------------------
%% @doc 	获取场景玩家id列表(同节点的玩家)
%% @throws 	none
%% @end
%% ----------------------------------
handle_get_player_id_list(player, PlayerId) ->
    #obj_scene_actor{
        client_node = Node
    } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    [
        E#obj_scene_actor.obj_id
        || E <- get_all_obj_scene_player(), E#obj_scene_actor.is_robot == false, E#obj_scene_actor.client_node == Node
    ];
handle_get_player_id_list(robot, _PlayerId) ->
    [
        E#obj_scene_actor.obj_id
        || E <- get_all_obj_scene_player(), E#obj_scene_actor.is_robot == true
    ];
handle_get_player_id_list(all, PlayerId) ->
    #obj_scene_actor{
        client_node = Node
    } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    [
        E#obj_scene_actor.obj_id
        || E <- get_all_obj_scene_player(), E#obj_scene_actor.client_node == Node
    ].

%% ----------------------------------
%% @doc 	获取玩家位置
%% @throws 	none
%% @end
%% ----------------------------------
handle_msg_get_player_pos(PlayerId, #scene_state{scene_id = SceneId}) ->
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            exit(?ERROR_NOT_EXISTS);
        R ->
            {
                pos,
                {
                    SceneId,
                    R#obj_scene_actor.x,
                    R#obj_scene_actor.y
                }
            }
    end.

%%handle_msg_player_rebirth(PlayerId, Type, #scene_state{
%%    scene_id = SceneId
%%    rebirth_window = RebirthWindow
%%}) ->
%%    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%        ?UNDEFINED ->
%%            noop;
%%        R ->
%%            ?ASSERT(R#obj_scene_actor.hp =< 0, ?ERROR_ALREADY_LIVE),
%%
%%            {RebirthX, RebirthY} =
%%                %% 获取复活点
%%            if (RebirthWindow == 2 andalso Type == request) orelse RebirthWindow == 1 ->
%%                {
%%                    R#obj_scene_actor.x,
%%                    R#obj_scene_actor.y
%%                };
%%                true ->
%%                    mod_scene:get_scene_birth_pos(SceneId)
%%            end,
%%
%%            FGridId = R#obj_scene_actor.grid_id,
%%            TGridId = ?PIX_2_GRID_ID(RebirthX, RebirthY),
%%
%%%%            ?DEBUG("rebirth_timer_ref:~p~n", [R#obj_scene_actor.rebirth_timer_ref]),
%%            %% 移除复活定时器
%%            if R#obj_scene_actor.rebirth_timer_ref == null ->
%%                noop;
%%                true ->
%%                    erlang:cancel_timer(R#obj_scene_actor.rebirth_timer_ref)
%%            end,
%%            NewObjScenePlayer = R#obj_scene_actor{
%%                hp = R#obj_scene_actor.max_hp,
%%                move_path = [],
%%                grid_id = TGridId,
%%                x = RebirthX,
%%                y = RebirthY,
%%                go_x = 0,
%%                go_y = 0,
%%                rebirth_timer_ref = null,
%%                is_wait_navigate = false,
%%                hate_list = [],
%%                r_active_skill_list = mod_active_skill:clear_r_active_skill(R#obj_scene_actor.r_active_skill_list)
%%            },
%%
%%            ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
%%            mod_scene_grid_manager:handle_player_grid_change(NewObjScenePlayer, FGridId, TGridId, rebirth),
%%            %% 通知清理技能cd
%%            api_skill:notice_clear_active_skill_cd(PlayerId),
%%            %% 通知复活成功
%%            api_scene:api_notice_rebirth(PlayerId, ?P_SUCCESS)
%%%%            if
%%%%                Type == request ->
%%%%                    noop;
%%%%                true ->
%%%%                    api_scene:api_notice_rebirth(PlayerId, ?P_SUCCESS)
%%%%            end
%%    end.

%% ----------------------------------
%% @doc     移动
%% @throws 	none
%% @end
%% ----------------------------------
handle_msg_player_move(PlayerId, GoX, GoY, MoveType, High, Time, ActionId, #scene_state{is_mission = _IsMission}) ->
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            exit(?ERROR_NO_OBJ_SCENE_PLAYER);
        R ->
            #obj_scene_actor{
                hp = Hp,
%%                grid_id = GridId,
                go_x = OldGoX,
                go_y = OldGoY
            } = R,

            Dis = util_math:get_distance({OldGoX, OldGoY}, {GoX, GoY}),
%%            ?DEBUG("MoveDis:~p", [Dis]),
            if Dis >= 100 ->
                ?ASSERT(Hp > 0, ?ERROR_ALREADY_DIE),
                NewObjScenePlayer = R#obj_scene_actor{
                    go_x = GoX,
                    go_y = GoY,
                    move_type = MoveType
                },
                ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
                api_scene:notice_player_move(
%%                    mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
                    mod_scene_player_manager:get_all_obj_scene_player_id(),
                    PlayerId,
                    GoX,
                    GoY,
                    MoveType,
                    [],
                    High, Time, ActionId
                );
                true ->
                    noop
            end
    end.

%% ----------------------------------
%% @doc 	纠正玩家位置
%% @throws 	none
%% @end
%% ----------------------------------
correct_player_pos(PlayerId) ->
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            noop;
        ObjScenePlayer ->
            #obj_scene_actor{
                x = X,
                y = Y
            } = ObjScenePlayer,
%%            NewObjScenePlayer = ObjScenePlayer#obj_scene_actor{
%%                move_path = []
%%            },
%%            ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
            api_scene:notice_correct_player_pos(PlayerId, X, Y)
    end.

%% ----------------------------------
%% @doc     玩家传送
%% @throws 	none
%% @end
%% ----------------------------------
handle_msg_player_transmit(
    PlayerId,
    TX,
    TY,
    CallBackFun,
    #scene_state{
        map_id = MapId
    }) ->
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            exit(?ERROR_NO_OBJ_SCENE_PLAYER);
        R ->
            #obj_scene_actor{
                grid_id = FGridId,
                hp = Hp
            } = R,
            mod_map:ensure_can_walk(?PIX_2_MASK_ID(MapId, TX, TY)),
            TGridId = ?PIX_2_GRID_ID(TX, TY),

            ?ASSERT(Hp > 0, ?ERROR_ALREADY_DIE),

            NewObjScenePlayer =
                R#obj_scene_actor{
                    x = TX,
                    y = TY,
                    grid_id = TGridId
                },
            ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
            mod_scene_grid_manager:handle_player_grid_change(NewObjScenePlayer, FGridId, TGridId, transmit),
            if CallBackFun == null ->
                noop;
                true ->
                    ?TRY_CATCH(CallBackFun())
            end
    end.


%% ----------------------------------
%% @doc     玩家移动step
%% @throws 	none
%% @end
%% ----------------------------------
handle_msg_player_move_step(
    PlayerId,
    TX,
    TY,
    #scene_state{
        map_id = MapId
    }) ->
%%    if IsMission ->
%%        mod_mission:assert_mission_start();
%%        true ->
%%            noop
%%    end,
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            exit(?ERROR_NO_OBJ_SCENE_PLAYER);
        R ->
            #obj_scene_actor{
                grid_id = FGridId,
                x = FX,
                y = FY,
                hp = Hp
            } = R,

            Dis = util_math:get_distance({FX, FY}, {TX, TY}),

            if Dis >= 100 ->
                mod_map:ensure_can_walk(?PIX_2_MASK_ID(MapId, TX, TY)),
                TGridId = ?PIX_2_GRID_ID(TX, TY),
                ?ASSERT(Hp > 0, ?ERROR_ALREADY_DIE),
                case mod_map:is_jump_pos(?PIX_2_TILE(TX, TY)) of
                    true ->
                        noop;
                    false ->
                        ?ASSERT(Dis < 1000, ?ERROR_TOO_LONG)
                end,
                NewObjScenePlayer =
                    R#obj_scene_actor{
                        x = TX,
                        y = TY,
                        grid_id = TGridId
                    },
                ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
                mod_scene_grid_manager:handle_player_grid_change(NewObjScenePlayer, FGridId, TGridId, walk);
                true ->
                    noop
            end
%%            ?DEBUG("Dis:~p", [Dis])

    end.

%% ----------------------------------
%% @doc     停止移动
%% @throws 	none
%% @end
%% ----------------------------------
handle_msg_player_stop_move(
    PlayerId,
    TX,
    TY,
    #scene_state{
        map_id = MapId,
        is_mission = _IsMission
    }) ->
%%    if IsMission ->
%%        mod_mission:assert_mission_start();
%%        true ->
%%            noop
%%    end,
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            exit(?ERROR_NO_OBJ_SCENE_PLAYER);
        R ->
            #obj_scene_actor{
                x = FX,
                y = FY
            } = R,
            Dis = util_math:get_distance({FX, FY}, {TX, TY}),
            case mod_map:can_walk_pix(MapId, TX, TY) of
                true ->
                    FGridId = R#obj_scene_actor.grid_id,
                    TGridId = ?PIX_2_GRID_ID(TX, TY),
                    NewObjScenePlayer =
                        R#obj_scene_actor{
                            x = TX,
                            y = TY,
                            go_x = 0,
                            go_y = 0,
                            grid_id = TGridId,
                            move_path = []
                        },
                    if Dis >= 100 ->
                        api_scene:notice_player_stop_move(mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId, TX, TY);
%%                        api_scene:notice_player_stop_move(mod_scene_grid_manager:get_subscribe_player_id_list(FGridId), PlayerId, TX, TY);
                        true ->
                            noop
                    end,
                    ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
                    mod_scene_grid_manager:handle_player_grid_change(NewObjScenePlayer, FGridId, TGridId, walk);
                false ->
                    NewObjScenePlayer =
                        R#obj_scene_actor{
                            go_x = 0,
                            go_y = 0,
                            move_path = []
                        },
                    ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer)
            end
    end.

%% ----------------------------------
%% @doc 	监听刷怪点
%% @throws 	none
%% @end
%% ----------------------------------
handle_join_monster_point(PlayerId, MonsterId) ->
    ?ASSERT(get(?DICT_IS_HOOK_SCENE) == true, {not_hook_scene, get(?DICT_SCENE_ID)}),
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            exit(?ERROR_NO_OBJ_SCENE_PLAYER);
        R ->
%%            #obj_scene_actor{
%%                join_monster_point = OldJoinMonsterPoint
%%            } = R,
%%            if OldJoinMonsterPoint > 0 ->
%%                monster_point:leave_monster_point(OldJoinMonsterPoint, PlayerId);
%%                true ->
%%                    noop
%%            end,
%%            monster_point:join_monster_point(MonsterId, PlayerId),
            ?UPDATE_OBJ_SCENE_PLAYER(R#obj_scene_actor{
                join_monster_point = MonsterId
            })
    end.

%% ----------------------------------
%% @doc 	定时恢复玩家血量
%% @throws 	none
%% @end
%% ----------------------------------
%%handle_recover_hp(_State) ->
%%%%    ?t_assert(?SD_OUT_COMBAT_TIME > 1),
%%    erlang:send_after((?SD_OUT_COMBAT_TIME + 5) * 1000, self(), ?MSG_SCENE_RECOVER_PLAYER_HP),
%%    lists:foreach(
%%        fun(PlayerId) ->
%%            ObjScenePlayer = ?GET_OBJ_SCENE_PLAYER(PlayerId),
%%            case mod_fight:is_fight_status(ObjScenePlayer) of
%%                true ->
%%                    noop;
%%                false ->
%%                    #obj_scene_actor{
%%                        grid_id = GridId,
%%                        hp = Hp,
%%                        max_hp = MaxHp
%%                    } = ObjScenePlayer,
%%                    if
%%                        Hp >= MaxHp * 0.95 orelse Hp == 0 ->
%%                            noop;
%%                        true ->
%%                            NewHp = MaxHp,
%%                            ?UPDATE_OBJ_SCENE_PLAYER(
%%                                ObjScenePlayer#obj_scene_actor{
%%                                    hp = NewHp
%%                                }
%%                            ),
%%                            api_scene:notice_player_attr_change(mod_scene_grid_manager:get_subscribe_player_id_list(GridId), PlayerId, [{?P_HP, NewHp}])
%%                    end
%%            end
%%        end,
%%        get_all_obj_scene_player_id()
%%    ).

%% ----------------------------------
%% @doc 	处理玩家死亡
%% @throws 	none
%% @end
%% ----------------------------------
%%handle_player_death(DefObjSceneActor, AttObjSceneActor) ->
%%    #obj_scene_actor{
%%        obj_id = DefPlayerId,
%%        obj_type = _DefObjType,
%%        client_worker = DefClientWorker,
%%        x = _X,
%%        y = _Y,
%%        is_robot = DefIsRobot
%%    } = DefObjSceneActor,
%%    #obj_scene_actor{
%%        obj_type = AttObjType,
%%        obj_id = AttObjId,
%%        base_id = AttBaseId,
%%        nickname = AttName,
%%        client_worker = AttClientWorker,
%%        is_robot = AttIsRobot
%%    } = AttObjSceneActor,
%%%%    IsMission = get(?DICT_IS_MISSION),
%%
%%    SceneType = get(?DICT_SCENE_TYPE),
%%    SceneId = get(?DICT_SCENE_ID),
%%
%%    case SceneType of
%%        ?SCENE_TYPE_MISSION ->
%%            %% 副本处理玩家死亡
%%            ?TRY_CATCH(mission_handle:handle_player_death(DefPlayerId, AttObjType, AttObjId));
%%%%        ?SCENE_TYPE_BATTLE_GROUND ->
%%%%            mod_battle_ground:handle_player_death(SceneId, DefPlayerId, ?PIX_2_GRID_ID(X, Y), AttObjType, AttObjId);
%%        _ ->
%%            noop
%%    end,
%%
%%    if AttObjType == ?OBJ_TYPE_PLAYER ->
%%        %% hook after_kill_player
%%        if AttIsRobot == false ->
%%            client_worker:send_msg(AttClientWorker, {?MSG_CLIENT_KILL_PLAYER, DefPlayerId, SceneId});
%%            true ->
%%                IsZoneServer = mod_server:is_zone_server(),
%%                if IsZoneServer == false ->
%%                    game_worker:apply(hook, after_kill_player, [AttObjId, DefPlayerId, SceneId]);
%%                    true ->
%%                        noop
%%                end
%%        end,
%%        %% 修改归属关联
%%        mod_scene_monster_manager:kill_belonger(DefPlayerId, AttObjId);
%%        true ->
%%            %% 删除归属关联
%%            mod_scene_monster_manager:unlink_belong(DefPlayerId)
%%    end,
%%
%%    ServerType = mod_server_config:get_server_type(),
%%    case ServerType of
%%        ?SERVER_TYPE_GAME ->
%%            if DefIsRobot == false ->
%%                %% hook be_killed
%%                client_worker:send_msg(DefClientWorker, {?MSG_CLIENT_BE_KILLED, AttObjType, AttObjId, get(?DICT_SCENE_ID)});
%%                true ->
%%                    game_worker:apply(hook, be_killed, [DefPlayerId, AttObjType, AttObjId, get(?DICT_SCENE_ID)])
%%            end;
%%        _ ->
%%            noop
%%    end,
%%
%%%%    RebirthWindow = get(?DICT_REBIRTH_WINDOWS),
%%    RebirthWindow = 1,
%%    RealAttName =
%%        if AttObjType == ?OBJ_TYPE_PLAYER ->
%%            AttName;
%%            AttObjType == ?OBJ_TYPE_MONSTER ->
%%                erlang:list_to_binary(mod_scene_monster_manager:get_monster_name(AttBaseId))
%%        end,
%%    RebirthTime = util_time:timestamp() + ?SD_REBIRTH_TIME,
%%    if
%%        RebirthWindow == 1 ->
%%            %% 通知玩家死亡
%%            api_scene:notice_player_death(DefPlayerId, AttObjType, AttObjId, RealAttName, get(?DICT_SCENE_ID), RebirthTime),
%%            if
%%                DefIsRobot == true ->
%%                    %% 机器人自动复活
%%                    RebirthTimerRef = erlang:send_after(?SD_REBIRTH_TIME * 1000, self(), {?MSG_SCENE_PLAYER_REBIRTH, DefPlayerId, system}),
%%                    ?UPDATE_OBJ_SCENE_PLAYER(
%%                        DefObjSceneActor#obj_scene_actor{
%%                            rebirth_timer_ref = RebirthTimerRef
%%                        }
%%                    );
%%                true ->
%%                    noop
%%            end;
%%        RebirthWindow == 2 ->
%%            %% 通知玩家死亡
%%            api_scene:notice_player_death(DefPlayerId, AttObjType, AttObjId, RealAttName, get(?DICT_SCENE_ID), RebirthTime),
%%
%%            %% 定时器复活
%%%%            if
%%%%                DefIsRobot == false ->
%%            RebirthTimerRef = erlang:send_after(?SD_REBIRTH_TIME * 1000, self(), {?MSG_SCENE_PLAYER_REBIRTH, DefPlayerId, system}),
%%            ?UPDATE_OBJ_SCENE_PLAYER(
%%                DefObjSceneActor#obj_scene_actor{
%%                    rebirth_timer_ref = RebirthTimerRef
%%                }
%%            );
%%%%                true ->
%%%%                    noop
%%%%            end;
%%        true ->
%%            noop
%%    end.

%% ----------------------------------
%% @doc 	同步玩家数据
%% @throws 	none
%% @end
%% ----------------------------------
handle_msg_sync_player_data(PlayerId, SyncDataList, _State) ->
%%    ?DEBUG("sync_player_data:~p~n", [{PlayerId, SyncDataList}]),
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            noop;
        ObjScenePlayer ->
            {NewObjScenePlayer, NoticeDataList, NoticeStringDataList} =
                lists:foldl(
                    fun(SyncData, {TmpObjScenePlayer, TmpNoticeDataList, TmpNoticeStringDataList}) ->
                        case SyncData of
                            {?MSG_SYNC_LEVEL, Level} ->
                                #obj_scene_actor{
                                    max_hp = MaxHp
                                } = TmpObjScenePlayer,
                                NewHp = MaxHp,
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        level = Level,
                                        hp = NewHp
                                    },
                                    [{?P_HP, NewHp} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_VIP_LEVEL, VipLevel} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        vip_level = VipLevel
                                    },
                                    [{?P_VIP_LEVEL, VipLevel} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_POWER, Power} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        power = Power
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_MAX_HP, MaxHp} ->
                                #obj_scene_actor{
                                    hp = OldHp,
                                    max_hp = OldMaxHp
                                } = TmpObjScenePlayer,
                                if OldHp =< 0 ->
                                    {
                                        TmpObjScenePlayer#obj_scene_actor{
                                            max_hp = MaxHp
                                        },
                                        TmpNoticeDataList,
                                        TmpNoticeStringDataList
                                    };
                                    true ->
                                        NewHp = max(1, min(MaxHp, OldHp + MaxHp - OldMaxHp)),
                                        {
                                            TmpObjScenePlayer#obj_scene_actor{
                                                max_hp = MaxHp,
                                                hp = NewHp
                                            },
                                            [{?P_HP, NewHp} | TmpNoticeDataList],
                                            TmpNoticeStringDataList
                                        }
                                end;
                            {?MSG_SYNC_HP, NewHp} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        hp = NewHp
                                    },
                                    [{?P_HP, NewHp} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_ATTACK, NewAttack} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        attack = NewAttack
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_DEFENSE, NewDefense} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        defense = NewDefense
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_PK_MODE, PkMode} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        pk_mode = PkMode
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_HURT_ADD, Value} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        hurt_add = Value
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_HURT_REDUCE, Value} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        hurt_reduce = Value
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_CRIT_HURT_ADD, Value} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        crit_hurt_add = Value
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_CRIT_HURT_REDUCE, Value} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        crit_hurt_reduce = Value
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_RATE_RESIST_BLOCK, Value} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        rate_resist_block = Value
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_RATE_BLOCK, Value} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        rate_block = Value
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_HIT, NewHit} ->
                                {
                                    ObjScenePlayer#obj_scene_actor{
                                        hit = NewHit
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_DODGE, NewDodge} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        dodge = NewDodge
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_CRITICAL, NewCritical} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        critical = NewCritical
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_TENACITY, NewTenacity} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        tenacity = NewTenacity
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_TITLE_ID, TitleId} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
                                            title_id = TitleId
                                        }
                                    },
                                    [{?P_TITLE_ID, TitleId} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_MAGIC_WEAPON_ID, MagicWeaponId} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
                                            magic_weapon_id = MagicWeaponId
                                        }
                                    },
                                    [{?P_MAGIC_WEAPON_ID, MagicWeaponId} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_NAME, Name} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        nickname = Name
                                    },
                                    TmpNoticeDataList,
                                    [{?P_NAME, Name} | TmpNoticeStringDataList]
                                };
                            {?MSG_SYNC_SEX, Sex} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        sex = Sex
                                    },
                                    [{?P_SEX, Sex} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_ACTIVE_SKILL, ActiveSkillId, 0} ->
                                ?DEBUG("移除技能:~p~n", [{ActiveSkillId}]),
                                #obj_scene_actor{
                                    r_active_skill_list = RActiveSkillList
                                } = TmpObjScenePlayer,
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        r_active_skill_list = lists:keydelete(ActiveSkillId, #r_active_skill.id, RActiveSkillList)
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_ACTIVE_SKILL, ActiveSkillId, Level} ->
%%                                ?DEBUG("主动技能更新:~p~n",[{ActiveSkillId, Level}]),
                                #obj_scene_actor{
                                    r_active_skill_list = RActiveSkillList
                                } = TmpObjScenePlayer,
                                NewRActiveSkillList =
                                    if Level == 0 ->
                                        lists:keydelete(ActiveSkillId, #r_active_skill.id, RActiveSkillList);
                                        true ->
                                            case lists:keytake(ActiveSkillId, #r_active_skill.id, RActiveSkillList) of
                                                {value, RActiveSkill, Left} ->
                                                    [RActiveSkill#r_active_skill{
                                                        level = Level
                                                    } | Left];
                                                false ->
                                                    [mod_active_skill:tran_r_active_skill(ActiveSkillId, Level) | RActiveSkillList]
                                            end
                                    end,
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        r_active_skill_list = NewRActiveSkillList
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_PASSIVE_SKILL, PassiveSkillId, Level} ->
                                ?DEBUG("被动技能更新:~p~n", [{PassiveSkillId, Level}]),
                                TmpObjScenePlayer_1 = mod_buff:handle_add_passive_skill_list(TmpObjScenePlayer, [{PassiveSkillId, Level}]),
                                {
                                    TmpObjScenePlayer_1,
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_HERO_ID, HeroId} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
                                            hero_id = HeroId
                                        }
                                    },
                                    [{?P_HERO_ID, HeroId} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_HERO_ARMS, ArmsId} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
                                            hero_arms = ArmsId
                                        }
                                    },
                                    [{?P_HERO_ARMS_ID, ArmsId} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_HERO_ORNAMENTS, OrnamentsId} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
                                            hero_ornaments = OrnamentsId
                                        }
                                    },
                                    [{?P_HERO_ORNAMENTS_ID, OrnamentsId} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_HEAD_ID, HeadId} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
                                            head_id = HeadId
                                        }
                                    },
                                    [{?P_HEAD_ID, HeadId} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_HEAD_FRAME_ID, HeadFrameId} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
                                            head_frame_id = HeadFrameId
                                        }
                                    },
                                    [{?P_HEAD_FRAME_ID, HeadFrameId} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_CHAT_QI_PAO_ID, ChatQiPaoId} ->
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
                                            chat_qi_pao_id = ChatQiPaoId
                                        }
                                    },
                                    [{?P_CHAT_QI_PAO_ID, ChatQiPaoId} | TmpNoticeDataList],
                                    TmpNoticeStringDataList
                                };
                            {?MSG_SYNC_IS_CAN_ADD_ANGER, NewIsCanAddAnger} ->
%%                                ?DEBUG("改变场景是否可以增加怒气~p",[NewIsCanAddAnger]),
                                api_scene:notice_anger(PlayerId, 0),
                                {
                                    TmpObjScenePlayer#obj_scene_actor{
                                        is_can_add_anger = NewIsCanAddAnger,
                                        anger = 0
                                    },
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                };
%%                            {?MSG_SYNC_SHEN_LONG_ID, ShenLongId} ->
%%                                {
%%                                    TmpObjScenePlayer#obj_scene_actor{
%%                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
%%                                            shen_long_id = ShenLongId
%%                                        }
%%                                    },
%%                                    [{?P_SHEN_LONG_ID, ShenLongId} | TmpNoticeDataList],
%%                                    TmpNoticeStringDataList
%%                                };
%%                            {?MSG_SYNC_HUO_QIU_ID, HuoQiuId} ->
%%                                {
%%                                    TmpObjScenePlayer#obj_scene_actor{
%%                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
%%                                            huo_qiu_id = HuoQiuId
%%                                        }
%%                                    },
%%                                    [{?P_HUO_QIU_ID, HuoQiuId} | TmpNoticeDataList],
%%                                    TmpNoticeStringDataList
%%                                };
%%                            {?MSG_SYNC_DI_ZHEN_ID, DiZhenId} ->
%%                                {
%%                                    TmpObjScenePlayer#obj_scene_actor{
%%                                        surface = (TmpObjScenePlayer#obj_scene_actor.surface)#surface{
%%                                            di_zhen_id = DiZhenId
%%                                        }
%%                                    },
%%                                    [{?P_DI_ZHEN_ID, DiZhenId} | TmpNoticeDataList],
%%                                    TmpNoticeStringDataList
%%                                };
                            Other ->
                                ?ERROR("sync_player_data:~p", [{Other}]),
                                {
                                    TmpObjScenePlayer,
                                    TmpNoticeDataList,
                                    TmpNoticeStringDataList
                                }
                        end
                    end,
                    {ObjScenePlayer, [], []},
                    SyncDataList
                ),
            ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
%%            #obj_scene_actor{
%%                grid_id = GridId
%%            } = NewObjScenePlayer,
%%            NoticePlayerIdList = mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
            NoticePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
            api_scene:notice_player_attr_change(NoticePlayerIdList, PlayerId, lists:reverse(NoticeDataList)),
            api_scene:notice_player_string_attr_change(NoticePlayerIdList, PlayerId, NoticeStringDataList)
    end.


%% ----------------------------------
%% @doc 	玩家进程apply
%% @throws 	none
%% @end
%% ----------------------------------
-spec apply_to_all_client_worker(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].

-spec apply_to_all_client_worker(M, F, A, Type) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()],
    Type :: term().

apply_to_all_client_worker(M, F, A) ->
    apply_to_all_client_worker(M, F, A, normal).
apply_to_all_client_worker(M, F, A, Type) ->
    lists:foreach(
        fun(PlayerId) ->
            apply_to_client_worker(PlayerId, M, F, [PlayerId | A], Type)
        end,
        get_all_obj_scene_player_id()
    ).

-spec apply_to_client_worker(PlayerId, M, F, A) -> term() when
    PlayerId :: integer(),
    M :: module(),
    F :: atom(),
    A :: [term()].

-spec apply_to_client_worker(PlayerId, M, F, A, Type) -> term() when
    PlayerId :: integer(),
    M :: module(),
    F :: atom(),
    A :: [term()],
    Type :: term().


apply_to_client_worker(PlayerId, M, F, A) ->
    apply_to_client_worker(PlayerId, M, F, A, normal).

apply_to_client_worker(PlayerId, M, F, A, Type) ->
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            noop;
        ObjScenePlayer ->
            #obj_scene_actor{
                client_node = ClientNode
            } = ObjScenePlayer,
            mod_apply:apply_to_online_player(ClientNode, PlayerId, M, F, A, Type)
    end.
