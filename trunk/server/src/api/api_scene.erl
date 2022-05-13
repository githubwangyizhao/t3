%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(api_scene).

-include("common.hrl").
-include("error.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("scene.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("client.hrl").
-include("msg.hrl").
%% API
-export([
    get_monster_list/2,
    load_scene/2,
    enter_scene/2,
    enter_single_scene/2,
    player_move/2,
    player_move_step/2,
    player_stop_move/2,
%%    player_rebirth/2,
    query_player_pos/2,
    challenge_boss/2,
    send_msg/2,
    player_collect/2,
    show_action/2
]).

%% 通知
-export([
    notice_special_skill_change/5,
    notice_prepare_scene/2,
    notice_load_scene/4,
    notice_prepare_transmit/1,
    notice_sync_scene/3,
    notice_player_enter/2,
    notice_player_leave/2,
    notice_player_move/9,
    notice_player_stop_move/4,
    notice_player_teleport/4,
    notice_correct_player_pos/3,
    notice_monster_enter/2,
    notice_monster_leave/2,
    notice_monster_move/3,
    notice_monster_teleport/4,
    notice_monster_stop_move/4,
    notice_item_enter/2,
    notice_item_leave/3,
    notice_player_death/6,
    notice_player_attr_change/3,
    notice_player_string_attr_change/3,
    api_notice_monster_attr_change/3,
    api_notice_obj_hp_change/8,
    api_notice_rebirth/2,
    notice_scene_item_owner_change/3,
    notice_scene_jbxy_state/5,
    notice_fanpai/2,
    notice_send_msg/4,
    notice_boss_state/5,
    notice_anger/2,
    notice_monster_restore_hp/3,
    notice_player_show_action/3,
    notice_player_kuangbao_info/3,
    notice_boss_die/3,
    notice_rank_event/3,
    notice_rank_event_1/3
]).

-export([
    api_update_npc_date/2,
    api_update_player_npc_date/2,
    api_notice_simplify_monster_pos/2
]).

-export([
    pack_scene_actor/1
]).

-export([
    notice_init_time_event_list/4,
    notice_add_time_event_list/2,
    notice_time_event_list_sleep/1,
    notice_time_event_list_start/2
]).

%% ----------------------------------
%% @doc 	进入场景
%% @throws 	none
%% @end
%% ----------------------------------
enter_scene(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_enter_scene_tos{scene_id = SceneId} = _Msg,
    try mod_scene:player_enter_world_scene(PlayerId, SceneId)
    catch
        _:Reason ->
            case Reason of
                already_wait_enter_scene ->
                    ?DEBUG("already_wait_enter_scene");
                _ ->
                    ReasonEnum = api_common:api_error_to_enum(Reason),
                    Out = proto:encode(#m_scene_enter_scene_toc{scene_id = SceneId, result = ReasonEnum}),
                    mod_socket:send(PlayerId, Out)
            end
    end,
    State.

%% ----------------------------------
%% @doc 	进入单人场景
%% @throws 	none
%% @end
%% ----------------------------------
enter_single_scene(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_enter_single_scene_tos{scene_id = SceneId} = _Msg,
    try mod_scene:player_enter_single_world_scene(PlayerId, SceneId)
    catch
        _:Reason ->
            case Reason of
                already_wait_enter_scene ->
                    ?DEBUG("already_wait_enter_scene");
                _ ->
                    ReasonEnum = api_common:api_error_to_enum(Reason),
                    Out = proto:encode(#m_scene_enter_scene_toc{scene_id = SceneId, result = ReasonEnum}),
                    mod_socket:send(PlayerId, Out)
            end
    end,
    State.

%% ----------------------------------
%% @doc 	加载场景
%% @throws 	none
%% @end
%% ----------------------------------
get_monster_list(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_get_monster_list_tos{} = _Msg,
    SceneWorker = get(?DICT_PLAYER_SCENE_WORKER),
    case catch gen_server:call(SceneWorker, get_monster_list, 1000) of
        L when is_list(L) ->
            Out = proto:encode(#m_scene_notice_monster_list_toc{monster_list = L}),
            mod_socket:send(PlayerId, Out);
        _ ->
            noop
    end,
    State.


%% ----------------------------------
%% @doc 	加载场景
%% @throws 	none
%% @end
%% ----------------------------------
load_scene(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_load_scene_tos{screen_high = ScreenH, screen_width = ScreenW} = _Msg,
    mod_scene:do_player_enter_scene(PlayerId, ScreenW, ScreenH),
    State.

notice_fanpai(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_notice_fanpai_tos{} = _Msg,
    mod_scene:get_fight_fanpai(PlayerId),
    State.

%% ----------------------------------
%% @doc 	玩家移动
%% @throws 	none
%% @end
%% ----------------------------------
player_move(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_player_move_tos{x = X, y = Y, move_type = MoveType, high = High, time = Time, action_id = ActionId} = _Msg,
    mod_scene:player_move(PlayerId, X, Y, MoveType, High, Time, ActionId),
    State.

%% ----------------------------------
%% @doc 	玩家移动step
%% @throws 	none
%% @end
%% ----------------------------------
player_move_step(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_player_move_step_tos{x = X, y = Y} = _Msg,
    mod_scene:player_move_step(PlayerId, X, Y),
    State.

%% ----------------------------------
%% @doc 	玩家停止移动
%% @throws 	none
%% @end
%% ----------------------------------
player_stop_move(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_player_stop_move_tos{x = X, y = Y} = _Msg,
    mod_scene:player_stop_move(PlayerId, X, Y),
    State.

%% 展示动作
show_action(
    #m_scene_show_action_tos{action_id = ActionId},
    State = #conn{player_id = PlayerId}
) ->
    catch mod_scene:show_action(PlayerId, ActionId),
    State.

%% 玩家展示动作消息推送
notice_player_show_action(NoticePlayerIdList, PlayerId, ActionId) ->
    Out = proto:encode(#m_scene_show_action_notice_toc{player_id = PlayerId, action_id = ActionId}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% 通知玩家狂暴信息
notice_player_kuangbao_info(NoticePlayerIdList, PlayerId, EndTime) ->
    Out = proto:encode(#m_scene_player_kuangbao_info_notice_toc{player_id = PlayerId, time = EndTime}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% @doc 通知初始化时间轴事件列表
notice_init_time_event_list(NoticePlayerIdList, IsSleep, SleepTime, TimeEventList) ->
    Out = proto:encode(#m_scene_notice_init_time_event_list_toc{is_sleep = IsSleep, sleep_time = SleepTime, time_event_list = pack_pb_time_event_list(TimeEventList)}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% @doc 通知增加时间轴事件列表
notice_add_time_event_list(NoticePlayerIdList, TimeEventList) ->
    Out = proto:encode(#m_scene_notice_add_time_event_list_toc{time_event_list = pack_pb_time_event_list(TimeEventList)}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% @doc 通知时间轴事件列表暂停
notice_time_event_list_sleep(NoticePlayerIdList) ->
    Out = proto:encode(#m_scene_notice_time_event_list_sleep_toc{}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% @doc 通知时间轴事件列表暂停
notice_time_event_list_start(NoticePlayerIdList, SleepTime) ->
    Out = proto:encode(#m_scene_notice_time_event_list_start_toc{sleep_time = SleepTime}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% @doc 通知boss死亡
notice_boss_die(NoticePlayerIdList, BossId, KillPlayerId) ->
    Out = proto:encode(#m_scene_notice_boss_die_toc{boss_id = BossId, kill_player_id = KillPlayerId, award = get(mod_fight_fight_result_mano_award)}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 通知排行榜事件
%% @throws 	none
%% @end
%% ----------------------------------
notice_rank_event(_Type, 0, _PlayerId) ->
    noop;
notice_rank_event(Type, Value, PlayerId) ->
    erlang:send(self(), {apply, ?MODULE, notice_rank_event_1, [Type, Value, PlayerId]}).
notice_rank_event_1(Type, Value, PlayerId) ->
    Out = proto:encode(#m_scene_notice_rank_event_toc{
        type = Type,
        value = Value,
        player_id = PlayerId,
%%        total_value = mod_prop:get_player_prop_num(PlayerId, api_fight:get_item_id(get(?DICT_SCENE_ID), ?ITEM_GOLD))
        total_value = 0
    }),
    mod_socket:send_to_player_list(mod_scene_player_manager:get_all_obj_scene_player_id(), Out).

%% ----------------------------------
%% @doc 	通知场景物品归属改变
%% @throws 	none
%% @end
%% ----------------------------------
notice_scene_item_owner_change([], _ObjSceneItemId, _OwnnerPlayerId) ->
    noop;
notice_scene_item_owner_change(NoticePlayerIdList, ObjSceneItemId, OwnerPlayerId) ->
%%    ?DEBUG("~p~n", [{NoticePlayerIdList, ObjSceneItem}]),
    Out = proto:encode(#m_scene_notice_scene_item_owner_change_toc{scene_item_id = ObjSceneItemId, owner = OwnerPlayerId}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%%%% ----------------------------------
%%%% @doc 	玩家复活
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%player_rebirth(
%%    _Msg,
%%    State = #conn{player_id = PlayerId}
%%) ->
%%    #m_scene_player_rebirth_tos{} = _Msg,
%%    Result =
%%        try mod_scene:player_rebirth(PlayerId) of
%%            _ ->
%%                ?P_SUCCESS
%%        catch
%%            _:Reason ->
%%                ?ERROR("玩家复活失败~p~n", [{Reason}]),
%%                ?P_FAIL
%%        end,
%%    if Result == ?P_FAIL ->
%%        %% 复活成功由场景进程下发
%%        Out = proto:encode(#m_scene_player_rebirth_toc{result = Result}),
%%        mod_socket:send(Out);
%%        true ->
%%            noop
%%    end,
%%    State.

%% ----------------------------------
%% @doc 	查询玩家位置
%% @throws 	none
%% @end
%% ----------------------------------
query_player_pos(
    _Msg,
    State = #conn{}
) ->
    #m_scene_query_player_pos_tos{player_id = QueryPlayerId, type = Type} = _Msg,
    {X, Y} =
        try mod_scene:query_player_pos(QueryPlayerId) of
            {_, ThisX, ThisY} ->
                {ThisX, ThisY}
        catch
            _:Reason ->
                ?ERROR("查询玩家位置~p~n", [{Reason}]),
                {0, 0}
        end,
    Out = proto:encode(#m_scene_query_player_pos_toc{player_id = QueryPlayerId, x = X, y = Y, type = Type}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	挑战boss
%% @throws 	none
%% @end
%% ----------------------------------
challenge_boss(
    #m_scene_challenge_boss_tos{},
    State = #conn{player_id = PlayerId}
) ->
    try mod_scene:challenge_boss(PlayerId)
    catch
        _:Reason ->
            ?ERROR("challenge_boss:~p~n", [{Reason, erlang:get_stacktrace()}])
    end,
    State.

%% ----------------------------------
%% @doc 	发送消息
%% @throws 	none
%% @end
%% ----------------------------------
send_msg(
    #m_scene_send_msg_tos{type = Type, id = Id},
    State = #conn{player_id = PlayerId}
) ->
    try mod_scene:send_msg(PlayerId, Type, Id)
    catch
        _:Reason ->
            ?ERROR("send_msg:~p~n", [{Reason, erlang:get_stacktrace()}])
    end,
    State.

%% @doc 通知发送消息
notice_send_msg(PlayerIdList, PlayerId, Type, Id) ->
    Out = proto:encode(#m_scene_notice_send_msg_toc{player_id = PlayerId, type = Type, id = Id}),
    mod_socket:send_to_player_list(PlayerIdList, Out).

%% @doc 通知boss状态
notice_boss_state(PlayerId, State, Time, MissionType, MissionId) ->
    Out = proto:encode(#m_scene_notice_boss_state_toc{state = State, time = Time, mission_type = MissionType, mission_id = MissionId}),
    mod_socket:send(PlayerId, Out).

api_notice_rebirth(PlayerId, Result) ->
    Out = proto:encode(#m_scene_player_rebirth_toc{result = Result}),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知准备传送
%% @throws 	none
%% @end
%% ----------------------------------
notice_prepare_transmit(PlayerId) ->
    Out = proto:encode(#m_scene_notice_prepare_transmit_toc{}),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知加载场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_load_scene(PlayerId, LoadPlayerIdList, LoadMonsterIdList, LoadSceneItemIdList) ->
    SceneId = get(?DICT_SCENE_ID),
    #t_scene{
        type = SceneType,
        mission_type = MissionType
    } = t_scene:assert_get({SceneId}),
    ScenePlayerList =
        [
            begin
                ThisObjPlayer = ?GET_OBJ_SCENE_PLAYER(ThisPlayerId),
                if ThisObjPlayer == ?UNDEFINED ->
                    ?ERROR("~p~n", [{ThisPlayerId}]);
                    true ->
                        noop
                end,
                pack_scene_actor(ThisObjPlayer)
            end

            || ThisPlayerId <- LoadPlayerIdList
        ],
    SceneMonsterList =
        if
            SceneType == ?SCENE_TYPE_MISSION andalso MissionType == ?MISSION_TYPE_MISSION_HERO_PK_BOSS ->
                [];
            true ->
                lists:foldl(
                    fun(ThisObjMonsterId, TmpL) ->
                        ThisObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(ThisObjMonsterId),
                        if
                            ThisObjSceneMonster == ?UNDEFINED ->
                                {TGridId, SubscribeList, TSubscribeGridIdList, _EnterObjMonsterIdList} = get(error_leave_monster_log_),
                                L = lists:filtermap(
                                    fun(GridId) ->
                                        #dict_scene_grid{
                                            monster_list = MonsterIdList
                                        } = ?GET_SCENE_GRID(GridId),
                                        lists:member(ThisObjMonsterId, MonsterIdList)
                                    end,
                                    TSubscribeGridIdList
                                ),
                                ?ERROR("通知场景时，没有这只怪物 : ~p 其他数据 ： ~p~n", [ThisObjMonsterId, {L, TGridId, SubscribeList, get(?DICT_SCENE_ID)}]),
                                TmpL;
                            true ->
                                [pack_scene_actor(ThisObjSceneMonster) | TmpL]
                        end
                    end,
                    [], LoadMonsterIdList
                )
        end,
    SceneItemList =
        [
            pack_scene_item(mod_scene_item_manager:get_obj_scene_item(ThisObjSceneItemId))
            || {_, ThisObjSceneItemId} <- LoadSceneItemIdList
        ],
    Out = proto:encode(#m_scene_load_scene_toc{
        scene_id = SceneId,
        scene_player_list = ScenePlayerList,
        scene_monster_list = SceneMonsterList,
        scene_item_list = SceneItemList
    }),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	同步场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_sync_scene(
    _PlayerId,
    {[], [], []},
    {[], [], []}
) -> noop;
notice_sync_scene(
    PlayerId,
    {LeavePlayerIdList, LeaveObjMonsterIsList, LeaveSceneItemIdList},
    {EnterObjPlayerIdList, EnterObjMonsterIdList, EnterSceneItemIdList}
) ->
    ScenePlayerList =
        [
            pack_scene_actor(?GET_OBJ_SCENE_PLAYER(ThisPlayerId))
            || ThisPlayerId <- EnterObjPlayerIdList
        ],
    SceneMonsterList =
        lists:foldl(
            fun(ThisObjMonsterId, TmpL) ->
                ThisObjMonster = ?GET_OBJ_SCENE_MONSTER(ThisObjMonsterId),
                if
                    ThisObjMonster == ?UNDEFINED ->
                        {TGridId, SubscribeList, TSubscribeGridIdList, _EnterObjMonsterIdList} = get(error_leave_monster_log_),
                        L = lists:filtermap(
                            fun(GridId) ->
                                #dict_scene_grid{
                                    monster_list = MonsterIdList
                                } = ?GET_SCENE_GRID(GridId),
                                lists:member(ThisObjMonsterId, MonsterIdList)
                            end,
                            TSubscribeGridIdList
                        ),
                        ?ERROR("通知场景时，没有这只怪物 : ~p 其他数据 ： ~p~n", [ThisObjMonsterId, {L, TGridId, SubscribeList, get(?DICT_SCENE_ID)}]),
                        TmpL;
                    true ->
                        [pack_scene_actor(ThisObjMonster) | TmpL]
                end
            end,
            [], EnterObjMonsterIdList
        ),
    SceneItemList =
        [
            pack_scene_item(mod_scene_item_manager:get_obj_scene_item(ThisObjSceneItemId))
            || {_, ThisObjSceneItemId} <- EnterSceneItemIdList
        ],
    Out = proto:encode(#m_scene_sync_scene_toc{
        remove_scene_player_id_list = LeavePlayerIdList,
        remove_scene_monster_id_list = LeaveObjMonsterIsList,
        remove_scene_item_id_list = [#sceneitemid{type = SceneItemType, id = ThisObjSceneItemId} || {SceneItemType, ThisObjSceneItemId} <- LeaveSceneItemIdList],
        scene_player_list = ScenePlayerList,
        scene_monster_list = SceneMonsterList,
        scene_item_list = SceneItemList
    }),
    mod_socket:send(PlayerId, Out).


%% ----------------------------------
%% @doc 	通知玩家准备场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_prepare_scene(
    PlayerId,
    SceneId
) ->
    Out = proto:encode(#m_scene_notice_prepare_scene_toc{scene_id = SceneId}),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知其他玩家进入场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_enter([], _ObjScenePlayer) ->
    noop;
notice_player_enter(NoticePlayerIdList, ObjScenePlayer) ->
    Out = proto:encode(#m_scene_notice_scene_player_enter_toc{scene_player = pack_scene_actor(ObjScenePlayer)}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out, [{ignore_player_id, ObjScenePlayer#obj_scene_actor.obj_id}]).

%% ----------------------------------
%% @doc 	通知其他玩家离开场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_leave([], _PlayerId) ->
    noop;
notice_player_leave(NoticePlayerIdList, PlayerId) ->
    Out = proto:encode(#m_scene_notice_scene_player_leave_toc{player_id = PlayerId}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out, [{ignore_player_id, PlayerId}]).

%% ----------------------------------
%% @doc 	通知玩家移动
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_move([], _PlayerId, _GoX, _GoY, _MoveType, _MovePath, _High, _Time, _ActionId) ->
    noop;
notice_player_move(NoticePlayerIdList, PlayerId, GoX, GoY, MoveType, MovePath, High, Time, ActionId) ->
%%    ?DEBUG("通知玩家移动:~p~n", [{NoticePlayerIdList, MoveType, PlayerId}]),
    Out = proto:encode(#m_scene_notice_player_move_toc{player_id = PlayerId, go_x = GoX, go_y = GoY, move_type = MoveType, move_path = pack_move_path(MovePath), high = High, time = Time, action_id = ActionId}),
    IsServerControlScene = get(?DICT_SCENE_IS_SERVER_CONTROL_SCENE),
    if IsServerControlScene == true ->
%%        ?DEBUG("通知玩家移动:~p~n", [{NoticePlayerIdList, MoveType, PlayerId}]),
        mod_socket:send_to_player_list(NoticePlayerIdList, Out);
        true ->
            mod_socket:send_to_player_list(NoticePlayerIdList, Out, [{ignore_player_id, PlayerId}])
    end.

%% ----------------------------------
%% @doc 	通知玩家停止移动
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_stop_move([], _PlayerId, _X, _Y) ->
    noop;
notice_player_stop_move(NoticePlayerIdList, PlayerId, X, Y) ->
    Out = proto:encode(#m_scene_notice_player_stop_move_toc{player_id = PlayerId, x = X, y = Y}),
    IsServerControlScene = get(?DICT_SCENE_IS_SERVER_CONTROL_SCENE),
    if IsServerControlScene ->
        mod_socket:send_to_player_list(NoticePlayerIdList, Out);
        true ->
            mod_socket:send_to_player_list(NoticePlayerIdList, Out, [{ignore_player_id, PlayerId}])
    end.

%% ----------------------------------
%% @doc 	通知玩家停止移动
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_teleport([], _PlayerId, _X, _Y) ->
    noop;
notice_player_teleport(NoticePlayerIdList, PlayerId, X, Y) ->
    Out = proto:encode(#m_scene_notice_player_teleport_toc{player_id = PlayerId, x = X, y = Y}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	纠正玩家位置
%% @throws 	none
%% @end
%% ----------------------------------
notice_correct_player_pos(PlayerId, X, Y) ->
    ?DEBUG("纠正玩家位置 ： ~p", [{PlayerId, X, Y}]),
    Out = proto:encode(#m_scene_notice_correct_player_pos_toc{x = X, y = Y}),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知怪物进入场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_monster_enter([], _ObjSceneMonsterList) ->
    noop;
notice_monster_enter(NoticePlayerIdList, ObjSceneMonsterList) ->
    Out = proto:encode(#m_scene_notice_monster_enter_toc{scene_monster_list = [pack_scene_actor(ObjSceneMonster) || ObjSceneMonster <- ObjSceneMonsterList]}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	通知怪物离开场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_monster_leave([], _ObjSceneMonsterId) ->
    noop;
notice_monster_leave(NoticePlayerIdList, ObjSceneMonsterId) ->
    Out = proto:encode(#m_scene_notice_monster_leave_toc{scene_monster_id = ObjSceneMonsterId}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	通知怪物移动
%% @throws 	none
%% @end
%% ----------------------------------
notice_monster_move([], _ObjSceneMonsterId, _MovePath) ->
    noop;
notice_monster_move(_NoticePlayerIdList, _ObjSceneMonsterId, []) ->
    noop;
notice_monster_move(NoticePlayerIdList, ObjSceneMonsterId, MovePath) ->
    Out = proto:encode(#m_scene_notice_monster_move_toc{scene_monster_id = ObjSceneMonsterId, move_path = pack_move_path(MovePath)}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	通知怪物瞬移
%% @throws 	none
%% @end
%% ----------------------------------
notice_monster_teleport([], _ObjSceneMonsterId, _X, _Y) ->
    noop;
notice_monster_teleport(NoticePlayerIdList, ObjSceneMonsterId, X, Y) ->
    Out = proto:encode(#m_scene_notice_monster_teleport_toc{scene_monster_id = ObjSceneMonsterId, x = X, y = Y}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	通知怪物停止移动
%% @throws 	none
%% @end
%% ----------------------------------
notice_monster_stop_move([], _ObjSceneMonsterId, _X, _Y) ->
    noop;
notice_monster_stop_move(NoticePlayerIdList, ObjSceneMonsterId, X, Y) ->
%%    ?DEBUG("~p~n", [NoticePlayerIdList]),
    Out = proto:encode(#m_scene_notice_monster_stop_move_toc{scene_monster_id = ObjSceneMonsterId, x = X, y = Y}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).


%% ----------------------------------
%% @doc 	通知物品进入场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_item_enter([], _ObjSceneItemList) ->
    noop;
notice_item_enter(NoticePlayerIdList, ObjSceneItemList) ->
%%    ?DEBUG("~p~n", [{NoticePlayerIdList, ObjSceneItem}]),
    Out = proto:encode(#m_scene_notice_item_enter_toc{scene_item_list = [pack_scene_item(ObjSceneItem) || ObjSceneItem <- ObjSceneItemList]}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	通知物品离开场景
%% @throws 	none
%% @end
%% ----------------------------------
notice_item_leave([], _Type, _ObjSceneItemIdList) ->
    noop;
notice_item_leave(NoticePlayerIdList, Type, ObjSceneItemIdList) ->
%%    ?DEBUG("~p~n", [{NoticePlayerIdList, ObjSceneItemId}]),
    Out = proto:encode(#m_scene_notice_item_leave_toc{scene_item_id_list = ObjSceneItemIdList, type = Type}),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	通知玩家死亡
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_death(PlayerId, AttObjType, AttObjId, AttName, SceneId, RebirthTime) ->
%%    ?DEBUG("通知玩家死亡:~p~n", [{PlayerId, AttObjType, AttObjId, AttName, SceneId, RebirthTime}]),
    Out = proto:encode(#m_scene_notice_player_death_toc{
        attacker_type = AttObjType,
        attacker_id = AttObjId,
        name = AttName,
        scene_id = SceneId,
        rebirth_time = RebirthTime
    }),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知玩家属性变化
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_attr_change(_NoticePlayerIdList, _PlayerId, []) ->
    noop;
notice_player_attr_change(NoticePlayerIdList, PlayerId, ChangeList) ->
%%    ?DEBUG("通知玩家属性变化:~p~n", [{NoticePlayerIdList, PlayerId, ChangeList}]),
    Out =
        proto:encode(#m_player_notice_player_attr_change_toc{
            player_id = PlayerId,
            list = api_player:tran_attr_change(ChangeList)
        }),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).


notice_special_skill_change(NoticePlayerIdList, PlayerId, DefObjId, Id, Time) ->
%%    ?DEBUG("通知玩家属性变化:~p~n", [{NoticePlayerIdList, PlayerId, ChangeList}]),
    Out =
        proto:encode(#m_scene_notice_special_skill_change_toc{
            player_id = PlayerId,
            special_skill_id = Id,
            special_skill_expire_time = Time,
            scene_monster_id = DefObjId
        }),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	通知玩家属性变化
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_string_attr_change(_NoticePlayerIdList, _PlayerId, []) ->
    noop;
notice_player_string_attr_change(NoticePlayerIdList, PlayerId, ChangeList) ->
%%    ?DEBUG("通知玩家属性变化:~p~n", [{NoticePlayerIdList, PlayerId, ChangeList}]),
    Out =
        proto:encode(#m_player_notice_player_string_attr_change_toc{
            player_id = PlayerId,
            list = api_player:tran_string_attr_change(ChangeList)
        }),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

% ----------------------------------
%% @doc 	通知场景金币小妖状态
%% @throws 	none
%% @end
%% ----------------------------------
notice_scene_jbxy_state(NoticePlayerIdList, State, MonsterId, CloseTime, KillPlayerId) ->
    Out = proto:encode(#m_scene_notice_scene_jbxy_state_toc{
        state = ?TRAN_BOOL_2_INT(State),
        monster_id = MonsterId,
        close_time = CloseTime,
        player_id = KillPlayerId
    }),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% ----------------------------------
%% @doc 	玩家采集
%% @throws 	none
%% @end
%% ----------------------------------
player_collect(
    _Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_scene_player_collect_tos{scene_item_id = SceneItemIdList} = _Msg,
%%    ?t_assert(SceneItemIdList =/= []),
    mod_scene_item_manager:player_collect(PlayerId, SceneItemIdList),
    State.

%% ----------------------------------
%% @doc 	打包场景物品
%% @throws 	none
%% @end
%% ----------------------------------
pack_scene_item(ObjSceneItem) ->
    #obj_scene_item{
        id = Id,
        base_id = BaseId,
        num = Num,
        x = X,
        y = Y,
        own_player_id = OwnPlayerId,
        drop_obj_scene_monster_id = ObjSceneMonsterId,
        type = Type
    } = ObjSceneItem,
    #sceneitem{
        id = Id,
        base_id = BaseId,
        num = Num,
        type = Type,
        x = X,
        y = Y,
        owner_player_id = OwnPlayerId,
        scene_monsrer_id = ObjSceneMonsterId
    }.

%% ----------------------------------
%% @doc 	打包场景actor
%% @throws 	none
%% @end
%% ----------------------------------
%% @todo OBJ SCENE ACTOR 可能为undefined
pack_scene_actor(ObjSceneActor) ->
    #obj_scene_actor{
        obj_id = ObjId,
        obj_type = ObjType,
        base_id = BaseId,
        nickname = NickName,
        sex = Sex,
        level = Level,
        vip_level = VipLevel,
        x = X,
        y = Y,
        go_x = GoX,
        go_y = GoY,
        move_path = MovePath,
        dir = Dir,
        hp = Hp,
        max_hp = MaxHp,
        move_speed = MoveSpeed,
        bing_don_end_time = BingDonEndTime,
        surface = Surface,
        destroy_time_ms = DestroyTimeMs,
        owner_obj_id = OwnnerObjId,
        move_type = MoveType,
        buff_list = RBuffList,
        track_info = _TrackInfo,
        belong_player_id = BelongPlayerId,
        owner_obj_type = OwnerObjType,
%%        owner_obj_id = OwnerObjId,
        anger = Anger,
        dizzy_close_time = DizzyCloseTime,
        kuang_bao_time = KuangbaoTime
    } = ObjSceneActor,

    if
        ObjType == ?OBJ_TYPE_PLAYER ->
            #surface{
                magic_weapon_id = MagicWeaponId,
                title_id = TitleId,
                hero_id = HeroId,
                hero_arms = HeroArms,
                hero_ornaments = HeroOrnaments,
                head_id = HeadId,
                head_frame_id = HeadFrameId,
                chat_qi_pao_id = ChatQiPaoId
            } = Surface,
%%            io:format("~p~n", [{NickName, Hp, MaxHp}]),
            #sceneplayer{
                player_id = ObjId,
                nickname = NickName,
                sex = Sex,
                level = Level,
                vip_level = VipLevel,
                hp = Hp,
                max_hp = MaxHp,
                move_speed = MoveSpeed,
                move_path = pack_move_path(MovePath),
                x = X,
                y = Y,
                go_x = GoX,
                go_y = GoY,
                move_type = MoveType,
                dir = Dir,
                title_id = TitleId,
                magic_weapon_id = MagicWeaponId,
                buff_list = api_fight:pack_buff_list(RBuffList),
                anger = Anger,
                anger_skill_effect = mod_player:get_player_anger_skill_effect_init(ObjId),
                hero_id = HeroId,
                hero_arms_id = HeroArms,
                hero_ornaments_id = HeroOrnaments,
                dizzy_close_time = round(DizzyCloseTime / 1000),
                kuangbao_time = round(KuangbaoTime / 1000),
                player_other_data = api_player:pack_player_other_data(HeadId, HeadFrameId, ChatQiPaoId),
                player_effect_in_scene = [
                    #playereffectinscene{
                        skill_id = SkillId,
                        timestamp = EndTime div ?SECOND_MS
                    } || {SkillId, EndTime, _Ref} <- mod_scene_skill_manager:get_player_all_skill_buff(ObjId)
                ]
            };
        ObjType == ?OBJ_TYPE_MONSTER ->
            #scenemonster{
                scene_monster_id = ObjId,
                monster_id = BaseId,
                x = X,
                y = Y,
                level = Level,
                move_path = pack_move_path(MovePath),
                move_speed = MoveSpeed,
                dir = Dir,
                hp = Hp,
                max_hp = MaxHp,
                buff_list = api_fight:pack_buff_list(RBuffList),
                belong_player_id = BelongPlayerId,
                owner_player_id = ?IF(OwnerObjType == ?OBJ_TYPE_PLAYER, OwnnerObjId, 0),
                bind_don_end_time = trunc(BingDonEndTime / 1000),
                destroy_time = if DestroyTimeMs > 0 ->
                    trunc(DestroyTimeMs / 1000);
                                   true ->
                                       0
                               end,
                is_call_monster = if OwnnerObjId > 0 -> 1; true -> 0 end
            }
    end.

%% @fun api通知怪物属性变数据
api_notice_monster_attr_change([], _ObjMonsterId, _List) ->
    noop;
api_notice_monster_attr_change(NoticePlayerIdList, ObjMonsterId, List) ->
    Out = proto:encode(#m_scene_notice_monster_attr_change_toc{
        scene_monster_id = ObjMonsterId,
        list = pack_monster_attr_change(List)
    }),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% @fun api通知怪物属性变数据
api_notice_obj_hp_change(NoticePlayerIdList, EffectId, ObjType, ObjId, ChangeValue, NewHp, ReleaseObjType, ReleaseObjId) ->
%%    ?DEBUG("api_notice_obj_hp_change:~p", [{NoticePlayerIdList, EffectId, ObjType, ObjId, ChangeValue, NewHp, ReleaseObjType, ReleaseObjId}]),
    Out = proto:encode(#m_scene_notice_obj_hp_change_toc{
        obj_type = ObjType,
        obj_id = ObjId,
        change_value = ChangeValue,
        new_hp = NewHp,
        effect_id = EffectId,
        release_obj_type = ReleaseObjType,
        release_obj_id = ReleaseObjId
    }),
    mod_socket:send_to_player_list(NoticePlayerIdList, Out).

%% @fun 通知当前场景玩家npc变化
api_update_npc_date(SceneId, List) ->
    Out = proto:encode(#m_scene_update_npc_date_toc{npc_data = pack_scene_npc_data(List)}),
    [mod_socket:send(PlayerId, Out) || PlayerId <- mod_scene:get_player_id_list_by_scene_id(SceneId)].
%% @fun 通知玩家npc变化
api_update_player_npc_date(PlayerId, List) ->
    Out = proto:encode(#m_scene_update_npc_date_toc{npc_data = pack_scene_npc_data(List)}),
    mod_socket:send(PlayerId, Out).

%% @fun 通知怪物简单的信息
api_notice_simplify_monster_pos(PlayerIdList, List) ->
    Out = proto:encode(#m_scene_notice_simplify_monster_pos_toc{monster = pack_sccene_simplify_monster(List)}),
    [mod_socket:send(PlayerId, Out) || PlayerId <- PlayerIdList].

%% @doc 通知怒气
notice_anger(PlayerId, NewAnger) ->
    Out = proto:encode(#m_scene_notice_anger_change_toc{
        anger = NewAnger
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知怪物血量恢复
notice_monster_restore_hp(PlayerIdList, MonsterObjId, NewHp) ->
    Out = proto:encode(#m_scene_notice_monster_restore_hp_toc{
        obj_id = MonsterObjId,
        new_hp = NewHp
    }),
    mod_socket:send_to_player_list(PlayerIdList, Out).

%% ----------------------------------
%% @doc 	打包移动路径
%% @throws 	none
%% @end
%% ----------------------------------
pack_move_path(MovePath) ->
    [#movepath{x = X, y = Y} || {X, Y} <- MovePath].

%% @fun 打包怪物属性变数据
pack_monster_attr_change(List) ->
    [#'m_scene_notice_monster_attr_change_toc.monster_attr_change'{monsterattr = Attr, value = Value} || {Attr, Value} <- List].
%% @fun 打包怪物属性变数据
pack_scene_npc_data(List) ->
    [#scenenpcdata{scene_id = SceneId, x = X, y = Y, npc_id = NpcId, npc_name = NameBinary} || {SceneId, X, Y, NpcId, NameBinary} <- List].
%% @fun 打包简单的怪物数据
pack_sccene_simplify_monster(List) ->
    [#scenesimplifymonster{monster_id = MonsterId, x = X, y = Y, time = UpdateTime} || {MonsterId, X, Y, UpdateTime} <- List].

pack_pb_time_event_list(List) -> pack_pb_time_event_list(List, []).
pack_pb_time_event_list([], Acc) -> Acc;
pack_pb_time_event_list([TimeEvent | Rest], Acc) ->
    pack_pb_time_event_list(Rest, Acc ++ pack_pb_time_event_list_1(TimeEvent)).

pack_pb_time_event_list_1(#scene_loop_time_event{is_notice = false}) ->
    [];
pack_pb_time_event_list_1(#scene_loop_time_event{time = Time, event_type = ?SCENE_TIME_EVENT_TYPE_FUNCTION_MONSTER, event_arg = {Effect, _, _, _}}) ->
    [#timeevent{
        time = Time,
        type = ?SCENE_TIME_EVENT_TYPE_FUNCTION_MONSTER,
        params = [Effect]
    }];
pack_pb_time_event_list_1(#scene_loop_time_event{time = Time, event_type = ?SCENE_TIME_EVENT_TYPE_BOSS, event_arg = [BossId]}) ->
    [#timeevent{
        time = Time,
        type = ?SCENE_TIME_EVENT_TYPE_BOSS,
        params = [BossId]
    }];
pack_pb_time_event_list_1(#scene_loop_time_event{time = Time, event_type = ?SCENE_TIME_EVENT_TYPE_TASK, event_arg = [TaskType]}) ->
    [#timeevent{
        time = Time,
        type = ?SCENE_TIME_EVENT_TYPE_TASK,
        params = [TaskType]
    }];
pack_pb_time_event_list_1(#scene_loop_time_event{time = Time, event_type = EventType}) ->
    [#timeevent{
        time = Time,
        type = EventType,
        params = []
    }].
