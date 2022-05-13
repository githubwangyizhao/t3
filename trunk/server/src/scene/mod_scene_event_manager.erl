%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%     场景事件管理
%%% @end
%%% Created : 03. 8月 2021 下午 03:22:12
%%%-------------------------------------------------------------------
-module(mod_scene_event_manager).
-author("Administrator").

-include("common.hrl").
-include("scene.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("msg.hrl").
-include("p_message.hrl").
-include("system.hrl").

%% MSG
-export([
    send_msg/1,
    send_msg_after/2
]).
%% FUNCTION
-export([
    init/1,
    get_state/0,
    start_event/6,
    close_event/4,
    player_enter_scene/1,
    get_event_type_end_time/2
]).
%% EVENT
-export([
    get_scene_event_value/0,
    set_scene_event_value/1
]).
-export([
    get_random_pos_1/0,
    handle_close_blind_box/1,
    trigger_task/3
]).

%% 处理模块消息
-export([
    on_scene_worker_info/2,
    on_scene_worker_info/3
]).

-record(?MODULE, {
    waiting_events = [] :: list(),                  %% 等待开启的事件队列 [#scene_loop_time_event{} | ...]
    opening_events = [] :: list(),                  %% 已经开启的事件队列 [#m_scene_notice_time_stop_toc{} | ...]
    scene_monster_state,                            %% 场景刷怪状态 {刷怪状态(鱼潮，boss，宝箱), 开启时间戳}
    is_hangup = false :: false | {true, integer()}, %% 等待事件队列是否被挂起 (false | {true, 挂起时间})
    event_timer_ref                                 %% 事件定时器引用
}).

-define(SCENE_LOOP_YU_CHAO_LIST, scene_loop_yu_chao_list).
-define(SCENE_LOOP_FUNCTION_CACHE_LIST, scene_loop_function_cache_list).
-define(SCENE_LOOP_EVENT_END_TIME, scene_loop_event_end_time).

%% ----------------------------------
%% @doc 	发送消息
%% @throws 	none
%% @end
%% ----------------------------------
send_msg(Info) ->
    send_msg(self(), Info).
send_msg(ScenePid, Info) when is_pid(ScenePid) ->
    ScenePid ! {notify, {?MODULE, Info}}.

%% ----------------------------------
%% @doc 	延迟发送消息
%% @throws 	none
%% @end
%% ----------------------------------
send_msg_after(0, Info) -> send_msg(Info);
send_msg_after(Time, Info) ->
    send_msg_after(self(), Time, Info).
send_msg_after(ScenePid, Time, Info) ->
    erlang:send_after(Time, ScenePid, {notify, {?MODULE, Info}}).

%% ----------------------------------
%% @doc 	定时器关闭事件
%% @throws 	none
%% @end
%% ----------------------------------
event_close_timer(Time, EventType, Params) -> event_close_timer(Time, EventType, Params, true).
event_close_timer(Time, EventType, Params, IsSaveTimer) ->
    Info = {?MSG_SCENE_LOOP_CLOSE_EVENT, {EventType, Params}},
    TimerRef = erlang:start_timer(Time, self(), {module_timer, {?MODULE, Info}}),
    if
        IsSaveTimer ->
            ?setModDict(event_timer_ref, TimerRef);
        true ->
            skip
    end,
    TimerRef.

%% ----------------------------------
%% @doc 	处理场景进程的模块消息
%% @throws 	none
%% @end
%% ----------------------------------
on_scene_worker_info({?MSG_SCENE_LOOP_YU_CHAO, Round, CreateMid, CreateNum, RemoveMid}, SceneState) ->
    handle_yu_chao(Round, CreateMid, CreateNum, RemoveMid, SceneState);
on_scene_worker_info(?MSG_SCENE_LOOP_TIME_CLOCK, SceneState) ->
    handle_event_loop(SceneState);
on_scene_worker_info({?MSG_SCENE_LOOP_MONSTER_DEATH, MonsterId, Group}, SceneState) ->
    handle_monster_death(MonsterId, Group, SceneState);
on_scene_worker_info({?MSG_SCENE_LOOP_MONSTER_DEATH_FIGHT, MonsterId, Group, X, Y}, SceneState) ->
    handle_monster_death_fight(MonsterId, Group, X, Y, SceneState);
on_scene_worker_info({?MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, State, CreateMonsterId, BirthX, BirthY}, SceneState) ->
    handle_create_guaji_monster(State, CreateMonsterId, 1, BirthX, BirthY, SceneState);
on_scene_worker_info({?MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, State, CreateMonsterId, Group, BirthX, BirthY}, SceneState) ->
    handle_create_guaji_monster(State, CreateMonsterId, Group, BirthX, BirthY, SceneState);
on_scene_worker_info({?MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, State, CreateMonsterId, Group}, SceneState) ->
    handle_create_guaji_monster(State, CreateMonsterId, Group, SceneState);
on_scene_worker_info({?MSG_SCENE_CREATE_BOSS_MONSTER, BossId, AliveTime}, SceneState = #scene_state{scene_id = SceneId}) ->
    %% 创建普通小怪
    create_boss_all_guaji_monster(BossId, SceneState),
    %% 创建boss
    #t_scene{
        boss_x_y_list = BossXYList
    } = mod_scene:get_t_scene(SceneId),
    BossPosList = util_random:get_list_random_member(BossXYList),
    [X, Y] = util_random:get_list_random_member(BossPosList),
    CreateMonsterArgs = #create_monster_args{
        monster_id = BossId,
        birth_x = X,
        birth_y = Y,
        live_time = AliveTime,
        dir = util_random:get_list_random_member([?DIR_UP, ?DIR_DOWN, ?DIR_LEFT, ?DIR_RIGHT, ?DIR_LEFT_UP, ?DIR_LEFT_DOWN, ?DIR_RIGHT_UP, ?DIR_LEFT_DOWN])
    },
    mod_scene_monster_manager:do_create_monster(CreateMonsterArgs, SceneState),
    mod_scene_robot_manager:handle_start_boss_event(BossId);
on_scene_worker_info(?MSG_SCENE_CREATE_ALL_MONSTER, SceneState) ->
    NowTime = util_time:timestamp(),
    set_monster_state(?SCENE_MASTER_STATE_MONSTER, NowTime),
    start_monster_state(SceneState);
on_scene_worker_info(?MSG_SCENE_LOOP_BOX_FINISHED, SceneState) ->
    handle_close_blind_box(SceneState);
on_scene_worker_info(?MSG_SCENE_LOOP_BALL_FINISHED, SceneState) ->
    handle_close_ball_event(SceneState);
on_scene_worker_info({try_update_scene_task, TaskIdList, AddNum}, SceneState) ->
    handle_try_update_scene_task(TaskIdList, AddNum, SceneState);
on_scene_worker_info(_Info, _SceneState) ->
    ?ERROR("unknow info: ~p", [_Info]).

on_scene_worker_info({?MSG_SCENE_LOOP_CLOSE_EVENT, {EventType, Params}}, TimerRef, SceneState) ->
    close_event(EventType, TimerRef, Params, SceneState);
on_scene_worker_info(_Info, _TimerRef, _SceneState) ->
    ?ERROR("unknow info: ~p, timerref ~p ", [_Info, _TimerRef]).

%% ----------------------------------
%% @doc 	开启鱼潮
%% @throws 	none
%% @end
%% ----------------------------------
start_event(?SCENE_TIME_EVENT_TYPE_YU_CHAO = EventType, Now, StartTime, ExistTime, _EventArgs, #scene_state{scene_id = SceneId} = SceneState) ->
%%    ?DEBUG("SceneId ~p ===>> 创建鱼潮!!!", [SceneId]),
    set_monster_state(?SCENE_MASTER_STATE_YU_CHAO, Now),
    handle_event_start(EventType, [], StartTime, Now + ExistTime, SceneState, true, true, {true, Now}),

    #t_scene{
        yuchao_list = YuChaoList,
        new_monster_x_y_list = NewMonsterXYList
    } = mod_scene:get_t_scene(SceneId),
    BirthYuChaoList = util_random:get_list_random_member(util:get_dict(?SCENE_LOOP_YU_CHAO_LIST, YuChaoList)),
    init_random_pos(NewMonsterXYList),
    lists:foldl(
        fun([Time, CreateMid, CreateNum, RemoveMid], Round) ->
            send_msg_after(Time, {?MSG_SCENE_LOOP_YU_CHAO, Round, CreateMid, CreateNum, RemoveMid}),
            Round + 1
        end,
        0,
        BirthYuChaoList
    ),
    put(?SCENE_LOOP_YU_CHAO_LIST, YuChaoList -- BirthYuChaoList),
    event_close_timer(ExistTime, EventType, [ExistTime]);

%% ----------------------------------
%% @doc 	开启boss事件
%% @throws 	none
%% @end
%% ----------------------------------
start_event(?SCENE_TIME_EVENT_TYPE_BOSS = EventType, Now, StartTime, ExistTime, [BossId] = _EventArgs, SceneState) ->
%%    ?DEBUG("SceneId ~p ===>> 创建boss!!!", [SceneId]),
    set_monster_state(?SCENE_MASTER_STATE_BOSS, Now),
    handle_event_start(EventType, [BossId], StartTime, Now + ExistTime, SceneState, true, false, {true, Now}),
    send_msg_after(1500, {?MSG_SCENE_CREATE_BOSS_MONSTER, BossId, ExistTime}),
    event_close_timer(ExistTime, EventType, [Now]);

%% ----------------------------------
%% @doc 	开启宝箱事件
%% @throws 	none
%% @end
%% ----------------------------------
start_event(?SCENE_TIME_EVENT_TYPE_BOX = EventType, Now, StartTime, ExistTime, _EventArgs, #scene_state{} = SceneState) ->
%%    ?DEBUG("SceneId ~p ===>> 创建宝箱怪!!!", [SceneId]),
    set_monster_state(?SCENE_MASTER_STATE_BOX, Now),
    handle_event_start(EventType, [], StartTime, Now + ExistTime, SceneState, true, true, {true, Now}),
    mod_blind_box:handle_start(SceneState),
    event_close_timer(ExistTime, EventType, [ExistTime]);

%% ----------------------------------
%% @doc 	刷出金币妖
%% @throws 	none
%% @end
%% ----------------------------------
start_event(?SCENE_TIME_EVENT_TYPE_GOLD_MONSTER = _EventType, Now, _StartTime, ExistTime, [Mid, GroupId] = _EventArgs, #scene_state{scene_id = SceneId} = SceneState) ->
%%    ?DEBUG("SceneId ~p ===>> 创建金币妖!!!", [SceneId]),
    CloseTime = Now + ExistTime,
    set_scene_event_value({true, {?SCENE_TIME_EVENT_TYPE_GOLD_MONSTER, Mid, CloseTime}}),
    api_scene:notice_scene_jbxy_state(mod_scene_player_manager:get_all_obj_scene_player_id(), true, Mid, round(CloseTime / 1000), ?UNDEFINED),
    #t_scene{
        new_monster_x_y_list = NewMonsterXYList
    } = mod_scene:get_t_scene(SceneId),
    [GroupId, _, _, PosList] = util_list:key_find(GroupId, 1, NewMonsterXYList),
    [X, Y] = util_random:get_list_random_member(PosList),
    CreateMonsterArgs = #create_monster_args{
        monster_id = Mid,
        birth_x = X,
        birth_y = Y,
        is_notice = true
    },
    mod_scene_monster_manager:do_create_monster(CreateMonsterArgs, SceneState),
    SceneState;

%% ----------------------------------
%% @doc 	刷出功能怪
%% @throws 	none
%% @end
%% ----------------------------------
start_event(?SCENE_TIME_EVENT_TYPE_FUNCTION_MONSTER = _EventType, _Now, _StartTime, _ExistTime, EventArgs, #scene_state{scene_id = SceneId} = SceneState) ->
    #t_scene{
        new_monster_x_y_list = NewMonsterXYList
    } = mod_scene:get_t_scene(SceneId),
    List = get_function_monster_cache_list(),
    {_Effect, FunctionMonsterGroupId, PosGroupIdList, FunctionMonsterId} = EventArgs,
    XYL = lists:append([XYList || [Group, _Min, _Max, XYList] <- NewMonsterXYList, lists:member(Group, PosGroupIdList)]),
    AllMonsterObjIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
    MonsterXyList = lists:foldl(
        fun(ObjMonsterId, TmpL) ->
            #obj_scene_actor{
                effect = EffectList,
                x = X,
                y = Y,
                is_boss = IsBoss
            } = ?GET_OBJ_SCENE_MONSTER(ObjMonsterId),
            Effect = get_effect(EffectList),
            if
                Effect > 0 andalso Effect /= 15 andalso IsBoss == false ->
                    [{X, Y} | TmpL];
                true ->
                    TmpL
            end
        end,
        [],
        AllMonsterObjIdList
    ),
    [X, Y] = hd(util_list:shuffle(get_function_monster_born_x_y_list(XYL, MonsterXyList))),
    mod_scene_monster_manager:create_monster_by_group(FunctionMonsterId, X, Y, 0, SceneState),
    set_function_monster_cache_list([{FunctionMonsterId, FunctionMonsterGroupId, PosGroupIdList} | List]);

%% ----------------------------------
%% @doc 	开启任务事件
%% @throws 	none
%% @end
%% ----------------------------------
start_event(?SCENE_TIME_EVENT_TYPE_TASK = EventType, Now, StartTime, _ExistTime, [TaskType] = _EventArgs, #scene_state{scene_id = SceneId} = SceneState) ->
    ScenePid = self(),
    case mod_cache:get({scene_worker_event_task, ScenePid}) of
        null ->
%%            ?DEBUG("SceneId ~p, ScenePid ~p ===>> 开启任务阶段1!", [SceneState#scene_state.scene_id, self()]),
            TaskId = get_rand_task_id(SceneId, TaskType),
            ExistTime = get_task_state_1_time(TaskId),
            Stage = 1,
            save_scene_task_info(#r_event_task{type = TaskType, id = TaskId, stage = Stage}),
            handle_event_start(EventType, [TaskType, Stage, TaskId], StartTime, Now + ExistTime, SceneState, false, false, {true, Now}),
            mod_scene_event:scene_task_start(TaskType, Stage),
            event_close_timer(ExistTime, EventType, []),
            ok;
        #r_event_task{type = TaskType, id = TaskId, status = 2, stage = 1} = OldTask -> %% 任务完成，进入第二阶段
%%            ?DEBUG("SceneId ~p, ScenePid ~p ===>> 开启任务阶段2!", [SceneState#scene_state.scene_id, self()]),
            remove_from_open_events(EventType),    %% 关闭第一阶段
            ExistTime = get_task_state_2_time(TaskId),
            Stage = 2,
            save_scene_task_info(OldTask#r_event_task{stage = Stage}),
            handle_event_start(EventType, [TaskType, Stage, TaskId], StartTime, Now + ExistTime, SceneState, false, false, false),
            event_close_timer(ExistTime, EventType, []),
            ok;
        _ ->
            skip
    end;

%% ----------------------------------
%% @doc 	开启彩球事件
%% @throws 	none
%% @end
%% ----------------------------------
start_event(?SCENE_TIME_EVENT_TYPE_LUCK_BALLS = EventType, Now, StartTime, ExistTime, [BallNum, CostRate] = _EventArgs, #scene_state{scene_id = SceneId} = SceneState) ->
    ScenePid = self(),
%%    ?DEBUG("SceneId ~p, ScenePid ~p ===>> 开启彩球事件! ~p", [SceneId, ScenePid, ExistTime]),
    set_monster_state(?SCENE_MASTER_STATE_BALL, Now),

    %% 记录将滞留在场景进程内的玩家id
    ScenePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
    mod_cache:update({scene_worker_stay_player_list, ScenePid}, ScenePlayerIdList),

    handle_event_start(EventType, [EventType, BallNum, CostRate], StartTime, Now + ExistTime, SceneState, true, true, {true, Now}),
    mod_scene_event:scene_ball_start(BallNum, CostRate, SceneState),
    event_close_timer(ExistTime, EventType, []);

%% ----------------------------------
%% @doc 	开启其他事件
%% @throws 	none
%% @end
%% ----------------------------------
start_event(EventType, Now, StartTime, ExistTime, _EventArgs, SceneState) ->
    handle_event_start(EventType, [], StartTime, Now + ExistTime, SceneState, false, false, false),
    event_close_timer(ExistTime, EventType, [], false).

%% ----------------------------------
%% @doc 	关闭鱼潮
%% @throws 	none
%% @end
%% ----------------------------------
close_event(?SCENE_TIME_EVENT_TYPE_YU_CHAO = EventType, TimerRef, _Params, SceneState) ->
    case ?getModDict(event_timer_ref) of
        TimerRef ->
%%            ?DEBUG("SceneId ~p ===>> 关闭鱼潮 ok!!!", [SceneState#scene_state.scene_id]),
            handle_event_close(EventType, SceneState, true, true);
        _ ->
            skip
    end;

%% ----------------------------------
%% @doc 	关闭boss
%% @throws 	none
%% @end
%% ----------------------------------
close_event(?SCENE_TIME_EVENT_TYPE_BOSS = EventType, TimerRef, _Params, SceneState) ->
    case ?getModDict(event_timer_ref) of
        TimerRef ->
%%            ?DEBUG("SceneId ~p ===>> 关闭boss ok!!!", [SceneState#scene_state.scene_id]),
            handle_event_close(EventType, SceneState, true, {true, 1500});
        _ ->
            skip
    end;

%% ----------------------------------
%% @doc 	关闭宝箱事件
%% @throws 	none
%% @end
%% ----------------------------------
close_event(?SCENE_TIME_EVENT_TYPE_BOX = EventType, TimerRef, _Params, SceneState) ->
    case ?getModDict(event_timer_ref) of
        TimerRef ->
%%            ?DEBUG("SceneId ~p ===>> 关闭宝箱怪 ok!!!", [SceneState#scene_state.scene_id]),
            mod_blind_box:handle_notice_reward(),
            handle_event_close(EventType, SceneState, true, true);
        _ ->
            skip
    end;

%% ----------------------------------
%% @doc 	关闭任务事件
%% @throws 	none
%% @end
%% ----------------------------------
close_event(?SCENE_TIME_EVENT_TYPE_TASK = EventType, TimerRef, _Params, SceneState) ->
    case ?getModDict(event_timer_ref) of
        TimerRef ->
%%            ?DEBUG("SceneId ~p, ScenePid ~p ===>> 关闭任务 ok!!!", [SceneState#scene_state.scene_id, self()]),
            #r_event_task{
                type = TaskType,
                stage = Stage
            } = mod_cache:get({scene_worker_event_task, self()}),
            delete_scene_task_info(),
            mod_scene_event:scene_task_close(TaskType, Stage),
            handle_event_close(EventType, SceneState, false, false);
        _ ->
            skip
    end;

%% ----------------------------------
%% @doc 	关闭彩球事件
%% @throws 	none
%% @end
%% ----------------------------------
close_event(?SCENE_TIME_EVENT_TYPE_LUCK_BALLS = EventType, TimerRef, _Params, SceneState) ->
    case ?getModDict(event_timer_ref) of
        TimerRef ->
            ScenePid = self(),
%%            ?DEBUG("SceneId ~p, ScenePid ~p ===>> 关闭彩球事件 ok!!!", [SceneState#scene_state.scene_id, ScenePid]),
            mod_cache:delete({scene_worker_stay_player_list, ScenePid}),    %% 清除场景进程内驻留的玩家数据
            mod_scene_event:scene_ball_close(),
            handle_event_close(EventType, SceneState, true, true);
        _ ->
            skip
    end;

%% ----------------------------------
%% @doc 	关闭其他事件
%% @throws 	none
%% @end
%% ----------------------------------`
close_event(EventType, _TimerRef, [] = _Params, SceneState) ->
    handle_event_close(EventType, SceneState, false, false).


%% ----------------------------------
%% @doc 	宝箱打完，事件提前结束
%% @throws 	none
%% @end
%% ----------------------------------
handle_close_blind_box(SceneState) ->
    {OldState, _} = get_state(),
    if
        OldState == ?SCENE_MASTER_STATE_BOX ->
%%            ?DEBUG("SceneId ~p ===>> 关闭宝箱怪 ok!!!", [SceneState#scene_state.scene_id]),
            mod_blind_box:handle_notice_reward(),
            handle_event_close(?SCENE_TIME_EVENT_TYPE_BOX, SceneState, true, true);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	彩球怪打完，事件提前结束
%% @throws 	none
%% @end
%% ----------------------------------
handle_close_ball_event(SceneState) ->
    {OldState, _} = get_state(),
    if
        OldState == ?SCENE_MASTER_STATE_BALL ->
%%            ?DEBUG("SceneId ~p, ScenePid ~p ===>> 提前结束彩球事件 ok!!!", [SceneState#scene_state.scene_id, self()]),
            mod_scene_event:scene_ball_close(),
            mod_cache:delete({scene_worker_stay_player_list, self()}),   %% 清除场景进程内驻留的玩家数据
            handle_event_close(?SCENE_TIME_EVENT_TYPE_BOX, SceneState, true, true);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	boss死亡，事件提前结束
%% @throws 	none
%% @end
%% ----------------------------------
close_boss_by_fight(SceneState) ->
    {OldState, _} = get_state(),
    if
        OldState == ?SCENE_MASTER_STATE_BOSS ->
%%            ?DEBUG("SceneId ~p ===>> 关闭boss ok!!!", [SceneState#scene_state.scene_id]),
            handle_event_close(?SCENE_TIME_EVENT_TYPE_BOSS, SceneState, true, {true, 1500});
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	保存任务信息
%% @throws 	none
%% @end
%% ----------------------------------
save_scene_task_info(RecTaskInfo) ->
    ServerType = mod_server_config:get_server_type(),
    SceneWorker = self(),
    if
        %% 同步任务信息到所有游戏服
        ServerType =:= ?SERVER_TYPE_WAR_AREA ->
            mod_server_rpc:cast_all_game_server(mod_cache, update, [{scene_worker_event_task, SceneWorker}, RecTaskInfo]);
        true ->
            noop
    end,
    mod_cache:update({scene_worker_event_task, SceneWorker}, RecTaskInfo).

%% ----------------------------------
%% @doc 	删除任务信息
%% @throws 	none
%% @end
%% ----------------------------------
delete_scene_task_info() ->
    ServerType = mod_server_config:get_server_type(),
    SceneWorker = self(),
    if
        ServerType =:= ?SERVER_TYPE_WAR_AREA ->
            mod_server_rpc:cast_all_game_server(mod_cache, delete, [{scene_worker_event_task, SceneWorker}]);
        true ->
            noop
    end,
    mod_cache:delete({scene_worker_event_task, SceneWorker}).

%% ----------------------------------
%% @doc 	触发场景任务完成
%% @throws 	none
%% @end
%% ----------------------------------
trigger_task(_PlayerId, [], _AddNum) -> skip;
trigger_task(_PlayerId, _TaskIdList, 0) -> skip;
trigger_task(PlayerId, TaskIdList, AddNum) ->
    #ets_obj_player{
        scene_id = SceneId,
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    if
        SceneWorker /= null andalso SceneId /= 0 ->
            case mod_cache:get({scene_worker_event_task, SceneWorker}) of
                #r_event_task{status = 1} ->  %% 任务进行中
                    scene_worker:notify_to_scene_worker(SceneWorker, {?MODULE, {try_update_scene_task, TaskIdList, AddNum}});
                _ ->
                    noop
            end;
        true ->
            skip
    end.

handle_try_update_scene_task(TaskIdList, AddNum, SceneState) ->
    SceneWorker = self(),
    case mod_cache:get({scene_worker_event_task, SceneWorker}) of
        #r_event_task{status = OriStatus, id = TaskId, done = OriDone, type = TaskType} = TaskInfo when OriStatus =:= 1 ->  %% 任务进行中
            case lists:member(TaskId, TaskIdList) of
                false -> skip;
                true ->
                    #t_monster_function_task{
                        task_list = ConditionList
                    } = t_monster_function_task:get({TaskId}),
                    [_, Target] = logic_code:tran_condition_list(ConditionList),
                    {NewDone, NewStatus} =
                        case OriDone + AddNum >= Target of
                            true ->
                                {min(OriDone + AddNum, Target), 2};
                            false ->
                                {OriDone + AddNum, OriStatus}
                        end,
                    mod_cache:update({scene_worker_event_task, SceneWorker}, TaskInfo#r_event_task{status = NewStatus, done = NewDone}),
                    if
                        NewDone /= OriDone ->    %% 通知任务更新
                            api_scene_event:notice_task_info();
                        true ->
                            skip
                    end,
                    if
                        NewStatus /= OriStatus ->   %% 任务完成
                            NowMilSec = util_time:milli_timestamp(),
                            mod_scene_event_manager:start_event(?SCENE_TIME_EVENT_TYPE_TASK, NowMilSec, NowMilSec, 0, [TaskType], SceneState);
                        true ->
                            skip
                    end
            end;
        _ ->    %% 无任务或任务已经被完成
            skip
    end.

%% ----------------------------------
%% @doc 	处理事件开始
%% @throws 	none
%% @end
%% ----------------------------------
handle_event_start(EventType, Params, StartTime, CloseTime, _SceneState, DestroyMonster, CreateMonster, Hangup) ->
    reset_scene_all_monster(DestroyMonster, CreateMonster),
    %% 其他事件暂时挂起
    case Hangup of
        false ->
            noop;
        {true, HangupTime} ->
            ?setModDict(is_hangup, {true, HangupTime}),
            api_scene:notice_time_event_list_sleep(mod_scene_player_manager:get_all_obj_scene_player_id())
    end,
    %% 通知事件开启
    Notice = #m_scene_notice_time_stop_toc{
        type = EventType,
        params = Params,
        time = CloseTime,
        start_time = StartTime
    },
    mod_socket:send_to_all_online_player(proto:encode(Notice)),
    ?setModDict(opening_events, [Notice | ?getModDict(opening_events)]).

%% ----------------------------------
%% @doc 	处理事件关闭
%% @throws 	none
%% @end
%% ----------------------------------
handle_event_close(EventType, _SceneState, DestroyMonster, CreateMonster) ->
    NowTime = util_time:milli_timestamp(),

    case ?getModDict(is_hangup) of
        false -> skip;
        {true, HangupTime} ->     %% 更新所有事件时间
            ?setModDict(is_hangup, false),
            DiffTime = NowTime - HangupTime,
%%            ?DEBUG("EventClose ===> SceneId ~p, EventType ~p, add ~p second !!!", [SceneState#scene_state.scene_id, EventType, DiffTime div 1000]),
            api_scene:notice_time_event_list_start(mod_scene_player_manager:get_all_obj_scene_player_id(), DiffTime),
            NewEvents = [
                TimeEvent#scene_loop_time_event{
                    time = OldTime + DiffTime
                } || TimeEvent = #scene_loop_time_event{time = OldTime} <- ?getModDict(waiting_events)],
            ?setModDict(waiting_events, NewEvents)
    end,
    reset_scene_all_monster(DestroyMonster, CreateMonster),
    ?setModDict(event_timer_ref, undefined),        %% 清除定时器引用
    remove_from_open_events(EventType).

%% ----------------------------------
%% @doc 	重置场景怪物
%% @throws 	none
%% @end
%% ----------------------------------
reset_scene_all_monster(DestroyMonster, CreateMonster) ->
    %% 销毁场景所有怪物
    case DestroyMonster of
        false ->
            noop;
        true ->
            mod_scene_monster_manager:destroy_all_monster(yuchao),
            %% 创建所有普通小怪
            case CreateMonster of
                false ->
                    noop;
                true ->
                    send_msg(?MSG_SCENE_CREATE_ALL_MONSTER);
                {true, DelayCreateTime} ->
                    send_msg_after(DelayCreateTime, ?MSG_SCENE_CREATE_ALL_MONSTER)
            end
    end.

%% ----------------------------------
%% @doc 	从已开启队列中移除事件
%% @throws 	none
%% @end
%% ----------------------------------
remove_from_open_events(EventType) ->
    ?setModDict(opening_events, lists:keydelete(EventType, #m_scene_notice_time_stop_toc.type, ?getModDict(opening_events))).

%% ----------------------------------
%% @doc 	处理事件循环
%% @throws 	none
%% @end
%% ----------------------------------
handle_event_loop(SceneState) ->
    Now = util_time:milli_timestamp(),
    IsSleep = ?getModDict(is_hangup),
    case IsSleep of
        false ->
            OldEvents = ?getModDict(waiting_events),
            Events1 =
                lists:foldl(
                    fun(TimeEvent, TmpEvents) ->
                        case ?getModDict(is_hangup) of
                            false ->
                                #scene_loop_time_event{
                                    time = StartTime,
                                    event_type = EventType,
                                    event_arg = EventArg,
                                    exist_time = ExistTime
                                } = TimeEvent,
                                if
                                    StartTime =< Now ->
                                        set_event_type_end_time(EventType, Now + ExistTime),
                                        case EventType of
                                            ?SCENE_TIME_EVENT_TYPE_START_NEW_LOOP ->
                                                TmpEvents ++ get_new_loop_list(Now, SceneState);
                                            _ ->
                                                start_event(EventType, Now, StartTime, ExistTime, EventArg, SceneState),
                                                TmpEvents
                                        end;
                                    true ->
                                        [TimeEvent | TmpEvents]
                                end;
                            _ ->
                                [TimeEvent | TmpEvents]
                        end
                    end,
                    [],
                    OldEvents
                ),
            NewEvents = lists:keysort(#scene_loop_time_event.time, Events1),
            if
                NewEvents == OldEvents ->
                    noop;
                true ->
                    ?setModDict(waiting_events, NewEvents)
            end;
        _ ->
            noop
    end,
    NextTime = max(0, (Now div ?SECOND_MS + 1) * ?SECOND_MS - Now),
    send_msg_after(NextTime, ?MSG_SCENE_LOOP_TIME_CLOCK),
    SceneState.

%% @doc 鱼潮
handle_yu_chao(_Round, CreateMid, CreateNum, RemoveMid, SceneState) ->
    put(tmp_create_num, 0),
    Min = CreateNum div 10,
    util:run(
        fun() ->
            [X2, Y2] = get_random_pos(),
            [X3, Y3] = [X2 + util_random:random_number(-400, 400), Y2 + util_random:random_number(-400, 400)],
            [X4, Y4] =
                case mod_map:can_walk_pix(get(?DICT_MAP_ID), X3, Y3) of
                    true ->
                        [X3, Y3];
                    _ ->
                        [X2, Y2]
                end,
            TmpCreateNum = get(tmp_create_num),
            put(tmp_create_num, TmpCreateNum + 1),
            RandomTime = if TmpCreateNum < Min ->
                util_random:random_number(0, 200);
                             true ->
                                 util_random:random_number(0, 3000)
                         end,
            send_msg_after(50 + RandomTime, {?MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, get_state(), CreateMid, 0, X4, Y4})
        end,
        CreateNum
    ),
    if RemoveMid > 0 ->
        mod_scene_monster_manager:destroy_monster_by_monster_id(RemoveMid);
        true ->
            noop
    end,
    SceneState.

handle_monster_death(DeleteMonsterId, Group, SceneState) ->
    #t_monster{
        is_boss = IsBoss
    } = mod_scene_monster_manager:get_t_monster(DeleteMonsterId),
    {State, _StartTime} = get_state(),
    function_monster_death(false, DeleteMonsterId, SceneState),
    if
        State == ?SCENE_MASTER_STATE_YU_CHAO ->
            noop;
        IsBoss == ?FALSE ->
            case delete_guaji_monster(DeleteMonsterId) of
                false ->
                    %% 跑去攻击玩家的怪物在清除后
                    ?IF(get({?SCENE_MONSTER_ATTACK_PLAYER, DeleteMonsterId}) =:= ?UNDEFINED, ?TRUE, put({?SCENE_MONSTER_ATTACK_PLAYER, DeleteMonsterId}, [])),
                    noop;
                _ ->
                    List = get_guaji_monster(),
                    CreateMonsterId = get_birth_monster_id(List),
                    add_guaji_monster(CreateMonsterId),
                    #t_monster{
                        rebirth_time = RebirthTime
                    } = t_monster:assert_get({CreateMonsterId}),
                    send_msg_after(RebirthTime, {?MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, get_state(), CreateMonsterId, Group})
            end;
        true ->
            noop
    end,
    SceneState.

handle_monster_death_fight(DeleteMonsterId, Group, DeathX, DeathY, SceneState) ->
    #t_monster{
        is_boss = IsBoss
    } = mod_scene_monster_manager:get_t_monster(DeleteMonsterId),
    {State, _} = get_state(),
    function_monster_death(true, DeleteMonsterId, SceneState),
    if
        State == ?SCENE_MASTER_STATE_YU_CHAO ->
            noop;
        IsBoss == ?TRUE ->
            close_boss_by_fight(SceneState);
        true ->
            case delete_guaji_monster(DeleteMonsterId) of
                false ->
                    noop;
                _ ->
                    List = get_guaji_monster(),
                    MonsterId = get_birth_monster_id(List),
                    add_guaji_monster(MonsterId),
                    #t_monster{
                        rebirth_time = RebirthTime
                    } = t_monster:assert_get({MonsterId}),
                    {NewGroup, [X, Y]} =
                        case util_random:p(?SD_DEAD_REFLASH_RATE) of
                            true ->
                                {Group, get_fight_random_birth_x_y(DeathX, DeathY)};
                            false ->
                                delete_random_pos_group(Group),
                                get_random_pos()
                        end,
                    send_msg_after(RebirthTime, {?MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, get_state(), MonsterId, NewGroup, X, Y})
            end
    end,
    SceneState.

handle_create_guaji_monster(State, MonsterId, Group, BirthX, BirthY, SceneState) ->
    case get_state() of
        State ->
            mod_scene_monster_manager:create_monster_by_group(MonsterId, BirthX, BirthY, Group, SceneState);
        _ ->
            noop
    end,
    SceneState.

handle_create_guaji_monster(State, MonsterId, Group, SceneState) ->
    case get_state() of
        State ->
            delete_random_pos_group(Group),
            create_guaji_monster_by_group(MonsterId, SceneState);
        _ ->
            noop
    end,
    SceneState.

%% =============================================== FUNCTION =======================================================

%% @doc 初始化
init(#scene_state{scene_id = SceneId} = SceneState) ->
    #t_scene{
        time_list = ConfigTimeList,
        function_monster_list = FunctionMonsterList,
        function_monster_time_list = ConfigFunctionMonsterTimeList
    } = mod_scene:get_t_scene(SceneId),
    Now = util_time:milli_timestamp(),
    StartTime = (Now div ?SECOND_MS + 1) * ?SECOND_MS,
    set_monster_state(?SCENE_MASTER_STATE_MONSTER, StartTime),

    NewConfigTimeList = ConfigTimeList ++ [[?SECOND_MS * 3, [[?SCENE_TIME_EVENT_TYPE_START_NEW_LOOP, 0, [], 1]]]],
    {_, TimeList} = lists:foldl(
        fun([WaitTime, EventWeightList], {TmpStartTime, TmpL}) ->
            EventWeightList1 = [{{EventType, Time, Args}, Weight} || [EventType, Time, Args, Weight] <- EventWeightList],
            {EventType, ExistTime, Args} = util_random:get_probability_item(EventWeightList1),
            NewTmpStartTime = TmpStartTime + WaitTime,
            {
                NewTmpStartTime,
                case EventType of
                    ?SCENE_TIME_EVENT_TYPE_START_NEW_LOOP ->
                        [#scene_loop_time_event{time = NewTmpStartTime, event_type = EventType, is_notice = false} | TmpL];
                    _ ->
                        [#scene_loop_time_event{time = NewTmpStartTime, event_type = EventType, event_arg = Args, exist_time = ExistTime} | TmpL]
                end
            }
        end,
        {StartTime, []},
        NewConfigTimeList ++ NewConfigTimeList
    ),

    NewFunctionMonsterList = util_list:shuffle(FunctionMonsterList),
    {_, FunctionMonsterTimeList} =
        lists:foldl(
            fun(WaitTime, {TmpL, TmpTimeL}) ->
                if
                    TmpL == [] ->
                        {TmpL, TmpTimeL};
                    true ->
                        [[FunctionMonsterGroupId, MonsterIdList, PosGroupIdList] | NewTmpL] = TmpL,
                        FunctionMonsterId = util_random:get_list_random_member(MonsterIdList),
                        #t_monster{
                            effect_list = EffectList
                        } = mod_scene_monster_manager:get_t_monster(FunctionMonsterId),
                        Effect = get_effect(EffectList),
                        {NewTmpL, [#scene_loop_time_event{time = StartTime + WaitTime, event_type = ?SCENE_TIME_EVENT_TYPE_FUNCTION_MONSTER, event_arg = {Effect, FunctionMonsterGroupId, PosGroupIdList, FunctionMonsterId}} | TmpTimeL]}
                end
            end,
            {NewFunctionMonsterList, []}, ConfigFunctionMonsterTimeList
        ),
    NewTimeList = lists:keysort(#scene_loop_time_event.time, TimeList ++ FunctionMonsterTimeList),
    ?setModDict(waiting_events, NewTimeList),

    start_monster_state(SceneState),
    send_msg_after(max(0, StartTime - Now), ?MSG_SCENE_LOOP_TIME_CLOCK).

get_new_loop_list(Now, #scene_state{scene_id = SceneId}) ->
    #t_scene{
        time_list = ConfigTimeList
    } = mod_scene:get_t_scene(SceneId),
    NewConfigTimeList = ConfigTimeList ++ [[?SECOND_MS * 3, [[?SCENE_TIME_EVENT_TYPE_START_NEW_LOOP, 0, [], 1]]]],
    TotalWaitTime = lists:sum([WaitTime || [WaitTime, _] <- ConfigTimeList]),
    StartTime = (Now div ?SECOND_MS + 1) * ?SECOND_MS + TotalWaitTime,
    {_, TimeList} = lists:foldl(
        fun([WaitTime, EventWeightList], {TmpStartTime, TmpL}) ->
            {EventType, ExistTime, Args} = util_random:get_probability_item([{{EventType, Time, Args}, Weight} || [EventType, Time, Args, Weight] <- EventWeightList]),
            NewTmpStartTime = TmpStartTime + WaitTime,
            {
                NewTmpStartTime,
                case EventType of
                    ?SCENE_TIME_EVENT_TYPE_START_NEW_LOOP ->
                        [#scene_loop_time_event{time = NewTmpStartTime, event_type = EventType, is_notice = false} | TmpL];
                    _ ->
                        [#scene_loop_time_event{time = NewTmpStartTime, event_type = EventType, event_arg = Args, exist_time = ExistTime} | TmpL]
                end
            }
        end,
        {StartTime, []}, NewConfigTimeList
    ),
    api_scene:notice_add_time_event_list(mod_scene_player_manager:get_all_obj_scene_player_id(), TimeList),
    TimeList.

%% @doc 玩家进入场景
player_enter_scene(PlayerId) ->
    EventList = ?getModDict(waiting_events),
    case ?getModDict(is_hangup) of
        false ->
            api_scene:notice_init_time_event_list([PlayerId], ?FALSE, 0, EventList);
        {true, HangupTime} ->
            api_scene:notice_init_time_event_list([PlayerId], ?TRUE, HangupTime, EventList)
    end,
    lists:foreach(
        fun(Data) ->
            mod_socket:send(PlayerId, proto:encode(Data))
        end,
        ?getModDict(opening_events)
    ),
    case mod_cache:get({scene_worker_event_task, self()}) of   %% 有任务
        #r_event_task{stage = 1} ->
            api_scene_event:notice_task_info();
        _ ->
            skip
    end.

%% @doc 开始普通怪物阶段
start_monster_state(SceneState) ->
    create_all_function_monster(SceneState),
    create_all_guaji_monster(SceneState).

create_all_function_monster(SceneState = #scene_state{scene_id = SceneId}) ->
    #t_scene{
        new_monster_x_y_list = NewMonsterXYList
    } = mod_scene:get_t_scene(SceneId),
    List = get_function_monster_cache_list(),
    lists:foreach(
        fun({MonsterId, _FunctionMonsterGroupId, PosGroupIdList}) ->
            XYL = lists:append([XYList || [Group, _Min, _Max, XYList] <- NewMonsterXYList, lists:member(Group, PosGroupIdList)]),
            AllMonsterObjIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
            MonsterXyList = lists:foldl(
                fun(ObjMonsterId, TmpL) ->
                    #obj_scene_actor{
                        effect = EffectList,
                        x = X,
                        y = Y,
                        is_boss = IsBoss
                    } = ?GET_OBJ_SCENE_MONSTER(ObjMonsterId),
                    Effect = get_effect(EffectList),
                    if
                        Effect > 0 andalso Effect /= 15 andalso IsBoss == false ->
                            [{X, Y} | TmpL];
                        true ->
                            TmpL
                    end
                end,
                [],
                AllMonsterObjIdList
            ),
            [X, Y] = hd(util_list:shuffle(get_function_monster_born_x_y_list(XYL, MonsterXyList))),
            mod_scene_monster_manager:create_monster_by_group(MonsterId, X, Y, 0, SceneState)
        end,
        List
    ).

%% @doc 功能怪死亡(第一个参数:是否战斗死亡)
function_monster_death(false, DeleteMonsterId, #scene_state{scene_id = SceneId}) ->
    FunctionMonsterCacheList = get_function_monster_cache_list(),
    case lists:keytake(DeleteMonsterId, 1, FunctionMonsterCacheList) of
        false ->
            noop;
        {value, {DeleteMonsterId, FunctionMonsterGroup, _}, List} ->
            set_function_monster_cache_list(List),
            #t_scene{
                function_monster_list = FunctionMonsterList,
                function_monster_param_list = [_KillRefreshTimeMin, _KillRefreshTimeMax, MonsterSumLimit, RefreshTimeMin, RefreshTimeMax]
            } = mod_scene:get_t_scene(SceneId),
            Now = util_time:milli_timestamp(),
            TimeList = ?getModDict(waiting_events),
            LiveNum = length(List),
            WaitRefreshNum = lists:foldl(
                fun(#scene_loop_time_event{time = Time}, TmpNum) ->
                    if
                        Time < Now + RefreshTimeMin ->
                            TmpNum + 1;
                        true ->
                            TmpNum
                    end
                end,
                0, TimeList
            ),
            RefreshTime =
                if
                    LiveNum + WaitRefreshNum =< MonsterSumLimit ->
                        Now + RefreshTimeMin;
                    true ->
                        Now + RefreshTimeMax
                end,
            [FunctionMonsterGroup, FunctionMonsterIdList, PosGroupIdList] = util_list:key_find(FunctionMonsterGroup, 1, FunctionMonsterList),
            FunctionMonsterId = util_random:get_list_random_member(FunctionMonsterIdList),
            #t_monster{
                effect_list = EffectList
            } = mod_scene_monster_manager:get_t_monster(FunctionMonsterId),
            NewSceneLoopTimeEvent = #scene_loop_time_event{
                time = RefreshTime,
                event_type = ?SCENE_TIME_EVENT_TYPE_FUNCTION_MONSTER,
                event_arg = {get_effect(EffectList), FunctionMonsterGroup, PosGroupIdList, FunctionMonsterId}
            },
            api_scene:notice_add_time_event_list(mod_scene_player_manager:get_all_obj_scene_player_id(), [NewSceneLoopTimeEvent]),
            ?setModDict(waiting_events, [NewSceneLoopTimeEvent | TimeList])
    end;
function_monster_death(true, DeleteMonsterId, #scene_state{scene_id = SceneId}) ->
    FunctionMonsterCacheList = get_function_monster_cache_list(),
    case lists:keytake(DeleteMonsterId, 1, FunctionMonsterCacheList) of
        false ->
            noop;
        {value, {DeleteMonsterId, FunctionMonsterGroup, _}, List} ->
            set_function_monster_cache_list(List),
            #t_scene{
                function_monster_list = FunctionMonsterList,
                function_monster_param_list = [KillRefreshTimeMin, KillRefreshTimeMax, _MonsterSumLimit, _RefreshTimeMin, _RefreshTimeMax]
            } = mod_scene:get_t_scene(SceneId),
            Now = util_time:milli_timestamp(),
            TimeList = ?getModDict(waiting_events),
            RefreshTime = Now + util_random:random_number(KillRefreshTimeMin, KillRefreshTimeMax),
            [FunctionMonsterGroup, FunctionMonsterIdList, PosGroupIdList] = util_list:key_find(FunctionMonsterGroup, 1, FunctionMonsterList),
            FunctionMonsterId = util_random:get_list_random_member(FunctionMonsterIdList),
            #t_monster{
                effect_list = EffectList
            } = mod_scene_monster_manager:get_t_monster(FunctionMonsterId),
            NewSceneLoopTimeEvent = #scene_loop_time_event{
                time = RefreshTime,
                event_type = ?SCENE_TIME_EVENT_TYPE_FUNCTION_MONSTER,
                event_arg = {get_effect(EffectList), FunctionMonsterGroup, PosGroupIdList, FunctionMonsterId}
            },
            api_scene:notice_add_time_event_list(mod_scene_player_manager:get_all_obj_scene_player_id(), [NewSceneLoopTimeEvent]),
            ?setModDict(waiting_events, [NewSceneLoopTimeEvent | TimeList])
    end.

create_all_guaji_monster(State = #scene_state{scene_id = SceneId}) ->
    #t_scene{
        new_monster_x_y_list = NewMonsterXyList,
        monster_born_list = MonsterBornList,
        monster_count = MonsterCount
    } = mod_scene:get_t_scene(SceneId),
    init_random_pos(NewMonsterXyList),
    List = lists:foldl(
        fun(_, TmpL) ->
            MonsterId = get_birth_monster_id(TmpL),
            {value, {MonsterId, Num, P, Min, Max}, TmpL2} = lists:keytake(MonsterId, 1, TmpL),
            create_guaji_monster_by_group(MonsterId, State),
            [{MonsterId, Num + 1, P, Min, Max} | TmpL2]
        end,
        [{M, 0, P, Min, Max} || [M, P, Min, Max] <- MonsterBornList],
        lists:seq(1, MonsterCount)
    ),
    update_guaji_monster(List).

create_boss_all_guaji_monster(BossId, State = #scene_state{scene_id = SceneId}) ->
    #t_scene{
        new_monster_x_y_list = NewMonsterXyList,
        boss_time_monster_born_list = MonsterBornList1,
        boss_time_monster_count = MonsterCount
    } = mod_scene:get_t_scene(SceneId),
    MonsterBornList = util_list:opt(BossId, MonsterBornList1),
    init_random_pos(NewMonsterXyList),
    List = lists:foldl(
        fun(_, TmpL) ->
            MonsterId = get_birth_monster_id(TmpL),
            {value, {MonsterId, Num, P, Min, Max}, TmpL2} = lists:keytake(MonsterId, 1, TmpL),
            create_guaji_monster_by_group(MonsterId, State),
            [{MonsterId, Num + 1, P, Min, Max} | TmpL2]
        end,
        [{M, 0, P, Min, Max} || [M, P, Min, Max] <- MonsterBornList],
        lists:seq(1, MonsterCount)
    ),
    update_guaji_monster(List).

init_random_pos_1(L) ->
    put(random_pos_1, util_list:shuffle(L)).
init_random_pos(L) ->
    put(random_pos, [{Group, 0, Min, Max, PosList} || [Group, Min, Max, PosList] <- L]).

get_birth_monster_id(TmpL) ->
    get_birth_monster_id(TmpL, TmpL).
get_birth_monster_id([], TmpL) ->
    util_random:get_probability_item([{MonsterId, P} || {MonsterId, Num, P, _Min, Max} <- TmpL, Num < Max]);
get_birth_monster_id([{MonsterId, Num, _P, Min, _Max} | _NewTmpL], _TmpL) when Num < Min ->
    MonsterId;
get_birth_monster_id([_ | _NewTmpL], TmpL) ->
    get_birth_monster_id(_NewTmpL, TmpL).

get_random_pos_1() ->
    L = get(random_pos_1),
    [X, Y] = hd(L),
    L1 = lists:delete([X, Y], L),
    put(random_pos_1, L1 ++ [[X, Y]]),
    [X, Y].
delete_random_pos_group(Group) ->
    L = get(random_pos),
    case lists:keytake(Group, 1, L) of
        false ->
            noop;
        {value, {Group, Num, Min, Max, PosList}, L1} ->
            if
                Num > 0 ->
                    put(random_pos, [{Group, Num - 1, Min, Max, PosList} | L1]);
                true ->
                    ?WARNING("有问题 : ~p", [{get(?DICT_SCENE_ID), get_state(), Group}]),
                    noop
            end
    end.
create_guaji_monster_by_group(MonsterId, State) ->
    case get_random_pos() of
        null ->
            noop;
        {Group, [X, Y]} ->
            mod_scene_monster_manager:create_monster_by_group(MonsterId, X, Y, Group, State)
    end.
get_random_pos() ->
    L = get(random_pos),
    MinList = [{Group, Num, Min, Max, PosList} || {Group, Num, Min, Max, PosList} <- L, Num < Min],
    if
        MinList == [] ->
            List = [{Group, Num, Min, Max, PosList} || {Group, Num, Min, Max, PosList} <- L, Num < Max],
            if
                List == [] ->
                    ?WARNING("分组配置错误，找不到可以生成的组了: ~p", [[{Group, Num, Min, Max} || {Group, Num, Min, Max, _PosList} <- L]]),
                    null;
                true ->
                    {Group, Num, Min, Max, PosList} = util_random:get_list_random_member(List),
                    Pos = util_random:get_list_random_member(PosList),
                    NewList = lists:keyreplace(Group, 1, L, {Group, Num + 1, Min, Max, PosList}),
                    put(random_pos, NewList),
                    {Group, Pos}
            end;
        true ->
            {Group, Num, Min, Max, PosList} = util_random:get_list_random_member(MinList),
            Pos = util_random:get_list_random_member(PosList),
            List = lists:keyreplace(Group, 1, L, {Group, Num + 1, Min, Max, PosList}),
            put(random_pos, List),
            {Group, Pos}
    end.

get_effect(EffectList) ->
    case EffectList of
        [] ->
            0;
        [ThisEffect] ->
            ThisEffect;
        [ThisEffect, _] ->
            ThisEffect
    end.

get_fight_random_birth_x_y(DeathX, DeathY) ->
    get_fight_random_birth_x_y(DeathX, DeathY, 3).
get_fight_random_birth_x_y(DeathX, DeathY, 0) ->
    [DeathX, DeathY];
get_fight_random_birth_x_y(DeathX, DeathY, Times) ->
    [ChangeX, ChangeY] = ?SD_DEAD_REFLASH_RANGE_LIST,
    [X, Y] = [DeathX + util_random:random_number(-ChangeX, ChangeX), DeathY + util_random:random_number(-ChangeY, ChangeY)],
    case mod_map:can_walk_pix(get(?DICT_MAP_ID), X, Y) of
        true ->
            [X, Y];
        _ ->
            get_fight_random_birth_x_y(DeathX, DeathY, Times - 1)
    end.

get_function_monster_born_x_y_list(XYL, MonsterXyList) ->
    IsNotInRangeFun =
        fun(ThisX, ThisY) ->
            lists:all(
                fun({MonsterX, MonsterY}) ->
                    abs(MonsterX - ThisX) > ?SD_FUNCTION_REFLASH_RANGE_LIMIT orelse abs(MonsterY - ThisY) > ?SD_FUNCTION_REFLASH_RANGE_LIMIT
                end,
                MonsterXyList
            )
        end,
    List = [[X, Y] || [X, Y] <- XYL, IsNotInRangeFun(X, Y)],
    if
        List == [] ->
            XYL;
        true ->
            List
    end.

%% 获取随机任务
get_rand_task_id(SceneId, TaskType) ->
    PlayerCount = mod_scene_player_manager:get_obj_scene_player_count(),
    TaskList = t_monster_function_task@group:get({SceneId, TaskType}),
    WeightList = [
        {Id, Weight} ||
        #t_monster_function_task{
            id = Id,
            player_limit_list = PlayerCountList,
            weight = Weight
        } <- TaskList, lists:member(PlayerCount, PlayerCountList) orelse PlayerCountList == []
    ],
    util_random:get_probability_item(WeightList).

%% 任务阶段1持续时间
get_task_state_1_time(TaskId) ->
    (t_monster_function_task:assert_get({TaskId}))#t_monster_function_task.task_time.

%% 任务阶段2持续时间
get_task_state_2_time(TaskId) ->
    (t_monster_function_task:assert_get({TaskId}))#t_monster_function_task.awark_time.

%% =============================================== DICT =======================================================
%% 更新刷怪状态
set_monster_state(Status, Now) ->
    ?setModDict(scene_monster_state, {Status, Now}).

%% 场景刷怪状态
get_state() -> ?getModDict(scene_monster_state).

update_guaji_monster(L) ->
    put(guaji_monster, L).

get_guaji_monster() ->
    case get(guaji_monster) of
        ?UNDEFINED ->
            [];
        L ->
            L
    end.

delete_guaji_monster(Mid) ->
    L = get_guaji_monster(),
    case lists:keytake(Mid, 1, L) of
        {value, {MonsterId, Num, P, Min, Max}, L1} ->
            L2 = [{MonsterId, max(0, Num - 1), P, Min, Max} | L1],
            update_guaji_monster(L2);
        false ->
            false
    end.
add_guaji_monster(Mid) ->
    L = get_guaji_monster(),
    L2 = case lists:keytake(Mid, 1, L) of
             {value, {MonsterId, Num, P, Min, Max}, L1} ->
                 [{MonsterId, Num + 1, P, Min, Max} | L1]
         end,
    update_guaji_monster(L2).

get_function_monster_cache_list() ->
    util:get_dict(?SCENE_LOOP_FUNCTION_CACHE_LIST, []).

set_function_monster_cache_list(List) ->
    put(?SCENE_LOOP_FUNCTION_CACHE_LIST, List).

get_scene_event_value() ->
    get(hook_scene_event_value).

set_scene_event_value(Data) ->
    put(hook_scene_event_value, Data).

set_event_type_end_time(EventType, EndTime) ->
    mod_cache:update({?SCENE_LOOP_EVENT_END_TIME, self(), EventType}, EndTime).

get_event_type_end_time(EventType, Pid) ->
    case mod_cache:get({?SCENE_LOOP_EVENT_END_TIME, Pid, EventType}) of
        null ->
            0;
        EndTime ->
            EndTime
    end.