%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 01. 二月 2018 20:54
%%%-------------------------------------------------------------------
-module(api_achievement).
-author("home").

%% API
-export([
    %% api
    api_get_achievement_data_list/1,                %% api成就信息
    %% function
    get_info/2,                                     %% 获得成就信息
    get_award/2,                                    %% 成就奖励领取
    %% notice
    notice_update_achievement_data/2,               %% 增加成就数据
    pack_achievement_data/1                         %% 打包成就数据
]).

-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").

%% @doc api成就信息
api_get_achievement_data_list(PlayerId) ->
    mod_achievement:get_achievement_data_list(PlayerId).

%% @doc  获得成就信息
get_info(
    #m_achievement_get_info_tos{},
    #conn{player_id = PlayerId} = State) ->
    Out = proto:encode(#m_achievement_get_info_toc{achievement_data_list = api_get_achievement_data_list(PlayerId)}),
    mod_socket:send(Out),
    State.

%% @doc  获得成就奖励
get_award(
    #m_achievement_get_award_tos{type = Type},
    #conn{player_id = PlayerId} = State) ->
    {Result, Tuple} =
        case catch mod_achievement:get_award(PlayerId, Type) of
            {ok, Tuple1} ->
                {?P_SUCCESS, Tuple1};
            R ->
                R1 = api_common:api_result_to_enum(R),
                {R1, {0, 0, 0, 0}}
        end,
    AchievementData = pack_achievement_data(Tuple),
    Out = proto:encode(#m_achievement_get_award_toc{result = Result, achievement_data = AchievementData}),
    mod_socket:send(Out),
    mod_daily_task:try_update_task_show(PlayerId),
    State.

%% @doc 通知更新成就数据
notice_update_achievement_data(PlayerId, Tuple) ->
    Out = proto:encode(#m_achievement_notice_update_achievement_data_toc{achievement_data = pack_achievement_data(Tuple)}),
    mod_socket:send(PlayerId, Out).

%% @doc 打包成就数据
pack_achievement_data({Type, Id, Value, State}) ->
    #achievementdata{
        type = Type,
        id = Id,
        value = min(Value, ?MAX_NUMBER_VALUE_64),
        state = State
    }.