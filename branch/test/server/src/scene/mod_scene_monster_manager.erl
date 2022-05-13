%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            场景怪物管理
%%% @end
%%% Created : 20. 十一月 2017 上午 11:10
%%%-------------------------------------------------------------------
-module(mod_scene_monster_manager).

-include("scene.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").
-include("error.hrl").
-include("scene_monster.hrl").
-include("fight.hrl").
-include("skill.hrl").
-include("msg.hrl").
-include("p_enum.hrl").
-include("mission.hrl").
-include("p_message.hrl").

-define(RANDOM_OBJ_MONSTER_ID_RANGE, [10000, 90000000]).%% 怪物对象随机唯一id范围
-export([
    get_obj_scene_monster/1,
    get_all_obj_scene_monster_id/0,
    get_all_obj_scene_spec_monster_id/0,
    get_live_monster_num/0,
    get_live_monster_num/1,
    get_monster_effect/1
]).
%% API
-export([
    call_monster/4,
    call_monster1/6,
    create_all_monster/1,
    destroy_monster_by_monster_id/1,
    destroy_all_monster/0,
    destroy_all_monster/1,
    async_destroy_monster/2,
    handle_heart_beat/2,
    update_hate_list/4,
    start_timer_2_create_monster/4,
    handle_create_monster_2/5,
    handle_rebirth_monster/2,
    do_destroy_monster/2,
    handle_death/2,
    create_monster/2,
    create_monster_list/2,
    create_monster/4,
    create_monster_by_group/5,
    do_create_monster/2,
    go_target_place/5,
    get_t_monster/1,
    get_t_monster_kind/1,
    get_monster_name/1,
    handle_navigate_result/2,
    unlink_belong/1,
    kill_belonger/2,
    handle_monster_wild_timeout/2
]).

%% 怪物回血(血条模式下)
-export([
    handle_recover_all_monster_hp/0,
    handle_recover_monster_hp/0,
    player_leave_recover_monster_hp/1
]).

-export([
    create_monster/5
]).

%% 睡眠
-define(GO_SLEEP(ObjMonster, State),
    if ObjMonster#obj_scene_actor.move_path =/= [] ->
        (stop_move(ObjMonster, State))#obj_scene_actor{
            status = ?MONSTER_STATUS_SLEEP,
            track_info = #track_info{}
        };
        true ->
            ObjMonster#obj_scene_actor{
                status = ?MONSTER_STATUS_SLEEP,
                track_info = #track_info{}
            }
    end
).
%% 巡逻
-define(GO_PATROL(ObjMonster, State),
    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 300),

    handle_monster_run(ObjMonster, ?MOVE_TYPE_NORMAL),

    if ObjMonster#obj_scene_actor.move_path =/= [] ->
        (stop_move(ObjMonster, State))#obj_scene_actor{
            status = ?MONSTER_STATUS_PATROL,
            track_info = #track_info{}
        };
        true ->
            ObjMonster#obj_scene_actor{
                status = ?MONSTER_STATUS_PATROL,
                track_info = #track_info{}
            }
    end
).
%% 追踪
-define(GO_TRACK(ObjMonster, State),
    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 300),

    if ObjMonster#obj_scene_actor.move_path =/= [] ->
        (stop_move(ObjMonster, State))#obj_scene_actor{status = ?MONSTER_STATUS_TRACK};
        true ->
            ObjMonster#obj_scene_actor{status = ?MONSTER_STATUS_TRACK}
    end
).
%% 攻击
-define(GO_ATTACK(ObjMonster, State),
    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 300),
    ObjMonsterAfterStatusModify =
        if ObjMonster#obj_scene_actor.move_path =/= [] ->
            (stop_move(ObjMonster, State))#obj_scene_actor{status = ?MONSTER_STATUS_ATTACK};
            true ->
                ObjMonster#obj_scene_actor{status = ?MONSTER_STATUS_ATTACK}
        end,
    ObjMonsterAfterStatusModify
).
%% 回退
-define(GO_BACK(ObjMonster, State),
    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 300),
    if ObjMonster#obj_scene_actor.move_path =/= [] ->
        (stop_move(ObjMonster, State))#obj_scene_actor{
            status = ?MONSTER_STATUS_BACK,
            hate_list = [],
            track_info = #track_info{}
        };
        true ->
            ObjMonster#obj_scene_actor{
                status = ?MONSTER_STATUS_BACK,
                track_info = #track_info{},
                hate_list = []
            }
    end
).

%% ----------------------------------
%% @doc 	获取所有场景怪物id
%% @throws 	none
%% @end
%% ----------------------------------
get_all_obj_scene_monster_id() ->
    mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER).

%% 需要全场景同步的怪id列表
get_all_obj_scene_spec_monster_id() ->
    lists:filtermap(fun(ObjSceneMonsterId) ->
        R = ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId),
        R#obj_scene_actor.is_all_sync
                    end, get_all_obj_scene_monster_id()).

get_live_monster_num(Mid) ->
    lists:foldl(
        fun(ObjSceneMonsterId, N) ->
            case ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId) of
                ?UNDEFINED ->
                    N;
                R ->
                    if R#obj_scene_actor.owner_obj_type =/= ?OBJ_TYPE_PLAYER andalso R#obj_scene_actor.base_id == Mid ->
                        N + 1;
                        true ->
                            N
                    end
            end
        end,
        0,
        get_all_obj_scene_monster_id()
    ).

get_live_monster_num() ->
    lists:foldl(
        fun(ObjSceneMonsterId, N) ->
            case ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId) of
                ?UNDEFINED ->
                    N;
                R ->
                    if R#obj_scene_actor.owner_obj_type =/= ?OBJ_TYPE_PLAYER ->
                        N + 1;
                        true ->
                            N
                    end
            end
        end,
        0,
        get_all_obj_scene_monster_id()
    ).

%% 获取怪物效果
get_monster_effect(ObjSceneActor) when is_record(ObjSceneActor, obj_scene_actor) ->
    #obj_scene_actor{
        effect = EffectList
    } = ObjSceneActor,
    get_monster_effect(EffectList);
get_monster_effect(EffectList) ->
    case EffectList of
        [] -> ?MONSTER_EFFECT_0;
        [ThisEffect] -> ThisEffect;
        [ThisEffect, _] -> ThisEffect;
        _ -> ?MONSTER_EFFECT_0
    end.

%% ----------------------------------
%% @doc     创建所有怪物
%% @throws 	none
%% @end
%% ----------------------------------
create_all_monster(State = #scene_state{scene_id = SceneId}) ->
    case scene_data:get_scene_monster_id_list(SceneId) of
        null ->
            ?WARNING("怪物没配:~p~n", [{SceneId}]),
            noop;
        SceneMonsterIdList ->
            if SceneMonsterIdList == [] ->
                ?WARNING("怪物没配:~p~n", [{SceneId}]);
                true ->
                    noop
            end,
            lists:foreach(
                fun(SceneMonsterId) ->
                    ?TRY_CATCH2(create_monster(SceneMonsterId, State))
                end,
                SceneMonsterIdList
            )
    end.


call_monster1(PlayerId, MonsterId, LiveTime, Cost, BirthX, BirthY) ->
    CreateMonsterArgs = #create_monster_args{
        monster_id = MonsterId,
        birth_x = BirthX,
        birth_y = BirthY,
        is_notice = true,
        owner_obj_type = ?OBJ_TYPE_PLAYER,
        owner_obj_id = PlayerId,
        live_time = LiveTime,
        cost = Cost
    },
%%    put({is_call_monster, PlayerId, MonsterId}, true),
    self() ! {?MSG_SCENE_CREATE_MONSTER_BY_ARGS, CreateMonsterArgs}.

%% ----------------------------------
%% @doc 	召唤怪物
%% @throws 	none
%% @end
%% ----------------------------------
call_monster(PlayerId, MonsterId, BirthX, BirthY) ->
    CreateMonsterArgs = #create_monster_args{
        monster_id = MonsterId,
        birth_x = BirthX,
        birth_y = BirthY,
        is_notice = true,
        owner_obj_type = ?OBJ_TYPE_PLAYER,
        owner_obj_id = PlayerId
    },
    put({is_call_monster, PlayerId, MonsterId}, true),
    self() ! {?MSG_SCENE_CREATE_MONSTER_BY_ARGS, CreateMonsterArgs}.

%% ----------------------------------
%% @doc     创建怪物列表
%% @throws 	none
%% @end
%% ----------------------------------
create_monster_list(SceneMonsterIdList, State = #scene_state{scene_id = SceneId, mission_type = MissionType}) ->
    BossPosList =
        if
            MissionType =:= ?MISSION_TYPE_GUESS_BOSS ->
                #t_scene{
                    monster_x_y_list = MonsterPosList
                } = t_scene:get({SceneId}),
                RealMonsterPosList = util_list:shuffle(MonsterPosList),
                BossList = [Boss || Boss <- SceneMonsterIdList],
                #t_scene{
                    monster_x_y_list = MonsterPosList
                } = t_scene:get({SceneId}),
                lists:zip(BossList, RealMonsterPosList);
            true -> []
        end,

    NoticeList =
        lists:foldl(
            fun(SceneMonsterId, Tmp) ->
                {MonsterNoticePlayerIdList, ObjSceneMonster} =
                    if
                        length(BossPosList) > 0 ->
                            [OffsetMinX, OffsetMaxX, OffsetMinY, OffsetMaxY] = ?SD_GUESS_BOSS_BIRTH_POSITION_RANGE_LIST,
                            case lists:keyfind(SceneMonsterId, 1, BossPosList) of
                                false -> ok;
                                {SceneMonsterId, [BirthX, BirthY]} ->
                                    RealBirthX = BirthX + util_random:random_number(OffsetMinX, OffsetMaxX),
                                    RealBirthY = BirthY + util_random:random_number(OffsetMinY, OffsetMaxY),
                                    {RealX, RealY} =
                                        case mod_map:can_walk_pix(SceneId, RealBirthX, RealBirthY) of
                                            true -> {RealBirthX, RealBirthY};
                                            false ->
                                                {BirthX, BirthY}
                                        end,
                                    create_monster(SceneMonsterId, RealX, RealY, State)
                            end;
                        true ->
                            {MonsterNoticePlayerIdList1, ObjSceneMonster1} = create_monster(SceneMonsterId, false, State),
                            SceneMonster = mod_scene:get_r_scene_monster({SceneId, SceneMonsterId}),
                            ?t_assert(SceneMonster =/= null, {scene_monster_no_found, SceneMonsterId, SceneId}),
                            #r_scene_monster{
                                monster_id = MonsterId
                            } = SceneMonster,
                            #t_monster{
                                is_boss = IsBoss
                            } = t_monster:assert_get({MonsterId}),
                            MonsterNoticePlayerIdList2 = ?IF(IsBoss =:= ?TRUE, mod_scene_player_manager:get_all_obj_scene_player_id(), MonsterNoticePlayerIdList1),
                            {MonsterNoticePlayerIdList2, ObjSceneMonster1}
                    end,
                if MonsterNoticePlayerIdList == [] ->
                    Tmp;
                    true ->
                        case lists:keytake(MonsterNoticePlayerIdList, 1, Tmp) of
                            {value, {MonsterNoticePlayerIdList, ObjSceneMonsterList}, Left} ->
                                [{MonsterNoticePlayerIdList, [ObjSceneMonster | ObjSceneMonsterList]} | Left];
                            false ->
                                [{MonsterNoticePlayerIdList, [ObjSceneMonster]} | Tmp]
                        end
                end
            end,
            [],
            SceneMonsterIdList
        ),
    lists:foreach(
        fun({NoticePlayerIdList, ObjSceneMonsterList}) ->
            if
                MissionType =:= ?MISSION_TYPE_GUESS_BOSS ->
                    mod_mission_one_on_one:handle_monster_enter();
                true ->
                    api_scene:notice_monster_enter(NoticePlayerIdList, ObjSceneMonsterList)
            end
        end,
        NoticeList
    ).

%% ----------------------------------
%% @doc 	创建怪物
%% @throws 	none
%% @end
%% ----------------------------------
create_monster(SceneMonsterId, State) ->
    create_monster(SceneMonsterId, true, State).
create_monster(SceneMonsterId, IsNotice, State = #scene_state{scene_id = SceneId}) ->
    SceneMonster = mod_scene:get_r_scene_monster({SceneId, SceneMonsterId}),
    ?t_assert(SceneMonster =/= null, {scene_monster_no_found, SceneMonsterId, SceneId}),
    #r_scene_monster{
        monster_id = MonsterId,
        x = BirthX,
        y = BirthY
    } = SceneMonster,
    CreateMonsterArgs = #create_monster_args{
        monster_id = MonsterId,
        birth_x = BirthX,
        birth_y = BirthY,
        is_notice = IsNotice
    },
    do_create_monster(CreateMonsterArgs, State).

create_monster(MonsterId, BirthX, BirthY, Dir, State) ->
    CreateMonsterArgs = #create_monster_args{
        monster_id = MonsterId,
        birth_x = BirthX,
        birth_y = BirthY,
        is_notice = true,
        dir = Dir
    },
    do_create_monster(CreateMonsterArgs, State).

create_monster(MonsterId, BirthX, BirthY, State) ->
    CreateMonsterArgs = #create_monster_args{
        monster_id = MonsterId,
        birth_x = BirthX,
        birth_y = BirthY,
        is_notice = true,
        dir = util_random:get_list_random_member([?DIR_UP, ?DIR_DOWN, ?DIR_LEFT, ?DIR_RIGHT, ?DIR_LEFT_UP, ?DIR_LEFT_DOWN, ?DIR_RIGHT_UP, ?DIR_LEFT_DOWN])
    },
    do_create_monster(CreateMonsterArgs, State).

create_monster_by_group(MonsterId, BirthX, BirthY, Group, State) ->
    CreateMonsterArgs = #create_monster_args{
        monster_id = MonsterId,
        birth_x = BirthX,
        birth_y = BirthY,
        is_notice = true,
        group = Group,
        dir = util_random:get_list_random_member([?DIR_UP, ?DIR_DOWN, ?DIR_LEFT, ?DIR_RIGHT, ?DIR_LEFT_UP, ?DIR_LEFT_DOWN, ?DIR_RIGHT_UP, ?DIR_LEFT_DOWN])
    },
    do_create_monster(CreateMonsterArgs, State).

do_create_monster(CreateMonsterArgs, #scene_state{scene_id = SceneId, map_id = MapId, scene_type = SceneType, mission_type = MissionType, fight_type = FightType} = State) ->
    #create_monster_args{
        monster_id = MonsterId,
        birth_x = BirthX,
        birth_y = BirthY,
        is_notice = IsNotice,
        owner_obj_type = OwnerObjType,
        owner_obj_id = OwnerObjId,
        live_time = LiveTime,
        cost = Cost,
        dir = Dir,
        group = Group
    } = CreateMonsterArgs,

    ObjSceneMonsterId = get_unique_id(),
    ?ASSERT(?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId) == ?UNDEFINED, {obj_monster_id_repeated, ObjSceneMonsterId, MonsterId}),
    ?ASSERT(mod_map:can_walk_pix(MapId, BirthX, BirthY), {monster_birth_not_can_walk, SceneId, ObjSceneMonsterId, MonsterId, BirthX, BirthY}),
    NewMonster = get_t_monster(MonsterId),
    ?ASSERT(NewMonster =/= null, {monster_no_found, MonsterId}),

    #t_monster{
        type = Type,
        skill_list = SkillList,
        p_skill_list = PassiveSkillList,
        rebirth_time = RebirthTime,
        is_boss = IsBoss,
        kind = Kind,
        new_ling_li = NewLingli,
        hp = HpInCsv,
        new_hp = NewHp,
        effect_list = EffectList,
        attack = Attack,
        defense = Defense,
        level = MonsterLevel,
        hurt_add = HurtAdd,
        hurt_reduce = HurtReduce,
        move_speed = MoveSpeed,
        tenacity = Tenacity,
        resist_block = ResistBlock,
        block = Block,
        hit = Hit,
        dodge = Dodge,
        crit = Crit,
        crit_hurt_add = CriHurtAdd,
        crit_hurt_reduce = CritHurtReduce,
        destroy_time = DestroyTime0,
        new_hp_destroy_time = NewHpDestroyTime0,
        type_action_list = TypeActionList
    } = NewMonster,

    DestroyTime =
        if
            LiveTime > 0 ->
                LiveTime;
            true ->
                case FightType of 0 -> DestroyTime0; 1 -> NewHpDestroyTime0 end
        end,
    Hp =
        case FightType of
            0 ->
                if
                    NewLingli == 0 ->
                        if
                            SceneType =:= ?SCENE_TYPE_MISSION -> HpInCsv;
                            true -> 1
                        end;
                    true ->
                        NewLingli
                end;
            1 -> NewHp end,
    ActiveSkillList =
        if
            SceneType =:= ?SCENE_TYPE_MISSION andalso (MissionType =:= ?MISSION_TYPE_GUESS_BOSS orelse
                MissionType =:= ?MISSION_TYPE_MISSION_HERO_PK_BOSS) ->
                [t_mission_guess_boss_skill:get({SkillId}) || [SkillId, _] <- SkillList];
            true ->
                [mod_active_skill:tran_r_active_skill(SkillId, null) || [SkillId, _] <- SkillList]
        end,
    Effect =
        case EffectList of
            [] ->
                0;
            [ThisEffect] ->
                ThisEffect;
            [ThisEffect, _] ->
                ThisEffect;
            _ ->
                0
        end,
    ObjSceneMonster_0 =
        #obj_scene_actor{
            key = {?OBJ_TYPE_MONSTER, ObjSceneMonsterId},
            obj_type = ?OBJ_TYPE_MONSTER,
            obj_id = ObjSceneMonsterId,
            base_id = MonsterId,
            cost = Cost,
            base_type = Type,
            status = ?MONSTER_STATUS_PATROL,
            create_time = util_time:timestamp(),
            x = BirthX,
            y = BirthY,
            birth_x = BirthX,
            birth_y = BirthY,
            grid_id = ?PIX_2_GRID_ID(BirthX, BirthY),
            hp = Hp,
            max_hp = Hp,
            level = MonsterLevel,
            attack = Attack,
            effect = EffectList,
            defense = Defense,
            tenacity = Tenacity,
            rate_resist_block = ResistBlock,
            rate_block = Block,
            hit = Hit,
            dodge = Dodge,
            critical = Crit,
            crit_hurt_add = CriHurtAdd,
            crit_hurt_reduce = CritHurtReduce,
            owner_obj_type = OwnerObjType,
            owner_obj_id = OwnerObjId,
            move_speed = MoveSpeed,
            init_move_speed = MoveSpeed,
            rebirth_time = RebirthTime,
            r_active_skill_list = ActiveSkillList,
            is_boss = ?TRAN_INT_2_BOOL(IsBoss),
            hurt_add = HurtAdd,
            hurt_reduce = HurtReduce,
            dir = ?IF(Dir =:= 0, ?DIR_DOWN, Dir),
            kind = Kind,
            is_all_sync = ?TRAN_INT_2_BOOL(IsBoss) orelse case EffectList of [] -> false;[0] -> false;_ -> true end,
            destroy_time_ms = if
                                  DestroyTime > 0 ->
                                      util_time:milli_timestamp() + DestroyTime;
                                  true ->
                                      0
                              end,
            type_action_list = ?IF(TypeActionList == [], [], util_random:get_list_random_member(TypeActionList)),
            group = Group
        },

    ObjSceneMonster_1 =
        if
            Effect == 15 ->
                #t_scene{
                    gold_monster_move_list = GoldMonsterMoveList
                } = mod_scene:get_t_scene(SceneId),
                GoldMonsterMoveList1 = util_random:get_list_random_member(GoldMonsterMoveList),
                Length = length(GoldMonsterMoveList1),
                {ThisGoldMonsterMoveList2, GoldMonsterMoveList2} = lists:split(util_random:random_number(Length) - 1, GoldMonsterMoveList1),
                [[GoldMonsterBirthX, GoldMonsterBirthY] | GoldMonsterMoveList3] = GoldMonsterMoveList2,
                ObjSceneMonster_0#obj_scene_actor{
                    birth_y = GoldMonsterBirthY,
                    birth_x = GoldMonsterBirthX,
                    x = GoldMonsterBirthX,
                    y = GoldMonsterBirthY,
                    type_action_list = [GoldMonsterMoveList3 ++ ThisGoldMonsterMoveList2, GoldMonsterMoveList3 ++ ThisGoldMonsterMoveList2]
                };
            true ->
                ObjSceneMonster_0
        end,

    ObjSceneMonster = mod_buff:handle_add_passive_skill_list(ObjSceneMonster_1, [{PassiveSkillId, PassiveSkillLevel}
        || [PassiveSkillId, PassiveSkillLevel] <- PassiveSkillList]),
    add_obj_scene_monster(ObjSceneMonster),
    %% @todo 当场景为108时，不通知怪物进场
    SubscribePlayerIdList = mod_scene_grid_manager:handle_monster_enter_grid(
        ObjSceneMonster, ?IF(MissionType =:= ?MISSION_TYPE_MISSION_HERO_PK_BOSS, false, IsNotice)),

    if
        MissionType =:= ?MISSION_TYPE_GUESS_BOSS orelse MissionType =:= ?MISSION_TYPE_MISSION_HERO_PK_BOSS -> ok;
        true ->
            %% 创建怪物心跳
            erlang:send_after(util_random:random_number(500, 1000), self(), {?MSG_SCENE_MONSTER_HEART_BEAT, ObjSceneMonsterId})
    end,
    if OwnerObjId == 0 ->
        case SceneType of
            ?SCENE_TYPE_MISSION ->
                %% @todo 当场景为108时，不通知怪物进场
                if
                    MissionType =:= ?MISSION_TYPE_MISSION_HERO_PK_BOSS -> noop;
                    true -> mission_handle:handle_monster_enter_mission(ObjSceneMonster, State)
                end;
            _ ->
                noop
        end;
        true ->
            noop
    end,
    if DestroyTime > 0 ->
        async_destroy_monster(ObjSceneMonsterId, force, DestroyTime);
        true ->
            noop
    end,
    {SubscribePlayerIdList, ObjSceneMonster}.

%% ----------------------------------
%% @doc 	前往目的地
%% @throws 	none
%% @end
%% ----------------------------------
go_target_place(ObjMonsterId, X, Y, Fun, #scene_state{scene_id = _SceneId} = State) ->
    case ?GET_OBJ_SCENE_MONSTER(ObjMonsterId) of
        ?UNDEFINED ->
            ?WARNING("怪物不存在:~p", [{ObjMonsterId, _SceneId}]);
        ObjMonster ->
            ObjMonster_0 = mod_scene:deal_move_step(ObjMonster, util_time:milli_timestamp(), State),
            ObjMonster_1 = stop_move(ObjMonster_0, State),
            NewObjMonster =
                ObjMonster_1#obj_scene_actor{
                    status = ?MONSTER_STATUS_TARGET_PLACE,
                    go_target_place = #go_target_place{
                        x = X,
                        y = Y,
                        function = Fun
                    }
                },
            ?UPDATE_OBJ_SCENE_MONSTER(NewObjMonster)
    end.

%% ----------------------------------
%% @doc 	停止移动
%% @throws 	none
%% @end
%% ----------------------------------
stop_move(ObjMonster = #obj_scene_actor{move_path = []}, _State) ->
    ObjMonster;
stop_move(ObjMonster, _State) ->
    #obj_scene_actor{
        obj_id = ObjMonsterId,
        x = X,
        y = Y,
        grid_id = GridId,
        is_all_sync = IsAllSync
    } = ObjMonster,
    api_scene:notice_monster_stop_move(?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)), ObjMonsterId, X, Y),
    ObjMonster#obj_scene_actor{move_path = [], go_x = 0, go_y = 0, is_wait_navigate = false}.

%% ----------------------------------
%% @doc 	寻路结果回调
%% @throws 	none
%% @end
%% ----------------------------------
handle_navigate_result({Result, ObjMonsterId, {_TargetX, _TargetY}, NewMovePath}, #scene_state{scene_id = _SceneId, map_id = _MapId}) ->
    case ?GET_OBJ_SCENE_MONSTER(ObjMonsterId) of
        ?UNDEFINED ->
            noop;
        ObjMonster ->
            #obj_scene_actor{
                grid_id = GridId,
                is_wait_navigate = IsWaitNavigate,
                hp = Hp,
                x = _X,
                y = _Y,
                is_all_sync = IsAllSync
            } = ObjMonster,
            if
                Hp > 0 andalso IsWaitNavigate == true ->
                    NewObjMonster =
                        if
                            Result == success ->
                                if NewMovePath =/= [] ->
                                    api_scene:notice_monster_move(?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)), ObjMonsterId, NewMovePath);
                                    true ->
                                        noop
                                end,
                                ObjMonster#obj_scene_actor{
                                    is_wait_navigate = false,
                                    move_path = NewMovePath,
                                    last_move_time = util_time:milli_timestamp()
                                };
                            Result == max_node ->
                                ObjMonster#obj_scene_actor{
                                    is_wait_navigate = false,
                                    next_can_heart_time = util_time:milli_timestamp() + 1500,
                                    move_path = [],
                                    status = ?MONSTER_STATUS_BACK,
                                    track_info = #track_info{}
                                };
                            true ->
%%                                ?ERROR("寻路失败:~p~n", [{SceneId, MapId, ObjMonsterId, {X, Y}, {TargetX, TargetY}, NewMovePath, IsMaxNode}]),
                                ObjMonster#obj_scene_actor{
                                    is_wait_navigate = false,
                                    next_can_heart_time = util_time:milli_timestamp() + 3000,
                                    move_path = [],
                                    status = ?MONSTER_STATUS_BACK,
                                    track_info = #track_info{}
                                }
                        end,
                    ?UPDATE_OBJ_SCENE_MONSTER(NewObjMonster);
                true ->
                    noop
            end
    end.

%% 检测心跳时间
check_heart_time(IsBoss, OwnerObjType) when IsBoss; OwnerObjType > 0 -> ?HIGH_LEVEL_MONSTER_DEFAULT_HEART_TIME;
check_heart_time(_IsBoss, _OwnerObjType) -> ?LOW_MONSTER_DEFAULT_HEART_TIME.

%% ----------------------------------
%% @doc 	怪物心跳
%% @throws 	none
%% @end
%% ----------------------------------
handle_heart_beat(ObjSceneMonsterId, State = #scene_state{scene_id = _SceneId}) ->
    case ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId) of
        ?UNDEFINED ->
            noop;
        OldObjMonster ->
            #obj_scene_actor{
                obj_id = ObjId,
                base_type = MonsterType,
                is_boss = IsBoss,
                owner_obj_type = OwnerObjType,
                move_path = MovePath,
                effect = EffectList
            } = OldObjMonster,
            Now = util_time:milli_timestamp(),
            put(?DICT_NOW_MS, Now),
            Effect = get_monster_effect(EffectList),

            %% 处理移动
            ObjMonster_0 =
                if
                    MovePath =/= [] ->
                        mod_scene:deal_move_step(OldObjMonster, Now, State);
                    true ->
                        OldObjMonster
                end,
            %% 心跳前处理
            ObjMonster_1 = before_do_heart_beat(Effect, ObjMonster_0, Now, State),

            {DefaultHeartBeatTime, MoveHeartBeatTime} = check_heart_time(IsBoss, OwnerObjType),
            NewObjMonster =
                if
                    MonsterType =:= ?MONSTER_TYPE_ATTACK_PLAYER ->
                        do_heart_beat_by_type_6(ObjMonster_1, State);
                    MonsterType == ?MONSTER_TYPE_FIY ->
                        do_heart_beat_by_type_4(ObjMonster_1, State);
                    MonsterType == ?MONSTER_TYPE_HD ->
                        do_heart_beat_by_type_5(ObjMonster_1, State);
                    MonsterType == ?MT_BOSS_1 ->
                        do_heart_beat_by_type_9(ObjMonster_1, State);
                    true ->
                        %% 设置怪物默认心跳
                        put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, DefaultHeartBeatTime),

                        #obj_scene_actor{
                            next_can_heart_time = NextCanHeartBeatTime,
                            can_action_time = CanActionTime,
                            hp = Hp,
                            is_wait_navigate = IsWaitNavigate,
                            owner_obj_id = OwnerPlayerId
                        } = ObjMonster_1,
                        ?ASSERT(Hp > 0),

                        ObjMonster_2 =
                            if
                                OwnerPlayerId > 0 ->
                                    %% 更新怪物出生点(归属者当前位置为出生点)
                                    case ?GET_OBJ_SCENE_PLAYER(OwnerPlayerId) of
                                        ?UNDEFINED ->
                                            async_destroy_monster(ObjId, force),
                                            ObjMonster_1;
                                        ObjScenePlayer ->
                                            if ObjScenePlayer#obj_scene_actor.hp =< 0 ->
                                                async_destroy_monster(ObjId, force);
                                                true ->
                                                    noop
                                            end,
                                            ObjMonster_1#obj_scene_actor{
                                                birth_x = ObjScenePlayer#obj_scene_actor.x,
                                                birth_y = ObjScenePlayer#obj_scene_actor.y
                                            }
                                    end;
                                true ->
                                    ObjMonster_1
                            end,
                        if
                            Now >= NextCanHeartBeatTime andalso Now >= CanActionTime andalso IsWaitNavigate == false ->
                                do_heart_beat(ObjMonster_2, State);
                            true ->
                                ObjMonster_2
                        end
                end,
            if OldObjMonster =/= NewObjMonster ->
                ?UPDATE_OBJ_SCENE_MONSTER(NewObjMonster);
                true ->
                    noop
            end,
            %% 获取下次心跳时间，如果路径不为空则心跳加快，减少拉扯现象
            NextHeartBeatTime = ?IF(NewObjMonster#obj_scene_actor.move_path =/= [], MoveHeartBeatTime, get(?DICT_MONSTER_NEXT_HEART_BEAT_TIME)),
            erlang:send_after(NextHeartBeatTime, self(), {?MSG_SCENE_MONSTER_HEART_BEAT, ObjSceneMonsterId})
    end.


%% 睡眠
do_heart_beat(
    ObjMonster = #obj_scene_actor{status = ?MONSTER_STATUS_SLEEP},
    State = #scene_state{scene_id = _SceneId, is_mission = IsMission}
) ->
    #obj_scene_actor{
        base_type = MonsterType,
        hate_list = HateList,
        is_boss = IsBoss,
        owner_obj_id = _OwnerPlayerId
    } = ObjMonster,
    if
        MonsterType == ?MT_ACTIVE orelse MonsterType == ?MONSTER_ACTIVE_ATTACK_MONSTER orelse HateList =/= [] ->
            %% 主动怪
            case mod_scene_player_manager:get_all_obj_scene_player_id() of
                [] ->
                    %% 没有玩家在场景， 继续睡眠
                    if IsMission orelse IsBoss ->
                        put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 1200);
                        true ->
                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 4000)
                    end,
                    ObjMonster;
                _ ->
                    %% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 巡逻
                    ?GO_PATROL(ObjMonster, State)
            end;
        true ->
            %% 被动怪
            case mod_scene_player_manager:get_all_obj_scene_player_id() of
                [] ->
                    %% 没有玩家在场景， 继续睡眠
                    if IsMission orelse IsBoss ->
                        put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 1200);
                        true ->
                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 4000)
                    end,
                    ObjMonster;
                _ ->
                    %% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 巡逻
                    ?GO_PATROL(ObjMonster, State)
            end
    end;
%% 巡逻
do_heart_beat(
    ObjMonster_0 = #obj_scene_actor{status = ?MONSTER_STATUS_PATROL},
    State = #scene_state{is_mission = IsMission}
) ->
    ObjMonster = search_attack_target(ObjMonster_0, State),
    #obj_scene_actor{
        obj_id = _ObjId,
        base_type = MonsterType,
        base_id = MonsterId,
        x = X,
        y = Y,
        birth_x = SrcX,
        birth_y = SrcY,
        is_boss = IsBoss,
        track_info = #track_info{obj_id = TrackObjId},
        owner_obj_type = OwnerObjType,
        is_all_sync = _IsAllSync
    } = ObjMonster,
    {PatrolRange, _TrackRange, _WarnRange} = get_monster_ai_args(MonsterId),
    if
        %% 没有追踪对象
        TrackObjId == 0 ->
            if
                PatrolRange == 0 ->
                    %% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 睡眠
                    ?GO_SLEEP(ObjMonster, State);
                true ->
                    case util_math:is_in_range({X, Y}, {SrcX, SrcY}, PatrolRange * ?TILE_LEN) of
                        true ->
                            case mod_scene_player_manager:get_all_obj_scene_player_id() of
                                [] ->
                                    %% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 睡眠
                                    ?GO_SLEEP(ObjMonster, State);
                                _ ->
                                    if
                                        IsMission orelse IsBoss orelse OwnerObjType > 0 ->
                                            noop;
                                        true ->
                                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 2000)
                                    end,
                                    if
                                        MonsterType =/= ?MT_WOOD ->
                                            auto_move(ObjMonster, State);
                                        true ->
                                            ObjMonster
                                    end
                            end;
                        false ->
                            %% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 回退
                            ?GO_BACK(ObjMonster, State)
                    end
            end;
        %% 有追踪对象
        true ->
            handle_monster_run(ObjMonster, ?MOVE_TYPE_MOMENT),
            ?GO_TRACK(ObjMonster, State)
    end;
%% 追踪
do_heart_beat(
    ObjMonster_0 = #obj_scene_actor{status = ?MONSTER_STATUS_TRACK},
    #scene_state{
        map_id = MapId
    } = State
) ->
    #obj_scene_actor{
        track_info = OldTrackInfo,
        base_id = MonsterId
    } = ObjMonster_0,
    ObjMonster_1 = search_attack_target(ObjMonster_0, State),
    #obj_scene_actor{
        track_info = NewTrackInfo,
        move_path = MovePath,
        x = X,
        y = Y,
        is_boss = IsBoss
    } = ObjMonster_1,
    {_PatrolRange, TrackRange, WarnRange} = get_monster_ai_args(MonsterId),
    #track_info{
        x = OldTrackX,
        y = OldTrackY
    } = OldTrackInfo,
    #track_info{
        obj_type = TrackObjType,
        obj_id = TrackObjId
    } = NewTrackInfo,
%%    SkillLength = 6,
    case ?GET_OBJ_SCENE_ACTOR(TrackObjType, TrackObjId) of
        ?UNDEFINED ->%%敌方不在场景
            ?GO_BACK(ObjMonster_1, State);
        R ->%%敌方在场景
            #obj_scene_actor{
                hp = TrackHp,
                x = TargetX,
                y = TargetY,
                join_monster_point = JoinMonsterPoint
            } = R,
            if
                TrackHp > 0 ->%%敌方活着
                    if
                        TrackRange == 0 ->
                            %% 非追踪
                            Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
                            if
                                Distance =< WarnRange * ?TILE_LEN ->%%在警戒范围
                                    %% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 攻击
                                    ?GO_ATTACK(ObjMonster_1, State);
                                true ->%%不在攻击范围
                                    %% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 巡逻
                                    ?GO_PATROL(ObjMonster_1, State)
                            end;
                        true ->
                            %% 追踪敌方
%%                            FromBirthDistance = util_math:get_distance({SrcX, SrcY}, {TargetX, TargetY}),
                            %% @todo 从出生地变成目前的坐标，是否合理另外说
                            FromBirthDistance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
                            RealTrackRange =
                                if JoinMonsterPoint == MonsterId ->
                                    TrackRange * 1.5;
                                    true ->
                                        TrackRange
                                end,
%%                            ?DEBUG("~p 正在追踪: ~p", [{ObjMonster_1#obj_scene_actor.obj_id, MonsterId},
%%                                {FromBirthDistance, TrackRange * ?TILE_LEN, WarnRange * ?TILE_LEN}]),
                            if
                                FromBirthDistance < RealTrackRange * ?TILE_LEN ->%%敌方在追踪范围
%%                                    Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
                                    Distance = FromBirthDistance,
                                    Now = get(?DICT_NOW_MS),
                                    {Skill, _} = update_skill_info(ObjMonster_1, Now),
                                    case Skill of
                                        null ->
                                            ObjMonster_1;
                                        _ ->
                                            #r_active_skill{
                                                id = SkillId
                                            } = Skill,
                                            #t_active_skill{
                                                attack_length = SkillLength
                                            } = mod_active_skill:get_t_active_skill(SkillId),
                                            if
%%                                        MovePath == [] andalso Distance =< SkillLength * ?TILE_LEN ->%%在攻击范围
                                                Distance =< SkillLength * ?TILE_LEN ->%%在攻击范围
                                                    ?GO_ATTACK(ObjMonster_1, State);
                                                true ->%%不在攻击范围
                                                    TrackMoveDis = util_math:get_distance({OldTrackX, OldTrackY}, {TargetX, TargetY}),
                                                    TolerateTrackMoveDis =
                                                        if
                                                            Distance >= 3000 ->
                                                                1500;
                                                            Distance >= 2000 ->
                                                                1000;
                                                            Distance >= 1000 ->
                                                                300;
                                                            true ->
                                                                200
                                                        end,
                                                    if
                                                        (TrackMoveDis > TolerateTrackMoveDis orelse MovePath == []) ->
                                                            ObjMonster_2 = ObjMonster_1#obj_scene_actor{
                                                                %% 记录当前目标位置
                                                                track_info = NewTrackInfo#track_info{x = TargetX, y = TargetY}
                                                            },
                                                            DiffPix = max(trunc(min((SkillLength - 1) * ?TILE_LEN, Distance)), ?TILE_LEN),
                                                            if IsBoss ->
                                                                find_path(ObjMonster_2, {TargetX, TargetY}, DiffPix, State);
                                                                true ->
%%                                                                    handle_monster_run(ObjMonster_2, ?MOVE_TYPE_NORMAL),
                                                                    {TargetPixX, TargetPixY} = util_math:get_random_target_pix_pos(MapId, {X, Y}, {TargetX, TargetY}, DiffPix, DiffPix),
                                                                    find_path(ObjMonster_2, {TargetPixX, TargetPixY}, State)
                                                            end;
                                                        true ->
                                                            %% =============================
                                                            ObjMonster_1
                                                    end
                                            end
                                    end;
                                true ->%%敌方不在追踪范围
                                    ?GO_BACK(ObjMonster_1, State)
                            end
                    end;
                true ->%%敌方死亡
                    %% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                    ?GO_BACK(ObjMonster_1, State)
            end
    end;
%% 攻击
do_heart_beat(
    ObjMonster = #obj_scene_actor{status = ?MONSTER_STATUS_ATTACK},
    #scene_state{} = State
) ->
    ObjMonster_0 = search_attack_target(ObjMonster, State),
    #obj_scene_actor{
        track_info = #track_info{
            obj_id = TrackObjId,
            obj_type = TrackObjType
        }
    } = ObjMonster_0,
    case ?GET_OBJ_SCENE_ACTOR(TrackObjType, TrackObjId) of
        ?UNDEFINED ->
            ?GO_BACK(ObjMonster_0, State);
        TargetObjSceneActor ->
            #obj_scene_actor{
                hp = TrackHp
            } = TargetObjSceneActor,
            if
                TrackHp > 0 ->
                    ObjMonsterAfterAttack = handle_attack_target(ObjMonster_0, TargetObjSceneActor, State),
                    handle_monster_runaway(ObjMonsterAfterAttack, State);
                true ->
                    ?GO_BACK(ObjMonster_0, State)
            end
    end;
%% 回退
do_heart_beat(
    ObjMonster_0 = #obj_scene_actor{status = ?MONSTER_STATUS_BACK, hate_list = HateList},
    #scene_state{
        scene_id = _SceneId,
        map_id = _MapId
    } = State
) ->
    ObjMonster_1 =
        if
            HateList == [] ->
                ObjMonster_0;
            true ->
                search_attack_target(ObjMonster_0, State)
        end,
    #obj_scene_actor{
        obj_type = _ObjType,
        base_id = _MonsterId,
        x = X,
        y = Y,
        birth_x = SrcX,
        birth_y = SrcY,
        move_path = MovePath,
        track_info = #track_info{obj_id = TrackObjId}
    } = ObjMonster_1,
    if TrackObjId == 0 ->
        case util_math:is_in_range({X, Y}, {SrcX, SrcY}, ?TILE_LEN * 3) of
            true ->
                ?GO_PATROL(ObjMonster_1, State);
            false ->
                if
                    MovePath == [] ->
                        find_path(ObjMonster_1, {SrcX, SrcY}, State);
                    true ->
                        ObjMonster_1
                end
        end;
        true ->
            ?GO_TRACK(ObjMonster_1, State)
    end;
%% 前往目的地
do_heart_beat(
    ObjMonster = #obj_scene_actor{status = ?MONSTER_STATUS_TARGET_PLACE},
    #scene_state{} = State
) ->
    #obj_scene_actor{
        x = X,
        y = Y,
        move_path = MovePath,
        go_target_place = #go_target_place{x = Gox, y = GoY, function = Fun}
    } = ObjMonster,
    case util_math:is_in_range({X, Y}, {Gox, GoY}, ?TILE_LEN * 3) of
        true ->
            %% 到达目的地
            if Fun =/= null ->
                Fun(),
                ObjMonster#obj_scene_actor{
                    go_target_place = #go_target_place{
                        function = null
                    }
                };
                true ->
                    ObjMonster
            end;
        false ->
            if
                MovePath == [] ->
                    find_path(ObjMonster, {Gox, GoY}, State);
                true ->
                    ObjMonster
            end
    end.

update_skill_info(ObjMonster, Now) ->
    #obj_scene_actor{
        r_active_skill_list = RActiveSkillList,
        can_use_skill_time = CanUseSkillTime
    } = ObjMonster,
    SortActiveSkillList = lists:keysort(#r_active_skill.last_time_ms, RActiveSkillList),
    Skill =
        lists:foldl(
            fun(CActiveSkill, TmpSkill) ->
                ?IF(CActiveSkill =:= null, ?ERROR("怪物心跳主动技能为空打印 ~p~n,怪物信息 ~p~n,主动技能列表 ~p~n", [get(?DICT_SCENE_ID), ObjMonster, RActiveSkillList]), noop),
                #r_active_skill{
                    id = ThisSkillId,
                    last_time_ms = LastTime,
                    is_common_skill = IsCommonSkill
                } = CActiveSkill,
                #t_active_skill{
                    cd_time = CdTime,
                    skill_trigger_probability_for_attack = P
                } = mod_active_skill:get_t_active_skill(ThisSkillId),

                if
                    IsCommonSkill == false andalso (Now >= LastTime + CdTime) andalso Now >= CanUseSkillTime ->
                        if
                            TmpSkill == null ->
                                CActiveSkill;
                            true ->
                                #r_active_skill{
                                    is_common_skill = TmpIsCommonSkill
                                } = TmpSkill,
                                if
                                    TmpIsCommonSkill -> CActiveSkill;
                                    true -> TmpSkill
                                end
                        end;
                    TmpSkill == null andalso (Now >= LastTime + CdTime) andalso (IsCommonSkill == true orelse Now >= CanUseSkillTime) ->
                        if P == 0 ->
                            CActiveSkill;
                            true ->
                                case util_random:p(P) of
                                    true ->
                                        CActiveSkill;
                                    false ->
                                        TmpSkill
                                end
                        end;
                    true ->
                        TmpSkill
                end
            end,
            null,
            SortActiveSkillList
        ),
    {Skill, ObjMonster}.

%% 处理攻击对象
handle_attack_target(ObjMonster, TargetObjSceneActor, #scene_state{scene_type = SceneType} = State) ->
    Now = get(?DICT_NOW_MS),
    #obj_scene_actor{
        obj_id = ObjMonsterId,
        track_info = #track_info{obj_id = TrackObjId, obj_type = TrackObjType},
        x = X,
        y = Y,
        is_boss = IsBoss,
        owner_obj_id = OwnerObjId,
        cost = Cost,
        wait_skill_info = WaitSkillInfo
    } = ObjMonster,
    #obj_scene_actor{
        x = TargetX,
        y = TargetY,
        is_all_sync = IsAllSync,
        grid_id = GridId
    } = TargetObjSceneActor,
    if
        WaitSkillInfo == ?UNDEFINED ->
            {Skill, ObjMonster_1} = update_skill_info(ObjMonster, Now),
            if
                Skill == null ->
                    auto_move(ObjMonster_1, State);
                true ->
                    #r_active_skill{
                        id = SkillId,
                        force_wait_time = ForceWaitTime
                    } = Skill,
                    #t_active_skill{
                        attack_length = AttackLength,
                        charge_time = ChargeTime
                    } = mod_active_skill:get_t_active_skill(SkillId),
                    RealAttackLength = AttackLength * ?TILE_LEN,
                    IsWaitSkill = ChargeTime > 0,
                    Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
                    if
                        Distance =< RealAttackLength ->
                            Dir = util_math:get_direction({X, Y}, {TargetX, TargetY}),
                            SkillPointList = get_skill_point_list(SkillId, X, Y, RealAttackLength, State),
                            RequestFightParam =
                                #request_fight_param{
                                    attack_type = ?OBJ_TYPE_MONSTER,
                                    obj_type = ?OBJ_TYPE_MONSTER,
                                    obj_id = ObjMonsterId,
                                    skill_id = SkillId,
                                    dir = Dir,
                                    target_type = TrackObjType,
                                    target_id = TrackObjId,
                                    cost = Cost,
                                    skill_point_list = SkillPointList
                                },
                            if
                                IsWaitSkill ->  %% 蓄力技能
                                    NoticePlayerIds = ?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)),
                                    api_fight:notice_fight_wait_skill(NoticePlayerIds, ?OBJ_TYPE_MONSTER, ObjMonsterId, SkillId, Dir, Now + ChargeTime, SkillPointList),
                                    erlang:send_after(ChargeTime + 100, self(), scene_wait_skill:pack_msg({?MSG_SCENE_USE_WAIT_SKILL, RequestFightParam, Now + ChargeTime}));
                                true ->
                                    #t_monster{type = MonsterType} = get_t_monster(ObjMonster_1#obj_scene_actor.base_id),
                                    ?IF(MonsterType == ?MONSTER_ACTIVE_ATTACK_MONSTER,
                                        handle_target_filter(ObjMonster, [TargetObjSceneActor], ?TRUE), noop),
                                    self() ! {?MSG_FIGHT, RequestFightParam}
                            end,
                            if
                                IsWaitSkill ->
                                    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, ChargeTime + ForceWaitTime + 100);
                                IsBoss orelse OwnerObjId > 0 ->
                                    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, ForceWaitTime + 100);
                                true ->
                                    if
                                        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
                                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, ForceWaitTime + 100);
                                        true ->
                                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, ForceWaitTime + 100)
                                    end
                            end,
                            ObjMonster_2 =
                                if
                                    IsWaitSkill ->
                                        ObjMonster_1#obj_scene_actor{
                                            wait_skill_info = #wait_skill{
                                                skill_id = SkillId,
                                                dir = Dir,
                                                end_time = Now + ChargeTime
                                            }
                                        };
                                    true ->
                                        ObjMonster_1
                                end,
                            if ObjMonster_2#obj_scene_actor.move_path =/= [] ->
                                stop_move(ObjMonster_2, State);
                                true ->
                                    ObjMonster_2
                            end;
                        true ->
%%                            handle_monster_run(ObjMonster_1, ?MOVE_TYPE_NORMAL),
                            ?GO_TRACK(ObjMonster_1, State)
                    end
            end;
        true ->
            ObjMonster
    end.

%% ----------------------------------
%% @doc 	更新仇恨列表
%% @throws 	none
%% @end
%% ----------------------------------
update_hate_list(HateList, AttObjType, AttObjId, Hurt) ->
%%    ?DEBUG("--- HateList ~p, AttObjType ~p, AttObjId ~p, Hurt ~p", [HateList, AttObjType, AttObjId, Hurt]),
    case lists:keytake({AttObjType, AttObjId}, 1, HateList) of
        {value, {{AttObjType, AttObjId}, Hate}, Left} ->
            [{{AttObjType, AttObjId}, Hate + Hurt} | Left];
        false ->
            [{{AttObjType, AttObjId}, Hurt} | HateList]
    end.

%% ----------------------------------
%% @doc     搜索攻击目标
%% @throws 	none
%% @end
%% ----------------------------------
search_attack_target(ObjMonster = #obj_scene_actor{effect = [?MONSTER_EFFECT_12]}, _SceneState) -> ObjMonster;
search_attack_target(ObjMonster = #obj_scene_actor{effect = [?MONSTER_EFFECT_15]}, _SceneState) -> ObjMonster;
search_attack_target(ObjMonster, _SceneState) ->
    #obj_scene_actor{
        obj_id = ObjMonsterId,
        base_type = MonsterType,
        base_id = MonsterId,
        birth_x = SrcX,
        birth_y = SrcY,
        x = X,
        y = Y,
        hate_list = HateList,
        grid_id = GridId,
        track_info = _OldTrackInfo,
        belong_player_id = BelongPlayerId,
        owner_obj_type = OwnerObjType,
        owner_obj_id = OwnerObjId,
        search_fight_target_time = LastSearchFightTargetTime
    } = ObjMonster,
    #track_info{
        obj_type = OldTrackObjType,
        obj_id = OldTrackObjId
    } = _OldTrackInfo,
    Now = get(?DICT_NOW_MS),
    IsForceSearch =
        if
            OldTrackObjId == 0 ->
                true;
            true ->
                case ?GET_OBJ_SCENE_ACTOR(OldTrackObjType, OldTrackObjId) of
                    ?UNDEFINED ->
                        true;
                    OldTrackObj ->
                        if OldTrackObj#obj_scene_actor.hp =< 0 ->
                            true;
                            true ->
                                false
                        end
                end
        end,
    if
        Now - LastSearchFightTargetTime >= 1000 orelse IsForceSearch ->
            {_PatrolRange, _TrackRange, WarnRange} = get_monster_ai_args(MonsterId),
            {HateList_0, HateObjPlayer, NewBelongPlayerId} =
                if
                    BelongPlayerId > 0 andalso OwnerObjId == 0 ->
                        BelongObjScenePlayer =
                            case ?GET_OBJ_SCENE_PLAYER(BelongPlayerId) of
                                ?UNDEFINED ->
                                    null;
                                BelongObjScenePlayer_ ->
                                    #obj_scene_actor{
                                        x = BelongerX,
                                        y = BelongerY,
                                        hp = BelongerHp
                                    } = BelongObjScenePlayer_,
                                    case util_math:is_in_range({BelongerX, BelongerY}, {X, Y}, WarnRange * ?TILE_LEN) of
                                        true ->
                                            if BelongerHp > 0 ->
                                                BelongObjScenePlayer_;
                                                true ->
                                                    null
                                            end;
                                        false ->
                                            null
                                    end
                            end,
                        if BelongObjScenePlayer == null ->
                            NoticePlayerIdList = mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
                            api_scene:api_notice_monster_attr_change(NoticePlayerIdList, ObjMonsterId, [{?P_BELONG_PLAYER_ID, 0}]),
                            {HateList_, HateObjPlayer_} = deal_hate_list(HateList, X, Y, WarnRange),
                            {HateList_, HateObjPlayer_, 0};
                            true ->
                                {HateList_, _} = deal_hate_list(HateList, SrcX, SrcY, WarnRange),
                                {HateList_, BelongObjScenePlayer, BelongPlayerId}
                        end;
                    true ->
                        {HateList_, HateObjPlayer_} = deal_hate_list(HateList, X, Y, WarnRange),
                        {HateList_, HateObjPlayer_, 0}
                end,

            {NewTrackInfo, NewHateList} =
                if
                %% 没有仇恨对象 搜索警戒范围内最近的玩家
                    HateObjPlayer == null ->
                        %% 尝试搜寻目标
                        if
                            MonsterType == ?MT_ACTIVE orelse MonsterType == ?MONSTER_ACTIVE_ATTACK_MONSTER ->
                                F =
                                    fun(#filter_target{this_obj_type = ThisObjType, this_obj_id = ThisObjId, this_own_type = ThisOwnType, this_own_id = ThisOwnId}) ->
                                        if
                                            ThisObjType == ?OBJ_TYPE_MONSTER andalso ThisObjId == ObjMonsterId ->
                                                false;
                                            OwnerObjId > 0 orelse ThisOwnId > 0 ->
                                                if
                                                    OwnerObjType == ThisObjType andalso OwnerObjId == ThisObjId ->
                                                        false;
                                                    ThisOwnType == ?OBJ_TYPE_MONSTER andalso ThisOwnId == ObjMonsterId ->
                                                        false;
                                                    ThisOwnType == OwnerObjType andalso ThisOwnId == OwnerObjId ->
                                                        false;
                                                    true ->
                                                        true
                                                end;
                                            true ->
                                                true
                                        end
                                    end,
                                TargetList =
                                    if
                                        OwnerObjId > 0 ->
                                            mod_fight_target:get_nine_grid_attack_target_list(?PIX_2_GRID_ID(X, Y), X, Y, F, WarnRange * ?TILE_LEN);
                                        true ->
                                            ?IF(
                                                WarnRange > 40,
                                                %% 获取最近的玩家
                                                mod_fight_target:get_attack_target_list([], mod_scene_player_manager:get_all_obj_scene_player_id(), X, Y, F, 0),
                                                %% 获取最近的玩家 并且在 警戒范围内
                                                mod_fight_target:get_nine_grid_attack_player_target_list(?PIX_2_GRID_ID(X, Y), X, Y, F, WarnRange * ?TILE_LEN)
                                            )
                                    end,
                                if
                                    TargetList == [] ->
                                        {#track_info{}, []};
                                    true ->
                                        TargetListAfterFilter = ?IF(MonsterType == ?MONSTER_ACTIVE_ATTACK_MONSTER,
                                            handle_target_filter(ObjMonster, TargetList), TargetList),
                                        TrackInfo_1 = pack_track_info(TargetListAfterFilter),
                                        {
                                            TrackInfo_1,
                                            [
                                                {{TrackInfo_1#track_info.obj_type, TrackInfo_1#track_info.obj_id}, 0}
                                            ]
                                        }
                                end;
                            true ->
                                {#track_info{}, HateList_0}
                        end;
                    true ->
                        {pack_track_info([HateObjPlayer]), HateList_0}
                end,
            ObjMonster#obj_scene_actor{
                hate_list = NewHateList,
                track_info = NewTrackInfo,
                belong_player_id = NewBelongPlayerId,
                search_fight_target_time = Now
            };
        true ->
            ObjMonster
    end.

pack_track_info(TargetList) ->
    if TargetList == [] ->
        #track_info{};
        true ->
            Target = hd(TargetList),
            #obj_scene_actor{
                obj_id = ObjId,
                obj_type = ObjType,
                x = _X,
                y = _Y
            } = Target,
            #track_info{
                obj_type = ObjType,
                obj_id = ObjId
            }
    end.
%% ----------------------------------
%% @doc     处理仇恨列表
%% @throws 	none
%% @end
%% ----------------------------------
deal_hate_list([], _BirthX, _BirthY, _WarnRange) ->
    {[], null};
deal_hate_list(HateList, BirthX, BirthY, WarnRange) ->
    {NewHateList, {HateObjActor, _}} =
        lists:foldl(
            fun({{HateObjType, HateObjId}, Hate}, {TmpHateList, {TmpObj, TmpHate}} = Tmp) ->
                if HateObjType == ?OBJ_TYPE_PLAYER ->
                    case ?GET_OBJ_SCENE_ACTOR(HateObjType, HateObjId) of
                        ?UNDEFINED ->
                            Tmp;
                        ObjSceneActor ->
                            #obj_scene_actor{
                                x = X,
                                y = Y,
                                hp = Hp
                            } = ObjSceneActor,
                            case util_math:is_in_range({X, Y}, {BirthX, BirthY}, WarnRange * ?TILE_LEN) of
                                true ->
                                    if Hp > 0 ->
                                        if Hate > TmpHate ->
                                            {[{{HateObjType, HateObjId}, Hate} | TmpHateList], {ObjSceneActor, Hate}};
                                            true ->
                                                {[{{HateObjType, HateObjId}, Hate} | TmpHateList], {TmpObj, TmpHate}}
                                        end;
                                        true ->
                                            Tmp
                                    end;
                                false ->
                                    Tmp
                            end
                    end;
                    true ->
                        Tmp
                end
            end,
            {[], {null, -1}},
            HateList
        ),
    {NewHateList, HateObjActor}.


%% ----------------------------------
%% @doc 	随机移动
%% @throws 	none
%% @end
%% ----------------------------------
auto_move(ObjMonster = #obj_scene_actor{effect = [?MONSTER_EFFECT_12], move_path = MovePath}, _SceneState) when MovePath /= [] -> ObjMonster;
auto_move(ObjMonster = #obj_scene_actor{effect = [?MONSTER_EFFECT_15], move_path = MovePath}, _SceneState) when MovePath /= [] -> ObjMonster;
auto_move(ObjMonster = #obj_scene_actor{move_path = OldMovePath}, SceneState) ->
    Effect = mod_scene_monster_manager:get_monster_effect(ObjMonster),
    {NewMovePath, ObjMonster_0} = handle_auto_move(Effect, ObjMonster, SceneState),
    #obj_scene_actor{
        x = X,
        y = Y,
        obj_id = ObjMonsterId,
        grid_id = GridId,
        is_all_sync = IsAllSync
    } = ObjMonster_0,
    Now = get(?DICT_NOW_MS),
    case NewMovePath of
        OldMovePath -> ObjMonster_0;
        [] -> ObjMonster_0;
        [{GoX, GoY}] when {X, Y} /= {GoX, GoY} ->
%%            ?INFO("go to ====>> ~p", [NewMovePath]),
            ObjMonster_1 = ObjMonster_0#obj_scene_actor{move_path = NewMovePath, last_move_time = Now},
            api_scene:notice_monster_move(?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)), ObjMonsterId, [{GoX, GoY}]),
            ObjMonster_1;
        _ ->
            ObjMonster_0
    end.

%% 处理金币小妖移动
handle_auto_move(?MONSTER_EFFECT_15, ObjMonster, SceneState) ->
    #obj_scene_actor{
        type_action_list = [ActionList1, ActionList2]
    } = ObjMonster,

    ActionList = ?IF(ActionList1 == [], ActionList2, ActionList1),
    [[GoX, GoY] | RestActionList1] = ActionList,

    ObjMonster_0 = ObjMonster#obj_scene_actor{type_action_list = [RestActionList1, ActionList2]},
    {[], find_path(ObjMonster_0, {GoX, GoY}, SceneState)};
%% 处理炸弹怪移动
handle_auto_move(?MONSTER_EFFECT_12, ObjMonster, SceneState) ->
    #obj_scene_actor{
        obj_id = MonsterId,
        base_id = BaseMonsterId,
        x = X,
        y = Y,
        birth_x = SrcX,
        birth_y = SrcY,
        move_speed = MoveSpeed
    } = ObjMonster,
    NowMs = get(?DICT_NOW_MS),

    OldMonsterBombRec = scene_worker:dict_get_monster_bomb(MonsterId),
    #r_monster_bomb{
        base_x = BaseX,
        base_y = BaseY,
        wild_end_time = EndTime
    } = OldMonsterBombRec,
    {PatrolRange, _TrackRange, _WarnRange} = get_monster_ai_args(BaseMonsterId),

    {SrcPos, Range, P, AddTile, Retries} =
        case EndTime >= NowMs of
            true -> {{BaseX, BaseY}, 12, 10000, util_random:random_number(4, 8), 3};
            false -> {{SrcX, SrcY}, PatrolRange, 3000, util_random:random_number(8, 12), 1}
        end,

    NewMovePath = get_move_path(MoveSpeed, P, AddTile, {X, Y}, SrcPos, Range, SceneState, Retries),
    {NewMovePath, ObjMonster};
%% 处理其它怪移动
handle_auto_move(_Effect, ObjMonster, SceneState) ->
    #obj_scene_actor{
        base_id = BaseMonsterId,
        x = X,
        y = Y,
        birth_x = SrcX,
        birth_y = SrcY,
        move_speed = MoveSpeed
    } = ObjMonster,
    {PatrolRange, _TrackRange, _WarnRange} = get_monster_ai_args(BaseMonsterId),
    AddTile = util_random:random_number(PatrolRange - 4, PatrolRange),
    NewMovePath = get_move_path(MoveSpeed, 6000, AddTile, {X, Y}, {SrcX, SrcY}, PatrolRange, SceneState, 1),
    {NewMovePath, ObjMonster}.

get_move_path(MoveSpeed, _P, _Add, _Pos, _SrcPos, _Range, _SceneState, Retries) when MoveSpeed =< 0; Retries =< 0 -> [];
get_move_path(MoveSpeed, P, Add, {X, Y}, {SrcX, SrcY}, Range, SceneState, Retries) ->
    #scene_state{map_id = MapId} = SceneState,
    case util_random:p(P) of
        true ->
            {TileX, TileY} = ?PIX_2_TILE(X, Y),
            Case = util_random:random_number(80) rem 9,

            {GoTileX, GoTileY} =
                if Case == 0 ->
                    {TileX - Add, TileY - Add};
                    Case == 1 ->
                        {TileX - Add, TileY};
                    Case == 2 ->
                        {TileX - Add, TileY + Add};
                    Case == 3 ->
                        {TileX, TileY - Add};
                    Case == 4 ->
                        {TileX, TileY - Add};
                    Case == 5 ->
                        {TileX, TileY + Add};
                    Case == 6 ->
                        {TileX + Add, TileY - Add};
                    Case == 7 ->
                        {TileX + Add, TileY};
                    Case == 8 ->
                        {TileX + Add, TileY + Add}
                end,
            {GoX, GoY} = ?TILE_2_PIX(GoTileX, GoTileY),
            if
                X =/= GoX orelse Y =/= GoY ->
                    case mod_map:can_walk({MapId, {GoTileX, GoTileY}}) andalso
                        navigate:check_line(MapId, {TileX, TileY}, {GoTileX, GoTileY}) andalso
                        util_math:is_in_range({GoTileX, GoTileY}, ?PIX_2_TILE(SrcX, SrcY), Range) of
                        false ->
                            get_move_path(MoveSpeed, P, Add, {X, Y}, {SrcX, SrcY}, Range, SceneState, Retries - 1);
                        true ->
                            [{GoX, GoY}]
                    end;
                true ->
                    []
            end;
        false ->
            []
    end.

find_path(ObjMonster, {TargetX, TargetY}, State) ->
    find_path(ObjMonster, {TargetX, TargetY}, 0, State).

find_path(ObjMonster, {TargetX, TargetY}, Diff, #scene_state{is_mission = IsMission, map_id = _MapId, scene_navigate_worker = NavigateWorker}) ->
    #obj_scene_actor{
        obj_id = ObjMonsterId,
        x = X,
        y = Y,
        status = _Status,
        is_boss = IsBoss,
        track_info = _TrackInfo,
        owner_obj_type = OwnerObjType
    } = ObjMonster,
    IsFloyd = IsBoss == true,
    MaxNavigateNode =
        if IsBoss ->
            1000;
            IsMission ->
                100;
            OwnerObjType > 0 ->
                500;
            true ->
                40
        end,
    IsCanJump = false,
%%        if OwnerObjType > 0 ->
%%            true;
%%            true ->
%%                get(?DICT_MONSTER_IS_CAN_JUMP)
%%        end,
%%    ?DEBUG("怪物寻路：~p", [ObjMonster#obj_scene_actor.obj_id]),
    scene_navigate_worker:request_navigate(NavigateWorker, ?OBJ_TYPE_MONSTER, ObjMonsterId, {X, Y}, {TargetX, TargetY}, IsFloyd, IsCanJump, MaxNavigateNode, Diff),
    ObjMonster#obj_scene_actor{
        is_wait_navigate = true
    }.

%% ----------------------------------
%% @doc 	获取场景怪物对象
%% @throws 	none
%% @end
%% ----------------------------------
get_obj_scene_monster(ObjMonsterId) ->
    ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, ObjMonsterId).


add_obj_scene_monster(ObjSceneMonster) ->
    mod_scene_actor:add_obj_scene_actor(ObjSceneMonster).


%% ----------------------------------
%% @doc 	怪物死亡
%% @throws 	none
%% @end
%% ----------------------------------
handle_death(ObjSceneMonster, AttObjSceneActor) ->
    #obj_scene_actor{
        obj_id = ObjId,
        base_id = MonsterId,
        birth_x = BirthX,
        birth_y = BirthY,
        x = X,
        y = Y,
        rebirth_time = RebirthTime,
        create_time = CreateTime,
        belong_player_id = BelongPlayerId,
        owner_obj_id = OwnerObjId,
        hurt_list = HurtList,
        group = Group,
        is_boss = IsBoss
    } = ObjSceneMonster,
    #obj_scene_actor{
        obj_type = AttObjType,
        obj_id = AttObjId,
        nickname = AttObjNickName,
        client_worker = ClientWorker,
        x = AttX,
        y = AttY
    } = AttObjSceneActor,

    IsHookScene = get(?DICT_IS_HOOK_SCENE),
    SceneType = get(?DICT_SCENE_TYPE),
    do_destroy_monster(ObjSceneMonster, death),

    if
        OwnerObjId == 0 ->
            if
                AttObjType =:= ?OBJ_TYPE_PLAYER andalso OwnerObjId =:= 0 ->
                    case get(?DICT_IS_FIGHT) of
                        true ->
                            mod_fight:update_kill_monster_list(MonsterId);
                        _ ->
                            client_worker:send_msg(ClientWorker, {?MSG_CLIENT_KILL_MONSTER, get(?DICT_SCENE_ID), MonsterId, 1})
                    end;
                true ->
                    noop
            end,
            case SceneType of
                ?SCENE_TYPE_MISSION ->
                    %% 副本
                    mission_handle:handle_monster_death(ObjId, MonsterId, AttObjType, AttObjId, BelongPlayerId, CreateTime, RebirthTime, X, Y, BirthX, BirthY, HurtList, AttObjNickName);
                ?SCENE_TYPE_WORLD_SCENE ->
                    if
                        IsHookScene ->
                            if
                                IsBoss ->
                                    api_scene:notice_boss_die(mod_scene_player_manager:get_all_obj_scene_player_id(), MonsterId, AttObjId);
                                true ->
                                    noop
                            end,
                            case mod_scene_event_manager:get_scene_event_value() of
                                {true, {15, MonsterId, CloseTime}} ->
                                    mod_scene_event_manager:set_scene_event_value({0, false, {15, MonsterId, CloseTime}}),
                                    api_scene:notice_scene_jbxy_state(mod_scene_player_manager:get_all_obj_scene_player_id(), false, MonsterId, ?UNDEFINED, AttObjId);
                                _ ->
                                    noop
                            end,
                            mod_scene_event_manager:send_msg({?MSG_SCENE_LOOP_MONSTER_DEATH_FIGHT, MonsterId, Group, AttX, AttY});
                        true ->
                            if RebirthTime >= 0 ->
                                erlang:send_after(RebirthTime, self(), {?MSG_SCENE_CREATE_MONSTER, MonsterId, BirthX, BirthY});
                                true ->
                                    noop
                            end
                    end;
                ?SCENE_TYPE_MATCH_SCENE ->
                    if
                        IsBoss ->
                            api_scene:notice_boss_die(mod_scene_player_manager:get_all_obj_scene_player_id(), MonsterId, AttObjId);
                        true ->
                            noop
                    end,
                    case mod_scene_event_manager:get_scene_event_value() of
                        {true, {15, MonsterId, CloseTime}} ->
                            mod_scene_event_manager:set_scene_event_value({0, false, {15, MonsterId, CloseTime}}),
                            api_scene:notice_scene_jbxy_state(mod_scene_player_manager:get_all_obj_scene_player_id(), false, MonsterId, ?UNDEFINED, AttObjId);
                        _ ->
                            noop
                    end,
                    mod_scene_event_manager:send_msg({?MSG_SCENE_LOOP_MONSTER_DEATH_FIGHT, MonsterId, Group, AttX, AttY})
            end;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	销毁所有怪物
%% @throws 	none
%% @end
%% ----------------------------------
destroy_all_monster() -> destroy_all_monster(force).
destroy_all_monster(Type) ->
    lists:foreach(
        fun(ObjSceneMonsterId) ->
            do_destroy_monster(ObjSceneMonsterId, Type)
        end,
        get_all_obj_scene_monster_id()
    ).

async_destroy_monster(ObjSceneMonsterId, Type) ->
    async_destroy_monster(ObjSceneMonsterId, Type, 0).
async_destroy_monster(ObjSceneMonsterId, Type, Delay) ->
    if Delay == 0 ->
        self() ! {?MSG_SCENE_DESTROY_MONSTER, ObjSceneMonsterId, Type};
        true ->
            erlang:send_after(Delay, self(), {?MSG_SCENE_DESTROY_MONSTER, ObjSceneMonsterId, Type})
    end.

destroy_monster_by_monster_id(MonsterId) ->
    lists:foreach(
        fun(ObjSceneMonsterId) ->
            case ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId) of
                ?UNDEFINED ->
                    noop;
                ObjSceneMonster ->
                    if ObjSceneMonster#obj_scene_actor.base_id == MonsterId ->
                        do_destroy_monster(ObjSceneMonsterId, force);
                        true ->
                            noop
                    end
            end
        end,
        get_all_obj_scene_monster_id()
    ).

%% ----------------------------------
%% @doc     销毁怪物
%% @throws 	none
%% @end
%% ----------------------------------
do_destroy_monster(ObjSceneMonsterId, Type) when is_integer(ObjSceneMonsterId) ->
    case ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId) of
        ?UNDEFINED ->
            noop;
        ObjSceneMonster ->
            do_destroy_monster(ObjSceneMonster, Type)
    end;
do_destroy_monster(ObjSceneMonster, Type0) ->
    Type = ?IF(Type0 =:= yuchao, force, Type0),
    Now = util_time:milli_timestamp(),
    #obj_scene_actor{
        obj_id = ObjSceneMonsterId,
        base_id = BaseId,
        owner_obj_id = OwnerObjId,
        destroy_time_ms = DestroyTimeMs,
        hp = Hp,
        effect = EffectList,
        group = Group
    } = ObjSceneMonster,
    %% 删除模块字典
    scene_worker:delete_monster_mod_dict(ObjSceneMonsterId),
    if
%%        EffectList == [15] andalso Type0 == yuchao ->
%%            noop;
        DestroyTimeMs > Now + 50 andalso Hp > 0 andalso Type0 =/= yuchao ->
            erlang:send_after(DestroyTimeMs - Now, self(), {?MSG_SCENE_DESTROY_MONSTER, ObjSceneMonsterId, Type});
        true ->
            if OwnerObjId > 0 ->
                erase({is_call_monster, OwnerObjId, BaseId});
                true ->
                    noop
            end,
            mod_scene_actor:delete_obj_scene_actor(?OBJ_TYPE_MONSTER, ObjSceneMonster#obj_scene_actor.obj_id),
            mod_scene_grid_manager:handle_monster_leave_grid(ObjSceneMonster, Type),
            SceneType = get(?DICT_SCENE_TYPE),
            case SceneType of
                ?SCENE_TYPE_MISSION ->
                    case get(?DICT_MISSION_TYPE) of
                        ?MISSION_TYPE_GUESS_BOSS ->
                            noop;
                        ?MISSION_TYPE_SHISHI_BOSS ->
                            noop;
                        ?MISSION_TYPE_MISSION_EITHER_OR ->
                            noop;
                        ?MISSION_TYPE_MISSION_HERO_PK_BOSS ->
                            noop;
                        _ ->
                            if OwnerObjId == 0 ->
                                case get_live_monster_num() of
                                    0 ->
                                        self() ! ?MSG_SCENE_MISSION_ROUND_END;
                                    _ ->
                                        noop
                                end;
                                true ->
                                    noop
                            end
                    end;
                ?SCENE_TYPE_WORLD_SCENE ->
                    if
                        Type == death ->
                            noop;
                        Type0 == yuchao ->
                            noop;
                        true ->
                            IsHookScene = get(?DICT_IS_HOOK_SCENE),
                            if
                                IsHookScene ->
                                    case mod_scene_event_manager:get_scene_event_value() of
                                        {true, {15, MonsterId, CloseTime}} ->
                                            mod_scene_event_manager:set_scene_event_value({false, {15, MonsterId, CloseTime}}),
                                            api_scene:notice_scene_jbxy_state(mod_scene_player_manager:get_all_obj_scene_player_id(), false, MonsterId, ?UNDEFINED, ?UNDEFINED);
                                        _ ->
                                            noop
                                    end,
                                    mod_scene_event_manager:send_msg({?MSG_SCENE_LOOP_MONSTER_DEATH, BaseId, Group});
                                true ->
                                    noop
                            end
                    end;
                ?SCENE_TYPE_MATCH_SCENE ->
                    if
                        Type == death ->
                            noop;
                        Type0 == yuchao ->
                            noop;
                        true ->
                            case mod_scene_event_manager:get_scene_event_value() of
                                {true, {15, MonsterId, CloseTime}} ->
                                    mod_scene_event_manager:set_scene_event_value({false, {15, MonsterId, CloseTime}}),
                                    api_scene:notice_scene_jbxy_state(mod_scene_player_manager:get_all_obj_scene_player_id(), false, MonsterId, ?UNDEFINED, ?UNDEFINED);
                                _ ->
                                    noop
                            end,
                            mod_scene_event_manager:send_msg({?MSG_SCENE_LOOP_MONSTER_DEATH, BaseId, Group})
                    end
            end
    end.

%% ----------------------------------
%% @doc 	获取场景怪物唯一id
%% @throws 	none
%% @end
%% ----------------------------------
get_unique_id() ->
    [Min, Max] = ?RANDOM_OBJ_MONSTER_ID_RANGE,
    UniqueId =
        case get(?DICT_OBJ_MONSTER_ID) of
            ?UNDEFINED ->
                Min;
            ObjMonsterId_ ->
                ObjMonsterId_
        end,
    if
        UniqueId >= Max ->
            put(?DICT_OBJ_MONSTER_ID, Min);
        true ->
            put(?DICT_OBJ_MONSTER_ID, UniqueId + 1)
    end,
    UniqueId.

get_monster_name(MonsterId) ->
    #t_monster{
        name = Name
    } = get_t_monster(MonsterId),
    Name.

get_t_monster(MonsterId) ->
    t_monster:get({MonsterId}).

get_t_monster_kind(KindId) ->
    t_monster_kind:get({KindId}).

%% ----------------------------------
%% @doc 	删除归属关联
%% @throws 	none
%% @end
%% ----------------------------------
unlink_belong(PlayerId) ->
    kill_belonger(PlayerId, 0).

%% ----------------------------------
%% @doc 	杀死归属玩家
%% @throws 	none
%% @end
%% ----------------------------------
kill_belonger(BelongerPlayerId, AttackerPlayerId) ->
    case erase({?DICT_SCENE_BELONG_LINK, BelongerPlayerId}) of
        ?UNDEFINED ->
            noop;
        ObjSceneMonsterId ->
            ?DEBUG("修改归属关联:~p", [{BelongerPlayerId, AttackerPlayerId, ObjSceneMonsterId}]),
            case ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId) of
                ?UNDEFINED ->
                    noop;
                ObjSceneMonster ->
                    NoticePlayerIdList = mod_scene_grid_manager:get_subscribe_player_id_list(ObjSceneMonster#obj_scene_actor.grid_id),
                    api_scene:api_notice_monster_attr_change(NoticePlayerIdList, ObjSceneMonsterId, [{?P_BELONG_PLAYER_ID, AttackerPlayerId}]),
                    ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneMonster#obj_scene_actor{
                        belong_player_id = AttackerPlayerId
                    })
            end
    end.

handle_create_monster_2(MonsterId, BirthX, BirthY, TimerRef, State) ->
    case erase({?DICT_SCENE_MONSTER_REBIRTH_REF, MonsterId}) of
        {TimerRef, BirthX, BirthY} ->
            ?INFO("boss自动复活成功:~p", [{self(), get(?DICT_SCENE_ID), MonsterId}]),
            mod_scene_monster_manager:create_monster(MonsterId, BirthX, BirthY, State);
        _ ->
            ?WARNING("怪物复活定时器不匹配:~p", [{self(), get(?DICT_MISSION_TYPE), get(?DICT_MISSION_ID), MonsterId}])
    end.

start_timer_2_create_monster(RebirthTime, MonsterId, BirthX, BirthY) ->
    case erase({?DICT_SCENE_MONSTER_REBIRTH_REF, MonsterId}) of
        ?UNDEFINED ->
            noop;
        {OldTimerRef, _, _} ->
            ?WARNING("start_timer_2_create_monster:~p~n", [{RebirthTime, MonsterId, BirthX, BirthY}]),
            erlang:cancel_timer(OldTimerRef)
    end,
    ?INFO("启动怪物定时器:~p", [{self(), RebirthTime, MonsterId, BirthX, BirthY}]),
    TimerRef = erlang:start_timer(RebirthTime, self(), {?MSG_SCENE_CREATE_MONSTER_2, MonsterId, BirthX, BirthY}),
    put({?DICT_SCENE_MONSTER_REBIRTH_REF, MonsterId}, {TimerRef, BirthX, BirthY}).

%% ----------------------------------
%% @doc 	主动复活怪物
%% @throws 	none
%% @end
%% ----------------------------------
handle_rebirth_monster(MonsterId, State) ->
    L = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
    lists:foreach(
        fun(ObjSceneMonsterId) ->
            ObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(ObjSceneMonsterId),
            if ObjSceneMonster#obj_scene_actor.base_id == MonsterId ->
                exit(already_live);
                true ->
                    noop
            end
        end,
        L
    ),
    {TimerRef, BirthX, BirthY} = erase({?DICT_SCENE_MONSTER_REBIRTH_REF, MonsterId}),
    ?ASSERT(TimerRef =/= ?UNDEFINED),
    erlang:cancel_timer(TimerRef),
    ?INFO("boss复活成功:~p", [{self(), get(?DICT_SCENE_ID), MonsterId}]),
    mod_scene_monster_manager:create_monster(MonsterId, BirthX, BirthY, State).


get_monster_ai_args(MonsterId) ->
    %%{patrol_range, track_range, warn_range}
    logic_get_monster_ai_args:get(MonsterId).

%% ========================================= 怪物回血(血条模式) start ==================================================

%% @doc 恢复所有怪物血量
handle_recover_all_monster_hp() ->
    ScenePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
    NewSceneRecoverHpMonsterIdList = lists:foldl(
        fun(MonsterObjId, TmpList) ->
            MonsterObj = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
            #obj_scene_actor{
                last_attacked_time_ms = LastAttackedTimeMs,
                hp = Hp,
                max_hp = MaxHp,
                player_hp_hurt_list = PlayerHpHurtList,
                x = X,
                y = Y
%%                is_all_sync = IsAllSync,
%%                grid_id = GridId
            } = MonsterObj,
            if
                PlayerHpHurtList == [] ->
                    TmpList;
                true ->
                    Now = util_time:milli_timestamp(),
                    {AddHp, NewPlayerHpHurtList} =
                        lists:foldl(
                            fun({AttObjId, Cost, Time}, {TmpCost, TmpL}) ->
                                if
                                    Now > Time + ?SD_HP_MODE_DELETE_TIME ->
                                        case ?GET_OBJ_SCENE_PLAYER(AttObjId) of
                                            ?UNDEFINED ->
                                                {TmpCost + Cost, TmpL};
                                            PlayerObj ->
                                                #obj_scene_actor{
                                                    x = PlayerX,
                                                    y = PLayerY
                                                } = PlayerObj,
                                                IsInRange = util_math:is_in_range({X, Y}, {PlayerX, PLayerY}, ?TILE_LEN * ?SD_HP_MODE_DELETE_RANGE),
                                                if
                                                    IsInRange ->
                                                        {TmpCost, [{AttObjId, Cost, Time} | TmpL]};
                                                    true ->
                                                        {TmpCost + Cost, TmpL}
                                                end
                                        end;
                                    true ->
                                        {TmpCost, [{AttObjId, Cost, Time} | TmpL]}
                                end
                            end,
                            {0, []}, PlayerHpHurtList
                        ),
                    NewHp = min(Hp + AddHp, MaxHp),
                    NewTmpList =
                        if
                            NewHp < MaxHp andalso Now > LastAttackedTimeMs + ?SD_HP_MODE_HP_RECOVER_TIME ->
%%                                NewHp2 = min(ceil(MaxHp * ?SD_HP_MODE_HP_RECOVER_PER / 10000) + NewHp, MaxHp),
%%                                ?DEBUG("慢慢回血 ~p", [{MaxHp, NewHp, NewHp2, NewHp2 - NewHp}]),
                                ?IF(NewHp == MaxHp, TmpList, [MonsterObjId | TmpList]);
                            true ->
                                TmpList
                        end,
                    if
                        NewHp > Hp ->
                            %% 暂时全场景同步
                            api_scene:notice_monster_restore_hp(ScenePlayerIdList, MonsterObjId, NewHp);
                        true ->
                            noop
                    end,
                    ?UPDATE_OBJ_SCENE_MONSTER(MonsterObj#obj_scene_actor{hp = NewHp, player_hp_hurt_list = NewPlayerHpHurtList}),
                    NewTmpList
            end
        end,
        [],
        mod_scene_monster_manager:get_all_obj_scene_monster_id()
    ),
    put(scene_recover_hp_monster_id_list, NewSceneRecoverHpMonsterIdList).

%% @doc 恢复怪物血量
handle_recover_monster_hp() ->
    SceneRecoverHpMonsterIdList = util:get_dict(scene_recover_hp_monster_id_list, []),
    if
        SceneRecoverHpMonsterIdList == [] ->
            noop;
        true ->
            Now = util_time:milli_timestamp(),
            NewSceneRecoverHpMonsterIdList =
                lists:foldl(
                    fun(MonsterObjId, TmpList) ->
                        MonsterObj = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
                        if
                            MonsterObj == ?UNDEFINED ->
                                TmpList;
                            true ->
                                #obj_scene_actor{
                                    last_attacked_time_ms = LastAttackedTimeMs,
                                    hp = Hp,
                                    max_hp = MaxHp
                                } = MonsterObj,
                                if
                                    Hp < MaxHp andalso Now > LastAttackedTimeMs + ?SD_HP_MODE_HP_RECOVER_TIME ->
                                        NewHp = min(ceil(MaxHp * ?SD_HP_MODE_HP_RECOVER_PER / 10000) + Hp, MaxHp),
%%                                ?DEBUG("慢慢回血 ~p", [{MaxHp, Hp, NewHp, NewHp - Hp}]),
                                        ?UPDATE_OBJ_SCENE_MONSTER(MonsterObj#obj_scene_actor{hp = NewHp}),
                                        api_scene:notice_monster_restore_hp(mod_scene_player_manager:get_all_obj_scene_player_id(), MonsterObjId, NewHp),
                                        [MonsterObjId | TmpList];
                                    true ->
                                        TmpList
                                end
                        end
                    end,
                    [],
                    SceneRecoverHpMonsterIdList
                ),
            put(scene_recover_hp_monster_id_list, NewSceneRecoverHpMonsterIdList)
    end.

%% @doc 玩家离开恢复怪物hp
player_leave_recover_monster_hp(PlayerId) ->
    MonsterIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
    PlayerIdList = lists:delete(PlayerId, mod_scene_player_manager:get_all_obj_scene_player_id()),
    lists:foreach(
        fun(MonsterObjId) ->
            MonsterObj = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
            #obj_scene_actor{
                hp = Hp,
                max_hp = MaxHp,
                player_hp_hurt_list = PlayerHpHurtList
            } = MonsterObj,
            case lists:keytake(PlayerId, 1, PlayerHpHurtList) of
                false ->
                    noop;
                {value, {PlayerId, AddHp, _}, NewPlayerHpHurtList} ->
                    NewHp = min(Hp + AddHp, MaxHp),
                    ?UPDATE_OBJ_SCENE_MONSTER(MonsterObj#obj_scene_actor{player_hp_hurt_list = NewPlayerHpHurtList, hp = NewHp}),
                    ?IF(NewHp > Hp, api_scene:notice_monster_restore_hp(PlayerIdList, MonsterObjId, NewHp), noop)
            end
        end,
        MonsterIdList
    ).

%% ========================================= 怪物回血(血条模式) end ==================================================


%% ============================================== 飞行怪心跳 start ==================================================

do_heart_beat_by_type_4(ObjMonster, State) ->
%%    ?DEBUG("怪物类型4的心跳"),
    #obj_scene_actor{
        obj_id = ObjId,
        type_action_list = TypeActionList,
        base_id = MonsterId,
        x = X,
        y = Y
    } = ObjMonster,
    if
        TypeActionList == [] ->
            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 1000),
            #t_monster{
                type_action_list = ConfigTypeActionList
            } = get_t_monster(MonsterId),

%%            ObjMonster1 = mod_mission_scene_boss:handle_boss_teleport(ObjMonster, State),

%%            NewGridId = ?PIX_2_GRID_ID(X, Y),
            {_BossId, BossXYList} = get(scene_master_boss_data),
            [NewX, NewY] = util_random:get_list_random_member(BossXYList -- [[X, Y]]),
%%            ?DEBUG("怪物闪现~p", [{X, Y, NewX, NewY}]),
            ObjMonster2 = ObjMonster#obj_scene_actor{x = NewX, y = NewY, last_move_time = get(?DICT_NOW_MS)},
%%            mod_scene_grid_manager:handle_monster_grid_change(NewObjSceneMonster, OldGridId, NewGridId),
            api_scene:notice_monster_teleport(
                mod_scene_player_manager:get_all_obj_scene_player_id(),
                ObjId,
                NewX,
                NewY
            ),

            ObjMonster2#obj_scene_actor{
                type_action_list = util_random:get_list_random_member(ConfigTypeActionList)
            };
        true ->
            ScenePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),

            if
                ScenePlayerIdList == [] ->
                    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 4000),
                    ObjMonster;
                true ->
                    [[SkillId, NextTime] | NewTypeActionList] = TypeActionList,

                    #t_active_skill{
                        attack_length = AttackLength,
                        charge_time = ChargeTime,
                        force_wait_time = ForceWaitTime,
                        continue_time = ContinueTime,
                        is_common_skill = IsCommonSkill
                    } = mod_active_skill:get_t_active_skill(SkillId),
                    WaitTime =
                        if
                            IsCommonSkill == ?TRUE ->
                                mod_active_skill:decode_skill_continue_time(ContinueTime, 0);
                            true ->
                                ForceWaitTime
                        end + ChargeTime,
                    F =
                        fun(#filter_target{this_obj_type = ThisObjType}) ->
                            if
                                ThisObjType == ?OBJ_TYPE_PLAYER ->
                                    true;
                                true ->
                                    false
                            end
                        end,
                    %% 获取最近的玩家
                    TargetList = mod_fight_target:get_attack_target_list([], ScenePlayerIdList, X, Y, F, AttackLength * ?TILE_LEN),
                    Target =
                        if
                            TargetList == [] ->
                                NewTargetList = mod_fight_target:get_attack_target_list([], ScenePlayerIdList, X, Y, F, 0),
                                if
                                    NewTargetList == [] ->
                                        ?ERROR("飞行怪攻击报错 XY: ~p , PlayerIdList : ~p", [{X, Y}, lists:map(
                                            fun(PlayerId) ->
                                                #obj_scene_actor{
                                                    x = X,
                                                    y = Y
                                                } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
                                                {PlayerId, X, Y}
                                            end,
                                            ScenePlayerIdList
                                        )]),
                                        null;
                                    true ->
                                        util_random:get_list_random_member(NewTargetList)
                                end;
                            true ->
                                hd(TargetList)
                        end,
                    if
                        Target == null ->
                            ObjMonster;
%%                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, ChargeTime + WaitTime + NextTime);
                        true ->
                            #obj_scene_actor{
                                obj_type = TargetObjType,
                                obj_id = TargetObjId,
                                x = TargetX,
                                y = TargetY
                            } = Target,
                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, ChargeTime + WaitTime + NextTime),
                            Dir = util_math:get_direction({X, Y}, {TargetX, TargetY}),
%%                            ?DEBUG("怪物类型战斗参数 ~p", [{{X, Y}, {TargetX, TargetY}, Dir}]),
                            SkillPointList = get_skill_point_list(SkillId, X, Y, AttackLength * ?TILE_LEN, State),
                            RequestFightParam =
                                #request_fight_param{
                                    attack_type = ?OBJ_TYPE_MONSTER,
                                    obj_type = ?OBJ_TYPE_MONSTER,
                                    obj_id = ObjId,
                                    skill_id = SkillId,
                                    dir = Dir,
                                    target_type = TargetObjType,
                                    target_id = TargetObjId,
                                    cost = 1,
                                    skill_point_list = SkillPointList
                                },
                            Now = get(?DICT_NOW_MS),
                            EndTime = Now + ChargeTime,
                            api_fight:notice_fight_wait_skill(ScenePlayerIdList, ?OBJ_TYPE_MONSTER, ObjId, SkillId, Dir, Now + ChargeTime, SkillPointList),
                            erlang:send_after(ChargeTime, self(), scene_wait_skill:pack_msg({?MSG_SCENE_USE_WAIT_SKILL, RequestFightParam, EndTime})),
                            WaitSkill = #wait_skill{
                                skill_id = SkillId,
                                dir = Dir,
                                end_time = EndTime,
                                request_fight_param = RequestFightParam
                            },
                            ObjMonster#obj_scene_actor{
                                wait_skill_info = WaitSkill,
                                type_action_list = NewTypeActionList
                            }
                    end
            end
    end.

do_heart_beat_by_type_5(ObjMonster, State) ->
%%    ?DEBUG("怪物类型5的心跳"),
    #obj_scene_actor{
        obj_id = ObjId,
        type_action_list = TypeActionList,
        base_id = MonsterId,
        x = X,
        y = Y,
        status = Status,
        birth_x = BirthX,
        birth_y = BirthY,
        last_fight_skill_id = LastMoveTime,
        track_info = TrackInfo,
        move_path = MovePath
    } = ObjMonster,

    ScenePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),

    if
        ScenePlayerIdList == [] ->
            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 2000),
            if
                Status == ?MONSTER_STATUS_SLEEP ->
                    ObjMonster;
                true ->
                    ObjMonster#obj_scene_actor{
                        x = BirthX,
                        y = BirthY,
                        status = ?MONSTER_STATUS_SLEEP
                    }
            end;
        true ->

            Now = get(?DICT_NOW_MS),

            [[MoveTime, SkillId] | NewTypeActionList] =
                if
                    TypeActionList == [] ->
                        #t_monster{
                            type_action_list = ConfigTypeActionList
                        } = get_t_monster(MonsterId),
                        util_random:get_list_random_member(ConfigTypeActionList);
                    true ->
                        TypeActionList
                end,

            #t_active_skill{
                attack_length = AttackLength,
                charge_time = ChargeTime,
                force_wait_time = ForceWaitTime,
                continue_time = ContinueTime,
                is_common_skill = IsCommonSkill
            } = mod_active_skill:get_t_active_skill(SkillId),

            #track_info{
                obj_type = TrackType,
                obj_id = TrackId
            } = TrackInfo,

            TrackObj = ?GET_OBJ_SCENE_ACTOR(TrackType, TrackId),

            if
                TrackObj == ?UNDEFINED ->
                    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 100),
                    F =
                        fun(#filter_target{this_obj_type = ThisObjType}) ->
                            if
                                ThisObjType == ?OBJ_TYPE_PLAYER ->
                                    true;
                                true ->
                                    false
                            end
                        end,
                    TargetList = mod_fight_target:get_attack_target_list([], ScenePlayerIdList, X, Y, F, 0),
                    #obj_scene_actor{
                        obj_type = TargetObjType,
                        obj_id = TargetObjId,
                        x = TargetX,
                        y = TargetY
                    } = hd(TargetList),
                    NewTrackInfo = #track_info{
                        obj_type = TargetObjType,
                        obj_id = TargetObjId,
                        x = TargetX,
                        y = TargetY
                    },
                    ObjMonster#obj_scene_actor{
                        track_info = NewTrackInfo
                    };
                true ->
                    #obj_scene_actor{
                        obj_type = TargetObjType,
                        obj_id = TargetObjId,
                        x = TargetX,
                        y = TargetY
                    } = TrackObj,

                    #t_monster{
                        track_min_range = TrackMinRange
                    } = get_t_monster(MonsterId),

                    Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),

%%                    ?DEBUG("去寻路把 : ~p", [{Now,MoveTime,LastMoveTime, Distance,WarnRange * ?TILE_LEN}]),
%%                    ?DEBUG("去寻路把 : ~p", [{Now > MoveTime + LastMoveTime, Distance > WarnRange * ?TILE_LEN}]),
                    if
                        (Now < MoveTime + LastMoveTime orelse LastMoveTime == 0) andalso Distance > TrackMinRange * ?TILE_LEN ->
                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 500),
                            if
                                MovePath == [] ->
                                    api_scene:notice_monster_move(ScenePlayerIdList, ObjId, [{TargetX, TargetY}]),
                                    ObjMonster#obj_scene_actor{last_move_time = Now, move_path = [{TargetX, TargetY}], last_fight_skill_id = Now};
                                true ->
                                    ObjMonster
                            end;
                        true ->
                            WaitTime =
                                if
                                    IsCommonSkill == ?TRUE ->
                                        mod_active_skill:decode_skill_continue_time(ContinueTime, 0);
                                    true ->
                                        ForceWaitTime
                                end + ChargeTime,

                            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, ChargeTime + WaitTime),
                            Dir = util_math:get_direction({X, Y}, {TargetX, TargetY}),
                            SkillPointList = get_skill_point_list(SkillId, X, Y, AttackLength * ?TILE_LEN, State),
                            RequestFightParam =
                                #request_fight_param{
                                    attack_type = ?OBJ_TYPE_MONSTER,
                                    obj_type = ?OBJ_TYPE_MONSTER,
                                    obj_id = ObjId,
                                    skill_id = SkillId,
                                    dir = Dir,
                                    target_type = TargetObjType,
                                    target_id = TargetObjId,
                                    cost = 1,
                                    skill_point_list = SkillPointList
                                },
                            Now = get(?DICT_NOW_MS),
                            EndTime = Now + ChargeTime,
                            api_fight:notice_fight_wait_skill(ScenePlayerIdList, ?OBJ_TYPE_MONSTER, ObjId, SkillId, Dir, Now + ChargeTime, SkillPointList),
                            erlang:send_after(ChargeTime, self(), scene_wait_skill:pack_msg({?MSG_SCENE_USE_WAIT_SKILL, RequestFightParam, EndTime})),
                            WaitSkill = #wait_skill{
                                skill_id = SkillId,
                                dir = Dir,
                                end_time = EndTime,
                                request_fight_param = RequestFightParam
                            },
                            api_scene:notice_monster_stop_move(ScenePlayerIdList, ObjId, X, Y),
                            ObjMonster#obj_scene_actor{
                                wait_skill_info = WaitSkill,
                                type_action_list = NewTypeActionList,
                                last_fight_skill_id = 0,
                                can_action_time = EndTime,
                                track_info = #track_info{
                                    obj_type = 0,
                                    obj_id = 0
                                },
                                move_path = []
                            }
                    end
            end
    end.

do_heart_beat_by_type_6(ObjMonster, State) ->
    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 500),
    #obj_scene_actor{
        x = MonsterX, y = MonsterY, obj_id = MonsterId, move_path = _MovePath, r_active_skill_list = ActiveSkillList,

        hate_list = OldHateList, is_all_sync = IsAllSync, base_id = MonsterBaseId, grid_id = GridId, obj_type = ObjType,
        dir = OldDir, attack_times = AttackTimes
    } = ObjMonster,

    #t_monster{
        move_speed = NewMoveSpeed, warn_range = WarnRange1
    } = get_t_monster(MonsterBaseId),
    %% @todo 2021-07-29表中配置的(20159)怪物的警戒范围为420 * ?TILE_LEN = 16800 感觉不太对 所以先注释
%%    WarnRange = WarnRange1 * ?TILE_LEN,
    WarnRange = WarnRange1,

    SkillInfoTupleList =
        lists:filtermap(
            fun(SkillRecord) ->
                #r_active_skill{id = SkillId1} = SkillRecord,

                #t_active_skill{attack_length = AttackLength, is_common_skill = IsCommonSkill,
                    cd_time = AttackInterval
                } = t_active_skill:get({SkillId1}),
                if
                    IsCommonSkill =:= ?TRUE -> {true, {SkillId1, AttackLength * ?TILE_LEN, AttackInterval}};
                    true -> false
                end
            end,
            ActiveSkillList
        ),
    SkillInfoTuple = ?IF(SkillInfoTupleList =/= [], hd(SkillInfoTupleList), {}),
    {SkillId, AttackRange1, _AttackInterval} =
        case SkillInfoTuple of
            {} -> {0, 0, 0};
            SkillInfo -> SkillInfo
        end,

%%    {_PatrolRange, TrackRange, WarnRange} = get_monster_ai_args(ObjMonster#obj_scene_actor.base_id),
    %% 警戒范围，具体值读表
    AttackLength = AttackRange1,
%%    NewMoveSpeed = 180,
    %% 突进的距离
    Distance = 400,
%%    Distance = AttackLength,

    %% 被当前怪物攻击过的玩家列表
    PlayerHasBeenAttacked = ?IF(get({?SCENE_MONSTER_ATTACK_PLAYER, MonsterBaseId}) =:= ?UNDEFINED, [],
        get({?SCENE_MONSTER_ATTACK_PLAYER, MonsterBaseId})),

    NoticePlayerIds = ?IF(IsAllSync,
        mod_scene_player_manager:get_all_obj_scene_player_id(),
        mod_scene_grid_manager:get_subscribe_player_id_list(GridId)),

    PlayerList =
        if
        %% 没有目标（正在跑过去的玩家，或者曾经攻击过怪物的玩家）
            OldHateList =:= [] ->
                lists:foldl(
                    fun(PlayerIdInScene, Tmp) ->
                        case lists:member(PlayerIdInScene, PlayerHasBeenAttacked) of
                            true -> Tmp;
                            false ->
                                case ?GET_OBJ_SCENE_PLAYER(PlayerIdInScene) of
                                    ?UNDEFINED -> Tmp;
                                    ObjPlayer ->
                                        #obj_scene_actor{
                                            obj_id = TargetId, obj_type = TargetType, x = X, y = Y
                                        } = ObjPlayer,
                                        Dis = util_math:get_distance({MonsterX, MonsterY}, {X, Y}),
                                        %% 警戒范围内的玩家 距离越近权重越高
                                        if

                                            Dis =< WarnRange ->
                                                [{WarnRange - Dis, {TargetType, TargetId, X, Y}}] ++ Tmp;
                                            true -> Tmp
                                        end
                                end
                        end
                    end,
                    [],
                    mod_scene_player_manager:get_all_obj_scene_player_id()
                );
            true ->
                ?DEBUG("~p的hate_list: ~p", [MonsterId, [OldHateList]]),
                %% 重构仇恨列表为[{Weight, {TargetType, TargetId}}]结构，方便按照权重排序
                lists:sort([{OldWeight, OldTargetInfo} || {OldTargetInfo, OldWeight} <- OldHateList])
        end,

    %% 新仇恨列表 权重最高的那个玩家（理论上来说就是距离怪物最近的玩家）
%%    ?WARNING("~p PlayerList: ~p", [MonsterId, PlayerList]),
    NewHateList = ?IF(PlayerList =/= [], hd(lists:sort(PlayerList)), []),
    {Attack, Track, TargetObjId, TargetObjType, NewAttackerDir, Sprint} =
        if
        %% 新仇恨列表为空，继续巡逻
            NewHateList =:= [] ->
                {?FALSE, ?TRUE, 0, 0, OldDir, ?FALSE};
        %% 新仇恨列表不为空，表示要怪物要发起攻击
            true ->
                {_, TargetInfo1} = NewHateList,
                FirstTargetTupleInHateList =
                    case TargetInfo1 of
                        {TargetType, TargetId, TargetX, TargetY} ->
                            {TargetType, TargetId, TargetX, TargetY};
                        {TargetType1, TargetId1} ->
                            %% 确定目标还在场景内
                            case ?GET_OBJ_SCENE_ACTOR(TargetType1, TargetId1) of
                                ?UNDEFINED -> noop;
                                TargetObj ->
                                    {TargetType1, TargetId1, TargetObj#obj_scene_actor.x, TargetObj#obj_scene_actor.y}
                            end
                    end,
                if
                    FirstTargetTupleInHateList =:= noop -> {?FALSE, ?FALSE, 0, 0, ?FALSE};
                    true ->
                        %% 通过判断玩家与怪物间的距离，判断是否可以发起撞击
                        {TargetType2, TargetId2, TargetX2, TargetY2} = FirstTargetTupleInHateList,
                        Dis = util_math:get_distance({MonsterX, MonsterY}, {TargetX2, TargetY2}),
                        NewDir = util_math:get_direction({MonsterX, MonsterY}, {TargetX2, TargetY2}),
                        ?DEBUG("~p计算距离: ~p", [MonsterId, {Dis, Distance, AttackLength, Dis =< Distance,
                            {MonsterX, MonsterY}, {TargetX2, TargetY2}, SkillId}]),
                        put({?SCENE_MONSTER_ATTACK_PLAYER, MonsterBaseId}, %% [TargetId2] ++ PlayerHasBeenAttacked),
                            ?IF(lists:member(TargetId2, PlayerHasBeenAttacked) =:= false,
                                ([TargetId2] ++ PlayerHasBeenAttacked),
                                PlayerHasBeenAttacked)),
%%                        MatchDis = Distance + AttackLength,
                        if
                        %% 冲刺
%%                            Dis > AttackLength andalso Dis =< MatchDis ->
%%                                {?TRUE, ?FALSE, TargetId2, TargetType2, NewDir, ?TRUE};
                        %% 发起撞击
                            Dis =< AttackLength ->
                                {?TRUE, ?FALSE, TargetId2, TargetType2, NewDir, ?FALSE};
                        %% 跑向玩家
                            true -> {?FALSE, ?FALSE, TargetId2, TargetType2, NewDir, ?FALSE}
                        end
                end
        end,
%%    ?DEBUG("~p的动作: ~p", [MonsterId, {Attack, Track, TargetObjId, TargetObjType, NewAttackerDir, Sprint}]),
    {ClearHateList, AutoMove, NewObjMonster} =
        if
        %% @todo 策划说要有突进，但现阶段可能不太好搞，所以使用跑向玩家的逻辑
            Attack =:= ?TRUE andalso Track =:= ?FALSE andalso AttackTimes < 1 andalso Sprint =:= ?TRUE ->
                ObjMonster1 = stop_move(ObjMonster, State),
                HateListWaitUpdate =
                    case NewHateList of
                        {Weight, {TargetType3, TargetId3, _, _}} -> [{{TargetType3, TargetId3}, Weight}];
                        {Weight1, {TargetType4, TargetId4}} -> [{{TargetType4, TargetId4}, Weight1}]
                    end,
                {HateListWaitUpdate, ?FALSE, ObjMonster1};
        %% 发起撞击 直接给客户端下发撞击协议 清空仇恨列表
            Attack =:= ?TRUE andalso Track =:= ?FALSE andalso AttackTimes < 1 andalso Sprint =:= ?FALSE ->
                ObjMonster1 = stop_move(ObjMonster, State),
                ?DEBUG("~p攻击玩家: ~p", [MonsterId, TargetObjId]),

                #obj_scene_actor{
                    r_active_skill_list = ActiveSkillList
                } = ObjMonster1,

                RequestFightParam =
                    #request_fight_param{
                        attack_type = ObjType,
                        obj_type = ObjType,
                        obj_id = MonsterId,
                        skill_id = SkillId,
                        dir = NewAttackerDir,
                        target_type = TargetObjType,
                        target_id = TargetObjId,
                        cost = 0,
                        skill_point_list = []
                    },
                self() ! {?MSG_FIGHT, RequestFightParam},

                ObjMonsterAfterAttack = ObjMonster1#obj_scene_actor{attack_times = AttackTimes + 1, move_type = ?MOVE_TYPE_SKILL},
                put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 100),

                HateListWaitUpdate = [],
                {HateListWaitUpdate, ?FALSE, ObjMonsterAfterAttack};
        %% 跑向玩家 向客户端下发跑的协议 保存新的仇恨列表 新仇恨列表的数据结构：{{TargetType, TargetId}, Weight}
            Attack =:= ?FALSE andalso Track =:= ?FALSE andalso AttackTimes < 1 andalso Sprint =:= ?FALSE ->
                ObjMonster1 = stop_move(ObjMonster, State),
                HateListWaitUpdate =
                    case NewHateList of
                        {Weight, {TargetType3, TargetId3, _, _}} -> [{{TargetType3, TargetId3}, Weight}];
                        {Weight1, {TargetType4, TargetId4}} -> [{{TargetType4, TargetId4}, Weight1}]
                    end,
                ?DEBUG("~p跑向玩家: ~p", [MonsterId, HateListWaitUpdate]),
                {HateListWaitUpdate, ?FALSE, ObjMonster1};
        %% 继续巡逻 仇恨列表保持不变
            true ->
%%                ?WARNING("~p继续巡逻 ~p", [MonsterId, {Ram, Track}]),
                {[], ?TRUE, ObjMonster}
        end,
    if
        ClearHateList =:= [] andalso AutoMove =:= ?TRUE ->
            ObjMonster2 = NewObjMonster#obj_scene_actor{hate_list = ClearHateList},
            auto_move(ObjMonster2, State),
            ObjMonster2;
        ClearHateList =:= [] andalso AutoMove =:= ?FALSE ->
            ObjMonster2 = NewObjMonster#obj_scene_actor{hate_list = ClearHateList,
                track_info = [#track_info{obj_type = 0, obj_id = 0, x = 0, y = 0}]},
            ?DEBUG("~p向别的地方跑掉", [MonsterId]),
            auto_move(ObjMonster2, State);
        ClearHateList =/= [] andalso AutoMove =:= ?FALSE ->
            {{ObjTargetType, ObjTargetId}, _} = hd(ClearHateList),
            case ?GET_OBJ_SCENE_ACTOR(ObjTargetType, ObjTargetId) of
                ?UNDEFINED -> ?DEBUG("目标离开场景"), NewObjMonster;
                ObjTarget ->
                    ObjMonsterStopPatrol = stop_move(ObjMonster, State),
                    #obj_scene_actor{
                        x = ObjTargetX, y = ObjTargetY
                    } = ObjTarget,

                    #obj_scene_actor{x = MonsterX1, y = MonsterY1} = ObjMonsterStopPatrol,

                    api_scene:notice_monster_move(NoticePlayerIds, MonsterId, [{ObjTargetX, ObjTargetY}]),
                    RealDis = util_math:get_distance({MonsterX1, MonsterY1}, {ObjTargetX, ObjTargetY}),
                    ?WARNING("~p NextHeartbeat: ~p", [MonsterId, {RealDis, {MonsterX1, MonsterY1}, {ObjTargetX, ObjTargetY}}]),

                    ObjMonsterAfterMove1 = go_target_place(MonsterId, ObjTargetX, ObjTargetY, null, State),
                    ObjMonsterAfterMove = ObjMonsterAfterMove1#obj_scene_actor{
                        move_type = ?MOVE_TYPE_MOMENT, move_speed = NewMoveSpeed, move_path = [{ObjTargetX, ObjTargetY}],
                        hate_list = ClearHateList,
                        track_info = [
                            #track_info{obj_type = ObjTargetType, obj_id = ObjTargetId, x = ObjTargetX, y = ObjTargetY}
                        ]
                    },
                    api_scene:notice_monster_move(NoticePlayerIds, MonsterId, [{ObjTargetX, ObjTargetY}]),
                    api_scene:api_notice_monster_attr_change(
                        NoticePlayerIds, MonsterId, [{?P_MOVE_SPEED, NewMoveSpeed}, {?P_MOVE_TYPE, ?MOVE_TYPE_MOMENT}]),
                    ObjMonsterAfterMove
            end;
        true ->
            ObjMonster2 = NewObjMonster#obj_scene_actor{hate_list = ClearHateList},
            ObjMonster2
    end.

do_heart_beat_by_type_9(ObjMonster = #obj_scene_actor{obj_id = ObjId}, State) ->
    #r_boss_ai{
        seq = OriActionSeq,
        action_end_time = ActionEndTime
    } = scene_worker:dict_get_boss_ai(ObjId),

	NowMilSec = get(?DICT_NOW_MS),
	case NowMilSec >= ActionEndTime of
        false ->
            ObjMonster;
        true ->
            ScenePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
            if
            %% 场景内没有玩家，心跳放缓
                ScenePlayerIdList == [] ->
                    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 4000),
                    (stop_move(ObjMonster, State))#obj_scene_actor{
                        track_info = #track_info{}
                    };
                true ->
                    #obj_scene_actor{
                        obj_id = ObjId,
                        type_action_list = ActionList,
                        base_id = MonsterId
                    } = ObjMonster,

                    if
                        %% 出生瞬间不做操作
                        OriActionSeq =:= 0 ->
                            Action = [],
                            RestActionList = ActionList;
                        true ->
                            [Action | RestActionList] =
                                if
                                    ActionList == [] ->
                                        #t_monster{
                                            type_action_list = CfgActionLists
                                        } = get_t_monster(MonsterId),
                                        util_random:get_list_random_member(CfgActionLists);
                                    true ->
                                        ActionList
                                end
                    end,

                    %% 执行ai操作
                    {ActionTime, ObjMonster0} = execute_ai_action(ObjMonster, Action, State),
                    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, ActionTime),
                    scene_worker:dict_set_boss_ai(
                        ObjId,
                        #r_boss_ai{action_end_time = NowMilSec + ActionTime, seq = OriActionSeq + 1}
                    ),
                    ObjMonster0#obj_scene_actor{
                        type_action_list = RestActionList
                    }
            end
    end.

%% 原地待机
execute_ai_action(
    ObjMonster, [], State
) ->
    {3000, stop_move(ObjMonster, State)};
%% 使用技能
execute_ai_action(
    ObjMonster, [1, SkillId, ActionTime], State
) ->
    #obj_scene_actor{
        obj_id = ObjId,
        x = X,
        y = Y
    } = ObjMonster,

    %% 停止移动
    ObjMonster0 = stop_move(ObjMonster, State),

    %% 搜索攻击目标
    ObjMonster1 = search_attack_target(ObjMonster0, State),
    #obj_scene_actor{
        track_info = #track_info{
            obj_type = TrackType,
            obj_id = TrackId
        }
    } = ObjMonster1,
    TrackSceneObj = ?GET_OBJ_SCENE_ACTOR(TrackType, TrackId),

    case TrackSceneObj of
        %% 无攻击目标，心跳加快，去执行下一个动作
        ?UNDEFINED ->
            {1000, ObjMonster1};
        _ ->
            #obj_scene_actor{
                obj_type = TargetObjType,
                obj_id = TargetObjId,
                x = TargetX,
                y = TargetY
            } = TrackSceneObj,

            #t_active_skill{
                attack_length = AttackLength,
                charge_time = ChargeTime
            } = mod_active_skill:get_t_active_skill(SkillId),

            Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
            Dir = util_math:get_direction({X, Y}, {TargetX, TargetY}),
            if
            %% 攻击范围内，准备使用技能
                Distance =< AttackLength * ?TILE_LEN ->
                    SKillPointList = [{TargetX, TargetY}],
                    RequestFightParam =
                        #request_fight_param{
                            attack_type = ?OBJ_TYPE_MONSTER,
                            obj_type = ?OBJ_TYPE_MONSTER,
                            obj_id = ObjId,
                            skill_id = SkillId,
                            dir = Dir,
                            target_type = TargetObjType,
                            target_id = TargetObjId,
                            cost = 1,
                            skill_point_list = SKillPointList
                        },

                    EndTime = get(?DICT_NOW_MS) + ChargeTime,
                    ScenePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
                    api_fight:notice_fight_wait_skill(ScenePlayerIdList, ?OBJ_TYPE_MONSTER, ObjId, SkillId, Dir, EndTime, SKillPointList),
                    erlang:send_after(ChargeTime + 100, self(), scene_wait_skill:pack_msg({?MSG_SCENE_USE_WAIT_SKILL, RequestFightParam, EndTime})),
                    WaitSkill = #wait_skill{
                        skill_id = SkillId,
                        dir = Dir,
                        end_time = EndTime,
                        request_fight_param = RequestFightParam
                    },

                    %% 攻击一次过后，清除所有仇恨对象
                    HeartBeatInterval = max(ActionTime, ChargeTime),
                    {
                        HeartBeatInterval,
                        ObjMonster1#obj_scene_actor{
                            wait_skill_info = WaitSkill,
                            last_fight_skill_id = SkillId,
                            track_info = #track_info{
                                obj_type = 0,
                                obj_id = 0
                            },
                            hate_list = []
                        }
                    };
            %% 不在攻击范围内，直接跳过，心跳加快
                true ->
                    {1000, ObjMonster1}
            end
    end;
%% 移动
execute_ai_action(
    ObjMonster, [2, ActionTime], State
) ->
    #obj_scene_actor{
        obj_id = ObjId,
        x = X,
        y = Y,
        birth_x = SrcX,
        birth_y = SrcY,
        is_all_sync = IsAllSync,
        grid_id = GridId,
        move_speed = MoveSpeed
    } = ObjMonster,

    ObjMonster0 = stop_move(ObjMonster, State),
    MovePath = get_move_path(MoveSpeed, 10000, util_random:random_number(8, 12), {X, Y}, {SrcX, SrcY}, 10000, State, 5),
    api_scene:notice_monster_move(
        ?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)),
        ObjId,
        MovePath
    ),
    {
        ActionTime,
        ObjMonster0#obj_scene_actor{
            move_path = MovePath
        }
    };
%% 跳跃
execute_ai_action(
    ObjMonster, [3, ActionTime], State
) ->
    #obj_scene_actor{
        obj_id = ObjId,
        x = X,
        y = Y,
        birth_x = SrcX,
        birth_y = SrcY,
        grid_id = GridId,
        is_all_sync = IsAllSync,
        move_speed = MoveSpeed
    } = ObjMonster,

    ObjMonster0 = stop_move(ObjMonster, State),
    MovePath = get_move_path(MoveSpeed, 10000, 7, {X, Y}, {SrcX, SrcY}, 10000, State, 5),
    case MovePath of
        [] ->
            noop;
        [{NewX, NewY}] ->
            api_scene:notice_monster_teleport(?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)), ObjId, NewX, NewY)
    end,
    {ActionTime, ObjMonster0}.

%% ----------------------------------
%% @doc 	处理怪物狂暴状态结束
%% @throws 	none
%% @end
%% ----------------------------------
handle_monster_wild_timeout(MonsterObjId, State) ->
    ObjSceneActor = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
    case ObjSceneActor of
        ?UNDEFINED -> skip;
        _ ->
            ObjSceneActor_0 = stop_move(ObjSceneActor, State),  %% 停止移动

            #obj_scene_actor{
                init_move_speed = InitMoveSpeed,
                is_all_sync = IsAllSync,
                grid_id = GridId
            } = ObjSceneActor_0,

            %% 还原状态
            ObjSceneActor_1 = ObjSceneActor_0#obj_scene_actor{
                move_type = ?MOVE_TYPE_NORMAL,
                move_speed = InitMoveSpeed
            },
            ?UPDATE_OBJ_SCENE_MONSTER(ObjSceneActor_1),
            NoticePlayerIds = ?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)),
            api_scene:api_notice_monster_attr_change(NoticePlayerIds, MonsterObjId, [{?P_MOVE_SPEED, InitMoveSpeed}, {?P_MOVE_TYPE, ?MOVE_TYPE_NORMAL}]),

            ObjSceneActor_1
    end.

%% ----------------------------------
%% @doc 	获取技能施放位置列表
%% @throws 	none
%% @end
%% ----------------------------------
get_skill_point_list(SkillId, X, Y, DisLimit, _State = #scene_state{map_id = MapId}) ->
    #t_active_skill{
        balance_type = BalanceType,
        target_num = TargetNum,
        base_limit_range = Gap,
        base_dot_list = BaseDotLists
    } = mod_active_skill:get_t_active_skill(SkillId),

    case BalanceType of
        %% 周围玩家的位置
        ?BALANCE_TYPE_GRID2 ->
            mod_skill_balance_range:get_balance_point_list_1(X, Y, DisLimit, TargetNum);
        %% 随机选取位置
        ?BALANCE_TYPE_GRID3 ->
            mod_skill_balance_range:get_balance_point_list_2(X, Y, DisLimit, Gap, TargetNum);
        %% 固定偏移位置
        ?BALANCE_TYPE_GRID4 ->
            mod_skill_balance_range:get_balance_point_list_3(X, Y, MapId, BaseDotLists);
        %% 附近玩家位置 + 随机位置
        ?BALANCE_TYPE_GRID5 ->
            ResL = mod_skill_balance_range:get_balance_point_list_1(X, Y, DisLimit, TargetNum),
            case TargetNum - length(ResL) of
                0 -> ResL;
                N -> ResL ++ mod_skill_balance_range:get_balance_point_list_2(X, Y, DisLimit, Gap, N)
            end;
        _ ->
            [{X, Y}]
    end.

before_do_heart_beat(_, ObjSceneMonster = #obj_scene_actor{can_action_time = CanActionTime}, NowMilSec, _SceneState) when CanActionTime >= NowMilSec ->
    ObjSceneMonster;
%% 心跳前处理炸弹怪
before_do_heart_beat(?MONSTER_EFFECT_12, ObjSceneMonster, _NowMilSec, _SceneState) ->
    {_IsStateChange, ObjSceneMonster0} = handle_monster_attacked_state(ObjSceneMonster),
    ObjSceneMonster1 = handle_monster_drop_bomb(ObjSceneMonster0),
    ObjSceneMonster1;
%% 心跳前处理金币小妖
before_do_heart_beat(?MONSTER_EFFECT_15, ObjSceneMonster, _NowMilSec, SceneState) ->
    {IsStateChange, ObjSceneMonster_0} = handle_monster_attacked_state(ObjSceneMonster),
    case IsStateChange of
        false -> ObjSceneMonster_0;
        true ->
            ObjSceneMonster_1 = stop_move(ObjSceneMonster_0, SceneState),    %% 停止移动
            #obj_scene_actor{
                obj_id = ObjId,
                init_move_speed = InitMoveSpeed,
                grid_id = GridId,
                is_all_sync = IsAllSync
            } = ObjSceneMonster_1,

            %% 还原状态
            ObjSceneMonster_2 = ObjSceneMonster_1#obj_scene_actor{move_type = ?MOVE_TYPE_NORMAL, move_speed = InitMoveSpeed},
            ?UPDATE_OBJ_SCENE_MONSTER(ObjSceneMonster_2),

            NoticePlayerIds = ?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)),
            api_scene:api_notice_monster_attr_change(NoticePlayerIds, ObjId, [{?P_MOVE_SPEED, InitMoveSpeed}, {?P_MOVE_TYPE, ?MOVE_TYPE_NORMAL}]),
            ObjSceneMonster_2
    end;
before_do_heart_beat(_, ObjSceneMonster, _NowMilSec, _SceneState) ->
    {_IsStateChange, ObjSceneMonster0} = handle_monster_attacked_state(ObjSceneMonster),
    ObjSceneMonster0.

%% 处理怪物受击状态
handle_monster_attacked_state(ObjSceneMonster) ->
    #obj_scene_actor{
        base_id = BaseMonsterId,
        obj_id = ObjId,
        last_attacked_time_ms = LastAttackedTime
    } = ObjSceneMonster,
    Now = get(?DICT_NOW_MS),

    #t_monster{
        monster_ai_bubble = AiSpeakId
    } = t_monster:get({BaseMonsterId}),
    IsCanSpeak = AiSpeakId > 0,

    OldStateRec = scene_worker:dict_get_monster_ai(ObjId),
    #r_monster_ai{
        state = State,
        speak_times = SpeakTimes,
        last_speak_time = LastSpeakTime0
    } = OldStateRec,
    LastSpeakTime =
        case LastSpeakTime0 of
            0 when IsCanSpeak == true ->
                scene_worker:dict_set_monster_ai(ObjId, OldStateRec#r_monster_ai{last_speak_time = Now}),
                Now;
            _ ->
                LastSpeakTime0
        end,
    case State of
        %% 超过三秒未受到攻击，进入待机状态
        ?MONSTER_AI_STATE_HURT when Now - LastAttackedTime >= 3000 ->
            scene_worker:dict_set_monster_ai(ObjId, OldStateRec#r_monster_ai{state = ?MONSTER_AI_STATE_STAND}),
            {true, ObjSceneMonster};
        %% 受伤状态说话
        ?MONSTER_AI_STATE_HURT when IsCanSpeak == true ->
            #t_monster_ai_bubble{
                injured_bubble_type = HurtSpeakKind,
                injured_bubble_cd_time = HurtSpeakCdTime,
                injured_bubble_per = HurtSpeakPer
            } = t_monster_ai_bubble:get({AiSpeakId}),
            if
                SpeakTimes > 0, Now - LastSpeakTime >= HurtSpeakCdTime; SpeakTimes =:= 0, Now - LastSpeakTime >= 2 * 1000 ->
                    scene_worker:dict_set_monster_ai(ObjId, OldStateRec#r_monster_ai{last_speak_time = Now, speak_times = SpeakTimes + 1}),
                    {false, try_do_monster_speak(util_random:p(HurtSpeakPer), HurtSpeakKind, ObjSceneMonster)};
                true ->
                    {false, ObjSceneMonster}
            end;
        %% 待机状态说话
        ?MONSTER_AI_STATE_STAND when IsCanSpeak == true ->
            #t_monster_ai_bubble{
                stand_bubble_cd_time = StandSpeakCdTime,
                stand_bubble_type = StandSpeakKind
            } = t_monster_ai_bubble:get({AiSpeakId}),
            if
                Now - LastSpeakTime >= StandSpeakCdTime ->
                    scene_worker:dict_set_monster_ai(ObjId, OldStateRec#r_monster_ai{last_speak_time = Now, speak_times = SpeakTimes + 1}),
                    {false, try_do_monster_speak(util_random:p(10000), StandSpeakKind, ObjSceneMonster)};
                true ->
                    {false, ObjSceneMonster}
            end;
        _ ->
            {false, ObjSceneMonster}
    end.

%% 炸弹怪丢炸弹
handle_monster_drop_bomb(ObjSceneMonster) ->
    #obj_scene_actor{
        obj_id = ObjId,
        x = X,
        y = Y,
        cost = Cost,
        grid_id = GridId,
        is_all_sync = IsAllSync,
        wait_skill_info = WaitSkillInfo
    } = ObjSceneMonster,
    NowMilSec = get(?DICT_NOW_MS),

    OldMonsterBombRec = scene_worker:dict_get_monster_bomb(ObjId),
    #r_monster_bomb{
        wild_end_time = OldWildEndTime,
        last_drop_bomb_time = LastTime
    } = OldMonsterBombRec,

    {Skill, ObjSceneMonster_1} = update_skill_info(ObjSceneMonster, NowMilSec),
    Cd = ?SD_ZHADAN_JIAN_GE_TIME * 1000,
    case WaitSkillInfo == undefined andalso Skill /= null andalso OldWildEndTime >= NowMilSec andalso (NowMilSec - LastTime + 100) >= Cd of
        true ->   %% 狂暴期间每隔一秒放置一枚炸弹
            Func = fun(I) -> I + lists:nth(rand:uniform(3), [0, 60, -60]) end,
            SkillPointList = [{Func(X), Func(Y)}],

%%            ?DEBUG("~p狂暴期间，在~w位置上，朝着~w位置放了一枚定时炸弹", [ObjId, {X, Y}, SkillPointList]),

            #r_active_skill{
                id = SkillId
            } = Skill,
            DelaySec = ?SD_ZHADAN_YIN_BAO_TIME * 1000,
            RequestFightParam =
                #request_fight_param{
                    attack_type = ?OBJ_TYPE_MONSTER,
                    obj_type = ?OBJ_TYPE_MONSTER,
                    obj_id = ObjId,
                    skill_id = SkillId,
                    dir = ?DIR_UP,
                    cost = Cost,
                    skill_point_list = SkillPointList
                },
            NoticePlayerIds = ?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)),
            api_fight:notice_fight_wait_skill(NoticePlayerIds, ?OBJ_TYPE_MONSTER, ObjId, SkillId, ?DIR_UP, NowMilSec + DelaySec, SkillPointList),
            erlang:send_after(DelaySec + 100, self(), {?MSG_SCENE_MONSTER_USE_SKILL, RequestFightParam}),
            scene_worker:dict_set_monster_bomb(ObjId, OldMonsterBombRec#r_monster_bomb{last_drop_bomb_time = NowMilSec}),
            ObjSceneMonster_1;
        false ->
            ObjSceneMonster_1
    end.

%% 处理怪物说话
try_do_monster_speak(_IsCanSpeak = false, _SpeakKind, ObjSceneMonster) -> ObjSceneMonster;
try_do_monster_speak(_IsCanSpeak, 0, ObjSceneMonster) -> ObjSceneMonster;
try_do_monster_speak(_IsCanSpeak = true, SpeakKind, ObjSceneMonster) ->
    #obj_scene_actor{
        obj_id = ObjId,
        grid_id = GridId
    } = ObjSceneMonster,
    List = t_bubble@group:get(SpeakKind),
    #t_bubble{
        id = Id
    } = lists:nth(rand:uniform(length(List)), List),
    Notice = proto:encode(#m_scene_notice_monster_speak_toc{monster_id = ObjId, id = Id}),
    mod_socket:send_to_player_list(mod_scene_grid_manager:get_subscribe_player_id_list(GridId), Notice),
    ObjSceneMonster.

%% 过滤目标
handle_target_filter(ObjMonster, TargetList) ->
    handle_target_filter(ObjMonster, TargetList, ?FALSE).
handle_target_filter(ObjMonster, TargetList, UpdateCacheData) ->
    MonsterObj = get_t_monster(ObjMonster#obj_scene_actor.base_id),
    Key =
        case MonsterObj#t_monster.type of
            ?MONSTER_ACTIVE_ATTACK_MONSTER -> {?MONSTER_ACTIVE_ATTACK_MONSTER, ObjMonster#obj_scene_actor.obj_id};
            _ -> null
        end,
    RealTargetList =
        case get(Key) of
            ?UNDEFINED -> TargetList;
            L when is_list(L) ->
                lists:filtermap(
                    fun(TargetObj) ->
                        case lists:member(TargetObj#obj_scene_actor.obj_id, L) of
                            false -> {true, TargetObj};
                            true -> false
                        end
                    end,
                    TargetList
                )
        end,
    TargetListLength = length(RealTargetList),
    if
        TargetListLength > 0 ->
            case hd(RealTargetList) of
                R when is_record(R, obj_scene_actor) ->
                    %% 跑着去找玩家
                    handle_monster_run(ObjMonster, ?MOVE_TYPE_MOMENT),
                    ?IF(
                        UpdateCacheData =:= ?TRUE,
                        put(Key, [R#obj_scene_actor.obj_id] ++ ?IF(get(Key) =:= ?UNDEFINED, [], get(Key))),
                        noop
                    );
                O -> ?ERROR("handle_filter_target 非预期错误: ~p", [O])
            end;
        true -> noop
    end,
    RealTargetList.

%% 处理追踪+巡逻的怪物遇到玩家
handle_monster_run(ObjMonster, MoveTypeMoment) ->
    #t_monster{type = MonsterType, move_speed = MoveSpeed} = get_t_monster(ObjMonster#obj_scene_actor.base_id),
    if
        MonsterType =:= ?MONSTER_ACTIVE_ATTACK_MONSTER ->
            NoticePlayerIds = mod_scene_player_manager:get_all_obj_scene_player_id(),
%%            ?DEBUG("通知修改~p的移动形态: ~p", [ObjMonster#obj_scene_actor.obj_id,
%%                api_scene:api_notice_monster_attr_change(
%%                    NoticePlayerIds, ObjMonster#obj_scene_actor.obj_id,
%%                    [{?P_MOVE_SPEED, MoveSpeed}, {?P_MOVE_TYPE, MoveTypeMoment}]
%%                )]);
            api_scene:api_notice_monster_attr_change(
                NoticePlayerIds, ObjMonster#obj_scene_actor.obj_id,
                [{?P_MOVE_SPEED, MoveSpeed}, {?P_MOVE_TYPE, MoveTypeMoment}]
            );
        true -> noop
    end.
handle_monster_runaway(ObjMonster, State) ->
%%    put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, 300),

    #t_monster{type = MonsterType} = get_t_monster(ObjMonster#obj_scene_actor.base_id),
    if
        MonsterType =:= ?MONSTER_ACTIVE_ATTACK_MONSTER andalso ObjMonster#obj_scene_actor.status =:= ?MONSTER_STATUS_ATTACK ->
            #obj_scene_actor{obj_id = MonsterId, x = OldX, y = OldY, dir = OldDir} = ObjMonster,
            Dir = ?IF(OldDir >= ?DIR_DOWN, OldDir + ?DIR_DOWN, OldDir - ?DIR_DOWN),
            #scene_state{map_id = MapId} = State,
            Range = 200,
%%            Range = WarnRange * ?TILE_LEN,
            {X, Y} = util_math:get_direct_target_pos_by_direction(MapId, OldX, OldY, Dir * 45, Range),

            %% 清空追踪对象与仇恨列表
            NewObjMonster = ObjMonster#obj_scene_actor{track_info = #track_info{}, hate_list = []},
            ObjMonster_1 = ?UPDATE_OBJ_SCENE_MONSTER(NewObjMonster),
            ObjMonsterArrival = go_target_place(MonsterId, X, Y,
                fun() ->
                    ?GO_PATROL(ObjMonster_1, State)
                end,
                State),

%%            Distance = util_math:get_distance({X, Y}, {OldX, OldY}) * ?TILE_LEN,
%%            #t_monster{
%%                move_speed = MoveSpeed
%%            } = get_t_monster(ObjMonster#obj_scene_actor.base_id),

%%            NextHeartbeatTime = round(Distance / MoveSpeed),
            NextHeartbeatTime = 500,
            put(?DICT_MONSTER_NEXT_HEART_BEAT_TIME, NextHeartbeatTime),
            ObjMonsterArrival;
        true ->
            ObjMonster
    end.