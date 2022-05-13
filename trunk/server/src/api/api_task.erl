%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(api_task).

-include("common.hrl").
-include("p_message.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("gen/db.hrl").
-include("player_game_data.hrl").

%% API
-export([
    get_award/2,
    notice_task_change/1
]).
-export([
    bounty_query_info/2,
    bounty_refresh/2,
    bounty_accept/2,
    bounty_get_award/2,
    notice_bounty_task_change/2,
    notice_bounty_task_reset/1
]).

-export([
    pack_task_info/1
]).

%% -----------------------------------------------------
%% 主线任务相关
%% -----------------------------------------------------
%% 获得奖励
get_award(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_task_get_award_tos{} = Msg,
    {Result, TaskId} =
        try mod_task:get_award(PlayerId) of
            TaskId_ ->
                {?P_SUCCESS, TaskId_}
        catch
            _:?ERROR_NO_FINISH ->
                {?P_UNFINISH, 0};
            _:Other ->
                ?ERROR("get_task_award:~p", [{Other, erlang:get_stacktrace()}]),
                {?P_FAIL, 0}
        end,
    Out = proto:encode(#m_task_get_award_toc{result = Result, task_id = TaskId}),
    mod_socket:send(Out),
    State.

%% 通知任务改变
notice_task_change(DbPlayerTask) ->
    #db_player_task{
        player_id = PlayerId
    } = DbPlayerTask,
    Out = proto:encode(#m_task_notice_task_change_toc{task_info = pack_task_info(DbPlayerTask)}),
    mod_socket:send(PlayerId, Out).

%% 打包主线任务数据
pack_task_info(PlayerId) when is_integer(PlayerId) ->
    pack_task_info(mod_task:get_db_player_task(PlayerId));
pack_task_info(PlayerTask) ->
    #db_player_task{
        task_id = TaskId,
        num = Num,
        status = Status
    } = PlayerTask,
    #taskinfo{task_id = TaskId, num = Num, status = Status}.

%% -----------------------------------------------------
%% 赏金任务相关
%% -----------------------------------------------------
%% 查询赏金任务数据
bounty_query_info(
    #m_task_bounty_query_info_tos{},
    State = #conn{player_id = PlayerId}
) ->
    {AcceptState, DbPlayerTaskData} = mod_bounty_task:get_player_bounty_task_data_list(PlayerId),
    Out = proto:encode(#m_task_bounty_query_info_toc{
        accept_state = AcceptState,
        tasks = [pack_bounty_task_info(DbPlayerTask) || DbPlayerTask <- DbPlayerTaskData],
        reset_times = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_RESET_TIMES, 0),
        accept_times = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_TIMES, 0)
    }),
    mod_socket:send(Out),
    State.

%% 接受赏金任务
bounty_accept(
    #m_task_bounty_accept_tos{task_id = TaskId},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_bounty_task:do_accept_bounty_task(PlayerId, TaskId)),
    Out = proto:encode(#m_task_bounty_accept_toc{result = Result, task_id = TaskId}),
    mod_socket:send(Out),
    State.

%% 领取赏金任务奖励
bounty_get_award(
    #m_task_bounty_get_award_tos{},
    State = #conn{player_id = PlayerId}
) ->
    TaskId = mod_player_game_data:get_int_data_default(PlayerId, ?PLAYER_GAME_DATA_BOUNTY_TASK_ACCEPT_ID, -1),
    Result = api_common:api_result_to_enum(catch mod_bounty_task:get_award(PlayerId)),
    Out = proto:encode(#m_task_bounty_get_award_toc{
        result = Result,
        task_id = TaskId
    }),
    mod_socket:send(Out),
    State.

%% 刷新赏金任务
bounty_refresh(
    #m_task_bounty_refresh_tos{},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_bounty_task:do_refresh_bounty_task(PlayerId)),
    Out = proto:encode(#m_task_bounty_refresh_toc{result = Result}),
    mod_socket:send(Out),
    State.

%% 通知赏金任务数据变更
notice_bounty_task_change(PlayerId, DbPlayerTask) ->
    Out = proto:encode(#m_task_bounty_notice_change_toc{task_info = pack_bounty_task_info(DbPlayerTask)}),
    mod_socket:send(PlayerId, Out).

%% 通知赏金任务数据重置
notice_bounty_task_reset(PlayerId) ->
    Out = proto:encode(#m_task_bounty_notice_reset_toc{}),
    mod_socket:send(PlayerId, Out).

%% 打包赏金任务
pack_bounty_task_info(PlayerTask) ->
    #db_player_bounty_task{
        id = TaskId,
        value = Num,
        state = Status
    } = PlayerTask,
    #taskinfo{task_id = TaskId, num = Num, status = Status}.

