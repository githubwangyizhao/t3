%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         每日任务
%%% @end
%%% Created : 07. 十二月 2020 下午 03:27:27
%%%-------------------------------------------------------------------
-module(mod_daily_task).
-author("yizhao.wang").

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("p_message.hrl").
-include("player_game_data.hrl").

%% API
-export([
    try_update_task_show/1,                 %% 尝试更新任务展示
    init_task_show/1,                       %% 初始化任务展示
    get_task_show/0,                        %% 获得任务展示

    get_award/2,                            %% 获得每日任务奖励
    get_points_award/2,                     %% 领取每日积分奖励

    trigger_task/3,                         %% 触发任务

    on_before_enter_game/1,                 %% 钩子进入游戏前
    on_date_cut/1,                          %% 跨天时

    get_player_daily_task_data_list/1,             %% 获得每日任务数据列表
    get_daily_points_award_records/1        %% 获取每日积分奖励领取记录
]).

%% ----------------------------------
%% @doc 	钩子进入游戏前
%% @throws 	none
%% @end
%% ----------------------------------
on_before_enter_game(PlayerId) ->
    NowSec = util_time:timestamp(),
    NowDateStr = util_time:timestamp_to_datestr(NowSec),
    case mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_DAILY_TASK_REFRESH_DATE) of
        NowDateStr ->
            skip;
        _ ->
            refresh_daily_task_data(PlayerId)
    end,
    ok.

%% ----------------------------------
%% @doc 	跨天时
%% @throws 	none
%% @end
%% ----------------------------------
on_date_cut(PlayerId) ->
    refresh_daily_task_data(PlayerId),
    ok.

%% ----------------------------------
%% @doc 	重置每日任务数据
%% @throws 	none
%% @end
%% ----------------------------------
refresh_daily_task_data(PlayerId) ->
    %% 每种类型随一个任务
    NewTaskIdList =
        [begin
             TypeTaskIdList = [TaskId_ || #t_daily_task{id = TaskId_} <- t_daily_task@group:get(Type)],
             TaskId = util_random:get_list_random_member(TypeTaskIdList),
             TaskId
         end || Type <- t_daily_task@group:get_group_keys()],
    Tran =
        fun() ->
            %% 删除旧任务数据
            db:select_delete(player_daily_points, [{#db_player_daily_points{player_id = '$1', _ = '_'}, [{'=:=','$1',PlayerId}], ['$_']}]),
            db:select_delete(player_daily_task, [{#db_player_daily_task{player_id = '$1', _ = '_'}, [{'=:=','$1',PlayerId}], ['$_']}]),
            %% 每日积分数量清零
            DailyPointNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_MEIRIJIFEN),
            if
                DailyPointNum > 0 ->
                    mod_prop:decrease_player_prop(PlayerId, [{?ITEM_MEIRIJIFEN, DailyPointNum}], ?LOG_TYPE_DAILY_TASK);
                true ->
                    noop
            end,
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_DAILY_POINTS, 0),
            %% 写入新任务数据
            [db:write(#db_player_daily_task{player_id = PlayerId, id = Id}) || Id <- NewTaskIdList],
            %% 通知任务刷新
            db:tran_apply(fun() -> api_daily_task:notice_refresh_daily_task_data(PlayerId) end),
            try_update_task_show(PlayerId),

            NowSec = util_time:timestamp(),
            mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_DAILY_TASK_REFRESH_DATE, util_time:timestamp_to_datestr(NowSec))
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	获取每日任务数据列表
%% @throws 	none
%% @end
%% ----------------------------------
get_player_daily_task_data_list(PlayerId) ->
    TaskIdList = get_player_daily_task_id_list(PlayerId),
    lists:map(
        fun(Id) ->
            get_db_player_daily_task(PlayerId, Id)
        end,
        TaskIdList
    ).

%% ----------------------------------
%% @doc 	获取玩家日常任务id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_player_daily_task_id_list(PlayerId) ->
    [R#db_player_daily_task.id || R <- db_index:get_rows(#idx_player_daily_task_1{player_id = PlayerId})].

%% ----------------------------------
%% @doc 	获取玩家每日积分奖励领取记录
%% @throws 	none
%% @end
%% ----------------------------------
get_daily_points_award_records(PlayerId) ->
    Records = db_index:get_rows(#idx_player_daily_points_1{player_id = PlayerId}),
    lists:sort([Record#db_player_daily_points.bid || Record <- Records]).

%% ----------------------------------
%% @doc 	领取每日任务奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_award(PlayerId, -1) ->  %% 一键领取
    [get_award(PlayerId, TaskId) || #db_player_daily_task{state = ?AWARD_CAN, id = TaskId} <- get_player_daily_task_data_list(PlayerId)],
    ok;
get_award(PlayerId, Id) ->
    DbPlayerDailyTask = get_db_player_daily_task(PlayerId, Id),
    ?ASSERT(DbPlayerDailyTask /= null),

    #db_player_daily_task{
        id = Id,
        state = State
    } = DbPlayerDailyTask,
    ?ASSERT(State =/= ?AWARD_NONE, ?ERROR_NOT_AUTHORITY),
    ?ASSERT(State =/= ?AWARD_ALREADY, ?ERROR_ALREADY_GET),

    #t_daily_task{
        award_list = AwardList
    } = t_daily_task:assert_get({Id}),
    mod_prop:assert_give(PlayerId, AwardList),

    Tran =
        fun() ->
            %% 更新每日活跃积分
            case util_list:key_find(?ITEM_MEIRIJIFEN, 1, AwardList) of
                false ->
                   noop;
                [_, Val] ->
                    mod_player_game_data:incr_int_data(PlayerId, ?PLAYER_GAME_DATA_DAILY_POINTS, Val),
                    Val
            end,

            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_DAILY_TASK),
            db:write(DbPlayerDailyTask#db_player_daily_task{state = ?AWARD_ALREADY, change_time = util_time:timestamp()})
        end,
    db:do(Tran),
    ok.

%% ----------------------------------
%% @doc 	领取每日积分奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_points_award(PlayerId, Id) ->
    Result = util_list:key_find(Id, 1, ?SD_NTERAL_CHEST),
    ?ASSERT(Result /= false, ?ERROR_FAIL),

    ?ASSERT(get_db_player_daily_points(PlayerId, Id) == null, ?ERROR_ALREADY_GET),

    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_DAILY_POINTS),
    ?ASSERT(Value >= Id, ?ERROR_NOT_AUTHORITY),

    [Id, AwardId] = Result,
    AwardList = mod_award:decode_award(AwardId),

    Tran =
        fun() ->
            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_DAILY_TASK),
            %% 记录领取数据
            db:write(#db_player_daily_points{player_id = PlayerId, bid = Id, create_time = util_time:timestamp()})
        end,
    db:do(Tran),
    ok.


%% ----------------------------------
%% @doc 	触发完成任务
%% @throws 	none
%% @end
%% ----------------------------------
trigger_task(PlayerId, TaskIdList, AddValue) ->
    try_update_player_task(PlayerId, TaskIdList, AddValue, []).

try_update_player_task(PlayerId, [], _AddValue, NoticeTaskList) ->
    if
        NoticeTaskList =:= [] ->
            noop;
        true ->
            db:tran_apply(fun() -> api_daily_task:notice_update_daily_task_data(PlayerId, NoticeTaskList) end)
    end;
try_update_player_task(PlayerId, [TaskId | TaskIdList], AddValue, NoticeTaskList) ->
    #t_daily_task{
        approach_list = ConditionList
    } = t_daily_task:assert_get({TaskId}),
    [_TaskConditionKey, NeedValue] = logic_code:tran_condition_list(ConditionList),

    DbPlayerDailyTask = get_db_player_daily_task(PlayerId, TaskId),
    if
        DbPlayerDailyTask == null ->    %% 不存在的任务
            try_update_player_task(PlayerId, TaskIdList, AddValue, NoticeTaskList);
        true ->
            #db_player_daily_task{
                value = Value,
                state = State
            } = DbPlayerDailyTask,

            case State of
                ?AWARD_ALREADY ->   %% 已领取
                    try_update_player_task(PlayerId, TaskIdList, AddValue, NoticeTaskList);
                ?AWARD_NONE ->      %% 未完成
                    NewValue = Value + AddValue,
                    NewState = ?IF(NewValue >= NeedValue, ?AWARD_CAN, ?AWARD_NONE),
                    NewDbPlayerDailyTask = DbPlayerDailyTask#db_player_daily_task{
                        value = NewValue,
                        state = NewState,
                        change_time = util_time:timestamp()
                    },
                    %% 更新任务进度
                    db:write(NewDbPlayerDailyTask),

                    if
                        NewState =:= ?AWARD_CAN ->
                            try_update_player_task(PlayerId, TaskIdList, AddValue, [NewDbPlayerDailyTask | NoticeTaskList]);
                        true ->
                            case get_task_show() of
                                {daily_task, ThisTaskId} ->
                                    if
                                        ThisTaskId =:= TaskId ->
                                            try_update_player_task(PlayerId, TaskIdList, AddValue, [NewDbPlayerDailyTask | NoticeTaskList]);
                                        true ->
                                            try_update_player_task(PlayerId, TaskIdList, AddValue, NoticeTaskList)
                                    end;
                                _ ->
                                    try_update_player_task(PlayerId, TaskIdList, AddValue, NoticeTaskList)
                            end
                    end;
                ?AWARD_CAN ->   %% 已经完成
                    try_update_player_task(PlayerId, TaskIdList, AddValue, NoticeTaskList)
            end
    end.

%% ----------------------------------
%% @doc 	尝试更新任务展示
%% @throws 	none
%% @end
%% ----------------------------------
try_update_task_show(PlayerId) ->
    OldTaskShow = pack_task_show(get_task_show()),
    NewTaskShow = init_task_show(PlayerId),
    ?IF(OldTaskShow =/= NewTaskShow, api_daily_task:notice_update_task_show(PlayerId, NewTaskShow), noop).

%% ----------------------------------
%% @doc 	初始化任务展示
%% @throws 	none
%% @end
%% ----------------------------------
init_task_show(PlayerId) ->
    TaskShowTuple =
        case mod_task:init_task_show(PlayerId) of
            ?UNDEFINED ->
                TaskIdList = get_player_daily_task_id_list(PlayerId),
                init_task_show(PlayerId, TaskIdList, null);
            R ->
                R
        end,
    put(task_show, TaskShowTuple),
    pack_task_show(TaskShowTuple).

init_task_show(PlayerId, [], Id) ->
    case Id of
        null ->
            mod_achievement:init_task_show(PlayerId);
        _ ->
            {daily_task, Id}
    end;
init_task_show(PlayerId, [Id | IdList], TmpId) ->
    #db_player_daily_task{
        state = State
    } = get_db_player_daily_task(PlayerId, Id),
    case State of
        ?AWARD_ALREADY ->
            init_task_show(PlayerId, IdList, TmpId);
        ?AWARD_CAN ->
            init_task_show(PlayerId, [], Id);
        _ ->
            if
                TmpId =:= null ->
                    init_task_show(PlayerId, IdList, Id);
                true ->
                    init_task_show(PlayerId, IdList, TmpId)
            end
    end.

get_task_show() ->
    get(task_show).

pack_task_show(?UNDEFINED) -> #taskshow{key = 0, value = 0};
pack_task_show({daily_task, Id}) -> #taskshow{key = 1, value = Id};
pack_task_show({achievement, Type}) -> #taskshow{key = 2, value = Type};
pack_task_show({task, Id}) -> #taskshow{key = 3, value = Id}.

%% ----------------------------------
%% @doc 	获取每日任务数据
%% @throws 	none
%% @end
%% ----------------------------------
get_db_player_daily_task(PlayerId, Id) ->
    db:read(#key_player_daily_task{player_id = PlayerId, id = Id}).

%% ----------------------------------
%% @doc 	获取积分宝箱领取记录
%% @throws 	none
%% @end
%% ----------------------------------
get_db_player_daily_points(PlayerId, Id) ->
    db:read(#key_player_daily_points{player_id = PlayerId, bid = Id}).