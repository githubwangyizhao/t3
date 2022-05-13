%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             client
%%% @end
%%% Created : 26. 五月 2016 下午 4:08
%%%-------------------------------------------------------------------
-define(DICT_PLAYER_ID, dict_player_id).                                    %% 玩家id
%%-define(DICT_CLIENT_ACC_ID , dict_client_acc_id).                          %% 帐号id
%%-define(DICT_CLIENT_SERVER_ID , dict_client_server_id).                    %% 区服id
-define(DICT_ACCOUNT_TYPE, dict_account_type).                              %% 账号类型
-define(DICT_PLAYER_SCENE_WORKER, dict_player_scene_worker).                %% 玩家所在的场景 进程
-define(DICT_PLAYER_SCENE_ID, dict_player_scene_id).                        %% 玩家所在的场景 id
-define(DICT_DO_ENTER_SCENE_ARGS, dict_do_enter_scene_args).                %% 进入的场景参数
-define(DICT_PLAYER_LOGIN_TIME, dict_login_time).                           %% 登录时间
-define(DICT_IS_ENTER_GAME, dict_is_enter_game).                            %% 是否已经进入游戏
-define(DICT_OFFLINE_AWARD, dict_offline_award).                            %% 离线奖励
-define(DICT_PLAYER_LOGIN_IP, dict_login_ip).                               %% 登录IP
-define(DICT_LAST_LAST_CHANNEL_CHAT_TIME, dict_last_channel_chat_time).     %% 上次频道聊天时间
-define(DICT_CACHE_OBJ_BUFF, dict_buff).                                    %% obj_buff
-define(DICT_OBJ_PASSIVE_SKILL, dict_passive_skill).                        %% obj_passive_skill
-define(DICT_IS_LEAVE_GAME, dict_is_leave_game).                            %% 是否离开游戏
-define(DICT_EXIT_MISSION_JUMP_SCENE, dict_exit_mission_jump_scene).        %% 退出副本挑战场景
-define(DICT_CACHE_MISSION_AWARD, dict_cache_mission_award).                %% 缓存副本奖励
-define(DICT_ACTIVITY_CHECK_LIST, dict_activity_check_list).                %% 玩家活动检测内容列表
-define(DICT_ACTIVITY_DATA_LIST, dict_activity_data_list).                  %% 玩家活动数据列表
-define(DICT_ACCOUNT_SOURCE, dict_account_source).                          %% 玩家账号来源: fb，google，visitor，line

%% 平台相关信息
-define(DICT_PLATFORM_OPEN_ID, dict_open_id).                               %% 平台open_id
-define(DICT_PLATFORM_TICKET, dict_ticket).                                 %% 平台密钥
-define(DICT_PLATFORM_ENTRY, dict_platform_entry).                          %% 平台入口
%%-define(DICT_PLATFORM_IS_FOCUS,  dict_platform_is_focus).                  %% 是否关注
-define(DICT_PLATFORM_PLATFORM_ID, dict_platform_platform_id).              %% 平台id
-define(DICT_CHANNEL, dict_channel).                                        %% 渠道
-define(DICT_EQUIP_ID, dict_equip_id).                                      %% 设备唯一标识码


%% qq 平台相关信息
-define(DICT_QQ_PLATFORM, dict_qq_platform).                                %% qq 平台 platform
-define(DICT_QQ_QUA, dict_qq_qua).                                          %% qq 平台 qua
-define(DICT_QQ_VIA, dict_qq_via).                                          %% qq 平台 via 20210422 用来记录登陆协议客户端上报的手机系统

%% 微信 平台相关信息
-define(DICT_WX_SESSION_KEY, dict_wx_session_key).                          %% 微信 平台 session_key


%% 玩家进程定时器
-define(CLIENT_WORKER_TIMER_CLEAN_EXPIRE_PROP, client_worker_timer_clean_expire_prop).      %% 删除过期道具
-define(CLIENT_WORKER_TIMER_MSG_PLAYER_ACTIVITY, client_worker_timer_msg_player_activity).  %% 玩家活动记时器
-define(CLIENT_WORKER_TIMER_BALANCE_REG_PACKAGE, client_worker_timer_balance_reg_package).  %% 结算红包
-define(CLIENT_WORKER_TIMER_CLOSE_PERSON_ACTIVITY, client_worker_timer_close_activity).     %% 个人活动关闭
-define(CLIENT_WORKER_TIMER_OPEN_PERSON_ACTIVITY, client_worker_timer_open_activity).       %% 个人活动开启
-define(CLIENT_WORKER_TIMER_CLEAN_EXPIRE_SPECIAL_PROP, client_worker_timer_clean_expire_special_prop).   %% 删除过期特殊道具
