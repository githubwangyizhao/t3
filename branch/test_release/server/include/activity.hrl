
%% @doc 活动回调函数
-define(ACTIVITY_READY_FUNCTION, ready_activity).       %% 活动准备函数
-define(ACTIVITY_OPEN_FUNCTION, open_activity).         %% 活动开启函数
-define(ACTIVITY_CLOSE_FUNCTION, close_activity).       %% 活动关闭函数
-define(ACTIVITY_CLEAN_FUNCTION, clean_activity).       %% 活动清理函数

%% @doc 活动进程消息
-define(ACTIVITY_MSG_PULL_ACTIVITY, pull_activity).
-define(ACTIVITY_MSG_PUSH_ACTIVITY, push_activity).
-define(ACTIVITY_MSG_DEBUG_OPEN, debug_open).
-define(ACTIVITY_MSG_CLEAN_DEBUG, clean_debug).
-define(ACTIVITY_MSG_CLOSE_ACTIVITY, close_activity).
-define(ACTIVITY_MSG_CLOCK, clock).
-define(ACTIVITY_MSG_CLOCK_PUSH, clock_push).

%% @doc 活动状态
-define(ACTIVITY_STATE_CLOSE, 0).   %% 关闭
-define(ACTIVITY_STATE_READY, 1).   %% 准备
-define(ACTIVITY_STATE_OPEN, 2).    %% 启动

%% @doc 活动类型
-define(ACTIVITY_TYPE_GAME, 1). % 本服活动
-define(ACTIVITY_TYPE_WAR, 2). % 跨服活动
-define(ACTIVITY_TYPE_PERSON, 3). % 个人活动

%% @doc 活动进程名
-define(ACTIVITY_SRV, activity_srv).