%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            通用 ets 定义
%%% @end
%%% Created : 26. 五月 2016 下午 4:08
%%%-------------------------------------------------------------------

%% ----------------------------------
%% @doc 	oauth登录
%% @end
%% ----------------------------------
-define(ETS_OAUTH_STATE_JWT, ets_oauth_state_jwt).
-record(ets_oauth_state_jwt, {
    code = "",                %% code md5(platformId ++ accId)
    platformId = "",          %% 所属平台
    accId = "",               %% 玩家账号
    jwt = "",                 %% jwt
    recentServerList = []     %% 最近登录的服务器
}).

%% ----------------------------------
%% @doc 	前端获取setting.json时所需的versions与firstversions数据的ets
%% @end
%% ----------------------------------
-define(ETS_ERGET_SETTING, ets_erget_setting).
-record(ets_erget_setting, {
    app_id = "",                    %% app报名，如：com.goldenmaster.game
    platform = "",                  %% 平台名，如:local
    channel = "",                   %% 渠道名，如:local_test 必须是platform下辖的channel
    versions = "",                  %% 当客户端提交上来的版本号小于等于ets中的client_version时，使用该值作为setting数据中的versions
    firstversions = "",             %% jwt
    is_close_charge = 0,            %% 是否关闭充值
    is_native_pay = 0,              %% 是否开启商店充值
    client_version = "",            %% 客户端版本号，格式：x.yy x为大版本号（服务端大于客户端时，客户端冷更）,y为小版本号（服务端大于客户端时，客户端热更）
    android_download_url = "",      %% 安卓冷更包下载地址
    ios_download_url = "",          %% iOS冷更包下载地址
    reload_url = "",                %% 热更包下载地址
    status = 0,                     %% 状态，取值为0或1，是否进入审核游戏服，0时表示进入审核游戏服，反之则进入正常游戏服
    facebook_app_id = "",           %% facebook应用编号
    region = ""                     %% 隶属国家/地区
}).

%% ----------------------------------
%% @doc 	前端获取审核服资源版本号
%% @end
%% ----------------------------------
-define(ETS_EGRET_REVIEWING_VERSION, ets_egret_reviewing_version).
-record(ets_egret_reviewing_version, {
    app_id = "",                    %% app包名，如：com.arsham.t3
    reviewing_versions = ""         %% 审核服所使用的前端资源版本号
}).

%% ----------------------------------
%% @doc 	APP公告
%% @end
%% ----------------------------------
-define(ETS_APP_NOTICE, ets_app_notice).
-record(ets_app_notice, {
    row_key = {},                   %% {app_id, type, version中的大版本号}
    version = "",                   %% 版本号
    repeated = 0,                   %% 每次打开游戏是否显示 1为是，0为否
    updated_at = 0,                 %% 公告更新时间戳
    notice = ""                     %% 公告内容
}).

-define(ETS_DOMAIN, ets_domain).
-record(ets_domain, {
    app_id = "",
    domain = "",
    test_domain = ""
}).

%% ----------------------------------
%% @doc 	platformId与TrackerToken的对应关系
%% @end
%% ----------------------------------
-define(ETS_TRACKER_TOKEN, ets_tracker_token).
-record(ets_tracker_token, {
%%    row_key = {},           %% {platform_id, tracker_token}
    platform_id = "0",      %% 平台
    channel = "0",          %% 渠道
    tracker_token = "0"     %% tracker_token
}).

%% ----------------------------------
%% @doc 	currency与region、areaCode的对应关系
%% @end
%% ----------------------------------
-define(ETS_AREA_INFO, ets_area_info).
-record(ets_area_info, {
    currency = "",           %% 货币单位
    region = "",          %% 地区
    area_code = ""     %% 区号
}).

%% ----------------------------------
%% @doc 	region、areaCode与TrackerToken的对应关系
%% @end
%% ----------------------------------
-define(ETS_REGION_INFO, ets_region_info).
-record(ets_region_info, {
    tracker_token = "",      %% 渠道的tracker_token
    region = "",          %% 地区
    area_code = "",     %% 区号
    currency = ""           %% 货币单位
}).

%% ----------------------------------
%% @doc 	app相关信息 app所属国家/地区的电话区号 app中游戏前端资源的大小（单位：MB）
%% @end
%% ----------------------------------
-define(ETS_APP_INFO, ets_app_info).
-record(ets_app_info, {
    app_id = "",
    area_code = "",
    package_size = 0.00
}).

%% ----------------------------------
%% @doc 	中心服upgrade接口用来通过ip判断平台所需的数据
%% @end
%% ----------------------------------
-define(ETS_PLATFORM_SETTING, ets_platform_setting).
-record(ets_platform_setting, {
    platform = "",      %% 平台名，如:indonesia
    name = ""           %% 平台中文标识，如:印度尼西亚
}).

%% ----------------------------------
%% @doc 	中心服upgrade接口用来通过ip判断平台所需的数据
%% @end
%% ----------------------------------
-define(ETS_TEST_ACCOUNT, ets_test_account).
-record(ets_test_account, {
    account = "",           %% 测试账号
    privilege = 0           %% 是否为测试账号，0为否，1为是
}).

%% ----------------------------------
%% @doc 	玩家对象
%% @end
%% ----------------------------------
-define(ETS_OBJ_PLAYER, ets_obj_player).
-record(ets_obj_player, {
    id,                                 %% 玩家ID
    client_node,                        %% 玩家节点
    client_worker,                      %% 玩家进程 {}
    sender_worker,                      %% 玩家发送进程
    scene_worker = null,                %% 场景进程
    ip = "",
    scene_id = 0,                       %% 场景id
    room_worker = null,                         %% 房间进程
    room_type,
    room_id
}).

%% ----------------------------------
%% @doc    玩家离线场景缓存 (断线重连用)
%% @end
%% ----------------------------------
-define(ETS_OFFLINE_PLAYER_SCENE_CACHE, ets_offline_player_scene_cache).
-record(ets_offline_player_scene_cache, {
    player_id,
    scene_id,
    x,
    y,
    scene_worker,
    timestamp
}).

%% 玩家离线房间缓存
-define(ETS_OFFLINE_PLAYER_ROOM_CACHE, ets_offline_player_room_cache).
-record(ets_offline_player_room_cache, {
    player_id,
    room_type,
    room_id,
    room_worker,
    timestamp
}).

%%  玩家登录缓存
-define(ETS_LOGIN_CACHE, ets_login_cache).
-record(ets_login_cache, {
    account,
    ticket = null,
    promote = "",
    time = 0,
    app_id = "",
    region = "",
    registration_id = "",
    os_platform = ""
}).

%%  通用缓存数据
-define(ETS_CACHE, ets_cache_data).
-record(ets_cache, {
    id = 0,
    data = null,
    expire_time = 0,    %% 超时时间
    update_time = 0     %% 更新时间
}).

%%  平台玩家平台好友数据
-define(ETS_PLATFORM_FRIENDS_DATA, ets_platform_friends_data).
-record(ets_platform_friends_data, {
    player_id = 0,          % 玩家id
    friends_openid_list = [],   % 玩家好友openid列表
    request_time = 0            % 请求时间
}).

%% 玩家聊天信息
-define(ETS_PLAYER_CHAT_MSG, ets_player_chat_msg).
-record(ets_player_chat_msg, {
    player_id = 0,          % 玩家id
    msg = []                % 信息
}).

-define(RANK_COUNT_KEY_1, 1).    % 城主争夺
%% @fun 排行榜条数数据
-define(ETS_RANK_COUNT_RECORD, ets_rank_count_record).
-record(ets_rank_count_record, {
    row_key = {},               %% RANK_COUNT_KEY_1
    count = 0,                  %% 最后一名
    change_time = 0             %% 操作时间
}).

%% @fun 红包记录数据
-define(ETS_RED_PACKET_RECORD, ets_red_packet_record).
-record(ets_red_packet_record, {
    r_id = 0,   % 唯一id
    round = 0,  % 轮次
    id = 0,     % 红包id
    state = 0,  % 领取状态
    scene_rate = 0, % 场景倍率
    weapon_rate = 0 % 武器倍率
}).

%% 1v1数据结构
-define(ETS_BOSS_ONE_ON_ONE_RECORD, ets_boss_one_on_one_record).
-record(ets_boss_one_on_one_record, {
    row_key = {},     %% 主键
    winner = 0,      %% 获胜boss
    loser = 0,       %% 失败boss
    created_time = 0 %% 时间
}).

%% 客户端静态资源版本数据接口
-define(ETS_CLIENT_STATIC_RESOURCE_RECORD, ets_client_static_res_record).
-record(ets_client_static_resource_record, {
    row_key = {},           %% 主键 {app_id, version}
    app_id = "",            %% app_id 包名
    version = 0,            %% 静态资源版本号
    download = ""           %% 静态资源zip下载地址
}).

%% 调用装备交易平台支付接口时所需的token
-define(ETS_PROPS_TRADER_TOKEN, ets_props_trader_token).
-record(ets_props_trader_token, {
    row_key = {},           %% 主键 {username}
    username = "",          %% 登录名
    token = ""              %% token
}).

-define(ETS_CLIENT_HEARTBEAT_VERIFY, ets_client_heartbeat_verify).
-record(ets_client_heartbeat_verify, {
    row_key = {},           %% 主键 {platform_id, server_id}
    start_time = 0,         %% 起始时间戳
    expire = 0              %% 有效期 单位秒
}).
