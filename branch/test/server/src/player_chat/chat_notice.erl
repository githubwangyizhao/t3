%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. 12月 2021 上午 11:29:34
%%%-------------------------------------------------------------------
-module(chat_notice).
-author("Administrator").

-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("global_data.hrl").
-include("gen/db.hrl").

%% API
-export([
    shi_shi_cai_gold/2,
    shi_shi_cai_red_gem/2,
    wheel_gold/2,
    wheel_red_gem/2,
    wheel_gold_big_rate/3,
    wheel_red_gem_big_rate/3,
    broadcast_msg_player_laba/3,

    player_login/1
]).

%% @doc 时时彩金币
shi_shi_cai_gold(PlayerName, Num) ->
    spawn(fun() -> player_chat_srv:chat_notice(?CHAT_NOTICE_NOTICE_1, [PlayerName, Num]) end).

%% @doc 时时彩赏金石
shi_shi_cai_red_gem(PlayerName, Num) ->
    spawn(fun() -> player_chat_srv:chat_notice(?CHAT_NOTICE_NOTICE_2, [PlayerName, Num]) end).

%% @doc 无尽对决金币
wheel_gold(PlayerId, Num) ->
    if
        Num >= 10000000 ->
            spawn(fun() -> player_chat_srv:chat_notice(?CHAT_NOTICE_NOTICE_3, [get_player_name(PlayerId), Num]) end);
        true ->
            noop
    end.

%% @doc 无尽对决赏金石
wheel_red_gem(PlayerId, Num) ->
    if
        Num >= 1000000 ->
            spawn(fun() -> player_chat_srv:chat_notice(?CHAT_NOTICE_NOTICE_4, [get_player_name(PlayerId), Num]) end);
        true ->
            noop
    end.

%% @doc 无尽对决金币大倍率
wheel_gold_big_rate(PlayerId, Rate, Num) ->
    if
        (Rate == 51 orelse Rate == 25) andalso Num >= 100000000 ->
            spawn(fun() ->
                player_chat_srv:chat_notice(?CHAT_NOTICE_NOTICE_5, [get_player_name(PlayerId), Rate, Num]) end);
        true ->
            noop
    end.

%% @doc 无尽对决赏金石大倍率
wheel_red_gem_big_rate(PlayerId, Rate, Num) ->
    if
        (Rate == 51 orelse Rate == 25) andalso Num >= 10000000 ->
            spawn(fun() ->
                player_chat_srv:chat_notice(?CHAT_NOTICE_NOTICE_6, [get_player_name(PlayerId), Rate, Num]) end);
        true ->
            noop
    end.

%% @doc 广播玩家拉霸消息
broadcast_msg_player_laba(PlayerId, CostType, Num) ->
    if
        CostType == ?ITEM_GOLD, Num >= 10000000 ->
            spawn(fun() -> player_chat_srv:chat_notice(?CHAT_NOTICE_NOTICE_7, [get_player_name(PlayerId), Num]) end);
        CostType == ?ITEM_RUCHANGJUAN, Num >= 1000000 ->
            spawn(fun() -> player_chat_srv:chat_notice(?CHAT_NOTICE_NOTICE_8, [get_player_name(PlayerId), Num]) end);
        true ->
            noop
    end.

%% @doc 玩家登录
player_login(PlayerId) ->
    mod_player_chat:send_system_template_message(PlayerId, ?CHAT_NOTICE_NOTICE_13, []).

%% @doc 获得玩家名字
get_player_name(PlayerId) ->
    case global_data:get_global_player_data(PlayerId) of
        GlobalPlayerData when is_record(GlobalPlayerData, global_player_data) ->
            #global_player_data{
                db_player = DbPlayer
            } = GlobalPlayerData,
            #db_player{
                server_id = ServerId,
                nickname = Nickname
            } = DbPlayer,
            mod_player:get_player_name(ServerId, Nickname);
        Reason ->
            exit({error, Reason})
    end.

