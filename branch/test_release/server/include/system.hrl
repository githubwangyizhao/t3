%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            系统配置
%%% @end
%%% Created : 15. 六月 2016 下午 2:40
%%%-------------------------------------------------------------------

-ifdef(debug).
-define(IS_TRACE_PROTO, env:get(is_trace_proto, false)).%% 是否追踪协议
-define(HEART_BEAT_TIME, 20 * 60 * 1000).        %% 心跳时间
-define(MAX_ERROR_PACK, 20 * 20).                %% 最大错误包数量
-define(MAX_PACK, 20000).                          %% 最大包数量
-else.
%%-define(IS_TRACE_PROTO, false).                  %% 是否追踪协议
-define(IS_TRACE_PROTO, env:get(is_trace_proto, false)).%% 是否追踪协议
-define(HEART_BEAT_TIME, 30 * 1000).              %% 心跳时间
-define(MAX_ERROR_PACK, 20).                      %% 最大错误包数量
-define(MAX_PACK, 1500).                          %% 最大包数量
-endif.




%%-define(IS_TRACE_PROTO, env:get(is_trace_proto, false)).    %% 是否追踪协议




%%-define(LOGIN_SERVER, 'login_server@192.168.31.100').
-define(LOGIN_SERVER, env:get(login_server)).

-define(CENTER_DEFAULT_HTTP_PORT, 6663).    %% 中心服默认端口

%% ----------------------------------
%% @doc 	服务器类型
%% @end
%% ----------------------------------
-define(SERVER_TYPE_CENTER, 0).             %%中心服
-define(SERVER_TYPE_GAME, 1).               %%游戏服
-define(SERVER_TYPE_WAR_ZONE, 2).           %%跨服
-define(SERVER_TYPE_LOGIN_SERVER, 4).       %%登录服
-define(SERVER_TYPE_UNIQUE_ID, 5).          %%唯一id服
-define(SERVER_TYPE_CHARGE, 6).             %%充值服
-define(SERVER_TYPE_WAR_AREA, 7).           %%战区服
-define(SERVER_TYPE_WEB, 8).                %%web 服务器

%% ----------------------------------
%% @doc 	服务器状态
%% @end
%% ----------------------------------
%%-define(SERVER_STATE_OFFLINE, 0).            %%下线
-define(SERVER_STATE_MAINTENANCE, 1).        %%维护
-define(SERVER_STATE_ONLINE, 2).             %%正常
-define(SERVER_STATE_HOT, 3).                %%火爆

%% ----------------------------------
%% @doc 	节点连接状态
%% @end
%% ----------------------------------
-define(NODE_RUN_STATE_DISCONNECT, 0).        %%断开连接
-define(NODE_RUN_STATE_RUNNING, 1).           %%运行中

-define(RELOAD_CHECK_TIME, 3).                     %% 热更新检测间隔 (秒)

-ifdef(debug).
-define(SERVER_MONITOR_LOG_MS, (1 * 60) * 1000).    %% 服务器系统监控间隔 (ms)
-define(PROCESS_GC_MS, 10 * 60 * 1000).             %% 5
-define(PROCESS_GC_VALUE, 64 * 1024).             %% 64kb
-else.
-define(SERVER_MONITOR_LOG_MS, (5 * 60) * 1000).    %% 服务器系统监控间隔 每隔5分钟
-define(PROCESS_GC_MS, 10 * 60 * 1000).             %% GC 时间 每隔10分钟
-define(PROCESS_GC_VALUE, 128 * 1024).              %% GC 水线 128kb
-endif.


-define(TICKET_SALT, "6a18da8e81ebc0440c708714b638e49b").



