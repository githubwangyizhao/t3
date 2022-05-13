%%%-------------------------------------------------------------------
%%% @author        home
%%% @copyright (C) 2020, THYZ
%%% @doc            个人活动
%%% @end
%%% Created : 17. 二月 2020 下午 3:39
%%%-------------------------------------------------------------------
-module(activity_person).

%% API
-export([
    init/1,
    is_open/2,                          %% 个人活动是否开启
    assert_open/2,                      %%
    get_all_db_player_activity_info/1,
    get_activity_start_and_end_time/2,  %% 获取活动开启合结束时间
    open_activity_list/2,
    open_activity/2,                    %% 开启个人活动
    close_activity/2,                   %% 关闭个人活动
    format_activity_info/2,
    get_activity_state_and_time_range/2
]).

-export([
    get_db_player_activity_info_or_init/2
]).
-include("gen/db.hrl").
-include("activity.hrl").
-include("common.hrl").
-include("error.hrl").
-include("gen/table_db.hrl").
-include("client.hrl").
%% @doc 玩家进程启动， 初始化个人活动
init(PlayerId) ->
    Now = util_time:timestamp(),
    lists:foreach(
        fun(R) ->
            #db_player_activity_info{
                activity_id = ActivityId,
                config_close_time = CloseTime,
                state = State
            } = R,
            if State == ?ACTIVITY_STATE_OPEN andalso CloseTime > 0 ->
                LeftTime = max(0, CloseTime - Now) * 1000,

                if LeftTime > 0 ->
                    util_timer:start_timer({?CLIENT_WORKER_TIMER_CLOSE_PERSON_ACTIVITY, ActivityId}, LeftTime);
                    true ->
                        close_activity(PlayerId, ActivityId)
                end;
                true ->
                    noop
            end
        end,
        get_all_db_player_activity_info(PlayerId)
    ).

%% @doc 关闭个人活动
close_activity(PlayerId, ActivityId) ->
    case is_open(PlayerId, ActivityId) of
        true ->
            handle_close_activity(PlayerId, ActivityId);
        false ->
            noop
    end.

handle_close_activity(PlayerId, ActivityId) ->
    Now = util_time:timestamp(),
    DbPlayerActivityInfo = get_db_player_activity_info(PlayerId, ActivityId),
    #t_activity_info{
        module = Module
    } = activity:get_t_activity_info(ActivityId),
    Tran = fun() ->
        NewDbPlayerActivityInfo = DbPlayerActivityInfo#db_player_activity_info{
            state = ?ACTIVITY_STATE_CLOSE,
            last_close_time = Now
        },
        db:tran_apply(fun() -> api_activity:notice_player_update_activity_time(PlayerId, NewDbPlayerActivityInfo) end),
        db:write(NewDbPlayerActivityInfo)
           end,
    db:do(Tran),
    Result =
    if
        Module == "" ->
            ?WARNING("执行关闭个人活动没有模块：~p~n",[ActivityId]),
            noop;
        true ->
            AtomModule = util:to_atom(Module),
            try erlang:apply(AtomModule, ?ACTIVITY_CLOSE_FUNCTION, [PlayerId, ActivityId]) of
                _ ->
                    ?INFO("执行关闭个人活动回调函数成功:~p", [{AtomModule, ?ACTIVITY_CLOSE_FUNCTION, PlayerId, ActivityId}]),
                    ok
            catch
                error:undef ->
                    noop;
                _:Reason ->
                    ?ERROR("关闭个人活动失败:~p", [{AtomModule, PlayerId, ActivityId, Reason, erlang:get_stacktrace()}]),
                    fail
            end
    end,
    if Result =/= fail ->
        case is_loop_activity(ActivityId) of
            true ->
                ?INFO("个人活动循环开启:~p", [{PlayerId, ActivityId}]),
                util_timer:start_timer({?CLIENT_WORKER_TIMER_OPEN_PERSON_ACTIVITY, ActivityId}, 1000);
            false ->
                noop
        end;
        true ->
            noop
    end.

%% @doc 开启个人活动
open_activity_list(_PlayerId, [])->
    noop;
open_activity_list(PlayerId, ActivityIdList)->
    lists:foreach(
        fun(ActivityId) ->
            open_activity(PlayerId, ActivityId)
        end,
        ActivityIdList
    ).

open_activity(PlayerId, ActivityId) ->
    case is_open(PlayerId, ActivityId) of
        true ->
            noop;
        false ->
            IsCanOpen =
                case is_can_repeat_open(ActivityId) of
                    true ->
                        true;
                    false ->
                        %% 不可重复开启
                        is_once_open(PlayerId, ActivityId) == false
                end,
            if IsCanOpen ->
                handle_open_activity(PlayerId, ActivityId);
                true ->
                    noop
            end
    end.

handle_open_activity(PlayerId, ActivityId) ->
    Now = util_time:timestamp(),
    DbPlayerActivityInfo = get_db_player_activity_info_or_init(PlayerId, ActivityId),
    #t_activity_info{
        module = Module,
        person_time_list = TimeList
    } = activity:get_t_activity_info(ActivityId),
    CloseTime = case TimeList of
                    [day, Day] ->
                        util_time:get_today_zero_timestamp(Now) + Day * 86400 -1;
                    [loop_day, Day] ->
                        util_time:get_today_zero_timestamp(Now) + Day * 86400 -1;
                    forever ->
                        0
                end,
    Tran = fun() ->
        NewDbPlayerActivityInfo = DbPlayerActivityInfo#db_player_activity_info{
            state = ?ACTIVITY_STATE_OPEN,
            last_open_time = Now,
            config_open_time = Now,
            config_close_time = CloseTime
        },
        db:write(NewDbPlayerActivityInfo),
        db:tran_apply(fun() -> api_activity:notice_player_update_activity_time(PlayerId, NewDbPlayerActivityInfo) end),
        if
            Module == "" ->
                noop;
            true ->
                AtomModule = util:to_atom(Module),
                try erlang:apply(AtomModule, ?ACTIVITY_OPEN_FUNCTION, [PlayerId, ActivityId]) of
                    _ ->
                        ?INFO("执行开启个人活动回调函数成功:~p", [{AtomModule, ?ACTIVITY_OPEN_FUNCTION, PlayerId, ActivityId}])
                catch
                    error:undef ->
                        noop;
                    _:Reason ->
                        %% 初始化活动失败，则直接抛出
                        ?ERROR("开启个人活动失败:~p", [{AtomModule, PlayerId, ActivityId, Reason, erlang:get_stacktrace()}]),
                        exit(Reason)
                end
        end
           end,
    db:do(Tran),
    if CloseTime > 0 ->
        util_timer:start_timer({?CLIENT_WORKER_TIMER_CLOSE_PERSON_ACTIVITY, ActivityId}, max(0, CloseTime - Now) * 1000);
        true ->
            noop
    end.

%% @doc 个人活动是否开启
is_open(PlayerId, ActivityId) ->
    case get_db_player_activity_info(PlayerId, ActivityId) of
        null ->
            false;
        DbPlayerActivityInfo ->
            DbPlayerActivityInfo#db_player_activity_info.state == ?ACTIVITY_STATE_OPEN
    end.

%% @doc 个人活动是否曾经开启过
is_once_open(PlayerId, ActivityId) ->
    case get_db_player_activity_info(PlayerId, ActivityId) of
        null ->
            false;
        DbPlayerActivityInfo ->
            DbPlayerActivityInfo#db_player_activity_info.last_open_time > 0
    end.

%% @doc 个人活动是否可以重复开启
is_can_repeat_open(ActivityId) ->
    #t_activity_info{
        person_repeat_open = IsPersonRepeatOpen
    } = activity:get_t_activity_info(ActivityId),
    IsPersonRepeatOpen == ?TRUE orelse is_loop_activity(ActivityId).

assert_open(PlayerId, ActivityId) ->
    ?ASSERT(is_open(PlayerId, ActivityId), ?ERROR_ACTIVITY_NO_OPEN).

%% @doc 是否循环活动
is_loop_activity(ActivityId) ->
    #t_activity_info{
        person_time_list = TimeList
    } = activity:get_t_activity_info(ActivityId),
    case TimeList of
        [loop_day, _] ->
            true;
        _ ->
            false
    end.

%%get_open_activity_id_list(PlayerId) ->
%%    MatchSpec = [{#db_player_activity_info{player_id = PlayerId, activity_id = '$1', state = ?ACTIVITY_STATE_OPEN, _ = '_'}, [], ['$1']}],
%%    lists:sort(db:select(?DB_PLAYER_ACTIVITY_INFO, MatchSpec)).


format_activity_info(PlayerId, ActivityId) ->
            {OpenTime, CloseTime} = get_activity_start_and_end_time(PlayerId, ActivityId),
            {is_open(PlayerId, ActivityId), util_time:local_datetime(), {util_time:timestamp_to_datetime(OpenTime), util_time:timestamp_to_datetime(CloseTime)}}.

get_all_db_player_activity_info(PlayerId) ->
    db_index:get_rows(#idx_player_activity_info_1{player_id = PlayerId}).


get_activity_state_and_time_range(PlayerId, ActivityId) ->
    case t_activity_info:get({ActivityId}) of
        null ->
            ?DEBUG("activity no exists:~p", [ActivityId]),
            {false, {0, 0}};
        _ ->
            {is_open(PlayerId, ActivityId), get_activity_start_and_end_time(PlayerId, ActivityId)}
    end.

%% @doc 获取活动开启关闭时间
get_activity_start_and_end_time(PlayerId, ActivityId) ->
    case get_db_player_activity_info(PlayerId, ActivityId) of
        null ->
%%            ?DEBUG("Read parse activity time:~p", [ActivityId]),
            {0, 0};
        R ->
            {R#db_player_activity_info.config_open_time, R#db_player_activity_info.config_close_time}
    end.

get_db_player_activity_info(PlayerId, ActivityId) ->
    db:read(#key_player_activity_info{player_id = PlayerId, activity_id = ActivityId}).

get_db_player_activity_info_or_init(PlayerId, ActivityId) ->
    case get_db_player_activity_info(PlayerId, ActivityId) of
        null ->
            #db_player_activity_info{
                player_id = PlayerId,
                activity_id = ActivityId,
                state = ?ACTIVITY_STATE_CLOSE,
                last_close_time = 0,
                last_open_time = 0,
                config_open_time = 0,
                config_close_time = 0
            };
        R ->
            R
    end.
