%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         多人BOSS
%%% @end
%%% Created : 25. 十一月 2020 下午 06:12:43
%%%-------------------------------------------------------------------
-author("Administrator").

%% 邀请码对应房间Id,{Key:{?DICT_MANY_PEOPLE_BOSS_INVITATION_CODE,InvitationCode},Value:RoomId}
-define(DICT_SHI_SHI_ROOM_INVITATION_CODE, dict_shi_shi_room_invitation_code).

%% 玩家房间
-define(DICT_SHI_SHI_ROOM_PLAYER_ROOM, dict_shi_shi_room_player_room).
%%-record(dict_many_people_boss_room_player_data, {
%%    player_id,
%%    platform_id,
%%    server_id,
%%    room_id,
%%    model_head_figure
%%}).

%% 最大房间Id,{Key:?DICT_MANY_PEOPLE_BOSS_MAX_ROOM_ID,Value:MaxRoomId}
-define(DICT_SHI_SHI_ROOM_MAX_ROOM_ID, dict_shi_shi_room_max_room_id).

%% -------------------------------------------------------ETS---------------------------------------------------------------
%% 房间数据
-define(ETS_SHI_SHI_ROOM_DATA, ets_shi_shi_room_data).
-record(ets_shi_shi_room_data, {
    room_id,                                %% 房间id
    mission_id,                             %% 副本id
    invitation_code,                        %% 邀请码
    is_lock = 0,                            %% 是否上锁
    password,
    owner_player_id,
    pos_data_list,                          %% 房间位置数据
    kick_player_list,                       %% 被T出的玩家列表
    state = 0,                              %% 状态(0:房间等待中,1:战斗中)
    mission_worker                          %% 副本
}).

%% 房间位置数据
-define(SHI_SHI_POS_DATA, shi_shi_pos_data).
-record(shi_shi_pos_data, {
    pos_id,                                 %% 位置id
    is_ready,                               %% 是否准备
    player_id,                              %% 玩家id
    model_head_figure,                      %% 头像模型
    is_owner                                %% 是否房主
}).

%% -------------------------------------------------------gen_server ENUM---------------------------------------------------------------
-define(SHI_SHI_ROOM_LEAVE_ROOM_TYPE1, 1).                                      %% 被房主T出
-define(SHI_SHI_ROOM_LEAVE_ROOM_TYPE2, 2).                                      %% 房主关闭房间
-define(SHI_SHI_ROOM_LEAVE_ROOM_TYPE3, 3).                                      %% 正常退出房间

-define(SHI_SHI_ROOM_NOTICE_TYPE_LEAVE, shi_shi_room_notice_type_leave).    %% 通知类型：离开

-define(SHI_SHI_ROOM_GET_MISSION_ID, shi_shi_room_get_mission_id).          %% 回调函数命名:获得副本id
-define(SHI_SHI_ROOM_JOIN_ROOM, shi_shi_room_join_room).                    %% 回调函数命名:加入房间
-define(SHI_SHI_ROOM_CREATE_ROOM, shi_shi_room_create_room).                %% 回调函数命名:创建房间
-define(SHI_SHI_ROOM_START, shi_shi_room_start).                            %% 回调函数命名:开始
-define(SHI_SHI_ROOM_PARTICIPATE_IN, shi_shi_room_participate_in).          %% 回调函数命名:房主参与Boss战斗
-define(SHI_SHI_ROOM_KICK_OUT_PLAYER, shi_shi_room_kick_out_player).        %% 回调函数命名:房主踢出玩家
-define(SHI_SHI_ROOM_SET_ALL_READY_START, shi_shi_room_set_all_ready_start).%% 回调函数命名:设置全部准备自动开始
-define(SHI_SHI_ROOM_READY, shi_shi_room_ready).                            %% 回调函数命名:准备
-define(SHI_SHI_ROOM_LEAVE_ROOM, shi_shi_room_leave_room).                  %% 回调函数命名:离开房间
-define(SHI_SHI_ROOM_MISSION_BALANCE, shi_shi_room_mission_balance).        %% 回调函数命名:副本结算
-define(SHI_SHI_ROOM_MISSION_LEAVE, shi_shi_room_mission_leave).            %% 回调函数命名:副本玩家离开
-define(SHI_SHI_ROOM_LOGIN_GAME, shi_shi_room_login_game).                  %% 回调函数命名:玩家登录游戏

%%-define(MANY_PEOPLE_BOSS_ROOM_START_DELAY, many_people_boss_room_start_delay).      %% 房间状态：等待
%%-define(MANY_PEOPLE_BOSS_ROOM_READY_START, many_people_boss_room_ready_start).      %% 房间状态：准备开始
%%-define(MANY_PEOPLE_BOSS_ROOM_FIGHTING, many_people_boss_room_fighting).            %% 房间状态：战斗中