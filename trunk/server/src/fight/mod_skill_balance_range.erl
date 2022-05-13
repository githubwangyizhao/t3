%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            技能结算范围
%%% @end
%%% Created : 29. 十二月 2017 下午 4:46
%%%-------------------------------------------------------------------
-module(mod_skill_balance_range).
-include("fight.hrl").
-include("common.hrl").
-include("skill.hrl").
-include("gen/table_db.hrl").
-include("scene.hrl").
%% API
-export([
    get_balance_info/3,
    is_in_skill_range/10
]).
-export([
    get_balance_point_list_1/4,
    get_balance_point_list_2/5,
    get_balance_point_list_3/4
]).
-export([
    get_attack_distance_limit/2
]).


%% ----------------------------------
%% @doc 	获取结算信息
%% @throws 	none
%% @end
%% ----------------------------------
get_balance_info(NowBalanceRound, BalanceType, MergeBalanceInfo) ->
    case BalanceType of
        _ when BalanceType =:= ?BALANCE_TYPE_GRID;
            BalanceType =:= ?BALANCE_TYPE_GRID2;
            BalanceType =:= ?BALANCE_TYPE_GRID3;
            BalanceType =:= ?BALANCE_TYPE_GRID4;
            BalanceType =:= ?BALANCE_TYPE_GRID5 ->
            {_BalanceId, SumRate, SumDelay, MergeBalanceList} = lists:nth(NowBalanceRound, MergeBalanceInfo),
            {MergeBalanceList, SumRate, SumDelay};
        ?BALANCE_TYPE_DIS ->
            {[], 1, 1000}
    end.

%% ----------------------------------
%% @doc     是否在技能攻击范围
%% @throws 	none
%% @end
%% ----------------------------------
is_in_skill_range(IsTarget, IsCommonSkill, IsSkillIsCircular, MergeBalanceGridList, Dir, BalanceType, AttackLength, {CalcPixX, CalcPixY}, {DefPixX, DefPixY}, AllowHurtDistance) ->
    if
        IsTarget andalso IsCommonSkill == true -> %% 普攻 主目标只判断距离
            IsInSKill = util_math:is_in_range({CalcPixX, CalcPixY}, {DefPixX, DefPixY}, ?TILE_LEN * (AttackLength + AllowHurtDistance + 4)),
%%            ?IF(IsInSKill == false, ?DEBUG("普工空了 :~p", [{{CalcPixX, CalcPixY}, {DefPixX, DefPixY}, AttackLength}]),noop),
            IsInSKill;
        true ->
            case BalanceType of
                _ when BalanceType =:= ?BALANCE_TYPE_GRID;
                    BalanceType == ?BALANCE_TYPE_GRID2;
                    BalanceType == ?BALANCE_TYPE_GRID3;
                    BalanceType == ?BALANCE_TYPE_GRID4;
					BalanceType == ?BALANCE_TYPE_GRID5 ->
                    RealDir =
                        %% 圆形结算范围
                    if IsSkillIsCircular == ?TRUE ->
                        -1;
                        true ->
                            Dir
                    end,
                    if
                        AllowHurtDistance == 0 ->
                            {DefTileX, DefTileY} = {trunc(DefPixX / 10), trunc(DefPixY / 10)},
                            {CalcTileX, CalcTileY} = {trunc(CalcPixX / 10), trunc(CalcPixY / 10)},
                            {DiffTileX, DiffTileY} = {DefTileX - CalcTileX, DefTileY - CalcTileY},
                            lists:any(
                                fun({_, SkillBalanceGridId, _, _}) ->
                                    is_in_balance_range(SkillBalanceGridId, RealDir, {DiffTileX, DiffTileY})
                                end,
                                MergeBalanceGridList
                            );
                        true ->
                            {CalcTileX, CalcTileY} = ?PIX_2_TILE(CalcPixX, CalcPixY),
                            lists:any(
                                fun({CheckTileX, CheckTileY}) ->
                                    {DiffTileX, DiffTileY} = {CheckTileX - CalcTileX, CheckTileY - CalcTileY},
                                    lists:any(
                                        fun({_, SkillBalanceGridId, _, _}) ->
                                            is_in_balance_range(SkillBalanceGridId, RealDir, {DiffTileX, DiffTileY})
                                        end,
                                        MergeBalanceGridList
                                    )
                                end,
                                get_range_tile_list(AllowHurtDistance, ?PIX_2_TILE(DefPixX, DefPixY))
                            )
                    end;
                ?BALANCE_TYPE_DIS ->
                    util_math:is_in_range({CalcPixX, CalcPixY}, {DefPixX, DefPixY}, ?TILE_LEN * (AttackLength + AllowHurtDistance))
            end
    end.

%% 获取范围内 格子列表
get_range_tile_list(Range, {X, Y}) ->
    RangeList = lists:seq(-Range, Range),
    lists:foldl(
        fun(DiffX, Tmp) ->
            X0 = X + DiffX,
            lists:foldl(
                fun(DiffY, Tmp1) ->
                    Y0 = Y + DiffY,
                    [{X0, Y0} | Tmp1]
                end,
                [],
                RangeList
            ) ++ Tmp
        end,
        [],
        RangeList
    ).

is_in_balance_range(SkillBalanceGridId, Dir, {DiffX, DiffY}) ->
    case logic_is_in_balance_grid:get({SkillBalanceGridId, Dir, {DiffX, DiffY}}) of
        null ->
            false;
        _ ->
            true
    end.

%% 获取攻击距离
get_attack_distance_limit(?BALANCE_TYPE_DIS, AttackLength) -> AttackLength * ?TILE_LEN;
get_attack_distance_limit(?BALANCE_TYPE_GRID, _AttackLength) -> 0;      %% 按格子计算可攻击范围，不考虑距离
get_attack_distance_limit(?BALANCE_TYPE_GRID2, _AttackLength) -> 0;
get_attack_distance_limit(?BALANCE_TYPE_GRID3, _AttackLength) -> 0;
get_attack_distance_limit(?BALANCE_TYPE_GRID4, _AttackLength) -> 0;
get_attack_distance_limit(?BALANCE_TYPE_GRID5, _AttackLength) -> 0.

%% 获取技能位置列表（周围玩家的位置）
get_balance_point_list_1(X, Y, DisLimit, TargetNum) ->
    PointList =
        lists:filtermap(fun(PlayerId) ->
            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                ?UNDEFINED -> false;
                ObjScenePlayer ->
                    #obj_scene_actor{
                        x = TempX,
                        y = TempY
                    } = ObjScenePlayer,
                    IsInRange = util_math:is_in_range({X, Y}, {TempX, TempY}, DisLimit),
                    ?IF(IsInRange, {true, {TempX, TempY}}, false)
            end
        end, mod_scene_player_manager:get_all_obj_scene_player_id()),
    lists:sublist(util_list:shuffle(PointList), TargetNum).

%% 获取技能位置列表（周围随机位置）
get_balance_point_list_2(X, Y, DisLimit, Gap, TargetNum) ->
    case Gap > 0 of
        true ->
            XList = [X_0 || X_0 <- lists:seq(X - DisLimit, X + DisLimit, Gap * ?TILE_LEN), X_0 > 0],
            YList = [Y_0 || Y_0 <- lists:seq(Y - DisLimit, Y + DisLimit, Gap * ?TILE_LEN), Y_0 > 0],
            Func =
                fun(_This, Acc, TempXList, TempYList, _N) when TempXList == []; TempYList == [] ->
                    Acc;
                    (_This, Acc, _TempXList, _TempYList, 0) ->
                        Acc;
                    (This, Acc, TempXList, TempYList, N) ->
                        TempX = lists:nth(rand:uniform(length(TempXList)), TempXList),
                        TempY = lists:nth(rand:uniform(length(TempYList)), TempYList),
                        This(This, [{TempX, TempY} | Acc], lists:delete(TempX, TempXList), lists:delete(TempY, TempYList), N - 1)
                end,
            Func(Func, [], XList, YList, TargetNum);
        false ->
            [begin
                 RX = util_random:random_number(X - DisLimit, X + DisLimit),
                 RY = util_random:random_number(Y - DisLimit, Y + DisLimit),
                 {RX, RY}
             end || _N <- lists:seq(1, TargetNum)]
    end.

%% 获取技能位置列表（固定位置）
get_balance_point_list_3(X, Y, MapId, BaseDotLists) ->
    Len = length(BaseDotLists),
    Rand = rand:uniform(Len),
    Func =
        fun([OffsetX, OffsetY]) ->
            {RX, RY} = {X + OffsetX, Y + OffsetY},
            case mod_map:can_walk_pix(MapId, RX, RY) of
                true -> {true, {RX, RY}};
                false -> false
            end
        end,
    lists:filtermap(Func, lists:nth(Rand, BaseDotLists)).