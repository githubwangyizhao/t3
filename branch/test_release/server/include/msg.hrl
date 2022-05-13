
%% ----------------------------------
%% @doc 	玩家进程消息
%% @throws 	none
%% @end
%% ----------------------------------
-define(MSG_CLIENT_AFTER_ENTER_GAME, msg_after_enter_game).                             %% 进入游戏
-define(MSG_CLIENT_KILL_MONSTER, msg_kill_monster).                                     %% 杀怪
-define(MSG_CLIENT_ATTACK_MONSTER, msg_attack_monster).                                 %% 攻击怪
-define(MSG_CLIENT_KILL_PLAYER, msg_kill_player).                                       %% 击杀玩家
-define(MSG_CLIENT_BE_KILLED, msg_be_killed).                                           %% 被击杀
-define(MSG_CLIENT_RETURN_WORLD_SCENE, msg_return_world_scene).                         %% 返回世界场景
-define(MSG_CLIENT_RECOVER_TIMES, msg_recover_times).                                   %% 恢复次数
-define(MSG_CLIENT_PLAYER_MAIL, msg_player_mail).                                       %% 玩家邮件
-define(MSG_CLIENT_COLLECT, msg_collect).                                               %% 玩家采集
-define(MSG_CLIENT_ENTER_SCENE, msg_enter_scene).                                       %% 进入场景
-define(MSG_CLIENT_ONLINE_AWARD, msg_online_award).                                     %% 在线奖励
-define(MSG_CLIENT_TIME_LIMIT_TASK, msg_time_limit_task).                               %% 限时任务
-define(MSG_PLAYER_FIGHT_MONSTER_LOG, msg_player_fight_monster_log).                    %% 玩家战斗怪物日志
-define(MSG_PLAYER_FIGHT_FUNCTION_MONSTER_LOG, msg_player_fight_function_monster_log).  %% 玩家战斗功能怪物日志
%% ----------------------------------
%% @doc 	场景进程消息
%% @throws 	none
%% @end
%% ----------------------------------
-define(MSG_SCENE_STOP, msg_stop).
-define(MSG_SCENE_GET_STATE, msg_get_state).
-define(MSG_SCENE_GET_PLAYER_COUNT, msg_get_player_count).                              %% 获取场景玩家数量
-define(MSG_SCENE_PLAYER_ENTER_SCENE, msg_player_enter).                                %% 玩家进入场景
-define(MSG_SCENE_PLAYER_LEAVE, msg_player_leave).                                      %% 玩家离开场景
-define(MSG_SCENE_PLAYER_LEAVE_ASYNC, msg_player_leave_async).                          %% 玩家异步离开场景
-define(MSG_SCENE_CHECK_CLOSE, msg_check_close).                                        %% 检测关闭
-define(MSG_SCENE_GET_PLAYER_POS, msg_player_get_pos).                                  %% 获取玩家场景位置
-define(MSG_SCENE_GET_SCENE_PLAYER_ID_LIST, msg_player_get_scene_player_id_list).       %% 获取场景玩家id列表
-define(MSG_SCENE_PLAYER_REBIRTH, msg_player_rebirth).                                  %% 玩家复活
-define(MSG_SCENE_PLAYER_TRANSMIT, msg_player_transmit).                                %% 传送
-define(MSG_SCENE_PLAYER_DO_TRANSMIT, msg_player_do_transmit).                          %% 传送
-define(MSG_SCENE_PLAYER_MOVE, msg_player_move).                                        %% 玩家移动
-define(MSG_SCENE_PLAYER_MOVE_STEP, msg_player_move_step).
-define(MSG_SCENE_PLAYER_STOP_MOVE, msg_player_stop_step).
-define(MSG_SCENE_PLAYER_JUMP_STEP, msg_player_jump_step).
-define(MSG_SCENE_PLAYER_JOINT_MONSTER_POINT, msg_player_join_monster_point).
-define(MSG_SCENE_SYNC_PLAYER_DATA, msg_sync_player_data).                              %% 同步玩家信息
-define(MSG_SCENE_ASYNC_INIT, msg_async_init).                                          %% 异步初始化
-define(MSG_SCENE_MONSTER_HEART_BEAT, msg_monster_heart_beat).                          %% 怪物心跳
-define(MSG_SCENE_PLAYER_COLLECT, msg_player_collect).                                  %% 玩家采集
-define(MSG_SCENE_REMOVE_SCENE_ITEM_LIST, msg_remvoe_scene_item).                       %% 移除场景物品
-define(MSG_SCENE_NOTICE_NEAR_PLAYER, msg_notice_near_player).                          %% 通知附近玩家
-define(MSG_SCENE_CREATE_MONSTER, msg_create_monster).                                  %% 创建怪物
%%-define(MSG_SCENE_CREATE_MONSTER_GUAJI, msg_create_monster_guaji).                      %% 创建怪物挂机
-define(MSG_SCENE_CREATE_MONSTER_BY_ARGS, msg_create_monster_by_args).                  %% 创建怪物 根据参数
-define(MSG_SCENE_CREATE_MONSTER_2, msg_create_monster_2).
-define(MSG_SCENE_CREATE_MONSTER_LIST, msg_create_monster_list).                        %% 创建怪物列表
-define(MSG_SCENE_TRIGGER_NEXT_ROUND, msg_trigger_next_round).                          %% 触发下一回合
-define(MSG_SCENE_MISSION_ROUND_END, msg_mission_round_end).                            %% 回合结束
-define(MSG_SCENE_REQUEST_NAVIGATE, msg_request_navigate).                              %% 请求寻路
-define(MSG_SCENE_NAVIGATE_RESULT, msg_navigate_result).                                %% 寻路结果
%%-define(MSG_SCENE_RECOVER_PLAYER_HP, msg_recover_player_hp).                            %% 恢复玩家血量
-define(MSG_SCENE_CHECK_ROBOT, msg_check_robot).                                        %% 检查机器人
-define(MSG_SCENE_CREATE_ROBOT, msg_create_robot).                                      %% 创建机器人
%%-define(MSG_SCENE_DEATH_ROBOT, msg_death_robot).                                        %% 销毁机器人
-define(MSG_SCENE_ROBOT_HEART_BEAT, msg_robot_heart_beat).                              %% 机器人心跳
%%-define(MSG_SCENE_HANDLE_SKILL_MOVE, msg_handle_skill_move).                            %% 技能位移
-define(MSG_SCENE_DESTROY_ALL_MONSTER, msg_destroy_all_monster).                        %% 销毁所有怪物
-define(MSG_SCENE_CLEAR_ALL_SKILL_CD, msg_clear_all_skill_cd).                          %% 清理所有技能cd
-define(MSG_SCENE_REMOVE_BUFF, msg_remove_buff).                                        %% 移除buff
-define(MSG_SCENE_CLOCK_INTERVAL_BUFF, msg_clock_interval_buff).                        %% 间隔buff
-define(MSG_SCENE_REBIRTH_MONSTER, msg_rebirth_monster).                                %% boss复活

-define(MSG_SCENE_DICT_KEY, msg_scene_dict_key).                                        %% 场景字典

-define(MSG_PLAYER_CLEAN_UP, msg_player_clean_up).                                      %% 清理玩家
-define(MSG_SCENE_DESTROY_MONSTER, msg_scene_destroy_monster).                          %% 销毁怪物
-define(MSG_SCENE_PLAYER_DROP_ITEM_LIST, msg_scene_player_drop_item_list).              %% 玩家掉落物品
-define(MSG_SCENE_DEAL_BUFF_HURT, msg_scene_deal_buff_hurt).                            %% 处理buff 伤害
-define(MSG_SCENE_BROADCAST_CHAT_MSG, msg_scene_broadcast_chat_msg).                    %% 广播聊天消息

-define(MSG_SCENE_STEP_BY_STEP_SY_FIGHT_MSG, msg_scene_step_by_step_sy_fight_msg).      %% 步步紧逼副本继续挑战
-define(MSG_SCENE_STEP_BY_STEP_SY_GET_AWARD_MSG, msg_scene_step_by_step_sy_get_award_msg).%% 步步紧逼副本领取奖励

-define(MSG_SCENE_GOLD_RANK_MSG, msg_scene_gold_rank_msg).                              %% 广播金币排行消息
-define(MSG_SCENE_SEND_MSG, msg_scene_send_msg).                                        %% 发送消息
-define(MSG_SCENE_AUTO_FIGHT_SKILL, msg_scene_auto_fight_skill).                        %% 玩家场景自动战斗技能
-define(MSG_SCENE_CLOSE_PLAYER_SHEN_LONG, msg_scene_close_player_shen_long).            %% 关闭玩家神龙buff
-define(MSG_SCENE_SHEN_LONG_DRAW, msg_scene_shen_long_draw).                            %% 神龙抽奖
-define(MSG_SCENE_GET_GOLD_RANK, msg_scene_get_gold_rank).                              %% 获得金币排行榜
-define(MSG_SCENE_ALL_MONSTER_RECOVER_HP, msg_scene_all_monster_recover_hp).            %% 全部怪物恢复hp
-define(MSG_SCENE_MONSTER_RECOVER_HP, msg_scene_monster_recover_hp).                    %% 恢复怪物hp
-define(MSG_SCENE_PLAYER_SHOW_ACTION, msg_scene_player_show_action).                    %% 展示动作
-define(MSG_SCENE_USE_FIGHT_ITEM, msg_scene_use_fight_item).                            %% 使用战斗道具【狂奔卷轴|冰冻卷轴|自动卷轴】
-define(MSG_SCENE_ADD_ANGER, msg_scene_add_anger).                                      %% 增加怒气值
-define(MSG_SCENE_MONSTER_WILD_TIMEOUT, monster_wild_timeout).                          %% 怪物狂暴超时

%% @doc 蓄力技能
-define(MSG_SCENE_WAIT_SKILL, msg_scene_wait_skill).                                    %% 蓄力技能
-define(MSG_SCENE_PLAN_USE_WAIT_SKILL, msg_scene_plan_use_wait_skill).                  %% 打算使用蓄力技能
-define(MSG_SCENE_WAIT_SKILL_TRIGGER, msg_scene_wait_skill_trigger).                    %% 蓄力技能触发
-define(MSG_SCENE_USE_WAIT_SKILL, msg_scene_use_wait_skill).                            %% 使用蓄力技能
-define(MSG_SCENE_MONSTER_USE_SKILL, msg_scene_use_skill).                              %% 怪物施放技能
-define(MSG_SCENE_CANCEL_CANNOT_BE_ATTACK, msg_scene_cancel_cannot_be_attack).          %% 取消无法被选中

%% @doc LOG
-define(MSG_SCENE_FIGHT_MONSTER_LOG, msg_scene_fight_monster_log).                      %% 场景战斗怪物日志

%% @doc SceneMonsterLoop
-define(MSG_SCENE_LOOP, msg_scene_loop).                                                %% 怪物循环
-define(MSG_SCENE_LOOP_TIME_CLOCK, msg_scene_loop_time_clock).                          %% 事件循环定时器
-define(MSG_SCENE_LOOP_UPDATE_NOTICE, msg_scene_loop_update_notice).                    %% 更新循环通知
-define(MSG_SCENE_LOOP_YU_CHAO, msg_scene_loop_yu_chao).                                %% 鱼潮
-define(MSG_SCENE_LOOP_CLOSE_EVENT, msg_scene_loop_close_event).                        %% 关闭事件
-define(MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, msg_scene_loop_create_monster_guaji).      %% 创建怪物挂机
-define(MSG_SCENE_LOOP_MONSTER_DEATH, msg_scene_loop_monster_death).                    %% 怪物死亡
-define(MSG_SCENE_LOOP_MONSTER_DEATH_FIGHT, msg_scene_loop_monster_death_fight).        %% 怪物死亡战斗
-define(MSG_SCENE_LOOP_BOX_FINISHED, msg_scene_loop_box_finished).        				%% 盲盒宝箱打完
-define(MSG_SCENE_LOOP_BALL_FINISHED, msg_scene_loop_ball_finished).        			%% 彩球怪打完
-define(MSG_SCENE_CREATE_BOSS_MONSTER, msg_scene_create_boss_common_monster).			%% 创建boss事件怪
-define(MSG_SCENE_CREATE_ALL_MONSTER, msg_scene_create_all_monster).					%% 创建所有普通怪

%% @doc MatchScene
-define(MSG_SCENE_MATCH_SCENE, msg_scene_match_scene).                                  %% 匹配场

% ---------------------- 玩家数据同步场景 ------------------------%
-define(MSG_SYNC_LEVEL, msg_sync_level).                                %% 等级
-define(MSG_SYNC_VIP_LEVEL, msg_sync_vip_level).                        %% vip等级
-define(MSG_SYNC_POWER, msg_sync_power).                                %% 战力
-define(MSG_SYNC_MAX_HP, msg_sync_max_hp).                              %% 最大血量
-define(MSG_SYNC_HP, msg_sync_hp).                                      %% 最大血量
-define(MSG_SYNC_ATTACK, msg_sync_attack).                              %% 攻击
-define(MSG_SYNC_DEFENSE, msg_sync_defense).                            %% 防御
-define(MSG_SYNC_HIT, msg_sync_hit).                                    %% 命中
-define(MSG_SYNC_DODGE, msg_sync_dodge).                                %% 跳闪避
-define(MSG_SYNC_CRITICAL, msg_sync_critical).                          %% 暴击
-define(MSG_SYNC_TENACITY, msg_sync_tenacity).                          %% 韧性
-define(MSG_SYNC_MOVE_SPEED, msg_sync_move_speed).                      %% 移动速度

-define(MSG_SYNC_CRIT_TIME, msg_sync_crit_time).                        %% 暴击时长
-define(MSG_SYNC_HURT_ADD, msg_sync_hurt_add).                          %% 造成伤害增加
-define(MSG_SYNC_HURT_REDUCE, msg_sync_hurt_reduce).                    %% 受到伤害减少
-define(MSG_SYNC_CRIT_HURT_ADD, msg_sync_crit_hurt_add).                %% 造成暴击伤害增加
-define(MSG_SYNC_CRIT_HURT_REDUCE, msg_sync_crit_hurt_reduce).          %% 受到暴击伤害减少
-define(MSG_SYNC_HP_REFLEX, msg_sync_hp_reflex).                        %% 生命恢复
-define(MSG_SYNC_RATE_RESIST_BLOCK, msg_sync_rate_resist_block).        %% 破击
-define(MSG_SYNC_RATE_BLOCK, msg_sync_rate_block).                      %% 格挡

-define(MSG_SYNC_TITLE_ID, msg_sync_title_id).                          %% 称号id
-define(MSG_SYNC_MAGIC_WEAPON_ID, msg_sync_magic_weapon_id).            %% 法宝id
-define(MSG_SYNC_WINGS_ID, msg_sync_wings_id).                          %% 翅膀id
-define(MSG_SYNC_CLOTH_ID, msg_sync_cloth_id).                          %% 时装id
-define(MSG_SYNC_HERO_ID, msg_sync_hero_id).                            %% 英雄id
-define(MSG_SYNC_HERO_ARMS, msg_sync_arms).                             %% 英雄武器
-define(MSG_SYNC_HERO_ORNAMENTS, msg_sync_ornaments).                   %% 英雄饰品
-define(MSG_SYNC_HEAD_ID, msg_sync_head_id).                            %% 头像id
-define(MSG_SYNC_HEAD_FRAME_ID, msg_sync_head_frame_id).                %% 头像框id
-define(MSG_SYNC_CHAT_QI_PAO_ID, msg_sync_chat_qi_pao_id).              %% 聊天气泡id
-define(MSG_SYNC_IS_CAN_ADD_ANGER, msg_sync_is_can_add_anger).          %% 是否可以增加怒气
%%-define(MSG_SYNC_SHEN_LONG_ID, msg_sync_shen_long_id).                  %% 神龙id
%%-define(MSG_SYNC_HUO_QIU_ID, msg_sync_huo_qiu_id).                      %% 火球id
%%-define(MSG_SYNC_DI_ZHEN_ID, msg_sync_di_zhen_id).                      %% 地震id

-define(MSG_SYNC_CLOTH_LEVEL, msg_sync_cloth_level).                    %% 时装等级
-define(MSG_SYNC_ACTIVE_SKILL, msg_sync_active_skill).                  %% 主动技能
-define(MSG_SYNC_SEX, msg_sync_sex).                                    %% 性别
-define(MSG_SYNC_NAME, msg_sync_name).                                  %% 昵称

-define(MSG_SYNC_PASSIVE_SKILL, msg_sync_passive_skill).                %% 被动技能
-define(MSG_SYNC_TEAM_ID, mag_sync_team_id).                            %% 队伍
-define(MSG_SYNC_PK_MODE, mag_sync_pk_mode).                            %% PK模式

-define(MSG_SCENE_ROBOT_FIGHT, msg_scene_robot_fight).                                  %% 场景内boss互搂
-define(MSG_DIZZY_TIME_REDUCE, msg_dizzy_time_reduce).                  %% 玩家减少眩晕时间
%%-define(MSG_MONSTER_UNDER_ATTACK, msg_monster_under_attack).            %% 怪物正在遭受攻击
%%-define(MSG_MONSTER_BIRTH_EVENT, msg_monster_birth_event).              %% 怪物出生时间
-define(MSG_HERO_ENTER_MISSION_DELAY, msg_hero_enter_mission_delay).    %% hero versus boss延迟英雄入场
-define(MSG_MONSTER_ENTER_MISSION_DELAY, msg_monster_enter_mission_delay).    %% hero versus boss延迟怪物入场

