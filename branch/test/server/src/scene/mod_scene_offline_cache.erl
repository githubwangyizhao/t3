%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            场景离线缓存
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_scene_offline_cache).
-include("scene.hrl").
-include("client.hrl").
-include("common.hrl").
-include("gen/table_enum.hrl").
%%-include("ets.hrl").
-include("msg.hrl").
-include("gen/db.hrl").
%% API
-export([
    update_offline_player_scene_cache/5,
    get_offline_player_scene_cache/1
]).

%% 更新离线场景缓存
update_offline_player_scene_cache(PlayerId, SceneId, SceneWorker, X, Y) ->
%%    noop.
    case get(?DICT_IS_LEAVE_GAME) of
        true ->
            case mod_scene:is_offline_reconnect_scene(PlayerId, SceneId, SceneWorker) of
                true ->
                    ?DEBUG("更新离线场景缓存:~p", [{PlayerId, SceneId, SceneWorker, X, Y}]),
                    ets:insert(?ETS_OFFLINE_PLAYER_SCENE_CACHE,
                        #ets_offline_player_scene_cache{
                            player_id = PlayerId,
                            scene_id = SceneId,
                            x = X,
                            y = Y,
                            scene_worker = SceneWorker,
                            timestamp = util_time:timestamp()
                        });
                false ->
                    erase_offline_player_scene_cache(PlayerId)
            end;
        _ ->
            noop
    end.

erase_offline_player_scene_cache(PlayerId) ->
    ets:delete(?ETS_OFFLINE_PLAYER_SCENE_CACHE, PlayerId).

get_offline_player_scene_cache(PlayerId) ->
    DbPlayerClientData =
        case db:read(#key_player_client_data{player_id = PlayerId, id = "k_guide_over"}) of
            null ->
                #db_player_client_data{
                    player_id = PlayerId,
                    id = "k_guide_over"
                };
            DbPlayerClientData1 ->
                DbPlayerClientData1
        end,
    #db_player_client_data{
        value = Value
    } = DbPlayerClientData,
    if
        Value == "" ->
            init;
        Value == "1" ->
            case ets:lookup(?ETS_OFFLINE_PLAYER_SCENE_CACHE, PlayerId) of
                [] ->
                    main_scene;
                [R] ->
                    #ets_offline_player_scene_cache{
                        scene_id = SceneId,
                        scene_worker = SceneWorker
                    } = R,
                    %% 删除ets缓存数据
                    erase_offline_player_scene_cache(PlayerId),
                    case mod_scene:is_offline_reconnect_scene(PlayerId, SceneId, SceneWorker) of
                        true ->
                            R;
                        false ->   %% 放弃重连旧场景，进入主场景
                            main_scene
                    end
            end;
        true ->
            ?ERROR("ERROR VALUE : ~p",[Value]),
            main_scene
    end.
