%%%-------------------------------------------------------------------
%%% @author        home
%%% @copyright (C) 2016, THYZ
%%% @doc            活动进程逻辑
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(activity_handle).

%% CALLBACK
-export([
    init/0,
    handle_clock/0,
    handle_close_activity/2,
    handle_debug_open/3,
    handle_clean_debug/1
]).

-export([
    update_activity/1
]).
-include("common.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("activity.hrl").
-include("gen/db.hrl").
-include("system.hrl").

%% @doc 活动进程初始化
init() ->
    %% 初始化debug
    activity_debug:init(),
    %% 同步跨服活动
    activity_sync:init(),
    %% 启动定时器
    clock().


%% @doc 启动定时器
clock() ->
    erlang:send_after(3000, self(), ?ACTIVITY_MSG_CLOCK).

%% @doc 获取活动配置时间
%% @private
get_activity_config_time(NowTimestamp, ActivityId) ->
    case activity_debug:get_activity_debug_time(ActivityId) of
        null ->
            {ConfigStartTime, ConfigEndTime} = activity_time_parse:parse_activity_time(ActivityId, NowTimestamp),
            {ConfigStartTime, ConfigEndTime};
        {DebugConfigStartTime, DebugConfigEndTime} ->
            %% debug 时间
            {DebugConfigStartTime, DebugConfigEndTime}
    end.

%% @doc 活动心跳
%% @private
handle_clock() ->
    Now = util_time:timestamp(),
    clock(),
    Type =
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_WAR_AREA ->
            ?ACTIVITY_TYPE_WAR;
        ?SERVER_TYPE_GAME ->
            ?ACTIVITY_TYPE_GAME
    end,
    lists:foreach(
        fun(ActivityId) ->
            ?CATCH(handle_clock_1(Now, ActivityId))
        end,
        activity:get_all_activity_id_by_type(Type)
    ).

handle_clock_1(Now, ActivityId) ->
    #t_activity_info{
        notice_time = NoticeTime
    } = activity:get_t_activity_info(ActivityId),
    {ConfigStartTime, ConfigEndTime} = get_activity_config_time(Now, ActivityId),
    DbActivityInfo = activity:get_db_activity_info_or_init(ActivityId),
    #db_activity_info{
        state = State,
        last_open_time = LastOpenTime,
        last_close_time = LastCloseTime,
        config_open_time = DbConfigOpenTime,
        config_close_time = DbConfigCloseTime
    } = DbActivityInfo,

    if
        DbConfigOpenTime =/= ConfigStartTime orelse DbConfigCloseTime =/= ConfigEndTime ->
            ?DEBUG("活动时间改变:~p", [{ActivityId, {DbConfigOpenTime, DbConfigCloseTime}, {ConfigStartTime, ConfigEndTime}}]),
            %% 更新db 活动配置时间
            NewDbActivityInfo = DbActivityInfo#db_activity_info{
                config_open_time = ConfigStartTime,
                config_close_time = ConfigEndTime
            },
            update_activity(NewDbActivityInfo);
        true ->
            noop
    end,
    IsServerLimit =
        case activity_debug:is_debug(ActivityId) of
            true ->
                false;
            false ->
                activity_time_parse:is_server_limit(ActivityId)
        end,
    if
        IsServerLimit ->
            %% 开服时间限制/合服时间限制
            handle_close_activity(ActivityId, Now);
        true ->
            if
                ConfigStartTime == 0 andalso ConfigEndTime == 0 ->
                    %% 永久开启
                    handle_open_activity(ActivityId, Now);
                Now >= ConfigStartTime andalso (Now < ConfigEndTime orelse ConfigEndTime == 0) ->
                    %% 在活动时间内
                    if
                        LastOpenTime >= ConfigStartTime andalso (LastOpenTime < ConfigEndTime orelse ConfigEndTime == 0) andalso LastCloseTime =< LastOpenTime ->
                            %% 已经开启过
                            noop;
                        true ->
                            %% 开启活动
                            if State == ?ACTIVITY_STATE_OPEN ->
                                ?WARNING("活动重新开启:~p", [{ActivityId, Now, util_time:timestamp_to_datetime(LastOpenTime), util_time:timestamp_to_datetime(LastCloseTime), {util_time:timestamp_to_datetime(ConfigStartTime), util_time:timestamp_to_datetime(ConfigEndTime)}}]),
                                handle_close_activity(ActivityId, Now),
                                handle_open_activity(ActivityId, Now);
                                true ->
                                    handle_open_activity(ActivityId, Now)
                            end
                    end;
                NoticeTime > 0 andalso (ConfigStartTime - NoticeTime) =< Now andalso Now < ConfigStartTime ->
                    %% 准备阶段
                    handle_ready_activity(ActivityId, Now);
                true ->
                    %% 在活动时间外
                    handle_close_activity(ActivityId, Now)
            end
    end.

%% @doc 活动准备
%% @private
handle_ready_activity(ActivityId, Now) ->
    #t_activity_info{
        module = Module
    } = activity:get_t_activity_info(ActivityId),
    DbActivityInfo = activity:get_db_activity_info_or_init(ActivityId),
    #db_activity_info{
        state = State,
        last_open_time = LastOpenTime,
        last_close_time = LastCloseTime,
        config_open_time = ConfigStartTime,
        config_close_time = ConfigEndTime
    } = DbActivityInfo,
    if
        State == ?ACTIVITY_STATE_CLOSE ->
            ?INFO("准备活动:~p", [{ActivityId}]),
            ?CATCH(mod_log:write_activity_log(ready, ActivityId, Now, State, {LastOpenTime, LastCloseTime}, {ConfigStartTime, ConfigEndTime})),
            if
                Module == "" ->
                    noop;
                true ->
                    AtomModule = util:to_atom(Module),
                    try erlang:apply(AtomModule, ?ACTIVITY_READY_FUNCTION, [ActivityId]) of
                        _ ->
                            ?INFO("执行准备活动回调函数成功:~p", [{AtomModule, ?ACTIVITY_READY_FUNCTION, ActivityId}])
                    catch
                        error:undef ->
                            noop;
                        _:R ->
                            %% 准备活动失败，则直接抛出
                            ?ERROR("准备活动失败:~p", [{AtomModule, ActivityId, R, erlang:get_stacktrace()}]),
                            exit(R)
                    end
            end,
            Tran = fun() ->
                NewDbActivityInfo = DbActivityInfo#db_activity_info{
                    state = ?ACTIVITY_STATE_READY
%%                    open_time = Now
                },
                update_activity(NewDbActivityInfo)
                   end,
            db:do(Tran);
        State == ?ACTIVITY_STATE_READY ->
            noop;
        true ->
            ?WARNING("no ready state:~p", [{ActivityId, State}])
    end.


%% @doc 更新活动
update_activity(NewDbActivityInfo) ->
    ?INFO("更新活动:~p", [NewDbActivityInfo]),
    Tran = fun() ->
        case mod_server_config:get_server_type() of
            ?SERVER_TYPE_GAME ->
                %% 广播活动变更
                db:tran_apply(fun() -> api_activity:notice_update_activity_time([NewDbActivityInfo]) end);
            _ ->
                ?INFO("推送活动同步:~p", [NewDbActivityInfo]),
                db:tran_apply(fun() ->  activity_sync:push([NewDbActivityInfo]) end)
        end,
        db:write(NewDbActivityInfo)
           end,
    db:do(Tran).

%% @doc 活动开启
%% @private
handle_open_activity(ActivityId, Now) ->
    #t_activity_info{
        module = Module
    } = activity:get_t_activity_info(ActivityId),
    DbActivityInfo = activity:get_db_activity_info_or_init(ActivityId),
    #db_activity_info{
        state = State,
        last_open_time = LastOpenTime,
        last_close_time = LastCloseTime,
        config_open_time = ConfigStartTime,
        config_close_time = ConfigEndTime
    } = DbActivityInfo,
    if State =/= ?ACTIVITY_STATE_OPEN ->
        ?INFO("启动活动:~p", [{ActivityId}]),
        ?CATCH(mod_log:write_activity_log(open, ActivityId, Now, State, {LastOpenTime, LastCloseTime}, {ConfigStartTime, ConfigEndTime})),
        Tran = fun() ->
            NewDbActivityInfo = DbActivityInfo#db_activity_info{
                state = ?ACTIVITY_STATE_OPEN,
                last_open_time = Now
            },
            update_activity(NewDbActivityInfo),
            if
                Module == "" ->
                    noop;
                true ->
                    AtomModule = util:to_atom(Module),
                    try erlang:apply(AtomModule, ?ACTIVITY_OPEN_FUNCTION, [ActivityId]) of
                        _ ->
                            ?INFO("执行开启活动回调函数成功:~p", [{AtomModule, ?ACTIVITY_OPEN_FUNCTION, ActivityId}])
                    catch
                        error:undef ->
                            noop;
                        _:R ->
                            %% 初始化活动失败，则直接抛出
                            ?ERROR("开启活动失败:~p", [{AtomModule, ActivityId, R, erlang:get_stacktrace()}]),
                            exit(R)
                    end
            end
               end,
        db:do(Tran);
        true ->
            noop
    end.

%% @doc 活动关闭
%% @private
handle_close_activity(ActivityId, Now) ->
    case activity:get_db_activity_info(ActivityId) of
        null ->
%%            ?WARNING("activity_info not found:~p", [ActivityId]),
            noop;
        DbActivityInfo ->
            #t_activity_info{
                module = Module
            } = activity:get_t_activity_info(ActivityId),
            #db_activity_info{
                state = State,
                last_open_time = LastOpenTime,
                last_close_time = LastCloseTime,
                config_open_time = ConfigStartTime,
                config_close_time = ConfigEndTime
            } = DbActivityInfo,
            if State =/= ?ACTIVITY_STATE_CLOSE ->
                ?INFO("关闭活动:~p", [ActivityId]),
                ?CATCH(mod_log:write_activity_log(close, ActivityId, Now, State, {LastOpenTime, LastCloseTime}, {ConfigStartTime, ConfigEndTime})),
                Tran = fun() ->
                    NewDbActivityInfo = DbActivityInfo#db_activity_info{
                        state = ?ACTIVITY_STATE_CLOSE,
                        last_close_time = Now
                    },
                    update_activity(NewDbActivityInfo)
                       end,
                db:do(Tran),
                activity_debug:clean_activity_debug_time(ActivityId),
                if
                    Module == "" ->
                        ?WARNING("执行关闭活动没有模块：~p~n",[ActivityId]),
                        noop;
                    true ->
                        AtomModule = util:to_atom(Module),
                        try erlang:apply(AtomModule, ?ACTIVITY_CLOSE_FUNCTION, [ActivityId]) of
                            _ ->
                                ?INFO("执行关闭活动回调函数成功:~p", [{AtomModule, ?ACTIVITY_CLOSE_FUNCTION, ActivityId}])
                        catch
                            error:undef ->
                                noop;
                            _:R ->
                                ?ERROR("关闭活动失败:~p", [{AtomModule, ActivityId, R, erlang:get_stacktrace()}])
                        end
                end;
                true ->
                    noop
            end
    end.


%% @doc debug_open callback
%% @private
handle_debug_open(ActivityId, OpenTime, CloseTime) ->
    handle_close_activity(ActivityId, util_time:timestamp()),
    activity_debug:update_activity_debug_time(ActivityId, OpenTime, CloseTime).

%% @doc clean_debug callback
%% @private
handle_clean_debug(ActivityId) ->
    handle_close_activity(ActivityId, util_time:timestamp()),
    activity_debug:clean_activity_debug_time(ActivityId).
