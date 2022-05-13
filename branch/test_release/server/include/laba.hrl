%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 11月 2021 10:58
%%%-------------------------------------------------------------------
-author("yizhao.wang").

%% 玩家拉霸记录
-define(ETS_LABA_PLAYER_DATA, ets_laba_player_data).
-record(ets_laba_player_data, {
	player_id,
	client_worker,
	monitor_ref,
	laba_id = 0,			%% 最后一次参与拉霸机id
	cost_rate = 0,			%% 消耗倍率
	time = 0
}).

%% 拉霸机数据
-define(ETS_LABA_DATA, ets_laba_data).
-record(ets_laba_data, {
	key, 							%% key {拉霸机id, 消耗倍率}
	player_count          			%% 当前参与人数
}).

-define(FREE_GAME_KIND, 99).		%% FreeGame图示
-define(UNIVERSAL_KIND, 100).		%% 万能图示

% 输赢结果控制
-define(LABA_RESULT_CTRL_1, 1).     %% 玩家必赚
-define(LABA_RESULT_CTRL_2, 2).     %% 纯随机
-define(LABA_RESULT_CTRL_3, 3).     %% 玩家必不赚
-define(LABA_RESULT_CTRL_4, 4).     %% 玩家少赚（保底方案）
-define(LABA_RESULT_CTRL_5, 5).     %% 预埋线路

% 拉霸机玩法类型
-define(TYPE_COMBO_LABA, 1).            %% 组合玩法
-define(TYPE_LINE_LABA, 2).             %% 连线玩法

% 初始换拉霸机行和列
-define(INIT_GRID_ROW(Value), put(labagridrow, Value)).
-define(INIT_GRID_COL(Value), put(labagridcol, Value)).
-define(GET_GRID_ROW, get(labagridrow)).
-define(GET_GRID_COL, get(labagridcol)).