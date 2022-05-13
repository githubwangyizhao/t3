
%% @fun 跨服玩家数据必要数据
-record(ets_player_info, {
    player_id = 0,                  % 玩家id
    power = 0,                      % 战力
    nickname = "",                  % 玩家名字
    faction_name = ""               % 仙盟名字
}).

%% @fun 跨服玩家数据
-define(ETS_ZONE_PLAYER_RECODE, ets_zone_player_recode).
-record(ets_zone_player_recode, {
    player_id = 0,
    player_data,                    %% 玩家数据
    ets_player_info = #ets_player_info{},
    modelfigure,                    %% 玩家形象数据
    player_enter_scene_data,        %% 玩家进入场景
    change_time = 0                 %% 操作时间
}).

%% @fun 跨服位置数据
-define(ETS_ZONE_POS_DATA, ets_zone_pos_data).
-record(ets_zone_pos_data, {
    row_key = {},                       %% {类型, id}
    type,
    id,
    player_id = 0,                      %% 强占玩家
    nick_name = "",                      %% 强占玩家名字
    fight_time = 0                  %% 强占时间
}).


-define(GET_MY_INFO, get_my_info).                          % 获得玩家个人数据
-define(GET_GAME_PLAYER_LIST, get_game_player_list).    % 获得游戏服玩家数据
-define(GET_ZONE_TYPE_INFO, get_zone_type_info).        % 获得跨服房间信息
-define(FIGURE_DOWN, figure_down).                      % 玩家坐下
-define(GET_FIGURE_GIVE, get_figure_give).              % 领取奖励
-define(FIGURE_FIGHT, figure_fight).                    % 挑战位置
-define(FIGURE_FIGHT_RESULT, figure_fight_result).          % 战斗返回结果
-define(FIGURE_GM_SETTLE_AWARD, figure_gm_settle_award).    % gm结算

