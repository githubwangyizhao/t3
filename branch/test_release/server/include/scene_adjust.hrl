%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 8月 2021 下午 02:21:25
%%%-------------------------------------------------------------------
-author("Administrator").

-record(scene_adjust_srv_state, {
    scene_data_list = []
}).
-record(scene_adjust_scene_data,{
    scene_id,
    scene_room_pid_list = []
}).

-define(SCENE_ADJUST_MSG, scene_adjust_msg).

-define(SCENE_ADJUST_TIMER, scene_adjust_timer).

-define(SCENE_ADJUST_MSG_CREATE_ROOM, scene_adjust_msg_create_room).
-define(SCENE_ADJUST_MSG_CLOSE_ROOM, scene_adjust_msg_close_room).
-define(SCENE_ADJUST_MSG_CHANGE_POOL_VALUE, scene_adjust_msg_change_pool_value).
-define(SCENE_ADJUST_MSG_SET_ROOM_STATE, scene_adjust_msg_set_room_state).
-define(SCENE_ADJUST_MSG_UPDATE_ROOM, scene_adjust_msg_update_room).
-define(SCENE_ADJUST_MSG_GET_PLAYER_STATE, scene_adjust_msg_get_player_state).              %% 获得玩家修正状态
-define(SCENE_ADJUST_MSG_PLAYER_BANKRUPTRY, scene_adjust_msg_player_bankruptry).            %% 破产
-define(SCENE_ADJUST_MSG_PLAYER_DEVELOP, scene_adjust_msg_player_develop).                  %% 破产恢复
-define(SCENE_ADJUST_MSG_RESET_ROOM_POOL_VALUE, scene_adjust_msg_reset_room_pool_value).    %% 重置房间值
-define(SCENE_ADJUST_MSG_ADD_BOSS_ADJUST_VALUE, scene_adjust_msg_add_boss_adjust_value).    %% 增加boss修正池子的值
%% @doc 触底反弹
-define(SCENE_ADJUST_MSG_TRY_REBOUND, scene_adjust_msg_try_rebound).                        %% 尝试触底反弹
-define(SCENE_ADJUST_MSG_REBOUND_END, scene_adjust_msg_rebound_end).                        %% 触底反弹结束
-define(SCENE_ADJUST_MSG_REBOUND_CD_END, scene_adjust_msg_rebound_cd_end).                  %% 触底反弹CD结束

%% @doc 测试日志
-define(SCENE_ADJUST_MSG_TEST_LOG, scene_adjust_msg_test_log).

-define(DICT_SCENE_WORKER_STATE, dict_scene_worker_state).
-define(DICT_SCENE_WORKER_PLAYER_ID_LIST, dict_scene_worker_player_id_list).
-define(DICT_SCENE_WORKER_POOL_VALUE, dict_scene_worker_pool_value).

%%-define(SCENE_WORKER_ADJUST_STATE_1, scene_worker_adjust_state_1).      %% 大赚
%%-define(SCENE_WORKER_ADJUST_STATE_2, scene_worker_adjust_state_2).      %% 小赚
%%-define(SCENE_WORKER_ADJUST_STATE_3, scene_worker_adjust_state_3).      %% 小亏
%%-define(SCENE_WORKER_ADJUST_STATE_4, scene_worker_adjust_state_4).      %% 大亏
%%-define(SCENE_WORKER_ADJUST_STATE_5, scene_worker_adjust_state_5).      %% 平
-define(SCENE_WORKER_ADJUST_STATE_1, 1).      %% 大赚
-define(SCENE_WORKER_ADJUST_STATE_2, 2).      %% 小赚
-define(SCENE_WORKER_ADJUST_STATE_3, 3).      %% 小亏
-define(SCENE_WORKER_ADJUST_STATE_4, 4).      %% 大亏
-define(SCENE_WORKER_ADJUST_STATE_5, 5).      %% 平