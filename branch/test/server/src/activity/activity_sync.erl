%%%-------------------------------------------------------------------
%%% @author        home
%%% @copyright (C) 2016, THYZ
%%% @doc            活动跨服同步
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(activity_sync).

%% API
-export([
    init/0,
    push/1,
    get_war_activity_list/0,
    handle_receive_war_push/2,
    handle_clock_push/0
]).

-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
-include("activity.hrl").
-include("gen/table_db.hrl").
%% @doc  活动进程启动
init() ->
    Tran = fun() ->
        lists:foreach(
            fun(R) ->
                #db_activity_info{
                    activity_id = ActivityId
                } = R,
                case t_activity_info:get({ActivityId}) of
                    null ->
                        ?WARNING("删除活动:~p", [R]),
                        db:delete(R);
                    T ->
                        if T#t_activity_info.is_valid == 0 ->
                            ?WARNING("删除活动:~p", [R]),
                            db:delete(R);
                            true ->
                                noop
                        end
                end
            end,
            ets:tab2list(activity_info)
        )
           end,
    db:do(Tran),

    ServerType = mod_server_config:get_server_type(),
    case ServerType of
        ?SERVER_TYPE_GAME ->
            % 主动拉取活动
            pull_war_activity();
        _ ->
            % 推送活动
            {ok, ActivityList} = get_war_activity_list(),
            push(ActivityList, true),
            start_push_timer()
    end.


start_push_timer() ->
    Now = util_time:timestamp(),
    TomorrowZeroTime = util_time:get_today_zero_timestamp(Now) + 86400,
    ?INFO("初始化0点推送活动定时器~p",[TomorrowZeroTime]),
    erlang:send_after((TomorrowZeroTime - Now) * 1000, self(), ?ACTIVITY_MSG_CLOCK_PUSH).

handle_clock_push() ->
    start_push_timer(),
% 推送活动
    ?INFO("0点推送活动"),
%%    ServerType = server_config:get_server_type(),
    {ok, ActivityList} = get_war_activity_list(),
    push(ActivityList, true).

%% @doc 推送活动到游戏节点
push(ActivityInfoList) ->
    push(ActivityInfoList, false).
push(ActivityInfoList, IsReset) ->
    ?ASSERT(mod_server:is_game_server() == false, push_must_not_game_server),
    ?INFO("推送活动:~p", [{ActivityInfoList, IsReset}]),
    lists:foreach(
        fun(GameNode) ->
            activity_srv:send(GameNode, {?ACTIVITY_MSG_PUSH_ACTIVITY, ActivityInfoList, IsReset})
        end,
        mod_server:get_all_game_node()
    ),
    ?INFO("推送活动完毕").

%% @doc 收到活动同步推送
handle_receive_war_push(DbActivityInfoList, IsReset) ->
    ?ASSERT(mod_server:is_game_server(), receive_push_must_game_server),
    ?INFO("收到活动推送:~p", [{DbActivityInfoList, IsReset}]),
    Tran = fun() ->
        if IsReset ->
            %% 重置活动
            clean_by_type(?ACTIVITY_TYPE_WAR);
            true ->
                noop
        end,
        lists:foreach(
            fun(DbActivityInfo) ->
                #db_activity_info{
                    activity_id = ActivityId,
                    state = State
                } = DbActivityInfo,
                OldDbActivityInfo = activity:get_db_activity_info(ActivityId),
                if OldDbActivityInfo =/= null ->
                    db:delete(OldDbActivityInfo);
                    true ->
                        noop
                end,
                RealState =
                    if State =/= ?ACTIVITY_STATE_CLOSE ->
                        %% 开服合服限制
                        case activity_time_parse:is_server_limit(ActivityId) of
                            true ->
                                ?INFO("开服合服限制:~p", [ActivityId]),
                                ?ACTIVITY_STATE_CLOSE;
                            false ->
                                State
                        end;
                        true ->
                            State
                    end,
                Now = util_time:timestamp(),

                #t_activity_info{
                    merge_server_day_limit_list = MergeServerDayLimitList,
                    open_server_day_limit_list = OpenServerDayLimitList
                } = activity:get_t_activity_info(ActivityId),

                {RealStartTime, RealEndTime} =
                    if MergeServerDayLimitList =/= [] orelse OpenServerDayLimitList =/= [] ->
                        %% 开服，合服限制的活动， 游戏服需要单独解析活动时间
                        {StartTime_1, EndTime_1} = activity_time_parse:parse_activity_time(ActivityId, Now),
                        ?INFO("重新解析活动时间:~p", [{ActivityId, {StartTime_1, EndTime_1}}]),
                        {StartTime_1, EndTime_1};
                        true ->
                            {DbActivityInfo#db_activity_info.config_open_time, DbActivityInfo#db_activity_info.config_close_time}
                    end,
                %% 更新活动
                NewDbActivityInfo = DbActivityInfo#db_activity_info{
                    row_key = ?UNDEFINED,
                    state = RealState,
                    config_open_time = RealStartTime,
                    config_close_time = RealEndTime
                },
                activity_handle:update_activity(NewDbActivityInfo)
            end,
            DbActivityInfoList
        )
           end,
    db:do(Tran).

%% @doc 拉取活动
pull_war_activity() ->
%%    pull_activity_1(?SERVER_TYPE_ZONE, server_config:get_zone_node()),
%%    pull_activity_1(?SERVER_TYPE_WAR, server_config:get_war_node()).
%%
%%pull_activity_1(ServerType, Node) ->
    ?INFO("拉取活动"),
    clean_by_type(?ACTIVITY_TYPE_WAR),
    case ?CATCH(activity_srv:call(mod_server_config:get_war_area_node(), ?ACTIVITY_MSG_PULL_ACTIVITY)) of
        {ok, ActivityInfoList} ->
            handle_receive_war_push(ActivityInfoList, true),
            ?INFO("拉取活动成功");
        Other ->
            ?WARNING("拉取活动失败:~p", [{Other}])
    end.

%% @doc 清理该服务器类型活动
clean_by_type(Type) ->
    ?INFO("清理该服务器活动:~p", [Type]),
    Tran = fun() ->
        lists:foreach(
            fun(ActivityId) ->
                case activity:get_db_activity_info(ActivityId) of
                    null ->
                        noop;
                    R ->
                        db:delete(R)
                end
            end,
            activity:get_all_activity_id_by_type(Type)
        )
           end,
    db:do(Tran).

%% @doc 获取该活动节点所有活动信息
get_war_activity_list() ->
    {
        ok,
        [
            activity:get_db_activity_info_or_init(ActivityId)
            || ActivityId <- activity:get_all_activity_id_by_type(?ACTIVITY_TYPE_WAR)
        ]
    }.
