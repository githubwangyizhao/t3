%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         场景boss副本
%%% @end
%%% Created : 22. 五月 2021 上午 11:09:17
%%%-------------------------------------------------------------------
-module(mod_mission_scene_boss).
-author("Administrator").

-include("mission.hrl").
-include("scene.hrl").
-include("gen/table_enum.hrl").
-include("scene_boss_pos.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
-include("one_on_one.hrl").
-include("server_data.hrl").

%% API
-export([
    scene_boss_bet/4,
    handle_scene_boss_bet/5,

    scene_boss_bet_reset/2,
    handle_scene_boss_bet_reset/2
]).

-export([
    handle_init_mission/1,
    handle_enter_mission/2,
    handle_leave_mission/1,
    handle_open_boss/1,
    handle_deal_cost/1,
    handle_balance/1,
    handle_boss_teleport/2,
    handle_terminate/1
]).

-define(BET_TYPE_POS, 0).
-define(BET_TYPE_DAO, 1).
-define(BET_TYPE_TIME, 2).

-define(SCENE_BOSS_ENTER_PLAYER_ID_LIST, scene_boss_enter_player_id_list).  %% 场景boss加入玩家列表
-define(SCENE_BOSS_DEAL_ATTACK_TIMES, scene_boss_deal_attack_times).        %% 场景刀数boss受到攻击的次数

-define(SCENE_BOSS_POS_BOSS_DIE_POS, scene_boss_pos_boss_die_pos).          %% 场景boss位置boss死亡位置
-define(SCENE_BOSS_DAO_BOSS_DIE_DAO, scene_boss_dao_boss_die_dao).          %% 场景boss刀数boss死亡刀数

%%-define(SCENE_BOSS_POS_STEP_BET).

%% @doc 场景boss 竞猜
scene_boss_bet(PlayerId, Type, Id, Num) ->
    case mod_prop:check_prop_num(PlayerId, ?ITEM_RMB, Num) andalso lists:member(Id, get_all_bet_id_list(Type)) of
        true ->
            case mod_mission:call(PlayerId, {?MSG_SCENE_BOSS_BET, PlayerId, Type, Id, Num}) of
                noop ->
                    noop;
                ok ->
                    Tran =
                        fun() ->
                            mod_prop:decrease_player_prop(PlayerId, [{?ITEM_RMB, Num}], ?LOG_TYPE_MISSION_SCENE_BOSS_LOCATION)
                        end,
                    db:do(Tran),
                    ok
            end;
        false ->
            noop
    end.
handle_scene_boss_bet(PlayerId, Type, Id, Num, #scene_state{mission_type = MissionType}) ->
    Fun =
        fun() ->
            PlayerBetValue = util:get_dict({?SCENE_BOSS_BET, Type, Id, PlayerId}, 0),
            BetValue = util:get_dict({?SCENE_BOSS_BET, Type, Id}, 0),
            NewPlayerBetValue = PlayerBetValue + Num,
            NewBetValue = BetValue + Num,
            put({?SCENE_BOSS_BET, Type, Id, PlayerId}, NewPlayerBetValue),
            put({?SCENE_BOSS_BET, Type, Id}, NewBetValue),
            notice_scene_boss_bet(mod_scene_player_manager:get_all_obj_scene_player_id(), [Id], Type),
            ok
        end,
    SceneBossStep = util:get_dict(?SCENE_BOSS_STEP),
    if
        MissionType =:= ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION andalso Type =:= ?BET_TYPE_POS andalso SceneBossStep == ?SCENE_BOSS_STEP_BET ->
            Fun();
        MissionType =:= ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT andalso (Type =:= ?BET_TYPE_DAO orelse Type =:= ?BET_TYPE_TIME) andalso SceneBossStep == ?SCENE_BOSS_STEP_BET ->
            Fun();
        MissionType =:= ?MISSION_TYPE_GUESS_BOSS andalso (Type =:= ?BET_TYPE_ONE_ON_ONE) ->
            Fun();
        true ->
            noop
    end.

get_all_bet_id_list(BetType) ->
    [Id || [Id, _, _] <- get_bet_list(BetType)].
get_bet_list(BetType) ->
    case BetType of
        ?BET_TYPE_POS ->
            ?SD_SCENE_BOSS_LOCATION_LIST;
        ?BET_TYPE_DAO ->
            ?SD_SCENE_BOSS_COUNT_LIST;
        _ ->
            []
    end.

%% @doc 场景boss位置竞猜重置
scene_boss_bet_reset(PlayerId, Type) ->
    mod_mission:send_msg(PlayerId, {?MSG_SCENE_BOSS_BET_RESET, PlayerId, Type}).
handle_scene_boss_bet_reset(PlayerId, Type) ->
    case util:get_dict(?SCENE_BOSS_STEP) of
        ?SCENE_BOSS_STEP_BET ->
            {NoticeIdList, AwardRmbValue} =
                lists:foldl(
                    fun(Id, {IdChangeList, TmpPlayerBetValue}) ->
                        PlayerBetValue = util:get_dict({?SCENE_BOSS_BET, Type, Id, PlayerId}, 0),
                        ?DEBUG("竞猜值 ~p", [{?SCENE_BOSS_BET, Type, Id, PlayerId, PlayerBetValue}]),
                        if
                            PlayerBetValue > 0 ->
                                BetValue = util:get_dict({?SCENE_BOSS_BET, Type, Id}, 0),
                                NewBetValue = BetValue - PlayerBetValue,
                                put({?SCENE_BOSS_BET, Type, Id, PlayerId}, 0),
                                put({?SCENE_BOSS_BET, Type, Id}, NewBetValue),
                                {[Id | IdChangeList], TmpPlayerBetValue + PlayerBetValue};
                            true ->
                                {IdChangeList, TmpPlayerBetValue}
                        end
                    end, {[], 0}, get_all_bet_id_list(Type)
                ),
            notice_scene_boss_bet(mod_scene_player_manager:get_all_obj_scene_player_id(), NoticeIdList, Type),
            ?IF(AwardRmbValue > 0, mod_apply:apply_to_online_player(PlayerId, mod_award, give, [PlayerId, [{?ITEM_RMB, AwardRmbValue}], ?LOG_TYPE_MISSION_SCENE_BOSS_LOCATION], game_worker), noop),
            ok;
        _ ->
            noop
    end.

%% @doc 通知场景boss位置竞猜
notice_scene_boss_bet([], _IdList, _Type) ->
    noop;
notice_scene_boss_bet(_PlayerIdList, [], _Type) ->
    noop;
notice_scene_boss_bet(PlayerIdList, IdList, Type) ->
    lists:foreach(
        fun(PlayerId) ->
            api_mission:notice_scene_boss_bet(PlayerId, [{Type, Id, util:get_dict({?SCENE_BOSS_BET, Type, Id, PlayerId}, 0), util:get_dict({?SCENE_BOSS_BET, Type, Id}, 0)} || Id <- IdList])
        end,
        PlayerIdList
    ).

%% @doc 处理消耗
handle_deal_cost(_DefObjId) ->
    Value = util:get_dict(?SCENE_BOSS_DEAL_ATTACK_TIMES, 0),
    NewValue = Value + 1,
    DieDao = get(?SCENE_BOSS_DAO_BOSS_DIE_DAO),
    put(?SCENE_BOSS_DEAL_ATTACK_TIMES, NewValue),
    if
        NewValue >= DieDao ->
            lists:foreach(
                fun(MonsterObjId) ->
                    ObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
                    #obj_scene_actor{
                        is_boss = IsBoss,
                        die_type = DieType
                    } = ObjSceneMonster,
                    if
                        IsBoss andalso DieType /= 2 ->
                            ?UPDATE_OBJ_SCENE_MONSTER(ObjSceneMonster#obj_scene_actor{die_type = 2});
                        true ->
                            noop
                    end
                end,
                mod_scene_monster_manager:get_all_obj_scene_monster_id()
            );
        true ->
            noop
    end,
    api_mission:notice_scene_boss_dao_num_change(mod_scene_player_manager:get_all_obj_scene_player_id(), NewValue).

%% @doc 初始化副本
handle_init_mission(ExtraDataList) ->
    lists:foreach(
        fun({Key, Value}) ->
            put(Key, Value)
        end,
        ExtraDataList
    ),
    put(?SCENE_BOSS_ENTER_PLAYER_ID_LIST, []),
    Now = util_time:milli_timestamp(),
    BossFightTime = get(?DICT_MISSION_SCENE_BOSS_WAIT_TIME),
    if
        Now >= BossFightTime ->
            put(?SCENE_BOSS_STEP, ?SCENE_BOSS_STEP_FIGHT),
            mod_mission:send_msg(?MSG_SCENE_BOSS_POS_OPEN_BOSS);
        true ->
            put(?SCENE_BOSS_STEP, ?SCENE_BOSS_STEP_BET),
            mod_mission:send_msg_delay(?MSG_SCENE_BOSS_POS_OPEN_BOSS, BossFightTime - Now)
    end.
%%    case get(?DICT_MISSION_TYPE) of
%%        ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION ->
%%            [Min, Max] = ?SD_SCENE_BOSS_LOCATION_CHANGE_TIME_LIST,
%%            mod_mission:send_msg_delay(?MSG_SCENE_BOSS_POS_BOSS_TELEPORT, util_random:random_number(Min, Max));
%%        _ ->
%%            noop
%%    end.

%% @doc 进入副本
handle_enter_mission(PlayerId, #scene_state{mission_type = MissionType, scene_id = SceneId}) ->
    Step = get(?SCENE_BOSS_STEP),
    Time =
        case Step of
            ?SCENE_BOSS_STEP_BET ->
                get(?DICT_MISSION_SCENE_BOSS_WAIT_TIME);
            ?SCENE_BOSS_STEP_FIGHT ->
                get(?DICT_MISSION_SCENE_BOSS_BALANCE_MS)
        end,
    api_mission:notice_scene_boss_step(PlayerId, Step, round(Time / 1000)),
    EnterPlayerIdList = get(?SCENE_BOSS_ENTER_PLAYER_ID_LIST),
    case lists:member(PlayerId, EnterPlayerIdList) of
        false ->
            mod_apply:apply_to_online_player(PlayerId, mod_conditions, add_conditions, [PlayerId, {?CON_ENUM_KILL_BOSS_COUNT, ?CONDITIONS_VALUE_ADD, 1}]),
            put(?SCENE_BOSS_ENTER_PLAYER_ID_LIST, [PlayerId | EnterPlayerIdList]);
        true ->
            noop
    end,
    case MissionType of
        ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION ->
            case Step of
                ?SCENE_BOSS_STEP_BET ->
                    noop;
                ?SCENE_BOSS_STEP_FIGHT ->
                    [SceneMonsterId] = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
                    ObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(SceneMonsterId),
                    #obj_scene_actor{
                        x = X,
                        y = Y
                    } = ObjSceneMonster,
                    #t_scene{
                        monster_x_y_list = MonsterBirthList
                    } = mod_scene:get_t_scene(SceneId),
                    {index, Index} = util_list:get_element_index([X, Y], MonsterBirthList),
                    %% 通知boss位置改变
                    api_mission:notice_scene_boss_boss_update_pos([PlayerId], Index)
            end,
            notice_scene_boss_bet([PlayerId], get_all_bet_id_list(?BET_TYPE_POS), ?BET_TYPE_POS);
        ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
            notice_scene_boss_bet([PlayerId], get_all_bet_id_list(?BET_TYPE_DAO), ?BET_TYPE_DAO),
            api_mission:notice_scene_boss_dao_num_change([PlayerId], util:get_dict(?SCENE_BOSS_DEAL_ATTACK_TIMES, 0));
        _ ->
            noop
    end,
    mod_apply:apply_to_online_player(PlayerId, erlang, put, [is_use_anger, true]).

%% @doc 离开副本
handle_leave_mission(_PlayerId) ->
    noop.
%%    ?DEBUG("离开场景boss副本~p", [PlayerId]),
%%    mod_apply:apply_to_online_player(PlayerId, erlang, put, [is_use_anger, true]).

%% @doc 开启boss
handle_open_boss(State = #scene_state{scene_id = SceneId, mission_type = MissionType, mission_id = MissionId}) ->
    put(?SCENE_BOSS_STEP, ?SCENE_BOSS_STEP_FIGHT),
    Time = get(?DICT_MISSION_SCENE_BOSS_BALANCE_MS),
    lists:foreach(
        fun(PlayerId) ->
            api_mission:notice_scene_boss_step(PlayerId, ?SCENE_BOSS_STEP_FIGHT, round(Time / 1000))
        end, mod_scene_player_manager:get_all_obj_scene_player_id()
    ),
    case MissionType of
        ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION ->
            #t_mission{
                boss_id = BossId
            } = mod_mission:get_t_mission(MissionType, MissionId),
            #t_scene{
                monster_x_y_list = MonsterBirthList
            } = mod_scene:get_t_scene(SceneId),
            BetAwardList = lists:map(
                fun([BetId, PosIdList, Rate]) ->
                    BetValue = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_POS, BetId}, 0),
                    {PosIdList, trunc(BetValue * Rate / 10000)}
                end,
                ?SD_SCENE_BOSS_LOCATION_LIST
            ),
            AllPosIdList = lists:seq(1, length(MonsterBirthList)),
            PosAwardList = util_list:rkeysort(2, lists:map(
                fun(PosId) ->
                    Value = lists:foldl(
                        fun({ThisPosIdList, ThisBetAward}, TmpV) ->
                            case lists:member(PosId, ThisPosIdList) of
                                true ->
                                    TmpV + ThisBetAward;
                                false ->
                                    TmpV - ThisBetAward
                            end
                        end,
                        0, BetAwardList
                    ),
                    {PosId, Value}
                end, AllPosIdList
            )),
            SceneBossAdjustPoolValue = mod_server_data:get_int_data(?SERVER_DATA_SCENE_BOSS_ADJUST_POOL),
            SortList = util_list:get_value_from_range_list(SceneBossAdjustPoolValue, ?SD_SCENE_BOSS_LOCATION_XIUZHENG_LIST, AllPosIdList),
            {_, L} = lists:foldl(
                fun(PosAward, {ThisIndex, TmpL}) ->
                    {
                        ThisIndex + 1,
                        case lists:member(ThisIndex, SortList) of
                            true ->
                                [PosAward | TmpL];
                            false ->
                                TmpL
                        end
                    }
                end, {1, []}, PosAwardList
            ),
            {ResultPosId, ResultAward} = util_random:get_list_random_member(L),
            ?DEBUG("位置boss 死亡位置已经决定 : ~p", [{ResultPosId, ResultAward}]),
            put(?SCENE_BOSS_POS_BOSS_DIE_POS, ResultPosId),
            [X, Y] = util_random:get_list_random_member(MonsterBirthList),
            mod_scene_monster_manager:create_monster(BossId, X, Y, State),
%%            [Min, Max] = ?SD_SCENE_BOSS_LOCATION_CHANGE_TIME_LIST,
            {index, Index} = util_list:get_element_index([X, Y], MonsterBirthList),
            lists:foreach(
                fun(MonsterObjId) ->
                    ObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
                    #obj_scene_actor{
                        is_boss = IsBoss
                    } = ObjSceneMonster,
                    if
                        IsBoss ->
                            if
                                ResultPosId == Index ->
                                    ?UPDATE_OBJ_SCENE_MONSTER(ObjSceneMonster#obj_scene_actor{die_type = 1});
                                true ->
                                    ?UPDATE_OBJ_SCENE_MONSTER(ObjSceneMonster#obj_scene_actor{die_type = 0})
                            end;
                        true ->
                            noop
                    end
                end,
                mod_scene_monster_manager:get_all_obj_scene_monster_id()
            ),
            %% 通知boss位置改变
            api_mission:notice_scene_boss_boss_update_pos(mod_scene_player_manager:get_all_obj_scene_player_id(), Index);
%%            mod_mission:send_msg_delay(?MSG_SCENE_BOSS_POS_BOSS_TELEPORT, util_random:random_number(Min, Max));
        ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
            SceneBossAdjustPoolValue = mod_server_data:get_int_data(?SERVER_DATA_SCENE_BOSS_ADJUST_POOL),
            case util_list:get_value_from_range_list(SceneBossAdjustPoolValue, ?SD_SCENE_BOSS_COUNT_XIUZHENG_LIST) of
                ?UNDEFINED ->
                    ?DEBUG("找不到修正 ~p", [{SceneBossAdjustPoolValue, ?SD_SCENE_BOSS_COUNT_XIUZHENG_LIST}]),
                    [DaoMin, DaoMax] = util_random:get_probability_item([{Dao, Weight} || [_Id, Dao, Weight] <- ?SD_SCENE_BOSS_COUNT_DEAD_LIST]),
                    DieDao = util_random:random_number(DaoMin, DaoMax),
                    ?DEBUG("刀数boss 死亡刀数已经决定 : ~p", [DieDao]),
                    put(?SCENE_BOSS_DAO_BOSS_DIE_DAO, DieDao);
                SortList ->
                    BetAwardList = util_list:rkeysort(2, lists:map(
                        fun([BetId, _, Rate]) ->
                            BetValue = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_DAO, BetId}, 0),
                            {BetId, trunc(BetValue * Rate / 10000)}
                        end, ?SD_SCENE_BOSS_COUNT_LIST
                    )),
                    {_, L} = lists:foldl(
                        fun({ThisBetId, _}, {ThisIndex, TmpL}) ->
                            {
                                ThisIndex + 1,
                                case lists:member(ThisIndex, SortList) of
                                    true ->
                                        [ThisBetId | TmpL];
                                    false ->
                                        TmpL
                                end
                            }
                        end, {1, []}, BetAwardList
                    ),
                    DieBetId = util_random:get_list_random_member(L),
                    [DaoMin, DaoMax] = util_list:opt(DieBetId, [{Id, Dao} || [Id, Dao, _Weight] <- ?SD_SCENE_BOSS_COUNT_DEAD_LIST]),
                    DieDao = util_random:random_number(DaoMin, DaoMax),
                    ?DEBUG("刀数boss 死亡刀数已经决定 : ~p", [DieDao]),
                    put(?SCENE_BOSS_DAO_BOSS_DIE_DAO, DieDao)
            end,
            SceneMonsterIdList = scene_data:get_scene_monster_id_list(SceneId),
            mod_scene_monster_manager:create_monster_list(SceneMonsterIdList, State)
    end.

%% @doc boss闪现
handle_boss_teleport(ObjSceneMonster, #scene_state{scene_id = SceneId}) ->
    #obj_scene_actor{
        obj_id = ObjId,
        x = OldX,
        y = OldY,
        grid_id = OldGridId
    } = ObjSceneMonster,
    #t_scene{
        monster_x_y_list = MonsterBirthList
    } = mod_scene:get_t_scene(SceneId),
    [X, Y] = util_random:get_list_random_member(MonsterBirthList -- [[OldX, OldY]]),
    {index, Index} = util_list:get_element_index([X, Y], MonsterBirthList),
    ResultPosId = get(?SCENE_BOSS_POS_BOSS_DIE_POS),
    %% 通知boss位置改变
    api_mission:notice_scene_boss_boss_update_pos(mod_scene_player_manager:get_all_obj_scene_player_id(), Index),
    %% ?DEBUG("怪物闪现~p", [{OldX, OldY, X, Y}]),
    NewGridId = ?PIX_2_GRID_ID(X, Y),
    NewObjSceneMonster = ObjSceneMonster#obj_scene_actor{x = X, y = Y, grid_id = NewGridId, last_move_time = util_time:milli_timestamp(), die_type = ?IF(ResultPosId == Index, 0, 1)},
    mod_scene_grid_manager:handle_monster_grid_change(NewObjSceneMonster, OldGridId, NewGridId),
    api_scene:notice_monster_teleport(
        mod_scene_player_manager:get_all_obj_scene_player_id(),
        ObjId,
        X,
        Y
    ),
    NewObjSceneMonster.
%%handle_boss_teleport(#scene_state{scene_id = SceneId}) ->
%%    lists:foreach(
%%        fun(SceneMonsterId) ->
%%            ObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(SceneMonsterId),
%%            #obj_scene_actor{
%%                is_boss = IsBoss,
%%                x = OldX,
%%                y = OldY,
%%                grid_id = OldGridId
%%            } = ObjSceneMonster,
%%            if
%%                IsBoss ->
%%                    #t_scene{
%%                        monster_x_y_list = MonsterBirthList
%%                    } = mod_scene:get_t_scene(SceneId),
%%                    [X, Y] = util_random:get_list_random_member(MonsterBirthList -- [[OldX, OldY]]),
%%                    {index, Index} = util_list:get_element_index([X, Y], MonsterBirthList),
%%                    ResultPosId = get(?SCENE_BOSS_POS_BOSS_DIE_POS),
%%                    lists:foreach(
%%                        fun(MonsterObjId) ->
%%                            ObjSceneMonster = ?GET_OBJ_SCENE_MONSTER(MonsterObjId),
%%                            #obj_scene_actor{
%%                                is_boss = IsBoss
%%                            } = ObjSceneMonster,
%%                            if
%%                                IsBoss ->
%%                                    if
%%                                        ResultPosId == Index ->
%%                                            ?UPDATE_OBJ_SCENE_MONSTER(ObjSceneMonster#obj_scene_actor{die_type = 1});
%%                                        true ->
%%                                            ?UPDATE_OBJ_SCENE_MONSTER(ObjSceneMonster#obj_scene_actor{die_type = 0})
%%                                    end;
%%                                true ->
%%                                    noop
%%                            end
%%                        end,
%%                        mod_scene_monster_manager:get_all_obj_scene_monster_id()
%%                    ),
%%                    %% 通知boss位置改变
%%                    api_mission:notice_scene_boss_boss_update_pos(mod_scene_player_manager:get_all_obj_scene_player_id(), Index),
%%                    %% ?DEBUG("怪物闪现~p", [{OldX, OldY, X, Y}]),
%%                    NewGridId = ?PIX_2_GRID_ID(X, Y),
%%                    NewObjSceneMonster = ObjSceneMonster#obj_scene_actor{x = X, y = Y, grid_id = NewGridId, last_move_time = util_time:milli_timestamp()},
%%                    ?UPDATE_OBJ_SCENE_MONSTER(NewObjSceneMonster),
%%                    mod_scene_grid_manager:handle_monster_grid_change(NewObjSceneMonster, OldGridId, NewGridId),
%%                    api_scene:notice_monster_teleport(
%%                        mod_scene_player_manager:get_all_obj_scene_player_id(),
%%                        SceneMonsterId,
%%                        X,
%%                        Y
%%                    );
%%                true ->
%%                    noop
%%            end
%%        end, mod_scene_monster_manager:get_all_obj_scene_monster_id()
%%    ),
%%    [Min, Max] = ?SD_SCENE_BOSS_LOCATION_CHANGE_TIME_LIST,
%%    mod_mission:send_msg_delay(?MSG_SCENE_BOSS_POS_BOSS_TELEPORT, util_random:random_number(Min, Max)).

%% @doc 结算副本
handle_balance(#scene_state{scene_id = SceneId, mission_type = MissionType}) ->
    SceneBossOldSceneId = get(scene_boss_master_boss_id),
    PlayerIdList = get(?SCENE_BOSS_ENTER_PLAYER_ID_LIST),
    lists:foreach(
        fun(PlayerId) ->
            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                ?UNDEFINED ->
%%                    ?DEBUG("结算时不在场景中的玩家~p", [PlayerId]);
%%                    case mod_obj_player:get_obj_player(PlayerId) of
%%                        ObjPlayer when is_record(ObjPlayer, ets_obj_player) ->
%%                            #ets_obj_player{
%%                                scene_id = PlayerSceneId
%%                            } = ObjPlayer,
%%                            if
%%                                PlayerSceneId =:= SceneBossOldSceneId ->
                    mod_apply:apply_to_online_player(PlayerId, api_scene, notice_boss_state, [PlayerId, 0, 0, 0, 0]);
%%                    api_scene:notice_boss_state(PlayerId, 0, 0, 0, 0);
%%                                true ->
%%                                    noop
%%                            end;
%%                        _ ->
%%                            noop
%%                    end;
                _ ->
                    noop
            end
        end,
        PlayerIdList
    ),
    case MissionType of
        ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION ->
            #t_scene{
                monster_x_y_list = MonsterBirthList
            } = mod_scene:get_t_scene(SceneId),
            case get(scene_boss_die_data) of
                ?UNDEFINED ->
                    lists:foreach(
                        fun(PlayerId) ->
                            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                                ?UNDEFINED ->
                                    noop;
                                _ ->
                                    api_mission:notice_scene_boss_result(PlayerId, ?FALSE, "", 0, [], 0, [])
                            end
                        end,
                        PlayerIdList
                    );
                {DieX, DieY, PlayerName} ->
                    {index, DieId} = util_list:get_element_index([DieX, DieY], MonsterBirthList),
                    lists:foreach(
                        fun(PlayerId) ->
                            {AwardValue, List, IsSendFailMail} = lists:foldl(
                                fun([BetId, DiePosList, Rate], {TmpAwardValue, TmpList, TmpIsSendFailMail}) ->
                                    {BetValue, NewTmpIsSendFailMail} =
                                        case get({?SCENE_BOSS_BET, ?BET_TYPE_POS, BetId, PlayerId}) of
                                            ?UNDEFINED ->
                                                {0, TmpIsSendFailMail};
                                            Value ->
                                                {Value, true}
                                        end,
                                    case lists:member(DieId, DiePosList) of
                                        true ->
                                            ThisBetAwardValue = round(BetValue * Rate / 10000),
                                            {TmpAwardValue + ThisBetAwardValue, [{?BET_TYPE_POS, BetId, ThisBetAwardValue} | TmpList], NewTmpIsSendFailMail};
                                        false ->
                                            {TmpAwardValue, TmpList, NewTmpIsSendFailMail}
                                    end
                                end,
                                {0, [], false}, ?SD_SCENE_BOSS_LOCATION_LIST
                            ),
                            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                                ?UNDEFINED ->
                                    if
                                        AwardValue > 0 ->
                                            mod_apply:apply_to_online_player(PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, ?MAIL_SCENE_BOSS_LOCATION_DEATH, [{?ITEM_RMB, AwardValue}], [DieId, AwardValue], ?LOG_TYPE_MISSION_SCENE_BOSS_LOCATION], game_worker);
                                        true ->
                                            ?IF(IsSendFailMail, mod_apply:apply_to_online_player(PlayerId, mod_mail, add_mail_param, [PlayerId, ?MAIL_SCENE_BOSS_LOCATION_DEATH1, [DieId], ?LOG_TYPE_MISSION_SCENE_BOSS_LOCATION], game_worker), noop)
                                    end;
                                _ ->
                                    ?IF(AwardValue > 0, mod_apply:apply_to_online_player(PlayerId, mod_award, give, [PlayerId, [{?ITEM_RMB, AwardValue}], ?LOG_TYPE_MISSION_SCENE_BOSS_LOCATION], game_worker), noop),
                                    api_mission:notice_scene_boss_result(PlayerId, ?TRUE, PlayerName, get('ManoAward'), List, PlayerId, util:get_dict('CCAward', []))
                            end
                        end, PlayerIdList
                    ),
                    {TotalCostValue, TotalAwardValue} = lists:foldl(
                        fun([BetId, PosIdList, Rate], {TmpTotalCostValue, TmpTotalAwardValue}) ->
                            BetValue = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_POS, BetId}, 0),
                            {
                                TmpTotalCostValue + BetValue,
                                case lists:member(DieId, PosIdList) of
                                    true ->
                                        TmpTotalAwardValue + trunc(BetValue * Rate / 10000);
                                    false ->
                                        TmpTotalAwardValue
                                end
                            }
                        end,
                        {0, 0}, ?SD_SCENE_BOSS_LOCATION_LIST
                    ),
                    SceneBossAdjustPool = mod_server_data:get_int_data(?SERVER_DATA_SCENE_BOSS_ADJUST_POOL),
                    mod_server_data:set_int_data(?SERVER_DATA_SCENE_BOSS_ADJUST_POOL, SceneBossAdjustPool + trunc(TotalCostValue * ?SD_SCENE_BOSS_RATE / 10000) - TotalAwardValue)
            end;
        ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
            case get(scene_boss_die_data) of
                ?UNDEFINED ->
                    lists:foreach(
                        fun(PlayerId) ->
                            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                                ?UNDEFINED ->
                                    noop;
                                _ ->
                                    api_mission:notice_scene_boss_result(PlayerId, ?FALSE, "", 0, [], 0, [])
                            end
                        end,
                        get(?SCENE_BOSS_ENTER_PLAYER_ID_LIST)
                    );
                {_DieX, _DieY, PlayerName} ->
                    AttackTimes = get(?SCENE_BOSS_DEAL_ATTACK_TIMES),
                    lists:foreach(
                        fun(PlayerId) ->
                            {AwardValue, List, IsSendFailMail} = lists:foldl(
                                fun([BetId, [MinDaoShu, MaxDaoShu], Rate], {TmpAwardValue, TmpList, TmpIsSendFailMail}) ->
                                    {BetValue, NewTmpIsSendFailMail} =
                                        case get({?SCENE_BOSS_BET, ?BET_TYPE_DAO, BetId, PlayerId}) of
                                            ?UNDEFINED ->
                                                {0, TmpIsSendFailMail};
                                            Value ->
                                                {Value, true}
                                        end,
                                    case MinDaoShu =< AttackTimes andalso (MaxDaoShu >= AttackTimes orelse MaxDaoShu =:= 0) of
                                        true ->
                                            ThisBetAwardValue = round(BetValue * Rate / 10000),
                                            {TmpAwardValue + ThisBetAwardValue, [{?BET_TYPE_DAO, BetId, ThisBetAwardValue} | TmpList], NewTmpIsSendFailMail};
                                        false ->
                                            {TmpAwardValue, TmpList, NewTmpIsSendFailMail}
                                    end
                                end,
                                {0, [], false}, ?SD_SCENE_BOSS_COUNT_LIST
                            ),
                            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                                ?UNDEFINED ->
                                    if
                                        AwardValue > 0 ->
                                            mod_apply:apply_to_online_player(PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, ?MAIL_SCENE_BOSS_ATK_COUNT_DEATH, [{?ITEM_RMB, AwardValue}], [AttackTimes, AwardValue], ?LOG_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT], game_worker);
                                        true ->
                                            ?IF(IsSendFailMail, mod_apply:apply_to_online_player(PlayerId, mod_mail, add_mail_param, [PlayerId, ?MAIL_SCENE_BOSS_ATK_COUNT_DEATH1, [AttackTimes], ?LOG_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT], game_worker), noop)
                                    end;
                                _ ->
                                    ?IF(AwardValue > 0, mod_apply:apply_to_online_player(PlayerId, mod_award, give, [PlayerId, [{?ITEM_RMB, AwardValue}], ?LOG_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT], game_worker), noop),
                                    api_mission:notice_scene_boss_result(PlayerId, ?TRUE, PlayerName, get('ManoAward'), List, PlayerId, util:get_dict('CCAward', []))
                            end
                        end,
                        PlayerIdList
                    ),
                    {TotalCostValue, TotalAwardValue} = lists:foldl(
                        fun([BetId, [MinDaoShu, MaxDaoShu], Rate], {TmpTotalCostValue, TmpTotalAwardValue}) ->
                            BetValue = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_DAO, BetId}, 0),
                            {
                                TmpTotalCostValue + BetValue,
                                case MinDaoShu =< AttackTimes andalso (MaxDaoShu >= AttackTimes orelse MaxDaoShu =:= 0) of
                                    true ->
                                        ThisBetAwardValue = round(BetValue * Rate / 10000),
                                        TmpTotalAwardValue + ThisBetAwardValue;
                                    false ->
                                        TmpTotalAwardValue
                                end
                            }
                        end,
                        {0, 0}, ?SD_SCENE_BOSS_COUNT_LIST
                    ),
                    SceneBossAdjustPool = mod_server_data:get_int_data(?SERVER_DATA_SCENE_BOSS_ADJUST_POOL),
                    mod_server_data:set_int_data(?SERVER_DATA_SCENE_BOSS_ADJUST_POOL, SceneBossAdjustPool + trunc(TotalCostValue * ?SD_SCENE_BOSS_RATE / 10000) - TotalAwardValue)
            end
    end,
    scene_boss_master:cast({close_boss_mission, self(), SceneBossOldSceneId, PlayerIdList}),
    scene_worker:stop(self(), 10 * ?SECOND_MS).

%% @doc 场景关闭
handle_terminate(_State) ->
    noop.
%%handle_terminate(#scene_state{scene_id = SceneId, mission_type = MissionType}) ->
%%    case mod_mission:is_balance() of
%%        false ->
%%            PlayerIdList = get(?SCENE_BOSS_ENTER_PLAYER_ID_LIST),
%%            case MissionType of
%%                ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION ->
%%                    #t_scene{
%%                        monster_x_y_list = MonsterBirthList
%%                    } = mod_scene:get_t_scene(SceneId),
%%                    case get(scene_boss_die_data) of
%%                        ?UNDEFINED ->
%%                            noop;
%%                        {DieX, DieY, PlayerName} ->
%%                            {index, DieId} = util_list:get_element_index([DieX, DieY], MonsterBirthList),
%%                            lists:foreach(
%%                                fun(PlayerId) ->
%%                                    {AwardValue, List, IsSendFailMail} = lists:foldl(
%%                                        fun([BetId, DiePosList, Rate], {TmpAwardValue, TmpList, TmpIsSendFailMail}) ->
%%                                            {BetValue, NewTmpIsSendFailMail} =
%%                                                case get({?SCENE_BOSS_BET, ?BET_TYPE_POS, BetId, PlayerId}) of
%%                                                    ?UNDEFINED ->
%%                                                        {0, TmpIsSendFailMail};
%%                                                    Value ->
%%                                                        {Value, true}
%%                                                end,
%%                                            case lists:member(DieId, DiePosList) of
%%                                                true ->
%%                                                    ThisBetAwardValue = round(BetValue * Rate / 10000),
%%                                                    {TmpAwardValue + ThisBetAwardValue, [{?BET_TYPE_POS, BetId, ThisBetAwardValue} | TmpList], NewTmpIsSendFailMail};
%%                                                false ->
%%                                                    {TmpAwardValue, TmpList, NewTmpIsSendFailMail}
%%                                            end
%%                                        end,
%%                                        {0, [], false}, ?SD_SCENE_BOSS_LOCATION_LIST
%%                                    ),
%%                                    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%                                        ?UNDEFINED ->
%%                                            if
%%                                                AwardValue > 0 ->
%%                                                    mod_apply:apply_to_online_player(PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, ?MAIL_SCENE_BOSS_LOCATION_DEATH, [{?ITEM_RMB, AwardValue}], [DieId, AwardValue], ?LOG_TYPE_MISSION_SCENE_BOSS_LOCATION], game_worker);
%%                                                true ->
%%                                                    ?IF(IsSendFailMail, mod_apply:apply_to_online_player(PlayerId, mod_mail, add_mail_param, [PlayerId, ?MAIL_SCENE_BOSS_LOCATION_DEATH1, [DieId], ?LOG_TYPE_MISSION_SCENE_BOSS_LOCATION], game_worker), noop)
%%                                            end;
%%                                        _ ->
%%                                            ?IF(AwardValue > 0, mod_apply:apply_to_online_player(PlayerId, mod_award, give, [PlayerId, [{?ITEM_RMB, AwardValue}], ?LOG_TYPE_MISSION_SCENE_BOSS_LOCATION], game_worker), noop),
%%                                            api_mission:notice_scene_boss_result(PlayerId, ?TRUE, PlayerName, get('ManoAward'), List)
%%                                    end
%%                                end, PlayerIdList
%%                            )
%%                    end;
%%                ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
%%                    case get(scene_boss_die_data) of
%%                        ?UNDEFINED ->
%%                            lists:foreach(
%%                                fun(PlayerId) ->
%%                                    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%                                        ?UNDEFINED ->
%%                                            noop;
%%                                        _ ->
%%                                            api_mission:notice_scene_boss_result(PlayerId, ?FALSE, "", 0, [])
%%                                    end
%%                                end,
%%                                get(?SCENE_BOSS_ENTER_PLAYER_ID_LIST)
%%                            );
%%                        {_DieX, _DieY, PlayerName} ->
%%                            AttackTimes = get(scene_boss_deal_attack_times),
%%                            lists:foreach(
%%                                fun(PlayerId) ->
%%                                    {AwardValue, List, IsSendFailMail} = lists:foldl(
%%                                        fun([BetId, [MinDaoShu, MaxDaoShu], Rate], {TmpAwardValue, TmpList, TmpIsSendFailMail}) ->
%%                                            {BetValue, NewTmpIsSendFailMail} =
%%                                                case get({?SCENE_BOSS_BET, ?BET_TYPE_DAO, BetId, PlayerId}) of
%%                                                    ?UNDEFINED ->
%%                                                        {0, TmpIsSendFailMail};
%%                                                    Value ->
%%                                                        {Value, true}
%%                                                end,
%%                                            case MinDaoShu =< AttackTimes andalso (MaxDaoShu >= AttackTimes orelse MaxDaoShu =:= 0) of
%%                                                true ->
%%                                                    ThisBetAwardValue = round(BetValue * Rate / 10000),
%%                                                    {TmpAwardValue + ThisBetAwardValue, [{?BET_TYPE_DAO, BetId, ThisBetAwardValue} | TmpList], NewTmpIsSendFailMail};
%%                                                false ->
%%                                                    {TmpAwardValue, TmpList, NewTmpIsSendFailMail}
%%                                            end
%%                                        end,
%%                                        {0, [], false}, ?SD_SCENE_BOSS_COUNT_LIST
%%                                    ),
%%                                    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%                                        ?UNDEFINED ->
%%                                            if
%%                                                AwardValue > 0 ->
%%                                                    mod_apply:apply_to_online_player(PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, ?MAIL_SCENE_BOSS_ATK_COUNT_DEATH, [{?ITEM_RMB, AwardValue}], [AttackTimes, AwardValue], ?LOG_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT], game_worker);
%%                                                true ->
%%                                                    ?IF(IsSendFailMail, mod_apply:apply_to_online_player(PlayerId, mod_mail, add_mail_param, [PlayerId, ?MAIL_SCENE_BOSS_ATK_COUNT_DEATH1, [AttackTimes], ?LOG_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT], game_worker), noop)
%%                                            end;
%%                                        _ ->
%%                                            ?IF(AwardValue > 0, mod_apply:apply_to_online_player(PlayerId, mod_award, give, [PlayerId, [{?ITEM_RMB, AwardValue}], ?LOG_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT], game_worker), noop),
%%                                            api_mission:notice_scene_boss_result(PlayerId, ?TRUE, PlayerName, get('ManoAward'), List)
%%                                    end
%%                                end,
%%                                PlayerIdList
%%                            )
%%                    end
%%            end;
%%        true ->
%%            noop
%%    end.
