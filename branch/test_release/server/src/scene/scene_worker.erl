%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            场景进程
%%% @end
%%% Created : 10. 八月 2016 上午 11:37
%%%-------------------------------------------------------------------
-module(scene_worker).

-behaviour(gen_server).
-include("common.hrl").
-include("scene.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("msg.hrl").
-include("error.hrl").
-include("mission.hrl").
-include("fight.hrl").
-include("p_message.hrl").
-include("scene_master.hrl").
-include("guess_boss.hrl").
-include("one_on_one.hrl").
-include("p_enum.hrl").
-include("hero_versus_boss.hrl").
-include("scene_adjust.hrl").

%% API
-export([
    start/3,
    stop/1,                    %% 关闭场景进程
    stop/2,
    shot_all_player/1,         %% 踢出所有玩家
    shot_all_player/2,
%%    release/1,              %% 释放场景进程
    get_state/1,
    get_dict/2,               %% 获得进程字典值
    sync_to_scene_worker/2,
    notify_to_scene_worker/2,
    is_allow_enter_scene_worker/3
]).

%%CALLBACK
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-export([
    dict_set_monster_bomb/2,
    dict_get_monster_bomb/1,
    dict_set_monster_ai/2,
    dict_get_monster_ai/1,
    dict_set_boss_ai/2,
    dict_get_boss_ai/1,
    delete_monster_mod_dict/1       % 删除怪物模块字典
]).

-define(SERVER, ?MODULE).

-record(?MODULE, {
    monster_bomb = #r_monster_bomb{},             %% 炸弹怪AI相关
    monster_ai = #r_monster_ai{},                  %% 怪物的AI行为
    boss_ai = #r_boss_ai{}                        %% boss AI相关
}).

%%%===================================================================
%%% 字典操作，仅场景进程调用
%%%===================================================================
dict_set_monster_bomb(MonsterId, Rec) -> ?setModDict({monster_bomb, MonsterId}, Rec).
dict_get_monster_bomb(MonsterId) -> ?getModDict({monster_bomb, MonsterId}).
dict_set_monster_ai(MonsterId, Rec) -> ?setModDict({monster_ai, MonsterId}, Rec).
dict_get_monster_ai(MonsterId) -> ?getModDict({monster_ai, MonsterId}).
dict_set_boss_ai(MonsterId, Rec) -> ?setModDict({boss_ai, MonsterId}, Rec).
dict_get_boss_ai(MonsterId) -> ?getModDict({boss_ai, MonsterId}).

delete_monster_mod_dict(MonsterId) ->
    ?eraseModDict({monster_ai, MonsterId}),
    ?eraseModDict({monster_bomb, MonsterId}),
    ?eraseModDict({boss_ai, MonsterId}).

%%%===================================================================
%%% API
%%%===================================================================
start(SceneId, Owner, ExtraDataList) ->
    gen_server:start(?MODULE, [SceneId, Owner, ExtraDataList], []).

%% ----------------------------------
%% @doc 	停止场景进程
%% @throws 	none
%% @end
%% ----------------------------------
stop(SceneWorker) ->
    stop(SceneWorker, 0).
stop(SceneWorker, Delay) ->
    if Delay > 0 ->
        erlang:send_after(Delay, SceneWorker, ?MSG_SCENE_STOP);
        true ->
            SceneWorker ! ?MSG_SCENE_STOP
    end.

%% ----------------------------------
%% @doc 	踢出所有玩家
%% @throws 	none
%% @end
%% ----------------------------------
shot_all_player(SceneWorker) ->
    shot_all_player(SceneWorker, 0).
shot_all_player(SceneWorker, Delay) ->
    if Delay > 0 ->
        erlang:send_after(Delay, SceneWorker, shot_all_player);
        true ->
            SceneWorker ! shot_all_player
    end.

%% ----------------------------------
%% @doc 	释放场景进程
%% @throws 	none
%% @end
%% ----------------------------------
%%release(SceneWorker) ->
%%    SceneWorker ! ?MSG_RELEASE_SCENE_WORKER.

get_state(SceneWorker) ->
    gen_server:call(SceneWorker, ?MSG_SCENE_GET_STATE).

%% @fun 获得进程字典值
get_dict(SceneWorker, DictKey) ->
    gen_server:call(SceneWorker, {?MSG_SCENE_DICT_KEY, DictKey}).

%% ----------------------------------
%% @doc     判断场景进程是否允许加入
%% @throws 	none
%% @end
%% ----------------------------------
is_allow_enter_scene_worker(PlayerId, MaxPlayerCount, SceneWorker) ->
    case mod_cache:get({scene_worker_stay_player_list, SceneWorker}) of
        StayPlayerIdList when is_list(StayPlayerIdList) ->
            StayPLayerCount = length(StayPlayerIdList),
            case lists:member(PlayerId, StayPlayerIdList) of
                true -> true;
                false when (MaxPlayerCount == 0 orelse StayPLayerCount < MaxPlayerCount) -> true;
                false -> false
            end;
        null -> %% 其他情况
            true
    end.

%% ----------------------------------
%% @doc 	初始化场景进程
%% @throws 	none
%% @end
%% ----------------------------------
init([SceneId, Owner, ExtraDataList]) ->
%%    ?DEBUG("init scene_worker: ~p ~p ~p", [SceneId, Owner, ExtraDataList]),
%%    process_flag(trap_exit, true),
    erlang:process_flag(priority, high),
%%    erlang:process_flag(min_heap_size, 500), %% 默认值 233
%%    erlang:process_flag(min_bin_vheap_size, 100000), %% 默认值 65535
    case ?IS_DEBUG of
        true ->
            register(util:to_atom("scene_" ++ util:to_list(SceneId) ++ "_" ++ erlang:pid_to_list(self())), self());
        _ ->
            noop
    end,
%%    register(util:to_atom("scene_" ++ util:to_list(SceneId) ++ "_" ++ erlang:pid_to_list(self())), self()),
    erlang:monitor(process, Owner),
    SceneWorker = self(),

    #t_scene{
        map_id = MapId,
        type = SceneType,
        mission_type = MissionType,
%%        safe_type = SafeType,
        is_hook = IsHook,
%%        rebirth_window = RebirthWindow,
        max_player = MaxPlayerNum,
        is_server_control_player = IsServerControlPlayer,
        mana_attack_list = [ScenePropId, _]
    } = mod_scene:get_t_scene(SceneId),
    {ok, SceneNavigateWorker} = scene_navigate_worker:start(SceneWorker, MapId),
    erlang:monitor(process, SceneNavigateWorker),
    mod_map:load(MapId),
    mod_scene_grid_manager:init(SceneId),
    IsMission = SceneType == ?SCENE_TYPE_MISSION,


    ?INIT_PROCESS_TYPE(?PROCESS_TYPE_SCENE_WORKER),
    put(?DICT_SCENE_ID, SceneId),
    put(?DICT_SCENE_TYPE, SceneType),
    put(?DICT_IS_CAN_ACTION, true),
%%    put(?DICT_MONSTER_IS_CAN_JUMP, ?TRAN_INT_2_BOOL(IsMonsterCanJump)),
    put(?DICT_SCENE_CREATE_TIME, util_time:timestamp()),
    put(?DICT_MAP_ID, MapId),
    put(?DICT_SCENE_IS_SERVER_CONTROL_SCENE, ?TRAN_INT_2_BOOL(IsServerControlPlayer)),
%%    put(?DICT_SCENE_SAFE_TYPE, SafeType),
    put(?DICT_OBJ_SCENE_ITEM_ID, 1),
    put(?DICT_CAN_ACTION_TIME, 0),
    put(?DICT_MISSION_ROUND, 0),
    put(?DICT_MAX_PLAYER_NUM, MaxPlayerNum),
    put(?DICT_IS_HOOK_SCENE, ?TRAN_INT_2_BOOL(IsHook)),
    put(?DICT_SCENE_COST_PROP_ID, ScenePropId),
    ScenePropAwardPropId =
        if
            SceneType == ?SCENE_TYPE_MATCH_SCENE ->
                ?ITEM_JIFEN;
            true ->
                ScenePropId
        end,
    put(?DICT_SCENE_AWARD_PROP_ID, ScenePropAwardPropId),
%%    put(?DICT_REBIRTH_WINDOWS, RebirthWindow),
%%    put({?MISSION_BET_PLAYER_LIST, MissionType}, []),
    put(one_on_one_winner, 0),
    put(one_on_one, []),
%%    put({?MISSION_BET_PLAYER_LEAVE_LIST, MissionType}, []),
    put(?DICT_EXTRA_DATA, ExtraDataList),
    FightType = mod_fight:get_fight_type(SceneId),
    put(?DICT_SCENE_FIGHT_TYPE, FightType),
    self() ! ?MSG_SCENE_ASYNC_INIT,
    MissionId =
        if IsMission ->
            put(?DICT_IS_MISSION, true),
            mission_handle:handle_init_mission(MissionType, ExtraDataList);
            true ->
                put(?DICT_IS_MISSION, false),
                0
        end,
    if
        SceneType == ?SCENE_TYPE_WORLD_SCENE andalso IsHook == ?TRUE ->
%%            init_state(ExtraDataList),
            erlang:send_after(3000, self(), ?MSG_SCENE_GOLD_RANK_MSG),
            case FightType of
                ?FIGHT_TYPE_ODDS ->
                    noop;
                ?FIGHT_TYPE_HP ->
                    %% 全部怪物尝试因为没被打恢复血量
                    erlang:send_after(2000, self(), ?MSG_SCENE_ALL_MONSTER_RECOVER_HP),
                    %% 残血怪物恢复血量
                    erlang:send_after(?SD_HP_MODE_HP_RECOVER_CD_TIME, self(), ?MSG_SCENE_MONSTER_RECOVER_HP)
            end,
            erlang:send_after(?SD_SKILL_ANGER_INTERVAL, self(), ?MSG_SCENE_ADD_ANGER),
            scene_adjust:init_scene(SceneId);
        SceneType == ?SCENE_TYPE_MISSION ->
            erlang:send_after(3000, self(), ?MSG_SCENE_GOLD_RANK_MSG);
%%        SceneType == ?SCENE_TYPE_MATCH_SCENE ->
%%            match_scene:init();
        SceneType == ?SCENE_TYPE_MATCH_SCENE ->
            erlang:send_after(?SD_SKILL_ANGER_INTERVAL, self(), ?MSG_SCENE_ADD_ANGER),
            match_scene:init(ExtraDataList);
        true ->
            noop
    end,
    erlang:send_after(60000, self(), ?MSG_SCENE_FIGHT_MONSTER_LOG),
    ?INFO("场景进程(~p)启动成功!", [{SceneId, self()}]),
    {ok, #scene_state{
        scene_id = SceneId,
        scene_type = SceneType,
        mission_type = MissionType,
        mission_id = MissionId,
        is_mission = IsMission,
        map_id = MapId,
        owner = Owner,
%%        rebirth_window = RebirthWindow,
        scene_navigate_worker = SceneNavigateWorker,
        is_scene_master_manage = erlang:whereis(scene_master) == Owner,
        extra_data_list = ExtraDataList,
        is_hook_scene = ?TRAN_INT_2_BOOL(IsHook),
        fight_type = FightType
    }}.

%%%===================================================================
%%% 发送消息给场景进程
%%%===================================================================
% 实时回调场景进程
sync_to_scene_worker(SceneWorker, {_Mod, _Info} = Request) when is_pid(SceneWorker) ->
    case gen_server:call(SceneWorker, {sync, Request}) of
        {ok, Reply} ->
            Reply;
        {error, Reason} ->
            {error, Reason}
    end.

% 推送给场景进程
notify_to_scene_worker(SceneWorker, {_Mod, _Info} = Request) when is_pid(SceneWorker) ->
    SceneWorker ! {notify, Request}.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%init_state(ExtraDataList) ->
%%    case util_list:opt(scene_master_state, ExtraDataList) of
%%        ?UNDEFINED ->
%%            ?ERROR("创建世界挂机场景没给状态"),
%%            update_state({?SCENE_MASTER_STATE_MONSTER, util_time:milli_timestamp()});
%%        {Status, StatusStartTime} ->
%%            if
%%                Status == ?SCENE_MASTER_STATE_BOSS ->
%%                    put(scene_master_boss_data, util_list:opt(scene_master_boss_data, ExtraDataList));
%%                true ->
%%                    noop
%%            end,
%%            update_state({Status, StatusStartTime})
%%    end.

handle_call(get_monster_list, _From, State = #scene_state{}) ->
    {reply, catch lists:foldl(
        fun(Id, Tmp) ->
            case ?GET_OBJ_SCENE_MONSTER(Id) of
                ?UNDEFINED ->
                    Tmp;
                L ->
                    [#monster{
                        scene_monster_id = L#obj_scene_actor.obj_id,
                        monster_id = L#obj_scene_actor.base_id,
                        x = L#obj_scene_actor.x,
                        y = L#obj_scene_actor.y
                    } | Tmp]
            end
        end,
        [],
        mod_scene_monster_manager:get_all_obj_scene_monster_id()
    ), State};
%%
handle_call({?MSG_DIZZY_TIME_REDUCE, PlayerId, Times} = Msg, _From, State = #scene_state{scene_id = _SceneId}) ->
    try mod_fight:dizzy_reduce(PlayerId, Times) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            [Interval, AllowedTimes, _] = ?SD_DIZZY_TIME_REDUCE_LIST,
            case Reason of
                ?ERROR_TIME_LIMIT -> ?WARNING("~p在~p内多次上报减少眩晕时间协议", [PlayerId, Interval]);
                ?ERROR_TIMES_LIMIT -> ?WARNING("~p在上报减少眩晕时间协议~p", [PlayerId, {Times, AllowedTimes}]);
                O -> ?ERROR("~p:~p~n", [Msg, {O, PlayerId, erlang:get_stacktrace()}])
            end,
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_SCENE_SHEN_LONG_DRAW, PlayerId} = Msg, _From, State = #scene_state{scene_id = _SceneId}) ->
    try mod_shen_long:handle_shen_long_draw(PlayerId) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, PlayerId, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call(?MSG_SCENE_GET_PLAYER_COUNT, _From, State = #scene_state{}) ->
    {reply, mod_scene_player_manager:get_all_obj_scene_player_id(), State};
handle_call({?MSG_SCENE_PLAYER_ENTER_SCENE, PlayerEnterSceneData}, _From, State = #scene_state{scene_id = SceneId}) ->
    try mod_scene_player_manager:handle_player_enter_scene(PlayerEnterSceneData, State) of
        _ ->
            handle_player_count_change(State),
            {reply, success, State}
    catch
        _:Reason ->
            ?ERROR("PLAYER_ENTER_SCENE: ~p", [{Reason, {?MSG_SCENE_PLAYER_ENTER_SCENE, SceneId}, erlang:get_stacktrace()}]),
            ?TRY_CATCH(self() ! {?MSG_SCENE_PLAYER_LEAVE_ASYNC, PlayerEnterSceneData#player_enter_scene_data.player_id}),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_SCENE_USE_FIGHT_ITEM, ItemId, PlayerId}, _From, State = #scene_state{scene_id = _SceneId}) -> %% todo ??
    try handle_use_item(ItemId, PlayerId) of
        _ ->
            {reply, ok, State}
    catch
        _:Reason ->
            ?ERROR("use_item: ~p", [{Reason, {?MSG_SCENE_USE_FIGHT_ITEM, ItemId, PlayerId}, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?SCENE_ADJUST_MSG_GET_PLAYER_STATE, PlayerId} = Msg, _From, State) ->
    try scene_adjust:get_player_adjust_state(PlayerId) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("Msg: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_FIGHT, RequestFightParam} = Msg, _, State = #scene_state{mission_type = _MissionType}) ->
    try mod_fight:fight(RequestFightParam, State) of
        Res ->
            {reply, Res, State}
    catch
        _:Reason ->
            put(?DICT_IS_FIGHT, false),

            if Reason == ?ERROR_SKILL_CD_TIME -> noop;
                Reason == ?ERROR_ALREADY_BALANCE -> noop;
                Reason == ?ERROR_ALREADY_DIE -> noop;
                Reason == ?ERROR_NOT_ACTION_TIME -> noop;
                true ->
                    ?ERROR("MSG_FIGHT: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
            end,
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_SCENE_PLAYER_LEAVE, PlayerId}, _From, State) ->
    try mod_scene_player_manager:handle_player_leave(PlayerId, State) of
        Reply ->
            handle_player_count_change(State),
            {reply, Reply, State}
    catch
        _:Reason ->
            ?ERROR("PLAYER_LEAVE: ~p", [{Reason, {?MSG_SCENE_PLAYER_LEAVE, PlayerId}, erlang:get_stacktrace()}]),
            {reply, fail, State}
    end;
%%handle_call({?MSG_SCENE_PLAYER_REBIRTH, PlayerId, Type} = Msg, _From, State) ->
%%    try mod_scene_player_manager:handle_msg_player_rebirth(PlayerId, Type, State) of
%%        _ ->
%%            {reply, success, State}
%%    catch
%%        _:Reason ->
%%            ?ERROR("PLAYER_REBIRTH: ~p", [{Reason, Msg}]),
%%            {reply, {error, Reason}, State}
%%    end;
handle_call({?MSG_SCENE_GET_PLAYER_POS, PlayerId} = Msg, _From, State) ->
    try mod_scene_player_manager:handle_msg_get_player_pos(PlayerId, State) of
        Result ->
%%            ?INFO("GET_PLAYER_POS: ~p", [{Result}]),
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("GET_PLAYER_POS: ~p", [{Reason, Msg}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_SCENE_REBIRTH_MONSTER, MonsterId} = Msg, _From, State) ->
    try mod_scene_monster_manager:handle_rebirth_monster(MonsterId, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("MSG_BOSS_REBIRTH: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_SCENE_GET_SCENE_PLAYER_ID_LIST, Type} = Msg, _From, State) ->
    try mod_scene_player_manager:handle_get_player_id_list(Type) of
        Result ->
            {reply, {ok, Result}, State}
    catch
        _:Reason ->
            ?ERROR("GET_SCENE_PLAYER_ID_LIST: ~p", [{Reason, Msg}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_SCENE_GET_SCENE_PLAYER_ID_LIST, Type, PlayerId} = Msg, _From, State) ->
    try mod_scene_player_manager:handle_get_player_id_list(Type, PlayerId) of
        Result ->
            {reply, {ok, Result}, State}
    catch
        _:Reason ->
            ?ERROR("GET_SCENE_PLAYER_ID_LIST: ~p", [{Reason, Msg}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_PLAYER_RESET_BET, PlayerId} = Msg, _From, State) ->
%%    try bet_handle:handle_player_reset_bet_one_on_one(PlayerId, State) of
%%    try bet_handle:handle_player_reset_bet(PlayerId, State) of
    try bet_handle:handle_player_bet_reset(PlayerId, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("MSG_PLAYER_RESET_BET: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?GET_HERO_VERSUS_BOSS_AGAINST, PlayerId} = Msg, _From, State) ->
%%    try bet_handle:handle_player_bet({PlayerId, BetTupleList, ?MSG_PLAYER_BET}, State) of
    try mod_hero_versus_boss:get_against_record(PlayerId, ?GET_HERO_VERSUS_BOSS_AGAINST) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("GET_HERO_VERSUS_BOSS_AGAINST: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?GET_HERO_VERSUS_BOSS_AGAINST, PlayerId, HeroId} = Msg, _From, State) ->
    try mod_hero_versus_boss:get_against_record(PlayerId, HeroId, ?GET_HERO_VERSUS_BOSS_AGAINST) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("GET_HERO_VERSUS_BOSS_AGAINST: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?GET_ONE_ON_ONE_AGAINST, PlayerId} = Msg, _From, State) ->
    try mod_boss_one_on_one:get_against_record(PlayerId, ?GET_ONE_ON_ONE_AGAINST) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("GET_ONE_ON_ONE_AGAINST: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_PLAYER_BET, {PlayerId, BetTupleList}} = Msg, _From, State) ->
    try bet_handle:handle_player_bet_in_scene({PlayerId, BetTupleList, ?MSG_PLAYER_BET}, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("MSG_PLAYER_BET: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_PLAYER_LEAVE_GUESS_MISSION_BET, PlayerId} = Msg, _From, State) ->
    ?DEBUG("handle_call: ~p", [Msg]),
    try bet_handle:handle_player_leave_bet(PlayerId, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("MSG_PLAYER_LEAVE_GUESS_MISSION_BET: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_PLAYER_INTO_GUESS_MISSION_BET, {PlayerId, BetTupleList}} = Msg, _From, State) ->
    try bet_handle:handle_player_bet({PlayerId, BetTupleList, ?MSG_PLAYER_INTO_GUESS_MISSION_BET}, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("MSG_PLAYER_INTO_GUESS_MISSION_BET: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_SCENE_WAIT_SKILL, ThisMsg} = Msg, _From, State) ->
    try scene_wait_skill:handle_msg(ThisMsg, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_MISSION_MSG, Msg}, _From, State) ->
    try mission_handle:handle_msg(Msg, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("MSG_MISSION_MSG: ~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?SCENE_ADJUST_MSG, ThisMsg} = Msg, _From, State) ->
    try scene_adjust:handle_msg(ThisMsg, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call({?MSG_SCENE_MATCH_SCENE, ThisMsg} = Msg, _From, State) ->
    try match_scene:handle_msg(ThisMsg, State) of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call(?MSG_SCENE_STEP_BY_STEP_SY_FIGHT_MSG, _From, State) ->
    try mod_mission_step_by_step_sy:mission_start_fight() of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("MSG_SCENE_STEP_BY_STEP_SY_FIGHT_MSG: ~p", [{Reason, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call(?MSG_SCENE_STEP_BY_STEP_SY_GET_AWARD_MSG, _From, State) ->
    try mod_mission_step_by_step_sy:mission_get_award() of
        Result ->
            {reply, Result, State}
    catch
        _:Reason ->
            ?ERROR("MSG_SCENE_STEP_BY_STEP_SY_FIGHT_MSG: ~p", [{Reason, erlang:get_stacktrace()}]),
            {reply, {error, Reason}, State}
    end;
handle_call(?MSG_SCENE_GET_STATE, _From, State) ->
    {reply, State, State};
handle_call({?MSG_SCENE_DICT_KEY, Key}, _From, State) ->
    Result = get(Key),
    {reply, Result, State};
handle_call({sync, {Mod, Info} = Request}, _From, State) ->
    try Mod:on_scene_worker_info(Info, State) of
        Res ->
            {reply, {ok, Res}, State}
    catch
        T:E ->
            case api_common:api_error_to_enum(E, false) of
                ?P_FAIL ->  % 系统错误
                    ?ERROR("T:~p, E:~p, Stackrace:~p", [T, E, erlang:get_stacktrace()]),
                    ?ERROR("sync ===> SceneId:~p, Request:~p", [State#scene_state.scene_id, Request]);
                _ ->
                    skip
            end,
            {reply, {error, E}, State}
    end;
handle_call(_Request, _From, State) ->
    ?WARNING("场景未匹配消息:~p", [{handle_call, _Request}]),
    {reply, ok, State}.
handle_cast({?MSG_SCENE_PLAYER_SHOW_ACTION, PlayerId, ActionId}, State) ->
    ?TRY_CATCH(fun() ->
        ObjScenePlayer = ?GET_OBJ_SCENE_PLAYER(PlayerId),
        NoticePlayerIdList = mod_scene_grid_manager:get_subscribe_player_id_list(ObjScenePlayer#obj_scene_actor.grid_id),
        api_scene:notice_player_show_action(NoticePlayerIdList, PlayerId, ActionId)
               end()),
    {noreply, State};
handle_cast({?MSG_PLAYER_LEAVE_GUESS_MISSION_BET, PlayerId} = Msg, State) ->
    ?DEBUG("handle_cast: ~p", [Msg]),
    case catch bet_handle:handle_player_leave_bet(PlayerId, State) of
        {'EXIT', R} -> ?ERROR("hook player_leave_bet failure: ~p", [R]);
        _Res -> ok
    end,
    {noreply, State};
handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(?MSG_SCENE_STOP, State = #scene_state{scene_id = SceneId}) ->
    ?DEBUG("场景进程(~p)收到关闭消息", [{SceneId, self()}]),
    ?TRY_CATCH(deal_close(State)),
    {stop, normal, State};
handle_info({?MSG_SCENE_AUTO_FIGHT_SKILL, PlayerId, SkillId}, State) ->
    try handle_auto_fight_skill(PlayerId, SkillId) of
        _ -> ok
    catch
        T:E ->
            ?ERROR("T:~p, E:~p, Stackrace:~p", [T, E, erlang:get_stacktrace()])
    end,
    {noreply, State};
%%handle_info(?MSG_RELEASE_SCENE_WORKER, State = #scene_state{scene_id = SceneId}) ->
%%    OnlineCount = mod_scene_player_manager:get_obj_scene_player_count(),
%%    ?DEBUG("释放场景进程:~p~n", [{SceneId, self(), OnlineCount}]),
%%    case OnlineCount of
%%        0 ->
%%            ?TRY_CATCH(deal_close(State)),
%%            {stop, normal, State};
%%        _ ->
%%            {noreply, State#scene_state{is_scene_master_manage = false}}
%%    end;
%% MSG_MONSTER_INTELLECT_EVENT
%%handle_info({?MSG_MONSTER_BIRTH_EVENT, ObjId, Intellect} = Msg, State) ->
%%    try mod_scene_monster_manager:handle_birth_event(ObjId, Intellect, State)
%%    catch
%%        _:Reason ->
%%            ?ERROR("~p:~p~n", [Msg, {Reason, ObjId, erlang:get_stacktrace()}]),
%%            {reply, {error, Reason}, State}
%%    end,
%%    {noreply, State};
%%handle_info({?MSG_MONSTER_UNDER_ATTACK, MonsterId, PlayerId} = Msg, State) ->
%%    try mod_scene_monster_manager:handle_under_attack(MonsterId, PlayerId, State)
%%    catch
%%        _:Reason ->
%%            ?ERROR("~p:~p~n", [Msg, {Reason, PlayerId, erlang:get_stacktrace()}]),
%%            {reply, {error, Reason}, State}
%%    end,
%%    {noreply, State};
handle_info({?MSG_MONSTER_ENTER_MISSION_DELAY} = Msg, State) ->
    try mod_mission_hero_versus_boss:handle_monster_enter_mission()
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_HERO_ENTER_MISSION_DELAY} = Msg, State) ->
    try mod_mission_hero_versus_boss:handle_hero_enter_mission()
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_NOTICE_MONSTER_LEAVE, Winner} = Msg, State) ->
    try mod_mission_one_on_one:handle_notice_monster_leave(Winner)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
%%handle_info({?MSG_DELAY_NOTICE_MISSION_STATUS, StatusOut} = Msg, State) ->
%%    try mod_mission_hero_versus_boss:handle_delay_notice_status(State, StatusOut)
%%    catch
%%        _:Reason ->
%%            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
%%    end,
%%    {noreply, State};
handle_info({?MSG_NOTICE_MONSTER_POS, MonsterId, X, Y} = Msg, State) ->
    try mod_boss_one_on_one:update_monster_pos(MonsterId, X, Y)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_WAIT_SKILL, ThisMsg} = Msg, State) ->
    try scene_wait_skill:handle_msg(ThisMsg, State)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?SCENE_ADJUST_MSG, ThisMsg} = Msg, State) ->
    try scene_adjust:handle_msg(ThisMsg, State)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_MATCH_SCENE, ThisMsg} = Msg, State) ->
    try match_scene:handle_msg(ThisMsg, State)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({timeout, TimerRef, {module_timer, {Mod, Info} = Msg}}, State) ->
    try Mod:on_scene_worker_info(Info, TimerRef, State) of
        _ -> ok
    catch
        T:E ->
            case api_common:api_error_to_enum(E, false) of
                ?P_FAIL ->
                    ?ERROR("T:~p, E:~p, Stackrace:~p", [T, E, erlang:get_stacktrace()]),
                    ?ERROR("module_timer ===> SceneId:~p, Msg:~p, TimerRef:~p", [State#scene_state.scene_id, Msg, TimerRef]);
                _ ->
                    skip
            end
    end,
    {noreply, State};
handle_info({notify, {Mod, Info} = Msg}, State) ->
    try Mod:on_scene_worker_info(Info, State) of
        _ -> ok
    catch
        T:E ->
            case api_common:api_error_to_enum(E, false) of
                ?P_FAIL ->
                    ?ERROR("T:~p, E:~p, Stackrace:~p", [T, E, erlang:get_stacktrace()]),
                    ?ERROR("notify ===> SceneId:~p, Msg:~p", [State#scene_state.scene_id, Msg]);
                _ ->
                    skip
            end
    end,
    {noreply, State};
handle_info({?MSG_SCENE_MONSTER_USE_SKILL, RequestFightParam} = Msg, State) ->
    try scene_wait_skill:handle_monster_use_skill(RequestFightParam, State)
    catch
        _:Reason ->
            case Reason of
                ?ERROR_NOT_ACTION_TIME ->
                    noop;
                _ ->
                    ?ERROR("~p:~p~n", [Msg, {Reason, erlang:get_stacktrace()}])
            end
    end,
    {noreply, State};
handle_info(shot_all_player, State) ->
    try handle_shot_all_player(State)
    catch
        _:Reason ->
            ?ERROR("shot_all_player:~p~n", [{Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_PLAYER_COLLECT, PlayerId, ObjSceneItemId}, State) ->
    try mod_scene_item_manager:handle_player_collect(PlayerId, ObjSceneItemId, State)
    catch
        _:Reason ->
            ?ERROR("MSG_TRIGGER_NEXT_ROUND:~p~n", [{Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_GOLD_RANK_MSG = Msg, State) ->
    erlang:send_after(3000, self(), ?MSG_SCENE_GOLD_RANK_MSG),
    try scene_gold_rank:handle_notice_gold_rank()
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, get(?DICT_SCENE_ID), erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_FIGHT_MONSTER_LOG = Msg, State) ->
    erlang:send_after(60000, self(), ?MSG_SCENE_FIGHT_MONSTER_LOG),
    try monster_log:close_all_monster_log()
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, get(?DICT_SCENE_ID), erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_ADD_ANGER = Msg, #scene_state{scene_id = SceneId} = State) ->
    erlang:send_after(?SD_SKILL_ANGER_INTERVAL, self(), ?MSG_SCENE_ADD_ANGER),
    try handle_add_anger(State)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_SEND_MSG, PlayerId, Type, Id} = Msg, #scene_state{scene_id = SceneId} = State) ->
    try handle_send_msg(PlayerId, Type, Id)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_ALL_MONSTER_RECOVER_HP = Msg, #scene_state{scene_id = SceneId} = State) ->
    erlang:send_after(2000, self(), ?MSG_SCENE_ALL_MONSTER_RECOVER_HP),
    try mod_scene_monster_manager:handle_recover_all_monster_hp()
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_MONSTER_RECOVER_HP = Msg, #scene_state{scene_id = SceneId} = State) ->
    erlang:send_after(?SD_HP_MODE_HP_RECOVER_CD_TIME, self(), ?MSG_SCENE_MONSTER_RECOVER_HP),
    try mod_scene_monster_manager:handle_recover_monster_hp()
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_USE_FIGHT_ITEM, ItemId, PlayerId} = Msg, #scene_state{scene_id = SceneId} = State) ->
    try handle_use_item(ItemId, PlayerId)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_MISSION_ROUND_END = Msg, #scene_state{scene_id = SceneId} = State) ->
    try mission_handle:handle_round_end(State)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_MISSION_ROUND_END, EndRound} = Msg, #scene_state{scene_id = SceneId} = State) ->
    try mission_handle:handle_round_end(EndRound, State)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_DEAL_BUFF_HURT, ObjType, ObjId, EffectId, Hurt, ReleaserObjType, ReleaserObjId} = Msg, #scene_state{scene_id = SceneId} = State) ->
    try mod_buff:deal_hurt(ObjType, ObjId, EffectId, Hurt, ReleaserObjType, ReleaserObjId)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_DESTROY_ALL_MONSTER, State) ->
    try mod_scene_monster_manager:destroy_all_monster()
    catch
        _:Reason ->
            ?ERROR("DESTROY_ALL_MONSTER:~p~n", [{Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_REMOVE_SCENE_ITEM_LIST, ObjSceneItemIdList} = Msg, State) ->
    try mod_scene_item_manager:handle_remove_obj_scene_item_list(ObjSceneItemIdList)
    catch
        _:Reason ->
            ?ERROR("~p~n", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_PLAYER_DROP_ITEM_LIST, PlayerId, PropList} = Msg, State) ->
    try mod_scene_item_manager:handle_player_drop_item_list(PlayerId, PropList)
    catch
        _:Reason ->
            ?ERROR("玩家掉落物品:~p~n", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_NAVIGATE_RESULT, {Result, ?OBJ_TYPE_MONSTER, ObjId, {TargetX, TargetY}, NewMovePath}} = Msg, State) ->
    try mod_scene_monster_manager:handle_navigate_result({Result, ObjId, {TargetX, TargetY}, NewMovePath}, State)
    catch
        _:Reason ->
            ?ERROR("navigate:~p~n", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_NAVIGATE_RESULT, {Result, ?OBJ_TYPE_PLAYER, ObjId, {TargetX, TargetY}, NewMovePath}} = Msg, #scene_state{scene_id = SceneId} = State) ->
    try mod_scene_robot_manager:handle_navigate_result({Result, ObjId, {TargetX, TargetY}, NewMovePath}, State)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({apply, M, F, A} = Msg, #scene_state{scene_id = SceneId} = State) ->
    try erlang:apply(M, F, A)
    catch
        _:Reason ->
            ?ERROR("~p:~p~n", [Msg, {Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_PLAYER_LEAVE_ASYNC, PlayerId}, State) ->
    try mod_scene_player_manager:handle_player_leave(PlayerId, State) of
        _ ->
            handle_player_count_change(State)
%%            self() ! ?MSG_CHECK_CLOSE,
    catch
        _:Reason ->
%%            self() ! ?MSG_CHECK_CLOSE,
            ?ERROR("PLAYER_LEAVE_ASYNC: ~p", [{Reason, {?MSG_SCENE_PLAYER_LEAVE_ASYNC, PlayerId}}])
    end,
    {noreply, State};
handle_info({?MSG_FIGHT, RequestFightParam} = Msg, State = #scene_state{mission_type = _MissionType}) ->
    try mod_fight:fight(RequestFightParam, State)
    catch
        _:Reason ->
            put(?DICT_IS_FIGHT, false),
%%            if RequestFightParam#request_fight_param.obj_type == ?OBJ_TYPE_PLAYER ->
%%                noop;
%%                true ->
%%                    noop
%%            end,
%%            ?TRY_CATCH2(mod_fight:erase_balance_grid_list()),
            if
                Reason == ?ERROR_SKILL_CD_TIME -> noop;
                Reason == ?ERROR_ALREADY_BALANCE -> noop;
                Reason == ?ERROR_ALREADY_DIE -> noop;
                Reason == ?ERROR_NOT_ACTION_TIME -> noop;
                true ->
%%                    ?TRY_CATCH(api_fight:notice_fight_fail(RequestFightParam#request_fight_param.obj_id, ?P_FAIL)),
                    ?ERROR("MSG_FIGHT: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
            end
    end,
    {noreply, State};
handle_info({?MSG_SCENE_CREATE_MONSTER, SceneMonsterId} = Msg, State) ->
    try mod_scene_monster_manager:create_monster(SceneMonsterId, State)
    catch
        _:Reason ->
            ?ERROR("MSG_CREATE_MONSTER: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_CREATE_MONSTER_LIST, SceneMonsterIdList} = Msg, State) ->
    try mod_scene_monster_manager:create_monster_list(SceneMonsterIdList, State)
    catch
        _:Reason ->
            ?ERROR("MSG_CREATE_MONSTER_LIST: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_REMOVE_BUFF, ObjType, ObjId, Ref, IsForce} = Msg, State) ->
    try mod_buff:handle_remove_buff(ObjType, ObjId, Ref, IsForce)
    catch
        _:Reason ->
            ?ERROR("MSG_SCENE_REMOVE_BUFF: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_CLOCK_INTERVAL_BUFF, ObjType, ObjId, Ref} = Msg, State) ->
    try mod_buff:handle_interval_buff(ObjType, ObjId, Ref)
    catch
        _:Reason ->
            ?ERROR("MSG_SCENE_CLOCK_INTERVAL_BUFF: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_MISSION_MSG, Msg}, State) ->
    try mission_handle:handle_msg(Msg, State)
    catch
        _:Reason ->
            ?ERROR("handle_msg: ~p", [{Msg, Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_BROADCAST_CHAT_MSG, Msg}, State) ->
    try mod_scene:broadcast_chat_msg(Msg)
    catch
        _:Reason ->
            ?ERROR("BROADCAST_CHAT_MSG: ~p", [{Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_CREATE_MONSTER, MonsterId, BirthX, BirthY, Dir} = Msg, State) ->
    try mod_scene_monster_manager:create_monster(MonsterId, BirthX, BirthY, Dir, State)
    catch
        _:Reason ->
            ?ERROR("MSG_CREATE_MONSTER_WITH_DIR: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_CREATE_MONSTER, MonsterId, BirthX, BirthY} = Msg, State) ->
    try mod_scene_monster_manager:create_monster(MonsterId, BirthX, BirthY, State)
    catch
        _:Reason ->
            ?ERROR("MSG_CREATE_MONSTER: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_CREATE_MONSTER_BY_ARGS, CreateMonsterArgs} = Msg, State) ->
    try mod_scene_monster_manager:do_create_monster(CreateMonsterArgs, State)
    catch
        _:Reason ->
            ?ERROR("MSG_CREATE_MONSTER: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({timeout, TimerRef, {?MSG_SCENE_CREATE_MONSTER_2, MonsterId, BirthX, BirthY} = Msg}, State) ->
    try mod_scene_monster_manager:handle_create_monster_2(MonsterId, BirthX, BirthY, TimerRef, State)
    catch
        _:Reason ->
            ?ERROR("MSG_SCENE_CREATE_MONSTER_2: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({timeout, TimerRef, {timeout, ?SCENE_ADJUST_TIMER}} = Msg, State) ->
    try scene_adjust:handle_timer(TimerRef)
    catch
        _:Reason ->
            ?ERROR("timeout SCENE_ADJUST_TIMER: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_PLAYER_JOINT_MONSTER_POINT, PlayerId, MonsterId} = _Msg, State) ->
    try mod_scene_player_manager:handle_join_monster_point(PlayerId, MonsterId)
    catch
        _:_Reason -> noop
    end,
    {noreply, State};
handle_info(?MSG_SCENE_CHECK_CLOSE, State) ->
    case mod_scene_player_manager:get_obj_scene_player_count() of
        0 ->
            stop(self());
        _ ->
            noop
    end,
    {noreply, State};
handle_info({?MSG_SCENE_PLAYER_MOVE, PlayerId, GoX, GoY, MoveType, High, Time, ActionId} = Msg, State) ->
    try mod_scene_player_manager:handle_msg_player_move(PlayerId, GoX, GoY, MoveType, High, Time, ActionId, State)
    catch
        _:Reason ->
            if Reason == ?ERROR_ALREADY_DIE ->
                ?ERROR("PLAYER_MOVE: ~p", [{Reason, Msg}]);
                true ->
                    ?ERROR("PLAYER_MOVE: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
            end
    end,
    {noreply, State};
handle_info({?MSG_SCENE_PLAYER_DO_TRANSMIT, PlayerId, X, Y, CallBackFun}, State) ->
    try mod_scene_player_manager:handle_msg_player_transmit(PlayerId, X, Y, CallBackFun, State)
    catch
        _:Reason ->
            ?ERROR("SCENE_PLAYER_TRANSMIT: ~p~n", [{Reason, State#scene_state.map_id, PlayerId, X, Y}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_PLAYER_MOVE_STEP, PlayerId, X, Y}, State) ->
    try mod_scene_player_manager:handle_msg_player_move_step(PlayerId, X, Y, State)
    catch
        _:Reason ->
            ?TRY_CATCH(mod_scene_player_manager:correct_player_pos(PlayerId)),
            ?DEBUG("PLAYER_MOVE_STEP: ~p~n", [{Reason, State#scene_state.map_id, PlayerId, X, Y}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_PLAYER_STOP_MOVE, PlayerId, X, Y}, State) ->
    try mod_scene_player_manager:handle_msg_player_stop_move(PlayerId, X, Y, State)
    catch
        _:Reason ->
            ?TRY_CATCH(mod_scene_player_manager:correct_player_pos(PlayerId)),
            ?DEBUG("PLAYER_STOP_MOVE: ~p", [{Reason, {?MSG_SCENE_PLAYER_STOP_MOVE, PlayerId}}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_SYNC_PLAYER_DATA, PlayerId, SyncDataList}, State) ->
    try mod_scene_player_manager:handle_msg_sync_player_data(PlayerId, SyncDataList, State)
    catch
        _:Reason ->
            ?ERROR("SYNC_PLAYER_DATA: ~p", [{Reason, {?MSG_SCENE_SYNC_PLAYER_DATA, PlayerId, SyncDataList}, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_ASYNC_INIT, State) ->
    try async_init(State)
    catch
        _:Reason ->
            ?ERROR("MSG_ASYNC_INIT: ~p", [{Reason, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_MONSTER_HEART_BEAT, ObjSceneMonsterId} = Msg, State) ->
    try mod_scene_monster_manager:handle_heart_beat(ObjSceneMonsterId, State)
    catch
        _:Reason ->
            ?ERROR("怪物心跳失败: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_HERO_VERSUS_BOSS_FIGHTING, ObjInSceneId} = _Msg, State) ->
    try
        mod_hero_versus_boss:heartbeat(ObjInSceneId, State)
    catch
        _:Reason ->
            case Reason of
                stop_fighting -> ?DEBUG("已分胜负，停止败者英雄心跳");
                invalid_against_tuple ->
                    put(?FIGHTING_TUPLE, ?UNDEFINED),
                    ?DEBUG("无效目标: ~p", [ObjInSceneId]);
                {monster_attacker_dead, DeadMonsterId} ->
                    put(?FIGHTING_TUPLE, ?UNDEFINED),
                    ?DEBUG("boss攻击者已经死亡: ~p", [DeadMonsterId]);
                {monster_defender_dead, DeadMonsterId} ->
                    put(?FIGHTING_TUPLE, ?UNDEFINED),
                    ?DEBUG("boss受击者已经死亡: ~p", [DeadMonsterId]),
                    mod_hero_versus_boss:defender_dead(DeadMonsterId, ?OBJ_TYPE_MONSTER);
                {robot_attacker_dead, DeadRobotId} ->
                    put(?FIGHTING_TUPLE, ?UNDEFINED),
                    ?DEBUG("robot攻击者已经死亡: ~p", [DeadRobotId]);
                {robot_defender_dead, DeadRobotId} ->
                    put(?FIGHTING_TUPLE, ?UNDEFINED),
                    ?DEBUG("robot受击者已经死亡: ~p", [DeadRobotId]),
                    mod_hero_versus_boss:defender_dead(DeadRobotId, ?OBJ_TYPE_PLAYER);
                done -> ?DEBUG("打完了，不心跳: ~p", [ObjInSceneId]);
                O -> ?DEBUG("MSG_GUESS_BOSS_HEART_BEAT Error: ~p", [{ObjInSceneId, O, erlang:get_stacktrace()}])
            end
    end,
    {noreply, State};
handle_info({?MSG_GUESS_BOSS_HEART_BEAT, GuessBossObjId} = _Msg, State) ->
    try
        mod_mission_boss_fight:handle_guess_boss_heart_beat(GuessBossObjId, State)
    catch
        _:Reason ->
            case Reason of
                already_empty ->
                    %% 已经打完了，正在等待结算
                    {GuessBossStatus, Time} = get(?GUESS_MISSION_STATE),
                    ?DEBUG("已经打完了，正在等待结算: ~p ~p ~p", [GuessBossStatus, util_time:timestamp_to_datetime(Time div ?SECOND_MS), util_time:timestamp_to_datetime(util_time:timestamp())]);
                empty ->
                    %% 所有目标都死完了，5s后去结算
                    self() ! {?MSG_SCENE_ROBOT_FIGHT};
%%                    ?DEBUG("打完了，去结算: ~p", [get(?GUESS_MISSION_STATE)]),
%%                    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_ROUND_BALANCE, 5000);
                target_dead ->
                    %% 目标死完了，寻找下一个
                    self() ! {?MSG_GUESS_BOSS_HEART_BEAT, GuessBossObjId}, noop;
                heart_beat_obj_dead ->
                    %% 自己死了，停止心跳
                    noop;
                O ->
                    ?DEBUG("MSG_GUESS_BOSS_HEART_BEAT Error: ~p", [{Reason, O, erlang:get_stacktrace()}])
            end
    end,
    {noreply, State};
handle_info({?MSG_SCENE_ROBOT_FIGHT} = Msg, State) ->
%%    try mod_scene_robot_manager:handle_robot_fight(State)
    try
        {GuessState, _Time} = get(?GUESS_MISSION_STATE),
        if
            GuessState =:= ?TRUE -> ok;
%%                mod_boss_one_on_one:handle_robot_fight_each_other_new(State);
%%                mod_mission_boss_fight:handle_robot_fight_each_other(State);
            true -> true
        end
    catch
        _:Reason ->
            case Reason of
                already_empty ->
                    %% 已经打完了，正在等待结算
                    {GuessBossStatus, Time} = get(?GUESS_MISSION_STATE),
                    ?DEBUG("已经打完了!正在等待结算: ~p ~p ~p", [GuessBossStatus, util_time:timestamp_to_datetime(Time div ?SECOND_MS), util_time:timestamp_to_datetime(util_time:timestamp())]);
                empty ->
                    ?DEBUG("打完了，去结算: ~p", [get(?GUESS_MISSION_STATE)]),
                    mod_mission:send_msg_delay(?MSG_GUESS_MISSION_ROUND_BALANCE, 3000);
%%                    mod_mission:send_msg(?MSG_GUESS_MISSION_ROUND_BALANCE);
                false -> false;
                _ ->
                    ?ERROR("机器人互搂失败: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
            end
    end,
    {noreply, State};
handle_info({?MSG_SCENE_ROBOT_HEART_BEAT, RobotId} = Msg, State) ->
    try mod_scene_robot_manager:handle_robot_heart_beat(RobotId, State)
    catch
        _:Reason ->
            ?ERROR("机器人心跳失败: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info(?MSG_SCENE_CHECK_ROBOT, State = #scene_state{scene_id = SceneId}) ->
%%    ?DEBUG("机器人检测 ： ~p",[SceneId]),
    try mod_scene_robot_manager:handle_check_robot(State)
    catch
        _:Reason ->
            ?ERROR("机器人检测失败: ~p", [{Reason, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
%%handle_info({?MSG_SCENE_CREATE_ROBOT, PlayerId, RobotId, HeartBeatTime}, State) ->
%%    handle_info({?MSG_SCENE_CREATE_ROBOT, PlayerId, RobotId, HeartBeatTime, 1}, State);
handle_info({?MSG_SCENE_CREATE_ROBOT, ConfigRobotId, RobotId} = Msg, State) ->
    try mod_scene_robot_manager:create_robot(ConfigRobotId, RobotId)
    catch
        _:Reason ->
            ?ERROR("创建机器人失败: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_NOTICE_PLAYER_FIGHT, Out} = Msg, State) ->
    try mod_boss_one_on_one:notice_player_fight(Out) of
        Result -> ?DEBUG("one_on_one notice player: ~p", [Result])
    catch
        _:Reason ->
            ?ERROR("GET_ONE_ON_ONE_AGAINST: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
    end,
    {noreply, State};
%%handle_info(?MSG_SCENE_RECOVER_PLAYER_HP, State) ->
%%    try mod_scene_player_manager:handle_recover_hp(State)
%%    catch
%%        _:Reason ->
%%            ?ERROR("定时恢复玩家血量: ~p", [{Reason, erlang:get_stacktrace()}])
%%    end,
%%    {noreply, State};
%%handle_info({?MSG_SCENE_HANDLE_SKILL_MOVE, RobotId, TargetX, TargetY, StartTime, MoveLen, MoveTime, High} = Msg, State) ->
%%    try mod_scene_robot_manager:handle_skill_move(RobotId, TargetX, TargetY, StartTime, MoveLen, MoveTime, High)
%%    catch
%%        _:Reason ->
%%            ?ERROR("机器人位移失败: ~p", [{Reason, Msg, erlang:get_stacktrace()}])
%%    end,
%%    {noreply, State};
handle_info({?MSG_SCENE_DESTROY_MONSTER, ObjMonsterId, Type} = Msg, State = #scene_state{scene_id = SceneId}) ->
    try mod_scene_monster_manager:do_destroy_monster(ObjMonsterId, Type)
    catch
        _:Reason ->
            ?ERROR("销毁怪物失败: ~p", [{Reason, Msg, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({either_either, IsNext} = Msg, State = #scene_state{scene_id = SceneId}) ->
    try mod_mission_either:handle_either(IsNext, State)
    catch
        _:Reason ->
            ?ERROR("选择副本是否继续失败: ~p", [{Reason, Msg, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({cancel_kuang_bao, PlayerId} = Msg, State = #scene_state{scene_id = SceneId}) ->
    try handle_cancel_kuang_bao(PlayerId)
    catch
        _:Reason ->
            ?ERROR("取消狂暴状态: ~p", [{Reason, Msg, SceneId, erlang:get_stacktrace()}])
    end,
    {noreply, State};
handle_info({?MSG_SCENE_MONSTER_WILD_TIMEOUT, MonsterId}, State) ->
    ?CATCH(mod_scene_monster_manager:handle_monster_wild_timeout(MonsterId, State)),
    {noreply, State};
handle_info({'DOWN', _Ref, process, Owner, Reason}, State = #scene_state{owner = Owner}) ->
    if Reason == shutdown ->
        noop;
        true ->
            ?ERROR("Scene worker receive owner down:~p, ~p", [Reason, State])
    end,
    {stop, Reason, State};
handle_info({'DOWN', _Ref, process, SceneNavigateWorker, Reason}, State = #scene_state{scene_navigate_worker = SceneNavigateWorker}) ->
    ?ERROR("Scene worker receive scene_navigate_worker down:~p, ~p", [Reason, State]),
    {stop, Reason, State};
handle_info({'DOWN', _Ref, process, ClientWorker, Reason}, State) ->
    ?ERROR("Scene worker receive client worker down:~p", [Reason]),
    ?TRY_CATCH(handle_client_worker_down(ClientWorker, State)),
    {noreply, State};
handle_info(Info, State) ->
    ?WARNING("场景未匹配消息:~p", [{handle_info, Info}]),
    {noreply, State}.


terminate(Reason, State = #scene_state{scene_id = SceneId, mission_type = MissionType}) ->
    if Reason =/= normal andalso Reason =/= shutdown ->
        ?INFO("Scene worker terminate:~p, ~p~n", [Reason, State]);
        true ->
            noop
    end,

    ?INFO("场景进程(~p)销毁:~p", [{SceneId, self()}, Reason]),

    if
        MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT ->
            mod_mission_scene_boss:handle_terminate(State);
        true ->
            noop
    end,

%%    mod_scene:erase_scene_worker_info(self()),
%%    erlang:exit(MonsterWorker, kill),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%%===================================================================
%%% Internal functions
%%%===================================================================

async_init(State = #scene_state{scene_id = SceneId, scene_type = SceneType, is_hook_scene = IsHookScene, mission_type = _MissionType, extra_data_list = ExtraDataList}) ->
    if
        SceneType == ?SCENE_TYPE_WORLD_SCENE andalso IsHookScene ->
            IsGame = mod_server:is_game_server(),

            if IsGame ->
                %% 创建机器人
                case util_list:opt(is_single, ExtraDataList) of
                    true ->
                        noop;
                    _ ->
                        mod_scene_robot_manager:init_scene(SceneId)
                end;
                true ->
                    noop
            end,
            mod_scene_event_manager:init(State);
        SceneType == ?SCENE_TYPE_WORLD_SCENE ->
            mod_scene_monster_manager:create_all_monster(State);
        SceneType == ?SCENE_TYPE_MISSION ->
            %% 创建回合怪物
            mission_handle:trigger_next_round(State);
        SceneType == ?SCENE_TYPE_MATCH_SCENE ->
            mod_scene_event_manager:init(State);
        true ->
            noop
    end.

deal_close(State = #scene_state{scene_type = _SceneType}) ->
    handle_shot_all_player(State).

handle_shot_all_player(State = #scene_state{scene_id = SceneId}) ->
    ObjScenePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
    lists:foreach(
        fun(PlayerId) ->
            #obj_scene_actor{
                client_worker = ClientWorker,
                is_robot = IsRobot
            } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
            ?WARNING("强制踢出玩家:~p", [{SceneId, PlayerId, IsRobot}]),
            try mod_scene_player_manager:handle_player_leave(PlayerId, State)
            catch _:Reason ->
                ?ERROR("强制踢出玩家: ~p", [{Reason, {PlayerId, SceneId, erlang:get_stacktrace()}}])
            end,
            if IsRobot =/= true ->
                client_worker:apply(
                    ClientWorker,
                    mod_scene,
                    return_world_scene,
                    [PlayerId, true, false]
                );
                true ->
                    noop
            end
        end,
        ObjScenePlayerIdList
    ).

handle_client_worker_down(ClientWorker, State = #scene_state{scene_id = SceneId}) ->
    case get({client_worker_map, ClientWorker}) of
        ?UNDEFINED ->
            noop;
        PlayerId ->
            try mod_scene_player_manager:handle_player_leave(PlayerId, State)
            catch _:Reason ->
                ?ERROR("离开场景进程失败: ~p", [{Reason, {handle_client_worker_down, ClientWorker, SceneId, PlayerId}, erlang:get_stacktrace()}])
            end,
            handle_player_count_change(State)
    end.

handle_player_count_change(#scene_state{is_scene_master_manage = IsSceneMasterManage}) ->
    if
        IsSceneMasterManage ->
            {{NowCount, _}, _} = mod_scene_player_manager:get_player_info(),
%%            NowCount = mod_scene_player_manager:get_obj_scene_player_count(),
            %%由 scene_master 管理的场景， 需要告诉scene_master 更新当前进程人数
            scene_master:update_scene_player_count(self(), NowCount);
        true ->
            noop
    end.


handle_use_item(ItemId, PlayerId) ->
    ObjScenePlayer = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    #obj_scene_actor{
        x = X,
        y = Y,
        init_move_speed = InitMoveSpeed,
        move_speed = OriMoveSpeed
    } = ObjScenePlayer,
    match_scene:handle_use_skill(PlayerId, ItemId),
    Now = util_time:milli_timestamp(),
    case ItemId of
        ?ITEM_SKILL_BOOK_1 ->
            NewMoveSpeed = max(OriMoveSpeed, floor(InitMoveSpeed * ?SD_SPEED_MOVE_PARAMETER / 10000)),
            NewEndTime = Now + ?SD_SPEED_TIME,
            ?UPDATE_OBJ_SCENE_PLAYER(ObjScenePlayer#obj_scene_actor{
                move_speed = NewMoveSpeed,
                kuang_bao_time = NewEndTime
            }),
%%            ?DEBUG("~p add Speed! OriMoveSpeed ~p, NewMoveSpeed ~p, NewEndTime ~p", [PlayerId, OriMoveSpeed, NewMoveSpeed, NewEndTime]),
            case NewMoveSpeed /= OriMoveSpeed of
                false -> skip;
                true ->
                    api_scene:notice_player_attr_change(mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId, [{?P_MOVE_SPEED, NewMoveSpeed}])
            end,
            api_scene:notice_player_kuangbao_info(mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId, floor(NewEndTime / 1000)),
            erlang:send_after(?SD_SPEED_TIME, self(), {cancel_kuang_bao, PlayerId});
        ?ITEM_SKILL_BOOK_2 ->
            NewFrozenEndTime = Now + ?SD_FREEZE_PARAMETER,
            Func =
                fun(MonId) ->
                    MonsterObj = ?GET_OBJ_SCENE_MONSTER(MonId),
                    #obj_scene_actor{
                        obj_id = MonId,
                        x = X1,
                        y = Y1,
                        can_action_time = CanActionTime,
                        grid_id = GridId1,
                        is_all_sync = IsAllSync,
                        destroy_time_ms = OriDestroyTime,
                        kind = Kind
                    } = MonsterObj,
                    Dis = util_math:get_distance({X, Y}, {X1, Y1}),
                    #t_monster_kind{
                        can_be_frozen = CanBeFrozen
                    } = mod_scene_monster_manager:get_t_monster_kind(Kind),
                    case Dis < ?TILE_LEN_2_PIX_LEN(?SD_FREEZE_BALANCE_GRID) of  %% 冰冻范围内
                        true when CanBeFrozen == ?TRUE ->
                            NewDestroyTime = ?IF(OriDestroyTime > 0, OriDestroyTime + max(0, min(NewFrozenEndTime - CanActionTime, ?SD_FREEZE_PARAMETER)), 0),
                            ?UPDATE_OBJ_SCENE_MONSTER(MonsterObj#obj_scene_actor{
                                move_path = [],
                                go_x = 0,
                                go_y = 0,
                                is_wait_navigate = false,
                                can_action_time = NewFrozenEndTime,
                                bing_don_end_time = NewFrozenEndTime,
                                destroy_time_ms = NewDestroyTime,
                                wait_skill_info = ?UNDEFINED
                            }),
                            case IsAllSync of
                                true ->
                                    api_scene:notice_monster_stop_move(mod_scene_player_manager:get_all_obj_scene_player_id(), MonId, X1, Y1);
                                false ->
                                    api_scene:notice_monster_stop_move(mod_scene_grid_manager:get_subscribe_player_id_list(GridId1), MonId, X1, Y1)
                            end,
                            {true, {MonId, NewDestroyTime, NewFrozenEndTime}};
                        _ ->
                            false
                    end
                end,
            FrozenMonList = lists:filtermap(Func, mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER)),
            api_fight:notice_frozen_monster(mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId, FrozenMonList)
    end.

handle_cancel_kuang_bao(PlayerId) ->
    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
        ?UNDEFINED ->
            noop;
        ObjScenePlayer ->
            #obj_scene_actor{
                init_move_speed = InitMoveSpeed,
                kuang_bao_time = KuangBaoTime
            } = ObjScenePlayer,
            Now = util_time:milli_timestamp(),
            if
                Now >= KuangBaoTime ->
                    ?UPDATE_OBJ_SCENE_PLAYER(ObjScenePlayer#obj_scene_actor{
                        move_speed = InitMoveSpeed,
                        kuang_bao_time = 0
                    }),
                    api_scene:notice_player_attr_change(mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId, [{?P_MOVE_SPEED, InitMoveSpeed}]);
                true ->
                    noop
            end
    end.

%% @doc 发送消息
handle_send_msg(PlayerId, Type, Id) ->
    #obj_scene_actor{
        grid_id = GridId
    } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    PlayerIdList = mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
    api_scene:notice_send_msg(PlayerIdList, PlayerId, Type, Id).

handle_add_anger(_State) ->
    lists:foreach(
        fun(R) ->
            #obj_scene_actor{
                obj_id = PlayerId,
                is_robot = IsRobot,
                anger = Anger,
                is_can_add_anger = IsCanAddAnger
            } = R,
            if Anger < ?SD_SKILL_ANGER_TOTAL andalso IsCanAddAnger ->
                NewAnger = min(Anger + ?SD_SKILL_ANGER_REPLY_VALUE, ?SD_SKILL_ANGER_TOTAL),
                ?UPDATE_OBJ_SCENE_PLAYER(R#obj_scene_actor{
                    anger = NewAnger
                }),
                if
                    NewAnger =/= Anger andalso IsRobot == false ->
                        api_scene:notice_anger(PlayerId, NewAnger);
                    true ->
                        noop
                end;
                true ->
                    noop
            end
        end,
        mod_scene_player_manager:get_all_obj_scene_player()
    ).

%% @doc 自动发送战斗技能
handle_auto_fight_skill(PlayerId, SkillId) ->
    {RequestFightParam, CdTime, EndTime} = get({?MSG_SCENE_AUTO_FIGHT_SKILL, PlayerId, SkillId}),
    Now = util_time:milli_timestamp(),
    ObjScenePlayer = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    if
        EndTime >= Now andalso ObjScenePlayer =/= ?UNDEFINED ->
            self() ! {?MSG_FIGHT, RequestFightParam},
            erlang:send_after(CdTime, self(), {?MSG_SCENE_AUTO_FIGHT_SKILL, PlayerId, SkillId});
        true ->
            erase({?MSG_SCENE_AUTO_FIGHT_SKILL, PlayerId, SkillId})
    end.