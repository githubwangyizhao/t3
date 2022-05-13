%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         时时彩多人副本
%%% @end
%%% Created : 27. 十一月 2020 上午 10:58:11
%%%-------------------------------------------------------------------
-module(mod_mission_shi_shi_room).
-author("Administrator").

-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("scene.hrl").
-include("shi_shi_room.hrl").
-include("p_message.hrl").

%% API
-export([
    %% 多人boss进程调用
    create_mission/3,
    %% 场景进程调用
    handle_enter_mission/2,
    handle_init_mission/1,
    handle_leave_mission/1,
    handle_balance/1,
    handle_deal_cost/3,
    notice_shi_shi_room_cost_mana/0
]).

-define(SHI_SHI_ROOM_REFRESH_TIME_MS, 500).                                % 时时房间刷新时间 毫秒
-define(SHI_SHI_ROOM_COST_TOTAL_VALUE, shi_shi_room_cost_total_value).     % 时时房间消耗总值

%% @doc 处理消耗
handle_deal_cost(AttObjId, AttNickName, Cost) ->
    mod_log:add_mission_cost(AttObjId, Cost),
    mission_ranking:update_hurt(util:get_dict(room_id), AttObjId, AttNickName, Cost),
    OldTotalValue = util:get_dict(?SHI_SHI_ROOM_COST_TOTAL_VALUE, 0),
    NewTotalValue = OldTotalValue + trunc(Cost * ?SD_MANY_PEOPLE_SHISHI_RATE div ?PROP_NUM_10000),
    if
        NewTotalValue =/= OldTotalValue ->
            handle_deal_cost(NewTotalValue);
        true ->
            noop
    end.
handle_deal_cost(Cost) ->
    put(?SHI_SHI_ROOM_COST_TOTAL_VALUE, Cost),
    case is_need_refresh() of
        true ->
            noop;
        _ ->
            is_next_click_refresh(true),
            mod_mission:send_msg_delay(notice_shi_shi_room_cost, ?SHI_SHI_ROOM_REFRESH_TIME_MS)
    end.

%% ----------------------------------
%% @doc 	设置下一个心跳是否刷新排行榜
%% @throws 	none
%% @end
%% ----------------------------------
is_next_click_refresh(Bool) ->
    put(shi_shi_room_is_need_refresh, Bool).

is_need_refresh() ->
    get(shi_shi_room_is_need_refresh).

%% @doc 通知时时房间消耗灵力
notice_shi_shi_room_cost_mana() ->
    TotalValue = util:get_dict(?SHI_SHI_ROOM_COST_TOTAL_VALUE, 0),
    lists:foreach(
        fun(PlayerId) ->
            api_shi_shi_room:notice_shi_shi_value(PlayerId, TotalValue)
        end, mod_scene_player_manager:get_all_obj_scene_player_id()),
    is_next_click_refresh(false).

%% @doc 创建副本
create_mission(RoomId, MissionId, PlayerIdList) ->
    MissionType = ?MISSION_TYPE_MANY_PEOPLE_SHISHI,
    SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
    {ok, MissionSceneWorker} = scene_master:get_scene_worker(SceneId, [{mission_id, MissionId}, {room_id, RoomId}]),
    lists:foreach(
        fun(PlayerId) ->
            {X, Y} = mod_scene:get_scene_birth_pos(SceneId),
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, mod_shi_shi_room, player_enter_mission, [PlayerId, [MissionSceneWorker, SceneId, X, Y, [], null], MissionId], normal)
        end,
        PlayerIdList
    ),
    erlang:monitor(process, MissionSceneWorker),
    {ok, MissionSceneWorker}.

%% @doc 进入副本
handle_enter_mission(PlayerId, _SceneState) ->
    TotalValue = util:get_dict(?SHI_SHI_ROOM_COST_TOTAL_VALUE, 0),
    api_shi_shi_room:notice_shi_shi_value(PlayerId, TotalValue),
    mission_ranking:notice_ranking([PlayerId], ?MISSION_TYPE_MANY_PEOPLE_SHISHI, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)).

%% @doc 初始化副本
handle_init_mission(ExtraDataList) ->
    lists:foreach(
        fun({Type, Value}) ->
            put(Type, Value)
        end, ExtraDataList),
    mission_ranking:clean_ranking(?MISSION_TYPE_MANY_PEOPLE_SHISHI, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)),
    mission_ranking:init(?MISSION_TYPE_MANY_PEOPLE_SHISHI, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)).

%% @doc 玩家离开副本
handle_leave_mission(PlayerId) ->
    case mod_mission:is_balance() of
        false ->
            RoomId = get(room_id),
            case shi_shi_room_srv:call({?SHI_SHI_ROOM_MISSION_LEAVE, RoomId, PlayerId}) of
                true ->
                    ?DEBUG("玩家直接离开多人boss副本:~p", [{RoomId, PlayerId}]),
                    mission_ranking:remove_member_list(PlayerId, util:get_dict(room_id));
                false ->
                    ?DEBUG("玩家玩家离开多人副本，但可重连:~p~n", [{RoomId, PlayerId}]),
                    noop
            end;
        true ->
            noop
    end.

%% @doc 副本结算
handle_balance(_) ->
    RankList = mission_ranking:get_ranking_list(?MISSION_TYPE_MANY_PEOPLE_SHISHI, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)),
    RoomId = get(room_id),
    PlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
    TotalValue = util:get_dict(?SHI_SHI_ROOM_COST_TOTAL_VALUE, 0),

    case catch shi_shi_room_srv:call({?SHI_SHI_ROOM_MISSION_BALANCE, RoomId, PlayerIdList, RankList, TotalValue}) of
        {ok, WinPlayerId} ->
            mod_log:add_mission_award(WinPlayerId, TotalValue),
            ?INFO("结算时时房间副本:~p", [{RoomId, PlayerIdList, RankList}]),
            ok;
        Error ->
            ?ERROR("结算时时房间副本ERROR===:~p~n", [{{RoomId, PlayerIdList, RankList}, Error}]),
            noop
    end,
    ?TRY_CATCH(mod_log:balance_mission(?MISSION_TYPE_MANY_PEOPLE_SHISHI, get(mission_id), ?LOG_TYPE_MANY_PEOPLE_SHISHI)),

    mission_ranking:clean_ranking(?MISSION_TYPE_MANY_PEOPLE_SHISHI, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)),
    scene_worker:stop(self(), 10 * ?SECOND_MS).
