%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            构建地图数据
%%% @end
%%% Created : 01. 六月 2016 下午 4:30
%%%-------------------------------------------------------------------
-module(build_map).
-export([start/0, get_map_mark_name/1, get_zone_list/1]).
%% API
-include("common.hrl").
-include("scene.hrl").
%%-include("gen/table_enum.hrl").
%%-include("gen/table_db.hrl").
-define(PATH, "../src/gen/map_data.erl").
start() ->
    env:init(),
    {_, S, _} = os:timestamp(),
    put(start_second, S),
    qmake:compilep("../src/gen/logic_get_all_map_id", ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
    MapIds = logic_get_all_map_id:get(0),
    util_file:ensure_dir(?PATH),
    {ok, FileFp} = file:open(?PATH, [write]),
    file:write(FileFp, file_head()),
    Head =
        "-module(map_data).\n"
        "-export([get/1, get_map_mark_table_name/1]).\n\n",
    file:write(FileFp, Head),
    N = length(MapIds),
    lists:foreach(
        fun(MapId) ->
            File = map_id_2_filename(MapId),
            io:format("Decode json: ~p ~s", [File, lists:duplicate(max(0, 45 - length(File)), ".")]),
            case filelib:is_file(File) of
                true ->
                    decode(MapId, File, FileFp),
                    io:format(" [ok]\n\n");
                false ->
                    io:format("\n[ERROR]: map json no exists: " ++ File ++ "\n\n"),
                    halt(1)
            end
        end,
        MapIds
    ),
    Out =
        "get(Id) ->\n"
        "     logger:debug(\"map_data =>data not find:~p~n\", [Id]),\n"
        "     null.\n\n",
    file:write(FileFp, Out),
    build_mark_table_name(FileFp, MapIds),
    io:format("Waiting ~p Maps finished......~n~n", [N]),
    wait(N),
    qmake:compilep(?PATH, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),
%%    check_scene_config_pos(),
    {_, S1, _} = os:timestamp(),
    S2 = S1 - S,
    io:format(
        "~n~n"
        "*************************************************************~n~n"
        "                       All finished                          ~n"
        "                  Used ~p minute, ~p second         ~n~n"
        "*************************************************************~n~n",
        [S2 div 60, S2 rem 60]
    ).

wait(0) ->
    ok;
wait(N) ->
    receive
        {finish, MapId} ->
            io:format("[~p] Encode Map ~p finish!~n~n", [N - 1, MapId]),
            wait(N - 1);
        {error, MapId} ->
            io:format("[ERROR]:~p~n", [MapId]),
            halt(1);
        Other ->
            io:format("Other:~p~n", [Other]),
            halt(1)
    end.
map_id_2_filename(Id) ->
    MapDataDir = env:get(map_data_dir),
    filename:join([MapDataDir, util:to_list(Id), "map_data.json"]).

build_mark_table_name(FileFp, MapIds) ->
    lists:foreach(
        fun(MapId) ->
            Out1 =
                "get_map_mark_table_name(" ++ integer_to_list(MapId) ++ ") ->\n"
            "     map_mark_" ++ integer_to_list(MapId) ++ ";\n",
            file:write(FileFp, Out1)
        end,
        MapIds
    ),
    Out =
        "get_map_mark_table_name(MapId) ->\n"
        "     logger:debug(\"map_data =>get_map_mark_table_name not find:~p~n\", [MapId]),\n"
        "     null.",
    file:write(FileFp, Out).

decode(MapId, File, FileFp) ->
    {ok, Data} = file:read_file(File),
    Maps = jsone:decode(Data),
    {ok, MapHeight} = maps:find(<<"mapHeight">>, Maps),
    {ok, MapWidth} = maps:find(<<"mapWidth">>, Maps),
    {ok, GridCol} = maps:find(<<"gridCol">>, Maps),
    {ok, GridRow} = maps:find(<<"gridRow">>, Maps),
    {ok, RoadArray} = maps:find(<<"dataArray">>, Maps),
    JumpCrossArray =
        case maps:find(<<"jumpCrossArray">>, Maps) of
            error ->
                [];
            {ok, _JumpCrossArray_} ->
                _JumpCrossArray_
        end,
    JumpAreaArray =
        case maps:find(<<"jumpAreaArray">>, Maps) of
            error ->
                [];
            {ok, _JumpAreaArray_} ->
                _JumpAreaArray_
        end,
    PathNodeArray = [],
%%        case maps:find(<<"pathNodeArray">>, Maps) of
%%            error ->
%%                [];
%%            {ok, _PathNodeArray_} ->
%%                _PathNodeArray_
%%        end,
    save_map_data(MapId, JumpCrossArray, JumpAreaArray, PathNodeArray, MapHeight, MapWidth, FileFp),
    Self = self(),
    erlang:spawn(fun() -> save_road_array(Self, MapId, GridCol, GridRow, RoadArray) end).

save_map_data(MapId, JumpCrossArray, JumpAreaArray, _PathNodeArray, MapHeight, MapWidth, FileFp) ->
    JumpList0 = lists:foldl(
        fun(Map, Tmp) ->
            {ok, X1} = maps:find(<<"x1">>, Map),
            {ok, Y1} = maps:find(<<"y1">>, Map),
            {ok, X2} = maps:find(<<"x2">>, Map),
            {ok, Y2} = maps:find(<<"y2">>, Map),
            [{X1, Y1, X2, Y2} | Tmp]
        end,
        [],
        JumpCrossArray
    ),
    JumpList1 = lists:foldl(
        fun(Map, Tmp) ->
            {ok, JumpArea} = maps:find(<<"jumpArea">>, Map),
            {ok, TarPoint} = maps:find(<<"tarPoint">>, Map),
            {ok, TargetX} = maps:find(<<"x">>, TarPoint),
            {ok, TargetY} = maps:find(<<"y">>, TarPoint),

            lists:foldl(
                fun(B, Tmp1) ->
                    S = binary_to_list(B),
                    [SX, SY] = string:tokens(S, "_"),
                    {FX, FY} = {list_to_integer(SX), list_to_integer(SY)},
                    [{FX, FY, TargetX, TargetY} | Tmp1]
                end,
                [],
                JumpArea
            ) ++ Tmp
        end,
        [],
        JumpAreaArray
    ),
    JumpList = JumpList0 ++ JumpList1,
%%    PathNodeList = lists:foldl(
%%        fun(MapList, Tmp) ->
%%            lists:foldl(
%%                fun(Map, Tmp1) ->
%%                    {ok, X1} = maps:find(<<"x1">>, Map),
%%                    {ok, Y1} = maps:find(<<"y1">>, Map),
%%                    {ok, X2} = maps:find(<<"x2">>, Map),
%%                    {ok, Y2} = maps:find(<<"y2">>, Map),
%%                    IsA = lists:member({X1, Y1, X2, Y2}, JumpList),
%%                    IsB = lists:member({X2, Y2, X1, Y1}, JumpList),
%%                    if IsA == true andalso IsB == true ->
%%                        [{X1, Y1, X2, Y2}, {X2, Y2, X1, Y1} | Tmp1];
%%                        IsA == true andalso IsB == false ->
%%                            [{X1, Y1, X2, Y2} | Tmp1];
%%                        IsA == false andalso IsB == true ->
%%                            [{X2, Y2, X1, Y1} | Tmp1];
%%                        true ->
%%                            [{X1, Y1, X2, Y2}, {X2, Y2, X1, Y1} | Tmp1]
%%                    end
%%                end,
%%                [],
%%                MapList
%%            ) ++ Tmp
%%        end,
%%        [],
%%        PathNodeArray
%%    ),
%%    io:format("~nJumpList1:~p~n~n", [JumpList1]),
    RMap = #r_map_data{
        map_id = MapId,
        width = MapWidth,
        height = MapHeight,
        jump_list = JumpList
%%        path_node_list = PathNodeList
    },
    Out = io_lib:format(
        "get(~p) ->\n"
        "    ~p;\n",
        [MapId, RMap]
    ),
    file:write(FileFp, Out).

get_map_mark_name(MapId) ->
    ?MAP_DATA_DIR ++ "map_mark_" ++ util:to_list(MapId) ++ ".data".

save_road_array(Pid, MapId, GridCol, GridRow, RoadArray) ->
    try
        DetsName = get_map_mark_name(MapId),
        file:delete(DetsName),
        Tid = ets:new(ets_map_mark, [set, public, {keypos, #map.id}]),
        dets:open_file(DetsName, [{type, set}, {keypos, #map.id}]),
        TupleRoadArray = list_to_tuple(RoadArray),
%%        TileList =
            lists:foldl(
                fun(Y, Tmp) ->
                    lists:foldl(
                        fun(X, Tmp_1) ->
                            Key = {X, Y},
                            Obstacle = get_element(X, Y, GridCol, TupleRoadArray),
                            %% 2018 8 13 优化：不可行走区 不生成， 优化内存
%%                            ets:insert(Tid, #map{
%%                                id = Key,
%%                                obstacle = Obstacle
%%                            }),
                            if Obstacle == ?TILE_TYPE_WALK ->
                                ets:insert(Tid, #map{
                                    id = Key,
                                    obstacle = Obstacle
                                }),
                                [{X, Y} | Tmp_1];
                                true ->
                                    Tmp_1
                            end
                        end,
                        Tmp,
                        lists:seq(0, GridCol - 1)
                    )
                end,
                [],
                lists:seq(0, GridRow - 1)
            ),
%%        lists:foreach(
%%            fun({ZoneId, ZoneTileList}) ->
%%                lists:foreach(
%%                    fun(Tile) ->
%%                        [E] = ets:lookup(Tid, Tile),
%%                        ets:insert(Tid, E#map{
%%                            zone = ZoneId
%%                        })
%%
%%                    end,
%%                    ZoneTileList
%%                )
%%            end,
%%            get_zone_list(TileList)
%%        ),
%%        io:format("TileList:~p~n", [TileList]),
        ets:to_dets(Tid, DetsName),
        dets:close(DetsName),
%%        io:format("[SUCCESS]:~p~n", [{MapId, GridCol, GridRow, length(RoadArray)}]),
        Pid ! {finish, MapId}
    catch
        _:Reason ->
            io:format("[ERROR]:~p~n", [{MapId, GridCol, GridRow, length(RoadArray), Reason, erlang:get_stacktrace()}]),
            Pid ! {error, MapId}
    end.

get_zone_list(TileList) ->
    get_zone_list([], null, TileList, 1).

%%t([{{GX, GY}, ?FALSE} = A | L], Other) ->
%%    t(L, [A | Other]);
get_zone_list(Back, null, [], _N) ->
    Back;
get_zone_list(Back, null, [H | L], _N) ->
    get_zone_list(Back, H, L, _N);
get_zone_list(Back, {GX, GY}, Left, N) ->
    {L, NewLeft} = get_zone_list_2({GX, GY}, [{GX, GY}], Left),
%%    ?DEBUG("args:~p~n", [{{GX, GY}, Left}]),
%%    ?DEBUG("resulr:~p~n", [{L, NewLeft}]),
    get_zone_list([{N, L} | Back], null, NewLeft, N + 1).

get_zone_list_2({GX, GY}, OpenList, CloseList) ->
    List = [{GX - 1, GY - 1}, {GX, GY - 1}, {GX + 1, GY - 1},
        {GX - 1, GY}, {GX + 1, GY},
        {GX - 1, GY + 1}, {GX, GY + 1}, {GX + 1, GY + 1}],
    lists:foldl(
        fun(E, {TmpOpenList, TmpCloseList}) ->
            case lists:member(E, TmpCloseList) of
                true ->
                    get_zone_list_2(E, [E | TmpOpenList], lists:delete(E, TmpCloseList));
                false ->
                    {TmpOpenList, TmpCloseList}
            end
        end,
        {OpenList, CloseList},
        List
    ).



get_element(X, Y, GridCol, TupleRoadArray) ->
    erlang:element(X + 1 + GridCol * Y, TupleRoadArray).
%%    lists:nth(X + 1 + GridCol * Y, List).

file_head() -> "%%% Generated automatically, no need to modify.\n".

%% @doc 检查场景配置位置是否有错误
%%check_scene_config_pos() ->
%%    if
%%        ?IS_DEBUG ->
%%            io:format("Check scene_config_pos ......................................... "),
%%%%            List = ets:tab2list(t_scene),
%%            mod_map:init_all(),
%%            lists:foreach(
%%                fun({SceneId}) ->
%%                    #t_scene{
%%                        boss_x_y_list = BossXYList,
%%                        monster_x_y_list = MonsterXYList,
%%                        random_birth_list = RandomBirthList,
%%                        gold_monster_move_list = GoldMonsterMoveList,
%%                        new_monster_x_y_list = NewMonsterXYList,
%%
%%                        monster_count = MonsterCount,
%%                        boss_time_monster_born_list = BossTimeMonsterBornList,
%%                        boss_time_monster_count = BossTimeMonsterCount,
%%                        map_id = MapId,
%%                        is_hook = IsHook,
%%                        type = SceneType,
%%                        is_valid = IsValid
%%                    } = t_scene:assert_get({SceneId}),
%%                    if
%%                        IsHook == ?TRUE andalso IsValid == ?TRUE andalso SceneType == ?SCENE_TYPE_WORLD_SCENE ->
%%                            lists:foreach(
%%                                fun(BossXYList1) ->
%%                                    lists:foreach(
%%                                        fun([BossX, BossY]) ->
%%                                            case mod_map:can_walk_pix(MapId, BossX, BossY) of
%%                                                true ->
%%                                                    noop;
%%                                                false ->
%%                                                    io:format("[SCENE_ERROR] boss_x_y_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, BossX, BossY]),
%%                                                    halt(1)
%%                                            end
%%                                        end,
%%                                        BossXYList1
%%                                    )
%%                                end,
%%                                BossXYList
%%                            ),
%%                            lists:foreach(
%%                                fun([MonsterX, MonsterY]) ->
%%                                    case mod_map:can_walk_pix(MapId, MonsterX, MonsterY) of
%%                                        true ->
%%                                            noop;
%%                                        false ->
%%                                            io:format("[SCENE_ERROR] monster_x_y_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, MonsterX, MonsterY]),
%%                                            halt(1)
%%                                    end
%%                                end, MonsterXYList
%%                            ),
%%                            lists:foreach(
%%                                fun({MonsterX, MonsterY}) ->
%%                                    case mod_map:can_walk_pix(MapId, MonsterX, MonsterY) of
%%                                        true ->
%%                                            noop;
%%                                        false ->
%%                                            io:format("[SCENE_ERROR] random_birth_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, MonsterX, MonsterY]),
%%                                            halt(1)
%%                                    end
%%                                end, RandomBirthList
%%                            ),
%%                            lists:foreach(
%%                                fun(GoldMonsterMoveList1) ->
%%                                    lists:foreach(
%%                                        fun([BossX, BossY]) ->
%%                                            case mod_map:can_walk_pix(MapId, BossX, BossY) of
%%                                                true ->
%%                                                    noop;
%%                                                false ->
%%                                                    io:format("[SCENE_ERROR] gold_monster_move_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, BossX, BossY]),
%%                                                    halt(1)
%%                                            end
%%                                        end,
%%                                        GoldMonsterMoveList1
%%                                    )
%%                                end,
%%                                GoldMonsterMoveList
%%                            ),
%%                            {MonsterCountMin, MonsterCountMax} =
%%                                lists:foldl(
%%                                    fun([_, Min, Max, GoldMonsterMoveList1], {TmpMin, TmpMax}) ->
%%                                        lists:foreach(
%%
%%                                            fun([X, Y]) ->
%%                                                case mod_map:can_walk_pix(MapId, X, Y) of
%%                                                    true ->
%%                                                        noop;
%%                                                    false ->
%%
%%                                                        io:format("[SCENE_ERROR] new_monster_x_y_list error,scene_id:~p, x: ~p, y: ~p ~n", [SceneId, X, Y]),
%%                                                        halt(1)
%%                                                end
%%                                            end,
%%                                            GoldMonsterMoveList1
%%
%%                                        ),
%%                                        {TmpMin + Min, TmpMax + Max}
%%                                    end,
%%
%%                                    {0, 0}, NewMonsterXYList
%%                                ),
%%                            if
%%                                MonsterCount < MonsterCountMin ->
%%                                    io:format("[SCENE_ERROR] monster_count < new_monster_x_y_list min_total_num,scene_id:~p, monster_count: ~p, monster_count_min: ~p ~n", [SceneId, MonsterCount, MonsterCountMin]),
%%                                    halt(1);
%%                                MonsterCount > MonsterCountMax ->
%%                                    io:format("[SCENE_ERROR] monster_count > new_monster_x_y_list max_total_num,scene_id:~p, monster_count: ~p, monster_count_max: ~p ~n", [SceneId, MonsterCount, MonsterCountMax]),
%%                                    halt(1);
%%                                true ->
%%                                    noop
%%                            end,
%%                            {BossTimeMonsterCountMin, BossTimeMonsterCountMax} =
%%                                lists:foldl(
%%                                    fun([_, _, Min, Max], {TmpMin, TmpMax}) ->
%%                                        {TmpMin + Min, TmpMax + Max}
%%                                    end,
%%                                    {0, 0}, BossTimeMonsterBornList
%%                                ),
%%                            if
%%                                BossTimeMonsterCount < BossTimeMonsterCountMin ->
%%                                    io:format("[SCENE_ERROR] boss_time_monster_count < boss_time_monster_born_list min_total_num,scene_id:~p, boss_time_monster_count: ~p, boss_time_monster_count_min: ~p ~n", [SceneId, BossTimeMonsterCount, BossTimeMonsterCountMin]),
%%                                    halt(1);
%%                                BossTimeMonsterCount > BossTimeMonsterCountMax ->
%%                                    io:format("[SCENE_ERROR] boss_time_monster_count > boss_time_monster_born_list max_total_num,scene_id:~p, boss_time_monster_count: ~p, boss_time_monster_count_max: ~p ~n", [SceneId, BossTimeMonsterCount, BossTimeMonsterCountMax]),
%%                                    halt(1);
%%                                true ->
%%                                    noop
%%                            end;
%%                        true ->
%%                            noop
%%                    end
%%                end, t_scene:get_keys()),
%%            io:format("[ok]~n");
%%        true ->
%%            noop
%%    end.