%%% Generated automatically, no need to modify.
%% vip_levelVIP等级特权表
-record(t_vip_level, {
    row_key,
    level = 0,                                 %% VIP等级
    exp = 0,                                   %% 升级经验
    item_list = [],                            %% 道具id
    ui_off_list = [],                          %% 页面资源偏移量 [x,y,缩放]不用了
    is_show = 0,                               %% 客户端是否显示（1代表到需要到达上一等级才能看到
    icon_list = [],                            %% icon列表\assets\icon\vip
    desc = [],                                 %% 特权详情
    vip_up_icon_list = [],                     %% icon列表\assets\icon\vip
    vip_up_desc = [],                          %% 特权详情
    seven_login_vip_rate = 0,                  %% 七天登陆（奖励倍率万分比）【*基本奖金】
    seven_login_vip_coin_count = 0,            %% 七天登陆vip固定金币数
    exp_add_per = 0,                           %% 经验加成（万分比）
    name_color = 0,                            %% 玩家名字颜色（配色值color表）
    giveaway_fee = 0                           %% 赠送交易手续费（万分比）
}).
-record(key_t_vip_level, {
    level                                      %% VIP等级
}).

%% vip_boon_typeVIP特权类型表
-record(t_vip_boon_type, {
    row_key,
    id = 0,                                    %% 编号id
    name = [],                                 %% 名字
    sign = [],                                 %% 标识
    desc = [],                                 %% 备注
    is_tequan = 0,                             %% 是否特权
    rank = 0                                   %% 排序（从小到大）
}).
-record(key_t_vip_boon_type, {
    id                                         %% 编号id
}).

%% vip_boonVIP特权表
-record(t_vip_boon, {
    row_key,
    type = 0,                                  %% VIP福利类型
    level = 0,                                 %% vip等级
    name = [],                                 %% 名字
    value = 0,                                 %% 值
    show_value = 0,                            %% 显示值 0不显示
    symbol_before = [],                        %% 值的前缀
    sybol_down = [],                           %% 值的后缀
    desc = []                                  %% 备注
}).
-record(key_t_vip_boon, {
    type,                                      %% VIP福利类型
    level                                      %% vip等级
}).

%% turntable转盘抽奖
-record(t_turntable, {
    row_key,
    id = 0,                                    %% 位置id
    award_list = [],                           %% 奖励
    weights = 0                                %% 权重
}).
-record(key_t_turntable, {
    id                                         %% 位置id
}).

%% treasure_hunt_type寻宝类型表
-record(t_treasure_hunt_type, {
    row_key,
    id = 0,                                    %% 类型id（读静态表
    cost_list = [],                            %% 消耗[[抽奖次数，id,数量]…]
    luck_list = [],                            %% 幸运值值列表[每次抽增加祝福值,祝福值总值,满祝福值必定抽中对应奖励id]
    shop_type = 0,                             %% 兑换商店的商店类型
    achievement_list = []                      %% 成就列表[[抽奖次数,[奖励列表]],…]
}).
-record(key_t_treasure_hunt_type, {
    id                                         %% 类型id（读静态表
}).

%% treasure_hunt寻宝
-record(t_treasure_hunt, {
    row_key,
    type_id = 0,                               %% 类型id
    id = 0,                                    %% 奖励id
    award_list = [],                           %% 奖励内容
    weights = 0,                               %% 权重
    need_luck = 0                              %% 随到所需幸运值
}).
-record(key_t_treasure_hunt, {
    type_id,                                   %% 类型id
    id                                         %% 奖励id
}).

%% tou_zi_ji_hua  投资计划表
-record(t_tou_zi_ji_hua, {
    row_key,
    type_id = 0,                               %% 类型ID
    id = 0,                                    %% id
    is_condition = 0,                          %% 是否是购买后计入条件[0：不购买就开始计入  1：购买后才计入条件]
    condition_list = [],                       %% 条件列表
    reward_list = []                           %% 奖励列表
}).
-record(key_t_tou_zi_ji_hua, {
    type_id,                                   %% 类型ID
    id                                         %% id
}).

%% 月度任务
-record(t_tongxingzheng_task, {
    row_key,
    id = 0,                                    %% 月度任务id
    day = 0,                                   %% 解锁天数
    type = 0,                                  %% 月度任务类型
    is_need_buy = 0,                           %% 是否需要购买钻石通行证（1是
    condition_list = [],                       %% 条件枚举
    reward_list = []                           %% 完成任务奖励
}).
-record(key_t_tongxingzheng_task, {
    id                                         %% 月度任务id
}).

%% 通行证等级
-record(t_tongxingzheng_level, {
    row_key,
    id = 0,                                    %% 通行证id
    level = 0,                                 %% 等级
    need_exp = 0,                              %% 升到下一级所需经验（0为满级）
    reward1_list = [],                         %% 白银通行证奖励
    reward2_list = [],                         %% 钻石通行证奖励
    show_rare1 = 0,                            %% 白银通行证是否稀有
    show_rare2 = 0                             %% 钻石通行证奖励是否稀有
}).
-record(key_t_tongxingzheng_level, {
    id,                                        %% 通行证id
    level                                      %% 等级
}).

%% 通行证日常任务
-record(t_tongxingzheng_daily_task, {
    row_key,
    id = 0,                                    %% 日常任务id
    condition_list = [],                       %% 条件枚举
    reward_list = [],                          %% 完成任务奖励
    weights = 0                                %% 权重
}).
-record(key_t_tongxingzheng_daily_task, {
    id                                         %% 日常任务id
}).

%% 通行证
-record(t_tongxingzheng, {
    row_key,
    id = 0,                                    %% 通行证id
    buy1_list = [],                            %% 普通购买所需物品列表
    buy2_list = [],                            %% 高级购买所需物品列表
    buy2_add_level = 0,                        %% 高级购买提升等级
    buy_level_list = [],                       %% 购买等级所需物品列表
    time_list = [],                            %% [[开始年,开始月,开始日（默认0点0分0秒）],[结束年,结束月,结束日（默认24点0分0秒）]]
    max_level_exp = 0,                         %% 满级之后经验
    task_type = 0,                             %% 月度任务类型
    max_level_item_list = []                   %% 满级可领取的宝箱
}).
-record(key_t_tongxingzheng, {
    id                                         %% 通行证id
}).

%% 次数表
-record(t_times, {
    row_key,
    id = 0,                                    %% id
    sign = [],                                 %% 标识
    name = [],                                 %% 名称
    function_id = 0,                           %% 关联功能id, 功能开启才有数据
    log_type = 0,                              %% 日志类型
    is_notice = 1,                             %% 是否通知前端
    free_times = 0,                            %% 免费次数
    reset_type = 0,                            %% 重置免费次数类型[0:不重置 1:每日0点重置 2:每周一0点重置]
    recover_interval_time = 0,                 %% 恢复一次免费次数的时间(s)[0:不恢复]
    buy_times_limit = 0,                       %% 每日购买次数限制[0:无限制，配其他数字就是可以购买多少次]
    vip_init_add_id = 0,                       %% vip权限每日免费次数加成(关联vip_boon_type.csv)
    vip_max_add_id = 0,                        %% vip权限每日最大购买次数加成(关联vip_boon_type.csv)
    is_can_buy = 0,                            %% 是否可以购买次数
    buy_times_type = 0,                        %% 购买次数类型（0=购买次数，1=购买次数后自动消耗）
    buy_prop_list = []                         %% 购买消耗道具[区间上限，区间下限，道具id，数量]
}).
-record(key_t_times, {
    id                                         %% id
}).

%% task任务表
-record(t_task, {
    row_key,
    id = 0,                                    %% 任务id
    next_task = 0,                             %% 下个任务id
    open_main_funcid = 0,                      %% 对话完成，是否非主城场景回到主城激活建筑(不能是最后一个任务）
    content_list = [],                         %% 任务内容条件[key,value]
    title = [],                                %% 标题
    icon = 0,                                  %% resource\assets\icon\task
    init_type = 1,                             %% 初始化类型(0:读取玩家当前值,1:从0开始)
    award_id = 0,                              %% 奖励id（读取reward表）
    reward_dialog = 0,                         %% 领取任务奖励触发对话
    click_guide_id = 0,                        %% 点击前往任务启动引导
    is_auto_finish = 0,                        %% 是否系统自动完成任务
    jump_scene_list = [],                      %% 完成任务跳转场景[scene_id, x, y] | [scene_id]
    auto_scene_id = 0                          %% 挂机地图
}).
-record(key_t_task, {
    id                                         %% 任务id
}).

%% 公共系统
-record(t_sys_common, {
    row_key,
    id = 0,                                    %% ID(与item_id一致)
    func_id = 0,                               %% 功能ID
    pram_list = [],                            %% 功能属性【闪避5，暴击6】不叠加取当前装备
    effect_list = []                           %% 其他数据效果
}).
-record(key_t_sys_common, {
    id                                         %% ID(与item_id一致)
}).

%% 通用静态配置表
-record(t_static_data, {
    row_key,
    sign = [],                                 %% 标识
    name = [],                                 %% 功能说明(表格的说明)
    data = []                                  %% 数据
}).
-record(key_t_static_data, {
    sign                                       %% 标识
}).

%% 声音表
-record(t_sound, {
    row_key,
    id = 0,                                    %% 音效ID
    desc = [],                                 %% 备注
    sign = [],                                 %% 标识
    sound_type = 0,                            %% 音效类型（1为背景音乐 2为游戏音效 3英雄配音）
    sound_name = [],                           %% 音效名字
    sound_value = 0,                           %% 音效大小
    sound_value_other = 0,                     %% 听其他人音效大小百分比
    sound_value_time = 0                       %% 同一个对象播放同一音效硬直时间(毫秒)
}).
-record(key_t_sound, {
    id                                         %% 音效ID
}).

%% skill_slot技能槽位表
-record(t_skill_slot, {
    row_key,
    id = 0,                                    %% 槽位id
    skill_slot_type = 0,                       %% 技能槽类型:1=普通技能槽；2=心法技能槽；3=神兵技能槽
    open_list = [],                            %% 开启条件:[条件类型，条件参数]
    type = 0                                   %% 技能类型  1主角主动技能 8法宝技能 9神兵技能 10心法技能
}).
-record(key_t_skill_slot, {
    id                                         %% 槽位id
}).

%% skill_charge
-record(t_skill_charge, {
    row_key,
    id = 0,                                    %% 充能
    sign = [],                                 %% 标识
    desc = [],                                 %% 描述
    charge_time = 0,                           %% 回复时间ms
    charge_cd_time = 0,                        %% 使用间隔时间ms
    times = 0,                                 %% 最大累计次数
    inti_times = 0,                            %% 进场景初始次数
    parameter_desc = [],                       %% 参数描述
    parameter_list = []                        %% 参数列表
}).
-record(key_t_skill_charge, {
    id                                         %% 充能
}).

%% skill_balance_grid技能格子表
-record(t_skill_balance_grid, {
    row_key,
    id = 0,                                    %% id
    name = [],                                 %% 名字
    grid_list = []                             %% 格子列表
}).
-record(key_t_skill_balance_grid, {
    id                                         %% id
}).

%% 技能组件表
-record(t_skill_assembly, {
    row_key,
    id = 0,                                    %% 组件标识ID
    skillcellindex = 0,                        %% 程序用，顺序加即可
    note = [],                                 %% 中文说明
    skillcellid = 0,                           %% 使用的法术组件id
    refertoposition = 0,                       %% 【0】表示自身脚底，【1】表示目标位置【2】表示屏幕中心【3】表示玩家施法点
    settlementandviewoffsetx = 0,              %% 【0】表示不偏移【正整数】表示向前进行方向偏移【负整数】表示向后退方向偏移
    settlementandviewoffsety = 0,              %% 【0】表示不偏移【正整数】表示向上偏移【负整数】表示向下偏移
    viewoffseth = 0,                           %% 高度偏移
    directionpos = 0,                          %% 根据角色方向控制位置 0不控制 1控制
    directionrotation = 0,                     %% 根据角色方向控制角度 0不控制 1控制
    directiontype = 0,                         %% （0：基准为屏幕，1：基准为玩家 面朝的方向 左右  2：角色施法方向为基准 3：基准为玩家的面朝的方向 8方向 控制X  Y位置，4：基准为玩家的面朝的方向 8方向 控制X  Y位置 与角度)
    direction = 0,                             %% 特效朝向，顺时针旋转。当特效朝向类型为0时，0为原图方向；当特效朝向类型为1时，0为角色面朝方向
    flydistance = 0,                           %% 飞行距离
    playtimes = 0,                             %% 部件播放【0】表示时间循环【正整数】表示播放次数控制
    startshowtime = 0,                         %% 出现时间
    livespan = 0,                              %% 存在时间
    settlement = 0,                            %% 【-1】表示不结算，【0】表示碰撞结算，【正整数】表示帧结算
    alphastartshowtime = 0,                    %% alpha出现
    alphadisappeartime = 0,                    %% alpha消失
    sounddelay = 0,                            %% 声音播放延(单位：毫秒)迟 -1不播放  0立即播放
    shadow = [],                               %% 延时|残影帧数|残影持续时间|是否是玩家残影  1是（玩家残影）  0不是（元件残影）
    transform = [],                            %% 组件变换
    hideplayer = 0,                            %% 隐藏主角
    playaction = [],                           %% 施法者播放动作
    playermove = []                            %% 施法者移动  距离|时间|跳跃高度   -1不做处理
}).
-record(key_t_skill_assembly, {
    id                                         %% 组件标识ID
}).

%% 技能表
-record(t_skill, {
    row_key,
    id = 0,                                    %% 技能ID
    name = [],                                 %% 技能名
    forcestorageid = 0,                        %% 蓄力ID（只看这个）
    forcestorageround = 0,                     %% 技能蓄力回合（每回合0.5秒，每个技能持续多少回合需要配置）
    shootid = 0,                               %% 发射ID（只看这个）
    flyid = 0,                                 %% 飞行ID
    hitid = 0                                  %% 命中ID
}).
-record(key_t_skill, {
    id                                         %% 技能ID
}).

%% shop_type商店类型表
-record(t_shop_type, {
    row_key,
    id = 0,                                    %% 商店类型id
    sign = [],                                 %% 标识
    name = [],                                 %% 名字
    activity_id = 0,                           %% 活动id
    fun_id = 0,                                %% 判断功能id：0为不判断(function_id)
    log_type = 0,                              %% 日志类型
    times_id = 0                               %% 次数id
}).
-record(key_t_shop_type, {
    id                                         %% 商店类型id
}).

%% shop商店表
-record(t_shop, {
    row_key,
    id = 0,                                    %% 编号id
    type = 0,                                  %% 商店类型(1=道具商城，2=资源商城)
    item_icon = 0,                             %% 商店道具图片[配空用道具icon，配置ID读取独立icon  resource\assets\icon\shop\]
    item_list = [],                            %% 物品id
    buy_item_list = [],                        %% 购买价格
    original_price_list = [],                  %% 原价
    discount = [],                             %% 折扣
    limit_type = 0,                            %% 限购类型（0=不限购；1=1天；2=1周；3=活动时间;-1=终生限购，不填则默认不限购）
    limit = 0,                                 %% 限购数量
    buy_limit_list = [],                       %% 购买限制[枚举ID标识，参数]（参照conditions_enum表，例：VIP等级=vip_level）
    gift_name = [],                            %% 礼包名字
    order_id = 0,                              %% 排序id
    condition_list = []                        %% 任务内容[任务类型,任务对象id,目标数]
}).
-record(key_t_shop, {
    id                                         %% 编号id
}).

%% share_task_type 分享有礼任务类型表
-record(t_share_task_type, {
    row_key,
    task_type = 0,                             %% 任务类型id
    type = 1,                                  %% 任务类型（对应share_type表类型）
    sign = [],                                 %% 标识
    name = [],                                 %% 活动名称
    approach_list = [],                        %% 触发条件
    is_share = 0,                              %% 是否邀请任务
    show_type = 0,                             %% 显示类型
    desc = [],                                 %% 备注
    activity_id = 0                            %% 活动id
}).
-record(key_t_share_task_type, {
    task_type                                  %% 任务类型id
}).

%% share_task  分享有礼任务表
-record(t_share_task, {
    row_key,
    task_type_id = 0,                          %% 任务类型id
    id = 0,                                    %% 编号id
    need_num = 0,                              %% 需要数量
    item_list = [],                            %% 物品
    order = 0                                  %% 排序
}).
-record(key_t_share_task, {
    task_type_id,                              %% 任务类型id
    id                                         %% 编号id
}).

%% 七天登录服务端拉霸表
-record(t_seven_login_laba, {
    row_key,
    today = 0,                                 %% 天数
    id = 0,                                    %% id
    dice_list = [],                            %% 登录奖励
    weights = 0                                %% 权重
}).
-record(key_t_seven_login_laba, {
    today,                                     %% 天数
    id                                         %% id
}).

%% seven_login七天登录
-record(t_seven_login, {
    row_key,
    today = 0,                                 %% 第几天
    award_list = [],                           %% 登录奖励
    continue_award_count = 0                   %% 连续登陆奖励金币数
}).
-record(key_t_seven_login, {
    today                                      %% 第几天
}).

%% service_log
-record(t_service_log, {
    row_key,
    id = 0,                                    %% 枚举ID
    sign = [],                                 %% 标识
    name = []                                  %% 名称
}).
-record(key_t_service_log, {
    id                                         %% 枚举ID
}).

%% scene_type场景类型表
-record(t_scene_type, {
    row_key,
    id = 0,                                    %% ID
    name = [],                                 %% 名称
    sign = []                                  %% 标识
}).
-record(key_t_scene_type, {
    id                                         %% ID
}).

%% scene.csv 场景表
-record(t_scene, {
    row_key,
    id = 0,                                    %% 场景ID
    name = [],                                 %% 名称
    battle_type = 0,                           %% 战斗类型：0：概率 1血条
    function_monster_list = [],                %% [组别id,[功能怪id列表],[坐标组别列表]
    function_monster_time_list = [],           %% 场景建立功能怪时间列表ms
    function_monster_param_list = [],          %% 功能怪参数列表【击杀功能怪刷新时间下限ms,上限ms,消失刷怪数量,功能怪消失刷新时间下限ms,上限ms】
    mana_enter_list = [],                      %% 进入场景灵力值范围[1,0] 0表示无限
    mana_attack_list = [],                     %% 每次攻击消耗的倍率
    enter_conditions_list = [],                %% 进入条件
    yuchao_list = [],                          %% 鱼潮列表[时间（ms）,怪物id,怪物数量，清除怪物id]
    time_list = [],                            %% 时间[间隔时间ms,[类型id,持续时间,[参数],权重]   【 1：鱼潮（鱼潮存在时间ms）  2：刷BOSS（参数：[bossid]） 3：宝箱怪（怪物id） 4：转盘（） 5拉霸（） 6金币小妖（怪物id,出生组别) 7功能怪 8神龙祝福 9任务触发（任务类型） 10彩球（数量,倍率）】空列表为无，
    boss_x_y_list = [],                        %% BOSS_x_y_列表
    new_monster_x_y_list = [],                 %% 新怪物出生点坐标list[组别,数量下限,数量上限[坐标列表]]
    monster_count = 0,                         %% 场景怪物数量
    boss_time_monster_count = 0,               %% BOSS期间场景怪物数量
    monster_born_list = [],                    %% 怪物出生判断[[怪物id,权重,数量下限,数量上限]..]当怪物数量低于下限,直接判断是该怪物当怪物数量大于等于上限，剔除权重
    boss_time_monster_born_list = [],          %% BOSS期间怪物出生判断[[怪物id,权重,数量下限,数量上限]..]当怪物数量低于下限,直接判断是该怪物当怪物数量大于等于上限，剔除权重
    type = 1,                                  %% 场景类型[1:世界地图 2:副本 3:匹配场]
    is_valid = 0,                              %% 是否生效
    is_can_change_pk_mode = 1,                 %% 是否可以改变PK模式
    force_change_pk_mode = -1,                 %% 进入场景自动切换模式(>= 0有效)pk_mode.csv
    is_server_control_player = 0,              %% 是否服务端控制玩家
    mission_type = 0,                          %% 副本类型
    is_hook = 0,                               %% 是否挂机场景
    notice_list = [],                          %% 击杀获得奖励的提示列表[提示id,[[物品id,下限数量]…]
    is_all_scene_sync = 0,                     %% 是否全场景同步(副本有效)
    server_type = 1,                           %% 服务器类型[1:本服 2:跨服 7:战区服]
    is_force_no_shield_player = 0,             %% 是否强制不屏蔽场景玩家 [0:false 1:true]
    map_id = 0,                                %% 地图资源id
    height = 0,                                %% 高度
    width = 0,                                 %% 宽度
    birth_x = 0,                               %% 出生点x
    birth_y = 0,                               %% 出生点y
    random_birth_list = [],                    %% 随机出生点列表[{x, y}，{x, y}]
    max_player = 1,                            %% 最大玩家数量
    is_rember_line = 0,                        %% 是否记住分线
    sound = 0,                                 %% 场景BGM列表
    is_can_team = 0,                           %% 是否可组队 [0:false 1:true]
    gold_monster_move_list = [],               %% 金币小妖行动路线
    monster_x_y_list = []                      %% 怪物出生随机坐标list[x，y]
}).
-record(key_t_scene, {
    id                                         %% 场景ID
}).

%% role_experience主角升级表
-record(t_role_experience, {
    row_key,
    level = 0,                                 %% 等级
    next_level = 0,                            %% 下一等级
    experience = 0,                            %% 升级经验
    tittle = [],                               %% 称号
    reward = 0,                                %% 升级奖励【5升6取6】
    att = 0,                                   %% 伤害修正（万分比）【怪物死亡概率乘这个修正】（没用了）
    diamond_xiuzheng_list = [],                %% [掉落钻石下限,掉落钻石上限,修正万分比]
    newbee_xiuzheng_list = [],                 %% 新手修正列表[[剧本id,修正值]…]（必定0-4一共5套剧本）
    world_three = 0                            %% 世界树加成（万分比）
}).
-record(key_t_role_experience, {
    level                                      %% 等级
}).

%% robot 机器人表
-record(t_robot, {
    row_key,
    id = 0,                                    %% 机器人id
    scene = 0,                                 %% 场景id
    weights = 0,                               %% 权重
    vip_level = 0,                             %% vip等级
    level_list = [],                           %% 等级列表[[等级下限,等级上限,权重]
    cost_list = [],                            %% 消耗列表[[id,数量,权重],]
    item_list = [],                            %% 初始拥有列表[[物品id,下限,上限]
    hero_list = [],                            %% [[英雄id,武器部件,背饰部件,大招,权重]填0没有
    head_list = [],                            %% 头像[[id,权重]
    head_frame_list = [],                      %% 头像框[[id,权重]
    leave_list = []                            %% 离开列表[[物品id,下限,上限,离开时间下限秒,离开时间上限秒],
}).
-record(key_t_robot, {
    id                                         %% 机器人id
}).

%% reward,csv奖励表
-record(t_reward, {
    row_key,
    id = 0,                                    %% 奖励ID
    random_reward_list = [],                   %% 非权重奖励：【奖励类型对应物品ID】,【奖励数量】,【奖励概率（万分比）】；例如：[500,500,5000]
    weights_reward_list = []                   %% 权重奖励：[[【是否触发权重奖励概率万分比】],[【随机的数量下限】,【随机的数量上限】],是否去重（0/1）,[[【奖励类型对应物品ID】,【奖励数量】,【权重】],[【奖励类型对应物品ID】,【奖励数量】,【权重】…]]]支持多组
}).
-record(key_t_reward, {
    id                                         %% 奖励ID
}).

%% 红包表
-record(t_red_package, {
    row_key,
    id = 0,                                    %% id
    type = 0,                                  %% 档位(999特殊档位给boss用只发给个人)
    reward_list = [],                          %% 奖励
    speed = 0                                  %% 移动速度
}).
-record(key_t_red_package, {
    id                                         %% id
}).

%% 红包条件表
-record(t_red_condition, {
    row_key,
    id = 0,                                    %% id
    decs = [],                                 %% 描述
    content = [],                              %% 红包描述内容
    content_list = [],                         %% 红包内容条件【conditions_enum.csv】
    type = 0,                                  %% 档位【红包表type】
    is_individual = 0,                         %% 是否单人条件【0：单人  1：本服累计】
    red_number_list = [],                      %% 红包数量范围值
    red_time = 0                               %% 每个红包存在时间【秒】
}).
-record(key_t_red_condition, {
    id                                         %% id
}).

%% recharge 充值商品信息
-record(t_recharge, {
    row_key,
    id = 0,                                    %% 商品ID
    name = [],                                 %% 名称
    sign = [],                                 %% 标识
    icon_id = 0,                               %% 图标ID
    type = 0,                                  %% 支付类型[0,第三方 1,谷歌支付 2,苹果支付]
    client_log = 0,                            %% 客户端日志
    have_pf_list = [],                         %% 存在平台的列表
    remove_pf_list = [],                       %% 不生效的平台列表
    remark = [],                               %% 配置备注
    cash = 0,                                  %% 充值金额（美元）
    price_cash = 0,                            %% 原价【客户端表现用】
    ingot = 0,                                 %% 金币
    diamond = 0,                               %% 钻石
    vip_exp = 0,                               %% VIP经验
    reward_item_list = [],                     %% 充值获得物品【物品id,物品数量】
    recharge_reward_list = [],                 %% 充值活动奖励【充值次数，倍数】
    buy_limit = 0,                             %% 限制购买次数
    recharge_type = 0,                         %% 充值类型（charge_game.csv）
    is_show = 1,                               %% 是否显示
    idx_ord = 1,                               %% 排序(客户端)
    notice_id = 0,                             %% 通知广播id
    goods_id = []                              %% 商品ID
}).
-record(key_t_recharge, {
    id                                         %% 商品ID
}).

%% quality 品质对应名称
-record(t_quality, {
    row_key,
    quality_id = 0,                            %% 品质id
    name = []                                  %% 品质名称
}).
-record(key_t_quality, {
    quality_id                                 %% 品质id
}).

%% popup_msg_type
-record(t_popup_msg_type, {
    row_key,
    id = 0,                                    %% id
    sign = [],                                 %% 标识
    name = [],                                 %% 提示文字
    desc = []                                  %% 功能说明
}).
-record(key_t_popup_msg_type, {
    id                                         %% id
}).

%% popup_msg
-record(t_popup_msg, {
    row_key,
    id = 0,                                    %% id
    sign = [],                                 %% 标识
    type = 0,                                  %% 类型，对应popup_msg_type表
    name = [],                                 %% 功能说明
    content = []                               %% 内容
}).
-record(key_t_popup_msg, {
    id                                         %% id
}).

%% platform_charge 品台第三方充值表
-record(t_platform_charge, {
    row_key,
    id = 0,                                    %% 唯一key
    sign = [],                                 %% 标识
    name = [],                                 %% 标识
    desc = []                                  %% 属性名称说明(用#分隔)
}).
-record(key_t_platform_charge, {
    id                                         %% 唯一key
}).

%% c
-record(t_platform, {
    row_key,
    id = [],                                   %% 平台id
    name = [],                                 %% 平台名称
    currency = [],                             %% undefined
    charge_list = [],                          %% 第三方支持方式
    region = []                                %% 国家地区名称
}).
-record(key_t_platform, {
    id                                         %% 平台id
}).

%% t_pk_mode
-record(t_pk_mode, {
    row_key,
    id = 0,                                    %% 模式ID
    title = [],                                %% 模式名称
    sign = [],                                 %% 标识
    desc = [],                                 %% 描述
    title_color = []                           %% 名称颜色
}).
-record(key_t_pk_mode, {
    id                                         %% 模式ID
}).

%% online_award  在线奖励
-record(t_online_award, {
    row_key,
    id = 0,                                    %% id
    award_list = [],                           %% 签到奖励
    time = 0                                   %% 登录开始计时，可领取时间(s)
}).
-record(key_t_online_award, {
    id                                         %% id
}).

%% npc表
-record(t_npc, {
    row_key,
    id = 0,                                    %% NPC ID
    sign = [],                                 %% 标识
    name = [],                                 %% 名称
    dialog_id = 0,                             %% 对话id
    avatar_id = 0,                             %% 外观资源id
    direction = 0,                             %% 朝向01234567 0为朝上顺时针
    function_config_id = 0,                    %% function_config表对应id
    title_url = [],                            %% npc 头顶连续帧路径 resource/assets/uiEffect/title/
    set_off_list = [],                         %% 场景相对偏移坐标[x,y]
    beizhu = []                                %% 备注
}).
-record(key_t_npc, {
    id                                         %% NPC ID
}).

%% notice
-record(t_notice, {
    row_key,
    id = 0,                                    %% 公告id
    type = [],                                 %% 公告类型
    sign = [],                                 %% 公告标识
    notice_type = 3,                           %% 广播的频道(3:系统频道4:弹窗频道5.场景分线提示)
    content = [],                              %% 内容
    main_content = [],                         %% 内容
    count = 1,                                 %% 播放次数
    remark = [],                               %% 备注
    is_show = 0                                %% 客户端显示位置【0,全部 显示1，上方跑马灯  2，显示在主城左下】
}).
-record(key_t_notice, {
    id                                         %% 公告id
}).

%% 怪物类型表
-record(t_monster_kind, {
    row_key,
    id = 0,                                    %% 怪物ID
    name = [],                                 %% 名称
    can_be_frozen = 0,                         %% 是否可被冰冻（0不可，1可）
    can_be_immediate_death = 0                 %% 是否能被功能怪直接击杀功能击杀（0不可，1可）
}).
-record(key_t_monster_kind, {
    id                                         %% 怪物ID
}).

%% monster_intellect怪物智力表
-record(t_monster_intellect, {
    row_key,
    level = 0,                                 %% 级别
    auto_move_p = 0,                           %% 随机移动概率(万分比)
    patrol_heart_beat = 0,                     %% 巡逻心跳(ms)
    trace_heart_beat = 0,                      %% 追踪心跳(ms)
    update_track_heart_beat = 0                %% 搜索目标心跳(ms)
}).
-record(key_t_monster_intellect, {
    level                                      %% 级别
}).

%% monster_info.csv 场景怪物图鉴
-record(t_monster_info, {
    row_key,
    scene_id = 0,                              %% 场景ID
    id = 0,                                    %% id
    type = 0,                                  %% 类型（1：boss 2：事件 3：特殊怪 4小怪）
    name = [],                                 %% 名称（美术图的用id去assets\icon\monsterInfo\name取）
    icon_id = 0,                               %% 图片id
    reward_per = [],                           %% 倍率范围
    quality = 0,                               %% 品质（名字的底）
    distinguish_yupe = 0,                      %% 小怪类型（1：赏金怪 2：大怪 3：中怪 4：小怪）
    desc = []                                  %% 描述
}).
-record(key_t_monster_info, {
    scene_id,                                  %% 场景ID
    id                                         %% id
}).

%% monster_function_zhuanpan转盘功能怪表格
-record(t_monster_function_zhuanpan, {
    row_key,
    zhuanpan_type = 0,                         %% 转盘类型
    id = 0,                                    %% 结果id
    reward_per = 0,                            %% 奖励倍率（万分比）
    reward_item_list = [],                     %% 固定奖励[物品id,物品数量]
    xiuzheng_weights_list = [],                %% 修正权重[80%期望权重,120%期望权重]
    notice_id = 0                              %% 广播id
}).
-record(key_t_monster_function_zhuanpan, {
    zhuanpan_type,                             %% 转盘类型
    id                                         %% 结果id
}).

%% monster_function_xiangzi箱子事件宝箱怪奖励
-record(t_monster_function_xiangzi, {
    row_key,
    xiangzi_type = 0,                          %% 箱子类型
    id = 0,                                    %% 结果id
    reward_per = 0,                            %% 奖励倍率（万分比）
    reward_item_list = [],                     %% 固定奖励[物品id,物品数量]
    notice_id = 0,                             %% 广播id
    xiuzheng_weights_list = []                 %% 修正权重[80%期望权重,120%期望权重]
}).
-record(key_t_monster_function_xiangzi, {
    xiangzi_type,                              %% 箱子类型
    id                                         %% 结果id
}).

%% monster_function_task_rand_list任务随机奖励表
-record(t_monster_function_task_rand_list, {
    row_key,
    task_type = 0,                             %% 类型
    id = 0,                                    %% 结果id
    reward_per = 0,                            %% 奖励倍率（万分比）
    reward_item_list = [],                     %% 固定奖励[物品id,物品数量]
    xiuzheng_weights_list = [],                %% 修正权重[80%期望权重,120%期望权重]
    notice_id = 0                              %% 广播id
}).
-record(key_t_monster_function_task_rand_list, {
    task_type,                                 %% 类型
    id                                         %% 结果id
}).

%% monster_function_task事件任务
-record(t_monster_function_task, {
    row_key,
    id = 0,                                    %% 事件类型
    task_list = [],                            %% 任务信息（怪物名称，怪物id，数量）
    text = [],                                 %% 任务内容（文本）
    weight = 0,                                %% 权重（只是随机的时候过滤用）
    player_limit_list = [],                    %% 生效人数限制（只是随机的时候过滤用）
    scene_id = 0,                              %% 场景id
    task_type = 0,                             %% 任务类型 （只是随机的时候过滤用）1摇钱树
    expend_list = [],                          %% 消耗列表[[场景id,随机奖励类型,道具类型,道具数量]…]
    reward = 0,                                %% 任务奖励
    task_time = 0,                             %% 任务限制时间
    awark_time = 0,                            %% 活动限时时间
    biankuang = 0                              %% 任务栏边框
}).
-record(key_t_monster_function_task, {
    id                                         %% 事件类型
}).

%% monster_function_shenlongzhufu神龙祝福表格
-record(t_monster_function_shenlongzhufu, {
    row_key,
    shenlongzhufu_type = 0,                    %% 神龙祝福类型
    id = 0,                                    %% 结果id
    reward_item_list = [],                     %% [物品id,物品数量]
    is_bless = 0,                              %% 是否为神龙祝福（1：是
    weights = 0,                               %% 权重
    notice = 0                                 %% 神龙祝福提示
}).
-record(key_t_monster_function_shenlongzhufu, {
    shenlongzhufu_type,                        %% 神龙祝福类型
    id                                         %% 结果id
}).

%% monster_function_laba拉霸功能怪表格
-record(t_monster_function_laba, {
    row_key,
    laba_type = 0,                             %% 拉霸类型
    id = 0,                                    %% 结果id
    reward_per = 0,                            %% 奖励倍率（万分比）
    reward_item_list = [],                     %% 固定奖励内容[物品id,物品数量]
    xiuzheng_weights_list = [],                %% 修正权重[80%期望权重,120%期望权重]
    notice_id = 0                              %% 广播id
}).
-record(key_t_monster_function_laba, {
    laba_type,                                 %% 拉霸类型
    id                                         %% 结果id
}).

%% monster_function_fanpai翻牌功能怪表格
-record(t_monster_function_fanpai, {
    row_key,
    fanpai_type = 0,                           %% 翻牌类型
    id = 0,                                    %% 结果id
    reward_per = 0,                            %% 奖励倍率（万分比）
    reward_item_list = [],                     %% 固定奖励内容[物品id,物品数量]
    notice_id = 0,                             %% 广播id
    xiuzheng_weights_list = []                 %% 修正权重[80%期望权重,120%期望权重]
}).
-record(key_t_monster_function_fanpai, {
    fanpai_type,                               %% 翻牌类型
    id                                         %% 结果id
}).

%% monster_effect.csv 怪物效果表
-record(t_monster_effect, {
    row_key,
    skill_id = 0,                              %% 技能id
    effect_id = 0,                             %% 效果id
    sign = [],                                 %% 标识
    desc = [],                                 %% 描述
    type = 0,                                  %% 类型 1修改攻击   2角色周围持续  3死亡坐标   4死亡坐标持续  5角色周围随机延迟释放 （修改攻击的同类型互斥，获得新的覆盖。 其他的同id互斥）
    time = 0,                                  %% 持续时间ms
    att_type = 0,                              %% 攻击类型 0走正常攻击  1秒杀怪物种类0的
    mana_add_list = [],                        %% 存的灵力万分比列表[最后一个值循环使用]
    die_per_list = [],                         %% 概率万分比[最后一个值循环使用]
    speed_mana_add_list = [],                  %% 狂暴模式下存的灵力万分比列表[最后一个值循环使用]
    speed_die_per_list = []                    %% 狂暴模式下概率万分比[最后一个值循环使用]
}).
-record(key_t_monster_effect, {
    skill_id                                   %% 技能id
}).

%% monster_ai_bubble.csv 怪物id语言表
-record(t_monster_ai_bubble, {
    row_key,
    ai_id = 0,                                 %% ai_id
    birth_bubble_type = 0,                     %% 出生语言类型【bubble表类型】（配空不处理）
    stand_bubble_type = 0,                     %% 待机语音类型【bubble表类型】（配空不处理）
    stand_bubble_cd_time = 0,                  %% 待机触发语言cd【ms】
    death_bubble_type = 0,                     %% 死亡语言【bubble表类型】（配空不处理）
    injured_bubble_type = 0,                   %% 受伤语言【bubble表类型】（配空不处理）
    injured_bubble_cd_time = 0,                %% 受伤触发语言cd【ms】
    injured_bubble_per = 0                     %% 受伤触发语言概率万分比
}).
-record(key_t_monster_ai_bubble, {
    ai_id                                      %% ai_id
}).

%% monster.csv 怪物表
-record(t_monster, {
    row_key,
    id = 0,                                    %% 怪物ID
    name = [],                                 %% 名称
    scene_id = 0,                              %% 场景id
    monster_ai_bubble = 0,                     %% 怪物语音ai行为逻辑monster_ai_bubble
    effect_list = [],                          %% 效果[0无效果 1召唤怪 2金币雨 3旧翻牌 4双倍 5闪电链 6分裂弹 7恐惧之翼 8混沌 9翻牌（翻牌类型） 10拉霸（拉霸类型） 11转盘（转盘类型）12炸弹怪 13火球怪 14地震怪 15金币小妖  16神龙祝福  17黄金怪  18事件转盘  19事件拉霸  20开箱子 21陨石雨  22奥数圈 23龙卷风  24幽灵炸弹  25彩球怪物   26泰坦   27灭世之炎
    new_die_list = [],                         %% 死亡判断
    new_reward_1_list = [],                    %% 死亡奖励倍数【下限,上限】，随机一个倍数*击杀的消耗
    new_hp_reward_1_list = [],                 %% 血条版本死亡奖励倍数【[[修正id,[修正列表]…]】【修正列表=[奖励,权重,扣除池子,扣除值】
    xiuzheng_list = [[1,10000,1,0],[2,10000,1,0],[3,10000,1,0]],%% [[修正id,修正万分比,扣除池子,扣除倍率]…]1=等概率,2=低概率，3=高概率
    new_hp = 10000,                            %% 血条版本血量
    diamond_reward_list = [],                  %% 钻石奖励列表【获得概率万分比,钻石数量】
    new_reward_2 = 0,                          %% 死亡不翻倍奖励【直接给，黄金鱼*2】
    new_ling_li = 0,                           %% 包含灵力
    new_ling_li_count = 0,                     %% 灵力死亡奖励
    type = 0,                                  %% 怪物类型[1:主动 2:被动 3:木桩 4:飞行怪（瞬移切位置）]  5混沌  6刺客 9新BOSS
    is_boss = 0,                               %% 是否boss[0:小怪 1:BOSS ]
    kind = 0,                                  %% 怪物种类(大于100不受功能怪直接击杀影响）0其他 1小型怪 2中型怪 3大型怪 101赏金怪 102功能怪 102事件怪物 104BOSS
    skill_list = [],                           %% 技能列表[[技能id,level]]
    destroy_time = 0,                          %% 销毁时间,单位:ms
    type_action_list = [],                     %% 对应怪物类型的循环列表【对应怪物类型的循环列表 1：技能(1,技能id,时间）  2：移动（2,时间）  3:跳(3,时间)】
    p_skill_list = [],                         %% 被动技能列表[[技能id,level]]
    intellect = 1,                             %% ai智力
    exp = 0,                                   %% 经验
    hp = 10000,                                %% 生命
    attack = 0,                                %% 攻击
    defense = 0,                               %% 防御
    hit = 0,                                   %% 命中
    dodge = 0,                                 %% 闪避
    crit = 0,                                  %% 暴击
    crit_time = 0,                             %% 暴击时长
    hurt_add = 0,                              %% 伤害加成
    hurt_reduce = 0,                           %% 伤害减免
    crit_hurt_add = 0,                         %% 暴击伤害加成
    crit_hurt_reduce = 0,                      %% 暴击伤害减免
    hp_reflex = 0,                             %% 生命恢复
    tenacity = 0,                              %% 韧性
    resist_block = 0,                          %% 破击
    block = 0,                                 %% 格挡
    patrol_range = 0,                          %% 巡逻范围
    track_range = 0,                           %% 追踪范围
    track_min_range = 0,                       %% 追踪最低范围
    warn_range = 0,                            %% 警戒范围
    move_speed = 0,                            %% 移动速度 (点数)
    is_recover = 1,                            %% 是否回血
    first_recover_time = 3000,                 %% 失去仇恨首次回血时间(ms)
    rebirth_time = 0,                          %% 重生时间,单位:ms, 0:立刻重生 ,< 0 不重生
    new_hp_destroy_time = 0,                   %% 血条版本销毁时间,单位:ms
    dodge_pro = 0,                             %% 闪避几率
    allow_hurt_distance = 0,                   %% 受击距离 1=40像素
    is_place_die = 0,                          %% 是否只能原地死亡
    show_effect_sound_id = 0,                  %% 怪物出场特效音效id
    mount_step = 0,                            %% 坐骑step   配置0 无坐骑
    hallows_step = 0,                          %% 圣器step   配置0 无圣器
    appear_type = 1,                           %% 出场方式 1淡入 2闪白 100魂旋转
    is_evade_action = 0,                       %% 是否播放受击特效 0否 1是
    monster_sound_list = [],                   %% 怪物音效列表（[血量1,血量2,概率,CD,是否覆盖，sound_id]）
    mapping_relation = 0,                      %% 映射关系(客户端用)
    angry_kill = 0,                            %% 击败怪物获得怒气
    hit_probability = 0,                       %% 怪物击中损失概率
    hit_damage = 0,                            %% 怪物击中损失金币
    dizzy_time = 0,                            %% 击中眩晕时间（ms）
    dizzy_immune_time = 0,                     %% 免疫眩晕时间（ms）
    death_sound = 0,                           %% 怪物死亡音效
    notice = 0,                                %% 击杀怪物的场景提示
    haemal_strand = 1,                         %% 血条数
    level = 0                                  %% 等级
}).
-record(key_t_monster, {
    id                                         %% 怪物ID
}).

%% 懸賞任務表
-record(t_money_reward, {
    row_key,
    id = 0,                                    %% 懸賞任務id
    approach_list = [],                        %% 获取条件
    award_list = []                            %% 奖励列表
}).
-record(key_t_money_reward, {
    id                                         %% 懸賞任務id
}).

%% t_mission_type
-record(t_mission_type, {
    row_key,
    id = 0,                                    %% undefined
    sign = [],                                 %% 标识
    is_client = 0,                             %% 是否在客户端显示
    desc = [],                                 %% 描述
    log_type = 0,                              %% 日志类型id
    function_id = 0,                           %% 功能id
    function_config_id = 0,                    %% 页面id
    kind = 1,                                  %% 类别[1:单人副本 2:多人副本 3:多人唯一副本4:多人分线副本]
    tab_type = 1,                              %% 页签类型(1=材料,2=装备,3=资源)适用副本大厅
    video_id = 0,                              %% 对应视频Id
    tab_sort = 0,                              %% 页签排序
    delay_time = 0,                            %% 延迟启动时间(ms)
    continue_time = 0,                         %% 副本持续时间(ms)
    is_can_sweep = 0,                          %% 是否可以扫荡
    is_sweep_need_passed = 1,                  %% 扫荡是否必须先通关
    is_notice_round = 0,                       %% 是否通知波次[0:不通知波次 1: 通知波次 2:通知怪物数量]
    is_round_award = 0,                        %% 是否每波奖励
    is_record_passed = 0,                      %% 是否记录通关id
    is_repeat_challenge = 0,                   %% 通关后是否可以重复挑战
    is_must_passed_last = 0,                   %% 是否必须完成上一关卡
    sweep_times_id = 0,                        %% 扫荡消耗次数id(为0则消耗挑战次数)
    times_id = 0,                              %% 挑战消耗次数id (0:没有次数限制)
    del_times_node = 0,                        %% 扣次数节点[0:进入副本扣次数 1:通关副本扣次数 2:特殊 3:扫荡]
    is_rebirth = 0,                            %% 是否可以复活
    conditions_count_tuple = {},               %% 挑战成功触发次数条件
    is_can_be_bet = 0                          %% 是否允许投注(0或空为否，1为是，默认0)
}).
-record(key_t_mission_type, {
    id                                         %% undefined
}).

%% mission_step_by_step_sys步步紧逼
-record(t_mission_step_by_step_sy, {
    row_key,
    id = 0,                                    %% 副本id
    cost_list = [],                            %% 赌注消耗列表
    win_list = [],                             %% 胜利获得列表[次数,[物品类型,物品id,物品数量],获胜概率]
    enter_conditions_list = [],                %% 进入条件
    tips = 0                                   %% 所属页签
}).
-record(key_t_mission_step_by_step_sy, {
    id                                         %% 副本id
}).

%% mission_many_people_boss 多人boss表
-record(t_mission_many_people_boss, {
    row_key,
    id = 0,                                    %% boss_id
    participants_limit = 0,                    %% 参与人数限制
    create_condition_list = [],                %% 创建房间条件
    cost_mana = 0,                             %% 游客进入所消耗灵力
    mission_id = 0,                            %% 关卡id
    owner_award_mana = 0,                      %% 房主灵力抽佣值【BOSS死亡发放】
    join_reward = 0,                           %% 参与奖励【BOSS死亡,所有造成伤害的玩家发放】
    ui_off_list = [],                          %% 房间BOSS偏移量 [x,y,缩放]
    list_off_list = []                         %% 列表BOSS偏移量 [x,y,缩放]
}).
-record(key_t_mission_many_people_boss, {
    id                                         %% boss_id
}).

%% mission_guess
-record(t_mission_guess_boss_skill, {
    row_key,
    id = 0,                                    %% 技能id
    desc = [],                                 %% 备注
    type = 0,                                  %% 类型（1普攻,2技能）
    attack_time = 0,                           %% 攻击时长ms
    hurt_delay_time = 0,                       %% 飘伤害的延迟ms
    attack_range = 0,                          %% 攻击距离
    hit_back_range = 0,                        %% 击退距离
    main_target_type = 0,                      %% 技能主目标判断（1.默认 2重新随机（无视距离）
    target_range_type = 1,                     %% 目标选取（1.自身范围  2.选主目标范围）
    target_range = 0,                          %% 选取目标的范围
    attack_count = 1,                          %% 攻击数量上限
    attack_damage = 0,                         %% 技能伤害
    crit_damage = 0,                           %% 暴击伤害
    attack_damage_list = [],                   %% 技能伤害
    crit_damage_list = [],                     %% 暴击伤害
    crit = 0,                                  %% 暴击概率（万分比
    dodge = 0                                  %% 闪避概率（万分比
}).
-record(key_t_mission_guess_boss_skill, {
    id                                         %% 技能id
}).

%% mission_either_or.csv 二选一翻倍
-record(t_mission_either_or, {
    row_key,
    id = 0,                                    %% 副本id
    random_list = [],                          %% 首次区间值【万分比】
    time_list = [],                            %% 每一轮选择时间/s[[轮次,时间]...]
    box_probability_list = [],                 %% 开箱子概率[[轮次,概率,倍率]...]【万分比】
    loss = 0,                                  %% 未选择离开扣除金币【万分比】
    box_list = [],                             %% 2个箱子坐标[[x,y]...]
    box_monster_list = [],                     %% 2个箱子ID[轮次，箱子a,箱子b],
    box_die_times_list = [],                   %% 箱子击破所需次数列表
    box_cost = 0                               %% 
}).
-record(key_t_mission_either_or, {
    id                                         %% 副本id
}).

%% mission_brave_one勇敢者（1v1）
-record(t_mission_brave_one, {
    row_key,
    id = 0,                                    %% 副本id
    cost_list = [],                            %% 赌注消耗列表
    win_list = [],                             %% 胜利获得列表
    enter_conditions_list = [],                %% 进入条件
    tips = 0,                                  %% 所属页签
    mail_back = 0,                             %% 开启失败回退邮件
    mail_win = 0,                              %% 获胜邮件
    mail_fail = 0,                             %% 失败邮件
    round_time = 30                            %% 间隔时间
}).
-record(key_t_mission_brave_one, {
    id                                         %% 副本id
}).

%% mission副本表
-record(t_mission, {
    row_key,
    mission_type = 0,                          %% 副本类型
    id = 0,                                    %% 关卡id
    name = [],                                 %% 名字
    mana_multiple_list = 0,                    %% 每次消耗灵力值倍数
    mana_enter_list = [],                      %% 进入场景灵力值范围[1,0] 0表示无限
    mana_attack_list = [],                     %% 每次攻击消耗的倍率
    enter_conditions_list = [],                %% 进入条件
    scene_id = 0,                              %% 场景id
    boss_id = 0,                               %% boss_id
    boss_rebirth_list = [],                    %% VIP玩家重生Boss的花费
    drop_look_list = [],                       %% 掉落预览[[id,数量],……]
    jump_scene_list = [],                      %% 退出副本跳转场景[scene_id, x, y] | [scene_id]
    times_id = 0,                              %% 关联次数id (0:没有次数限制)
    round = 0,                                 %% 击杀多少波怪才可进入挑战（主线副本类型可用）
    robot_list = [],                           %% 机器人列表
    award_id = 0                               %% 奖励id
}).
-record(key_t_mission, {
    mission_type,                              %% 副本类型
    id                                         %% 关卡id
}).

%% 合成表
-record(t_merge, {
    row_key,
    id = 0,                                    %% 目标的物品id（数量固定1个）
    item_list = [],                            %% 消耗材料列表
    is_condition = 0                           %% 是否计算条件
}).
-record(key_t_merge, {
    id                                         %% 目标的物品id（数量固定1个）
}).

%% 匹配场
-record(t_mate, {
    row_key,
    id = 0,                                    %% id
    cost_list = [],                            %% 入场消耗[物品消耗,数量]
    rank_list = [],                            %% 排名奖励【填0为无奖励】
    game_time = 0,                             %% 对局时间（毫秒）
    start_countdown = 0,                       %% 实际倒计时时间（毫秒）
    lose = 0,                                  %% 多久匹配失败(毫秒）
    start_list = [],                           %% 子弹数量
    change_item_id = 0,                        %% 转换成的物品id
    scene = 0,                                 %% 场景id
    award_item_id = 0,                         %% 每天结算奖励id
    award = 0,                                 %% 每天结算显示（池子值低于这个值显示奖池累计中）
    mate_reward = 0                            %% 每场结束池子增加金额
}).
-record(key_t_mate, {
    id                                         %% id
}).

%% t_mail
-record(t_mail, {
    row_key,
    id = 0,                                    %% 邮件ID
    sign = [],                                 %% 标识
    name = [],                                 %% 名称
    type = 1,                                  %% 邮件方式(1:模板;2:修改标题)
    sender_id = 0,                             %% 发件人ID
    weight_value = 0,                          %% 邮件重要值(0最小)
    content = [],                              %% 内容
    award_id = 0,                              %% 奖励组ID
    valid_time = 0,                            %% 有效期(s)
    desc = []                                  %% 备注
}).
-record(key_t_mail, {
    id                                         %% 邮件ID
}).

%% 日志类型
-record(t_log_type, {
    row_key,
    id = 0,                                    %% ID
    sign = [],                                 %% 标识符
    name = []                                  %% 名称
}).
-record(key_t_log_type, {
    id                                         %% ID
}).

%% labapreset 拉霸机台表
-record(t_labapreset, {
    row_key,
    type = 0,                                  %% 判断机台
    id = 0,                                    %% undefined
    name = [],                                 %% 机台预埋线简介
    presetlevel = 0,                           %% 判断预埋线等级
    presetline_list = []                       %% 预埋线配置
}).
-record(key_t_labapreset, {
    type,                                      %% 判断机台
    id                                         %% undefined
}).

%% labaline 拉霸连线表
-record(t_labaline, {
    row_key,
    type = 0,                                  %% 判断机台
    id = 0,                                    %% undefined
    name = [],                                 %% 机台连线简介
    data_list = [],                            %% 连接线配置
    rowid = 0,                                 %% 连线对应行
    lineposition_list = []                     %% 线位置列表
}).
-record(key_t_labaline, {
    type,                                      %% 判断机台
    id                                         %% undefined
}).

%% laba_icon 拉霸内容表
-record(t_laba_icon, {
    row_key,
    type = 0,                                  %% 判断机台
    id = 0,                                    %% 图标
    icon_id = 0,                               %% 图标id
    name = [],                                 %% 功能说明(表格的说明)
    data_list = [],                            %% 倍率
    data = 0,                                  %% 概率权重
    dataquality = 0,                           %% 边框id（0为没有）
    basequality = 0,                           %% 底框id（0为没有）
    specialjudge = 0,                          %% 特殊格判断
    specialweight_list = []                    %% 特殊格权重
}).
-record(key_t_laba_icon, {
    type,                                      %% 判断机台
    id                                         %% 图标
}).

%% laba 拉霸机台表
-record(t_laba, {
    row_key,
    type = 0,                                  %% 判断机台
    name = [],                                 %% 功能说明(表格的说明)
    judgedefault = 0,                          %% 判断是否是默认拉霸机（1：默认拉霸；0非默认拉霸）
    consume_list = [],                         %% 倍率
    draw_list = [],                            %% 【拉霸奖池】抽水
    pricejackpot_list = [],                    %% 【拉霸奖池】消耗对应奖池
    freegamenumber_list = [],                  %% freegame出现时个数对应进入freegame模式次数[freeganme图标数，次数]
    presetlineid = 0,                          %% 预埋线id
    machinetype = 0,                           %% 机台类型（百搭：1；连线：2）
    judgefreegame = 0,                         %% freegame跳转机台id，0为无freegame机台，1为freegame机台
    gold_list = [],                            %% 金框出现概率[列数，概率]
    laba_result_list = [],                     %% 【拉霸奖池】三种结果出现权重[大亏大赚状态，[freegame，中，不中]]
    laba_baodi_list = [],                      %% 【拉霸修正】多次未中垃圾胡保底[未中次数,保底垃圾胡概率,[垃圾胡图形idlist]]
    laba_freegamenumber_list = [],             %% 【拉霸修正】freegame结果时，freegame图标出现个数[个数，权重]
    laba_freegamemultiplemax_list = [],        %% 【拉霸修正】freegame最多获得倍数 [大盘状态，[[概率组权重，[本次freegame奖励倍率下限，上限]],第二组…]]
    laba_freegameaward_list = [],              %% 【拉霸修正】freegame每次中奖概率[大盘状态,中奖概率]
    laba_presetline_list = []                  %% 【拉霸修正】freegame预埋线等级[[倍率下限,倍率上限],对应预埋线等级]
}).
-record(key_t_laba, {
    type                                       %% 判断机台
}).

%% 奖金池-翻倍次数表
-record(t_jiangjinchi_time_pro, {
    row_key,
    time = 0,                                  %% 翻倍次数
    success_pro = 0,                           %% 成功概率
    multi_time = 0,                            %% 翻倍倍率
    need_vip = 0,                              %% 需求VIP等级
    jiangchi_isopen = 0                        %% 是否开启奖金池
}).
-record(key_t_jiangjinchi_time_pro, {
    time                                       %% 翻倍次数
}).

%% 奖金池-奖金池场景配置表
-record(t_jiangjinchi_scene, {
    row_key,
    sceneid = 0,                               %% 场景id
    need_times = 0,                            %% 需求炮数
    init_award = 0,                            %% 奖池初始奖励
    limit_init = 0,                            %% 最低初始值
    vip_limit = 0,                             %% 大奖vip
    itemid = 0,                                %% 道具id
    reward_list = []                           %% 奖励列表[[参数下限,参数上限,权重]…]   奖励值=累计消耗*参数/200000，先算出值的上下限再随机值
}).
-record(key_t_jiangjinchi_scene, {
    sceneid                                    %% 场景id
}).

%% 奖金池-翻牌初始奖金表
-record(t_jiangjinchi_init_award, {
    row_key,
    id = 0,                                    %% ID
    cost_min = 0,                              %% 最小消耗
    cost_max = 0,                              %% 最大消耗
    award_list = []                            %% 奖励列表
}).
-record(key_t_jiangjinchi_init_award, {
    id                                         %% ID
}).

%% 奖金池-奖金池奖金表
-record(t_jiangjinchi_award, {
    row_key,
    sceneid = 0,                               %% 场景id
    id = 0,                                    %% ID
    award_min = 0,                             %% 奖励下限
    award_max = 0,                             %% 奖励上限
    award_per = 0                              %% 奖金池比例
}).
-record(key_t_jiangjinchi_award, {
    sceneid,                                   %% 场景id
    id                                         %% ID
}).

%% 物品类型
-record(t_item_type, {
    row_key,
    type = 0,                                  %% 物品类型
    name = [],                                 %% 名称
    sign = [],                                 %% 标识
    dec = [],                                  %% 备注（道具表effect字段填写格式）
    idx_sort = 0,                              %% 是否在背包排序显示
    is_show_redpoint = 0,                      %% 是否显示小红点(1=是；0=否)
    is_can_use = 0                             %% 是否可以直接使用
}).
-record(key_t_item_type, {
    type                                       %% 物品类型
}).

%% item_decompose 道具分解表
-record(t_item_decompose, {
    row_key,
    id = 0,                                    %% 道具ID
    decompose_list = []                        %% 分解列表
}).
-record(key_t_item_decompose, {
    id                                         %% 道具ID
}).

%% item.csv 道具表
-record(t_item, {
    row_key,
    id = 0,                                    %% 道具ID
    name = [],                                 %% 道具名称
    sign = [],                                 %% 标识
    type = 0,                                  %% 道具类型：1=物品；2=技能书；3=公共系统；4=金条碎片；5=金条 7=称号 8=礼拜 9=资源 10=英雄部件 11=英雄 12=图鉴卡牌  13英雄碎片
    level = 0,                                 %% 使用等级（角色满足多少级才可使用）
    vip_level = 0,                             %% vip等级限制
    quality = 0,                               %% 道具品质：1=白色；2=绿色；3=蓝色；4=紫色；5=橙色；6=红色
    sale_price = 0,                            %% 出售价格（金币）
    copper_price = 0,                          %% 铜币购买价格
    gold_price = 0,                            %% 元宝购买价格
    is_stacked = 0,                            %% 是否可堆叠
    effect = 0,                                %% 道具效果：（具体效果参考item_type备注字段说明）
    special_effect_list = [],                  %% 道具特殊效果
    use_num = 0,                               %% 最大使用个数
    icon = 0,                                  %% 道具图标(路径：icon\Item)
    drop_quality = 0,                          %% 掉落品质
    end_time = 0,                              %% 消失时间s
    limite_item_list = [],                     %% 关联的限时道具列表
    expire_time_list = [],                     %% 过期时间列表 每日凌晨0点:[today]  定时:[[年,月,日],[时,分,秒]]
    attr_list = [],                            %% 特殊物品附加属性列表
    key_item_list = [],                        %% 宝箱钥匙
    effect_key = 0,                            %% 道具效果：（具体效果参考item_type备注字段说明）
    is_conditions = 0,                         %% 是否加到条件中(1:加入条件)
    condition_list = [],                       %% 使用条件列表[1,100]([条件表id,值])
    can_be_traded = 0,                         %% 是否允许在第三方平台交易(1:是，0或空:否)
    can_be_logged = 0                          %% 是否被记录到日志中(空为不记录到日志中,反之则为service_log表中的id字段)
}).
-record(key_t_item, {
    id                                         %% 道具ID
}).

%% hurtEffect
-record(t_hit_effect, {
    row_key,
    id = 0,                                    %% 结算特效ID
    desc = [],                                 %% 描述
    skill_resource_id = -1,                    %% 技能特效ID
    skill_assembly_id = -1,                    %% 技能组件ID
    is_rotation = 0,                           %% 是否随机旋转 0不转 1旋转
    sound_id = -1                              %% 声音id
}).
-record(key_t_hit_effect, {
    id                                         %% 结算特效ID
}).

%% 英雄星级表
-record(t_hero_star, {
    row_key,
    hero_id = 0,                               %% 英雄id
    star = 0,                                  %% 星级
    star_next = 0,                             %% 下一星级
    item_list = [],                            %% 升星所需道具[物品id,物品数量]
    reward_id = 0                              %% 奖励id
}).
-record(key_t_hero_star, {
    hero_id,                                   %% 英雄id
    star                                       %% 星级
}).

%% 英雄部件表
-record(t_hero_parts, {
    row_key,
    parts_id = 0,                              %% 部件id
    hero_id = 0,                               %% 所属英雄Id
    type = 0,                                  %% 类型-1武器-2饰品
    icon_parts = 0,                            %% assets\role\guangbo\scene(光波，受击)
    icon_wuqi = 0,                             %% assets\role\weapon(shipin)\scene(武器,饰品)
    item_id = 0,                               %% 对应itemid
    dragon_list = [],                          %% 龙骨配置 [1] 处于第一层
    offset_list = [],                          %% UI角色页面 xy偏移量【x,y,scaleXY】
    conditions_desc = [],                      %% 解锁描述
    use_conditions_list = [],                  %% 使用条件
    use_conditions_desc = [],                  %% 使用条件描述
    guangbo_sound = 0,                         %% 弹道音效
    skill_dash_charge_per = 0,                 %% 突进技能回复加速万分比（实际回复时间=回复时间*10000/（加速万分比总值+10000）
    skill_dash_times_add = 0                   %% 突进技能次数增加
}).
-record(key_t_hero_parts, {
    parts_id                                   %% 部件id
}).

%% 英雄表
-record(t_hero, {
    row_key,
    hero_id = 0,                               %% 英雄id
    name = [],                                 %% 名称
    avatar_id = 0,                             %% 模型id
    order = 0,                                 %% 排序id
    icon = 0,                                  %% icon
    unlock_item_list = [],                     %% 解锁所需物品
    quality = 0,                               %% 英雄品质：1=白色；2=绿色；3=蓝色；4=紫色；5=橙色；6=红色  7彩色
    hero_skill_list = [],                      %% 大招技能【大招致怪死方式(默认0，取怪物表)，特效ID，硬直时间(毫秒)，开始拉镜头->动作延迟时间(毫秒)，开始拉镜头->特效时间(毫秒)，开始播技能->结算金币延迟时间(毫秒),开始播技能->播放受击动作延迟(毫秒)】
    danti_effect = 1,                          %% 单体技能特效
    hero_skill_time_cd = 0,                    %% 英雄大招无敌时间 毫毛(服务端用，使用技能成功开始计时)
    hero_skill_unlock_star = 0,                %% 英雄大招解锁所需星级
    unlock_parts_list = [],                    %% 默认解锁部件
    show_part_list = [],                       %% 未解锁展示部件列表[武器，饰品]
    weapon_part_list = [],                     %% 武器部件列表
    ornaments_part_list = [],                  %% 饰品部件列表
    world_tree = 0                             %% 世界树加成（万分比）
}).
-record(key_t_hero, {
    hero_id                                    %% 英雄id
}).

%% tajt
-record(t_guide, {
    row_key,
    id = 0,                                    %% 引导id
    step_id = 0,                               %% 步骤id
    next_step = 0,                             %% 引导下一步
    method_key = [],                           %% 当前指引对应的Key
    desc = [],                                 %% 备注说明
    start_step_id = 0,                         %% 重新登陆游戏，启动引导步骤
    is_client = 0,                             %% 0马上执行下一步  1等待客户端通知下一步(引导层隐藏)  2等待客户端通知下一步(引导层不隐藏，会发送当前步骤消息)
    show_type = 0,                             %% 引导点击区域形状（0默认圆形；1矩形）
    guide_type = 0,                            %% 0 默认强制(点按钮区域))  1不强制引导(点任意区域
    stay_time = 0,                             %% 必须停留多少时间才点击下一步(秒)
    execute_time = 0,                          %% 运行时间，单位秒  几秒后自动下一步 (默认0)
    param_obj = [],                            %% 该步骤对应参数
    mask_alpha = 0,                            %% 额外改变黑色蒙版透明度
    arrow_dire = 0,                            %% 箭头指向(顺时针1,2,3,4 对应：上右下左) 0默认不显示箭头
    float_type_x = 0,                          %% 适配浮动宽度(0居中适配舞台 1左边适配舞台 2右边适配舞台)默认居中
    float_type_y = 0,                          %% 适配浮动高度(0居中适配舞台 1顶部适配舞台 2底部适配舞台)默认居中
    position_list = [],                        %% 指引坐标 [x,y,宽，高] 为空不显示箭头指引
    tishi_off_list = [],                       %% 提示内容位置 [x,y,宽] 高根据内容自定义 默认为空不显示提示内容
    tishi_msg = [],                            %% 提示文本内容
    function_config_id = 0,                    %% 执行完该步骤，启动function_config
    sound_effect_id = 0                        %% 点击音效Id
}).
-record(key_t_guide, {
    id,                                        %% 引导id
    step_id                                    %% 步骤id
}).

%% give_mail
-record(t_give_mail, {
    row_key,
    id = 0,                                    %% 邮件ID
    sign = [],                                 %% 标识
    name = [],                                 %% 名称
    type = 1,                                  %% 邮件方式(1:模板;2:修改标题)
    sender_id = 0,                             %% 发件人ID
    weight_value = 0,                          %% 邮件重要值(0最小)
    content = [],                              %% 内容
    award_id = 0,                              %% 奖励组ID
    valid_time = 0,                            %% 有效期(s)
    desc = []                                  %% 备注
}).
-record(key_t_give_mail, {
    id                                         %% 邮件ID
}).

%% gift_code_exchange礼包码兑换表
-record(t_gift_code, {
    row_key,
    gift_code_id = [],                         %% 礼包码id(必须占4位)
    sign = [],                                 %% 标识
    platform_id = [],                          %% 平台限制
    channel_list = [],                         %% 渠道限制列表
    name = [],                                 %% 礼包名字
    type = 0,                                  %% 礼包类型 【0】：通码 注.可被多次使用，且一个角色只能使用一次 【1】:普码(有限制) 注. 不可被多次使用，且一个角色只能使用一次 【2】:普码(无限制) 注. 不可被多次使用，且角色不限制次数
    award_id = 0,                              %% 奖励id
    expire_time_list = [],                     %% 过期时间
    code_num = 1                               %% 礼包码数量
}).
-record(key_t_gift_code, {
    gift_code_id                               %% 礼包码id(必须占4位)
}).

%% 头像表
-record(t_ge_xing_hua, {
    row_key,
    id = 0,                                    %% id
    item_id = 0,                               %% 对应物品id[分类去物品表拿]
    order = 0,                                 %% 排序id
    icon = 0,                                  %% icon
    name = [],                                 %% 名称
    is_initial = 0,                            %% 是否默认获得
    conditions_list = [],                      %% 佩戴条件
    conditions_desc = []                       %% 佩戴条件描述
}).
-record(key_t_ge_xing_hua, {
    id                                         %% id
}).

%% function_config
-record(t_function_config, {
    row_key,
    id = 0,                                    %% 唯一ID(不要改变ID)
    sign = [],                                 %% 标识
    name = [],                                 %% 中文说明
    functions_type = 0,                        %% 映射函数类型
    param_obj = [],                            %% 参数代码
    function_id = 0,                           %% 对应function表
    icon_entaran = 0,                          %% resource/ui/entranceUI/entranceUI （默认优先）
    icon_id = 0,                               %% resource/assets/icon/entrance
    item_access = []                           %% 获取途径
}).
-record(key_t_function_config, {
    id                                         %% 唯一ID(不要改变ID)
}).

%% function功能开启表
-record(t_function, {
    row_key,
    id = 0,                                    %% 功能ID
    name = [],                                 %% 名称
    sign = [],                                 %% 标识
    not_have_pf_list = [],                     %% 不存在平台列表
    have_pf_list = [],                         %% 存在平台的列表：全平台写1(1级开启的功能不要写入数据库，不需要条件功能激活就写1，有需要对应平台就写对应平台)
    module_tuple = {},                         %% 模块名
    function_tuple = {},                       %% 方法名
    is_red = 0,                                %% 是否给小红点
    arg_list = [],                             %% 参数列表
    activate_condition_list = [],              %% 激活条件列表[[conditions, V(格式(1):V是要一样才能生效; 内容格式(2)：[A,B]-》 表示值 A >= V 并且 V =< B B等于0为无限大)]]
    condition_desc = [],                       %% 激活条件描述
    condition_desc__en = [],                   %% 激活条件描述
    activate_type = 0,                         %% 激活类型[0:或 1:与]
    enter_list = [],                           %% 关联激活入口
    icon = 0,                                  %% 图标ID(resource/functionIcon/icon)
    icon_name = 0,                             %% 图标按钮名称(resource/functionIcon/name)
    label_name_list = []                       %% 标签名字(1表示任务页签，2表示兑换页签，3表示兑换页签只有周末显示）
}).
-record(key_t_function, {
    id                                         %% 功能ID
}).

%% 首储
-record(t_first_recharge, {
    row_key,
    recharge_id = 0,                           %% 商品ID
    name = [],                                 %% 名字
    item_list = []                             %% 奖励列表
}).
-record(key_t_first_recharge, {
    recharge_id                                %% 商品ID
}).

%% everyday_sign  每日签到
-record(t_everyday_sign, {
    row_key,
    round = 0,                                 %% 第几轮
    today = 0,                                 %% 第几天
    award_list = [],                           %% 签到奖励
    vip_multiple_list = []                     %% [Vip等级，倍数]
}).
-record(key_t_everyday_sign, {
    round,                                     %% 第几轮
    today                                      %% 第几天
}).

%% 效果类型表
-record(t_effect_type, {
    row_key,
    id = 0,                                    %% 效果类型id
    sign = [],                                 %% 标识
    name = [],                                 %% 效果名称
    image_text = [],                           %% 美术飘字
    hit_effect_id = 0,                         %% 效果命中特效 （引用hit_effect表）
    pos = 0,                                   %% 显示在哪(1施法者头上 2目标头上)
    arg = []                                   %% 参数
}).
-record(key_t_effect_type, {
    id                                         %% 效果类型id
}).

%% 成长大作战
-record(t_eat_monster_battle, {
    row_key,
    id = 0,                                    %% id
    cost_list = [],                            %% 入场消耗[物品消耗,数量]
    rank_list = [],                            %% 本场排名奖励【填0为无奖励】
    game_time = 0,                             %% 对局时间（毫秒）
    start_countdown = 0,                       %% 实际倒计时时间（毫秒）
    life_hp = 0,                               %% 生命血量
    award_list = [],                           %% 每天排名奖励
    rule = [],                                 %% 规则说明
    amount = 0,                                %% 房间数量
    notice = 0,                                %% 上榜人数
    rank_mail_id = 0,                          %% 排行奖励邮件
    draw_id = 0,                               %% 平局奖励邮件id
    mail_id = 0,                               %% 离线掉线奖励邮件
    restrict = 0                               %% 最低上榜胜场
}).
-record(key_t_eat_monster_battle, {
    id                                         %% id
}).

%% 大鱼吃小鱼怪物表
-record(t_eat_monster, {
    row_key,
    level = 0,                                 %% 等级
    next_level = 0,                            %% 下一等级
    need_exp = 0,                              %% 升到下级所需经验
    move_speed = 0,                            %% 移动速度
    player_move_speed = 0,                     %% 玩家移动速度
    drop_exp = 0,                              %% 击杀掉落经验
    avatar_id_list = []                        %% 形象列表[avatarId,半径，缩放值](长度超过，可随机)
}).
-record(key_t_eat_monster, {
    level                                      %% 等级
}).

%% 提现金额
-record(t_draw_money, {
    row_key,
    id = 0,                                    %% 金额编号
    money = 0,                                 %% 额度
    times_id = 0,                              %% 次数id
    is_show = 0                                %% 是否显示
}).
-record(key_t_draw_money, {
    id                                         %% 金额编号
}).

%% 调试功能
-record(t_debug, {
    row_key,
    id = 0,                                    %% 类型
    name = [],                                 %% 功能名字
    csv_name = [],                             %% 对应表格名
    args = []                                  %% 
}).
-record(key_t_debug, {
    id                                         %% 类型
}).

%% 每日任務表
-record(t_daily_task, {
    row_key,
    id = 0,                                    %% 每日任務ID
    type = 0,                                  %% 類型（每個類型隨1個任務）
    approach_list = [],                        %% 獲取條件
    award_list = 0,                            %% 奖励列表
    function_config_id = 0                     %% 功能ID（界面跳转）
}).
-record(key_t_daily_task, {
    id                                         %% 每日任務ID
}).

%% 消耗-倍率表
-record(t_cost, {
    row_key,
    cost = 0,                                  %% 消耗
    conditions_limit_list = [],                %% 解锁条件
    coin_conditions_limit_list = [],           %% 金币解锁条件
    diamond_conditions_limit_list = [],        %% 钻石解锁条件
    select_def = 0                             %% 解锁后默认选中
}).
-record(key_t_cost, {
    cost                                       %% 消耗
}).

%% conditions_enum条件枚举表
-record(t_conditions_enum, {
    row_key,
    id = 0,                                    %% 枚举ID
    sign = [],                                 %% 标识
    data_restart_type = 0,                     %% 数据记录方式
    arg = [],                                  %% 参数列表（填写规则）
    func_config_id = 0,                        %% 功能链接id
    name = [],                                 %% 名称
    desc = [],                                 %% 备注
    is_task_init = 0                           %% 是否任务初始化获取数据
}).
-record(key_t_conditions_enum, {
    id                                         %% 枚举ID
}).

%% color 颜色配置表
-record(t_color, {
    row_key,
    id = 0,                                    %% 唯一key
    sign = [],                                 %% 标识
    color_value = [],                          %% 颜色数值
    desc = []                                  %% 备注说明
}).
-record(key_t_color, {
    id                                         %% 唯一key
}).

%% client_log
-record(t_client_log, {
    row_key,
    id = 0,                                    %% 枚举ID
    sign = [],                                 %% 标识
    name = []                                  %% 名称
}).
-record(key_t_client_log, {
    id                                         %% 枚举ID
}).

%% chat_notice
-record(t_chat_notice, {
    row_key,
    id = 0,                                    %% 系统id
    name = [],                                 %% 名字
    sign = [],                                 %% 公共标识
    notice_type = 1,                           %% 频道(1:系统)
    content = [],                              %% 内容
    remark = []                                %% 备注
}).
-record(key_t_chat_notice, {
    id                                         %% 系统id
}).

%% chat頻道
-record(t_chat, {
    row_key,
    id = 0,                                    %% 編號
    index = 0,                                 %% 排序
    name = [],                                 %% 频道名
    main_chat = [],                            %% 聊天入口頻道
    sign = [],                                 %% 标识
    is_send = 0,                               %% 1可发言
    send_cd_time = 0,                          %% 发言CD时间
    send_limit = 0,                            %% 频道发言文字上限
    broadcast_need_level = 0,                  %% 广播需求等级
    broadcast_need_vip_level = 0,              %% 广播需求VIP等级
    record_num = 0                             %% 聊天记录保存数量
}).
-record(key_t_chat, {
    id                                         %% 編號
}).

%% charge_game  游戏内充值id
-record(t_charge_game, {
    row_key,
    id = 0,                                    %% 编号
    sign = [],                                 %% 标识
    name = [],                                 %% 名字
    is_ingot = 1,                              %% 是否给元宝 1:给钻石 2给金币 0不给
    sell_money = 0,                            %% 购买金额（美元）在recharge.csv-cash 充值金额字段
    mail_id = 0                                %% 邮件id(没写使用默认)
}).
-record(key_t_charge_game, {
    id                                         %% 编号
}).

%% 渠道表
-record(t_channel, {
    row_key,
    platform_id = [],                          %% 平台
    channel = [],                              %% 渠道
    sign = [],                                 %% 标识
    name = [],                                 %% 渠道名称
    id = 0                                     %% 编号id
}).
-record(key_t_channel, {
    platform_id,                               %% 平台
    channel                                    %% 渠道
}).

%% 图鉴目录表
-record(t_card_title, {
    row_key,
    card_title_id = 0,                         %% 卡牌_目录_id
    card_item_list = [],                       %% 完成目标所需数量
    name = [],                                 %% 名称
    quality = 0,                               %% 品质
    reward = 0,                                %% 奖励id
    unlock_desc = [],                          %% 激活条件描述
    desc = []                                  %% 地图说明描述
}).
-record(key_t_card_title, {
    card_title_id                              %% 卡牌_目录_id
}).

%% 图鉴召唤
-record(t_card_summon, {
    row_key,
    id = 0,                                    %% id
    type = 0,                                  %% 卡池类型
    reward_list = [],                          %% 奖励列表[物品类型,物品id]
    weights = 0                                %% 权重
}).
-record(key_t_card_summon, {
    id                                         %% id
}).

%% 图鉴表
-record(t_card_book, {
    row_key,
    card_book_id = 0,                          %% 图鉴_id
    card_title_list = [],                      %% 卡牌目录列表
    reward = 0,                                %% 奖励id
    name = []                                  %% 名称
}).
-record(key_t_card_book, {
    card_book_id                               %% 图鉴_id
}).

%% 图鉴卡牌表
-record(t_card, {
    row_key,
    card_item_id = 0,                          %% 卡牌_物品_id（品质-名字去物品表拿）
    goal_count = 0,                            %% 完成目标所需数量
    icon = 0,                                  %% 卡牌样式
    reward = 0,                                %% 奖励id
    unlock_desc = [],                          %% 激活条件描述
    desc = []                                  %% 卡牌怪物说明
}).
-record(key_t_card, {
    card_item_id                               %% 卡牌_物品_id（品质-名字去物品表拿）
}).

%% buff效果表
-record(t_buff_new_effect, {
    row_key,
    id = 0,                                    %% Id
    sign = [],                                 %% 标识
    desc = []                                  %% 描述
}).
-record(key_t_buff_new_effect, {
    id                                         %% Id
}).

%% buff表
-record(t_buff_new, {
    row_key,
    id = 0,                                    %% Id
    effect_list = [],                          %% 效果列表（读buff_new_effect表）
    trigger_node_list = [],                    %% 触发节点[0:添加触发
    success_rate = 0,                          %% 生效概率
    continue_time = 0,                         %% 持续时间(ms)
    interval_time = 0,                         %% 间隔时间(ms)
    success_need_type_list = [],               %% 有对应类型buff存在才生效，空列表则必生效不做判断
    buff_type = 0                              %% buff分类（读buff_new_type表）
}).
-record(key_t_buff_new, {
    id                                         %% Id
}).

%% buff特效表现配置表
-record(t_buff_effect, {
    row_key,
    id = 0,                                    %% BUFF特效id
    buff_id = 0,                               %% 对应buff技能ID
    describe = [],                             %% buff名
    position = 0,                              %% buff所在的位置0头顶，1 身上，2 脚底
    recouse_id = 0,                            %% buff使用的技能资源
    assembly_id = 0                            %% buff出现时的技能组件id
}).
-record(key_t_buff_effect, {
    id                                         %% BUFF特效id
}).

%% buff表
-record(t_buff, {
    row_key,
    id = 0,                                    %% Id
    level = 0,                                 %% 等级
    quality = 0,                               %% 品质
    name = [],                                 %% 名称
    desc = [],                                 %% 描述
    arg_list = [],                             %% 效果参数列表
    is_permanent_attr = 0,                     %% 是否永久属性(属性会加到玩家身上)
    trigger_node_list = [],                    %% 触发节点[0:添加触发 1:攻击前  2:攻击后 3:被攻击前 4:被攻击后 6：法宝攻击后 [skill, 技能id]:释放技能时触发]
    skill_id_limit = 0,                        %% 技能限制
    hp_limit_list = [],                        %% 血量限制 [self|target,  {'>' | '<', 百分比}]
    attack_times_limit = 0,                    %% 攻击次数限制
    trigger_rate = 10000,                      %% 触发概率(万分比)
    target = 0,                                %% 效果目标[0:自己 1:敌方]
    type = 0,                                  %% 效果执行类型[0:单次 1:持续时间 2:间隔时间]
    target_type_limit_list = [],               %% 目标对象限制(空则无限制)[1:敌方是玩家有效 2:敌方是怪物有效 3:敌方是boss有效]
    continue_time = 0,                         %% 持续时间(ms)
    interval_time = 0,                         %% 间隔时间(ms)
    cd_time = 0,                               %% cd时间(ms)
    buff_effect_id = 0,                        %% buff特效表id 客户端表现用
    pos = 1                                    %% 显示在哪（1.角色上，2.法宝上,3.灵宠上）
}).
-record(key_t_buff, {
    id,                                        %% Id
    level                                      %% 等级
}).

%% bubble.csv 氣泡文
-record(t_bubble, {
    row_key,
    id = 0,                                    %% id
    type = 0,                                  %% 類型（0為玩家發送的語音）
    text = [],                                 %% 文本（如果沒填不出氣泡框）
    sound_id = 0                               %% 語音id（沒填不出語音）跳轉sound表
}).
-record(key_t_bubble, {
    id                                         %% id
}).

%% 日常活跃任务
-record(t_brisk_daily_task, {
    row_key,
    id = 0,                                    %% 日常任务id
    type = [],                                 %% 类型
    condition_list = [],                       %% 条件枚举
    reward_list = [],                          %% 完成任务奖励
    weights = 0                                %% 权重
}).
-record(key_t_brisk_daily_task, {
    id                                         %% 日常任务id
}).

%% big_wheel
-record(t_big_wheel_icon, {
    row_key,
    big_wheel_type = 0,                        %% 玩法类型
    id = 0,                                    %% 位置id
    name = [],                                 %% 名字
    type_id = 0,                               %% undefined
    icon = 0,                                  %% 图片id
    weight = 0,                                %% 权重
    leixing = 0                                %% 怪物或英雄（1怪物,2英雄,3灭世,4混沌）
}).
-record(key_t_big_wheel_icon, {
    big_wheel_type,                            %% 玩法类型
    id                                         %% 位置id
}).

%% big_wheel
-record(t_big_wheel, {
    row_key,
    big_wheel_type = 0,                        %% 类型
    name = [],                                 %% 名字
    betting_list = [],                         %% 投注金额
    odds_list = [],                            %% 赔率列表
    betting_limit = 0,                         %% 单人下注上限
    choushui = 0,                              %% 抽水率【万分比，98%表示进去100回98
    xiuzheng_list = [[-100000000,0,10000,10000],[1,100000000,10000,10000]],%% 修正列表[[池子下限,池子上限,正结果修正,负结果修正]…]
    baodi_list = [-100000000,100000000],       %% 保底列表[保底下限,保底上限]
    time_list = [],                            %% 各阶段时间毫秒[VS特效,开始下注特效,下注时长,停止下注特效,抽奖时长,中奖特效]
    time = 0,                                  %% undefined
    xiazhu_time = 0,                           %% undefined
    mail_id = 0                                %% 掉线邮件ID
}).
-record(key_t_big_wheel, {
    big_wheel_type                             %% 类型
}).

%% 1vs1
-record(t_bettle, {
    row_key,
    id = 0,                                    %% id
    cost_list = [],                            %% 入场消耗[物品消耗,数量]
    rank_list = [],                            %% 本场排名奖励【填0为无奖励】
    game_time = 0,                             %% 对局时间（毫秒）
    start_countdown = 0,                       %% 实际倒计时时间（毫秒）
    start = 0,                                 %% 子弹数量
    rank_money_list = [],                      %% 排名奖励
    scene = 0,                                 %% 场景id
    award_list = [],                           %% 每天排名奖励
    rule = [],                                 %% 规则说明
    amount = 0,                                %% 房间数量
    skill_list = [],                           %% 技能次数
    notice = 0,                                %% 上榜人数
    mail_id = 0,                               %% 离线掉线奖励邮件
    rank_mail_id = 0,                          %% 排行奖励邮件
    draw_id = 0,                               %% 平局奖励邮件id
    restrict = 0                               %% 最低上榜胜场
}).
-record(key_t_bettle, {
    id                                         %% id
}).

%% activity_time_type
-record(t_activity_time_type, {
    row_key,
    id = 0,                                    %% 活动类型id
    sign = [],                                 %% 标识
    name = [],                                 %% 名字
    check_type = 0,                            %% 活动检查类型(1:全服;2:玩家回归)
    des = [],                                  %% 备注
    unit_time_type = 1,                        %% 时间单位(1:秒;2:天)
    explain = []                               %% 注意说明列
}).
-record(key_t_activity_time_type, {
    id                                         %% 活动类型id
}).

%% lei_ji_chong_zhi  累计充值表
-record(t_activity_lei_chong, {
    row_key,
    activity_id = 0,                           %% 活动id
    id = 0,                                    %% id
    value = 0,                                 %% 储值金额
    reward_list = []                           %% 奖励列表
}).
-record(key_t_activity_lei_chong, {
    activity_id,                               %% 活动id
    id                                         %% id
}).

%% 活动信息表
-record(t_activity_info, {
    row_key,
    id = 0,                                    %% 活动id
    sign = [],                                 %% 标识
    name = [],                                 %% 活动名
    icon_id = 0,                               %% 图标ID
    type = 1,                                  %% 类型（1:本服活动，2:跨服活动,3:个人活动）
    house_type = 0,                            %% 1正常活动 2仙界活动
    comment = [],                              %% 备注
    is_valid = 1,                              %% 是否生效
    module = [],                               %% 模块名
    person_condition_list = [],                %% 个人活动开启条件
    person_time_list = [],                     %% 个人活动时间 [day, 天数]:开启当天到第N天23：59：59结束  forever: 永久
    person_repeat_open = 0,                    %% 个人活动关闭后是否可以重复开启
    open_server_day_limit_list = [],           %% 开服时间限制[[]:不限制 [起始天数， 结束天数]]
    merge_server_day_limit_list = [],          %% 合服时间限制[[]:不限制 [起始天数， 结束天数]]
    week_list = [],                            %% 周限制
    time_list = [],                            %% 时间配置 []:永久 [[时,分,秒],[时,分,秒]]:每天  [[[年,月,日],[时,分,秒]],[[年,月,日],[时,分,秒]]]:固定日期时间
    notice_time = 0,                           %% 提前通知时间(秒,不通知:0)
    prize_show_list = [],                      %% 玩法大厅奖励预览
    function_id = 0,                           %% 功能id(function表)
    function_config_id = 0,                    %% 打开页面(function_config.csv)
    open_desc = [],                            %% 活动开启的中文说明
    rule_desc = []                             %% 活动规则说明
}).
-record(key_t_activity_info, {
    id                                         %% 活动id
}).

%% t_active_skill
-record(t_active_skill, {
    row_key,
    id = 0,                                    %% 技能ID
    name = [],                                 %% 名称
    desc = [],                                 %% 描述
    sign = [],                                 %% 标识
    target = 0,                                %% 目标[0: 敌方 1：自己]
    wait_list = [],                            %% [预警类型,预警图片路径]   预警技能类型1.矩形 2扇形 3圆形 4无方向不改变    图片路径E:\t3\trunk\resource\assets\skills\xuliskill
    is_common_skill = 0,                       %% 是否是普攻[0:否 1:是]
    is_circular = 0,                           %% [填1不旋转]
    attack_length = 0,                         %% 攻击距离(1格=40像素)
    skill_distance = 0,                        %% 施法距离
    target_num = 1,                            %% 目标个数
    is_shift = 0,                              %% 是否位移技能
    speed_rate = 10,                           %% 速度加成 * 10
    calc_pos = 0,                              %% 结算源点[0:被攻击对象,1:被攻击点 2:施法者, 3施法点]
    cd_time = 0,                               %% CD时间[单位:ms]
    charge_time = 0,                           %% 充能时间[单位:ms]
    action_res = [],                           %% 动作资源路径
    beat_back = 0,                             %% 击退像素
    continue_time = "0",                       %% 施法持续时间[单位:ms]
    fps = [],                                  %% 帧率
    delay_time = [],                           %% 延迟结算时间[单位:ms]
    is_use_delay_time = 0,                     %% 是否使用延迟结算 0=否 1=是
    is_total = 0,                              %% 是否进行结算累计显示 0=否 1=是
    is_crash_only_one = 0,                     %% 是否只对角色击退1次 0否 1是
    is_evade_action = 0,                       %% 击退时是否播放受击动作 0否 1是
    skill_trigger_probability_for_attack = 0,  %% 普攻触发技能概率[万分比] 0技能走队列
    balance_type = 1,                          %% 结算类型[0:单段结算(仅仅通过距离判定) 1:多段结算(读取balance_list字段)  2:周围目标结算  3周围随机结算  4固定结算]
    base_dot_list = [],                        %% 基础点参数列表（balance_type=4时使用，施法者的X,Y偏移列表）
    base_limit_range = 0,                      %% 基础点距离（balance_type=3时使用）
    balance_list = [],                         %% 结算列表[{结算序号, 结算格子id,延迟时间(ms),伤害系数}](非普攻时格子1不生效)
    skill_res = 0,                             %% 技能资源路径
    sound_id_list = [],                        %% 技能音效id
    rangeattackid = 0,                         %% 远程攻击ID 无远程攻击则填0   rangeAttack表配置(废弃)
    hiteffect_id = "0",                        %% 受击特效id
    hitdietype = 2,                            %% 攻击死亡特效(1=击飞死亡，2=原地死亡，3=滑动后倒地死亡)
    skill_priority = 0,                        %% 技能优先级（值越大越优先）
    skill_type = 1,                            %% 技能类型 1主角主动技能 2主角普通攻击 4妖灵技能 5怪物技能 7被动技能 8法宝技能 9神兵技能 10 心法技能
    force_wait_time = 0,                       %% 硬直时间
    order = 0,                                 %% 技能显示排序
    is_tip = 0,                                %% 领悟后是否提示
    get_path_desc = [],                        %% 获取途径
    addbuff_list = []                          %% 添加BUFF列表[[添加对象,[buff列表]]…] 添加对象：1：技能命中目标
}).
-record(key_t_active_skill, {
    id                                         %% 技能ID
}).

%% 成就表
-record(t_achievement, {
    row_key,
    type = 0,                                  %% 成就類型
    id = 0,                                    %% 成就ID
    clients_type = 0,                          %% 客戶端分類顯示(1:目標,2:成就 99：提現任務)
    next_id = 0,                               %% 下一成就ID
    approach_list = [],                        %% 獲取條件
    award_list = 0,                            %% 獎勵列表
    function_config_id = 0,                    %% 功能ID（介面跳轉）
    withdrawal_type = 0                        %% 客戶端分類顯示(1:其他,2:儲值)
}).
-record(key_t_achievement, {
    type,                                      %% 成就類型
    id                                         %% 成就ID
}).

