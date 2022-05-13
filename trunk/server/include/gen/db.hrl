%%% Generated automatically, no need to modify.

-define(ACCOUNT, account).
-record(key_account, {
    acc_id,
    server_id
}).
-record(db_account, {
    row_key, 
    acc_id,                         %% string 平台账户id
    server_id,                      %% string 平台账户id
    is_create_role,                 %% int 是否创建角色
    player_id,                      %% int 玩家id
    is_enter_game,                  %% int 是否进入游戏
    is_finish_first_task,           %% int 是否完成第一个任务
    time,                           %% int 注册时间
    channel = ""                    %% string 渠道
}).

-define(ACCOUNT_CHARGE_WHITE, account_charge_white).
-record(key_account_charge_white, {
    platform_id,
    account
}).
-record(db_account_charge_white, {
    row_key, 
    platform_id = "",               %% string 平台
    account = "",                   %% string 账号
    is_white = 0                    %% int 上次分享时间
}).

-define(ACCOUNT_SHARE_DATA, account_share_data).
-record(key_account_share_data, {
    platform_id,
    account
}).
-record(db_account_share_data, {
    row_key, 
    platform_id = "",               %% string 平台
    account = "",                   %% string 账号
    last_share_time = 0,            %% int 上次分享时间
    finish_share_times = 0          %% int 完成分享的次数
}).

-define(ACTIVITY_AWARD, activity_award).
-record(key_activity_award, {
    activity_id
}).
-record(db_activity_award, {
    row_key, 
    activity_id = 0,                %% int 活动id
    start_time = 0,                 %% int 活动开始时间
    state = 0,                      %% int 状态(2:已发)
    change_time = 0                 %% int 创建时间
}).

-define(ACTIVITY_INFO, activity_info).
-record(key_activity_info, {
    activity_id
}).
-record(db_activity_info, {
    row_key, 
    activity_id,                    %% int 活动id
    state = 0,                      %% int 0: 关闭 1:准备 2: 启动
    last_open_time = 0,             %% int 上次开始时间
    last_close_time = 0,            %% int 上次结束时间
    config_open_time = 0,           %% int 活动配置开始时间
    config_close_time = 0           %% int 活动配置结束时间
}).

-define(BOSS_ONE_ON_ONE, boss_one_on_one).
-record(key_boss_one_on_one, {
    id
}).
-record(db_boss_one_on_one, {
    row_key, 
    id,                             %% int 主键
    home_boss = 0,                  %% int 左侧boss id
    away_boss = 0,                  %% int 右侧boss id
    player_total_cost = 0,          %% int 总投注
    player_total_award = 0,         %% int 总奖励
    winner = 0,                     %% int 获胜boss(0为home,1为away,默认为0)
    created_time = 0                %% int 对局开始时间戳
}).

-define(BRAVE_ONE, brave_one).
-record(key_brave_one, {
    player_id
}).
-record(idx_brave_one_1, {
    fight_player_id
}).
-record(db_brave_one, {
    row_key, 
    player_id = 0,                  %% int 玩家id
    id = 0,                         %% int 房间id
    pos_id = 0,                     %% int 位置
    brave_type = 0,                 %% int 房间类型
    start_time = 0,                 %% int 开始时间
    fight_player_id = 0,            %% int 对手玩家id
    change_time = 0                 %% int 操作时间
}).

-define(C_GAME_SERVER, c_game_server).
-record(key_c_game_server, {
    platform_id,
    sid
}).
-record(db_c_game_server, {
    row_key, 
    platform_id,                    %% string 平台id
    sid,                            %% string 区服ID
    desc = "",                      %% string 描述
    is_show = 0,                    %% int 是否显示
    node                            %% string 节点
}).

-define(C_SERVER_NODE, c_server_node).
-record(key_c_server_node, {
    node
}).
-record(db_c_server_node, {
    row_key, 
    node,                           %% string 节点
    ip = "",                        %% string 外网IP地址
    port = 0,                       %% int socket端口
    web_port = 0,                   %% int http端口
    db_host = "",                   %% string 数据库地址
    db_port = 3306,                 %% int 数据库端口
    db_name = "",                   %% string 数据库名
    type = 1,                       %% int 类型[1:游戏服节点 2:跨服节点  4. 登录服 5.唯一id服务器 6.充值服]
    zone_node = "",                 %% string 跨服节点(游戏服有效)
    open_time = 0,                  %% int 开服时间(游戏服有效)
    state = 0,                      %% int 状态[0:上线 1:维护]
    run_state = 0,                  %% int 运行状态[0:断开 1:运行]
    platform_id = ""                %% string 平台id(游戏服有效)
}).

-define(CHARGE_INFO_RECORD, charge_info_record).
-record(key_charge_info_record, {
    order_id
}).
-record(db_charge_info_record, {
    row_key, 
    order_id,                       %% string 订单ID
    charge_type = 0,                %% int 首充类型0:gm充值, 1:正常充值
    ip,                             %% string 充值时的ip
    part_id,                        %% string 平台id
    server_id,                      %% string 服务器id
    node,                           %% string 节点
    game_charge_id,                 %% int 游戏功能充值id
    charge_item_id = 0,             %% int 充值道具id
    acc_id,                         %% string 账号 id
    player_id,                      %% int 玩家id
    is_first = 0,                   %% int 是否首充1:是
    curr_level = 0,                 %% int 当前等级
    curr_task_id = 0,               %% int 当前任务id
    reg_time = 0,                   %% int 玩家注册时间
    first_time = 0,                 %% int 玩家首充时间
    curr_power = 0,                 %% int 当前战力
    money,                          %% float 充值人民币 /元
    ingot,                          %% int 充值元宝
    record_time = 0,                %% int 记录时间
    channel = "",                   %% string 渠道
    status = 1,                     %% int 状态(0为退款,1为成功,默认1)
    source = 1,                     %% int 来源(1为谷歌支付,2为app store支付,3为装备平台支付默认1)
    gold = 0,                       %% int 当前金币
    bounty = 0,                     %% int 当前赏金石
    coupon = 0                      %% int 当前点券
}).

-define(CHARGE_IP_WHITE_RECORD, charge_ip_white_record).
-record(key_charge_ip_white_record, {
    ip
}).
-record(db_charge_ip_white_record, {
    row_key, 
    ip,                             %% string ip
    name = "",                      %% string ip服务器名字
    state = 0,                      %% int 是否可以使用1:是
    record_time = 0                 %% int 记录时间
}).

-define(CHARGE_ORDER_REQUEST_RECORD, charge_order_request_record).
-record(key_charge_order_request_record, {
    order_id
}).
-record(db_charge_order_request_record, {
    row_key, 
    order_id = "",                  %% string 订单号
    param_str = "",                 %% string 订单参数
    change_time = 0                 %% int 操作时间
}).

-define(CLIENT_VERSIN, client_versin).
-record(key_client_versin, {
    version
}).
-record(db_client_versin, {
    row_key, 
    version = "",                   %% string 版本号
    is_release = 0,                 %% int 是否正式服
    time = 0                        %% int 更新时间
}).

-define(CONSUME_STATISTICS, consume_statistics).
-record(key_consume_statistics, {
    player_id,
    prop_id,
    type,
    log_type,
    scene_id
}).
-record(db_consume_statistics, {
    row_key, 
    player_id,                      %% int 玩家id
    prop_id,                        %% int 道具id
    type,                           %% int 0:获得 1:消费
    log_type = 0,                   %% int 日志类型
    value = 0,                      %% int 数量
    scene_id                        %% int 场景id
}).

-define(GIFT_CODE, gift_code).
-record(key_gift_code, {
    gift_code
}).
-record(db_gift_code, {
    row_key, 
    gift_code,                      %% string 礼包码
    gift_code_type = 0              %% int 礼包码类型
}).

-define(GIFT_CODE_TYPE, gift_code_type).
-record(key_gift_code_type, {
    type
}).
-record(idx_gift_code_type_1, {
    name
}).
-record(db_gift_code_type, {
    row_key, 
    type,                           %% int 礼包码type
    name = "",                      %% string 名称
    platform_id = "",               %% string 限制平台
    channel_list = "",              %% string 限制渠道
    award_list = "",                %% string 奖励列表
    user_id = 0,                    %% int 用户id
    kind = 0,                       %% int 礼包类别：0:通码(一码通用) 1:多码
    num = 0,                        %% int 申请数量
    allow_role_repeated_get = 0,    %% int 单角色是否可以多次领取(多码有效)
    vip_limit = 0,                  %% int vip限制
    level_limit = 0,                %% int level限制
    expire_time = 0,                %% int 过期时间
    update_time = 0                 %% int 更新时间
}).

-define(GLOBAL_ACCOUNT, global_account).
-record(key_global_account, {
    platform_id,
    account
}).
-record(db_global_account, {
    row_key, 
    platform_id,                    %% string 平台id
    account,                        %% string 帐号
    recent_server_list,             %% string 最近登陆的服务器列表
    promote = "",                   %% string 推广员标识
    type = 0,                       %% int 帐号类型0:普通 1:内部号
    forbid_type = 0,                %% int 封禁类型[0: 正常 1:禁言 2:封号]
    forbid_time = 0,                %% int 封禁时间
    app_id = "com.ashram.t3",       %% string app的包名
    region = "TWD",                 %% string 国家/地区
    registration_id = "",           %% string 激光设备码
    mobile = "0"                    %% string 手机号码
}).

-define(GLOBAL_PLAYER, global_player).
-record(key_global_player, {
    id
}).
-record(db_global_player, {
    row_key, 
    id,                             %% int 玩家ID
    account = "",                   %% string 帐号
    create_time = 0,                %% int 创建时间
    platform_id = "",               %% string 平台id
    server_id = "",                 %% string 服务器id
    channel = "",                   %% string 渠道
    nickanme = ""                   %% string 玩家昵称
}).

-define(JIANGJINCHI, jiangjinchi).
-record(key_jiangjinchi, {
    scene_id
}).
-record(db_jiangjinchi, {
    row_key, 
    scene_id,                       %% int  场景id
    pool = 0,                       %% int 当前奖池金额
    change_time = 0                 %% int 更新时间
}).

-define(LABA_ADJUST, laba_adjust).
-record(key_laba_adjust, {
    laba_id,
    cost_rate
}).
-record(db_laba_adjust, {
    row_key, 
    laba_id = 0,                    %% int 拉霸机id
    cost_rate = 0,                  %% int 消耗倍率
    pool = 0                        %% int 奖池数
}).

-define(LOGIN_NOTICE, login_notice).
-record(key_login_notice, {
    platform_id,
    channel_id
}).
-record(db_login_notice, {
    row_key, 
    platform_id = "",               %% string 平台id
    channel_id = "",                %% string 渠道
    content = ""                    %% string 公告内容
}).

-define(MATCH_SCENE_DATA, match_scene_data).
-record(key_match_scene_data, {
    id
}).
-record(db_match_scene_data, {
    row_key, 
    id,                             %% int 匹配场id
    player_id = 0,                  %% int 玩家id
    score = 0,                      %% int 积分
    award = 0,                      %% int 奖励
    last_time = 0                   %% int 上次结算时间
}).

-define(MISSION_GUESS_BOSS, mission_guess_boss).
-record(key_mission_guess_boss, {
    id
}).
-record(db_mission_guess_boss, {
    row_key, 
    id,                             %% int 猜BOSS副本期数id
    boss_id = 0,                    %% int BossId
    player_total_cost = 0,          %% int 玩家全部消耗
    player_total_award = 0,         %% int 玩家全部奖励
    time = 0                        %% int 时间
}).

-define(MISSION_RANKING, mission_ranking).
-record(key_mission_ranking, {
    mission_type,
    mission_id,
    id,
    player_id
}).
-record(idx_mission_ranking_1, {
    mission_type,
    mission_id,
    id
}).
-record(idx_mission_ranking_by_rank_id, {
    mission_type,
    mission_id,
    id,
    rank_id
}).
-record(db_mission_ranking, {
    row_key, 
    mission_type,                   %% int 副本类型
    mission_id = 0,                 %% int 通关的副本id
    id = 0,                         %% int 通关的副本id
    player_id,                      %% int 玩家id
    rank_id = 0,                    %% int 排名id
    nickname = "",                  %% string 昵称
    hurt = 0,                       %% int 伤害值
    time = 0                        %% int 更新时间
}).

-define(OAUTH_ORDER_LOG, oauth_order_log).
-record(key_oauth_order_log, {
    order_id
}).
-record(db_oauth_order_log, {
    row_key, 
    order_id,                       %% string 订单编号
    player_id,                      %% int 玩家id
    buyer_player_id = 0,            %% int 卖家编号 默认为0
    prop_id,                        %% int 道具id
    change_type,                    %% int 改变类型 0:减少 1:增加
    change_num,                     %% int 改变数量
    status = 1,                     %% int 订单状态(0为失败,1为成功,默认1)
    amount = 0.0,                   %% float 支付数额
    ip = "0",                       %% string IP地址
    create_time,                    %% int 创建时间
    update_time = 0                 %% int 最后一次编辑时间
}).

-define(ONE_VS_ONE_RANK_DATA, one_vs_one_rank_data).
-record(key_one_vs_one_rank_data, {
    type,
    player_id
}).
-record(idx_one_vs_one_rank_data_by_type, {
    type
}).
-record(db_one_vs_one_rank_data, {
    row_key, 
    type,                           %% int 类型
    player_id = 0,                  %% int 玩家id
    score = 0,                      %% int 积分
    time = 0                        %% int 时间
}).

-define(PHONE_UNIQUE_ID, phone_unique_id).
-record(key_phone_unique_id, {
    platform_id,
    phone_unique_id
}).
-record(db_phone_unique_id, {
    row_key, 
    platform_id,                    %% string 平台id
    phone_unique_id,                %% string 设备唯一标识码
    created_time = 0                %% int 创建时间
}).

-define(PLAYER, player).
-record(key_player, {
    id
}).
-record(idx_player_1, {
    nickname
}).
-record(idx_player_2, {
    acc_id,
    server_id
}).
-record(db_player, {
    row_key, 
    id,                             %% int 玩家id
    acc_id = "",                    %% string 平台帐号
    server_id,                      %% string 服务器ID
    nickname = "",                  %% string 昵称
    sex = 0,                        %% int 性别, 0:男 1:女
    forbid_type = 0,                %% int 封禁类型[1:禁言 2:封号]
    forbid_time = 0,                %% int 封禁时间
    reg_time = 0,                   %% int 注册时间
    last_login_time = 0,            %% int 最后登陆时间
    last_offline_time = 0,          %% int 最后离线时间
    total_online_time = 0,          %% int 累计在线时间
    last_login_ip = "",             %% string 最后登陆IP
    from = "",                      %% string 来源
    login_times = 0,                %% int 登录次数
    cumulative_day = 0,             %% int 累计登录天数
    continuous_day = 0,             %% int 连续登录天数
    total_recharge_ingot = 0,       %% int 充值总金额
    last_recharge_time = 0,         %% int 最后充值时间
    recharge_times = 0,             %% int 充值次数
    is_pass_fcm = 0,                %% int 是否通过防沉迷[0:否 1:是]
    type = 0,                       %% int 0:普通号 1:内部号
    is_online = 0,                  %% int 是否在线0:否
    channel = "",                   %% string 渠道
    friend_code = "",               %% string 分享码
    oauth_source = "vistor"         %% string 授权登录来源
}).

-define(PLAYER_ACHIEVEMENT, player_achievement).
-record(key_player_achievement, {
    player_id,
    type
}).
-record(db_player_achievement, {
    row_key, 
    player_id,                      %% int 玩家id
    type = 0,                       %% int 成就类型
    id = 0,                         %% int 成就id
    state = 0,                      %% int 领取状态(0:未领取,1:可领取,2:已领取)
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_ACTIVITY_CONDITION, player_activity_condition).
-record(key_player_activity_condition, {
    player_id,
    activity_id,
    condition_id
}).
-record(db_player_activity_condition, {
    row_key, 
    player_id,                      %% int 玩家id
    activity_id = 0,                %% int 活动id
    condition_id = 0,               %% int 条件id
    value = 0,                      %% int 条件值
    activity_time = 0               %% int 活动开始时间
}).

-define(PLAYER_ACTIVITY_GAME, player_activity_game).
-record(key_player_activity_game, {
    player_id,
    activity_id
}).
-record(idx_player_activity_game_1, {
    activity_id,
    activity_start_time
}).
-record(db_player_activity_game, {
    row_key, 
    player_id,                      %% int 玩家id
    activity_id = 0,                %% int 活动id
    activity_start_time = 0,        %% int 活动开始时间
    value = 0,                      %% int 值
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_ACTIVITY_GAME_INFO, player_activity_game_info).
-record(key_player_activity_game_info, {
    player_id,
    activity_id,
    game_id
}).
-record(db_player_activity_game_info, {
    row_key, 
    player_id,                      %% int 玩家id
    activity_id = 0,                %% int 活动id
    game_id = 0,                    %% int 档次id
    activity_start_time = 0,        %% int 活动开始时间
    state = 0,                      %% int 状态
    times = 0,                      %% int 次数
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_ACTIVITY_INFO, player_activity_info).
-record(key_player_activity_info, {
    player_id,
    activity_id
}).
-record(idx_player_activity_info_1, {
    player_id
}).
-record(db_player_activity_info, {
    row_key, 
    player_id,                      %% int 玩家id
    activity_id,                    %% int 活动id
    state = 0,                      %% int 0: 关闭 1:准备 2: 启动
    last_open_time = 0,             %% int 上次开始时间
    last_close_time = 0,            %% int 上次结束时间
    config_open_time = 0,           %% int 活动配置开始时间
    config_close_time = 0           %% int 活动配置结束时间
}).

-define(PLAYER_ACTIVITY_TASK, player_activity_task).
-record(key_player_activity_task, {
    player_id,
    activity_id,
    task_type
}).
-record(db_player_activity_task, {
    row_key, 
    player_id,                      %% int 玩家id
    activity_id,                    %% int 活动id
    task_type,                      %% int 任务类型
    value = 0,                      %% int 完成数量
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_ADJUST_REBOUND, player_adjust_rebound).
-record(key_player_adjust_rebound, {
    player_id,
    rebound_type
}).
-record(db_player_adjust_rebound, {
    row_key, 
    player_id,                      %% int 玩家id
    rebound_type,                   %% int 反弹类型(0:触底反弹 1:爆富反弹)
    trigger_times = 0,              %% int 当前触发次数
    trigger_time = 0                %% int 上次触发时间
}).

-define(PLAYER_BOUNTY_TASK, player_bounty_task).
-record(key_player_bounty_task, {
    player_id,
    id
}).
-record(idx_player_bounty_task_1, {
    player_id
}).
-record(db_player_bounty_task, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int id
    value = 0,                      %% int 值
    state = 0,                      %% int 领取状态(0-未领取,1-可领取,2-已领取)
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_CARD, player_card).
-record(key_player_card, {
    player_id,
    card_id
}).
-record(db_player_card, {
    row_key, 
    player_id,                      %% int 玩家id
    card_id,                        %% int 卡牌id
    state = 0,                      %% int 0:未领取,2:已领取
    num = 0                         %% int 数量
}).

-define(PLAYER_CARD_BOOK, player_card_book).
-record(key_player_card_book, {
    player_id,
    card_book_id
}).
-record(db_player_card_book, {
    row_key, 
    player_id,                      %% int 玩家id
    card_book_id                    %% int 卡牌图鉴id
}).

-define(PLAYER_CARD_SUMMON, player_card_summon).
-record(key_player_card_summon, {
    player_id
}).
-record(db_player_card_summon, {
    row_key, 
    player_id,                      %% int 玩家id
    once_cnt,                       %% int 单抽还剩几次抽高级卡池
    ten_times_cnt                   %% int 十连抽还剩几次抽高级卡池
}).

-define(PLAYER_CARD_TITLE, player_card_title).
-record(key_player_card_title, {
    player_id,
    card_title_id
}).
-record(db_player_card_title, {
    row_key, 
    player_id,                      %% int 玩家id
    card_title_id                   %% int 卡牌标题id
}).

-define(PLAYER_CHARGE_ACTIVITY, player_charge_activity).
-record(key_player_charge_activity, {
    player_id,
    type,
    id
}).
-record(db_player_charge_activity, {
    row_key, 
    player_id,                      %% int 玩家id
    type = 0,                       %% int 充值活动类型
    id = 0,                         %% int 充值活动id
    start_time = 0,                 %% int 活动开始时间
    value = 0,                      %% int 充值数据（各活动自己使用方式）
    state = 0,                      %% int 领取状态
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_CHARGE_INFO_RECORD, player_charge_info_record).
-record(key_player_charge_info_record, {
    player_id
}).
-record(db_player_charge_info_record, {
    row_key, 
    player_id,                      %% int 玩家id
    part_id,                        %% string 平台id
    server_id,                      %% string 服务器id
    total_money = 0.0,              %% float 总充值人民币/元
    charge_count = 0,               %% int 平台正式充值总次数
    charge_test_count = 0,          %% int 平台测试充值总次数
    gm_ingot_count = 0,             %% int 后台元宝充值总次数
    gm_charge_count = 0,            %% int 后台正式充值总次数
    gm_charge_novip_count = 0,      %% int 后台正式充值总次数(无vip经验)
    max_money = 0.0,                %% float 单笔最高充值人民币
    min_money = 0.0,                %% float 单笔最低充值人民币
    last_time = 0,                  %% int 玩家最后充值时间
    first_time = 0,                 %% int 玩家首充时间
    record_time = 0,                %% int 记录时间
    channel = "",                   %% string 渠道
    is_share = 0,                   %% int 是否分享
    refused_money = 0.0             %% float 退款总金额
}).

-define(PLAYER_CHARGE_RECORD, player_charge_record).
-record(key_player_charge_record, {
    order_id
}).
-record(idx_player_charge_record_1, {
    player_id
}).
-record(db_player_charge_record, {
    row_key, 
    order_id = "",                  %% string 订单号
    platform_order_id = "0",        %% string
    player_id,                      %% int 玩家id
    type = 0,                       %% int 充值类型,0:gm,99:正常充值
    game_charge_id = 0,             %% int 充值活动id,0:无活动
    charge_item_id = 0,             %% int 充值道具id
    ip = "",                        %% string 充值时ip
    value = 0,                      %% int 充值游戏币数量
    money = 0.0,                    %% float 充值人民币/元
    charge_state = 0,               %% int 充值订单状态1:创建2:上报9:完成
    rate = 0.0,                     %% float 费率,1美元兑换多少当地货币
    source = 1,                     %% int 来源(1为谷歌支付,2为app store支付,3为装备平台支付默认1)
    change_time = 0,                %% int 操作时间
    create_time = 0                 %% int 创建时间
}).

-define(PLAYER_CHARGE_SHOP, player_charge_shop).
-record(key_player_charge_shop, {
    player_id,
    id
}).
-record(db_player_charge_shop, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int 编号id
    count = 0,                      %% int 购买次数
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_CHAT_DATA, player_chat_data).
-record(key_player_chat_data, {
    player_id,
    id
}).
-record(idx_player_chat_data_by_player, {
    player_id
}).
-record(db_player_chat_data, {
    row_key, 
    player_id,                      %% int 玩家id
    id,                             %% int 消息id
    send_player_id,                 %% int 发送玩家id
    chat_msg = "",                  %% string 聊天消息
    level = 0,                      %% int 等级
    vip_level = 0,                  %% int vip等级
    head_id = 1,                    %% int 头像
    nickname = "",                  %% string 昵称
    sex = 0,                        %% int 性别, 0:男 1:女
    head_frame_id = 0,              %% int 头像框
    send_time = 0                   %% int 时间
}).

-define(PLAYER_CLIENT_DATA, player_client_data).
-record(key_player_client_data, {
    player_id,
    id
}).
-record(idx_player_client_data_1, {
    player_id
}).
-record(db_player_client_data, {
    row_key, 
    player_id,                      %% int 玩家id
    id = "",                        %% string id
    value = "",                     %% string 数据
    time = 0                        %% int 时间
}).

-define(PLAYER_CLIENT_LOG, player_client_log).
-record(key_player_client_log, {
    id
}).
-record(db_player_client_log, {
    row_key, 
    id,                             %% int ID
    player_id,                      %% int 玩家id
    log_id = 0,                     %% int 日志id
    time = 0                        %% int 時間
}).

-define(PLAYER_CONDITION_ACTIVITY, player_condition_activity).
-record(key_player_condition_activity, {
    player_id,
    activity_id
}).
-record(db_player_condition_activity, {
    row_key, 
    player_id,                      %% int 玩家id
    activity_id,                    %% int 活动id
    activity_time = 0,              %% int 活动时间
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_CONDITIONS_DATA, player_conditions_data).
-record(key_player_conditions_data, {
    player_id,
    conditions_id,
    type,
    type2
}).
-record(db_player_conditions_data, {
    row_key, 
    player_id,                      %% int 玩家id
    conditions_id = 0,              %% int 条件id
    type,                           %% int
    type2 = 0,                      %% int 类型2
    conditions_type = 0,            %% int 条件记录类型
    count = 0,                      %% int 次数计录
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_DAILY_POINTS, player_daily_points).
-record(key_player_daily_points, {
    player_id,
    bid
}).
-record(idx_player_daily_points_1, {
    player_id
}).
-record(db_player_daily_points, {
    row_key, 
    player_id,                      %% int 玩家id
    bid,                            %% int 领取积分宝箱id
    create_time                     %% int 领取时间
}).

-define(PLAYER_DAILY_TASK, player_daily_task).
-record(key_player_daily_task, {
    player_id,
    id
}).
-record(idx_player_daily_task_1, {
    player_id
}).
-record(db_player_daily_task, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int id
    value = 0,                      %% int 值
    state = 0,                      %% int 领取状态(0:未领取,1:可领取,2:已领取)
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_DATA, player_data).
-record(key_player_data, {
    player_id
}).
-record(db_player_data, {
    row_key, 
    player_id,                      %% int 玩家id
    exp = 0,                        %% int 经验
    level = 0,                      %% int 等级
    vip_level = 0,                  %% int vip等级
    title_id = 0,                   %% int 称号id
    honor_id = 0,                   %% int 头衔id
    head_id = 1,                    %% int 头像
    head_frame_id = 0,              %% int 头像框
    chat_qi_pao_id = 0,             %% int 聊天气泡id
    anger = 0,                      %% int 怒气值
    max_hp = 0,                     %% int 最大血量
    hp = 0,                         %% int 血量
    attack = 0,                     %% int 攻击
    defense = 0,                    %% int 防御
    hit = 0,                        %% int 命中
    dodge = 0,                      %% int 闪避
    tenacity = 0,                   %% int 韧性
    critical = 0,                   %% int 暴击
    rate_resist_block = 0,          %% int 破击
    rate_block = 0,                 %% int 格挡
    power = 0,                      %% int 战力
    speed = 0,                      %% int 速度
    crit_time = 0,                  %% int 暴击时长
    hurt_add = 0,                   %% int 造成伤害增加
    hurt_reduce = 0,                %% int 受到伤害减少
    crit_hurt_add = 0,              %% int 造成暴击伤害增加
    crit_hurt_reduce = 0,           %% int 受到暴击伤害减少
    hp_reflex = 0,                  %% int 生命恢复
    pk = 0,                         %% int pk值
    last_world_scene_id = 0,        %% int 上次世界场景ID
    x = 0,                          %% int X
    y = 0,                          %% int Y
    fight_mode = 0,                 %% int 战斗模式
    mount_status = 0,               %% int 坐骑状态
    game_event_id = 0               %% int 事件id
}).

-define(PLAYER_EVERYDAY_CHARGE, player_everyday_charge).
-record(key_player_everyday_charge, {
    player_id
}).
-record(db_player_everyday_charge, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int id
    state = 0,                      %% int 状态[0:未领取，1:可领取，2:已领取]
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_EVERYDAY_SIGN, player_everyday_sign).
-record(key_player_everyday_sign, {
    player_id,
    today
}).
-record(db_player_everyday_sign, {
    row_key, 
    player_id,                      %% int 玩家id
    today = 0,                      %% int 第几天
    state = 0,                      %% int 状态[0:未签到，1:已签到]
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_FIGHT_ADJUST, player_fight_adjust).
-record(key_player_fight_adjust, {
    player_id,
    prop_id,
    fight_type
}).
-record(db_player_fight_adjust, {
    row_key, 
    player_id,                      %% int 玩家id
    prop_id,                        %% int 道具id
    fight_type,                     %% int 战斗类型(0:概率战斗,1:血量战斗)
    pool = 0,                       %% int 当前池子
    pool_times = 0,                 %% int 当前池子次数
    rate = 0,                       %% int 当前倍率
    cost_rate = 0,                  %% int 当前消耗倍率
    cost_pool = 0,                  %% int 当前消耗池子
    pool_1 = 0,                     %% int 池子1
    pool_2 = 0,                     %% int 池子2
    bottom_times = 0,               %% int 触底反弹次数使用
    bottom_times_time = 0,          %% int 上一次触底反弹使用时间
    is_bottom = 0,                  %% int 是否是触底反弹
    id = 0                          %% int 修正id
}).

-define(PLAYER_FINISH_SHARE_TASK, player_finish_share_task).
-record(key_player_finish_share_task, {
    acc_id,
    task_type,
    player_id
}).
-record(db_player_finish_share_task, {
    row_key, 
    acc_id = "",                    %% string 平台帐号
    task_type = 0,                  %% int 任务类型id
    player_id = 0,                  %% int 玩家id
    state = 0                       %% int 完成状态（0：未完成，1：已完成）
}).

-define(PLAYER_FIRST_CHARGE, player_first_charge).
-record(key_player_first_charge, {
    player_id,
    type
}).
-record(db_player_first_charge, {
    row_key, 
    player_id,                      %% int 玩家id
    type,                           %% int 类型
    recharge_id,                    %% int 充值id
    login_day = 1,                  %% int 登录天数
    time = 0                        %% int 时间
}).

-define(PLAYER_FIRST_CHARGE_DAY, player_first_charge_day).
-record(key_player_first_charge_day, {
    player_id,
    type,
    day
}).
-record(db_player_first_charge_day, {
    row_key, 
    player_id,                      %% int 玩家id
    type,                           %% int 类型
    day,                            %% int 天数
    time                            %% int 领取时间
}).

-define(PLAYER_FUNCTION, player_function).
-record(key_player_function, {
    player_id,
    function_id
}).
-record(idx_player_function_1, {
    player_id
}).
-record(db_player_function, {
    row_key, 
    player_id,                      %% int 玩家id
    function_id = 0,                %% int 功能Id
    state = 0,                      %% int 状态1:开
    get_state = 0,                  %% int 状态2:已领取
    time = 0                        %% int 时间戳
}).

-define(PLAYER_GAME_CONFIG, player_game_config).
-record(key_player_game_config, {
    player_id,
    config_id
}).
-record(db_player_game_config, {
    row_key, 
    player_id,                      %% int
    config_id,                      %% int 配置id
    int_data = 0,                   %% int 整型数据
    str_data = "",                  %% string 字符串数据
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_GAME_DATA, player_game_data).
-record(key_player_game_data, {
    player_id,
    data_id
}).
-record(db_player_game_data, {
    row_key, 
    player_id,                      %% int player_id
    data_id,                        %% int 数据id
    int_data = 0,                   %% int 整型数据
    str_data = ""                   %% string 字符串数据
}).

-define(PLAYER_GAME_LOG, player_game_log).
-record(key_player_game_log, {
    id
}).
-record(db_player_game_log, {
    row_key, 
    id,                             %% int ID
    player_id,                      %% int 玩家ID
    scene_id = 0,                   %% int 場景id
    cost_list = "",                 %% string 消耗列表
    award_list = "",                %% string 獎勵列表
    time = 0,                       %% int 進入時間
    cost_time = 0                   %% int 消耗時間
}).

-define(PLAYER_GIFT_CODE, player_gift_code).
-record(key_player_gift_code, {
    player_id,
    gift_code_type
}).
-record(db_player_gift_code, {
    row_key, 
    player_id,                      %% int 玩家id
    gift_code_type,                 %% int 礼包码类型
    times = 0,                      %% int 领取次数
    change_time = 0                 %% int 时间
}).

-define(PLAYER_GIFT_MAIL, player_gift_mail).
-record(key_player_gift_mail, {
    player_id,
    mail_real_id
}).
-record(idx_player_gift_mail_by_player, {
    player_id
}).
-record(idx_player_gift_mail_by_sender, {
    sender
}).
-record(db_player_gift_mail, {
    row_key, 
    player_id,                      %% int 玩家id
    sender = 0,                     %% int 赠送者
    mail_real_id = 0,               %% int 邮件实际id
    weight_value = 0,               %% int 邮件重要级(重要级越小越先删除)
    is_read = 0,                    %% int 状态0未读,1:已读
    state = 0,                      %% int 状态0:没有附件,1有附件,2:已取附件
    is_del = 0,                     %% int 是否删除
    mail_id = 0,                    %% int 邮件模板id
    title_content = "",             %% string 邮件标题内容
    title_param = "0",              %% string 邮件标题参数
    content = "",                   %% string 邮件内容
    content_param = "0",            %% string 内容参数
    item_list = "",                 %% string 道具列表
    create_time = 0                 %% int 创建时间
}).

-define(PLAYER_GIFT_MAIL_LOG, player_gift_mail_log).
-record(key_player_gift_mail_log, {
    sender,
    create_time
}).
-record(db_player_gift_mail_log, {
    row_key, 
    sender,                         %% int 赠送者
    create_time = 0,                %% int 创建时间
    receiver = 0,                   %% int 接收者
    receiver_nickname = "",         %% string 接收者昵称
    item_list = ""                  %% string 道具列表
}).

-define(PLAYER_HERO, player_hero).
-record(key_player_hero, {
    player_id,
    hero_id
}).
-record(idx_player_hero_by_player, {
    player_id
}).
-record(db_player_hero, {
    row_key, 
    player_id,                      %% int 玩家id
    hero_id,                        %% int 英雄ID
    star = 0                        %% int 星级
}).

-define(PLAYER_HERO_PARTS, player_hero_parts).
-record(key_player_hero_parts, {
    player_id,
    parts_id
}).
-record(idx_player_hero_parts_by_player, {
    player_id
}).
-record(db_player_hero_parts, {
    row_key, 
    player_id,                      %% int 玩家id
    parts_id                        %% int 部件ID
}).

-define(PLAYER_HERO_USE, player_hero_use).
-record(key_player_hero_use, {
    player_id
}).
-record(db_player_hero_use, {
    row_key, 
    player_id,                      %% int 玩家id
    hero_id,                        %% int 英雄ID
    arms = 0,                       %% int 武器
    ornaments = 0                   %% int 饰品
}).

-define(PLAYER_INVEST, player_invest).
-record(key_player_invest, {
    player_id,
    type,
    id
}).
-record(db_player_invest, {
    row_key, 
    player_id,                      %% int 玩家id
    type,                           %% int 类型
    id,                             %% int id
    value = 0,                      %% int 值
    status,                         %% int 状态[0:未完成 1:可领取 2:已领取]
    update_time = 0                 %% int 领取时间
}).

-define(PLAYER_INVEST_TYPE, player_invest_type).
-record(key_player_invest_type, {
    player_id,
    type
}).
-record(db_player_invest_type, {
    row_key, 
    player_id,                      %% int 玩家id
    type,                           %% int type
    is_buy = 0,                     %% int 是否购买
    update_time = 0                 %% int 购买时间
}).

-define(PLAYER_INVITE_FRIEND, player_invite_friend).
-record(key_player_invite_friend, {
    acc_id,
    player_id
}).
-record(db_player_invite_friend, {
    row_key, 
    acc_id = "",                    %% string 平台帐号
    player_id                       %% int 玩家id
}).

-define(PLAYER_INVITE_FRIEND_LOG, player_invite_friend_log).
-record(key_player_invite_friend_log, {
    player_id,
    acc_id
}).
-record(db_player_invite_friend_log, {
    row_key, 
    player_id,                      %% int 玩家id
    acc_id = "",                    %% string 被邀请玩家平台帐号
    type,                           %% int 进入链接分享类型
    server_id,                      %% string 被邀请玩家服务器ID
    share_player_id,                %% int 被邀请玩家id
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_JIANGJINCHI, player_jiangjinchi).
-record(key_player_jiangjinchi, {
    player_id,
    scene_id
}).
-record(db_player_jiangjinchi, {
    row_key, 
    player_id,                      %% int 玩家id
    scene_id,                       %% int 场景id
    atk_cost = 0,                   %% int 普攻总消耗
    atk_times = 0,                  %% int 普攻刀数
    state = 0,                      %% int 状态 0-抽奖条件未达成 1-抽奖阶段 2-翻倍阶段
    award_num = 0,                  %% int 当前累计奖励数量
    extra_award_num = 0,            %% int 奖池奖励数量
    doubled_times = 0,              %% int 翻倍次数
    change_time = 0,                %% int 更新时间
    init_award_num = 0              %% int 初始奖励数量
}).

-define(PLAYER_LABA_DATA, player_laba_data).
-record(key_player_laba_data, {
    player_id,
    laba_id,
    cost_rate
}).
-record(db_player_laba_data, {
    row_key, 
    player_id = 0,                  %% int 玩家id
    laba_id = 0,                    %% int 拉霸id
    cost_rate = 0,                  %% int 消耗倍率
    missed_times = 0                %% int 连续未中奖次数
}).

-define(PLAYER_LEICHONG, player_leichong).
-record(key_player_leichong, {
    player_id,
    activity_id,
    task_id
}).
-record(db_player_leichong, {
    row_key, 
    player_id,                      %% int  玩家id
    activity_id,                    %% int  活动id
    task_id,                        %% int  任务id
    done = 0,                       %% int  完成数
    state = 0                       %% int  奖励状态 0-未完成 1-可领取 2-已领取
}).

-define(PLAYER_LOGIN_LOG, player_login_log).
-record(key_player_login_log, {
    id
}).
-record(db_player_login_log, {
    row_key, 
    id,                             %% int ID
    player_id,                      %% int 玩家ID
    ip,                             %% string 登录ip
    timestamp = 0                   %% int 时间戳
}).

-define(PLAYER_MAIL, player_mail).
-record(key_player_mail, {
    player_id,
    mail_real_id
}).
-record(idx_player_mail_1_player_id, {
    player_id
}).
-record(db_player_mail, {
    row_key, 
    player_id,                      %% int 玩家id
    mail_real_id = 0,               %% int 邮件实际id
    mail_id = 0,                    %% int 邮件id
    weight_value = 0,               %% int 邮件重要值
    state = 0,                      %% int 状态1:已读,2:已取附件
    title_name = "",                %% string 邮件标题
    content = "",                   %% string 邮件内容
    param = "",                     %% string 参数
    item_list = "",                 %% string 道具列表
    log_type = 0,                   %% int 邮件来源日志
    valid_time = 0,                 %% int 有效时间
    create_time = 0                 %% int 创建时间
}).

-define(PLAYER_MISSION_DATA, player_mission_data).
-record(key_player_mission_data, {
    player_id,
    mission_type
}).
-record(db_player_mission_data, {
    row_key, 
    player_id,                      %% int 玩家id
    mission_type,                   %% int 副本类型
    mission_id = 0,                 %% int 通关的副本id
    time = 0                        %% int 通关时间
}).

-define(PLAYER_OFFLINE_APPLY, player_offline_apply).
-record(key_player_offline_apply, {
    id
}).
-record(idx_player_offline_apply_1, {
    player_id
}).
-record(db_player_offline_apply, {
    row_key, 
    id,                             %% int ID
    player_id = 0,                  %% int 玩家id
    module,                         %% string 模块名
    function,                       %% string 函数名
    args,                           %% string 参数
    timestamp = 0                   %% int 时间戳
}).

-define(PLAYER_ONLINE_AWARD, player_online_award).
-record(key_player_online_award, {
    player_id,
    id
}).
-record(db_player_online_award, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int 档次id
    state = 0,                      %% int 状态[0:未领取，1:可领取，2:已领取]
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_ONLINE_INFO, player_online_info).
-record(key_player_online_info, {
    player_id
}).
-record(db_player_online_info, {
    row_key, 
    player_id,                      %% int 玩家id
    total_hours_online_today = 0,   %% int 今天在线总时长
    record_online_timestamps = 0    %% int 记录在线时间戳
}).

-define(PLAYER_ONLINE_LOG, player_online_log).
-record(key_player_online_log, {
    id
}).
-record(db_player_online_log, {
    row_key, 
    id,                             %% int ID
    player_id,                      %% int 玩家ID
    login_time = 0,                 %% int 登录时间
    offline_time = 0,               %% int 离线时间
    online_time = 0                 %% int 在线时长
}).

-define(PLAYER_PASSIVE_SKILL, player_passive_skill).
-record(key_player_passive_skill, {
    player_id,
    passive_skill_id
}).
-record(idx_player_passive_skill_1, {
    player_id
}).
-record(db_player_passive_skill, {
    row_key, 
    player_id,                      %% int 玩家id
    passive_skill_id,               %% int 被动技能ID
    level,                          %% int 等级
    is_equip,                       %% int 是否装备
    last_time = 0                   %% int 上次使用时间
}).

-define(PLAYER_PLATFORM_AWARD, player_platform_award).
-record(key_player_platform_award, {
    player_id,
    id
}).
-record(db_player_platform_award, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int 礼包id
    state = 0,                      %% int 状态
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_PREROGATIVE_CARD, player_prerogative_card).
-record(key_player_prerogative_card, {
    player_id,
    type
}).
-record(idx_player_prerogative_card_1, {
    player_id
}).
-record(db_player_prerogative_card, {
    row_key, 
    player_id,                      %% int 玩家id
    type = 0,                       %% int 特权卡类型
    state = 0,                      %% int 领取状态
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_PROP, player_prop).
-record(key_player_prop, {
    player_id,
    prop_id
}).
-record(idx_player_prop_1, {
    player_id
}).
-record(db_player_prop, {
    row_key, 
    player_id = 0,                  %% int 玩家id
    prop_id = 0,                    %% int 道具id
    num = 0,                        %% int 数量
    expire_time                     %% int 过期时间
}).

-define(PLAYER_PROP_LOG, player_prop_log).
-record(key_player_prop_log, {
    id
}).
-record(db_player_prop_log, {
    row_key, 
    id,                             %% int ID
    player_id,                      %% int 玩家ID
    prop_id,                        %% int 道具Id
    op_type = 0,                    %% int 操作类型
    op_time = 0,                    %% int 操作时间
    change_value = 0,               %% int 变化值
    new_value = 0                   %% int 新数值
}).

-define(PLAYER_SEND_GAMEBAR_MSG, player_send_gamebar_msg).
-record(key_player_send_gamebar_msg, {
    player_id,
    msg_type
}).
-record(db_player_send_gamebar_msg, {
    row_key, 
    player_id,                      %% int 玩家id
    msg_type,                       %% int 消息类型
    msg_id,                         %% int 消息id
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_SERVER_DATA, player_server_data).
-record(key_player_server_data, {
    player_id
}).
-record(db_player_server_data, {
    row_key, 
    player_id,                      %% int 玩家id
    platform_id,                    %% string 平台id
    server_id                       %% string 区服ID
}).

-define(PLAYER_SEVEN_LOGIN, player_seven_login).
-record(key_player_seven_login, {
    player_id
}).
-record(db_player_seven_login, {
    row_key, 
    player_id,                      %% int 玩家id
    give_award_value = 0            %% int 二进制记录奖励领取值
}).

-define(PLAYER_SHARE, player_share).
-record(key_player_share, {
    player_id
}).
-record(db_player_share, {
    row_key, 
    player_id,                      %% int 玩家id
    count = 0,                      %% int 分享数据
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_SHARE_FRIEND, player_share_friend).
-record(key_player_share_friend, {
    player_id,
    id
}).
-record(db_player_share_friend, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int 编号id
    state = 0,                      %% int 状态1:可领取,2:已领取
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_SHARE_TASK, player_share_task).
-record(key_player_share_task, {
    player_id,
    task_type
}).
-record(db_player_share_task, {
    row_key, 
    player_id,                      %% int 玩家id
    task_type = 0,                  %% int 任务类型id
    value = 0,                      %% int 任务完成值
    state = 0                       %% int 完成状态（0：未完成，1：已完成）
}).

-define(PLAYER_SHARE_TASK_AWARD, player_share_task_award).
-record(key_player_share_task_award, {
    player_id,
    task_type,
    task_id
}).
-record(db_player_share_task_award, {
    row_key, 
    player_id,                      %% int 玩家id
    task_type = 0,                  %% int 任务类型id
    task_id = 0,                    %% int 任务id
    state = 0                       %% int 完成状态（0：不可领，1：可领取，2：已领取）
}).

-define(PLAYER_SHEN_LONG, player_shen_long).
-record(key_player_shen_long, {
    player_id
}).
-record(db_player_shen_long, {
    row_key, 
    player_id,                      %% int 玩家id
    type = 0,                       %% int 神龙类型
    time = 0                        %% int 更新时间
}).

-define(PLAYER_SHOP, player_shop).
-record(key_player_shop, {
    player_id,
    id
}).
-record(db_player_shop, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int 编号id
    limit_type = 0,                 %% int 限购类型[-1:终身，0:不限购，1:每天，2:每周]
    buy_count = 0,                  %% int 购买数量
    award_state = 0,                %% int 领取状态
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_SPECIAL_PROP, player_special_prop).
-record(key_player_special_prop, {
    player_id,
    prop_obj_id
}).
-record(idx_player_special_prop_by_player, {
    player_id
}).
-record(db_player_special_prop, {
    row_key, 
    player_id,                      %% int 玩家id
    prop_obj_id,                    %% int 道具唯一id
    prop_id,                        %% int 道具id
    expire_time                     %% int 过期时间
}).

-define(PLAYER_SYS_ATTR, player_sys_attr).
-record(key_player_sys_attr, {
    player_id,
    fun_id
}).
-record(idx_player_sys_attr_1, {
    player_id
}).
-record(db_player_sys_attr, {
    row_key, 
    player_id,                      %% int 玩家id
    fun_id = 0,                     %% int 功能系统
    power = 0,                      %% int 当前系统总战力
    hp = 0,                         %% int 系统血量
    attack = 0,                     %% int 攻击
    defense = 0,                    %% int 防御
    hit = 0,                        %% int 命中
    dodge = 0,                      %% int 闪避
    critical = 0,                   %% int 暴击
    tenacity = 0,                   %% int 韧性
    speed = 0,                      %% int 速度
    crit_time = 0,                  %% int 暴击时长
    hurt_add = 0,                   %% int 造成伤害增加
    hurt_reduce = 0,                %% int 受到伤害减少
    crit_hurt_add = 0,              %% int 造成暴击伤害增加
    crit_hurt_reduce = 0,           %% int 受到暴击伤害减少
    hp_reflex = 0,                  %% int 生命恢复
    rate_resist_block = 0,          %% int 破击
    rate_block = 0,                 %% int 格挡
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_SYS_COMMON, player_sys_common).
-record(key_player_sys_common, {
    player_id,
    id
}).
-record(idx_player_sys_common_by_player, {
    player_id
}).
-record(idx_player_sys_common_by_state, {
    player_id,
    state
}).
-record(db_player_sys_common, {
    row_key, 
    player_id,                      %% int 玩家id
    id = 0,                         %% int id
    state = 0                       %% int 状态
}).

-define(PLAYER_TASK, player_task).
-record(key_player_task, {
    player_id
}).
-record(db_player_task, {
    row_key, 
    player_id,                      %% int 玩家id
    task_id,                        %% int 任务id
    status,                         %% int 任务状态[0:未完成 1:可领取 2:已领取,等待交接]
    num = 0,                        %% int 数量
    update_time = 0                 %% int 更新时间
}).

-define(PLAYER_TASK_SHARE_AWARD, player_task_share_award).
-record(key_player_task_share_award, {
    player_id,
    task_id
}).
-record(db_player_task_share_award, {
    row_key, 
    player_id,                      %% int 玩家id
    task_id = 0,                    %% int 任务id
    type = 0,                       %% int 领取类型
    change_time = 0                 %% int 领取时间
}).

-define(PLAYER_TIMES_DATA, player_times_data).
-record(key_player_times_data, {
    player_id,
    times_id
}).
-record(idx_player_times_data, {
    player_id
}).
-record(db_player_times_data, {
    row_key, 
    player_id,                      %% int 玩家id
    times_id,                       %% int 次数id
    use_times,                      %% int 今日使用次数
    left_times = 0,                 %% int 剩余次数
    buy_times,                      %% int 购买次数
    update_time,                    %% int 更新时间
    last_recover_time               %% int 上次恢复时间
}).

-define(PLAYER_TITLE, player_title).
-record(key_player_title, {
    player_id,
    title_id
}).
-record(idx_player_title_1, {
    player_id
}).
-record(db_player_title, {
    row_key, 
    player_id,                      %% int 玩家id
    title_id = 0,                   %% int 称号id
    title_level = 0,                %% int 等级
    state = 0,                      %% int 状态 1:已获得,2:已佩带
    create_time = 0                 %% int 创建时间
}).

-define(PLAYER_VIP, player_vip).
-record(key_player_vip, {
    player_id
}).
-record(db_player_vip, {
    row_key, 
    player_id,                      %% int 玩家id
    level = 0,                      %% int 等级
    exp = 0,                        %% int 当前经验
    change_time = 0                 %% int 操作时间
}).

-define(PLAYER_VIP_AWARD, player_vip_award).
-record(key_player_vip_award, {
    player_id,
    level
}).
-record(db_player_vip_award, {
    row_key, 
    player_id,                      %% int 玩家id
    level = 0,                      %% int 等级
    state = 0,                      %% int 领取状态
    change_time = 0                 %% int 操作时间
}).

-define(PROMOTE, promote).
-record(key_promote, {
    platform_id,
    acc_id
}).
-record(db_promote, {
    row_key, 
    platform_id = "",               %% string 平台id
    acc_id = "",                    %% string 平台帐号
    invite_player_id = 0,           %% int 邀请人玩家id
    use_times = 0,                  %% int 已领取次数
    times_time = 0,                 %% int 改变次数的时间
    is_red = 0                      %% int 是否显示红点
}).

-define(PROMOTE_INFO, promote_info).
-record(key_promote_info, {
    platform_id,
    acc_id,
    level
}).
-record(db_promote_info, {
    row_key, 
    platform_id = "",               %% string 平台id
    acc_id = "",                    %% string 平台帐号
    level = 0,                      %% int 推广等级
    number = 0,                     %% int 推广人数
    mana = 0,                       %% int 灵力奖励
    vip_exp = 0,                    %% int VIP经验奖励
    time = 0                        %% int 修改时间
}).

-define(PROMOTE_RECORD, promote_record).
-record(key_promote_record, {
    real_id
}).
-record(idx_promote_record_1, {
    platform_id,
    acc_id
}).
-record(db_promote_record, {
    row_key, 
    real_id = 0,                    %% int 实际id
    platform_id = "",               %% string 平台id
    acc_id = "",                    %% string 平台帐号
    id = 0,                         %% int 模板id
    param = "",                     %% string 参数
    time = 0                        %% int 创建时间
}).

-define(RANK_INFO, rank_info).
-record(key_rank_info, {
    rank_id,
    player_id
}).
-record(idx_rank_info_1_rank_id, {
    rank_id
}).
-record(idx_rank_info_2, {
    rank_id,
    rank
}).
-record(idx_rank_info_3_old_rank, {
    rank_id,
    old_rank
}).
-record(db_rank_info, {
    row_key, 
    rank_id,                        %% int 排行id
    player_id,                      %% int 玩家id
    rank = 0,                       %% int 排名
    old_rank = 0,                   %% int 上一次排名
    value = 0,                      %% int 战力
    old_value = 0,                  %% int 上一次战力
    change_time = 0                 %% int 创建时间
}).

-define(RED_PACKET_CONDITION, red_packet_condition).
-record(key_red_packet_condition, {
    id
}).
-record(db_red_packet_condition, {
    row_key, 
    id = 0,                         %% int 红包条件id
    value = 0,                      %% int 值
    change_time = 0                 %% int 操作时间
}).

-define(ROBOT_PLAYER_DATA, robot_player_data).
-record(key_robot_player_data, {
    player_id
}).
-record(idx_robot_player_data_1, {
    nickname
}).
-record(db_robot_player_data, {
    row_key, 
    player_id,                      %% int 玩家id
    nickname = "",                  %% string 名字
    server_id,                      %% string 服务器ID
    sex = 0                         %% int 性别, 0:男 1:女
}).

-define(ROBOT_PLAYER_SCENE_CACHE, robot_player_scene_cache).
-record(key_robot_player_scene_cache, {
    id
}).
-record(idx_robot_player_scene_cache_1, {
    player_id
}).
-record(db_robot_player_scene_cache, {
    row_key, 
    id,                             %% int id
    player_id = 0,                  %% int 玩家id
    server_id,                      %% string 服务器ID
    level = 0,                      %% int 等级
    clothe_id = 0,                  %% int 时装id
    title_id = 0,                   %% int 称号id
    magic_weapon_id = 0,            %% int 法宝id
    weapon_id = 0,                  %% int 武器id
    wings_id = 0,                   %% int 翅膀id
    shen_long_type = 0              %% int 神龙类型
}).

-define(SCENE_ADJUST, scene_adjust).
-record(key_scene_adjust, {
    scene_id
}).
-record(db_scene_adjust, {
    row_key, 
    scene_id,                       %% int 玩家id
    pool_value = 0                  %% int 场景修正池
}).

-define(SCENE_BOSS_ADJUST, scene_boss_adjust).
-record(key_scene_boss_adjust, {
    scene_id
}).
-record(db_scene_boss_adjust, {
    row_key, 
    scene_id,                       %% int 场景id
    pool_value = 0                  %% int 场景boss修正池
}).

-define(SCENE_LOG, scene_log).
-record(key_scene_log, {
    scene_id
}).
-record(db_scene_log, {
    row_key, 
    scene_id = 0,                   %% int 場景id
    cost_list = "",                 %% string 消耗列表
    award_list = "",                %% string 獎勵列表
    times = 0,                      %% int 次数
    cost_time = 0                   %% int 消耗時間
}).

-define(SERVER_DATA, server_data).
-record(key_server_data, {
    id,
    key2
}).
-record(db_server_data, {
    row_key, 
    id,                             %% int id
    key2 = 0,                       %% int 第二条件
    int_data = 0,                   %% int 整型数据
    str_data = "",                  %% string 字符串数据
    change_time = 0                 %% int 操作时间
}).

-define(SERVER_FIGHT_ADJUST, server_fight_adjust).
-record(key_server_fight_adjust, {
    prop_id
}).
-record(db_server_fight_adjust, {
    row_key, 
    prop_id,                        %% int 道具id
    pool_value = 0,                 %% int 池子值
    cost = 0,                       %% int 总消耗
    award = 0                       %% int 总奖励
}).

-define(SERVER_GAME_CONFIG, server_game_config).
-record(key_server_game_config, {
    config_id
}).
-record(db_server_game_config, {
    row_key, 
    config_id,                      %% int 配置id
    int_data = 0,                   %% int 整型数据
    str_data = "",                  %% string 字符串数据
    change_time = 0                 %% int 操作时间
}).

-define(SERVER_PLAYER_FIGHT_ADJUST, server_player_fight_adjust).
-record(key_server_player_fight_adjust, {
    player_id,
    prop_id
}).
-record(db_server_player_fight_adjust, {
    row_key, 
    player_id,                      %% int 玩家id
    prop_id,                        %% int 道具id
    id = 0,                         %% int 修正id
    times = 0,                      %% int 修正次数
    bottom_times = 0,               %% int 触底反弹次数使用
    bottom_times_time = 0           %% int 上一次触底反弹使用时间
}).

-define(SERVER_STATE, server_state).
-record(key_server_state, {
    time
}).
-record(db_server_state, {
    row_key, 
    time,                           %% int 时间戳
    create_count = 0,               %% int 创建角色次数
    login_count = 0,                %% int 登录次数
    online_count = 0,               %% int 最高在线人数
    error_count = 0,                %% int 累计服务器错误数
    db_error_count = 0              %% int 累计数据库错误数
}).

-define(TEST, test).
-record(key_test, {
    id
}).
-record(db_test, {
    row_key, 
    id,                             %% int id
    num,                            %% int num
    str                             %% string str
}).

-define(TIMER_DATA, timer_data).
-record(key_timer_data, {
    timer_id
}).
-record(db_timer_data, {
    row_key, 
    timer_id,                       %% int 定时器id
    last_time                       %% int 最近执行时间
}).

-define(TONGXINGZHENG_DAILY_TASK, tongxingzheng_daily_task).
-record(key_tongxingzheng_daily_task, {
    player_id
}).
-record(db_tongxingzheng_daily_task, {
    row_key, 
    player_id,                      %% int 玩家id
    task_list                       %% string 任务列表[{任务id,完成数,奖励领取状态}|...]
}).

-define(TONGXINGZHENG_MONTH_TASK, tongxingzheng_month_task).
-record(key_tongxingzheng_month_task, {
    player_id
}).
-record(db_tongxingzheng_month_task, {
    row_key, 
    player_id,                      %% int 玩家id
    task_list                       %% string 任务列表[{任务id,完成数,奖励领取状态}|...]
}).

-define(UNIQUE_ID_DATA, unique_id_data).
-record(key_unique_id_data, {
    type
}).
-record(db_unique_id_data, {
    row_key, 
    type,                           %% int 唯一id类型
    id                              %% int 数据
}).

-define(WHEEL_PLAYER_BET_RECORD, wheel_player_bet_record).
-record(key_wheel_player_bet_record, {
    player_id,
    type,
    id
}).
-record(idx_wheel_player_bet_record_by_id, {
    type,
    id
}).
-record(idx_wheel_player_bet_record_by_type_and_player, {
    type,
    player_id
}).
-record(db_wheel_player_bet_record, {
    row_key, 
    player_id,                      %% int 玩家id
    type,                           %% int 类型
    id,                             %% int wheel_id
    bet_num = 0,                    %% int 投注数量
    award_num = 0,                  %% int 投注奖励数量
    time = 0                        %% int 时间
}).

-define(WHEEL_PLAYER_BET_RECORD_TODAY, wheel_player_bet_record_today).
-record(key_wheel_player_bet_record_today, {
    player_id,
    type,
    id
}).
-record(idx_wheel_player_bet_record_today_by_player, {
    type,
    player_id
}).
-record(db_wheel_player_bet_record_today, {
    row_key, 
    player_id,                      %% int 玩家id
    type,                           %% int 类型
    id,                             %% int 玩家自增长id
    bet_num = 0,                    %% int 投注数量
    award_num = 0,                  %% int 投注奖励数量
    time = 0                        %% int 时间
}).

-define(WHEEL_POOL, wheel_pool).
-record(key_wheel_pool, {
    type
}).
-record(db_wheel_pool, {
    row_key, 
    type,                           %% int 类型
    value = 0,                      %% int 池子值
    id = 0                          %% int 当前id
}).

-define(WHEEL_RESULT_RECORD, wheel_result_record).
-record(key_wheel_result_record, {
    type,
    id
}).
-record(idx_wheel_result_record_by_type, {
    type
}).
-record(db_wheel_result_record, {
    row_key, 
    type,                           %% int 类型
    id,                             %% int id
    result_id = 0,                  %% int 结果id
    time = 0                        %% int 时间
}).

-define(WHEEL_RESULT_RECORD_ACCUMULATE, wheel_result_record_accumulate).
-record(key_wheel_result_record_accumulate, {
    type,
    u_id,
    record_type,
    id
}).
-record(idx_wheel_result_record_accumulate_1, {
    type,
    u_id,
    record_type
}).
-record(db_wheel_result_record_accumulate, {
    row_key, 
    type,                           %% int 类型
    u_id,                           %% int u_id期数
    record_type,                    %% int 记录类型(1:类型2:单体)
    id,                             %% int id
    num = 0,                        %% int 数量
    time = 0                        %% int 时间
}).
