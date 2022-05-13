%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家对象接口
%%% @end
%%% Created : 04. 十一月 2016 上午 11:06
%%%-------------------------------------------------------------------
-module(mod_obj_player).
-include("gen/db.hrl").
-include("common.hrl").
-include("client.hrl").

%% API
-export([
    delete_obj_player/1,                        %% 删除玩家对象
    get_obj_player/1,                           %% 获取玩家对象
    update_obj_player/1,                        %% 更新玩家对象
    init_obj_player/4,                          %% 初始化玩家对象
    get_all_obj_player/0,                       %% 获取所有玩家对象
    get_obj_player_scene_worker/1,              %% 获取玩家对象所在场景进程
    get_obj_player_scene_id/1,                  %% 获取玩家场景id
    get_obj_player_client_worker/1              %% 获取玩家对象进程
%%    get_all_online_player_id_by_scene_worker/1
]).
%% ----------------------------------
%% @doc 	初始化玩家对象
%% @throws 	none
%% @end
%% ----------------------------------
init_obj_player(PlayerId, ClientWorker, SendWorker, Ip) ->
    case get_obj_player(PlayerId) of
        null ->
            noop;
        R ->
            case erlang:is_process_alive(R#ets_obj_player.client_worker) of
                true ->
                    ?WARNING("顶掉玩家进程:~p", [{PlayerId, self(), R#ets_obj_player.client_worker}]),
                    case client_worker:kill_sync(R#ets_obj_player.client_worker, 6000, ?CSR_LOGIN_IN_OTHER) of
                        ok ->
                            noop;
                        timeout ->
                            ?WARNING("杀死玩家进程！！！！！！！！！！！！:~p", [R]),
                            erlang:exit(R#ets_obj_player.client_worker, kill),
                            delete_obj_player(PlayerId)
                    end;
                false ->
                    delete_obj_player(PlayerId)
            end
    end,
    ObjPlayer = #ets_obj_player{
        id = PlayerId,
        client_node = node(),
        client_worker = ClientWorker,
        sender_worker = SendWorker,
        ip = Ip
    },
    true = ets:insert_new(?ETS_OBJ_PLAYER, ObjPlayer),
    ok.

%% ----------------------------------
%% @doc 	更新玩家对象 (只能玩家进程调用)
%% @throws 	none
%% @end-
%% ----------------------------------
update_obj_player(ObjPlayer) when is_record(ObjPlayer, ets_obj_player) ->
    put(?DICT_PLAYER_SCENE_WORKER, ObjPlayer#ets_obj_player.scene_worker),
    put(?DICT_PLAYER_SCENE_ID, ObjPlayer#ets_obj_player.scene_id),
    true = ets:insert(?ETS_OBJ_PLAYER, ObjPlayer),
    ok.


%% ----------------------------------
%% @doc 	删除玩家对象
%% @throws 	none
%% @end
%% ----------------------------------
delete_obj_player(PlayerId) ->
    ets:delete(?ETS_OBJ_PLAYER, PlayerId), ok.

%% ----------------------------------
%% @doc 	获取玩家对象
%% @throws 	none
%% @end
%% ----------------------------------
get_obj_player(PlayerId) ->
    case ets:lookup(?ETS_OBJ_PLAYER, PlayerId) of
        [] ->
            null;
        [R] ->
            R
    end.

%% ----------------------------------
%% @doc 	获取玩家对象所在场景进程
%% @throws 	none
%% @end
%% ----------------------------------
get_obj_player_scene_worker(PlayerId) ->
    case ets:lookup(?ETS_OBJ_PLAYER, PlayerId) of
        [] ->
            null;
        [R] ->
            R#ets_obj_player.scene_worker
    end.

%% ----------------------------------
%% @doc 	获取玩家对象所在场景id
%% @throws 	none
%% @end
%% ----------------------------------
get_obj_player_scene_id(PlayerId) ->
    case ets:lookup(?ETS_OBJ_PLAYER, PlayerId) of
        [] ->
            0;
        [R] ->
            R#ets_obj_player.scene_id
    end.

%%%% ----------------------------------
%%%% @doc 	获取同场景玩家id列表
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_all_online_player_id_by_scene_worker(SceneWorker) ->
%%    ets:select(obj_player, [{#ets_obj_player{id = '$0', scene_worker = SceneWorker, _ = '_'}, [], ['$0']}]).

%%%% ----------------------------------
%%%% @doc 	获取玩家对象进程
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
get_obj_player_client_worker(PlayerId) ->
    case ets:lookup(?ETS_OBJ_PLAYER, PlayerId) of
        [] ->
            null;
        [R] ->
            R#ets_obj_player.client_worker
    end.

%% ----------------------------------
%% @doc 	获取所有玩家对象
%% @throws 	none
%% @end
%% ----------------------------------
get_all_obj_player() ->
    ets:tab2list(?ETS_OBJ_PLAYER).

