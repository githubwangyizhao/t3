%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             玩家游戏数据 宏定义
%%% @end
%%% Created : 26. 五月 2016 下午 4:08
%%%-------------------------------------------------------------------

-define(PLAYER_GAME_DATA_TEST, 0).                                      %% 测试数据
-define(PLAYER_GAME_DATA_VERSION, 1).                                   %% 玩家版本
-define(PLAYER_GAME_DATA_ENUM_MAIL_ID, 2).                              %% 玩家邮件id记录
-define(PLAYER_GAME_DATA_ENUM_GIFT_MAIL_ID, 3).                         %% 玩家礼物邮件id记录
-define(PLAYER_GAME_DATA_LEVEL_AWARD_ALREADY, 4).                       %% 玩家等级奖励已领取等级
-define(PLAYER_GAME_DATA_COLLECT_STATE, 6).                             %% 玩家收藏状态
-define(PLAYER_GAME_DATA_PLATFORM_VIP_AWARD_TIME, 7).                   %% 玩家平台vip等级奖励
-define(PLAYER_GAME_DATA_PLATFORM_CONCERN_AWARD_STATE, 10).             %% 玩家领取平台关注礼包状态
-define(PLAYER_GAME_DATA_PLATFORM_CERTIFICATION_AWARD_STATE, 11).       %% 玩家领取平台认证礼包状态
-define(PLAYER_GAME_DATA_PLAYER_CREATE_EXTRA_DATA, 12).                 %% 玩家创角额外数据
-define(PLAYER_GAME_DATA_PLAYER_SHARE_TIMES_DATA, 13).                  %% 玩家分享次数数据
-define(PLAYER_GAME_DATA_SEVEN_LOGIN_DAY, 14).                          %% 玩家七天登錄天數
-define(PLAYER_GAME_DATA_SEVEN_LOGIN_DAY_LAST_TIME, 15).                %% 玩家七天登錄天數上次更新時間
-define(PLAYER_GAME_DATA_RETURN_GAME_TIME, 22).                         %% 玩家回归时间
-define(PLAYER_GAME_DATA_LAST_NAME, 25).                                %% 玩家上一个名字

-define(PLAYER_GAME_DATA_IS_OPEN_CHARGE, 32).                           %% 是否开启充值
-define(PLAYER_GAME_DATA_CLIENT_DATA_NUM, 35).                          %% 玩家客户端数据数量

%% 玩家战斗概率修正
%%-define(PLAYER_GAME_DATA_ADJUST_STEP, 41).                            %%

-define(PLAYER_GAME_DATA_NEWBEE_ADJUST_VALUE, 42).                      %% 玩家新手修正值
-define(PLAYER_GAME_DATA_GET_EXP_NUM, 43).                              %% 玩家累计获得经验数量


-define(PLAYER_GAME_DATA_FIRST_CHARGE_ID, 44).                          %% 首充id
-define(PLAYER_GAME_DATA_TURN_TABLE_VALUE, 45).                         %% 转盘抽奖值
-define(PLAYER_GAME_DATA_TURN_TABLE_UPDATE_TIME, 46).                   %% 转盘更新时间
-define(PLAYER_GAME_DATA_INVEST, 47).                                   %% 玩家是否购买投资返利

-define(PLAYER_GAME_DATA_PLAYER_NOVICE_RANDOM_LIST, 48).                %% 玩家随机新手修正列表位置
-define(PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, 49).                    %% 玩家是否开启新手修正

-define(PLAYER_GAME_DATA_TRY_TIME, 50).                                 %% 玩家体验区更新时间
-define(PLAYER_GAME_DATA_TRY_FIGHT_TIME, 51).                           %% 玩家体验区可游玩时间

-define(PLAYER_GAME_DATA_SEIZE_LUCK_VALUE, 52).                         %% 玩家夺宝幸运值
-define(PLAYER_GAME_DATA_SEIZE_TIMES, 53).                              %% 玩家夺宝的次数
-define(PLAYER_GAME_DATA_SEIZE_ACHIEVEMENT, 54).                        %% 玩家夺宝成就奖励

-define(PLAYER_GAME_DATA_TXZ_BEST_LV, 55).                              %% 玩家通行证最高等级
-define(PLAYER_GAME_DATA_TXZ_EXP, 56).                                  %% 玩家通行证升级经验值
-define(PLAYER_GAME_DATA_TXZ_SILVER_AWARD_STR, 57).                     %% 玩家通行证白银等级奖励记录
-define(PLAYER_GAME_DATA_TXZ_DIAMOND_AWARD_STR, 58).                    %% 玩家通行证钻石等级奖励记录
-define(PLAYER_GAME_DATA_TXZ_EXTRA_BOX_NUM, 59).                        %% 玩家通行证额外大宝箱个数
-define(PLAYER_GAME_DATA_TXZ_IS_BUY, 60).                               %% 玩家是否购买了钻石通行证
-define(PLAYER_GAME_DATA_TXZ_ID, 61).                                   %% 玩家通行证ID
-define(PLAYER_GAME_DATA_TXZ_LAST_DATE, 62).                            %% 玩家通行证刷新日期

-define(PLAYER_GAME_DATA_SPECIAL_PROP_ID, 63).                          %% 玩家特殊道具唯一id

%%-define(PLAYER_GAME_DATA_GOLD_ADJUST_POOL_1, 63).                       %% 玩家金币个人修正池子1
%%-define(PLAYER_GAME_DATA_GOLD_ADJUST_POOL_2, 64).                       %% 玩家金币个人修正池子2
%%-define(PLAYER_GAME_DATA_RMB_ADJUST_POOL_1, 65).                        %% 玩家钻石个人修正池子1
%%-define(PLAYER_GAME_DATA_RMB_ADJUST_POOL_2, 66).                        %% 玩家钻石个人修正池子2

-define(PLAYER_GAME_DATA_LEI_CHONG_ACTIVITY_ID, 67).                    %% 玩家累充活动id
-define(PLAYER_FIRST_INTO_WORLD_SCENE, 68).                             %% 玩家第一次进入 世界场景

-define(PLAYER_GAME_DATA_TEST_COST_TOTAL_RMB, 69).                      %% 玩家测试记录消耗砖石总值
-define(PLAYER_GAME_DATA_KILL_MONSTER_AWARD_DIAMOND, 70).				%% 玩家击杀怪物(通过monster表diamond_reward_list字段)获得的砖石数量
-define(PLAYER_GAME_DATA_ANGER_SKILL_EFFECT, 71).						%% 玩家怒气技能效果id

-define(PLAYER_GAME_DATA_DAILY_POINTS, 72).								%% 玩家每日活跃积分（跨天重置）
-define(PLAYER_GAME_DATA_DAILY_TASK_REFRESH_DATE, 73).					%% 最后一次刷新日常任务日期
-define(PLAYER_GAME_DATA_CARD_CONDITION_IS_REPAIR, 74).					%% 图鉴条件是否修复

%% 赏金任务相关
-define(PLAYER_GAME_DATA_BOUNTY_TASK_LAST_DATE, 75).					%% 赏金任务刷新日期
-define(PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID, 76).					%% 接受的赏金任务id
-define(PLAYER_GAME_DATA_BOUNTY_TASK_RESET_TIMES, 77).					%% 当天累计重置赏金任务次数
-define(PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_TIMES, 78).					%% 当天累计接受赏金任务次数
-define(PLAYER_GAME_DATA_BOUNTY_TASK_COMPLETED_TIMES, 79).				%% 累计完成赏金任务总次数

%% 无尽对决相关
-define(PLAYER_GAME_DATA_WHEEL_RECORD_ID, 81).					        %% 玩家无尽对决记录唯一id

%% 聊天相关
-define(PLAYER_GAME_DATA_CHAT_RECORD_ID, 82).					        %% 玩家聊天记录id
-define(PLAYER_GAME_DATA_SIGNATURE, 83).					            %% 玩家个性签名