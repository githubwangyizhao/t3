%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            副本
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------

-define(NOTICE_ROUND_TYPE_ROUND, 1).                                                    %% 通知回合
-define(NOTICE_ROUND_TYPE_MONSTER, 2).                                                  %% 通知怪物数量

-define(SCENE_STOP_TIME, 10000).                                                        %% 10秒后关闭场景

-define(DICT_MONSTER_TOTAL_NUM, dict_monster_total).                                    %% 怪物总数量
-define(DICT_KILL_MONSTER_NUM, dict_kill_monster_num).                                  %% 击杀怪物数量
-define(DICT_MISSION_TASK_DATA, dict_mission_task_data).                                %% 副本任务数据
-define(DICT_MISSION_IS_START, dict_mission_is_start).                                  %% 副本是否启动
-define(DICT_MISSION_RESULT, dict_mission_result).                                      %% 副本结果
%%-define(DICT_IS_TASK_MISSION, dict_is_task_mission).                                  %% 是否任务型副本
-define(DICT_MISSION_TASK_TYPE, dict_mission_task_type).                                %% 副本任务类型
%%-define(DICT_MISSION_KIND, dict_mission_kind).
-define(DICT_IS_PLAYER_DIR_BALANCE, dict_is_player_die_balance).                        %% 是否玩家死亡就结算副本
-define(DICT_IS_SUBSCRIBE_MSG_PLAYER_DIE, dict_is_subscribe_msg_player_die).            %% 是否订阅消息:玩家死亡
-define(DICT_IS_SUBSCRIBE_MSG_PLAYER_REBIRTH, dict_is_subscribe_msg_player_rebirth).    %% 是否订阅消息:玩家复活
-define(DICT_IS_SUBSCRIBE_MSG_MONSTER_DIE, dict_is_subscribe_msg_monster_die).          %% 是否订阅消息:怪物死亡
-define(DICT_IS_SUBSCRIBE_MSG_MONSTER_ENTER, dict_is_subscribe_msg_monster_enter).      %% 是否订阅消息:怪物出生
-define(DICT_MISSION_IS_DEAL_RESULT, dict_mission_is_deal_result).                      %% 是否副本已经处理结果
-define(DICT_MISSION_IS_BALANCE, dict_mission_is_balance).                              %% 是否副本已经结算
-define(DICT_MISSION_ROUND, dict_mission_round).                                        %% 副本回合
-define(DICT_MISSION_ROUND_END_TIME, dict_mission_end_time).                            %% 副本本回合
-define(DICT_INIT_MISSION_ROUND, dict_init_mission_round).                              %% 副本初始回合
-define(DICT_MISSION_BALANCE_MS, dict_mission_balance_time_s).                          %% 副本结算时间(ms)
%%-define(DICT_IS_NOTICE_ROUND, dict_mission_is_notice_round).                          %% 是否通知回合
%%-define(DICT_IS_ROUND_AWARD, dict_mission_is_round_award).                            %% 是否有回合奖励
-define(DICT_ROUND_AWARD_LIST, dict_mission_round_award_list).                          %% 回合奖励列表
-define(DICT_MISSION_DATA, dict_mission_data).                                          %% 副本数据
-define(DICT_MISSION_SCENE_BOSS_WAIT_TIME, dict_mission_scene_boss_wait_time).          %% 副本场景boss等待时间
-define(DICT_MISSION_SCENE_BOSS_BALANCE_MS, dict_mission_scene_boss_balance_ms).        %% 副本场景结算时间(ms)

-define(DICT_LAST_CHALLENGE_MISSION_TIME, dict_last_challenge_mission_time).            %% 上次挑战副本时间

-define(MSG_UPDATE_MISSION_TASK, msg_update_mission_task).                              %% 更新副本任务
-define(MSG_MISSION_ROUND_START, msg_mission_round_start).                              %% 副本回合开始
-define(MSG_MISSION_ROUND_END, msg_mission_round_end).                                  %% 副本回合结束
-define(MSG_DUJIE_MISSION_RECOVER, msg_dujie_mission_recover).                          %% 渡劫副本回血

-define(MSG_MISSION_START, msg_mission_start).                                          %% 副本启动
-define(MSG_MISSION_MSG, msg_mission_msg).                                              %% 副本消息
%%-define(MSG_MISSION_GET_AWARD, msg_mission_get_award).                                %% 领取奖励
-define(MSG_MISSION_BALANCE, msg_mission_balance).                                      %% 副本结算

-define(DICT_MISSION_START_TIME_MS, msg_mission_start_time).                            %% 副本启动时间
-define(MSG_MISSION_TASK_FINISH, msg_mission_task_finish).                              %% 副本任务完成
%%-define(MSG_MISSION_CLEAN_ALL_PLAYER, msg_mission_clean_all_player).                  %% 清理所有玩家
-define(DICT_MONSTER_BELONG_PLAYER_ID, dict_belong_player_id).                          %% 归属玩家id

-define(MSG_MISSION_GATHER, msg_mission_gather).                                        %% 采集


-define(MSG_REQUEST_BALANCE_MISSION, msg_request_balance_mission).                      %% 请求结算副本

-define(MSG_ASYNC_CHALLENGE_MISSION, msg_async_challenge_mission).                      %% 异步挑战副本

-define(MSG_GUESS_MISSION_ROUND_BALANCE, msg_guess_mission_round_balance).
-define(MSG_GUESS_MISSION_REFRESH_COST, msg_guess_mission_refresh_cost).
-define(MSG_SHI_SHI_MISSION_ROBOT, msg_shi_shi_mission_robot).


-define(MSG_BRAVE_ONE_INIT_CHECK_SCENE, msg_brave_one_init_check_scene).                %% 勇敢者初始检测场景
-define(MSG_BRAVE_ONE_NEXT_FIGHT_PLAYER, msg_brave_one_next_fight_player).              %% 勇敢者下一回战斗玩家


-define(MSG_STEP_BY_STEP_SY_INIT_CHECK_SCENE, msg_step_by_step_sy_init_check_scene).    %% 步步紧逼初始检测场景
-define(MSG_STEP_BY_STEP_SY_NEXT_FIGHT_PLAYER, msg_step_by_step_sy_next_fight_player).  %% 步步紧逼下一回战斗玩家

-define(MSG_EITHER_TIMER, msg_either_timer).                                            %% 二选一副本定时器

-define(MSG_SCENE_BOSS_BET, msg_scene_boss_bet).                                        %% 场景boss 竞猜
-define(MSG_SCENE_BOSS_BET_RESET, msg_scene_boss_bet_reset).                            %% 场景boss 竞猜 重置
-define(MSG_SCENE_BOSS_POS_OPEN_BOSS, msg_scene_boss_pos_open_boss).                    %% 场景boss 位置 开启 boss
-define(MSG_SCENE_BOSS_POS_BOSS_TELEPORT, msg_scene_boss_pos_boss_teleport).            %% 场景boss 位置 boss 瞬移


-record(challenge_player_info, {
    player_id,              %% 玩家id
    can_challenge_time      %% 可以挑战时间
}).

-define(MSG_PLAYER_INTO_GUESS_MISSION_BET, msg_player_into_guess_mission_bet).          %% 玩家进入猜一猜下注界面
-define(MSG_PLAYER_LEAVE_GUESS_MISSION_BET, msg_player_leave_guess_mission_bet).        %% 玩家离开猜一猜下注界面
%%-define(MSG_SINGLE_PLAYER_BET_INFO, msg_single_player_bet_info).                        %% 获取指定玩家的下注信息
-define(MSG_PLAYER_BET, msg_player_bet).                                                %% 玩家下注
-define(MSG_PLAYER_RESET_BET, msg_player_reset_bet).                                    %% 玩家清空下注
-define(MSG_NOTICE_PLAYER_IN_BET, msg_notice_player_in_bet).                            %% 通知投注界面里的玩家，副本的状态
-define(MSG_NOTICE_PLAYER_IN_BET_RESULT, msg_notice_player_in_bet_result).              %% 通知投注界面里的玩家，副本的结果
-define(MSG_GUESS_BOSS_HEART_BEAT, msg_guess_boss_heart_beat).                          %% 猜一猜boss心跳

-define(MSG_ONE_ON_ONE_ROUND_BALANCE, msg_one_one_one_round_balance).

-define(MSG_HERO_VERSUS_BOSS_ROUND, msg_hero_versus_boss_round).                        %% 英雄怪物对战
-define(MSG_HERO_VERSUS_BOSS_FIGHTING, msg_hero_versus_boss_fighting).