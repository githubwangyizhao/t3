%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 6月 2021 下午 07:19:11
%%%-------------------------------------------------------------------
-module(mod_mission_boss_fight).
-author("Administrator").

-include("common.hrl").
-include("scene.hrl").
-include("mission.hrl").
-include("guess_boss.hrl").
-include("scene_monster.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("msg.hrl").
-include("fight.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("error.hrl").

-define(GUESS_BOSS_USE_SKILL, guess_boss_use_skill).
-define(GUESS_BOSS_ATTACKER, guess_boss_attacker).
-define(WHEN_DOSE_USE_SKILL, guess_boss_use_skill_timestamp).
-define(GUESS_BOSS_MAIN_TARGET, guess_boss_main_target).

%% API
-export([
    handle_navigate_result/2,
    reset_boss_skill/0,

    handle_robot_fight_each_other/1,
    guess_boss_fight/4,

    handle_guess_boss_heart_beat/2,

    get_nearest_monster_list/1
]).

handle_get_skill_target(Monster) ->
    #obj_scene_actor{
        obj_id = ObjId,
        base_id = _BossId,
        r_active_skill_list = SkillList
    } = Monster,
    SkillRecord =
        lists:filtermap(
            fun(Skill) ->
                #t_mission_guess_boss_skill{
                    type = SkillType
                } = Skill,
                if
                    SkillType =:= 2 -> {true, Skill};
                    true -> false
                end
            end,
            SkillList
        ),
    ?ASSERT(SkillRecord =/= [], none_skill),
    SkillInfo = hd(SkillRecord),
    #t_mission_guess_boss_skill{
        attack_range = _AttackRange,
        target_range_type = TargetRangeType,
        target_range = TargetRange,
        attack_count = AttackCount
    } = SkillInfo,

    MainTargetObjId = get_main_target(ObjId),
%%    ?DEBUG("MainTargetObjId: ~p", [MainTargetObjId]),
    ?ASSERT(MainTargetObjId =/= noop, target_dead),
    TargetObj = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, MainTargetObjId),
    ?ASSERT(TargetObj =/= ?UNDEFINED, target_dead),
%%    ?DEBUG("MainTargetObjId: ~p TargetRangeType: ~p ~p", [MainTargetObjId, TargetRangeType, ?IF(TargetRangeType =:= 1, ObjId, MainTargetObjId)]),

    SearchMonsterList =
        if
            TargetRangeType =:= 1 -> get_nearest_monster_list(ObjId);
            true -> get_nearest_monster_list(MainTargetObjId)
        end,
    %% 必须包含主目标，所以扣掉一个，方便加入主目标
    RealAttackCount = AttackCount - 1,
    lists:foldl(
        fun({Dis, EnemyObjId, {_EnemyPosX, _EnemyPosY, _EnemyMaxHp, EnemyCurrentHp, Enemy, _EnemyMoveSpeed}}, Tmp) ->
            TmpLength = length(Tmp),
%%            ?DEBUG("TmpLength: ~p ~p ~p ~p", [TmpLength, AttackCount, EnemyObjId, {Dis, TargetRange, EnemyCurrentHp}]),
            if
                TmpLength < RealAttackCount andalso EnemyObjId =/= ObjId andalso
                    EnemyCurrentHp > 0 andalso Dis =< TargetRange ->
                    [Enemy | Tmp];
                true -> Tmp
            end
        end,
        [TargetObj],
        SearchMonsterList
    ).

handle_guess_boss_get_main_target(Monster) ->
    #obj_scene_actor{
        obj_id = ObjId,
        base_id = _BossId,
        r_active_skill_list = SkillList,
        hp = _CurrentHp
    } = Monster,
    SkillRecord =
        lists:filtermap(
            fun(Skill) ->
                #t_mission_guess_boss_skill{
                    type = SkillType
                } = Skill,
                DoesBossUseSkill = use_skill(),
                if
                    DoesBossUseSkill =:= ?TRUE andalso SkillType =:= 2 -> {true, Skill};
                %% 普攻
                    DoesBossUseSkill =:= ?FALSE andalso SkillType =:= 1 -> {true, Skill};
                    true -> false % ?DEBUG("SkillType: ~p", [SkillType]),
                end
            end,
            SkillList
        ),
%%    ?DEBUG("~p(~p) SkillRecord: ~p", [ObjId, CurrentHp, SkillRecord]),
    ?ASSERT(SkillRecord =/= [], none_skill),
    SkillInfo = hd(SkillRecord),
    #t_mission_guess_boss_skill{
        attack_range = AttackRange,
        main_target_type = MainTargetType
    } = SkillInfo,

    %% 获取附近的boss
    NearestMonsterList = get_nearest_monster_list(ObjId),

    %% 选取主目标
    MainTargetList =
        lists:foldl(
            fun({Dis, EnemyObjId, {_EnemyPosX, _EnemyPosY, _EnemyMaxHp, EnemyCurrentHp, _Enemy, _EnemyMoveSpeed}}, Tmp) ->
%%                ?DEBUG("~p aaa: ~p", [ObjId, {EnemyObjId, Dis, AttackRange, MainTargetType, EnemyCurrentHp}]),
                if
                    MainTargetType =:= 1 andalso AttackRange =< Dis andalso EnemyCurrentHp > 0 ->
                        case lists:keyfind(random_attack, 1, Tmp) of
                            false -> lists:keystore(random_attack, 1, Tmp, {random_attack, [{EnemyObjId, 10000}]});
                            {random_attack, OldEnemyObjIdInTmp} ->
                                lists:keystore(random_attack, 1, Tmp, {random_attack, [{EnemyObjId, 10000} | OldEnemyObjIdInTmp]})
                        end;
                    MainTargetType =:= 1 andalso AttackRange > Dis andalso EnemyCurrentHp > 0 ->
                        case lists:keyfind(unique_attack, 1, Tmp) of
                            false -> lists:keystore(unique_attack, 1, Tmp, {unique_attack, [EnemyObjId]});
                            {unique_attack, OldEnemyObjIdInTmp} ->
                                lists:keystore(unique_attack, 1, Tmp, {unique_attack, [EnemyObjId | OldEnemyObjIdInTmp]})
                        end;
                    MainTargetType =/= 1 andalso EnemyCurrentHp > 0 ->
                        case lists:keyfind(random_attack, 1, Tmp) of
                            false -> lists:keystore(random_attack, 1, Tmp, {random_attack, [{EnemyObjId, 10000}]});
                            {random_attack, OldEnemyObjIdInTmp} ->
                                lists:keystore(random_attack, 1, Tmp, {random_attack, [{EnemyObjId, 10000} | OldEnemyObjIdInTmp]})
                        end;
                    true -> false
                end
            end,
            [],
            NearestMonsterList
        ),
%%    ?DEBUG("MainTargetList aaa: ~p ~p ~p", [ObjId, AttackRange, MainTargetList]),
    UniqueTargetList =
        case lists:keyfind(unique_attack, 1, MainTargetList) of
            false -> none;
            {unique_attack, UniqueTarget} -> hd(UniqueTarget) %% ?DEBUG("UniqueTargetList: ~p", [UniqueTarget]),
        end,
%%    ?DEBUG("ddd: ~p", [UniqueTargetList]),
    RealMainTarget =
        if
            UniqueTargetList =:= none ->
                case lists:keyfind(random_attack, 1, MainTargetList) of
                    false -> none;
                    {random_attack, RandomTarget} ->
                        util_random:get_probability_item(RandomTarget) %% lists:nth(1, RandomTarget)
                end;
            true -> UniqueTargetList
        end,
    ?ASSERT(RealMainTarget =/= none, none_target),
    %% 设置主目标
    set_main_target(ObjId, RealMainTarget),
    Monster.

handle_guess_boss_skill_attack(Monster, TargetList, State) ->
    ?ASSERT(is_record(Monster, obj_scene_actor), attacker_dead),
    #obj_scene_actor{
        obj_id = MonsterObjId,
        x = X,
        y = Y,
        r_active_skill_list = RActiveSkillList
    } = Monster,

    ?DEBUG("释放技能的boss: ~p", [MonsterObjId]),
%%    ?DEBUG("被技能打到的boss: ~p", [[TargetObjId || #obj_scene_actor{obj_id = TargetObjId} <- TargetList]]),

    %% 获取主目标
    MainTargetObjId = get_main_target(MonsterObjId),
    MainTarget = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, MainTargetObjId),
    #obj_scene_actor{
        obj_id = TargetObjId,
        obj_type = TargetObjType,
        x = TargetX,
        y = TargetY,
        hp = TargetCurrentHp
    } = MainTarget,

    NowMS = util_time:milli_timestamp(),

    %% 主目标已死
    {DoesTargetDead, MonsterObj} =
        if
            TargetCurrentHp =< 0 ->
%%                mod_scene_monster_manager:async_destroy_monster(TargetObjId, force),
                mod_scene_actor:delete_obj_scene_actor(TargetObjType, TargetObjId),
                del_main_target(MonsterObjId),
                NewMonster = Monster#obj_scene_actor{
                    next_can_heart_time = NowMS + 200
                },
                ?UPDATE_OBJ_SCENE_ACTOR(NewMonster),
                {?TRUE, NewMonster};
            true -> {?FALSE, Monster}
        end,
    ?ASSERT(DoesTargetDead =:= ?FALSE, {MonsterObj, null}),

    Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
    Dir = util_math:get_direction({X, Y}, {TargetX, TargetY}),

    #t_mission_guess_boss_skill{
        id = BossSkillId,
        attack_range = SkillDistance,
        attack_damage = AttachDamage,
        main_target_type = MainTargetType
%%        crit = Crit
    } = get_attack_info(RActiveSkillList, 2),

    %% 技能是否无视距离
    IgnoreDistance = ?IF(MainTargetType =:= 2, ?TRUE, ?FALSE),

    if
        Distance > SkillDistance andalso IgnoreDistance =:= ?FALSE ->
            ?DEBUG("移动(~p)去找~p(~p, ~p)在~p进行下一次心跳", [Distance, TargetObjId, TargetX, TargetY, util_time:timestamp_to_datetime((NowMS + 200) div ?SECOND_MS)]),
%%            #obj_scene_actor{
%%                x = CX,
%%                y = CY
%%            } = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, TargetObjId),
%%            ?DEBUG("~p(~p)目标位置(~p ~p) 主目标的位置(~p ~p) 追踪位置(~p ~p)", [MonsterObjId, TargetObjId, CX, CY, X, Y, TrackX, TrackY]),
            % 没到攻击距离，飞过去
            RealDiffDistance = SkillDistance - Distance,
%%            MonsterObjAfterDealMoveStep = mod_scene:deal_move_step(Monster, NowMS, State),
%%            NewMonster_1 = monster_find_path(Monster, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_MOMENT, State),
            NewMonster_1 = monster_find_path(Monster, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_SKILL, State),
            NewMonster_2 = NewMonster_1#obj_scene_actor{
                next_can_heart_time = NowMS + 200
            },
            ?UPDATE_OBJ_SCENE_MONSTER(NewMonster_2);
        true -> true
    end,

    put(?DICT_IS_FIGHT, true),
    put(fight_boss_notice_player, false),

    %% 设置下次使用技能的时间
    set_skill_timestamp(),
%%    RequestFightParam =
%%        #request_fight_param{
%%            attack_type = ?OBJ_TYPE_MONSTER,
%%            obj_type = ?OBJ_TYPE_MONSTER,
%%            obj_id = MonsterObjId,
%%            skill_id = BossSkillId,
%%            dir = Dir,
%%            target_type = TargetObjType,
%%            target_id = TargetObjId,
%%            cost = AttachDamage,
%%            rate = Crit
%%        },

    %% 初始化战报
    InitFightResult =
        #m_mission_notice_lucky_boss_fight_toc{
            attacker_type = ?OBJ_TYPE_MONSTER,
            attacker_id = MonsterObjId,
            x = X,
            y = Y,
            dir = Dir,
            target_type = TargetObjType,
            target_id = TargetObjId,
            skill_id = BossSkillId,
            skill_level = 0,
            defender_result_list = [],
            anger = 0
        },

%%    #request_fight_param{
%%%%        adjust_rate = _AdjustRate,
%%        server_adjust_rate = _ServerAdjustRate
%%    } = RequestFightParam,

%%    ?DEBUG("~p的技能~p最多只能攻击~p个目标(~p)", [MonsterObjId, BossSkillId, AttackCount, length(TargetList)]),

    SkillDefenderList =
        lists:foldl(
            fun(Enemy, Tmp) ->
                #obj_scene_actor{
                    obj_id = SkillTargetObjId,
                    obj_type = SkillTargetObjType,
                    x = _SkillTargetX,
                    y = _SkillTargetY,
                    hp = SkillTargetCurrentHp
                } = Enemy,
%%                ?DEBUG("被技能打到的boss: ~p", [SkillTargetObjId]),

                TargetAfterAttack = ?IF(SkillTargetCurrentHp - AttachDamage > 0, SkillTargetCurrentHp - AttachDamage, 0),
                %% 下发战报告知前端boss死亡
                ?DEBUG("技能伤害：~p(~p)  ~p - ~p = ~p", [MonsterObjId, SkillTargetObjId, SkillTargetCurrentHp, AttachDamage, TargetAfterAttack]),
                F = [#defenderresult{
                    defender_type = SkillTargetObjType,
                    defender_id = SkillTargetObjId,
                    x = 0,
                    y = 0,
                    hp = TargetAfterAttack,
                    hurt = AttachDamage,
                    type = ?P_NORMAL,
                    buff_list = [],
                    effect_list = [],
                    hurt_section_list = [],
                    total_mano = 0,
                    all_total_mano = 0,
                    beat_times = 1,
                    mano_award = 0,
                    exp = 0,
                    special_event = 0,
                    dizzy_close_time = 0
                } | Tmp],

                if
                    TargetAfterAttack =:= 0 ->
                        ?DEBUG("~p被秒了(技能)", [SkillTargetObjId]),
                        mod_scene_actor:delete_obj_scene_actor(TargetObjType, SkillTargetObjId);
%%                        mod_scene_monster_manager:async_destroy_monster(TargetObjId, force);
                    true ->
                        Enemy2 = Enemy#obj_scene_actor{hp = TargetAfterAttack},
                        ?UPDATE_OBJ_SCENE_MONSTER(Enemy2)
                end,
                F
            end,
            [],
            TargetList
        ),
%%    ?DEBUG("defenderResult len: ~p ~p", [length(SkillDefenderList), SkillDefenderList]),

    %% 生成战报
    #m_mission_notice_lucky_boss_fight_toc{
        defender_result_list = DefenderResultList
    } = InitFightResult,
    NewFightResult = InitFightResult#m_mission_notice_lucky_boss_fight_toc{
        defender_result_list = SkillDefenderList ++ DefenderResultList
    },

    %% 通知战报
    NoticePlayerIdList = mod_mission_guess_boss:get_player_id_list(),
    if
        length(NoticePlayerIdList) > 0 ->
            notice_fight_result(NoticePlayerIdList, NewFightResult);
        true -> true
    end,

    %% 修改monster的下一次心跳时间
    #t_mission_guess_boss_skill{
        attack_time = AttackInterval
    } = get_attack_info(RActiveSkillList, 1),

    NewMonsterObj = MonsterObj#obj_scene_actor{
        last_fight_skill_id = BossSkillId,
        last_fight_time_ms = NowMS,
        next_can_heart_time = NowMS + AttackInterval
    },
    ?UPDATE_OBJ_SCENE_ACTOR(NewMonsterObj),

    {NewMonsterObj, MainTarget}.

handle_guess_boss_attack(Monster, Target, State) ->
    ?ASSERT(is_record(Monster, obj_scene_actor), attacker_dead),
    ?ASSERT(is_record(Target, obj_scene_actor), target_dead),
    put(?DICT_IS_FIGHT, true),
    #obj_scene_actor{
        obj_type = TargetObjType,
        obj_id = TargetObjId,
        x = TargetX,
        hp = TargetCurrentHp,
        y = TargetY,
        go_x = _TargetGoX,
        go_y = _TargetGoY,
        move_path = _TargetMovePath
    } = Target,

    #obj_scene_actor{
        obj_id = RobotId,
        base_id = _Id,
        x = X,
        y = Y,
%%        move_path = MovePath,
        last_fight_time_ms = LastFightTime,
        last_fight_skill_id = LastSkillId,
        r_active_skill_list = RActiveSkillList,
        move_type = _MoveType,
%%        track_info = #track_info{x = TrackX, y = TrackY},
        can_use_skill_time = CanUseSkillTime,
%%        next_can_heart_time = OldNextCanHeartTime,
        move_speed = MoveSpeed
    } = Monster,

    NowMS = util_time:milli_timestamp(),

    %% 目标已死
    {DoesTargetDead, MonsterObj} =
        if
            TargetCurrentHp =< 0 ->
%%                mod_scene_monster_manager:async_destroy_monster(TargetObjId, force),
                mod_scene_actor:delete_obj_scene_actor(TargetObjType, TargetObjId),
%%                del_main_target(RobotId, TargetObjId),
                del_main_target(RobotId),
                NewMonster = Monster#obj_scene_actor{
                    next_can_heart_time = NowMS + 200
                },
                ?UPDATE_OBJ_SCENE_ACTOR(NewMonster),
                {?TRUE, NewMonster};
            true -> {?FALSE, Monster}
        end,
    ?ASSERT(DoesTargetDead =:= ?FALSE, {MonsterObj, Target}),

    RealActiveSkillList =
        lists:filtermap(
            fun(SingleSkillInfo) ->
                #t_mission_guess_boss_skill{
                    type = Type
                } = SingleSkillInfo,
                if
                    Type =:= 1 -> {true, SingleSkillInfo};
                    true -> false
                end
            end,
            RActiveSkillList
        ),

    #t_mission_guess_boss_skill{
%%        id = BossSkillId,
        attack_range = SkillDistance,
        attack_time = AttackInterval,
        crit = Crit
    } = hd(RealActiveSkillList),


%%    RealTargetX = ?IF(TrackX =:= 0, TargetX, TrackX),
%%    RealTargetY = ?IF(TrackY =:= 0, TargetY, TrackY),
    Distance = util_math:get_distance({X, Y}, {TargetX, TargetY}),
%%    RealLastFightTime = ?IF(LastFightTime =:= 0, NowMS, LastFightTime),
%%    RealOldNextHeartTime = ?IF(OldNextCanHeartTime =:= 0, NowMS, OldNextCanHeartTime),
%%    ?DEBUG("~p(~p ~p)(~p)<~p>(~p ~p)的攻击间隔是：~p 上次攻击时间~p, (~p ~p)",
%%        [RobotId, X, Y, BossSkillId, TargetObjId, TargetX, TargetY, AttackInterval,
%%        util_time:timestamp_to_datetime(RealLastFightTime div ?SECOND_MS), Distance, SkillDistance]),
%%    ?DEBUG("下次攻击时间: ~p", [
%%        util_time:timestamp_to_datetime((RealLastFightTime + AttackInterval) div ?SECOND_MS)]),
    if
        Distance =< SkillDistance ->
            Monster_1 = stop_move(Monster, State),
            Dir = util_math:get_direction({X, Y}, {TargetX, TargetY}),
            case get_guess_boss_skill_info(CanUseSkillTime, NowMS, LastSkillId, LastFightTime, RealActiveSkillList) of
                null ->
%%                    ?DEBUG("还不能攻击，在~p进行下一次心跳", [util_time:timestamp_to_datetime((NowMS + AttackInterval) div ?SECOND_MS)]),
                    %% 还不能攻击
                    NewMonster_1 = Monster_1#obj_scene_actor{
                        next_can_heart_time = NowMS + AttackInterval
                    },
                    ?UPDATE_OBJ_SCENE_ACTOR(NewMonster_1),
                    {NewMonster_1, Target};
                RActiveSkill ->
                    ?DEBUG("可以攻击，在~p进行下一次心跳", [util_time:timestamp_to_datetime((NowMS + AttackInterval) div ?SECOND_MS)]),
                    #t_mission_guess_boss_skill{
                        id = SkillId,
                        type = _SkillType,
                        %% 测试用 damage * 20
                        attack_damage = AttackDamage,
%%                        attack_damage = AAttackDamage,
                        crit = Crit
                    } = RActiveSkill,
%%                    AttackDamage = AAttackDamage * 20,

                    RequestFightParam =
                        #request_fight_param{
                            attack_type = ?OBJ_TYPE_MONSTER,
                            obj_type = ?OBJ_TYPE_MONSTER,
                            obj_id = RobotId,
                            skill_id = SkillId,
                            dir = Dir,
                            target_type = TargetObjType,
                            target_id = TargetObjId,
                            cost = AttackDamage,
                            rate = Crit
                        },
                    NewMonster_1 = Monster_1#obj_scene_actor{
                        last_fight_skill_id = SkillId,
                        last_fight_time_ms = NowMS,
                        next_can_heart_time = NowMS + AttackInterval
                    },
                    ?UPDATE_OBJ_SCENE_MONSTER(NewMonster_1),
                    guess_boss_fight(RequestFightParam, NewMonster_1, Target, State)
%%                    guess_boss_fight_new(RequestFightParam, NewMonster_1, Target, State),
%%                    {NewMonster_1, Target}
            end;
        true ->
%%        Distance < 200 andalso Distance > SkillDistance ->
%%        Distance < 400 andalso Distance > SkillDistance ->
            ?DEBUG("移动(~p{~p})去找~p(~p, ~p)在~p进行下一次心跳(~p)", [Distance, {RobotId, X, Y}, TargetObjId, TargetX, TargetY, util_time:timestamp_to_datetime((NowMS + 200) div ?SECOND_MS), MoveSpeed]),
%%            #obj_scene_actor{
%%                x = CX,
%%                y = CY
%%            } = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, TargetObjId),
%%            ?DEBUG("~p(~p)目标位置(~p ~p) 我的位置(~p ~p) 追踪位置(~p ~p)", [RobotId, TargetObjId, CX, CY, X, Y, TrackX, TrackY]),
            % 没到攻击距离，走过去
            RealDiffDistance = SkillDistance - Distance,
%%            MonsterObjAfterDealMoveStep = mod_scene:deal_move_step(Monster, NowMS, State),
%%            NewMonster_1 = monster_find_path(Monster, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_MOMENT, State),
            NewMonster_1 = monster_find_path(Monster, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_NORMAL, State),
            NewMonster_2 = NewMonster_1#obj_scene_actor{
                next_can_heart_time = NowMS + 200
            },
            ?UPDATE_OBJ_SCENE_MONSTER(NewMonster_2),
            {NewMonster_2, Target}
%%        true ->
%%            TargetMoveDis = util_math:get_distance({TargetX, TargetY}, {TrackX, TrackY}),
%%            NewMonster_1 =
%%                if
%%                    MovePath == [] orelse TargetMoveDis > 80 ->
%%                        ?DEBUG("move(~p)去找~p(~p, ~p)在~p进行下一次心跳", [Distance, TargetObjId, TargetX, TargetY,
%%                            util_time:timestamp_to_datetime((NowMS + 1000) div ?SECOND_MS)]),
%%
%%                        DiffDistance = 180,
    %%                    #scene_state{
    %%                        scene_navigate_worker = Ss
    %%                    } = State,
%%                        Monster_1 = monster_find_path(Monster, {TargetX, TargetY}, true, DiffDistance, ?MOVE_TYPE_NORMAL, State),
%%                        #obj_scene_actor{
%%                            go_x = GoX,
%%                            go_y = GoY,
%%                            move_path = MovePath
%%                        } = Monster_1,
    %%                    ?DEBUG("Monster_1 go to: ~p (~p, ~p) to (~p, ~p) ~p", [RobotId, X, Y, GoX, GoY, MovePath]),
%%                        Monster_1#obj_scene_actor{
%%                            next_can_heart_time = RealOldNextHeartTime + 1000,
%%                            track_info = #track_info{
%%                                obj_type = TargetObjType,
%%                                obj_id = TargetObjId,
%%                                x = TargetX,
%%                                y = TargetY
%%                            }
%%                        },
%%                        Monster_1;
%%                    true ->
%%                        #obj_scene_actor{
%%                            next_can_heart_time = OldNextCanHeartTime,
%%                            move_speed = MoveSpeed,
%%                            move_path = MovePath
%%                        } = Monster,
%%                        ?DEBUG("~p TargetMoveDis <= 80 or else movePath == [], ~p", [RobotId, {
%%                            TargetMoveDis, MoveSpeed, MovePath, util_time:timestamp_to_datetime(OldNextCanHeartTime div ?SECOND_MS)
%%                        }]),
%%                        Monster
%%                end,
%%            ?UPDATE_OBJ_SCENE_MONSTER(NewMonster_1),
%%            {NewMonster_1, Target}
    end.

handle_defender_change_target(DefenderSceneActor, AttackerSceneActor) ->
    #obj_scene_actor{
        x = DefenderX,
        y = DefenderY,
        obj_id = DefenderObjId,
        r_active_skill_list = RActiveSkillList
    } = DefenderSceneActor,

    #obj_scene_actor{
        x = AttackerX,
        y = AttackerY,
        obj_id = AttackerObjId
    } = AttackerSceneActor,

    NewMainTargetObjId =
        case get_main_target(DefenderObjId) of
            noop -> AttackerObjId;
            DefenderMainTargetObjId ->
                ?ASSERT(DefenderMainTargetObjId =/= AttackerObjId, same_target),
                ?DEBUG("defender: ~p(~p, ~p) attacker: ~p(~p, ~p)", [DefenderObjId, DefenderX, DefenderY, AttackerObjId, AttackerX, AttackerY]),
                Dis = util_math:get_distance({DefenderX, DefenderY}, {AttackerX, AttackerY}),
                SkillTypeList =
                    lists:filtermap(
                        fun(Skill) ->
                            #t_mission_guess_boss_skill{
                                attack_range = AttackRange,
                                type = SkillType
                            } = Skill,
                            if
                            %% 攻击者在受击者的普攻范围内，且不是受击者的主目标时，有概率切换为受击者的主目标
                                AttackRange >= Dis andalso SkillType =:= 1 andalso DefenderMainTargetObjId =/= AttackerObjId ->
                                    ?DEBUG("Dis: ~p AttackRange: ~p(~p)", [Dis, AttackRange, SkillType]),
                                    {true, SkillType};
                                true -> false
                            end
                        end,
                        RActiveSkillList
                    ),
                OldDefenderMainTargetObjId = get_main_target(DefenderObjId),
                SkillTypeListLength = length(SkillTypeList),
                if
                    SkillTypeListLength =< 0 andalso OldDefenderMainTargetObjId =/= noop -> exit(distance_not_enough);
                    SkillTypeListLength =< 0 andalso OldDefenderMainTargetObjId =:= noop -> AttackerObjId;
                    true ->
                        MainTargetList = [
                            [AttackerObjId, 1, ?SD_GUESS_BOSS_HURT_CHANGETARGET_PER, 10000],
                            [DefenderMainTargetObjId, 1, 10000 - ?SD_GUESS_BOSS_HURT_CHANGETARGET_PER, 10000]
                        ],
                        {NewMainTarget, _, Rate} = util_random:get_probability_item_2(MainTargetList),
                        ?DEBUG("更换目标: ~p", [{NewMainTarget, Rate}]),
                        NewMainTarget
%%                        MainTargetList = [
%%                            {AttackerObjId, ?SD_GUESS_BOSS_HURT_CHANGETARGET_PER},
%%                            {DefenderMainTargetObjId, 10000 - ?SD_GUESS_BOSS_HURT_CHANGETARGET_PER}
%%                        ],
%%                        util_random:get_probability_item(MainTargetList)
                end
        end,
    ?ASSERT(NewMainTargetObjId =:= AttackerObjId, no_necessary_change_main_target),
    set_main_target(DefenderObjId, NewMainTargetObjId).

handle_guess_boss_heart_beat(ObjId, State = #scene_state{scene_id = _SceneId}) ->
    Monster = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, ObjId),
    ?ASSERT(Monster =/= ?UNDEFINED, heart_beat_obj_dead),
%%    #obj_scene_actor{
%%        x = _X,
%%        y = _Y,
%%        base_id = _BossId,
%%        next_can_heart_time = _OldNextCanHeartTime,
%%        r_active_skill_list = _SkillList,
%%        last_fight_time_ms = _LastFightTimeMs,
%%        last_move_time = _LastMoveTime,
%%        last_attacked_time_ms = _LastAttackedTimeMs
%%    } = Monster,
%%    Now = get(?DICT_NOW_MS),
    Now = util_time:milli_timestamp(),
%%    ?DEBUG("~p next heart beat time ~p(~p)", [ObjId, OldNextCanHeartTime, Now]),
%%    ?DEBUG("~p all kinds of timestamp (~p)", [ObjId, {LastFightTimeMs, LastMoveTime, LastAttackedTimeMs}]),

    %% 找到主目标
    FindTargetMonsterObj =
        case get_main_target(ObjId) of
            noop ->
                case catch handle_guess_boss_get_main_target(Monster) of
                    {'EXIT', _GetMainTargetError} ->
%%                        ?DEBUG("~p在寻找主目标时报错(~p)", [ObjId, GetMainTargetError]),
                        main_target_none;
                    _ ->
%%                        ?DEBUG("eee: ~p", [M]),
                        case get_main_target(ObjId) of
                            noop -> main_target_none;
                            NewMainTarget -> ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, NewMainTarget)
                        end
                end;
            MainTarget ->
                case ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, MainTarget) of
                    ?UNDEFINED ->
%%                        ?DEBUG("~p的主目标死了~p", [ObjId, MainTarget]),
                        del_main_target(ObjId),
                        handle_guess_boss_heart_beat(ObjId, State);
                    TargetOBjSceneActor -> TargetOBjSceneActor
                end
        end,
    TargetMonsterObj =
        if
            FindTargetMonsterObj =:= main_target_none ->
                %% 结算
                ?DEBUG("~p结算 ~p", [ObjId, get(?GUESS_MISSION_STATE)]),
%%                {GuessBossStatue, _Time} = get(?GUESS_MISSION_STATE),
%%                ?ASSERT(GuessBossStatue =:= 2, already_empty),
%%                put(fighting, ?FALSE),
%%                put(?GUESS_MISSION_STATE, {?FALSE, util_time:milli_timestamp()}),
                empty;
            true -> FindTargetMonsterObj
        end,
    ?ASSERT(TargetMonsterObj =/= empty, empty),

    %% 是否使用技能
    UseSkill = use_skill(),

    {NextCanHeartTime, Ticker, _AttackerSceneActorObj, NewTargetSceneActorObj} =
        if
            UseSkill =:= ?TRUE ->
%%                ?DEBUG("~p 使用技能", [ObjId]),
                SkillMonsterList = handle_get_skill_target(Monster),
%%                ?DEBUG("攻击 ~p ", [[{DefenderMonsterObjId, DefenderMonsterHp} || #obj_scene_actor{obj_id = DefenderMonsterObjId, hp = DefenderMonsterHp} <- SkillMonsterList]]),
                {MonsterAfterAttack, MainTargetAfterAttack} = handle_guess_boss_skill_attack(Monster, SkillMonsterList, State),
                #obj_scene_actor{
                    next_can_heart_time = NextHeartTime
                } = MonsterAfterAttack,
                put(?DICT_IS_FIGHT, false),
                {NextHeartTime, ?IF(NextHeartTime - Now =< 0, 2000, NextHeartTime - Now), MonsterAfterAttack, MainTargetAfterAttack};
            true ->
                {MonsterAfterAttack, NewTargetAfterAttack} = handle_guess_boss_attack(Monster, TargetMonsterObj, State),
                #obj_scene_actor{
                    next_can_heart_time = NextHeartTime
                } = MonsterAfterAttack,
                put(?DICT_IS_FIGHT, false),
                {NextHeartTime, ?IF(NextHeartTime - Now < 0, 1000, NextHeartTime - Now), MonsterAfterAttack, NewTargetAfterAttack}
        end,

    ?DEBUG("fff: ~p", [{NewTargetSceneActorObj =/= ?FALSE andalso NewTargetSceneActorObj =/= null, ObjId, Ticker, NextCanHeartTime,
        util_time:timestamp_to_datetime(NextCanHeartTime div ?SECOND_MS), util_time:timestamp_to_datetime((NextCanHeartTime + Ticker) div ?SECOND_MS)}]),
    if
        NewTargetSceneActorObj =/= ?FALSE andalso NewTargetSceneActorObj =/= null ->
            case catch handle_defender_change_target(TargetMonsterObj, Monster) of
                {'EXIT', _ChangeMainTargetError} ->
%%                    #obj_scene_actor{
%%                        obj_id = AttackerObjId
%%                    } = AttackerSceneActorObj,
                    #obj_scene_actor{
%%                        obj_id = DefenderObjId
                    } = TargetMonsterObj;
%%                    ?DEBUG("受击者~p不能将主目标切换为~p(~p)", [DefenderObjId, AttackerObjId, ChangeMainTargetError]);
                Res -> ?DEBUG("新的主目标列表: ~p", [Res])
            end;
        true -> false %% ?DEBUG("不需要切换主目标，可能是不需要，也可能是死了"),
    end,

%%    ?DEBUG("~p NextCanHeartTime: ~p ~p", [ObjId, NextCanHeartTime, Ticker]),

    erlang:send_after(Ticker, self(), {?MSG_GUESS_BOSS_HEART_BEAT, ObjId}).

handle_robot_fight_each_other(_State = #scene_state{is_mission = IsMission, scene_id = _SceneId}) ->
    {GuessState, _Time} = get(?GUESS_MISSION_STATE),
    {IsContinue, MonsterList} =
        if IsMission ->
            case GuessState of
                2 ->
                    ?DEBUG("还在投注"),
                    {false, []};
                ?FALSE ->
                    ?DEBUG("还在等待生成boss"),
                    {false, []};
                ?TRUE ->
%%                    ?DEBUG("winner: ~p", [get(guess_boss_winner)]),
                    %% 清理怪物主目标
                    put(?GUESS_BOSS_MAIN_TARGET, ?UNDEFINED),
                    %% 设置使用技能的时间
                    set_skill_timestamp(),

                    AliveMonstersList =
                        lists:filtermap(
                            fun(MonObjId) ->
                                Robot = mod_scene_monster_manager:get_obj_scene_monster(MonObjId),
                                #obj_scene_actor{
                                    hp = CurrentHp, obj_type = TargetObjType, obj_id = TargetObjId
                                } = Robot,
                                if
                                    CurrentHp > 0 -> {true, Robot};
                                    true ->
                                        mod_scene_actor:delete_obj_scene_actor(TargetObjType, TargetObjId),
                                        false
                                end
%%                                ?IF(CurrentHp >= 0, {true, Robot}, false)
                            end,
                            mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER)
                        ),
                    {true, AliveMonstersList}
            end;
            true ->
                {false, []}
        end,
    ?ASSERT(IsContinue =:= true, false),
%%    ?DEBUG("当前还活着的目标数量: ~p", [[ObjId || #obj_scene_actor{obj_id = ObjId} <- MonsterList]]),
    Continue =
        if
            length(MonsterList) =< 1 ->
%%                ?DEBUG("结算"),
                ?DEBUG("结算 ~p", [get(?GUESS_MISSION_STATE)]),
                {GuessBossStatue, _Time} = get(?GUESS_MISSION_STATE),
                ?ASSERT(GuessBossStatue =/= ?FALSE, already_empty),
                put(fighting, ?FALSE),
                put(?GUESS_MISSION_STATE, {2, util_time:milli_timestamp()}),
                empty;
            true -> true
        end,
    ?ASSERT(Continue =:= true, Continue),
    lists:foreach(
        fun(Monster) ->
            #obj_scene_actor{
                obj_id = ObjId
            } = Monster,

            %% 生成对应进程
%%            self() ! {?MSG_START_GUESS_BOSS_THREAD, ObjId}
            self() ! {?MSG_GUESS_BOSS_HEART_BEAT, ObjId}
        end,
        MonsterList
    ),
    ok.

%% ----------------------------------------------------- 私有方法 -------------------------------------------------------

get_main_target(ObjId) ->
    case get(?GUESS_BOSS_MAIN_TARGET) of
        ?UNDEFINED -> noop;
        MainTargetList ->
            case lists:keyfind(ObjId, 1, MainTargetList) of
                {_ObjIdInDict, MainTarget} -> MainTarget;
                false -> noop
            end
    end.

del_main_target(ObjId) ->
    case get(?GUESS_BOSS_MAIN_TARGET) of
        ?UNDEFINED -> ok;
        MainTargetList ->
            case lists:keyfind(ObjId, 1, MainTargetList) of
                false -> ok;
                {OldObjId, OldMainTargetObjId} ->
                    ?DEBUG("~p(~p)原来的主目标是:~p", [ObjId, OldObjId, OldMainTargetObjId]),
                    put(?GUESS_BOSS_MAIN_TARGET, lists:keydelete(ObjId, 1, MainTargetList)),
                    get(?GUESS_BOSS_MAIN_TARGET)
            end
    end.

set_main_target(ObjId, MainTargetObjId) ->
    case get(?GUESS_BOSS_MAIN_TARGET) of
        ?UNDEFINED ->
            put(?GUESS_BOSS_MAIN_TARGET, [{ObjId, MainTargetObjId}]);
        MainTargetList ->
            case lists:keyfind(ObjId, 1, MainTargetList) of
                false -> put(?GUESS_BOSS_MAIN_TARGET, [{ObjId, MainTargetObjId} | MainTargetList]);
                {_OldObjId, OldMainTargetObjId} ->
                    if
                    %% ObjId的主目标没有发生变化
                        OldMainTargetObjId =:= MainTargetObjId -> ?UNDEFINED;
                    %% ObjId的主目标发生变化
                        true ->
                            put(?GUESS_BOSS_MAIN_TARGET, lists:keyreplace(ObjId, 1, MainTargetList, {ObjId, MainTargetObjId}))
                    end
            end
    end.

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

monster_find_path(Robot, {TargetX, TargetY}, IsFloyd, Diff, MoveType, #scene_state{scene_id = _SceneId, scene_navigate_worker = NavigateWorker}) ->
    #obj_scene_actor{
        obj_id = ObjMonsterId,
        x = X,
        y = Y
    } = Robot,
    MaxNavigateNode = 1500,
%%    ?DEBUG("机器人寻路：~p", [Robot#obj_scene_actor.obj_id]),
    scene_navigate_worker:request_navigate(NavigateWorker, ?OBJ_TYPE_MONSTER, ObjMonsterId, {X, Y}, {TargetX, TargetY}, IsFloyd, true, MaxNavigateNode, Diff),
%%    ?DEBUG("MoveType: ~p ~p", [MoveType, {NavigateWorker, ?OBJ_TYPE_MONSTER, ObjMonsterId, {X, Y}, {TargetX, TargetY}, IsFloyd, true, MaxNavigateNode, Diff}]),
    Robot#obj_scene_actor{
        is_wait_navigate = true,
        move_type = MoveType
    }.

winner_action(ObjId, TargetObjId) ->
%%    ?DEBUG("winner: ~p objId: ~p targetObjId: ~p", [get(guess_boss_winner), ObjId, TargetObjId]),
    WinnerAction = ?IF(get(guess_boss_winner) =:= ObjId, attack, ?IF(TargetObjId =:= get(guess_boss_winner), defensive, null)),
    if
        WinnerAction =:= null -> null;
        true ->
            #obj_scene_actor{base_id = WinnerBossId} = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, get(guess_boss_winner)),
            #t_monster{
                attack = _Attack,                               %% 攻击
                defense = _Defense,                             %% 防御
                hit = _Hit,                                     %% 命中
                dodge = Dodge,                                  %% 闪避
                crit = Crit,                                    %% 暴击
                crit_time = _CritTime,                          %% 暴击时长
                hurt_add = _HurtAdd,                            %% 伤害加成
                hurt_reduce = _HurtReduce                       %% 伤害减免
            } = t_monster:get({WinnerBossId}),
            Multiple = util_random:random_number(5, 10),
            case WinnerAction of
                attack ->
                    {attack, {?IF(Crit =:= 0, 100, Crit) * Multiple}};
                defensive ->
                    {defensive, {?IF(Dodge =:= 0, 100, Dodge) * Multiple}}
            end
    end.

guess_boss_fight(RequestFightParam, ObjSceneActor, TargetObjSceneActor, _State) ->
    %% 设置战斗过程标识
    put(?DICT_IS_FIGHT, true),
    put(fight_boss_notice_player, false),

    %% 检验副本中是否可以释放技能
    #request_fight_param{
        attack_type = _AttackType,
        obj_type = ObjType,
        obj_id = ObjId,
        skill_id = SkillId0,
        skill_level = _SkillLevel,
        dir = Dir,
        target_type = TargetObjType,
        target_id = TargetObjId,
        balance_round = NowBalanceRound,
        cost = Cost,
        player_left_coin = _LeftMano,
        rate = FRate,
%%        adjust_rate = AdjustRate,
%%        server_adjust_rate = ServerAdjustRate,
        skill_point_list = SkillPointList
    } = RequestFightParam,

    NowMS = util_time:milli_timestamp(),
    put(?DICT_NOW_MS, NowMS),

    #obj_scene_actor{
        obj_id = AttackerObjId,
        x = X,
        y = Y,
        r_active_skill_list = RActiveSkillList,
        hp = Hp,
        pk_mode = PkMode
    } = ObjSceneActor,

    if FRate > 1 ->
        noop;
        true ->
            noop
    end,

    ?ASSERT(Hp > 0, target_dead),
    ?ASSERT({ObjType, ObjId} =/= {TargetObjType, TargetObjId}, can_not_attack_myself),
    SkillId = SkillId0,

    put(?DICT_FIGHT_SKILL_ID, SkillId),
    put(?DICT_FIGHT_BALANCE_ROUND, NowBalanceRound),

    %% 初始化战报
    InitFightResult =
        #m_mission_notice_lucky_boss_fight_toc{
%%    #m_fight_notice_fight_result_toc{
            attacker_type = ObjType,
            attacker_id = ObjId,
            x = X,
            y = Y,
            dir = Dir,
            target_type = TargetObjType,
            target_id = TargetObjId,
            skill_id = SkillId,
            skill_level = 0,
            defender_result_list = [],
            anger = 0
        },

    #t_mission_guess_boss_skill{
        id = SkillIdInEts,
        type = Type,
        attack_range = AttackRange,                          %% 攻击距离
        attack_damage = _SkillDamage,
        attack_count = AttackCount
    } = t_mission_guess_boss_skill:get({SkillId}),

    SkillTarget = 0,
    %% 初始化战斗参数
    FightParam =
        #fight_param{
            obj_scene_actor = ObjSceneActor,
            balance_round = NowBalanceRound,
            skill_point_list =
            case SkillPointList of
                [] -> [{X, Y}];
                _ -> SkillPointList
            end,
            dir = Dir,
            skill_id = SkillId,
            skill_level = 1,
            skill_target_num = 1,
            skill_beat_back = 0,
            skill_is_circular = 0,
            skill_hurt_rate = 0,
            skill_ignore_defense_hurt = 0,
            skill_attack_length = AttackRange,
            skill_merge_balance_grid_list = [],
            skill_balance_hurt_rate = 1,
            skill_balance_type = 1,
            skill_target = SkillTarget,
            target_obj_type = TargetObjType,
            target_obj_id = TargetObjId,
            fight_result = InitFightResult,
            is_common_skill = 1,
            pk_mode = PkMode
%%            adjust_rate = ?IF(get(?DICT_SCENE_TYPE) == ?SCENE_TYPE_WORLD_SCENE, AdjustRate, 10000),
%%            server_adjust_rate = ?IF(get(?DICT_SCENE_TYPE) == ?SCENE_TYPE_WORLD_SCENE, ServerAdjustRate, 10000)
        },

    %% 获取攻击对象队列
    FightObjQueue = mod_fight:get_fight_obj_queue(FightParam),
    %% 处理攻击对象队列
%%    ResultFightParam = mod_fight:handle_fight_queue(FightParam, FightObjQueue),
    ResultFightParam = handle_fight_queue(FightParam, FightObjQueue),
    #fight_param{
        obj_scene_actor = ObjSceneActor_1,
        fight_result = FightResult
    } = ResultFightParam,
    %% 更新技能属性
    NewActiveSkillList = RActiveSkillList,

    {NewFightResult, _EnemyDead, ReturnObjSceneActor, ReturnTargetObjSceneActor} =
        if
            Type =:= 2 ->
                ?DEBUG("~p的技能~p最多只能攻击~p个目标", [ObjId, SkillIdInEts, AttackCount]),
                {FightResult, ?TRUE, ObjSceneActor_1, TargetObjSceneActor};
            true ->
                #obj_scene_actor{
                    obj_id = _TargetBaseId,
                    x = TargetX,
                    y = TargetY,
                    dir = _TargetDir,
                    hp = OldTargetHp,
                    max_hp = OldTargetMaxHp
                } = TargetObjSceneActor,

                NewObjSceneActor = ObjSceneActor_1#obj_scene_actor{
                    r_active_skill_list = NewActiveSkillList,
                    last_fight_time_ms = NowMS
                },
                ?UPDATE_OBJ_SCENE_MONSTER(NewObjSceneActor),

                %% 更新猜一猜boss对象
                TargetObjCurrentHp = ?IF(OldTargetHp - Cost >= 0, OldTargetHp - Cost, 0),
                ?DEBUG("~p攻击~p(~p - ~p) = ~p ~p", [ObjId, TargetObjId, OldTargetHp, Cost, TargetObjCurrentHp, util_time:milli_timestamp()]),

                O =
                    case winner_action(ObjId, TargetObjId) of
                        {Action, NewCrit} when Action =:= attack ->
                            ?DEBUG("~p是攻击者(~p ~p)，获得加成~p ~p", [get(guess_boss_winner), ObjId, TargetObjId, Action, NewCrit]),
                            ok;
                        {Action, NewDodge} when Action =:= defensive ->
                            %% 300 100 => 1 - 200 / 300
                            MinHp = util:to_int(OldTargetMaxHp * 0.3),
                            DodgeRate =
                                if
                                    TargetObjCurrentHp =< MinHp ->
                                        (1 - (TargetObjCurrentHp / MinHp)) * 100;
                                    true -> 0
                                end,
                            ?DEBUG("~p是防守者(~p)，有~p的概率获得闪避加成(~p)", [get(guess_boss_winner), ObjId, DodgeRate, NewDodge]),
                            ok;
                        null -> ?DEBUG("~p既不是防守者也不是进攻者", [get(guess_boss_winner)]), failure
                    end,
                ?DEBUG("O: ~p 击退: ~p", [O, {AttackerObjId, TargetX, TargetY}]),

                DefenderResult = #defenderresult{
                    defender_type = TargetObjType,
                    defender_id = TargetObjId,
                    x = TargetX,
                    y = TargetY,
                    hp = TargetObjCurrentHp,
                    hurt = 0,
                    type = ?P_NORMAL,
%%                    type = ?P_CRIT,
                    buff_list = [],
                    effect_list = [],
                    hurt_section_list = [],
                    total_mano = 0,
                    all_total_mano = 0,
                    beat_times = 0,
                    mano_award = 0,
                    exp = 0,
                    special_event = 0,
                    dizzy_close_time = 0
                },

                {TargetDead, NewTargetObjSceneActor} =
                    if
                        TargetObjCurrentHp =:= 0 ->
                            mod_scene_actor:delete_obj_scene_actor(TargetObjType, TargetObjId),
                            ?DEBUG("~p被秒了~p，去找下一个打。还剩~p", [TargetObjId, ObjId, mod_scene_monster_manager:get_all_obj_scene_monster_id()]),
%%                            erlang:send_after(200, self(), {?MSG_SCENE_ROBOT_FIGHT});
                            {?TRUE, null};
                        true ->
                            TargetObjSceneActor2 = TargetObjSceneActor#obj_scene_actor{hp = TargetObjCurrentHp},
                            ?UPDATE_OBJ_SCENE_MONSTER(TargetObjSceneActor2),
%%                            self() ! {?MSG_SCENE_ROBOT_FIGHT_WITH_TARGET, ObjId, TargetObjId}
                            {?FALSE, TargetObjSceneActor2}
                    end,
%%                {mod_fight:append_fight_result(FightResult, DefenderResult), TargetDead, ObjId, TargetObjId}
                if
                    TargetDead =:= ?TRUE ->
                        %% 受击目标死亡，删除攻击者的主目标
                        ?DEBUG("~p删除主目标后的主目标列表: ~p", [AttackerObjId, del_main_target(AttackerObjId)]);
                    true -> ok
                end,
                {append_fight_result(FightResult, DefenderResult), TargetDead, NewObjSceneActor, NewTargetObjSceneActor}
        end,

%%    ?DEBUG("NewFightResult: ~p", [NewFightResult]),
    %% 通知战报
    NoticePlayerIdList = mod_mission_guess_boss:get_player_id_list(),
    if
        length(NoticePlayerIdList) > 0 ->
%%            ?DEBUG("~p场景内还有几个boss：~p", [?OBJ_TYPE_MONSTER, mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER)]),
            notice_fight_result(NoticePlayerIdList, NewFightResult);
        true -> true
    end,

    {ReturnObjSceneActor, ReturnTargetObjSceneActor}.

%% ----------------------------------
%% @doc 	通知战斗结果
%% @throws 	none
%% @end
%% ----------------------------------
notice_fight_result(PlayerIdIdList, FightResult) ->
%%    #m_fight_notice_fight_result_toc{
    #m_mission_notice_lucky_boss_fight_toc{
        attacker_id = AttackerId,
        skill_id = SkillId,
        defender_result_list = DefList
    } = FightResult,
%%    ?DEBUG("DefList: ~p skill_id: ~p", [DefList, SkillId]),
    if
        SkillId =:= 4 ->
            TotalMana = lists:sum(lists:map(
                fun(Def) ->
                    #defenderresult{
                        mano_award = ManoAward
                    } = Def,
                    ManoAward
                end,
                DefList
            )),
            ?DEBUG("~p大招攻击消耗和收益，收益~p", [AttackerId, TotalMana]);
        true ->
            noop
    end,
%%    ?DEBUG("FightResult: ~p", [FightResult]),
    Out = proto:encode(FightResult),
    mod_socket:send_to_player_list(PlayerIdIdList, Out).

get_guess_boss_skill_info(CanUseSkillTime, Now, _LastSkillId, LastFightTime, SKillList) ->
    IsCanUseSkill = Now >= CanUseSkillTime,
%%    ?DEBUG("IsCanUseSkill: ~p", [IsCanUseSkill]),
    SkillInfo =
        if
            IsCanUseSkill ->
                lists:foldl(
                    fun(ThisSkillInfo, TmpSKillInfo) ->
%%                        ?DEBUG("ThisSkillInfo: ~p TmpSKillInfo: ~p", [ThisSkillInfo, TmpSKillInfo]),
                        if
                            TmpSKillInfo == null ->
                                #t_mission_guess_boss_skill{
                                    id = _SkillId,
                                    type = Type,
                                    attack_time = Cd
                                } = ThisSkillInfo,
%%                                RealCd = util:to_int(Cd / 5),
                                RealCd = Cd,
%%                                ?DEBUG("Type: ~p ~p ~p", [RealCd, Type, Now >= LastFightTime + RealCd]),
                                if
                                    Now >= LastFightTime + RealCd andalso Type =:= 1 -> ThisSkillInfo;
                                %% 测试用，只放技能
%%                                    Type =:= 2 -> ThisSkillInfo;
                                    true -> TmpSKillInfo
                                end;
                            true ->
                                TmpSKillInfo
                        end
                    end,
                    null,
                    util_list:rkeysort(#t_mission_guess_boss_skill.id, SKillList)
                );
            true ->
                null
        end,
%%    ?DEBUG("SkillInfo: ~p", [SkillInfo]),
    SkillInfo.

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
                is_boss = IsBoss
            } = ObjMonster,
            if
                Hp > 0 andalso IsWaitNavigate == true ->
                    NewObjMonster =
                        if
                            Result == success ->
                                if NewMovePath =/= [] ->
                                    api_scene:notice_monster_move(?IF(IsBoss, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)), ObjMonsterId, NewMovePath);
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

reset_boss_skill() ->
    put(?GUESS_BOSS_USE_SKILL, false).

get_nearest_monster_list(ObjId) ->
    SceneActorObject =
        case ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, ObjId) of
            ?UNDEFINED -> ?UNDEFINED;
            SceneActorObject1 ->
                #obj_scene_actor{
                    hp = MyHp
                } = SceneActorObject1,
                ?IF(MyHp > 0, SceneActorObject1, ?UNDEFINED)
        end,
    %% 当前目标已经死了
    ?ASSERT(SceneActorObject =/= ?UNDEFINED, dead),
    AliveMonstersList =
        lists:filtermap(
            fun(MonObjId) ->
                Robot = mod_scene_monster_manager:get_obj_scene_monster(MonObjId),
                #obj_scene_actor{
                    obj_id = TargetId,
                    hp = CurrentHp
                } = Robot,
                ?IF(CurrentHp >= 0 andalso TargetId =/= ObjId, {true, Robot}, false)
            end,
            mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER)
        ),
    Enemies =
        if
            length(AliveMonstersList) =< 0 -> ?FALSE;
            true -> ?TRUE
        end,
    %% 目标都死光了
    ?DEBUG("Enemies: ~p", [length(AliveMonstersList)]),
    ?ASSERT(Enemies =:= ?TRUE, target_dead),
    %% 找到最近的目标
    #obj_scene_actor{
        obj_id = _RobotId,
        x = CurrentPosX,
        y = CurrentPosY
    } = SceneActorObject,
    Match =
        lists:filtermap(
            fun(Enemy) ->
                #obj_scene_actor{
                    obj_id = EnemyObjId,
                    obj_type = _EnemyObjTypeId,
                    x = EnemyPosX,
                    y = EnemyPosY,
                    max_hp = EnemyMaxHp,
                    hp = EnemyCurrentHp,
                    move_speed = MoveSpeed
                } = Enemy,
                %% 目标死了
                Dis = util_math:get_distance({CurrentPosX, CurrentPosY}, {EnemyPosX, EnemyPosY}),
                {true, {Dis, EnemyObjId, {EnemyPosX, EnemyPosY, EnemyMaxHp, EnemyCurrentHp, Enemy, MoveSpeed}}}
            end,
            AliveMonstersList
        ),
    lists:keysort(1, Match).


%% ----------------------------------
%% @doc     处理攻击队列
%% @throws 	none
%% @end
%% ----------------------------------
handle_fight_queue(FightParam, FightObjList) when FightParam#fight_param.skill_target_num =< 0 orelse FightObjList == [] ->
    #fight_param{
        fight_result = FightResult,
        obj_scene_actor = Obj
    } = FightParam,
    RealFightResult =
        FightResult#m_mission_notice_lucky_boss_fight_toc{
%%            buff_list = api_fight:pack_buff_list(?GET_TRIGGER_BUFF_LIST(?ATTACKER)),
%%            effect_list = api_fight:pack_effect_list(?GET_TRIGGER_EFFECT_LIST(?ATTACKER)),
            %%战斗列表取反
            defender_result_list = lists:reverse(FightResult#m_mission_notice_lucky_boss_fight_toc.defender_result_list),
            anger = Obj#obj_scene_actor.anger
        },
    FightParam#fight_param{
        fight_result = RealFightResult

    };
handle_fight_queue(FightParam, [FightObj | LeftFightObjList]) ->
    #fight_param{
        obj_scene_actor = ObjSceneActor,
        skill_target_num = TargetNum
    } = FightParam,
    if
        ObjSceneActor#obj_scene_actor.hp > 0 ->
            NewFightParam =
                case mod_fight:is_can_fight(FightParam, FightObj) of
                    true ->
                        FightParam_1 =
                            mod_fight:fighting(
                                FightParam#fight_param{
                                    obj_scene_actor = mod_fight:init_fight_obj(FightParam#fight_param.obj_scene_actor, ?ATTACKER)
                                },
                                mod_fight:init_fight_obj(FightObj, ?DEFENSER)
                            ),
                        FightParam_1#fight_param{
                            skill_target_num = TargetNum - 1
                        };
                    false ->
                        FightParam
                end,
            handle_fight_queue(NewFightParam, LeftFightObjList);
        true ->
            handle_fight_queue(FightParam, [])
    end.


%% ----------------------------------
%% @doc 	追加战报
%% @throws 	none
%% @end
%% ----------------------------------
append_fight_result(FightResult, DefenderResult) ->
    #m_mission_notice_lucky_boss_fight_toc{
        defender_result_list = DefenderResultList
    } = FightResult,
    FightResult#m_mission_notice_lucky_boss_fight_toc{
        defender_result_list = [DefenderResult | DefenderResultList]
    }.

set_skill_timestamp() ->
    OldTimestamp =
        case get(?WHEN_DOSE_USE_SKILL) of
            ?UNDEFINED -> util_time:milli_timestamp();
            OldNowMs -> OldNowMs
        end,

    [MinTime, MaxTime] = ?SD_GUESS_BOSS_SKILL_TIME_LIST,
    NewSkillTimestamp = OldTimestamp + util_random:random_number(MinTime * 1000, MaxTime * 1000),
    ?DEBUG("set_skill_timestamp: ~p(~p)", [NewSkillTimestamp, util_time:timestamp_to_datetime(NewSkillTimestamp div ?SECOND_MS)]),
    put(?WHEN_DOSE_USE_SKILL, NewSkillTimestamp).

use_skill() ->
%%    ?TRUE.
    case get(?WHEN_DOSE_USE_SKILL) of
        ?UNDEFINED ->
            ?DEBUG("when dose use skill == undefined"),
            ?FALSE;
        UseSkillTimestamp ->
%%            ?DEBUG("latest skill time ~p(~p)", [UseSkillTimestamp, util_time:timestamp_to_datetime(UseSkillTimestamp div ?SECOND_MS)]),
            Now = util_time:milli_timestamp(),
            if
                Now >= UseSkillTimestamp ->
                    ?DEBUG("到点使用技能，并且将下次使用技能的时间设置为undefined，方便下次判断是否使用技能时，生成使用技能的时间"),
                    put(?WHEN_DOSE_USE_SKILL, ?UNDEFINED),
                    ?TRUE;
                true ->
                    ?DEBUG("when dose use skill ~p(~p)", [Now, util_time:timestamp_to_datetime(Now div ?SECOND_MS)]),
                    ?FALSE
            end
    end.
%%    ?FALSE.

get_attack_info(RActiveSkillList, AttackType) ->
    RealActiveSkillList =
        lists:filtermap(
            fun(SingleSkillInfo) ->
                #t_mission_guess_boss_skill{
                    type = Type
                } = SingleSkillInfo,
                if
                    AttackType =:= Type -> {true, SingleSkillInfo};
                    true -> false
                end
            end,
            RActiveSkillList
        ),

%%    #t_mission_guess_boss_skill{
%%        id = BossSkillId,
%%        attack_range = SkillDistance,
%%        attack_damage = AttachDamage,
%%        attack_count = AttackCount,
%%        main_target_type = MainTargetType,
%%        crit = Crit
%%    } = hd(RealActiveSkillList).
    hd(RealActiveSkillList).
