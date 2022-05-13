%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc    充值服
%%% Created : 20. 三月 2018 15:54
%%%-------------------------------------------------------------------
-module(mod_charge_server).
-author("home").


-export([
    server_charge/5,            %% 平台调用充值
    server_charge/6,            %% 平台调用充值
    server_charge/7,            %% 平台调用充值
    server_game_charge/10,      %% 平台调用充值（直接在游戏服充值）
    charge/12,                  %% 充值 get
    check_white_ip_list/1,      %% 检查白名单列表
    game_charge/13,             %% 游戏服数据上报 默认的充值来源字段为谷歌充值
    game_charge/14,             %% 游戏服数据上报 增加充值来源字段
    game_player_charge_data/3,  %% 请求充值玩家充值数据
    gm_charge/11,               %% gm充值
    http_list/0,
    check_gm_hash/2,
    get_charge_info_record/1,
    check_gm_white_ip_list/1,   %% 检查gm ip白名单列表
    change_white_ip/5           %% 操作白名单ip
]).


% gm操作
-export([
    gm_game_node_all_repair/2,      %% @fun 游戏服补充订单上报数据
    gm_get_white_ip_list/0,        %% 获得白名单列表
    gm_delete_player_charge_order_record_id/1,           %% 删除单条记录
    gm_delete_player_charge_order_record_player_id/3,    %% 删除玩家充值记录
    gm_add_ip/2,                    %% gm增加ip
    gm_update_ip/3                  %% gm更新ip状态
]).

-include("error.hrl").
-include("charge.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% ----------------------------------
%% @doc 	平台调用充值
%% @throws 	none
%% @end
%% ----------------------------------
server_charge(AccId, OrderId, GameOrderNoStr, Ip, FTime) ->
    server_charge(AccId, OrderId, 0, GameOrderNoStr, Ip, FTime).
server_charge(AccId, OrderId, Money, GameOrderNoStr, Ip, FTime) ->
    server_charge(AccId, OrderId, Money, GameOrderNoStr, Ip, FTime, {}).
server_charge(AccId1, OrderId, Money, GameOrderNoStr, Ip, FTime, Param) ->
    [PartId, ServerId, AccId, PlayerIdStr, ChargeTypeStr, ChargeItemIdStr, ItemCountStr] =
        case mod_charge:encode_game_order_id(GameOrderNoStr) of
            [PartId1, ServerId1, PlayerIdStr1, ChargeTypeStr1, ChargeItemIdStr1, ItemCountStr1] ->
                ?ASSERT(AccId1 =/= "", {param_type_error, 'AccId=null'}),
                [PartId1, ServerId1, AccId1, PlayerIdStr1, ChargeTypeStr1, ChargeItemIdStr1, ItemCountStr1];
            [PartId1, ServerId1, AccId2, AccId21, PlayerIdStr1, ChargeTypeStr1, ChargeItemIdStr1, ItemCountStr1] -> % 玩吧特殊处理
                [PartId1, ServerId1, AccId2 ++ "_" ++ AccId21, PlayerIdStr1, ChargeTypeStr1, ChargeItemIdStr1, ItemCountStr1];
            GameOrderList ->
                GameOrderList
        end,
%%    [PartId, ServerId, PlayerIdStr, ChargeTypeStr, ChargeItemIdStr, ItemCountStr] = mod_charge:encode_game_order_id(GameOrderNoStr),
    ChargeType = util:to_int(ChargeTypeStr),
    ?ASSERT(ChargeType == ?CHARGE_TYPE_NORMAL orelse ChargeType == ?CHARGE_TYPE_GM_NORMAL, error_charge_type),
    PlayerId = util:to_int(PlayerIdStr),
    ChargeItemId = util:to_int(ChargeItemIdStr),
    ItemCount = util:to_int(ItemCountStr),
    if
        Money > 0 ->
            #t_recharge{
                cash = SingleMoney
            } = mod_charge:try_get_t_recharge(ChargeItemId),
            CalcMoney = SingleMoney * ItemCount,
            if
                CalcMoney - 1 < Money ->
                    noop;
                true ->
                    ?ERROR("人民币不对:~p~n", [{SingleMoney, ItemCount, Money}]),
                    exit(money)
            end;
%%            ?ASSERT(CalcMoney - 1 < Money, money);
        true ->
            noop
    end,
    ServerNode = mod_server:get_game_server(PartId, ServerId),
    ?ASSERT(is_record(ServerNode, db_c_game_server) == true, null_server),
    Node = ServerNode#db_c_game_server.node,
    CurrTime = util_time:timestamp(),
    Interval = abs(CurrTime - FTime),
    ?ASSERT(Interval =< ?TIME_INTERVAL, old_time),
    OldOrder = get_charge_info_record(OrderId),
    ?ASSERT(is_record(OldOrder, db_charge_info_record) == false, error_order_id),
    case catch rpc:call(util:to_atom(Node), mod_charge, charge_server_charge, [PlayerId, ChargeType, ChargeItemId, ItemCount, OrderId, Ip, Param]) of
        {ok, GameChargeId, ChargeMoney, ChargeIngot, Result} ->
            common_charge_body(Node, PartId, ServerId, AccId, GameChargeId, ChargeItemId, ?IF(Money == 0, ChargeMoney, Money), ChargeIngot, OrderId, Ip, ChargeType, "", CurrTime, Result);
        {_, {_, ?ERROR_NOT_EXISTS}} ->
            logger2:write(null_player_id, {Node, PartId, ServerId, AccId, Ip, OrderId}),
            exit(null_player_id);
        {_, {_, ?ERROR_ALREADY_HAVE}} ->        % 存在订单
            exit(error_order_id);
        R ->
            ?ERROR("错误 平台调用充值: ~p ~n", [R]),
            R
    end.
%% @doc     平台调用充值
server_game_charge(PartId, ServerId, AccId, ChargeItemId, ItemCount, OrderId, Ip, ChargeType, GmId, ReportParam) ->
    ?ASSERT(ChargeType == ?CHARGE_TYPE_NORMAL orelse ChargeType == ?CHARGE_TYPE_GM_NORMAL, error_charge_type),
    ServerNode = mod_server:get_game_server(PartId, ServerId),
    ?ASSERT(is_record(ServerNode, db_c_game_server) == true, null_server),
    Node = ServerNode#db_c_game_server.node,
    OldOrder = get_charge_info_record(OrderId),
    ?ASSERT(is_record(OldOrder, db_charge_info_record) == false, error_order_id),
    CurrTime = util_time:timestamp(),
    case catch rpc:call(util:to_atom(Node), mod_charge, charge_server_game_charge, [ServerId, AccId, ChargeType, ChargeItemId, ItemCount, OrderId, Ip, ReportParam]) of
        {ok, GameChargeId, ChargeMoney, ChargeIngot, Result} ->
            common_charge_body(Node, PartId, ServerId, AccId, GameChargeId, ChargeItemId, ChargeMoney, ChargeIngot, OrderId, Ip, ChargeType, GmId, CurrTime, Result);
        {_, {_, ?ERROR_NOT_EXISTS}} ->
            logger2:write(null_player_id, {Node, PartId, ServerId, AccId, Ip, OrderId}),
            exit(null_player_id);
        {_, {_, ?ERROR_ALREADY_HAVE}} ->        % 存在订单
            exit(error_order_id);
        R ->
            ?ERROR("错误 平台调用充值: ~p ~n", [R]),
            R
    end.

%% ----------------------------------
%% @doc 	充值(废弃)
%% @throws 	none
%% @end
%% ----------------------------------
charge(PartId, ServerId, AccId, GameChargeId, Money, Ingot, OrderId, IP, FTime, ChargeType, Hash, Str) ->
    ?ASSERT(ChargeType == ?CHARGE_TYPE_NORMAL orelse ChargeType == ?CHARGE_TYPE_GM_NORMAL, error_charge_type),
    check_hash(Str, Hash),
    ServerNode = mod_server:get_game_server(PartId, ServerId),
    ?ASSERT(is_record(ServerNode, db_c_game_server) == true, null_server),
    Node = ServerNode#db_c_game_server.node,
    CurrTime = util_time:timestamp(),
    Interval = abs(CurrTime - FTime),
    ?ASSERT(Interval =< ?TIME_INTERVAL, old_time),
    OldOrder = get_charge_info_record(OrderId),
    ?ASSERT(is_record(OldOrder, db_charge_info_record) == false, error_order_id),
    common_charge(Node, PartId, ServerId, AccId, GameChargeId, Money, Ingot, OrderId, IP, ChargeType, "", CurrTime).

%% 公共充值部分
common_charge(Node, PartId, ServerId, AccId, GameChargeId, Money, Ingot, OrderId, IP, ChargeType, GmId, CurrTime) ->
    ?ASSERT(Money > 0 andalso Money =< Ingot andalso Ingot =< Money * ?INGOT_RATE_MONEY * 100, money_ingot),
    Result = (catch rpc:call(util:to_atom(Node), mod_charge, deal_charge, [ServerId, AccId, GameChargeId, Money, Ingot, OrderId, ChargeType])),
    common_charge_body(Node, PartId, ServerId, AccId, GameChargeId, 0, Money, Ingot, OrderId, IP, ChargeType, GmId, CurrTime, Result).
common_charge_body(Node, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, GmId, CurrTime, Result) ->
    common_charge_body(Node, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, GmId, CurrTime, Result, ?SOURCE_CHARGE_FROM_GOOGLE).
common_charge_body(Node, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, GmId, CurrTime, Result, Source) ->
    IsNormal =
        if
            ChargeType == ?CHARGE_TYPE_NORMAL orelse
                ChargeType == ?GM_CHARGE_TYPE_REPAIR orelse
                ChargeType == ?CHARGE_TYPE_GM_NORMAL
                ->
                true;
            true ->
                false
        end,
    case Result of
        {ok, PlayerId, GameResult} ->
            {CurrLevel, CurrTaskId, RegTime, Power, ChannelId, IsShare, GoldNum, CouponNum, BountyNum} = game_result(GameResult),
            PlayerCharge = get_player_charge_info_record_init(PlayerId),
            ?INFO("OldPlayerCharge Data: ~p", [PlayerCharge]),
            #db_player_charge_info_record{
                total_money = OldTotalMoney,
                charge_count = OldChargeCount,
                charge_test_count = OldChargeTestCount,
                gm_charge_count = OldGmChargeCount,
                gm_ingot_count = OldGmIngotCount,
                gm_charge_novip_count = OldGmChargeNovipCount,
                max_money = OldMaxMoney,
                min_money = OldMinMoney,
                last_time = OldLastTime,
                first_time = OldFirstTime,
                refused_money = OldRefusedMoney
            } = PlayerCharge,
            {NormalCount, ChargeTestCount, GmChargeCount, GmIngotCount, GmChargeNovipCount, RefusedMoney} =
                case ChargeType of
                    ?CHARGE_TYPE_NORMAL ->
                        {OldChargeCount + 1, OldChargeTestCount, OldGmChargeCount, OldGmIngotCount, OldGmChargeNovipCount, ?IF(OldRefusedMoney - Money =< 0, 0.0, OldRefusedMoney - Money)};
                    ?CHARGE_TYPE_GM_NORMAL ->
                        {OldChargeCount, OldChargeTestCount + 1, OldGmChargeCount, OldGmIngotCount, OldGmChargeNovipCount, OldRefusedMoney};
                    ?GM_CHARGE_TYPE_NOT_VIP ->
                        {OldChargeCount, OldChargeTestCount, OldGmChargeCount, OldGmIngotCount, OldGmChargeNovipCount + 1, OldRefusedMoney};
                    ?GM_CHARGE_TYPE_ALL ->
                        {OldChargeCount, OldChargeTestCount, OldGmChargeCount + 1, OldGmIngotCount, OldGmChargeNovipCount, OldRefusedMoney};
                    ?GM_CHARGE_TYPE_I_INGOT ->
                        {OldChargeCount, OldChargeTestCount, OldGmChargeCount, OldGmIngotCount + 1, OldGmChargeNovipCount, OldRefusedMoney};
                    ?GM_CHARGE_TYPE_REPAIR ->
                        {OldChargeCount + 1, OldChargeTestCount, OldGmChargeCount, OldGmIngotCount, OldGmChargeNovipCount, OldRefusedMoney}
                end,

            ?INFO("mod_charge_server RefusedMoney: ~p ~p ~p ~p", [OldRefusedMoney, OldRefusedMoney - Money =< 0, OldRefusedMoney - Money, Money]),

            {IsFirst, FirstTime, LastTime, NewTotalMoney, NewMaxMoney, NewMinMoney} =
                case ChargeType of
                    ?CHARGE_TYPE_NORMAL ->
                        {IsFirst1, FirstTime1} =
                            if
                                NormalCount == 1 ->
                                    {?TRUE, CurrTime};
                                true ->
                                    {?FALSE, OldFirstTime}
                            end,
                        {IsFirst1, FirstTime1, CurrTime, OldTotalMoney + Money, max(OldMaxMoney, Money), ?IF(OldMinMoney == 0, Money, min(OldMinMoney, Money))};
                    _ ->
                        {?FALSE, OldFirstTime, OldLastTime, OldTotalMoney, OldMaxMoney, OldMinMoney}
                end,
            Tran =
                fun() ->
                    db:write(#db_charge_info_record{
                        order_id = OrderId,            %% 运营传
                        part_id = PartId,
                        charge_type = ChargeType,
                        node = util:to_list(Node),
                        ip = IP,
                        server_id = ServerId,
                        acc_id = AccId,
                        player_id = PlayerId,
                        is_first = IsFirst,
                        game_charge_id = GameChargeId,
                        charge_item_id = ChargeItemId,
                        money = util:to_float(Money),                %% 充值人民币
                        ingot = Ingot,
                        reg_time = RegTime,
                        first_time = FirstTime,
                        curr_level = CurrLevel,
                        curr_task_id = CurrTaskId,
                        curr_power = Power,
                        channel = ChannelId,
                        record_time = CurrTime,
                        source = Source,
                        gold = GoldNum,
                        bounty = BountyNum,
                        coupon = CouponNum
                    }),
                    Data = PlayerCharge#db_player_charge_info_record{
                        server_id = ServerId,
                        part_id = PartId,
                        total_money = util:to_float(NewTotalMoney),
                        charge_count = NormalCount,
                        charge_test_count = ChargeTestCount,
                        gm_charge_count = GmChargeCount,
                        gm_ingot_count = GmIngotCount,
                        gm_charge_novip_count = GmChargeNovipCount,
                        last_time = LastTime,
                        channel = ChannelId,
                        is_share = IsShare,
                        max_money = util:to_float(NewMaxMoney),
                        min_money = util:to_float(NewMinMoney),
                        first_time = FirstTime,
                        record_time = CurrTime,
                        refused_money = RefusedMoney
                    },
                    ?INFO("common_charge_body Data: ~p", [Data]),
                    db:write(Data),
                    ok
                end,
            DoResult = db:do(Tran),
            case DoResult of
                ok ->
                    if
                        IsNormal ->
                            logger2:write(charge_success, {{ip, IP}, {ChargeType, PlayerId, CurrLevel, CurrTaskId, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId}});
                        true ->
                            logger2:write(gm_charge_success, {GmId, {ip, IP}, {ChargeType, PlayerId, CurrLevel, CurrTaskId, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Ingot, OrderId}})
                    end,
                    ok;
                R1 ->
                    if
                        IsNormal ->
                            logger2:write(charge_game_db_error, {{PlayerId, ServerId, AccId, GameChargeId, Money, Ingot, OrderId, ChargeType}, R1}),
                            exit(charge_game_db_error);
                        true ->
                            logger2:write(gm_charge_game_db_error, {{PlayerId, ServerId, AccId, GameChargeId, Money, Ingot, OrderId, ChargeType}, R1}),
                            exit(gm_charge_game_db_error)
                    end
            end;
        {_, {_, ?ERROR_NOT_EXISTS}} ->
%%        {_, ?ERROR_NOT_EXISTS} ->
            if
                IsNormal ->
                    logger2:write(null_player_id, {Node, PartId, ServerId, AccId, IP, OrderId});
                true ->
                    logger2:write(gm_null_player_id, {Node, PartId, ServerId, AccId, IP})
            end,
            exit(null_player_id);
        {_, {_, ?ERROR_ALREADY_HAVE}} ->        % 存在订单
            exit(error_order_id);
        R ->
            ?ERROR("错误 公共充值部分: ~p ~n", [R]),
            R
    end.

% 游戏服返回
game_result(GameResult) ->
    {CurrLevel, CurrTaskId, RegTime, Power, ChannelId, IsShare, GoldNum, CouponNum, BountyNum} =
        case GameResult of
            {CurrLevel2, CurrTaskId2, RegTime2, Power2} ->
                {CurrLevel2, CurrTaskId2, RegTime2, Power2, "", 0, 0, 0, 0};
            {CurrLevel2, CurrTaskId2, RegTime2, Power2, ChannelId2} ->
                {CurrLevel2, CurrTaskId2, RegTime2, Power2, ChannelId2, 0, 0, 0, 0};
            {CurrLevel3, CurrTaskId3, RegTime3, Power3, ChannelId3, IsShare3} ->
                {CurrLevel3, CurrTaskId3, RegTime3, Power3, ChannelId3, IsShare3, 0, 0, 0};
            {CurrLevel3, CurrTaskId3, RegTime3, Power3, ChannelId3, IsShare3, GoldNum1, CouponNum1, BountyNum1} ->
                {CurrLevel3, CurrTaskId3, RegTime3, Power3, ChannelId3, IsShare3, GoldNum1, CouponNum1, BountyNum1};
            GameResult when is_integer(GameResult) ->
                {0, 0, GameResult, 0, "", 0, 0, 0, 0};
            _ ->
                {0, 0, 0, 0, "", 0, 0, 0, 0}
        end,
    {CurrLevel, CurrTaskId, RegTime, Power, ChannelId, IsShare, GoldNum, CouponNum, BountyNum}.

%% @fun 请求充值玩家充值数据
game_player_charge_data(PartId, ServerId, NickName) ->
    ServerNode = mod_server:get_game_server(PartId, ServerId),
    ?ASSERT(is_record(ServerNode, db_c_game_server) == true, null_server),
    Node = ServerNode#db_c_game_server.node,
    case catch rpc:call(util:to_atom(Node), mod_charge, game_player_charge_data, [ServerId, NickName]) of
        {ok, ServerId, List} ->
            {ok, ServerId, List};
        {_, {_, ?ERROR_NOT_EXISTS}} ->
            ?ERROR("请求充值玩家充值数据null_player_id:~p~n", [{PartId, ServerId, NickName}]),
            exit(null_player_id);
        R ->
            R
    end.

%% ----------------------------------
%% @doc 	gm 充值
%% @throws 	none
%% @end
%% ----------------------------------
gm_charge(PartId, ServerId, AccId, GameChargeId, Ingot, IP, FTime, Hash, Str, GmId, ChargeType) ->
    ?ASSERT(ChargeType == ?GM_CHARGE_TYPE_I_INGOT orelse ChargeType == ?GM_CHARGE_TYPE_ALL orelse ChargeType == ?GM_CHARGE_TYPE_NOT_VIP, error_charge_type),
    check_gm_hash(Str, Hash),
    ServerNode = mod_server:get_game_server(PartId, ServerId),
    ?ASSERT(is_record(ServerNode, db_c_game_server) == true, null_server),
    Node = ServerNode#db_c_game_server.node,
    CurrTime = util_time:timestamp(),
    Interval = abs(CurrTime - FTime),
    ?ASSERT(Interval =< ?TIME_INTERVAL, old_time),
    OrderIdInt = util_time:milli_timestamp() * 1000 + util_random:random_number(1000),
    common_charge(Node, PartId, ServerId, AccId, GameChargeId, Ingot div 10, Ingot, util:to_list(OrderIdInt), IP, ChargeType, GmId, CurrTime).

%% @fun 游戏服数据上报 充值来源默认谷歌充值
game_charge(Node, PlayerId, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, Tuple) ->
    game_charge(Node, PlayerId, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, Tuple, ?SOURCE_CHARGE_FROM_GOOGLE).
%% @fun 游戏服数据上报
game_charge(Node, PlayerId, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, Tuple, Source) ->
    CurrTime = util_time:timestamp(),
    {GmId, Result} =
        case Tuple of
            {GmId1, Result1} ->
                {GmId1, Result1};
            {ok, _, _} ->
                {0, Tuple};
            _ ->
                {0, {ok, PlayerId, {}}}
        end,
    common_charge_body(Node, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, GmId, CurrTime, Result, Source).

%% @fun 游戏服补充订单上报数据
gm_game_node_all_repair(Node, List) ->
    NewList =
        lists:foldl(
            fun({PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, GmId, CurrTime, Result}, L) ->
                OldOrder = get_charge_info_record(OrderId),
                case is_record(OldOrder, db_charge_info_record) of
                    true ->
                        L;
                    _ ->
                        common_charge_body(Node, PartId, ServerId, AccId, GameChargeId, ChargeItemId, Money, Ingot, OrderId, IP, ChargeType, GmId, CurrTime, Result),
                        [OrderId | L]
                end
            end, [], List),
    {ok, NewList}.

%% @fun 获得http列表
http_list() ->
    lists:foldl(
        fun(#db_c_server_node{type = Type, node = Node, ip = Ip, web_port = WebPort}, L) ->
            if
                Type == ?SERVER_TYPE_GAME ->
                    Url = "http://" ++ util:to_list(Ip) ++ ":" ++ util:to_list(WebPort),
                    Name = hd(string:tokens(Node, "@")),
                    [{util:to_atom(Name), util:to_binary(Url)} | L];
                true ->
                    L
            end
        end, [], mod_server:get_server_node_list()).

%% 操作白名单ip
change_white_ip(WhiteIp, WhiteIpState, Hash, Str, GmId) ->
    if
        GmId == "game" ->
            noop;
        true ->
            ?DEBUG("GmId: ~p~n", [GmId]),
            exit(?ERROR_NOT_AUTHORITY)
    end,
    check_gm_hash(Str, Hash),
    WhiteIpList = string:tokens(WhiteIp, "."),
    ?ASSERT(length(WhiteIpList) == 4, not_ip),
    lists:foreach(
        fun(IpSonId) ->
            SonLen = length(IpSonId),
            ?ASSERT(1 =< SonLen andalso SonLen =< 4, not_ip)
        end, WhiteIpList),
    ChangeType =
        case get_charge_ip_white(WhiteIp) of
            IpRecord when is_record(IpRecord, db_charge_ip_white_record) ->
                if
                    IpRecord#db_charge_ip_white_record.state =/= WhiteIpState ->
                        Tran =
                            fun() ->
                                db:write(IpRecord#db_charge_ip_white_record{state = WhiteIpState})
                            end,
                        db:do(Tran),
                        add_ip;
                    true ->
                        noop
                end;
            _ ->
                Tran =
                    fun() ->
                        db:write(#db_charge_ip_white_record{ip = WhiteIp, state = ?TRUE})
                    end,
                db:do(Tran),
                update_ip
        end,
    ?IF(ChangeType == noop, noop, logger2:write(change_white_ip, {WhiteIp, WhiteIpState, ChangeType})),
    ok.


% 检查校验码
check_hash(Str, Hash) ->
    Key = io_lib:format("~s~s", [Str, ?KEY]),
    Md5 = encrypt:md5(Key),
    if
        Md5 == Hash ->
            noop;
        true ->
            ?DEBUG("检验码不一致: sign:~p  >> md5: ~p~n", [Hash, Md5]),
            exit(error_md5)
    end.

% 检查校验码
check_gm_hash(Str, Hash) ->
    Key = io_lib:format("~s~s", [Str, ?GM_KEY]),
    Md5 = encrypt:md5(Key),
    if
        Md5 == Hash ->
            noop;
        true ->
            ?DEBUG("gm检验码不一致: sign:~p  >> md5: ~p~n", [Hash, Md5]),
            exit(error_md5)
    end.

% 检查 Ip
check_white_ip_list(IP) ->
    case get_charge_ip_white(IP) of
        IpRecord when is_record(IpRecord, db_charge_ip_white_record) ->
            if
                IpRecord#db_charge_ip_white_record.state == ?TRUE ->
                    ok;
                true ->
                    exit(not_ip)
            end;
        _ ->
%%            IsTrunk = string:substr(IP, 1, 11) == "192.168.31.", % 内网充值
%%            if
%%                IsTrunk ->
%%                    noop;
%%                true ->
            exit(not_ip)
%%            end
    end.

% 检查 Ip
check_gm_white_ip_list(IP) ->
    IsTrunk = string:substr(IP, 1, 11) == "192.168.31.", % 内网充值
    if
        IsTrunk ->
            ok;
        true ->
            IpList = ["110.86.26.42", "118.184.176.81"],
            case lists:member(IP, IpList) of
                true ->
                    ok;
                _ ->
                    exit(not_ip)
            end
    end.

%% ================================================ gm 操作 ================================================
%% 删除单条记录
gm_delete_player_charge_order_record_id(OrderId) ->
    case get_charge_info_record(OrderId) of
        Order when is_record(Order, db_charge_info_record) ->
            Tran =
                fun() -> db:delete(Order),
                    delete_record_log(Order)
                end,
            db:do(Tran),
            ok;
        _ ->
            noop
    end.

%% 删除玩家充值记录
gm_delete_player_charge_order_record_player_id(PlayerId, InitTime, EndTime) ->
    MathSpec = [{#db_charge_info_record{player_id = PlayerId, charge_type = ?CHARGE_TYPE_NORMAL, record_time = '$1', _ = '_'}, [{'and', {'=<', InitTime, '$1'}, {'=<', '$1', EndTime}}], [{'$_'}]}],
    List = db:select(db_player_charge_order_record, MathSpec),

    Tran =
        fun() ->
            [db:delete(Record) || Record <- List],
            [catch delete_record_log(DelRecord) || DelRecord <- List]
        end,
    db:do(Tran),
    ok.

% 删除日志记录
delete_record_log(Record) when is_record(Record, db_charge_info_record) ->
    #db_charge_info_record{
        order_id = OrderId,
        part_id = PartId,
        charge_type = ChargeType,
        ip = IP,
        server_id = ServerId,
        acc_id = AccId,
        player_id = PlayerId,
        is_first = IsFirst,
        money = Money,
        ingot = Ingot
    } = Record,
    logger2:write(delete_record, {OrderId, PartId, ChargeType, IP, ServerId, AccId, PlayerId, IsFirst, Money, Ingot});
delete_record_log(_) ->
    noop.


%% gm增加ip
gm_add_ip(GmId, AddIp) ->
    if
        GmId == "game" orelse GmId == game ->
            noop;
        true ->
            exit(null_gm_id)
    end,
    case get_charge_ip_white(AddIp) of
        IpRecord when is_record(IpRecord, db_charge_ip_white_record) ->
            noop;
        _ ->
            Tran =
                fun() ->
                    db:write(#db_charge_ip_white_record{ip = AddIp, state = ?TRUE}),
                    ok
                end,
            db:do(Tran)
    end.

%% gm更新ip状态
gm_update_ip(GmId, AddIp, State) ->
    if
        GmId == "game" orelse GmId == game ->
            noop;
        true ->
            exit(null_gm_id)
    end,
    case get_charge_ip_white(AddIp) of
        IpRecord when is_record(IpRecord, db_charge_ip_white_record) ->
            if
                IpRecord#db_charge_ip_white_record.state =/= State ->
                    Tran =
                        fun() ->
                            db:write(IpRecord#db_charge_ip_white_record{state = State})
                        end,
                    db:do(Tran),
                    ok;
                true ->
                    noop
            end;
        _ ->
            not_ip_record
    end.

%% 获得白名单列表
gm_get_white_ip_list() ->
    [{IpWhite#db_charge_ip_white_record.ip, IpWhite#db_charge_ip_white_record.state} || IpWhite <- ets:tab2list(charge_ip_white_record)].


%% ================================================ 数据操作 ================================================
% 记录玩家充值次数数据
get_player_charge_info_record(PlayerId) ->
    db:read(#key_player_charge_info_record{player_id = PlayerId}).

% 记录玩家充值次数数据	并初始化
get_player_charge_info_record_init(PlayerId) ->
    case get_player_charge_info_record(PlayerId) of
        PlayerCharge when is_record(PlayerCharge, db_player_charge_info_record) ->
            PlayerCharge;
        _ ->
            #db_player_charge_info_record{player_id = PlayerId}
    end.

% 获得充值白名单ip
get_charge_ip_white(Ip) ->
    db:read(#key_charge_ip_white_record{ip = Ip}).

% 获得充值记录数据
get_charge_info_record(OrderId) ->
    db:read(#key_charge_info_record{order_id = OrderId}).
