%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            玩家进程调用模块
%%% @end
%%% Created : 27. 十二月 2017 下午 3:34
%%%-------------------------------------------------------------------
-module(mod_apply).

-include("common.hrl").
%% API
-export([
    apply_to_online_player/4,
    apply_to_online_player/5,
    apply_to_online_player/6,
    apply_to_all_online_player/3,
    apply_to_all_online_player/4,
    apply_to_all_online_player_args/3,
    apply_to_all_online_player_args/4,
    apply_to_all_online_player_2/3,
    apply_to_all_online_player_2/4
]).

%% ----------------------------------
%% @doc apply给所有在线玩家进程执行
%% @throws 	none
%% @end
%% ----------------------------------
apply_to_all_online_player(M, F, A) ->
    apply_to_all_online_player(M, F, A, normal).
apply_to_all_online_player(M, F, A, Type) ->
    PlayerIdList = case Type of
                       normal ->
                           mod_online:get_all_online_player_id();
                       _ ->
                           mod_player:get_all_player_id()
                   end,
%%    PlayerIdList = mod_player:get_all_player_id(),
    lists:foreach(
        fun(PlayerId) ->
            apply_to_online_player(PlayerId, M, F, A, Type)
        end,
        PlayerIdList
    ).

%% ----------------------------------
%% @doc apply给所有在线玩家进程执行
%% @throws 	none
%% @end
%% ----------------------------------
-spec apply_to_all_online_player_args(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].

-spec apply_to_all_online_player_args(M, F, A, Type) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()],
    Type :: atom().

apply_to_all_online_player_args(M, F, A) ->
    apply_to_all_online_player_args(M, F, A, normal).
apply_to_all_online_player_args(M, F, A, Type) ->
    PlayerIdList = case Type of
                       normal ->
                           mod_online:get_all_online_player_id();
                       _ ->
                           mod_player:get_all_player_id()
                   end,
%%    PlayerIdList = mod_player:get_all_player_id(),
    lists:foreach(
        fun(PlayerId) ->
            apply_to_online_player(PlayerId, M, F, [PlayerId | A], Type)
        end,
        PlayerIdList
    ).


%% ----------------------------------
%% @doc apply给所有在线玩家进程执行
%% @throws 	none
%% @end
%% ----------------------------------
-spec apply_to_all_online_player_2(M, F, A) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()].

-spec apply_to_all_online_player_2(M, F, A, Type) -> term() when
    M :: module(),
    F :: atom(),
    A :: [term()],
    Type :: atom().

apply_to_all_online_player_2(M, F, A) ->
    apply_to_all_online_player_2(M, F, A, normal).
apply_to_all_online_player_2(M, F, A, Type) ->
    PlayerIdList = case Type of
                       normal ->
                           mod_online:get_all_online_player_id();
                       _ ->
                           mod_player:get_all_player_id()
                   end,
%%    PlayerIdList = mod_player:get_all_player_id(),
    lists:foreach(
        fun(PlayerId) ->
            apply_to_online_player(PlayerId, M, F, [PlayerId, A], Type)
        end,
        PlayerIdList
    ).

%% ----------------------------------
%% @doc 	apply给在线玩家进程执行
%% @throws 	none
%% @end
%% ----------------------------------
-spec apply_to_online_player(PlayerId, M, F, A) -> term() when
    PlayerId :: integer(),
    M :: module(),
    F :: atom(),
    A :: [term()].
-spec apply_to_online_player(PlayerId, M, F, A, Type) -> term() when
    PlayerId :: integer(),
    M :: module(),
    F :: atom(),
    A :: [term()],
    Type :: atom().
-spec apply_to_online_player(Node, PlayerId, M, F, A, Type) -> term() when
    Node :: node(),
    PlayerId :: integer(),
    M :: module(),
    F :: atom(),
    A :: [term()],
    Type :: atom().

apply_to_online_player(ClientWorker, M, F, A) when is_pid(ClientWorker) ->
    client_worker:apply(ClientWorker, M, F, A);
apply_to_online_player(PlayerId, M, F, A) ->
    apply_to_online_player(PlayerId, M, F, A, normal).

apply_to_online_player(PlayerId, M, F, A, Type) ->
    apply_to_online_player(node(), PlayerId, M, F, A, Type).

apply_to_online_player(Node, PlayerId, M, F, A, Type) ->
    if
        Node == node() ->
            case mod_obj_player:get_obj_player(PlayerId) of
                null ->
                    %% 玩家不在线
                    case Type of
%%                        game_worker ->
%%                            %% game_worker 执行
%%                            game_worker:apply(M, F, A);
%%                        store ->
%%                            %% 存mysql
%%                            mod_offline_apply:store(PlayerId, M, F, A);
                        normal ->
                            %% 不执行
                            noop;
                        _ ->
                            %% game_worker 执行
                            game_worker:apply(M, F, A)
                    end;
                ObjPlayer ->
                    client_worker:apply(ObjPlayer#ets_obj_player.client_worker, M, F, A)
            end;
        true ->
            rpc:cast(Node, mod_apply, apply_to_online_player, [PlayerId, M, F, A, Type])
    end.
