%%%-------------------------------------------------------------------
%%% @author        home
%%% @copyright (C) 2016, THYZ
%%% @doc            活动时间调试
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(activity_debug).

%% API
-export([
    debug_open_from_now/2,
    debug_open/3,
    clean_debug/1,
    is_debug/1
]).

%% @private
-export([
    init/0,
    get_activity_debug_time/1,
    update_activity_debug_time/3,
    clean_activity_debug_time/1
]).

-include("common.hrl").
-include("activity.hrl").
-include("gen/table_db.hrl").
-include("system.hrl").

-define(ETS_ACTIVITY_DEBUG, ets_activity_debug).
-record(ets_activity_debug, {
    activity_id,
    open_time,
    close_time
}).

%% @doc 调试开启活动
debug_open_from_now(ActivityId, CloseDateTime) when is_tuple(CloseDateTime) ->
    Now = util_time:timestamp(),
    CloseTime = util_time:datetime_to_timestamp(CloseDateTime),
    ?ASSERT(CloseTime > Now),
    debug_open(ActivityId, Now, CloseTime);
debug_open_from_now(ActivityId, ContinueSec) when is_integer(ContinueSec) ->
    ?ASSERT(ContinueSec > 0),
    Now = util_time:timestamp(),
    debug_open(ActivityId, Now, Now + ContinueSec).

debug_open(ActivityId, OpenDateTime, CloseDateTime) when is_tuple(OpenDateTime), is_tuple(CloseDateTime) ->
    debug_open(ActivityId, util_time:datetime_to_timestamp(OpenDateTime), util_time:datetime_to_timestamp(CloseDateTime));
debug_open(ActivityId, OpenTime, CloseTime) when is_integer(OpenTime), is_integer(CloseTime) ->
%%    ?ASSERT(?IS_DEBUG == true),
    ?INFO("debug_open:~p", [{ActivityId, OpenTime, CloseTime}]),
    #t_activity_info{
        type = Type
    } = activity:get_t_activity_info(ActivityId),
    if Type == ?ACTIVITY_TYPE_GAME ->
        activity_srv:cast({?ACTIVITY_MSG_DEBUG_OPEN, ActivityId, OpenTime, CloseTime});
        Type == ?ACTIVITY_TYPE_WAR ->
            activity_srv:cast(mod_server_config:get_war_area_node(), {?ACTIVITY_MSG_DEBUG_OPEN, ActivityId, OpenTime, CloseTime})
    end.

%% @doc 是否开启调试
is_debug(ActivityId) ->
    case get_activity_debug_time(ActivityId) of
        null ->
            false;
        _->
            true
    end.

%% @doc 清理活动时间调试
clean_debug(ActivityId) ->
%%    ?ASSERT(?IS_DEBUG == true),
    ?INFO("clean_debug:~p", [ActivityId]),
    #t_activity_info{
        type = Type
    } = activity:get_t_activity_info(ActivityId),
%%    ServerType = mod_server_config:get_server_type(),
    if Type == ?ACTIVITY_TYPE_GAME ->
        activity_srv:cast({?ACTIVITY_MSG_CLEAN_DEBUG, ActivityId});
        Type == ?ACTIVITY_TYPE_WAR ->
            activity_srv:cast(mod_server_config:get_war_area_node(), {?ACTIVITY_MSG_CLEAN_DEBUG, ActivityId})
    end.

%% @doc 进程初始化活动调试
init() ->
    ets:new(?ETS_ACTIVITY_DEBUG, ?ETS_INIT_ARGS(#ets_activity_debug.activity_id)).

%% @private
get_activity_debug_time(ActivityId) ->
    case ets:lookup(?ETS_ACTIVITY_DEBUG, ActivityId) of
        [] ->
            null;
        [R] ->
            #ets_activity_debug{
                open_time = OpenTime,
                close_time = CloseTime
            } = R,
            {OpenTime, CloseTime}
    end.

%% @private
update_activity_debug_time(ActivityId, OpenTime, CloseTime) ->
    ets:insert(?ETS_ACTIVITY_DEBUG, #ets_activity_debug{
        activity_id = ActivityId,
        open_time = OpenTime,
        close_time = CloseTime
    }).

%% @private
clean_activity_debug_time(ActivityId) ->
    ets:delete(?ETS_ACTIVITY_DEBUG, ActivityId).
