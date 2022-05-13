%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc        充值
%%% Created : 20. 三月 2018 10:11
%%%-------------------------------------------------------------------
-module(mod_charge).
-author("home").


%% API
-export([
    get_charge_http_param_info/1,%% 请求充值http参数
    game_player_charge_data/2,  %% 请求充值玩家充值数据
    charge_platform_item/5,     %% 获得/充值平台数据
    charge_platform_item/6,     %% 获得/充值平台数据
    get_charge_platform_conditions/5,   %% 获得平台充值数据加条件类型处理
    web_game_charge/4,          %% web游戏服充值返回
    web_game_charge/5,          %% web游戏服充值返回(加上报参数)
    web_game_charge_conditions/5,   %% web游戏服充值返回带条件
    charge_server_charge/6,     %% 充值服回调充值
    charge_server_charge/7,     %% 充值服回调充值
    charge_server_game_charge/8,%% 充值服回调游戏服充值

    common_game_charge/9,       %% 游戏服公共充值 且上报
    common_game_charge/10,      %% 游戏服公共充值 且上报 修改第三方订单编号
    create_order/11,             %% 创建订单
    apply_online_charge_data/8, %% 在线处理数据
    create_order_id/3,              % 生成一个订单id
    deal_charge/7,                %% 玩家充值

    check_zhi_gou_completed/1
]).

-export([
    charge_report/6,            %% 充值上报
    get_is_open_charge/1,       %% 获得是否开启充值
    update_is_open_charge/1,    %% 更新开启充值数据
    get_charge_order_request_record_init/1, % 充值订单请求数据
    encode_game_order_id/1,     %% 解析打包参数
    encode_game_conditions_param/1,          %% 解析特殊条件
    check_activity_charge/3,    %% 检查充值数据合法
    get_charge_http_shop_info/1,%% 获得充值http商场数据
    get_player_charge/1,        %% 获得玩家充值记录
    get_charge_time_list_money/2,   %% 获得时间内的人民币       单位：元
    get_charge_shop_data_list/1,    %% 获得qq平台充值商店列表
    get_charge_time_ingot/2,    %% 获得玩家时间内充值的充值元宝数
    get_charge_time_ingot/3,    %% 获得玩家时间内充值的充值元宝数
    get_charge_time_value/2,    %% 获得玩家当天充值的元宝数
    get_charge_time_value/3,    %% 获得玩家时间内充值的元宝数
    get_charge_time_money/2,    %% 获得玩家当天充值的人民币
    get_charge_time_money/3     %% 获得玩家时间内充值的人民币
]).

-export([
    get_fail_charge_list/0,     %% 获得全部失败的订单数据
    gm_all_repair_charge/1,     %% 全部失败充值补充订单
    gm_repair_charge/2,         %% 失败补充充值订单
    gm_all_repair/0,            %% gm全部充值数据订单上报
    gm_add_charge_record/3,     %% gm增加充值订单
    try_get_t_recharge/1,
    get_charge_name/1,

    change_charge_state/3,
    change_charge_state/4,      %% 更新三方充值订单状态
    change_ios_android_charge_state/5      %% 更新android/ios充值订单状态
]).

-export([
    chk_order_by_player/4
]).

-export([
    get_charge_type/0
]).

-export([
    has_player_charged/1
]).

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("charge.hrl").
-include("client.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").

%%-define(CHARGE_NODE_NAME, env:get(charge_node, 'charge@192.168.31.100')).

-define(CHANGE_ITEM_ID_0, 0).           % 充值物品id]

%% 注意ios  平台充值星币的档位 [10,60,120,180,300,500,980,1980,2980,4880,6980,9980,19980,29980]
%% 玩吧 ios 可做档位[1, 6, 12, 18, 30, 50, 98, 198, 298, 488, 998, 1998, 2998] 元.
%% 玩吧 安卓不限

%% 微信 安卓档位 [1,3,6,8,12,18,25,30,40,45,50,60,68,73,78,88,98,108,118,128,148,168,188,198,328,648]
%% 微信 ios未开放

%% @doc fun 获得平台充值数据加条件类型处理
get_charge_platform_conditions(PlayerId, PlatformId, PlatformItemId, ItemCount, ConditionsParamTypeStr) ->
    handle_charge_platform_item(PlayerId, PlatformId, PlatformItemId, ItemCount, "", ConditionsParamTypeStr, ?UNDEFINED).

%% @doc     获得/充值平台数据
charge_platform_item(PlayerId, PlatformItemId, ItemCount, IP, ChargeTypeIdx) ->
    charge_platform_item(PlayerId, mod_server_config:get_platform_id(), PlatformItemId, ItemCount, IP, ChargeTypeIdx).
%%    charge_platform_item(PlayerId, ?PLATFORM_WX, PlatformItemId, ItemCount, IP).
charge_platform_item(PlayerId, PlatformId, PlatformItemId, ItemCount, IP, ChargeTypeIdx) ->
    handle_charge_platform_item(PlayerId, PlatformId, PlatformItemId, ItemCount, IP, 0, ChargeTypeIdx).
handle_charge_platform_item(PlayerId, PlatformId, PlatformItemId, ItemCount, _IP, _ConditionsParamTypeStr, _ChargeTypeIdx) ->
    ?DEBUG("PlayerId: ~p, PlatformId: ~p, PlatformItemId: ~p, ItemCount: ~p", [PlayerId, PlatformId, PlatformItemId, ItemCount]),
%%    ?ASSERT(PlatformItemId =/= 99999, ?ERROR_FAIL),
    mod_interface_cd:assert({charge_platform_item, PlayerId}, 3000),
    #t_recharge{
        cash = SingleMoney,
        recharge_type = GameChargeId,
        ingot = Ingot,
        diamond = Diamond
    } = try_get_t_recharge(PlatformItemId),
    SingleValue =
        case GameChargeId of
            ?CHARGE_GAME_COMMON_CHARGE_DIAMOND ->
                Diamond;
            ?CHARGE_GAME_COMMON_CHARGE_COIN ->
                Ingot;
            _ ->
                Diamond
        end,
    ?DEBUG("SingleMoney: ~p GameChargeId: ~p SingleValue: ~p", [SingleMoney, GameChargeId, SingleValue]),
    check_activity_charge(PlayerId, GameChargeId, PlatformItemId, PlatformId),
%%    CurrTime = util_time:timestamp(),
    Money = SingleMoney * ItemCount,
    ChargeIngot = SingleValue * ItemCount,
    ChargeType = ?CHARGE_TYPE_NORMAL,
%%    ServerOrderIdStr = pack_game_order_id(PlayerId, ChargeType, PlatformItemId, ItemCount),     % 回调到游戏服数据
    #db_player{
        server_id = ServerId,
        channel = Channel,
        from = OSPlatform,
        acc_id = AccId
    } = mod_player:get_player(PlayerId),
    ?INFO("获得/充值平台数据 --- 平台~p~n", [{PlatformId, Channel, PlatformItemId, OSPlatform}]),
    AppId =
        case mod_server_rpc:call_center(global_account_srv, local_get_global_account, [PlatformId, AccId]) of
            RInDb when is_record(RInDb, db_global_account) ->
                #db_global_account{
                    app_id = AppIdInDb
                } = RInDb,
                AppIdInDb;
            Else ->
                ?ERROR("get app_id from center by platformId and accId: ~p", [Else]),
                none
        end,
    ?DEBUG("AppId: ~p", [AppId]),
    {IsNativePay, Currency} =
        case mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, AppId]) of
            [ErgetSetting] when is_record(ErgetSetting, ets_erget_setting) ->
                #ets_erget_setting{
                    is_native_pay = IsNativePayInEts, region = Region
                } = ErgetSetting,
                {IsNativePayInEts, Region};
            Other ->
                ?ERROR("get native pay status from ets by app_id: ~p ~p", [Other, AppId]),
                {1, ?REGION_CURRENCY_TW}
        end,
    ?INFO("是否使用native pay: ~p ~p", [IsNativePay, util:to_atom(mod_server_config:get_charge_node())]),
    PlayerRefusedMoney =
        case catch rpc:call(util:to_atom(mod_server_config:get_charge_node()),
            mod_google_pay, chk_player_has_refused, [PlatformId, ServerId, PlayerId]) of
            {MatchPlayerId, RefusedMoney} when is_integer(MatchPlayerId) andalso MatchPlayerId =:= PlayerId ->
                RefusedMoney;
            {MatchPlayerId, _RefusedMoney} when is_integer(MatchPlayerId) ->
                ?ERROR("PlayerId not match: ~p ~p", [MatchPlayerId, PlayerId]), 0;
            {'EXIT', R} -> ?ERROR("call charge_server mod_google_pay:chk_player_has_refused failure: ~p", [R]), 100;
            {_, Other1} -> ?ERROR("undefined error: ~p", [Other1]), 100
        end,
    ?DEBUG("PlayerRefusedMoney； ~p ~p", [PlayerRefusedMoney, {PlayerRefusedMoney > 0, IsNativePay}]),
    if
        PlayerRefusedMoney > 0 ->
            ?INFO("has refused. send mail to warn player"),
            mod_mail:add_mail_id(PlayerId, ?MAIL_CHARGE_AFTER_REFUSED, ?LOG_TYPE_CHARGE_SEND);
        true ->
            ?INFO("no refused")
    end,
    Fun = fun() ->
        case Currency of
            ?REGION_CURRENCY_TW ->
                %% @todo 以下7行代码需要在装备交易平台接口完成对接后直接删除
                ?INFO("测试环境下，使用zf999提供的支付接口"),
%%                case zf999:pay(PlayerId, ChargeType, PlatformItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId) of
%%                    {ok, PayInfo} -> {ok, PayInfo};
%%                    _ERROR -> _ERROR
%%                end;
                case props_trader:pay(PlayerId, ChargeType, PlatformItemId, GameChargeId, Money, ChargeIngot,
                    PlatformId, ServerId, Currency) of
                    {ok, PayInfo} -> {ok, PayInfo};
                    _ERROR -> _ERROR
                end;
            ?PLATFORM_TEST ->
                ?INFO("调用装备交易平台提供的支付接口，使用台湾地区的支付通道"),
                case props_trader:pay(PlayerId, ChargeType, PlatformItemId, GameChargeId, Money, ChargeIngot,
                    PlatformId, ServerId, Currency) of
                    {ok, PayInfo} -> {ok, PayInfo};
                    _ERROR -> _ERROR
                end;
            _ ->
                ?INFO("调用zf999提供的支付接口，使用印尼地区的支付通道")
        end
          end,
    if
        IsNativePay =:= 1 andalso (OSPlatform =:= ?OS_PLATFORM_ANDROID orelse OSPlatform =:= ?OS_PLATFORM_IOS) ->
            case OSPlatform of
                ?OS_PLATFORM_ANDROID -> % 安卓系统充值
                    case ios_android_charge_handle:pay(PlayerId, ChargeType, PlatformItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId, ?SOURCE_CHARGE_FROM_GOOGLE) of
                        {ok, PayInfo} ->
                            {ok, PayInfo};
                        _ERROR ->
                            _ERROR
                    end;
                ?OS_PLATFORM_IOS -> % ios系统充值
                    case ios_android_charge_handle:pay(PlayerId, ChargeType, PlatformItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId, ?SOURCE_CHARGE_FROM_APP_STORE) of
                        {ok, PayInfo} ->
                            {ok, PayInfo};
                        _ERROR ->
                            _ERROR
                    end
            end;
        true ->
            Fun()
    end.

%% ----------------------------------
%% @doc 	直购礼包是否完成
%% @throws 	none
%% @end
%% ----------------------------------
check_zhi_gou_completed(PlayerId) ->
    #db_player{
        from = OsPlatFrom
    } = mod_player:get_player(PlayerId),
    OsType =
        case OsPlatFrom of
            ?OS_PLATFORM_ANDROID -> 1;
            ?OS_PLATFORM_IOS -> 2;
            _ -> 0
        end,

    lists:all(
        fun({RechargeId}) ->
            case t_recharge:get({RechargeId}) of
                %% 对应平台的直购礼包充值id
                #t_recharge{type = OsType, recharge_type = ?CHARGE_GAME_ZHI_GOU} ->
                    ShopIdList = [ShopId0 || {_, _, ShopId0} <- logic_get_charge_http_recharge_id_list(RechargeId)],
                    lists:all(
                        fun(ShopId) ->
                            %% 是否全部购买完成
                            mod_shop:is_shop_count_limit(PlayerId, ShopId)
                        end,
                        ShopIdList
                    );
                _ ->
                    true
            end
        end, t_recharge:get_keys()
    ).

%% @fun 请求充值http参数
get_charge_http_param_info(_PlayerId) ->
%%    #db_player{
%%        acc_id = AccId
%%    } = mod_player:get_player(PlayerId),
%%    PlatformId = mod_server_config:get_platform_id(),
%%    case PlatformId of
%%        ?PLATFORM_WX ->
%%            {ok, weixin:get_charge_http_param_info(PlayerId, AccId)};
%%        _ ->
    {ok, []}.
%%    end.

%% @fun 请求充值玩家充值数据
game_player_charge_data(ServerId, NickName) ->
    PlayerId =
        lists:foldl(
            fun(Player, PlayerId1) ->
                case Player of
                    #db_player{server_id = ServerId, id = PlayerId2} ->
                        PlayerId2;
                    _ ->
                        PlayerId1
                end
            end, 0, mod_player:get_player_list_by_nickname(NickName)),
    ?ASSERT(PlayerId > 0, ?ERROR_NOT_EXISTS),
    Level = mod_player:get_player_data(PlayerId, level),
    WebUrl = mod_server_config:get_game_web_url(),
    ParamList = [
        {request_url, WebUrl},
        {level, Level},
        {player_id, util:to_list(PlayerId)}
    ],
    {ok, ServerId, ParamList}.

%% @fun 获得充值http商场数据
get_charge_http_shop_info(PlayerId) ->
    ?ASSERT(is_record(mod_player:get_player(PlayerId), db_player), null_player_id),
    PlatformId = util:to_atom(mod_server_config:get_platform_id()),
    ServerId = mod_player:get_player_server_id(PlayerId),
    NickName = mod_player:get_player_name(PlayerId),
    ActivityShopList =
        lists:foldl(
            fun({Type, TypeName, ActivityId}, L) ->
                ActivityIsOpen = ?IF(ActivityId > 0, activity:is_open(ActivityId), true),
                if
                    ActivityIsOpen == true ->
                        {_, ValueList} = logic_get_charge_http_type_value_list(Type),
                        NewValueList =
                            lists:foldl(
                                fun({ChargeItemId, ConditionList, ShopId}, ValueL) ->
                                    case check_recharge_shop(PlayerId, ActivityId, ConditionList, ShopId) of
                                        true ->
                                            #t_recharge{
                                                buy_limit = BuyLimit,
                                                remark = RechargeName,
                                                cash = Money,
                                                ingot = Ingot,
                                                have_pf_list = HavePlatformList,
                                                remove_pf_list = RemovePlatformList
                                            } = try_get_t_recharge(ChargeItemId),
                                            IsPlatform =
                                                case lists:member(PlatformId, RemovePlatformList) of
                                                    true -> false;
                                                    _ ->
                                                        case HavePlatformList of
                                                            [] -> true;
                                                            _ -> lists:member(PlatformId, HavePlatformList)
                                                        end
                                                end,
                                            case IsPlatform of
                                                false -> ValueL;
                                                _ ->
                                                    #db_player_charge_shop{
                                                        count = PlayerCount
                                                    } = get_player_charge_shop_init(PlayerId, ChargeItemId),
                                                    if
                                                        BuyLimit > PlayerCount orelse BuyLimit == 0 ->
                                                            [{ChargeItemId, RechargeName, Money, Ingot} | ValueL];
                                                        true ->
                                                            ValueL
                                                    end
                                            end;
                                        _ ->
                                            ValueL
                                    end
                                end, [], ValueList),
                        if
                            NewValueList =/= [] ->
                                [{Type, TypeName, util_list:rSortKeyList([{false, 1}], NewValueList)} | L];
                            true ->
                                L
                        end;
                    true ->
                        L
                end
            end, [], logic_get_charge_http_type_list()),
    {NickName, ServerId, ActivityShopList}.

%% @fun web游戏服充值返回带条件
web_game_charge_conditions(Ip, OrderId, GameOrderNoStr, MoneyFloat, ConditionsParam) ->
    web_game_charge(Ip, OrderId, GameOrderNoStr, MoneyFloat, {}, ConditionsParam).
%% @fun web游戏服充值返回
web_game_charge(Ip, OrderId, GameOrderNoStr, MoneyFloat) ->
    web_game_charge(Ip, OrderId, GameOrderNoStr, MoneyFloat, {}).
web_game_charge(Ip, OrderId, GameOrderNoStr, MoneyFloat, ReportParam) ->
    web_game_charge(Ip, OrderId, GameOrderNoStr, MoneyFloat, ReportParam, 0).
web_game_charge(Ip, OrderId, GameOrderNoStr, MoneyFloat, ReportParam, ConditionsParam) ->
    {PlayerId, ChargeType, PlatformItemId, ItemCount} =
        case encode_game_order_id(GameOrderNoStr) of
            [PlayerId1, ChargeType1, PlatformItemId1, ItemCount1] ->
                {util:to_int(PlayerId1), util:to_int(ChargeType1), util:to_int(PlatformItemId1), util:to_int(ItemCount1)};
            _ ->
                exit(?ERROR_NONE)
        end,
    #t_recharge{
        cash = SingleMoney,
        recharge_type = GameChargeId,
%%        ingot = SingleValue
        ingot = _Ingot,
        diamond = SingleValue
    } = try_get_t_recharge(PlatformItemId),
    ChargeIngot = SingleValue * ItemCount,
    CalcMoney = SingleMoney * ItemCount,
    NewMoneyFloat =
        if
            MoneyFloat > 0 ->
                ?ASSERT(CalcMoney - 1 < MoneyFloat, money),
                MoneyFloat;
            true ->
                CalcMoney
        end,
%%    ?ASSERT(SingleMoney * ItemCount == MoneyFloat, money),
%%    ?INFO("web游戏服充值返回 ~p~n", [{Ip, OrderId, GameOrderNoStr, MoneyFloat}]),
    Result = common_game_charge(PlayerId, GameChargeId, PlatformItemId, ChargeType, NewMoneyFloat, ChargeIngot, OrderId, Ip, ""),
    ?IF(ChargeType == ?CHARGE_TYPE_NORMAL, charge_report(PlayerId, PlatformItemId, OrderId, NewMoneyFloat, ChargeIngot, ReportParam), noop),
    ?TRY_CATCH(platform_change_rebate(PlayerId, PlatformItemId, ChargeIngot, ConditionsParam)),
    Result.

%% @doc fun 平台充值后返利
platform_change_rebate(_PlayerId, _PlatformItemId, _ChargeIngot, _ConditionsParam) ->
%%    case mod_server_config:get_platform_id() of
%%        ?PLATFORM_WX ->
%%            if
%%                ConditionsParam == 1 ->
%%                    RebateIngot = ChargeIngot,
%%                    ?INFO("平台充值后返利:~p~n", [{PlatformItemId, ChargeIngot, RebateIngot}]),
%%                    if
%%%%                        @TODO 充值元宝返利屏蔽
%%%%                        RebateIngot > 0 andalso PlatformItemId > 0 ->
%%%%                            mod_mail:add_mail_param_item_list(PlayerId, ?MAIL_PINGTAI_CHONGZHI_FANLI, [[?PROP_TYPE_RESOURCES, ?RES_INGOT, RebateIngot]], [RebateIngot], ?LOG_TYPE_CHARGE_SEND);
%%                        true -> noop end;
%%                true -> noop
%%            end;
%%        _ -> noop
%%    end.
    noop.

%%-------------------------------
%% @doc     玩家充值
%% @throws  none
%% @end
%%-------------------------------
deal_charge(ServerId, AccId, GameChargeId, Money, ChargeIngot, OrderId, ChargeType) ->
    Player = mod_player:get_player_by_server_id_and_acc_id(ServerId, AccId),
    ?ASSERT(is_record(Player, db_player), ?ERROR_NOT_EXISTS),
    PlayerId = Player#db_player.id,
    OldPlayerCharge = get_player_charge(OrderId),
    ?DEBUG("====================== charge"),
    ?ASSERT(is_record(OldPlayerCharge, db_player_charge_record) == false, ?ERROR_ALREADY_HAVE),
    deal_charge_body(PlayerId, GameChargeId, ?CHANGE_ITEM_ID_0, Money, ChargeIngot, OrderId, ChargeType, "").

%% @doc     充值服回调游戏服充值
charge_server_game_charge(ServerId, AccId, ChargeType, ChargeItemId, ItemCount, OrderId, Ip, Param) ->
    Player = mod_player:get_player_by_server_id_and_acc_id(ServerId, AccId),
    ?ASSERT(is_record(Player, db_player), ?ERROR_NOT_EXISTS),
    PlayerId = Player#db_player.id,
    OldPlayerCharge = get_player_charge(OrderId),
    ?ASSERT(is_record(OldPlayerCharge, db_player_charge_record) == false, ?ERROR_ALREADY_HAVE),
    charge_server_charge(PlayerId, ChargeType, ChargeItemId, ItemCount, OrderId, Ip, Param).

%% @fun 充值服回调充值
charge_server_charge(PlayerId, ChargeType, ChargeItemId, ItemCount, OrderId, Ip) ->
    charge_server_charge(PlayerId, ChargeType, ChargeItemId, ItemCount, OrderId, Ip, {}).
charge_server_charge(PlayerId, ChargeType, ChargeItemId, ItemCount, OrderId, Ip, Param) ->
    OldPlayerCharge = get_player_charge(OrderId),
    ?INFO("充值服回调充值 订单是否存在:~p => ~p~n", [is_record(OldPlayerCharge, db_player_charge_record), {mod_server_config:get_platform_id(), PlayerId, ChargeType, ChargeItemId, ItemCount, OrderId, Ip}]),
    ?ASSERT(is_record(OldPlayerCharge, db_player_charge_record) == false, ?ERROR_ALREADY_HAVE),
    if
        ChargeItemId > 0 ->
            #t_recharge{
                recharge_type = GameChargeId,
                cash = SingleMoney,
                ingot = SingleValue
            } = try_get_t_recharge(ChargeItemId),
            {ChargeRewardList, PlayerCount} = check_activity_charge(PlayerId, GameChargeId, ChargeItemId),
            ChargeIngot1 = SingleValue * ItemCount,
            Money = SingleMoney * ItemCount,
            ChargeIngot = calc_count_ingot(ChargeRewardList, PlayerCount, ChargeIngot1),
            Result = deal_charge_body(PlayerId, GameChargeId, ChargeItemId, Money, ChargeIngot, OrderId, ChargeType, Ip),
            ?IF(ChargeType == ?CHARGE_TYPE_NORMAL, charge_report(PlayerId, ChargeItemId, OrderId, Money, ChargeIngot, Param), noop),
            {ok, GameChargeId, Money, ChargeIngot, Result};
        true ->
            exit(?ERROR_NONE)
    end.

deal_charge_body(PlayerId, GameChargeId, ChargeItemId, Money, ChargeIngot, OrderId, ChargeType, Ip) ->
    if
        ChargeType == ?GM_CHARGE_TYPE_ALL orelse
            ChargeType == ?GM_CHARGE_TYPE_NOT_VIP orelse
            ChargeType == ?GM_CHARGE_TYPE_REPAIR orelse
            ChargeType == ?CHARGE_TYPE_GM_NORMAL orelse
            ChargeType == ?CHARGE_TYPE_NORMAL
            ->
            common_manage_charge(PlayerId, GameChargeId, ChargeItemId, Money, ChargeIngot, OrderId, ChargeType, Ip);
        ChargeType == ?GM_CHARGE_TYPE_I_INGOT ->
            ingot_charge(PlayerId, ChargeIngot);
        true ->
            exit(?ERROR_NONE)
    end.

%% @fun 计算充值次数元宝数
calc_count_ingot(ChargeRewardList, PlayerCount, ChargeIngot1) ->
    ?DEBUG("计算充值次数元宝数: ~p", [{ChargeRewardList, PlayerCount, ChargeIngot1}]),
    case ChargeRewardList of
        [Count, Rate] ->
            if
                PlayerCount < Count ->
                    ChargeIngot1 * Rate;
                true ->
                    ChargeIngot1
            end;
        _ ->
            ChargeIngot1
    end.

%%% 充值公共处理
%%common_manage(PlayerId, GameChargeId, Money, ChargeIngot, OrderId, ChargeType) ->
%%    OldPlayerCharge = get_player_charge(OrderId),
%%    ?ASSERT(is_record(OldPlayerCharge, db_player_charge_record) == false, ?ERROR_ALREADY_HAVE),
%%    common_manage_charge(PlayerId, GameChargeId, Money, ChargeIngot, OrderId, ChargeType).
common_manage_charge(PlayerId, GameChargeId, ChargeItemId, Money, ChargeIngot, OrderId, ChargeType, Ip) ->
    ?DEBUG("充值公共处理：~p~n", [{PlayerId, GameChargeId, Money, ChargeIngot, OrderId, ChargeItemId, ChargeType}]),
    CurrTime = util_time:timestamp(),
    PlayerChargeInit = get_player_charge_init(PlayerId, GameChargeId, ChargeItemId, util:to_float(Money), ChargeIngot, OrderId, ChargeType, Ip, CurrTime),
    ?ASSERT(PlayerChargeInit#db_player_charge_record.charge_state < ?CHARGE_STATE_9, ?ERROR_NOT_AUTHORITY),

    Tran =
        fun() ->
            db:write(PlayerChargeInit#db_player_charge_record{charge_state = ?CHARGE_STATE_9, change_time = CurrTime}),
            NoticeId =
                if
                    ChargeItemId > 0 ->
                        ChargeShopInit = get_player_charge_shop_init(PlayerId, ChargeItemId),
                        NewCount = ChargeShopInit#db_player_charge_shop.count + 1,
                        db:write(ChargeShopInit#db_player_charge_shop{count = NewCount, change_time = CurrTime}),
                        #t_recharge{
                            name = RechargeName,
                            notice_id = NoticeId1
                        } = try_get_t_recharge(ChargeItemId),
                        #t_charge_game{
                            mail_id = MailId
                        } = try_get_t_charge_game(GameChargeId),
%%                        db:tran_apply(fun() -> api_charge:notice_charge_data(PlayerId, ChargeItemId, NewCount) end),
                        if
                            MailId > 0 ->
                                mod_mail:add_mail_param(PlayerId, MailId, [RechargeName], ?LOG_TYPE_CHARGE_GET);
                            true ->
                                mod_mail:add_mail_param(PlayerId, ?MAIL_EVERY_PAY, [ChargeIngot], ?LOG_TYPE_CHARGE_GET)
                        end,
                        NoticeId1;
                    true ->
                        mod_mail:add_mail_param(PlayerId, ?MAIL_EVERY_PAY, [ChargeIngot], ?LOG_TYPE_CHARGE_GET),
                        0
                end,
            case get(?DICT_PLAYER_ID) == PlayerId of
                true ->
                    apply_online_charge_data(PlayerId, GameChargeId, ChargeItemId, Money, ChargeIngot, CurrTime, ChargeType, ?LOG_TYPE_CHARGE_GET);
                _ ->
                    mod_apply:apply_to_online_player(PlayerId, ?MODULE, apply_online_charge_data, [PlayerId, GameChargeId, ChargeItemId, Money, ChargeIngot, CurrTime, ChargeType, ?LOG_TYPE_CHARGE_GET], store)
            end,

            if
                GameChargeId == ?CHARGE_GAME_ZHI_GOU ->
                    ?TRY_CATCH(mod_shop:add_charge_shop_data(PlayerId, ChargeItemId));
                true ->
                    noop
            end,
            ?TRY_CATCH(mod_conditions:add_conditions(PlayerId, {?CON_ENUM_RECHARGE_MONEY_DALIY, ?CONDITIONS_VALUE_ADD, util:to_int(Money)})),
            ?TRY_CATCH(mod_conditions:add_conditions(PlayerId, {?CON_ENUM_RECHARGE_MONEY, ?CONDITIONS_VALUE_ADD, util:to_int(Money)})),
            ?TRY_CATCH(mod_conditions:add_conditions(PlayerId, {?CON_ENUM_CHARGE_COUNT, ?CONDITIONS_VALUE_ADD, 1})),
%%            ?TRY_CATCH(mod_promote:charge(PlayerId, Money)),
%%            mod_award:give_apply(PlayerId, [{?PROP_TYPE_RESOURCES, ?RES_INGOT, ChargeIngot}], ?LOG_TYPE_CHARGE_GET),
%%            apply_online_charge_data(PlayerId, Money, ChargeIngot, CurrTime, ?LOG_TYPE_CHARGE_GET),
            mod_log:write_charge_log(PlayerId, ChargeType, Money, ChargeIngot, OrderId, CurrTime),
            ?IF(NoticeId > 0, mod_chat:recharge_notice(NoticeId, PlayerId, Money), noop),
%%            mod_mail:add_mail_param(PlayerId, ?MAIL_EVERY_PAY, [{?I_INGOT, ChargeIngot}], ?OT_CHARGE_GET),
            ok
        end,
    db:do(Tran),
    charge_result(PlayerId).

%% @fun 在线处理数据
apply_online_charge_data(PlayerId, GameChargeId, ChargeItemId, Money, ChargeIngot, CurrTime, ChargeType, LogType) ->
    #t_recharge{
        vip_exp = VipExp,
        type = Type,
        reward_item_list = RewardItemList
    } = try_get_t_recharge(ChargeItemId),

    #t_charge_game{
        is_ingot = IsIngot
    } = try_get_t_charge_game(GameChargeId),

    if
        IsIngot == 1 ->
            mod_award:give(PlayerId, [{?ITEM_RMB, ChargeIngot}], LogType),
            mod_promote:charge(PlayerId, 0, ChargeIngot);
        IsIngot == 2 ->
            mod_award:give(PlayerId, [{?ITEM_GOLD, ChargeIngot}], LogType),
            mod_promote:charge(PlayerId, ChargeIngot, 0);
        true ->
            noop
    end,

    if
        %% 直购等级
        GameChargeId =:= ?CHARGE_GAME_ZHI_GOU_LEVEL ->
            [TargetLevel, _, _, _] =
                case Type of
                    1 ->
                        %% 谷歌充值
                        util_list:key_find(ChargeItemId, 2, ?SD_LEVEL_ZHIGOU_LIST);
                    2 ->
                        %% 苹果充值
                        util_list:key_find(ChargeItemId, 3, ?SD_LEVEL_ZHIGOU_LIST);
                    0 ->
                        %% 第三方充值
                        util_list:key_find(ChargeItemId, 4, ?SD_LEVEL_ZHIGOU_LIST)
                end,
            #db_player_data{
                level = Level
            } = mod_player:get_db_player_data(PlayerId),
            mod_player:add_level(PlayerId, max(0, TargetLevel - Level), LogType),
            ok;
        true ->
            noop
    end,
    if
        ChargeType =/= ?GM_CHARGE_TYPE_NOT_VIP andalso ChargeItemId > 0 ->
            ?IF(VipExp > 0, mod_vip:add_vip_exp(PlayerId, VipExp, CurrTime, LogType), noop);
        true ->
            noop
    end,
    if
        RewardItemList =/= [] ->
            mod_award:give(PlayerId, RewardItemList, LogType);
        true ->
            noop
    end,
    hook:after_recharge(PlayerId, ChargeItemId, Money).


%% @fun 充值后给充值服结果数据
charge_result(PlayerId) ->
    #db_player_data{
        level = Level,
        power = Power
    } = mod_player:get_db_player_data(PlayerId),
    #db_player{
        channel = ChannelId,
        friend_code = FriendCode
    } = mod_player:get_player(PlayerId),
    {ok, PlayerId, {
        Level,
        mod_task:get_player_task_id(PlayerId),
        mod_player:get_player_data(PlayerId, reg_time),
        Power,
        ChannelId,
        ?IF(FriendCode == "", ?FALSE, ?TRUE),
        mod_prop:get_player_prop_num(PlayerId, ?ITEM_GOLD),
        mod_prop:get_player_prop_num(PlayerId, ?ITEM_RMB),
        mod_prop:get_player_prop_num(PlayerId, ?ITEM_RUCHANGJUAN)}
    }.
%%    {ok, PlayerId, {Level, mod_conditions:get_player_conditions_data_number(PlayerId, ?CON_ENUM_TASK), 11111, Power}}.

%% @fun 充值上报
charge_report(PlayerId, ChargeItemId, OrderId, Money, ChargeIngot, ReportParam) ->
    spawn(fun() -> charge_report1(PlayerId, ChargeItemId, OrderId, Money, ChargeIngot, ReportParam) end).
charge_report1(PlayerId, ChargeItemId, _OrderId, _MoneyFloat, _ChargeIngot, _ReportParam) ->
%%    #db_player{
%%        acc_id = AccId,
%%        server_id = ServerId
%%    } = mod_player:get_player(PlayerId),
%%    #t_recharge{
%%        name = ItemName
%%    } = try_get_t_recharge(ChargeItemId),
%%    Channel = mod_player:get_player_channel(PlayerId),
%%    MoneyStr = util:to_list(MoneyFloat),
    PlatformId = mod_server_config:get_platform_id(),
%%     天合游戏上报
%%    erlang:spawn(fun() ->
%%        RealMoneyFloat =
%%%%            if PlatformId == ?PLATFORM_GAT ->
%%%%                MoneyFloat / 5;
%%%%                true ->
%%                    MoneyFloat,
%%%%            end,
%%        thyz:report_charge(PlayerId, OrderId, "", RealMoneyFloat, ChargeItemId, ItemName, util_time:timestamp()) end),
    IsNoticeApi =
%%        if
%%            PlatformId == ?PLATFORM_QQ andalso ReportParam =/= ?CHANNEL_QQ_GAME ->
%%                false;
%%            true ->
%%                Channel = mod_player:get_player_channel(PlayerId),
%%                if
%%                    PlatformId == ?PLATFORM_VM
%%                        andalso Channel == ?CHANNEL_TT
%%                        orelse PlatformId == ?PLATFORM_AF
%%                        andalso Channel == ?CHANNEL_HORTOR
%%                        ->
%%                        false;
%%                    true ->
    true,
%%                end
%%        end,
    ?IF(IsNoticeApi == true, api_charge:api_charge(PlayerId, ChargeItemId), noop), % 通知支付成功
    case PlatformId of
        _ ->
            noop
    end.


%% 获得是否开启充值
get_is_open_charge(PlayerId) ->
    case mod_server_config:get_platform_id() of
%%        ?PLATFORM_WX ->
%%            IsOpenCharge = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_CHARGE),
%%            IsOpenCharge == ?TRUE;
        _ ->
            mod_player:get_player_data(PlayerId, level) >= 50
    end.

%% 更新开启充值数据
update_is_open_charge(PlayerId) ->
    IsOpenCharge = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_CHARGE),
    if
        IsOpenCharge =/= ?TRUE ->
            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_CHARGE, ?TRUE),
            ?INFO("更新开启充值数据:~p", [PlayerId]),
            api_charge:notice_is_open_charge(PlayerId, ?TRUE);
        true ->
            noop
    end.


%% 获得玩家时间内充值的元宝数
get_charge_time_value(PlayerId, Time) ->
    ZeroTime = util_time:get_today_zero_timestamp(Time),
    get_charge_time_value(PlayerId, ZeroTime, ZeroTime + ?DAY_S - 1).
get_charge_time_value(PlayerId, InitTime, EndTime) ->
    get_charge_time_money(PlayerId, InitTime, EndTime, value).

%% 获得玩家时间内充值的充值元宝数
get_charge_time_ingot(PlayerId, Time) ->
    ZeroTime = util_time:get_today_zero_timestamp(Time),
    get_charge_time_ingot(PlayerId, ZeroTime, ZeroTime + ?DAY_S - 1).
get_charge_time_ingot(PlayerId, InitTime, EndTime) ->
    get_charge_time_money(PlayerId, InitTime, EndTime, chargeIngot).

%% 获得玩家时间内充值的人民币    单位：元
get_charge_time_money(PlayerId, Time) ->
    ZeroTime = util_time:get_today_zero_timestamp(Time),
    get_charge_time_money(PlayerId, ZeroTime, ZeroTime + ?DAY_S - 1).
get_charge_time_money(PlayerId, InitTime, EndTime) ->
    Money = get_charge_time_money(PlayerId, InitTime, EndTime, money),
    util:to_float(Money).
get_charge_time_money(PlayerId, InitTime, EndTime, ChargeType) ->
    lists:foldl(
        fun(#db_player_charge_record{create_time = ChargeTime, value = Ingot, charge_item_id = ChargeItemId, money = Money, charge_state = ChargeState}, ChargeNum) ->
            if
                ChargeState == ?CHARGE_STATE_9 andalso InitTime =< ChargeTime andalso ChargeTime =< EndTime ->
                    if
                        ChargeType == value ->
                            ChargeNum + Ingot;
                        ChargeType == chargeIngot ->
                            #t_recharge{
                                ingot = ChargeIngot
                            } = try_get_t_recharge(ChargeItemId),
                            ChargeNum + ChargeIngot;
                        true ->
                            ChargeNum + Money
                    end;
                true ->
                    ChargeNum
            end
        end, 0, get_index_player_charge_record_1(PlayerId)).

%% @fun 获得时间内的人民币       单位：元
get_charge_time_list_money(PlayerId, TimeList) ->
    List = get_charge_time_list_value(PlayerId, TimeList, money),
    [{Key, util:to_float(Money)} || {Key, Money} <- List].
%% @fun 获得时间内的人民币
get_charge_time_list_value(_PlayerId, [], _ChargeType) ->
    [];
get_charge_time_list_value(PlayerId, TimeList, ChargeType) ->
    lists:foldl(
        fun(#db_player_charge_record{create_time = ChargeTime, value = Ingot, money = Money, charge_state = ChargeState}, List) ->
            if
                ChargeState == ?CHARGE_STATE_9 ->
                    case is_charge_time(TimeList, ChargeTime) of
                        {true, Key} ->
                            V = ?IF(ChargeType == value, Ingot, Money),
                            case lists:keytake(Key, 1, List) of
                                {value, {Key, OldValue}, L} ->
                                    [{Key, OldValue + V} | L];
                                _ ->
                                    [{Key, V} | List]
                            end;
                        _ ->
                            List
                    end;
                true ->
                    List
            end
        end, [], get_index_player_charge_record_1(PlayerId)).

is_charge_time([], _) ->
    {false, noop};
is_charge_time([{InitTime, EndTime} | TimeList], ChargeTime) ->
    if
        InitTime =< ChargeTime andalso ChargeTime =< EndTime ->
            {true, {InitTime, EndTime}};
        true ->
            is_charge_time(TimeList, ChargeTime)
    end.


% 元宝充值
ingot_charge(PlayerId, _ChargeIngot) ->
%%    @TODO 元宝充值屏蔽
%%    mod_award:give_apply(PlayerId, [{?PROP_TYPE_RESOURCES, ?RES_INGOT, ChargeIngot}], ?LOG_TYPE_GM),
    charge_result(PlayerId).

%% 创建充值订单
create_order(PlayerId, GameChargeId, ChargeItemId, ChargeType, Money, ChargeIngot1, OrderId, Ip, _GmId, Rate, Source) ->
    %% 检查是否为真实用户
    ?ASSERT(mod_player:is_robot_player_id(PlayerId) == false, ?ERROR_NO_ROLE),
    Player = mod_player:get_player(PlayerId),
    ?ASSERT(is_record(Player, db_player), ?ERROR_NOT_EXISTS),

    %% 检查订单是否存在
    {ChargeRewardList, PlayerCount} = check_activity_charge(PlayerId, GameChargeId, ChargeItemId),
    ChargeIngot = calc_count_ingot(ChargeRewardList, PlayerCount, ChargeIngot1),
    MoneyFloat = util:to_float(Money),
    CurrTime = util_time:timestamp(),
    PlayerChargeInit = get_player_charge_init(PlayerId, GameChargeId, ChargeItemId, MoneyFloat, ChargeIngot, OrderId, ChargeType, Ip, CurrTime),
    #db_player_charge_record{
        charge_state = ChargeState
    } = PlayerChargeInit,
    ?ASSERT(ChargeState =:= ?CHARGE_STATE_0, ?ERROR_ALREADY_HAVE),

    %% 创建订单记录
    Tran =
        fun() ->
            db:write(PlayerChargeInit#db_player_charge_record{
                charge_state = ?CHARGE_STATE_1,
                change_time = CurrTime,
                rate = Rate, source = Source
            })
        end,
    Do = db:do(Tran),
    ?INFO("创建新订单: ~p", [Do]),
    ok.
%% @fun 游戏服公共充值 且上报
common_game_charge(PlayerId, GameChargeId, ChargeItemId, ChargeType, Money, ChargeIngot1, OrderId, Ip, GmId) ->
    common_game_charge(PlayerId, GameChargeId, ChargeItemId, ChargeType, Money, ChargeIngot1, OrderId, Ip, GmId, "").
common_game_charge(PlayerId, GameChargeId, ChargeItemId, ChargeType, Money, ChargeIngot1, OrderId, Ip, GmId, TxOrderId) ->
    {ChargeState, ChargeFrom} =
        case get_player_charge(OrderId) of
            PlayerCharge when is_record(PlayerCharge, db_player_charge_record) ->
                {PlayerCharge#db_player_charge_record.charge_state, PlayerCharge#db_player_charge_record.source};
            _ ->
                {?CHARGE_STATE_0, ?SOURCE_CHARGE_FROM_GOOGLE}
        end,
    ?ASSERT(ChargeState < ?CHARGE_STATE_9, ?ERROR_ALREADY_HAVE),
    ?ASSERT(mod_player:is_robot_player_id(PlayerId) == false, ?ERROR_NO_ROLE),
    Player = mod_player:get_player(PlayerId),
    ?ASSERT(is_record(Player, db_player), ?ERROR_NOT_EXISTS),
%%    ?ASSERT(is_record(OldPlayerCharge, db_player_charge_record) == false, ?ERROR_ALREADY_HAVE),
    {ChargeRewardList, PlayerCount} = check_activity_charge(PlayerId, GameChargeId, ChargeItemId),

%%    Player = mod_player:get_player(PlayerId),
%%    MoneyFloat = util:to_float(Money) + 0.1,
%%    ?ASSERT(is_record(Player, db_player), ?ERROR_NOT_EXISTS),
    #db_player{
        server_id = ServerId,
        acc_id = AccId
    } = Player,
    MoneyFloat = util:to_float(Money),
    ChargeIngot = calc_count_ingot(ChargeRewardList, PlayerCount, ChargeIngot1),
    PlatformId = mod_server_config:get_platform_id(),
    Result = charge_result(PlayerId),
    CurrTime = util_time:timestamp(),
    ?DEBUG("ChargeState ChargeFrom: ~p", [{ChargeState, ChargeFrom}]),
    RpcState =
        if
            ChargeState < ?CHARGE_STATE_2 -> % 当没有上报时
                case catch rpc:call(mod_server_config:get_charge_node(), mod_charge_server, game_charge,
                    [node(), PlayerId, PlatformId, ServerId, AccId, GameChargeId, ChargeItemId,
                        MoneyFloat, ChargeIngot, OrderId, Ip, ChargeType, {GmId, Result}, ChargeFrom]) of
                    ok ->
                        PlayerChargeInit2 = get_player_charge_init(PlayerId, GameChargeId, ChargeItemId, MoneyFloat,
                            ChargeIngot, OrderId, ChargeType, Ip, CurrTime),
                        Tran2 =
                            fun() ->
                                db:write(PlayerChargeInit2#db_player_charge_record{
                                    charge_state = ?CHARGE_STATE_2, change_time = CurrTime, platform_order_id = TxOrderId})
                            end,
                        Do = db:do(Tran2),
                        ?DEBUG("do: ~p", [Do]),
                        ok;
                    R1 ->
                        ?ERROR("游戏服公共充值 且上报: ~p", [R1]),
                        R1
                end;
            true ->
                ok
        end,
    case RpcState of
        ok ->
            deal_charge_body(PlayerId, GameChargeId, ChargeItemId, MoneyFloat, ChargeIngot, OrderId, ChargeType, Ip),
            logger2:write(charge_report_success, {PlayerId, GameChargeId, ChargeType, MoneyFloat, ChargeIngot, OrderId, Ip, GmId}),
            ok;
        R ->
            if
                ChargeState < ?CHARGE_STATE_1 ->    % 当没有创建时
                    PlayerChargeInit1 = get_player_charge_init(PlayerId, GameChargeId, ChargeItemId, MoneyFloat, ChargeIngot, OrderId, ChargeType, Ip, CurrTime),
                    Tran1 =
                        fun() ->
                            db:write(PlayerChargeInit1#db_player_charge_record{charge_state = ?CHARGE_STATE_1, change_time = CurrTime, platform_order_id = TxOrderId})
                        end,
                    db:do(Tran1);
                true ->
                    noop
            end,
            ?ERROR("web_game_charge db:write error: ~p~n", [R]),
            logger2:write(charge_report_fail, {PlayerId, GameChargeId, ChargeType, MoneyFloat, ChargeIngot, OrderId, Ip, GmId, R}),
            exit(R)
    end.

%% @fun 获得全部失败的订单数据
get_fail_charge_list() ->
    lists:foldl(
        fun(Record, L1) ->
            #db_player_charge_record{
                order_id = OrderId,                  %% string 订单号
                player_id = PlayerId,                      %% int 玩家id
                type = ChargeType,                       %% int 充值类型,0:gm,99:正常充值
                game_charge_id = GameChargeId,             %% int 充值活动id,0:无活动
                charge_item_id = ChargeItemId,             %% int 充值道具id
                ip = Ip,                        %% string 充值时ip
                value = ChargeIngot,                      %% int 充值元宝
                money = Money,                    %% float 充值人民币/元
                charge_state = ChargeState,               %% int 充值订单状态1:创建2:上报9:完成
                create_time = _CreateTime                 %% int 创建时间
            } = Record,
            if
                ChargeState < ?CHARGE_STATE_9 ->
                    [{PlayerId, GameChargeId, ChargeItemId, ChargeType, util:to_float(Money), ChargeIngot, OrderId, Ip, ChargeState} | L1];
                true ->
                    L1
            end
        end, [], ets:tab2list(player_charge_record)).

%% @fun gm后台失败补充充值
gm_all_repair_charge(GmId) ->
    gm_repair_charge(get_fail_charge_list(), GmId).

gm_repair_charge([], _GmId) ->
    noop;
gm_repair_charge(OrderId, GmId) ->
    RepairList =
        case is_list(OrderId) of
            true ->
                OrderId;
            _ ->
                PlayerCharge = get_player_charge(OrderId),
                ?ASSERT(is_record(PlayerCharge, db_player_charge_record) == true, ?ERROR_NOT_EXISTS),
                #db_player_charge_record{
                    player_id = PlayerId,
                    game_charge_id = GameChargeId,
                    charge_item_id = ChargeItemId,
                    type = ChargeType,
                    ip = Ip,
                    money = Money,
                    value = ChargeIngot,
                    charge_state = ChargeState
                } = PlayerCharge,
                ?ASSERT(ChargeState < ?CHARGE_STATE_9, ?ERROR_ALREADY_HAVE),
                [{PlayerId, GameChargeId, ChargeItemId, ChargeType, util:to_float(Money), ChargeIngot, OrderId, Ip, ChargeState}]
        end,
    {SuccessList, FailList} =
        lists:foldl(
            fun({RepairPlayerId, RepairGameChargeId, RepairChargeItemId, RepairChargeType, RepairFloatMoney, RepairChargeIngot, RepairOrderId, RepairIp, _ChargeState}, {SuccessL, FailL}) ->
                case catch common_game_charge(RepairPlayerId, RepairGameChargeId, RepairChargeItemId, RepairChargeType, RepairFloatMoney, RepairChargeIngot, RepairOrderId, RepairIp, GmId) of
                    ok ->
                        {[{RepairOrderId, RepairFloatMoney} | SuccessL], FailL};
                    R ->
                        ?ERROR("gm_all_repair_charge: ~p  err:~p~n", [RepairOrderId, R]),
                        {SuccessL, [{RepairPlayerId, RepairOrderId} | FailL]}
                end
            end, {[], []}, RepairList),
    {ok, SuccessList, FailList}.

%% @fun gm全部充值数据订单上报
gm_all_repair() ->
    PlatformId = mod_server_config:get_platform_id(),
    RepairList =
        lists:foldl(
            fun(Record, L1) ->
                #db_player_charge_record{
                    order_id = OrderId,                  %% string 订单号
                    player_id = PlayerId,                      %% int 玩家id
                    type = ChargeType,                       %% int 充值类型,0:gm,99:正常充值
                    game_charge_id = GameChargeId,             %% int 充值活动id,0:无活动
                    charge_item_id = ChargeItemId,             %% int 充值道具id
                    ip = IP,                        %% string 充值时ip
                    value = Ingot,                      %% int 充值元宝
                    money = Money,                    %% float 充值人民币/元
                    charge_state = ChargeState,               %% int 充值订单状态1:创建2:上报9:完成
                    create_time = CreateTime                 %% int 创建时间
                } = Record,
                if
                    ChargeState == ?CHARGE_STATE_9 ->
                        Result = charge_result(PlayerId),
                        #db_player{
                            server_id = ServerId,
                            acc_id = AccId
                        } = mod_player:get_player(PlayerId),
                        [{PlatformId, ServerId, AccId, GameChargeId, ChargeItemId, util:to_float(Money), Ingot, OrderId, IP, ChargeType, "", CreateTime, Result} | L1];
                    true ->
                        L1
                end
            end, [], ets:tab2list(player_charge_record)),
    ?INFO("gm全部充值数据订单上报 ~p~n", [RepairList]),
    case catch rpc:call(mod_server_config:get_charge_node(), mod_charge_server, gm_game_node_all_repair, [node(), RepairList]) of
        {ok, RepairResultList} ->
            ?INFO("gm全部充值数据订单上报成功列表 ~p~n", [RepairResultList]),
            ok;
        R1 ->
            ?INFO("gm全部充值数据订单上报失败 ~p~n", [R1])
    end.

%% @doc fun 生成一个订单id
create_order_id(PlayerId, CurrTime, PlatformId) ->
    lists:flatten(io_lib:format("~w~s~s", [PlayerId, util_time:get_format_datetime_string_simple(CurrTime), PlatformId])).

%%%% @fun 打包游戏服充值回调参数
%%pack_game_order_id(PlayerId, ChargeType, PlatformItemId, ItemCount) ->
%%    util_list:change_list_url([PlayerId, ChargeType, PlatformItemId, ItemCount], "_").
%%
%%%% @fun 打包充值服回调整参数
%%pack_game_order_id(PackDataList) ->
%%    util_list:change_list_url(PackDataList, "_").
%%%% @fun 打包充值服回调整参数
%%pack_game_order_id(PartId, ServerId, PlayerId, ChargeType, PlatformItemId, ItemCount) ->
%%    util_list:change_list_url([PartId, ServerId, PlayerId, ChargeType, PlatformItemId, ItemCount], "_").
%%    lists:concat([PlayerId, "_", ChargeType, "_", PlatformItemId, "_", ItemCount]).
%% @fun 解析打包参数
encode_game_order_id(Str) ->
    string:tokens(Str, "_").
%% @doc fun 解析特殊条件
encode_game_conditions_param(Str) ->
    string:tokens(Str, "^").

%% @fun 检查充值数据合法
check_activity_charge(PlayerId, _GameChargeId, ChargeItemId) ->
    check_activity_charge(PlayerId, _GameChargeId, ChargeItemId, mod_server_config:get_platform_id()).
check_activity_charge(PlayerId, _GameChargeId, ChargeItemId, PlatformId1) ->
    ?DEBUG("检查充值数据合法: ~p", [{PlayerId, _GameChargeId, ChargeItemId, PlatformId1}]),
    PlatformId = util:to_atom(PlatformId1),
    if
        ChargeItemId > 0 ->
            #t_recharge{
                buy_limit = BuyLimit,
                remove_pf_list = RemovePlatformList,
                have_pf_list = HavePlatformList,
                recharge_reward_list = ChargeRewardList
            } = try_get_t_recharge(ChargeItemId),
%%            first_recharge:assert_first_recharge(PlayerId, ChargeItemId),
            IsPlatform =
                case lists:member(PlatformId, RemovePlatformList) of
                    true -> false;
                    _ ->
                        case HavePlatformList of
                            [] -> true;
                            _ ->
                                lists:member(PlatformId, HavePlatformList)
                        end
                end,
            ?ASSERT(IsPlatform == true, ?ERROR_FAIL),
            #db_player_charge_shop{
                count = PlayerCount
            } = get_player_charge_shop_init(PlayerId, ChargeItemId),
%%            ?DEBUG("~p", [{BuyLimit, PlayerCount, BuyLimit, {PlayerId, _GameChargeId, ChargeItemId, PlatformId1}}]),
            ?ASSERT(BuyLimit > PlayerCount orelse BuyLimit == 0, ?ERROR_TIMES_LIMIT),
            RechargeIdList = logic_get_charge_http_recharge_id_list(ChargeItemId),
            IsShop =
                lists:foldl(
                    fun({ActivityId, ConditionList, ShopId}, ShopState1) ->
                        case activity:is_open(ActivityId) of
                            true ->
                                if
                                    ShopState1 == true ->
                                        ShopState1;
                                    true ->
                                        check_recharge_shop(PlayerId, ActivityId, ConditionList, ShopId)
                                end;
                            _ ->
                                ShopState1
                        end
                    end, false, RechargeIdList),
            ?DEBUG("检查充值数据合法:~p~n", [{ChargeItemId, IsShop, RechargeIdList}]),
            ?ASSERT(IsShop == true orelse RechargeIdList == [] andalso IsShop == false, ?ERROR_TIMES_LIMIT),
            {ChargeRewardList, PlayerCount};
        true ->
            {[], 0}
    end.

%% @fun 检测充值商店
check_recharge_shop(PlayerId, _ActivityId, ConditionList, ShopId) ->
    IsCondition =
        case ConditionList of
            [ConditionStr, ConditionValue] ->
%%                PlayerValue = mod_activity_task:get_activity_task_condition_value(PlayerId, ActivityId, ConditionStr),
                PlayerValue = mod_conditions:get_player_conditions_data_number(PlayerId, ConditionStr),
                ?IF(ConditionValue == PlayerValue, true, false);
            _ ->
                true
        end,
    if
        IsCondition == true ->
            if
                ShopId > 0 ->
                    mod_shop:check_recharge_shop(PlayerId, ShopId);
                true ->
                    IsCondition
            end;
        true ->
            false
    end.

has_player_charged(PlayerId) ->
    case db:read(#key_player_charge_info_record{player_id = PlayerId}) of
        null -> 0;
        PlayerChargeCount ->
            #db_player_charge_info_record{
                charge_count = ChargeCount1
            } = PlayerChargeCount,
            ChargeCount1
    end.

%% @fun 获得充值商店数据列表
get_charge_shop_data_list(PlayerId) ->
    PlatformId = util:to_atom(mod_server_config:get_platform_id()),
    %% 该玩家所使用的app_id的nativePay为0，则使用第三方支付的数据，
    %% 反之则判断当前包是android还是ios，并返回对应的商品信息
    %% 具体判断的字段为recharge.csv的type字段，为0,第三方;为1,谷歌支付;2,苹果支付
    #db_player{
        acc_id = AccId,
        from = OSPlatform
    } = mod_player:get_player(PlayerId),
    AppId =
        case mod_server_rpc:call_center(mod_global_account, get_global_account_by_acc_id_platform,
            [util:to_list(PlatformId), AccId]) of
            R when is_tuple(R) -> ?ASSERT(R =:= error, ?ERROR_ALREADY_DIE);
            AppIdInDb -> AppIdInDb
        end,
    ?DEBUG("test: ~p ~p", [AppId, OSPlatform =:= ?OS_PLATFORM_IOS]),
    {IsNativePay, Region} =
        case mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, AppId]) of
            [SettingInEts] when is_record(SettingInEts, ets_erget_setting) ->
                #ets_erget_setting{
                    is_native_pay = IsNativePayInEts, region = RegionInEts
                } = SettingInEts,
                {IsNativePayInEts, RegionInEts};
            [] -> {1, ?REGION_CURRENCY_TW}
        end,
    ?DEBUG("IsNativePay: ~p ~p", [IsNativePay, mod_server_config:get_charge_node()]),
    UnFirstChargeItemList = logic_get_recharge_charge_type_list(?CHARGE_GAME_COMMON_CHARGE_DIAMOND) ++ logic_get_recharge_charge_type_list(?CHARGE_GAME_COMMON_CHARGE_COIN),
    %% 使用商店支付（谷歌支付或app store支付）时，判断当前登录玩家是否满足平台、玩家对切换支付的要求
    %% 若满足，则切换第三方支付，反之则继续使用谷歌支付
    ChargeCount =
        if
            IsNativePay =:= 1 ->
                %% 查询玩家已经支付过几笔订单;
                case catch rpc:call(mod_server_config:get_charge_node(), mod_charge, has_player_charged, [PlayerId]) of
                    PlayerChargeTimes when is_integer(PlayerChargeTimes) ->
                        PlayerChargeTimes;
                    R1 ->
                        ?INFO("到充值服获取指定玩家支付次数不符合预期: ~p", [R1]),
                        0
                end;
            true -> IsNativePay
        end,
    PlatformPayTimesLimits =
        case mod_server_rpc:call_center(mod_cache, get, [{platform_pay_times, PlatformId}]) of
%%        case mod_cache:get({platform_pay_times, PlatformId}) of
            PlatformLimit when is_integer(PlatformLimit) -> PlatformLimit;
            _ -> 99999
        end,
    PlayerPayTimesLimit =
        case mod_cache:get({player_pay_times, PlayerId}) of
            PlayerLimit when is_integer(PlayerLimit) -> PlayerLimit;
            _ -> 0
        end,
    ?INFO("OSPlatform: ~p, PlayerChargeCount: ~p, PlatformPayTimesLimits: ~p PlayerPayTimesLimit: ~p R: ~p",
        [OSPlatform, ChargeCount, PlatformPayTimesLimits, PlayerPayTimesLimit,
            ChargeCount >= PlatformPayTimesLimits andalso ChargeCount >= PlayerPayTimesLimit]),
    IsThirdPartyPay = ?IF(ChargeCount >= PlatformPayTimesLimits andalso ChargeCount >= PlayerPayTimesLimit, ?TRUE, ?FALSE),
    ChargeItemList =
        case OSPlatform of
            ?OS_PLATFORM_IOS ->
%%                ?IF(IsNativePay =:= 1, logic_get_recharge_type_list:get(2), logic_get_recharge_type_list:get(0));
                ?IF(IsNativePay =:= 1 andalso IsThirdPartyPay =:= ?FALSE,
                    logic_get_recharge_type_list:get(2), logic_get_recharge_type_list:get(0));
            ?OS_PLATFORM_ANDROID ->
%%                ?IF(IsNativePay =:= 1, logic_get_recharge_type_list:get(1), logic_get_recharge_type_list:get(0));
                ?IF(IsNativePay =:= 1 andalso IsThirdPartyPay =:= ?FALSE,
                    logic_get_recharge_type_list:get(1), logic_get_recharge_type_list:get(0));
            Other ->
                ?DEBUG("Other: ~p", [Other]),
                logic_get_recharge_type_list:get(0)
        end,
    RealChargeItemList = lists:filter(
        fun(ItemId) ->
            lists:member(ItemId, ChargeItemList)
        end,
        UnFirstChargeItemList
    ),
    ChargeItem =
        lists:filtermap(
            fun(E) ->
                #t_recharge{remove_pf_list = RemovePfList} = t_recharge:get({E}),
%%                ?DEBUG("eee: ~p", [{E, RemovePfList, string:lowercase(Region),
%%                    lists:member(util:to_atom(string:lowercase(Region)), RemovePfList)}]),
                ?IF(lists:member(util:to_atom(string:lowercase(Region)), RemovePfList) =:= false, {true, E}, false)
            end,
            RealChargeItemList
        ),
    %% isNativePay
    lists:foldl(
        fun(Id, L) ->
            #t_recharge{
                have_pf_list = HavePlatformList,
                remove_pf_list = RemovePlatformList
            } = try_get_t_recharge(Id),
            IsPlatform =
                case lists:member(PlatformId, RemovePlatformList) of
                    true -> false;
                    _ ->
                        case HavePlatformList of
                            [] -> true;
                            _ -> lists:member(PlatformId, HavePlatformList)
                        end
                end,
            case IsPlatform of
                false ->
                    L;
                _ ->
                    #db_player_charge_shop{
                        count = Count
                    } = get_player_charge_shop_init(PlayerId, Id),
                    [{Id, Count} | L]
            end
%%        end, [], logic_get_recharge_charge_type_list(?CHARGE_GAME_COMMON_CHARGE)).
%%        end, [], RealChargeItemList).
        end, [], ChargeItem).

%% @fun gm增加充值订单
gm_add_charge_record(PlayerId, Day, Money) ->
    OrderId = util:to_list(util_time:milli_timestamp() + Day * ?DAY_MS + util_random:random_number(1000)),
    CurrTime = util_time:timestamp(),
    CreateTime = CurrTime + Day * ?DAY_S,
    ChargeIngot = erlang:trunc(Money * 10),
    PlayerChargeInit = get_player_charge_init(PlayerId, 0, 0, util:to_float(Money), ChargeIngot, OrderId,
        ?CHARGE_TYPE_NORMAL, "127.0.0.1", CreateTime),
    Tran =
        fun() ->
            db:write(PlayerChargeInit#db_player_charge_record{charge_state = ?CHARGE_STATE_9, change_time = CurrTime})
        end,
    db:do(Tran).

%% ================================================ 数据操作 ================================================
%% 获得玩家充值记录
get_player_charge(OrderId) ->
    db:read(#key_player_charge_record{order_id = OrderId}).

%% 获得玩家充值记录 并初始化
get_player_charge_init(PlayerId, GameChargeId, ChargeItemId, Money, ChargeIngot, OrderId, ChargeType, Ip, CurrTime) ->
    case get_player_charge(OrderId) of
        PlayerCharge when is_record(PlayerCharge, db_player_charge_record) ->
            PlayerCharge;
        _ ->
            #db_player_charge_record{order_id = OrderId, player_id = PlayerId, game_charge_id = GameChargeId,
                charge_item_id = ChargeItemId, money = Money, value = ChargeIngot, type = ChargeType, ip = Ip,
                create_time = CurrTime}
    end.

%%  充值订单请求数据
get_charge_order_request_record(OrderId) ->
    db:read(#key_charge_order_request_record{order_id = OrderId}).

%%  充值订单请求数据    并初始化
get_charge_order_request_record_init(OrderId) ->
    case get_charge_order_request_record(OrderId) of
        ChargeOrder when is_record(ChargeOrder, db_charge_order_request_record) ->
            ChargeOrder;
        _ ->
            #db_charge_order_request_record{order_id = OrderId}
    end.

% 获得玩家的全部充值记录
get_index_player_charge_record_1(PlayerId) ->
    db_index:get_rows(#idx_player_charge_record_1{player_id = PlayerId}).

%% @fun 玩家平台充值商店id
get_player_charge_shop(PlayerId, ItemId) ->
    db:read(#key_player_charge_shop{player_id = PlayerId, id = ItemId}).
%% @fun 玩家平台充值商店id  并初始化
get_player_charge_shop_init(PlayerId, ItemId) ->
    case get_player_charge_shop(PlayerId, ItemId) of
        Charge when is_record(Charge, db_player_charge_shop) ->
            Charge;
        _ ->
            #db_player_charge_shop{player_id = PlayerId, id = ItemId}
    end.

%% ================================================ 模板操作 ================================================
%% @fun 获得游戏内充值id数据
try_get_t_charge_game(ChargeGameId) ->
    Table = t_charge_game:get({ChargeGameId}),
    ?IF(is_record(Table, t_charge_game), Table, exit({t_charge_game, {ChargeGameId}})).

%% @fun 获得平台物品数据
try_get_t_recharge(ItemId) ->
    Table = t_recharge:get({ItemId}),
    ?IF(is_record(Table, t_recharge), Table, exit({t_recharge, {ItemId}})).

%% @fun 获得qq平台充值商店列表
logic_get_recharge_charge_type_list(ChargeGameId) ->
    case logic_get_recharge_charge_type_list:get(ChargeGameId) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.

%% @fun 充值类型列表
logic_get_charge_http_type_value_list(Type) ->
    case logic_get_charge_http_type_value_list:get(Type) of
        {ActivityId, List} when is_list(List) ->
            {ActivityId, List};
        _ ->
            {0, []}
    end.

%% @fun 充值类型列表
logic_get_charge_http_type_list() ->
    case logic_get_charge_http_type_list:get(0) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.

%% @fun 充值http充值id的值列表
logic_get_charge_http_recharge_id_list(ChargeGameId) ->
    case logic_get_charge_http_recharge_id_list:get(ChargeGameId) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.

get_charge_name(RechargeId) ->
    #t_recharge{
        name = Name
    } = try_get_t_recharge(RechargeId),
    Name.

%% ----------------------------------
%% @doc 	修改安卓、IOS充值订单状态
%% @throws 	none
%% @end
%% ----------------------------------
change_ios_android_charge_state(OrderId, PlayerId, State, PlatformOrderId, Source) ->
%%    ?INFO("===> OrderId: ~p, PlayerId: ~p, State: ~p, Source ~p", [OrderId, PlayerId, State, Source]),
    ?ASSERT(lists:member(State, [?CHARGE_STATE_2, ?CHARGE_STATE_3, ?CHARGE_STATE_4, ?CHARGE_STATE_9]), error_state),

    OldData = db:read(#key_player_charge_record{order_id = OrderId}),
    ?ASSERT(OldData /= null, order_none),
    #db_player_charge_record{
        platform_order_id = OldPlatformOrderId,
        game_charge_id = GameChargeId,
        charge_item_id = ItemId,
        charge_state = OldChargeState,
        money = Money,
        value = Value,
        ip = Ip
    } = OldData,

    if
        OldChargeState =:= ?CHARGE_STATE_9 ->
            %% 订单已完成
            exit(order_completed);
        true ->
            case State of
                ?CHARGE_STATE_2 ->  %% 上报订单
                    if
                        OldPlatformOrderId =:= "0" ->
                            %% 创建订单记录
                            Tran =
                                fun() ->
                                    db:write(OldData#db_player_charge_record{
                                        platform_order_id = PlatformOrderId,
                                        change_time = util_time:timestamp(),
                                        source = Source
                                    })
                                end,
                            db:do(Tran),
                            ok;
                        true ->
                            ok
                    end;
                ?CHARGE_STATE_3 -> ok;
                ?CHARGE_STATE_4 -> ok;
                ?CHARGE_STATE_9 ->  %% 完成订单
                    if
                        OldPlatformOrderId =:= PlatformOrderId ->
                            %% 订单完成，给奖励
                            mod_charge:common_game_charge(util:to_int(PlayerId), GameChargeId, ItemId, ?CHARGE_TYPE_NORMAL, Money, util:to_int(Value), OrderId, Ip, "", PlatformOrderId),
                            #t_recharge{
                                cash = Price
                            } = t_recharge:get({ItemId}),
                            api_charge:notice_charge_data(PlayerId, 1, ItemId, util:to_int(Money / Price)),
                            ok;
                        true ->
                            %% 订单无效
                            exit(invalid_order_id)
                    end
            end
    end.

-define(ALLOWED_PLAYER_RECHARGE_RECORD, [3, 4, 9]).

change_charge_state(OrderId, PlayerId, State) ->
    change_charge_state(OrderId, PlayerId, "", State).
change_charge_state(OrderId, PlayerId, TxOrderId, State) ->
    ?DEBUG("change_charge_state: ~p PlayerId: ~p", [OrderId, PlayerId]),
    case lists:member(State, ?ALLOWED_PLAYER_RECHARGE_RECORD) of
        true ->
            OldData = db:read(#key_player_charge_record{order_id = OrderId}),
            case State of
                9 ->
                    ?DEBUG("OldData: ~p", [OldData]),
                    ?DEBUG("TxOrderId: ~p", [TxOrderId]),
                    #db_player_charge_record{
                        game_charge_id = GameChargeId,
                        charge_item_id = ItemId,
                        money = Money,
                        value = Value,
                        ip = Ip
%%                        rate = Rate
                    } = OldData,
%%                    RealMoney = util:to_float(Money / Rate),
                    mod_charge:common_game_charge(util:to_int(PlayerId), GameChargeId, ItemId, ?CHARGE_TYPE_NORMAL,
                        Money, util:to_int(Value), OrderId, Ip, "", TxOrderId),
                    #t_recharge{
                        cash = Price
                    } = t_recharge:get({ItemId}),
                    api_charge:notice_charge_data(PlayerId, 1, ItemId, util:to_int(Money / Price)),
                    ok;
                _ ->
                    NewData = OldData#db_player_charge_record{charge_state = State},
                    #db_player_charge_record{
                        charge_item_id = ItemId,
                        platform_order_id = TxOrderId,
                        money = Money
                    } = NewData,
                    #t_recharge{
                        cash = Price
                    } = t_recharge:get({ItemId}),
                    Tran =
                        fun() ->
                            db:write(NewData)
                        end,
                    R = db:do(Tran),
                    api_charge:notice_charge_data(PlayerId, ?IF(State =:= 3, 2, 3), ItemId, util:to_int(Money / Price)),
                    ?DEBUG("player_order_record update res: ~p", [R]),
                    R
            end;
        false ->
            ?ERROR("Res: ~p", [[State, ?ALLOWED_PLAYER_RECHARGE_RECORD]]),
            exit(not_allowed_state)
    end.

%% @doc 检查指定平台，指定区服，指定玩家是否完成过指定物品的充值
chk_order_by_player(PlatformId, ServerId, PlayerId, ItemId) ->
    ?INFO("充值服查询指定平台: ~p, 指定区服: ~p的充值记录, 指定玩家: ~p是否完成了对指定物品的充值(~p)", [PlatformId, ServerId, PlayerId, ItemId]),
    Sql = io_lib:format("SELECT * from `charge_info_record` WHERE player_id = '~s' and charge_item_id = '~s' and part_id = '~s' and server_id = '~s'  LIMIT 1; ", [integer_to_list(PlayerId), integer_to_list(ItemId), PlatformId, ServerId]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?ERROR("reason:~p, sql:~p}", [Msg, Sql]),
            exit(error);
        {data, SelectRes} ->
            Fun =
                fun(R) ->
                    R#db_charge_info_record{
                        row_key = {R#db_charge_info_record.order_id}
                    }
                end,
            L = lib_mysql:as_record(SelectRes, db_charge_info_record, record_info(fields, db_charge_info_record), Fun),
            ?INFO("Res: ~p", [L]),
            case L of
                [R] when is_record(R, db_charge_info_record) ->
                    #db_charge_info_record{
                        order_id = OrderId
                    } = R,
                    ?DEBUG("OrderId: ~p", [OrderId]),
                    {ok, OrderId};
                [] ->
                    ?DEBUG("FFF"),
                    exit(specified_item_unpaid)
            end
    end.

get_charge_type() ->
    PlatformId = mod_server_config:get_platform_id(),
    case PlatformId of
        ?PLATFORM_TAIWAN ->
            {1, [{0, "ATM虛擬賬號轉賬付款"}, {1, "CVS超商代碼付款"}]};
        _ ->
            {2, []}
    end.
