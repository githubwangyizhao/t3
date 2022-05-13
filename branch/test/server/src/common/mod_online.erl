%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家在线数据模块
%%% @end
%%% Created : 08. 九月 2016 上午 9:51
%%%-------------------------------------------------------------------
-module(mod_online).

-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
-include("scene.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").

%%API
-export([
    is_online/1,                            %% 是否在线
    kill_online_player/1,                   %% 杀死玩家进程
%%    kill_all_robot/0,                       %% 杀死所有机器人
    get_all_online_player_id/0,             %% 获取所有在线玩家id
%%    get_all_online_not_new_player_id/0,     %% 获取所有在线非新手玩家id
%%    get_all_online_not_robot_player_id/0,   %% 获取所有在线非机器人玩家id
    get_all_online_player_id_by_function/1, %% 获取所有功能开启的在线玩家列表
    get_all_online_player_id_by_filter/1,   %% 通过过滤函数获取在线玩家列表
    get_online_count/0,                     %% 获取在线人数
    get_online_count_by_channel/1,          %% 获取该渠道在线人数
    get_common_online_player_count/0,       %% 获取在线正常玩家数量
    wait_all_online_player_exit/1
]).


%% 发消息到玩家进程
-export([
    send_msg_to_all_online_player_worker/1
]).

%% ----------------------------------
%% @doc 	获取在线人数
%% @throws 	none
%% @end
%% ----------------------------------
get_online_count() ->
    case mod_server:is_game_server() of
        true ->
            ets:info(?ETS_OBJ_PLAYER, size);
        false ->
            0
    end.

%% ----------------------------------
%% @doc 	获取该渠道在线人数
%% @throws 	none
%% @end
%% ----------------------------------
get_online_count_by_channel(Channel) when is_list(Channel) ->
    lists:foldl(
        fun(PlayerId, Num) ->
            PlayerChannel = mod_player:get_player_channel(PlayerId),
            if PlayerChannel == Channel ->
                Num + 1;
                true ->
                    Num
            end
        end,
        0,
        get_all_online_player_id()
    ).

%% ----------------------------------
%% @doc 	获取正常玩家数量
%% @throws 	none
%% @end
%% ----------------------------------
get_common_online_player_count() ->
    L = get_all_online_player_id(),
    lists:foldl(
        fun(PlayerId, N) ->
            case mod_player:is_common_account(PlayerId) of
                true ->
                    N + 1;
                _ ->
                    N
            end
        end,
        0,
        L
    ).

%% ----------------------------------
%% @doc 	获取机器人在线数量
%% @throws 	none
%% @end
%% ----------------------------------
get_robot_online_count() ->
    L = get_all_online_player_id(),
    lists:foldl(
        fun(PlayerId, N) ->
            case mod_player:is_common_account(PlayerId) of
                true ->
                    N + 1;
                _ ->
                    N
            end
        end,
        0,
        L
    ).


%% ----------------------------------
%% @doc 	是否在线
%% @throws 	none
%% @end
%% ----------------------------------
is_online(PlayerId) ->
    case mod_obj_player:get_obj_player(PlayerId) of
        null ->
            false;
        R ->
            case erlang:is_process_alive(R#ets_obj_player.client_worker) of
                false ->
                    mod_obj_player:delete_obj_player(PlayerId),
                    false;
                _ ->
                    true
            end
    end.

%% ----------------------------------
%% @doc 	杀死在线玩家
%% @throws 	none
%% @end
%% ----------------------------------
kill_online_player(PlayerId) ->
    case mod_obj_player:get_obj_player(PlayerId) of
        null ->
            not_online;
        R ->
            case client_worker:kill_sync(R#ets_obj_player.client_worker, 6000, ?CSR_GM_KILL) of
                ok ->
                    noop;
                timeout ->
                    ?INFO("Kill online player time out:~p~n", [PlayerId]),
                    exit(R#ets_obj_player.client_worker, kill)
            end,
            ok
    end.

%%%% ----------------------------------
%%%% @doc 	杀死所有机器人
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%kill_all_robot() ->
%%    L = get_all_online_player_id(),
%%    lists:foreach(
%%        fun(PlayerId) ->
%%            case mod_player:is_robot_account(PlayerId) of
%%                true ->
%%                    kill_online_player(PlayerId);
%%                _ ->
%%                    noop
%%            end
%%        end,
%%        L
%%    ).

%% ----------------------------------
%% @doc 获取所有在线玩家id
%% @throws 	none
%% @end
%% ----------------------------------
get_all_online_player_id() ->
    ets:select(?ETS_OBJ_PLAYER, [{#ets_obj_player{id = '$1', _ = '_'}, [], ['$1']}]).

%% ----------------------------------
%% @doc 	获取所有功能开启的在线玩家列表
%% @throws 	none
%% @end
%% ----------------------------------
get_all_online_player_id_by_function(FunctionId) ->
    FilterFun = fun(PlayerId) ->
        mod_function:is_open(PlayerId, FunctionId)
                end,
    get_all_online_player_id_by_filter(FilterFun).

%% ----------------------------------
%% @doc 	通过过滤函数获取在线玩家列表
%% @throws 	none
%% @end
%% ----------------------------------
get_all_online_player_id_by_filter(FilterFun) ->
    [PlayerId || PlayerId <- get_all_online_player_id(), FilterFun(PlayerId)].

%%%% ----------------------------------
%%%% @doc 获取所有在线非新手玩家
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_all_online_not_new_player_id() ->
%%    FilterFun = fun(PlayerId) ->
%%        mod_player:is_new_level_player(PlayerId) == false
%%                end,
%%    get_all_online_player_id_by_filter(FilterFun).

%%%% ----------------------------------
%%%% @doc 获取所有在线非机器人玩家id
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_all_online_not_robot_player_id() ->
%%    FilterFun = fun(PlayerId) ->
%%        mod_player:is_robot_account(PlayerId) == false
%%                end,
%%    get_all_online_player_id_by_filter(FilterFun).

%% ----------------------------------
%% @doc 获取所有在线玩家进程
%% @throws 	none
%% @end
%% ----------------------------------
get_all_online_player_worker() ->
    ets:select(?ETS_OBJ_PLAYER, [{#ets_obj_player{client_worker = '$1', _ = '_'}, [], ['$1']}]).

%% ----------------------------------
%% @doc 	发送消息到所有在线玩家进程
%% @throws 	none
%% @end
%% ----------------------------------
send_msg_to_all_online_player_worker(Msg) ->
    lists:foreach(
        fun(ClientWorker) ->
            client_worker:send_msg(ClientWorker, Msg)
        end,
        get_all_online_player_worker()
    ).

%% ----------------------------------
%% @doc 	等待所有玩家进程关闭
%% @throws 	none
%% @end
%% ----------------------------------
wait_all_online_player_exit(TimeOut) ->
    client_worker_sup:kill_all_client_worker(?CSR_SYSTEM_MAINTENANCE),
    do_wait_all_online_player_exit(TimeOut, 0).

do_wait_all_online_player_exit(TimeOut, TimeOut) ->
    PidS = supervisor:which_children(client_worker_sup),
    lists:foldl(fun({_, Pid, _, _}, _) -> exit(Pid, kill) end, 0, PidS),
    ?ERROR("Forbidden kill ~p client worker!!!", [client_worker_sup:count_child()]),
    timer:sleep(1000),
    ok;
do_wait_all_online_player_exit(TimeOut, Time) ->
    ?INFO("Wait ~p client worker exit ......", [client_worker_sup:count_child()]),
    receive
    after 1000 ->
        case client_worker_sup:count_child() of
            0 -> ?INFO("All client worker exit."), ok;
            _N -> do_wait_all_online_player_exit(TimeOut, Time + 1)
        end
    end.
