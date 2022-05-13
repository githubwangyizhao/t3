%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 2月 2021 下午 02:42:21
%%%-------------------------------------------------------------------
-module(zf999).
-author("Administrator").

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("charge.hrl").

%% API
-export([
    pay/8,              %% 支付
    refuse/2,           %% 异步回调：用户拒绝支付
    confirm/2,          %% 异步回调：支付成功
    failure/2,          %% 异步回调：支付失败
    callPay/4
]).

%%-define(PAY_API_HOST(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, ?IF(?IS_DEBUG, "http://192.168.31.100:13006", "http://47.102.119.76:9993"), "https://openapi.zf999.xyz")).
-define(PAY_API_HOST(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, "http://192.168.31.100:13006", "http://127.0.0.1:9993")).
%%-define(PAY_API_PATH(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, "/zf999/pay", "/open/index/createorder")).
-define(PAY_API_PATH(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL orelse PlatformId =:= ?PLATFORM_TEST, "/zf999/pay", "/open/index/createorder")).
%%-define(PAY_NOTIFY_URL(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, ?IF(?IS_DEBUG, "http://192.168.31.100:13006/zf999/notify", "http://47.102.119.76:9993/zf999/notify"), "http://47.57.166.185:9999/zf999/notify")).
-define(PAY_NOTIFY_URL(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, "http://192.168.31.100:13006/zf999/notify", "http://127.0.0.1:9993/zf999/notify")).

callPay(OrderId, Amount, CustomerName, PlatformId) ->
    Url = ?PAY_API_HOST(PlatformId) ++ ?PAY_API_PATH(PlatformId),
    ?INFO("ISDEBUG: ~p, url: ~p", [?IS_DEBUG, Url]),
    RealAmount = util:to_int(Amount),
    ?INFO("~p Amount: ~p ConvertMoney: ~p", [OrderId, Amount, RealAmount]),
    ParamList = lists:sort([
        {"mchid", ?ZF999_MCHID},
        {"timestamp", util_time:timestamp()},
        {"amount", RealAmount},
        {"orderno", OrderId},
        {"notifyurl", ?PAY_NOTIFY_URL(PlatformId)},
        {"customername", CustomerName},
        {"customermobile", "123"},
        {"order_intro", "order_intro"}
    ]),
    StringSign =
        lists:foldl(
            fun(Param, Tmp) ->
                {Key, Value} = Param,
                if
                    Value =/= "" ->
                        Tmp ++ (?IF(Tmp =/= "", "&", "")) ++ util:to_list(Key) ++ "=" ++ util:to_list(Value);
                    true ->
                        Tmp
                end
            end,
            "", ParamList
        ),
    Sign = string:to_upper(encrypt:md5(lists:concat([StringSign, "&key=", ?ZF999_API_KEY]))),
    Body = lists:concat([StringSign, "&sign=", Sign]),
    case util_http:post(Url, form, Body) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = maps:get(<<"msg">>, Response),
            Data = maps:get(<<"data">>, Response),
            ?INFO("Msg: ~p", [Msg]),
            ?INFO("Code: ~p ~p", [Code == 1, Code]),
            ?DEBUG("Data: ~p", [Data]),
            if
                Code == 1 ->
                    PayInfo = lists:filtermap(
                        fun({Key, Value}) ->
                            case Key of
                                <<"pay_info">> ->
                                    {true, {binary_to_list(Key), binary_to_list(Value)}};
                                <<"tx_orderno">> ->
                                    {true, {binary_to_list(Key), binary_to_list(Value)}};
                                _ ->
                                    false
                            end
                        end,
                        maps:to_list(Data)
                    ),
                    CallNotify = ?IF(PlatformId =:= ?PLATFORM_LOCAL orelse PlatformId =:= ?PLATFORM_TEST, callNotify(OrderId, CustomerName, Amount, PlatformId), noop),
                    ?DEBUG("内网环境 发起异步回调: ~p", [CallNotify]),
                    ?INFO("PayInfo: ~p", [PayInfo]),
                    PayInfo;
                true ->
                    ?ERROR("支付失败>>~p ~ts~n ", [Code, Msg]),
                    failure
            end;
        ErrorReason ->
            ?ERROR("支付失败==error:~p", [{Url, ErrorReason}]),
            failure
    end.

callNotify(OrderId, Customer, Amount, PlatformId) ->
    if
        PlatformId =:= ?PLATFORM_LOCAL orelse PlatformId =:= ?PLATFORM_TEST ->
            %% 内网环境，发送异步回调
            ParamList = lists:sort([
                {mchid, ?ZF999_MCHID},
                {timestamp, util_time:timestamp()},
                {amount, Amount},
                {orderno, OrderId},
                {notifyurl, ?PAY_NOTIFY_URL(PlatformId)},
                {customer, Customer},
                {customermobile, "123"},
                {order_intro, "order_intro"},
                {trade_state, "SUCCESS"}
            ]),
            StringSign =
                lists:foldl(
                    fun(Param, Tmp) ->
                        {Key, Value} = Param,
                        if
                            Value =/= "" ->
                                Tmp ++ (?IF(Tmp =/= "", "&", "")) ++ util:to_list(Key) ++ "=" ++ util:to_list(Value);
                            true ->
                                Tmp
                        end
                    end,
                    "", ParamList
                ),
            ?INFO("StringSign: ~p", [StringSign]),
            OriginalString = StringSign ++ "&key=" ++ ?ZF999_API_KEY,
            Sign = string:to_upper(encrypt:md5(OriginalString)),
            Body = StringSign ++ "&sign=" ++ Sign,
            case util_http:post(?PAY_NOTIFY_URL(PlatformId), form, Body) of
                {ok, Result} ->
                    ?DEBUG("Result: ~p", [Result]);
                ErrorReason ->
                    ?ERROR("支付失败==error:~p", [{?PAY_NOTIFY_URL(PlatformId), ErrorReason}])
            end,
            ok;
        true ->
            ?INFO("非本地模式，等待异步回调")
    end.

pay(PlayerId, ChargeType, ItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId) ->
    ?DEBUG("PlayerId: ~p", [PlayerId]),
    ?DEBUG("ChargeType: ~p", [ChargeType]),
    ?DEBUG("PlatformItemId: ~p", [ItemId]),
    ?DEBUG("GameChargeId: ~p", [GameChargeId]),
    ?INFO("Money: ~p", [Money]),
    ?DEBUG("ChargeIngot: ~p", [ChargeIngot]),
    ?DEBUG("PlatformId: ~p", [PlatformId]),
    Ip = "127.0.0.1",
    %% 根据platform与channel获取对应的费率
    WarNode = mod_server_config:get_war_area_node(),
    ?INFO("War_node: ~p", [WarNode]),
    {RealMoney, Usd, Rate} =
        if
            ?IS_DEBUG ->
                {Money, Money, 1.0};
            true ->
                mod_server_rpc:call_war(exchange_rate, convert, [?REGION_CURRENCY_INDONESIA, Money])
        end,
    ?INFO("R1: ~p ~p ~p", [RealMoney, Usd, Rate]),
    %% 适配 zf999订单编号不能超过28的情况
    Plat = lists:sublist(util:to_list(PlatformId), 5),
    OrderId = lists:flatten(io_lib:format("~2..0w~8..0w~13..0w~s", [ChargeType, PlayerId, util_time:milli_timestamp(), Plat])),
    ?DEBUG("OrderId: ~p", [OrderId]),
%%    MoneyFloat = util:to_float(RealMoney),
    MoneyFloat = util:to_float(Usd),
    Tran =
        fun() ->
            mod_charge:create_order(PlayerId, GameChargeId, ItemId, ChargeType, MoneyFloat, ChargeIngot, OrderId, Ip, "", Rate, ?SOURCE_CHARGE_FROM_PROPS_TRADER)
        %% 接口调用代码
        end,
    db:do(Tran),
    Result = callPay(OrderId, MoneyFloat * Rate, mod_unique_invitation_code:encode(PlayerId) ++ " " ++ PlatformId ++ " " ++ ServerId, PlatformId),
    case Result of
        R when is_list(R) ->
            {ok, R};
        _ ->
            failure
    end.

failure(OrderId, Customer) ->
    case get_server_name(OrderId, Customer) of
        {_, PlatformId, ServerId, PlayerId} ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, change_charge_state, [OrderId, PlayerId, 3]) of
                R when is_record(R, db_player_charge_record) ->
                    ?DEBUG("R: ~p", [R]),
                    ok;
                _ -> failure
            end
    end.
refuse(OrderId, Customer) ->
    case get_server_name(OrderId, Customer) of
        {_, PlatformId, ServerId, PlayerId} ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, change_charge_state, [OrderId, PlayerId, 4]) of
                R when is_record(R, db_player_charge_record) ->
                    ?DEBUG("R: ~p", [R]),
                    ok;
                _ -> failure
            end
    end.

confirm(OrderId, Customer) ->
    case get_server_name(OrderId, Customer) of
        {_, PlatformId, ServerId, PlayerId} ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, change_charge_state, [OrderId, PlayerId, 9]) of
                ok ->
                    ok;
                _ -> failure
            end
    end.

%% --------------------------------- 私有方法，不导出 --------------------------------- %%

%% 通过订单编号与Custormer(playerId-serverId-platformId)字符串到数据库中查找出对应的记录
%% 并通过中心服查找到对应的节点信息
%% 最后验证节点的ServerId是否正确
get_server_name(OrderId, Customer) ->
    ?DEBUG("OrderId: ~p", [OrderId]),
    %% Customer为异步回调返回结果的PlayerId-serverId-partId
    ?DEBUG("PlayerId: ~p", [Customer]),
    %% 通过Customer获取游戏节点信息
    [PlayerInvitationCode, PlatformId, ServerId] = lists:reverse(customer2Info(Customer, [])),
    ?INFO("查看bug: ~p", [{PlayerInvitationCode, PlatformId, ServerId}]),
    PlayerId = mod_unique_invitation_code:decode(PlayerInvitationCode),
%%    PlatformId = util:to_list(PlatformId0),
%%    ServerId = util:to_list(ServerId0),
%%    PlayerId = util:to_list(PlayerId0),
    %% 通过订单编号查询游戏服的数据，获取相关数据
    ?INFO("PlayerInvitationCode: ~p, PlayerId: ~p, ServerId: ~p, PlatformId: ~p",
        [PlayerInvitationCode, PlayerId, ServerId, PlatformId]),
    GameServerList = mod_server_rpc:call_center(mod_server, get_game_server_list, [PlatformId]),
    ServerIsValid = lists:filtermap(
        fun(Ele) ->
            #db_c_game_server{
                sid = Sid
            } = Ele,
            if
                Sid =:= ServerId ->
                    {true, ServerId};
                true -> false
            end
        end,
        GameServerList
    ),
    ?DEBUG("ServerIsValid: ~p", [ServerIsValid]),
    if
        ServerIsValid =:= [] ->
            exit(invalid);
        true ->
            {OrderId, PlatformId, ServerId, PlayerId}
    end.


customer2Info(Customer, L) ->
    case string:find(Customer, " ") of
        nomatch ->
            [Customer | L];
        _ ->
            [A, B] = string:split(Customer, " "),
            customer2Info(B, [A | L])
    end.

%% 退款的时候用
modify_record_info(R, State) when is_record(R, db_player_charge_record) ->
    #db_player_charge_record{
        charge_state = StateAfterUpdate,
        money = Money,
        player_id = PlayerId
    } = R,
    ?DEBUG("StateAfterUpdate: ~p, State: ~p Money: ~p PlayerId: ~p", [StateAfterUpdate, State, Money, PlayerId]),
    OldData = db:read(#key_player_charge_info_record{player_id = PlayerId}),
    ?DEBUG("OldData: ~p", [OldData]),
    #db_player_charge_info_record{
        total_money = TotalMoney,
        charge_count = ChargeCount
    } = OldData,
    NewMoney = TotalMoney - Money,
    NewChargeCount = ChargeCount - 1,
    ?DEBUG("TotalMoney: ~p ChargeCount: ~p", [NewMoney, NewChargeCount]),
    NewData = OldData#db_player_charge_info_record{total_money = NewMoney, charge_count = NewChargeCount},
    ?DEBUG("NewData: ~p", [NewData]),
    Tran =
        fun() ->
            db:write(NewData)
        end,
    ?DEBUG("Res: ~p", [db:do(Tran)]);
modify_record_info(_, _) ->
    exit(invalid_datatype).
