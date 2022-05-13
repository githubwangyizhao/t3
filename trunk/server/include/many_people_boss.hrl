%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         多人BOSS
%%% @end
%%% Created : 25. 十一月 2020 下午 06:12:43
%%%-------------------------------------------------------------------
-author("Administrator").
%% --------------------------------该文件所有is字段，使用的是0和1，需要使用TRAN_INT_TO_BOOR

%%=============================================CONDITION=========================================================
-define(MANY_PEOPLE_BOSS_CONDITION_MANA, mana).
-define(MANY_PEOPLE_BOSS_CONDITION_LEVEL, level).
-define(MANY_PEOPLE_BOSS_CONDITION_VIP_LEVEL, vip_level).

%%%% -------------------------------------------------------dict---------------------------------------------------------------
%%%% 房间数据
%%-define(DICT_MANY_PEOPLE_BOSS_ROOM_DATA, dict_many_people_boss_room_data).
%%-record(dict_many_people_boss_room_data, {
%%    room_id,                                %% 房间id
%%    boss_id,                                %% BoosId
%%    invitation_code,                        %% 邀请码
%%    people_count_limit,                     %% 人数上限
%%    is_lock = 0,                            %% 是否上锁
%%    room_owner_player_id,                   %% 房主玩家id
%%    is_participate_in,                      %% 房主是否参与游戏
%%    is_all_ready_auto_start,                %% 是否全部准备自动开始
%%    pos_data_list                           %% 房间位置数据
%%}).
%%
%%%% 房间位置数据
%%-define(DICT_MANY_PEOPLE_BOSS_ROOM_POS_DATA, dict_many_people_boss_room_pos_data).
%%-record(dict_many_people_boss_room_pos_data, {
%%    pos_id,
%%    player_id,
%%    is_ready
%%}).
%%
%%%% 玩家数据
%%-define(DICT_MANY_PEOPLE_BOSS_PLAYER_DATA, dict_many_people_boss_room_player_data).
%%-record(dict_many_people_boss_room_player_data, {
%%    player_id,
%%    room_id,
%%    pos_id
%%}).
%%
%% 房间数量,{Key:?DICT_MANY_PEOPLE_BOSS_ROOM_NUM,Value:RoomNum}
%%-define(DICT_MANY_PEOPLE_BOSS_ROOM_NUM, dict_many_people_boss_room_num).

%% 邀请码对应房间Id,{Key:{?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE,InvitationCode},Value:RoomId}
-define(DICT_MANY_PEOPLE_BOSS_INVITATION_CODE, dict_many_people_boss_invitation_code).

%%%% 玩家对应房间Id,{Key:{?DICT_MANY_PEOPLE_BOSS_PLAYER,PlayerId},Value:RoomId}
%%-define(DICT_MANY_PEOPLE_BOSS_PLAYER, dict_many_people_boss_player).

%% 玩家房间
-define(DICT_MANY_PEOPLE_BOSS_PLAYER_ROOM, dict_many_people_boss_room_player_room).
%%-record(dict_many_people_boss_room_player_data, {
%%    player_id,
%%    platform_id,
%%    server_id,
%%    room_id,
%%    model_head_figure
%%}).

%% 最大房间Id,{Key:?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID,Value:MaxRoomId}
-define(DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID, dict_many_people_boss_max_room_id).

%% -------------------------------------------------------ETS---------------------------------------------------------------
%% 房间数据
-define(ETS_MANY_PEOPLE_BOSS_ROOM_DATA, ets_many_people_boss_room_data).
-record(ets_many_people_boss_room_data, {
    room_id,                                %% 房间id
    boss_id,                                %% BoosId
    invitation_code,                        %% 邀请码
    is_lock = 0,                            %% 是否上锁
    password,
    is_participate_in = 0,                  %% 房主是否参与游戏
    owner_pos_data,                         %% 房主玩家数据           Type:PosData,但是PosId = 0
    is_all_ready_auto_start = 1,            %% 是否全部准备自动开始
    pos_data_list,                          %% 房间位置数据
    kick_player_list,                       %% 被T出的玩家列表
    state = 0,                              %% 状态(0:房间等待中,1:战斗中)
    mission_worker,                         %% 副本
    is_robot_room = false                   %% 是否机器人房
}).

%% 房间位置数据
-define(MANY_PEOPLE_BOSS_ROOM_POS_DATA, many_people_boss_room_pos_data).
-record(many_people_boss_room_pos_data, {
    pos_id,                                 %% 位置id
    is_ready,                               %% 是否准备
    player_id,                              %% 玩家id
    model_head_figure,                      %% 头像模型
    is_owner,                               %% 是否房主
    state                                   %% 状态:(0:正常,2:退出游戏有奖励通过邮件)
}).


%% -------------------------------------------------------gen_server ENUM---------------------------------------------------------------
-define(MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE1, 1).                                      %% 被房主T出
-define(MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE2, 2).                                      %% 房主关闭房间
-define(MANY_PEOPLE_BOSS_LEAVE_ROOM_TYPE3, 3).                                      %% 正常退出房间

-define(MANY_PEOPLE_BOSS_NOTICE_TYPE_LEAVE, many_people_boss_notice_type_leave).    %% 通知类型：离开

-define(MANY_PEOPLE_BOSS_JOIN_ROOM, many_people_boss_join_room).                    %% 回调函数命名:加入房间
-define(MANY_PEOPLE_BOSS_CREATE_ROOM, many_people_boss_create_room).                %% 回调函数命名:创建房间
-define(MANY_PEOPLE_BOSS_START, many_people_boss_start).                            %% 回调函数命名:开始
-define(MANY_PEOPLE_BOSS_PARTICIPATE_IN, many_people_boss_participate_in).          %% 回调函数命名:房主参与Boss战斗
-define(MANY_PEOPLE_BOSS_KICK_OUT_PLAYER, many_people_boss_kick_out_player).        %% 回调函数命名:房主踢出玩家
-define(MANY_PEOPLE_BOSS_SET_ALL_READY_START, many_people_boss_set_all_ready_start).%% 回调函数命名:设置全部准备自动开始
-define(MANY_PEOPLE_BOSS_READY, many_people_boss_ready).                            %% 回调函数命名:准备
-define(MANY_PEOPLE_BOSS_LEAVE_ROOM, many_people_boss_leave_room).                  %% 回调函数命名:离开房间
-define(MANY_PEOPLE_BOSS_MISSION_BALANCE, many_people_boss_mission_balance).        %% 回调函数命名:副本结算
-define(MANY_PEOPLE_BOSS_MISSION_LEAVE, many_people_boss_mission_leave).            %% 回调函数命名:副本玩家离开
-define(MANY_PEOPLE_BOSS_LOGIN_GAME, many_people_boss_login_game).                  %% 回调函数命名:玩家登录游戏

%%-define(MANY_PEOPLE_BOSS_ROOM_START_DELAY, many_people_boss_room_start_delay).      %% 房间状态：等待
%%-define(MANY_PEOPLE_BOSS_ROOM_READY_START, many_people_boss_room_ready_start).      %% 房间状态：准备开始
%%-define(MANY_PEOPLE_BOSS_ROOM_FIGHTING, many_people_boss_room_fighting).            %% 房间状态：战斗中