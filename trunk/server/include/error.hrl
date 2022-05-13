%%%-------------------------------------------------------------------
%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            ERROR宏定义
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------

% ---------------------- 通用错误  ------------------------%
-define(ERROR_NO_ROLE,                   no_role).                      %% 没有角色
-define(ERROR_DISABLE_LOGIN,             disable_login).                %% 禁止登录
-define(ERROR_LOGIN_FREQUENT,            login_frequent).               %% 频繁登录
-define(ERROR_VERIFY_FAIL,               verify_fail).                  %% 验证失败
-define(ERROR_TOKEN_EXPIRE,              token_expire).                 %% token过期
-define(ERROR_ALREADY_CREATE_ROLE,       already_create_role).          %% 已经创建角色
-define(ERROR_INVAILD_NAME,              invaild_name).                 %% 非法名字
-define(ERROR_NAME_USED,                 name_used).                    %% 名字已经使用
-define(ERROR_NAME_TOO_LONG,             name_too_long).                %% 名字过长
-define(ERROR_NOT_ENOUGH_INGOT,          not_enough_ingot).             %% 元宝不足
-define(ERROR_NOT_ENOUGH_BIND_INGOT,     not_enough_bind_ingot).        %% 绑元不足
-define(ERROR_NOT_ENOUGH_COIN,           not_enough_coin).              %% 铜钱不足
-define(ERROR_NOT_ENOUGH_MANA,           not_enough_mana).              %% 灵力不足
-define(ERROR_NOT_ENOUGH_ITEM_NUM,       not_enough_item_num).          %% 道具不足
-define(ERROR_NOT_CAN_RESOURCE,          not_can_resource).             %% 资源不足
-define(ERROR_NOT_ENOUGH_PLAYER_LEVEL,   not_enough_player_level).      %% 玩家等级不足
-define(ERROR_NOT_ENOUGH_TEMP_BAG,       not_enough_temp_bag).          %% 临时背包不足
-define(ERROR_NOT_ENOUGH_GRID,           not_enough_grid).              %% 没有空格子
-define(ERROR_NOT_ENOUGH_NUMBER,         not_enough_number).            %% 数量不足
-define(ERROR_NEED_LEVEL,                need_level).                   %% 等级限制
-define(ERROR_NEED_POWER,                need_power).                   %% 战力限制
-define(ERROR_NEED_MINERAL_LEVEL,        need_mineral_level).           %% 挖矿等级限制
-define(ERROR_NONE,                      none).                         %% 无
-define(ERROR_DISABLE_CHAT,              disable_chat).                 %% 禁言
-define(ERROR_MSG_TOO_LONG,              msg_too_long).                 %% 消息太长
-define(ERROR_TOO_FREQUENT,              too_frequent).                 %% 太频繁
-define(ERROR_LEVEL_TEMPLATE_LIMIT,      level_template_limit).         %% 模板等级上限
-define(ERROR_ALREADY_PASS,              already_pass).                 %% 已经通关
-define(ERROR_NO_TEAM,                   no_team).                      %% 没有队伍
-define(ERROR_ALREADY_WISH,              already_wish).                 %% 已经祝福
-define(ERROR_NOT_ENOUGH_TIMES,          not_enough_times).             %% 次数不足
-define(ERROR_ALREADY_SWEEP,             already_sweep).                %% 已经扫荡
-define(ERROR_NO_PASSED,                 no_passed).                    %% 没有通关
-define(ERROR_NOT_AUTHORITY,             not_authority).                %% 没有权力
-define(ERROR_NOT_ENOUGH_VIP_LEVEL,      not_enough_vip_level).         %% vip等级不足
-define(ERROR_EXISTS_PLAYER,             exists_player).                %% 玩家存在
-define(ERROR_NOT_EXISTS,                not_exists).                   %% 不存在
-define(ERROR_MEMBER_FULL,               member_full).                  %% 满员
-define(ERROR_NOT_ENOUGH_LEVEL,          not_enough_level).             %% 等级不足
-define(ERROR_OLD_ITEM_TIME,             old_item_time).                %% 道具过期
-define(ERROR_TIMES_LIMIT,               times_limit).                  %% 次数限制
-define(ERROR_NEW_PLAYER,                new_player).                   %% 新手玩家
-define(ERROR_FUNCTION_NO_OPEN,          function_no_open).             %% 未开启
-define(ERROR_NO_ENOUGH_PROP,            no_enough_prop).               %% 道具不足
-define(ERROR_TIME_LIMIT,                time_limit).                   %% 时间限制
-define(ERROR_NUMBER_LIMIT,              number_limit).                 %% 数量限制
-define(ERROR_COMPARE_HIGH,              compare_high).                 %% 比较高
-define(ERROR_ALREADY_HAVE,              already_have).                 %% 已经存在
-define(ERROR_NOT_ONLINE,                not_online).                   %% 不在线
-define(ERROR_NULL_OBJECT,               null_object).                  %% 空对象
-define(ERROR_PLAYER_NOT_EXISTS,         player_not_exists).            %% 玩家不存在
-define(ERROR_LAST_LEVEL_NO_PASSED,      last_level_no_passed).         %% 上一关未通过
-define(ERROR_ONE,                       one).
-define(ERROR_TWO,                       two).
-define(ERROR_THREE,                     three).
-define(ERROR_FAIL,                      fail).                         %% 失败
-define(ERROR_ALREADY_GET,               already_get).                  %% 已经获得
-define(ERROR_TASK_LIMIT,                task_limit).                   %% 任务限制
-define(ERROR_PVP_STATUS,                pvp_status).                   %% PVP状态
-define(ERROR_IN_TRANSPORT_GOODS,        in_transport_goods).           %% 物资运送中
-define(ERROR_HAVE_OBJECT,               have_object).                  %% 存在对象
-define(ERROR_MAX_LEVEL,                 max_level).                    %% 最高等级
-define(ERROR_NUM_0,                     num_0).                        %% 数量为0
-define(ERROR_NOT_ENOUGH_EXP,            not_enough_exp).               %% 经验不足
-define(ERROR_CLOSE,                     close).                        %% 关闭
-define(ERROR_NO_FINISH,                 no_finish).                    %% 未完成
-define(ERROR_CHALLENGE_MISSION_TOO_FREQUENT,challenge_mission_too_frequent).%% 挑战副本太频繁
-define(ERROR_LOGIN_IN_OTHER,            login_in_other).               %% 已经在别处登录
-define(ERROR_NOT_NEW_LEVEL_PLAYER,      not_new_level_player).         %% 不是新手玩家
-define(ERROR_ACTIVITY_NO_OPEN,          activity_no_open).             %% 活动未开启
-define(ERROR_NO_OPEN,                   no_open).                      %% 未开启
-define(ERROR_QUALITY_LIMIT,             quality_limit).                %% 品质上限
-define(ERROR_ALREADY_START,             already_start).                %% 已经开始
-define(ERROR_ERROR_PASSWORD,            error_password).               %% 密码错误
-define(ERROR_NO_ENOUGH_POWER,           no_enough_power).              %% 战力不足
-define(ERROR_ALREADY_GUESS,             already_guess).                %% 已经竞猜
-define(ERROR_NO_PLACE,                  no_place).                     %% 么有位置
-define(ERROR_NO_ENOUGH_SCORE,           no_enough_score).              %% 没有足够积分
-define(ERROR_INTERFACE_CD_TIME,         interface_cd_time).            %% 接口cd时间
-define(ERROR_PLAYER_LEVEL_LIMIT,        player_level_limit).           %% 玩家等级限制
-define(ERROR_ALREADY_EQUIP,             already_equip).                %% 已装备
-define(ERROR_TABLE_DATA,                error_table_data).             %% 模板数据出错
-define(ERROR_NO_CONDITION,              error_no_condition).           %% 条件不足
-define(ERROR_GM_CONFINE,                error_gm_confine).             %% gm限制
-define(ERROR_INVALID_IP,                error_invalid_ip).             %% 无效ip
-define(ERROR_EXPIRE,                    expire).                       %% 过期
% ====================== 通用错误  =======================%


% ---------------------- 场景错误  ------------------------%
-define(ERROR_NOT_CAN_WALK,              not_can_walk).                 %% 不可行走区
-define(ERROR_NO_PET,                    no_pet).                       %% 没有宠物
-define(ERROR_NOT_USE_SKILL_TIME,        not_use_skill_time).           %% 不可使用技能
-define(ERROR_ALREADY_DIE,               already_die).                  %% 已经死亡
-define(ERROR_ALREADY_LIVE,              already_live).                 %% 还活着
-define(ERROR_ALREADY_IN_SCENE_WORKER,   already_in_scene_worker).      %% 已经在场景
-define(ERROR_NOT_MOVE_TIME,             not_can_move_time).            %% 不可移动时间
-define(ERROR_NO_OBJ_SCENE_PLAYER,       no_obj_scene_player).          %% 玩家对象不存在
-define(ERROR_NO_OBJ_SCENE_MONSTER,      no_obj_scene_monster).         %% 怪物对象不存在
-define(ERROR_MOVE_TOO_QUICK,            move_too_quick).               %% 移动太快
-define(ERROR_ALREADY_IN_THIS_GRID,      already_in_this_grid).         %% 已经在这个格子
-define(ERROR_NOT_IN_THIS_GRID,          not_in_scene_grid).            %% 不在这个格子
-define(ERROR_UNKNOWN_GRID,              unknown_grid).
-define(ERROR_SAFE_POS,                  safe_pos).                     %% 安全场景
-define(ERROR_BALANCE_ERROR,             balance_step_error).           %% 结算错误
-define(ERROR_NEED_TASK,                 need_task).                    %% 需要任务
-define(ERROR_TOO_LONG,                  too_long).                     %% 太远
-define(ERROR_TOO_NEAR,                  too_near).                     %% 太近
-define(ERROR_ALREADY_VISIT,             already_visit).                %% 已经访问
-define(ERROR_NOT_ACTION_TIME,           not_action_time).              %% 非行动时间
-define(ERROR_WATCH_MODEL,               watch_model).                  %% 观察者模式
-define(ERROR_OTHER_COLLECTING, other_collecting).                      %% 其他人正在采集
-define(ERROR_NOT_COLLECT_TIME, not_collect_time).                      %% 不可采集时间
-define(ERROR_NOT_ENOUGH_JUMP, not_enought_jump).                       %% 没有足够跳闪值
-define(ERROR_NOT_OWNER, not_owner).                                    %% 不是属主
-define(ERROR_SCENE_TRAP_REPEATED, scene_trap_repeated).                %% 陷阱重复
-define(ERROR_TREASURE_STATUS, scene_treasure_status).                  %% 挖矿状态
-define(ERROR_MISSION_NO_START, mission_no_start).                      %% 副本未启动
% ====================== 场景错误  =======================%

% ---------------------- 战斗错误  ------------------------%
-define(ERROR_SKILL_FORCE_WAIT_TIME, skill_force_wait_time).             %% 技能硬直时间
-define(ERROR_SKILL_CD_TIME, skill_cd_time).                             %% 技能cd时间
-define(ERROR_SKILL_TYPE_ERROR, skill_type_error).                       %% 技能类型错误
-define(ERROR_NOT_ENOUGH_ANGER, not_enought_anger).                      %% 没有足够怒气
-define(ERROR_ALREADY_BIAN_SHEN, already_bian_shen).                     %% 已经变身
-define(ERROR_NOT_BIANSHEN_TIME, not_bianshen_time).                     %% 不是变身时间
-define(ERROR_BIANSHEN_TIME, bianshen_time).                             %% 变身时间
-define(ERROR_FIGHT_TARGET_ERROR, fight_target_error).                   %% 战斗目标错误
-define(ERROR_SKILL_NOT_FIND, skill_not_find).                           %% 没有该技能
-define(ERROR_TARGET_ALREADY_DIE, target_already_die).                   %% 目标已经死亡
-define(ERROR_TARGET_NO_EXISTS, target_no_exitsts).                      %% 目标不存在
-define(ERROR_ALREADY_BALANCE, already_balance).                         %% 已经结算
% ====================== 战斗错误  =======================%

% ---------------------- 物资运送  ------------------------%
-define(ERROR_ALREADY_TRANSPORT,         already_transport).             %% 还在运送
-define(ERROR_NO_TRANSPORT,              no_transport).                  %% 没有运送
-define(ERROR_WISHING,                   wishing).                       %% 正在祝福
% ====================== 物资运送  =======================%

% ---------------------- 队伍 ------------------------%
-define(ERROR_ALREADY_JOIN_TEAM,         already_join_team).             %% 已经加入队伍
-define(ERROR_TEAM_NO_EXISTS,           team_no_exists).                 %% 队伍不存在
-define(ERROR_NOT_LEADER,              not_leader).                      %% 不是队长
-define(ERROR_ALREADY_INVITE,              already_invite).              %% 已经邀请
-define(ERROR_ALREADY_REQUEST,              already_request).            %% 已经请求
-define(ERROR_EXPIRE_REQUEST,              expire_request).              %% 请求过期
% ====================== 队伍 =======================%

% ---------------------- 多人BOSS ------------------------%
-define(ERROR_ALREADY_JOIN_ROOM,          error_already_join_room).     %% 已经加入房间
% ====================== 多人BOSS =======================%

% ---------------------- 投注界面 ------------------------%
-define(ERROR_NOT_CAN_BE_BET,          error_not_can_bet_bet).     %% 在不允许投注的mission_type中进行投注
% ====================== 投注界面 =======================%
