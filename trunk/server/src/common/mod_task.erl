%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            任务模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_task).

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("server_data.hrl").

-export([
    init_task_show/1,           %% 初始化任务展示
    get_award/1,                %% 领取奖励
    try_update_player_task/3,   %% 更新任务
%%    condition_update_player_task/3, %% 特殊条件更新任务

    get_player_task_id/1,       %% 获取玩家任务id
    debug_set_task/2,           %% debug 调任务
    get_player_task_scene_id/1,

    get_db_player_task/1,       %% Db 获取玩家任务数据

    get_t_task/1,
    is_task_line_completed/1
]).

-export([
    %% 修复任务
    repair_task/0,
    refresh_player_task/1,
    refresh_all_player_task/0,
    do_refresh_player_task/1
]).

%% ----------------------------------
%% @doc 	判断主线任务是否全部完成
%% @throws 	none
%% @end
%% ----------------------------------
is_task_line_completed(PlayerId) ->
    #db_player_task{
        task_id = TaskId,
        status = Status
    } = get_db_player_task(PlayerId),
    TaskId == 0 orelse Status == ?AWARD_ALREADY.

%% ----------------------------------
%% @doc 	初始化玩家任务展示
%% @throws 	none
%% @end
%% ----------------------------------
init_task_show(PlayerId) ->
    DbPlayerTask = get_db_player_task(PlayerId),
    #db_player_task{
        task_id = TaskId,
        status = Status
    } = DbPlayerTask,
    if
        Status =/= ?AWARD_ALREADY ->
            {task, TaskId};
        true ->
            ?UNDEFINED
    end.

%% ----------------------------------
%% @doc 	领取奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_award(PlayerId) ->
    get_award(PlayerId, true).
get_award(PlayerId, IsCheck) ->
    DbPlayerTask = get_db_player_task(PlayerId),
    #db_player_task{
        player_id = PlayerId,
        task_id = TaskId,
        status = Status
    } = DbPlayerTask,
    if
        IsCheck ->
            ?ASSERT(Status == ?AWARD_CAN, ?ERROR_NO_FINISH);
        true ->
            noop
    end,
    #t_task{
        next_task = NextTaskId,
        award_id = AwardId
    } = get_t_task(TaskId),
    ?ASSERT(TaskId =/= NextTaskId, {task_repeated, NextTaskId}),
    Tran =
        fun() ->
            mod_award:give(PlayerId, AwardId, ?LOG_TYPE_FINISH_TASK),
            trigger_next_task(PlayerId, NextTaskId),
            hook:after_task_finish(PlayerId, TaskId)
        end,
    db:do(Tran),
    TaskId.

%% ----------------------------------
%% @doc 	触发下一任务
%% @throws 	none
%% @end
%% ----------------------------------
trigger_next_task(PlayerId, TaskId) when is_integer(PlayerId) ->
    trigger_next_task(get_db_player_task(PlayerId), TaskId);
trigger_next_task(DbPlayerTask, 0) ->
    NewPlayerTask = DbPlayerTask#db_player_task{
        task_id = 0,
        status = ?AWARD_ALREADY,
        update_time = util_time:timestamp()
    },
    db:write(NewPlayerTask),

    PlayerId = NewPlayerTask#db_player_task.player_id,
    mod_bounty_task:refresh_bounty_task_data(PlayerId),
    api_task:notice_task_change(NewPlayerTask),
    mod_daily_task:try_update_task_show(PlayerId),

    NewPlayerTask;
trigger_next_task(DbPlayerTask, TaskId) ->
    #db_player_task{
        player_id = PlayerId
    } = DbPlayerTask,
    #t_task{
        init_type = InitType,
        content_list = ContentList
    } = get_t_task(TaskId),
    [ConditionKey, NeedValue] = logic_code:tran_condition_list(ContentList),

    PlayerValue =
        case InitType of
            0 ->
                mod_conditions:get_player_conditions_data_number(PlayerId, ConditionKey);
            1 ->
                case ConditionKey of
                    {?CON_ENUM_GO_SCENE, SceneId} ->
                        #ets_obj_player{
                            scene_id = PlayerSceneId
                        } = mod_obj_player:get_obj_player(PlayerId),
                        if
                            PlayerSceneId == SceneId ->
                                1;
                            true ->
                                0
                        end;
                    _ ->
                        0
                end
        end,

    Status =
        case NeedValue of
            [Min, Max] ->
                if PlayerValue >= Min andalso PlayerValue =< Max ->
                    ?AWARD_CAN;
                    true ->
                        ?AWARD_NONE
                end;
            _ ->
                if
                    PlayerValue >= NeedValue ->
                        ?AWARD_CAN;
                    true ->
                        ?AWARD_NONE
                end
        end,

    NewPlayerTask = DbPlayerTask#db_player_task{
        task_id = TaskId,
        num = PlayerValue,
        status = Status,
        update_time = util_time:timestamp()
    },
    db:write(NewPlayerTask),
    api_task:notice_task_change(NewPlayerTask),
    mod_daily_task:try_update_task_show(PlayerId),
    NewPlayerTask.

%%%% ----------------------------------
%%%% @doc 	特殊条件触发完成任务(如前往场景，对话等等,这种任务默认从0开始)
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%condition_update_player_task(PlayerId, ConditionKey, Value) ->
%%    DbPlayerTask = get_db_player_task(PlayerId),
%%    #db_player_task{
%%        player_id = PlayerId,
%%        task_id = TaskId,
%%        status = State
%%    } = DbPlayerTask,
%%    T_Task = t_task:get({TaskId}),
%%    case T_Task =/= null andalso State =:= ?AWARD_NONE of
%%        true ->
%%            #t_task{
%%                content_list = ConditionList
%%            } = T_Task,
%%            [TaskConKey, _TaskConValue] = tran_condition_list(ConditionList),
%%            if
%%                ConditionKey =:= TaskConKey ->
%%                    try_update_player_task(DbPlayerTask, {?CONDITIONS_VALUE_ADD, Value});
%%                true ->
%%                    noop
%%            end;
%%        false ->
%%            noop
%%    end.

%% ----------------------------------
%% @doc 	触发完成任务
%% @throws 	none
%% @end
%% ----------------------------------
try_update_player_task(_PlayerId, [], _E) ->
    noop;
try_update_player_task(PlayerId, TaskIdList, E) when is_list(TaskIdList) ->
    DbPlayerTask = get_db_player_task(PlayerId),
    #db_player_task{
        player_id = PlayerId,
        task_id = TaskId
    } = DbPlayerTask,
    case lists:member(TaskId, TaskIdList) of
        true ->
            try_update_player_task(DbPlayerTask, E);
        false ->
            noop
    end.
try_update_player_task(DbPlayerTask, {Type, Value}) when is_integer(Value) ->
    #db_player_task{
        player_id = PlayerId,
        task_id = TaskId,
        num = OldNum,
        status = Status
    } = DbPlayerTask,
    if
        Status == ?AWARD_NONE ->
            #t_task{
                is_auto_finish = IsAutoFinish,
                content_list = ConditionList
            } = get_t_task(TaskId),
            [TaskType, NeedNum] = logic_code:tran_condition_list(ConditionList),
            RealNum =
                if Type == ?CONDITIONS_VALUE_ADD ->
                    OldNum + Value;
                    true ->
                        Value
                end,
            {NewNum, NewStatus} =
                case NeedNum of
                    [Min, Max] ->
                        ?DEBUG("范围任务更新:~p~n", [{PlayerId, TaskType, NeedNum, RealNum}]),
                        if RealNum >= Min andalso (RealNum =< Max orelse RealNum == 0) ->
                            {RealNum, ?AWARD_CAN};
                            true ->
                                {RealNum, ?AWARD_NONE}
                        end;
                    _ ->
                        if RealNum >= NeedNum ->
                            {NeedNum, ?AWARD_CAN};
                            true ->
                                {RealNum, ?AWARD_NONE}
                        end
                end,
            Tran =
                fun() ->
                    NewPlayerTask = DbPlayerTask#db_player_task{num = NewNum, status = NewStatus, update_time = util_time:timestamp()},
                    db:write(NewPlayerTask),
                    if
                        IsAutoFinish == ?TRUE andalso NewStatus == ?AWARD_CAN ->
                            %% 系统自动完成任务
                            get_award(PlayerId);
                        true ->
                            db:tran_apply(fun() -> api_task:notice_task_change(NewPlayerTask) end)
                    end
                end,
            db:do(Tran);
        true ->
            noop
    end.

%% ================================================ 数据操作 ================================================

get_db_player_task(PlayerId) ->
    case db:read(#key_player_task{player_id = PlayerId}) of
        null ->
            #db_player_task{
                player_id = PlayerId,
                task_id = ?SD_INIT_TASK_ID,
                num = 0,
                status = ?AWARD_NONE
            };
        R ->
%%            #db_player_task{
%%                task_id = TaskId,
%%                status = Status
%%            } = R,
%%            case Status of
%%                ?AWARD_ALREADY ->
%%                    #t_task{
%%                        next_task = NextTaskId
%%                    } = get_t_task(TaskId),
%%                    if
%%                        NextTaskId > 0 ->
%%                            trigger_next_task(R, NextTaskId);
%%                        true ->
%%                            R
%%                    end;
%%                _ ->
            R
%%            end
    end.

%% ================================================ 模板操作 ================================================

get_t_task(TaskId) ->
    t_task:get({TaskId}).

%% ================================================ UTIL ================================================

%% ----------------------------------
%% @doc 	获取玩家当前任务id
%% @throws 	none
%% @end
%% ----------------------------------
get_player_task_id(PlayerId) ->
    #db_player_task{
        task_id = TaskId
    } = mod_task:get_db_player_task(PlayerId),
    TaskId.

%% ----------------------------------
%% @doc 	获取玩家当前任务场景id
%% @throws 	none
%% @end
%% ----------------------------------
get_player_task_scene_id(PlayerId) ->
    #db_player_task{
        task_id = TaskId
    } = mod_task:get_db_player_task(PlayerId),
    #t_task{
        auto_scene_id = SceneId
    } = get_t_task(TaskId),
    SceneId.

%% ----------------------------------
%% @doc 	debug 调任务
%% @throws 	none
%% @end
%% ----------------------------------
debug_set_task(PlayerId, TaskId) ->
    ?DEBUG("debug 调任务：~p", [{PlayerId, TaskId}]),
    ?ASSERT(?IS_DEBUG, ?ERROR_NOT_AUTHORITY),
    ?t_assert(TaskId == 0 orelse get_t_task(TaskId) =/= null, {none_task, TaskId}),
    PlayerTask = get_db_player_task(PlayerId),
    #db_player_task{
        task_id = NowTaskId
    } = PlayerTask,
    if
        (TaskId /= 0 andalso NowTaskId >= TaskId) orelse NowTaskId == 0 ->
            noop;
        true ->
            Tran =
                fun() ->
                    #t_task{
                        content_list = ContList
                    } = get_t_task(NowTaskId),
                    case ContList of
                        [?CON_ENUM_LEVEL, NeedLevel] ->
                            PlayerLevel = mod_player:get_player_data(PlayerId, level),
                            if
                                PlayerLevel >= NeedLevel ->
                                    noop;
                                true ->
                                    mod_player:add_level(PlayerId, NeedLevel - PlayerLevel, ?LOG_TYPE_GM)
                            end;
                        [?CON_ENUM_MISSION, MissionType, MissionId] ->
                            hook:do_after_mission_balance(PlayerId, MissionType, MissionId, ?P_SUCCESS, []);
                        _ ->
                            noop
                    end,
                    get_award(PlayerId, false)
                end,
            db:do(Tran),
            PlayerTask_1 = get_db_player_task(PlayerId),
            if PlayerTask_1#db_player_task.task_id == NowTaskId ->
                ?ERROR("任务错误:~p", [{PlayerId, NowTaskId, TaskId}]),
                exit(debug_task_error);
                true ->
                    noop
            end,
            debug_set_task(PlayerId, TaskId)
    end.

%% ================================================ 修复任务 ================================================

%% @doc 修复任务
repair_task() ->
    lists:foreach(
        fun({RepairVersion, List}) ->
            OldRepairVersion = mod_server_data:get_int_data(?SERVER_DATA_GAME_REPAIR_TASK_VERSION),
            if
                RepairVersion > OldRepairVersion ->
                    Tran =
                        fun() ->
                            lists:foreach(
                                fun(PlayerId) ->
                                    DbPlayerTask = get_db_player_task(PlayerId),
                                    #db_player_task{
                                        task_id = TaskId
                                    } = DbPlayerTask,
                                    case get_repair_task_id(TaskId, List) of
                                        ?UNDEFINED ->
                                            noop;
                                        RepairTaskId ->
                                            ?ASSERT(RepairTaskId > 0, {no_found, PlayerId, TaskId}),
                                            ?ASSERT(get_t_task(RepairTaskId) =/= null, {task_no_found, PlayerId, TaskId}),
                                            db:write(DbPlayerTask#db_player_task{
                                                task_id = RepairTaskId
                                            })
                                    end
                                end,
                                mod_player:get_all_player_id()
                            ),
                            mod_server_data:set_int_data(?SERVER_DATA_GAME_REPAIR_TASK_VERSION, RepairVersion),
                            refresh_all_player_task()
                        end,
                    db:do(Tran);
                true ->
                    noop
            end
        end,
        ?SD_REPAIR_TASK
    ),
    ok.

get_repair_task_id(TaskId, List) ->
    lists:foldl(
        fun({RepairTaskId, L}, Tmp) ->
            if Tmp =:= ?UNDEFINED ->
                case lists:member(TaskId, L) of
                    true ->
                        RepairTaskId;
                    false ->
                        Tmp
                end;
                true ->
                    Tmp
            end
        end,
        ?UNDEFINED,
        List
    ).

%% ----------------------------------
%% @doc 	刷新玩家任务
%% @throws 	none
%% @end
%% ----------------------------------
refresh_all_player_task() ->
    lists:foreach(
        fun(PlayerId) ->
            refresh_player_task(PlayerId)
        end,
        mod_player:get_all_player_id()
    ).

refresh_player_task(PlayerId) ->
    mod_apply:apply_to_online_player(PlayerId, ?MODULE, do_refresh_player_task, [PlayerId], game_worker).

do_refresh_player_task(PlayerId) ->
    #db_player_task{
        task_id = TaskId,
        status = Status
    } = get_db_player_task(PlayerId),
    if
        Status =:= ?AWARD_ALREADY ->
            noop;
        true ->
            Tran = fun() ->
                trigger_next_task(PlayerId, TaskId)
                   end,
            db:do(Tran)
    end.