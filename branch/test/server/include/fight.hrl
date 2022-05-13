%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc
%%% @end
%%% Created : 27. 十一月 2017 上午 1:10
%%%-------------------------------------------------------------------
-define(MSG_FIGHT, msg_fight).

%%-define(DICT_BALANCE_GRID_LIST, balance_grid_list).                     %% 结算列表

%%-define(DICT_BALANCE_HURT_RATE, dict_balance_hurt_rate).                %% 结算回合伤害倍率

%% ----------------------------------
%% @doc     战斗结果通知格子列表
%% @throws 	none
%% @end
%% ----------------------------------
%%初始化通知格子列表
-define(INIT_NOTICE_GRID_LIST(),
    put(notice_grid_list, [])
).
%%更新通知格子列表
-define(UPDATE_NOTICE_GRID_LIST(GridId),
    put(notice_grid_list, [GridId | get(notice_grid_list)])
).
%% 获取通知格子列表
-define(GET_NOTICE_GRID_LIST(),
    get(notice_grid_list)
).

%% ----------------------------------
%% @doc     触发buff
%% @throws 	none
%% @end
%% ----------------------------------
%%初始化触发buff列表
-define(INIT_TRIGGER_BUFF_LIST(Type),
    put({trigger_buff_list, Type}, [])
).
%%更新触发buff列表
-define(UPDATE_TRIGGER_BUFF_LIST(Type, RBuff),
    put({trigger_buff_list, Type}, [RBuff | get({trigger_buff_list, Type})])
).
%% 获取触发buff列表
-define(GET_TRIGGER_BUFF_LIST(Type),
    get({trigger_buff_list, Type})
).


%% ----------------------------------
%% @doc     触发effect
%% @throws 	none
%% @end
%% ----------------------------------
%%初始化触发触发effect列表
-define(INIT_TRIGGER_EFFECT_LIST(Type),
    put({trigger_effect_list, Type}, [])
).
%%更新触发触发effect列表
-define(UPDATE_TRIGGER_EFFECT_LIST(Type, RBuff),
    put({trigger_effect_list, Type}, [RBuff | get({trigger_effect_list, Type})])
).
%% 获取触发触发effect列表
-define(GET_TRIGGER_EFFECT_LIST(Type),
    get({trigger_effect_list, Type})
).

%% ----------------------------------
%% @doc     击杀怪物列表
%% @throws 	none
%% @end
%% ----------------------------------
%% 初始化击杀怪物列表
-define(INIT_KILL_MONSTER_LIST(), put(dict_fight_kill_monster_list, [])
).
%% 获取击杀怪物列表
-define(GET_KILL_MONSTER_LIST(), get(dict_fight_kill_monster_list)).

-define(EFFECT_TRIGGER_NODE_ADD, 0).                    %% 添加
-define(EFFECT_TRIGGER_NODE_BEFORE_ATTACK, 1).          %% 攻击前
-define(EFFECT_TRIGGER_NODE_AFTER_ATTACK, 2).           %% 攻击后
-define(EFFECT_TRIGGER_NODE_BEFORE_BE_ATTACKED, 3).     %% 被攻击前
-define(EFFECT_TRIGGER_NODE_AFTER_BE_ATTACKED, 4).      %% 被攻击后

-define(EFFECT_TRIGGER_TYPE_ONE, 0).        %% 执行一次
-define(EFFECT_TRIGGER_TYPE_BUFF, 1).       %% 持续
-define(EFFECT_TRIGGER_TYPE_INTERVAL, 2).   %% 间隔执行

-define(ATTACKER, 0).       %% 攻击者
-define(DEFENSER, 1).       %% 被攻击者

-record(r_passive_skill, {
    id,
    level,
    last_trigger_time = 0
}).
-record(r_buff, {
    id,
    level,
    ref = null,
    data = 0,
    invalid_ms = 0,           %% 失效时间 mx
    releaser_id,              %% 释放者
    release_type              %% 释放者类型
}).

-record(r_effect, {
    id,
    data = 0
}).

%% ----------------------------------
%% @doc 	请求战斗
%% @throws 	none
%% @end
%% ----------------------------------
-record(request_fight_param, {
    attack_type,                        %% 攻击类型
    obj_type,                           %% 攻击者对象类型
    obj_id,                             %% 攻击者对象id
    skill_id,                           %% 技能id
    skill_level,                        %% 技能等级
    dir,                                %% 方向
    target_type = 0,                    %% 目标对象类型
    target_id = 0,                      %% 目标对象id
    balance_round = 1,                  %% 结算回合
    cost = 0,                           %% 消耗银币
    rate = 1,                           %% 时时彩倍率
    player_left_coin = 0,               %% 战斗前玩家身上剩余的金币数量
    skill_point_list = [],              %% 技能释放点列
    other_data_list = [],               %% 其他数据列表
    single_goal_attack_num = 1,         %% 对单一目标的攻击次数(默认一个目标只打一下)
    is_novice = false                   %% 是否新手(修正使用)
}).

%% ----------------------------------
%% @doc 	战斗参数
%% @throws 	none
%% @end
%% ----------------------------------
-record(fight_param, {
    obj_scene_actor,                    %% 攻击者对象
    balance_round,                      %% 结算回合
    skill_point_list = [],              %% 技能释放点列表
    dir,                                %% 方向
    skill_id,                           %% 技能id
    skill_level,                        %% 技能等级
    skill_target_num,                   %% 技能攻击个数
    skill_beat_back,                    %% 技能击退距离
    skill_hurt_rate,                    %% 技能伤害倍率
    skill_ignore_defense_hurt,          %% 技能无视防御伤害
    skill_is_circular,
    skill_attack_length,                %% 技能攻击距离
    skill_balance_type,                 %% 技能结算类型
    pk_mode,                            %% pk模式
    skill_merge_balance_grid_list,      %% 结算格子列表
    skill_balance_hurt_rate,            %% 技能结算伤害倍率
    skill_target,                       %% 技能目标 [0: 敌方　１：自己]
    is_common_skill,                    %% 是否普攻
    target_obj_type,                    %% 目标对象类型
    target_obj_id,                      %% 目标对象id
    fight_type,                         %% 战斗类型[0:概率战斗  1:血量战斗]
    fight_result,                       %% 战报
    single_goal_attack_num,             %% 对单一目标的攻击次数
    skill_adjust = 1,                   %% 主动技能的修正(怒气大招或者单体大招)
    chou_shui_value                     %% 抽水
}).

%% ----------------------------------
%% @doc     基础伤害
%% @throws 	none
%% @end
%% ----------------------------------
%%             攻击          技能伤害            无视防御伤害               防御        防御无视防御伤害减免
-define(GET_BASE_HURT(AttAttack, AttSkillHurtRate, SkillIgnoreDefenseHurt, DefDefense),
    if AttAttack >= 2 * DefDefense ->
        max((AttAttack - DefDefense) * AttSkillHurtRate / 10000, 0) + SkillIgnoreDefenseHurt;
        true ->
            max(AttAttack * AttAttack / max(DefDefense * 4, 1) * AttSkillHurtRate / 10000, 0) + SkillIgnoreDefenseHurt
    end
).

%% ----------------------------------
%% @doc     普通伤害
%% @throws 	none
%% @end
%% ----------------------------------
-define(GET_NORMAL_HURT(BaseHurt, AttHurtAddRate, DefHurtReduceRate, AttLevel, DefLevel),
    max(
        (BaseHurt * util_random:random_number(95, 105) / 100 *
            (1 + (AttHurtAddRate - DefHurtReduceRate) / 10000)),
        1
    )
).


%%%% ----------------------------------
%%%% @doc     普通伤害
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%-define(GET_NORMAL_HURT(BaseHurt, AttHurtAddRate, DefHurtReduceRate, AttLevel, DefLevel),
%%    max(
%%        (BaseHurt * util_random:random_number(95, 105) / 100 *
%%            (1 + (AttHurtAddRate - DefHurtReduceRate) / 10000)) *
%%            (1 + max(min(AttLevel - DefLevel, 100), -100) * 0.01),
%%        1
%%    )
%%).


%% ============================================================================================
-define(DICT_FIGHT_RESULT_IS_ALL_SCENE_SYNC, dict_fight_result_is_all_scene_sync).          %% 战斗结果是否全场景同步
-define(DICT_FIGHT_IS_FIXED_CRIT, dict_fight_is_fixed_crit).                                %% 战斗是否必定暴击
-define(DICT_FIGHT_OTHER_DATA_LIST, dict_fight_other_data_list).                            %% 战斗其他数据列表

-define(FIGHT_TYPE_ODDS, 0).                                                                %% 战斗类型(概率)
-define(FIGHT_TYPE_HP, 1).                                                                  %% 战斗类型(血量)

%% @doc 攻击参数
-record(attack_param, {
    skill_id,
    att_obj_type,
    att_obj_id,
    new_linli,
    def_hurt_list,
    die_list,
    def_hp,
    cost,
    defender_nth,                        %% 第N个受击对象
    attack_times,
    already_attack_times = 0,
    total_hurt_value,
    kind,
    monster_id,
    is_use_adjust,
    player_hp_hurt_list,
    attack_result_type,
    die_type,
    is_boss,
    scene_id,
    skill_adjust,
    chou_shui_value
}).

%% @doc buff
-record(r_new_buff, {
    id,
    ref,
    invalid_ms = 0,             %% 失效时间 mx
    cd_time                     %% cd时间
}).

%% @doc 效果
-record(r_new_effect, {
    id,
    time
}).