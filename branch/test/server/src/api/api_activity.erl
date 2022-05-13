%%%-------------------------------------------------------------------
%%% @author wangZhuFei
%%% @copyright (C) 2018, THYZ
%%% @doc
%%% Created : 12. 三月 2018 15:13
%%%-------------------------------------------------------------------
-module(api_activity).

-export([
    notice_update_activity_time/1,
    notice_player_update_activity_time/2
]).

-export([
    pack_init_activity_info/1
]).

%%-include("p_enum.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("activity.hrl").
-include("p_message.hrl").

%% @doc 玩家活动时间数据
pack_init_activity_info(PlayerId) ->
    pack_activity_info(activity:get_all_db_activity_info(PlayerId)).

%% @doc 推送活动时间
notice_update_activity_time(DbActivityInfoList) ->
    Out = proto:encode(#m_activity_update_activity_time_toc{activity_data = pack_activity_info(DbActivityInfoList)}),
    mod_socket:send_to_all_online_player(Out).

%% @doc 推送个人活动时间
notice_player_update_activity_time(PlayerId, DbPlayerActivityInfo) ->
    Out = proto:encode(#m_activity_update_activity_time_toc{activity_data = pack_activity_info([DbPlayerActivityInfo])}),
    mod_socket:send(PlayerId, Out).

%% @doc 打包活动时间列表
pack_activity_info(DbActivityInfoList) ->
    [
        begin
            case is_record(DbActivityInfo, db_activity_info) of
                true ->
                    #db_activity_info{
                        activity_id = ActivityId,
%%                open_time = OpenTime,
%%                close_time = CloseTime,
                        config_open_time = OpenTime,
                        config_close_time = CloseTime,
                        state = State
                    } = DbActivityInfo;
                false ->
                    #db_player_activity_info{
                        activity_id = ActivityId,
%%                open_time = OpenTime,
%%                close_time = CloseTime,
                        config_open_time = OpenTime,
                        config_close_time = CloseTime,
                        state = State
                    } = DbActivityInfo
            end,

            ApiState =
                if
                    State == ?ACTIVITY_STATE_READY ->
                        1;
                    State == ?ACTIVITY_STATE_OPEN ->
                        2;
                    State == ?ACTIVITY_STATE_CLOSE ->
                        3
                end,
%%            ?DEBUG("pack_activity_info:~p~n", [{ActivityId, OpenTime, CloseTime}]),
%%            {OpenTime, CloseTime} = activity:get_activity_start_and_end_time(ActivityId),
            #activity_data{
                activity_id = ActivityId,
                start_time = OpenTime,
                close_time = CloseTime,
                activity_state = ApiState,
                player_join_state = ?FALSE
            }
        end
        || DbActivityInfo <- DbActivityInfoList
    ].
