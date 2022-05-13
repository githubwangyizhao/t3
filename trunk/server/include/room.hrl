%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 11月 2021 9:47
%%%-------------------------------------------------------------------
-author("yizhao.wang").

-define(MSG_ROOM_PLAYER_REBIND_ROOM, msg_room_rebind_room).						%% 玩家重新绑定房间
-define(MSG_ROOM_PLAYER_ADD_FRAME_ACTION, msg_room_add_frame_action).			%% 更新客户端操作
-define(MSG_ROOM_PLAYER_READY, msg_room_ready).									%% 玩家准备
-define(MSG_ROOM_FIGHT_RESULT, msg_room_fight_result).							%% 客户端上报战斗结果

-define(ROOM_MAX_PLAYER, 2).

%% 房间信息
-define(ETS_ROOM_INFO, ets_room_info).
-record(ets_room_info, {
	playerid,
	room_worker = null
}).

%% 订阅房间
-define(ETS_ROOM_SUBSCRIBE, ets_room_subscribe).
-record(ets_room_subscribe, {
	playerid,
	roomtype
}).