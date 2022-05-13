%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         多人boss
%%% @end
%%% Created : 25. 十一月 2020 下午 05:39:59
%%%-------------------------------------------------------------------
-module(mod_shi_shi_room).
-author("Administrator").

-include("gen/table_enum.hrl").
-include("shi_shi_room.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").
-include("error.hrl").

%% API
-export([
    get_room_list/2,
    join_room/4,
    create_room/4,
    start/1,
    kick_out_player/2,
    ready/2,
    leave_room/1,
    leave_room/2,

    mission_balance_give_award/7,
    player_enter_mission/3,
    player_enter_game/1,

    get_t_mission_many_people_boss/1
]).

%% @doc 获得房间列表
get_room_list(PlayerId, MissionId) ->
    case mod_function:is_open(PlayerId, ?FUNCTION_MISSION_SHISHI_MULTI_LIST) of
        true ->
            List = shi_shi_room_srv:rpc_call(get_room_list, [MissionId]),
            get_list(List);
        false ->
            []
    end.

get_list(List) ->
    get_list(List, [], 100).
get_list([], NewList, _Limit) ->
    NewList;
get_list(_List, NewList, 0) ->
    NewList;
get_list([EtsData | List], NewList, Limit) ->
    #ets_shi_shi_room_data{
        pos_data_list = PosDatalist
    } = EtsData,
    case length(PosDatalist) < shi_shi_room_srv_mod:get_pos_limit() of
        true ->
            get_list(List, [EtsData | NewList], Limit - 1);
        false ->
            get_list(List, NewList, Limit)
    end.

%% @doc 创建房间
create_room(PlayerId, MissionId, IsLock, Password) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_MISSION_SHISHI_MULTI_CREATE),
    #t_mission{
        enter_conditions_list = EnterConditionsList
    } = mod_mission:get_t_mission(?MISSION_TYPE_MANY_PEOPLE_SHISHI, MissionId),
    ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, EnterConditionsList), ?ERROR_NO_CONDITION),
    ?IF(IsLock, ?ASSERT(length(Password) =< 20, ?ERROR_FAIL), noop),
    shi_shi_room_srv:call({?SHI_SHI_ROOM_CREATE_ROOM, PlayerId, MissionId, IsLock, Password, get_player_data(PlayerId)}).

%% @doc 加入房间
join_room(PlayerId, RoomId, Password, InvitationCode) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_MISSION_SHISHI_MULTI_CREATE),
    MissionId = shi_shi_room_srv:call({?SHI_SHI_ROOM_GET_MISSION_ID, RoomId, InvitationCode}),
    ?ASSERT(MissionId > 0, ?ERROR_NONE),
    ?DEBUG("副本id ~p", [MissionId]),
    #t_mission{
        enter_conditions_list = EnterConditionsList
    } = mod_mission:get_t_mission(?MISSION_TYPE_MANY_PEOPLE_SHISHI, MissionId),
    ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, EnterConditionsList), ?ERROR_NO_CONDITION),
    shi_shi_room_srv:call({?SHI_SHI_ROOM_JOIN_ROOM, PlayerId, RoomId, Password, InvitationCode, get_player_data(PlayerId)}).

%% @doc 开始游戏
start(PlayerId) ->
    shi_shi_room_srv:call({?SHI_SHI_ROOM_START, PlayerId}).

%% @doc 踢出玩家
kick_out_player(PlayerId, PosId) ->
    shi_shi_room_srv:cast({?SHI_SHI_ROOM_KICK_OUT_PLAYER, PlayerId, PosId}).

%% @doc 准备
ready(PlayerId, IsReady) ->
    shi_shi_room_srv:call({?SHI_SHI_ROOM_READY, PlayerId, IsReady}),
    ok.

%% @doc 离开房间
leave_room(PlayerId) ->
    leave_room(PlayerId, false).
leave_room(PlayerId, IsLeaveGame) ->
    shi_shi_room_srv:cast({?SHI_SHI_ROOM_LEAVE_ROOM, PlayerId, IsLeaveGame}).

%% @doc 副本结算给奖励
mission_balance_give_award(PlayerId, AwardList, IsInRoom, NewEtsRoomData, WinPlayerNameStr, TotalCostValue, WinPlayerId) ->
    if
        IsInRoom ->
            if
                AwardList =/= [] ->
                    Tran =
                        fun() ->
                            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_MANY_PEOPLE_SHISHI)
                        end,
                    db:do(Tran);
                true ->
                    noop
            end,
            api_shi_shi_room:notice_player_fight_result(PlayerId, AwardList, NewEtsRoomData, WinPlayerNameStr, TotalCostValue, WinPlayerId);
        true ->
            if
                AwardList =/= [] ->
                    mod_mail:add_mail_item_list(PlayerId, ?MAIL_MANY_PEOPLE_SHISHI_MISSION_MAIL, AwardList, ?LOG_TYPE_MANY_PEOPLE_SHISHI);
                true ->
                    noop
            end
    end.

%% @doc 玩家进入副本
player_enter_mission(PlayerId, [MissionSceneWorker, SceneId, X, Y, [], null], MissionId) ->
    ?DEBUG("玩家(~p)准备进入场景:~p~n", [PlayerId, {MissionSceneWorker, SceneId, X, Y, [], null}]),
    mod_scene:player_prepare_enter_scene(PlayerId, MissionSceneWorker, SceneId, X, Y, [], null),
    api_mission:notice_challenge_mission(PlayerId, ?MISSION_TYPE_MANY_PEOPLE_SHISHI, MissionId).

%% @doc 玩家进入游戏
player_enter_game(PlayerId) ->
    shi_shi_room_srv:player_enter_game(PlayerId).

get_player_data(PlayerId) ->
    ServerId = mod_player:get_player_server_id(PlayerId),
    PlatformId = mod_server_config:get_platform_id(),
    ModelHeadFigure = api_player:pack_model_head_figure(PlayerId),
    {PlatformId, ServerId, ModelHeadFigure}.

%%put_player_many_data(Result) ->
%%    case Result of
%%        {ok, EtsRoomData} ->
%%            #ets_many_people_boss_room_data{
%%                room_id = RoomId,
%%                boss_id = BossId
%%            } = EtsRoomData,
%%            put(many_player_data, {RoomId, BossId});
%%        _ ->
%%            noop
%%    end.
%%
%%get_player_many_data() ->
%%    get(many_player_data).
%%
%%delete_player_many_data() ->
%%    erase(many_player_data).

%%%% ================================================ 模板操作 ================================================

get_t_mission_many_people_boss(BossId) ->
    t_mission_many_people_boss:assert_get({BossId}).
