%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 3月 2021 下午 04:13:43
%%%-------------------------------------------------------------------
-module(api_step_by_step_sy).
-author("Administrator").

%% API
-export([
    enter/2,        % 进入房间
    fight/2,        % 继续挑战
    get_award/2,    % 领取奖励
    fight_result/3  % 等待其他玩家进入最后时间
]).


-include("common.hrl").
-include("p_message.hrl").

%% 进入房间
enter(
    #m_step_by_step_sy_enter_tos{id = Id},
    #conn{player_id = PlayerId} = State) ->
    Result =
        case ?TRY_CATCH2(mod_mission_step_by_step_sy:enter(PlayerId, Id)) of
            ok ->
                ok;
            Result1 ->
                Result1
        end,
    Out = proto:encode(#m_step_by_step_sy_enter_toc{id = Id, result = api_common:api_result_to_enum(Result)}),
    mod_socket:send(Out),
    State.

%% 继续挑战
fight(
    #m_step_by_step_sy_fight_tos{},
    #conn{player_id = PlayerId} = State) ->
    {Result, LoopNum, FightEndTime} =
        case ?TRY_CATCH2(mod_mission_step_by_step_sy:fight(PlayerId)) of
            {ok, {FightCount1, FightEndTime1}} ->
                {ok, FightCount1, FightEndTime1};
            Result1 ->
                {Result1, 0, 0}
        end,
    Out = proto:encode(#m_step_by_step_sy_fight_toc{result = api_common:api_result_to_enum(Result), loop_num = LoopNum, end_fight_time = FightEndTime}),
    mod_socket:send(Out),
    State.

%% 领取奖励
get_award(
    #m_step_by_step_sy_get_award_tos{},
    #conn{player_id = PlayerId} = State) ->
    {Result, LoopNum} =
        case ?TRY_CATCH2(mod_mission_step_by_step_sy:get_award(PlayerId)) of
            {ok, FightCount1} ->
                {ok, FightCount1};
            Result1 ->
                {Result1, 0}
        end,
    Out = proto:encode(#m_step_by_step_sy_get_award_toc{result = api_common:api_result_to_enum(Result), loop_num = LoopNum}),
    mod_socket:send(Out),
    State.


%% 准备开始时间
fight_result(PlayerId, LoopNum, IsWin) ->
    Out = proto:encode(#m_step_by_step_sy_fight_result_toc{loop_num = LoopNum, is_win = IsWin}),
    mod_socket:send(PlayerId, Out).



