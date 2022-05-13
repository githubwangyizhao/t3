%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 十一月 2020 下午 04:56:50
%%%-------------------------------------------------------------------
-module(api_many_people_boss).
-author("Administrator").

-include("gen/db.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").
-include("many_people_boss.hrl").
-include("error.hrl").

%% API
-export([
    %% function
    get_room_list/2,                    %% 获得房间列表
    join_room/2,                        %% 加入房间
    create_room/2,                      %% 创建房间
    start/2,                            %% 开始战斗
    participate_in/2,                   %% 房主参与战斗
    kick_out_player/2,                  %% 踢出玩家
    set_is_all_ready_start/2,           %% 设置是否全部准备自动开始
    ready/2,                            %% 准备
    leave_room/2,                       %% 离开房间

    %% notice
    notice_leave_room/2,                %% 通知玩家自己离开房间
    notice_player_join/2,               %% 通知玩家加入
    notice_player_leave/2,              %% 通知玩家离开
    notice_player_ready/3,              %% 通知玩家准备
    notice_set_is_all_ready_start/2,    %% 通知设置是否全部准备自动开始
    notice_player_fight_start/2,        %% 通知玩家战斗开始
    notice_player_fight_result/7,       %% 通知玩家战斗结果
    notice_owner_fight_result/3         %% 通知玩家战斗结算
]).

%% @doc 获得房间列表
get_room_list(
    #m_many_people_boss_get_room_list_tos{boss_id = BossId},
    State = #conn{player_id = PlayerId}
) ->
    case mod_interface_cd:check(many_people_boss_get_room_list, 500) of
        true ->
            EtsRoomDataList = mod_many_people_boss:get_room_list(PlayerId, BossId),
            RoomDataList = pack_room_data_list(EtsRoomDataList),
            Out = proto:encode(#m_many_people_boss_get_room_list_toc{boss_id = BossId, room_data_list = RoomDataList}),
            mod_socket:send(Out);
        false ->
            noop
    end,
    State.

%% @doc 加入房间
join_room(
    #m_many_people_boss_join_room_tos{room_id = RoomId, password = Password, invitation_code = InvitationCode},
    State = #conn{player_id = PlayerId}
) ->
    {Result, RoomDetailsData} =
        case catch mod_many_people_boss:join_room(PlayerId, RoomId, Password, InvitationCode) of
            {ok, RoomDetailsData1} ->
                {?P_SUCCESS, pack_room_details_data(PlayerId, RoomDetailsData1)};
            {'EXIT', ERROR} ->
                Result1 = api_common:api_error_to_enum(ERROR),
                {Result1, ?UNDEFINED};
            R ->
                ?WARNING("未知错误:~p~n", [R]),
                {?P_FAIL, ?UNDEFINED}
        end,
    Out = proto:encode(#m_many_people_boss_join_room_toc{result = Result, room_details_data = RoomDetailsData}),
    mod_socket:send(Out),
    State.

%% @doc 创建房间
create_room(
    #m_many_people_boss_create_room_tos{boss_id = BossId, is_lock = IsLock, password = Password},
    State = #conn{player_id = PlayerId}
) ->
    {Result, RoomDetailsData} =
        case catch mod_many_people_boss:create_room(PlayerId, BossId, IsLock, util:to_list(Password)) of
            {ok, RoomDetailsData1} ->
                {?P_SUCCESS, pack_room_details_data(PlayerId, RoomDetailsData1)};
            {'EXIT', ERROR} ->
                Result1 = api_common:api_error_to_enum(ERROR),
                {Result1, ?UNDEFINED};
            R ->
                ?WARNING("未知错误:~p~n", [R]),
                {?P_FAIL, ?UNDEFINED}
        end,
    Out = proto:encode(#m_many_people_boss_create_room_toc{result = Result, room_details_data = RoomDetailsData}),
    mod_socket:send(Out),
    State.

%% @doc 房主参与游戏
start(
    #m_many_people_boss_start_tos{},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_many_people_boss:start(PlayerId)),
    Out = proto:encode(#m_many_people_boss_start_toc{result = Result}),
    mod_socket:send(Out),
    State.

%% @doc 房主参与游戏
participate_in(
    #m_many_people_boss_participate_in_tos{is_participate_in = IsParticipateIn},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_many_people_boss:participate_in(PlayerId, IsParticipateIn)),
    Out = proto:encode(#m_many_people_boss_participate_in_toc{result = Result, is_participate_in = IsParticipateIn}),
    mod_socket:send(Out),
    State.

%% @doc 踢出玩家
kick_out_player(
    #m_many_people_boss_kick_out_player_tos{pos_id = PosId},
    State = #conn{player_id = PlayerId}
) ->
    mod_many_people_boss:kick_out_player(PlayerId, PosId),
    State.

%% @doc 设置是否自动准备全部开始
set_is_all_ready_start(
    #m_many_people_boss_set_is_all_ready_start_tos{is_all_ready_start = IsAllReadyStart},
    State = #conn{player_id = PlayerId}
) ->
    mod_many_people_boss:set_is_all_ready_start_tos(PlayerId, IsAllReadyStart),
    State.

%% @doc 通知设置是否自动准备全部开始
notice_set_is_all_ready_start(PlayerId, IsAllReadyStart) ->
    Out = proto:encode(#m_many_people_boss_set_is_all_ready_start_toc{is_all_ready_start = IsAllReadyStart}),
    mod_socket:send(PlayerId, Out).

%% @doc 准备
ready(
    #m_many_people_boss_ready_tos{is_ready = IsReady},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_many_people_boss:ready(PlayerId, IsReady)),
    Out = proto:encode(#m_many_people_boss_ready_toc{result = Result, is_ready = IsReady}),
    mod_socket:send(Out),
    State.

%% @doc 离开房间
leave_room(
    #m_many_people_boss_leave_room_tos{},
    State = #conn{player_id = PlayerId}
) ->
    mod_many_people_boss:leave_room(PlayerId),
    State.

%% @doc 通知玩家自己离开房间
notice_leave_room(PlayerId, Type) ->
    Out = proto:encode(#m_many_people_boss_notice_leave_room_toc{
        type = Type
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家加入房间
notice_player_join(PlayerId, PosData) ->
    Out = proto:encode(#m_many_people_boss_notice_player_join_toc{
        room_player_data = pack_room_player_data(PosData)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家离开房间
notice_player_leave(PlayerId, PosId) ->
    Out = proto:encode(#m_many_people_boss_notice_player_leave_toc{
        pos_id = PosId
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家准备
notice_player_ready(PlayerId, PosId, IsReady) ->
    Out = proto:encode(#m_many_people_boss_notice_player_ready_toc{
        pos_id = PosId,
        is_ready = IsReady
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家战斗开始
notice_player_fight_start(PlayerId, MissionTime) ->
    Out = proto:encode(#m_many_people_boss_notice_player_fight_start_toc{
        mission_time = MissionTime
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知玩家战斗结果
notice_player_fight_result(PlayerId, IsFirstPrize, PropList, EtsRoomData, Rank, Result, PlayerNameStr) ->
    Out = proto:encode(#m_many_people_boss_notice_player_fight_result_toc{
        is_first_prize = ?TRAN_BOOL_2_INT(IsFirstPrize),
        prop_list = api_prop:pack_prop_list(PropList),
        room_details_data = pack_room_details_data(PlayerId, EtsRoomData),
        rank = Rank,
        result = ?TRAN_BOOL_2_INT(Result),
        win_name = util:to_binary(PlayerNameStr)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知房主战斗结算
notice_owner_fight_result(PlayerId, Mana, EtsRoomData) ->
    Out = proto:encode(#m_many_people_boss_notice_owner_fight_result_toc{
        mana = Mana,
        room_details_data = pack_room_details_data(PlayerId, EtsRoomData)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 打包房间数据
pack_room_data(EtsRoomData) ->
    #ets_many_people_boss_room_data{
        room_id = RoomId,
        boss_id = BossId,
        pos_data_list = PosDataList,
        is_lock = IsLock
    } = EtsRoomData,
    pack_room_data(RoomId, BossId, PosDataList, IsLock).
pack_room_data(RoomId, BossId, PosDataList, IsLock) ->
    #roomdata{
        room_id = RoomId,
        boss_id = BossId,
        people_count = length(PosDataList),
        is_lock = IsLock
    }.
pack_room_data_list(EtsRoomDataList) ->
    [pack_room_data(EtsRoomData) || EtsRoomData <- EtsRoomDataList].


%% @doc 打包房间详细数据
pack_room_details_data(_PlayerId, ?UNDEFINED) ->
    ?UNDEFINED;
pack_room_details_data(PlayerId, EtsRoomData) ->
    #ets_many_people_boss_room_data{
        room_id = RoomId,
        boss_id = BossId,
        invitation_code = InvitationCode,
        pos_data_list = PosDataList,
        owner_pos_data = OwnerPosData,
        is_all_ready_auto_start = IsAllReadAutoStart,
        is_lock = IsLock
    } = EtsRoomData,
    RoomPlayerDataList = pack_room_player_data_list(PosDataList),
    #roomdetailsdata{
        room_data = pack_room_data(RoomId, BossId, PosDataList, IsLock),
        invitation_code = InvitationCode,
        room_player_data_list = RoomPlayerDataList,
        is_room_owner = ?TRAN_BOOL_2_INT(OwnerPosData#many_people_boss_room_pos_data.player_id =:= PlayerId),
        is_all_ready_auto_start = IsAllReadAutoStart,
        owner_name = OwnerPosData#many_people_boss_room_pos_data.model_head_figure#modelheadfigure.nickname,
        owner_level = OwnerPosData#many_people_boss_room_pos_data.model_head_figure#modelheadfigure.level
    }.

%% @doc 打包房间玩家数据
pack_room_player_data(PosData) ->
    #many_people_boss_room_pos_data{
        pos_id = PosId,
        model_head_figure = ModelHeadFigure,
        is_ready = IsReady,
        is_owner = IsOwner
    } = PosData,
    #roomplayerdata{
        pos_id = PosId,
        model_head_figure = ModelHeadFigure,
        is_ready = IsReady,
        is_room_owner = IsOwner
    }.
pack_room_player_data_list(PosDataList) ->
    [pack_room_player_data(PosData) || PosData <- PosDataList].
