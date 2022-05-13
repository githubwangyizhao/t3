
%% 定时器使用
-define(TIME_SERVER, timer_srv).    %%定时器进程名字

-define(TIMER_TYPE_ONE, 0).         %% 定时器类型  定时1次
-define(TIMER_TYPE_INTERVAL, 1).    %% 定时器类型  间隔
-define(TIMER_TYPE_EVERYDAY, 2).    %% 定时器类型  每天
-define(TIMER_TYPE_WEEKLY, 3).      %% 定时器类型  每周

%% 玩家定时器使用
-define(PLAYER_SERVER, player_timer_srv).   % 玩家定时器进程名
-define(EXECUTE_INTERVAL, 2).       % 消息执行最小间隙
-define(NOTIFY_INTERVAL, 5).        % 消息通知最小间隙
-define(TYPE_TIME_EXECUTE, 0).      %% 时间模板执行类型
-define(TYPE_TIME_NOTIFY, 1).       %% 时间模板通知类型

%% ----------------------------------
%% @doc 	时间数据存储
%% @end
%% ----------------------------------
-record(timer_meta, {
    id,                 %%
    type,               %% 定时器类型
    time,               %% 时间  {{Y, M, D},{H, M, S}}  | INT:秒 |  {H, M, S}
    m,                  %% mod
    f,                  %% fun
    a,                  %% args
    is_check = false    %% 是否强检测已经执行过
}).


