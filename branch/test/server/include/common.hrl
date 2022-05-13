%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             通用宏定义
%%% @end
%%% Created : 26. 五月 2016 下午 4:08
%%%-------------------------------------------------------------------
-include("logger.hrl").
-include("ets.hrl").
-include("record.hrl").
-include("platform.hrl").
-include("cache.hrl").
-include("def.hrl").

-ifdef(debug).
-define(IS_DEBUG, true).
-else.
-define(IS_DEBUG, false).
-endif.

-define(UNDEFINED, undefined).

-define(ASYNC, async).  %%异步
-define(SYNC, sync).    %%同步

-ifdef(debug).
-define(t_assert(Expression), ?ASSERT(Expression)).
-define(t_assert(Expression, Reason), ?ASSERT(Expression, Reason)).
-else.
-define(t_assert(Expression), ok).
-define(t_assert(Expression, Reason), ok).
-endif.

%%-define(GAME_KEY, "fd340a27541333e0").
%%-define(GAME_ID, "100448").
%%-define(GAME_SECRET, "c3e52ef003892d38fb99320f97024915").

%% ----------------------------------
%% @doc 	Bool
%% @end
%% ----------------------------------
-define(TRUE, 1).
-define(FALSE, 0).

%% 整形 -> bool
-define(TRAN_INT_2_BOOL(Int), if Int >= 1 -> true;true -> false end).

%% bool -> 整形
-define(TRAN_BOOL_2_INT(BOOL), if BOOL -> ?TRUE;true -> ?FALSE end).


%% ----------------------------------
%% @doc 	毫秒
%% @end
%% ----------------------------------
-define(SECOND_MS, 1000).
-define(MINUTE_MS, 60 * 1000).
-define(HOUR_MS, 60 * 60 * 1000).
-define(DAY_MS, ?DAY_S * 1000).

%% ----------------------------------
%% @doc 	秒
%% @end
%% ----------------------------------
-define(MINUTE_S, 60).
-define(HOUR_S, 60 * 60).
-define(DAY_S, 86400).          % 一天的秒数
-define(WEEK_S, 604800).        % 一周的秒数

%% ----------------------------------
%% @doc 	位操作
%% @end
%% ----------------------------------
-define(BIT1(X), X band 2#00000001).
-define(BIT2(X), X band 2#00000010).
-define(BIT3(X), X band 2#00000100).
-define(BIT4(X), X band 2#00001000).
-define(BIT5(X), X band 2#00010000).
-define(BIT6(X), X band 2#00100000).
-define(BIT7(X), X band 2#01000000).
-define(BIT8(X), X band 2#10000000).

-define(SET1(X), X bor 2#00000001).
-define(SET2(X), X bor 2#00000010).
-define(SET3(X), X bor 2#00000100).
-define(SET4(X), X bor 2#00001000).
-define(SET5(X), X bor 2#00010000).
-define(SET6(X), X bor 2#00100000).
-define(SET7(X), X bor 2#01000000).
-define(SET8(X), X bor 2#10000000).

%% ----------------------------------
%% @doc 	ETS 初始化
%% @end
%% ----------------------------------
-define(ETS_INIT_ARGS(KeyPos, Extra), [set, named_table, public, {keypos, KeyPos}] ++ Extra).
-define(ETS_INIT_ARGS(KeyPos), ?ETS_INIT_ARGS(KeyPos, [{write_concurrency, true}, {read_concurrency, true}])).

-define(ETS_INIT_ARGS_PROTECTED(KeyPos), [set, named_table, protected, {keypos, KeyPos}]).

%% ----------------------------------
%% @doc 	断言
%% @end
%% ----------------------------------
-define(ASSERT(Expression), case Expression of true -> ok; _ -> exit(assert_fail) end).
-define(ASSERT(Expression, Reason), case Expression of true -> ok; _ -> exit(Reason) end).
-define(IF(Expression, A, B), case Expression of true -> A; _ -> B end).

-define(CATCH(Fun),
    try Fun
    catch
        _:_Reason_ ->
            ?ERROR(
                "catch ->~n"
                "reason:~p~n"
                "stacktrace:~p"
                , [_Reason_, erlang:get_stacktrace()]),
            {'EXIT', _Reason_}
    end).

-define(TRY_CATCH(Fun),
    try Fun
    catch
        _:_ ->
            ?ERROR(
                "Try catch ->~n"
                " stacktrace:~p"
                , [erlang:get_stacktrace()])
    end
).
-define(TRY_CATCH2(Fun),
    try Fun
    catch
        _:_Reason_ ->
            ?ERROR(
                "Try catch ->~n"
                "     reason:~p~n"
                " stacktrace:~p"
                , [_Reason_, erlang:get_stacktrace()]),
            {error, _Reason_}
    end
).

%% ----------------------------------
%% @doc 	客户端登录状态
%% @end
%% ----------------------------------
-define(CLIENT_STATE_WAIT_AUTH, 0).                 %% 等待验证
-define(CLIENT_STATE_WAIT_CREATE_ROLE, 1).          %% 等待创建角色
-define(CLIENT_STATE_WAIT_ENTER_GAME, 2).           %% 等待进入游戏
-define(CLIENT_STATE_ENTER_GAME, 3).                %% 进入游戏


%% ----------------------------------
%% @doc 	客户端离线原因
%% @end
%% ----------------------------------
-define(CSR_LOGIN_IN_OTHER, login_in_other).            %%在别处登录
-define(CSR_SYSTEM_MAINTENANCE, system_maintenance).    %%系统维护
-define(CSR_MAX_PACK, max_pack).                        %%发包太快
-define(CSR_MAX_ERROR, max_error_pack).                 %%错包太多
-define(CSR_GM_KILL, gm_kill).                          %%管理员踢出
-define(CSR_DISABLE_LOGIN, disable_login).              %%封号
-define(CSR_HEART_BEAT_TIME_OUT, heart_beat_time_out). %%玩家心跳超时
-define(CSR_AUTH_TIME_OUT, auth_time_out).              %%玩家验证超时
-define(CSR_TCP_ERROR, tcp_error).                      %%socket 错误
-define(CSR_TCP_CLOSED, tcp_closed).                    %%玩家主动断开
-define(CSR_TCP_HTTP, http).                            %%http
-define(CSR_BLACK_IP_LIST, black_ip_list).   %% 当前客户端ip是为黑名单ip

%% 封禁类型
-define(FORBID_TYPE_NONE, 0).   %% 无
-define(FORBID_TYPE_DISABLE_CHAT, 1).%%禁言
-define(FORBID_TYPE_DISABLE_LOGIN, 2).%%禁止登录


%%%% 官网
%%-define(OFFICIAL_WEBSITE, "http://www.menle.com/").
%%%% 登录key
%%-define(LOGIN_KEY, "038c45530e076ae7b5862e54606d85cd").
%%%% 查询key
%%-define(ROLE_KEY, "0db664f276696ea89175ed0175d80faa").
%%%% 服务器批量查询 key
%%-define(SERVER_LIST_KEY, "69c9153b95a52fd36043db46e5286c11").

-define(LOGIN_HTML, "http://res.bajian.menle.com.cn/client/Index.html?").

-define(GM_SALT, "fretj9tnda3gr7t14terg4es5f4ds514f").

-define(NODE_KEY, "xmyw").


%% 中心节点
%%-define(CENTER_NODE, 'center@120.92.102.11').
%%%% 充值服节点
%%-define(CHARGE_NODE, 'charge@120.92.102.11').


%%%% ----------------------------------
%%%% @doc 	PK模式
%%%% @end
%%%% ----------------------------------
%%-define(PK_MODE_PEACE, 0).       %%和平模式
%%-define(PK_MODE_FACTION, 1).     %%帮派模式
%%-define(PK_MODE_ALL, 2).         %%全体模式
%%

%% ----------------------------------
%% @doc 	性别
%% @end
%% ----------------------------------
-define(SEX_MAN, 0).                    %%男
-define(SEX_WOMEN, 1).                  %%女

%% ----------------------------------
%% @doc 	账号类型
%% @end
%% ----------------------------------
-define(ACCOUNT_TYPE_COMMON, 0).                                %% 普通号
-define(ACCOUNT_TYPE_INTERVAL, 1).                              %% 内部号
-define(ACCOUNT_TYPE_GM, 2).                                    %% GM号
-define(ACCOUNT_TYPE_CHARGE_ALWAYS_OPEN, 3).                    %% 任何情况下都能显示充值的号
-define(ACCOUNT_TYPE_AUTO_CREATE_ROLE, 4).                      %% 任何情况下都能显示充值的号

-define(INGOT_RATE_MONEY, 10).        % 元宝和人币民 比率
%% ----------------------------------
%% @doc 	进程类型宏定义
%% @end
%% ----------------------------------
%% 进程类型
-define(PROCESS_TYPE_CLIENT_WORKER, client_worker).     %% 玩家进程
-define(PROCESS_TYPE_SCENE_WORKER, scene_worker).       %% 场景进程
-define(PROCESS_TYPE_ROBOT_WORKER, robot_worker).       %% 机器人进程

%% 进程类型
-define(PROCESS_TYPE, get(process_type)).

%% 设置进程类型
-define(INIT_PROCESS_TYPE(Type), put(process_type, Type)).

%% 设置玩家发送进程
-define(INIT_PLAYER_SENDER_WORKER(PlayerId, Worker), put({sender, PlayerId}, Worker)).
%% 获取玩家发送进程
-define(GET_PLAYER_SENDER_WORKER(PlayerId), get({sender, PlayerId})).
%% 销毁
-define(ERASE_PLAYER_SENDER_WORKER(PlayerId), erase({sender, PlayerId})).

%% ----------------------------------
%% @doc 	星期宏定义
%% @end
%% ----------------------------------
-define(MONDAY, 1).             %% 星期一
-define(TUESDAY, 2).            %% 星期二
-define(WEDNESDAY, 3).          %% 星期三
-define(THURSDAY, 4).           %% 星期四
-define(FRIDAY, 5).             %% 星期五
-define(SATURDAY, 6).           %% 星期六
-define(SUNDAY, 7).             %% 星期天

%% ----------------------------------
%% @doc 	方向定义
%% @end
%% ----------------------------------
-define(DIR_UP, 0).
-define(DIR_RIGHT_UP, 1).
-define(DIR_RIGHT, 2).
-define(DIR_RIGHT_DOWN, 3).
-define(DIR_DOWN, 4).
-define(DIR_LEFT_DOWN, 5).
-define(DIR_LEFT, 6).
-define(DIR_LEFT_UP, 7).


%% ----------------------------------
%% @doc 	名字颜色
%% @end
%% ----------------------------------
-define(COLOR_WHITE, 0).    %%白色
-define(COLOR_YELLOW, 1).   %%黄色
-define(COLOR_RED, 2).      %%红色
%% 名字颜色
-define(TRAN_NAME_COLOR(Pk),
    if Pk == 0 ->
        ?COLOR_WHITE;
        Pk > 0 andalso Pk < 20 ->
            ?COLOR_YELLOW;
        Pk >= 20 ->
            ?COLOR_RED
    end
).

-define(OFFLINE_CACHE_EXPIRE_TIME, 60).    %% 玩家断线 缓存时间 (s)

%%-define(SERVER_NAME_JOIN_NICKNAME, ".").    % 名字连接符号

%% ----------------------------------
%% @doc 	编译选项
%% @end
%% ----------------------------------
-define(COMPILE_INCLUDE_PATH, "../include").
-define(COMPILE_OUT_PATH, "../ebin").
-define(CODE_PATH, "../src/gen/").


-define(PROP_NUM_10000, 10000).                   % 概率值
-define(PROP_NUM_100, 100).                        % 概率值

-define(ROBOT_PLAYER_ID_LIMIT, 10000).            % 机器人id小于这个值

-define(VIP_INGOT_EXP_RATE, 1).        % vip经验是元宝几倍

-define(AWARD_NONE, 0).         % 不可领取
-define(AWARD_CAN, 1).          % 可领取
-define(AWARD_ALREADY, 2).      % 已领取
-define(AWARD_LOSE, 3).         % 失效

-define(MAX_NUMBER_VALUE, 2100000000).      % 数字最大值
-define(MAX_NUMBER_VALUE_64, 4200000000).   % 数字最大值

%% @doc     条件设置类型
-define(CONDITIONS_VALUE_ADD, add_value). %% 条件 增加值
-define(CONDITIONS_VALUE_SET, set_value). %% 条件 设置值
-define(CONDITIONS_VALUE_SET_MAX, set_max_value).   %% 条件 设置值(只保留最大值且只有最大值时才触发事件)
-define(CONDITIONS_VALUE_SET_MIN, set_min_value).   %% 条件 设置值(只保留最小值且只有大于0值时才触发事件)
-define(CONDITIONS_VALUE_DECREASE, decrease_value). %% 条件 减少值
-define(CONDITIONS_VALUE_NOT_SAME_DAY_ADD, not_same_day_add).   %% 不是同一天增加值


%% @fun 战区服活动记录消息类型
-define(WAR_ACTIVITY_MSG_MOD_TYPE_1, 1).    % 活动任务
-define(WAR_ACTIVITY_MSG_MOD_TYPE_2, 2).    % 祝福值转盘
-define(WAR_ACTIVITY_MSG_MOD_TYPE_3, 3).    % 转动圆形转盘
-define(WAR_ACTIVITY_MSG_MOD_TYPE_4, 4).    % 活动砸金蛋
-define(WAR_ACTIVITY_MSG_MOD_TYPE_5, 5).    % 活动龙宫探宝

%% 法宝被动技能偏移量
-define(MAGIC_WEAPON_BUFF_ID_OFFSET, 10000000).

%% @fun 属性计算参数规则
-define(ATTR_ADD_RATIO, add_ratio).         % 属性提升万分比
-define(ATTR_RATIO, ratio).                 % 属性万分比


-define(TRAN_ZERO_2_UNDEFINED(Value),
    if Value == 0 ->
        ?UNDEFINED;
        true ->
            Value
    end
).

-define(SERVER_SALT, "fsfsd454tgfg54").

-define(REQUEST_INFO(Msg), ?DEBUG("客户端请求>>" ++ Msg)).
-define(REQUEST_INFO(Msg, Msg2), ?DEBUG("客户端请求>>" ++ Msg ++ util:to_list(Msg2))).

%% 更新ip list定时器
-define(UPDATE_BLACK_IP_LIST_INTERVAL, 720).       % 检测活动列表时间(分钟)
-define(UPDATE_BLACK_IP_LIST_TIMER, update_black_ip_list_timer).
-define(UPDATE_BLACK_IP_LIST_TXT_SCRIPT, env:get(update_black_ip_list_txt_dir)).
-define(BLACK_IP_LIST_TXT, env:get(update_black_ip_list_txt)).

%% 第三方授权登录所需的验证文件路径 oauth登录的client_id与client_secret文件
-define(OAUTH_CLIENT_INFO, "../priv/clientIdSecret.yaml").

%% 容错用的客服链接+app所使用的upgrade接口返回的客服链接
%%-define(DEFAULT_CUSTOMER, "http://custome.props-trader.com/").
-define(DEFAULT_CUSTOMER, "https://www.notion.so/530f686ef95b4036a695afa80bf86711").
-define(DEFAULT_TAIWAN_CUSTOMER, "https://lin.ee/3X2Wcwr").

%% 检查谷歌支付订单
%%-define(UPDATE_GOOGLE_PAY_ORDER_INTERVAL, 2 * 24 * 60).                 % 间隔时间 单位:分钟
-define(UPDATE_GOOGLE_PAY_ORDER_INTERVAL, 1).                           % 间隔时间 单位:分钟
-define(UPDATE_GOOGLE_PAY_ORDER_TIMER, update_google_pay_order_timer).  % 定时器名称
-define(GOOGLE_PAY_TIME_STEP, 2 * 24 * 60 * 60).                        % 谷歌支付订单间隔时间 单位：秒

%% 用户操作系统
-define(OS_PLATFORM_ANDROID, "Android").			% 安卓
-define(OS_PLATFORM_IOS, "iOS").					% ios

-define(REVIEWING_SERVER(Env),
    case Env of
        "develop" -> "s999";
        "testing" -> "s0";
        "testing_oversea" -> "s0";
        _ -> "s0"
    end
).

-define(DEFAULT_PLATFORM(Env),
    case Env of
        "develop" -> "local";
        "testing" -> "test";
        "testing_oversea" -> "test";
        _ -> "aurora"
    end
).

-define(DEFAULT_CHANNEL(Env),
    case Env of
        "develop" -> "local_test";
        "testing" -> "test";
        "testing_oversea" -> "test";
        _ -> "fb"
    end
).