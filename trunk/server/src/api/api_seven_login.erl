%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         七天登錄
%%% @end
%%% Created : 10. 五月 2021 下午 12:17:49
%%%-------------------------------------------------------------------
-module(api_seven_login).
-author("Administrator").

%% API
-export([
    api_get_seven_login_data/1,     %% API 获得七天登录数据
    give_award/2,                   %% 领取奖励

    update_cumulative_day/2         %% 更新七天登入数据
]).

-include("common.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").

%% @doc 获得七天登录数据
api_get_seven_login_data(PlayerId) ->
    AlreadyGiveList = mod_seven_login:get_already_give_day_list(PlayerId),
    #sevenlogindata{
        already_give_list = AlreadyGiveList,
        cumulative_day = mod_seven_login:get_cumulative_day(PlayerId)
    }.

%% @doc 领取奖励
give_award(
    #m_seven_login_give_award_tos{today = Today},
    State = #conn{player_id = PlayerId}
) ->
    {Result, DiceId, DiceList} =
        case catch mod_seven_login:give_award(PlayerId, Today) of
            {ok, DiceId1, List} ->
                {?P_SUCCESS, DiceId1, pack_seven_login_dice_list(List)};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), 0, []}
        end,
    Out = proto:encode(#m_seven_login_give_award_toc{result = Result, today = Today, dice_id = DiceId, dice_list = DiceList}),
    mod_socket:send(Out),
    State.

%% @doc 更新七天登入数据
update_cumulative_day(PlayerId, CumulativeDay) ->
    Out = proto:encode(#m_seven_login_update_cumulative_day_toc{cumulative_day = CumulativeDay}),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

%% @doc 结构化七天登录骰子列表
pack_seven_login_dice_list(List) ->
    [#sevenlogindice{type = Type, value = Value} || {Type, Value} <- List].
