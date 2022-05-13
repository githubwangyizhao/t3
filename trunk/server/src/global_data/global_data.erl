%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         全局數據(戰區服)
%%% @end
%%% Created : 27. 11月 2021 下午 04:39:46
%%%-------------------------------------------------------------------
-module(global_data).
-author("Administrator").

-include("common.hrl").
-include("global_data.hrl").
-include("system.hrl").

%% API
-export([
    get_global_player_data/1
]).

%% HANDLE
-export([
    get_global_player_data_game/1
]).

get_global_player_data(PlayerId) ->
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_WAR_AREA ->
            Fun =
                fun() ->
                    {PlatformId, ServerId} = mod_player:get_platform_id_and_server_id(PlayerId),
                    case mod_server_rpc:call_game_server(PlatformId, ServerId, ?MODULE, get_global_player_data_game, [PlayerId]) of
                        GlobalPlayerData when is_record(GlobalPlayerData, global_player_data) ->
                            GlobalPlayerData;
                        Reason ->
                            exit(Reason)
                    end
                end,
            mod_cache:cache_data({get_global_player_data, PlayerId}, Fun, 10 * ?MINUTE_S);
        _ ->
            mod_server_rpc:call_war(?MODULE, get_global_player_data, [PlayerId])
    end.
get_global_player_data_game(PlayerId) ->
    #global_player_data{
        db_player = mod_player:get_player(PlayerId),
        db_player_data = mod_player:get_db_player_data(PlayerId)
    }.
