%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2018, THYZ
%%% @doc            距离
%%% @end
%%% Created : 02. 一月 2018 下午 1:42
%%%-------------------------------------------------------------------
-module(util_math).
-include("common.hrl").
-include("scene.hrl").
%% API
-export([
    get_distance_from_path/1,
    get_distance/2,
    is_in_range/3,
    is_in_range/4,
    get_random_pos/3,
    get_angle/2,
    get_direction/2,
    tran_pos_by_dir/2,
    get_random_target_pix_pos/5,
    get_direct_src_pos/4,
    get_direct_target_pos/4,
    get_direct_target_pos_by_direction/5
]).

-export([test_get_direction/0]).


get_distance_from_path(MovePath) ->
    get_distance_from_path(MovePath, 0).
get_distance_from_path([], Dis) ->
    Dis;
get_distance_from_path([_], Dis) ->
    Dis;
get_distance_from_path([{X1, Y1}, {X2, Y2} | Left], Dis) ->
    get_distance_from_path([{X2, Y2} | Left], Dis + get_distance_2({X1, Y1}, {X2, Y2})).

get_distance({X1, Y1}, {X2, Y2}) ->
    max(abs(X1 - X2), abs(Y1 - Y2)).

get_distance_2({X1, Y1}, {X2, Y2}) ->
%%    max(abs(X1 - X2), abs(Y1 - Y2)).
    math:sqrt(erlang:abs((X1 - X2) * (X1 - X2)) + erlang:abs((Y1 - Y2) * (Y1 - Y2))).

is_in_range({X1, Y1}, {X2, Y2}, Range) ->
    is_in_range({X1, Y1}, {X2, Y2}, Range, 0).
is_in_range({X1, Y1}, {X2, Y2}, Range, Tolerate) ->
%%     abs(X1 - X2) =< Range andalso abs(Y1 - Y2) =< Range.
    Range1 = Range + Tolerate,
    abs(X1 - X2) =< Range1 andalso abs(Y1 - Y2) =< Range1.


get_random_pos(X, Y, Diff) when Diff > 0 ->
    {X + util_random:random_number(-Diff, Diff), Y + util_random:random_number(-Diff, Diff)}.

test_get_direction() ->
    Time1 = util_time:milli_timestamp(),
    test_get_direction(10000000),
    Time2 = util_time:milli_timestamp(),
    ?DEBUG("10000000次运行时间 ~p", [Time2 - Time1]).
test_get_direction(0) ->
    noop;
test_get_direction(M) ->
    get_direction({15000, 15000}, {6750, 6750}),
    test_get_direction(M - 1).
%% ----------------------------------
%% @doc 	获取两点的方向
%% @throws 	none
%% @end
%% @test 测试一千万次时间列表[1349,1341,1340,1339,1337,1345]ms
%% ----------------------------------
get_angle({SrcPixX, SrcPixY}, {DestPixX, DestPixY}) ->
    X = (DestPixX - SrcPixX),
    Y = case (SrcPixY - DestPixY) of 0 -> 1;Value -> Value end,
%%    ATan = math:atan2(Y, X) * 180 / math:pi(),
%%    Dir =
%%        if
%%            Y > 0 ->
%%                ATan;
%%            true ->
%%                360 - abs(ATan)
%%        end,
%%     @todo 参数错了，但是结果没问题。。。
    ATan = math:atan2(X, Y) * 180 / math:pi(),
    if
        X > 0 ->
            ATan;
        true ->
            360 - abs(ATan)
    end.
get_direction({SrcPixX, SrcPixY}, {DestPixX, DestPixY}) ->
    Angle = get_angle({SrcPixX, SrcPixY}, {DestPixX, DestPixY}),
    trunc(if Angle > 337.5 -> Angle + 22.5 - 360; true -> Angle + 22.5 end / 45).
%% @doc 测试一千万次时间列表[610,605,610,617,614,649,613,615]ms
%%get_direction({SrcPixX, SrcPixY}, {DestPixX, DestPixY}) ->
%%    SrcX = SrcPixX div 60,
%%    SrcY = SrcPixY div 60,
%%    DestX = DestPixX div 60,
%%    DestY = DestPixY div 60,
%%    if SrcX == DestX ->
%%        if SrcY == DestY ->
%%            ?DIR_DOWN;
%%            SrcY > DestY ->
%%                ?DIR_UP;
%%            SrcY < DestY ->
%%                ?DIR_DOWN
%%        end;
%%        SrcX > DestX ->
%%            if SrcY == DestY ->
%%                ?DIR_LEFT;
%%                SrcY > DestY ->
%%                    ?DIR_LEFT_UP;
%%                SrcY < DestY ->
%%                    ?DIR_LEFT_DOWN
%%            end;
%%        SrcX < DestX ->
%%            if SrcY == DestY ->
%%                ?DIR_RIGHT;
%%                SrcY > DestY ->
%%                    ?DIR_RIGHT_UP;
%%                SrcY < DestY ->
%%                    ?DIR_RIGHT_DOWN
%%            end
%%    end.

%% ----------------------------------
%% @doc 	坐标通过方向翻转
%% @throws 	none
%% @end
%% ----------------------------------
tran_pos_by_dir({X, Y}, Direction) ->
    Radian = direction_to_radian(Direction),
    TranX = round(math:cos(Radian) * X - math:sin(Radian) * Y),
    TranY = round(math:cos(Radian) * Y + math:sin(Radian) * X),
    [
        {TranX - 1, TranY - 1},
        {TranX - 1, TranY},
        {TranX - 1, TranY + 1},
        {TranX, TranY - 1},
        {TranX, TranY},
        {TranX, TranY + 1},
        {TranX + 1, TranY - 1},
        {TranX + 1, TranY},
        {TranX + 1, TranY + 1}
    ].

direction_to_radian(Direction) ->
    case Direction of
        ?DIR_UP ->
            4.712;
        ?DIR_RIGHT_UP ->
            5.8119;  %%5.4977; 333
        ?DIR_RIGHT ->
            0;
        ?DIR_RIGHT_DOWN ->
            0.4712;%%0.7853; 27
        ?DIR_DOWN ->
            1.5707;
        ?DIR_LEFT_DOWN ->
            2.6703;%%2.3561; 153
        ?DIR_LEFT ->
            3.1415;
        ?DIR_LEFT_UP ->
            3.6128%%3.9269 207
    end.


%%获取目标点随机像素坐标
get_random_target_pix_pos(MapId, {FPixX, FPixY}, {TPixX, TPixY}, Range_PixY, Range_PixX) ->
    {TTileX, TTileY} = get_random_target_tile_pos(MapId, ?PIX_2_TILE(FPixX, FPixY), ?PIX_2_TILE(TPixX, TPixY), trunc(Range_PixY / ?TILE_LEN), trunc(Range_PixX / ?TILE_LEN)),
    ?TILE_2_PIX(TTileX, TTileY).

%%获取目标点随机格子坐标
get_random_target_tile_pos(MapId, {FX, FY}, {TX, TY}, Range_Y, Range_X) ->
    get_random_target_tile_pos(MapId, {FX, FY}, {TX, TY}, Range_Y, Range_X, 1).
get_random_target_tile_pos(_MapId, {_FX, _FY}, {TX, TY}, _Range_Y, _Range_X, 0) ->
    {TX, TY};
get_random_target_tile_pos(MapId, {FX, FY}, {TX, TY}, Range_Y, Range_X, N) ->
    {TmpTX, TmpTY} =
        if
            FX == TX ->
                if
                    FY == TY ->
                        {
                            TX,
                            TY
                        };
                    FY > TY ->
                        {
                            TX + util_random:random_number(-Range_X, Range_X),
                            TY + util_random:random_number(1, Range_Y)
                        };
                    FY < TY ->
                        {
                            TX + util_random:random_number(-Range_X, Range_X),
                            TY + util_random:random_number(-Range_Y, -1)
                        }
                end;
            FX > TX ->
                if
                    FY == TY ->
                        {
                            TX + util_random:random_number(1, Range_Y),
                            TY + util_random:random_number(-Range_X, Range_X)
                        };
                    FY > TY ->
                        {
                            TX + util_random:random_number(1, Range_Y),
                            TY + util_random:random_number(1, Range_Y)
                        };
                    FY < TY ->
                        {
                            TX + util_random:random_number(1, Range_Y),
                            TY + util_random:random_number(-Range_Y, -1)
                        }
                end;
            FX < TX ->
                if
                    FY == TY ->
                        {
                            TX + util_random:random_number(-Range_Y, -1),
                            TY + util_random:random_number(-Range_X, Range_X)
                        };
                    FY > TY ->
                        {
                            TX + util_random:random_number(-Range_Y, -1),
                            TY + util_random:random_number(1, Range_Y)
                        };
                    FY < TY ->
                        {
                            TX + util_random:random_number(-Range_Y, -1),
                            TY + util_random:random_number(-Range_Y, -1)
                        }
                end
        end,
    case mod_map:can_walk({MapId, {TmpTX, TmpTY}}) of
        true ->
            {TmpTX, TmpTY};
        false ->
            get_random_target_tile_pos(MapId, {FX, FY}, {TX, TY}, Range_Y, Range_X, N - 1)
    end.


%%获取 两点间  直线上, 距离原点diff 距离的点
get_direct_src_pos(MapId, {X1, Y1}, {X1, Y2}, Diff) ->
    Y3 =
        if Y1 > Y2 ->
            Y1 - Diff;
            true ->
                Y1 + Diff
        end,
    case mod_map:can_walk({MapId, ?PIX_2_TILE(X1, Y3)}) of
        true ->
            {X1, Y3};
        false ->
            {X1, Y2}
    end;
get_direct_src_pos(MapId, {X1, Y1}, {X2, Y1}, Diff) ->
    X3 =
        if X1 > X2 ->
            X1 - Diff;
            true ->
                X1 + Diff
        end,
    case mod_map:can_walk({MapId, ?PIX_2_TILE(X3, Y1)}) of
        true ->
            {X3, Y1};
        false ->
            {X1, Y1}
    end;
get_direct_src_pos(MapId, {X1, Y1}, {X2, Y2}, Diff) ->
    K = (Y2 - Y1) / (X2 - X1),
    B = Y2 - K * X2,
    FY = fun(X) -> K * X + B end,
    Len = get_distance_2({X1, Y1}, {X2, Y2}),
    COS = abs(X1 - X2) / Len,
    DiffX = Diff * COS,
    X3 =
        if X1 > X2 ->
            trunc(X1 - DiffX);
            true ->
                trunc(X1 + DiffX)
        end,
    Y3 = trunc(FY(X3)),
    case mod_map:can_walk({MapId, ?PIX_2_TILE(X3, Y3)}) of
        true ->
            {X3, Y3};
        false ->
            {X2, Y2}
    end.

%%获取 两点间  直线上, 距离目标点diff 距离的点
get_direct_target_pos(MapId, {X1, Y1}, {X1, Y2}, Diff) ->
    Len = get_distance_2({X1, Y1}, {X1, Y2}),
    if Len > Diff ->
        Y3 =
            if Y1 > Y2 ->
                Y2 + Diff;
                true ->
                    Y2 - Diff
            end,
        case mod_map:can_walk({MapId, ?PIX_2_TILE(X1, Y3)}) of
            true ->
                {X1, Y3};
            false ->
                {X1, Y2}
        end;
        true ->
            {X1, Y1}
    end;
get_direct_target_pos(MapId, {X1, Y1}, {X2, Y2}, Diff) ->
    K = (Y2 - Y1) / (X2 - X1),
    B = Y2 - K * X2,
    FY = fun(X) -> K * X + B end,

    Len = get_distance_2({X1, Y1}, {X2, Y2}),
    if Len > Diff ->
        COS = abs(X1 - X2) / Len,
        DiffX = (Len - Diff) * COS,
        X3 =
            if X1 > X2 ->
                trunc(X1 - DiffX);
                true ->
                    trunc(X1 + DiffX)
            end,
        Y3 = trunc(FY(X3)),
        case mod_map:can_walk({MapId, ?PIX_2_TILE(X3, Y3)}) of
            true ->
                {X3, Y3};
            false ->
                {X2, Y2}
        end;
        true ->
            {X1, Y1}
    end.

%% @doc 获得距离某点 方向dir 距离range的点
get_direct_target_pos_by_direction(MapId, OldX, OldY, Dir, Range) ->
    get_direct_target_pos_by_direction(MapId, OldX, OldY, Dir, Range, Range div 10, 9).
get_direct_target_pos_by_direction(_MapId, OldX, OldY, _Dir, _Range, _Range1, 0) ->
    {OldX, OldY};
get_direct_target_pos_by_direction(MapId, OldX, OldY, Dir, Range, Range1, Times) ->
    {NewX, NewY} = {OldX + round(math:sin(Dir * math:pi() / 180) * Range), OldY - round(math:cos(Dir * math:pi() / 180) * Range)},
    case mod_map:can_walk_pix(MapId, NewX, NewY) of
        true ->
            {NewX, NewY};
        false ->
            get_direct_target_pos_by_direction(MapId, OldX, OldY, Dir, round(Range - Range1), Range1, Times - 1)
    end.