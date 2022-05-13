%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             服务器数据 宏定义
%%% @end
%%% Created : 26. 五月 2016 下午 4:08
%%%-------------------------------------------------------------------
-define(SERVER_DATA_VERSION, 0).                                %% 服务器版本号
-define(SERVER_DATA_RANK_AWARD_DATE, 1).                        %% 排行榜奖励发送时间
-define(SERVER_DATA_IS_SOCKET_FORBID, 2).                       %% 是否禁止socket连接
-define(SERVER_DATA_SERVER_START_TIME, 3).                      %% 服务器启动时间
%%-define(SERVER_DATA_LOGIN_NOTICE, 4).                         %% 登录公告
-define(SERVER_DATA_MAIL_LOCK, 5).                              %% 邮件锁
-define(SERVER_DATA_SERVER_MERGE_TIME, 6).                      %% 合服时间
-define(SERVER_DATA_IS_NEED_MERGE_ACTION, 7).                   %% 是否需要执行合服操作

-define(SERVER_DATA_CLIENT_VERSION, 29).                        %% 客户端版本(废弃)

-define(SERVER_DATA_CLIENT_PLATFORM_VERSION, 41).               %% 客户平台端版本

%% 以下是t1_s1项目新增
-define(SERVER_DATA_CENTER_PROMOTE_RECORD_REAL_ID, 50).         %% 中心服数据:推广记录唯一id
-define(SERVER_DATA_GAME_REPAIR_TASK_VERSION, 51).              %% 游戏服数据:修复任务版本
-define(SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER, 52).        %% 战区服数据:猜boss活动序号(第几期)

-define(SERVER_DATA_ROBOT_PLAYER_SCENE_CACHE_ID, 54).           %% 机器人场景缓存id

-define(SERVER_DATA_SERVER_ADJUST_COST, 60).                    %%
-define(SERVER_DATA_SERVER_ADJUST_AWARD, 61).                   %%

-define(SERVER_DATA_RED_PACKET_ROUND_ID, 62).                   %% 红包轮次id

%%-define(SERVER_DATA_FIGHT_TYPE, 63).                          %% 战斗类型参数(0:正常概率,1:血量)
-define(SERVER_DATA_SCENE_BOSS_ADJUST_POOL, 64).                %% 场景boss竞猜修正池
-define(SERVER_DATA_MATCH_SCENE_LAST_BALANCE_TIME, 65).         %% 匹配场上次结算时间
-define(SERVER_DATA_ONE_VS_ONE_LAST_BALANCE_TIME, 66).          %% 1v1上次结算时间

-define(SERVER_DATA_FIGHT_AWARD_RATE, 100).                     %% 战斗调节系数
-define(SERVER_DATA_LEI_CHONG_ACTIVITY_ID, 101).              	%% 累充活动id