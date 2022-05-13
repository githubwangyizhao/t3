%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            场景九宫格管理
%%% @end
%%% Created : 11. 八月 2016 下午 4:19
%%%-------------------------------------------------------------------
-module(mod_scene_grid_manager).
%%-include("scene.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
%%-include("db.hrl").
-include("scene.hrl").
-include("error.hrl").
%% API
-export([
    nine_grid/1,                                %% 获取九宫格
    init/1,                                     %% 初始化场景格子
%%    get_scene_grid/1,                          %% 获取场景格子
    get_subscribe_grid_id_list_by_px/2,
    get_nine_grid_monster_id_list/1,
    get_subscribe_player_id_list/1             %% 获取订阅该格子的玩家列表

]).

-export([
    %% 处理玩家格子变更
    handle_player_enter_grid/1,
    handle_player_leave_grid/1,
    handle_player_grid_change/4,

    %% 处理怪物格子变更
    handle_monster_enter_grid/2,
    handle_monster_leave_grid/2,
    handle_monster_grid_change/3,

    %% 处理掉落物格子变更
    handle_item_enter_grid/2,
    handle_item_leave_grid/2
]).

%% 获取 ets_scene_grid
%%-define(GET_SCENE_GRID(GridId), get({scene_grid, GridId})).

%% ----------------------------------
%% @doc 	初始化九宫格
%% @throws 	none
%% @end
%% ----------------------------------
init(SceneId) ->
    init_grid_width_and_height(SceneId),
    #t_scene{
        map_id = MapId
    } = mod_scene:get_t_scene(SceneId),
    #r_map_data{
        width = PW,
        height = PH
    } = map_data:get(MapId),
    GW = erlang:ceil(PW / ?GET_GRID_PIX_WIDTH),
    GH = erlang:ceil(PH / ?GET_GRID_PIX_HEIGHT),
    lists:foreach(
        fun(GY) ->
            lists:foreach(
                fun(GX) ->
                    ?UPDATE_SCENE_GRID(#dict_scene_grid{id = {GX, GY}})
                end,
                lists:seq(0, GW - 1)
            )
        end,
        lists:seq(0, GH - 1)
    ).

%% ----------------------------------
%% @doc 	初始化九宫格大小
%% @throws 	none
%% @end
%% ----------------------------------
init_grid_width_and_height(_SceneId) ->
%%    #t_scene{
%%        map_id = MapId,
%%        type = Type,
%%        mission_type = _MissionType
%%        is_all_scene_sync = IsAllSceneSync
%%    } = mod_scene:get_t_scene(SceneId),
%%    #r_map_data{
%%        width = PW,
%%        height = PH
%%    } = map_data:get(MapId),

    %% 普通同步
    CommonSyncInitFun =
        fun() ->
            ?INIT_GRID_PIX_WIDTH(?DEFAULT_GRID_PIX_WIDTH),
            ?INIT_GRID_PIX_HEIGHT(?DEFAULT_GRID_PIX_HEIGHT)
        end,

    CommonSyncInitFun().

%% 全场景同步
%%    AllSyncInitFun =
%%        fun() ->
%%            ?INIT_GRID_PIX_WIDTH(PW),
%%            ?INIT_GRID_PIX_HEIGHT(PH)
%%        end,

%%    if %% 是否全场景同步, 世界场景一定非全场景同步
%%        IsAllSceneSync == ?FALSE orelse Type == ?SCENE_TYPE_WORLD_SCENE orelse Type == ?SCENE_TYPE_BATTLE_GROUND->
%%            CommonSyncInitFun();
%%        true ->
%%            AllSyncInitFun().
%%    end.
%%    case Type of
%%        ?SCENE_TYPE_WORLD_SCENE ->
%%            CommonSyncInitFun();
%%        _ ->
%%            if %% 是否全场景同步
%%                IsAllSceneSync == ?FALSE ->
%%                    CommonSyncInitFun();
%%                true ->
%%                    AllSyncInitFun()
%%            end
%%    end.

%%%% ----------------------------------
%%%% @doc 	获取场景格子
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_scene_grid(GridId) ->
%%    case get({scene_grid, GridId}) of
%%        ?UNDEFINED ->
%%            null;
%%        R ->
%%            R
%%    end.

%%%% ----------------------------------
%%%% @doc 	更新场景格子
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%update_scene_grid(SceneGrid) ->
%%    put({scene_grid, SceneGrid#dict_scene_grid.id}, SceneGrid).

%%get_nine_grid_info(GridId) ->
%%    get_grid_list_info(nine_grid(GridId)).

get_grid_list_info(GridList) ->
    lists:foldl(
        fun(GridId, {PlayerIdList, ObjMonsterIdList, SceneItemIdList, SceneTrapIdList}) ->
            case ?GET_SCENE_GRID(GridId) of
                ?UNDEFINED ->
                    {PlayerIdList, ObjMonsterIdList, SceneItemIdList, SceneTrapIdList};
                R ->
                    {
                            R#dict_scene_grid.player_list ++ PlayerIdList,
                            R#dict_scene_grid.monster_list ++ ObjMonsterIdList,
                            R#dict_scene_grid.item_list ++ SceneItemIdList,
                            R#dict_scene_grid.trap_list ++ SceneTrapIdList
                    }
            end
        end,
        {[], [], [], []},
        GridList
    ).

%%get_grid_list_player_list(GridList) ->
%%    lists:foldl(
%%        fun(GridId, PlayerIdList) ->
%%            case get_scene_grid(GridId) of
%%                null ->
%%                    PlayerIdList;
%%                R ->
%%                    R#dict_scene_grid.player_list ++ PlayerIdList
%%            end
%%        end,
%%        [],
%%        GridList
%%    ).

%% ----------------------------------
%% @doc 	获取九宫格玩家id列表
%% @throws 	none
%% @end
%% ----------------------------------
%%get_nine_grid_player_id_list(GridId) ->
%%    lists:foldl(
%%        fun(GridId1, TempList) ->
%%            case ?GET_SCENE_GRID(GridId1) of
%%                ?UNDEFINED ->
%%                    TempList;
%%                R ->
%%                    R#dict_scene_grid.player_list ++ TempList
%%            end
%%        end,
%%        [],
%%        nine_grid(GridId)
%%    ).

%% ----------------------------------
%% @doc 	获取九宫格怪物id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_nine_grid_monster_id_list(GridId) ->
    lists:foldl(
        fun(GridId1, TempList) ->
            case ?GET_SCENE_GRID(GridId1) of
                ?UNDEFINED ->
                    TempList;
                R ->
                    R#dict_scene_grid.monster_list ++ TempList
            end
        end,
        [],
        nine_grid(GridId)
    ).


%%%%获取九宫格
nine_grid({GX, GY}) ->
    [
        {GX - 1, GY - 1}, {GX, GY - 1}, {GX + 1, GY - 1},
        {GX - 1, GY}, {GX, GY}, {GX + 1, GY},
        {GX - 1, GY + 1}, {GX, GY + 1}, {GX + 1, GY + 1}
    ].


split_list(List1, List2) ->
    lists:foldl(
        fun(E, {Leave, Cross, Enter}) ->
            case lists:member(E, List2) of
                false ->
                    {[E | Leave], Cross, Enter};
                true ->
                    {Leave, [E | Cross], lists:delete(E, Enter)}
            end
        end,
        {[], [], List2},
        List1
    ).


%% ----------------------------------
%% @doc 	获取订阅的格子id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_player_subscribe_grid_id_list(SubscribeList, {GX, GY}) ->
    [{GX + DiffX, GY + DiffY} || {DiffX, DiffY} <- SubscribeList].
%%    nine_grid(GridId).

get_subscribe_grid_id_list_by_px(PxX, PxY) ->
    W = erlang:ceil(PxX / 2 / ?DEFAULT_GRID_PIX_WIDTH),
    H = erlang:ceil(PxY / 2 / ?DEFAULT_GRID_PIX_HEIGHT),
    R = [{X, Y} || X <- lists:seq(-W, W), Y <- lists:seq(-H, H)],
%%    ?DEBUG("get_subscribe_grid_id_list_by_px:~p~n", [{W, H}]),
%%    ?DEBUG("~p~n", [{{PxX, PxY}, {W, H}}]),
%%    ?DEBUG("~p~n", [R]),
    R.

%% ----------------------------------
%% @doc 	订阅格子
%% @throws 	none
%% @end
%% ----------------------------------
subscribe_grid(PlayerId, GridIdList) ->
    lists:foreach(
        fun(ThisGridId) ->
            SceneGrid = ?GET_SCENE_GRID(ThisGridId),
            if SceneGrid == ?UNDEFINED ->
                noop;
                true ->
                    ?t_assert(lists:member(PlayerId, SceneGrid#dict_scene_grid.subscribe_player_id_list) == false),
                    NewSceneGrid = SceneGrid#dict_scene_grid{
                        subscribe_player_id_list = [PlayerId | SceneGrid#dict_scene_grid.subscribe_player_id_list]
                    },
                    ?UPDATE_SCENE_GRID(NewSceneGrid)
            end

        end,
        GridIdList
    ).

%% ----------------------------------
%% @doc 	取消订阅格子
%% @throws 	none
%% @end
%% ----------------------------------
cancel_subscribe_grid(PlayerId, GridIdList) ->
    lists:foreach(
        fun(ThisGridId) ->
            SceneGrid = ?GET_SCENE_GRID(ThisGridId),
            if SceneGrid == ?UNDEFINED ->
                noop;
                true ->
                    ?t_assert(lists:member(PlayerId, SceneGrid#dict_scene_grid.subscribe_player_id_list) == true),
                    NewSceneGrid = SceneGrid#dict_scene_grid{
                        subscribe_player_id_list = lists:delete(PlayerId, SceneGrid#dict_scene_grid.subscribe_player_id_list)
                    },
                    ?UPDATE_SCENE_GRID(NewSceneGrid)
            end
        end,
        GridIdList
    ).

%% ----------------------------------
%% @doc 	获取订阅该格子的玩家列表
%% @throws 	none
%% @end
%% ----------------------------------
get_subscribe_player_id_list(GridId) ->
    SceneGrid = ?GET_SCENE_GRID(GridId),
    SceneGrid#dict_scene_grid.subscribe_player_id_list.

%% ----------------------------------
%% @doc     玩家进入格子
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_enter_grid(ObjScenePlayer) ->
    #obj_scene_actor{
        obj_id = PlayerId,
        obj_type = ?OBJ_TYPE_PLAYER,
        grid_id = GridId,
        subscribe_list = SubscribeList
    } = ObjScenePlayer,
    SceneGrid = ?GET_SCENE_GRID(GridId),
    ?ASSERT(SceneGrid =/= ?UNDEFINED, {?ERROR_UNKNOWN_GRID, get(?DICT_SCENE_ID), GridId}),
    #dict_scene_grid{
        player_list = PlayerList,
        subscribe_player_id_list = _SubscribePlayerIdList
    } = SceneGrid,
    SubscribePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),    %% todo 订阅者暂时调整为场景内所有玩家
    ?ASSERT(lists:member(PlayerId, PlayerList) == false, ?ERROR_ALREADY_IN_THIS_GRID),

    %% 加入新格子
    NewPlayerList = [PlayerId | PlayerList],
    NewSceneGrid = SceneGrid#dict_scene_grid{player_list = NewPlayerList},
    ?UPDATE_SCENE_GRID(NewSceneGrid),

    %% 订阅九宫格
    SubscribeGridIdList = get_player_subscribe_grid_id_list(SubscribeList, GridId),
    subscribe_grid(PlayerId, SubscribeGridIdList),

    %% 场内所有玩家
    ObjScenePlayerIdList = SubscribePlayerIdList,
    %% 九宫格内的怪物和掉落物
    {_ObjScenePlayerIdList, ObjSceneMonsterIdList, ObjSceneItemIdList, _ObjSceneTrapIdList} = get_grid_list_info(SubscribeGridIdList),
    %% 场内所有boss和功能怪
    ObjectSceneSpecMonsterIdList = mod_scene_monster_manager:get_all_obj_scene_spec_monster_id(),

    put(error_leave_monster_log_, {GridId, SubscribeList, SubscribeGridIdList, ObjSceneMonsterIdList}),
    %% 通知自己加载场景
    api_scene:notice_load_scene(PlayerId, ObjScenePlayerIdList, lists:append(ObjectSceneSpecMonsterIdList, ObjSceneMonsterIdList), ObjSceneItemIdList),
    %% 通知其他玩家加载自己
    api_scene:notice_player_enter(SubscribePlayerIdList, ObjScenePlayer).


%% ----------------------------------
%% @doc     玩家离开格子
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_leave_grid(ObjScenePlayer) ->
    #obj_scene_actor{
        obj_id = PlayerId,
        grid_id = GridId,
        subscribe_list = SubscribeList
    } = ObjScenePlayer,
    SceneGrid = ?GET_SCENE_GRID(GridId),
    ?ASSERT(SceneGrid =/= ?UNDEFINED, ?ERROR_UNKNOWN_GRID),
    #dict_scene_grid{
        player_list = PlayerList,
        subscribe_player_id_list = _SubscribePlayerIdList
    } = SceneGrid,

    SubscribePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(), %% todo 订阅者暂时调整为场景内所有玩家

    %% 从旧格子移除
    NewSceneGrid = SceneGrid#dict_scene_grid{player_list = lists:delete(PlayerId, PlayerList)},
    ?UPDATE_SCENE_GRID(NewSceneGrid),

    %% 取消订阅格子列表
    DescribeGridIdList = get_player_subscribe_grid_id_list(SubscribeList, GridId),
    cancel_subscribe_grid(PlayerId, DescribeGridIdList),

    %% 通知其他玩家移除自己
    api_scene:notice_player_leave(SubscribePlayerIdList, PlayerId).

%% ----------------------------------
%% @doc     玩家格子改变
%% @throws 	none
%% @end
%% ----------------------------------
handle_player_grid_change(ObjScenePlayer, FGridId, TGridId, Action) ->
    #obj_scene_actor{
        key = {_, PlayerId},
        subscribe_list = SubscribeList
    } = ObjScenePlayer,
    ObjSceneAllPlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
    if
        FGridId == TGridId ->
            if
                Action == walk -> noop;
                true ->
%%                    SubscribePlayerIdList = get_subscribe_player_id_list(FGridId),
                    SubscribePlayerIdList = ObjSceneAllPlayerIdList,    %% todo 订阅者暂时调整为场景内所有玩家
                    %% 通知其他玩家移除自己
                    api_scene:notice_player_leave(SubscribePlayerIdList, PlayerId),
                    %% 通知其他玩家加载自己
                    api_scene:notice_player_enter(SubscribePlayerIdList, ObjScenePlayer),
                    %% 通知自己同步场景
                    api_scene:notice_sync_scene(
                        PlayerId,
                        {[PlayerId], [], []},
                        {[PlayerId], [], []}
                    )
            end;
        true ->
            %% 取消订阅格子列表
            FSubscribeGridIdList = get_player_subscribe_grid_id_list(SubscribeList, FGridId),
            cancel_subscribe_grid(PlayerId, FSubscribeGridIdList),

            %% 订阅格子列表
            TSubscribeGridIdList = get_player_subscribe_grid_id_list(SubscribeList, TGridId),
            subscribe_grid(PlayerId, TSubscribeGridIdList),

            FSceneGrid = ?GET_SCENE_GRID(FGridId),
            ?ASSERT(FSceneGrid =/= ?UNDEFINED, ?ERROR_UNKNOWN_GRID),
            #dict_scene_grid{
                player_list = FPlayerList,
                subscribe_player_id_list = _FSubscribeList
            } = FSceneGrid,
            FSubscribeList = ObjSceneAllPlayerIdList,

            TSceneGrid = ?GET_SCENE_GRID(TGridId),
            ?ASSERT(TSceneGrid =/= ?UNDEFINED, ?ERROR_UNKNOWN_GRID),
            #dict_scene_grid{
                subscribe_player_id_list = _TSubscribeList,
                player_list = TPlayerList
            } = TSceneGrid,
            TSubscribeList = ObjSceneAllPlayerIdList,
            ?ASSERT(lists:member(PlayerId, TPlayerList) == false, ?ERROR_ALREADY_IN_THIS_GRID),

            %% 从旧格子移除
            NewFSceneGrid = FSceneGrid#dict_scene_grid{player_list = lists:delete(PlayerId, FPlayerList)},
            ?UPDATE_SCENE_GRID(NewFSceneGrid),

            LeaveGridList = FSubscribeGridIdList -- TSubscribeGridIdList,
            EnterGridList = TSubscribeGridIdList -- FSubscribeGridIdList,
            {_LeavePlayerIdList, LeaveObjMonsterIdList, LeaveSceneItemIdList, _LeaveSceneTrapIdList} = get_grid_list_info(LeaveGridList),
            {_EnterPlayerIdList, EnterObjMonsterIdList, EnterSceneItemIdList, _EnterSceneTrapIdList} = get_grid_list_info(EnterGridList),
            LeavePlayerIdList = [],
            EnterPlayerIdList = [],

            %% 加入新格子
            NewTSceneGrid = TSceneGrid#dict_scene_grid{player_list = [PlayerId | TPlayerList]},
            ?UPDATE_SCENE_GRID(NewTSceneGrid),

            ?t_assert(lists:member(PlayerId, LeavePlayerIdList) == false),
            ?t_assert(lists:member(PlayerId, EnterPlayerIdList) == false),
            %% 刷新其他玩家的视野
            if Action == rebirth orelse Action == transmit ->
                %% 通知其他玩家移除自己
                api_scene:notice_player_leave(FSubscribeList, PlayerId),
                %% 通知其他玩家加载自己
                api_scene:notice_player_enter(TSubscribeList, ObjScenePlayer);
                true ->
                    %% 通知其他玩家移除自己
                    api_scene:notice_player_leave(FSubscribeList -- TSubscribeList, PlayerId),
                    %% 通知其他玩家加载自己
                    api_scene:notice_player_enter(TSubscribeList -- FSubscribeList, ObjScenePlayer)
            end,

            %% 刷新自己的视野
            if Action == rebirth orelse Action == transmit ->
                %% 通知自己同步场景
                api_scene:notice_sync_scene(
                    PlayerId,
                    {[PlayerId] ++ LeavePlayerIdList, LeaveObjMonsterIdList, LeaveSceneItemIdList},
                    {[PlayerId] ++ EnterPlayerIdList, EnterObjMonsterIdList, EnterSceneItemIdList}
                );
                true ->
                    put(error_leave_monster_log_, {TGridId, SubscribeList, TSubscribeGridIdList, EnterObjMonsterIdList}),
                    api_scene:notice_sync_scene(
                        PlayerId,
                        {LeavePlayerIdList, LeaveObjMonsterIdList, LeaveSceneItemIdList},
                        {EnterPlayerIdList, EnterObjMonsterIdList, EnterSceneItemIdList}
                    )
            end
    end.


%% ----------------------------------
%% @doc 	怪物进入格子
%% @throws 	none
%% @end
%% ----------------------------------
handle_monster_enter_grid(ObjSceneMonster, IsNotice) ->
    #obj_scene_actor{
        obj_id = ObjSceneMonsterId,
        grid_id = GridId,
        is_all_sync = IsAllSync
    } = ObjSceneMonster,
    case ?GET_SCENE_GRID(GridId) of
        ?UNDEFINED ->
            exit(?ERROR_UNKNOWN_GRID);
        #dict_scene_grid{monster_list = MonsterList, subscribe_player_id_list = SubscribePlayerIdList} = SceneGrid ->
            case lists:member(ObjSceneMonsterId, MonsterList) of
                true ->
                    exit(?ERROR_ALREADY_IN_THIS_GRID);
                false ->
                    ?IF(IsAllSync, noop, ?UPDATE_SCENE_GRID(SceneGrid#dict_scene_grid{monster_list = [ObjSceneMonsterId | MonsterList]})),  %% 需要全场景同步的怪不进入格子
                    ok
            end,
            NoticePlayerIdList =
                case IsAllSync of
                    true ->
                        %% 场景内所有玩家
                        [Player || Player <- mod_scene_player_manager:get_all_obj_scene_player_id(), Player >= 10000];
                    false ->
                        SubscribePlayerIdList
                end,
            case IsNotice of
                false ->
                    skip;
                true ->
                    api_scene:notice_monster_enter(NoticePlayerIdList, [ObjSceneMonster])
            end,
            NoticePlayerIdList
    end.

%% ----------------------------------
%% @doc 	怪物离开格子
%% @throws 	none
%% @end
%% ----------------------------------
handle_monster_leave_grid(ObjSceneMonster, Type) ->
    #obj_scene_actor{
        obj_id = ObjSceneMonsterId,
        grid_id = GridId,
        x = X,
        y = Y,
        is_all_sync = IsAllSync
    } = ObjSceneMonster,
    case ?GET_SCENE_GRID(GridId) of
        ?UNDEFINED ->
            exit(?ERROR_UNKNOWN_GRID);
        #dict_scene_grid{monster_list = MonsterList, subscribe_player_id_list = SubscribePlayerIdList} = R ->
            case lists:member(ObjSceneMonsterId, MonsterList) orelse IsAllSync of
                false ->
                    exit({?ERROR_NOT_IN_THIS_GRID, GridId, {X, Y}, ObjSceneMonster});
                true ->
                    ?IF(IsAllSync, noop, ?UPDATE_SCENE_GRID(R#dict_scene_grid{monster_list = lists:delete(ObjSceneMonsterId, MonsterList)})),
                    case Type of
                        death ->
                            noop;
                        _ ->
                            api_scene:notice_monster_leave(
                                ?IF(IsAllSync, mod_scene_player_manager:get_all_obj_scene_player_id(), SubscribePlayerIdList),
                                ObjSceneMonsterId
                            )
                    end
            end
    end.

%% ----------------------------------
%% @doc 	怪物格子改变
%% @throws 	none
%% @end
%% ----------------------------------
handle_monster_grid_change(ObjSceneMonster, FGridId, TGridId) ->
    #obj_scene_actor{
        obj_id = ObjSceneMonsterId,
        is_all_sync = IsAllSync
    } = ObjSceneMonster,
    if
        FGridId == TGridId orelse IsAllSync ->
            noop;
        true ->
            FSceneGrid = ?GET_SCENE_GRID(FGridId),
            ?ASSERT(FSceneGrid =/= ?UNDEFINED, ?ERROR_UNKNOWN_GRID),
            #dict_scene_grid{
                monster_list = FMonsterList,
                subscribe_player_id_list = FSubscribePlayerIdList
            } = FSceneGrid,

            TSceneGrid = ?GET_SCENE_GRID(TGridId),
            ?ASSERT(TSceneGrid =/= ?UNDEFINED, ?ERROR_UNKNOWN_GRID),
            #dict_scene_grid{
                monster_list = TMonsterList,
                subscribe_player_id_list = TSubscribePlayerIdList
            } = TSceneGrid,

            ?t_assert(lists:member(ObjSceneMonsterId, FMonsterList) == true, not_in_from_grid),
            ?UPDATE_SCENE_GRID(FSceneGrid#dict_scene_grid{monster_list = lists:delete(ObjSceneMonsterId, FMonsterList)}),

            ?t_assert(lists:member(ObjSceneMonsterId, TMonsterList) == false, ?ERROR_ALREADY_IN_THIS_GRID),
            ?UPDATE_SCENE_GRID(TSceneGrid#dict_scene_grid{monster_list = [ObjSceneMonsterId | TMonsterList]}),

            {A, _B, C} = split_list(FSubscribePlayerIdList, TSubscribePlayerIdList),
            api_scene:notice_monster_leave(A, ObjSceneMonsterId),
            api_scene:notice_monster_enter(C, [ObjSceneMonster])
    end.


%% ----------------------------------
%% @doc 	物品进入格子
%% @throws 	none
%% @end
%% ----------------------------------
handle_item_enter_grid(ObjSceneItem, IsNoticeEnter) ->
    #obj_scene_item{id = ObjSceneItemId, x = X, y = Y, type = Type, own_player_id = OwnPlayerId} = ObjSceneItem,
    GridId = ?PIX_2_GRID_ID(X, Y),
    SceneGrid = ?GET_SCENE_GRID(GridId),
    ?ASSERT(SceneGrid =/= ?UNDEFINED, ?ERROR_UNKNOWN_GRID),
    #dict_scene_grid{item_list = ItemList, subscribe_player_id_list = SubscribePlayerIdList} = SceneGrid,
    ?t_assert(lists:member({Type, ObjSceneItemId}, ItemList) == false, ?ERROR_ALREADY_IN_THIS_GRID),
    ?UPDATE_SCENE_GRID(SceneGrid#dict_scene_grid{item_list = [{Type, ObjSceneItemId} | ItemList]}),
    if IsNoticeEnter ->
        if OwnPlayerId > 0 ->
            case lists:member(OwnPlayerId, SubscribePlayerIdList) of
                true ->
                    api_scene:notice_item_enter([OwnPlayerId], [ObjSceneItem]);
                false ->
                    noop
            end;
            true ->
                api_scene:notice_item_enter(SubscribePlayerIdList, [ObjSceneItem])
        end;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc     物品离开格子
%% @throws 	none
%% @end
%% ----------------------------------
handle_item_leave_grid(ObjSceneItem, IsNoticeLeave) ->
    #obj_scene_item{
        id = ObjSceneItemId,
        x = X, y = Y,
        type = Type
    } = ObjSceneItem,
    GridId = ?PIX_2_GRID_ID(X, Y),
    SceneGrid = ?GET_SCENE_GRID(GridId),
    ?ASSERT(SceneGrid =/= ?UNDEFINED, ?ERROR_UNKNOWN_GRID),
    #dict_scene_grid{item_list = ItemList, subscribe_player_id_list = SubscribePlayerIdList} = SceneGrid,
    ?t_assert(lists:member({Type, ObjSceneItemId}, ItemList) == true),
    ?UPDATE_SCENE_GRID(SceneGrid#dict_scene_grid{item_list = lists:delete({Type, ObjSceneItemId}, ItemList)}),
    if IsNoticeLeave ->
        api_scene:notice_item_leave(SubscribePlayerIdList, Type, [ObjSceneItemId]);
        true ->
            SubscribePlayerIdList
    end.
