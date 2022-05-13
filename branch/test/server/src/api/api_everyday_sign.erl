%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 27. 三月 2018 10:18
%%%-------------------------------------------------------------------
-module(api_everyday_sign).
-author("home").

%% API
-export([
%%    get_everyday_sign_info/2,   %% 获得每日签到数据
    everyday_sign/2             %% 每日签到/补签
]).

-export([
    api_get_everyday_sign_info/1,
    notice_time/3                   %% 通知天数
]).

-include("common.hrl").
-include("p_message.hrl").
%%-include("gen/db.hrl").
-include("p_enum.hrl").

%% 获得每日签到数据
%%get_everyday_sign_info(
%%    #m_everyday_sign_get_everyday_sign_info_tos{},
%%    State = #conn{player_id = PlayerId}
%%) ->
%%    ?REQUEST_INFO("获得每日签到数据"),
%%    {Day, Today} = mod_everyday_sign:get_everyday_sign_info(PlayerId),
%%%%    EverydaySignData = api_get_everyday_sign_info(PlayerId),
%%    Out = proto:encode(#m_everyday_sign_get_everyday_sign_info_toc{day = Day, today = Today}),
%%    mod_socket:send(Out),
%%    State.

api_get_everyday_sign_info(PlayerId) ->
    {Day, Today, Round} = mod_everyday_sign:get_everyday_sign_info(PlayerId),
    pack_everyday_sign_data(Day, Today, Round).

%% 每日签到/补签     (0:等待领取，1:已领取)
everyday_sign(
    #m_everyday_sign_everyday_sign_tos{today = Today, round = Round},
    State = #conn{player_id = PlayerId}
) ->
    ?REQUEST_INFO("每日签到/补签"),
%%    {Result, EverydaySign} =
%%        case catch mod_everyday_sign:everyday_sign(PlayerId, Today) of
%%            {ok, EverydaySignData1} ->
%%                {?P_SUCCESS, EverydaySignData1};
%%            R ->
%%                R1 = api_common:api_result_to_enum(R),
%%                {R1, null}
%%        end,
%%    EverydaySignData = pack_everyday_sign_data(EverydaySign),
    Result = api_common:api_result_to_enum(catch mod_everyday_sign:everyday_sign(PlayerId, Round, Today)),
    Out = proto:encode(#m_everyday_sign_everyday_sign_toc{result = Result, today = Today, round = Round}),
    mod_socket:send(Out),
    State.

%% 通知天数
notice_time(PlayerId, Day, Round)->
    Out = proto:encode(#m_everyday_sign_notice_day_toc{day = Day, round = Round}),
    mod_socket:send(PlayerId, Out).

%% 打包每日签到数据
pack_everyday_sign_data(Day, Today, Round) ->
%%    {Today, State} =
%%        case is_record(EverydaySign, db_player_everyday_sign) of
%%            true ->
%%                #db_player_everyday_sign{
%%                    today = Today1,
%%                    state = State1
%%                } = EverydaySign,
%%                {Today1, State1};
%%            _ ->
%%                {0, 0}
%%        end,
    #everydaysigndata{day = Day, today = Today, round = Round}.
