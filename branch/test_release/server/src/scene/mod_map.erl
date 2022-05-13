%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            地图模块
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_map).

-include("common.hrl").
-include("scene.hrl").
-include("error.hrl").

%% API
-export([
    can_walk_pix/3,                        %% 像素点是否可行走
    can_walk/1,                            %% 是否可以行走
    can_walk_pix_origin/3,                 %% 是否可以行走(不包括跳跃点)
%%    can_walk_dirty/1,
    ensure_can_walk/1,                     %% 确保可以行走
    is_jump_pos/1,                         %% 是否跳跃点
%%    is_fly/1,                            %% 是否飞行区
%%    is_same_zone/3,                      %% 两点是否在同一区域
    get_all_map_id/0                       %% 获取所有地图id
]).

-export([
    init_all/0,                                 %% 地图数据预加载
    init_common/0,
    init_zone/0,
    init_war/0,
    init_map/1,
    reload_map_data/1,
    load/1,                                %% 加载地图数据
    unload/0                               %% 移除地图数据
]).
-export([
    load_jump_data/1,
    unload_jump_data/0
]).
%% 动态阻挡格接口
-export([
    set_dynamic_obstacle/1,                %% 设置动态可行走区
    unset_dynamic_obstacle/1               %% 清除动态可行走区
]).

%%%% ----------------------------------
%%%% @doc 	两点是否在同一区域
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%is_same_zone(MapId, {PixX, PixY}, {PixX2, PixY2}) ->
%%    {X, Y} = ?PIX_2_TILE(PixX, PixY),
%%    {X2, Y2} = ?PIX_2_TILE(PixX2, PixY2),
%%    Table = case get(map_mark_table) of
%%                ?UNDEFINED ->
%%                    ?MAP_MART_TABLE(MapId);
%%                Table_ ->
%%                    Table_
%%            end,
%%    case ets:lookup(Table, {X, Y}) of
%%        [] ->
%%%%            ?DEBUG("1111:~p", [{MapId, {PixX, PixY}, {PixX2, PixY2}, Table, {X, Y}}]),
%%            false;
%%        [R] ->
%%            case ets:lookup(Table, {X2, Y2}) of
%%                [] ->
%%%%                    ?DEBUG("2222"),
%%                    false;
%%                [R2] ->
%%                    R#map.zone == R2#map.zone
%%            end
%%    end.

%% ----------------------------------
%% @doc 	是否可以行走
%% @throws 	none
%% @end
%% ----------------------------------
can_walk_pix(MapId, PixX, PixY) ->
    can_walk(?PIX_2_MASK_ID(MapId, PixX, PixY)).

can_walk({MapId, {X, Y}}) ->
    Table = case get(map_mark_table) of
                ?UNDEFINED ->
                    ?MAP_MART_TABLE(MapId);
                Table_ ->
                    Table_
            end,
    Re = case ets:lookup(Table, {X, Y}) of
             [] ->
                 false;
             [R] ->
                 if
                     R#map.obstacle =/= ?TILE_TYPE_NO_WALK ->     %% 阻挡格
                         true;
%%                         get({obstacle, X, Y}) =/= 1;    %% 动态阻挡格 注：当前版本没有动态阻挡格， 暂时优化掉
                     true ->
                         false
                 end
         end orelse get({jump_p, {X, Y}}) == true,
    Re.

%% ----------------------------------
%% @doc 	是否可以行走(不包括跳跃点)
%% @throws 	none
%% @end
%% ----------------------------------
can_walk_pix_origin(MapId, PixX, PixY) ->
    {MapId, {X, Y}} = ?PIX_2_MASK_ID(MapId, PixX, PixY),
    Table = case get(map_mark_table) of
                ?UNDEFINED ->
                    ?MAP_MART_TABLE(MapId);
                Table_ ->
                    Table_
            end,
    case ets:lookup(Table, {X, Y}) of
        [] ->
            false;
        [R] ->
            R#map.obstacle =/= ?TILE_TYPE_NO_WALK
    end.

ensure_can_walk(MaskId) ->
    ?ASSERT(mod_map:can_walk(MaskId), {?ERROR_NOT_CAN_WALK, MaskId}).

%% 是否飞行区域
%%is_fly({MapId, {X, Y}}) ->
%%    Table = case get(map_mark_table) of
%%                ?UNDEFINED ->
%%                    ?MAP_MART_TABLE(MapId);
%%                Table_ ->
%%                    Table_
%%            end,
%%    case ets:lookup(Table, {X, Y}) of
%%        [] ->
%%            false;
%%        [R] ->
%%            R#map.obstacle == ?ROAD_TYPE_FLY
%%    end.

%%can_walk_dirty({MapId, {X, Y}}) ->
%%    case ets:lookup(?MAP_MART_TABLE(MapId), {X, Y}) of
%%        [] ->
%%            false;
%%        [R] ->
%%            if
%%                R#map.obstacle =/= ?ROAD_TYPE_NO_WALK ->     %% 阻挡格
%%                    get({obstacle, X, Y}) =/= 1;    %% 动态阻挡格
%%                true ->
%%                    false
%%            end
%%    end orelse get({jump_p, {X, Y}}) == true.

%% ----------------------------------
%% @doc 	地图数据初始化
%% @throws 	none
%% @end
%% ----------------------------------
init_all() ->
    MapIds = logic_get_all_map_id:get(0),
    init_map(MapIds).

init_common() ->
    MapIds = logic_get_all_common_map_id:get(0),
    init_map(MapIds).

init_zone() ->
    MapIds = logic_get_all_cross_map_id:get(0),
    init_map(MapIds).

init_war() ->
    MapIds = logic_get_all_war_map_id:get(0),
    init_map(MapIds).

init_map(MapIds) ->
    ets:new(?ETS_SCENE_WORKER_MAP, ?ETS_INIT_ARGS(#ets_scene_worker_map.scene_id)),
    lists:foreach(
        fun(MapId) ->
            EtsTableName = ?MAP_MART_TABLE(MapId),
            ets:new(EtsTableName, ?ETS_INIT_ARGS(#map.id, [{read_concurrency, true}])),
            DetsName = build_map:get_map_mark_name(MapId),
            dets:open_file(DetsName, [{type, set}, {keypos, #map.id}]),
            dets:to_ets(DetsName, EtsTableName),
            dets:close(DetsName)
        end,
        MapIds
    ).

reload_map_data(MapId) ->
    EtsTableName = ?MAP_MART_TABLE(MapId),
    DetsName = build_map:get_map_mark_name(MapId),
    dets:open_file(DetsName, [{type, set}, {keypos, #map.id}]),
    dets:to_ets(DetsName, EtsTableName),
    dets:close(DetsName).

%% ----------------------------------
%% @doc 	加载地图数据
%% @throws 	none
%% @end
%% ----------------------------------
load(MapId) ->
%%    load_walk_data(MapId),
    put(map_mark_table, ?MAP_MART_TABLE(MapId)),
    load_jump_data(MapId),
    load_path_data(MapId).

%% ----------------------------------
%% @doc 	移除地图数据
%% @throws 	none
%% @end
%% ----------------------------------
unload() ->
%%    unload_walk_data(),
    put(map_mark_table, null),
    unload_jump_data(),
    unload_path_data().

%% ----------------------------------
%% @doc 	加载跳跃点数据
%% @throws 	none
%% @end
%% ----------------------------------
load_jump_data(MapId) ->
    MapData = map_data:get(MapId),
    JumpList = MapData#r_map_data.jump_list,
    lists:foreach(
        fun({X1, Y1, X2, Y2}) ->
            put({jump_p, {X1, Y1}}, true),
            put({jump_p, {X2, Y2}}, true),
            put({jump_p, {X1, Y1}, {X2, Y2}}, true),
            case get({jump, {X1, Y1}}) of
                undefined ->
                    put({jump, {X1, Y1}}, [{X2, Y2}]);
                L ->
                    case lists:member({X2, Y2}, L) of
                        true ->
                            noop;
                        false ->
                            put({jump, {X1, Y1}}, [{X2, Y2} | L])
                    end

            end
        end,
        JumpList
    ).

%% ----------------------------------
%% @doc 	是否跳跃点
%% @throws 	none
%% @end
%% ----------------------------------
is_jump_pos({X, Y}) ->
    case get({jump_p, {X, Y}}) of
        undefined ->
            false;
        _ ->
            true
    end.

%% ----------------------------------
%% @doc 	移除跳跃点数据
%% @throws 	none
%% @end
%% ----------------------------------
unload_jump_data() ->
    KeyS = erlang:get_keys(),
    lists:foreach(
        fun(Key) ->
            case Key of
                {jump, _} ->
                    erlang:erase(Key);
                {jump_p, _} ->
                    erlang:erase(Key);
                {jump_p, _, _} ->
                    erlang:erase(Key);
                _ ->
                    noop
            end
        end,
        KeyS
    ).

%% ----------------------------------
%% @doc 	加载路径点数据
%% @throws 	none
%% @end
%% ----------------------------------
load_path_data(MapId) ->
%%    MapData = map_data:get(MapId),
%%    PathNodeList = MapData#r_map_data.path_node_list,
    PathNodeList = get_map_node_path(MapId),
%%        case lists:keyfind(MapId, 1, ?SCENE_PATH) of
%%            false ->
%%                [];
%%            {MapId, PathNodeList_} ->
%%                PathNodeList_
%%        end,
    lists:foreach(
        fun({X1, Y1, X2, Y2}) ->
%%            ?ASSERT(navigate:check_line(MapId, {X1, Y1}, {X2, Y2}) == true, {{X1, Y1}, {X2, Y2}}),
            case get({path, {X1, Y1}}) of
                undefined ->
                    put({path, {X1, Y1}}, [{X2, Y2}]);
                L ->
                    case lists:member({X2, Y2}, L) of
                        true ->
                            noop;
                        false ->
%%                            ?DEBUG("load_path_data:~p~n", [{{path, {X1, Y1}}, [{X2, Y2} | L]}]),
                            put({path, {X1, Y1}}, [{X2, Y2} | L])
                    end

            end
        end,
        PathNodeList
    ).

%% ----------------------------------
%% @doc 	移除路径点数据
%% @throws 	none
%% @end
%% ----------------------------------
unload_path_data() ->
    KeyS = erlang:get_keys(),
    lists:foreach(
        fun(Key) ->
            case Key of
                {path, _} ->
                    erlang:erase(Key);
                _ ->
                    noop
            end
        end,
        KeyS
    ).

%% ----------------------------------
%% @doc 	获取所有地图id
%% @throws 	none
%% @end
%% ----------------------------------
get_all_map_id() ->
    logic_get_all_map_id:get(0).

%% ----------------------------------
%% @doc 	设置动态阻挡格
%% @throws 	none
%% @end
%% ----------------------------------
set_dynamic_obstacle(TileList) ->
    ?DEBUG("设置动态阻挡格", []),
    lists:foreach(
        fun({X, Y}) ->
            put({obstacle, X, Y}, 1)
        end,
        TileList
    ).

%% ----------------------------------
%% @doc 	清除动态阻挡格
%% @throws 	none
%% @end
%% ----------------------------------
unset_dynamic_obstacle(TileList) ->
    ?DEBUG("移除动态阻挡格", []),
    lists:foreach(
        fun({X, Y}) ->
            erase({obstacle, X, Y})
        end,
        TileList
    ).


%% ----------------------------------
%% @doc 	获取地图路径点
%% @throws 	none
%% @end
%% ----------------------------------
get_map_node_path(MapId) ->
    case logic_get_map_node_path:get(MapId) of
        null ->
            [];
        L ->
            L
    end.
