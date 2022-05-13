%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            socket模块
%%% @end
%%% Created : 27. 十二月 2017 下午 3:16
%%%-------------------------------------------------------------------
-module(mod_socket).
-include("scene.hrl").
-include("common.hrl").

%% API
-export([
    send/1,                                 %% 发送socket给该玩家(玩家进程调用)
    send/2,                                 %% 发送socket给在线玩家
    send_to_player_list/2,
    send_to_player_list/3,
    send_to_all_online_player/1,
    send_to_all_online_player_by_function/2,
    send_to_all_online_player_by_filter/2
]).


%% ----------------------------------
%% @doc 	发送socket给该玩家(玩家进程调用)
%% @throws 	none
%% @end
%% ----------------------------------
send(Data) ->
    ?t_assert(?PROCESS_TYPE == ?PROCESS_TYPE_CLIENT_WORKER, not_client_worker),
    case mod_game:is_enter_game() of
        true ->
            client_sender_worker:send(Data);
        false ->
            noop
    end.

%% ----------------------------------
%% @doc 	发送socket给在线玩家
%% @throws 	none
%% @end
%% ----------------------------------
send(SenderWorker, Data) when is_pid(SenderWorker) ->
    client_sender_worker:send(SenderWorker, Data);
send(PlayerId, Data) when PlayerId >= 10000 ->
%%    IsRobot = ?IF(get({is_robot, PlayerId}), true, false),
%%    if
%%        IsRobot ->
%%            false;
%%        true ->
    ProcessType = ?PROCESS_TYPE,
    %% 场景进程
    if
        ProcessType == ?PROCESS_TYPE_SCENE_WORKER ->
            case ?GET_PLAYER_SENDER_WORKER(PlayerId) of
                null ->
                    %% 忽略
                    false;
                ?UNDEFINED ->
                    ?WARNING("no sender worker ~p~n", [{PlayerId, Data, get(?DICT_SCENE_ID)}]),
                    false;
                SenderWorker ->
                    client_sender_worker:send(SenderWorker, Data),
                    true
            end;
    %% 玩家进程
        ProcessType == ?PROCESS_TYPE_CLIENT_WORKER ->
            case ?GET_PLAYER_SENDER_WORKER(PlayerId) of
                null ->
                    %% 忽略
                    false;
                ?UNDEFINED ->
                    case ets:lookup(?ETS_OBJ_PLAYER, PlayerId) of
                        [] ->
                            false;
                        [R] ->
                            client_sender_worker:send(R#ets_obj_player.sender_worker, Data),
                            true
                    end;
                SenderWorker ->
                    case mod_game:is_enter_game() of
                        true ->
                            client_sender_worker:send(SenderWorker, Data);
                        false ->
                            noop
                    end,
                    true
            end;
    %% 其他进程
        true ->
            case ets:lookup(?ETS_OBJ_PLAYER, PlayerId) of
                [] ->
                    false;
                [R] ->
                    client_sender_worker:send(R#ets_obj_player.sender_worker, Data),
                    true
            end
    end;
send(_PlayerId, _Data) ->
    true.
%%    end.


%% ----------------------------------
%% @doc 	发送socket给在线玩家列表
%% @throws 	none
%% @end
%% ----------------------------------
send_to_player_list(PlayerList, Data) ->
    send_to_player_list(PlayerList, Data, []).
%% @doc Options:
%%         > ignore_player_id  不发送的玩家id  默认为0
%%
send_to_player_list([], _Data, _Options) ->
    noop;
send_to_player_list(PlayerIdList, Data, Options) ->
    IgnorePlayerId =
        if Options == [] ->
            0;
            true ->
                util_list:opt(ignore_player_id, Options, 0)
        end,
    lists:foreach(
        fun(PlayerId) ->
            if
                IgnorePlayerId == PlayerId ->
                    noop;
                true ->
                    send(PlayerId, Data)
            end
        end,
        PlayerIdList
    ).

%% ----------------------------------
%% @doc 	发送消息给所有在线玩家
%% @throws 	none
%% @end
%% ----------------------------------
send_to_all_online_player(Data) ->
    ProcessType = ?PROCESS_TYPE,
    PlayerIdList =
        case ProcessType of
            ?PROCESS_TYPE_SCENE_WORKER ->
                %% 场景进程获取该场景的玩家id列表
                mod_scene_player_manager:get_all_obj_scene_player_id();
            _ ->
                mod_online:get_all_online_player_id()
        end,
    send_to_player_list(PlayerIdList, Data),
    PlayerIdList.

%% ----------------------------------
%% @doc 	发送给所有功能开启的在线玩家
%% @throws 	none
%% @end
%% ----------------------------------
send_to_all_online_player_by_function(Data, FunctionId) ->
    FilterFun = fun(PlayerId) ->
        mod_function:is_open(PlayerId, FunctionId)
                end,
    send_to_all_online_player_by_filter(Data, FilterFun).


%% ----------------------------------
%% @doc 	发送给所有在线玩家 带过滤
%% @throws 	none
%% @end
%% ----------------------------------
send_to_all_online_player_by_filter(Data, FilterFun) ->
    lists:foreach(
        fun(PlayerId) ->
            case FilterFun(PlayerId) of
                true ->
                    case mod_obj_player:get_obj_player(PlayerId) of
                        null ->
                            noop;
                        ObjPlayer ->
                            #ets_obj_player{
                                sender_worker = SenderWorker
                            } = ObjPlayer,
                            client_sender_worker:send(SenderWorker, Data)
                    end;
                _ ->
                    noop
            end
        end,
        mod_online:get_all_online_player_id()
    ).
