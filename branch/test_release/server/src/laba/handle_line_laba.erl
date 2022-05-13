%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%      连线拉霸机
%%% @end
%%% Created : 25. 五月 2021 上午 11:20:42
%%%-------------------------------------------------------------------
-module(handle_line_laba).
-author("yizhao.wang").

-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("error.hrl").
-include("client.hrl").
-include("player_game_data.hrl").
-include("laba.hrl").

%% 必须导出的api
-export([
    init_grids/1,
    handle_laba_spin/3,
    set_protect_base_kind/1
]).

-define(GRID_ROW, 3).
-define(GRID_COL, 5).

-record(?MODULE, {
    freegame_flag = false,              %% 是否进入FreeGame模式标志
    protect_base_kind = -1,             %% 保底基础图示（促发保底方案时使用）
    pre_set_line = [],                   %% 预埋线（预埋方案时使用）

    lineSuccessFlag = false,            %% 是否连线成功标志
    hitSpecialGridIdList = [],          %% 命中的特殊格子id列表
    hitFGSpecialGridIdList = []         %% 命中FreeGame的特殊格子id列表
}).

%% ----------------------------------
%% @doc 	初始化
%% @throws 	none
%% @end
%% ----------------------------------
init_data() ->
    ?INIT_GRID_ROW(?GRID_ROW),
    ?INIT_GRID_COL(?GRID_COL),

    ?setModDict(freegame_flag, false),
    ?setModDict(protect_base_kind, -1),
    ?setModDict(pre_set_line, []),
    reset_all_grid_data(),
    ok.

%% ----------------------------------
%% @doc 	重置所有格子数据
%% @throws 	none
%% @end
%% ----------------------------------
reset_all_grid_data() ->
    lists:foreach(
        fun(GridId) ->
            ?eraseModDict(GridId)
        end,
        lists:seq(1, ?GRID_ROW * ?GRID_COL)
    ),
    lists:foreach(
        fun(GridId) ->
            ?eraseModDict({specialgrid, GridId})
        end,
        lists:seq(1, ?GRID_ROW)
    ),
    ?setModDict(lineSuccessFlag, false),
    ?setModDict(hitSpecialGridIdList, []),
    ?setModDict(hitFGSpecialGridIdList, []).

%%% ----------------------------------
%% @doc     设置保底图示
%% @throws 	none
%% @end
%% ----------------------------------
set_protect_base_kind(BaseKind) ->
    ?setModDict(protect_base_kind, BaseKind).

%% ----------------------------------
%% @doc 	随机生成某个格子上数据
%% @throws 	none
%% @end
%% ----------------------------------
rand_grid_kind(GridId, ExcludeKinds) -> rand_grid_kind(GridId, ExcludeKinds, null).
rand_grid_kind(GridId, ExcludeKinds, PreSetKind) -> rand_grid_kind(GridId, ExcludeKinds, PreSetKind, null).
rand_grid_kind(GridId, ExcludeKinds, PreSetKind, UniversalKindP0) ->
    LaBaId = mod_laba:get_cur_laba_id(),
    #t_laba{
        gold_list = UniversalKindPList
    } = t_laba:get({LaBaId}),

    UniversalKindP =
        if
            UniversalKindP0 /= null -> UniversalKindP0;
            true ->
                Col = mod_laba:get_column_by_grid_id(GridId),
                util_list:opt(Col, UniversalKindPList)
        end,
    %% 概率变成万能图示
    case util_random:p(UniversalKindP) of
        true -> ?UNIVERSAL_KIND;
        false ->
            if
            %% 使用预设图示
                PreSetKind /= null -> PreSetKind;
            %% 随机一种图示
                true ->
                    util_random:get_probability_item([
                        {Kind, Weight} || #t_laba_icon{id = Kind, data = Weight, specialjudge = IsSpecialGridData} <- t_laba_icon@group:get(LaBaId),
                        IsSpecialGridData == 0,
                        not lists:member(Kind, ExcludeKinds)
                    ])
            end
    end.

rand_special_grid_kind(GridId) ->
    LaBaId = mod_laba:get_cur_laba_id(),
    LineHitSpeGridIdList = ?getModDict(hitSpecialGridIdList),
    LineSuccessFlag = ?getModDict(lineSuccessFlag),
    IsHit = lists:member(GridId, LineHitSpeGridIdList),
    util_random:get_probability_item([
        begin
            case LineSuccessFlag of
                true when IsHit -> {Kind, W1};      %% 连线成功且命中
                true -> {Kind, W2};                 %% 连线成功但未命中
                false -> {Kind, W3}                 %% 连线未成功
            end
        end || #t_laba_icon{id = Kind, specialweight_list = [W1, W2, W3], specialjudge = IsSpecialGridData} <- t_laba_icon@group:get(LaBaId),
        IsSpecialGridData == 1
    ]).

%% ----------------------------------
%% @doc 	尝试初始化未被初始化的格子
%% @throws 	none
%% @end
%% ----------------------------------
try_init_other_grids() -> try_init_other_grids(false).
try_init_other_grids(IsInterrupt) ->
    %% 普通格子
    init_grids_by_column(1, ?GRID_COL, IsInterrupt),
    %% 检查普通格子连线情况
    check_line_result(),
    %% 特殊格子
    lists:foreach(
        fun(SpecialGridId) ->
            case ?getModDict({specialgrid, SpecialGridId}) of
                ?UNDEFINED ->
                    ?setModDict({specialgrid, SpecialGridId}, rand_special_grid_kind(SpecialGridId));
                _ ->
                    noop
            end
        end,
        lists:seq(1, ?IF(?getModDict(freegame_flag), 1, ?GRID_ROW))
    ).

%% ----------------------------------
%% @doc 	按列初始化拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
init_grids_by_column(Col, MaxCol, _IsInterrupt) when Col > MaxCol -> noop;
init_grids_by_column(Col, MaxCol, IsInterrupt) ->
    {ExcludeKinds, UniversalKindP} =
        if
        %% 强制中断连线
            IsInterrupt, Col =:= 3 ->
                {[?getModDict(GridId) || GridId <- mod_laba:get_same_column_grid_id_list(1) ++ mod_laba:get_same_column_grid_id_list(2)], 0};
            IsInterrupt, Col =:= 2 ->
                {[?getModDict(GridId) || GridId <- mod_laba:get_same_column_grid_id_list(1) ++ mod_laba:get_same_column_grid_id_list(3)], 0};
            IsInterrupt, Col =:= 1 ->
                {[?getModDict(GridId) || GridId <- mod_laba:get_same_column_grid_id_list(2) ++ mod_laba:get_same_column_grid_id_list(3)], 0};
            IsInterrupt ->
                {[], 0};
            true ->
                {[], null}
        end,
    lists:map(
        fun(ThisGridId) ->
            case ?getModDict(ThisGridId) of
                ?UNDEFINED ->
                    ?setModDict(ThisGridId, rand_grid_kind(ThisGridId, ExcludeKinds, null, UniversalKindP));
                _ ->
                    noop
            end
        end,
        mod_laba:get_same_column_grid_id_list(Col)
    ),
    init_grids_by_column(Col+1, MaxCol, IsInterrupt).

%% ----------------------------------
%% @doc 	按保底方式初始化拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
init_grids_with_protected(PreSetKind, LineColNum, IsTriggerFreeGame) ->
    %% 随机确定一条保底路线
    LaBaId = mod_laba:get_cur_laba_id(),
    LaBaLineInfoList = t_labaline@group:get(LaBaId),
    LaBaLineInfo = util_random:get_list_random_member(LaBaLineInfoList),

    #t_labaline{
        rowid = SpecialGridId,
        data_list = LineGridIdList
    } = LaBaLineInfo,
    lists:foreach(
        fun(GridId) ->
            CurCol = mod_laba:get_column_by_grid_id(GridId),
            if
                %% 使得保底路线上前LineColNum个图示能够连上
                CurCol =< LineColNum ->
                    ?setModDict(GridId, rand_grid_kind(GridId, [], PreSetKind));
                true ->
                    ?setModDict(GridId, rand_grid_kind(GridId, [PreSetKind]))
            end
        end,
        LineGridIdList
    ),

    if
        %% 使得预埋路线能够命中FreeGame
        IsTriggerFreeGame ->
            ?setModDict({specialgrid, SpecialGridId}, ?FREE_GAME_KIND);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	按当前大盘状态初始化拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
init_grids(?LABA_RESULT_CTRL_1) ->
    LaBaId = mod_laba:get_cur_laba_id(),
    #t_laba{
        laba_freegamenumber_list = LineColNumWeightList
    } = t_laba:assert_get({LaBaId}),
    %% 确定保底线路上连中的图示个数
    LineColNum = util_random:get_probability_item(LineColNumWeightList),
    PreSetKind = util_random:get_probability_item([{Kind, Weight} || #t_laba_icon{id = Kind, data = Weight, specialjudge = IsSpecialGridKind} <- t_laba_icon@group:get(LaBaId), IsSpecialGridKind /= 1]),
    init_grids_with_protected(PreSetKind, LineColNum, true),
    try_init_other_grids();
init_grids(?LABA_RESULT_CTRL_2) ->
    try_init_other_grids();
init_grids(?LABA_RESULT_CTRL_3) ->
    init_grids_by_column(1, ?GRID_COL, true),
    try_init_other_grids();
init_grids(?LABA_RESULT_CTRL_4) ->
    ProtectKind = ?getModDict(protect_base_kind),
    ?t_assert(ProtectKind /= -1),
    ?setModDict(protect_base_kind, -1),
    init_grids_with_protected(ProtectKind, 3, false),
    try_init_other_grids();
init_grids(?LABA_RESULT_CTRL_5) ->
    PreSetLine = ?getModDict(pre_set_line),
    ?t_assert(PreSetLine /= []),
    ?setModDict(pre_set_line, []),
    lists:foldl(
        fun(Tag, {GridId, TagKindMap, ExcludeKinds}) ->
            case lists:keyfind(Tag, 1, TagKindMap) of
                false when Tag =:= 0 ->
                    {GridId + 1, TagKindMap, ExcludeKinds};
                false ->
                    PreSetKind = rand_grid_kind(GridId, ExcludeKinds, null, 0),
                    ?setModDict(GridId, PreSetKind),
                    {GridId + 1, [{Tag, PreSetKind} | TagKindMap], [PreSetKind | ExcludeKinds]};
                {_, PreSetKind} ->
                    ?setModDict(GridId, rand_grid_kind(GridId, ExcludeKinds, PreSetKind)),
                    {GridId + 1, TagKindMap, ExcludeKinds}
            end
        end,
        {1, [], []},
        PreSetLine
    ),
    try_init_other_grids(true).

%% ----------------------------------
%% @doc     获取FreeGame结果及奖励
%% @throws 	none
%% @end
%% ----------------------------------
do_free_game() ->
    FreeGameCount = length(?getModDict(hitFGSpecialGridIdList)),
    case ?getModDict(freegame_flag) of
        true ->
            LaBaId = mod_laba:get_cur_laba_id(),
            #t_laba{
                judgefreegame = FreeGameLaBaId,
                freegamenumber_list = FreeGameTimesList
            } = t_laba:assert_get({LaBaId}),
            #t_laba{
                presetlineid = PreSetLineKey,
                laba_presetline_list = PreSetLineIdList,
                laba_freegameaward_list = AwardPList
            } = t_laba:assert_get({FreeGameLaBaId}),

            mod_laba:set_cur_laba_id(FreeGameLaBaId),                               %% 切换成FreeGame模式拉霸机
            CoinsBet = mod_laba:get_coins_bet(),
            LaBaState = mod_laba:get_laba_state(),
            TotalFreeGameTimes = util_list:opt(FreeGameCount, FreeGameTimesList),   %% FreeGame总回合数
            TotalExpectRewardNum = mod_laba:get_freegame_max_reward_num(),          %% FreeGame所有回合期望总奖励值
            AwardP = util_list:opt(LaBaState, AwardPList),                          %% FreeGame模式中每个回合中奖的概率
%%            ?DEBUG("FreeGame期望总奖励值 ~p, 每个回合中奖概率 ~p", [TotalExpectRewardNum, AwardP]),
            %% 计算FreeGame结果
            {_LeftExpectRewardNum, GridLists, SpecialGridLists, RewardNumList} =
                lists:foldl(
                    fun(LeftTimes, {TmpLeftRewardNum, TmpGridLists, TmpSpecialGridLists, TmpRewardNumList}) ->
                        %% 计算当前回合期望奖励值
                        ThisExpectRewardNum =
                            if
                                %% 最后一个回合，不需要再走中奖概率
                                LeftTimes == 1 ->
                                    if
                                        TmpLeftRewardNum > 0 ->
                                            TmpLeftRewardNum;
                                        true ->
                                            0
                                    end;
                                true ->
                                    case util_random:p(AwardP) of
                                        true ->
                                            floor(TmpLeftRewardNum / LeftTimes * 2 * rand:uniform());
                                        false ->
                                            0
                                    end
                            end,
%%                        ?DEBUG(" FreeGame第~p回合 => 期望奖励值 ~p,", [TotalFreeGameTimes - LeftTimes + 1, ThisExpectRewardNum]),
                        %% 重置格子数据
                        reset_all_grid_data(),
                        if
                        %% 未中奖
                            ThisExpectRewardNum =< 0 ->
%%                                ?DEBUG("第~p回合不中！", [TotalFreeGameTimes - LeftTimes + 1]),
                                init_grids(?LABA_RESULT_CTRL_3);
                        %% 初始预埋路线
                            true ->
                                PreSetLineId = util_list:get_value_from_range_list(floor(ThisExpectRewardNum / CoinsBet * 10000), PreSetLineIdList),
                                #t_labapreset{
                                    presetline_list = PreSetLine
                                } = util_random:get_list_random_member(t_labapreset@group:get({PreSetLineKey, PreSetLineId})),
%%                                ?DEBUG("第~p回合中奖, 预埋线id:~p, 预埋线:~w", [TotalFreeGameTimes - LeftTimes + 1, PreSetLineId, PreSetLine]),
                                ?setModDict(pre_set_line, PreSetLine),
                                init_grids(?LABA_RESULT_CTRL_5)
                        end,
                        ThisGridList = tran_grids(),
                        ThisSpecialGridList = tran_special_grids(),
                        %% 打印拉霸机
                        print_grids(),
                        %% 计算当前回合真实获得奖励数
                        ThisRealRewardNum = laba_spin_one(),
%%                        ?DEBUG("第~p回合真实获得奖励值 ~p", [TotalFreeGameTimes - LeftTimes + 1, ThisRealRewardNum]),
                        {TmpLeftRewardNum - ThisRealRewardNum, [ThisGridList | TmpGridLists], [ThisSpecialGridList | TmpSpecialGridLists], [ThisRealRewardNum | TmpRewardNumList]}
                    end,
                    {TotalExpectRewardNum, [], [], []},
                    lists:seq(TotalFreeGameTimes, 1, -1)
                ),
            {lists:reverse(GridLists), lists:reverse(SpecialGridLists), lists:reverse(RewardNumList)};
        false ->
            {[], [], []}
    end.

%% ----------------------------------
%% @doc 	转动拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
handle_laba_spin(PlayerId,  LaBaId, Cost) ->
    #t_laba{
        consume_list = [CostType, _]
    } = t_laba:assert_get({LaBaId}),
    %% 初始化拉霸机
    init_data(),
    mod_laba:init_laba_grids(PlayerId),
    GridList = tran_grids(),
    SpecialGridList = tran_special_grids(),
    print_grids(),
    %% 计算普通拉霸奖励
    RewardNum0 = laba_spin_one(),
    %% 计算FreeGame结果及奖励
    {FGGridLists, FGSpecialGridLists, FGRewardNumList} = do_free_game(),
    TotalRewardNum = RewardNum0 + lists:sum(FGRewardNumList),
    Tran =
        fun() ->
            if
            %% 记录玩家拉霸连续不中次数
                TotalRewardNum =< 0 ->
                    mod_laba:db_inc_player_laba_missed_times(PlayerId, LaBaId, Cost);
                true ->
                    chat_notice:broadcast_msg_player_laba(PlayerId, CostType, TotalRewardNum),
                    mod_laba:db_clear_player_laba_missed_times(PlayerId, LaBaId, Cost)
            end,
            mod_prop:decrease_player_prop(PlayerId, [{CostType, Cost}], ?LOG_TYPE_LABA),
            mod_award:give(PlayerId, [{CostType, TotalRewardNum}], ?LOG_TYPE_LABA),

            %% 修正拉霸奖池
            db:tran_apply(
                fun() ->
                    %% 修正拉霸奖池
                    mod_laba:adjust_Laba_pool(LaBaId, Cost, TotalRewardNum),
                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_LABA_COUNT, ?CONDITIONS_VALUE_ADD, 1})
                end
            ),
            {ok, GridList, SpecialGridList, RewardNum0, FGGridLists, FGSpecialGridLists, FGRewardNumList}
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	连线拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
laba_spin_one() ->
    LaBaId = mod_laba:get_cur_laba_id(),
    LaBaLineInfoList = t_labaline@group:get(LaBaId),
    FreeGameFlag = ?getModDict(freegame_flag),
    RewardNum =
        lists:foldl(
            fun(LaBaLineInfo, TmpRewardNum) ->
                #t_labaline{
                    rowid = HitSpecialGridId,
                    data_list = LineGridIdList
                } = LaBaLineInfo,
                [LineFirstGridId | LineRestGridIds] = LineGridIdList,
                {LineKind, LineColNum} = calc_line_result(?getModDict(LineFirstGridId), LineRestGridIds, 1, false),
                calc_line_award_num(LineKind, LineColNum, ?IF(FreeGameFlag, 1, HitSpecialGridId)) + TmpRewardNum
            end,
            0,
            LaBaLineInfoList
        ),
    RewardNum.

%% ----------------------------------
%% @doc 	计算连线结果
%% @throws 	none
%% @end
%% ----------------------------------
calc_line_result(Kind, LineGridIdList, ColNum, CheckFlag) when LineGridIdList == []; CheckFlag, ColNum >= 3 ->
    {Kind, ColNum};
calc_line_result(Kind, [HGridId | R], ColNum, CheckFlag) ->
    case ?getModDict(HGridId) of
        Kind ->
            calc_line_result(Kind, R, ColNum+1, CheckFlag);
        OtherKind when Kind =:= ?UNIVERSAL_KIND ->
            calc_line_result(OtherKind, R, ColNum+1, CheckFlag);
        ?UNIVERSAL_KIND ->
            calc_line_result(Kind, R, ColNum+1, CheckFlag);
        _ ->
            {Kind, ColNum}
    end.

%% ----------------------------------
%% @doc 	计算连线奖励数量
%% @throws 	none
%% @end
%% ----------------------------------
calc_line_award_num(LineKind, LineColNum, SpecialGridId) when LineColNum >= 3 ->
	LaBaId = mod_laba:get_cur_laba_id(),
    SpecialGridKind = ?getModDict({specialgrid, SpecialGridId}),
%%    ?DEBUG("calc award, LaBaId:~p, LineKind:~p, LineColNum:~p, SpecialGridId:~p", [LaBaId, LineKind, LineColNum, SpecialGridId]),
    #t_laba_icon{
		data_list = RateList
	} = t_laba_icon@key_index:get({LaBaId, LineKind}),
    #t_laba_icon{
        data_list = SpecialRateList
    } = t_laba_icon@key_index:get({LaBaId, SpecialGridKind}),

    if
    %% 连线成功且命中FreeGame图示，触发FreeGame福利模式
        SpecialGridKind =:= ?FREE_GAME_KIND ->
            handle_hit_free_game(SpecialGridId);
        true ->
            noop
    end,

    Rate = util_list:opt(LineColNum, RateList),
    SpecialRate = util_list:opt(1, SpecialRateList),
    CoinsBet = mod_laba:get_coins_bet(),
    RewardNum = floor(Rate * SpecialRate * CoinsBet / (10000 * 10000)),
    RewardNum;
calc_line_award_num(_, _, _)  ->
    0.

%% ----------------------------------
%% @doc 	处理连线命中FreeGame图示
%% @throws 	none
%% @end
%% ----------------------------------
handle_hit_free_game(SpecialGridId) ->
    OriSpeGridIdList = ?getModDict(hitFGSpecialGridIdList),
    case lists:member(SpecialGridId, OriSpeGridIdList) of
        true -> noop;
        false ->
            ?setModDict(hitFGSpecialGridIdList, [SpecialGridId | OriSpeGridIdList])
    end,
    case ?getModDict(freegame_flag) of
        true -> noop;
        false ->
            ?setModDict(freegame_flag, true)
    end.

%% ----------------------------------
%% @doc 	检查普通格子连线结果
%% @throws 	none
%% @end
%% ----------------------------------
check_line_result() ->
    LaBaId = mod_laba:get_cur_laba_id(),
    LaBaLineInfoList = t_labaline@group:get(LaBaId),
    lists:foreach(
        fun(LaBaLineInfo) ->
            #t_labaline{
                rowid = HitSpecialGridId,
                data_list = LineGridIdList
            } = LaBaLineInfo,
            [LineFirstGridId | LineRestGridIds] = LineGridIdList,
            {_LineKind, LineColNum} = calc_line_result(?getModDict(LineFirstGridId), LineRestGridIds, 1, true),
            if
                LineColNum >= 3 ->
                    ?setModDict(lineSuccessFlag, true),
                    ?setModDict(hitSpecialGridIdList, [?IF(?getModDict(freegame_flag), 1, HitSpecialGridId) | ?getModDict(hitSpecialGridIdList)]);
                true ->
                    noop
            end
        end,
        LaBaLineInfoList
    ).

%% ----------------------------------
%% @doc 	打印拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
print_grids() -> print_grids(tran_grids()).
print_grids(GridResult) ->
    {_, ResStr} =
        lists:foldl(
            fun(GridData, {GridId, Str}) ->
                {
                    GridId + 1,
                    case GridId rem ?GRID_COL of
                        0 ->
                            ThisRow = mod_laba:get_row_by_grid_id(GridId),
                            SpecialGridData = ?IF(?getModDict(freegame_flag), ?getModDict({specialgrid, 1}), ?getModDict({specialgrid, ThisRow})),
                            Str ++ integer_to_list(GridData) ++ "\t| " ++ integer_to_list(SpecialGridData) ++ " |\t\n\t";
                        _ ->
                            Str ++ integer_to_list(GridData) ++ "\t"
                    end
                }
            end,
            {1, ""},
            GridResult
        ),

    ?DEBUG("
	-------------------------
	~s
	-------------------------", [ResStr]).

%% ----------------------------------
%% @doc 	将普通格子数据转成一维数组
%% @throws 	none
%% @end
%% ----------------------------------
tran_grids() ->
    lists:map(
        fun(GridId) ->
            ?getModDict(GridId)
        end,
        lists:seq(1, ?GRID_ROW * ?GRID_COL)
    ).

%% ----------------------------------
%% @doc 	将特殊格子数据转成一维数组
%% @throws 	none
%% @end
%% ----------------------------------
tran_special_grids() ->
    lists:map(
        fun(GridId) ->
            ?getModDict({specialgrid, GridId})
        end,
        lists:seq(1, ?IF(?getModDict(freegame_flag), 1, ?GRID_ROW))
    ).