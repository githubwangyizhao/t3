%%%-------------------------------------------------------------------
%%% @author        home
%%% @copyright (C) 2016, THYZ
%%% @doc            活动接口
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(activity).

%% API
-export([
    is_open/1,                          %% 活动是否开启
    is_open/2,                          %% 个人活动是否开启
    is_ready/1,                         %% 活动是否在准备阶段
    assert_open/1,                      %%
    assert_open/2,                      %%
    is_person_activity/1,               %% 是否个人活动
    get_open_activity_id_list/0,        %% 获取所有已经开启的活动id列表
    get_all_db_activity_info/1,         %% 获取所有活动数据
    get_activity_start_and_end_time/1,  %% 获取活动开启合结束时间
    get_activity_state_and_time_range/2,
    close_activity/1,                   %% 关闭活动
    close_activity/2,
    get_activity_open_day/2,            %% 获得活动第几天
    get_activity_state_and_time_range/1,
    get_activity_start_and_end_time/2
]).

-export([
    get_db_activity_info/1,             %% 获取活动db
    get_db_activity_info_or_init/1
%%    get_init_db_activity_info/0     %% 获取所有开启的活动db
]).

-export([
    get_all_activity_id/0,
    get_all_activity_id_by_type/1,
    format_activity_info/1,
    get_t_activity_info/1
]).

-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").
-include("error.hrl").
-include("activity.hrl").
-include("system.hrl").

%% @doc 关闭活动
close_activity(ActivityId) ->
    close_activity(0, ActivityId).
close_activity(PlayerId, ActivityId) ->
    ?INFO("close_activity:~p", [{PlayerId, ActivityId}]),
    #t_activity_info{
        type = ActivityType
    } = activity:get_t_activity_info(ActivityId),
    case ActivityType of
        ?ACTIVITY_TYPE_GAME ->
            activity_srv:cast({?ACTIVITY_MSG_CLOSE_ACTIVITY, ActivityId});
        ?ACTIVITY_TYPE_WAR ->
            case mod_server_config:get_server_type() of
                ?SERVER_TYPE_WAR_AREA ->
                    activity_srv:cast({?ACTIVITY_MSG_CLOSE_ACTIVITY, ActivityId});
                _ ->
                    activity_srv:cast(mod_server_config:get_war_area_node(), {?ACTIVITY_MSG_CLOSE_ACTIVITY, ActivityId})
            end;
        ?ACTIVITY_TYPE_PERSON ->
            activity_person:close_activity(PlayerId, ActivityId)
%%            activity_srv:cast({?ACTIVITY_MSG_CLOSE_ACTIVITY, PlayerId, ActivityId})
    end.

%% @doc 活动是否开启
is_open(ActivityId) ->
    is_open(0, ActivityId).
is_open(_, 0) ->
    true;
is_open(PlayerId, ActivityId) ->
    case is_person_activity(ActivityId) of
        true ->
            activity_person:is_open(PlayerId, ActivityId);
        false ->
            case get_db_activity_info(ActivityId) of
                null ->
                    false;
                ActivityInfo ->
                    ActivityInfo#db_activity_info.state == ?ACTIVITY_STATE_OPEN
            end
    end.

%% @doc 活动是否准备阶段
is_ready(ActivityId) ->
    case get_db_activity_info(ActivityId) of
        null ->
            false;
        ActivityInfo ->
            ActivityInfo#db_activity_info.state == ?ACTIVITY_STATE_READY
    end.

assert_open(ActivityId) ->
    assert_open(0, ActivityId).
assert_open(_, 0) ->
    true;
assert_open(PlayerId, ActivityId) ->
    case is_person_activity(ActivityId) of
        true ->
            activity_person:assert_open(PlayerId, ActivityId);
        false ->
            ?ASSERT(is_open(ActivityId), ?ERROR_ACTIVITY_NO_OPEN)
    end.

%% @doc 打印活动信息
format_activity_info(ActivityId) ->
    format_activity_info(0, ActivityId).
format_activity_info(PlayerId, ActivityId) ->
    case is_person_activity(ActivityId) of
        true ->
            activity_person:format_activity_info(PlayerId, ActivityId);
        false ->
            {OpenTime, CloseTime} = get_activity_start_and_end_time(ActivityId),
            {is_open(ActivityId), util_time:local_datetime(), {util_time:timestamp_to_datetime(OpenTime), util_time:timestamp_to_datetime(CloseTime)}}
    end.

%% @doc 获得活动第几天
get_activity_open_day(PlayerId, ActivityId) ->
    {StartTime, _} = get_activity_start_and_end_time(PlayerId, ActivityId),
    util_time:get_interval_day_add_1(StartTime).

%% @doc  获取活动状态和时间范围
get_activity_state_and_time_range(ActivityId) ->
    get_activity_state_and_time_range(0, ActivityId).
get_activity_state_and_time_range(PlayerId, ActivityId) ->
    case is_person_activity(ActivityId) of
        true ->
            activity_person:get_activity_state_and_time_range(PlayerId, ActivityId);
        false ->
            case t_activity_info:get({ActivityId}) of
                null ->
                    ?DEBUG("activity no exists:~p", [ActivityId]),
                    {false, {0, 0}};
                _ ->
                    {is_open(ActivityId), get_activity_start_and_end_time(ActivityId)}
            end
    end.

%% @doc 获取活动开启关闭时间
get_activity_start_and_end_time(ActivityId) ->
    get_activity_start_and_end_time(0, ActivityId).
get_activity_start_and_end_time(PlayerId, ActivityId) ->
    case is_person_activity(ActivityId) of
        true ->
            activity_person:get_activity_start_and_end_time(PlayerId, ActivityId);
        false ->
            case get_db_activity_info(ActivityId) of
                null ->
%%            ?DEBUG("Read parse activity time:~p", [ActivityId]),
                    activity_time_parse:parse_activity_time(ActivityId, util_time:timestamp());
                R ->
                    #db_activity_info{
                        state = State,
                        config_open_time = ConfigOpenTime,
                        config_close_time = ConfigCloseTime,
                        last_open_time = LastOpenTime
                    } = R,
                    if
                        State == ?ACTIVITY_STATE_OPEN andalso ConfigOpenTime == 0 ->
                            {LastOpenTime, ConfigCloseTime};
                        true ->
                            {ConfigOpenTime, ConfigCloseTime}
                    end
            end
    end.
%%%% @doc 获取活动开启关闭时间
%%get_activity_start_and_end_time(ActivityId) ->
%%    get_activity_start_and_end_time(util_time:timestamp(), ActivityId).
%%
%%get_activity_start_and_end_time(NowTimestamp, ActivityId) ->
%%    case activity_debug:get_activity_debug_time(ActivityId) of
%%        null ->
%%            {ConfigStartTime, ConfigEndTime} = activity_time_parse:parse_activity_time(ActivityId, NowTimestamp),
%%            {ConfigStartTime, ConfigEndTime};
%%        {DebugConfigStartTime, DebugConfigEndTime} ->
%%            {DebugConfigStartTime, DebugConfigEndTime}
%%    end.

get_db_activity_info(ActivityId) ->
    #t_activity_info{
        type = Type
    } = get_t_activity_info(ActivityId),
    ServerType = mod_server_config:get_server_type(),
    if Type == ?ACTIVITY_TYPE_WAR andalso ServerType =/= ?SERVER_TYPE_WAR_AREA ->
        mod_server_rpc:call_war(activity, get_db_activity_info, [ActivityId]);
        true ->
            db:read(#key_activity_info{activity_id = ActivityId})
    end.

get_db_activity_info_or_init(ActivityId) ->
    case get_db_activity_info(ActivityId) of
        null ->
            #db_activity_info{
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

%% @doc 获取所有已经开启的活动id列表
get_open_activity_id_list() ->
    MatchSpec = [{#db_activity_info{activity_id = '$1', state = ?ACTIVITY_STATE_OPEN, _ = '_'}, [], ['$1']}],
    lists:sort(db:select(activity_info, MatchSpec)).

%% @doc 获取所有初始化玩家数据的活动列表
%%get_init_db_activity_info() ->
%%    lists:foldl(
%%        fun(DbActivityInfo, Tmp) ->
%%            #db_activity_info{
%%                activity_id = ActivityId,
%%                state = State
%%            } = DbActivityInfo,
%%            #t_activity_info{
%%                house_type = HouseType
%%            } = get_t_activity_info(ActivityId),
%%            if HouseType == 1 ->
%%                [DbActivityInfo | Tmp];
%%                true ->
%%                    if State =/= ?ACTIVITY_STATE_CLOSE ->
%%                        [DbActivityInfo | Tmp];
%%                        true ->
%%                            Tmp
%%                    end
%%            end
%%        end,
%%        [],
%%        get_all_db_activity_info()
%%    ).
%%    [
%%
%%        DbActivityInfo || DbActivityInfo <- get_all_db_activity_info(),
%%        DbActivityInfo#db_activity_info.state == ?ACTIVITY_STATE_READY orelse
%%            DbActivityInfo#db_activity_info.state == ?ACTIVITY_STATE_OPEN
%%    ].

get_all_db_activity_info(PlayerId) ->
    [
        begin
            #t_activity_info{
                type = Type
            } = get_t_activity_info(ActivityId),
            if Type == ?ACTIVITY_TYPE_PERSON ->
                activity_person:get_db_player_activity_info_or_init(PlayerId, ActivityId);
                true ->
                    get_db_activity_info_or_init(ActivityId)
            end
        end || ActivityId <- get_all_activity_id()
    ].

is_person_activity(ActivityId) ->
    #t_activity_info{
        type = ActivityType
    } = activity:get_t_activity_info(ActivityId),
    ActivityType == ?ACTIVITY_TYPE_PERSON.

get_all_activity_id() ->
    logic_get_activity_id_all_list:get(0).

get_all_activity_id_by_type(Type) ->
    logic_get_activity_id_list_by_type:get(Type, []).

get_t_activity_info(ActivityId) ->
    t_activity_info:assert_get({ActivityId}).
