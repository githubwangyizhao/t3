-module(navigate).

-export([
    start/3,
    start/5,
    start/6,
    start_2/3,
    start_2/5,
    start_2/6,
    start_2/7,
    floyd/2,
    check_line/3,
    check/3
]).
-include("common.hrl").
-include("scene.hrl").
-include("prof.hrl").

-record(r_map_node, {key, g, f, p_parent}).
-define(DEFAULT_MAX_NAVIGATE_NODE, 500).

-define(GET_OPEN_LIST(), erlang:get(astar_open_list)).
-define(INIT_OPEN_LIST(), erlang:put(astar_open_list, [])).
-define(SET_OPEN_LIST(OpenList, AddMapNode),
    erlang:put(astar_open_list, OpenList),
    if AddMapNode =/= null ->
        erlang:put({open, AddMapNode#r_map_node.key}, AddMapNode),
        erlang:put(open_node_list, [AddMapNode#r_map_node.key | get(open_node_list)]);
        true ->
            noop
    end
).
-define(DELETE_OPEN_LIST(), erlang:erase(astar_open_list)).


-define(GET_CLOSE_LIST(), erlang:get(astar_close_list)).
-define(INIT_CLOSE_LIST(), erlang:put(astar_close_list, [])).
%%-define(SET_CLOSE_LIST(CloseList), erlang:put(astar_close_list, CloseList)).
-define(INSERT_CLOSE_LIST(Node),
    erlang:put(astar_close_list, [Node | erlang:get(astar_close_list)]),
    erlang:put({close, Node#r_map_node.key}, Node),
    erlang:put(close_node_list, [Node#r_map_node.key | get(close_node_list)]),
    put(close_list_length, get(close_list_length) + 1)
).
-define(DELETE_CLOSE_LIST(), erlang:erase(astar_close_list)).


-define(INIT_CLOSE_NODE_LIST(), put(close_node_list, [])).
-define(ERASE_CLOSE_NODE_LIST(),
    lists:foreach(
        fun(Key_) ->
            erlang:erase({close, Key_})
        end,
        get(close_node_list)
    ),
    erlang:erase(close_node_list)
).

-define(INIT_OPEN_NODE_LIST(), put(open_node_list, [])).
-define(ERASE_OPEN_NODE_LIST(),
    lists:foreach(
        fun(Key_) ->
            erlang:erase({open, Key_})
        end,
        get(open_node_list)
    ),
    erlang:erase(open_node_list)
).

-define(GET_CLOSE_NODE(Key),
    get({close, Key})
).
-define(GET_OPEN_NODE(Key),
    get({open, Key})
).

-define(GET_CLOSE_LIST_LENGTH(), get(close_list_length)).
-define(INIT_CLOSE_LIST_LENGTH(), put(close_list_length, 0)).
-define(SET_CLOSE_LIST_LENGTH(N), put(close_list_length, N)).

init() ->
    ?INIT_CLOSE_LIST_LENGTH(),
    ?INIT_CLOSE_LIST(),
    ?INIT_OPEN_LIST(),
    ?INIT_CLOSE_NODE_LIST(),
    ?INIT_OPEN_NODE_LIST().

clean() ->
    ?DELETE_OPEN_LIST(),
    ?DELETE_CLOSE_LIST(),
    ?ERASE_CLOSE_NODE_LIST(),
    ?ERASE_OPEN_NODE_LIST().

-define(IS_CLOSE_MEMBER(Key), ?GET_CLOSE_NODE({TX, TY}) =/= undefined).

%% 传 像素点 坐标
start_2(MapId, {StartPixX, StartPixY}, {EndPixX, EndPixY}) ->
    start_2(MapId, {StartPixX, StartPixY}, {EndPixX, EndPixY}, false, false).
start_2(_MapId, {StartPixX, StartPixY}, {EndPixX, EndPixY}, IsFloyd, IsJump) ->
    start_2(_MapId, {StartPixX, StartPixY}, {EndPixX, EndPixY}, IsFloyd, IsJump, ?DEFAULT_MAX_NAVIGATE_NODE).

start_2(MapId, {StartPixX, StartPixY}, {EndPixX, EndPixY}, IsFloyd, IsJump, MaxNavigateNode) ->
    start_2(MapId, {StartPixX, StartPixY}, {EndPixX, EndPixY}, IsFloyd, IsJump, MaxNavigateNode, 0).

start_2(_MapId, {StartPixX, StartPixY}, {StartPixX, StartPixY}, _IsFloyd, _IsJump, _MaxNavigateNode, _Diff) ->
    {fail, []};
start_2(MapId, {StartPixX, StartPixY}, {EndPixX, EndPixY}, IsFloyd, IsJump, MaxNavigateNode, Diff) ->
%%    ?START_PROF,
    try
        StartTile = ?PIX_2_TILE(StartPixX, StartPixY),
        EndTile = ?PIX_2_TILE(EndPixX, EndPixY),
        if StartTile == EndTile ->
            {false, [{EndPixX, EndPixY}]};
            true ->
                {IsMaxNode, MovePath} = start(MapId, StartTile, EndTile, IsFloyd, IsJump, MaxNavigateNode),
                Result =
                    if IsMaxNode == true ->
                        max_node;
                        true ->
                            success
                    end,
                if
                    MovePath == [] ->
                        {Result, []};
                    true ->
                        PixMovePath = [?TILE_2_PIX(T_X, T_Y) || {T_X, T_Y} <- MovePath],
                        RealMovePath =
                            if
                                Diff == 0 ->
                                    PixMovePath;
                                true ->
                                    [{X2, Y2}, {X1, Y1} | Left] = lists:reverse(PixMovePath),
                                    {X3, Y3} = util_math:get_direct_target_pos(MapId, {X1, Y1}, {X2, Y2}, Diff),
                                    if {X3, Y3} == {X1, Y1} ->
                                        lists:reverse([{X1, Y1} | Left]);
                                        true ->
                                            lists:reverse([{X3, Y3}, {X1, Y1} | Left])
                                    end

                            end,

                        [_ | T] = RealMovePath,
                        {
                            Result,
                            if T == [] ->
                                RealMovePath;
                                true ->
                                    case get({jump_p, StartTile}) of
                                        true ->
                                            RealMovePath;
                                        _ ->
                                            T
                                    end
                            end
                        }
                end
        end
    of
        {Result_, FindPath} ->
            {Result_, FindPath}
    catch
        _:_Reason ->
%%            ?DEBUG("寻路失败:~p", [{Reason, MapId, {StartPixX, StartPixY}, {EndPixX, EndPixY}, IsFloyd, MaxNavigateNode, Diff}]),
            {fail, []}
    end.

%% 传 Tile 坐标
%% return {IsMaxNode, [{StartX, StartY} ...]}
start(MapId, {StartX, StartY}, {EndX, EndY}) ->
    start(MapId, {StartX, StartY}, {EndX, EndY}, false, false).
start(MapId, {StartX, StartY}, {EndX, EndY}, IsFloyd, IsJump) ->
    start(MapId, {StartX, StartY}, {EndX, EndY}, IsFloyd, IsJump, ?DEFAULT_MAX_NAVIGATE_NODE).
start(MapId, {StartX, StartY}, {EndX, EndY}, IsFloyd, IsJump, MaxNavigateNode) ->
    ?ASSERT(mod_map:can_walk({MapId, {EndX, EndY}}), {navigate_no_walk, {MapId, {EndX, EndY}}}),
    put(navigate_info, {MapId, {StartX, StartY}, {EndX, EndY}, IsFloyd, MaxNavigateNode}),
    put('MaxNavigateNode', MaxNavigateNode),
    put('navigate_is_max_node', false),
    Dis = util_math:get_distance({StartX, StartY}, {EndX, EndY}),
    if Dis >= 25 ->
        put(is_use_node_path, true);
        true ->
            put(is_use_node_path, false)
    end,
%%    ?DEBUG("~p~n", [{MapId, {StartX, StartY}, {EndX, EndY}, IsFloyd}]),
    Path1 =
        case StartX =:= EndX andalso StartY =:= EndY of
            true ->
                [];
            false ->
                case quick_find_path(MapId, StartX, StartY, EndX, EndY) of
                    stop ->
                        StartNode = #r_map_node{key = {StartX, StartY}, g = 0},
                        init(),
                        P0 =
                            try find_path(MapId, EndX, EndY, StartNode, IsFloyd, IsJump)
                            catch
                                _:Reason ->
                                    clean(),
                                    exit(Reason)
                            end,
                        clean(),
                        P0;
%%                        [_ | P1] = P0,
%%                        P1;
                    Path ->
                        Path
                end
        end,
    {
        get('navigate_is_max_node'),
        if IsFloyd ->
%%        ?DEBUG("LENGTH:~p~n", [?GET_CLOSE_LIST_LENGTH()]),
            floyd(MapId, Path1);
            true ->
                Path1
        end
    }.

%%arrange_path(Path) ->
%%    arrange_path(Path, [], 0).
%%arrange_path([], L, _K) ->
%%    lists:reverse(L);
%%arrange_path([{X1, Y1} | L1], [], K) ->
%%    arrange_path(L1, [{X1, Y1}], K);
%%arrange_path([{X1, Y1} | L1], [{X0, Y0}], _K) ->
%%    arrange_path(L1, [{X1, Y1}, {X0, Y0}], get_k({X0, Y0}, {X1, Y1}));
%%arrange_path([{X1, Y1} | L1], [{X0, Y0} | L], K) ->
%%    case get({jump_p, {X0, Y0}}) of
%%        true ->
%%            NewK = get_k({X0, Y0}, {X1, Y1}),
%%            arrange_path(L1, [{X1, Y1}, {X0, Y0} | L], NewK);
%%        _ ->
%%            NewK = get_k({X0, Y0}, {X1, Y1}),
%%            if NewK == K ->
%%                arrange_path(L1, [{X1, Y1} | L], K);
%%                true ->
%%                    arrange_path(L1, [{X1, Y1}, {X0, Y0} | L], NewK)
%%            end
%%    end.
%%
%%get_k({X0, Y0}, {X1, Y1}) ->
%%    if
%%        X1 == X0 ->
%%            infinite;
%%        true ->
%%            (Y1 - Y0) / (X1 - X0)
%%    end.

%%pos_to_direction({AX, AY}, {DX, DY}) ->
%%    if
%%        AX == DX ->
%%            if AY == DY ->
%%                ?DIR_DOWN;
%%                AY > DY ->
%%                    ?DIR_UP;
%%                AY < DY ->
%%                    ?DIR_DOWN
%%            end;
%%        AX > DX ->
%%            if AY == DY ->
%%                ?DIR_LEFT;
%%                AY > DY ->
%%                    ?DIR_LEFT_UP;
%%                AY < DY ->
%%                    ?DIR_LEFT_DOWN
%%            end;
%%        AX < DX ->
%%            if AY == DY ->
%%                ?DIR_RIGHT;
%%                AY > DY ->
%%                    ?DIR_RIGHT_UP;
%%                AY < DY ->
%%                    ?DIR_RIGHT_DOWN
%%            end
%%    end.

quick_find_path(MapId, StartX, StartY, ENdX, EndY) ->
    case check_line(MapId, {StartX, StartY}, {ENdX, EndY}) of
        true ->
            [{StartX, StartY}, {ENdX, EndY}];
        false ->
            stop
    end.

find_path(MapId, EndX, EndY, CurNode, IsFloyd, IsJump) ->
    case catch insert_around_nodes(MapId, CurNode, EndX, EndY, IsFloyd, IsJump) of
        {ok, reach} ->
            Path = [{EndX, EndY}],
            deal_result(CurNode, Path);
        Bool ->
            case ?GET_OPEN_LIST() of
                [] ->
                    exit({error, no_way});
                [MinNode | T] ->
                    ?SET_OPEN_LIST(T, null),
                    if Bool ->
                        case insert_close_list(CurNode) of
                            true ->
                                deal_result(CurNode, []);
                            false ->
                                find_path(MapId, EndX, EndY, MinNode, IsFloyd, IsJump)
                        end;
                        true ->
                            find_path(MapId, EndX, EndY, MinNode, IsFloyd, IsJump)
                    end
            end
    end.

deal_result(#r_map_node{p_parent = undefined} = MapNode, Path) ->
    [MapNode#r_map_node.key | Path];
deal_result(CurNode, Path) ->
    ParentNode = ?GET_CLOSE_NODE(CurNode#r_map_node.p_parent),
    deal_result(ParentNode, [CurNode#r_map_node.key | Path]).

%%
%%get_expect(X, Y, X1, Y1) ->
%%    erlang:abs(X1 - X) + erlang:abs(Y1 - Y).

insert_close_list(Node) ->
    ?INSERT_CLOSE_LIST(Node),
    case ?GET_CLOSE_LIST_LENGTH() >= get('MaxNavigateNode') of
        true ->
%%            io:format("Max node:~p!!!~n", [get(navigate_info)]),
%%            exit(max_node),
            put('navigate_is_max_node', true),
            true;
        false ->
            false
    end.

update_open_list(MapNode) ->
    ?SET_OPEN_LIST(lists:keyreplace(MapNode#r_map_node.key, #r_map_node.key, ?GET_OPEN_LIST(), MapNode), MapNode).
%%    set_open_list().

insert_open_list(MapNode) ->
    OpenList = ?GET_OPEN_LIST(),
    Fun = fun(#r_map_node{f = F}, {AccInH, AccInT}) ->
        case F >= MapNode#r_map_node.f of
            true ->
                throw({get, lists:reverse([MapNode | AccInH], AccInT)});
            false ->
                [AccInTH | AccInTT] = AccInT,
                {[AccInTH | AccInH], AccInTT}
        end
          end,
    case catch lists:foldl(Fun, {[], OpenList}, OpenList) of
        {get, NewOpenList} ->
            ?SET_OPEN_LIST(NewOpenList, MapNode);
        _ ->
            ?SET_OPEN_LIST(OpenList ++ [MapNode], MapNode)
    end.

%%is_close_list_member({TX, TY}) ->
%%    ?GET_CLOSE_NODE({TX, TY}) =/= undefined.
%%    lists:keyfind({TX, TY}, #r_map_node.key, ?GET_CLOSE_LIST()) =/= false.

insert_around_nodes(MapId, CurNode, EndTX, EndTY, _IsFloyd, IsJump) ->
    #r_map_node{key = {CTX, CTY}} = CurNode,
    F = fun(TileInfo, AccIn) ->
        {TX, TY, IsPriority} = case TileInfo of
                                   {TX_, TY_} ->
                                       {TX_, TY_, false};
                                   {TX_, TY_, IsPriority_} ->
                                       {TX_, TY_, IsPriority_}
                               end,
        if TX =:= EndTX andalso TY =:= EndTY ->
            erlang:throw({ok, reach});
            true ->
                insert_around_nodes(MapId, CurNode, EndTX, EndTY, TX, TY, IsPriority, ?IS_CLOSE_MEMBER({TX, TY})) orelse AccIn
        end
        end,

    %% 跳跃点列表
    JumpL =
        if IsJump == true ->
            case get({jump, {CTX, CTY}}) of
                undefined ->
                    [];
                JumpL_ ->
                    [{JX, JY, true} || {JX, JY} <- JumpL_]
            end;
            true ->
                []
        end,

    %% 提前寻路好的路径
    PathL =
        if
            IsJump == true ->
                case get({path, {CTX, CTY}}) of
                    undefined ->
                        [];
                    PathL_ ->
                        PathL_
                end;
            true ->
                case get({jump_p, {CTX, CTY}}) of
                    true ->
                        %% 如果是跳跃点 则 为空
                        [];
                    _ ->
                        case get({path, {CTX, CTY}}) of
                            undefined ->
                                [];
                            PathL_ ->
                                PathL_
                        end
                end
        end,
    NodeList =
        case get(is_use_node_path) of
            true ->
                JumpL ++ PathL ++ [
                    {CTX - 1, CTY - 1, false},
                    {CTX - 1, CTY, false},
                    {CTX - 1, CTY + 1, false},
                    {CTX, CTY - 1, false},
                    {CTX, CTY + 1, false},
                    {CTX + 1, CTY - 1, false},
                    {CTX + 1, CTY + 1, false},
                    {CTX + 1, CTY, false}
                ];
            _ ->
                JumpL ++ [
                    {CTX - 1, CTY - 1, false},
                    {CTX - 1, CTY, false},
                    {CTX - 1, CTY + 1, false},
                    {CTX, CTY - 1, false},
                    {CTX, CTY + 1, false},
                    {CTX + 1, CTY - 1, false},
                    {CTX + 1, CTY + 1, false},
                    {CTX + 1, CTY, false}
                ]
        end,
    lists:foldl(F, false, NodeList).

insert_around_nodes(_MapId, _CurNode, _EndTX, _EndTY, _TX, _TY, _IsPriority, true) ->
    false;
insert_around_nodes(MapId, CurNode, EndTX, EndTY, TX, TY, IsPriority, false) ->
%%    case lists:keyfind({TX, TY}, #r_map_node.key, ?GET_OPEN_LIST()) of
    case ?GET_OPEN_NODE({TX, TY}) of
        undefined ->
            case mod_map:can_walk({MapId, {TX, TY}}) of
                true ->
                    MapNode = make_node(TX, TY, IsPriority, CurNode, EndTX, EndTY),
                    insert_open_list(MapNode),
                    true;
                false ->
                    false
            end;
        OldMapNode ->
            MapNode = make_node(TX, TY, IsPriority, CurNode, EndTX, EndTY),
            case MapNode#r_map_node.f >= OldMapNode#r_map_node.f of
                true ->
                    false;
                false ->
                    update_open_list(MapNode),
                    true
            end
    end.

make_node(TX, TY, IsPriority, CurNode, EndTX, EndTY) ->
    G = CurNode#r_map_node.g + 1,
    H =
        if IsPriority ->
            1;
            true ->
                erlang:abs(EndTX - TX) + erlang:abs(EndTY - TY)
%%                get_expect(TX, TY, EndTX, EndTY)
        end,
    #r_map_node{key = {TX, TY}, g = G, f = G + H, p_parent = CurNode#r_map_node.key}.

floyd(MapId, Path) ->
    do_floyd(MapId, Path, []).
do_floyd(_MapId, [], Path) ->
    lists:reverse(Path);
do_floyd(MapId, [{X, Y} | L], Path) ->
    Left = do_floyd_1(MapId, {X, Y}, L, []),
    do_floyd(MapId, lists:reverse(Left), [{X, Y} | Path]).

do_floyd_1(_MapId, {_X, _Y}, [], Left) ->
    Left;
do_floyd_1(MapId, {X, Y}, [{X1, Y1} | L], Left) ->
    case get({jump_p, {X1, Y1}, {X, Y}}) of
        true ->
            do_floyd_1(MapId, {X, Y}, [], lists:reverse([{X1, Y1} | L]));
        _ ->
            case check_line(MapId, {X, Y}, {X1, Y1}) of
                true ->
                    do_floyd_1(MapId, {X, Y}, L, [{X1, Y1}]);
                false ->
                    do_floyd_1(MapId, {X, Y}, L, [{X1, Y1} | Left])
            end
    end.


%% 检查两点之间是否可以行走
check_line(MapId, {X1, Y1}, {X2, Y2}) ->
    get({jump_p, {X1, Y1}, {X2, Y2}}) == true orelse
        if X1 == X2 orelse Y1 == Y2 ->
            handle_check_line_2(MapId, {X1, Y1}, {X2, Y2});
            true ->
                handle_check_line(MapId, {X1, Y1}, {X2, Y2})
        end.

handle_check_line_2(MapId, {X, Y}, {X1, Y1}) ->
    case mod_map:can_walk({MapId, {X, Y}}) of
        true ->
            if
                X == X1 ->
                    if Y == Y1 ->
                        true;
                        Y > Y1 ->
                            handle_check_line_2(MapId, {X, Y - 1}, {X1, Y1});
                        Y < Y1 ->
                            handle_check_line_2(MapId, {X, Y + 1}, {X1, Y1})
                    end;
                X > X1 ->
                    if Y == Y1 ->
                        handle_check_line_2(MapId, {X - 1, Y}, {X1, Y1});
                        Y > Y1 ->
                            handle_check_line_2(MapId, {X - 1, Y - 1}, {X1, Y1});
                        Y < Y1 ->
                            handle_check_line_2(MapId, {X - 1, Y + 1}, {X1, Y1})
                    end;
                X < X1 ->
                    if Y == Y1 ->
                        handle_check_line_2(MapId, {X + 1, Y}, {X1, Y1});
                        Y > Y1 ->
                            handle_check_line_2(MapId, {X + 1, Y - 1}, {X1, Y1});
                        Y < Y1 ->
                            handle_check_line_2(MapId, {X + 1, Y + 1}, {X1, Y1})
                    end
            end;
        false ->
            false
    end.


handle_check_line(MapId, {X1, Y1}, {X2, Y2}) ->
    Dx = abs(X2 - X1),
    Dy = abs(Y2 - Y1),
    IsX = ?IF(Dx > Dy, true, false),
    {{X3, Y3}, {X4, Y4}} = {{X1 + 0.5, Y1 + 0.5}, {X2 + 0.5, Y2 + 0.5}},
    K = (Y4 - Y3) / (X4 - X3),
    B = Y4 - K * X4,
    if
        IsX ->
            FY = fun(X) -> K * X + B end,
            StartX = min(X1, X2),
            EndX = max(X1, X2),
            do_x(MapId, StartX + 1, EndX, FY);
        true ->
            FX = fun(Y) -> (Y - B) / K end,
            StartY = min(Y1, Y2),
            EndY = max(Y1, Y2),
            do_y(MapId, StartY + 1, EndY, FX)
    end.

do_x(MapId, X1, X2, FY) ->
    if X1 == X2 ->
        true;
        true ->
            case check(MapId, X1, FY(X1)) of
                true ->
                    do_x(MapId, X1 + 1, X2, FY);
                false ->
                    false
            end
    end.

do_y(MapId, Y1, Y2, FX) ->
    if Y1 == Y2 ->
        true;
        true ->
            case check(MapId, FX(Y1), Y1) of
                true ->
                    do_y(MapId, Y1 + 1, Y2, FX);
                false ->
                    false
            end
    end.

check(MapId, X, Y) ->
    FlagX = trunc(X * 10000) rem 10000 == 0,
    FlagY = trunc(Y * 10000) rem 10000 == 0,
    RealX = trunc(X),
    RealY = trunc(Y),

%%    io:format("~p~n", [{X, Y, FlagX, FlagY}]),
    if FlagX andalso FlagY ->
        mod_map:can_walk({MapId, {RealX, RealY}}) orelse
            (mod_map:can_walk({MapId, {RealX - 1, RealY - 1}}) andalso
                mod_map:can_walk({MapId, {RealX - 1, RealY}}) andalso
                mod_map:can_walk({MapId, {RealX, RealY - 1}}));
        FlagX andalso FlagY == false ->
            mod_map:can_walk({MapId, {RealX, RealY}}) orelse
                mod_map:can_walk({MapId, {RealX - 1, RealY}});
        FlagY == true andalso FlagX == false ->
            mod_map:can_walk({MapId, {RealX, RealY - 1}}) orelse
                mod_map:can_walk({MapId, {RealX, RealY}});
        true ->
            mod_map:can_walk({MapId, {RealX, RealY}})
    end.

