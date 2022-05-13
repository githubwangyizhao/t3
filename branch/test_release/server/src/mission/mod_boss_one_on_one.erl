%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 30. 6月 2021 下午 06:29:42
%%%-------------------------------------------------------------------
-module(mod_boss_one_on_one).
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
-include("db_config.hrl").
-include("one_on_one.hrl").

%% API
-export([
    handle_robot_fight_each_other_new/1
]).


-export([
    set_against_data/2,

    get_record/1,
    handle_get_record/2,
    get_against_record/2,
    get_against_record/0,

    handle_get_win_rate/2,

    notice_player_fight/1
]).

handle_get_win_rate(PlayerId, Res) ->
    {{HomeBossId, HomeRate}, {AwayBossId, AwayRate}, _Records} = Res,
    ?DEBUG("PlayerId: ~p", [PlayerId]),
    Out2 = #m_mission_notice_one_on_one_rate_toc{
        winne_rate = [#winnerrate{boss_id = BossId, rate = util:to_int(Rate * 100)} || {BossId, Rate} <- [{HomeBossId, HomeRate}, {AwayBossId, AwayRate}]]
    },
    ?DEBUG("Out2: ~p", [Out2]),
    mod_socket:send(PlayerId, proto:encode(Out2)).

handle_get_record(PlayerId, Res) ->
    {{HomeBossId, HomeRate}, {AwayBossId, AwayRate}, Records} = Res,
    ?DEBUG("PlayerId: ~p", [PlayerId]),
    ?DEBUG("Res: ~p", [Res]),
    ?DEBUG("DbMissionGuessBossList: ~p", [length(Records)]),
    {RateList, RecordList} = {[{HomeBossId, HomeRate}, {AwayBossId, AwayRate}], [{CreatedTime, Winner} ||
        #ets_boss_one_on_one_record{winner = Winner, loser = _Loser, created_time = CreatedTime} <- Records]},
    Out = #m_mission_guess_get_record_toc{
        guess_boss_record_list = [#guessbossrecord{id = Id, boss_id = BossId} || {Id, BossId} <- RecordList]
    },
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(PlayerId, proto:encode(Out)),
    Out2 = #m_mission_notice_one_on_one_rate_toc{
        winne_rate = [#winnerrate{boss_id = BossId, rate = util:to_int(Rate * 100)} || {BossId, Rate} <- RateList]
    },
    ?DEBUG("Out2: ~p", [Out2]),
    mod_socket:send(PlayerId, proto:encode(Out2)).

get_win_rate(PlayerId) ->
    SceneId = mod_mission:get_scene_id_by_mission(?MISSION_TYPE_GUESS_BOSS, 1),
    SceneWorker =
        case scene_master:get_scene_worker(SceneId) of
            null -> ?ERROR("多人副本不存在"), exit(?ERROR_NOT_EXISTS);
            {ok, SceneWorker1} -> SceneWorker1;
            Other -> ?ERROR("获取多人副本非预期错误: ~p", [Other]), exit(unknown)
        end,
    ?DEBUG("SceneWorker: ~p", [SceneWorker]),
    case gen_server:call(SceneWorker, {?GET_ONE_ON_ONE_WIN_RATE, PlayerId}) of
        {error, Reason} ->
            exit(Reason);
        Result ->
            ?DEBUG("Result: ~p ", [Result])
    end.

%% @doc 获得记录
get_record(PlayerId) ->
    SceneId = mod_mission:get_scene_id_by_mission(?MISSION_TYPE_GUESS_BOSS, 1),
    SceneWorker =
        case scene_master:get_scene_worker(SceneId) of
            null -> ?ERROR("多人副本不存在"), exit(?ERROR_NOT_EXISTS);
            {ok, SceneWorker1} -> SceneWorker1;
            Other -> ?ERROR("获取多人副本非预期错误: ~p", [Other]), exit(unknown)
        end,
    ?DEBUG("SceneWorker: ~p", [SceneWorker]),
    case gen_server:call(SceneWorker, {?GET_ONE_ON_ONE_AGAINST, PlayerId}) of
        {error, Reason} ->
            exit(Reason);
        Result ->
            ?DEBUG("Result: ~p ", [Result])
    end.

handle_robot_fight_each_other_new(_State = #scene_state{is_mission = _IsMission, scene_id = _SceneId, map_id = MapId}) ->
    ?DEBUG("new fight: ~p winner: ~p", [mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER), get(guess_boss_winner)]),
    Wait4FightList =
        lists:filtermap(
            fun(MonObjId) ->
                Robot = mod_scene_monster_manager:get_obj_scene_monster(MonObjId),
                #obj_scene_actor{
                    hp = CurrentHp, obj_type = _TargetObjType, obj_id = MonsterObjId,
                    r_active_skill_list = SkillList, move_speed = MoveSpeed1, x = X, y = Y
                } = Robot,
                MoveSpeed = util:speed_point_2_speed(MoveSpeed1) * ?TILE_LEN,
                ?INFO("移动速度: ~p", [MoveSpeed]),
                {Dis, EnemyObjId, {EnemyPosX, EnemyPosY, _EnemyMaxHp, EnemyCurrentHp, _Enemy, _EnemyMoveSpeed}} =
                    hd(mod_mission_boss_fight:get_nearest_monster_list(MonObjId)),
                Skill =
                    lists:filtermap(
                        fun(SingleSkill) ->
                            #t_mission_guess_boss_skill{
                                attack_time = AttackCd,
                                attack_damage = Damage,
                                type = Type,
                                id = SkillId,
                                hurt_delay_time = HurtDelayTime,
                                attack_range = AttackRange,
                                crit_damage = CritDamage,
                                crit = CritRate,
                                dodge = DodgeRate
                            } = SingleSkill,
                            AttackTimes = ceil(EnemyCurrentHp / Damage),
                            if
                                Dis > AttackRange andalso Type =:= 1 ->
                                    {TargetX, TargetY} = util_math:get_direct_src_pos(
                                        MapId,
                                        {X, Y},
                                        {EnemyPosX, EnemyPosY},
                                        util:to_int((Dis - AttackRange) / 2)
                                    ),
                                    ?INFO("移动 ~p ~p", [MonsterObjId,
                                        {{X, Y}, {EnemyPosX, EnemyPosY}, Dis, AttackRange, util:to_int((Dis - AttackRange) / 2)}]),
                                    FightX = util:to_int(TargetX),
                                    FightY = util:to_int(TargetY),
                                    RealDis = util_math:get_distance({X, Y}, {FightX, FightY}),
                                    RealDir = util_math:get_direction({X, Y}, {FightX, FightY}),
                                    TimeInWalk = ceil((RealDis / MoveSpeed) * ?SECOND_MS),
                                    ?INFO("移动 ~p ~p", [MonsterObjId,
                                        {RealDis, MoveSpeed, TimeInWalk, RealDir}]),
                                    Robot1 = Robot#obj_scene_actor{
                                        x = FightX, y = FightY, move_type = ?P_NORMAL, dir = RealDir
                                    },
                                    ?UPDATE_OBJ_SCENE_MONSTER(Robot1),
                                    {true, {
                                        RealDir,
                                        FightX,
                                        FightY,
                                        TimeInWalk,
                                        EnemyObjId,
                                        EnemyCurrentHp,
                                        Damage,
                                        AttackCd,
                                        AttackTimes,
                                        AttackTimes * AttackCd,
                                        CritDamage,
                                        CritRate,
                                        DodgeRate,
                                        Type,
                                        HurtDelayTime,
                                        SkillId,
                                        MoveSpeed,
                                        AttackRange}};
                                true -> false
                            end
                        end,
                        SkillList
                    ),
                {true, {MonsterObjId, {CurrentHp, EnemyObjId, Skill}}}
            end,
            mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER)
        ),
    ?DEBUG("Wait4FightList: ~p", [Wait4FightList]),
    Now = util_time:milli_timestamp(),
    FightResultList =
        lists:foldl(
            fun(Ele, Tmp) ->
                {MonsterObjId, {_, _CurrentHp, SkillList}} = Ele,
                SkillTuple = hd(SkillList),
                ?DEBUG("EnemyTuple: ~p", [{is_tuple(SkillTuple), SkillTuple}]),
                {
                    RealDir,
                    FightX,
                    FightY,
                    TimeInWalk,
                    EnemyObjId,
                    _EnemyCurrentHp,
                    Damage,
                    AttackCd,
                    AttackTimes,
                    TotalAttackTimes,
                    _CritDamage,
                    _CritRate,
                    _DodgeRate,
                    _Type,
                    HurtDelayTime,
                    SkillId,
                    MoveSpeed,
                    _AttackRange
                } = SkillTuple,
                AfterWalk = Now + TimeInWalk,
                ?DEBUG("Now: ~p", [{Now, util_time:timestamp_to_datetime(Now div ?SECOND_MS), MoveSpeed, TimeInWalk, AfterWalk,
                    util_time:timestamp_to_datetime(AfterWalk div ?SECOND_MS)}]),
                Tmp1 = [{MonsterObjId, FightX, FightY, EnemyObjId, RealDir, AfterWalk, AttackTimes, TotalAttackTimes,
                    Damage, AttackCd, HurtDelayTime, SkillId, AfterWalk} | Tmp],
                MoveOut = #m_scene_notice_monster_move_toc{
                    scene_monster_id = MonsterObjId,
                    move_path = [#movepath{x = FightX, y = FightY}]
                },
                StopMove = #m_scene_notice_monster_stop_move_toc{
                    scene_monster_id = MonsterObjId,
                    x = FightX,
                    y = FightY
                },
                %% 更新怪物位置
                MonsterObj = mod_scene_monster_manager:get_obj_scene_monster(MonsterObjId),
                #obj_scene_actor{ x = BirthX, y = BirthY } = MonsterObj,
                NewMonsterObj = MonsterObj#obj_scene_actor{
                    x = FightX, y = FightY, dir=RealDir
                },
                ?UPDATE_OBJ_SCENE_MONSTER(NewMonsterObj),

                ?INFO("通知:~p，~p怪物的移动:~p", [MonsterObjId, {BirthX, BirthY}, {FightX, FightY}]),
                erlang:send_after(?SD_GUESS_MISSION_OPENING_SHOW, self(), {?MSG_NOTICE_PLAYER_FIGHT, MoveOut}),
                ?INFO("在~p后通知怪物停止移动 ~p", [TimeInWalk + ?SD_GUESS_MISSION_OPENING_SHOW, StopMove]),
                erlang:send_after(TimeInWalk + ?SD_GUESS_MISSION_OPENING_SHOW, self(), {?MSG_NOTICE_PLAYER_FIGHT, StopMove}),

                Tmp1
            end,
            [],
            Wait4FightList
        ),
%%    ?DEBUG("FightResultList: ~p", [FightResultList]),
    MinStartTime = lists:min(lists:map(fun(X) -> element(6, X) end, FightResultList)),
%%    AddTime = lists:min(lists:map(fun(X) -> element(13, X) end, FightResultList)),
%%    MinStartTime = MinStartTime1 + AddTime,
    ?DEBUG("startTime: ~p", [{MinStartTime}]),
    MinAttackTimes = lists:max(lists:map(fun(X) -> element(7, X) end, FightResultList)),
%%    AttackTimesList = lists:seq(0, MinAttackTimes - 1),

    %% 生成技能释放时间点
    [Min, Max] = ?SD_GUESS_BOSS_SKILL_TIME_LIST,
    put(use_skill, Now + (util_random:random_number(Min, Max) * ?SECOND_MS)),

    TimeStep1 = 50,
    AttackTimesList = lists:seq(0, util:to_int(MinAttackTimes * (?SECOND_MS / TimeStep1)) - 1),
    lists:foreach(
        fun(T) ->
            TmpTime = util:to_int(MinStartTime + T * TimeStep1),
            lists:foreach(
                fun(Obj) ->
                    {AttackerObjId, {_, DefenderObjId, SkillList}} = Obj,
                    SkillTuple = hd(SkillList),
                    {Dir, _, _, _, _, _, Damage, AttackCd, _, _, CritDamage, CritRate, DodgeRate,
                        _Type, HurtDelayTime, SkillId, _MoveSpeed, AttackRange} = SkillTuple,
                    AttackerObj = mod_scene_monster_manager:get_obj_scene_monster(AttackerObjId),
                    #obj_scene_actor{
                        x = AttackerX, y = AttackerY, last_attacked_time_ms = _LastAttackedTimeMs,
                        base_id = AttackerBossId, max_hp = AttackerMaxHp, dir = AttackerDir,
                        hp = CurrentHp, obj_type = AttackerType, last_move_time = _LastMoveTime,
                        last_fight_time_ms = AttackerLastFightTime, move_speed = AttackerMonsterMoveSpeed,
                        next_can_heart_time = OldAttackerNextHeartbeatTime, move_path = AttackerMovePath,
                        r_active_skill_list = MonsterSkillList %, obj_type = ObjType,
                    } = AttackerObj,
                    RealMonsterMoveSpeed = util:speed_point_2_speed(AttackerMonsterMoveSpeed) * ?TILE_LEN,

                    DefenderObj = mod_scene_monster_manager:get_obj_scene_monster(DefenderObjId),
                    #obj_scene_actor{
                        hp = DefenderCurrentHp, x = DefenderX, y = DefenderY, obj_type = DefenderObjType,
                        last_attacked_time_ms = _OldDefenderAttackTime,
                        move_speed = DefenderMoveSpeed, base_id = _DefenderBossId, max_hp = _DefenderMaxHp,
                        dir = DefenderDir, next_can_heart_time = OldDefenderNextHeartbeatTime,
                        move_path = _DefenderMovePath
                    } = DefenderObj,
                    RealEnemyMoveSpeed = util:speed_point_2_speed(DefenderMoveSpeed) * ?TILE_LEN,

%%                    if
%%                        T =:= 1 ->
%%                            ?DEBUG("Attacker movePath: ~p", [{AttackerMovePath, DefenderMovePath,
%%                                {AttackerX, AttackerY}, {DefenderX, DefenderY}}]);
%%                        true -> ok
%%                    end,

                    if
                    %% 攻击者的心跳时间已到,指定相关动作
                        TmpTime >= OldAttackerNextHeartbeatTime ->
%%                            ?DEBUG("TTT: ~p", [{MinStartTime, TmpTime}]),
%%                            ?DEBUG("以~p为主视角,判断其是否发出攻击~p", [AttackerObjId,
%%                                {TmpTime, OldAttackerNextHeartbeatTime, TmpTime >= OldAttackerNextHeartbeatTime}]),
                            %% 攻击者在上次攻击中被对手用大招打中发生了击退效果,此时更新其坐标
                            {RealAttackerX, RealAttackerY, RealAttackerNextHeartbeat, AttackerHasBeenBeatBack} =
                                case get(pos_after_hit) of
                                    ?UNDEFINED -> {AttackerX, AttackerY, TmpTime, ?FALSE};
                                    L1 ->
                                        case lists:keyfind(AttackerObjId, 1, L1) of
                                            false -> {AttackerX, AttackerY, TmpTime, ?FALSE};
                                            {AttackerObjId, {NewAttackerX, NewAttackerY, NewAttackerNextHeartBeatTime}} ->
%%                                                ?DEBUG("在上轮战斗时被~p的大招打中,发生了击退,在本次攻击结束后,最新的坐标为:~p", [
%%                                                    DefenderObjId,
%%                                                    {{NewAttackerX, NewAttackerY, NewAttackerNextHeartBeatTime, ?FALSE}}
%%                                                ]),
                                                put(pos_after_hit, lists:keydelete(AttackerObjId, 1, L1)),
%%                                                AttackerObjAfterBeatBack = AttackerObj#obj_scene_actor{
%%                                                    x = NewAttackerX, y = NewAttackerY,
%%                                                    next_can_heart_time = NewAttackerNextHeartBeatTime
%%                                                },
%%                                                ?UPDATE_OBJ_SCENE_MONSTER(AttackerObjAfterBeatBack),
                                                {NewAttackerX, NewAttackerY, NewAttackerNextHeartBeatTime, ?TRUE}
                                        end
                                end,

                            RealDistance = util_math:get_distance({AttackerX, AttackerY}, {DefenderX, DefenderY}),
                            if
                                RealDistance > AttackRange ->
%%                                    ?DEBUG("realMoveSpeed: ~p ~p", [RealMonsterMoveSpeed, RealEnemyMoveSpeed]),
                                    RealDistance1 = RealDistance - AttackRange,
                                    TakeTime = ?IF(RealDistance1 >= util:to_int(AttackRange / 2),
                                        RealDistance1 / (util:to_int(RealMonsterMoveSpeed) + util:to_int(RealEnemyMoveSpeed)),
                                        RealDistance1 / util:to_int(RealMonsterMoveSpeed)
                                    ),
                                    RealDis = util:to_int(RealMonsterMoveSpeed * TakeTime),
%%                                    ?DEBUG("~p与~p的距离超过了攻击距离~p",
%%                                        [AttackerObjId, DefenderObjId, {RealDistance, RealDistance1, AttackRange, RealDis, TakeTime, RealMonsterMoveSpeed}]),
                                    {TargetX, TargetY} = util_math:get_direct_src_pos(
                                        MapId,
                                        {AttackerX, AttackerY},
                                        {DefenderX, DefenderY},
                                        util:to_int(RealDis)
                                    ),
                                    FightX = util:to_int(TargetX),
                                    FightY = util:to_int(TargetY),
%%                                    ?DEBUG("~p从~p移动到~p耗时~p", [AttackerObjId, {AttackerX, AttackerY}, {FightX, FightY}, {TakeTime, {DefenderX, DefenderY}}]),
                                    AttackerObjBeginMove = AttackerObj#obj_scene_actor{
                                        x = FightX, y = FightY, move_path = [{FightX, FightY}],
                                        last_move_time = TmpTime + TakeTime, go_x = FightX, go_y = FightY
                                        , next_can_heart_time = TmpTime + util:to_int(TakeTime * ?SECOND_MS)
                                    },
                                    ?UPDATE_OBJ_SCENE_MONSTER(AttackerObjBeginMove),

                                    MoveOut = #m_scene_notice_monster_move_toc{
                                        scene_monster_id = AttackerObjId,
                                        move_path = [#movepath{x = FightX, y = FightY}]
                                    },
                                    erlang:send_after(TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW - Now, self(), {?MSG_NOTICE_PLAYER_FIGHT, MoveOut}),
                                    ?DEBUG("行走: ~p ~p", [
                                        util_time:timestamp_to_datetime((TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW) div ?SECOND_MS),
                                        MoveOut
                                    ]);
%%                                    ?DEBUG("下发移动协议 ~p下次心跳时间~p", [AttackerObjId, TmpTime + util:to_int(TakeTime * ?SECOND_MS)]);
                                true ->
                                    if
                                    %% cd时间到，可以开始攻击
                                        TmpTime >= AttackerLastFightTime ->
                                            AttackerObjAfterMove = AttackerObj#obj_scene_actor{ go_x = 0, go_y = 0 },
                                            ?UPDATE_OBJ_SCENE_MONSTER(AttackerObjAfterMove),

                                            StopMove = #m_scene_notice_monster_stop_move_toc{
                                                scene_monster_id = AttackerObjId, x = AttackerX, y = AttackerY
                                            },
                                            erlang:send_after(TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW - Now, self(), {?MSG_NOTICE_PLAYER_FIGHT, StopMove}),
%%                                            ?DEBUG("下发停止移动协议"),

                                            DoseUseSkill = get(use_skill),
                                            %% 随机获取本次释放技能的monsterId
                                            UseSkillMonsterId = util_random:random_number(
                                                ?IF(AttackerObjId < DefenderObjId, AttackerObjId, DefenderObjId),
                                                ?IF(AttackerObjId > DefenderObjId, AttackerObjId, DefenderObjId)
                                            ),
%%                                            ?DEBUG("~p在~p放大招", [UseSkillMonsterId, TmpTime]),
                                            {RealDamage2, CritDamage2, HurtDelayTime2, SkillId2,
                                                UpdateSkillInfo, AttackerNextAttackDelay, HitBackDis} =
                                                if
                                                %% 本次攻击允许使用技能且当前monsterId就是要释放技能的monster
                                                    TmpTime >= DoseUseSkill andalso UseSkillMonsterId =:= AttackerObjId ->
%%                                                        ?DEBUG("随机到~p放大招", [AttackerObjId]),
                                                        DamageList =
                                                            lists:filtermap(
                                                                fun(SkillRecord) ->
                                                                    #t_mission_guess_boss_skill{
                                                                        id = SkillId1,
                                                                        attack_damage = SkillDamage,
                                                                        type = SkillType,
                                                                        crit_damage = SkillCritDamage,
                                                                        hurt_delay_time = SkillHurtDelayTime,
                                                                        attack_time = AttackTime,
                                                                        hit_back_range = SkillHitBackDis
                                                                    } = SkillRecord,
                                                                    if
                                                                        SkillType =:= 2 ->
                                                                            NextUseSkillTime = TmpTime +
                                                                                util_random:random_number(Min, Max) * ?SECOND_MS,
                                                                            put(use_skill, NextUseSkillTime),
                                                                            {true, {SkillDamage, SkillCritDamage,
                                                                                SkillHurtDelayTime, SkillId1, ?TRUE, AttackTime,
                                                                                SkillHitBackDis}};
                                                                        true -> false
                                                                    end
                                                                end,
                                                                MonsterSkillList
                                                            ),
                                                        ?IF(length(DamageList) >= 1,
                                                            hd(DamageList),
                                                            {Damage, CritDamage, HurtDelayTime, SkillId, ?FALSE, ?FALSE, ?FALSE});
                                                    true ->
                                                        {Damage, CritDamage, HurtDelayTime, SkillId, ?FALSE, ?FALSE, ?FALSE}
                                                end,

                                            %% 攻击者的暴击伤害，是否暴击
                                            Random4Crit = util_random:random_number(0, 10000),
                                            {RealDamage, Crit} = ?IF(Random4Crit =< CritRate, {CritDamage2, ?TRUE},
                                                {RealDamage2, ?FALSE}),

                                            %% 防御者是否被闪避
                                            Random4Dodge = util_random:random_number(0, 10000),
                                            RealDodge = ?IF(Random4Dodge =< DodgeRate, ?TRUE, ?FALSE),

                                            %% 防御者闪避，则收到的真实伤害为0；反之则为RealDamage
                                            RealDamage1 = ?IF(RealDodge =:= ?TRUE, 0, RealDamage),
                                            %% 更新受击者血量
                                            NewDefenderHp = ?IF((DefenderCurrentHp - RealDamage1) > 0,
                                                (DefenderCurrentHp - RealDamage1), 0),
%%                                            ?DEBUG("~p的攻击打到~p时造成了~p的伤害", [AttackerObjId, DefenderObjId, RealDamage1]),
                                            {AttackerNextHeartbeatAfterAttack, DefenderNextHeartbeatAfterAttack,
                                                DefenderXAfterAttack, DefenderYAfterAttack, _HeatBack} =
                                                if
                                                %% 攻击者释放技能,且被受击者闪避
                                                %% 攻击者的下次心跳时间修改为当前时间+大招释放延迟时间
                                                %% 受击者的下次心跳时间,横纵坐标不变
                                                    UpdateSkillInfo =:= ?TRUE andalso RealDamage1 =:= 0 ->
%%                                                        ?DEBUG("~p对~p造成了大招伤害0点伤害", [AttackerObjId, DefenderObjId]),
                                                        DefenderNextHeartbeatTime = ?IF(OldDefenderNextHeartbeatTime =:= 0, TmpTime, OldDefenderNextHeartbeatTime),
                                                        %% 闪避了，增加位移
%%                                                        Step = ?IF(EnemyCurrentDir =:= ?DIR_RIGHT, -100, 100),
                                                        {
                                                            DefenderNextHeartbeatTime,
%%                                                            RealAttackerNextHeartbeat + AttackerNextAttackDelay,
                                                            DefenderNextHeartbeatTime,
%%                                                            DefenderX + Step,
%%                                                            DefenderY + Step,
                                                            0,
                                                            0,
                                                            ?FALSE};
                                                %% 攻击者释放技能,且受击者没有闪避
                                                %% 攻击者的下次心跳时间修改为当前时间+大招释放延迟时间
                                                %% 受击者的下次心跳时间不变,横纵坐标变为击退后的坐标
                                                    UpdateSkillInfo =:= ?TRUE andalso RealDamage1 =/= 0 ->
%%                                                        ?DEBUG("~p对~p造成了大招伤害,大招延迟~p",
%%                                                            [AttackerObjId, DefenderObjId, AttackerNextAttackDelay]),
                                                        EnemyXAfterHit = ?IF(DefenderDir =:= ?DIR_RIGHT,
                                                            DefenderX - HitBackDis,
                                                            DefenderX + HitBackDis),
                                                        PosAfterHitTupleList =
                                                            case get(pos_after_hit) of
                                                                ?UNDEFINED ->
                                                                    [{DefenderObjId,
                                                                        {EnemyXAfterHit, DefenderY,
                                                                            TmpTime + AttackerNextAttackDelay}}];
                                                                L ->
                                                                    case lists:keyfind(DefenderObjId, 1, L) of
                                                                        false ->
                                                                            [{DefenderObjId,
                                                                                {EnemyXAfterHit, DefenderY,
                                                                                    TmpTime + AttackerNextAttackDelay}
                                                                            } | L];
                                                                        {DefenderObjId, _} ->
                                                                            lists:keyreplace(DefenderObjId, 1, L,
                                                                                {DefenderObjId,
                                                                                    {EnemyXAfterHit, DefenderY,
                                                                                        TmpTime + AttackerNextAttackDelay}}
                                                                            )
                                                                    end
                                                            end,
                                                        put(pos_after_hit, PosAfterHitTupleList),
%%                                                        ?DEBUG("位移列表~p", [PosAfterHitTupleList]),
                                                        DefenderNextHeartbeatTime =
                                                            ?IF(OldDefenderNextHeartbeatTime =:= 0, TmpTime,
                                                                OldDefenderNextHeartbeatTime),
                                                        {RealAttackerNextHeartbeat + AttackerNextAttackDelay,
                                                            DefenderNextHeartbeatTime,
                                                            %% 技能打死受击者时，受击者没有击退效果
                                                            ?IF(NewDefenderHp > 0, EnemyXAfterHit, 0),
                                                            ?IF(NewDefenderHp > 0, DefenderY, 0),
                                                            ?TRUE};
                                                %% 攻击者释放普通
                                                %% 攻击者的下次心跳时间修改为当前时间+普攻cd时间
                                                %% 受击者的心跳时间不变,横纵坐标不变
                                                    true ->
                                                        %% 闪避了，增加位移
%%                                                        Step = ?IF(RealDamage1 =:= 0,
%%                                                            ?IF(EnemyCurrentDir =:= ?DIR_RIGHT, -100, 100), 0),
                                                        DefenderNextHeartbeatTime = ?IF(OldDefenderNextHeartbeatTime =:= 0, TmpTime, OldDefenderNextHeartbeatTime),
                                                        {
                                                            %% 攻击者在上次被攻击时遭受大招伤害,此处下次心跳时间就不增加AttackCd了
                                                            ?IF(AttackerHasBeenBeatBack =:= ?TRUE,
                                                                RealAttackerNextHeartbeat, RealAttackerNextHeartbeat + AttackCd),
                                                            DefenderNextHeartbeatTime,
%%                                                            ?IF(RealDamage1 =:= 0, DefenderX + Step, 0),
%%                                                            ?IF(RealDamage1 =:= 0, DefenderY, 0),
                                                            0,
                                                            0,
                                                            ?FALSE}
                                                end,

                                            ?DEBUG("~p的下次心跳时间~p", [AttackerObjId,
                                                util_time:timestamp_to_datetime(AttackerNextHeartbeatAfterAttack div ?SECOND_MS)]),

                                            %% 攻击者修改下次心跳时间,上次攻击时间
                                            AttackerAfterAttack = AttackerObjAfterMove#obj_scene_actor{
                                                x = RealAttackerX, y = RealAttackerY, go_x = 0, go_y = 0,
                                                next_can_heart_time =
                                                ?IF(AttackerHasBeenBeatBack =:= ?TRUE,
                                                    RealAttackerNextHeartbeat,
                                                    %% 若发生了闪避，则下一次心跳延迟200ms，防止客户端动画被打断
                                                    ?IF(RealDamage1 =:= 0, AttackerNextHeartbeatAfterAttack + 200,
                                                        AttackerNextHeartbeatAfterAttack)),
                                                last_fight_time_ms = TmpTime
                                            },
                                            ?UPDATE_OBJ_SCENE_MONSTER(AttackerAfterAttack),

                                            %% 受击者只修改下次心跳时间,上次被攻击时间
                                            DefenderAfterAttack = DefenderObj#obj_scene_actor{
                                                hp = NewDefenderHp, last_attacked_time_ms = TmpTime,
                                                %% 若发生了闪避，则下一次心跳延迟200ms，防止客户端动画被打断
                                                next_can_heart_time = ?IF(RealDamage1 =:= 0,
                                                    DefenderNextHeartbeatAfterAttack + 200, DefenderNextHeartbeatAfterAttack)
                                            },
                                            ?UPDATE_OBJ_SCENE_MONSTER(DefenderAfterAttack),

                                            ?DEBUG("本次攻击的延迟：~p", [{AttackerNextAttackDelay, HurtDelayTime2}]),
                                            ReturnTime = TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW + HurtDelayTime2,
%%                                                ?IF(AttackerNextAttackDelay =:= 0, HurtDelayTime2 , AttackerNextAttackDelay),
                                            OneOnOneDefenderResult = [#oneononedefenderresult{
                                                defender_id = DefenderObjId, defender_type = DefenderObjType,
                                                hp = NewDefenderHp, hurt = RealDamage1,
                                                type = ?IF(RealDodge =:= ?TRUE, ?P_DODGE,
                                                    ?IF(Crit =:= ?TRUE, ?P_CRIT, ?P_NORMAL)),
                                                x = DefenderXAfterAttack, y = DefenderYAfterAttack,
                                                buff_list = [], effect_list = [],  hurt_section_list = [],
                                                total_mano = 0, all_total_mano = 0, beat_times = 1, mano_award = 0,
                                                exp = 0, special_event = 0, dizzy_close_time = 0, award_player_id = 0,
                                                timestamp = ReturnTime
                                            }],
                                            FightOut =
                                                #m_mission_notice_lucky_boss_fight_toc{
                                                    attacker_id = AttackerObjId, attacker_type = AttackerType,
                                                    x = AttackerX, y = AttackerY, dir = Dir,
                                                    target_id = DefenderObjId, target_type = DefenderObjType,
                                                    skill_id = SkillId2, skill_level = 1, anger = 0,
                                                    timestamp = TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW,
                                                    defender_result_list = OneOnOneDefenderResult
                                                },
                                            ?DEBUG("战斗: ~p ~p", [
                                                util_time:timestamp_to_datetime(
                                                    (TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW) div ?SECOND_MS),
                                                FightOut
                                            ]),
                                            RealTimestamp = TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW,
%%                                            NoticeTime = TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW - Now,
                                            MonsterActionList = get(one_on_one_fighting_status),
%%                                            ?DEBUG("MonsterActionList: ~p", [MonsterActionList]),
%%                                            case lists:keyfind(DefenderObjId, 1, MonsterActionList) of
%%                                                {_, ActionList} ->
%%                                                    NewActionList =
%%                                                        case lists:keyfind(RealTimestamp + Now, 1, ActionList) of
%%                                                            false ->
%%                                                                NewActionTuple = {RealTimestamp, {DefenderBossId, DefenderObjId,
%%                                                                    DefenderCurrentHp, DefenderX, DefenderY,
%%                                                                    DefenderDir, DefenderMaxHp}},
%%                                                                [NewActionTuple | ActionList];
%%                                                            {_, _} -> ActionList
%%                                                        end,
%%                                                    ?DEBUG("ActionList: ~p", [ActionList]),
%%                                                    ?DEBUG("NewActionList: ~p", [NewActionList]),
%%                                                    put(one_on_one_fighting_status, lists:keyreplace(DefenderObjId, 1,
%%                                                        MonsterActionList, {DefenderObjId, NewActionList}));
                                            case lists:keyfind(AttackerObjId, 1, MonsterActionList) of
                                                {_, ActionList} ->
                                                    NewActionList =
                                                        case lists:keyfind(RealTimestamp, 1, ActionList) of
                                                            false ->
                                                                NewActionTuple = {RealTimestamp, {AttackerBossId, AttackerObjId,
                                                                    CurrentHp, AttackerX, AttackerY, AttackerDir, AttackerMaxHp,
                                                                    AttackerMovePath}},
                                                                [NewActionTuple | ActionList];
                                                            {_, _} -> ActionList
                                                        end,
%%                                                    ?DEBUG("ActionList: ~p", [ActionList]),
%%                                                    ?DEBUG("NewActionList: ~p", [NewActionList]),
                                                    put(one_on_one_fighting_status, lists:keyreplace(AttackerObjId, 1,
                                                        MonsterActionList, {AttackerObjId, NewActionList}));
                                                false -> ok
%%                                                    ?DEBUG("AttackerObjId: ~p not exists", [DefenderObjId])
                                            end,
%%                                            ?DEBUG("Fighting status: ~p", [get(one_on_one_fighting_status)]),
                                            ?DEBUG("Tmp: ~p", [{TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW - Now}]),
                                            erlang:send_after(
                                                TmpTime + ?SD_GUESS_MISSION_OPENING_SHOW - Now,
                                                self(),
                                                {?MSG_NOTICE_PLAYER_FIGHT, FightOut}
                                            ),
                                            if
                                                NewDefenderHp =:= 0 ->
                                                    put(?GUESS_MISSION_STATE, {2, util_time:milli_timestamp()}),
                                                    exit({empty, {ReturnTime, AttackerObjId}});
                                                true -> true
                                            end;
                                        true -> ok
                                    end
                            end;
                        true -> ok
                    end
                end,
                Wait4FightList
            )
        end,
        AttackTimesList
    ).

update_monster_pos(MonsterId, X, Y) ->
    EnemyObj = mod_scene_monster_manager:get_obj_scene_monster(MonsterId),
    #obj_scene_actor{x = OldX, y = OldY} = EnemyObj,
    ?DEBUG("更新怪物被击退后的位置：~p", [{MonsterId, {{OldX, OldY}, {X, Y}}}]),
    NewEnemyObj = EnemyObj#obj_scene_actor{ x = X, y = Y },
    ?UPDATE_OBJ_SCENE_MONSTER(NewEnemyObj).

notice_player_fight(Out) ->
%%    case Out of
%%        StopMoveOut when is_record(StopMoveOut, m_scene_notice_monster_stop_move_toc) ->
%%            ok;
%%        MoveOut when is_record(MoveOut, m_scene_notice_monster_move_toc) ->
%%            ok;
%%        FightOut when is_record(FightOut, m_mission_notice_lucky_boss_fight_toc) ->
%%            #m_mission_notice_lucky_boss_fight_toc{ attacker_id = AttackerId, x = AttackerX, y = AttackerY,
%%                dir = AttackerDir} = FightOut,
%%            ?DEBUG("Fighting status: ~p", [{get(one_on_one_fighting_status), AttackerId, AttackerDir, AttackerX,
%%                AttackerY, util_time:milli_timestamp()}])
%%    end,
    ?DEBUG("Out: ~p", [Out]),
    case mod_scene_player_manager:get_all_obj_scene_player_id() of
        [] -> ?DEBUG("no players in scene");
        PlayersInScene ->
            mod_socket:send_to_player_list(PlayersInScene, proto:encode(Out))
    end.

set_against_data(BossId1, BossId2) ->
    Sql = io_lib:format("select if(winner = 1, away_boss, home_boss) as winner, if(winner = 1, home_boss, away_boss) as loser, created_time from `boss_one_on_one` where (away_boss = ~p and home_boss = ~p) or (away_boss = ~p and home_boss = ~p) order by created_time desc limit 20",
        [util:to_list(BossId1), util:to_list(BossId2), util:to_list(BossId2), util:to_list(BossId1)]),
    OneOnOneRecordInDb =
        case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
            {error, Msg} ->
                ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
                error;
            {data, SelectRes} ->
                Fun = fun(R) ->
                    R#ets_boss_one_on_one_record{row_key = R#ets_boss_one_on_one_record.created_time}
                      end,
                L = lib_mysql:as_record(SelectRes, ets_boss_one_on_one_record, record_info(fields, ets_boss_one_on_one_record), Fun),
                L
        end,
    ets:insert_new(?ETS_BOSS_ONE_ON_ONE_RECORD, OneOnOneRecordInDb),
    ok.

get_against_record() ->
    [HomeBossId, AwayBossId] = [BossId || {_Monster, BossId} <- mod_mission_one_on_one:get_against()],
    HomeBossWinInEts = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{#ets_boss_one_on_one_record{winner = HomeBossId, loser = AwayBossId, _ = '_'}, [], ['$_']}]),
    HomeBossLoseInEts = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{#ets_boss_one_on_one_record{winner = AwayBossId, loser = HomeBossId, _ = '_'}, [], ['$_']}]),
    HomeBossWin = length(HomeBossWinInEts),
    HomeBossLose = length(HomeBossLoseInEts),
    R = if
            HomeBossWin =:= 0 andalso HomeBossLose =:= 0 ->
                ?DEBUG("have not fighted yet"),
                {
                    {HomeBossId, 0.0}, {AwayBossId, 0.0}, []
                };
            true ->
                MatchList =
                    lists:filtermap(
                        fun(MonsterId) ->
                            #obj_scene_actor{
                                base_id = BossId, obj_id = _MonsterIdMatch, x = X
                            } = mod_scene_monster_manager:get_obj_scene_monster(MonsterId),
                            {true, {X, BossId}}
                        end,
                        mod_scene_monster_manager:get_all_obj_scene_spec_monster_id()
                    ),
                {_, FirstBossId} = lists:nth(1, lists:sort(MatchList)),
                {Left, Right} =
                    if
                        FirstBossId =:= HomeBossId ->
                            {
                                {HomeBossId, util:to_float(HomeBossWin / (HomeBossWin + HomeBossLose))},
                                {AwayBossId, util:to_float(HomeBossLose / (HomeBossWin + HomeBossLose))}
                            };
                        true ->
                            {
                                {AwayBossId, util:to_float(HomeBossLose / (HomeBossWin + HomeBossLose))},
                                {HomeBossId, util:to_float(HomeBossWin / (HomeBossWin + HomeBossLose))}
                            }

                    end,
                AgainstRecordList = util_list:rkeysort(#ets_boss_one_on_one_record.created_time, HomeBossWinInEts ++ HomeBossLoseInEts),
                {
                    Left, Right,
                    lists:sublist(AgainstRecordList, 1, 20)
                }
        end,
    R.
get_against_record(PlayerId, Msg) ->
    [HomeBossId, AwayBossId] = [BossId || {_Monster, BossId} <- mod_mission_one_on_one:get_against()],
    HomeBossWinInEts = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{#ets_boss_one_on_one_record{winner = HomeBossId, loser = AwayBossId, _ = '_'}, [], ['$_']}]),
    HomeBossLoseInEts = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{#ets_boss_one_on_one_record{winner = AwayBossId, loser = HomeBossId, _ = '_'}, [], ['$_']}]),
    HomeBossWin = length(HomeBossWinInEts),
    HomeBossLose = length(HomeBossLoseInEts),
    R = if
            HomeBossWin =:= 0 andalso HomeBossLose =:= 0 ->
                ?DEBUG("have not fighted yet"),
                {
                    {HomeBossId, 0.0}, {AwayBossId, 0.0}, []
                };
            true ->
                ?DEBUG("OK: ~p", [mod_scene_monster_manager:get_all_obj_scene_monster_id()]),
                Res =
                    case mod_scene_monster_manager:get_all_obj_scene_monster_id() of
                        [] -> get(temp_record);
                        L ->
                            ?DEBUG("get_all_obj_scene_monster: ~p", [L]),
                            MatchList =
                                lists:filtermap(
                                    fun(MonsterId) ->
                                        #obj_scene_actor{
                                            base_id = BossId, obj_id = _MonsterIdMatch, x = X
                                        } = mod_scene_monster_manager:get_obj_scene_monster(MonsterId),
                                        {true, {X, BossId}}
                                    end,
                                    mod_scene_monster_manager:get_all_obj_scene_monster_id()
                                ),
                            {_, FirstBossId} = lists:nth(1, lists:sort(MatchList)),

                            {Left, Right} =
                                if
                                    FirstBossId =:= HomeBossId ->
                                        {
                                            {HomeBossId, util:to_float(HomeBossWin / (HomeBossWin + HomeBossLose))},
                                            {AwayBossId, util:to_float(HomeBossLose / (HomeBossWin + HomeBossLose))}
                                        };
                                    true ->
                                        {
                                            {AwayBossId, util:to_float(HomeBossLose / (HomeBossWin + HomeBossLose))},
                                            {HomeBossId, util:to_float(HomeBossWin / (HomeBossWin + HomeBossLose))}
                                        }

                                end,
                            AgainstRecordList = util_list:rkeysort(#ets_boss_one_on_one_record.created_time, HomeBossWinInEts ++ HomeBossLoseInEts),
                            {
                                Left, Right,
                                lists:sublist(AgainstRecordList, 1, 20)
                            }
                    end,
                Res
        end,
    if
        Msg =:= ?GET_ONE_ON_ONE_AGAINST ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, mod_boss_one_on_one, handle_get_record, [PlayerId, R], store);
%%            ?DEBUG("Res: ~p", []);
        Msg =:= ?GET_ONE_ON_ONE_WIN_RATE ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, mod_boss_one_on_one, handle_get_win_rate, [PlayerId, R], store);
%%            ?DEBUG("Res: ~p", []);
        true -> R
    end.
