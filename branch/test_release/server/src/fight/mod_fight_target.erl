%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            战斗目标模块
%%% @end
%%% Created : 11. 八月 2016 下午 4:19
%%%-------------------------------------------------------------------
-module(mod_fight_target).
-include("scene.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
%% API
-export([
    get_nine_grid_attack_target_list/5,         %% 获取九宫格攻击对象列表
    get_nine_grid_attack_monster_target_list/5,
    get_nine_grid_attack_monster_target_list/6,
    get_nine_grid_attack_player_target_list/5,
    get_attack_target_list/6
]).


%% ----------------------------------
%% @doc     获取九宫格攻击怪物对象列表 距离排序
%% @throws 	none
%% @end
%% ----------------------------------
get_nine_grid_attack_monster_target_list(GridId, X, Y, F, DisLimit, TargetNum) ->
    NineGridList = mod_scene_grid_manager:nine_grid(GridId),
    MonsterIdList =
        lists:foldl(
            fun(GridId1, TempMonsterIdList) ->
                case ?GET_SCENE_GRID(GridId1) of
                    ?UNDEFINED ->
                        TempMonsterIdList;
                    R ->
                        if R#dict_scene_grid.monster_list == [] ->
                            TempMonsterIdList;
                            true ->
                                R#dict_scene_grid.monster_list ++ TempMonsterIdList
                        end

                end
            end,
            [],
            NineGridList
        ),
    %% 九宫格内全场景同步的怪物列表
    NineGridAllSceneSyncMonsterList =
        lists:foldl(
            fun(MonsterObjId, TmpList) ->
                #obj_scene_actor{
                    x = MonsterX,
                    y = MonsterY,
                    is_all_sync = IsAllSync
                } = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
                if
                    IsAllSync ->
                        MonsterGridId = ?PIX_2_GRID_ID(MonsterX, MonsterY),
                        ?IF(lists:member(MonsterGridId, NineGridList), [MonsterObjId | TmpList], TmpList);
                    true ->
                        TmpList
                end
            end,
            [], mod_scene_monster_manager:get_all_obj_scene_monster_id()),
%%    ?DEBUG("功能怪受击列表 ~p", [NineGridAllSceneSyncMonsterList]),
    get_attack_target_list(MonsterIdList ++ NineGridAllSceneSyncMonsterList, [], X, Y, F, DisLimit, TargetNum).

get_attack_target_list(MonsterIdList, PlayerIdList, SourceX, SourceY, FilterFun, DisLimit, TargetNum) ->
    F1 = fun(ObjType, ObjIdList) ->
        lists:sublist(lists:sort(lists:foldl(
            fun(ObjId, Tmp) ->
                case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
                    ?UNDEFINED ->
                        Tmp;
                    ObjSceneActor ->
                        #obj_scene_actor{
                            obj_type = ObjType,
                            obj_id = ObjId,
                            hp = Hp,
                            x = X,
                            y = Y,
                            level = Level,
                            is_robot = IsRobot,
                            owner_obj_type = OwnerObjType,
                            owner_obj_id = OwnerPlayerId,
                            effect = EffectList,
                            kind = Kind,
                            is_cannot_be_attack = IsCannotBeAttack
                        } = ObjSceneActor,
                        Effect =
                            case EffectList of
                                [] ->
                                    0;
                                [ThisEffect] ->
                                    ThisEffect;
                                [ThisEffect, _] ->
                                    ThisEffect;
                                _ ->
                                    0
                            end,
                        #t_monster_kind{
                            can_be_immediate_death = CanBeImmediateDeath
                        } = mod_scene_monster_manager:get_t_monster_kind(Kind),
                        FilterTarget = #filter_target{
                            this_obj_type = ObjType,
                            this_obj_id = ObjId,
                            this_own_type = OwnerObjType,
                            this_own_id = OwnerPlayerId,
                            level = Level,
                            is_robot = IsRobot,
                            effect = Effect,
                            can_be_immediate_death = CanBeImmediateDeath
                        },
                        case Hp > 0 andalso FilterFun(FilterTarget) andalso IsCannotBeAttack == false of
                            true ->
                                Dis = util_math:get_distance({X, Y}, {SourceX, SourceY}),
                                if DisLimit == 0 orelse Dis =< DisLimit ->
                                    [{Dis, ObjSceneActor} | Tmp];
                                    true ->
                                        Tmp
                                end;
                            false ->
                                Tmp
                        end
                end
            end,
            [],
            ObjIdList
        )), TargetNum)
         end,
    MonsterList1 = F1(?OBJ_TYPE_MONSTER, MonsterIdList),
    PlayerList1 = F1(?OBJ_TYPE_PLAYER, PlayerIdList),
    if PlayerList1 == [] andalso MonsterList1 == [] ->
        [];
        PlayerList1 == [] ->
            [Obj || {_, Obj} <- lists:sort(MonsterList1)];
        MonsterList1 == [] ->
            [Obj || {_, Obj} <- lists:sort(PlayerList1)];
        true ->
            L2 = lists:sort(PlayerList1) ++ lists:sort(MonsterList1),
            [Obj || {_, Obj} <- L2]
    end.

%% ----------------------------------
%% @doc     获取九宫格攻击对象列表 距离排序
%% @throws 	none
%% @end
%% ----------------------------------
get_nine_grid_attack_player_target_list(GridId, X, Y, F, DisLimit) ->
    PlayerIdList =
        lists:foldl(
            fun(GridId1, TmpPlayerIdList) ->
                case ?GET_SCENE_GRID(GridId1) of
                    ?UNDEFINED ->
                        TmpPlayerIdList;
                    R ->
                        if R#dict_scene_grid.player_list == [] ->
                            TmpPlayerIdList;
                            true ->
                                R#dict_scene_grid.player_list ++ TmpPlayerIdList
                        end
                end
            end,
            [],
            mod_scene_grid_manager:nine_grid(GridId)
        ),
    get_attack_target_list([], PlayerIdList, X, Y, F, DisLimit).

%% ----------------------------------
%% @doc     获取九宫格攻击怪物对象列表 距离排序
%% @throws 	none
%% @end
%% ----------------------------------
get_nine_grid_attack_monster_target_list(GridId, X, Y, F, DisLimit) ->
    NineGridList = mod_scene_grid_manager:nine_grid(GridId),
    MonsterIdList =
        lists:foldl(
            fun(GridId1, TempMonsterIdList) ->
                case ?GET_SCENE_GRID(GridId1) of
                    ?UNDEFINED ->
                        TempMonsterIdList;
                    R ->
                        if R#dict_scene_grid.monster_list == [] ->
                            TempMonsterIdList;
                            true ->
                                R#dict_scene_grid.monster_list ++ TempMonsterIdList
                        end

                end
            end,
            [],
            NineGridList
        ),
    %% 九宫格内全场景同步的怪物列表
    NineGridAllSceneSyncMonsterList =
        lists:foldl(
            fun(MonsterObjId, TmpList) ->
                #obj_scene_actor{
                    x = MonsterX,
                    y = MonsterY,
                    is_all_sync = IsAllSync
                } = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
                if
                    IsAllSync ->
                        MonsterGridId = ?PIX_2_GRID_ID(MonsterX, MonsterY),
                        ?IF(lists:member(MonsterGridId, NineGridList), [MonsterObjId | TmpList], TmpList);
                    true ->
                        TmpList
                end
            end,
            [], mod_scene_monster_manager:get_all_obj_scene_monster_id()),
%%    ?DEBUG("功能怪受击列表 ~p", [NineGridAllSceneSyncMonsterList]),
    get_attack_target_list(MonsterIdList ++ NineGridAllSceneSyncMonsterList, [], X, Y, F, DisLimit).

%% ----------------------------------
%% @doc     获取九宫格攻击对象列表 距离排序
%% @throws 	none
%% @end
%% ----------------------------------
get_nine_grid_attack_target_list(GridId, X, Y, F, DisLimit) ->
    {MonsterIdList, PlayerIdList} =
        lists:foldl(
            fun(GridId1, {TempMonsterIdList, TmpPlayerIdList}) ->
                case ?GET_SCENE_GRID(GridId1) of
                    ?UNDEFINED ->
                        {TempMonsterIdList, TmpPlayerIdList};
                    R ->
                        {
                            if R#dict_scene_grid.monster_list == [] ->
                                TempMonsterIdList;
                                true ->
                                    R#dict_scene_grid.monster_list ++ TempMonsterIdList
                            end,
                            if R#dict_scene_grid.player_list == [] ->
                                TmpPlayerIdList;
                                true ->
                                    R#dict_scene_grid.player_list ++ TmpPlayerIdList
                            end
                        }
                end
            end,
            {[], []},
            mod_scene_grid_manager:nine_grid(GridId)
        ),
    get_attack_target_list(MonsterIdList, PlayerIdList, X, Y, F, DisLimit).

get_attack_target_list(MonsterIdList, PlayerIdList, SourceX, SourceY, FilterFun, DisLimit) ->
    F1 = fun(ObjType, ObjIdList) ->
        lists:foldl(
            fun(ObjId, Tmp) ->
                case ?GET_OBJ_SCENE_ACTOR(ObjType, ObjId) of
                    ?UNDEFINED ->
                        Tmp;
                    ObjSceneActor ->
                        #obj_scene_actor{
                            obj_type = ObjType,
                            obj_id = ObjId,
                            hp = Hp,
                            x = X,
                            y = Y,
                            level = Level,
                            is_robot = IsRobot,
                            owner_obj_type = OwnerObjType,
                            owner_obj_id = OwnerPlayerId,
                            effect = EffectList,
                            kind = Kind,
                            is_cannot_be_attack = IsCannotBeAttack
                        } = ObjSceneActor,
                        Effect = mod_scene_monster_manager:get_monster_effect(EffectList),
                        #t_monster_kind{
                            can_be_immediate_death = CanBeImmediateDeath
                        } = mod_scene_monster_manager:get_t_monster_kind(Kind),
                        FilterTarget = #filter_target{
                            this_obj_type = ObjType,
                            this_obj_id = ObjId,
                            this_own_type = OwnerObjType,
                            this_own_id = OwnerPlayerId,
                            level = Level,
                            is_robot = IsRobot,
                            effect = Effect,
                            can_be_immediate_death = CanBeImmediateDeath
                        },
                        case Hp > 0 andalso FilterFun(FilterTarget) andalso IsCannotBeAttack == false of
                            true ->
                                Dis = util_math:get_distance({X, Y}, {SourceX, SourceY}),
                                if DisLimit == 0 orelse Dis =< DisLimit ->
                                    [{Dis, ObjSceneActor} | Tmp];
                                    true ->
                                        Tmp
                                end;
                            false ->
                                Tmp
                        end
                end
            end,
            [],
            ObjIdList
        )
         end,
    MonsterList1 = F1(?OBJ_TYPE_MONSTER, MonsterIdList),
    PlayerList1 = F1(?OBJ_TYPE_PLAYER, PlayerIdList),
    if PlayerList1 == [] andalso MonsterList1 == [] ->
        [];
        PlayerList1 == [] ->
            [Obj || {_, Obj} <- lists:sort(MonsterList1)];
        MonsterList1 == [] ->
            [Obj || {_, Obj} <- lists:sort(PlayerList1)];
        true ->
            L2 = lists:sort(PlayerList1) ++ lists:sort(MonsterList1),
            [Obj || {_, Obj} <- L2]
    end.
