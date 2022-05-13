%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 9月 2021 下午 03:08:26
%%%-------------------------------------------------------------------
-author("Administrator").

-record(state, {
    status = true,
    robot_workers = [],
    last_create_role_time = 0,
    buff = <<>>,
    recv_count = 0,
    error_count = 0
}).

-define(ROBOT_DICT_OBJ_ROBOT, robot_dict_obj_robot).
-record(robot, {
    %% ROBOT_ATTR
    player_id = 0 :: integer(),                                             %% 玩家id
    level = 1 :: integer(),                                                 %% 玩家等级
    vip_level = 0 :: integer(),                                             %% VIP_LEVEL
    skill_list = [] :: list(),                                              %% 技能列表
%%    common_skill_list = [] :: list(),                                       %% 普攻列表
    pk_mode = 0 :: integer(),                                               %% pk模式
    sex = 0 :: integer(),                                                   %% 性别
    next_can_heart_beat_time = 0 :: integer(),                              %% 下一次心跳时间
    last_heart_time = 0 :: integer(),                                       %% 上一次心跳时间
    prop_list = [] :: list(),                                               %% 道具列表
    %% SCENE_DATA
    scene_id = 0 :: integer(),                                              %% 场景id
    map_id = 0 :: integer(),                                                %% 当前地图id
    move_path = [] :: list(),                                               %% 移动路径
    speed = 1300 :: integer(),                                              %% 移动速度
    buff_list = [] :: list(),                                               %% buff列表
    x = 0 :: integer(),
    y = 0 :: integer(),
    go_x = 0 :: integer(),                                                  %%
    go_y = 0 :: integer(),                                                  %%
    anger = 0 :: integer(),                                                 %% 怒气
    dizzy_close_time = 0 :: integer(),                                      %% 眩晕时间
    kuangbao_time = 0 :: integer(),                                         %% 狂暴时间
    last_move_time = 0 :: integer(),                                        %% 上次移动时间
    last_fight_time = 0 :: integer(),                                       %% 上次战斗时间
    last_fight_skill_id = 0 :: integer(),                                   %% 上次战斗技能id
    force_wait_time = 0 :: integer(),                                       %% 硬直时间
    target_obj_type = 0 :: integer(),                                       %% 目标对象类型
    target_obj_id = 0 :: integer()                                          %% 目标对象id
}).

-define(ROBOT_HEART_BEAT_TIME, 1000).                                       %% 机器人战斗心跳时间

%% @doc DICT
-define(ROBOT_DICT_ACC_ID, robot_dict_acc_id).                              %% 账号id
-define(ROBOT_DICT_SEQ, robot_dict_seq).                                    %% 请求
-define(ROBOT_DICT_NEXT_HEART_BEAT, robot_dict_next_heart_beat).            %% 下一次心跳时间
-define(ROBOT_DICT_IS_START, robot_dict_is_start).                          %%
-define(ROBOT_DICT_TOUCH_DISTANCE, robot_dict_touch_distance).              %%
-define(ROBOT_DICT_LAST_FIGHT_TIME, robot_dict_last_fight_time).            %%
-define(ROBOT_DICT_CLIENT_WORKER, robot_dict_client_worker).                %%
-define(ROBOT_DICT_IS_REQUEST_ENTER_SCENE, robot_dict_is_request_enter_scene).%%
-define(ROBOT_DICT_MOVE_TYPE, robot_dict_move_type).                        %%

%% @doc SCENE_ACTOR
-define(ROBOT_DICT_SCENE_PLAYER_TABLE, robot_dict_scene_player_table).      %% 场景玩家对象表
-record(scene_player, {
    id,
    x = 0,
    y = 0,
    hp = 1,
    move_path = [],
    speed = 0,
    last_move_time = 0,
    force_wait_time = 0                                                     %% 硬直时间
}).
-define(ROBOT_DICT_SCENE_MONSTER_TABLE, robot_dict_scene_monster_table).    %% 场景怪物对象表
-record(scene_monster, {
    id,
    monster_id,
    is_boss = false,
    x = 0,
    y = 0,
%%    go_x,
%%    go_y,
    hp = 1,
    move_path = [],
    speed = 0,
    last_move_time = 0,
    force_wait_time = 0                                                     %% 硬直时间
}).
-define(ROBOT_DICT_SCENE_ITEM_TABLE, robot_dict_scene_item_table).          %% 场景物品对象表
-record(scene_item, {
    id,
    base_id,
    x = 0,
    y = 0,
    scene_monster_id = 0,
    owner_player_id = 0
}).