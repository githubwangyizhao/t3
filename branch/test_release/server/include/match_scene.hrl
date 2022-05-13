%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 9月 2021 下午 05:01:34
%%%-------------------------------------------------------------------
-author("Administrator").

-define(MSG_MATCH_SCENE_BALANCE, msg_match_scene_balance).               %% 匹配场 结算
-define(MSG_MATCH_SCENE_RANK, msg_match_scene_rank).                     %% 匹配场 排行榜

-define(DICT_MATCH_SCENE_PLAYER_LIST, dict_match_scene_player_list).     %% 玩家列表
-define(DICT_MATCH_SCENE_TIME_CONFIG, dict_match_scene_time_config).     %% 时间配置{开始时间戳，结算时间戳}
-define(DICT_MATCH_SCENE_SCORE_RANK, dict_match_scene_score_rank).       %% 积分排行榜

%% 房间数据
-define(ETS_ROOM_DATA, ets_room_data).
-record(ets_room_data, {
    room_id,                                                            %% 房间id
    password,
    owner_player_id,
    model_head_figure,
    world_recruit_time_limit = 0,
    player_recruit_time_limit = 0,
    cost_num,
    player_list = [],                                                   %% 除了房主外的玩家id列表
    recruit_player_list = [],                                           %% 指定招募玩家列表
    world_observer_id_list = [],                                        %% 世界招募查看过的玩家id列表
    player_observer_id_list = []
}).
%%-define(DICT_RECRUIT_MAP, dict_recruit_map).
-define(DICT_WORLD_RECRUIT_LIST, dict_world_recruit_list).              %% 世界招募列表
-define(DICT_PLAYER_RECRUIT, dict_player_recruit).                      %% 指定招募
-define(DICT_PLAYER_ROOM, dict_player_room).                            %% 玩家房间
-define(DICT_ROOM_ID, dict_room_id).                                    %% 当前房间id
-define(DICT_OBSERVER_LIST, dict_observer_list).                        %% 观察者列表