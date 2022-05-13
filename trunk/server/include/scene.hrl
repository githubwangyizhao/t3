%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             场景
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-define(SCENE_MASTER, scene_master).
-define(MAP_DATA_DIR, "../priv/map/").
-define(DETS_MAP_MARK, ?MAP_DATA_DIR ++ "map_mark.data").

%% 场景类型
%%-define(SCENE_TYPE_WORLD_SCENE, 1).        %% 世界场景
%%-define(SCENE_TYPE_MISSION, 2).            %% 副本

%% 副本类别
-define(MISSION_KIND_SINGLE, 1).            %% 单人副本
-define(MISSION_KIND_MULTIPLE, 2).          %% 多人副本
-define(MISSION_KIND_UNIQUE_MULTIPLE, 3).   %% 多人唯一副本
-define(MISSION_KIND_LINE_MULTIPLE, 4).     %% 多人分线副本

%% 场景刷怪状态类型
-define(SCENE_MASTER_STATE_MONSTER, 0).                                 %% 场景管理状态 普通怪
-define(SCENE_MASTER_STATE_YU_CHAO, 1).                                 %% 场景管理状态 鱼潮
-define(SCENE_MASTER_STATE_BOSS, 2).                                    %% 场景管理状态 BOSS
-define(SCENE_MASTER_STATE_BOX, 3).                                     %% 场景管理状态 宝箱
-define(SCENE_MASTER_STATE_BALL, 4).                                    %% 场景管理状态 彩球

%% 地图数据ets表
-define(MAP_MART_TABLE(MapId), map_data:get_map_mark_table_name(MapId)).

-define(TILE_TYPE_NO_WALK, 0).
-define(TILE_TYPE_WALK, 1).
-define(TILE_TYPE_FLY, 7).

%%-define(GRID1(GX, GY), {GX - 1, GY - 1}).
%%-define(GRID2(GX, GY), {GX, GY - 1}).
%%-define(GRID3(GX, GY), {GX + 1, GY - 1}).
%%-define(GRID4(GX, GY), {GX - 1, GY}).
%%-define(GRID5(GX, GY), {GX, GY}).
%%-define(GRID6(GX, GY), {GX + 1, GY}).
%%-define(GRID7(GX, GY), {GX - 1, GY + 1}).
%%-define(GRID8(GX, GY), {GX, GY + 1}).
%%-define(GRID9(GX, GY), {GX + 1, GY + 1}).

%%场景安全类型
%%-define(SCENE_SAFE_LEVEL_SAFE, 0).      %%安全场景
%%-define(SCENE_SAFE_LEVEL_COMMON, 1).    %%一般场景
%%-define(SCENE_SAFE_LEVEL_DANGER, 2).    %%危险场景

%%格子大小
-define(GET_GRID_PIX_WIDTH, get(grid_pix_width)).
-define(GET_GRID_PIX_HEIGHT, get(grid_pix_height)).
-define(INIT_GRID_PIX_WIDTH(Value), put(grid_pix_width, Value)).
-define(INIT_GRID_PIX_HEIGHT(Value), put(grid_pix_height, Value)).

%% 588 * 988
%%-define(DEFAULT_GRID_PIX_WIDTH, 266).  640 * 1136   rate 2.5  1920 * 980
%%-define(DEFAULT_GRID_PIX_WIDTH, 400).
%%-define(DEFAULT_GRID_PIX_HEIGHT, 473).
%%-define(DEFAULT_GRID_PIX_WIDTH, 220).
%%-define(DEFAULT_GRID_PIX_HEIGHT, 380).


%%-define(DEFAULT_GRID_PIX_WIDTH, 350).
%%-define(DEFAULT_GRID_PIX_HEIGHT, 450).

-define(DEFAULT_GRID_PIX_WIDTH, 350).
-define(DEFAULT_GRID_PIX_HEIGHT, 450).


-define(MIN_PW, 640).
-define(MIN_PH, 640).

-define(MAX_PW, 1920 - 200).
-define(MAX_PH, 1080 - 200).

%% TILE 长度
-define(TILE_LEN, 40).
-define(TILE_LEN_2_PIX_LEN(L), L * ?TILE_LEN).
-define(PIX_LEN_2_TILE_LEN(L), erlang:ceil(L / ?TILE_LEN)).
%%-define(PIX_LEN_2_TILE_LEN_CEIL(L), erlang:ceil(L / ?TILE_LEN)).
%% 像素坐标 -> tile坐标
-define(PIX_2_TILE(X, Y), {trunc(X / ?TILE_LEN), trunc(Y / ?TILE_LEN)}).
%% 像素坐标 -> mask_id
-define(PIX_2_MASK_ID(MapId, X, Y), {MapId, ?PIX_2_TILE(X, Y)}).
%% tile坐标 -> 像素坐标
-define(TILE_2_PIX(X, Y), {trunc((X + 0.5) * ?TILE_LEN), trunc((Y + 0.5) * ?TILE_LEN)}).
%% 像素坐标 -> 格子id
-define(PIX_2_GRID_ID(X, Y), {trunc(X / ?GET_GRID_PIX_WIDTH), trunc(Y / ?GET_GRID_PIX_HEIGHT)}).

-define(CHECK_CLOSE_SCENE_TIME, 2 * 60 * 1000). %%定时检测关闭场景

-define(RANDOM_OBJ_SCENE_TRAP_ID_RANGE, [1000000, 2000000]).%% 怪物对象随机唯一id范围


%%场景物品类型
-define(SCENE_ITEM_TYPE_ITEM, 0). %%道具

%% 场景state
-record(scene_state, {
    scene_id = 0,                       %% 场景id
    scene_type,                         %% 场景类型
    is_mission = false,                 %% 是否是副本
    mission_type = 0,                   %% 副本类型
    mission_id = 0,                     %% 副本id
    is_hook_scene = true,               %% 是否挂机场景
    rebirth_window = 0,                 %% 复活弹窗类型
    owner = null,                       %% 归属进程
    is_scene_master_manage,             %% 场景管理进程
    scene_navigate_worker,              %% 场景寻路进程
    map_id = 0,                         %% 地图id
    extra_data_list = [],               %% 场景额外信息
    fight_type = 1
}).

-record(filter_target, {
    this_obj_type,
    this_obj_id,
    this_own_type,
    this_own_id,
    level,
    effect,
    is_robot,
    can_be_immediate_death
}).

%%地图MARK
-record(map, {
    id :: {x, y},
    obstacle        %%障碍点 0: 不可行走 1:可行走
}).

%%场景进程映射
-define(ETS_SCENE_WORKER_MAP, ets_scene_worker_map).
-record(ets_scene_worker_map, {
    scene_id,                       %% 场景id
%%    energy = 0,                     %% 场景能量
%%    energy_list = [],               %% 场景能量事件列表
%%    state,                          %% 场景状态
%%    state_start_time,               %% 该状态开始时间
%%    boss_data,                      %% boss的场景数据
    scene_worker_info_list          %% 场景进程信息列表(同场景不同分线)
}).

%%刷怪点
-record(monster_point, {
%%    id,
    monster_id,
    x,
    y,
    obj_monster_id_list = [],
    player_id_list = [],
%%    num = 0,
    birth_time = 0
}).

-record(scene_worker_info, {
    scene_worker,
    monitor_ref,
    count = 0,
    status = 0,
    player_id_list = []
}).

-define(SCENE_WORKER_STATUS_NORMAL, 0).     %% 正常
-define(SCENE_WORKER_STATUS_WAIT_CLOSE, 1). %% 等待关闭

%%-define(ETS_SCENE_GRID, ets_scene_grid).
-record(dict_scene_grid, {
    id :: {gx, gy},
    player_list = [],                %% 该格子上玩家id列表
    monster_list = [],               %% 该格子上怪物唯一id列表
    item_list = [],                  %% 该格子上掉落物id列表
    trap_list = [],                  %% 该格子上陷阱id列表
    subscribe_player_id_list = []    %% 订阅该格子的玩家id列表
}).


%% ----------------------------------
%% @doc 	玩家进入场景数据
%% @throws 	none
%% @end
%% ----------------------------------
-record(player_enter_scene_data, {
    x = 0,
    y = 0,
    player_id = 0,
    player,
    player_data,
    obj_player,
    dir = 0,
    active_skill_list = [],
    passive_skill_list = [],
    subscribe_list = [],                %% 订阅的宫格数据
    player_name = "",                   %% 玩家名字
    magic_weapon_id = 0,                %% 法宝id
    is_robot,                           %% 是否是机器人
    hero,                               %% 英雄
    is_use_anger = false,               %% 是否使用怒气
    is_can_add_anger                    %% 玩家是否可以增加怒气
}).


-define(MOVE_TYPE_NORMAL, 0).           %% 移动类型:正常
-define(MOVE_TYPE_MOMENT, 1).           %% 移动类型:冲刺
-define(MOVE_TYPE_SKILL, 2).            %% 移动类型:技能

%% ----------------------------------
%% @doc 	属主信息
%% @throws 	none
%% @end
%% ----------------------------------
-record(owner_info, {
    obj_type = 0,
    obj_id = 0
}).

%% ----------------------------------
%% @doc 	场景对象类型
%% @throws 	none
%% @end
%% ----------------------------------
-define(OBJ_TYPE_PLAYER, 1).
-define(OBJ_TYPE_MONSTER, 2).
-define(OBJ_TYPE_PET, 3).
-define(OBJ_TYPE_MAGIC_WEAPON, 4).
-define(OBJ_TYPE_FUNCTION_MONSTER_SKILL, 5).
%%-define(OBJ_TYPE_BUFF, 5).
%% ----------------------------------
%% @doc 	追踪对象信息
%% @throws 	none
%% @end
%% ----------------------------------
-record(track_info, {
    obj_type = 0,
    obj_id = 0,
    x = 0,
    y = 0
}).

%% ----------------------------------
%% @doc 	前往目的地
%% @throws 	none
%% @end
%% ----------------------------------
-record(go_target_place, {
    x = 0,
    y = 0,
    function = null
}).

-record(fight_attr_param, {
    attack = 0,                         %% 攻击
    defense = 0,                        %% 防御
    hit = 0,                            %% 命中
    dodge = 0,                          %% 闪避
    tenacity = 0,                       %% 韧性
    critical = 0,                       %% 暴击
    hurt_add = 0,                       %% 伤害加成
    hurt_reduce = 0,                    %% 伤害减免
    crit_hurt_add = 0,                  %% 造成暴击伤害增加
    crit_hurt_reduce = 0,               %% 受到暴击伤害减少
    hurt = 0,                           %% 造成的伤害
    rate_resist_block = 0,              %% 破击
    rate_block = 0                      %% 格挡
}).
%% ----------------------------------
%% @doc 	玩家外观
%% @throws 	none
%% @end
%% ----------------------------------
-record(surface, {
    title_id = 0,                       %% 称号id
    magic_weapon_id = 0,                %% 法宝id
    hero_id = 0,                        %% 英雄id
    hero_arms = 0,                      %% 英雄武器
    hero_ornaments = 0,                 %% 英雄饰品
    head_id = 0,                        %% 头像id
    head_frame_id = 0,                  %% 头像框id
    chat_qi_pao_id = 0                  %% 聊天气泡id
}).

-record(robot_data, {
    robot_task_context = null,          %% 任务内容
    robot_task_num = 0,                 %% 当前任务数量
    robot_task_status = 0,              %% 任务状态
    robot_task_id = 0,                  %% 任务id
    robot_destroy_time_ms = 0,          %% 机器人销毁时间
    robot_delay_time_ms = 0,            %% 机器人等待销毁时间
    robot_fight_cost_mana = 0,          %% 机器人战斗消耗灵力(时时副本)
    robot_item_list = [],               %% 机器人道具列表
    robot_leave_list = []               %% 机器人道具离开列表
}).

-record(wait_skill,{
    skill_id,
    dir,
    end_time,
    request_fight_param
}).

%% ----------------------------------
%% @doc 	场景活物对象
%% @throws 	none
%% @end
%% ----------------------------------
-record(obj_scene_actor, {
    key :: {?OBJ_TYPE_PLAYER | ?OBJ_TYPE_MONSTER, integer()},%% key
    obj_id :: integer(),                %% actor唯一id
    obj_type :: ?OBJ_TYPE_PLAYER | ?OBJ_TYPE_MONSTER,%% 对象类型
    client_node,                        %% 玩家节点
    server_id,                          %% 玩家区服id
    client_worker,                      %% 玩家进程
    base_id,                            %% base id ,怪物有效， 即怪物id
    base_type,                          %% base 类型 怪物有效 即怪物类型
    monitor_ref,
    cost = 0,
    is_robot = false,                   %% 是否机器人
    is_call = false,
    anger = 0,
    destroy_time_ms = 0,                %% 销毁时间
%%    cd_reduce_time = 0,                 %% cd减少时间
    hurt_list = [],
    total_hurt = 0,
    create_time = 0,                    %% 创建时间
    %% 基础属性 %%
    nickname = "",                      %% 玩家昵称
    sex = 0,                            %% 性别
    level = 0,                          %% 玩家等级
    vip_level = 0,                      %% 玩家vip等级
    init_move_speed = 0,
    move_speed = 0,                     %% 移动速度
%%    buff_add_speed = 0,                 %% buff 加的速度值(只能有一个加速度的buff)
    %% 战斗属性 %%
    bing_don_end_time = 0,              %% 冰冻结束时间
    pk_mode = 0,                        %% pk 模式

    max_hp = 0,                         %% 最大血量
    hp = 0,                             %% 血量
    hu_dun = 0,                         %% 护盾
    hu_dun_ref = 0,                     %% 护盾buff ref
    attack = 0,                         %% 攻击
    defense = 0,                        %% 防御
    hit = 0,                            %% 命中
    dodge = 0,                          %% 闪避
    tenacity = 0,                       %% 韧性
    critical = 0,                       %% 暴击
    hurt_add = 0,                       %% 伤害加成
    hurt_reduce = 0,                    %% 伤害减免
    crit_hurt_add = 0,                  %% 造成暴击伤害增加
    crit_hurt_reduce = 0,               %% 受到暴击伤害减少
    rate_resist_block = 0,              %% 破击
    rate_block = 0,                     %% 格挡

    effect = 0,
%%    is_huangjin = 0,
    power = 0,                          %% 战力
    buff_list = [],                     %% buff列表
    r_passive_skill_list = [],          %% 被动效果列表
    r_active_skill_list = [],           %% 主动技能列表
    last_fight_time_ms = 0,             %% 上次战斗时间
    last_fight_skill_id = 0,            %% 上次战斗使用的技能id
    last_attacked_time_ms = 0,          %% 上次被攻击时间
    join_monster_point = 0,             %% 监听的刷怪点
    rebirth_timer_ref = null,           %% 复活定时器
    be_attacked_obj_type = 0,           %% 攻击自己的对象类型
    be_attacked_obj_id = 0,             %% 攻击自己的对象id
    attack_type = 0,                    %% 攻击类型[0:攻击者 1:被攻击者]
    fight_attr_param = #fight_attr_param{},
    belong_player_id = 0,               %% 归属玩家id(怪物有效)

    %% 移动相关 %%
    grid_id = {-1, -1},                 %% 格子id
    subscribe_list = [],
    birth_x = 0,
    birth_y = 0,
    x = 0,                              %% x坐标
    y = 0,                              %% y坐标
    dir = 4,                            %% 方向
    go_x = 0,
    go_y = 0,
    move_path = [],
    move_type = 0,
    last_move_time = 0,                 %% 上次移动时间
    attack_times = 0,                   %% 攻击次数
    collect_obj_scene_item_id = 0,      %% 正在采集的物品id
    %% 外观相关 %%
    surface :: #surface{},

    %% ai 相关 %%
    can_action_time = 0,                %% 可以行动的时间 (ms)
    can_use_skill_time = 0,             %% 可以使用技能的时间 (ms)
%%    pet_can_fight_time = 0,           %% 妖灵可以攻击的时间 (ms)
%%    magic_weapon_can_fight_time = 0,    %% 法宝可以攻击的时间 (ms)
    next_can_heart_time = 0,            %% 下次可以心跳时间
    status = 0,                         %% 状态
    rebirth_time = -1,                  %% 复活时间 ms
    hate_list = [],                     %% 仇恨列表
    is_wait_navigate = false,           %% 是否等待寻路
    is_boss = false,                    %% 是否是boss
    track_info = #track_info{},         %% 追踪信息
    go_target_place :: #go_target_place{},
    owner_obj_id = 0,                   %% 归属玩家id
    owner_obj_type = 0,
    search_fight_target_time = 0,       %% 上次搜索攻击目标时间

    %% 机器人数据
    robot_data = undefined :: undefined|#robot_data{},
    kind = 0,                           %% 怪物类型(0:小怪)
    shen_long_time = 0,                 %% 神龙时间
    gold_rank_event_list = [],          %% 金币排行榜事件列表
    dizzy_close_time = 0,               %% 眩晕结束时间
    can_be_dizzy_time = 0,              %% 可以被眩晕的时间
    jbxy_can_move_time = 0,             %% 金币小妖可以切换目标时间
    is_all_sync = false,                %% 是否全场景同步(怪物)
    is_can_add_anger = false,           %% 是否可以增加怒气
    player_hp_hurt_list = [],           %% 新版hp战斗 怪物受玩家伤害列表
    wait_skill_info :: undefined|#wait_skill{},  %% 蓄力技能
    kuang_bao_time = 0,                 %% 狂暴时间(玩家)
    die_type = 0,                       %% (0:正常走概率,1:不可被打死,2:下一刀必死)
    new_buff_list = [],                 %% 新buff列表
    is_cannot_be_attack = false,        %% 是否无法选中状态
    type_action_list = [],              %% 对应怪物类型的循环列表
    group = 0                           %% 怪物分组
}).

%% 炸弹怪AI相关
-record(r_monster_bomb, {
    base_x = 0,                         %% 触发狂暴时x坐标
    base_y = 0,                         %% 触发狂暴时y坐标
    wild_end_time = 0,                  %% 狂暴结束时间
    last_drop_bomb_time = 0,            %% 上一次仍炸弹时间
    attacked_time_records = []          %% 最近N次受攻击时间记录(辅助判定炸弹怪是否开启狂暴模式)
}).

%% 场景怪AI相关
-define(MONSTER_AI_STATE_STAND, 1).         %% 待机
-define(MONSTER_AI_STATE_HURT, 2).          %% 受击
-record(r_monster_ai, {
    state = ?MONSTER_AI_STATE_STAND,            %% 状态
    speak_times = 0,                            %% 受击后说话次数
    last_speak_time = 0                         %% 最近一次说话时间
}).

%% boss ai相关
-record(r_boss_ai, {
    seq = 0,                            %% 动作序号
    action_end_time = 0                 %% 动作结束时间（毫秒）
}).

%% 场景事件任务
-record(r_event_task, {
    type,           %% 任务类型(1-摇钱树, 其他)
    id,             %% 任务ID
    status = 1,     %% 任务状态(1-未完成, 2-已完成)
    done = 0,       %% 完成数
    stage = 1       %% 阶段(1-任务阶段, 2-活动阶段)
}).

%% ----------------------------------
%% @doc 	场景物品
%% @throws 	none
%% @end
%% ----------------------------------
-define(OBJ_SCENE_ITEM, obj_scene_item).
-record(obj_scene_item, {
    id,                     %% 场景物品ID
    type = 0,               %% 0:道具 1:采集物
    base_id = 0,            %% 道具id
    num = 0,
    x = 0,
    y = 0,
    drop_obj_scene_monster_id = 0, %% 掉落该物品的怪物唯一id
    own_player_id = 0       %% 属主玩家id
}).


%% 场景采集物
-record(r_scene_gather, {
    id,
    gather_id,
    x,
    y
}).

%% 场景陷阱
-record(r_scene_trap, {
    id,
    trap_id,
    delay = 0,
    x = 0,
    y = 0,
    tile_list = [],
    param_list = []
}).

%% npc
-record(r_scene_npc, {
%%    id,
    npc_id,
    x,
    y
}).

% 地图数据
-record(r_map_data, {
    map_id,
    width,
    height,
    jump_list
%%    path_node_list
}).

% 场景怪物
-record(r_scene_monster, {
    id,
    monster_id,
    scene_id,
    x,
    y,
    level,
    round,
    delay,
    rebirth_time = -2
}).
%% 进入场景参数
-record(enter_scene_args, {
    player_id,
    scene_id,
    x,
    y,
    extra_data_list,
    type,
    scene_worker = null,
    is_reconnect = false,
    call_back_fun = null,
    expire_time = 0,
    is_single = false
}
).
%% 创建怪物参数
-record(create_monster_args, {
    monster_id = 0,
    birth_x = 0,
    birth_y = 0,
    is_notice = true,
    owner_obj_type = 0,
    owner_obj_id = 0,
    live_time = 0,
    cost = 0,
    dir = 0,
    group = 0
}).

%% 时间轴事件
-record(scene_loop_time_event,{
    time = 0,
    event_type = 0,
    event_arg = 0,
    exist_time = 0,
    is_notice = true
}).

-define(SCENE_TIME_EVENT_TYPE_YU_CHAO, 1).                              %% 鱼潮
-define(SCENE_TIME_EVENT_TYPE_BOSS, 2).                                 %% BOSS
-define(SCENE_TIME_EVENT_TYPE_BOX, 3).                                  %% 宝箱
-define(SCENE_TIME_EVENT_TYPE_ZHUAN_PAN, 4).                            %% 转盘
-define(SCENE_TIME_EVENT_TYPE_LA_BA, 5).                                %% 拉霸
-define(SCENE_TIME_EVENT_TYPE_GOLD_MONSTER, 6).                         %% 金币小妖
-define(SCENE_TIME_EVENT_TYPE_FUNCTION_MONSTER, 7).                     %% 功能怪
-define(SCENE_TIME_EVENT_TYPE_LONG, 8).                                 %% 神龙
-define(SCENE_TIME_EVENT_TYPE_TASK, 9).                                 %% 场景任务
-define(SCENE_TIME_EVENT_TYPE_LUCK_BALLS, 10).                          %% 彩球
-define(SCENE_TIME_EVENT_TYPE_START_NEW_LOOP, 100).                     %% 开始新的循环

%% 复活类型
-define(REBIRTH_TYPE_PLACE, place).     %% 原地复活
-define(REBIRTH_TYPE_RANDOM, random).   %% 随机点复活

-define(DICT_OBJ_SCENE_ITEM_ID, dict_scene_item_id).                    %% 场景物品唯一id
-define(DICT_SCENE_CREATE_TIME, dict_scene_create_time).                %% 场景创建时间
-define(DICT_MAP_ID, dict_map_id).                                      %% 地图id
%%-define(DICT_SCENE_SAFE_TYPE, dict_scene_safe_type).                    %% 场景安全类型
-define(DICT_MISSION_ID, dict_mission_id).                              %% 副本id
-define(DICT_MISSION_TYPE, dict_mission_type).                          %% 副本类型
-define(DICT_ACTIVITY_ID, dict_activity_id).                            %% 活动id
-define(DICT_ACTIVITY_START_TIME, dict_activity_start_time).            %% 活动开始时间
-define(DICT_ACTIVITY_CLOSE_TIME, dict_activity_close_time).            %% 活动关闭时间
-define(DICT_MISSION_KIND, dict_mission_kind).                          %% 副本类别
-define(DICT_IS_MISSION, dict_is_mission).                              %% 是否副本
-define(DICT_IS_HOOK_SCENE, dict_is_hook_scene).                        %% 是否挂机场景
-define(DICT_OBJ_MONSTER_ID, dict_obj_monster_id).                      %% 怪物对象唯一id
-define(DICT_CAN_ACTION_TIME, dict_can_action_time).                    %% 可以动作时间
-define(DICT_IS_CAN_ACTION, dict_is_can_actin).                         %% 是否可动作
-define(DICT_MAX_PLAYER_NUM, dict_max_player_num).                      %% 最大玩家数量
-define(DICT_EXTRA_DATA, dict_extra_data).                              %% 场景额外数据
-define(DICT_MONSTER_IS_CAN_JUMP, dict_monster_is_can_jump).            %% 怪物是否可以跳
-define(DICT_SCENE_ID, dict_scene_id).                                  %% 场景id
-define(DICT_SCENE_COST_PROP_ID, dict_scene_cost_prop_id).              %% 场景消耗道具id
-define(DICT_SCENE_AWARD_PROP_ID, dict_scene_award_prop_id).            %% 场景奖励道具id
-define(DICT_SCENE_IS_SERVER_CONTROL_SCENE, dict_is_server_control_scene). %% 是否该场景服务器控制玩家
-define(DICT_SCENE_TYPE, dict_scene_type).                              %% 场景类型
-define(DICT_OBJ_SCENE_ITEM, dict_obj_scene_item).                      %% 场景怪物
-define(DICT_MONSTER_NEXT_HEART_BEAT_TIME, dict_monster_enxt_heart_beat_time). %% 下次心跳时间
-define(DICT_NOW_MS, dict_now).                                         %% 当前时间(ms)
-define(DICT_FIGHT_INIT_SKILL_ID, dict_fight_init_skill_id).            %% 初始战斗技能id
-define(DICT_FIGHT_SKILL_ID, dict_fight_skill_id).                      %% 战斗技能id
-define(DICT_FIGHT_BALANCE_ROUND, dict_fight_balance_round).            %% 当前结算回合
-define(DICT_IS_FIGHT, dict_is_fight).                                  %% 是否战斗中
-define(DICT_FIGHT_KILL_MONSTER_LIST, dict_fight_kill_monster_list).    %% 战斗击杀的怪物列表
%%-define(DICT_IS_JUDGE_CRIT, dict_is_judge_crit).                        %% 是否判断暴击
-define(DICT_RESULT_HURT, dict_result_hurt).                            %% 最终伤害
%%-define(DICT_RESULT_SHOW_HURT, dict_result_show_hurt).                        %% 最终显示伤害

%%-define(DICT_LAST_ENTER_PLAYER_ID, dict_last_enter_player_id).          %% 最近进入场景的玩家id
%%-define(DICT_LAST_PLAYER_ENTER_TIME, dict_last_player_enter_time).      %% 最近玩家进入场景的时间
-define(DICT_REBIRTH_WINDOWS, dict_rebirth_windows).                      %% 复活窗口
-define(DICT_KILL_DIE_LAST, dict_kill_die_last).                        %% 最后一杀死的
-define(DICT_CACHE_OBJ_SCENE_PLAYER, dict_cache_obj_scene_player).      %% 玩家缓存
-define(DICT_SCENE_BELONG_LINK, dict_scene_belong_link).                %% 归属玩家关联
-define(DICT_OBJ_SCENE_ACTOR, dict_scene_actor).
-define(DICT_SCENE_GRID, dict_scene_grid).
-define(DICT_SCENE_PLAYER_FUNCTION_EFFECT_LIST, dict_scene_player_function_effect_list).    %% 玩家功能怪效果列表

-define(DICT_SCENE_MONSTER_REBIRTH_REF, monster_rebirth_ref).           %% boss 复活定时器
-define(DICT_SCENE_FIGHT_TYPE, dict_scene_fight_type).                  %% 场景战斗类型

%% 获取场景格子
-define(GET_SCENE_GRID(GridId), get({?DICT_SCENE_GRID, GridId})).
%% 更新场景格子
-define(UPDATE_SCENE_GRID(SceneGrid), put({?DICT_SCENE_GRID, SceneGrid#dict_scene_grid.id}, SceneGrid)).

%% 获取场景对象
-define(GET_OBJ_SCENE_ACTOR(ObjType, ObjId), get({?DICT_OBJ_SCENE_ACTOR, {ObjType, ObjId}})).
%% 更新场景对象
-define(UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor), put({?DICT_OBJ_SCENE_ACTOR, ObjSceneActor#obj_scene_actor.key}, ObjSceneActor)).

%% 获取场景玩家对象
-define(GET_OBJ_SCENE_PLAYER(ObjId), ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_PLAYER, ObjId)).
%% 更新场景玩家对象
-define(UPDATE_OBJ_SCENE_PLAYER(ObjSceneActor), ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor)).

%% 获取场景怪物对象
-define(GET_OBJ_SCENE_MONSTER(ObjId), ?GET_OBJ_SCENE_ACTOR(?OBJ_TYPE_MONSTER, ObjId)).
%% 更新场景怪物对象
-define(UPDATE_OBJ_SCENE_MONSTER(ObjSceneActor), ?UPDATE_OBJ_SCENE_ACTOR(ObjSceneActor)).

%%-define(SERVER_CONTROL_SCENE_LIST, [9999, 12001]).

%% 机器人不创建的  被动技能列表
-define(ROBOT_IGNORE_PASSIVE_SKILL_ID_LIST, [1203, 1204, 2204]).

%% 场景内下注玩家列表
-define(MISSION_BET_PLAYER_LIST, bet_player_id_list).
-define(MISSION_BET_PLAYER_LEAVE_LIST, bet_leave_player_id_list).

%% 怪物AI事件 在巡逻时主动发现玩家并发起攻击后抛开的那个怪，现在还不知道叫什么名字 2021-07-29
-define(SCENE_MONSTER_ATTACK_PLAYER, scene_monster_attack_player).