%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 11月 2021 下午 05:01:30
%%%-------------------------------------------------------------------
-module(mod_one_vs_one).
-author("Administrator").

-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").

%% API
-export([
    get_room_list/2,
    exit_room_list/1,
    join_room/3,

    leave_game/1
]).

get_room_list(PlayerId, Type) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_BETTLE),
    mod_interface_cd:assert({?MODULE, get_player_room_list, Type}, 100),
    PlatformId = mod_server_config:get_platform_id(),
    ServerId = mod_player:get_player_data(PlayerId, server_id),
    one_vs_one_srv:call({get_room_list, PlayerId, PlatformId, ServerId, Type}).
%%    mod_server_rpc:call_war(one_vs_one_srv_mod, handle_get_room_list, [PlayerId, Type]).

exit_room_list(PlayerId) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_BETTLE),
    one_vs_one_srv:call({exit_room_list, PlayerId}).

leave_game(PlayerId) ->
    case mod_function:is_open(PlayerId, ?FUNCTION_BETTLE) of
        true ->
            one_vs_one_srv:cast({exit_room_list, PlayerId});
        false ->
            noop
    end.

join_room(PlayerId, Type, RoomId) ->
    mod_function:assert_open(PlayerId, ?FUNCTION_BETTLE),
    #t_bettle{
        cost_list = CostList,
        amount = Amount
    } = one_vs_one_srv_mod:get_t_bettle(Type),
    ?ASSERT(RoomId >= 1 andalso RoomId =< Amount),
    mod_prop:assert_prop_num(PlayerId, CostList),
    one_vs_one_srv:call({join_room, PlayerId, api_player:pack_model_head_figure(PlayerId), Type, RoomId}).