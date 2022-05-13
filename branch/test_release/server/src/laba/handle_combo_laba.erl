%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%      组合拉霸机
%%% @end
%%% Created : 25. 五月 2021 上午 11:20:42
%%%-------------------------------------------------------------------
-module(handle_combo_laba).
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

-define(FREE_GAME_THRESHOLD, 3).        %% 触发FreeGame福利模式需要同时出现FreeGame图示的个数
-define(GRID_ROW, 3).
-define(GRID_COL, 5).

-record(?MODULE, {
    freegame_flag = false,              %% 是否进入FreeGame模式标志
    freegame_count = 0,                 %% FreeGame图示同时出现个数
    freegame_include_column = false,    %% 指定列中是否存在FreeGame图示标识
    freegame_max_allow_count = 0,       %% 最大允许同时出现FreeGame图示个数
    protect_base_kind = -1,             %% 保底基础图示（促发保底方案时使用）
    pre_set_line = [],                  %% 预埋线（预埋方案时使用）
    force_break_line = false            %% 是否强制中断连线标志
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
    ?setModDict(freegame_count, 0),
    ?setModDict(protect_base_kind, -1),
    ?setModDict(pre_set_line, []),
    ?setModDict(force_break_line, false),
    lists:foreach(
        fun(Col) ->
            ?setModDict({freegame_include_column, Col}, false)
        end,
        lists:seq(1, ?GRID_COL)
    ),
    ok.

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
rand_grid_kind(GridId) -> rand_grid_kind(GridId, []).
rand_grid_kind(GridId, ExcludeKinds) -> rand_grid_kind(GridId, ExcludeKinds, -1).
rand_grid_kind(GridId, ExcludeKinds, PreSetBaseKind) ->
    LaBaId = mod_laba:get_cur_laba_id(),
    #t_laba{
        gold_list = GoldenPList
    } = t_laba:get({LaBaId}),

    Col = (GridId - 1) rem ?GRID_COL + 1,

    BaseKind =
    case PreSetBaseKind of
        -1 ->
            %% 随机获取一个基础图示
            ThisColExitFreeGame = ?getModDict({freegame_include_column, Col}),
            FreeGameFlag = ?getModDict(freegame_flag),
            FreeGameCountLimit = ?getModDict(freegame_count) >= ?getModDict(freegame_max_allow_count),
            KindWeightList =
                if
                % 同一列不重复出现FreeGame图示; 进入过FreeGame模式后不再出FreeGame图示; FreeGame图示个数达到上限后不再出FreeGame图示
                    ThisColExitFreeGame; FreeGameFlag; FreeGameCountLimit ->
                        [{Kind, Weight} || #t_laba_icon{id = Kind, data = Weight} <- t_laba_icon@group:get(LaBaId), Kind /= ?FREE_GAME_KIND, not lists:member(Kind, ExcludeKinds)];
                    true ->
                        [{Kind, Weight} || #t_laba_icon{id = Kind, data = Weight} <- t_laba_icon@group:get(LaBaId), not lists:member(Kind, ExcludeKinds)]
                end,
            util_random:get_probability_item(KindWeightList);
        _ ->
            %% 预设基础图示
            PreSetBaseKind
    end,

    if
        BaseKind == ?FREE_GAME_KIND ->
            ?incrModDict(freegame_count),
            ?setModDict({freegame_include_column, Col}, true),
            BaseKind;
        true ->
            GoldenP = util_list:opt(Col, GoldenPList),
            case util_random:p(GoldenP) of
                %% 升级为金色边框图示
                true -> BaseKind + 100;
                false -> BaseKind
            end
    end.

%% ----------------------------------
%% @doc 	按列初始化拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
init_grids_by_column(Col, MustFreeGameCols, ExcludeKinds) ->
    SameColGridIds = mod_laba:get_same_column_grid_id_list(Col),
    IsMustIncludeFreeGame = lists:member(Col, MustFreeGameCols),

    FreeGameGridId =
    if
        % 列中随机一个格子存放FreeGame图示
        IsMustIncludeFreeGame ->
            ?setModDict({freegame_include_column, Col}, true),
            util_random:get_list_random_member(SameColGridIds);
        true ->
            -1

    end,
    lists:map(
        fun(ThisGridId) ->
            if
                ThisGridId =:= FreeGameGridId ->
                    ?setModDict(ThisGridId, ?FREE_GAME_KIND);
                true ->
                    Kind = rand_grid_kind(ThisGridId, ExcludeKinds),
                    ?setModDict(ThisGridId, Kind)
            end
        end,
        SameColGridIds
    ).

%% ----------------------------------
%% @doc 	按列初始化拉霸机2
%% @throws 	none
%% @end
%% ----------------------------------
init_grids_by_column2(Col, MustBaseKind) ->
    SameColGridIds = mod_laba:get_same_column_grid_id_list(Col),

    GridId =
        if
            % 当前列中必出MustBaseKind图示
            MustBaseKind /= -1 ->
                util_random:get_list_random_member(SameColGridIds);
            true ->
                -1
        end,
    lists:map(
        fun(ThisGridId) ->
            if
                ThisGridId =:= GridId ->
                    ?setModDict(ThisGridId, rand_grid_kind(GridId, [], MustBaseKind));
                true ->
                    Kind = rand_grid_kind(ThisGridId),
                    ?setModDict(ThisGridId, Kind)
            end
        end,
        SameColGridIds
    ).

%% ----------------------------------
%% @doc 	按行初始化拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
init_grids_by_row() ->
    lists:map(
        fun(GridId) ->
            Kind = rand_grid_kind(GridId),
            ?setModDict(GridId, Kind),
            Kind
        end,
        lists:seq(1, ?GRID_ROW * ?GRID_COL)
    ).

%% ----------------------------------
%% @doc 	按当前大盘状态初始化拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
init_grids(?LABA_RESULT_CTRL_1) ->
    %% 必出FreeGame图示个数
    LaBaId = mod_laba:get_cur_laba_id(),
    #t_laba{
        laba_freegamenumber_list = FreeGameCountWeightList
    } = t_laba:assert_get({LaBaId}),
    MustFreeGameCount = util_random:get_probability_item(FreeGameCountWeightList),
    MaxAllowFreeGameCount = MustFreeGameCount,
    ?setModDict(freegame_count, MustFreeGameCount),
    ?setModDict(freegame_max_allow_count, MaxAllowFreeGameCount),
    MustFreeGameCols = lists:sublist(util_list:shuffle(lists:seq(1, ?GRID_COL)), MustFreeGameCount),
    lists:foreach(
        fun(ThisCol) ->
            init_grids_by_column(ThisCol, MustFreeGameCols, [])
        end,
        lists:seq(1, ?GRID_COL)
    );
init_grids(?LABA_RESULT_CTRL_2) ->
    ?setModDict(freegame_max_allow_count, ?FREE_GAME_THRESHOLD - 1),
    init_grids_by_row();
init_grids(?LABA_RESULT_CTRL_3) ->
    ?setModDict(freegame_max_allow_count, ?FREE_GAME_THRESHOLD - 1),
    MustFreeGameCols = [],
    %% 第一列有的图示不出现在第二列中
    FirstColKinds = init_grids_by_column(1, MustFreeGameCols, []) -- [?FREE_GAME_KIND],
    lists:foreach(
        fun(ThisCol) ->
            ExcludeKinds = ?IF(ThisCol == 2, FirstColKinds, []),
            init_grids_by_column(ThisCol, MustFreeGameCols, ExcludeKinds)
        end,
        lists:seq(2, ?GRID_COL)
    );
init_grids(?LABA_RESULT_CTRL_4) ->
    ProtectBaseKind = ?getModDict(protect_base_kind),
    ?t_assert(ProtectBaseKind /= -1),
    ?setModDict(protect_base_kind, -1),
    ?setModDict(freegame_max_allow_count, ?FREE_GAME_THRESHOLD - 1),
    MustFreeGameCols = [],
    %% 前三列必出保底图示
    lists:foreach(
        fun(ThisCol) ->
            init_grids_by_column2(ThisCol, ProtectBaseKind)
        end,
        lists:seq(1, 3)
    ),
    lists:foreach(
        fun(ThisCol) ->
            ExcludeKinds = ?IF(ThisCol == 4, [ProtectBaseKind], []),
            init_grids_by_column(ThisCol, MustFreeGameCols, ExcludeKinds)
        end,
        lists:seq(4, ?GRID_COL)
    );
init_grids(?LABA_RESULT_CTRL_5) ->
    PreSetLine = ?getModDict(pre_set_line),
    ?t_assert(PreSetLine /= []),
    ?setModDict(pre_set_line, []),
    LaBaId = mod_laba:get_cur_laba_id(),
    %% 预埋两种图示
    PreSetBaseKindA = util_random:get_probability_item([{Kind, Weight} || #t_laba_icon{id = Kind, data = Weight} <- t_laba_icon@group:get(LaBaId), Kind /= ?FREE_GAME_KIND]),
    PreSetBaseKindB = util_random:get_probability_item([{Kind, Weight} || #t_laba_icon{id = Kind, data = Weight} <- t_laba_icon@group:get(LaBaId), Kind /= ?FREE_GAME_KIND, Kind /= PreSetBaseKindA]),
    lists:foldl(
        fun(Tag, TmpGridId) ->
            case Tag of
                1 -> ?setModDict(TmpGridId, rand_grid_kind(TmpGridId, [], PreSetBaseKindA));
                2 -> ?setModDict(TmpGridId, rand_grid_kind(TmpGridId, [], PreSetBaseKindB));
                0 -> ?setModDict(TmpGridId, rand_grid_kind(TmpGridId, [PreSetBaseKindA, PreSetBaseKindB]))
            end,
            TmpGridId + 1
        end,
        1,
        PreSetLine
    ).

%% ----------------------------------
%% @doc     获取FreeGame结果及奖励
%% @throws 	none
%% @end
%% ----------------------------------
do_free_game() ->
    case ?getModDict(freegame_count) of
        FreeGameCount when FreeGameCount >= ?FREE_GAME_THRESHOLD ->
            LaBaId = mod_laba:get_cur_laba_id(),
            #t_laba{
                judgefreegame = FreeGameLaBaId,
                freegamenumber_list = FreeGameTimesList
            } = t_laba:assert_get({LaBaId}),
            #t_laba{
                presetlineid = PreSetLineKey,
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
            {_LeftExpectRewardNum, FreeGameResults, RewardNumLists} =
                lists:foldl(
                    fun(LeftTimes, {TmpLeftRewardNum, TmpFreeGameResults, TmpRewardNumLists}) ->
                        ?setModDict(force_break_line, false),
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
                        if
                            %% 未中奖
                            ThisExpectRewardNum =< 0 ->
%%                                ?DEBUG("第~p回合不中！", [TotalFreeGameTimes - LeftTimes + 1]),
                                init_grids(?LABA_RESULT_CTRL_3);
                            true ->
                                %% 通过预埋线路初始化拉霸机
                                PreSetLineId = util_list:get_value_from_range_list(floor(ThisExpectRewardNum / CoinsBet * 10000), ?SD_LABA_PRESETLINE),
                                #t_labapreset{
                                    presetline_list = PreSetLine
                                } = util_random:get_list_random_member(t_labapreset@group:get({PreSetLineKey, PreSetLineId})),
                                ?setModDict(pre_set_line, PreSetLine),
                                init_grids(?LABA_RESULT_CTRL_5)
                        end,
                        %% 打印拉霸机
%%                        print_grids(),
                        InitFreeGameGridList = tran_grids(),
                        {GridLists, RewardNumList} = laba_spin_one([InitFreeGameGridList], [], 0, ThisExpectRewardNum),
                        %% 计算当前回合真实获得奖励数
                        ThisRealRewardNum = lists:sum(RewardNumList),
%%                        ?DEBUG("第~p回合真实获得奖励值 ~p, 奖励详情列表 ~w", [TotalFreeGameTimes - LeftTimes + 1, ThisRealRewardNum, RewardNumList]),
                        {TmpLeftRewardNum - ThisRealRewardNum, [GridLists | TmpFreeGameResults], [RewardNumList | TmpRewardNumLists]}
                    end,
                    {TotalExpectRewardNum, [], []},
                    lists:seq(TotalFreeGameTimes, 1, -1)
                ),

            {lists:reverse(FreeGameResults), lists:reverse(RewardNumLists)};
        _ ->
            {[], []}
    end.

%% ----------------------------------
%% @doc 	转动拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
handle_laba_spin(PlayerId, LaBaId, Cost) ->
    #t_laba{
        consume_list = [CostType, _]
    } = t_laba:assert_get({LaBaId}),
    %% 初始化拉霸机
    init_data(),
    mod_laba:init_laba_grids(PlayerId),
    InitGridList = tran_grids(),
    print_grids(),

    %% 计算普通拉霸结果及奖励
    {GridLists, RewardNumList} = laba_spin_one([InitGridList], [], 0, -1),
    %% 计算FreeGame结果及奖励
    {FreeGameResults, FreeGameRewardNumLists} = do_free_game(),
    Tran =
        fun() ->
            TotalRewardNum = lists:sum(RewardNumList ++ lists:merge(FreeGameRewardNumLists)),
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

            db:tran_apply(
                fun() ->
                    %% 修正拉霸奖池
                    mod_laba:adjust_Laba_pool(LaBaId, Cost, TotalRewardNum),
                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_LABA_COUNT, ?CONDITIONS_VALUE_ADD, 1})
                end
            ),
            {ok, GridLists, RewardNumList, FreeGameResults, FreeGameRewardNumLists}
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	百搭拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
laba_spin_one(GridLists, RewardNumList, TotalRewardNum, MaxRewardNum) ->
    %% 尝试判断是否触发FreeGame游戏福利
    try_check_free_game(),

    %% 第一列按照图示类别分组
    FirstColGridIds = mod_laba:get_same_column_grid_id_list(1),
    KindList =
        lists:foldl(
            fun(GridId, TempList) ->
                ThisKind = ?getModDict(GridId),
                util_list:key_insert({ThisKind, GridId}, TempList)
            end,
            [], FirstColGridIds),

    %% 每组分别从左往右连线，计算连线获得的奖励
    {RewardNum, ClearGridIdList} =
        lists:foldl(
            fun({ThisKind, GridIdList}, {TmpRewardNum, TmpClearGridIdList}) ->
                if
                    %% FreeGame图示不参与连线
                    ThisKind == ?FREE_GAME_KIND ->
                        {TmpRewardNum, TmpClearGridIdList};
                    true ->
                        {ThisRewardNum, ThisClearGridIdList} = calc_combo_result(2, ThisKind, length(GridIdList), GridIdList),
                        {TmpRewardNum + ThisRewardNum, lists:umerge([TmpClearGridIdList, ThisClearGridIdList])}
                end
            end,
            {0, []}, KindList),

    if
        %% 当前回合玩家获得奖励已经达到期望奖励上限，标记需要强制中断连线
        MaxRewardNum /= -1, TotalRewardNum + RewardNum >= MaxRewardNum ->
            case ?getModDict(force_break_line) of
                false ->
%%                    ?DEBUG("当前总奖励 ~p, 允许最大奖励 ~p ==> 标记需要强制中断连线!!", [TotalRewardNum + RewardNum, MaxRewardNum]),
                    ?setModDict(force_break_line, true);
                true ->
                    noop
            end;
        true ->
            noop
    end,

    %% 重置格子数据
    case try_reset_all_grids(ClearGridIdList) of
        true ->
            GridResult = tran_grids(),
            print_grids(),
            laba_spin_one([GridResult | GridLists], [RewardNum | RewardNumList], TotalRewardNum + RewardNum, MaxRewardNum);
        false ->
            {lists:reverse(GridLists), lists:reverse(RewardNumList)}
    end.

%% ----------------------------------
%% @doc 	按kind类型从左往右连接图示
%% @throws 	none
%% @end
%% ----------------------------------
calc_combo_result(CurCol, Kind, Lines, ClearGridIdList0) ->
    case CurCol > ?GRID_COL of
        true ->
            {calc_combo_award_num(Kind, CurCol - 1, Lines), ClearGridIdList0};
        false ->
            ?t_assert(Kind /= ?UNIVERSAL_KIND),
            %% 统计当前列中与Kind相同的图示个数
            ColGridIds = mod_laba:get_same_column_grid_id_list(CurCol),
            {Count, ClearGridIdList} =
                lists:foldl(
                    fun(ThisGridId, {TmpCount, TmpClearGridIdList}) ->
                        ThisGridKind = ?getModDict(ThisGridId),
                        if
                        %% 遇到相同图示或者万能图示，标记当前格子需要被消除
                            ThisGridKind =:= Kind; ThisGridKind =:= ?UNIVERSAL_KIND ->
                                {TmpCount + 1, [ThisGridId | TmpClearGridIdList]};
                        %% 遇到金色边框的图示或者本身是金色边框的图示
                            ThisGridKind - 100 =:= Kind; ThisGridKind + 100 =:= Kind ->
                                {TmpCount + 1, [ThisGridId | TmpClearGridIdList]};
                            true ->
                                {TmpCount, TmpClearGridIdList}
                        end
                    end,
                    {0, ClearGridIdList0}, ColGridIds),

            %%    ?DEBUG("Kind ~p, CurCol ~p, Count ~p~n", [Kind, CurCol, Count]),
            if
            %% 连接中断
                Count == 0 ->
                    %% 判断连接是否成功
                    case CurCol > 3 of
                        true ->
                            {calc_combo_award_num(Kind, CurCol - 1, Lines), ClearGridIdList};
                        false ->
                            {0, []}
                    end;
            %% 继续向右连接
                true ->
                    calc_combo_result(CurCol+1, Kind, Lines*Count, ClearGridIdList)
            end
    end.

%% ----------------------------------
%% @doc 	计算连接某个图示获得的奖励数量
%% @throws 	none
%% @end
%% ----------------------------------
calc_combo_award_num(Kind, ColCount, Lines) ->
	LaBaId = mod_laba:get_cur_laba_id(),
	#t_laba_icon{
		data_list = RateList
	} = t_laba_icon@key_index:get({LaBaId, Kind}),

    Rate = util_list:opt(ColCount, RateList),
    CoinsBet = mod_laba:get_coins_bet(),
    RewardNum = floor(Rate * Lines * CoinsBet / 10000),
    RewardNum.

%% ----------------------------------
%% @doc 	尝试判断是否触发FreeGame游戏福利
%% @throws 	none
%% @end
%% ----------------------------------
try_check_free_game() ->
    case ?getModDict(freegame_flag) of
        true -> noop;
        false ->
            FreeGameCount = ?getModDict(freegame_count),
            if
                FreeGameCount >= ?FREE_GAME_THRESHOLD ->
                    ?setModDict(freegame_flag, true);
                true ->
                    noop
            end
    end.

%% ----------------------------------
%% @doc 	尝试重置所有格子数据
%% @throws 	none
%% @end
%% ----------------------------------
try_reset_all_grids([]) -> false;
try_reset_all_grids(ClearGridIdList) ->
    lists:foreach(
        fun(GridId) ->
            Kind = ?getModDict(GridId),
            case Kind == 0 orelse lists:member(GridId, ClearGridIdList) of
                %% 带金色框的图示被消除后升级为万能图示
                true when Kind > 100 ->
                    ?setModDict(GridId, ?UNIVERSAL_KIND);
                true ->
                    put_grid(GridId, GridId-?GRID_COL, ClearGridIdList);
                false ->
                    noop
            end
        end,
        lists:reverse(lists:seq(1, ?GRID_ROW * ?GRID_COL))
    ),
    true.

%% ----------------------------------
%% @doc 	重置某个格子上的数据
%% @throws 	none
%% @end
%% ----------------------------------
put_grid(GridId, TopGridId, _ClearGridIdList) when TopGridId < 1 ->
    ForceBreakLine = ?getModDict(force_break_line),
    ExcludeKinds =
    if
        %% 需要强制中断连线
        ForceBreakLine -> get_grid_exclude_kinds(GridId);
        true -> []
    end,
    %% 重新为格子生成新的图示
    ?setModDict(GridId, rand_grid_kind(GridId, ExcludeKinds));
put_grid(GridId, TopGridId, ClearGridIdList) ->
    TopGridKind = ?getModDict(TopGridId),
    if
        %% 顶上一格格子图示为空，继续往上找
        TopGridKind == 0 ->
            put_grid(GridId, TopGridId - ?GRID_COL, ClearGridIdList);
        true ->
            case lists:member(TopGridId, ClearGridIdList) of
                %% 顶上的格子图示正常掉落
                false ->
                    ?setModDict(GridId, TopGridKind),
                    ?setModDict(TopGridId, 0);
                %% 顶上带金框格子的图示变成万能图示后掉落
                true when TopGridKind > 100 ->
                    ?setModDict(GridId, ?UNIVERSAL_KIND),
                    ?setModDict(TopGridId, 0);
                true ->
                    put_grid(GridId, TopGridId - ?GRID_COL, ClearGridIdList)
            end
    end.

get_grid_exclude_kinds(GridId) ->
    FirstColGridIds = mod_laba:get_same_column_grid_id_list(1),
    SecondColGridIds = mod_laba:get_same_column_grid_id_list(2),
    ThirdColGridIds = mod_laba:get_same_column_grid_id_list(3),
    Func =
        fun(GridIds) ->
            [begin
                 Kind = ?getModDict(TempGridId),
                 ?IF(Kind > 100, Kind - 100, Kind)
             end || TempGridId <- GridIds]
        end,
    case lists:member(GridId, FirstColGridIds) of
        true ->
            Func(SecondColGridIds);
        false ->
            case lists:member(GridId, SecondColGridIds) of
                true ->
                    Func(FirstColGridIds);
                false ->
                    case lists:member(GridId, ThirdColGridIds) of
                        true ->
                            Func(SecondColGridIds);
                        false ->
                            []
                    end
            end
    end.

%% ----------------------------------
%% @doc 	打印拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
print_grids() -> print_grids(tran_grids()).
print_grids(GridResult) ->
    {_, ResStr} =
        lists:foldl(
            fun(GridVal, {GridId, Str}) ->
                {
                    GridId + 1,
                    case (GridId + 1) rem ?GRID_COL of
                        0 -> Str ++ integer_to_list(GridVal) ++ "\t\n\t";
                        _ -> Str ++ integer_to_list(GridVal) ++ "\t"
                    end
                }
            end,
            {0, ""}, GridResult),

    ?DEBUG("
	-------------------------
	~s
	-------------------------", [ResStr]).

%% ----------------------------------
%% @doc 	将所有格子数据转成一维数组
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