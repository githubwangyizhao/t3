%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 11月 2021 下午 04:43:02
%%%-------------------------------------------------------------------
-author("Administrator").

-define(WHEEL_MSG_JOIN_WHEEL, wheel_msg_join_wheel).
-define(WHEEL_MSG_BET, wheel_msg_bet).
-define(WHEEL_MSG_GET_RECORD, wheel_msg_get_record).
-define(WHEEL_MSG_GET_BET_RECORD, wheel_msg_get_bet_record).
-define(WHEEL_MSG_GET_PLAYER_LIST, wheel_msg_get_player_list).
-define(WHEEL_MSG_EXIT_WHEEL, wheel_msg_exit_wheel).
-define(WHEEL_MSG_BALANCE, wheel_msg_balance).
-define(WHEEL_MSG_GET_LAST_BET_LIST, wheel_msg_get_last_bet_list).
-define(WHEEL_MSG_USE_LAST_BET_LIST, wheel_msg_use_last_bet_list).

-define(WHEEL_TIME, 40).

-define(SERVER_PLAYER_LIST, server_player_list).

-define(WHEEL_DATA, wheel_data).

-record(wheel_data, {
    bet_list = [],
    player_bet_lists = [],
    time = 0,
    left_rank_list = [],
    right_rank_list = [],
    player_rank_list = []
}).

-define(WHEEL_PLAYER_DATA, wheel_player_data).
-record(wheel_player_data, {
    player_id,
    platform_id,
    server_id,
    type,
    bet_list = [],
    total_award_num = 0,
    model_head_figure,
    award = 0,
    last_bet_list = []
}).