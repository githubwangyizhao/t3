%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         多人BOSS副本
%%% @end
%%% Created : 27. 十一月 2020 上午 10:58:11
%%%-------------------------------------------------------------------
-module(mod_mission_many_people_boss).
-author("Administrator").

-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("scene.hrl").
-include("many_people_boss.hrl").
-include("p_message.hrl").

%% API
-export([
    %% 多人boss进程调用
    create_mission/6,
    %% 场景进程调用
    handle_enter_mission/2,
    handle_init_mission/1,
    handle_leave_mission/1,
    handle_balance/1,
    handle_deal_cost/3
]).

%% @doc 处理消耗
handle_deal_cost(AttObjId, AttNickName, Cost) ->
    mission_ranking:update_hurt(util:get_dict(room_id), AttObjId, AttNickName, Cost).

%% @doc 创建副本
create_mission(RoomId, BossId, IsRobotRoom, IsParticipateIn, OwnerPlayerId, PlayerIdList) ->
    MissionType = ?MISSION_TYPE_MANY_PEOPLE_BOSS,
    #t_mission_many_people_boss{
        mission_id = MissionId,
        cost_mana = CostMana
    } = mod_many_people_boss:get_t_mission_many_people_boss(BossId),
    SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
    {ok, MissionSceneWorker} = scene_master:get_scene_worker(SceneId, [{mission_id, MissionId}, {boss_id, BossId}, {room_id, RoomId}]),
    if
        IsParticipateIn =:= ?FALSE andalso not IsRobotRoom ->
            #t_mission_type{
                continue_time = ContinueTime
            } = t_mission_type:get({?MISSION_TYPE_MANY_PEOPLE_BOSS}),
            OwnerNode = mod_player:get_game_node(OwnerPlayerId),
            rpc:cast(OwnerNode, api_many_people_boss, notice_player_fight_start, [OwnerPlayerId, ContinueTime div 1000]);
        true ->
            noop
    end,
    lists:foreach(
        fun(PlayerId) ->
            {X, Y} = mod_scene:get_scene_birth_pos(SceneId),
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, mod_many_people_boss, player_enter_mission, [PlayerId, CostMana, true, [MissionSceneWorker, SceneId, X, Y, [], null], MissionId], normal)
        end,
        PlayerIdList
    ),
    erlang:monitor(process, MissionSceneWorker),
    {ok, MissionSceneWorker}.

%% @doc 进入副本
handle_enter_mission(PlayerId, _SceneState) ->
    mission_ranking:notice_ranking([PlayerId], ?MISSION_TYPE_MANY_PEOPLE_BOSS, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)).

%% @doc 初始化副本
handle_init_mission(ExtraDataList) ->
    lists:foreach(
        fun({Type, Value}) ->
            put(Type, Value)
        end, ExtraDataList),
    mission_ranking:init(?MISSION_TYPE_MANY_PEOPLE_BOSS, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)).

%% @doc 玩家离开副本
handle_leave_mission(PlayerId) ->
    case mod_mission:is_balance() of
        false ->
            RoomId = get(room_id),
            case many_people_boss_srv:call({?MANY_PEOPLE_BOSS_MISSION_LEAVE, RoomId, PlayerId}) of
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
    RankList = mission_ranking:get_ranking_list(?MISSION_TYPE_MANY_PEOPLE_BOSS, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)),
    RoomId = get(room_id),
    KillBossPlayerId = get(?DICT_KILL_DIE_LAST),
    PlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),

    PlayerNameStr =
        case is_integer(KillBossPlayerId) of
            true ->
                #obj_scene_actor{
                    nickname = WinPlayerName
                } = ?GET_OBJ_SCENE_PLAYER(KillBossPlayerId),
                WinPlayerName;
            false ->
                ""
        end,

    case many_people_boss_srv:call({?MANY_PEOPLE_BOSS_MISSION_BALANCE, RoomId, PlayerIdList, KillBossPlayerId, RankList,PlayerNameStr}) of
        ok ->
            ?INFO("结算多人boss副本:~p", [{RoomId, KillBossPlayerId, PlayerIdList, RankList}]),
            ok;
        Error ->
            ?ERROR("结算多人boss副本ERROR===:~p~n", [{{RoomId, KillBossPlayerId, PlayerIdList, RankList}, Error}]),
            noop
    end,

    mission_ranking:clean_ranking(?MISSION_TYPE_MANY_PEOPLE_BOSS, util:get_dict(?DICT_MISSION_ID), util:get_dict(room_id)),
    scene_worker:stop(self(), 15 * ?SECOND_MS).
