%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 11ζ 2021 δΈε 05:07:14
%%%-------------------------------------------------------------------
-author("Administrator").

-record(ets_one_vs_one_room_data,{
    row_key,
    type,
    room_id,
    player_list,
    scene_worker
}).

-define(DICT_ONE_VS_ONE_PLAYER_DATA, dict_one_vs_one_player_data).
-record(one_vs_one_player_data, {
    player_id,
    type,
    room_id,
    platform_id,
    server_id
}).