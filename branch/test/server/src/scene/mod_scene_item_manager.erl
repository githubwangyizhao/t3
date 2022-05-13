%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            场景物品
%%% @end
%%% Created : 30. 十一月 2017 下午 4:54
%%%-------------------------------------------------------------------
-module(mod_scene_item_manager).
-include("scene.hrl").
-include("common.hrl").
-include("msg.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("p_enum.hrl").
-include("system.hrl").
-include("error.hrl").
%% API
-export([
    player_drop_item_list/2,
    place_list/1
]).

-export([
    get_obj_scene_item/1,
    handle_player_drop_item_list/2,
    drop_item_list/5,
    handle_remove_obj_scene_item_list/1
]).

-export([
    player_collect/2,
    handle_player_collect/3
]).

%% ----------------------------------
%% @doc 	移除物品
%% @throws 	none
%% @end
%% ----------------------------------
handle_remove_obj_scene_item_list(ObjSceneItemIdList) ->
%%    ?DEBUG("移除物品:~p", [ObjSceneItemIdList]),
    lists:foreach(
        fun(ObjSceneItemId) ->
            case get_obj_scene_item(ObjSceneItemId) of
                ?UNDEFINED ->
                    noop;
                ObjSceneItem ->
                    handle_remove_obj_scene_item(ObjSceneItem, true, true)
            end
        end,
        ObjSceneItemIdList
    ).

%% ----------------------------------
%% @doc 	玩家采集
%% @throws 	none
%% @end
%% ----------------------------------
player_collect(PlayerId, ObjSceneItemIdList) ->
%%    ?DEBUG("采集:~p", [ObjSceneItemIdList]),
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    if SceneWorker == null ->
        noop;
        true ->
            SceneWorker ! {?MSG_SCENE_PLAYER_COLLECT, PlayerId, ObjSceneItemIdList}
    end.

handle_player_collect(PlayerId, ObjSceneItemIdList, #scene_state{is_hook_scene = IsHookScene}) ->
    ObjScenePlayer = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    #obj_scene_actor{
        client_worker = ClientWorker,
        collect_obj_scene_item_id = CollectObjSceneItemId,
        hp = Hp
    } = ObjScenePlayer,
    ?ASSERT(Hp > 0, ?ERROR_ALREADY_DIE),
    IsCanGetBlessCoin =
            case mod_scene_event_manager:get_scene_event_value() of
                ?UNDEFINED ->
                    false;
                {IsOpen, {SceneEventType, _, _}} ->
                    %% 神龙开启的时候才可以真正获得
                    IsOpen andalso SceneEventType =:= 16
            end,
%%    ?DEBUG("handle_player_collect:~p", [{PlayerId, ObjSceneItemIdList}]),
    {AwardList, MergeNoticeRemoveItemList} =
        lists:foldl(
            fun(ObjSceneItemId, {TmpAwardList, TmpMergeNoticeRemoveItemList}) ->
                case get_obj_scene_item(ObjSceneItemId) of
                    ?UNDEFINED ->
                        {TmpAwardList, TmpMergeNoticeRemoveItemList};
                    ObjSceneItem ->
                        #obj_scene_item{
                            base_id = BaseId,
                            num = Num,
                            type = Type,
                            own_player_id = OwnPlayerId
                        } = ObjSceneItem,

                        if
                            BaseId =:= ?ITEM_BLESS_COIN andalso not IsCanGetBlessCoin ->
                                handle_remove_obj_scene_item(ObjSceneItem, true),
                                {TmpAwardList, [ObjSceneItemId | TmpMergeNoticeRemoveItemList]};
                            Type == ?SCENE_ITEM_TYPE_ITEM ->
                                %% 物品
                                if OwnPlayerId > 0 ->
                                    handle_remove_obj_scene_item(ObjSceneItem, false),
                                    {[{BaseId, Num} | TmpAwardList], [ObjSceneItemId | TmpMergeNoticeRemoveItemList]};
                                    true ->
                                        handle_remove_obj_scene_item(ObjSceneItem, true),
                                        {[{BaseId, Num} | TmpAwardList], TmpMergeNoticeRemoveItemList}
                                end;
                            true ->
%%                                %% 采集物
%%                                #t_collect{
%%                                    award_id = AwardId,
%%                                    is_task = IsTask,
%%                                    is_gather_disappear = IsGatherDisappear,
%%                                    is_can_many_people_gather = IsCanTogetherCollect
%%                                } = t_collect:get({BaseId}),
%%
%%                                if IsCanTogetherCollect == ?FALSE ->
%%                                    %% 不可同时采， 校验归属玩家是否是自己
%%                                    ?ASSERT(OwnPlayerId == 0 orelse OwnPlayerId == PlayerId, not_owner_player);
%%                                    true ->
%%                                        noop
%%                                end,
%%                                if IsTask == ?TRUE ->
%%                                    %% 通知玩家进程更新任务
%%                                    client_worker:send_msg(ClientWorker, {?MSG_CLIENT_COLLECT, BaseId, SceneId});
%%                                    true ->
%%                                        noop
%%                                end,
%%                                if IsGatherDisappear == ?TRUE ->
%%                                    %% 采集后自动消失
%%                                    handle_remove_obj_scene_item(ObjSceneItem, true);
%%                                    true ->
%%                                        noop
%%                                end,
%%%%                                ?DEBUG("采集物品奖励:~p~n", [mod_award:decode_award(AwardId)]),
%%                                {mod_award:decode_award(AwardId) ++ TmpAwardList, TmpMergeNoticeRemoveItemList}
                                {TmpAwardList, TmpMergeNoticeRemoveItemList}
                        end
                end
            end,
            {[], []},
            ObjSceneItemIdList
        ),
%%    ?DEBUG("award:~p", [{AwardList, MergeNoticeRemoveItemList}]),
    if AwardList =/= [] ->
        if IsHookScene == true ->
            %% 挂机场景， 背包已满， 则只给资源
            client_worker:apply(ClientWorker, mod_award, give_ignore, [PlayerId, AwardList, ?LOG_TYPE_GATHER_GET]);
            true ->
                client_worker:apply(ClientWorker, mod_award, give, [PlayerId, AwardList, ?LOG_TYPE_GATHER_GET])
        end;
        true ->
            noop
    end,
    if MergeNoticeRemoveItemList =/= [] ->
%%        api_scene:notice_item_leave([PlayerId], 0, MergeNoticeRemoveItemList);
        %% @todo 特殊处理，全场景同步
        api_scene:notice_item_leave(mod_scene_player_manager:get_all_obj_scene_player_id(), 0, MergeNoticeRemoveItemList);
        true ->
            noop
    end,
    if CollectObjSceneItemId > 0 ->
        ?UPDATE_OBJ_SCENE_PLAYER(ObjScenePlayer#obj_scene_actor{
            collect_obj_scene_item_id = 0
        });
        true ->
            noop
    end.

handle_remove_obj_scene_item(ObjSceneItem, IsNoticeLeave) ->
    handle_remove_obj_scene_item(ObjSceneItem, IsNoticeLeave, false).
handle_remove_obj_scene_item(ObjSceneItem, IsNoticeLeave, IsCheck) ->
    #obj_scene_item{
        base_id = PropId,
        num = Num,
        type = Type,
        id = ObjSceneItemId,
        own_player_id = OwnPlayerId
    } = ObjSceneItem,
    delete_obj_scene_item(ObjSceneItemId),
    if IsCheck ->
        if OwnPlayerId > 0 andalso Type == ?SCENE_ITEM_TYPE_ITEM ->
            SceneId = get(?DICT_SCENE_ID),
            SceneServerType = mod_scene:get_scene_server_type(SceneId),
            if SceneServerType == ?SERVER_TYPE_GAME ->
                ?TRY_CATCH(mod_apply:apply_to_online_player(OwnPlayerId, mod_award, give, [OwnPlayerId, [{PropId, Num}], ?LOG_TYPE_GATHER_GET], store));
                true ->
                    try
                        case ?GET_OBJ_SCENE_PLAYER(OwnPlayerId) of
                            ?UNDEFINED ->
                                ?WARNING("掉落物未被领取:~p", [{SceneId, ObjSceneItem}]);
                            ObjScenePlayer ->
                                ?TRY_CATCH(mod_apply:apply_to_online_player(ObjScenePlayer#obj_scene_actor.client_node, OwnPlayerId, mod_award, give, [OwnPlayerId, [{PropId, Num}], ?LOG_TYPE_GATHER_GET], store))
                        end
                    catch
                        _:Reason ->
                            ?WARNING("掉落物未被领取2:~p", [{SceneId, ObjSceneItem, Reason}])
                    end
            end;
            true ->
                noop
        end;
        true ->
            noop
    end,
    mod_scene_grid_manager:handle_item_leave_grid(ObjSceneItem, IsNoticeLeave).

%% ----------------------------------
%% @doc 	掉落物品
%% @throws 	none
%% @end
%% ----------------------------------
player_drop_item_list(PlayerId, PropList) ->
    ?DEBUG("掉落物品:~p~n", [{PropList}]),
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    SceneWorker ! {?MSG_SCENE_PLAYER_DROP_ITEM_LIST, PlayerId, PropList}.

handle_player_drop_item_list(PlayerId, PropList) ->
    #obj_scene_actor{
        x = X,
        y = Y
    } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    drop_item_list(0, PlayerId, PropList, X, Y).

place_list(Num) ->
%%    ?DEBUG("get_subscribe_grid_id_list_by_px:~p~n", [{W, H}]),
    N = max(0, erlang:ceil(math:sqrt(Num)) - 1),
    NN = N div 2,
    lists:foldl(
        fun(X, Tmp) ->
            lists:foldl(
                fun(Y, Tmp2) ->
                    [{X, Y} | Tmp2]
                end,
                Tmp,
                [E - NN || E <- lists:seq(0, N)]
            )
        end,
        [],
        [E - NN || E <- lists:seq(0, N)]
    ).

%% @fun 转换成元组
tran_prop({PropId, Num}, OwnerPlayerId) ->
    {PropId, Num, OwnerPlayerId};
tran_prop([PropId, Num], OwnerPlayerId) ->
    {PropId, Num, OwnerPlayerId};
tran_prop({PropId, Num, OwnerPlayerId}, _) ->
    {PropId, Num, OwnerPlayerId};
tran_prop([PropId, Num, OwnerPlayerId], _) ->
    {PropId, Num, OwnerPlayerId};
tran_prop(Other, _) ->
    ?ERROR("转换prop 失败:~p", [Other]),
    exit(tran_prop_error).

%% ----------------------------------
%% @doc 	掉落物品
%% @throws 	none
%% @end
%% ----------------------------------
drop_item_list(_ObjSceneMonsterId, _PlayerId, [], _X, _Y) ->
    noop;
drop_item_list(ObjSceneMonsterId, PlayerId, PropList, X, Y) ->
    PropNum = erlang:length(PropList),
    {IsOpen, {SceneEventType, _, _}} =
        case mod_scene_event_manager:get_scene_event_value() of
            ?UNDEFINED ->
                {false, {0, 0, 0}};
            EventValue ->
                EventValue
        end,
    {_, DelayRemoveItemList, NoticeItemEnterList} =
        lists:foldl(
            fun(Prop, {[{PX, PY} | PlaceList], TmpDelayRemoveItemList, TmpNoticeItemEnterList}) ->
                {PropId, Num, OwnerPlayerId} = tran_prop(Prop, PlayerId),
                case mod_player:is_robot_player_id(OwnerPlayerId) of
                    true ->
                        %% 归属玩家是机器人则 不掉落物品
                        {PlaceList, TmpDelayRemoveItemList, TmpNoticeItemEnterList};
                    false ->
                        if
                            PropId =/= ?ITEM_BLESS_COIN orelse (SceneEventType == 16 andalso IsOpen) ->
                                {RandomX, RandomY} = {X + PX * 80, Y + PY * 80},
                                {RealX, RealY} =
                                    case ?GET_SCENE_GRID(?PIX_2_GRID_ID(RandomX, RandomY)) of
                                        ?UNDEFINED ->
                                            {X, Y};
                                        _ ->
                                            {RandomX, RandomY}
                                    end,
                                ObjSceneItemId = get_obj_scene_item_id(),
                                ObjSceneItem =
                                    #obj_scene_item{
                                        id = ObjSceneItemId,
                                        type = ?SCENE_ITEM_TYPE_ITEM,
                                        base_id = PropId,
                                        num = Num,
                                        x = RealX,
                                        y = RealY,
                                        own_player_id = OwnerPlayerId,
                                        drop_obj_scene_monster_id = ObjSceneMonsterId
                                    },
                                update_obj_scene_item(ObjSceneItem),
                                mod_scene_grid_manager:handle_item_enter_grid(ObjSceneItem, false),

                                {
                                    PlaceList,
                                    [ObjSceneItemId | TmpDelayRemoveItemList],
                                    case lists:keytake(OwnerPlayerId, 1, TmpNoticeItemEnterList) of
                                        {value, {OwnerPlayerId, OwnerItemList}, L2} ->
                                            [{OwnerPlayerId, [ObjSceneItem | OwnerItemList]} | L2];
                                        _ ->
                                            [{OwnerPlayerId, [ObjSceneItem]} | TmpNoticeItemEnterList]
                                    end
                                };
                            true ->
                                %% 不是神龙祈福状态并且给的是神龙祝福币就不给了
                                {PlaceList, TmpDelayRemoveItemList, TmpNoticeItemEnterList}
                        end
                end
            end,
            {place_list(PropNum), [], []},
            PropList
        ),
    if DelayRemoveItemList =/= [] ->
        RemoveTime = ?MINUTE_MS,
        erlang:send_after(RemoveTime, self(), {?MSG_SCENE_REMOVE_SCENE_ITEM_LIST, DelayRemoveItemList});
        true ->
            noop
    end,
    if NoticeItemEnterList =/= [] ->
        lists:foreach(
            fun({_ThisOwnerPlayerId, ThisObjSceneItemList}) ->
%%                api_scene:notice_item_enter([ThisOwnerPlayerId], ThisObjSceneItemList)
                %% @todo 特殊处理，全场景同步
                api_scene:notice_item_enter(mod_scene_player_manager:get_all_obj_scene_player_id(), ThisObjSceneItemList)
            end,
            NoticeItemEnterList
        );
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	更新场景物品对象
%% @throws 	none
%% @end
%% ----------------------------------
update_obj_scene_item(ObjSceneItem) ->
    put({?DICT_OBJ_SCENE_ITEM, ObjSceneItem#obj_scene_item.id}, ObjSceneItem).

%% ----------------------------------
%% @doc 	删除场景物品对象
%% @throws 	none
%% @end
%% ----------------------------------
delete_obj_scene_item(ObjSceneItemId) ->
    erase({?DICT_OBJ_SCENE_ITEM, ObjSceneItemId}).

get_obj_scene_item(ObjSceneItemId) ->
    get({?DICT_OBJ_SCENE_ITEM, ObjSceneItemId}).

%% ----------------------------------
%% @doc 	获取场景物品唯一id
%% @throws 	none
%% @end
%% ----------------------------------
get_obj_scene_item_id() ->
    ObjSceneItemId = get(?DICT_OBJ_SCENE_ITEM_ID),
    if ObjSceneItemId > 100000000 ->
        put(?DICT_OBJ_SCENE_ITEM_ID, 1);
        true ->
            put(?DICT_OBJ_SCENE_ITEM_ID, ObjSceneItemId + 1)
    end,
    ObjSceneItemId.
