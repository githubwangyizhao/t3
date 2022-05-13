%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc            商城
%%% Created : 07. 二月 2018 16:28
%%%-------------------------------------------------------------------
-module(mod_shop).
-author("home").

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("activity.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").

%% API
-export([
    get_shop_info/2,                %% 获得商店信息
    buy_item/3                      %% 购买物品
%%    get_mystery_shop_info/1,        %% 获得神秘商店信息
%%    mystery_shop_item/2,            %% 神秘商店购买
%%    refresh_mystery_shop_item/1,    %% 神秘商店刷新
%%    get_limit_time_shop_info/1,     %% 获得限时抢购商店信息
%%    buy_limit_time_shop/3           %% 购买限时抢购物品
]).

-export([
    add_charge_shop_data/2,
    check_recharge_shop/2,
    is_shop_count_limit/2
%%    zero_online_restart/0,          %% 0点时推送限购商店
%%    calc_auto_buy_item/2,           %% 计算自动购买道具
%%    get_player_mystery_shop_item/1, %%获得神秘商店物品
%%    close_activity_shop/2,          %% 关闭活动时玩家结算
%%    close_day_activity_shop/1,      %% 关闭每日活动时玩家结算
%%    open_action/1,                  %% 活动开启时处理
%%    close_action/1                  %% 活动关闭时处理
]).


%（0=不限购；1=1天；2=1周；-1=终生限购，不填则默认不限购）
-define(SHOP_LIMIT_TYPE_TOTAL, -1).   % 总限制数量
-define(SHOP_LIMIT_TYPE_0, 0).        % 不限购
-define(SHOP_LIMIT_TYPE_1, 1).        % 每天限制数量
-define(SHOP_LIMIT_TYPE_2, 2).        % 每周限制数量
-define(SHOP_LIMIT_TYPE_3, 3).        % 活动时间限制数量

-define(SHOP_BUY_TYPE_0, 0).        % 一买一
-define(SHOP_BUY_TYPE_1, 1).        % 多个道具买一个
-define(SHOP_BUY_TYPE_2, 2).        % 一个买多个道具


%% @fun 商场加触发条件
-define(SHOP_CONDITIONS_LIST, [
    {?SHOP_T_ITEM_SHOP, ?CON_ENUM_ITEM_SHOP_BUY_COUNT}
%%    {?SHOP_T_HONOR_SHOP, ?CON_ENUM_HONOR_SHOP_BUY_COUNT}
]).


%% @doc     获得商店信息
get_shop_info(PlayerId, ShopType) ->
%%    #t_shop_type{
%%        activity_id = ActivityId
%%    } = try_get_t_shop_type(ShopType),
    lists:foldl(
        fun(ShopId, L) ->
            #t_shop{
                condition_list = ConditionList
            } = try_get_t_shop(ShopId),
            #db_player_shop{
                id = Id,
                buy_count = BuyCount,
                award_state = AwardState
            } = get_player_shop_init(PlayerId, ShopId),
            if
                ConditionList =/= [] ->
                    [ConditionStr, NeedValue] = ConditionList,
%%                    {ConditionId1, _} = mod_conditions:get_conditions_id(ConditionId),
%%                    #db_player_activity_condition{
%%                        value = PlayerValue
%%                    } = mod_activity_task:get_activity_task_condition_init(PlayerId, ActivityId, ConditionId1),
                    PlayerValue = mod_conditions:get_player_conditions_data_number(PlayerId, ConditionStr),
%%                    ?INFO("获得商店信息~p~n", [{ShopId, ConditionStr, NeedValue, PlayerValue}]),
                    if
                        PlayerValue == NeedValue -> [{Id, BuyCount, AwardState} | L];
                        true -> L
                    end;
                true ->
                    [{Id, BuyCount, AwardState} | L]
            end
        end, [], logic_get_shop_type_id_list(ShopType)).


%%购买物品
buy_item(PlayerId, Id, Num) ->
%%    ?ASSERT(Num > 0, ?ERROR_NUM_0),

%%    T_Shop = try_get_t_shop(Id),
%%    #t_shop{
%%        item_list = ItemList,
%%        type = ShopType,
%%        buy_item_list = BuyItemList,
%%        limit = Limit,
%%        buy_limit_list = BuyLimitList
%%    } = T_Shop,
%%    case BuyLimitList of
%%        [BuyLimitType, BuyLimitValue] ->
%%            ?ASSERT(get_shop_buy_limit_value(PlayerId, BuyLimitType) >= BuyLimitValue, ?ERROR_NOT_AUTHORITY);
%%        _ ->
%%            noop
%%    end,
%%    PlayerShop = get_player_shop_init(PlayerId, Id),
%%    BuyCount = PlayerShop#db_player_shop.buy_count,
%%    LimitType = PlayerShop#db_player_shop.limit_type,
%%    NewBuyCount = Num + BuyCount,
%%    ?ASSERT(LimitType == ?SHOP_LIMIT_TYPE_0 orelse NewBuyCount =< Limit, ?ERROR_TIMES_LIMIT),
%%    {NewItemList, NewBuyItemList} =
%%        if
%%            Num > 1 ->
%%                GiveItemList = lists:duplicate(Num, ItemList),
%%                BuyPropList = lists:duplicate(Num, BuyItemList),
%%                {mod_prop:merge_prop_list(GiveItemList), mod_prop:merge_prop_list(BuyPropList)};
%%            true ->
%%                {[ItemList], [BuyItemList]}
%%        end,
%%    mod_prop:assert_prop_num(PlayerId, NewBuyItemList),
    {LogType, NewItemList, NewBuyItemList, DataF} = auto_buy_item(PlayerId, Id, Num),
%%    ?DEBUG("购买物品~p~n", [{NewItemList, NewBuyItemList}]),
    mod_prop:assert_prop_num(PlayerId, NewBuyItemList),
    mod_prop:assert_give(PlayerId, NewItemList),
    Tran =
        fun() ->
            mod_prop:decrease_player_prop(PlayerId, NewBuyItemList, LogType),
            mod_award:give(PlayerId, NewItemList, LogType),
            mod_service_player_log:add_log(PlayerId, {?SERVICE_LOG_SHOP_ITEM_BUY_COUNT, Id}),
            DataF()
%%            db:write(PlayerShop#db_player_shop{buy_count = NewBuyCount, change_time = util_time:timestamp()}),
%%            case lists:keyfind(ShopType, 1, ?SHOP_CONDITIONS_LIST) of
%%                {ShopType, ConditionsKey} ->
%%                    mod_conditions:add_conditions(PlayerId, {ConditionsKey, ?CONDITIONS_VALUE_ADD, Num});
%%                _ ->
%%                    noop
%%            end
        end,
    db:do(Tran),
    ok.

%% @doc     获得神秘商店信息
%%get_mystery_shop_info(PlayerId) ->
%%    OldMysteryShopList = get_player_mystery_shop_item(PlayerId),
%%    if
%%        OldMysteryShopList == [] ->
%%            List = refresh_mystery_shop_list(PlayerId),
%%            Tran =
%%                fun() ->
%%                    lists:foldl(
%%                        fun(Id, L) ->
%%                            PlayerMysteryShopInit = get_player_mystery_shop_init(PlayerId, Id),
%%                            NewPlayerMysteryShop = db:write(PlayerMysteryShopInit#db_player_mystery_shop{buy_state = ?AWARD_CAN}),
%%                            [NewPlayerMysteryShop | L]
%%                        end, [], List)
%%                end,
%%            db:do(Tran);
%%        true ->
%%            OldMysteryShopList
%%    end.

%% @doc     神秘商店购买
%%mystery_shop_item(PlayerId, Id) ->
%%    mod_function:assert_open(PlayerId, ?FUNCTION_SHOP_SYS),
%%    T_Mystery =
%%        case catch try_get_t_shop_mystery(Id) of
%%            Table1 when is_record(Table1, t_shop_mystery) ->
%%                Table1;
%%            _ ->
%%                ?DEBUG("系统刷新神秘商店购买: ~p~n", [{PlayerId, Id}]),
%%                api_shop:api_get_refresh_mystery_shop_info(catch gm_refresh_mystery_shop(PlayerId)),
%%                exit(?ERROR_NOT_AUTHORITY)
%%        end,
%%    #t_shop_mystery{
%%        item_list = ItemList1,
%%        current_price_list = CurrentPriceList1
%%    } = T_Mystery,
%%    MysteryShop = get_player_mystery_shop(PlayerId, Id),
%%    ?ASSERT(is_record(MysteryShop, db_player_mystery_shop), ?ERROR_NOT_AUTHORITY),
%%    #db_player_mystery_shop{
%%        buy_state = BuyState
%%    } = MysteryShop,
%%    ?ASSERT(BuyState == ?AWARD_CAN, ?ERROR_ALREADY_HAVE),
%%    ItemList = [ItemList1],
%%    CurrentPriceList = [CurrentPriceList1],
%%    mod_prop:assert_give(PlayerId, ItemList),
%%    mod_prop:assert_prop_num(PlayerId, CurrentPriceList),
%%    Tran =
%%        fun() ->
%%            mod_prop:decrease_player_prop(PlayerId, CurrentPriceList, ?LOG_TYPE_MYSTERY_SHOP_BUY),
%%            mod_award:give(PlayerId, ItemList, ?LOG_TYPE_MYSTERY_SHOP_BUY),
%%            db:write(MysteryShop#db_player_mystery_shop{buy_state = ?AWARD_ALREADY}),
%%            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_MYSTERY_SHOP_BUY_COUNT, ?CONDITIONS_VALUE_ADD, 1})
%%        end,
%%    db:do(Tran),
%%    ok.

%% @doc     神秘商店刷新
%%refresh_mystery_shop_item(PlayerId) ->
%%    mod_function:assert_open(PlayerId, ?FUNCTION_SHOP_SYS),
%%    TimesId = ?TIMES_MYSTERY_TIMES,
%%    mod_times:assert_times(PlayerId, TimesId),
%%    OldMysteryShopList = get_player_mystery_shop_item(PlayerId),
%%    List = refresh_mystery_shop_list(PlayerId),
%%    Tran =
%%        fun() ->
%%            mod_times:use_times(PlayerId, TimesId),
%%            [db:delete(DelShop) || DelShop <- OldMysteryShopList],
%%            ShopList =
%%                lists:foldl(
%%                    fun(Id, L) ->
%%                        PlayerMysteryShopInit = get_player_mystery_shop_init(PlayerId, Id),
%%                        NewPlayerMysteryShop = db:write(PlayerMysteryShopInit#db_player_mystery_shop{buy_state = ?AWARD_CAN}),
%%                        [NewPlayerMysteryShop | L]
%%                    end, [], List),
%%            {ok, ShopList}
%%        end,
%%    db:do(Tran).


%% @doc     获得限时抢购商店信息
%%get_limit_time_shop_info(PlayerId) ->
%%%%    ActivityId = ?ACT_FLASH_SALE,
%%    %% 随便填1，要改的
%%    ActivityId = 1,
%%    {ActivityState, ActivityTime} = get_open_state_and_start_time(ActivityId),
%%    if
%%        ActivityState ->
%%            ActivityDay = get_limit_time_shop_day(ActivityTime),             %% 活动天数
%%            ShopList =
%%                lists:foldl(
%%                    fun(Id, L) ->
%%                        #db_player_shop_limit_time{
%%                            buy_count = BuyCount
%%                        } = get_player_shop_limit_time_init(PlayerId, Id),
%%                        [{Id, BuyCount} | L]
%%                    end, [], logic_get_shop_limit_time_day_list(ActivityDay)),
%%            {ActivityDay, ShopList};
%%        true ->
%%            {0, []}
%%    end.

%% @doc     购买限时抢购物品
%%buy_limit_time_shop(PlayerId, Id, Num) ->
%%%%    ActivityId = ?ACT_FLASH_SALE,
%%    %% 随便填1，要改的
%%    ActivityId = 1,
%%    {ActivityState, ActivityTime} = get_open_state_and_start_time(ActivityId),
%%    ?ASSERT(ActivityState, ?ERROR_NOT_ACTION_TIME),
%%    #t_shop_limit_time{
%%        show_day = Day,                              %% 显示的天
%%        item_list = GiveItemList,                            %% 物品id
%%        buy_item_list = BuyItemList,                        %% 购买价格
%%        limit_num = LimitNum,                             %% 限购数量
%%        buy_limit_list = BuyLimitList                       %% 购买限制[限制类型，参数]（限制类型：1=vip等级限制；2转生限制；3战场限制）
%%    } = try_get_t_shop_limit_time(Id),
%%    ActivityDay = get_limit_time_shop_day(ActivityTime),             %% 活动天数
%%    ?ASSERT(Day == ActivityDay, ?ERROR_NOT_AUTHORITY),
%%    case BuyLimitList of
%%        [] ->
%%            noop;
%%        _ ->
%%            ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, BuyLimitList) == true, ?ERROR_NOT_AUTHORITY)
%%    end,
%%    PlayerShopInit = get_player_shop_limit_time_init(PlayerId, Id),
%%    BuyCount = PlayerShopInit#db_player_shop_limit_time.buy_count,
%%    NewBuyCount = Num + BuyCount,
%%    ?ASSERT(NewBuyCount =< LimitNum, ?ERROR_TIMES_LIMIT),
%%    {NewGiveList, NewBuyItemList} =
%%        if
%%            Num > 1 ->
%%                GiveItemList1 = lists:duplicate(Num, GiveItemList),
%%                BuyPropList = lists:duplicate(Num, BuyItemList),
%%                {GiveItemList1, BuyPropList};
%%            true ->
%%                {[GiveItemList], [BuyItemList]}
%%        end,
%%    mod_prop:assert_prop_num(PlayerId, NewBuyItemList),
%%    mod_prop:assert_give(PlayerId, NewGiveList),
%%
%%    Tran =
%%        fun() ->
%%            mod_prop:decrease_player_prop(PlayerId, NewBuyItemList, ?LOG_TYPE_SHOP_LIMIT_TIME_BUY),
%%            mod_award:give(PlayerId, NewGiveList, ?LOG_TYPE_SHOP_LIMIT_TIME_BUY),
%%            db:write(PlayerShopInit#db_player_shop_limit_time{buy_count = NewBuyCount, change_time = util_time:timestamp()})
%%        end,
%%    db:do(Tran),
%%    ok.

%% @fun gm刷新神秘商店数据
%%gm_refresh_mystery_shop(PlayerId) ->
%%    OldMysteryShopList = get_player_mystery_shop_item(PlayerId),
%%    List = refresh_mystery_shop_list(PlayerId),
%%    Tran =
%%        fun() ->
%%            [db:delete(DelShop) || DelShop <- OldMysteryShopList],
%%            ShopList =
%%                lists:foldl(
%%                    fun(Id, L) ->
%%                        PlayerMysteryShopInit = get_player_mystery_shop_init(PlayerId, Id),
%%                        NewPlayerMysteryShop = db:write(PlayerMysteryShopInit#db_player_mystery_shop{buy_state = ?AWARD_CAN}),
%%                        [NewPlayerMysteryShop | L]
%%                    end, [], List),
%%            {ok, ShopList}
%%        end,
%%    db:do(Tran).

%% @fun 刷新神秘商店数据
%%refresh_mystery_shop_list(PlayerId) ->
%%    Level = mod_player:get_player_data(PlayerId, level),
%%    lists:foldl(
%%        fun([RandomBag, RandNum], L) ->
%%            {RandomList, Count} =
%%                lists:foldl(
%%                    fun({Id, Weights, [InitLevel, EndLevel]}, {L1, Count1}) ->
%%                        if
%%                            InitLevel =< Level andalso (Level =< EndLevel orelse EndLevel == 0) ->
%%                                {[{Id, Weights} | L1], Count1 + 1};
%%                            true ->
%%                                {L1, Count1}
%%                        end
%%                    end, {[], 0}, logic_get_mystery_shop_id_list(RandomBag)),
%%            if
%%                Count >= RandNum ->
%%                    noop;
%%                true ->
%%                    ?ERROR("刷新神秘商店数据RandomBag:~p  => ~p~n", [{RandomBag, Level}, RandomList])
%%            end,
%%            RandList = util_random:get_probability_item_count(RandomList, RandNum),
%%            if
%%                length(RandList) == RandNum ->
%%                    noop;
%%                true ->
%%                    exit({refresh_mystery_length, Level, length(RandList)})
%%            end,
%%            RandList ++ L
%%        end, [], ?SD_SHOP_MYSTERY_RANDOM_NUM).

%% @fun 增加充值商店数据
add_charge_shop_data(PlayerId, ChargeItemId) ->
%%    ?INFO("增加充值商店数据:~p~n", [{PlayerId, ChargeItemId, util_time:datetime()}]),
    Tran = fun() ->
        lists:foldl(
            fun({ShopType, ShopId}, L) ->
                #t_shop_type{
                    activity_id = ActivityId
                } = try_get_t_shop_type(ShopType),
                case activity:is_open(ActivityId) of
                    true ->
                        #t_shop{
                            limit = Limit
                        } = try_get_t_shop(ShopId),
                        PlayerShopInit = get_player_shop_init(PlayerId, ShopId),
                        #db_player_shop{
                            buy_count = BuyCount
                        } = PlayerShopInit,
                        if
                            Limit > BuyCount ->
                                db:write(PlayerShopInit#db_player_shop{award_state = ?AWARD_CAN, change_time = util_time:timestamp()}),
                                db:tran_apply(fun() ->
                                    ?INFO("充值商店可领取:~p", [{PlayerId, ShopId, BuyCount}]),
                                    api_shop:notice_shop_state(PlayerId, ShopId, ?AWARD_CAN) end),
                                [ShopId | L];
                            true ->
                                ?INFO("充值商店可领取次数上限:~p", [{PlayerId, ShopId, BuyCount, Limit}]),
                                L
                        end;
                    _ ->
                        L
                end end, [], logic_get_shop_charge_id_list(ChargeItemId))
           end,
    db:do(Tran).

%% @fun 检查
check_recharge_shop(PlayerId, ShopId) ->
    #t_shop{
        limit = Limit
    } = try_get_t_shop(ShopId),
    PlayerShopInit = get_player_shop_init(PlayerId, ShopId),
    #db_player_shop{
        buy_count = BuyCount,
        award_state = AwardState
    } = PlayerShopInit,
    if
        Limit > BuyCount andalso AwardState =/= ?AWARD_CAN ->
            true;
        true ->
            false
    end.

%% ----------------------------------
%% @doc 	商品购买次数是否达到上限
%% @throws 	none
%% @end
%% ----------------------------------
is_shop_count_limit(PlayerId, ShopId) ->
    #t_shop{
        limit = Limit
    } = try_get_t_shop(ShopId),
    PlayerShopInit = get_player_shop_init(PlayerId, ShopId),
    #db_player_shop{
        buy_count = BuyCount
    } = PlayerShopInit,
    BuyCount >= Limit.

%% @fun 计算自动购买道具;
%%calc_auto_buy_item(PlayerId, ItemList) ->
%%    mod_function:assert_open(PlayerId, ?FUNCTION_SHOP_ITEM_SYS),
%%    MergeItemList = mod_prop:merge_prop_list(ItemList),
%%    {ConditionsGiveItemList, CalcGiveItemList, CalcItemList, CalcDataF1} =
%%        lists:foldl(
%%            fun(Tuple, {ConditionsGiveItemL, GiveL, PropL, ShopF}) ->
%%                {PropId, PropNum} = mod_prop:tran_prop(Tuple),
%%                CurrPropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
%%                if
%%                    PropNum > CurrPropNum ->
%%                        {LogicPropNum, ShopId} = logic_get_auto_shop_id_list(PropType, PropId),
%%                        N1 = PropNum - CurrPropNum,
%%                        ShopNum = ceil(N1 / LogicPropNum),
%%                        CalcNum = ShopNum * LogicPropNum - N1 - CurrPropNum,
%%                        {_LogType, GiveItemL1, BuyItemList, DataF1} = auto_buy_item(PlayerId, ShopId, ShopNum),
%%                        DataF =
%%                            if
%%                                ShopF == null ->
%%                                    DataF1;
%%                                true ->
%%                                    fun() -> ShopF(), DataF1() end
%%                            end,
%%                        NewBuyItemList = PropL ++ BuyItemList,
%%                        ConditionsGiveItemL1 = GiveItemL1 ++ ConditionsGiveItemL,
%%                        if
%%                            CalcNum == 0 ->
%%                                {ConditionsGiveItemL1, GiveL, NewBuyItemList, DataF};
%%                            CalcNum < 0 ->
%%                                {ConditionsGiveItemL1, GiveL, [{PropType, PropId, abs(CalcNum)} | NewBuyItemList], DataF};
%%                            true ->
%%                                {ConditionsGiveItemL1, [{PropType, PropId, abs(CalcNum)} | GiveL], NewBuyItemList, DataF}
%%                        end;
%%                    true ->
%%                        {ConditionsGiveItemL, GiveL, [{PropType, PropId, PropNum} | PropL], ShopF}
%%                end
%%            end, {[], [], [], null}, MergeItemList),
%%    MergeConditionsGiveItemList = mod_prop:merge_prop_list(ConditionsGiveItemList),
%%    MergeCalcItemList = mod_prop:merge_prop_list(CalcItemList),
%%    MergeCalcGiveItemList = mod_prop:merge_prop_list(CalcGiveItemList),
%%    mod_prop:assert_prop_num(PlayerId, MergeCalcItemList),
%%    mod_prop:assert_give(PlayerId, CalcGiveItemList),
%%    CalcDataF =
%%        if
%%            CalcDataF1 == null ->
%%                fun() -> mod_prop:add_cost_item_conditions(PlayerId, MergeConditionsGiveItemList) end;
%%            true ->
%%                fun() -> CalcDataF1(), mod_prop:add_cost_item_conditions(PlayerId, MergeConditionsGiveItemList) end
%%        end,
%%    {MergeCalcGiveItemList, MergeCalcItemList, CalcDataF}.


%% @fun 自动购买数据处理 : NewGiveList:转换给列表, NewBuyItemList:消耗列表
auto_buy_item(PlayerId, Id, Num) ->
    ?ASSERT(Num > 0, ?ERROR_NUM_0),
%%    T_Shop = try_get_t_shop(Id),
    #t_shop{
        item_list = GiveList,
        type = ShopType,
        buy_item_list = BuyItemList,
        limit = Limit,
        buy_limit_list = BuyLimitList,
        condition_list = ConditionList,
        limit_type = LimitType
    } = try_get_t_shop(Id),
    #t_shop_type{
        activity_id = ActivityId,
        log_type = LogType,
        fun_id = CheckFunId,
        times_id = TimesId
    } = try_get_t_shop_type(ShopType),
    mod_prop:try_t_log_type(LogType),
    if
        CheckFunId > 0 ->
            mod_function:assert_open(PlayerId, CheckFunId);
        true ->
            noop
    end,
    if
        ActivityId > 0 ->
            ?ASSERT(activity:is_open(PlayerId, ActivityId), ?ERROR_ACTIVITY_NO_OPEN);
        true ->
            noop
    end,
    case BuyLimitList of
        [] ->
            noop;
        _ ->
            ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, BuyLimitList) == true, ?ERROR_NOT_AUTHORITY)
    end,
    if
        TimesId > 0 ->
            LeftTimes = mod_times:get_left_times(PlayerId, TimesId),
            ?ASSERT(LeftTimes >= Num, ?ERROR_TIMES_LIMIT);
        true ->
            noop
    end,
    PlayerShop = get_player_shop_init(PlayerId, Id),
    #db_player_shop{
        buy_count = BuyCount,
%%        limit_type = LimitType,
        award_state = AwareState
    } = PlayerShop,
%%    BuyCount = PlayerShop#db_player_shop.buy_count,
%%    LimitType = PlayerShop#db_player_shop.limit_type,
    NewBuyCount = Num + BuyCount,
    ?DEBUG("~p~n", [{Id, NewBuyCount, Num, BuyCount, Limit}]),
    ?ASSERT(logic_get_charge_shop_list(Id) == true andalso AwareState == ?AWARD_CAN andalso NewBuyCount =< Limit orelse
        logic_get_charge_shop_list(Id) =/= true andalso (NewBuyCount =< Limit orelse LimitType == ?SHOP_LIMIT_TYPE_0), ?ERROR_TIMES_LIMIT),% 非充值商场

%%    ?ASSERT(LimitType == ?SHOP_LIMIT_TYPE_0 andalso logic_get_charge_shop_list(Id) =/= true orelse LimitType =/= ?SHOP_LIMIT_TYPE_0 andalso logic_get_charge_shop_list(Id) == true  andalso AwareState == ?AWARD_CAN orelse NewBuyCount =< Limit, ?ERROR_TIMES_LIMIT),

    {NewGiveList, NewBuyItemList} =
        case logic_get_charge_shop_list(Id) of      %% 直购商店（true:是）
            true ->
                ?ASSERT(Num == 1, ?ERROR_NUM_0),
                {GiveList, []};
            _ ->
                if
                    Num > 1 ->
                        GiveItemList1 = lists:duplicate(Num, GiveList),
                        BuyPropList1 = lists:duplicate(Num, BuyItemList),
                        BuyPropList = lists:append(BuyPropList1),
                        GiveItemList = lists:append(GiveItemList1),
                        {GiveItemList, BuyPropList};
                    true ->
                        BuyPropList = BuyItemList,
                        GiveItemList = GiveList,
                        {GiveItemList, BuyPropList}
                end
        end,
    if
        ConditionList =/= [] ->
            [ConditionStr, Value] = ConditionList,
%%            {ConditionId, _} = mod_conditions:get_conditions_id(ConditionStr),
%%            #db_player_activity_condition{
%%                value = PlayerValue
%%            } = mod_activity_task:get_activity_task_condition_init(PlayerId, ActivityId, ConditionId),
            PlayerValue = mod_conditions:get_player_conditions_data_number(PlayerId, ConditionStr),
            ?ASSERT(PlayerValue == Value, ?ERROR_NOT_AUTHORITY);
        true ->
            noop
    end,
    DataF =
        fun() ->
            if
                TimesId > 0 ->
                    lists:foreach(
                        fun(_) ->
                            mod_times:use_times(PlayerId, TimesId)
                        end,
                        lists:seq(1, Num)
                    );
                true ->
                    noop
            end,
            db:write(PlayerShop#db_player_shop{buy_count = NewBuyCount, award_state = ?AWARD_ALREADY, change_time = util_time:timestamp()}),
            case lists:keyfind(ShopType, 1, ?SHOP_CONDITIONS_LIST) of
                {ShopType, ConditionsKey} ->
                    mod_conditions:add_conditions(PlayerId, {ConditionsKey, ?CONDITIONS_VALUE_ADD, Num});
                _ ->
                    noop
            end
        end,
    {LogType, NewGiveList, NewBuyItemList, DataF}.

%%%% @fun 获得活动状态和时间
%%get_open_state_and_start_time(ActivityId) ->
%%    {ActivityState, StateTime} = mod_activity:get_open_state_and_start_time(ActivityId),
%%    {ActivityState, ?IF(StateTime == ?OPEN_ACTIVITY_TIME, mod_server_config:get_server_open_time(), StateTime)}.
%%%% @fun 获得限时商店当前天
%%get_limit_time_shop_day(ActivityTime) ->
%%    ActivityDay = util_time:get_interval_day_add_1(ActivityTime),
%%    MaxDay = logic_get_shop_limit_time_max_day(),
%%    Day = ActivityDay rem MaxDay,
%%    if
%%        Day > 0 ->
%%            Day;
%%        true ->
%%            MaxDay
%%    end.
%% @fun 0点时推送限购商店
%%zero_online_restart() ->
%%%%    ActivityId = ?ACT_FLASH_SALE,
%%    %% 随便填1，要改的
%%    ActivityId = 1,
%%    case get_open_state_and_start_time(ActivityId) of
%%        {true, _} ->
%%            mod_apply:apply_to_all_online_player_args(api_shop, api_get_limit_time_shop_info, []);
%%        _ ->
%%            noop
%%    end.

%% @fun 开启活动时
%%open_action(_) ->
%%    ok.

%% @fun 关闭活动时
%%close_action({ActivityId, StartTime}) ->
%%    ?INFO("关闭商城活动时:~p", [{ActivityId, StartTime}]),
%%    mod_apply:apply_to_all_online_player_args(?MODULE, close_activity_shop, [ActivityId], game_worker),
%%    0.

%% @fun 关闭活动时玩家结算
%%close_activity_shop(PlayerId, ActivityId) ->
%%    CurrTime = util_time:timestamp(),
%%    List = logic_get_shop_activity_reset_list(ActivityId),
%%    close_activity_shop(PlayerId, ActivityId, CurrTime, List).
%%close_activity_shop(PlayerId, ActivityId, CurrTime, List) ->
%%    ActivityName = mod_activity:get_activity_name(ActivityId),
%%    ActivityGiveList =
%%        lists:foldl(
%%            fun(Element, L) ->
%%                ShopId =
%%                    case Element of
%%                        {ShopId1, _} ->
%%                            ShopId1;
%%                        _ ->
%%                            Element
%%                    end,
%%                case get_player_shop(PlayerId, ShopId) of
%%                    PlayerShop when is_record(PlayerShop, db_player_shop) ->
%%                        if
%%                            PlayerShop#db_player_shop.award_state == ?AWARD_CAN ->
%%                                #t_shop{
%%                                    item_list = GiveItemL
%%                                } = try_get_t_shop(ShopId),
%%%%                                GiveItemList = ?IF(BuyType == ?SHOP_BUY_TYPE_2, GiveItemL, [GiveItemL]),
%%%%                                MiilId = ?MAIL_ACTIVITY_AUTO_GIVE,
%%                                %% 邮件
%%                                MailId = 1,
%%                                Tran =
%%                                    fun() ->
%%                                        db:write(PlayerShop#db_player_shop{award_state = ?AWARD_ALREADY, change_time = CurrTime}),
%%                                        mod_mail:add_mail_param_item_list(PlayerId, MailId, GiveItemL, [ActivityName], ?LOG_TYPE_SYSTEM_SEND)
%%                                    end,
%%                                db:do(Tran),
%%                                [{ShopId, GiveItemL} | L];
%%                            true ->
%%                                L
%%                        end;
%%                    _ ->
%%                        L
%%                end
%%            end, [], List),
%%    ?IF(ActivityGiveList == [], noop, ?INFO("活动结束时玩家结算>~p:~p :~p", [PlayerId, ActivityId, ActivityGiveList])),
%%    ok.

%% @fun 关闭每日活动时玩家结算
%%close_day_activity_shop(PlayerId) ->
%%    ActivityList = logic_get_shop_day_reset_list(),
%%    CurrTime = util_time:timestamp(),
%%    [close_activity_shop(PlayerId, ActivityId, CurrTime, List) || {ActivityId, List} <- ActivityList].

%%================================================= 数据操作 ==================================================
%%商店数据
get_player_shop(PlayerId, Id) ->
    db:read(#key_player_shop{player_id = PlayerId, id = Id}).

%%商店数据   并初始化
get_player_shop_init(PlayerId, Id) ->
    Table = try_get_t_shop(Id),
    case get_player_shop(PlayerId, Id) of
        S when is_record(S, db_player_shop) ->
            ChangeTime = S#db_player_shop.change_time,
            IsHave =
                case Table#t_shop.limit_type of
                    ?SHOP_LIMIT_TYPE_1 ->
                        util_time:is_today(ChangeTime);
                    ?SHOP_LIMIT_TYPE_2 ->
                        util_time:is_this_week(ChangeTime);
                    ?SHOP_LIMIT_TYPE_3 ->
                        #t_shop{
                            type = ShopType
                        } = try_get_t_shop(Id),
                        #t_shop_type{
                            activity_id = ActivityId
                        } = try_get_t_shop_type(ShopType),
                        {StartTime, EndTime} = activity:get_activity_start_and_end_time(PlayerId, ActivityId),
                        if
                            StartTime =< ChangeTime andalso ChangeTime < EndTime ->
                                true;
                            true ->
                                false
                        end;
                    _ ->
                        true
                end,
            case IsHave of % 是否在时间内
                true ->
                    S;
                _ ->
                    S#db_player_shop{buy_count = 0, award_state = ?AWARD_NONE}
            end;
        _ ->
            #db_player_shop{player_id = PlayerId, id = Id, limit_type = Table#t_shop.limit_type}
    end.

%%获得神秘商店数据
%%get_player_mystery_shop(PlayerId, Id) ->
%%    db:read(#key_player_mystery_shop{player_id = PlayerId, id = Id}).

%%%%获得神秘商店数据    并初始化
%%get_player_mystery_shop_init(PlayerId, Id) ->
%%    case get_player_mystery_shop(PlayerId, Id) of
%%        S when is_record(S, db_player_mystery_shop) ->
%%            S;
%%        _ ->
%%            #db_player_mystery_shop{player_id = PlayerId, id = Id}
%%    end.

%% 获得玩家限时抢购商店数据
%%get_player_shop_limit_time(PlayerId, Id) ->
%%    db:read(#key_player_shop_limit_time{player_id = PlayerId, id = Id}).

%%%% 获得玩家限时抢购商店数据     并初始化
%%get_player_shop_limit_time_init(PlayerId, Id) ->
%%    case get_player_shop_limit_time(PlayerId, Id) of
%%        Shop when is_record(Shop, db_player_shop_limit_time) ->
%%            case util_time:is_today(Shop#db_player_shop_limit_time.change_time) of
%%                true ->
%%                    Shop;
%%                _ ->
%%                    Shop#db_player_shop_limit_time{buy_count = 0}
%%            end;
%%        _ ->
%%            #db_player_shop_limit_time{player_id = PlayerId, id = Id}
%%    end.

%%获得神秘商店物品
%%get_player_mystery_shop_item(PlayerId) ->
%%    db_index:get_rows(#idx_player_mystery_shop_1{player_id = PlayerId}).

%%================================================= 模板操作 ==================================================
%%商店模板
try_get_t_shop(Id) ->
    T_Shop = t_shop:get({Id}),
    ?IF(is_record(T_Shop, t_shop), T_Shop, exit({t_shop, {Id}})).

%%商店类型模板
try_get_t_shop_type(Type) ->
    T_Shop = t_shop_type:get({Type}),
    ?IF(is_record(T_Shop, t_shop_type), T_Shop, exit({t_shop_type, {Type}})).

%%神秘商店模板
%%try_get_t_shop_mystery(Id) ->
%%    T_ShopMystery = t_shop_mystery:get({Id}),
%%    ?IF(is_record(T_ShopMystery, t_shop_mystery), T_ShopMystery, exit({t_shop_mystery, {Id}})).

%% 限时抢购商店模板
%%try_get_t_shop_limit_time(Id) ->
%%    Table = t_shop_limit_time:get({Id}),
%%    ?IF(is_record(Table, t_shop_limit_time), Table, exit({t_shop_limit_time, {Id}})).

%% 神秘商店数据列表
%%logic_get_mystery_shop_id_list(RandomBag) ->
%%    logic_get_mystery_shop_id_list:get(RandomBag).

%% 自动购买数据
%%logic_get_auto_shop_id_list(ItemType, ItemId) ->
%%    case logic_get_auto_shop_id_list:get({ItemType, ItemId}) of
%%        {ItemNum, ShopId} ->
%%            {ItemNum, ShopId};
%%        _ ->
%%            ?ERROR({logic_get_auto_shop_id_list, ItemType, ItemId}),
%%            exit({?ERROR_TABLE_DATA, {ItemType, ItemId}})
%%    end.

%% @fun 当前类型的商品id列表
logic_get_shop_type_id_list(ShopType) ->
    case logic_get_shop_type_id_list:get(ShopType) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.

%% @fun 获得限时抢购商店天数据物品列表
%%logic_get_shop_limit_time_day_list(ActivityDay) ->
%%    case logic_get_shop_limit_time_day_list:get(ActivityDay) of
%%        List when is_list(List) ->
%%            List;
%%        _ ->
%%            []
%%    end.

%% @fun 获得限时抢购商店最大天数
%%logic_get_shop_limit_time_max_day() ->
%%    case logic_get_shop_limit_time_max_day:get(0) of
%%        MaxDay when is_integer(MaxDay) ->
%%            MaxDay;
%%        _ ->
%%            -1
%%    end.

%% @fun 获得直充商店列表
logic_get_shop_charge_id_list(ChargeItemId) ->
    case logic_get_shop_charge_id_list:get(ChargeItemId) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.

%% @fun 获得直充商店列表
logic_get_charge_shop_list(ShopId) ->
    logic_get_shop_charge_shop_id:get(ShopId).

%% @fun 商店活动重置列表
%%logic_get_shop_activity_reset_list(ActivityId) ->
%%    logic_get_shop_activity_reset_list:get(ActivityId, []).
%%
%%%% @fun 商店每日重置列表
%%logic_get_shop_day_reset_list() ->
%%    logic_get_shop_day_reset_list:get(0, []).

