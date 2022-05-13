%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         匹配场房间
%%% @end
%%% Created : 11. 10月 2021 下午 02:20:14
%%%-------------------------------------------------------------------
-module(api_match_scene_room).
-author("Administrator").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").

%% API
-export([
    get_room_list/2,                    %% 获得房间列表
    exit_room_list/2,                   %% 退出房间列表
    create_room/2,                      %% 创建房间
    world_recruit/2,                    %% 世界招募
    recruit/2,                          %% 招募
    join_room/2,                        %% 加入房间
    leave_room/2,                       %% 离开房间

    pack_pb_match_scene_room_data/7     %% 结构化 卡牌图鉴
]).

-export([
    notice_leave_room/1,
    notice_unread_num/2,
%%    notice_add_room/1,
    notice_add_room/2,
    notice_delete_room/3,
%%    notice_delete_room/1,
%%    notice_delete_room/2,
    notice_room_people_num_change/3,
    notice_people_num_change/2
]).

%% @doc 获得房间列表
get_room_list(
    #m_match_scene_room_get_room_list_tos{},
    State = #conn{player_id = PlayerId}
) ->
    List =
        try
            mod_match_scene_room:get_player_room_list(PlayerId)
        catch
            _:Reason ->
                ?DEBUG("获取房间列表失败 : ~p", [{PlayerId, Reason, erlang:get_stacktrace()}]),
                []
        end,
    ?DEBUG("List Data : ~p", [List]),
    Out = proto:encode(#m_match_scene_room_get_room_list_toc{
        room_data_list = List
    }),
    mod_socket:send(Out),
    State.

%% @doc 退出房间列表
exit_room_list(
    #m_match_scene_room_exit_room_list_tos{},
    State = #conn{player_id = PlayerId}
) ->
    mod_match_scene_room:exit_room_list(PlayerId),
    State.

%% @doc 创建房间
create_room(
    #m_match_scene_room_create_room_tos{password = Password, cost_num = CostNum},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_match_scene_room:create_room(PlayerId, util:to_list(Password), CostNum)),
    Out = proto:encode(#m_match_scene_room_create_room_toc{
        result = Result
    }),
    mod_socket:send(Out),
    State.

%% @doc 世界招募
world_recruit(
    #m_match_scene_room_world_recruit_tos{},
    State = #conn{player_id = PlayerId}
) ->
    {Result, LimitTime} =
        case catch mod_match_scene_room:world_recruit(PlayerId) of
            {ok, LimitTime1} ->
                {?P_SUCCESS, LimitTime1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), 0}
        end,
    Out = proto:encode(#m_match_scene_room_world_recruit_toc{
        result = Result,
        limit_time = LimitTime
    }),
    mod_socket:send(Out),
    State.

%% @doc 指定招募
recruit(
    #m_match_scene_room_recruit_tos{player_name = PlayerName},
    State = #conn{player_id = PlayerId}
) ->
    {Result, LimitTime} =
        case catch mod_match_scene_room:recruit(PlayerId, util:to_list(PlayerName)) of
            {ok, LimitTime1} ->
                {?P_SUCCESS, LimitTime1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), 0}
        end,
    Out = proto:encode(#m_match_scene_room_recruit_toc{
        result = Result,
        limit_time = LimitTime
    }),
    mod_socket:send(Out),
    State.

%% @doc 加入房间
join_room(
    #m_match_scene_room_join_room_tos{room_id = RoomId, password = Password},
    State = #conn{player_id = PlayerId}
) ->
    {Result, PeopleNum} =
        case catch mod_match_scene_room:join_room(PlayerId, RoomId, util:to_list(Password)) of
            {ok, PeopleNum1} ->
                {?P_SUCCESS, PeopleNum1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), 0}
        end,
    Out = proto:encode(#m_match_scene_room_join_room_toc{
        result = Result,
        people_num = PeopleNum
    }),
    mod_socket:send(Out),
    State.

%% @doc 离开房间
leave_room(
    #m_match_scene_room_leave_room_tos{},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_match_scene_room:leave_room(PlayerId)),
    Out = proto:encode(#m_match_scene_room_leave_room_toc{
        result = Result
    }),
    mod_socket:send(Out),
    State.
notice_leave_room(PlayerId) ->
    Out = proto:encode(#m_match_scene_room_leave_room_toc{
        result = no_condition
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知未读数量
notice_unread_num(_PlayerId, Num) when Num < 0 ->
    noop;
notice_unread_num(PlayerId, Num) ->
    Out = proto:encode(#m_match_scene_room_notice_unread_num_toc{
        num = Num
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知 增加房间
%%notice_add_room(RoomData) ->
%%    notice_add_room(mod_online:get_all_online_player_id(), RoomData).
notice_add_room(PlayerId, RoomData) ->
    Out = proto:encode(#m_match_scene_room_add_room_toc{
        room_data = pack_pb_match_scene_room_data(RoomData)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知 删除房间
%%notice_delete_room(RoomId) ->
%%    notice_delete_room(mod_online:get_all_online_player_id(), RoomId, 0).
%%notice_delete_room(PlayerId, RoomId) ->
%%    notice_delete_room([PlayerId], RoomId, 1).
notice_delete_room(PlayerIdList, RoomId, Type) ->
    Out = proto:encode(#m_match_scene_room_delete_room_toc{
        type = Type,
        room_id = RoomId
    }),
    mod_socket:send(PlayerIdList, Out).

%% @doc 通知 房间外玩家 房间人数改变
notice_room_people_num_change(PlayerId, RoomId, PeopleNum) ->
    Out = proto:encode(#m_match_scene_room_notice_room_people_num_change_toc{
        room_id = RoomId,
        people_num = PeopleNum
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知 房间内玩家 房间人数改变
notice_people_num_change(PlayerId, PeopleNum) ->
    Out = proto:encode(#m_match_scene_room_notice_people_num_change_toc{
        people_num = PeopleNum
    }),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

%% @doc 结构化 匹配场房间数据
pack_pb_match_scene_room_data({Type, RoomId, ModelHeadFigure, Cost, IsLock, RecruitTime, PeopleNum}) ->
    pack_pb_match_scene_room_data(Type, RoomId, ModelHeadFigure, Cost, IsLock, RecruitTime, PeopleNum).
pack_pb_match_scene_room_data(Type, RoomId, ModelHeadFigure, Cost, IsLock, RecruitTime, PeopleNum) ->
    #matchsceneroomdata{
        type = Type,
        room_id = RoomId,
        model_head_figure = ModelHeadFigure,
        cost_num = Cost,
        is_lock = IsLock,
        recruit_time = RecruitTime,
        people_num = PeopleNum
    }.