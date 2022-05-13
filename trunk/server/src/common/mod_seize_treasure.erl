%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 5月 2021 上午 11:45:46
%%%-------------------------------------------------------------------
-module(mod_seize_treasure).
-author("Administrator").

%% API
-export([
    seize_type/0,                       %% 获取今日夺宝转盘类型 (treasure_hunt_type.csv表的id字段)
    seize/3,                            %% 玩家发起夺宝抽奖
    extra_award/2,                      %% 玩家领取夺宝转盘额外奖励
    get_seize_extra_award_status/1,     %% 查询指定玩家的夺宝转盘额外奖励的状态
    get_player_seize_times/1 %% 每周玩家首次登录时，清空其累计夺宝次数
]).
-export([
]).

-include("common.hrl").
-include("gen/table_db.hrl").
-include("p_message.hrl").
-include("gen/db.hrl").
-include("player_game_data.hrl").
-include("gen/table_enum.hrl").
-include("error.hrl").

%% @doc 获取今日的夺宝转盘类型
seize_type() ->
    SeizeTypeList =
        lists:filtermap(
            fun ([YyyyMm, Type]) ->
                MatchTargetYearNMouth = util:to_list(YyyyMm),
                {MatchYear, MatchMouth, _} = util_time:local_date(),
                MatchMouth2Str = util:to_list(MatchMouth),
                MatchYearMouth = util:to_list(MatchYear) ++ ?IF(MatchMouth2Str > 1, MatchMouth2Str, "0" ++ MatchMouth2Str),
                ?IF(MatchTargetYearNMouth =:= MatchYearMouth, {true, Type}, false)
            end,
            ?SD_TREASURE_HUNT_TYPE_LIST
        ),
%%    ?DEBUG("今日夺宝转盘类型: ~p", [SeizeTypeList]),
    ?IF(length(SeizeTypeList) =/= 1, 1, hd(SeizeTypeList)).

%% @doc 玩家发起夺宝抽奖
seize(PlayerId, TreasureHuntTypeId, Type) ->
%%    ?DEBUG("params: ~p ~p ~p", [PlayerId, TreasureHuntTypeId, Type]),
    chk_platform_valid(mod_server_config:get_platform_id()),
    %% 上次夺宝完成后的幸运值
    LuckValueBeforeSeize = get_currency_luck_value_by_player(PlayerId),

    %% 获取本次夺宝后，参与夺宝的玩家可得的
    %% 夺宝次数、幸运值、所消耗的道具编号、所消耗的道具数量，所增加的幸运值，幸运值达标所得额外奖励道具编号、数量
    {Times, LuckValue2Db, CostItemId, CostNum, ExtraAwardItemId, ExtraAwardNum} =
        get_seize_cost_n_extra_award(TreasureHuntTypeId, Type, LuckValueBeforeSeize),
    R = mod_prop:assert_prop_num(PlayerId, CostItemId, CostNum),

    SeizeTimes2Db = get_latest_seize_times_by_player(PlayerId, ?TRUE, Times),
    ?INFO("SeizeTimes2Db: ~p, LuckValue2Db: ~p", [SeizeTimes2Db, LuckValue2Db]),

    %% 获取本次夺宝物品的元组列表[{{物品编号1，数量1}, 权重1}, {{物品编号2，数量2}, 权重2}, {...}, ...]
    ValidSeizeTreasureTupleList = get_valid_seize_treasure_list(TreasureHuntTypeId, LuckValueBeforeSeize),

    %% 事务：抽奖+扣除物品数量+增加对应物品数量
    case catch seize_treasure(PlayerId, CostItemId, CostNum, LuckValue2Db, SeizeTimes2Db,
        ExtraAwardItemId, ExtraAwardNum, ValidSeizeTreasureTupleList, Times) of
%%        {ok, {TreasureId, Numbers}} ->
%%            {[#prop{prop_id = TreasureId, num = Numbers}], SeizeTimes2Db, LuckValue2Db};
        {ok, TreasureList} ->
            PropList =
                lists:foldl(
                    fun({TreasureId, Numbers}, Tmp) ->
                        [#prop{prop_id = TreasureId, num = Numbers} | Tmp]
                    end,
                    [],
                    TreasureList
                ),
            PosList =
                lists:foldl(
                    fun({TreasureId, Numbers}, Tmp) ->
%%                        ?DEBUG("pos: ~p", [logic_get_seize_treasure_id_by_award_list:get({TreasureId, Numbers, TreasureHuntTypeId})]),
                        case logic_get_seize_treasure_id_by_award_list:get({TreasureId, Numbers, TreasureHuntTypeId}) of
                            Pos when is_integer(Pos) -> [util:to_list(Pos) | Tmp];
                            _ -> Tmp
                        end
                    end,
                    [],
                    TreasureList
                ),
            {PropList, SeizeTimes2Db, LuckValue2Db, PosList};
        {'EXIT', R} -> exit(R);
        O ->
            ?ERROR("非预期结果: ~p", [O]),
            exit(unknown)
    end.

get_player_seize_times(PlayerId) ->
    flush_seize_times_first_login_per_week(PlayerId).

flush_seize_times_first_login_per_week(PlayerId) ->
    ?DEBUG("flush_seize_times_first_login_per_week: ~p in ~p", [PlayerId, util_time:is_this_week(util_time:timestamp())]),
    SeizeExtraAwardTimeList = [Timestamp || {_, Timestamp} <- get_old_extra_award(PlayerId)],
    if
        SeizeExtraAwardTimeList =:= [] -> ok;
        true ->
            case util_time:is_this_week(lists:max(SeizeExtraAwardTimeList)) of
                false ->
                    Fun =
                        fun() ->
                            mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_ACHIEVEMENT,
                                util_string:term_to_string([])),
                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_TIMES, 0)
%%                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_LUCK_VALUE, 0)
                        end,
                    R = db:do(Fun),
                    ?DEBUG("RRR: ~p", [R]),
                    R;
                true -> ok
            end
    end.

%% @doc 玩家领取夺宝抽奖额外奖励
extra_award(PlayerId, Pos) ->
    TreasureHuntTypeId = 1,
    %% 读取指定玩家的夺宝转盘次数
    SeizeTimes = get_latest_seize_times_by_player(PlayerId, ?FALSE, 0),
    %% 读取指定玩家的已经领取的额外奖励数据 [{夺宝转盘次数1, 领取奖励的时间戳1}, {...}, ...]
    AlreadyGetTimesTupleList = get_old_extra_award(PlayerId),
%%    ?DEBUG("AlreadyGetTimesTupleList: ~p", [AlreadyGetTimesTupleList]),
    %% 读取指定夺宝转盘类型，指定额外奖励下标所对应的奖励数据
    {Times, AwardList} = get_seize_extra_award_list(TreasureHuntTypeId, Pos),
%%    ?DEBUG("Wait4Get: ~p ~p ~p ~p", [Times, AwardList, SeizeTimes >= Times, SeizeTimes < Times orelse lists:keyfind(Times, 1, AlreadyGetTimesTupleList) =/= false]),

    %% 判断当前玩家已达成的夺宝转盘次数是否符合领取额外奖励的条件
    ?ASSERT(SeizeTimes >= Times, no_enough_seize_times),
    %% 判断指定额外奖励是否已经被当前玩家领取
    ?ASSERT(SeizeTimes >= Times andalso lists:keyfind(Times, 1, AlreadyGetTimesTupleList) =:= false, already_get),
    %% 判断额外奖励是否是一个长度大于0的数组
    ?ASSERT(is_list(AwardList) andalso length(AwardList) > 0, no_achievement_wait_4_get),

    %% 发放奖励
    Fun =
        fun() ->
            mod_player_game_data:set_str_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_ACHIEVEMENT,
                util_string:term_to_string([{Times, util_time:timestamp()} | AlreadyGetTimesTupleList])),
            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_SEIZE_EXTRA_AWARD)
        end,
    R = db:do(Fun),
    ?INFO("doResult: ~p", [R]),

    {SeizeTimes, lists:foldl(
        fun([PropId, PropNum], Tmp) ->
            [#prop{prop_id = PropId, num = PropNum} | Tmp]
        end,
        [],
        AwardList
    )}.

%% @doc 查询指定玩家的夺宝转盘额外奖励的状态
get_seize_extra_award_status(PlayerId) ->
    %% 静态表配置的今日夺宝类型编号
    TreasureHuntTypeId = mod_seize_treasure:seize_type(),
    %% 读取指定玩家的夺宝转盘次数
    SeizeTimes = get_latest_seize_times_by_player(PlayerId, ?FALSE, 0),
    %% 读取指定玩家已经领取的夺宝转盘额外奖励数据
    AlreadyGetTimesTupleList = get_old_extra_award(PlayerId),
    case t_treasure_hunt_type:get({TreasureHuntTypeId}) of
        TreasureHuntTypeInCsv when is_record(TreasureHuntTypeInCsv, t_treasure_hunt_type) ->
            #t_treasure_hunt_type{
                achievement_list = AchievementList
            } = TreasureHuntTypeInCsv,
%%            ?DEBUG("AchievementList: ~p", [AchievementList]),
            ReturnList =
                lists:foldl(
                    fun([Times, _], Tmp) ->
                        DoseGet = ?IF(AlreadyGetTimesTupleList =:= [], 0,
                            ?IF(is_tuple(lists:keyfind(Times, 1, AlreadyGetTimesTupleList)) =:= true, 1,
                                ?IF(SeizeTimes >= Times, 2, 0))),
                        [util:to_list(DoseGet) | Tmp]
                    end, [], AchievementList
                ),
            lists:reverse(ReturnList);
        null -> exit(not_exists);
        R -> ?ERROR("非预期结果: ~p", [R]), exit(unknown)
    end.

%% ------------------------------------------------- 私有方法 -----------------------------------------------------------
%% @doc 判断指定平台下的玩家是否有权参与夺宝
chk_platform_valid(PlatformId) ->
    #t_function{
        not_have_pf_list = InvalidPlatformList,
        have_pf_list = ValidPlatformList
%%        activate_condition_list = ActivateConditionList
    } = t_function:get({900}),
%%    ?DEBUG("ValidPlatformList: ~p", [ValidPlatformList]),
    PlatformIsValid =
        if
            ValidPlatformList =/= 1 ->
                MatchPlatformList =
                    lists:filtermap(
                        fun(PlatformInList) -> ?IF(PlatformId =:= PlatformInList, {true, PlatformInList}, false) end,
                        InvalidPlatformList
                    ),
                length(MatchPlatformList);
            true -> ?TRUE
        end,
    ?ASSERT(PlatformIsValid =:= ?TRUE, invalid_platform).

%% @doc 根据当前参与夺宝的玩家、指定夺宝类型 获取 本次夺宝后玩家的幸运值、消耗的道具、数量和幸运值达标时的额外奖励
get_seize_cost_n_extra_award(TreasureHuntTypeId, Type, CurrencyLuckValue) ->
    case t_treasure_hunt_type:get({TreasureHuntTypeId}) of
        TreasureHuntTypeInCsv when is_record(TreasureHuntTypeInCsv, t_treasure_hunt_type) ->
            #t_treasure_hunt_type{
%%                cost_once_list = [CostItemId, Num],
%%                cost_fivetimes_list = [CostItemId5Times, Num5Times],
                luck_list = LuckList
            } = TreasureHuntTypeInCsv,
            {Times, ItemId, TimesNum} = logic_get_seize_treasure_cost_list_by_pos:get({TreasureHuntTypeId, Type}),
%%            {ItemId, TimesNum} =
%%                case Type of
%%                    1 -> {CostItemId, Num};
%%                    2 -> {CostItemId5Times, Num5Times}
%%                end,
            ?INFO("本次夺宝后，玩家抽~p次,得消耗~p个编号为~p的道具", [Times, TimesNum, ItemId]),
            {SingleLuckValueIncr, MaxLuckValue, ExtraAwardItemId} =
                case LuckList of
                    Res when is_list(Res) andalso length(Res) =:= 3 ->
                        [SingleLuckValueIncrInCsv, MaxLuckValueInCsv, AwardIdInCsv] = Res,
                        {SingleLuckValueIncrInCsv, MaxLuckValueInCsv, AwardIdInCsv};
                    OtherOfLuckList -> ?ERROR("非预期luck_list的值: ~p", [OtherOfLuckList]), {0, 0, 0}
                end,

            ?INFO("SingleLuckValueIncr ~p, MaxLuckValue ~p, ExtraAwardItemId ~p",
                [SingleLuckValueIncr, MaxLuckValue, ExtraAwardItemId]),
            ?DEBUG("t_treasure_hunt:get(): ~p", [t_treasure_hunt:get({Type + 1, ExtraAwardItemId})]),
            %% 给指定玩家修改夺宝幸运值数据到db中
%%            NewLuckValue = (TimesNum * SingleLuckValueIncr) + CurrencyLuckValue,
            NewLuckValue = Times + CurrencyLuckValue,
            ?INFO("每消耗一个~p的道具可得~p幸运值.本次夺宝前玩家幸运值：~p.夺宝后幸运值：~p.",
                [ItemId, SingleLuckValueIncr, CurrencyLuckValue, NewLuckValue]),

            {RealLuckValue, DoesGetExtraAward} = ?IF(NewLuckValue >= MaxLuckValue,
                {NewLuckValue - MaxLuckValue, ?TRUE}, {NewLuckValue, ?FALSE}),
            ?DEBUG("ddd: ~p", [{RealLuckValue, DoesGetExtraAward}]),
            {ExtraAwardId, ExtraAwardNum} =
                if
                    DoesGetExtraAward =:= ?TRUE ->
                        case t_treasure_hunt:get({Type + 1, ExtraAwardItemId}) of
                            ExtraAwardInfoInCsv when is_record(ExtraAwardInfoInCsv, t_treasure_hunt) ->
                                #t_treasure_hunt{
                                    award_list = [[ExtraAwardIdInCsv, ExtraAwardNumInCsv]]   %% [[101,1]]
                                } = ExtraAwardInfoInCsv,
                                {ExtraAwardIdInCsv, ExtraAwardNumInCsv};
                            null -> ?INFO("该玩家所得额外奖励在treasure_hunt.csv中没找到"), {0, 0};
                            Other -> ?ERROR("非预期夺宝额外奖励的结果：~p", [Other]), {0, 0}
                        end;
                    true -> ?INFO("该玩家不能获得额外奖励"), {0, 0}
                end,
            ?INFO("本次夺宝后，玩家的幸运值：~p, 额外获得: ~p个编号为~p的道具", [RealLuckValue, ExtraAwardId, ExtraAwardNum]),
            {Times, RealLuckValue, ItemId, TimesNum, ExtraAwardId, ExtraAwardNum};
        null ->
            ?INFO("没有配置id为~p的类型为~p的treasure_hunt_type.csv的记录"),
            {0, 0, 0, 0, 0, 0};
        OtherOfTreasureHuntType ->
            ?INFO("非预期的获取指定夺宝类型数据的结果: ~p", [OtherOfTreasureHuntType]),
            {0, 0, 0, 0, 0, 0}
    end.

%% @doc 获取指定玩家(玩家编号)的当前夺宝幸运值
get_currency_luck_value_by_player(PlayerId) ->
    case db:read(#key_player_game_data{player_id = PlayerId, data_id = ?PLAYER_GAME_DATA_SEIZE_LUCK_VALUE}) of
        LuckValue when is_record(LuckValue, db_player_game_data) ->
            #db_player_game_data{
                int_data = CurrencyLuckValueInDb
            } = LuckValue,
            CurrencyLuckValueInDb;
        null -> ?INFO("玩家在player_game_data表中没有夺宝幸运值的记录"), 0;
        OtherOfLuckValue -> ?ERROR("非预期夺宝幸运值结果: ~p", [OtherOfLuckValue]), 0
    end.

%% @doc 获取指定玩家夺宝前、夺宝后的夺宝次数
get_latest_seize_times_by_player(PlayerId, AfterSeize, Increment) ->
    SeizeTimes =
        case db:read(#key_player_game_data{player_id = PlayerId, data_id = ?PLAYER_GAME_DATA_SEIZE_TIMES}) of
            TimesRecord when is_record(TimesRecord, db_player_game_data) ->
                #db_player_game_data{
                    int_data = CurrencySeizeTimes
                } = TimesRecord,
                CurrencySeizeTimes;
            null -> ?INFO("玩家第一次发起夺宝"), 0;
            OtherOfSeizeTimes -> ?ERROR("非预期夺宝次数结果: ~p", [OtherOfSeizeTimes]), 0
        end,
    ?IF(AfterSeize =:= ?TRUE, ?IF(Increment >= 0, SeizeTimes + Increment, SeizeTimes), SeizeTimes).

%% @doc 通过夺宝类型编号与当前幸运值，获取夺宝物品元组列表
get_valid_seize_treasure_list(SeizeTreasureTypeId, CurrencyLuckValue) ->
    ValidSeizeTreasureTupleList =
        case logic_get_seize_treasure_list_by_type_id:get(SeizeTreasureTypeId) of
            SeizeTreasureTupleList ->
                lists:filtermap(
                    fun(Ele) ->
                        {Data, Minimum} = Ele,
                        ?IF(CurrencyLuckValue >= Minimum, {true, Data}, false)
                    end,
                    SeizeTreasureTupleList
                )
        end,
%%    ?DEBUG("ValidSeizeTreasureTupleList: ~p", [ValidSeizeTreasureTupleList]),
    ValidSeizeTreasureTupleList.

%% @doc 玩家夺宝，事务处理数据库
seize_treasure(PlayerId, CostItemId, CostItemNum, RealLuckValue, RealSeizeTimes,
    ExtraAwardId, ExtraAwardNum, TreasureList, Times) ->
    %% 抽奖
    SeizeTimes = ?IF(ExtraAwardId > 0 andalso ExtraAwardNum > 0, Times - 1, Times),
    SeizeTreasureList =
        lists:foldl(
            fun (Ele, Tmp) ->
                {TreasureId, Numbers} =
                    case util_random:get_probability_item(TreasureList) of
                        Result when is_tuple(Result) -> Result;
%%                            {T, N} = Result;
                        Other1 -> ?ERROR("非预期的权重计算结果: ~p", [Other1]), {0, 0}
                    end,
                ?DEBUG("Ele: ~p", [Ele]),
                [{TreasureId, Numbers} | Tmp]
            end,
            [],
            lists:seq(1, SeizeTimes)
        ),
    ?INFO("Treasure Res: ~p Times: ~p", [SeizeTreasureList, SeizeTimes]),
    NewSeizeTreasureList = ?IF(ExtraAwardId > 0 andalso ExtraAwardNum > 0,
        [{ExtraAwardId, ExtraAwardNum} | SeizeTreasureList], SeizeTreasureList),
%%    ?DEBUG("NewSeizeTreasureList: ~p", [NewSeizeTreasureList]),
%%    ?ASSERT(TreasureId =/= 0 andalso Numbers =/= 0, unknown),
%%    ?INFO("TreasureId: ~p, Numbers: ~p", [TreasureId, Numbers]),

    Fun =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, [CostItemId, CostItemNum], ?LOG_TYPE_DUOBAO_SHOP),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_LUCK_VALUE, RealLuckValue),
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_TIMES, RealSeizeTimes),
%%            SeizeTreasureList = [{TreasureId, Numbers}],
            AwardList = NewSeizeTreasureList,
%%                if
%%                    ExtraAwardId > 0 andalso ExtraAwardNum > 0 -> [{ExtraAwardId, ExtraAwardNum} | SeizeTreasureList];
%%                    true -> SeizeTreasureList
%%                end,
%%            ?DEBUG("AwardList: ~p", [AwardList]),
            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_SEIZE_TREASURE)
        end,
    db:do(Fun),
%%    ?INFO("doResult: ~p", [R]),
%%    {ok, {TreasureId, Numbers}}.
    {ok, NewSeizeTreasureList}.

%% @doc 指定夺宝类型与额外奖励下标(treasure_hunt_type.csv表的achievement_list字段的下标)，读取相应数据
get_seize_extra_award_list(TreasureHuntTypeId, Pos) ->
    case logic_get_seize_treasure_achievement_list_by_pos:get({TreasureHuntTypeId, Pos}) of
        AchievementList when is_tuple(AchievementList) ->
            AchievementList;
        null ->
            ?INFO("没有配置id为~p的类型为~p的treasure_hunt_type.csv的记录"),
            exit(no_achievement_list);
        OtherOfTreasureHuntType ->
            ?INFO("非预期的获取指定夺宝类型数据的结果: ~p", [OtherOfTreasureHuntType]),
            exit(no_achievement_list)
    end.

%% @doc 获取指定玩家已经领取的额外奖励记录
get_old_extra_award(PlayerId) ->
    case mod_player_game_data:get_player_game_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_ACHIEVEMENT) of
        null ->
            %% 测试用，
            %% [{5, "领取奖励时间"}]
            [];
        HasGetAwardList ->
%%            ?DEBUG("HasGetAwardList: ~p", [HasGetAwardList]),
            #db_player_game_data{
                str_data = StrData
            } = HasGetAwardList,
            util_string:string_to_term(StrData)
    end.