%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 7月 2021 上午 10:24:58
%%%-------------------------------------------------------------------
-module(mod_hero_versus_boss).
-author("Administrator").

-include("hero_versus_boss.hrl").
-include("msg.hrl").
-include("error.hrl").
-include("scene.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("mission.hrl").
-include("p_message.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("guess_boss.hrl").
-include("scene_boss_pos.hrl").
-include("client.hrl").
-include("skill.hrl").
-include("p_enum.hrl").
-include("one_on_one.hrl").
-include("db_config.hrl").

%% API
-export([
    get_lineup/1,           %% 获取出战信息
    get_boss_id/0,
    create_robot/9,         %% 创建机器人
    create_hero/1,          %% 创建英雄
    create_monster/0,       %% 创建boss
    pack_robot_out/0,
    pack_robot_out/1,
    gen_skill_timestamp/0,  %% 生成大招释放时间点列表

    handle_player_bet/2,    %% 玩家投注
    handle_notice_player_bet/1, %% 通知其他玩家当前最新投注情况(扣除自己的投注数据)
    handle_my_bet/1,        %% 玩家进入场景，获取自己的投注记录
    heartbeat/2,            %% 怪物、机器人心跳
    defender_dead/2,
    fight/1                 %% 战斗
]).

-export([
    get_against/0,
    get_against_record/0,
    get_against_record/2,
    set_against_data/2,
    get_record/1,
    handle_get_record/3,
    handle_get_win_rate/2          %%
]).

-export([
    get_record/2,
    get_against_record/3,
    get_against_record/1,
    handle_get_record/2
]).

fight(#scene_state{map_id = _MapId } = _State) ->
    put(?HERO_VERSUS_BOSS_FIGHT_STATUS, ?TRUE),
    Lineup = get(?LINEUP_POS),
    FightingTuple =
        lists:filtermap(
            fun({Side, HeroBossTupleList}) ->
                RobotId =
                    case lists:keyfind(hero, 1, HeroBossTupleList) of
                        {hero, {_HeroTuple, _HeroPos, HeroRobotId}} -> HeroRobotId;
                        false -> null
                    end,
                MonsterId =
                    case lists:keyfind(boss, 1, HeroBossTupleList) of
                        {boss, {_BossTuple, _BossPos, Monster}} -> Monster;
                        {boss, {{BossId, Num}, {MonsterX, MonsterY}}} ->
                            ?DEBUG("not found monsterid: ~p", [{{BossId, Num}, {MonsterX, MonsterY},
                                mod_scene_monster_manager:get_all_obj_scene_monster_id()}]),
                            MatchMonsterIdList =
                                lists:filtermap(
                                    fun(MonsterInScene) ->
                                        #obj_scene_actor{ x = MatchMonsterX, y = MatchMonsterY, obj_id = MatchMonsterId} =
                                            ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, MonsterInScene),
                                        if
                                            MatchMonsterX =:= MonsterX andalso MatchMonsterY =:= MonsterY ->
                                                NewBossData = lists:keyreplace(boss, 1, HeroBossTupleList,
                                                    {boss, {{BossId, Num}, {MonsterX, MonsterY}, MatchMonsterId}}),
                                                NewHeroBossTupleList = lists:keyreplace(Side, 1, get(?LINEUP_POS),
                                                    {Side, NewBossData}),
                                                put(?LINEUP_POS, NewHeroBossTupleList),
                                                {true, MatchMonsterId};
                                            true -> false
                                        end
                                    end,
                                    mod_scene_monster_manager:get_all_obj_scene_monster_id()
                                ),
                            hd(MatchMonsterIdList);
                        false -> null
                    end,
                self() ! {?MSG_HERO_VERSUS_BOSS_FIGHTING, RobotId},
                self() ! {?MSG_HERO_VERSUS_BOSS_FIGHTING, MonsterId},
                {true, {Side, RobotId, MonsterId}}
            end,
            Lineup
        ),
    put(?FIGHTING_TUPLE, FightingTuple).

defender_dead(DefenderId, Type) ->
%%    put(?HERO_VERSUS_BOSS_FIGHT_STATUS, ?FALSE),
    put(boss_skill, ?UNDEFINED),
    put(?HERO_VERSUS_BOSS_MAX_BOSS_HP, ?UNDEFINED),
    put(?HERO_VERSUS_BOSS_MIN_HERO_DAMAGE, ?UNDEFINED),
    put(?HERO_VERSUS_BOSS_SKILL_TIMES, ?UNDEFINED),
    put(?HERO_VERSUS_BOSS_SKILL_TIME, ?UNDEFINED),
    put(?HERO_VERSUS_BOSS_SKILL_ID_TIME, ?UNDEFINED),
    put(?HERO_VERSUS_BOSS_RANDOM_ROBOT_ID, ?UNDEFINED),
    RealType = ?IF(Type =:= ?OBJ_TYPE_PLAYER, hero, boss),
    ?INFO("受击者~p死亡", [DefenderId]),
    ValidObj =
        case get(?LINEUP_POS) of
            ?UNDEFINED -> ok;
            LineupPosList -> LineupPosList
        end,
    if
        is_list(ValidObj) ->
            WinnerSide1 =
                lists:filtermap(
                    fun({Pos, HeroBosTupleList}) ->
                        case lists:keyfind(RealType, 1, HeroBosTupleList) of
                            false -> false;
                            {RealType, ObjTupleInfo} ->
                                ObjId =
                                    if
                                        RealType =:= hero -> {_, _, RobotId} = ObjTupleInfo, RobotId;
                                        true -> {_, _, MonsterId} = ObjTupleInfo, MonsterId
                                    end,
                                if
                                    ObjId =:= DefenderId -> put(winner_side, Pos);
                                    true -> put(loser_side, Pos)
                                end,
                                ?IF(ObjId =:= DefenderId, {true, Pos}, false)
                        end
                    end,
                    ValidObj
                ),
            WinnerSide = hd(WinnerSide1),
            WinnerRobotId =
                case lists:keyfind(WinnerSide, 1, ValidObj) of
                    false -> ok;
                    {WinnerSide, WinnerSideInfo} ->
                        case lists:keyfind(hero, 1, WinnerSideInfo) of
                            false -> ok;
                            {hero, HeroTupleInfo} ->
                                {_, _, WinnerId} = HeroTupleInfo,
                                WinnerId
                        end
                end,
%%            put(?HERO_VERSUS_BOSS_WINNER, WinnerRobotId),
            %% 停止剩余所有hero的心跳，删除loss hero的boss对象，并下发通知告知
%%            lists:foreach(
%%                fun(MonsterId) ->
%%                    case ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, MonsterId) of
%%                        ?UNDEFINED -> ok;
%%                        WinnerMonster when is_record(WinnerMonster, obj_scene_actor) andalso MonsterId =/= DefenderId ->
%%                            mod_scene_actor:delete_obj_scene_actor(?OBJ_TYPE_MONSTER, MonsterId),
%%                            DeleteMonsterDelay =
%%                                case get(?HERO_VERSUS_BOSS_DELAY_BALANCE) of
%%                                    ?UNDEFINED -> 1 * ?SECOND_MS;
%%                                    Delay -> Delay
%%                                end,
%%                            ?DEBUG("MonsterDelay: ~p", [DeleteMonsterDelay]);
%%                            erlang:send_after(DeleteMonsterDelay, self(), {?MSG_NOTICE_MONSTER_LEAVE, MonsterId});
%%                            erlang:send(self(), {?MSG_NOTICE_MONSTER_LEAVE, MonsterId});
%%                        _LoserMonster -> ok
%%                    end
%%                end,
%%                mod_scene_monster_manager:get_all_obj_scene_monster_id()
%%            ),
            DelayTime = 1 * ?SECOND_MS,
            put(?HERO_VERSUS_BOSS_WINNER, WinnerRobotId),
            put(?HERO_VERSUS_BOSS_STATUS, {6, util_time:milli_timestamp()}),
            put(notice_monster_enter, ?FALSE),
%%            erlang:send_after(?SECOND_MS, self(), {?MSG_HERO_VERSUS_BOSS_ROUND}),
            mod_mission:send_msg_delay(?MSG_HERO_VERSUS_BOSS_ROUND, DelayTime),
            ?DEBUG("~p 获胜！：~p", [WinnerSide, WinnerRobotId]);
        true -> ok
    end.

heartbeat(AttackerId, State) ->
    ?ASSERT(get(?HERO_VERSUS_BOSS_FIGHT_STATUS) =:= ?TRUE, stop_fighting),
    Now = util_time:milli_timestamp(),
    FightingStatus =
        case get(?FIGHTING_TUPLE) of
            L when is_list(L) -> L;
            O -> ?DEBUG("FightingStatus: ~p", [O]), ?UNDEFINED
        end,
    ?ASSERT(FightingStatus =/= ?UNDEFINED, done),
    AgainstTupleList =
        lists:filtermap(
            fun({_Side, RobotId, MonsterId}) ->
                if
                    RobotId =:= AttackerId orelse MonsterId =:= AttackerId ->
                        DefenderIdInLoop = ?IF(RobotId =:= AttackerId, MonsterId, RobotId),
                        AttackerTypeInLoop = ?IF(RobotId =:= AttackerId, ?OBJ_TYPE_PLAYER, ?OBJ_TYPE_MONSTER),
                        DefenderTypeInLoop = ?IF(AttackerTypeInLoop =:= ?OBJ_TYPE_PLAYER, ?OBJ_TYPE_MONSTER, ?OBJ_TYPE_PLAYER),
                        {true, {{AttackerTypeInLoop, AttackerId}, {DefenderTypeInLoop, DefenderIdInLoop}}};
                    true -> false
                end
            end,
            FightingStatus
        ),
    ?ASSERT(length(AgainstTupleList) =:= 1, invalid_against_tuple),
    {{AttackerType, _}, {DefenderType, DefenderId}} = hd(AgainstTupleList),

    AttackerObj = ?GET_OBJ_SCENE_ACTOR(AttackerType, AttackerId),
    ?ASSERT(AttackerObj =/= ?UNDEFINED,
        {?IF(AttackerType =:= ?OBJ_TYPE_MONSTER, monster_attacker_dead, robot_attacker_dead), AttackerId}),
    #obj_scene_actor{
        x = AttackerX, y = AttackerY, dir = _AttackerDir, next_can_heart_time = AttackerHeartbeatTime, hp =AttackerHp,
        last_fight_time_ms = LastAttackedTime, last_fight_skill_id = _LastFightSkillId, r_active_skill_list = ActiveSkillList
    } = AttackerObj,
    ?ASSERT(AttackerHp > 0,
        {?IF(DefenderType =:= ?OBJ_TYPE_MONSTER, monster_attacker_dead, robot_attacker_dead), AttackerId}),

    DefenderObj = ?GET_OBJ_SCENE_ACTOR(DefenderType, DefenderId),
    ?ASSERT(DefenderObj =/= ?UNDEFINED,
        {?IF(DefenderType =:= ?OBJ_TYPE_MONSTER, monster_defender_dead, robot_defender_dead), DefenderId}),
    #obj_scene_actor{
        hp = DefenderCurrentHp, x = DefenderX, y = DefenderY, dir = _DefenderDir,
        next_can_heart_time = _DefenderHeartbeatTime
    } = DefenderObj,
    ?ASSERT(DefenderCurrentHp > 0,
        {?IF(DefenderType =:= ?OBJ_TYPE_MONSTER, monster_defender_dead, robot_defender_dead), DefenderId}),
%%    PlayersInScene = [Player || Player <- mod_scene_player_manager:get_all_obj_scene_player_id(), Player >= 10000],

    if
        AttackerHeartbeatTime =< Now ->
            UseSkill = use_skill(AttackerId, Now),
            {
                SkillId, SkillInterval, Damage, AttackRange, _HitBackRange, HurtDelayTime, CritDamage, Crit, Dodge
            } = get_skill_info(ActiveSkillList, UseSkill, AttackerType),
            %% 判断距离是否足以攻击
            Distance = util_math:get_distance({AttackerX, AttackerY}, {DefenderX, DefenderY}),
            if
                Distance > AttackRange ->
                    RealDiffDistance = Distance - AttackRange,
%%                    ?DEBUG("~p移动: ~p", [AttackerId, {Distance, AttackRange, RealDiffDistance,
%%                        {AttackerX, AttackerY}, {DefenderX, DefenderY}}]),
                    move(AttackerObj, {DefenderX, DefenderY}, RealDiffDistance, Now, State);
                true ->
                    AttackerAfterStop = stop_move(AttackerObj, State),
                    %% cool down?
                    if
                        SkillInterval + LastAttackedTime =< Now ->
                            {RealDamage, DoesDodge, DoesCrit} = dodge_or_crit(Crit, Dodge, Damage, CritDamage),

                            {DefenderXAfterAttacked, DefenderYAfterAttacked, DefenderDirAfterAttacked} =
                                if
                                    UseSkill =:= true ->
                                        %% 使用技能，defender会被击退，此时需要计算defender的新坐标
                                        {0, 0, ?DIR_DOWN};
                                    true -> {0, 0, ?DIR_DOWN}
                                end,

                            NewDefenderHp = ?IF(DefenderCurrentHp - RealDamage > 0, DefenderCurrentHp - RealDamage, 0),
                            NewDefenderObj = DefenderObj#obj_scene_actor{
                                hp = NewDefenderHp, last_attacked_time_ms = Now,
%%                                x = DefenderXAfterAttacked, y = DefenderYAfterAttacked,
                                dir = DefenderDirAfterAttacked
%%                                next_can_heart_time = Now
                            },
                            ?UPDATE_OBJ_SCENE_ACTOR(NewDefenderObj),

%%                            NewAttackerDir = util_math:get_direction({AttackerX, AttackerY}, {DefenderX, DefenderY}),
                            NewAttackerDir = ?IF(AttackerType =:= ?OBJ_TYPE_MONSTER, ?DIR_DOWN, ?DIR_UP),
                            NewAttackerObj = AttackerAfterStop#obj_scene_actor{
                                next_can_heart_time = Now + SkillInterval, last_fight_skill_id = SkillId,
                                dir = NewAttackerDir
                            },
                            ?UPDATE_OBJ_SCENE_ACTOR(NewAttackerObj),

                            AttackInfo = {Now, DoesDodge, DoesCrit,
                                RealDamage, SkillId, HurtDelayTime, DefenderXAfterAttacked, DefenderYAfterAttacked
                            },
                            pack_hero_versus_boss_out(NewAttackerObj, NewDefenderObj, AttackInfo),
                            if
                                NewDefenderHp > 0 ->
                                    erlang:send_after(SkillInterval, self(), {?MSG_HERO_VERSUS_BOSS_FIGHTING, AttackerId});
                                true ->
                                    %% 结算状态延迟
                                    put(?HERO_VERSUS_BOSS_DELAY_BALANCE, HurtDelayTime),
                                    exit({
                                        ?IF(DefenderType =:= ?OBJ_TYPE_MONSTER, monster_defender_dead, robot_defender_dead),
                                        DefenderId
                                    })
                            end;
                        true -> ok
                    end
            end;
        true ->
            erlang:send_after(200, self(), {?MSG_HERO_VERSUS_BOSS_FIGHTING, AttackerId})
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
    PlayersInScene = [Player || Player <- mod_scene_player_manager:get_all_obj_scene_player_id(), Player >= 10000],
    api_scene:notice_monster_stop_move(?IF(IsAllSync, PlayersInScene, mod_scene_grid_manager:get_subscribe_player_id_list(GridId)), ObjMonsterId, X, Y),
    ObjMonster#obj_scene_actor{move_path = [], go_x = 0, go_y = 0, is_wait_navigate = false}.

move(MovementObject, {TargetX, TargetY}, RealDiffDistance, NowMs, State) ->
    #obj_scene_actor{ hp = MovementCurrentHp, obj_id = MovementObjId} = MovementObject,
    ?ASSERT(MovementCurrentHp > 0, attacker_dead),

    NewMovementObj = monster_find_path(MovementObject, {TargetX, TargetY}, true, RealDiffDistance, ?MOVE_TYPE_NORMAL, State),
    MovementObjUpdateHeartbeatTime = NewMovementObj#obj_scene_actor{
        next_can_heart_time = NowMs + 200
    },
%%    ?UPDATE_OBJ_SCENE_MONSTER(MovementObjUpdateHeartbeatTime),
%%    mod_scene_monster_manager:handle_heart_beat(MovementObjId, State),
    MovementObjAfterMoveDeal = mod_scene:deal_move_step(MovementObjUpdateHeartbeatTime, NowMs, State),
    ?UPDATE_OBJ_SCENE_MONSTER(MovementObjAfterMoveDeal),
    erlang:send_after(200, self(), {?MSG_HERO_VERSUS_BOSS_FIGHTING, MovementObjId}).

monster_find_path(ObjInScene, {TargetX, TargetY}, IsFloyd, Diff, MoveType,
    #scene_state{scene_id = _SceneId, scene_navigate_worker = NavigateWorker}) ->
    #obj_scene_actor{
        obj_id = ObjSceneId,
        obj_type = ObjSceneType,
        x = X,
        y = Y
    } = ObjInScene,
    MaxNavigateNode = 1500,
    scene_navigate_worker:request_navigate(NavigateWorker, ObjSceneType, ObjSceneId, {X, Y}, {TargetX, TargetY}, IsFloyd, true, MaxNavigateNode, Diff),
    ObjInScene#obj_scene_actor{
        is_wait_navigate = true,
        move_type = MoveType
    }.

pack_hero_versus_boss_out(AttackerObj, DefenderObj, OtherAttackInfo) ->
    {
        Now, DoesDodge, DoesCrit, RealDamage, SkillId, HurtDelayTime, DefenderXAfterAttacked, DefenderYAfterAttacked
    } = OtherAttackInfo,
    #obj_scene_actor{
        obj_id = AttackerId, obj_type = AttackerType, x = AttackerX, y = AttackerY, dir = AttackerDir
    } = AttackerObj,
    #obj_scene_actor{
        obj_id = DefenderId, obj_type = DefenderType, hp = DefenderHp
    } = DefenderObj,
    HeroVersusBossDefenderResult = [#heroversusbossdefenderresult{
        defender_id = DefenderId, defender_type = DefenderType,
        hp = DefenderHp, hurt = RealDamage,
        type = ?IF(DoesDodge =:= ?TRUE, ?P_DODGE,
            ?IF(DoesCrit =:= ?TRUE, ?P_CRIT, ?P_NORMAL)),
        x = DefenderXAfterAttacked, y = DefenderYAfterAttacked,
        buff_list = [], effect_list = [],  hurt_section_list = [],
        total_mano = 0, all_total_mano = 0, beat_times = 1, mano_award = 0,
        exp = 0, special_event = 0, dizzy_close_time = 0, award_player_id = 0,
        timestamp = Now + HurtDelayTime
    }],
    FightOut =
        #m_mission_notice_hero_versus_boss_fight_toc{
            attacker_id = AttackerId, attacker_type = AttackerType,
            x = AttackerX, y = AttackerY, dir = AttackerDir,
            target_id = DefenderId, target_type = DefenderType,
            skill_id = SkillId, skill_level = 1, anger = 0,
            timestamp = Now,
            defender_result_list = HeroVersusBossDefenderResult
        },
    PlayersInScene = [Player || Player <- mod_scene_player_manager:get_all_obj_scene_player_id(), Player >= 10000],
    if
        length(PlayersInScene) > 0 -> mod_socket:send_to_player_list(PlayersInScene, proto:encode(FightOut));
        true -> ok
    end.

dodge_or_crit(Crit, Dodge, Damage, CritDamage) ->
    CanCrit = util_random:random_number(0, 10000),
    {RealDamage1, DoesCrit} = ?IF(CanCrit =< Crit, {CritDamage, ?TRUE}, {Damage, ?FALSE}),

    CanDodge = util_random:random_number(0, 10000),
    {RealDamage, DoesDodge} = ?IF(CanDodge =< Dodge, {0, ?TRUE}, {RealDamage1, ?FALSE}),

    {RealDamage, DoesDodge, DoesCrit}.

get_skill_info(ActiveSkillList, UseSkill, AttackerType) when is_list(ActiveSkillList) andalso is_boolean(UseSkill) ->
    SkillList =
        lists:filtermap(
            fun(Skill) ->
                if
                    AttackerType =:= ?OBJ_TYPE_MONSTER ->
                        #t_mission_guess_boss_skill{
                            id = SkillId1,
                            attack_time = AttackInterval1,
                            attack_range = AttackRange1,
%%                            attack_damage = AttackDamage1,
                            attack_damage_list = AttackDamageList,
                            hurt_delay_time = HurtDelayTime,
                            hit_back_range = HitBackRange,
%%                            crit_damage = CritDamage,
                            crit_damage_list = CritDamageList,
                            type = Type,
                            crit = Crit,
                            dodge = Dodge
                        } = Skill,
                        [MinAttackDamage, MaxAttackDamage] = AttackDamageList,
                        AttackDamage1 = util_random:random_number(MinAttackDamage, MaxAttackDamage),
                        [MinCritDamage, MaxCritDamage] = CritDamageList,
                        CritDamage = util_random:random_number(MinCritDamage, MaxCritDamage),
                        if
                            (UseSkill =:= true andalso Type =:= 2) orelse
                                (UseSkill =:= false andalso Type =:= 1) ->
                                {true, {SkillId1, AttackInterval1, AttackDamage1, AttackRange1, HitBackRange,
                                    HurtDelayTime, CritDamage, Crit, Dodge}};
                            true -> false
                        end;
                    AttackerType =:= ?OBJ_TYPE_PLAYER ->

                        #r_active_skill{
                            id = SkillId1, is_common_skill = IsCommonSkill
                        } = Skill,
                        if
                            IsCommonSkill =:= UseSkill ->
                                #t_mission_guess_boss_skill{
                                    attack_time = AttackInterval1,
                                    attack_range = AttackRange1,
%%                                    attack_damage = AttackDamage1,
                                    attack_damage_list = AttackDamageList,
                                    hurt_delay_time = HurtDelayTime,
                                    hit_back_range = HitBackRange,
%%                                    crit_damage = CritDamage,
                                    crit_damage_list = CritDamageList,
                                    crit = Crit,
                                    dodge = Dodge
                                } = t_mission_guess_boss_skill:get({SkillId1}),

                                [MinAttackDamage, MaxAttackDamage] = AttackDamageList,
                                AttackDamage1 = util_random:random_number(MinAttackDamage, MaxAttackDamage),
                                [MinCritDamage, MaxCritDamage] = CritDamageList,
                                CritDamage = util_random:random_number(MinCritDamage, MaxCritDamage),

                                %% 设置下次使用技能的时间点
                                {true, {SkillId1, AttackInterval1, AttackDamage1, AttackRange1, HitBackRange,
                                    HurtDelayTime, CritDamage, Crit, Dodge}};
                            true ->
                                false
                        end;
                    true -> false
                end
            end,
            ActiveSkillList
        ),
    if
        length(SkillList) > 0 -> hd(SkillList);
        true -> ?WARNING("找不到对应技能: ~p", [{ActiveSkillList, UseSkill}]), exit(none_skill)
    end;
get_skill_info(ActiveSkillList, UseSkill, AttackerType) ->
    ?ERROR("unexectpion error: ~p", [{ActiveSkillList, UseSkill, AttackerType}]),
    exit(none_skill).

gen_skill_timestamp() ->
    Time = util_time:milli_timestamp(),
    put(?HERO_VERSUS_BOSS_SKILL_TIMES, 4 * ceil(get(?HERO_VERSUS_BOSS_MAX_BOSS_HP) / get(?HERO_VERSUS_BOSS_MIN_HERO_DAMAGE))),
    MonstersInScene = [{MonsterId, 10000} || MonsterId <- mod_scene_monster_manager:get_all_obj_scene_monster_id()],
    RobotInScene = [{RobotId, 10000} || RobotId <- mod_scene_player_manager:get_all_obj_scene_player_id(), RobotId < 10000],
    SkillObjTupleList = util_list:shuffle(MonstersInScene ++ RobotInScene),
    SkillTimeList =
        lists:foldl(
            fun(Times, SkillObjTimeListTmp) ->
                [Min, Max] =
                    if
                        Times =:= 1 ->
                            [FirstSkillMin, FirstSkillMax] = ?SD_HERO_VS_BOSS_MISSION_SKILL_FIRST_TIME_LIST,
                            [FirstSkillMin * ?SECOND_MS, FirstSkillMax * ?SECOND_MS];
                        true ->
                            [SkillMin, SkillMax] = ?SD_HERO_VS_BOSS_MISSION_SKILL_CD_TIME_LIST,
                            [SkillMin * ?SECOND_MS, SkillMax * ?SECOND_MS]
                    end,
                Interval = util_random:random_number(Min, Max),
%%                {_, Time} = get(hero_versus_boss_status),
                RealTime =
                    case get(?HERO_VERSUS_BOSS_SKILL_TIME) of
                        ?UNDEFINED -> Time + Interval;
                        LastSkillTime -> LastSkillTime + Interval
                    end,
                put(?HERO_VERSUS_BOSS_SKILL_TIME, RealTime),
                SkillObjId = util_random:get_probability_item(SkillObjTupleList),
                SkillObjTimeListTmp ++ [{SkillObjId, RealTime}]
%%                [{SkillObjId, RealTime} | SkillObjTimeListTmp]
            end,
            [],
            lists:seq(1, get(?HERO_VERSUS_BOSS_SKILL_TIMES))
        ),
    put(?HERO_VERSUS_BOSS_SKILL_ID_TIME, SkillTimeList),
    ?INFO("生成大招: ~p", [{Time, get(?HERO_VERSUS_BOSS_SKILL_ID_TIME)}]).


%% ----------------------------------
%% @doc 	获取随机数 [Min, Max]
%% @throws 	none
%% @end
%% ----------------------------------
use_skill(AttackerId, Now) ->
    case get(?HERO_VERSUS_BOSS_SKILL_ID_TIME) of
        ?UNDEFINED -> false;
        ObjIdTimeTupleList ->
            {ObjId, UseSkillTimestamp} = hd(ObjIdTimeTupleList),
            if
                ObjId =:= AttackerId andalso Now >= UseSkillTimestamp ->
                    AfterUserSkill = lists:delete({ObjId, UseSkillTimestamp}, ObjIdTimeTupleList),
                    put(?HERO_VERSUS_BOSS_SKILL_ID_TIME, AfterUserSkill),
                    true;
                true -> false
            end
    end.

get_boss_id() ->
    get(?HERO_VERSUS_BOSS_BOSS_ID).

%% 获取出场boss
get_lineup(SceneId) ->
    #t_scene{
        monster_x_y_list = MonsterPosList
    } = t_scene:get({SceneId}),
    BossRateTupleList = [{BossId, 10000} || BossId <- ?SD_HERO_VS_BOSS_MISSION_BOSS_LIST],
    HeroRateTupleList = [{{HeroId, HeroWeaponId, AccessoriesId, AttackId, SkillId}, 10000} ||
        [HeroId, HeroWeaponId, AccessoriesId, AttackId, SkillId] <- ?SD_HERO_VS_BOSS_MISSION_HERO_LIST],
    HeroList = util_random:get_probability_item_count(HeroRateTupleList, ?HERO_NUM),
    set_max_hp(?SD_HERO_VS_BOSS_MISSION_BOSS_HP),
%%    ?DEBUG("HeroList: ~p", [{HeroList, HeroRateTupleList}]),
    RealHeroList = util_list:shuffle(HeroList),
%%    ?INFO("MonsterPosList: ~p", [MonsterPosList]),
    RealMonsterPosList = [{X, Y} || [X, Y] <- MonsterPosList],
    BossId = util_random:get_probability_item_count(BossRateTupleList, ?BOSS_NUM),
    RealBossId = hd(BossId),
    put(?HERO_VERSUS_BOSS_BOSS_ID, RealBossId),
    ?DEBUG("bossId: ~p", [get(?HERO_VERSUS_BOSS_BOSS_ID)]),
%%    ?INFO("MonsterBoss: ~p", [{
%%        RealMonsterPosList,
%%        lists:seq(1, length(RealMonsterPosList))
%%    }]),
    LineupPos =
        lists:foldl(
            fun(Idx, Tmp) ->
                Side = Idx div (?HERO_NUM + 1),
                Tmp1 =
                    case lists:keyfind(Side, 1, Tmp) of
                        false ->
                            {HeroX, HeroY} = lists:nth(Idx, RealMonsterPosList),
                            mod_mission_hero_versus_boss:set_hero_versus_boss_pos(hero, Side, {HeroX, HeroY}),
%%                            put({hero_versus_boss_pos, Type, X, Y}, Side),
%%                            put({hero_versus_boss_pos, Type, Side}, {X, Y}),
                            HeroTuple = lists:nth(Side + 1, RealHeroList),
                            {_, _, _, _, SkillId} = HeroTuple,
                            #t_mission_guess_boss_skill{
                                attack_damage = Damage
                            } = t_mission_guess_boss_skill:get({SkillId}),
                            set_min_skill_damage(Damage),
                            NewData = [{Side, [{hero, {HeroTuple, {HeroX, HeroY}}}]}],
                            case length(Tmp) of
                                0 -> NewData;
                                _ -> Tmp ++ NewData
                            end;
                        {Side, DataWithoutBoss} ->
                            case lists:keyfind(boss, 1, DataWithoutBoss) of
                                false ->
                                    {BossX, BossY} = lists:nth(Idx, RealMonsterPosList),
                                    mod_mission_hero_versus_boss:set_hero_versus_boss_pos(boss, Side, {BossX, BossY}),
%%                                    put({hero_versus_boss_pos, boss, BossX, BossY}, Side),
%%                                    put({hero_versus_boss_pos, boss, Side}, {BossX, BossY}),
                                    NewData = DataWithoutBoss ++ [{boss, {{RealBossId, ?HERO_NUM}, {BossX, BossY}}}],
                                    lists:keyreplace(Side, 1, Tmp, {Side, NewData});
                                {boss, DataWithBoss} -> ?DEBUG("data with boss: ~p", [DataWithBoss])
                            end
                    end,
                Tmp1
            end,
            [],
            lists:seq(1, length(RealMonsterPosList))
        ),
    put(?LINEUP_POS, LineupPos),
    ?INFO("?LINEUP_POS: ~p", [get(?LINEUP_POS)]),
    ok.

set_min_skill_damage(SkillDamage) ->
    MinDamage =
        case get(?HERO_VERSUS_BOSS_MIN_HERO_DAMAGE) of
            ?UNDEFINED -> SkillDamage;
            Damage -> ?IF(Damage > SkillDamage, SkillDamage, Damage)
        end,
    put(?HERO_VERSUS_BOSS_MIN_HERO_DAMAGE, MinDamage).

set_max_hp(Hp) ->
    MaxHp =
        case get(?HERO_VERSUS_BOSS_MAX_BOSS_HP) of
            ?UNDEFINED -> Hp;
            OldHp -> ?IF(OldHp > Hp, OldHp, Hp)
        end,
    put(?HERO_VERSUS_BOSS_MAX_BOSS_HP, MaxHp).

%% ----------------------------------------
%% 创建英雄
%% ----------------------------------------
create_robot(RobotId, HeroId, WeaponId, AccessoriesId, AttackId, SkillId, {X, Y}, {_BossX, _BossY}, MaxHp) ->
    NewRobotId =
        case get(robot_in_hero_versus_boss) of
            ?UNDEFINED -> [RobotId];
            L -> L ++ [RobotId]
        end,
    put(robot_in_hero_versus_boss, NewRobotId),
    RobotDir = ?DIR_UP,
%%    RobotDir = util_math:get_direction({X, Y}, {BossX, BossY}),
%%    ?DEBUG("RobotId: ~p ~p", [RobotId, {{X, Y}, {BossX, BossY}, RobotDir}]),

    Robot = #obj_scene_actor{
        key = {?OBJ_TYPE_PLAYER, RobotId},
        obj_id = RobotId,
        obj_type = ?OBJ_TYPE_PLAYER,
        base_id = 0,
        is_robot = true,
        max_hp = MaxHp,
        hp = MaxHp,
        grid_id = ?PIX_2_GRID_ID(X, Y),
        dir = RobotDir,
        x = X,
        y = Y,
        r_active_skill_list = [#r_active_skill{ id = AttackId, is_common_skill = false },
            #r_active_skill{ id = SkillId, is_common_skill = true }],
        surface = #surface{
            hero_id = HeroId,
            hero_arms = WeaponId,
            hero_ornaments = AccessoriesId
        },
        next_can_heart_time = 0
    },
    mod_scene_actor:delete_obj_scene_actor(?OBJ_TYPE_PLAYER, RobotId),
    mod_scene_actor:add_obj_scene_actor(Robot).

%% ----------------------------------------
%% 打包下发给玩家的英雄数据
%% ----------------------------------------
pack_robot_out(Players) when is_list(Players)  ->
    lists:foreach(
        fun(RobotId) ->
            #obj_scene_actor{
                max_hp = MaxHp,
                hp = Hp,
                dir = RobotDir,
                x = X,
                y = Y,
                surface = #surface{
                    hero_id = HeroId,
                    hero_arms = WeaponId,
                    hero_ornaments = AccessoriesId
                }
            } = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_PLAYER, RobotId),

            #t_hero{
                name = Name
            } = t_hero:get({HeroId}),

            RobotEnterSceneOut = #m_scene_notice_scene_player_enter_toc{
                scene_player = #sceneplayer{
                    player_id = RobotId, x = X, y = Y, hp = Hp, max_hp = MaxHp, nickname = list_to_binary(Name),
                    sex = 0, level = 100, vip_level = 5, move_speed = 600, go_x = 0, go_y = 0,
                    move_type = 0, dir = RobotDir, move_path = [],
                    title_id = 0, magic_weapon_id = 0, buff_list = [], anger = 0,
%%                    special_skill_id = 0, special_skill_expire_time = 0, shen_long_time = 0, huo_qiu_time = 0, di_zhen_time = 0,
                    hero_id = HeroId, hero_arms_id = WeaponId, hero_ornaments_id = AccessoriesId,
                    dizzy_close_time = 0, kuangbao_time = 0,
                    player_other_data = #playerotherdata{ head_id = 0, head_frame_id = 0, chat_qi_pao_id = 0}
                }
            },
            mod_socket:send_to_player_list(Players, proto:encode(RobotEnterSceneOut))
        end,
        [RobotInScene || RobotInScene <- mod_scene_player_manager:get_all_obj_scene_player_id(), RobotInScene < 10000]
    );
%% 给指定的场景内玩家下发英雄数据
pack_robot_out(PlayerId) ->
    PlayerInScene = [Player || Player <- mod_scene_player_manager:get_all_obj_scene_player_id(),
        Player >= 10000 andalso PlayerId =:= Player],
    pack_robot_out(PlayerInScene).
%% 给场景内所有玩家下发英雄数据
pack_robot_out() ->
    PlayerInScene = [Player || Player <- mod_scene_player_manager:get_all_obj_scene_player_id(), Player >= 10000],
    pack_robot_out(PlayerInScene).

%% ----------------------------------------
%% 生成随机英雄编号
%% ----------------------------------------
get_random_robot_id() ->
    %% 测试用，提高重复的概率
%%    MatchRobotId = util_random:random_number(1, 2),
    MatchRobotId = util_random:random_number(1, 9999),
    case get(?HERO_VERSUS_BOSS_RANDOM_ROBOT_ID) of
        ?UNDEFINED ->
            put(?HERO_VERSUS_BOSS_RANDOM_ROBOT_ID, [MatchRobotId]),
            MatchRobotId;
        L ->
            case lists:member(MatchRobotId, L) of
                false ->
                    put(?HERO_VERSUS_BOSS_RANDOM_ROBOT_ID, [MatchRobotId]),
                    MatchRobotId;
                true ->
                    ?DEBUG("repeat: ~p", [{L, MatchRobotId}]),
                    get_random_robot_id()
            end
    end.

%% ----------------------------------------
%% 随机生成英雄
%% ----------------------------------------
create_hero(_SceneId) ->
    case get(?LINEUP_POS) of
        [] -> ?ERROR("没有角色需要创建"), noop;
        ?UNDEFINED -> ?ERROR("没有角色需要创建"), noop;
        HeroMonsterList ->
            lists:foreach(
                fun(Pos) ->
                    RealPos = Pos - 1,
                    case lists:keyfind(RealPos, 1, HeroMonsterList) of
                        false -> false;
                        {_, HeroMonsterTupleList} ->
                            {RealBossX, RealBossY} =
                                case lists:keyfind(boss, 1, HeroMonsterTupleList) of
                                    false -> ?ERROR("没有怪物对象"), {0, 0, 0};
                                    {boss, {{_BossId, _}, {BossX, BossY}}} ->
                                        {BossX, BossY}
                                end,
                            case lists:keyfind(hero, 1, HeroMonsterTupleList) of
                                false -> false;
                                {hero, {{HeroId, WeaponId, AccessoriesId, AttackId, SkillId}, {X, Y}}} ->
                                    RobotId = get_random_robot_id(),
                                    NewHeroMonsterList = lists:keyreplace(hero, 1, HeroMonsterTupleList,
                                        {hero, {{HeroId, WeaponId, AccessoriesId, AttackId, SkillId},
                                            {X, Y}, RobotId}}),
                                    NewHeroMonsterTupleList =
                                        lists:keyreplace(RealPos, 1, get(?LINEUP_POS),
                                            {RealPos, NewHeroMonsterList}),
                                    put(?LINEUP_POS, NewHeroMonsterTupleList),
                                    create_robot(RobotId, HeroId, WeaponId, AccessoriesId, AttackId, SkillId,
                                        {X, Y}, {RealBossX, RealBossY}, ?SD_HERO_VS_BOSS_MISSION_HERO_HP)
                            end
                    end
                end,
                lists:seq(1, length(HeroMonsterList))
            )
    end.

handle_my_bet(PlayerId) ->
    {GuessState, _} = get(?HERO_VERSUS_BOSS_STATUS),
    AllBetList = mod_bet_player_manager:get_bet_player_list(?MISSION_TYPE_MISSION_HERO_PK_BOSS),
    AllBetTupleList =
        lists:foldl(
            fun ({_, BetList}, Tmp) ->
                lists:merge(BetList, Tmp)
            end,
            [],
            AllBetList
        ),
    RealAllBetTupleList = [{Pos, Bet} || {Pos, Bet} <- mod_prop:merge_prop_list(AllBetTupleList)],
    Node = mod_player:get_game_node(PlayerId),
    AllBet =
        lists:filtermap(
            fun({PlayerIdInBet, BetTupleList}) ->
                if
                    PlayerIdInBet =:= PlayerId ->
                        BetModification = [#betmodification{pos = Pos - 1, bet = Bet} || {Pos, Bet} <- BetTupleList],
                        Out = #m_mission_hero_versus_boss_bet_info_toc{bet_modification = BetModification},
                        mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice,
                            [PlayerId, Out, ?MSG_PLAYER_BET], store),
                        MyBet4Cal = [{Pos, 0 - Bet} || {Pos, Bet} <- BetTupleList],
                        OtherPlayersBet = mod_prop:merge_prop_list(lists:merge(MyBet4Cal, RealAllBetTupleList)),
                        {true, OtherPlayersBet};
                    true -> false
                end
            end,
            AllBetList
        ),
    OtherPlayersBetOut = [#betmodification{pos = Pos - 1, bet = Bet} ||
        {Pos, Bet} <- ?IF(length(AllBet) =:= 1, hd(AllBet), RealAllBetTupleList)],
    OtherBetOut = #m_mission_hero_versus_boss_bet_modification_toc{bet_modification = OtherPlayersBetOut},
    ?DEBUG("notify others bet: ~p ~p(~p)<~p>", [GuessState,
        mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice,
            [PlayerId, OtherBetOut, ?MSG_PLAYER_BET], store),
        PlayerId, OtherBetOut]).

handle_player_bet(PlayerId, BetTupleList) ->
    RealBetTupleList = [{Pos + 1, Bet} || {Pos, Bet} <- BetTupleList],
    _OldBetTupleList =
        case mod_bet_player_manager:get_single_player_bet(?MISSION_TYPE_MISSION_HERO_PK_BOSS, PlayerId) of
            [] -> ?UNDEFINED;
            BetTupleListInData -> BetTupleListInData
        end,
    mod_bet_player_manager:add_bet_player_list(?MISSION_TYPE_MISSION_HERO_PK_BOSS, {PlayerId, RealBetTupleList}),
    AllPlayersBetTupleList = mod_bet_player_manager:get_bet_player_list(?MISSION_TYPE_MISSION_HERO_PK_BOSS),
    MyBetOut =
        case lists:keyfind(PlayerId, 1, AllPlayersBetTupleList) of
            false ->
                #m_mission_hero_versus_boss_bet_info_toc{
%%                    bet_modification = [#betmodification{pos = P, bet = B} || {P, B} <- BetTupleList]
                    bet_modification = [#betmodification{pos = P, bet = B} || {P, B} <- BetTupleList, B > 0]
                };
            {PlayerId, MyBetTupleList} ->
                MatchBetTupleList = [MatchP + 1 || {MatchP, MatchB} <- BetTupleList, MatchB > 0],
                #m_mission_hero_versus_boss_bet_info_toc{
                    bet_modification = [#betmodification{pos = P - 1, bet = B} || {P, B} <- MyBetTupleList,
                        lists:member(P, MatchBetTupleList)]
%%                    bet_modification = [#betmodification{pos = P, bet = B} || {P, B} <- BetTupleList, B > 0]
                }
        end,
    %% 给投注玩家下发自己的投注信息
    BetPlayerNode = mod_player:get_game_node(PlayerId),
    ?INFO("MyBetRes: ~p", [{PlayerId, mod_apply:apply_to_online_player(BetPlayerNode, PlayerId, mod_bet, handle_notice,
        [PlayerId, MyBetOut, ?MSG_PLAYER_BET], store)}]),
    ?TRUE.

handle_notice_player_bet(PlayerId) ->
    AllBetList = mod_bet_player_manager:get_bet_player_list(?MISSION_TYPE_MISSION_HERO_PK_BOSS),
    AllBetTupleList =
        lists:foldl(
            fun ({_, BetList}, Tmp) ->
                lists:merge(BetList, Tmp)
            end,
            [],
            AllBetList
        ),
    RealAllBetTupleList = [{Pos, Bet} || {Pos, Bet} <- mod_prop:merge_prop_list(AllBetTupleList)],
    lists:foreach(
        fun({PlayerInBet, BetTupleList}) ->
            if
                PlayerId =/= PlayerInBet ->
                    BetInfo = [{Pos, 0 - Bet} || {Pos, Bet} <- BetTupleList],
                    OtherBetInfo = mod_prop:merge_prop_list(lists:merge(BetInfo, RealAllBetTupleList)),
                    BetModification = [#betmodification{pos = Pos - 1, bet = Bet} || {Pos, Bet} <- OtherBetInfo],
                    Out = #m_mission_hero_versus_boss_bet_modification_toc{bet_modification = BetModification},

                    PlayerInBetNode = mod_player:get_game_node(PlayerInBet),
                    mod_apply:apply_to_online_player(PlayerInBetNode, PlayerInBet, mod_bet, handle_notice,
                        [PlayerInBet, Out, ?MSG_PLAYER_BET], store);
                true -> ok
            end
        end,
        AllBetList
    ).

create_monster() ->
    Wait4CreateMonsterList =
        case get(?LINEUP_POS) of
            [] -> ?ERROR("没有怪物需要创建"), noop;
            ?UNDEFINED -> ?ERROR("没有怪物需要创建"), noop;
            HeroMonsterList -> HeroMonsterList
        end,
    if
        Wait4CreateMonsterList =/= noop ->
            lists:foreach(
                fun(Pos) ->
                    RealPos = Pos - 1,
                    case lists:keyfind(RealPos, 1, Wait4CreateMonsterList) of
                        false -> false;
                        {_, HeroMonsterTupleList} ->
                            case lists:keyfind(boss, 1, HeroMonsterTupleList) of
                                false -> false;
                                {boss, {{BossId, _}, {BossX, BossY}}} ->
                                    {hero, HeroTupleList} = lists:keyfind(hero, 1, HeroMonsterTupleList),
                                    {_, {_HeroX, _HeroY}, _HeroRobotId} = HeroTupleList,
%%                                    MonsterDir = util_math:get_direction({BossX, BossY}, {HeroX, HeroY}),
                                    MonsterDir = ?DIR_DOWN,
%%                                    erlang:send(self(), {?MSG_SCENE_CREATE_MONSTER, BossId, BossX, BossY, MonsterDir})
                                    erlang:send_after(100, self(),
                                        {?MSG_SCENE_CREATE_MONSTER, BossId, BossX, BossY, MonsterDir})
                            end
                    end
                end,
                lists:seq(1, length(Wait4CreateMonsterList))
            );
        true -> ok
    end.

set_against_data(HeroTuple, BossId) when is_tuple(HeroTuple) andalso is_integer(BossId) ->
    {HomeHeroId, AwayHeroId} = HeroTuple,
    Sql = io_lib:format("SELECT IF ( winner = 1, away_boss, home_boss ) AS winner, IF ( winner = 1, home_boss, away_boss ) AS loser, created_time FROM `boss_one_on_one` WHERE ( away_boss = ~p AND home_boss = ~p ) OR ( away_boss = ~p AND home_boss = ~p ) OR ( away_boss = ~p AND home_boss = ~p ) OR ( away_boss = ~p AND home_boss = ~p ) ORDER BY created_time DESC LIMIT 40",
        [util:to_list(BossId), util:to_list(AwayHeroId), util:to_list(HomeHeroId), util:to_list(BossId),
            util:to_list(AwayHeroId), util:to_list(BossId), util:to_list(BossId), util:to_list(HomeHeroId)]),
    OneOnOneRecordInDb =
        case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
            {error, Msg} ->
                ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
                error;
            {data, SelectRes} ->
                Fun = fun(R) ->
%%                    R#ets_boss_one_on_one_record{row_key = R#ets_boss_one_on_one_record.created_time}
                    R#ets_boss_one_on_one_record{row_key =
                    {
                        R#ets_boss_one_on_one_record.created_time,
                        R#ets_boss_one_on_one_record.winner,
                        R#ets_boss_one_on_one_record.loser
                    }}
                      end,
                L = lib_mysql:as_record(SelectRes, ets_boss_one_on_one_record, record_info(fields, ets_boss_one_on_one_record), Fun),
                L
        end,
    ets:insert_new(?ETS_BOSS_ONE_ON_ONE_RECORD, OneOnOneRecordInDb),
    ok;
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
%%    ?DEBUG("OneOnOneRecordInDb: ~p", [{
%%        ets:insert_new(?ETS_BOSS_ONE_ON_ONE_RECORD, OneOnOneRecordInDb),
%%        OneOnOneRecordInDb
%%    }]),
    ok.

get_record(PlayerId, HeroId) ->
    SceneId = mod_mission:get_scene_id_by_mission(?MISSION_TYPE_MISSION_HERO_PK_BOSS, 1),
    SceneWorker =
        case scene_master:get_scene_worker(SceneId) of
            null -> exit(?ERROR_NOT_EXISTS);
            {ok, SceneWorker1} -> SceneWorker1;
            Other -> ?ERROR("获取hero_versus_boss历史记录非预期错误: ~p", [Other]), exit(unknown)
        end,
    case gen_server:call(SceneWorker, {?GET_HERO_VERSUS_BOSS_AGAINST, PlayerId, HeroId}) of
        {error, Reason} ->
            exit(Reason);
        Result -> Result
    end.

get_record(PlayerId) ->
    SceneId = mod_mission:get_scene_id_by_mission(?MISSION_TYPE_MISSION_HERO_PK_BOSS, 1),
    SceneWorker =
        case scene_master:get_scene_worker(SceneId) of
            null -> exit(?ERROR_NOT_EXISTS);
            {ok, SceneWorker1} -> SceneWorker1;
            Other -> ?ERROR("获取多人副本非预期错误: ~p", [Other]), exit(unknown)
        end,
    ?DEBUG("SceneWorker: ~p", [SceneWorker]),
    case gen_server:call(SceneWorker, {?GET_HERO_VERSUS_BOSS_AGAINST, PlayerId}) of
        {error, Reason} ->
            exit(Reason);
        Result -> Result
%%            ?DEBUG("Result: ~p ", [Result])
    end.

get_against() ->
    case get(?LINEUP_POS) of
        ?UNDEFINED -> noop;
        [] -> noop;
        LineupPos ->
            PosHeroIdTupleList =
                lists:foldl(
                    fun(Ele, Tmp) ->
                        {Side, HeroBossTupleList} = Ele,
                        {RealHeroId, RealRobotId} =
                            case lists:keyfind(hero, 1, HeroBossTupleList) of
                                false -> false;
                                {hero, {{HeroId1, _, _, _, _}, _, RobotId}} -> {HeroId1, RobotId}
                            end,
                        {_MonsterId, MonsterObjId} =
                            case lists:keyfind(boss, 1, HeroBossTupleList) of
                                false -> false;
                                {boss, {{MonsterId1, _}, _, MonsterObjId1}} ->
                                    {MonsterId1, MonsterObjId1};
                                {boss, {{MonsterId1, _}, _}} ->
                                    {MonsterId1, 0}
                            end,
                        [{Side, RealHeroId, RealRobotId, MonsterObjId} | Tmp]
                    end,
                    [],
                    LineupPos
                ),
            SideHeroTupleList = lists:sort(PosHeroIdTupleList),
            SideHeroTupleList
    end.
get_against_record(PlayerId, HeroId, Msg) ->
    R = get_against_record(HeroId),
    ?DEBUG("get_against_record: ~p", [R]),
    if
        Msg =:= ?GET_HERO_VERSUS_BOSS_AGAINST ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, mod_hero_versus_boss, handle_get_record, [PlayerId, R], store);
        true -> R
    end.
get_against_record(PlayerId, Msg) ->
    R = get_against_record(),
    if
        Msg =:= ?GET_HERO_VERSUS_BOSS_AGAINST ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, mod_hero_versus_boss, handle_get_record, [PlayerId, R, Msg], store);
        Msg =:= ?GET_HERO_VERSUS_BOSS_WIN_RATE ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, mod_hero_versus_boss, handle_get_win_rate, [PlayerId, R], store);
        true -> R
    end.
get_against_record(HeroId) when is_integer(HeroId) ->
    case get_against() of
        noop -> ok;
        Against ->
            ?DEBUG("Against: ~p", [Against]),
            BossId = get(?HERO_VERSUS_BOSS_BOSS_ID),
            RealHeroMonsterTupleList =
                lists:filtermap(
                    fun(HeroIdAgainstTuple) ->
                        {_, HeroIdAgainst, _, MonsterId} = HeroIdAgainstTuple,
                        ?IF(HeroIdAgainst =:= HeroId, {true, {HeroId, MonsterId}}, false)
                    end,
                    Against
                ),
            ?ASSERT(length(RealHeroMonsterTupleList) =:= 1, error),
            [{RealHeroId, RealMonsterId}] = RealHeroMonsterTupleList,

            AllRecordInEts = ets:tab2list(?ETS_BOSS_ONE_ON_ONE_RECORD),
            AllRecord = util_list:rkeysort(#ets_boss_one_on_one_record.created_time, AllRecordInEts),
            ?DEBUG("AllRecord: ~p", [AllRecord]),
            AllRecordLength = length(AllRecord),
            RandomRecordLength = ?IF(AllRecordLength < 10, (10 - AllRecordLength), 0),

            RandomRecord =
                if
                    RandomRecordLength > 0 ->
                        Now = util_time:timestamp(),
                        lists:foldl(
                            fun(_, Tmp) ->
                                RandomWinner = util_random:random_number(100),
                                Winner = ?IF(RandomWinner >= 50, HeroId, BossId),
                                NewRandomRecord = [
                                    #ets_boss_one_on_one_record{
                                        winner = Winner,
                                        loser = ?IF(Winner =:= BossId, HeroId, BossId),
                                        created_time = Now
                                    }],
                                Tmp1 =
                                    case lists:keyfind(record, 1, Tmp) of
                                        false ->
                                            lists:keystore(record, 1, Tmp, {record, NewRandomRecord});
                                        {record, OldRecord} ->
                                            NewRecord = NewRandomRecord ++ OldRecord,
                                            lists:keyreplace(record, 1, Tmp, {record, NewRecord})
                                    end,
                                ?DEBUG("Tmp1: ~p", [Tmp1]),
                                Tmp2 =
                                    case lists:keyfind(hero_win_times, 1, Tmp1) of
                                        false ->
                                            lists:keystore(hero_win_times, 1, Tmp1,
                                                {hero_win_times, ?IF(Winner =:= HeroId, 1, 0)});
                                        {hero_win_times, Old} ->
                                            New = Old + ?IF(Winner =:= HeroId, 1, 0),
                                            lists:keyreplace(hero_win_times, 1, Tmp1, {hero_win_times, New})
                                    end,
                                ?DEBUG("Tmp1: ~p", [Tmp1]),
                                Tmp2
                            end,
                            [],
                            lists:seq(1, RandomRecordLength)
                        );
                    true -> []
                end,

            RealRandomRecord =
                case lists:keyfind(record, 1, RandomRecord) of
                    {record, RandomRecord1} -> RandomRecord1;
                    false -> []
                end,
            AgainstRecord = AllRecord ++ RealRandomRecord,
            ?DEBUG("AgainstRecord: ~p", [AgainstRecord]),
            {HeroId, BossId, AgainstRecord}
    end;
get_against_record(HeroId) when is_list(HeroId) ->
    case get_against() of
        noop -> ok;
        Against ->
            BossId = get(?HERO_VERSUS_BOSS_BOSS_ID),
            RealHeroMonsterTupleList =
                lists:filtermap(
                    fun(HeroIdAgainstTuple) ->
                        {_, HeroIdAgainst, _, MonsterId} = HeroIdAgainstTuple,
                        ?IF(HeroIdAgainst =:= HeroId, {true, {HeroId, MonsterId}}, false)
                    end,
                    Against
                ),
            ?ASSERT(length(RealHeroMonsterTupleList) =:= 1, error),
            [{RealHeroId, RealMonsterId}] = RealHeroMonsterTupleList,

            HeroWinRecord = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{
                #ets_boss_one_on_one_record{winner = RealHeroId, loser = BossId, _ = '_'}, [], ['$_']
            }]),
            HeroLoseRecord = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{
                #ets_boss_one_on_one_record{winner = BossId, loser = RealHeroId, _ = '_'}, [], ['$_']
            }]),

            HeroWinTimes = length(HeroWinRecord),
            HeroLoseTimes = length(HeroLoseRecord),
            RandomHeroRecord = ?IF((HeroWinTimes + HeroLoseTimes) < 10, (10 - (HeroWinTimes + HeroLoseTimes)), 0),
            RandomRecord =
                if
                    RandomHeroRecord > 0 ->
                        Now = util_time:timestamp(),
                        lists:foldl(
                            fun(_, Tmp) ->
                                RandomWinner = util_random:random_number(100),
                                Winner = ?IF(RandomWinner >= 50, HeroId, BossId),
                                NewRandomRecord = [
                                    #ets_boss_one_on_one_record{
                                    winner = Winner,
                                    loser = ?IF(Winner =:= BossId, HeroId, BossId),
                                    created_time = Now
                                }],
                                Tmp1 =
                                    case lists:keyfind(record, 1, Tmp) of
                                        false ->
                                            lists:keystore(record, 1, Tmp, {record, NewRandomRecord});
                                        {record, OldRecord} ->
                                            NewRecord = NewRandomRecord ++ OldRecord,
                                            lists:keyreplace(record, 1, Tmp, {record, NewRecord})
                                    end,
                                ?DEBUG("Tmp1: ~p", [Tmp1]),
                                Tmp2 =
                                    case lists:keyfind(hero_win_times, 1, Tmp1) of
                                        false ->
                                            lists:keystore(hero_win_times, 1, Tmp1,
                                                {hero_win_times, ?IF(Winner =:= HeroId, 1, 0)});
                                        {hero_win_times, Old} ->
                                            New = Old + ?IF(Winner =:= HeroId, 1, 0),
                                            lists:keyreplace(hero_win_times, 1, Tmp1, {hero_win_times, New})
                                    end,
                                ?DEBUG("Tmp1: ~p", [Tmp1]),
                                Tmp2
                            end,
                            [],
                            lists:seq(1, RandomHeroRecord)
                        );
                    true -> []
                end,
            RealRandomRecord =
                case lists:keyfind(record, 1, RandomRecord) of
                    {record, RandomRecord1} -> RandomRecord1;
                    false -> []
                end,
            ?DEBUG("RealRandomRecord: ~p", [RealRandomRecord]),
            AgainstRecord = HeroWinRecord ++ HeroLoseRecord ++ RealRandomRecord,
            ?DEBUG("AgainstRecord: ~p", [AgainstRecord]),
            {HeroId, BossId, AgainstRecord}
    end.
get_against_record() ->
    case get_against() of
        noop -> ok;
        Against ->
            BossId = get(?HERO_VERSUS_BOSS_BOSS_ID),
            [{HomeHeroId, HomeMonsterId}, {AwayHeroId, AwayMonsterId}] =
                [{HeroId, MonsterId} || {_, HeroId, _, MonsterId} <- Against],
            HomeBossWinInEts1 = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{
                #ets_boss_one_on_one_record{winner = HomeHeroId, loser = BossId, _ = '_'}, [], ['$_']
            }]),
            HomeBossLoseInEts = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{
                #ets_boss_one_on_one_record{winner = BossId, loser = HomeHeroId, _ = '_'}, [], ['$_']
            }]),
            HomeBossWinInEts = HomeBossWinInEts1 ++ HomeBossLoseInEts,

            AwayBossWinInEts1 = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{
                #ets_boss_one_on_one_record{winner = AwayHeroId, loser = BossId, _ = '_'}, [], ['$_']
            }]),
            AwayBossLoseInEts = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{
                #ets_boss_one_on_one_record{winner = BossId, loser = AwayHeroId, _ = '_'}, [], ['$_']
            }]),
            AwayBossWinInEts = AwayBossWinInEts1 ++ AwayBossLoseInEts,
%%            HomeBossWinInEts = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{
%%                #ets_boss_one_on_one_record{winner = HomeHeroId, loser = AwayHeroId, _ = '_'}, [], ['$_']
%%            }]),
%%            HomeBossLoseInEts = ets:select(?ETS_BOSS_ONE_ON_ONE_RECORD, [{
%%                #ets_boss_one_on_one_record{winner = AwayHeroId, loser = HomeHeroId, _ = '_'}, [], ['$_']
%%            }]),
            HomeHeroWin = length(HomeBossWinInEts1),
            HomeHeroLost = length(HomeBossLoseInEts),
            HomeHeroGames = HomeHeroWin + HomeHeroLost,
            AwayHeroWin = length(AwayBossWinInEts1),
            AwayHeroLost = length(AwayBossLoseInEts),
            AwayHeroGames = AwayHeroWin + AwayHeroLost,
%%            HomeHeroLose = length(HomeBossLoseInEts),
%%            HomeHeroLose = length(AwayBossWinInEts),
            if
                HomeHeroGames =:= 0 andalso AwayHeroGames =:= 0 ->
                    {
%%                        {HomeHeroId, 0.0}, {AwayHeroId, 0.0}, []
                        {HomeHeroId, 0.0, HomeMonsterId}, {AwayHeroId, 0.0, AwayMonsterId}, []
                    };
                true ->
                    MatchList =
                        lists:filtermap(
                            fun(Robot) ->
                                #obj_scene_actor{
                                    obj_id = _RobotMatch, x = X, surface = #surface{ hero_id = MatchRobotId }
                                } = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_PLAYER, Robot),
                                {true, {X, MatchRobotId}}
                            end,
                            [Robot || Robot <- mod_scene_player_manager:get_all_obj_scene_player_id(), Robot < 10000]
                        ),
                    {_, FirstHeroId} = lists:nth(1, lists:sort(MatchList)),

                    {Left, Right} =
                        if
                            FirstHeroId =:= HomeHeroId ->
                                {
%%                                    {HomeHeroId, util:to_float(HomeHeroWin / (HomeHeroWin + HomeHeroLose))},
%%                                    {AwayHeroId, util:to_float(HomeHeroLose / (HomeHeroWin + HomeHeroLose))}
                                    {HomeHeroId,
                                        ?IF(HomeHeroGames > 0, util:to_float(HomeHeroWin / HomeHeroGames), 0.0),
                                        HomeMonsterId},
                                    {AwayHeroId,
                                        ?IF(AwayHeroGames > 0, util:to_float(AwayHeroWin / AwayHeroGames), 0.0),
                                        AwayMonsterId}
                                };
                            true ->
                                {
%%                                    {AwayHeroId, util:to_float(HomeHeroLose / (HomeHeroWin + HomeHeroLose))},
%%                                    {HomeHeroId, util:to_float(HomeHeroWin / (HomeHeroWin + HomeHeroLose))}
                                    {AwayHeroId,
                                        ?IF(AwayHeroGames > 0, util:to_float(AwayHeroWin / AwayHeroGames), 0.0),
                                        HomeMonsterId},
                                    {HomeHeroId,
                                        ?IF(HomeHeroGames > 0, util:to_float(HomeHeroWin / HomeHeroGames), 0.0),
                                        AwayMonsterId}
                                }

                        end,
                    HomeRecord = util_list:rkeysort(#ets_boss_one_on_one_record.created_time, HomeBossWinInEts),
                    RealHomeRecord = lists:sublist(HomeRecord, 1, 10),
                    AwayRecord = util_list:rkeysort(#ets_boss_one_on_one_record.created_time, AwayBossWinInEts),
                    RealAwayRecord = lists:sublist(AwayRecord, 1, 10),
                    AgainstRecordList = RealHomeRecord ++ RealAwayRecord,
%%                    AgainstRecordList = util_list:rkeysort(
%%                        #ets_boss_one_on_one_record.created_time,
%%                        HomeBossWinInEts ++ HomeBossLoseInEts
%%                    ),
                    {
                        Left, Right, AgainstRecordList
%%                        lists:sublist(AgainstRecordList, 1, 20)
                    }
            end
    end.

handle_get_record(PlayerId, Res) ->
    ?DEBUG("handle_get_record: ~p", [Res]),
    RecordOut =
        case Res of
            ok ->
                ?ERROR("get_hero_versus_boss_record"),
                #m_mission_get_hero_versus_boss_record_toc{
                    hero_versus_boss_record = []
                };
            R ->
                {HeroId, BossId, Record} = R,
                #m_mission_get_hero_versus_boss_record_toc{
                    hero_versus_boss_record = [#heroversusbossrecord{
                        hero_id = HeroId, monster_id = BossId, timestamp = CreatedTime,
                        winner = ?IF(Winner =:= HeroId, 0, 1)
                    } || #ets_boss_one_on_one_record{winner = Winner, loser = Loser, created_time = CreatedTime} <- Record]
                }
        end,
    ?DEBUG("RecordOut: ~p", [RecordOut]),
    mod_socket:send(PlayerId, proto:encode(RecordOut)).

handle_get_record(PlayerId, Res, Msg) ->
    {Out1, Out2} =
        case Res of
            noop ->
                RecordOut = #m_mission_guess_get_record_toc{
                    guess_boss_record_list = []
                },
                WinnerRateOut = #m_mission_notice_hero_versus_boss_rate_toc{
                    winne_rate = []
                },
                {RecordOut, WinnerRateOut};
            R ->
                {{HomeBossId, HomeRate, _MonsterId}, {AwayBossId, AwayRate, _MonsterId1}, Records} = R,
                {RateList, RecordList} = {[{HomeBossId, HomeRate}, {AwayBossId, AwayRate}], [{CreatedTime, Winner} ||
                    #ets_boss_one_on_one_record{winner = Winner, loser = _Loser, created_time = CreatedTime} <- Records]},
                RecordOut = #m_mission_guess_get_record_toc{
                    guess_boss_record_list = [#guessbossrecord{id = Id, boss_id = BossId} || {Id, BossId} <- RecordList]
                },
                WinnerRateOut = #m_mission_notice_hero_versus_boss_rate_toc{
                    winne_rate = [#winnerrate{boss_id = BossId, rate = util:to_int(Rate * 100)} || {BossId, Rate} <- RateList]
                },
                {RecordOut, WinnerRateOut}
        end,
    if
        Msg =:= ?GET_HERO_VERSUS_BOSS_AGAINST ->
            ?DEBUG("Out: ~p ~p", [mod_socket:send(PlayerId, proto:encode(Out1)), Out1]);
        Msg =:= ?GET_HERO_VERSUS_BOSS_WIN_RATE ->
            mod_socket:send(PlayerId, proto:encode(Out2));
        true ->
            mod_socket:send(PlayerId, proto:encode(Out1)),
            mod_socket:send(PlayerId, proto:encode(Out2))
    end.

handle_get_win_rate(PlayerId, Res) ->
    Out =
        case Res of
            noop ->
                #m_mission_notice_hero_versus_boss_rate_toc{
                    winne_rate = []
                };
            R ->
                {{HomeBossId, HomeRate, MonsterId}, {AwayBossId, AwayRate, MonsterId1}, _Records} = R,
                Out1 = #m_mission_notice_hero_versus_boss_rate_toc{
                    winne_rate = [
                        #winnerrate{boss_id = HomeBossId, monster_id = MonsterId, rate = HomeRate},
                        #winnerrate{boss_id = AwayBossId, monster_id = MonsterId1, rate = AwayRate}
                    ]
%%                    winne_rate = [#winnerrate{boss_id = BossId, rate = util:to_int(Rate * 100)} || {BossId, Rate} <- [{HomeBossId, HomeRate}, {AwayBossId, AwayRate}]]
                },
                Out1
        end,
    mod_socket:send(PlayerId, proto:encode(Out)).