%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 11月 2021 下午 04:36:12
%%%-------------------------------------------------------------------
-module(api_one_vs_one).
-author("Administrator").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").

%% API
-export([
    get_room_list/2,                    %% 获得房间列表
    exit_room_list/2,                   %% 退出房间列表
    join_room/2,                        %% 加入房间

    notice_update_room_list/3,
    notice_scene_skill_limit/2,

    pack_pb_one_vs_one_room_data/2
]).

%% @doc 获得房间列表
get_room_list(
    #m_one_vs_one_get_room_list_tos{type = Type},
    State = #conn{player_id = PlayerId}
) ->
    {RoomList, RankList, MyWinValue} =
        try
            mod_one_vs_one:get_room_list(PlayerId, Type)
        catch
            _:Reason ->
                ?DEBUG("获取房间列表失败 : ~p", [{PlayerId, Reason, erlang:get_stacktrace()}]),
                {[], [], 0}
        end,
    Out = proto:encode(#m_one_vs_one_get_room_list_toc{
        type = Type,
        room_list = pack_pb_one_vs_one_room_data_list(RoomList),
        rank_list = pack_pb_one_vs_one_rank_data_list(RankList),
        my_win_value = MyWinValue
    }),
    mod_socket:send(Out),
    State.

%% @doc 退出房间列表
exit_room_list(
    #m_one_vs_one_exit_room_list_tos{},
    State = #conn{player_id = PlayerId}
) ->
    catch mod_one_vs_one:exit_room_list(PlayerId),
    State.

%% @doc 加入房间
join_room(
    #m_one_vs_one_join_room_tos{type = Type, room_id = RoomId},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_one_vs_one:join_room(PlayerId, Type, RoomId)),
    Out = proto:encode(#m_one_vs_one_join_room_toc{
        result = Result
    }),
    mod_socket:send(Out),
    State.

notice_update_room_list(PlayerIdList, Type, UpdateRoomDataList) ->
    Out = proto:encode(#m_one_vs_one_notice_update_room_data_toc{
        type = Type,
        room_list = UpdateRoomDataList
    }),
    mod_socket:send_to_player_list(PlayerIdList, Out).

notice_scene_skill_limit(PlayerId, List) ->
    Out = proto:encode(#m_one_vs_one_notice_scene_skill_limit_toc{
        skill_limit_list = [
            #'m_one_vs_one_notice_scene_skill_limit_toc.skill_limit'{
                skill_id = SkillId,
                times_limit = Num
            } || [SkillId, Num] <- List
        ]
    }),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

pack_pb_one_vs_one_room_data_list(List) ->
    [pack_pb_one_vs_one_room_data(RoomId, ModelHeadFigureList) || {RoomId, ModelHeadFigureList} <- List].
pack_pb_one_vs_one_room_data(RoomId, ModelHeadFigureList) ->
    #onevsoneroomdata{
        room_id = RoomId,
        model_head_figure_list = ModelHeadFigureList
    }.

pack_pb_one_vs_one_rank_data_list(List) ->
    [pack_pb_one_vs_one_rank_data(Rank, ModelHeadFigure, Score) || {Rank, _PlayerId,ModelHeadFigure, Score} <- List].
pack_pb_one_vs_one_rank_data(Rank, ModelHeadFigure, Score) ->
    #onevsonerankdata{
        rank = Rank,
        model_head_figure = ModelHeadFigure,
        value = Score
    }.