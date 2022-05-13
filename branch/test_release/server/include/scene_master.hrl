%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             场景管理
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-define(MSG_GET_SCENE_WORKER, msg_get_scene_worker).                    %% 获取场景进程
-define(MSG_CREATE_SCENE_WORKER, msg_create_scene_worker).              %% 创建场景进程
-define(MSG_DESTROY_SCENE_WORKER, msg_destroy_scene_worker).            %% 销毁场景进程
%%-define(MSG_RELEASE_SCENE_WORKER, msg_release_scene_worker).            %% 释放场景进程
-define(MSG_LOCK_SCENE_WORKER, msg_lock_scene_worker).                  %% 锁定场景进程
-define(MSG_CREATE_ALL_WORLD_SCENE, msg_create_all_world_scene).        %% 创建所有世界场景
-define(MSG_UPDATE_SCENE_PLAYER_COUNT, msg_update_scene_player_count).  %% 更新场景玩家数量    %% 移除

%%-define(MSG_ADD_ENERGY, msg_add_energy).                                %% 增加能量值
