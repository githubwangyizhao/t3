%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 三月 2021 下午 02:39:50
%%%-------------------------------------------------------------------
-module(api_shi_shi_room).
-author("Administrator").

-include("gen/db.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").
-include("shi_shi_room.hrl").
-include("error.hrl").

%% API
-export([
    %% function
    get_room_list/2,                    %% 获得房间列表
    create_room/2,                      %% 创建房间
    join_room/2,                        %% 加入房间
    start/2,                            %% 开始战斗
    kick_out_player/2,                  %% 踢出玩家
    ready/2,                            %% 准备
    leave_room/2,                       %% 离开房间

    %% notice
    notice_leave_room/2,                %% 通知玩家自己离开房间
    notice_player_join/2,               %% 通知玩家加入
    notice_player_leave/2,              %% 通知玩家离开
    notice_player_ready/3,              %% 通知玩家准备
    notice_player_fight_start/1,        %% 通知玩家战斗开始
    notice_player_fight_result/6,       %% 通知玩家战斗结果
    notice_room_owner_change/2,         %% 通知玩家房主改变
    notice_shi_shi_value/2              %% 通知时时房间消耗值
]).

%% @doc 获得房间列表
get_room_list(
    #m_shi_shi_room_get_room_list_tos{mission_id = MissionId},
    State = #conn{player_id = PlayerId}
) ->
    case mod_interface_cd:check(shi_shi_room_get_room_list, 300) of
        true ->
            EtsRoomDataList = mod_shi_shi_room:get_room_list(PlayerId, MissionId),
            RoomDataList = pack_room_data_list(EtsRoomDataList),
            Out = proto:encode(#m_shi_shi_room_get_room_list_toc{mission_id = MissionId, room_data_list = RoomDataList}),
            mod_socket:send(Out);
        false ->
            noop
    end,
    State.

%% @doc 创建房间
create_room(
    #m_shi_shi_room_create_room_tos{mission_id = MissionId, is_lock = IsLock, password = Password},
    State = #conn{player_id = PlayerId}
) ->
    {Result, RoomDetailsData} =
        case catch mod_shi_shi_room:create_room(PlayerId, MissionId, ?TRAN_INT_2_BOOL(IsLock), util:to_list(Password)) of
            {ok, RoomDetailsData1} ->
                {?P_SUCCESS, pack_room_details_data(PlayerId, RoomDetailsData1)};
            {'EXIT', ERROR} ->
                Result1 = api_common:api_error_to_enum(ERROR),
                {Result1, ?UNDEFINED};
            R ->
                ?WARNING("未知错误:~p~n", [R]),
                {?P_FAIL, ?UNDEFINED}
        end,
    Out = proto:encode(#m_shi_shi_room_create_room_toc{result = Result, room_details_data = RoomDetailsData}),
    mod_socket:send(Out),
    State.

%% @doc 加入房间
join_room(
    #m_shi_shi_room_join_room_tos{room_id = RoomId, password = Password, invitation_code = InvitationCode},
    State = #conn{player_id = PlayerId}
) ->
    {Result, RoomDetailsData} =
        case catch mod_shi_shi_room:join_room(PlayerId, RoomId, util:to_list(Password), util:to_list(InvitationCode)) of
            {ok, RoomDetailsData1} ->
                {?P_SUCCESS, pack_room_details_data(PlayerId, RoomDetailsData1)};
            {'EXIT', ERROR} ->
                Result1 = api_common:api_error_to_enum(ERROR),
                {Result1, ?UNDEFINED};
            R ->
                ?WARNING("未知错误:~p~n", [R]),
                {?P_FAIL, ?UNDEFINED}
        end,
    Out = proto:encode(#m_shi_shi_room_join_room_toc{result = Result, room_details_data = RoomDetailsData}),
    mod_socket:send(Out),
    State.

%% @doc 开始游戏
start(
    #m_shi_shi_room_start_tos{},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_shi_shi_room:start(PlayerId)),
    Out = proto:encode(#m_shi_shi_room_start_toc{result = Result}),
    mod_socket:send(Out),
    State.

%% @doc 踢出玩家
kick_out_player(
    #m_shi_shi_room_kick_out_player_tos{pos_id = PosId},
    State = #conn{player_id = PlayerId}
) ->
    mod_shi_shi_room:kick_out_player(PlayerId, PosId),
    State.

%% @doc 准备
ready(
    #m_shi_shi_room_ready_tos{is_ready = IsReady},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_shi_shi_room:ready(PlayerId, ?TRAN_INT_2_BOOL(IsReady))),
    Out = proto:encode(#m_shi_shi_room_ready_toc{result = Result, is_ready = IsReady}),
    mod_socket:send(Out),
    State.

%% @doc 离开房间
leave_room(
    #m_shi_shi_room_leave_room_tos{},
    State = #conn{player_id = PlayerId}
) ->
    mod_shi_shi_room:leave_room(PlayerId),
    State.

%% @doc 通知玩家自己离开房间
notice_leave_room(PlayerId, Type) ->
    Out = proto:encode(#m_shi_shi_room_notice_leave_room_toc{
        type = Type
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家加入房间
notice_player_join(PlayerId, PosData) ->
    Out = proto:encode(#m_shi_shi_room_notice_player_join_toc{
        room_player_data = pack_room_player_data(PosData)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家离开房间
notice_player_leave(PlayerId, PosId) ->
    Out = proto:encode(#m_shi_shi_room_notice_player_leave_toc{
        pos_id = PosId
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家准备
notice_player_ready(PlayerId, PosId, IsReady) ->
    Out = proto:encode(#m_shi_shi_room_notice_player_ready_toc{
        pos_id = PosId,
        is_ready = ?TRAN_BOOL_2_INT(IsReady)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家战斗开始
notice_player_fight_start(PlayerId) ->
    Out = proto:encode(#m_shi_shi_room_notice_player_fight_start_toc{
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家战斗结果
notice_player_fight_result(PlayerId, PropList, EtsRoomData, PlayerNameStr, TotalCostValue, WinPlayerId) ->
    Out = proto:encode(#m_shi_shi_room_notice_player_fight_result_toc{
        prop_list = api_prop:pack_prop_list(PropList),
        room_details_data = pack_room_details_data(PlayerId, EtsRoomData),
        win_name = ?IF(PlayerNameStr =:= ?UNDEFINED, ?UNDEFINED, util:to_binary(PlayerNameStr)),
        total_cost_value = TotalCostValue,
        win_player_id = WinPlayerId
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家房主改变
notice_room_owner_change(PlayerId, PosId) ->
    Out = proto:encode(#m_shi_shi_room_notice_room_owner_change_toc{
        pos_id = PosId
    }),
    mod_socket:send(PlayerId, Out).


%% @doc 通知消耗值
notice_shi_shi_value(PlayerId, Value) ->
    Out = proto:encode(#m_shi_shi_room_notice_shi_shi_value_toc{
        value = Value
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 打包房间数据
pack_room_data(EtsRoomData) ->
    #ets_shi_shi_room_data{
        room_id = RoomId,
        mission_id = MissionId,
        pos_data_list = PosDataList,
        is_lock = IsLock
    } = EtsRoomData,
    pack_room_data(RoomId, MissionId, PosDataList, IsLock).
pack_room_data(RoomId, MissionId, PosDataList, IsLock) ->
    #shishiroomdata{
        room_id = RoomId,
        mission_id = MissionId,
        people_count = length(PosDataList),
        is_lock = ?TRAN_BOOL_2_INT(IsLock)
    }.
pack_room_data_list(EtsRoomDataList) ->
    [pack_room_data(EtsRoomData) || EtsRoomData <- EtsRoomDataList].


%% @doc 打包房间详细数据
pack_room_details_data(_PlayerId, ?UNDEFINED) ->
    ?UNDEFINED;
pack_room_details_data(PlayerId, EtsRoomData) ->
    #ets_shi_shi_room_data{
        room_id = RoomId,
        mission_id = MissionId,
        invitation_code = InvitationCode,
        pos_data_list = PosDataList,
        owner_player_id = OwnerPlayerId,
        is_lock = IsLock
    } = EtsRoomData,
    RoomPlayerDataList = pack_room_player_data_list(PosDataList),
    {OwnerNickName, OwnerLevel} =
        case lists:keyfind(OwnerPlayerId, #shi_shi_pos_data.player_id, PosDataList) of
            false ->
                ?ERROR("数据错误"),
                {"", 1};
            PosData ->
                #shi_shi_pos_data{
                    model_head_figure = ModelHeadFigure
                } = PosData,
                #modelheadfigure{
                    nickname = NickName,
                    level = Level
                } = ModelHeadFigure,
                {NickName, Level}
        end,
    #shishiroomdetailsdata{
        room_data = pack_room_data(RoomId, MissionId, PosDataList, IsLock),
        invitation_code = InvitationCode,
        room_player_data_list = RoomPlayerDataList,
        is_room_owner = ?TRAN_BOOL_2_INT(OwnerPlayerId =:= PlayerId),
        owner_name = util:to_binary(OwnerNickName),
        owner_level = OwnerLevel
    }.

%% @doc 打包房间玩家数据
pack_room_player_data(PosData) ->
    #shi_shi_pos_data{
        pos_id = PosId,
        model_head_figure = ModelHeadFigure,
        is_ready = IsReady,
        is_owner = IsOwner
    } = PosData,
    #shishiroomplayerdata{
        pos_id = PosId,
        model_head_figure = ModelHeadFigure,
        is_ready = ?TRAN_BOOL_2_INT(IsReady),
        is_room_owner = ?TRAN_BOOL_2_INT(IsOwner)
    }.
pack_room_player_data_list(PosDataList) ->
    [pack_room_player_data(PosData) || PosData <- PosDataList].
