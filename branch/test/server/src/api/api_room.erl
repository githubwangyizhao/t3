%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 11月 2021 17:19
%%%-------------------------------------------------------------------
-module(api_room).
-author("yizhao.wang").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").

%% API
-export([
    push_init_room_data/8,
    push_room_fight_data/2,
    push_frame_data/2,
    notice_room_list_change/4,
    notice_player_ready/2,
    notice_fight_result/2
]).

-export([
    get_room_list/2,
    leave_room_list/2,
    enter_room/2,
    leave_room/2,
    ready/2,
    add_frame_action/2,
    fight_result/2
]).

%% ----------------------------------
%% @doc 	获取房间列表
%% @throws 	none
%% @end
%% ----------------------------------
get_room_list(
    #m_room_get_room_list_tos{type = Type},
    State = #conn{player_id = PlayerId}
) ->
    Out =
    proto:encode(#m_room_get_room_list_toc{
        type = Type,
        my_score = 0,
        rank_list = [],
        room_list = [
            #roominfo{
                room_id = RoomId,
                player_list = PlayerBaseInfoList
            } || {RoomId, PlayerBaseInfoList} <- mod_room:get_room_list(PlayerId, Type)]
    }),
    mod_socket:send(PlayerId, Out),
    State.

%% ----------------------------------
%% @doc 	离开房间列表
%% @throws 	none
%% @end
%% ----------------------------------
leave_room_list(
    #m_room_leave_room_list_tos{},
    State = #conn{player_id = PlayerId}
) ->
    mod_room:leave_room_list(PlayerId),
    State.

%% ----------------------------------
%% @doc 	进入房间
%% @throws 	none
%% @end
%% ----------------------------------
enter_room(
    #m_room_enter_room_tos{type = Type, room_id = RoomId},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_room:enter_room(PlayerId, Type, RoomId)),
    Out = proto:encode(#m_room_enter_room_toc{result = Result}),
    mod_socket:send(PlayerId, Out),
    State.

%% ----------------------------------
%% @doc 	离开房间
%% @throws 	none
%% @end
%% ----------------------------------
leave_room(
    #m_room_leave_room_tos{},
    State = #conn{player_id = PlayerId}
) ->
    mod_room:leave_room(PlayerId),
    State.

%% ----------------------------------
%% @doc 	玩家准备
%% @throws 	none
%% @end
%% ----------------------------------
ready(
    #m_room_ready_tos{},
    State = #conn{player_id = PlayerId}
) ->
    mod_room:ready(PlayerId),
    State.

%% ----------------------------------
%% @doc 	客户端上报战斗操作
%% @throws 	none
%% @end
%% ----------------------------------
add_frame_action(
    #m_room_add_frame_action_tos{action = Action},
    State = #conn{player_id = PlayerId}
) ->
    mod_room:add_frame_action(PlayerId, Action),
    State.

%% ----------------------------------
%% @doc 	客户端上报战斗结果
%% @throws 	none
%% @end
%% ----------------------------------
fight_result(
    #m_room_fight_result_tos{winner = WinnerPlayerId},
    State = #conn{player_id = PlayerId}
) ->
    mod_room:fight_result(PlayerId, WinnerPlayerId),
    State.

%%%% ----------------------------------
%%%% @doc 	 房间列表变更通知
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
notice_room_list_change(PlayerId, Type, RoomId, PlayerBaseInfoList) ->
    Out =
        proto:encode(
            #m_room_notice_room_list_change_toc{
                type = Type,
                room_list = [
                    #roominfo{
                        room_id = RoomId,
                        player_list = PlayerBaseInfoList
                    }
                ]
            }
        ),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知玩家准备
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_ready(PlayerId, ReadyPlayerId) ->
    mod_socket:send(PlayerId, proto:encode(#m_room_notice_player_ready_toc{playerid = ReadyPlayerId})).

%% ----------------------------------
%% @doc 	通知最终战斗结果
%% @throws 	none
%% @end
%% ----------------------------------
notice_fight_result(PlayerId, WinnerPlayerId) ->
    mod_socket:send(PlayerId, proto:encode(#m_room_fight_result_toc{winner = WinnerPlayerId})).

%% ----------------------------------
%% @doc 	推送帧数据
%% @throws 	none
%% @end
%% ----------------------------------
push_frame_data(null, _) -> noop;
push_frame_data(SenderWorker, FrameDataList) ->
    OneFrameData =
        proto:encode(#m_room_push_frame_info_toc{
            frameDatas = pack_frame_data(FrameDataList)
        }),
    mod_socket:send(SenderWorker, OneFrameData).

%% ----------------------------------
%% @doc 	房间初始化数据推送
%% @throws 	none
%% @end
%% ----------------------------------
push_init_room_data(PlayerId, Type, RoomId, Seed, EndTime, PlayerBaseInfoList, ReadyPlayerIdList, Index) ->
    InitRoomData =
        proto:encode(#m_room_notice_room_start_toc{
            type = Type,
            roomid = RoomId,
            seed = Seed,
            player_list = PlayerBaseInfoList,
            ready_list = ReadyPlayerIdList,
            endTime = EndTime,
            index = Index
        }),
    mod_socket:send(PlayerId, InitRoomData).

%% ----------------------------------
%% @doc 	房间战斗开始通知
%% @throws 	none
%% @end
%% ----------------------------------
push_room_fight_data(PlayerId, EndTime) ->
    InitRoomData =
        proto:encode(#m_room_notice_fighting_toc{
            endTime = EndTime
        }),
    mod_socket:send(PlayerId, InitRoomData).

%% ----------------------------------
%% @doc 	打包帧数据
%% @throws 	none
%% @end
%% ----------------------------------
pack_frame_data(FrameDataList) ->
    [
        #'m_room_push_frame_info_toc.frameinfo'{
            frame = FrameSeq,
            actions = FrameActions
        } || {FrameSeq, FrameActions} <- FrameDataList
    ].