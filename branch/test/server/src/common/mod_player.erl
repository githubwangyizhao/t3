%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家模块
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_player).
-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").
%%-include("msg.hrl").
-include("error.hrl").
-include("scene.hrl").
-include("p_enum.hrl").
-include("client.hrl").
-include("msg.hrl").
-include("server_data.hrl").
%%API
-export([
%%    get_try_fight_time/1,
%%    set_try_fight_time/2,
%%    get_player_list_by_acc_id/1,            %% 账户id找到玩家列表
    get_player_by_server_id_and_acc_id/2,   %% 账户id和服务器id找到玩家
    get_player_base_info_by_server_id_and_acc_id/2,
    get_player_list_by_nickname/1,          %% 使用昵称找到玩家列表
    get_player_id_by_server_id_nickname/2,  %% 根据区服和名字获得玩家id
    get_player_by_sid_and_nickname/2,       %% 通过区服id 和昵称寻找玩家
    create_role/8,                          %% 创建角色
    create_role/9,                          %% 创建角色
%%    create_role/7,
    get_player_id_list_by_channel/1,
    get_player_server_id/1,                 %% 获取玩家server_id
    is_common_account/1,                    %% 是否普通账号
    is_interval_account/1,                      %% 是否内部账号
    is_gm_account/1,                        %% 是否GM账号
    set_gm_account/1,                       %% 设置gm帐号
    do_set_account_type/2,
    init_server_data/1,
    change_name/2,                          %% 改名
    change_sex/2,                           %% 改性
    level_upgrade/1,                        %% 升级
    get_level_award/2,                      %% 获得等级奖励
%%    is_robot_account/1,                     %% 是否机器人账号
    get_account_type/1,                     %% 获取账号类型
    set_account_type/2,                     %% 设置账号类型
    get_player/1,                           %% 获取玩家记录
    get_db_player1/1,
    get_db_player_data/1,                      %% 获取玩家数据记录
    get_player_data/2,                      %% 获取玩家数据
    set_player_online_status/2,             %% 设置玩家在线状态
    get_player_info/1,                        %% 获取玩家信息（中心服调用， 请勿修改）
    reset_all_player_online_status/0,
    get_player_pf/1,                        %% 获取玩家子渠道
    get_atom_platform_and_pf/1,
    '_get_player_channel'/0,
    '_get_player_oauth_source'/0,
%%    set_disable_login/2,                    %% 封号下线, 解封
%%    set_disable_chat/2,                     %% 禁言
    set_forbid/3,                           %% 封禁
    is_can_login/1,                      %% 是否禁止登录
    is_can_chat/1,                       %% 是否禁止聊天
    record_login_info/3,                    %% 记录登录信息
    get_all_player_id/0,                    %% 获得全服全部玩家id
%%    get_all_robot_player_id/0,              %% 获得所有机器人玩家id
%%    get_all_dis_robot_player_id/0,          %% 获得所有非机器人玩家id
    get_all_player_data/0,                  %% 获得全服全部玩家player_data
    get_all_player/0,                       %% 获得全服全部玩家player
    get_player_channel/1,
    get_via/1,
%%    tran_qq_pf_2_channel/1,
%%    get_player_offline_time/1,              %% 获取玩家上次离线时间
    change_pk_mode/2,                       %% 修改pk模式
    update_player_offline_time/1,           %% 更新玩家离线时间
    update_player_total_online_time/2,      %% 更新累计在线时长
    get_player_name/1,                      %% 获得玩家名字（服务器名字 + 玩家昵称）
    get_player_name/2,                      %% 获得玩家名字（服务器名字 + 玩家昵称）
    get_player_name_to_binary/1,            %% 获得玩家名字 并转二进制(proto 需求)
    save_player_pos/4,                      %% 保存玩家数据
    check_str_common/2,                     % 检查字符串公共处理
    check_str_common/3,                     % 检查字符串公共处理
%%    give_hook_exp_and_coin/1,               %% 挂机给经验和铜钱
    is_robot_player_id/1,                   %% 是否机器人id
    set_player_data/3,                       %% 设置玩家数据
    get_player_anger_skill_effect_init/1,     %% 获取玩家怒气技能效果id
    get_player_anger_skill_effect_init/2,
    init_player_anger_skill_effect/1,          %% 重置怒气技能效果
    update_player_signature/2,
    world_tree_award/1                          %% 领取世界树奖励
%%    is_new_level_player/1                   %% 是否新手玩家
]).
-export([
    update_player_scene_stay_rewards/2,       %% 更新玩家滞留的奖励
    give_player_scene_stay_rewards/1,           %% 发放玩家在场景内滞留的部分奖励
    give_player_all_scene_stay_rewards/0         %% 发放玩家在场景内滞留的所有奖励
]).

-export([
    add_exp/3,                              %% 加经验
    add_level/3,                            %% 加等级
    add_vip_exp/3                         %% 设置vip等级
]).

-export([
    get_player_last_offline_time/1,         %% 获得玩家离线时间
    get_player_return_game_day_number/1,    %% 获得回归几天
    get_player_return_game_time/1,          %% 获得回归的时间
    set_player_return_game_time/1,          %% 设置回归的时间
    get_platform_id_and_server_id/1,        %% 获得平台id和服务器id
    update_player_server_data_init/3,       %% 更新玩家服务器数据
    get_game_player_server_id/1,            %% 获得玩家不在游戏机服的区服
    get_game_node/1                         %% 获得玩家不在游戏机服的游戏服节点
]).

-export([
    %% Client Data
    update_client_data/2,                   %% 更新客户端数据
    delete_client_data/2,                   %% 删除客户端数据
    get_db_player_client_data/2,
    get_db_player_client_data_list/1        %% 获得玩家客户端数据列表
]).

%% gm操作
-export([
    gm_player_change_accId/2        % 玩家账号互换
]).

-export([
    get_t_level/1,           % 等级
    get_t_ge_xing_hua/1
]).

-export([
    get_region_by_player_id/1
]).

-export([
    get_player_chat_info/1,
    handle_get_player_chat_info/1,
    handle_game_get_player_chat_info/1
]).

%% 修正
%%-export([
%%    get_player_adjust_rate/1,
%%    add_player_adjust_value/2,
%%    is_new_adjust/1,
%%    get_player_random_newbee_xiuzheng/1
%%]).
-define(ACTION_ADD_LEVEL, action_add_level).                %% 加等级
-define(ACTION_ADD_VIP_EXP, action_add_vip_exp).            %% 增加VIP经验
-define(ACTION_ADD_EXP, action_add_exp).                    %% 增加经验

-export([
    auto_create_role/3,                     %% 自动创角
    modify_nickname_gender/3,               %% 自动创角玩家可以修改一次性别与昵称
    is_player_auto_create/1                 %% 是否是自动注册玩家
]).

-record(?MODULE, {
    scene_delay_rewards = []          %% 玩家在场景内滞留的奖励
}).

%% ----------------------------------
%% @doc 	通过玩家账号，获取玩家手机系统
%% @throws 	none
%% @end
%% ----------------------------------
get_os_platform_by_acc_id(AccId) ->
    %% 登陆服获取登录缓存中的os_platform
    LoginServerNode = mod_server_config:get_login_server_node(),
    case rpc:call(LoginServerNode, ets, lookup, [?ETS_LOGIN_CACHE, AccId]) of
        [SettingInEts] when is_record(SettingInEts, ets_login_cache) ->
            SettingInEts#ets_login_cache.os_platform;
        [] ->
            ?OS_PLATFORM_ANDROID
    end.

%% ----------------------------------
%% @doc 	通过玩家编号，获取玩家所属国家地区
%% @throws 	none
%% @end
%% ----------------------------------
get_region_by_player_id(PlayerId) ->
    AccId =
        case get_db_player1(PlayerId) of
            Player when is_record(Player, db_player) -> Player#db_player.acc_id;
            _ -> ?UNDEFINED
        end,
    ?ASSERT(AccId =/= ?UNDEFINED, noop),
    %% 登陆服获取登录缓存中的Region
    LoginServerNode = mod_server_config:get_login_server_node(),
    case rpc:call(LoginServerNode, ets, lookup, [?ETS_LOGIN_CACHE, AccId]) of
        [SettingInEts] when is_record(SettingInEts, ets_login_cache) ->
            SettingInEts#ets_login_cache.region;
        [] ->
            "TWD"
    end.

auto_create_role(ServerId, AccId, Channel) ->
%%    ?DEBUG("ServerId: ~p AccId: ~p", [ServerId, AccId]),
%%    ok.
    % 是否已经创建角色
    ?ASSERT(get_player_by_server_id_and_acc_id(ServerId, AccId) == null, ?ERROR_ALREADY_CREATE_ROLE),
    OSPlatform = get_os_platform_by_acc_id(AccId),

    Sex = util_random:random_number(?SEX_MAN, ?SEX_WOMEN),
    {_, Nickname} = random_name:get_name(Sex),

    % 检查名字是否有效
    RealNickName =
        case catch check_nickname_valid(Nickname) of
            {'EXIT', ?ERROR_NAME_USED} ->
                LastWord = util_time:milli_timestamp() rem 90,
                LastWord1 = ?IF(LastWord < 65, util_random:random_number(65, 90), LastWord),
                ?DEBUG("LastWord1: ~p", [{LastWord1, LastWord, [LastWord1]}]),
                LastWord2 = util_time:milli_timestamp() rem 122,
                RealLastWord = [LastWord1] ++ [?IF(LastWord2 < 97, util_random:random_number(97, 122), LastWord2)],
                ?DEBUG("RealLastWord: ~p", [{RealLastWord, [RealLastWord]}]),
                Nickname ++ RealLastWord;
            {'EXIT', Other} -> ?ERROR("check_nickname_valid: ~p", [Other]), exit(Other);
            ok -> Nickname
        end,
    ?DEBUG("RealNickName: ~p", [RealNickName]),
    ?DEBUG("ServerId: ~p AccId: ~p NickName: ~p Sex: ~p Channel: ~p", [ServerId, AccId, Nickname, Sex, Channel]),
    PlayerId = create_role(ServerId, AccId, Nickname, Sex, OSPlatform, "", "", ?TRUE, Channel),
    ?INFO("~p auto create role. ServerId: ~p AccId: ~p", [PlayerId, ServerId, AccId]),

    % 平台id
    PlatformId = mod_server_config:get_platform_id(),
    %% 玩家数据写入中心服global_account
    ?TRY_CATCH(rpc:cast(mod_server_config:get_center_node(), mod_global_account, update_recent_server_list, [PlatformId, AccId, ServerId, ?TRUE])),
    put(?DICT_CHANNEL, Channel),
    mod_account:try_init_account(AccId, ServerId),
    mod_account:try_record_create_role(AccId, ServerId, PlayerId),
    ok.


%% ----------------------------------
%% @doc 	创建角色
%% @throws 	none
%% @end
%% ----------------------------------
create_role(ServerId, AccId, NickName, Sex, From, Extra, FriendCode, IsAuto, Channel) ->
    %%create_role(ServerId, AccId, NickName, Sex, From, Extra, ?ACCOUNT_TYPE_COMMON).
    %%create_role(ServerId, AccId, NickName, Sex, From, Extra, AccountType) ->
    ?ASSERT(Sex == ?SEX_MAN orelse Sex == ?SEX_WOMEN, sex_error),

    ?ASSERT(length(From) =< 20, {from_too_long, From}),
    % 是否已经创建角色
    ?ASSERT(get_player_by_server_id_and_acc_id(ServerId, AccId) == null, ?ERROR_ALREADY_CREATE_ROLE),

    % 检查名字是否有效
    check_nickname_valid(NickName),

    % 平台id
    PlatformId = mod_server_config:get_platform_id(),

    % 验证游戏服
    ?ASSERT(mod_server:get_game_server(PlatformId, ServerId) =/= null, {game_server_no_found, PlatformId, ServerId}),

    % 获取玩家唯一id
    PlayerId = unique_id:get_unique_player_id(),
    %%    PlayerId = util_time:timestamp(),
    put(?DICT_PLAYER_ID, PlayerId),
    % 创角时先加载热数据
    db_load:safe_load_hot_data(PlayerId),


    % 初始化角色数据
    ?INFO("create role channel: ~p", [Channel]),
    init_role_data(PlayerId, ServerId, AccId, NickName, Sex, From, ?IF(IsAuto =:= ?TRUE, ?ACCOUNT_TYPE_AUTO_CREATE_ROLE, ?ACCOUNT_TYPE_COMMON), Channel, FriendCode),

    hook:after_create_role(AccId, ServerId, PlayerId, Extra, FriendCode, NickName, PlatformId),

    PlayerId.
create_role(ServerId, AccId, NickName, Sex, From, Extra, FriendCode, IsAuto) ->
    Channel = '_get_player_channel'(),
    check_channel(Channel),
    create_role(ServerId, AccId, NickName, Sex, From, Extra, FriendCode, IsAuto, Channel).


%% ----------------------------------
%% @doc 	检查名字是否有效
%% @throws 	none
%% @end
%% ----------------------------------
check_nickname_valid(NickName) ->
    % 屏蔽字
%%    ?ASSERT(mod_server_rpc:call_war(util_string, is_match, [NickName]) == false, ?ERROR_INVAILD_NAME),
    % 非法字符
    ?ASSERT(util_string:is_valid_name(NickName) == true, ?ERROR_INVAILD_NAME),
    % 长度
    ?ASSERT(util_string:string_length(NickName) =< 14, ?ERROR_NAME_TOO_LONG),
    % 查重
    ?ASSERT(get_player_list_by_nickname(NickName) == [], ?ERROR_NAME_USED).

%% @doc fun 检查字符串公共处理
check_str_common(Str, MaxLen) ->
    check_str_common(Str, 1, MaxLen).
check_str_common(Str, MinLen, MaxLen) ->
    % 屏蔽字
    ?ASSERT(mod_server_rpc:call_war(util_string, is_match, [Str]) == false, ?ERROR_INVAILD_NAME),
    % 非法字符
    ?ASSERT(util_string:is_valid_string(Str) == true, ?ERROR_INVAILD_NAME),
    NameLen = util_string:string_length(Str),
    % 长度范围
    ?ASSERT(MinLen =< NameLen andalso NameLen =< MaxLen, ?ERROR_NAME_TOO_LONG),      % 名字长度过长
    true.

%% 获取渠道 (玩家进程调用)
'_get_player_channel'() ->
    get(?DICT_CHANNEL).
%%    PlatformId = mod_server_config:get_platform_id(),
%%    if
%%        PlatformId == ?PLATFORM_LOCAL ->
%% 测试渠道
%%            ?CHANNEL_LOCAL_TEST;
%%        PlatformId == ?PLATFORM_INDONESIA ->
%%            "fb";
%%        true ->
%%             混服
%%            get(?DICT_CHANNEL)
%%    end.

%% 获取授权登录来源 (玩家进程调用)
'_get_player_oauth_source'() ->
    PlatformId = mod_server_config:get_platform_id(),
    if
        PlatformId == ?PLATFORM_LOCAL ->
            %% 测试渠道
            "fb";
        true ->
            get(?DICT_ACCOUNT_SOURCE)
    end.

%%tran_qq_pf_2_channel(Pf) ->
%%    if
%%        Pf == "wanba_ts.105" orelse Pf == "weixin.105" ->
%%            %% 玩一玩
%%            ?CHANNEL_WYW;
%%        Pf == "wanba_ts.101"
%%            orelse Pf == "weixin.101"
%%            orelse Pf == "wanba_ts.102"
%%            orelse Pf == "weixin.102" ->
%%            %% 腾讯视频
%%            ?CHANNEL_QQ_VIDEO;
%%        Pf == "wanba_ts.113" orelse Pf == "weixin.114" ->
%%            %% 心悦
%%            ?CHANNEL_XY;
%%        Pf == "wanba_ts.111" orelse Pf == "weixin.112" ->
%%            %% 电竞
%%            ?CHANNEL_DJ;
%%        Pf == ?CHANNEL_QQ_GAME ->
%%            Pf;
%%        true ->
%%            ?CHANNEL_QQ
%%    end.

check_channel(Channel) ->
    PlatformId = mod_server_config:get_platform_id(),
    if PlatformId == ?PLATFORM_LOCAL orelse PlatformId == ?PLATFORM_TEST ->
        noop;
        true ->
            case t_channel:get({PlatformId, Channel}) of
                null ->
                    ?WARNING("channel_no_exists:~p", [{PlatformId, Channel}]);
                _ ->
                    noop
            end
%%            ?ASSERT(t_channel:get({PlatformId, Channel}) =/= null, {channel_no_exists, {PlatformId, Channel}})
    end.


get_via(PlayerId) ->
%%    PlatformId = mod_server_config:get_platform_id(),
    if
%%        PlatformId == ?PLATFORM_QQ ->
%%        AccId = get_player_data(PlayerId, acc_id),
%%        Via = mod_cache:get({?CACHE_QQ_VIA, AccId}, "null"),
%%        ?INFO("via:~p~n", [{PlayerId, AccId, Via}]),
%%        Via;
%%        util:to_list(get(?DICT_QQ_VIA));
        true ->
            get_player_channel(PlayerId)
    end.

%% ----------------------------------
%% @doc 	初始化角色数据
%% @throws 	none
%% @end
%% ----------------------------------
init_role_data(PlayerId, ServerId, AccId, NickName, Sex, From, AccountType, Channel, FriendCode) ->
    ?DEBUG("初始化角色数据~p", [{PlayerId, ServerId, AccId, NickName, Sex, From, AccountType, Channel, FriendCode}]),
    Tran =
        fun() ->
            Now = util_time:timestamp(),
            Player = #db_player{
                id = PlayerId,
                acc_id = AccId,
                server_id = ServerId,
                nickname = NickName,
                sex = Sex,
                reg_time = Now,
                type = AccountType,
                from = From,
                channel = Channel,
                friend_code = FriendCode,
                oauth_source = ?IF('_get_player_oauth_source'() =:= ?UNDEFINED, "fb", '_get_player_oauth_source'())
            },
            ?DEBUG("Player: ~p", [Player]),
            db:write(Player),

            InitSceneId = ?SD_INIT_SCENE_ID,
            [InitHeadId, InitHeadFrameId, InitChatQiPaoId] = ?SD_INIT_GE_XING_HUA_LIST,
            {BirthX, BirthY} = mod_scene:get_scene_birth_pos(InitSceneId),
            PlayerData = #db_player_data{
                player_id = PlayerId,
                exp = 0,
                level = 1,
                last_world_scene_id = InitSceneId,
                x = BirthX,
                y = BirthY,
                fight_mode = ?PK_MODE_PK_PEACE,
                mount_status = 0,
                honor_id = 0,
                speed = ?SD_INIT_SPEED,
                head_id = InitHeadId,
                head_frame_id = InitHeadFrameId,
                chat_qi_pao_id = InitChatQiPaoId
            },
            db:write(PlayerData),

%%            % 初始化任务
%%            mod_task:init(PlayerId),
%%
%%            % 初始化支线任务
%%            mod_branch_task:init(PlayerId),

            % 升级
            hook:after_level_upgrade(PlayerId, 0, 1, ?LOG_TYPE_GM),

            %% 创角给奖励 @todo 2021-07-24 创角奖励修改至玩家第一次进入主场景时发放
%%            mod_prop:add_player_prop(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_INGOT, ?SD_INIT_INGOT, ?LOG_TYPE_SYSTEM_SEND),
            mod_award:give(PlayerId, ?SD_INIT_REWARD_FIRST, ?LOG_TYPE_SYSTEM_SEND),

            %% 获得个性化系统初始奖励
            mod_award:give(PlayerId, logic_get_ge_xing_hua_init_award_list:assert_get(0), ?LOG_TYPE_SYSTEM_SEND),

            version:register_init_version(PlayerId),

            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_LEVEL_AWARD_ALREADY, 1)

%%            case ?IS_DEBUG of
%%                true ->
%%                    LocalTestPropAward = [[?PROP_TYPE_RESOURCES, ?RES_MANA, 10000000]] ++ lists:map(
%%                        fun({ItemId}) ->
%%                            [?PROP_TYPE_ITEM, ItemId, 100]
%%                        end, t_item:get_keys()
%%                    ),
%%                    mod_award:give(PlayerId, LocalTestPropAward, ?LOG_TYPE_SYSTEM_SEND);
%%                false ->
%%                    noop
%%            end
%%            mod_equip:dress(PlayerId, [110001, 210001, 310001, 410001, 510001, 610001, 710001, 810001], true)

        end,
    db:do(Tran).

is_player_auto_create(PlayerId) ->
    #db_player{
        type = Type
    } = get_player(PlayerId),
    Type =:= ?ACCOUNT_TYPE_AUTO_CREATE_ROLE.

modify_nickname_gender(PlayerId, Nickname, Gender) ->
    ?INFO("改名改性别:~p", [{PlayerId, Nickname, Gender}]),
    Player = get_player(PlayerId),
    PlatformId = mod_server_config:get_platform_id(),
    #db_player{
        acc_id = AccId,
        type = Type,
        nickname = OldNickname,
        sex = OldGender
    } = Player,
    ?ASSERT(Type =:= ?ACCOUNT_TYPE_AUTO_CREATE_ROLE, ?P_NOT_AUTHORITY),
    check_nickname_valid(Nickname),
    if
        OldNickname =:= Nickname andalso Gender =:= OldGender -> ok;
        true ->
            Tran =
                fun() ->
                    NewPlayer = Player#db_player{
                        nickname = Nickname,
                        sex = Gender,
                        type = ?ACCOUNT_TYPE_COMMON
                    },
                    db:write(NewPlayer),
                    mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_LAST_NAME, Nickname),
%%                    mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_NAME, get_player_name_to_binary(PlayerId)}]),
                    mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_NAME, util:to_binary(get_player_name(NewPlayer))}]),
                    hook:after_change_name(PlayerId, Nickname),
                    mod_server_rpc:call_center(mod_global_account, set_account_type, [PlatformId, AccId, ?ACCOUNT_TYPE_COMMON])
                end,
            Res = db:do(Tran),
            ?INFO("改名该性别结果: ~p", [Res]),
            ok
    end.

%% ----------------------------------
%% @doc 	改名
%% @throws 	none
%% @end
%% ----------------------------------
change_name(PlayerId, NickName) ->
    check_nickname_valid(NickName),
    DbPlayer = get_player(PlayerId),
    #db_player{
        nickname = LastNickname
    } = DbPlayer,
    mod_times:assert_times(PlayerId, ?TIMES_CHANGE_NAME),
    Tran = fun() ->
        NewPlayer = DbPlayer#db_player{nickname = NickName},
        db:write(NewPlayer),
        mod_times:use_times(PlayerId, ?TIMES_CHANGE_NAME),
        mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_LAST_NAME, LastNickname),
        mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_NAME, util:to_binary(get_player_name(NewPlayer))}]),
        hook:after_change_name(PlayerId, NickName)
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	改性
%% @throws 	none

%% @end
%% ----------------------------------
change_sex(PlayerId, Sex) ->
    ?INFO("改性别:~p", [{PlayerId, Sex}]),
    ?ASSERT(Sex == ?SEX_MAN orelse Sex == ?SEX_WOMEN, sex_error),
    Player = get_player(PlayerId),
    Tran = fun() ->
        %%        @TODO 变性卡屏蔽
%%        mod_prop:decrease_player_prop(PlayerId, ?PROP_TYPE_ITEM, ?ITEM_BIAN_XING_CARD, 1, ?LOG_TYPE_USE_ITEM),
        db:write(Player#db_player{
            sex = Sex
        }),
        mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_SEX, Sex}])
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	领取世界树奖励
%% @throws 	none
%% @end
%% ----------------------------------
world_tree_award(PlayerId) ->
    mod_times:assert_times(PlayerId, ?TIMES_SHAKE_TREE),
    Tran =
        fun() ->
            mod_times:use_times(PlayerId, ?TIMES_SHAKE_TREE),
            BasePropList = ?SD_WORLDTREE_REWARD,
            % 玩家等级奖励加成
            PlayerLevel = mod_player:get_player_data(PlayerId, level),
            #t_role_experience{
                world_three = PlayerLvEffect
            } = t_role_experience:assert_get({PlayerLevel}),
            %% 解锁英雄奖励加成
            DbPlayerHeroList = mod_hero:get_db_player_hero_list_by_player(PlayerId),
            UnlockHeroEffectTotal =
                lists:foldl(
                    fun(#db_player_hero{hero_id = ThisHeroId}, HeroEffectTotal) ->
                        #t_hero{
                            world_tree = ThisHeroEffect
                        } = t_hero:assert_get({ThisHeroId}),
                        HeroEffectTotal + ThisHeroEffect
                    end,
                    0,
                    DbPlayerHeroList
                ),

            RealPropList = mod_prop:rate_prop(BasePropList, 1 + (PlayerLvEffect + UnlockHeroEffectTotal) / 10000),
            mod_award:give(PlayerId, RealPropList, ?LOG_TYPE_SHAKE_TREE),
            {ok, RealPropList}
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	获取玩家渠道
%% @throws 	none
%% @end
%% ----------------------------------
get_player_channel(PlayerId) ->
    Player = get_player(PlayerId),
    Player#db_player.channel.

%% ----------------------------------
%% @doc 	是否普通账号
%% @throws 	none
%% @end
%% ----------------------------------
is_common_account(PlayerId) ->
    get_account_type(PlayerId) == ?ACCOUNT_TYPE_COMMON.

%% ----------------------------------
%% @doc 	是否内部账号
%% @throws 	none
%% @end
%% ----------------------------------
is_interval_account(PlayerId) ->
    get_account_type(PlayerId) == ?ACCOUNT_TYPE_INTERVAL.

%% ----------------------------------
%% @doc 	是否GM账号
%% @throws 	none
%% @end
%% ----------------------------------
is_gm_account(PlayerId) ->
    get_account_type(PlayerId) == ?ACCOUNT_TYPE_GM.

%% ----------------------------------
%% @doc 	是否GM账号
%% @throws 	none
%% @end
%% ----------------------------------
set_gm_account(PlayerId) ->
    case mod_online:is_online(PlayerId) of
        true ->
            mod_apply:apply_to_online_player(PlayerId, mod_player, do_set_account_type, [PlayerId, ?ACCOUNT_TYPE_GM]);
        false ->
            do_set_account_type(PlayerId, ?ACCOUNT_TYPE_GM)
    end.

do_set_account_type(PlayerId, Type) ->
    Player = get_player(PlayerId),
    Tran = fun() ->
        db:write(Player#db_player{
            type = Type
        })
           end,
    db:do(Tran).

%%
%%%% ----------------------------------
%%%% @doc 	是否机器人账号
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%is_robot_account(PlayerId) ->
%%    get_account_type(PlayerId) == ?ACCOUNT_TYPE_ROBOT.

%% ----------------------------------
%% @doc 	获取账号类型
%% @throws 	none
%% @end
%% ----------------------------------
get_account_type(PlayerId) ->
    Player = get_player(PlayerId),
    Player#db_player.type.

%% ----------------------------------
%% @doc 	设置账号类型
%% @throws 	none
%% @end
%% ----------------------------------
set_account_type(PlayerId, Type) ->
    ?ASSERT(lists:member(Type, [?ACCOUNT_TYPE_COMMON, ?ACCOUNT_TYPE_INTERVAL])),
    Player = get_player(PlayerId),
    Tran = fun() ->
        db:write(Player#db_player{type = Type})
           end,
    db:do(Tran),
    ok.

%% @doc     是否机器人id
is_robot_player_id(PlayerId) ->
    PlayerId < 10000.
%%    logic_get_is_robot:get(PlayerId) == true.
%%    lists:member(PlayerId, mod_robot_data:logic_get_robot_id_list()).


get_player_data(PlayerId, sex) ->
    Player = get_player(PlayerId),
    Player#db_player.sex;

get_player_data(PlayerId, total_recharge_ingot) ->
    Player = get_player(PlayerId),
    Player#db_player.total_recharge_ingot;
get_player_data(PlayerId, reg_time) ->
    Player = get_player(PlayerId),
    Player#db_player.reg_time;
get_player_data(PlayerId, last_login_time) ->
    Player = get_player(PlayerId),
    Player#db_player.last_login_time;
get_player_data(PlayerId, last_offline_time) ->
    Player = get_player(PlayerId),
    Player#db_player.last_offline_time;
get_player_data(PlayerId, acc_id) ->
    Player = get_player(PlayerId),
    Player#db_player.acc_id;
get_player_data(PlayerId, server_id) ->
    Player = get_player(PlayerId),
    Player#db_player.server_id;
get_player_data(PlayerId, cumulative_day) ->
    Player = get_player(PlayerId),
    Player#db_player.cumulative_day;

get_player_data(PlayerId, Term) when is_integer(PlayerId) ->
    PlayerData = get_db_player_data(PlayerId),
%%    ?DEBUG("PlayerId, Term:~p~n", [{PlayerId, Term, PlayerData}]),
    case Term of
        level ->
            PlayerData#db_player_data.level;
        power ->
            PlayerData#db_player_data.power;
        head_id ->
            PlayerData#db_player_data.head_id;
        pk_mode ->
            PlayerData#db_player_data.fight_mode;
        anger ->
            PlayerData#db_player_data.anger;
        is_mount ->
            PlayerData#db_player_data.mount_status;
        title_id ->
            PlayerData#db_player_data.title_id;
        honor_id ->
            PlayerData#db_player_data.honor_id;
        pk ->
            PlayerData#db_player_data.pk;
        game_event_id ->
            PlayerData#db_player_data.game_event_id;
        vip_level ->
            PlayerData#db_player_data.vip_level
    end.

%% ----------------------------------
%% @doc 	修改pk模式
%% @throws 	none
%% @end
%% ----------------------------------
change_pk_mode(PlayerId, PkMode) ->
    PlayerData = get_db_player_data(PlayerId),
    TPkMode = t_pk_mode:get({PkMode}),
    ?ASSERT(TPkMode =/= null, {pk_mode_no_found, PkMode}),
    if PlayerData#db_player_data.fight_mode == PkMode ->
        noop;
        true ->
            Tran = fun() ->
                db:write(PlayerData#db_player_data{
                    fight_mode = PkMode
                })
                   end,
            db:do(Tran),
            api_player:notice_player_attr_change(PlayerId, [{?P_PK_MODE, PkMode}]),
            mod_scene:push_player_data_2_scene(PlayerId, [{?MSG_SYNC_PK_MODE, PkMode}])
    end.

%% ----------------------------------
%% @doc 	封禁
%% @throws 	none
%% @end
%% ----------------------------------
set_forbid(PlayerId, Type, Sec) ->
    Player = get_player(PlayerId),
    case Type of
        ?FORBID_TYPE_NONE -> %% 无
            Tran =
                fun() ->
                    db:write(Player#db_player{
                        forbid_type = Type,
                        forbid_time = 0
                    })
                end,
            db:do(Tran);
        ?FORBID_TYPE_DISABLE_CHAT -> %% 禁言
            Tran =
                fun() ->
                    db:write(Player#db_player{
                        forbid_type = Type,
                        forbid_time = util_time:timestamp() + Sec
                    })
                end,
            db:do(Tran);
        ?FORBID_TYPE_DISABLE_LOGIN -> %% 封号
            Tran =
                fun() ->
                    db:write(Player#db_player{
                        forbid_type = Type,
                        forbid_time = util_time:timestamp() + Sec
                    })
                end,
            db:do(Tran),
            case mod_obj_player:get_obj_player(PlayerId) of
                null ->
                    noop;
                ObjPlayer ->
                    %% 下线
                    #ets_obj_player{
                        client_worker = ClientWorker
                    } = ObjPlayer,
                    client_worker:kill_async(ClientWorker, ?CSR_DISABLE_LOGIN)
            end
    end,
    ok.

%% ----------------------------------
%% @doc 	是否可以登录
%% @throws 	none
%% @end
%% ----------------------------------
is_can_login(PlayerId) when is_integer(PlayerId) ->
    is_can_login(mod_player:get_player(PlayerId));
is_can_login(Player) ->
    #db_player{
        forbid_type = ForbidType,
        forbid_time = ForbidTime
    } = Player,
    ForbidType =/= ?FORBID_TYPE_DISABLE_LOGIN orelse util_time:timestamp() > ForbidTime.

%% ----------------------------------
%% @doc 	是否可以聊天
%% @throws 	none
%% @end
%% ----------------------------------
is_can_chat(PlayerId) when is_integer(PlayerId) ->
    is_can_chat(mod_player:get_player(PlayerId));
is_can_chat(Player) ->
    #db_player{
        forbid_type = ForbidType,
        forbid_time = ForbidTime
    } = Player,
    ForbidType == ?FORBID_TYPE_NONE orelse util_time:timestamp() > ForbidTime.

%%%% ----------------------------------
%%%% @doc 	获取玩家离线时间
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_player_offline_time(PlayerId) ->
%%    Player = get_player(PlayerId),
%%    Player#db_player.last_offline_time.


%% ----------------------------------
%% @doc 	更新玩家离线时间
%% @throws 	none
%% @end
%% ----------------------------------
update_player_offline_time(PlayerId) ->
    Player = get_player(PlayerId),
    Tran = fun() ->
        db:write(Player#db_player{last_offline_time = util_time:timestamp()})
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	更新累计在线时长
%% @throws 	none
%% @end
%% ----------------------------------
update_player_total_online_time(PlayerId, Time) ->
    Player = get_player(PlayerId),
    Tran = fun() ->
        NewOnlineTime = Time + Player#db_player.total_online_time,
        db:write(Player#db_player{total_online_time = NewOnlineTime})
           end,
    db:do(Tran).


%% ----------------------------------
%% @doc 	设置玩家在线状态
%% @throws 	none
%% @end
%% ----------------------------------
set_player_online_status(PlayerId, Status) ->
    Player = get_player(PlayerId),
    Tran =
        fun() ->
            db:write(Player#db_player{is_online = Status})
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc     重置所有玩家在线状态
%% @throws 	none
%% @end
%% ----------------------------------
reset_all_player_online_status() ->
    Tran = fun() ->
        lists:foreach(
            fun(PlayerId) ->
                Player = get_player(PlayerId),
                if Player#db_player.is_online =/= ?FALSE ->
                    db:write(Player#db_player{is_online = ?FALSE});
                    true ->
                        noop
                end
            end,
            get_all_player_id()
        )
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	记录登录信息
%% @throws 	none
%% @end
%% ----------------------------------
record_login_info(PlayerId, LoginTime, Ip) ->
    Player = get_player(PlayerId),
    #db_player{
        last_login_time = LastLoginTime,
        last_offline_time = LastOfflineTime,
        cumulative_day = OldCumulativeDay,
        continuous_day = OldContinuousDay,
        login_times = OldLoginTimes
    } = Player,
    LastLoginIsToday = util_time:is_today(LastLoginTime),
    NewCumulativeDay =
        case LastLoginIsToday of
            true ->
                OldCumulativeDay;
            false ->
                OldCumulativeDay + 1
        end,
    NewContinuousDay =
        case LastLoginIsToday of
            true ->
                OldContinuousDay;
            false ->
                case util_time:is_yesterday(LastLoginTime) of
                    true ->
                        OldContinuousDay + 1;
                    false ->
                        1
                end
        end,
    NewLoginTimes = OldLoginTimes + 1,
    OSPlatform = get_os_platform_by_acc_id(Player#db_player.acc_id),
    Tran = fun() ->
        db:write(Player#db_player{
            last_login_time = LoginTime,
            last_login_ip = Ip,
            cumulative_day = NewCumulativeDay,
            continuous_day = NewContinuousDay,
            login_times = NewLoginTimes,
            from = OSPlatform
        })
           end,
    db:do(Tran),
    {LastLoginIsToday, util_time:is_today(LastOfflineTime)}.

%% @fun 设置回归的时间
set_player_return_game_time(PlayerId) ->
    #db_player{
        last_offline_time = LastOfflineTime,
        reg_time = RegTime
    } = mod_player:get_player(PlayerId),
    OfflineDayTime = max(RegTime, LastOfflineTime),
    IntervalDay = util_time:get_interval_day_add_1(OfflineDayTime),
    if
        IntervalDay >= 8 ->
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_RETURN_GAME_TIME, util_time:timestamp());
        true ->
            noop
    end.
%% @fun 获得回归的时间
get_player_return_game_time(PlayerId) ->
    mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_RETURN_GAME_TIME).
%% @fun 获得玩家回归的天数
get_player_return_game_day_number(PlayerId) ->
    case get_player_return_game_time(PlayerId) of
        0 ->
            0;
        Time ->
            util_time:get_interval_day_add_1(Time)
    end.

%% @fun 获得玩家离线时间
get_player_last_offline_time(PlayerId) ->
    #db_player{
        last_offline_time = LastOfflineTime1
    } = mod_player:get_player(PlayerId),
    LastOfflineTime = ?IF(mod_online:is_online(PlayerId), 0, LastOfflineTime1),
    {ok, LastOfflineTime}.

%%%% ----------------------------------
%%%% @doc 	获取player
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_player_list_by_acc_id(AccId) ->
%%    db:select(player, [{#db_player{acc_id = AccId, _ = '_'}, [], ['$_']}]).

get_player_by_server_id_and_acc_id(ServerId, AccId) ->
    case db_index:get_rows(#idx_player_2{acc_id = AccId, server_id = ServerId}) of
        [] ->
            null;
        [R] ->
            R
    end.

%% web 调用
get_player_base_info_by_server_id_and_acc_id(ServerId, AccId) ->
    case get_player_by_server_id_and_acc_id(ServerId, AccId) of
        null ->
            null;
        Player ->
            PlayerId = Player#db_player.id,
            PlayerLevel = get_player_data(PlayerId, level),
            {
                PlayerId,
                Player#db_player.nickname,
                PlayerLevel
            }
    end.

get_player_list_by_nickname(NickName) ->
    case db_index:get_rows(#idx_player_1{nickname = NickName}) of
%%    case db:select(?PLAYER, [{#db_player{nickname = '$2', _ = '_'}, [{'==', '$2', NickName}], ['$_']}]) of
        [] ->
            db_index:get_rows(#idx_robot_player_data_1{nickname = NickName});
        R ->
            R
    end.

%% @fun 根据区服和名字获得玩家id
get_player_id_by_server_id_nickname(ServerId, NickName) ->
    PlayerIdTuple =
        case get_player_by_sid_and_nickname(ServerId, NickName) of
            #db_player{id = PlayerId2, sex = Sex} ->
                {PlayerId2, Sex};
            _ ->
                {}
        end,
%%        lists:foldl(
%%            fun(Player, PlayerIdTuple1) ->
%%                case Player of
%%%%                    #db_player{server_id = ServerId, id = PlayerId2, sex = Sex} ->
%%                    #db_player{id = PlayerId2, sex = Sex} ->
%%                        {PlayerId2, Sex};
%%                    _ ->
%%                        PlayerIdTuple1
%%                end
%%            end, {}, get_player_by_sid_and_nickname(ServerId, NickName)),
    {ok, PlayerIdTuple}.

%% ----------------------------------
%% @doc 	通过区服id 和昵称寻找玩家
%% @throws 	none
%% @end
%% ----------------------------------
get_player_by_sid_and_nickname(Sid, Nickname) ->
    case db:select(?PLAYER, [{#db_player{server_id = '$1', nickname = '$2', _ = '_'}, [{'andalso', {'==', Sid, '$1'}, {'==', '$2', Nickname}}], ['$_']}]) of
        [] ->
            null;
        [R] ->
            R
    end.


%% 获得全服全部玩家id
get_all_player_id() ->
    MatchSpec = [{#db_player{id = '$1', _ = '_'}, [], ['$1']}],
    db:select(player, MatchSpec).

%%%% 获得所有机器人玩家id
%%get_all_robot_player_id() ->
%%    MatchSpec = [{#db_player{id = '$1', type = ?ACCOUNT_TYPE_ROBOT, _ = '_'}, [], ['$1']}],
%%    db:select(player, MatchSpec).

%% 获得所有非机器人玩家id
%%get_all_dis_robot_player_id() ->
%%    MatchSpec = [{#db_player{id = '$1', type = '$2', _ = '_'}, [{'=/=', '$2', ?ACCOUNT_TYPE_ROBOT}], ['$1']}],
%%    db:select(player, MatchSpec).

%% 获得全服全部玩家player_data
get_all_player_data() ->
    ets:tab2list(player_data).

%% 获得全服全部玩家player
get_all_player() ->
    ets:tab2list(player).

get_player_id_list_by_channel(ChannelList0) ->
    ChannelList = [util:to_list(E) || E <- ChannelList0],
    PlayerIdList = lists:foldl(
        fun(Player, Tmp) ->
            #db_player{
                id = PlayerId,
                channel = Channel
            } = Player,
            case lists:member(Channel, ChannelList) of
                true ->
                    [PlayerId | Tmp];
                false ->
                    Tmp
            end
        end,
        [],
        mod_player:get_all_player()
    ),
    PlayerIdList.

%% ----------------------------------
%% @doc 	保存玩家数据
%% @throws 	none
%% @end
%% ----------------------------------
save_player_pos(PlayerId, SceneId, X, Y) ->
    PlayerData = get_db_player_data(PlayerId),
    Tran = fun() ->
        db:write(
            PlayerData#db_player_data{
                last_world_scene_id = SceneId,
                x = X,
                y = Y
            }
        )
           end,
    db:do(Tran).


%% ----------------------------------
%% @doc 	获得玩家名字 (服务器名字 + 玩家昵称)
%% @throws 	none
%% @param 	none
%% @end
%% ----------------------------------
get_player_name(0) ->
    "";
get_player_name(PlayerId) when PlayerId < 10000 ->
    #obj_scene_actor{
        server_id = ServerId,
        nickname = Nickname
    } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    get_player_name(ServerId, Nickname);
get_player_name(PlayerId) when is_integer(PlayerId) ->
    get_player_name(get_player(PlayerId));
get_player_name(Player) ->
    ServerId = Player#db_player.server_id,
    Nickname = Player#db_player.nickname,
    get_player_name(ServerId, Nickname).
get_player_name(ServerId, Nickname) ->
    ServerId ++ "." ++ Nickname.

%% @fun 获得玩家名字 并转二进制(proto 需求)
get_player_name_to_binary(PlayerId) ->
    Nickname = get_player_name(PlayerId),
    util:to_binary(Nickname).


%%%% ----------------------------------
%%%% @doc 	是否新手玩家
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%is_new_level_player(PlayerId) ->
%%    get_player_data(PlayerId, level) =< 50.

%% ----------------------------------
%% @doc 	加经验
%% @throws 	none
%% @end
%% ----------------------------------
add_exp(PlayerId, Value, LogType) when Value > 0 ->
    update_player_data(PlayerId, ?ACTION_ADD_EXP, Value, LogType);
add_exp(_, _, _) ->
    noop.

%% ----------------------------------
%% @doc 	加等级
%% @throws 	none
%% @end
%% ----------------------------------
add_level(PlayerId, Value, LogType) when Value > 0 ->
    update_player_data(PlayerId, ?ACTION_ADD_LEVEL, Value, LogType);
add_level(_, _, _) ->
    noop.

%% ----------------------------------
%% @doc 	增加VIP经验
%% @throws 	none
%% @end
%% ----------------------------------
add_vip_exp(PlayerId, Value, LogType) when Value > 0 ->
    update_player_data(PlayerId, ?ACTION_ADD_VIP_EXP, Value, LogType);
add_vip_exp(_, _, _) ->
    noop.

%% ----------------------------------
%% @doc 	更新Player_data
%% @throws 	none
%% @end
%% ----------------------------------
update_player_data(PlayerId, ActionType, Value, LogType) when is_integer(PlayerId) ->
    update_player_data(db:read(#key_player_data{player_id = PlayerId}), ActionType, Value, LogType);
update_player_data(PlayerData, ActionType, Value, LogType) ->
    Tran =
        fun() ->
            #db_player_data{
                player_id = PlayerId,
                level = NowLevel,
                exp = NowExp,
                vip_level = VipLevel
            } = PlayerData,
            case ActionType of
                %% 等级
                ?ACTION_ADD_LEVEL when Value > 0 ->
                    NewLevel = NowLevel + Value,
%%                    ?ASSERT(NewLevel =< ?SSD_LEVEL_LIMIT, ?ERROR_MAX_LEVEL),
                    NewPlayerData = PlayerData#db_player_data{level = NewLevel},
                    db:write(NewPlayerData),
                    hook:after_level_upgrade(PlayerId, PlayerData#db_player_data.level, NewLevel, LogType),
                    F = fun() ->
%%                        api_player:send_level_upgrade(PlayerId, ?P_SUCCESS, NowLevel, NewLevel, AwardList),
                        api_player:notice_player_attr_change(PlayerId, [{?P_LEVEL, NewLevel}])
                        end,
                    db:tran_apply(F);
%%                    mod_attr:refresh_player_data(PlayerId, true);
                %% 经验
                ?ACTION_ADD_EXP when Value > 0 ->
                    ExpAddPer =
                        if
                            VipLevel > 0 ->
                                #t_vip_level{
                                    exp_add_per = ExpAddPer0
                                } = t_vip_level:assert_get({VipLevel}),
                                ExpAddPer0;
                            true ->
                                10000
                        end,
                    NewExp_0 = NowExp + Value * ExpAddPer div 10000,
                    {NewLevel, NewExp_1} = calc_level_and_exp(NowLevel, NewExp_0),
                    NewPlayerData = PlayerData#db_player_data{exp = NewExp_1, level = NewLevel},
                    db:write(NewPlayerData),
                    if
                    %% 升级
                        NowLevel =/= NewLevel ->
                            db:tran_apply(
                                fun() ->
                                    api_player:notice_player_attr_change(PlayerId, [{?P_LEVEL, NewLevel}, {?P_EXP, NewExp_1}])
                                end
                            ),
                            hook:after_level_upgrade(PlayerId, NowLevel, NewLevel, LogType);
                        true ->
                            db:tran_apply(
                                fun() ->
                                    api_player:notice_player_attr_change(PlayerId, [{?P_EXP, NewExp_1}])
                                end
                            )
                    end;
%%                    mod_attr:refresh_player_data(PlayerId, true);
                %% vip等级
                ?ACTION_ADD_VIP_EXP ->
                    mod_vip:test_fun_change(PlayerId, Value, LogType)
            end
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc     计算新等级和经验
%% @throws 	none
%% @end
%% ----------------------------------
calc_level_and_exp(NowLevel, NowExp) ->
    #t_role_experience{
        experience = NeedExp,
        next_level = NextLevel
    } = get_t_level(NowLevel),
    if NextLevel == 0 ->
        %% 最大等级时不累计经验
        {NowLevel, min(NowExp, NeedExp)};
        true ->
            if
                NowExp > NeedExp ->
                    calc_level_and_exp(NextLevel, NowExp - NeedExp);
                NowExp == NeedExp ->
                    {NextLevel, 0};
                NowExp < NeedExp ->
                    {NowLevel, NowExp}
            end
    end.

%%get_sys_attr_list(PlayerId) ->
%%%%    PlayerData = mod_player:get_player_data(PlayerId),
%%%%	#db_player{
%%%%		sex = Sex
%%%%	} = mod_player:get_player(PlayerId),
%%%%    #db_player_data{
%%%%        level = Level
%%%%    } = PlayerData,
%%%%	RoleId = case Sex of
%%%%				 ?SEX_MAN ->
%%%%					 ?ROLE_NEW_MAN;
%%%%				 ?SEX_WOMEN ->
%%%%					 ?ROLE_NEW_WOMEN
%%%%			 end,
%%    Level = get_player_data(PlayerId, level),
%%    #t_role_attr{
%%        attack = InitAttack,
%%        defense = InitDefense,
%%        hp = InitHp,
%%        hit = Hit,
%%        dodge = Dodge,
%%        crit = Crit,
%%        resist_crit = Tenacity
%%    } = try_get_t_role_attr(Level),
%%%%    Rate = Level - 1,
%%%%    Attack = InitAttack + AttackGrow * Rate,
%%%%    Defense = InitDefense + DefenseGrow * Rate,
%%%%    Hp = InitHp + HpGrow * Rate,
%%    [
%%        {?ATTR_HP, InitHp},
%%        {?ATTR_ATTACK, InitAttack},
%%        {?ATTR_DEFENSE, InitDefense},
%%        {?ATTR_HIT, Hit},
%%        {?ATTR_DODGE, Dodge},
%%        {?ATTR_CRIT, Crit},
%%        {?ATTR_RESIST_CRIT, Tenacity}
%%    ].

%%%% ----------------------------------
%%%% @doc 	挂机给经验和铜钱
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%give_hook_exp_and_coin(PlayerId) ->
%%    Chapter = mod_mission:get_player_zhu_xian_id(PlayerId),
%%    SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
%%
%%    IsGive =
%%        if SceneId > 0 ->
%%            case mod_scene:get_scene_type(SceneId) of
%%                ?SCENE_TYPE_MISSION ->
%%                    %% 副本里面不给挂机经验
%%                    false;
%%                _ ->
%%                    true
%%            end;
%%            true ->
%%                false
%%        end,
%%    if IsGive ->
%%%%        ?DEBUG("挂机给经验和铜钱:~p~n", [PlayerId]),
%%        #t_chapter{
%%            offline_coin = OfflineCoin,
%%            offline_exp = OfflineExp
%%        } = mod_task:get_t_chapter(Chapter),
%%        mod_award:give(PlayerId, [{?PROP_TYPE_RESOURCES, ?RES_COIN, OfflineCoin}, {?PROP_TYPE_RESOURCES, ?RES_EXP, OfflineExp}], ?LOG_TYPE_HOOK);
%%        true ->
%%            noop
%%    end.

%% ----------------------------------
%% @doc 	获取玩家server_id
%% @throws 	none
%% @end
%% ----------------------------------
get_player_server_id(PlayerId) ->
    Player = get_player(PlayerId),
    Player#db_player.server_id.

%% ----------------------------------
%% @doc 	获取玩家渠道(玩家进程内)
%% @throws 	none
%% @end
%% ----------------------------------
get_player_pf(_PlayerId) ->
%%    Player = mod_player:get_player(PlayerId),
%%    Player#db_player.channel.
    get(?DICT_CHANNEL).


get_atom_platform_and_pf(PlayerId) ->
    case get_player_pf(PlayerId) of
        "" ->
            util:to_atom(mod_server_config:get_platform_id());
        ?UNDEFINED ->
            util:to_atom(mod_server_config:get_platform_id());
        Pf ->
            util:to_atom(mod_server_config:get_platform_id() ++ "_" ++ Pf)
    end.

%% ----------------------------------
%% @doc 	获取玩家信息（中心服调用， 请勿修改）
%% @throws 	none
%% @end
%% ----------------------------------
get_player_info(PlayerId) ->
    case mod_player:get_player(PlayerId) of
        null ->
            {error, null};
        Player ->
            #db_player{
                reg_time = CreateTime,
                nickname = Nickname
            } = Player,
            #db_player_data{
                level = Level,
                power = Power
            } = mod_player:get_db_player_data(PlayerId),
            {ok, {CreateTime, Nickname, Level, Power}}
    end.

%% @fun 获得平台id和服务器id
get_platform_id_and_server_id(PlayerId) ->
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_GAME ->
            case get_player(PlayerId) of
                null ->
                    mod_server_rpc:call_war(?MODULE, get_platform_id_and_server_id, [PlayerId]);
                _ ->
                    PlatformId = mod_server_config:get_platform_id(),
                    ServerId = get_player_server_id(PlayerId),
                    {PlatformId, ServerId}
            end;
        _ ->
            #db_player_server_data{
                platform_id = PlatformId,
                server_id = ServerId
            } = get_player_server_data_init(PlayerId),
            {PlatformId, ServerId}
    end.

%% @fun 更新玩家服务器数据
update_player_server_data_init(PlayerId, PlatformId, ServerId) ->
    PlayerServerDataInit = get_player_server_data_init(PlayerId),
    Tran =
        fun() ->
            db:write(PlayerServerDataInit#db_player_server_data{platform_id = PlatformId, server_id = ServerId})
        end,
    db:do(Tran).

%% @fun 获得玩家不在游戏机服的游戏服节点
get_game_node(PlayerId) ->
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_GAME ->
            node();
        _ ->
            #db_player_server_data{
                platform_id = PlatformId,
                server_id = ServerId
            } = get_player_server_data_init(PlayerId),
            mod_server:get_game_node(PlatformId, ServerId)
    end.

%% @fun 获得玩家不在游戏机服的区服
get_game_player_server_id(PlayerId) ->
    #db_player_server_data{
        server_id = ServerId
    } = get_player_server_data_init(PlayerId),
    ServerId.

%% ================================================ Client Data ================================================

%% @doc 更新玩家客户端数据
update_client_data(PlayerId, ClientDataList) ->
    Tran =
        fun() ->
            lists:foreach(
                fun(ClientData) ->
                    {Id, Value} = ClientData,
                    case get_db_player_client_data(PlayerId, util:to_list(Id)) of
                        null ->
                            noop;
                        DbPlayerClientData ->
                            case "k_jpush_status" == util:to_list(Id) of
                                true ->
                                    spawn(
                                        fun() ->
                                            #db_player{
                                                acc_id = AccId
                                            } = get_player(PlayerId),
                                            mod_tui_song:set_no_push_account(mod_server_config:get_platform_id(), AccId)
                                        end
                                    );
                                false ->
                                    noop
                            end,
                            db:write(DbPlayerClientData#db_player_client_data{value = util:to_list(Value)})
                    end
                end,
                ClientDataList
            )
        end,
    db:do(Tran),
    ok.

%% @doc 删除玩家客户端数据
delete_client_data(PlayerId, IdList) ->
    Tran =
        fun() ->
            lists:foreach(
                fun(Id) ->
                    case db:read(#key_player_client_data{player_id = PlayerId, id = util:to_list(Id)}) of
                        null ->
                            noop;
                        DbPlayerClientData ->
                            OldNum = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_CLIENT_DATA_NUM),
                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_CLIENT_DATA_NUM, OldNum - 1),
                            db:delete(DbPlayerClientData)
                    end
                end,
                IdList
            )
        end,
    db:do(Tran),
    ok.

%% @doc 获得玩家客户端数据
get_db_player_client_data(PlayerId, Id) ->
    case db:read(#key_player_client_data{player_id = PlayerId, id = Id}) of
        null ->
            OldNum = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_CLIENT_DATA_NUM),
            if
                OldNum > 500 ->
                    null;
                true ->
                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_CLIENT_DATA_NUM, OldNum + 1),
                    #db_player_client_data{player_id = PlayerId, id = Id}
            end;
        R ->
            R
    end.

%% @doc 获得玩家客户端数据列表
get_db_player_client_data_list(PlayerId) ->
    db_index:get_rows(#idx_player_client_data_1{player_id = PlayerId}).

%% ================================================ gm操作 ================================================
%% @doc fun 玩家账号互换
gm_player_change_accId(OnPlayerId, ToPlayerId) ->
    OnPlayer = mod_player:get_player(OnPlayerId),
    ?ASSERT(is_record(OnPlayer, db_player), {not_find_onPlayer}),
    ToPlayer = mod_player:get_player(ToPlayerId),
    ?ASSERT(is_record(ToPlayer, db_player), {not_find_toPlayer}),
    Tran =
        fun() ->
            db:write(OnPlayer#db_player{acc_id = ToPlayer#db_player.acc_id}),
            db:write(ToPlayer#db_player{acc_id = OnPlayer#db_player.acc_id})
        end,
    db:do(Tran),
    ?INFO("玩家账号互换ON:~p  TO:~p~n", [{OnPlayerId, OnPlayer#db_player.acc_id}, {ToPlayerId, ToPlayer#db_player.acc_id}]).

%% ================================================ 数据操作 ================================================
%% ----------------------------------
%% @doc 	获取玩家数据
%% @throws 	none
%% @end
%% ----------------------------------
get_player_data1(PlayerId) ->
    db:read(#key_player_data{player_id = PlayerId}).
get_db_player_data(PlayerId) ->
    PlayerData = get_player_data1(PlayerId),
    case is_record(PlayerData, db_player_data) of
        true ->
            noop;
        false ->
            ?WARNING("null player_data:~p~n", [{PlayerId, PlayerData}])
    end,
    PlayerData.

%% @fun 获得玩家数据处理
get_db_player1(PlayerId) ->
    db:read(#key_player{id = PlayerId}).

get_player(PlayerId) ->
    Player = get_db_player1(PlayerId),
    case is_record(Player, db_player) of
        true ->
            noop;
        false ->
            ?WARNING("null player:~p~n", [{PlayerId, Player}])
    end,
    Player.

%% @fun 玩家服务器数据
get_player_server_data(PlayerId) ->
    db:read(#key_player_server_data{player_id = PlayerId}).
%% @fun 玩家服务器数据     并初始
get_player_server_data_init(PlayerId) ->
    case get_player_server_data(PlayerId) of
        PlayerServerData when is_record(PlayerServerData, db_player_server_data) ->
            PlayerServerData;
        _ ->
            #db_player_server_data{player_id = PlayerId}
    end.

%%%% @doc 获得玩家修正倍率
%%get_player_adjust_rate(PlayerId) ->
%%    case mod_phone_unique_id:get_is_newbee_adjust(PlayerId) of
%%        true ->
%%            Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_ADJUST_TOTAL_VALUE),
%%            case util_list:get_value_from_range_list(Value, get_player_random_newbee_xiuzheng(PlayerId)) of
%%                undefined ->
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?FALSE),
%%                    10000;
%%                Rate ->
%%                    Rate
%%            end;
%%        false ->
%%            10000
%%    end.
%%
%%%% @doc 获得玩家随机新手修正
%%get_player_random_newbee_xiuzheng(PlayerId) ->
%%    Length = length(?SD_NEWBEE_XIUZHENG),
%%    case mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_NOVICE_RANDOM_LIST) of
%%        0 ->
%%            RandomNum = util_random:random_number(Length),
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_NOVICE_RANDOM_LIST, RandomNum),
%%            lists:nth(RandomNum, ?SD_NEWBEE_XIUZHENG);
%%        Num ->
%%            if
%%                Length >= Num ->
%%                    lists:nth(Num, ?SD_NEWBEE_XIUZHENG);
%%                true ->
%%                    RandomNum = util_random:random_number(Length),
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_NOVICE_RANDOM_LIST, RandomNum),
%%                    lists:nth(RandomNum, ?SD_NEWBEE_XIUZHENG)
%%            end
%%    end.

%%init_try(PlayerId) ->
%%    case util_time:is_today(mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TRY_TIME)) of
%%        true ->
%%            noop;
%%        false ->
%%            Tran = fun() ->
%%                mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TRY_FIGHT_TIME, ?SD_TRAINING_TIME),
%%                mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TRY_TIME, util_time:timestamp()),
%%%%                L = mod_award:decode_award(?SD_TRY_INIT_REWARD),
%%                lists:foreach(
%%                    fun([PropId]) ->
%%                        HaveNum = mod_prop:get_player_prop_num(PlayerId, PropId),
%%                        if
%%                            HaveNum > 0 ->
%%                                mod_prop:decrease_player_prop(PlayerId, PropId, HaveNum, ?LOG_TYPE_CESHI);
%%                            true ->
%%                                noop
%%                        end
%%                    end,
%%                    ?SD_TRY_ITEM_CHANGE_LIST
%%                ),
%%                mod_award:give(PlayerId, ?SD_TRY_INIT_REWARD, ?LOG_TYPE_CESHI)
%%                   end,
%%            db:do(Tran)
%%    end.

%%get_try_fight_time(PlayerId) ->
%%    mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TRY_FIGHT_TIME).
%%
%%set_try_fight_time(PlayerId, CostTime) ->
%%    Time = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_TRY_FIGHT_TIME),
%%    Time1 = Time - CostTime,
%%    NewTime =
%%        if
%%            5 > Time1 ->
%%                0;
%%            true ->
%%                Time1
%%        end,
%%    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_TRY_FIGHT_TIME, NewTime).

%%%% @doc 是否新手修正
%%is_new_adjust(PlayerId) ->
%%    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_ADJUST_TOTAL_VALUE),
%%    case util_list:get_value_from_range_list(Value, get_player_random_newbee_xiuzheng(PlayerId)) of
%%        undefined ->
%%            false;
%%        _Rate ->
%%            true
%%    end.

%%%% @doc 增加玩家修正值
%%add_player_adjust_value(PlayerId, Add) ->
%%    SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
%%    case mod_scene:is_world_scene(SceneId) of
%%        true ->
%%            case mod_phone_unique_id:get_is_newbee_adjust(PlayerId) of
%%                true ->
%%                    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_ADJUST_TOTAL_VALUE),
%%                    case util_list:get_value_from_range_list(Value, get_player_random_newbee_xiuzheng(PlayerId)) of
%%                        undefined ->
%%                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?FALSE);
%%                        _Rate ->
%%                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_ADJUST_TOTAL_VALUE, Value + Add)
%%                    end,
%%                    api_player:notice_player_adjust_value(PlayerId);
%%                false ->
%%                    server_adjust:add_server_adjust_cost(Add)
%%            end;
%%        false ->
%%            noop
%%    end.

%% @doc 设置玩家数据
set_player_data(PlayerId, Type, Id) ->
    mod_prop:assert_prop_num(PlayerId, [Id, 1]),
    #t_ge_xing_hua{
        conditions_list = ConditionList
    } = get_t_ge_xing_hua(Id),
    ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, ConditionList), ?ERROR_NOT_AUTHORITY),
    DbPlayerData = get_db_player_data(PlayerId),
    Tran =
        fun() ->
            case Type of
                %% 头像
                1 ->
                    db:write(DbPlayerData#db_player_data{head_id = Id}),
                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_CHANGE_HEAD, ?CONDITIONS_VALUE_ADD, 1}),
                    mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_HEAD_ID, Id}]);
                %% 头像框
                2 ->
                    db:write(DbPlayerData#db_player_data{head_frame_id = Id}),
                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_CHANGE_HEAD_FRAME, ?CONDITIONS_VALUE_ADD, 1}),
                    mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_HEAD_FRAME_ID, Id}]);
                %% 聊天气泡
                3 ->
                    db:write(DbPlayerData#db_player_data{chat_qi_pao_id = Id}),
                    mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_CHAT_QI_PAO_ID, Id}])
            end
        end,
    db:do(Tran),
    ok.

%% ----------------------------------
%% @doc 	获取玩家怒气技能效果id
%% @throws 	none
%% @end
%% ----------------------------------
get_player_anger_skill_effect_init(PlayerId) -> get_player_anger_skill_effect_init(PlayerId, false).
get_player_anger_skill_effect_init(PlayerId, InitFlag) ->
    InitFunc =
        fun() ->
            EffectId = lists:nth(rand:uniform(length(?SD_SKILL_ANGER_EFFECT_ID_LIST)), ?SD_SKILL_ANGER_EFFECT_ID_LIST),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_ANGER_SKILL_EFFECT, EffectId),
            EffectId
        end,
    case mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_ANGER_SKILL_EFFECT) of
        0 -> InitFunc();
        _OldEffectId when InitFlag -> InitFunc();
        OldEffectId -> OldEffectId
    end.

init_player_anger_skill_effect(PlayerId) ->
    get_player_anger_skill_effect_init(PlayerId, true).


%% ----------------------------------
%% @doc 	更新玩家滞留的奖励（玩家进程） 来源 (1-大招,9-翻牌,10-拉霸,11-转盘,12-炸弹)
%% @throws 	none
%% @end
%% ----------------------------------
update_player_scene_stay_rewards(Type, Awards) ->
    OldDelayRewards = ?getModDict(scene_delay_rewards),
    NewDelayRewards =
        case lists:keytake(Type, 1, OldDelayRewards) of
            false ->
                [{Type, mod_prop:merge_prop_list(Awards)} | OldDelayRewards];
            {value, {Type, OldAwards}, Rest} ->
                [{Type, mod_prop:merge_prop_list(Awards ++ OldAwards)} | Rest]
        end,
    ?setModDict(scene_delay_rewards, NewDelayRewards),
    ok.

%% ----------------------------------
%% @doc 	发放玩家在场景内滞留的部分奖励（玩家进程）
%% @throws 	none
%% @end
%% ----------------------------------
give_player_scene_stay_rewards(Type) ->
    PlayerId = get(?DICT_PLAYER_ID),
    case ?getModDict(scene_delay_rewards) of
        [] ->
            skip;
        List ->
            case lists:keytake(Type, 1, List) of
                false ->
                    skip;
                {value, {Type, Awards}, Rest} ->
                    mod_award:give(PlayerId, Awards, getDelayRewardLogType(Type)),
                    ?setModDict(scene_delay_rewards, Rest)
            end
    end.

%% ----------------------------------
%% @doc 	升级
%% @throws 	none
%% @end
%% ----------------------------------
level_upgrade(_PlayerId) ->
    skip.
%%    DbPlayerData = get_db_player_data(PlayerId),
%%    #db_player_data{
%%        level = Level
%%    } = DbPlayerData,
%%    #t_role_experience{
%%        experience = NeedExperience,
%%        next_level = NextLevel
%%    } = get_t_level(Level),
%%    PropId = ?ITEM_EXP,
%%    PlayerPropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
%%    ?ASSERT(PlayerPropNum >= NeedExperience, ?ERROR_NO_ENOUGH_PROP),
%%    ?ASSERT(NextLevel > 0, ?ERROR_NOT_AUTHORITY),
%%    Tran =
%%        fun() ->
%%            mod_prop:decrease_player_prop(PlayerId, [{PropId, NeedExperience}], ?LOG_TYPE_PLAYER_LEVEL_AWARD),
%%            db:write(DbPlayerData#db_player_data{level = NextLevel}),
%%            hook:after_level_upgrade(PlayerId, Level, NextLevel, ?LOG_TYPE_PLAYER_LEVEL_AWARD)
%%        end,
%%    AwardList = db:do(Tran),
%%    {ok, Level, Level, AwardList}.

%% ----------------------------------
%% @doc 	获得等级奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_level_award(PlayerId, Level) ->
    DbPlayerData = get_db_player_data(PlayerId),
    #db_player_data{
        level = PlayerLevel
    } = DbPlayerData,
    ?ASSERT(PlayerLevel >= Level, ?ERROR_NOT_AUTHORITY),
    AlreadyLevel = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_LEVEL_AWARD_ALREADY),
    ?ASSERT(Level == AlreadyLevel + 1, ?ERROR_ALREADY_GET),
    #t_role_experience{
        reward = RewardId
    } = get_t_level(Level),
    Tran =
        fun() ->
            mod_award:give(PlayerId, RewardId, ?LOG_TYPE_PLAYER_LEVEL_AWARD),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_LEVEL_AWARD_ALREADY, Level)
        end,
    db:do(Tran),
    ok.

%% ----------------------------------
%% @doc 	修改签名
%% @throws 	none
%% @end
%% ----------------------------------
update_player_signature(PlayerId, Signature) ->
    % 非法字符
%%    ?ASSERT(util_string:is_valid_name(Signature) == true, ?ERROR_INVAILD_NAME),
    % 长度
    ?ASSERT(util_string:string_length(Signature) =< ?SD_PLAYER_SIGNATURE_MAX * 2, ?ERROR_NAME_TOO_LONG),
    Tran =
        fun() ->
            mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_SIGNATURE, Signature)
        end,
    db:do(Tran),
    ok.

%% @doc 获得玩家信息 聊天
get_player_chat_info(PlayerId) ->
    case get_db_player1(PlayerId) of
        null ->
            mod_server_rpc:call_war(?MODULE, handle_get_player_chat_info, [PlayerId]);
        _DbPlayer ->
            handle_game_get_player_chat_info(PlayerId)
    end.
handle_get_player_chat_info(PlayerId) ->
    DbServerData = get_player_server_data_init(PlayerId),
    ?ASSERT(DbServerData =/= null, ?ERROR_NONE),
    #db_player_server_data{
        platform_id = PlatformId,
        server_id = ServerId
    } = DbServerData,
    case mod_server_rpc:call_game_server(PlatformId, ServerId, ?MODULE, handle_game_get_player_chat_info, [PlayerId]) of
        {badrpc, _Reason} ->
            exit(?ERROR_NOT_AUTHORITY);
        Data ->
            Data
    end.
handle_game_get_player_chat_info(PlayerId) ->
    {ok, mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_SIGNATURE), api_player:pack_model_head_figure(PlayerId)}.

init_server_data(PlayerId) ->
    PlatformId = mod_server_config:get_platform_id(),
    ServerId = mod_player:get_player_data(PlayerId, server_id),
    mod_server_rpc:cast_war(mod_player, update_player_server_data_init, [PlayerId, PlatformId, ServerId]).

%% ----------------------------------
%% @doc 	发放玩家在场景内滞留的所有奖励（玩家进程）
%% @throws 	none
%% @end
%% ----------------------------------
give_player_all_scene_stay_rewards() ->
    PlayerId = get(?DICT_PLAYER_ID),
    case ?getModDict(scene_delay_rewards) of
        [] ->
            skip;
        List ->
            lists:foreach(
                fun({Type, Awards}) ->
                    mod_award:give(PlayerId, Awards, getDelayRewardLogType(Type))
                end,
                List
            ),
            ?setModDict(scene_delay_rewards, [])
    end.

%% 滞留奖励日志类型
getDelayRewardLogType(9) -> ?LOG_TYPE_FUNCTION_MONSTER_FANPAI;
getDelayRewardLogType(10) -> ?LOG_TYPE_FUNCTION_MONSTER_LABA;
getDelayRewardLogType(11) -> ?LOG_TYPE_FUNCTION_MONSTER_ZHUANPAN;
getDelayRewardLogType(12) -> ?LOG_TYPE_FUNCTION_MONSTER_ZHADAN;
getDelayRewardLogType(1) -> ?LOG_TYPE_FIGHT.

%%================================================ 模板操作 ==================================================
%% @模板 等级
get_t_level(Level) ->
    t_role_experience:get({Level}).

%% @doc 获得个性化表
get_t_ge_xing_hua(Id) ->
    t_ge_xing_hua:assert_get({Id}).
