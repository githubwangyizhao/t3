%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            构建场景数据
%%% @end
%%% Created : 01. 六月 2016 下午 4:30
%%%-------------------------------------------------------------------
-module(build_scene).

%% API
-export([start/0]).
%%-include("amf.hrl").
-include("common.hrl").
-include("scene.hrl").
-define(PATH, "../src/gen/scene_data.erl").
start() ->
    env:init(),
    {_, S, _} = os:timestamp(),
%%    put(start_second, S),
%%    qmake:compilep("../src/gen/logic_get_all_scene_id", ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),

    case filelib:is_file("../src/scene/mod_map.erl") of
        true ->
            qmake:compilep("../src/scene/mod_map.erl", ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH);
        false ->
            ignore
    end,
    SceneIds = logic_get_all_scene_id:get(0),
    util_file:ensure_dir(?PATH),
    {ok, FileFp} = file:open(?PATH, [write]),
    file:write(FileFp, file_head()),
    Head =
        "-module(scene_data).\n"
        "-export([\n"
        "   get_scene_monster_id_list/1,\n"
        "   get_scene_monster/1,\n"
        "   get_scene_gather_id_list/1,\n"
        "   get_scene_gather/1,\n"
        "   get_scene_npc_list/1,\n"
        "   get_scene_monster_list_by_round/1,\n"
        "   get_scene_trap_id_list/1,\n"
        "   get_scene_trap/2,\n"
        "   get_scene_event_list/1\n"
        "]).\n\n",
    file:write(FileFp, Head),
    {SceneGatherInfoList, SceneMonsterList, SceneNpcInfoList, SceneTrapInfoList, SceneEventInfoList} = lists:foldl(
        fun(SceneId, {TmpSceneGatherList, TmpSceneMonsterList, TmpSceneNpcInfoList, TmpSceneTrapInfoList, TmpSceneEventInfo}) ->
            File = scene_id_2_filename(SceneId),
            io:format("Decode json: ~p ~s", [File, lists:duplicate(max(0, 45 - length(File)), ".")]),
            case filelib:is_file(File) of
                true ->
                    {SceneGather, SceneMonsterList0, SceneNpcInfo, SceneTrapInfo, SceneEventInfo} = decode(SceneId, File, FileFp),
                    io:format(" [ok]\n\n"),
                    {
                        [SceneGather | TmpSceneGatherList],
                            SceneMonsterList0 ++ TmpSceneMonsterList,
                        [SceneNpcInfo | TmpSceneNpcInfoList],
                        [SceneTrapInfo | TmpSceneTrapInfoList],
                        [SceneEventInfo | TmpSceneEventInfo]
                    };
                false ->
                    io:format("\n[WARINING]: scene json no exists: " ++ File ++ "\n\n"),
                    exit({scene_json_no_exists, File}),
                    {
                        TmpSceneGatherList,
                        TmpSceneMonsterList,
                        TmpSceneNpcInfoList,
                        TmpSceneTrapInfoList,
                        TmpSceneEventInfo
                    }
            end
        end,
        {[], [], [], [], []},
        SceneIds
    ),
    Out0 =
        "get_scene_monster_id_list(Id) ->\n"
        "     logger:debug(\"scene_data =>get_scene_monster_id_list not find:~p~n\", [Id]),\n"
        "     [].\n\n",
    file:write(FileFp, Out0),
    lists:foldl(
        fun(SceneMonster, T) ->
            #r_scene_monster{
                id = Id,
                scene_id = SceneId
            } = SceneMonster,
            case lists:member({SceneId, Id}, T) of
                true ->
                    io:format("scene_monster_id_repeated:~p~n", [{SceneId, Id}]),
                    halt(1);
                false ->
                    noop
            end,
            Out = io_lib:format(
                "get_scene_monster({~p, ~p}) ->\n"
                "    ~p;\n",
                [SceneId, Id, SceneMonster]
            ),
            file:write(FileFp, Out),

            [{SceneId, Id} | T]
        end,
        [],
        SceneMonsterList
    ),
%%    lists:foreach(
%%        fun(SceneMonster) ->
%%            #r_scene_monster{
%%                id = Id
%%            } = SceneMonster,
%%            Out = io_lib:format(
%%                "get_scene_monster(~p) ->\n"
%%                "    ~p;\n",
%%                [Id, SceneMonster]
%%            ),
%%            file:write(FileFp, Out)
%%        end,
%%        SceneMonsterList
%%    ),
    Out1 =
        "get_scene_monster(Id) ->\n"
        "     logger:debug(\"scene_data =>get_scene_monster not find:~p~n\", [Id]),\n"
        "     null.\n\n",
    file:write(FileFp, Out1),

    lists:foreach(
        fun({SceneId, SceneGatherList}) ->
            SceneGatherIdList = [SceneGather#r_scene_gather.id || SceneGather <- SceneGatherList],
            Out = io_lib:format(
                "get_scene_gather_id_list(~p) ->\n"
                "    ~p;\n",
                [SceneId, SceneGatherIdList]
            ),
            file:write(FileFp, Out)
        end,
        SceneGatherInfoList
    ),
    file:write(FileFp,
        "get_scene_gather_id_list(Id) ->\n"
        "     logger:debug(\"scene_data =>get_scene_gather_id_list not find:~p~n\", [Id]),\n"
        "     [].\n\n"
    ),

    lists:foreach(
        fun({SceneId, SceneItemList}) ->
            lists:foreach(
                fun(SceneItem) ->
                    Out = io_lib:format(
                        "get_scene_gather({~p, ~p}) ->\n"
                        "    ~p;\n",
                        [SceneId, SceneItem#r_scene_gather.id, SceneItem]
                    ),
                    file:write(FileFp, Out)
                end,
                SceneItemList
            )

        end,
        SceneGatherInfoList
    ),
    file:write(FileFp,
        "get_scene_gather({SceneId, GatherId}) ->\n"
        "     logger:debug(\"scene_data =>get_scene_gather not find:~p~n\", [{SceneId, GatherId}]),\n"
        "     null.\n\n"
    ),


    L = lists:foldl(
        fun(SceneMonster, Tmp) ->
            #r_scene_monster{
                id = Id,
                level = Level,
                round = Round,
                scene_id = SceneId
            } = SceneMonster,
            util_list:key_insert({{SceneId, Level, Round}, Id}, Tmp)
        end,
        [],
        SceneMonsterList
    ),
    lists:foreach(
        fun({Key, Value}) ->
            ok = file:write(FileFp, io_lib:format(
                "get_scene_monster_list_by_round(~p) ->~n"
                "     ~w;~n"
                , [Key, Value]
            ))
        end,
        L
    ),
    Out2 =
        "get_scene_monster_list_by_round(Id) ->\n"
%%        "     logger:debug(\"scene_data =>get_scene_monster_list_by_round not find:~p~n\", [Id]),\n"
        "     [].\n\n",
    file:write(FileFp, Out2),

    lists:foreach(
        fun({Key, Value}) ->
            ok = file:write(FileFp, io_lib:format(
                "get_scene_npc_list(~p) ->~n"
                "     ~w;~n"
                , [Key, Value]
            ))
        end,
        SceneNpcInfoList
    ),
    Out3 =
        "get_scene_npc_list(SceneId) ->\n"
        "     logger:debug(\"scene_data =>get_scene_npc_list not find:~p~n\", [SceneId]),\n"
        "     null.\n\n",
    file:write(FileFp, Out3),

%%    io:format("MapEventInfoList:~p~n", [MapEventInfoList]),
%%    lists:foreach(
%%        fun({Key, {Type, Param}}) ->
%%            lib_file:write(FileFp, io_lib:format(
%%                "get_scene_event(~p) ->~n"
%%                "     {\"~s\", ~w};~n"
%%                , [Key, Type, Param]
%%            ))
%%        end,
%%        MapEventInfoList
%%    ),
%%    Out4 =
%%        "get_scene_event(SceneEventId) ->\n"
%%        "     logger:debug(\"scene_data =>get_scene_event not find:~p~n\", [SceneEventId]),\n"
%%        "     [].\n\n",
%%    file:write(FileFp, Out4),
    lists:foreach(
        fun({SceneId, SceneTrapList}) ->
            SceneIdTrapList = [SceneTrap#r_scene_trap.id || SceneTrap <- SceneTrapList],
            Out = io_lib:format(
                "get_scene_trap_id_list(~p) ->\n"
                "    ~p;\n",
                [SceneId, SceneIdTrapList]
            ),
            file:write(FileFp, Out)
        end,
        SceneTrapInfoList
    ),
    file:write(FileFp,
        "get_scene_trap_id_list(Id) ->\n"
        "     logger:debug(\"scene_data =>get_scene_trap_id_list not find:~p~n\", [Id]),\n"
        "     [].\n\n"
    ),

    lists:foreach(
        fun({SceneId, SceneTrapList}) ->
            lists:foreach(
                fun(SceneTrap) ->
%%                    SceneIdTrapList = [SceneTrap#r_scene_trap.id || SceneTrap<- SceneTrapList],
                    Out = io_lib:format(
                        "get_scene_trap(~p, ~p) ->\n"
                        "    ~p;\n",
                        [SceneId, SceneTrap#r_scene_trap.id, SceneTrap]
                    ),
                    file:write(FileFp, Out)
                end,
                SceneTrapList
            )
        end,
        SceneTrapInfoList
    ),
    file:write(FileFp,
        "get_scene_trap(SceneId, Id) ->\n"
        "     logger:debug(\"scene_data =>get_scene_trap not find:~p~n\", [{SceneId, Id}]),\n"
        "     [].\n\n"
    ),




    lists:foreach(
        fun(E) ->
%%            io:format("~p~n", [E]),
            {SceneId, SceneEventList} = E,
            Out = io_lib:format(
                "get_scene_event_list(~p) ->\n"
                "    ~p;\n",
                [SceneId, SceneEventList]
            ),
            file:write(FileFp, Out)
        end,
        SceneEventInfoList
    ),
    file:write(FileFp,
        "get_scene_event_list(Id) ->\n"
        "     logger:debug(\"scene_data =>get_scene_event_list not find:~p~n\", [Id]),\n"
        "     [].\n\n"
    ),


    qmake:compilep(?PATH, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH),

    %% 生成场景逻辑数据
    mod_map:init_all(),
    build_code_db:create_scene_logic_code(),

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

scene_id_2_filename(Id) ->
    MapDataDir = env:get(scene_data_dir),
    filename:join([MapDataDir, util:to_list(Id), "scene_data.json"]).

decode(SceneId, File, FileFp) ->
    {ok, Data} = file:read_file(File),
    Maps = jsone:decode(Data),
    {ok, MonsterArray} = maps:find(<<"monsterArray">>, Maps),
    SceneItemInfo =
        case maps:find(<<"gatherArray">>, Maps) of
            {ok, GatherArray} ->
                do_decode(gatherArray, SceneId, GatherArray, FileFp);
            _ ->
                {SceneId, []}
        end,
    SceneNpcInfo =
        case maps:find(<<"npcArray">>, Maps) of
            {ok, NpcInfoArray} ->
                do_decode(npcArray, SceneId, NpcInfoArray, FileFp);
            _ ->
                {SceneId, []}
        end,
    SceneMonsterList = do_decode(monsterArray, SceneId, MonsterArray, FileFp),
    TrapList =
        case maps:find(<<"trapArray">>, Maps) of
            {ok, TrapArray} ->
                do_decode(trapArray, SceneId, TrapArray, FileFp);
            _ ->
                []
        end,
    MapEventList =
        case maps:find(<<"mapEventArray">>, Maps) of
            {ok, MapEventArray} ->
                do_decode(mapEventArray, SceneId, MapEventArray, FileFp);
            _ ->
                {SceneId, []}
        end,
    {SceneItemInfo, SceneMonsterList, SceneNpcInfo, TrapList, MapEventList}.
do_decode(gatherArray, SceneId, GatherArray, _FileFp) ->
    {SceneId, lists:foldl(
        fun(Map, L) ->
            {ok, Id} = maps:find(<<"only_id">>, Map),
            {ok, GatherId} = maps:find(<<"gather_id">>, Map),
            {ok, X} = maps:find(<<"x">>, Map),
            {ok, Y} = maps:find(<<"y">>, Map),
            RGather = #r_scene_gather{
                id = Id,
                gather_id = GatherId,
                x = X,
                y = Y
            },
            [RGather | L]
        end,
        [],
        GatherArray
    )};
do_decode(mapEventArray, SceneId, MapEventArray, _FileFp) ->
    {SceneId, lists:foldl(
        fun(Map, L) ->
            {ok, EventArea} = maps:find(<<"eventArea">>, Map),
            {ok, EventList} = maps:find(<<"event_list">>, Map),
            PosList = lists:foldl(
                fun(P, Tmp) ->
                    [StrX, StrY] = string:split(P, "_"),
                    [{util:to_int(StrX), util:to_int(StrY)} |Tmp]
                end,
                [],
                EventArea
            ),
            if PosList == [] ->
                L;
                true ->
%%                    io:format("~p~n", [{{PosList, EventList}}]),
                    [{PosList, EventList} | L]
            end
        end,
        [],
        MapEventArray
    )};
do_decode(trapArray, SceneId, TrapArray, _FileFp) ->
    {SceneId, lists:foldl(
        fun(Map, L) ->
            {ok, TrapId} = maps:find(<<"trap_id">>, Map),
            {ok, Id} = maps:find(<<"only_id">>, Map),
            {ok, GridList} = maps:find(<<"grid_list">>, Map),
            {ok, Delay} = maps:find(<<"delay_time">>, Map),
            {ok, X} = maps:find(<<"x">>, Map),
            {ok, Y} = maps:find(<<"y">>, Map),
            {ok, ParamList} = maps:find(<<"param_list">>, Map),
            ParamList1 = util:to_list(ParamList),
            ParamList2 = string:tokens(ParamList1, "&"),
            ParamList3 = [util:to_int(Param) || Param <- ParamList2],
            TileList =
                lists:foldl(
                    fun(Grid, Tmp) ->
                        {ok, TileX} = maps:find(<<"x">>, Grid),
                        {ok, TileY} = maps:find(<<"y">>, Grid),
                        [
                            {trunc(TileX), trunc(TileY)} | Tmp
                        ]
                    end,
                    [],
                    GridList
                ),
            RSceneItem = #r_scene_trap{
                id = Id,
                trap_id = TrapId,
                x = trunc(X),
                y = trunc(Y),
                tile_list = TileList,
                delay = Delay,
                param_list = ParamList3
            },
            [RSceneItem | L]
        end,
        [],
        TrapArray
    )};
do_decode(npcArray, SceneId, NpcArray, _FileFp) ->
    {SceneId, lists:foldl(
        fun(Map, L) ->
%%            {ok, Id} = maps:find(<<"only_id">>, Map),
            {ok, NpcId} = maps:find(<<"npc_id">>, Map),
            {ok, X} = maps:find(<<"x">>, Map),
            {ok, Y} = maps:find(<<"y">>, Map),
            RSceneNpc = #r_scene_npc{
%%                id = Id,
                npc_id = NpcId,
                x = X,
                y = Y
            },
            [RSceneNpc | L]
        end,
        [],
        NpcArray
    )};
do_decode(monsterArray, SceneId, MonsterArray, FileFp) ->
    {SceneMonsterList, SceneMonsterIdList, SceneMonsterIdMap} = lists:foldl(
        fun(Map, {TmpSceneMonsterList, TmpSceneMonsterIdList, TmpSceneMonsterIdMap}) ->
            {ok, Id} = maps:find(<<"only_id">>, Map),
            {ok, MonsterId} = maps:find(<<"monster_id">>, Map),
            {ok, X} = maps:find(<<"x">>, Map),
            {ok, Y} = maps:find(<<"y">>, Map),
            Level = case maps:find(<<"level">>, Map) of
                        {ok, Level_} ->
                            Level_;
                        _ ->
                            0
                    end,
            Round = case maps:find(<<"round">>, Map) of
                        {ok, Round_} ->
                            Round_;
                        _ ->
                            0
                    end,
            Delay = case maps:find(<<"delay">>, Map) of
                        {ok, Delay_} ->
                            Delay_;
                        _ ->
                            0
                    end,
            RebirthTime = case maps:find(<<"rebrith">>, Map) of
                              {ok, RebirthTime_} ->
                                  RebirthTime_;
                              _ ->
                                  -2
                          end,
            t_monster:assert_get({MonsterId}),
            SceneMonster = #r_scene_monster{
                id = Id,
                monster_id = MonsterId,
                scene_id = SceneId,
                x = X,
                y = Y,
                level = Level,
                round = Round,
                delay = Delay,
                rebirth_time = RebirthTime
            },
            {[SceneMonster | TmpSceneMonsterList], [Id | TmpSceneMonsterIdList], util_list:key_insert({{SceneId, MonsterId}, Id}, TmpSceneMonsterIdMap)}
        end,
        {[], [], []},
        MonsterArray
    ),

    Out = io_lib:format(
        "get_scene_monster_id_list(~p) ->\n"
        "    ~p;\n",
        [SceneId, SceneMonsterIdList]
    ),
    file:write(FileFp, Out),
%%    io:format("~p~n", [SceneMonsterIdMap]),
    lists:foreach(
        fun({Key, Value}) ->
%%            io:format("~p~n", [E]),
            Out1 = io_lib:format(
                "get_scene_monster_id_list(~p) ->\n"
                "    ~p;\n",
                [Key, Value]
            ),
            file:write(FileFp, Out1)
        end,
        SceneMonsterIdMap
    ),
    SceneMonsterList.
%%do_decode(mapEventArray, SceneId, MapEventArray, _FileFp) ->
%%    Out = lists:foldl(
%%        fun(E, L) ->
%%            {ok, EventList} = maps:find(<<"event_list">>, E),
%%            L1 = lists:foldl(
%%                fun(R, L2) ->
%%                    {ok, Id} = maps:find(<<"event_id">>, R),
%%                    {ok, Type} = maps:find(<<"type">>, R),
%%                    {ok, ParamsList} = maps:find(<<"params_lsit">>, R),
%%                    [{Id, {Type, ParamsList}} | L2]
%%                end,
%%                [],
%%                EventList
%%            ),
%%            [L1 | L]
%%        end,
%%        [],
%%        MapEventArray
%%    ),
%%    io:format("Out~p~n", [lists:flatten(Out)]),
%%    lists:flatten(Out).


file_head() -> "%%% Generated automatically, no need to modify.\n".
%%    io_lib:format(
%%        "%%% Generated automatically, no need to modify.\n"
%%        "%%% Created : ~s\n\n",
%%        [util:format_datetime()]).
