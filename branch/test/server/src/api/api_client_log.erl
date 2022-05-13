%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         客户端日志
%%% @end
%%% Created : 07. 四月 2021 下午 06:44:58
%%%-------------------------------------------------------------------
-module(api_client_log).
-author("Administrator").

-include("p_message.hrl").
-include("common.hrl").

%% API
-export([
    client_log/2
]).

%% @doc 客户端日志
client_log(
    #m_client_log_client_log_tos{id = Id},
    State = #conn{player_id = PlayerId}
) ->
    case lists:member({Id},t_client_log:get_keys()) of
        true ->
            mod_log:write_player_client_log(PlayerId, Id);
        false ->
            noop
    end,
    State.
