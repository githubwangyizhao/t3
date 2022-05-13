%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         每日任务
%%% @end
%%% Created : 07. 十二月 2020 上午 11:15:24
%%%-------------------------------------------------------------------
-module(api_daily_task).
-author("yizhao.wang").

-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").
-include("player_game_data.hrl").
-include("gen/db.hrl").

%% API
-export([
    %% 请求接口
    get_info/2,                                 %% 获得每日任务信息
    get_award/2,                                %% 获得每日任务奖励
    get_points_award/2,                         %% 获得每日积分奖励

    %% 推送接口
    notice_refresh_daily_task_data/1,           %% 通知刷新每日任务（日常任务被重置后，客户端重新拉取任务数据）
    notice_update_daily_task_data/2,            %% 通知更新每日任务
    notice_update_task_show/2,                  %% 通知更新任务展示

    pack_daily_task_data_list/1                 %% 打包任务数据
]).

%% ----------------------------------
%% @doc 	获得每日任务数据
%% @throws 	none
%% @end
%% ----------------------------------
get_info(
    #m_daily_task_get_info_tos{},
    #conn{player_id = PlayerId} = State
) ->
    DailyTaskDataList = mod_daily_task:get_player_daily_task_data_list(PlayerId),
    Reply =
        proto:encode( #m_daily_task_get_info_toc{
            points = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_DAILY_POINTS),
            points_rewards = mod_daily_task:get_daily_points_award_records(PlayerId),
            daily_task_data_list = pack_daily_task_data_list(DailyTaskDataList)
        }),
    mod_socket:send(Reply),
    State.

%% ----------------------------------
%% @doc 	获得每日任务奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_award(
    #m_daily_task_get_award_tos{id = Id},
    #conn{player_id = PlayerId} = State
) ->
    Result = api_common:api_result_to_enum(catch mod_daily_task:get_award(PlayerId, Id)),
    Reply = proto:encode(#m_daily_task_get_award_toc{
        result = Result,
        id = Id,
        points = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_DAILY_POINTS)
    }),
    mod_socket:send(Reply),
    mod_daily_task:try_update_task_show(PlayerId),
    State.

%% ----------------------------------
%% @doc 	获得每日积分奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_points_award(
    #m_daily_task_get_points_award_tos{id = Id},
    #conn{player_id = PlayerId} = State
) ->
    Result = api_common:api_result_to_enum(catch mod_daily_task:get_points_award(PlayerId, Id)),
    Reply = proto:encode(#m_daily_task_get_points_award_toc{
        result = Result,
        id = Id
    }),
    mod_socket:send(Reply),
    State.

%% ----------------------------------
%% @doc 	通知更新每日任务数据
%% @throws 	none
%% @end
%% ----------------------------------
notice_update_daily_task_data(PlayerId, DailyTaskDataList) ->
    Out = proto:encode(#m_daily_task_notice_update_daily_task_data_toc{daily_task_data_list = pack_daily_task_data_list(DailyTaskDataList)}),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知任务刷新
%% @throws 	none
%% @end
%% ----------------------------------
notice_refresh_daily_task_data(PlayerId) ->
    mod_socket:send(PlayerId, proto:encode(#m_daily_task_notice_reset_daily_task_data_toc{})).

%% ----------------------------------
%% @doc 	通知更新任务展示数据
%% @throws 	none
%% @end
%% ----------------------------------
notice_update_task_show(PlayerId, TaskShow) ->
    Out = proto:encode(#m_daily_task_notice_update_task_show_toc{task_show = TaskShow}),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	打包任务数据
%% @throws 	none
%% @end
%% ----------------------------------
pack_daily_task_data_list(DailyTaskDataList) ->
    [
        #dailytaskdata{
            id = Id,
            value = Value,
            state = State
        } || #db_player_daily_task{id = Id, value = Value, state = State} <- DailyTaskDataList
    ].