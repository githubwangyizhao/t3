%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            战斗模块
%%% @end
%%% Created : 27. 十一月 2017 下午 9:01
%%%-------------------------------------------------------------------
-module(mod_fight).

-include("common.hrl").
-include("scene.hrl").
-include("error.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("system.hrl").
-include("skill.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("fight.hrl").
-include("msg.hrl").
-include("server_data.hrl").
-include("scene_monster.hrl").
-include("player_game_data.hrl").
-include("gen/db.hrl").

%% API
-export([
    fight/2,                       %% 战斗
    get_fight_obj_queue/1,         %% 获取攻击对象队列
    handle_fight_queue/2,          %% 处理攻击队列
    is_can_fight/2,                %% 对象是否可以被攻击
    fighting/2,                    %% 对单个目标对象的战斗逻辑
    init_fight_obj/2,              %% 初始化战斗对象
    on_client_worker_info/2,        %% 处理玩家进程模块消息
    delete_player_mod_dict/1        %% 删除玩家模块字典
]).

-export([
    deal_hurt/4,                   %% 处理对象受到伤害
    update_kill_monster_list/1
]).

-export([
    get_fight_award_rate/0,
    center_get_fight_award_rate/0
]).

-export([
    get_fight_type/1
]).

-export([
    dizzy_reduce/2
]).

-record(?MODULE, {
    player_left_coin,                           %% 玩家身上剩余的金币数量（临时值）
    fight_extra_cost,                           %% 战斗结束后需要额外扣除的金币数量（临时值）
    fight_boss_extra_cost,                      %% 战斗结束后boss战斗需要额外扣除的金币数量（临时值）
    base_cost,                                  %% 战斗中每一下攻击的基础消耗（临时值）
    f_rate,                                     %% 时时彩倍率（临时值）

    fight_reward_num = 0,                       %% 击杀一只怪奖励物品数量（临时值）
    fight_reward_exp = 0,                       %% 击杀一只怪奖励经验值（临时值）
    fight_total_reward_num,                     %% 战斗中奖励物品总数（临时值）
    fight_total_reward_exp,                     %% 战斗获得总经验值（临时值）

    left_anger_skill_times,                     %% 怒气大招总攻击次数（临时值）
    is_dodge,
    adjust_death_rate = 1,                       %% 怪物死亡修正倍率（临时值）

    last_kill_fun_monster_cost = 0               %% 玩家最近一次击杀功能怪时的消耗（击杀死亡倍率）
}).

-define(COMMON_ATTACK_SKILL_ID_LIST, [901, 902, 903]).

%%%===================================================================
%%% 字典操作，仅场景进程调用
%%%===================================================================
delete_player_mod_dict(PlayerId) ->
    ?eraseModDict({last_kill_fun_monster_cost, PlayerId}).

%%%===================================================================
%%% 处理玩家进程模块消息
%%%===================================================================
%% 战斗奖励
on_client_worker_info({fight_rewards, SkillId, AddManoNum, AddExp, SceneId}, _ConnState = #conn{player_id = PlayerId}) ->
%%    ?DEBUG("通知玩家~p战斗奖励: SkillId ~p, AddManoNum ~p, AddExp ~p", [PlayerId, SkillId, AddManoNum, AddExp]),
    if AddManoNum > 0 ->
        Rewards = [{api_fight:get_item_id(SceneId, ?ITEM_GOLD), AddManoNum}],
        case SkillId of
            ?ACTIVE_SKILL_4 ->  %% 延迟发放
                mod_player:update_player_scene_stay_rewards(1, Rewards);
            _ ->
                mod_award:give(PlayerId, Rewards, ?LOG_TYPE_FIGHT)
        end;
        true ->
            noop
    end,
    if AddExp > 0 ->
        mod_award:give(PlayerId, [{api_fight:get_item_id(SceneId, ?ITEM_EXP), AddExp}], ?LOG_TYPE_FIGHT);
        true ->
            noop
    end,
    ok.

%% ----------------------------------
%% @doc 	战斗
%% @throws 	none
%% @end
%% ----------------------------------
fight(RequestFightParam, SceneState) ->
    #scene_state{
        scene_id = SceneId,
        scene_type = SceneType,
        is_mission = IsMission,
        fight_type = FightType
    } = SceneState,

    %% 设置战斗过程标识
    put(?DICT_IS_FIGHT, true),
    put(?DICT_FIGHT_RESULT_IS_ALL_SCENE_SYNC, false),

    #request_fight_param{
        attack_type = AttackType,
        obj_type = AttObjType,
        obj_id = AttObjId,
        skill_id = SkillId0,
        dir = Dir,
        target_type = TargetObjType,
        target_id = TargetObjId,
        balance_round = NowBalanceRound,
        cost = BaseCost,
        player_left_coin = PlayerLeftCoin,
        rate = FRate,
        skill_point_list = SkillPointList,
        other_data_list = OtherDataList,
        single_goal_attack_num = SingleGoalAttackNum
    } = RequestFightParam,
    put(?DICT_FIGHT_OTHER_DATA_LIST, OtherDataList),

    %% 校验请求参数
    check_fight_param_valid(RequestFightParam, SceneState),

    ?setModDict(player_left_coin, PlayerLeftCoin),
    ?setModDict(fight_extra_cost, 0),
    ?setModDict(fight_boss_extra_cost, 0),
    ?setModDict(base_cost, BaseCost),
    ?setModDict(f_rate, FRate),
    ?setModDict(fight_total_reward_num, 0),
    ?setModDict(fight_total_reward_exp, 0),
    if
        SkillId0 == ?ACTIVE_SKILL_4 andalso FightType == ?FIGHT_TYPE_HP ->
            ?setModDict(left_anger_skill_times, ?SD_SKILL_TOTAL_ATTACK_NUMBER);     %% 初始怒气大招总攻击次数
        true ->
            noop
    end,
    NowMS = util_time:milli_timestamp(),
    put(?DICT_NOW_MS, NowMS),

    case ?GET_OBJ_SCENE_ACTOR(AttObjType, AttObjId) of
        ?UNDEFINED ->
            noop;
        ObjSceneActor ->
            #obj_scene_actor{
                x = X,
                y = Y,
                r_active_skill_list = RActiveSkillList,
                hp = Hp,
                grid_id = GridId,
                pk_mode = PkMode,
                client_worker = ClientWorker,
                level = AttObjLevel,

                attack_times = AttackTimes,
                anger = Anger,
                is_robot = IsRobot,
                can_action_time = CanActionTime,
                dizzy_close_time = DizzyCloseTime,
                shen_long_time = ShenLongTime,
                wait_skill_info = WaitSkillInfo
            } = ObjSceneActor,
            put(?DICT_FIGHT_IS_FIXED_CRIT, ShenLongTime > NowMS),
            if FRate > 1 ->
                noop;
                true ->
                    noop
            end,

            %% 普攻技能效果
            SpecialSKillId = mod_scene_skill_manager:get_player_common_skill_id(AttObjId),
            OriIsCommonSkill = lists:member(SkillId0, [?ACTIVE_SKILL_901, ?ACTIVE_SKILL_902, ?ACTIVE_SKILL_903]),
            SkillId =
                if OriIsCommonSkill andalso SpecialSKillId > 0 ->  % 修改普攻技能
                    SpecialSKillId;
                    true ->
                        SkillId0
                end,
            %% 是否是有怪物效果的技能
            IsFunctionMonsterSkill =
                case t_monster_effect:get({SkillId}) of
                    null -> false;
                    _ -> true
                end,
            %% 不可行动的时候不能打
            ?ASSERT(NowMS >= CanActionTime orelse IsFunctionMonsterSkill, ?ERROR_NOT_ACTION_TIME),
            %% 眩晕的时候不能打(使用地震火球炸弹怪时可以打)
            ?ASSERT(NowMS >= DizzyCloseTime orelse IsFunctionMonsterSkill, ?ERROR_NOT_ACTION_TIME),
            ?ASSERT(Hp > 0, ?ERROR_ALREADY_DIE),
            ?ASSERT({AttObjType, AttObjId} =/= {TargetObjType, TargetObjId}),
            %% 不可以是蓄力状态
            ?ASSERT(WaitSkillInfo == ?UNDEFINED, ?ERROR_NOT_ACTION_TIME),
            if IsMission ->
                %% 猜一猜副本校验需要在前面
                mission_handle:handle_assert_fight(AttObjType, AttObjId, TargetObjType, TargetObjId, BaseCost, SkillId0),
                mission_handle:handle_cost_mano(ObjSceneActor, BaseCost, TargetObjType, TargetObjId);
                true ->
                    noop
            end,
            %% 获取技能对象
            if
                SpecialSKillId > 0 orelse AttackType =:= ?OBJ_TYPE_FUNCTION_MONSTER_SKILL ->
                    %% 特殊战斗， 创建一个技能
                    RActiveSkill = mod_active_skill:tran_r_active_skill(SkillId, 1),
                    LeftRActiveSkillList = null;
                true ->
                    {value, RActiveSkill, LeftRActiveSkillList} =
                        case lists:keytake(SkillId, #r_active_skill.id, RActiveSkillList) of
                            false ->
                                exit({skill_no_exists, {AttObjType, AttObjId, SkillId}});
                            SkillR ->
                                SkillR
                        end
            end,

            #t_active_skill{
                balance_type = BalanceType,
                is_circular = IsCircular,
                target = SkillTarget,
                attack_length = AttackLength,
                target_num = TargetNum
            } = mod_active_skill:get_t_active_skill(SkillId),

            #r_active_skill{
                level = SkillLevel,
                is_common_skill = IsCommonSkill
            } = RActiveSkill,

            MergeBalanceInfo = logic_merge_skill_balance_list:get(SkillId),

            put(?DICT_FIGHT_INIT_SKILL_ID, SkillId0),
            put(?DICT_FIGHT_SKILL_ID, SkillId),
            put(?DICT_FIGHT_BALANCE_ROUND, NowBalanceRound),

            %% 技能 cd 检测
%%            ?ASSERT(NowBalanceRound =/= 1 orelse LastTime + CdTime - 100 =< NowMS, ?ERROR_SKILL_CD_TIME),

            %% 初始化战报
            InitFightResult = #m_fight_notice_fight_result_toc{
                attacker_type = AttObjType,
                attacker_id = AttObjId,
                x = X,
                y = Y,
                dir = Dir,
                target_type = TargetObjType,
                target_id = TargetObjId,
                skill_id = SkillId,
                skill_level = SkillLevel,
                defender_result_list = [],
                anger = 0
            },

            %% 初始化通知格子列表
            ?INIT_NOTICE_GRID_LIST(),
            %% 初始化触发buff列表
            ?INIT_TRIGGER_BUFF_LIST(?ATTACKER),
            %% 初始化触发effect列表
            ?INIT_TRIGGER_EFFECT_LIST(?ATTACKER),
            %% 初始化击杀怪物列表
            ?INIT_KILL_MONSTER_LIST(),

            %% 获取结算数据
            {MergeBalanceList, BalanceHurtRate, _SumTime} = mod_skill_balance_range:get_balance_info(NowBalanceRound, BalanceType, MergeBalanceInfo),

            %% 释放技能触发被动技能
            InitObjSceneActor =
                if NowBalanceRound == 1 ->
                    {InitObjSceneActor_, _} =
                        if ObjSceneActor#obj_scene_actor.r_passive_skill_list =/= [] ->
                            mod_buff:try_trigger_passive_list(ObjSceneActor, #obj_scene_actor{}, [skill, SkillId]);
                            true ->
                                {ObjSceneActor, null}
                        end,
                    NewAnger =
                        if SkillId == ?ACTIVE_SKILL_4 ->
                            ?ASSERT(Anger >= ?SD_SKILL_ANGER_TOTAL, need_anger),
                            0;
                            true ->
                                Anger
                        end,
                    InitObjSceneActor_#obj_scene_actor{
                        attack_times = AttackTimes + 1,
                        anger = NewAnger
                    };
                    true ->
                        ObjSceneActor
                end,

            ChouShuiValue = scene_adjust:get_scene_adjust_rate_value(SceneId),

            SkillAdjust =
                if
                    SkillId == ?ACTIVE_SKILL_4 orelse SkillId == ?ACTIVE_SKILL_5 ->
                        if
                            SceneType == ?SCENE_TYPE_WORLD_SCENE ->
                                util_random:get_probability_item(util_list:opt(SkillId, ?SD_SKILL_XIUZHENG_LIST)) / 10000;
                            true ->
                                1
                        end;
%%                        [SkillAdjustArg, ASkillAdjustList, BSkillAdjustList] = ?SD_SKILL_XIUZHENG_LIST,
%%                        IsUseASkillAdjust = util_random:p(5000 + (10000 - ChouShuiValue) * 10000 / SkillAdjustArg),
%%                        if
%%                            IsUseASkillAdjust ->
%%                                util_random:get_probability_item(ASkillAdjustList);
%%                            true ->
%%                                util_random:get_probability_item(BSkillAdjustList)
%%                        end / 10000;
                    true ->
                        1
                end,

            %% 初始化战斗参数
            FightParam =
                #fight_param{
                    obj_scene_actor = InitObjSceneActor,
                    balance_round = NowBalanceRound,
                    skill_point_list =
                    case SkillPointList of
                        [] -> [{X, Y}];
                        _ -> SkillPointList
                    end,
                    dir = Dir,
                    skill_id = SkillId,
                    skill_level = SkillLevel,
                    skill_target_num = TargetNum,
                    skill_beat_back = 0,
                    skill_is_circular = IsCircular,
                    skill_hurt_rate = 1,
                    skill_ignore_defense_hurt = 1,
                    skill_attack_length = AttackLength,
                    skill_merge_balance_grid_list = MergeBalanceList,
                    skill_balance_hurt_rate = BalanceHurtRate,
                    skill_balance_type = BalanceType,
                    skill_target = SkillTarget,
                    target_obj_type = TargetObjType,
                    target_obj_id = TargetObjId,
                    fight_result = InitFightResult,
                    is_common_skill = IsCommonSkill,
                    pk_mode = PkMode,
                    fight_type = FightType,
                    single_goal_attack_num = SingleGoalAttackNum,
                    skill_adjust = SkillAdjust,
                    chou_shui_value = ChouShuiValue
                },

%%            %% 初始化新手修正
%%            scene_adjust:init_fight_novice_adjust(AttObjType, AttObjId, AttObjLevel),

            %% 获取攻击对象队列
            FightObjQueue = get_fight_obj_queue(FightParam),
            ResultFightParam = handle_fight_queue(FightParam, FightObjQueue),

            #fight_param{
                obj_scene_actor = ObjSceneActor_1,
                fight_result = FightResult
            } = ResultFightParam,

            ?ASSERT(not lists:member(SkillId0, ?COMMON_ATTACK_SKILL_ID_LIST) orelse FightResult#m_fight_notice_fight_result_toc.defender_result_list =/= [], ?ERROR_NOT_ACTION_TIME),

%%            %% 清除新手修正
%%            scene_adjust:del_fight_novice_adjust(),

            %% 消耗总结到一个变量
            if
                AttObjType == ?OBJ_TYPE_PLAYER andalso (SkillId == ?ACTIVE_SKILL_4 orelse SkillId == ?ACTIVE_SKILL_5) ->
                    CommonMonsterCost = trunc(?getModDict(fight_extra_cost) * SkillAdjust) div BaseCost * BaseCost,
                    ScenePropId = get(?DICT_SCENE_COST_PROP_ID),
                    #t_role_experience{
                        newbee_xiuzheng_list = NewbeeXiuZhenList
                    } = mod_player:get_t_level(AttObjLevel),
                    if
                        NewbeeXiuZhenList =/= [] andalso ScenePropId == ?ITEM_GOLD ->
                            noop;
                        true ->
                            %% 加入普通修正池
                            if
                                SceneType == ?SCENE_TYPE_WORLD_SCENE ->
                                    scene_adjust:add_room_pool_value(AttObjId, CommonMonsterCost);
                                true ->
                                    noop
                            end
                    end,
                    ?setModDict(fight_extra_cost, ?getModDict(fight_boss_extra_cost) + CommonMonsterCost);
                true ->
                    noop
            end,

            %% 更新技能属性
            NewActiveSkillList =
                if NowBalanceRound == 1 andalso SpecialSKillId == 0 andalso AttackType =/= ?OBJ_TYPE_FUNCTION_MONSTER_SKILL ->
                    [RActiveSkill#r_active_skill{last_time_ms = NowMS} | LeftRActiveSkillList];
                    true ->
                        RActiveSkillList
                end,

            AddManoNum = ?getModDict(fight_total_reward_num),
            AddExp = ?getModDict(fight_total_reward_exp),

            ObjSceneActor_2 =
                if
                    AddManoNum > 0 orelse AddExp > 0 ->
                        %% 给奖励
                        if
                            IsRobot ->
                                PropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
                                Robot = mod_scene_robot_manager:award_prop(ObjSceneActor_1, [{PropId, AddManoNum}]),
                                if
                                    SkillId0 == ?ACTIVE_SKILL_4 orelse SkillId0 == ?ACTIVE_SKILL_5 ->
                                        mod_scene_robot_manager:decrease_prop(Robot, [{PropId, ?getModDict(fight_extra_cost)}]);
                                    true ->
                                        Robot
                                end;
                            true ->
                                ClientWorker ! {notify, {?MODULE, {fight_rewards, SkillId, AddManoNum, AddExp, SceneId}}},
                                ObjSceneActor_1
                        end;
                    true ->
                        ObjSceneActor_1
                end,

            NewObjSceneActor = ObjSceneActor_2#obj_scene_actor{
                r_active_skill_list = NewActiveSkillList,
                last_fight_time_ms = NowMS
            },
            %% 更新玩家对象
            ?UPDATE_OBJ_SCENE_ACTOR(NewObjSceneActor),

            %% 通知战报
            if NowBalanceRound =/= 1 andalso FightResult#m_fight_notice_fight_result_toc.defender_result_list == [] ->
                %% 非首次结算的空战报不下发
                noop;
                true ->
                    NoticePlayerIdList = ?IF(get(?DICT_FIGHT_RESULT_IS_ALL_SCENE_SYNC), mod_scene_player_manager:get_all_obj_scene_player_id(), get_notice_player_id_list(GridId)),
                    OldSkillId = FightResult#m_fight_notice_fight_result_toc.skill_id,
                    case AttObjType of
                        ?OBJ_TYPE_MONSTER ->
                            api_fight:notice_fight_result(NoticePlayerIdList, FightResult);
                        ?OBJ_TYPE_PLAYER ->
                            Result =
                                FightResult#m_fight_notice_fight_result_toc{
                                    skill_id = ?IF(lists:member(SkillId0, [?ACTIVE_SKILL_901, ?ACTIVE_SKILL_902, ?ACTIVE_SKILL_903, ?ACTIVE_SKILL_4, ?ACTIVE_SKILL_5]), SkillId0, 0),
                                    skill_effect =
                                    case IsFunctionMonsterSkill of
                                        false when OldSkillId =:= ?ACTIVE_SKILL_4 ->
                                            OldSkillEffect = mod_player:get_player_anger_skill_effect_init(AttObjId),
                                            mod_player:init_player_anger_skill_effect(AttObjId),        % 重置大招特效id
                                            OldSkillEffect;
                                        false ->
                                            0;
                                        true ->
                                            OldSkillId
                                    end,
                                    anger_skill_effect = mod_player:get_player_anger_skill_effect_init(AttObjId)
                                },
                            api_fight:notice_fight_result(NoticePlayerIdList, Result)
                    end
            end,

            %% 异步触发技能下一次结算
            if
                BalanceType == ?BALANCE_TYPE_GRID andalso SkillTarget == 0 ->
                    %% 技能目标是敌方 并且 技能是格子结算
                    NextBalanceRound = NowBalanceRound + 1,
                    case lists:keyfind(NextBalanceRound, 1, MergeBalanceInfo) of
                        false ->
                            noop;
                        {_BalanceId, _SumRate, _SumDelay, _MergeBalanceList} ->
                            erlang:send_after(_SumDelay, self(), {?MSG_FIGHT, RequestFightParam#request_fight_param{
                                balance_round = NextBalanceRound
                            }})
                    end;
                true ->
                    noop
            end,
            %% 异步通知玩家进程击杀怪物信息
            case ?GET_KILL_MONSTER_LIST() of
                [] ->
                    noop;
                KillMonsterList ->
                    lists:foreach(
                        fun({KillMonsterId, KillNum}) ->
                            client_worker:send_msg(ClientWorker, {?MSG_CLIENT_KILL_MONSTER, SceneId, KillMonsterId, KillNum})
                        end,
                        KillMonsterList
                    )
            end,
            case get(?DICT_SCENE_TYPE) of
                ?SCENE_TYPE_WORLD_SCENE ->      %% todo .....
                    if AttObjType == ?OBJ_TYPE_PLAYER andalso IsRobot == false ->
                        logger2:write(player_fight_log,
                            [
                                {type, player},
                                {player_id, AttObjId}, %% 次数id
                                {skill_id, SkillId},
                                {scene_id, get(?DICT_SCENE_ID)},
                                {cost, ?IF(SkillId == 4 orelse SkillId == 5, ?getModDict(fight_extra_cost), BaseCost)},       %% 改变值
                                {get, AddManoNum},   %% 剩余次数
                                {server_total_cost, mod_server_data:get_int_data(?SERVER_DATA_SERVER_ADJUST_COST) + ?getModDict(fight_extra_cost)},
                                {server_total_award, mod_server_data:get_int_data(?SERVER_DATA_SERVER_ADJUST_AWARD) + AddManoNum}
                            ]
                        );
                        true ->
                            noop
                    end;
                _ ->
                    noop
            end
    end,

    put(?DICT_IS_FIGHT, false),
    {success, ?getModDict(fight_extra_cost)}.

%% ----------------------------------
%% @doc     获取通知的玩家列表
%% @throws 	none
%% @end
%% ----------------------------------
get_notice_player_id_list(GridId) ->
    lists:usort(
        lists:foldl(
            fun(ThisGridId, TmpNoticePlayerIdList) ->
                mod_scene_grid_manager:get_subscribe_player_id_list(ThisGridId) ++ TmpNoticePlayerIdList
            end,
            [],
            lists:usort([GridId | ?GET_NOTICE_GRID_LIST()])
        )).

%% ----------------------------------
%% @doc 	初始化战斗对象
%% @throws 	none
%% @end
%% ----------------------------------
init_fight_obj(ObjSceneActor, AttackType) ->
    #obj_scene_actor{
        attack = Attack,
        defense = Defense,
        hit = Hit,
        dodge = Dodge,
        tenacity = Tenacity,
        critical = Critical,
        hurt_add = HurtAdd,
        hurt_reduce = HurtReduce,
        crit_hurt_add = CritHurtAdd,
        crit_hurt_reduce = CritHurtReduce,
        rate_resist_block = ResistBlock,          %% 破击
        rate_block = Block                 %% 格挡
    } = ObjSceneActor,

    ObjSceneActor#obj_scene_actor{
        fight_attr_param = #fight_attr_param{
            attack = Attack,
            defense = Defense,
            hit = Hit,
            dodge = Dodge,
            tenacity = Tenacity,
            critical = Critical,
            hurt_add = HurtAdd,
            hurt_reduce = HurtReduce,
            crit_hurt_add = CritHurtAdd,
            crit_hurt_reduce = CritHurtReduce,
            rate_resist_block = ResistBlock,          %% 破击
            rate_block = Block                 %% 格挡
        },
        attack_type = AttackType
    }.

update_kill_monster_list(MonsterId) ->
    L = ?GET_KILL_MONSTER_LIST(),

    NewL = case lists:keytake(MonsterId, 1, L) of
               {value, {MonsterId, Num}, L1} ->
                   [{MonsterId, Num + 1} | L1];
               _ ->
                   [{MonsterId, 1} | L]
           end,
    put(?DICT_FIGHT_KILL_MONSTER_LIST, NewL).


%% ----------------------------------
%% @doc 	获取攻击对象队列
%% @throws 	none
%% @end
%% ----------------------------------
get_fight_obj_queue(FightParam) ->
    #fight_param{
        obj_scene_actor = ObjSceneActor,
        skill_point_list = SkillPointList,
        target_obj_type = TargetObjType,
        target_obj_id = TargetObjId,
        skill_target_num = TargetNum,
        skill_attack_length = AttackLength,
        skill_target = SkillTarget,
        skill_id = SkillId,
        pk_mode = PkMode,
        fight_type = FightType,
        skill_balance_type = SkillBalanceType
    } = FightParam,

    List =
        if
            SkillTarget == 0 -> %% 攻击目标是敌方
                #obj_scene_actor{
                    obj_type = ObjType,
                    obj_id = ObjId,
                    grid_id = GridId,
                    owner_obj_type = OwnerObjType,
                    owner_obj_id = OwnerObjId
                } = ObjSceneActor,
                TargetObj = ?GET_OBJ_SCENE_ACTOR(TargetObjType, TargetObjId),

                if
                    TargetNum == 1 andalso TargetObjId > 0 andalso SkillBalanceType < ?BALANCE_TYPE_GRID2 -> %% 单体
                        if
                            TargetObj == ?UNDEFINED ->
                                [];
                            true ->
                                [TargetObj]
                        end;
                    true ->   %% 群体
                        CommonFilterFun =
                            fun(#filter_target{this_obj_type = ThisObjType, this_obj_id = ThisObjId, this_own_type = ThisOwnType, this_own_id = ThisOwnObjId}) ->
                                if
                                    ThisObjType == ObjType andalso ThisObjId == ObjId ->
                                        %% 过滤自己
                                        false;
                                    ThisOwnObjId > 0 orelse OwnerObjId > 0 ->
                                        %% 有归属
                                        if
                                            ThisOwnType == ObjType andalso ThisOwnObjId == ObjId ->
                                                %% 过滤归属是自己
                                                false;
                                            ThisOwnType == OwnerObjType andalso ThisOwnObjId == OwnerObjId ->
                                                %% 过滤有共同归属
                                                false;
                                            ThisObjType == OwnerObjType andalso ThisObjId == OwnerObjId ->
                                                %% 过滤自己的归属
                                                false;
                                            true ->
                                                true
                                        end;
                                    true ->
                                        true
                                end
                            end,
                        F =
                            if
                            %% 玩家
                                ObjType == ?OBJ_TYPE_PLAYER ->
                                    fun(#filter_target{this_obj_type = ThisObjType, can_be_immediate_death = CanBeImmediateDeath} = FilterTarget) ->
                                        case CommonFilterFun(FilterTarget) of
                                            true ->
                                                if
                                                    SkillId == ?MONSTER_EFFECT_SKILL_105 andalso CanBeImmediateDeath == ?FALSE andalso FightType == ?FIGHT_TYPE_ODDS ->
                                                        %% 炸弹爆炸过滤功能怪
                                                        false;
                                                    SkillId == ?MONSTER_EFFECT_SKILL_109 andalso CanBeImmediateDeath == ?FALSE andalso FightType == ?FIGHT_TYPE_ODDS ->
                                                        %% 炸弹爆炸过滤功能怪
                                                        false;
                                                    true ->
                                                        if
                                                        %% 和平模式
                                                            PkMode == ?PK_MODE_PK_PEACE ->
                                                                if
                                                                    ThisObjType == ?OBJ_TYPE_PLAYER ->
                                                                        %% 过滤玩家
                                                                        false;
                                                                    true ->
                                                                        true
                                                                end;
                                                        %% 世界模式
                                                            PkMode == ?PK_MODE_PK_WORLD ->
                                                                if
                                                                    ThisObjType == ?OBJ_TYPE_PLAYER ->
                                                                        %% 新手玩家保护
                                                                        false;
                                                                    true ->
                                                                        true
                                                                end;
                                                            true ->
                                                                if
                                                                    ThisObjType == ?OBJ_TYPE_PLAYER ->
                                                                        %% 过滤玩家
                                                                        false;
                                                                    true ->
                                                                        true
                                                                end
                                                        end
                                                end;
                                            false ->
                                                false
                                        end
                                    end;
                                true ->
                                    %% 怪物
                                    fun(#filter_target{this_obj_type = ThisObjType, level = _ThisLevel} = FilterTarget) ->
                                        case CommonFilterFun(FilterTarget) of
                                            true ->
                                                if
                                                    OwnerObjId == 0 andalso ThisObjType == ObjType ->
                                                        %% 过滤同类型
                                                        false;
                                                    true ->
                                                        true
                                                end;
                                            false ->
                                                false
                                        end
                                    end
                            end,

                        DisLimit = mod_skill_balance_range:get_attack_distance_limit(SkillBalanceType, AttackLength),
                        ObjList =
                            if
                                ObjType == ?OBJ_TYPE_PLAYER ->
                                    if
                                        PkMode == ?PK_MODE_PK_PEACE orelse PkMode == ?PK_MODE_PK_BATTLE ->
                                            %% 和平模式下 只搜索怪物， 优化性能
                                            [mod_fight_target:get_nine_grid_attack_monster_target_list(GridId, X, Y, F, DisLimit) || {X, Y} <- SkillPointList];
                                        true ->
                                            [mod_fight_target:get_nine_grid_attack_target_list(GridId, X, Y, F, DisLimit) || {X, Y} <- SkillPointList]
                                    end;
                                true ->
                                    %% 怪物只搜索玩家
                                    [mod_fight_target:get_nine_grid_attack_player_target_list(GridId, X, Y, F, DisLimit) || {X, Y} <- SkillPointList]
                            end,
                        if
                            SkillId == ?ACTIVE_SKILL_102 orelse SkillId == ?ACTIVE_SKILL_103 ->
                                [TargetObj | ObjList];
                            true ->
                                ObjList
                        end
                end;
            true ->
                %% 攻击目标是自己
                []
        end,
    SubList = util_list:unique(lists:flatten(List)),
    if
        SkillId == ?ACTIVE_SKILL_4 andalso FightType == ?FIGHT_TYPE_HP ->
            %% 特殊处理(血量战斗的情况下，大招优先打血量低的)
            lists:sort(
                fun(DefObjA, DefObjB) ->
                    if
                        DefObjA == undefined orelse DefObjB == undefined ->
                            true;
                        true ->
                            DefObjA#obj_scene_actor.hp < DefObjB#obj_scene_actor.hp
                    end
                end,
                SubList
            );
        SkillId == ?ACTIVE_SKILL_4 andalso FightType == ?FIGHT_TYPE_ODDS ->
            %% 特殊处理(概率战斗的情况下，大招优先打怪物id小的)
            lists:sort(
                fun(DefObjA, DefObjB) ->
                    if
                        DefObjA == undefined orelse DefObjB == undefined ->
                            true;
                        true ->
                            DefObjA#obj_scene_actor.base_id < DefObjB#obj_scene_actor.base_id
                    end
                end,
                SubList
            );
        true ->
            SubList
    end.

%% ----------------------------------
%% @doc     处理攻击队列
%% @throws 	none
%% @end
%% ----------------------------------
handle_fight_queue(#fight_param{skill_target_num = SkillTargetNum, fight_result = OldFightResult, obj_scene_actor = Obj} = FightParam, FightObjList) when SkillTargetNum =< 0; FightObjList == [] ->
    #m_fight_notice_fight_result_toc{
        defender_result_list = OldDefenderResultList
    } = OldFightResult,
    %% 更新战报
    FightParam#fight_param{
        fight_result =
        OldFightResult#m_fight_notice_fight_result_toc{
            defender_result_list = lists:reverse(OldDefenderResultList),
            anger = Obj#obj_scene_actor.anger
        }
    };
handle_fight_queue(FightParam, [FightObj | LeftFightObjList]) ->
    #fight_param{
        obj_scene_actor = ObjSceneActor,
        skill_target_num = TargetNum,
        skill_id = SkillId,
        fight_type = FightType,
        skill_balance_type = SkillBalanceType
    } = FightParam,
    if
        ObjSceneActor#obj_scene_actor.hp > 0 ->
            NewFightParam =
                case is_can_fight(FightParam, FightObj) of
                    true ->     %% 对象允许被攻击
                        if
                            FightType == ?FIGHT_TYPE_HP andalso SkillId == ?ACTIVE_SKILL_4 ->
                                LeftAngerSkillTimes = ?getModDict(left_anger_skill_times),
                                if
                                    LeftAngerSkillTimes > 0 ->
                                        FightParam_1 =
                                            fighting(FightParam#fight_param{
                                                obj_scene_actor = init_fight_obj(FightParam#fight_param.obj_scene_actor, ?ATTACKER)
                                            },
                                                init_fight_obj(FightObj, ?DEFENSER)
                                            ),
                                        FightParam_1#fight_param{
                                            skill_target_num = TargetNum - 1
                                        };
                                    true ->
                                        handle_fight_queue(FightParam, [])
                                end;
                            true ->
                                FightParam_1 =
                                    fighting(FightParam#fight_param{
                                        obj_scene_actor = init_fight_obj(FightParam#fight_param.obj_scene_actor, ?ATTACKER)
                                    },
                                        init_fight_obj(FightObj, ?DEFENSER)
                                    ),
                                FightParam_1#fight_param{
                                    skill_target_num =
                                    if
                                        SkillBalanceType == ?BALANCE_TYPE_DIS orelse SkillBalanceType == ?BALANCE_TYPE_GRID ->
                                            TargetNum - 1;
                                        true ->
                                            TargetNum
                                    end
                                }
                        end;
                    false ->
                        FightParam
                end,
            handle_fight_queue(NewFightParam, LeftFightObjList);
        true ->
            handle_fight_queue(FightParam, [])
    end.

%% ----------------------------------
%% @doc 	对象是否可以被攻击
%% @throws 	none
%% @end
%% ----------------------------------
is_can_fight(_FightParam, ?UNDEFINED) ->
    false;
is_can_fight(FightParam, DefObjSceneActor) ->
    #fight_param{
        skill_point_list = SkillPointList,
        dir = Dir,
        target_obj_type = TargetObjType,
        target_obj_id = TargetObjId,
        skill_balance_type = SkillBalanceType,
        skill_merge_balance_grid_list = MergeBalanceGridList,
        skill_is_circular = IsSkillIsCircular,
        is_common_skill = IsCommonSkill,
        skill_attack_length = AttackLength,
        skill_id = SkillId,
        fight_result = FightResult
    } = FightParam,
    #obj_scene_actor{
        obj_type = DefObjType,
        obj_id = DefObjId,
        x = DefX,
        y = DefY,
        hp = DefHp,
        is_cannot_be_attack = IsCannotBeAttack
    } = DefObjSceneActor,
    #m_fight_notice_fight_result_toc{
        defender_result_list = DefenderResultList
    } = FightResult,

    if
        DefHp > 0 andalso IsCannotBeAttack == false andalso (SkillId == ?ACTIVE_SKILL_102 orelse SkillId == ?ACTIVE_SKILL_102) andalso DefenderResultList == [] ->
            IsTarget = {DefObjType, DefObjId} == {TargetObjType, TargetObjId},
            lists:any(
                fun({CalcX, CalcY}) ->
                    mod_skill_balance_range:is_in_skill_range(IsTarget, true, IsSkillIsCircular, MergeBalanceGridList, Dir, SkillBalanceType, AttackLength, {CalcX, CalcY}, {DefX, DefY}, 0)
                end,
                SkillPointList
            );
        DefHp > 0 andalso IsCannotBeAttack == false ->
            IsTarget = {DefObjType, DefObjId} == {TargetObjType, TargetObjId},
            lists:any(
                fun({CalcX, CalcY}) ->
                    mod_skill_balance_range:is_in_skill_range(IsTarget, IsCommonSkill, IsSkillIsCircular, MergeBalanceGridList, Dir, SkillBalanceType, AttackLength, {CalcX, CalcY}, {DefX, DefY}, 0)
                end,
                SkillPointList
            );
        true ->
            false
    end.

init_fighting(AttObjSceneActor, DefObjSceneActor) ->
    {AttObjSceneActor_0, DefObjSceneActor_0} =
        if AttObjSceneActor#obj_scene_actor.r_passive_skill_list =/= [] ->
            mod_buff:try_trigger_passive_list(AttObjSceneActor, DefObjSceneActor, ?EFFECT_TRIGGER_NODE_BEFORE_ATTACK);
            true ->
                {AttObjSceneActor, DefObjSceneActor}
        end,

    ?t_assert({AttObjSceneActor#obj_scene_actor.obj_type, AttObjSceneActor#obj_scene_actor.obj_id} == {AttObjSceneActor_0#obj_scene_actor.obj_type, AttObjSceneActor_0#obj_scene_actor.obj_id}),
    ?t_assert({DefObjSceneActor#obj_scene_actor.obj_type, DefObjSceneActor#obj_scene_actor.obj_id} == {DefObjSceneActor_0#obj_scene_actor.obj_type, DefObjSceneActor_0#obj_scene_actor.obj_id}),

    {DefObjSceneActor_1, AttObjSceneActor_1} =
        if DefObjSceneActor_0#obj_scene_actor.r_passive_skill_list =/= [] ->
            mod_buff:try_trigger_passive_list(DefObjSceneActor_0, AttObjSceneActor_0, ?EFFECT_TRIGGER_NODE_BEFORE_BE_ATTACKED);
            true ->
                {DefObjSceneActor_0, AttObjSceneActor_0}
        end,

    ?t_assert({AttObjSceneActor#obj_scene_actor.obj_type, AttObjSceneActor#obj_scene_actor.obj_id} == {AttObjSceneActor_1#obj_scene_actor.obj_type, AttObjSceneActor_1#obj_scene_actor.obj_id}),
    ?t_assert({DefObjSceneActor#obj_scene_actor.obj_type, DefObjSceneActor#obj_scene_actor.obj_id} == {DefObjSceneActor_1#obj_scene_actor.obj_type, DefObjSceneActor_1#obj_scene_actor.obj_id}),

    {AttObjSceneActor_2, DefObjSceneActor_2} =
        if AttObjSceneActor_1#obj_scene_actor.buff_list =/= [] ->
            mod_buff:deal_buff_list(AttObjSceneActor_1, DefObjSceneActor_1, ?EFFECT_TRIGGER_NODE_BEFORE_ATTACK);
            true ->
                {AttObjSceneActor_1, DefObjSceneActor_1}
        end,

    ?t_assert({AttObjSceneActor#obj_scene_actor.obj_type, AttObjSceneActor#obj_scene_actor.obj_id} == {AttObjSceneActor_2#obj_scene_actor.obj_type, AttObjSceneActor_2#obj_scene_actor.obj_id}),
    ?t_assert({DefObjSceneActor#obj_scene_actor.obj_type, DefObjSceneActor#obj_scene_actor.obj_id} == {DefObjSceneActor_2#obj_scene_actor.obj_type, DefObjSceneActor_2#obj_scene_actor.obj_id}),


    {DefObjSceneActor_3, AttObjSceneActor_3} =
        if DefObjSceneActor_2#obj_scene_actor.buff_list =/= [] ->
            mod_buff:deal_buff_list(DefObjSceneActor_2, AttObjSceneActor_2, ?EFFECT_TRIGGER_NODE_BEFORE_BE_ATTACKED);
            true ->
                {DefObjSceneActor_2, AttObjSceneActor_2}
        end,

    ?t_assert({AttObjSceneActor#obj_scene_actor.obj_type, AttObjSceneActor#obj_scene_actor.obj_id} == {AttObjSceneActor_3#obj_scene_actor.obj_type, AttObjSceneActor_3#obj_scene_actor.obj_id}),
    ?t_assert({DefObjSceneActor#obj_scene_actor.obj_type, DefObjSceneActor#obj_scene_actor.obj_id} == {DefObjSceneActor_3#obj_scene_actor.obj_type, DefObjSceneActor_3#obj_scene_actor.obj_id}),

    {AttObjSceneActor_3, DefObjSceneActor_3}.

%% ----------------------------------
%% @doc 	判断是否可以攻击
%% @throws 	none
%% @end
%% ----------------------------------
isCanBeatAgain(SkillId, SkillAdjust, IsBoss, Cost) ->
    if
        SkillId == ?ACTIVE_SKILL_4; SkillId == ?ACTIVE_SKILL_5 ->   % 计算金币消耗
            PlayerLeftCoin = ?getModDict(player_left_coin),
            PlayerExtraCost = ?getModDict(fight_extra_cost),
            PlayerBossExtraCost = ?getModDict(fight_boss_extra_cost),
            if
                IsBoss ->
                    NewPlayerBossExtraCost = PlayerBossExtraCost + Cost,
                    TotalCost = trunc(PlayerExtraCost * SkillAdjust) div Cost * Cost + NewPlayerBossExtraCost,
                    if
                        TotalCost < PlayerLeftCoin ->
                            ?setModDict(fight_boss_extra_cost, NewPlayerBossExtraCost),
                            true;
                        true ->
                            false
                    end;
                true ->
                    NewPlayerExtraCost = Cost + PlayerExtraCost,
                    TotalCost = trunc(NewPlayerExtraCost * SkillAdjust) div Cost * Cost + PlayerBossExtraCost,
                    if
                        TotalCost < PlayerLeftCoin ->
                            ?setModDict(fight_extra_cost, NewPlayerExtraCost),
                            true;
                        true ->
                            false
                    end
            end;
        true ->
            true
    end.

%% ----------------------------------
%% @doc 	计算目标怪物受攻击后的状态
%% @throws 	none
%% @end
%% ----------------------------------
do_beat(AttackParam = #attack_param{attack_times = AttackTimes, def_hp = DefHp}) when AttackTimes =< 0 orelse DefHp == 0 ->
    AttackParam;
do_beat(AttackParam) ->
    #attack_param{
        cost = Cost,
        defender_nth = DefNth,
        skill_id = SkillId,
        att_obj_type = AttObjType,
        att_obj_id = AttObjId,
        def_hurt_list = DefHurtList,
        def_hp = DefHp,
        player_hp_hurt_list = PlayerHpHurtList,
        die_type = DieType,
        new_linli = NewLinli,
        die_list = MonsterDieRules,
        attack_times = AttackTimes,
        already_attack_times = AlreadyAttackTimes,
        total_hurt_value = TotalHurtValue,
        is_boss = IsBoss,
        scene_id = SceneId,
        skill_adjust = SkillAdjust,
        chou_shui_value = ChouShuiValue
    } = AttackParam,
    IsAngerSkill = SkillId == ?ACTIVE_SKILL_4,
    FightType = get(?DICT_SCENE_FIGHT_TYPE),
    case isCanBeatAgain(SkillId, SkillAdjust, IsBoss, Cost) of    %% 继续攻击
        true ->
            {AttTotalHurt, NewDefHurtList} =
                case lists:keytake(AttObjId, 1, DefHurtList) of     %% 攻击者对当前怪累计造成的伤害总值(灵力总值)
                    {value, {_, Num}, L1} ->
                        {Num, [{AttObjId, Num + Cost} | L1]};
                    _ ->
                        {0, [{AttObjId, Cost} | DefHurtList]}
                end,
            NewPlayerHpHurtList =
                case FightType of
                    ?FIGHT_TYPE_ODDS ->
                        [];
                    ?FIGHT_TYPE_HP ->
                        case lists:keytake(AttObjId, 1, PlayerHpHurtList) of
                            {value, {_, ThisNum, _}, ThisL1} ->
                                [{AttObjId, ThisNum + Cost, get(?DICT_NOW_MS)} | ThisL1];
                            _ ->
                                [{AttObjId, Cost, get(?DICT_NOW_MS)} | PlayerHpHurtList]
                        end
                end,

            {NewHp, NewAttResultType} =
                case FightType of
                    ?FIGHT_TYPE_ODDS ->
                        case DieType of
                            %% 正常走概率死亡
                            0 ->
                                if
                                    NewLinli > 0 ->
                                        {max(0, DefHp - Cost), ?P_NORMAL};
                                    true ->
                                        case t_monster_effect:get({SkillId}) of
                                            #t_monster_effect{att_type = 1} ->  %% 秒杀技能
                                                {0, ?P_NORMAL};
                                            _ ->
                                                %% 计算怪物血量
                                                NewDefHp = calc_beat_monster_hp(AttObjType, AttObjId, DefHp, DefNth, AttTotalHurt, Cost, MonsterDieRules, SkillId, IsBoss, SceneId, ChouShuiValue),
                                                {NewDefHp, ?P_NORMAL}
                                        end
                                end;
                            1 ->
                                %% 不可能死
                                {1, ?P_NORMAL};
                            2 ->
                                %% 必死
                                {0, ?P_NORMAL}
                        end;
                    ?FIGHT_TYPE_HP ->
                        if
                            IsAngerSkill ->
                                {max(0, DefHp - Cost), ?P_NORMAL};
                            true ->
                                IsFixedCrit = get(?DICT_FIGHT_IS_FIXED_CRIT),
                                if
                                    IsFixedCrit ->
                                        {max(0, DefHp - round(Cost * AttackTimes * ?SD_HP_MODE_CRIT_DAMAGE_PER / 10000)), ?P_CRIT};
                                    true ->
                                        IsMiss = util_random:p(?SD_HP_MODE_MISS_PER),
                                        if
                                            IsMiss ->
                                                {DefHp, ?P_DODGE};
                                            true ->
                                                IsCrit = util_random:p(?SD_HP_MODE_CRIT_PER),
                                                if
                                                    IsCrit ->
                                                        {max(0, DefHp - round(Cost * AttackTimes * ?SD_HP_MODE_CRIT_DAMAGE_PER / 10000)), ?P_CRIT};
                                                    true ->
                                                        {max(0, DefHp - Cost * AttackTimes), ?P_NORMAL}
                                                end
                                        end
                                end
                        end
                end,
            NewAttackParam = AttackParam#attack_param{
                attack_times = AttackTimes - 1,
                already_attack_times = AlreadyAttackTimes + 1,
                total_hurt_value = TotalHurtValue + Cost,
                def_hurt_list = NewDefHurtList,
                def_hp = NewHp,
                player_hp_hurt_list = NewPlayerHpHurtList,
                attack_result_type = NewAttResultType
            },
            do_beat(NewAttackParam);
        false ->
            AttackParam
    end.

%% ----------------------------------
%% @doc     计算攻击怪物消耗
%% @throws 	none
%% @end
%% ----------------------------------
calc_beat_monster_cost(AttackObjActor, DefMonsterNth, SkillId, Cost) ->
    #obj_scene_actor{
        kuang_bao_time = SpeedEndTime
    } = AttackObjActor,
    Now = util_time:milli_timestamp(),

    case t_monster_effect:get({SkillId}) of
        #t_monster_effect{speed_mana_add_list = L1, mana_add_list = L2} ->   %% 具有功能怪效果的技能
            Rate =
                case SpeedEndTime >= Now of  %% 狂暴期间
                    true ->
                        lists:nth(min(length(L1), DefMonsterNth), L1);
                    false ->
                        lists:nth(min(length(L2), DefMonsterNth), L2)
                end,
            {ceil(Cost * Rate / 10000), false};
        null ->
            if
                SkillId == ?SD_MONSTER_EFFECT4_SKILL_ID ->      %% 双倍技能，击杀怪消耗及死亡概率修正
                    ?setModDict(adjust_death_rate, ?SD_MONSTER_EFFECT4_DIE_PER / 10000),
                    {ceil(?SD_MONSTER_EFFECT4_MANA_ADD / 10000 * Cost), true};
                true ->
                    {Cost, false}
            end
    end.

%% ----------------------------------
%% @doc     计算怪物剩余血量（判定怪是否死亡）
%% @throws 	none
%% @end
%% ----------------------------------
calc_beat_monster_hp(AttObjType, AttObjId, OldDefHp, DefMonsterNth, TotalCost, Cost, MonsterDieRules, SkillId, IsBoss, SceneId, ChouShuiValue) ->
    #obj_scene_actor{
        kuang_bao_time = SpeedEndTime
    } = ?GET_OBJ_SCENE_ACTOR(AttObjType, AttObjId),
    Now = util_time:milli_timestamp(),

    %% 根据玩家累计消耗，计算怪物基础死亡权值
    ManaCost = TotalCost * 100 / Cost,
    Func =
        fun([Min0, Max0, P], Tmp) ->
            {Min, Max} =
                if
                    AttObjId >= 10000 ->
                        {Min0, Max0};
                    true ->
                        {Min0 * 2, Max0 * 2}
                end,
            if Tmp > 0 ->
                Tmp;
                true ->
                    if ManaCost >= Min andalso (ManaCost =< Max orelse Max == 0) ->
                        P;
                        true ->
                            Tmp
                    end
            end
        end,
    DeathWeightValue = lists:foldl(Func, 0, MonsterDieRules),

    %% 怪物效果技能的死亡修正率
    SkillDeathRate =
        case t_monster_effect:get({SkillId}) of
            #t_monster_effect{speed_die_per_list = L1, die_per_list = L2, type = SkillType} ->       %% 带效果的功能怪
                Rate =
                    case SpeedEndTime >= Now of  %% 狂暴期间
                        true ->
                            lists:nth(min(length(L1), DefMonsterNth), L1);
                        false ->
                            lists:nth(min(length(L2), DefMonsterNth), L2)
                    end,
                case DefMonsterNth of
                    N when N > 1, SkillType == 1 -> %% 修改普攻的buff技能需要修正
                        Rate / 10000 * ?getModDict({last_kill_fun_monster_cost, AttObjId}) / ?getModDict(base_cost);
                    _ ->
                        Rate / 10000
                end;
            null ->
                1
        end,

    %% ?INFO("怪物死亡判断方案1参数 ==> DeathWeightValue ~p, SkillDeathRate ~p", [DeathWeightValue, SkillDeathRate]),
    CommonDieP = DeathWeightValue * SkillDeathRate,
    NoviceAdjustData = scene_adjust:get_newbee_adjust_value(AttObjType, AttObjId),
    ScenePropId = get(?DICT_SCENE_COST_PROP_ID),
    SceneType = get(?DICT_SCENE_TYPE),
    %% 记录修正
    P =
        if
            SceneType == ?SCENE_TYPE_MISSION ->
                CommonDieP;
            SceneType == ?SCENE_TYPE_MATCH_SCENE ->
                CommonDieP;
            NoviceAdjustData =/= false andalso NoviceAdjustData =/= ?UNDEFINED andalso ScenePropId == ?ITEM_GOLD ->
                {value, NoviceAdjust} = NoviceAdjustData,
                CommonDieP * NoviceAdjust / 10000;
            (IsBoss andalso (SkillId == 901 orelse SkillId == 902 orelse SkillId == 903 orelse SkillId == 4 orelse SkillId == 5)) orelse (IsBoss andalso (SkillId == ?ACTIVE_SKILL_103 orelse SkillId == ?ACTIVE_SKILL_102) andalso DefMonsterNth == 1) ->
                %% 加入boss修正池;
                scene_adjust:add_player_total_cost(AttObjId, Cost),
                handle_scene_adjust_srv:add_boss_adjust_value(AttObjId, SceneId, trunc(Cost * ChouShuiValue / 10000)),
                BossAdjustValue = handle_scene_adjust_srv:get_boss_adjust_value(SceneId),
                BossValue = trunc(BossAdjustValue / (util_list:opt(SceneId, ?SD_ROOMJACKPOT_JINE) / 1000)),
                Value = util_list:get_value_from_range_list_1(BossValue, ?SD_BOSS_XIUZHENG_LIST),
                ?IF(Value == ?UNDEFINED, ?ERROR("boss数据为 undefined ： ~p", [{AttObjId, BossAdjustValue, SceneId, BossValue, Value}]), noop),
                BossAdjust = Value / 10000,
%%                ?DEBUG("查看boss 修正 和boss 池子 ： ~p", [{CommonDieP, BossAdjust, BossValue, BossAdjustValue}]),
                CommonDieP * BossAdjust;
            IsBoss ->
                BossAdjustValue = handle_scene_adjust_srv:get_boss_adjust_value(SceneId),
                BossValue = trunc(BossAdjustValue / (util_list:opt(SceneId, ?SD_ROOMJACKPOT_JINE) / 1000)),
                Value = util_list:get_value_from_range_list_1(BossValue, ?SD_BOSS_XIUZHENG_LIST),
                ?IF(Value == ?UNDEFINED, ?ERROR("boss数据为 undefined ： ~p", [{AttObjId, BossAdjustValue, SceneId, BossValue, Value}]), noop),
                BossAdjust = Value / 10000,
                CommonDieP * BossAdjust * ChouShuiValue / 10000;
            SkillId == 901 orelse SkillId == 902 orelse SkillId == 903 orelse ((SkillId == ?ACTIVE_SKILL_103 orelse SkillId == ?ACTIVE_SKILL_102) andalso DefMonsterNth == 1) ->
                %% 加入普通修正池
                scene_adjust:add_room_pool_value(AttObjId, Cost),
                %% 决定死亡判定的计算方案
                [Ratio] = ?SD_ORIGINALMONSTERPROBABILITY,
                PlanResult = util_random:p(DeathWeightValue * SkillDeathRate * Ratio / 10000),
                if
                    PlanResult ->
%%                        ?DEBUG("死亡概率 1 : ~p",[CommonDieP]),
                        %% ?INFO("怪物死亡判断方案1参数 ==> DeathWeightValue ~p, SkillDeathRate ~p", [DeathWeightValue, SkillDeathRate]),
                        CommonDieP;
                    true ->
                        %% 死亡修正率1
                        AdjustDeathRate1 =
                            case AttObjType of
                                ?OBJ_TYPE_PLAYER when AttObjId >= 10000 ->
                                    case get(?DICT_IS_HOOK_SCENE) of
                                        true ->
                                            scene_adjust:get_player_adjust(AttObjId);
                                        false ->
                                            1
                                    end;
                                _ ->
                                    1
                            end,
                        %% 死亡修正率2
                        AdjustDieRate2 = ?getModDict(adjust_death_rate),
                        %% ?INFO("怪物死亡判断方案2参数 ==> DeathWeightValue ~p, SkillDeathRate ~p, AdjustDeathRate1 ~p, AdjustDieRate2 ~p", [DeathWeightValue, SkillDeathRate, AdjustDeathRate1, AdjustDieRate2]),
                        CommonDieP * AdjustDeathRate1 * AdjustDieRate2
                end;
            SkillId == 4 orelse SkillId == 5 ->
                %% 在上面有统计大招和充能技能的消耗了
                CommonDieP * ChouShuiValue / 10000;
            true ->
                CommonDieP
        end,

%%    ?INFO("死亡概率 ~p", [P]),
    case p(P) of
        true ->
            0;
        false ->
            OldDefHp
    end.

%% ----------------------------------
%% @doc 	概率
%% @throws 	none
%% @end
%% ----------------------------------
p(P) ->
    if
        P >= 100000 ->
            true;
        P =< 0 ->
            false;
        true ->
            RandomNum = rand:uniform(100000),
            if
                RandomNum =< P ->
                    true;
                true ->
                    false
            end
    end.

%% ----------------------------------
%% @doc     对单个目标对象的战斗逻辑
%% @throws 	none
%% @end
%% ----------------------------------
fighting(FightParam, DefObjSceneActor_0) ->
    #fight_param{
        obj_scene_actor = AttObjSceneActor_0,
        fight_result =
        #m_fight_notice_fight_result_toc{
            defender_result_list = DefenderResultList
        },
        skill_id = SkillId,
        single_goal_attack_num = SingleGoalAttackNum,
        skill_adjust = SkillAdjust,
        chou_shui_value = ChouShuiValue,
        target_obj_type = TargetObjType,
        target_obj_id = TargetObjId
    } = FightParam,

    %% 初始化
    ?setModDict(fight_reward_num, 0),
    ?setModDict(fight_reward_exp, 0),
    put(mod_fight_fight_result_mano_award, 0),
    ?INIT_TRIGGER_BUFF_LIST(?DEFENSER),
    ?INIT_TRIGGER_EFFECT_LIST(?DEFENSER),
    put(?DICT_RESULT_HURT, 0),
    Now = get(?DICT_NOW_MS),
    {AttObjSceneActor, DefObjSceneActor} = init_fighting(AttObjSceneActor_0, DefObjSceneActor_0),

    #obj_scene_actor{
        obj_type = AttObjType,
        obj_id = AttObjId,
        is_robot = IsRobot,
        client_worker = ClientWorker
    } = AttObjSceneActor,

    #obj_scene_actor{
        obj_type = DefObjType,
        obj_id = DefObjId,
        base_id = MonsterId,
        hp = DefHp,
        fight_attr_param = #fight_attr_param{
            attack = _DefAttack
        },
        hurt_list = DefHurtList,
        hate_list = DefHateList,
        total_hurt = TotalHurtValue,
        kind = Kind,
        player_hp_hurt_list = PlayerHpHurtList,
        die_type = DieType,
        is_boss = IsBoss
    } = DefObjSceneActor,

    if
        DefObjType == ?OBJ_TYPE_MONSTER ->
            Cost = ?getModDict(base_cost),

            #t_monster{
                new_die_list = DieList,
                new_ling_li = NewLinli
            } = t_monster:assert_get({MonsterId}),

            DefMonsterNth = length(DefenderResultList) + 1,     %% 第N只被打的怪
            {Cost1, IsUseAdjust} = calc_beat_monster_cost(AttObjSceneActor, DefMonsterNth, SkillId, Cost),

            SceneId = get(?DICT_SCENE_ID),

            InitSkillId = get(?DICT_FIGHT_INIT_SKILL_ID),
            #t_active_skill{
                is_common_skill = IsCommonSkill
            } = mod_active_skill:get_t_active_skill(InitSkillId),

            if
                IsCommonSkill == ?TRUE andalso IsRobot == false andalso AttObjType == ?OBJ_TYPE_PLAYER andalso TargetObjType == DefObjType andalso TargetObjId == DefObjId ->
                    client_worker:send_msg(ClientWorker, {?MSG_CLIENT_ATTACK_MONSTER, SceneId, MonsterId});
                true ->
                    noop
            end,

            AttackParam = #attack_param{
                skill_id = SkillId,
                att_obj_type = AttObjType,
                att_obj_id = AttObjId,
                new_linli = NewLinli,
                def_hurt_list = DefHurtList,
                die_list = DieList,
                def_hp = DefHp,
                cost = Cost1,
                defender_nth = DefMonsterNth,
                attack_times = SingleGoalAttackNum,
                total_hurt_value = TotalHurtValue,
                kind = Kind,
                monster_id = MonsterId,
                is_use_adjust = IsUseAdjust,
                player_hp_hurt_list = PlayerHpHurtList,
                attack_result_type = ?P_NORMAL,
                die_type = DieType,
                is_boss = IsBoss,
                scene_id = SceneId,
                skill_adjust = SkillAdjust,
                chou_shui_value = ChouShuiValue
            },

            %% 计算怪被攻击后状态
            NewAttackParam = do_beat(AttackParam),
            #attack_param{
                def_hp = NewHp,
                def_hurt_list = NewDefHurtList,
                total_hurt_value = NewTotalHurtValue,
                player_hp_hurt_list = NewPlayerHpHurtList
            } = NewAttackParam,
            {DefObjSceneActor1, IsBeat} = deal_beat_back(FightParam, DefObjSceneActor, AttObjSceneActor),
            NewDefHateList = mod_scene_monster_manager:update_hate_list(DefHateList, AttObjType, AttObjId, Cost),

            Effect = mod_scene_monster_manager:get_monster_effect(DefObjSceneActor1),
            ResultDefObjSceneActor =
                (deal_monster_hurt(Effect, DefObjSceneActor1))#obj_scene_actor{
                    hp = NewHp,
                    hurt_list = NewDefHurtList,
                    total_hurt = NewTotalHurtValue,
                    hate_list = NewDefHateList,
                    player_hp_hurt_list = NewPlayerHpHurtList,
                    last_attacked_time_ms = Now
                },

            ?UPDATE_OBJ_SCENE_ACTOR(ResultDefObjSceneActor),
            IsMission = get(?DICT_IS_MISSION),
            if
                IsMission ->
                    mission_handle:handle_hurt(DefObjSceneActor, AttObjSceneActor, Cost);
                true ->
                    noop
            end,
            if
                NewHp =:= 0 -> %% 怪受击死亡
                    NewFightParam = deal_monster_hurt_death(AttObjSceneActor, ResultDefObjSceneActor, FightParam, NewAttackParam);
                true ->
                    NewFightParam = deal_monster_hurt_not_death(AttObjSceneActor, ResultDefObjSceneActor, FightParam, NewAttackParam, IsBeat)
            end;
        AttObjType == ?OBJ_TYPE_MONSTER andalso DefObjType == ?OBJ_TYPE_PLAYER ->
            NewFightParam = deal_player_hurt(AttObjSceneActor, DefObjSceneActor, FightParam)
    end,
    NewFightParam.

%% 处理玩家受怪物攻击
deal_player_hurt(AttObjSceneActor, DefObjSceneActor, FightParam) ->
    #fight_param{
        fight_result = FightResult,
        skill_id = SkillId
    } = FightParam,

    #obj_scene_actor{
        obj_id = AttObjId,
        base_id = AttBaseId
    } = AttObjSceneActor,

    #obj_scene_actor{
        obj_type = DefObjType,
        obj_id = DefObjId,
        is_robot = DefIsRobot,
        client_worker = DefClientWorker,
        grid_id = DefGridId,
        hp = DefHp,
        fight_attr_param = #fight_attr_param{
            attack = _DefAttack,
            dodge = DefDodge
        }
    } = DefObjSceneActor,

    #t_monster{
        hit_damage = HitDamage,
        hit_probability = HitP
    } = t_monster:assert_get({AttBaseId}),
    ?setModDict(is_dodge, false),

    ServerType = mod_server_config:get_server_type(),
    SceneId = get(?DICT_SCENE_ID),
    ScenePropAwardId = get(?DICT_SCENE_AWARD_PROP_ID),

    Hurt =
        case util_random:p(HitP) andalso ServerType =:= ?SERVER_TYPE_GAME andalso DefObjType =:= ?OBJ_TYPE_PLAYER
            andalso mod_conditions:is_player_conditions_state(DefObjId, ?SD_MONSTER_ATTACK_BUCKS_GOLD_OPEN) of
            true ->
                case util_random:p(DefDodge) of
                    true ->
                        ?setModDict(is_dodge, true),
                        0;
                    false ->
                        if DefIsRobot == false ->
                            LeftGOld = mod_prop:get_player_prop_num(DefObjId, ScenePropAwardId),
                            if LeftGOld > 0 andalso HitDamage > 0 ->
                                HitDamage1 = min(HitDamage, LeftGOld),
                                client_worker:send_msg(DefClientWorker, {hit_damage, HitDamage1, SceneId}),
                                HitDamage1;
                                true ->
                                    0
                            end;
                            true ->
                                HitDamage
                        end
                end;
            false ->
                0
        end,

    {_AttObjSceneActor1, DefObjSceneActor1} = mod_new_buff:try_attack_add_buff(AttObjSceneActor, DefObjSceneActor, SkillId),
    NewDizzyCloseTime = DefObjSceneActor1#obj_scene_actor.dizzy_close_time,
    FightResultEffectList = [#effect{id = Id, data = Time} || #r_new_effect{id = Id, time = Time} <- ?GET_TRIGGER_EFFECT_LIST(?DEFENSER)],
    BeatList = [Id || #effect{id = Id} <- FightResultEffectList, Id == ?EFFECT_KNOCK2 orelse Id == ?EFFECT_KNOCK3],
    IsBeat =
        if
            BeatList == [] ->
                false;
            true ->
                true
        end,

    DefObjSceneActor2 = deal_beat_back_2(DefObjSceneActor, DefObjSceneActor1),
    ?UPDATE_OBJ_SCENE_PLAYER(DefObjSceneActor2),

    {ResultX, ResultY} =
        case IsBeat of
            false ->
                {0, 0};
            true ->
                {DefObjSceneActor2#obj_scene_actor.x, DefObjSceneActor2#obj_scene_actor.y}
        end,

    DefenderResult = #defenderresult{
        defender_type = DefObjType,
        defender_id = DefObjId,
        x = ResultX,
        y = ResultY,
        hp = DefHp,
        hurt = Hurt,
        type = case ?getModDict(is_dodge) of
                   true ->
                       ?P_DODGE;
                   _ ->
                       ?P_NORMAL
               end,
        buff_list = [],
        effect_list = FightResultEffectList,
        hurt_section_list = [],
        total_mano = 0,
        all_total_mano = 0,
        beat_times = 1,
        mano_award = 0,
        exp = 0,
        special_event = 0,
        dizzy_close_time = round(NewDizzyCloseTime / 1000),
        award_player_id = AttObjId
    },
    ?UPDATE_NOTICE_GRID_LIST(DefGridId),
    NewFightResult = append_fight_result(FightResult, DefenderResult),
    FightParam#fight_param{
        obj_scene_actor = AttObjSceneActor,
        fight_result = NewFightResult
    }.

%% 处理怪受击后未死
deal_monster_hurt_not_death(AttObjSceneActor, DefObjSceneActor, FightParam, NewAttackParam, IsBeat) ->
    #fight_param{
        fight_result = FightResult,
        skill_id = SkillId
    } = FightParam,

    #attack_param{
        def_hp = NewHp,
        total_hurt_value = NewTotalHurtValue,
        def_hurt_list = NewDefHurtList,
        attack_result_type = AttResultType,
        already_attack_times = AlreadyAttackTimes
    } = NewAttackParam,

    #obj_scene_actor{
        obj_id = AttObjId,
        client_worker = AttClientWorker,
        level = AttObjLevel
    } = AttObjSceneActor,

    #obj_scene_actor{
        obj_type = DefObjType,
        obj_id = DefObjId,
        base_id = MonsterId,
        grid_id = DefGridId,
        dizzy_close_time = DizzyCloseTime
    } = DefObjSceneActor,

    {XX, YY} =
        if
            IsBeat ->
                {DefObjSceneActor#obj_scene_actor.x, DefObjSceneActor#obj_scene_actor.y};
            true ->
                {0, 0}
        end,

    Cost = ?getModDict(base_cost),

    {MonsterLogObjId, MonsterLogId} =
        case util_list:opt(monster_log, get(?DICT_FIGHT_OTHER_DATA_LIST)) of
            ?UNDEFINED ->
                {DefObjId, MonsterId};
            {ThisObjId, ThisId} ->
                {ThisObjId, ThisId}
        end,

    Effect = mod_scene_monster_manager:get_monster_effect(DefObjSceneActor),
    FunctionMonsterLogCost = get_monster_log_cost(FightResult, SkillId, Cost),
    NewManoAward =
        if
            Effect =:= ?MONSTER_EFFECT_15 ->
                JinBiXiaoYaoAward = round(Cost * util_random:get_probability_item(?SD_MONSTER_FUNCTION_JINBIXIAOYAO_LIST) / 10000),
                ?setModDict(fight_total_reward_num, ?getModDict(fight_total_reward_num) + JinBiXiaoYaoAward),
                monster_log:monster_log(add, MonsterLogObjId, MonsterLogId, FunctionMonsterLogCost, JinBiXiaoYaoAward),
                %% 通知金币排行榜 金币小妖受击奖励
                if
                    JinBiXiaoYaoAward > 0 ->
                        SceneType = get(?DICT_SCENE_TYPE),
                        case SceneType of
                            ?SCENE_TYPE_WORLD_SCENE ->
                                scene_adjust:cost_room_pool_value(AttObjId, AttObjLevel, JinBiXiaoYaoAward);
                            _ ->
                                noop
                        end,
                        api_scene:notice_rank_event(6, JinBiXiaoYaoAward, AttObjId);
                    true ->
                        noop
                end,
                JinBiXiaoYaoAward;
            true ->
                monster_log:monster_log(add, MonsterLogObjId, MonsterLogId, FunctionMonsterLogCost, 0),
                0
        end,

    client_worker:send_msg(AttClientWorker, {?MSG_PLAYER_FIGHT_MONSTER_LOG, DefObjId, MonsterId, ?getModDict(base_cost), ?getModDict(fight_reward_num)}),
    Total =
        case lists:keyfind(AttObjId, 1, NewDefHurtList) of
            {_, Num} ->
                Num;
            _ ->
                0
        end,

    DefenderResult = #defenderresult{
        defender_type = DefObjType,
        defender_id = DefObjId,
        x = XX,
        y = YY,
        hp = NewHp,
        hurt = 0,
        type = AttResultType,
        buff_list = [],
        effect_list = [#effect{id = Id, data = Time} || #r_new_effect{id = Id, time = Time} <- ?GET_TRIGGER_EFFECT_LIST(?DEFENSER)],
        hurt_section_list = [],
        total_mano = case get(?DICT_SCENE_FIGHT_TYPE) of 0 -> Total; 1 -> NewHp end,
        all_total_mano = NewTotalHurtValue,
        beat_times = AlreadyAttackTimes,
        mano_award = NewManoAward,
        exp = 0,
        special_event = ?IF(Effect =:= ?MONSTER_EFFECT_15, 15, 0),
        dizzy_close_time = round(DizzyCloseTime / 1000),
        award_player_id = AttObjId
    },
    ?UPDATE_NOTICE_GRID_LIST(DefGridId),
    NewFightResult = append_fight_result(FightResult, DefenderResult),
    FightParam#fight_param{
        obj_scene_actor = AttObjSceneActor,
        fight_result = NewFightResult
    }.

%% 处理怪受击死亡
deal_monster_hurt_death(AttObjSceneActor, DefObjSceneActor, FightParam, NewAttackParam) ->
    SceneType = get(?DICT_SCENE_TYPE),
    #fight_param{
        fight_result = FightResult,
        skill_id = SkillId,
        fight_type = FightType
    } = FightParam,

    #attack_param{
        total_hurt_value = NewTotalHurtValue,
        attack_result_type = AttResultType,
        already_attack_times = AlreadyAttackTimes
    } = NewAttackParam,

    #obj_scene_actor{
        is_robot = IsRobot,
        obj_id = AttObjId,
        nickname = AttNickName,
        client_worker = AttClientWorker,
        fight_attr_param = #fight_attr_param{
            critical = AttCrit
        },
        anger = Anger,
        owner_obj_id = OwnerObjId,
        shen_long_time = ShenLongTime,
        is_can_add_anger = IsCanAddAnger,
        level = AttObjLevel
    } = AttObjSceneActor,

    #obj_scene_actor{
        obj_type = DefObjType,
        obj_id = DefObjId,
        base_id = MonsterId,
        grid_id = DefGridId,
        x = DefX,
        y = DefY,
        effect = EffectList,
        dizzy_close_time = DizzyCloseTime,
        is_all_sync = IsAllSync,
        is_boss = IsBoss
    } = DefObjSceneActor,

    Effect = mod_scene_monster_manager:get_monster_effect(DefObjSceneActor),
    SceneId = get(?DICT_SCENE_ID),
    ScenePropId = get(?DICT_SCENE_COST_PROP_ID),
    Cost = ?getModDict(base_cost),
    Now = get(?DICT_NOW_MS),

    #t_monster{
        new_ling_li = NewLinli,
        new_reward_1_list = DieRewardRateList,
        new_reward_2 = DieAwardId,
        angry_kill = AngryKill
    } = t_monster:assert_get({MonsterId}),

    ?IF(IsAllSync, put(?DICT_FIGHT_RESULT_IS_ALL_SCENE_SYNC, true), noop),

    {MonsterLogObjId, MonsterLogId} =
        case util_list:opt(monster_log, get(?DICT_FIGHT_OTHER_DATA_LIST)) of
            ?UNDEFINED ->
                {DefObjId, MonsterId};
            {ThisObjId, ThisId} ->
                {ThisObjId, ThisId}
        end,

    SceneType = get(?DICT_SCENE_TYPE),

    NewAnger =
        case SceneType of
            ?SCENE_TYPE_WORLD_SCENE ->
                if
                    SkillId =/= 4 andalso IsCanAddAnger ->
                        Anger + AngryKill;
                    true ->
                        Anger
                end;
            _ ->
                Anger
        end,
    if
        NewLinli == 0 ->
            DiamondAwards = get_kill_monster_diamond_award(AttObjId, AttObjLevel, MonsterId),
            ShenLongRate = ?IF(ShenLongTime > Now, 2, 1),
            AwardList = mod_prop:merge_prop_list(?IF(DieRewardRateList == [], [], [{ScenePropId, util_random:random_number(DieRewardRateList) * Cost * ShenLongRate}]) ++ DiamondAwards),
            WRate = ?IF(util_random:p(AttCrit), 2, 1) * get_fight_award_rate(),
            if
                OwnerObjId > 0 ->
                    Award = lists:foldl(
                        fun({PropId, Num}, TMpL) ->
                            [{PropId, Num * WRate} | TMpL]
                        end,
                        [],
                        AwardList
                    ),
                    mod_award:give(OwnerObjId, Award ++ mod_award:decode_award(DieAwardId), ?LOG_TYPE_FIGHT);
                Effect == ?MONSTER_EFFECT_3 ->
                    FanpaiAward =
                        lists:foldl(
                            fun({PropId, Num}, TMpL) ->
                                [{PropId, Num * WRate} | TMpL]
                            end,
                            [],
                            AwardList
                        ) ++ mod_award:decode_award(DieAwardId),
                    put('FanpaiAward', FanpaiAward);
                Effect == ?MONSTER_EFFECT_20 ->
                    ManoAward = mod_blind_box:handle_fight(SceneId, AttObjSceneActor, DefObjSceneActor, Cost),
                    scene_adjust:cost_room_pool_value(AttObjId, AttObjLevel, ManoAward),
                    ?setModDict(fight_reward_num, ManoAward),
                    put(mod_fight_fight_result_mano_award, ManoAward);
            %% 彩球怪死亡
                Effect == ?MONSTER_EFFECT_25 ->
                    mod_scene_event:handle_kill_ball_monster(AttObjSceneActor, DefObjSceneActor),
                    ok;
                true ->
                    FAward =
                        lists:foldl(
                            fun({PropId, Num}, TMpL) ->
                                [{PropId, Num * WRate} | TMpL]
                            end,
                            [],
                            AwardList
                        ) ++ mod_award:decode_award(DieAwardId),
                    ResGold = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
%%                    ResExp = api_fight:get_item_id(SceneId, ?ITEM_EXP),
                    {ManoAward, Exp, OtherAwardList1} = lists:foldl(
                        fun({ThisPropId, Num}, {TmpMano, TmpExp, TMpL}) ->
                            if
                                Num == 0 ->
                                    {TmpMano, TmpExp, TMpL};
                                true ->
                                    PropId = api_fight:get_item_id(SceneId, ThisPropId),
                                    if
                                        PropId == ResGold ->
                                            {TmpMano + Num, TmpExp, TMpL};
%%                                        PropId == ResExp ->
%%                                            {TmpMano, TmpExp + Num, TMpL};
                                        true ->
                                            {TmpMano, TmpExp, [{PropId, Num} | TMpL]}
                                    end
                            end
                        end,
                        {0, 0, []},
                        FAward
                    ),
                    OtherAwardList = mod_award:calc_drop_item(AttObjId, OtherAwardList1),
                    if
                        SkillId =:= ?MONSTER_EFFECT_SKILL_105 ->
                            if
                                IsRobot == false ->
                                    AttClientWorker ! {apply, mod_player, update_player_scene_stay_rewards, [?MONSTER_EFFECT_12, [{ScenePropId, ManoAward}]]};
                                true ->
                                    noop
                            end;
                        true ->
                            noop
                    end,

                    if
                        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
                            if
                                IsBoss ->
                                    scene_adjust:add_player_total_award(AttObjId, ManoAward),
                                    handle_scene_adjust_srv:add_boss_adjust_value(AttObjId, SceneId, -ManoAward),
                                    %% 通知金币排行榜事件 击杀boss
                                    api_scene:notice_rank_event(0, ManoAward, AttObjId);
                                true ->
                                    scene_adjust:cost_room_pool_value(AttObjId, AttObjLevel, ManoAward),
                                    noop
                            end;
                        SceneType == ?SCENE_TYPE_MATCH_SCENE ->
                            if
                                IsBoss ->
                                    api_scene:notice_rank_event(0, ManoAward, AttObjId);
                                true ->
                                    noop
                            end;
                        true ->
                            noop
                    end,

                    if
                        SkillId =:= ?MONSTER_EFFECT_SKILL_105 ->
                            skip;
                        true ->
                            ?setModDict(fight_reward_num, ManoAward)
                    end,
                    put(mod_fight_fight_result_mano_award, ManoAward),
                    ?setModDict(fight_reward_exp, Exp),
                    put('CCAward', OtherAwardList),
                    ?CATCH(scene_notice:kill_monster(AttNickName, MonsterId, mod_prop:merge_prop_list(FAward), SceneId)),
%%                    ?DEBUG("掉落物品 : ~p", [OtherAwardList]),
                    mod_scene_item_manager:drop_item_list(DefObjId, AttObjId, OtherAwardList, DefX, DefY)
            end;
        true ->
            noop
    end,
    mod_scene_monster_manager:handle_death(DefObjSceneActor, AttObjSceneActor),

    AwardPlayerId =
        case FightType of
            ?FIGHT_TYPE_ODDS ->
                AttObjId;
            ?FIGHT_TYPE_HP ->
                get('FightAwardPlayerId')
        end,

    IsFuncMonster =
        case t_monster_effect@key_index:get(Effect) of
            undefined -> false;
            _ -> true
        end,

    SpecialEvent = Effect,

    case Effect of
        ?MONSTER_EFFECT_3 ->
            if IsRobot == false ->
                client_worker:send_msg(AttClientWorker, {fanpai, get('FanpaiAward')});
                true ->
                    noop
            end;
        ?MONSTER_EFFECT_9 ->
            %% 翻牌
            [_, EffectType] = EffectList,
            if IsRobot == false ->
                mod_fight:give_function_award(AwardPlayerId, Effect, EffectType, Cost, 3, SceneId, MonsterLogObjId, MonsterLogId);
                true ->
                    noop
            end;
        ?MONSTER_EFFECT_10 ->
            %% 拉霸
            [_, EffectType] = EffectList,
            if IsRobot == false ->
                mod_fight:give_function_award(AwardPlayerId, Effect, EffectType, Cost, 1, SceneId, MonsterLogObjId, MonsterLogId);
                true ->
                    noop
            end;
        ?MONSTER_EFFECT_11 ->
            %% 转盘
            [_, EffectType] = EffectList,
            if IsRobot == false ->
                mod_fight:give_function_award(AwardPlayerId, Effect, EffectType, Cost, 1, SceneId, MonsterLogObjId, MonsterLogId);
                true ->
                    noop
            end;
        _ when IsFuncMonster == true ->         %% 带有技能效果的功能怪死亡
            ?setModDict({last_kill_fun_monster_cost, AwardPlayerId}, Cost),
            mod_scene_skill_manager:player_kill_function_monster(AttObjSceneActor, DefObjId, Effect, Cost, MonsterLogId, DefX, DefY);
        _ ->
            noop
    end,

    FunctionMonsterLogCost = get_monster_log_cost(FightResult, SkillId, Cost),
    if
        MonsterLogObjId == DefObjId ->
            if
                Effect == 14 orelse Effect == 13 orelse Effect == 12 orelse Effect == 5 orelse Effect == 22 ->
                    monster_log:monster_log(add, DefObjId, MonsterId, FunctionMonsterLogCost, ?getModDict(fight_reward_num));
                Effect == 9 orelse Effect == 10 orelse Effect == 11 ->
                    monster_log:monster_log(close, DefObjId, MonsterId, FunctionMonsterLogCost, ?getModDict(fight_reward_num));
                true ->
                    monster_log:monster_log(close, DefObjId, MonsterId, FunctionMonsterLogCost, ?getModDict(fight_reward_num))
            end;
        true ->
            monster_log:monster_log(add, MonsterLogObjId, MonsterLogId, FunctionMonsterLogCost, ?getModDict(fight_reward_num))
    end,

    DefenderResult = #defenderresult{
        defender_type = DefObjType,
        defender_id = DefObjId,
        x = 0,
        y = 0,
        hp = 0,
        hurt = 0,
        type = AttResultType,
        buff_list = [],
        effect_list = [#effect{id = Id, data = Time} || #r_new_effect{id = Id, time = Time} <- ?GET_TRIGGER_EFFECT_LIST(?DEFENSER)],
        hurt_section_list = [],
        total_mano = 0,
        all_total_mano = NewTotalHurtValue,
        beat_times = AlreadyAttackTimes,
        mano_award = get(mod_fight_fight_result_mano_award),
        exp = ?IF(NewLinli == 0, ?getModDict(fight_reward_exp), 0),
        special_event = SpecialEvent,
        dizzy_close_time = round(DizzyCloseTime / 1000),
        award_player_id = AwardPlayerId
    },
    ?UPDATE_NOTICE_GRID_LIST(DefGridId),
    NewFightResult = append_fight_result(FightResult, DefenderResult),
    NewFightResult1 =
        if NewLinli > 0 ->
            NewFightResult;
            true ->
                client_worker:send_msg(AttClientWorker, {?MSG_PLAYER_FIGHT_MONSTER_LOG, DefObjId, MonsterId, Cost, ?getModDict(fight_reward_num)}),
                ?setModDict(fight_total_reward_num, ?getModDict(fight_total_reward_num) + ?getModDict(fight_reward_num)),
                ?setModDict(fight_total_reward_exp, ?getModDict(fight_total_reward_exp) + ?getModDict(fight_reward_exp)),
                NewFightResult
        end,
    FightParam#fight_param{
        obj_scene_actor = AttObjSceneActor#obj_scene_actor{
            anger = NewAnger
        },
        fight_result = NewFightResult1
    }.

get_fight_award_rate() ->
    F =
        fun() ->
            case mod_server_rpc:call_center(mod_fight, center_get_fight_award_rate, []) of
                {badrpc, _Reason} ->
                    1;
                Result ->
                    Result
            end
        end,
    Key = {?MODULE, get_fight_award_rate},
    case mod_cache:cache_data(Key, F, 10) of
        null ->
            1;
        Value ->
            trunc(Value)
    end.

center_get_fight_award_rate() ->
    case mod_server_data:get_int_data(?SERVER_DATA_FIGHT_AWARD_RATE) of
        0 ->
            1;
        D ->
            D / 10000
    end.

%% ----------------------------------
%% @doc 	计算击杀怪物获得钻石奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_kill_monster_diamond_award(PlayerId, Level, MonsterId) ->
    #t_monster{
        diamond_reward_list = DiamondRewardList
    } = t_monster:assert_get({MonsterId}),
    case DiamondRewardList of
        [] ->
            [];
        [AwardBaseP, DiamondNum] ->
            #t_role_experience{
                diamond_xiuzheng_list = AdjustRules
            } = t_role_experience:assert_get({Level}),
            OldAwardDiamondNum = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_KILL_MONSTER_AWARD_DIAMOND),
            AwardAdjustRate = util_list:get_value_from_range_list(OldAwardDiamondNum, AdjustRules) / 10000,
            %% ?DEBUG("击杀怪奖励钻石判断参数: PlayerId ~p, OldAwardDiamondNum ~p, AwardBaseP ~p, AwardAdjustRate ~p", [PlayerId, OldAwardDiamondNum, AwardBaseP, AwardAdjustRate]),
            case util_random:p(AwardBaseP * AwardAdjustRate) of
                false ->
                    [];
                true ->
                    mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_KILL_MONSTER_AWARD_DIAMOND, DiamondNum),
                    [{?ITEM_RMB, DiamondNum}]
            end
    end.

%%%% ----------------------------------
%%%% @doc 	闪避
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%do_dodge(FightParam, DefObjSceneActor) ->
%%    #fight_param{
%%        obj_scene_actor = AttObjSceneActor,
%%        fight_result = FightResult
%%    } = FightParam,
%%    #obj_scene_actor{
%%        grid_id = DefGridId,
%%        fight_attr_param = #fight_attr_param{
%%        }
%%    } = AttObjSceneActor,
%%    #obj_scene_actor{
%%        obj_type = DefObjType,
%%        obj_id = DefObjId,
%%        hp = DefHp,
%%        fight_attr_param = #fight_attr_param{
%%        }
%%    } = DefObjSceneActor,
%%    DefenderResult = #defenderresult{
%%        defender_type = DefObjType,
%%        defender_id = DefObjId,
%%        x = 0,
%%        y = 0,
%%        hp = DefHp,
%%        hurt = 0,
%%        type = ?P_DODGE,
%%        buff_list = api_fight:pack_buff_list(?GET_TRIGGER_BUFF_LIST(?DEFENSER)),
%%        effect_list = api_fight:pack_effect_list(?GET_TRIGGER_EFFECT_LIST(?DEFENSER)),
%%        beat_times = 1,
%%        mano_award = 0,
%%        exp = 0,
%%        special_event = 0
%%    },
%%    ?UPDATE_NOTICE_GRID_LIST(DefGridId),
%%    NewFightResult = append_fight_result(FightResult, DefenderResult),
%%    FightParam#fight_param{
%%        obj_scene_actor = AttObjSceneActor,
%%        fight_result = NewFightResult
%%    }.

%% ----------------------------------
%% @doc 	追加战报
%% @throws 	none
%% @end
%% ----------------------------------
append_fight_result(FightResult, DefenderResult) ->
    #m_fight_notice_fight_result_toc{
        defender_result_list = DefenderResultList
    } = FightResult,
    FightResult#m_fight_notice_fight_result_toc{
        defender_result_list = [DefenderResult | DefenderResultList]
    }.


%% ----------------------------------
%% @doc 	处理对象受到伤害
%% @throws 	none
%% @end
%% ----------------------------------
deal_hurt(DefObjSceneActor, AttObjSceneActor, Hurt, IsDealDeath) ->
    #obj_scene_actor{
        hp = DefHp,
        obj_type = DefObjType,
        obj_id = DefObjId,
        hu_dun = DefHuDun,
        hu_dun_ref = DefHuDunRef,
        hate_list = DefHateList,
%%        grid_id = DefGridId,
        attack_type = DefAttackType
%%        belong_player_id = DefBelongPlayerId,
%%        is_boss = DefIsBoss
    } = DefObjSceneActor,
    #obj_scene_actor{
        obj_type = AttObjType,
        obj_id = AttObjId
    } = AttObjSceneActor,
    {NewDefHp, NewHuDun, ResultHurt, HuDunAbsorb} =
        if DefHuDun > 0 ->
            ?DEBUG("护盾:~p", [{DefHuDun}]),
            if DefHuDun >= Hurt ->
                {DefHp, DefHuDun - Hurt, 0, Hurt};
                true ->
                    {max(0, DefHp + DefHuDun - Hurt), 0, Hurt - DefHuDun, DefHuDun}
            end;
            true ->
                {max(0, DefHp - Hurt), 0, Hurt, 0}
        end,
%%    MissionType = get(?DICT_MISSION_TYPE),
    SceneType = get(?DICT_SCENE_TYPE),
    put(?DICT_RESULT_HURT, ResultHurt),
    RealHurt = min(DefHp, ResultHurt),

    DefObjSceneActor_1 = DefObjSceneActor#obj_scene_actor{
        hp = NewDefHp,
        hu_dun = NewHuDun,
        last_attacked_time_ms = get(?DICT_NOW_MS)
    },
    NewDefObjSceneActor =
%%        if
%%            SceneType == ?SCENE_TYPE_BATTLE_GROUND ->
%%                %% 归属者判断
%%                if AttObjType == ?OBJ_TYPE_PLAYER andalso DefObjType == ?OBJ_TYPE_MONSTER andalso DefIsBoss == true ->
%%                    if DefBelongPlayerId > 0 ->
%%                        DefObjSceneActor_1;
%%                        true ->
%%                            %% 归属者改变
%%                            put({?DICT_SCENE_BELONG_LINK, AttObjId}, DefObjId),
%%                            NoticePlayerIdList = mod_scene_grid_manager:get_subscribe_player_id_list(DefGridId),
%%                            %% 通知归属改变
%%                            api_scene:api_notice_monster_attr_change(NoticePlayerIdList, DefObjId, [{?P_BELONG_PLAYER_ID, AttObjId}]),
%%                            DefObjSceneActor_1#obj_scene_actor{
%%                                belong_player_id = AttObjId
%%                            }
%%                    end;
%%                    true ->
%%                        DefObjSceneActor_1
%%                end;
%%            true ->
    DefObjSceneActor_1,
%%        end,

    %% 副本回调
    case SceneType of
        ?SCENE_TYPE_MISSION ->
            mission_handle:handle_hurt(NewDefObjSceneActor, AttObjSceneActor, RealHurt);
        _ ->
            noop
    end,


    if
        HuDunAbsorb > 0 ->
            AddEffect = #r_effect{
                id = mod_buff:tran_effect_sign_2_effect_id(?EFFECT_TYPE_HU_DUN),
                data = - HuDunAbsorb
            },
%%        ?DEBUG("护盾吸收:~p", [{HuDunAbsorb, NewHuDun, {DefObjType, DefObjId}, {AttObjType, AttObjId}}]),
            ?UPDATE_TRIGGER_EFFECT_LIST(DefAttackType, AddEffect),
            %% 护盾吸收
            if NewHuDun =< 0 ->
                %% 护盾破碎
%%                ?DEBUG("护盾破碎"),
                self() ! {?MSG_SCENE_REMOVE_BUFF, DefObjType, DefObjId, DefHuDunRef, true};
                true ->
                    noop
            end;
        true ->
            noop
    end,

    IsDefDeath = NewDefHp =< 0,

    %% 处理死亡
    if
        IsDefDeath andalso IsDealDeath ->
            ?UPDATE_OBJ_SCENE_ACTOR(NewDefObjSceneActor),
            case DefObjType of
                ?OBJ_TYPE_MONSTER ->
                    %% 怪物死亡
                    mod_scene_monster_manager:handle_death(NewDefObjSceneActor, AttObjSceneActor)
%%                ?OBJ_TYPE_PLAYER ->
%%                    %% 玩家死亡
%%                    mod_scene_player_manager:handle_player_death(NewDefObjSceneActor, AttObjSceneActor)
            end,
            death;
        true ->
            if
                DefObjType == ?OBJ_TYPE_MONSTER ->
                    NewHurtList = mod_scene_monster_manager:update_hate_list(DefHateList, AttObjType, AttObjId, RealHurt),
                    NewDefObjSceneActor#obj_scene_actor{
                        hate_list = NewHurtList,
                        be_attacked_obj_type = AttObjType,
                        be_attacked_obj_id = AttObjId
                    };
                true ->
                    NewDefObjSceneActor#obj_scene_actor{
                        be_attacked_obj_type = AttObjType,
                        be_attacked_obj_id = AttObjId
                    }
            end
    end.

%% ----------------------------------
%% @doc 	处理击退
%% @throws 	none
%% @end
%% ----------------------------------
deal_beat_back(FightParam, DefObjSceneActor, AttObjSceneActor) ->
    #fight_param{
        skill_beat_back = SkillBeatBack
    } = FightParam,
    #obj_scene_actor{
        x = AttX,
        y = AttY,
        obj_type = AttObjType
    } = AttObjSceneActor,
    #obj_scene_actor{
        obj_type = DefObjType,
        x = DefX,
        y = DefY,
        hp = DefHp,
        grid_id = DefGridId,
        is_boss = DefIsBoss,
        move_path = DefMovePath,
        kind = Kind
    } = DefObjSceneActor,
    % 击退 注:玩家和玩家不能击退
    if
        SkillBeatBack > 0 andalso DefHp > 0 andalso (DefObjType =/= ?OBJ_TYPE_PLAYER orelse AttObjType =/= ?OBJ_TYPE_PLAYER) andalso DefIsBoss == false andalso DefMovePath == [] andalso Kind == 0 ->
            case calc_beat_back_pos(get(?DICT_MAP_ID), AttX, AttY, DefX, DefY, SkillBeatBack) of
                {DefX, DefY} ->
                    {DefObjSceneActor, false};
                {DefX_1, DefY_1} ->
                    NewGridId = ?PIX_2_GRID_ID(DefX_1, DefY_1),
                    NewDefObjSceneActor = DefObjSceneActor#obj_scene_actor{
                        x = DefX_1,
                        y = DefY_1,
                        grid_id = NewGridId,
                        move_path = [],             %% => 注: 被击退 停止移动
                        is_wait_navigate = false,   %%        停止寻路
                        wait_skill_info = ?UNDEFINED %%       停止蓄力技能
                    },
                    if
                        NewGridId == DefGridId ->
                            noop;
                        true ->
                            %% 九宫格改变
                            if
                                DefObjType == ?OBJ_TYPE_PLAYER ->
                                    mod_scene_grid_manager:handle_player_grid_change(NewDefObjSceneActor, DefGridId, NewGridId, beat_back);
                                DefObjType == ?OBJ_TYPE_MONSTER ->
                                    mod_scene_grid_manager:handle_monster_grid_change(NewDefObjSceneActor, DefGridId, NewGridId)
                            end
                    end,
                    {NewDefObjSceneActor, true}
            end;
        true ->
            {DefObjSceneActor, false}
    end.
deal_beat_back_2(OldActor, Actor) ->
    #obj_scene_actor{
        grid_id = OldGridId
    } = OldActor,
    #obj_scene_actor{
        x = DefX_1,
        y = DefY_1,
        obj_type = ObjType
    } = Actor,
    NewGridId = ?PIX_2_GRID_ID(DefX_1, DefY_1),
    NewDefObjSceneActor = Actor#obj_scene_actor{
        grid_id = NewGridId,
        move_path = [],             %% => 注: 被击退 停止移动
        is_wait_navigate = false,   %%        停止寻路
        wait_skill_info = ?UNDEFINED %%       停止蓄力技能
    },
    if
        NewGridId == OldGridId ->
            noop;
        true ->
            %% 九宫格改变
            if
                ObjType == ?OBJ_TYPE_PLAYER ->
                    mod_scene_grid_manager:handle_player_grid_change(NewDefObjSceneActor, OldGridId, NewGridId, beat_back);
                ObjType == ?OBJ_TYPE_MONSTER ->
                    mod_scene_grid_manager:handle_monster_grid_change(NewDefObjSceneActor, OldGridId, NewGridId)
            end
    end,
    NewDefObjSceneActor.

%% 处理炸弹怪受到伤害
deal_monster_hurt(?MONSTER_EFFECT_12, ObjSceneActor) ->
    ObjSceneActor0 = update_bomb_monster_state(ObjSceneActor),
    {_IsStateChange, ObjSceneActor1} = update_monster_ai_state(ObjSceneActor0),
    ObjSceneActor1;
%% 处理金币小妖受到伤害
deal_monster_hurt(?MONSTER_EFFECT_15, ObjSceneActor) ->
    {IsStateChange, ObjSceneActor0} = update_monster_ai_state(ObjSceneActor),
    case IsStateChange of
        false -> ObjSceneActor0;
        true ->
            #obj_scene_actor{
                obj_id = MonsterObjId,
                init_move_speed = InitMoveSpeed,
                is_all_sync = IsAllSync,
                grid_id = GridId
            } = ObjSceneActor0,
            NewMoveSpeed = InitMoveSpeed * 6,
            NoticePlayerIds = ?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)),
            api_scene:api_notice_monster_attr_change(NoticePlayerIds, MonsterObjId, [{?P_MOVE_SPEED, NewMoveSpeed}, {?P_MOVE_TYPE, ?MOVE_TYPE_MOMENT}]),
            ObjSceneActor0#obj_scene_actor{
                move_type = ?MOVE_TYPE_MOMENT,
                move_speed = NewMoveSpeed
            }
    end;
deal_monster_hurt(_, ObjSceneActor) ->
    {_IsStateChange, ObjSceneActor0} = update_monster_ai_state(ObjSceneActor),
    ObjSceneActor0.

%% 更新炸弹怪受击状态
update_bomb_monster_state(ObjSceneActor) ->
    NowMilSec = util_time:milli_timestamp(),
    #obj_scene_actor{
        x = X,
        y = Y,
        obj_id = MonsterObjId,
        init_move_speed = InitMoveSpeed,
        is_all_sync = IsAllSync,
        grid_id = GridId
    } = ObjSceneActor,

    OldMonsterBombRec = scene_worker:dict_get_monster_bomb(MonsterObjId),
    #r_monster_bomb{
        wild_end_time = OldWildEndTime,
        attacked_time_records = Records_0
    } = OldMonsterBombRec,
    [CfgTimeLimit, CfgAttackedCntLimit] = ?SD_ZHADAN_KUANG_BAO,
    Duration = ?SD_ZHADAN_CHI_XU_TIME * 1000,
    Cd = ?SD_ZHADAN_LENG_QUE_TIME * 1000,
    Records_1 = lists:sublist(Records_0, CfgAttackedCntLimit - 1),
    LenRecords = length(Records_1),

    ObjSceneActor_0 =
        case lists:reverse(Records_1) of
            %% 非狂暴状态下，在N秒时间内被攻击M下，开启狂暴
            [FirstSec | _] when NowMilSec - OldWildEndTime > Cd, LenRecords + 1 >= CfgAttackedCntLimit, (NowMilSec - FirstSec) div 1000 =< CfgTimeLimit ->
%%                ?DEBUG("~p在~p秒内被攻击了~p下 ==> 开启狂暴,位置~w", [MonsterObjId, (NowMilSec - FirstSec) div 1000, LenRecords + 1, {X, Y}]),
                NewMoveSpeed = InitMoveSpeed * 6,
                NewWildEndTime = NowMilSec + Duration,
                NoticePlayerIds = ?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), mod_scene_grid_manager:get_subscribe_player_id_list(GridId)),
                api_scene:api_notice_monster_attr_change(NoticePlayerIds, MonsterObjId, [{?P_MOVE_SPEED, NewMoveSpeed}, {?P_MOVE_TYPE, ?MOVE_TYPE_MOMENT}]),
                scene_worker:dict_set_monster_bomb(MonsterObjId, OldMonsterBombRec#r_monster_bomb{attacked_time_records = [NowMilSec | Records_1], wild_end_time = NewWildEndTime, base_x = X, base_y = Y}),
                erlang:send_after(Duration, self(), {?MSG_SCENE_MONSTER_WILD_TIMEOUT, MonsterObjId}),
                ObjSceneActor#obj_scene_actor{
                    move_type = ?MOVE_TYPE_MOMENT,
                    move_speed = NewMoveSpeed
                };
            _ ->
                scene_worker:dict_set_monster_bomb(MonsterObjId, OldMonsterBombRec#r_monster_bomb{attacked_time_records = [NowMilSec | Records_1]}),
                ObjSceneActor
        end,
    ObjSceneActor_0.

%% 更新怪物受击状态
update_monster_ai_state(ObjSceneActor) ->
    #obj_scene_actor{
        obj_id = MonsterObjId
    } = ObjSceneActor,

    Now = get(?DICT_NOW_MS),
    OldMonsterCoinRec = scene_worker:dict_get_monster_ai(MonsterObjId),
    #r_monster_ai{
        state = State
    } = OldMonsterCoinRec,
    case State of
        ?MONSTER_AI_STATE_STAND ->
            scene_worker:dict_set_monster_ai(MonsterObjId, OldMonsterCoinRec#r_monster_ai{state = ?MONSTER_AI_STATE_HURT, speak_times = 0, last_speak_time = Now}),
            {true, ObjSceneActor};
        _ ->
            {false, ObjSceneActor}
    end.

%% ----------------------------------
%% @doc 	计算击退后的位置
%% @throws 	none
%% @end
%% ----------------------------------
calc_beat_back_pos(_MapId, _AX, _AY, DX, DY, Dist) ->
    calc_beat_back_pos(_MapId, _AX, _AY, DX, DY, Dist, false).
calc_beat_back_pos(_MapId, _AX, _AY, DX, DY, 0, _IsReverse) ->
    {DX, DY};
calc_beat_back_pos(MapId, AX, AY, DX, DY, Dist, IsReverse) ->
    RealDist = ?IF(IsReverse, trunc(Dist / 1.414) * -1, trunc(Dist / 1.414)),
    {NewDX, NewDY} =
        if
            AX == DX andalso AY == DY ->
                {DX, DY - RealDist};
            AX == DX andalso AY > DY ->
                {DX, DY - RealDist};
            AX == DX andalso AY < DY ->
                {DX, DY + RealDist};
            AX > DX andalso AY == DY ->
                {DX - RealDist, DY};
            AX > DX andalso AY > DY ->
                {DX - RealDist, DY - RealDist};
            AX > DX andalso AY < DY ->
                {DX - RealDist, DY + RealDist};
            AX < DX andalso AY == DY ->
                {DX + RealDist, DY};
            AX < DX andalso AY > DY ->
                {DX + RealDist, DY - RealDist};
            AX < DX andalso AY < DY ->
                {DX + RealDist, DY + RealDist}
        end,
    ?IF(
        mod_map:can_walk(?PIX_2_MASK_ID(MapId, NewDX, NewDY)),
        {NewDX, NewDY},
        {DX, DY}
    ).

%% ----------------------------------
%% @doc 	新增场景功能奖励
%% @throws 	none
%% @end
%% ----------------------------------
give_function_award(PlayerId, Effect, EffectType, Cost, LeftTimes, SceneId, MonsterObjId, MonsterId) ->
    give_function_award(PlayerId, Effect, EffectType, Cost, LeftTimes, SceneId, [], MonsterObjId, MonsterId, []).

give_function_award(PlayerId, Effect, EffectType, _Cost, 0, SceneId, IdAwardList, MonsterObjId, MonsterId, _AlreadyGetIdList) ->
    api_fight:notice_get_function_monster_award(PlayerId, Effect, EffectType, IdAwardList),
    AwardPropList = mod_prop:merge_prop_list(lists:merge([AwardList || {_Id, AwardList} <- IdAwardList])),
    case Effect of
        9 ->
            %% 翻牌
            ?CATCH(scene_notice:kill_fanpai_monster(PlayerId, AwardPropList));
        _ ->
            noop
    end,
    PropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
    Num = util_list:opt(PropId, AwardPropList),
    monster_log:monster_log(add, MonsterObjId, MonsterId, 0, Num),
    #db_player_data{
        level = Level
    } = mod_player:get_db_player_data(PlayerId),
    #t_role_experience{
        newbee_xiuzheng_list = NewBeeXiuZhengList
    } = mod_player:get_t_level(Level),
    if
        NewBeeXiuZhengList =/= [] andalso PropId == ?ITEM_GOLD ->
            noop;
        true ->
            scene_adjust:cost_room_pool_value(PlayerId, Level, Num)
    end,
    GameNode = mod_player:get_game_node(PlayerId),
    mod_apply:apply_to_online_player(GameNode, PlayerId, mod_player, update_player_scene_stay_rewards, [Effect, AwardPropList], normal);
give_function_award(PlayerId, Effect, EffectType, Cost, LeftTimes, SceneId, IdAwardList, MonsterObjId, MonsterId, AlreadyGetIdList) ->
    WeightList =
        case Effect of
            9 ->
                %% 翻牌
                logic_get_function_monster_fanpai_weights_list:assert_get(EffectType);
            10 ->
                %% 拉霸
                logic_get_function_monster_laba_weights_list:assert_get(EffectType);
            11 ->
                %% 转盘
                logic_get_function_monster_zhuanpan_weights_list:assert_get(EffectType)
        end,
    SceneAdjustValue = scene_adjust:get_scene_adjust_rate_value(SceneId),
    [Id, RewardPer, List] = mod_scene_event:get_rand_result(WeightList, SceneAdjustValue),

    Num = case List of [] -> 0; [_, ThisNum] -> ThisNum end,
    IdItemList = {Id, [{api_fight:get_item_id(SceneId, ?ITEM_GOLD), round(Cost * RewardPer / 10000) + Num}]},
    give_function_award(PlayerId, Effect, EffectType, Cost, LeftTimes - 1, SceneId, [IdItemList | IdAwardList], MonsterObjId, MonsterId, [Id | AlreadyGetIdList]).

%% @doc 获得战斗类型
get_fight_type(SceneId) ->
    #t_scene{
        battle_type = FightType
    } = mod_scene:get_t_scene(SceneId),
    FightType.

dizzy_reduce(PlayerId, _Times) ->
    NowTime = util_time:milli_timestamp(),
    [Interval, TimesLimitation, ReduceMs] = ?SD_DIZZY_TIME_REDUCE_LIST,
    CanReduce =
        case get({dizzy_reduce_time, PlayerId}) of
            ?UNDEFINED -> ?TRUE;
            {LatestTime, _LatestTimes} ->
                ?ASSERT(NowTime - Interval >= LatestTime, ?ERROR_TIME_LIMIT),
%%                ?ASSERT(Times >= TimesLimitation, ?ERROR_TIMES_LIMIT),
                ?TRUE
        end,
    put({dizzy_reduce_time, PlayerId}, {NowTime, CanReduce}),
    OldObj = ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_PLAYER, PlayerId),
    #obj_scene_actor{dizzy_close_time = DizzyTime} = OldObj,
    Reduce = ReduceMs * TimesLimitation,
    NewDizzyTime = DizzyTime - Reduce,
    ObjAfterReduceDizzyTime = OldObj#obj_scene_actor{dizzy_close_time = NewDizzyTime},
    ?UPDATE_OBJ_SCENE_ACTOR(ObjAfterReduceDizzyTime),
    Out = #m_fight_dizzy_time_reduce_toc{timestamp = NewDizzyTime, player_id = PlayerId},
%%    ?DEBUG("DizzyTime: ~p", [{DizzyTime, NewDizzyTime, DizzyTime - NewDizzyTime}]),
%%    ?DEBUG("Out: ~p", [Out]),
    mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_REDUCE_STUN_USE_COUNT),
    mod_socket:send_to_player_list(mod_scene_player_manager:get_all_obj_scene_player_id(), proto:encode(Out)),
    success.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%% 校验请求参数
check_fight_param_valid(RequestFightParam, #scene_state{is_mission = true, mission_type = MissionType, mission_id = MissionId} = _SceneState) ->
    #request_fight_param{
        attack_type = AttackType,
        cost = Cost
    } = RequestFightParam,
    if
        AttackType =:= ?OBJ_TYPE_PLAYER ->
            #t_mission{
                mana_attack_list = ManaAttackList
            } = mod_mission:get_t_mission(MissionType, MissionId),
            [_NewPropId, AttackCostList] = ManaAttackList,
            ?ASSERT(lists:member(Cost, AttackCostList));
        true ->
            noop
    end,
    ?ASSERT(mod_mission:is_balance() == false, ?ERROR_ALREADY_BALANCE),
    ?ASSERT(mod_mission:is_start() == true);
check_fight_param_valid(RequestFightParam, #scene_state{scene_id = SceneId} = _SceneState) ->
    #request_fight_param{
        attack_type = AttackType,
        cost = Cost
    } = RequestFightParam,
    if
        AttackType =:= ?OBJ_TYPE_PLAYER ->
            #t_scene{
                mana_attack_list = ManaAttackList
            } = mod_scene:get_t_scene(SceneId),
            [_NewPropId, AttackCostList] = ManaAttackList,
%%            ?DEBUG("查看cost ： ~p", [{Cost, SceneId, AttackCostList}]),
            ?ASSERT(lists:member(Cost, AttackCostList), {value_error, Cost, SceneId, AttackCostList});
        true ->
            noop
    end.

%% -- ??
get_monster_log_cost(FightResult, SkillId, DefaultCost) ->
    if
        SkillId == ?MONSTER_EFFECT_SKILL_102 ->
            ThisLength = length(FightResult#m_fight_notice_fight_result_toc.defender_result_list),
            if
                ThisLength == 0 ->
                    DefaultCost;
                true ->
                    0
            end;
        SkillId == ?MONSTER_EFFECT_SKILL_107 orelse
            SkillId == ?MONSTER_EFFECT_SKILL_106 orelse
            SkillId == ?MONSTER_EFFECT_SKILL_105 orelse
            SkillId == ?MONSTER_EFFECT_SKILL_109 orelse
            SkillId == ?MONSTER_EFFECT_SKILL_110
            ->
            0;
        true ->
            DefaultCost
    end.
