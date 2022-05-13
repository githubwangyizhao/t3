%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 8月 2021 下午 03:23:22
%%%-------------------------------------------------------------------
-module(props_trader).
-author("Administrator").

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("charge.hrl").
-include("error.hrl").

%% API
-export([
    pay/8,                  %% 支付
    pay/9,                  %% 支付 带支付货币单位
    refuse/3,               %% 异步回调：用户拒绝支付
    confirm/3,              %% 异步回调：支付成功
    failure/2,              %% 异步回调：支付失败
    callPay/5,
    getPayParam/3,
    callNotify/2,           %% 测试用方法，自己给自己发异步回调
    modify_record_info/2    %% 退款
]).

-define(PROPS_TRADER_UID(Env),
    case Env of
        "develop" -> "14";
        "testing" -> "14";
        "testing_oversea" -> "14";
        _ -> "14"
    end
).
-define(PAY_HOST(Env),
    case Env of
%%        "develop" -> "http://192.168.31.100:8111";
        "develop" -> "http://192.168.31.100:8100";
        %% 国内阿里云测试服 测试服go端口号不对外开放，需要nginx转发请求，因此请求地址为：abc.com/api
        "testing" -> "https://test.props-trader.com/api";
        %% 香港测试服 香港测试服go端口号不对外开放，需要nginx转发请求，因此请求地址为：abc.com/api
        "testing_oversea" -> "https://test.props-trader.com/api";
        %% 生产环境 生产环境go端口号不对外开放，需要nginx转发请求，因此请求地址为：abc.com/api
        _ -> "https://www.props-trader.com/api"
    end
).

-define(PAY_PARAM_PATH, "/funds/activation_channel").
-define(PAY_PATH, "/funds/game_recharge_now").

-define(NOTIFY_URL(Env),
    case Env of
        "develop" -> "http://192.168.31.100:13006";
        %% 国内阿里云测试服
        "testing" -> "http://47.102.119.76:9993";
        %% 香港测试服
        "testing_oversea" -> "http://8.210.191.53:9993";
        %% 生产环境
        _ -> "https://charge.daggerofbonuses.com"
    end
).
-define(NOTIFY_URL_PATH, "/props_trader/notify").


getPayParam(Region, Amount, _PlatformId) ->
    Env = env:get(env),
    Url = ?PAY_HOST(Env) ++ ?PAY_PARAM_PATH,
    ?INFO("ISDEBUG: ~p, url: ~p", [?IS_DEBUG, Url]),
    Data = [
        {'country', util:to_binary(Region)},
        {'gold_num', Amount},
        {'uid', util:to_binary(?PROPS_TRADER_UID(Env))},
        {'rate_flag', util:to_binary(Region)}
    ],
%%    Data = #{country => util:to_binary(Region), gold_num => Amount},
    ?DEBUG("originalData: ~p", [{Data, is_map(Data)}]),
    JsonData = lib_json:encode(Data),
    ?DEBUG("JsonData: ~p", [{JsonData, is_list(JsonData)}]),
    RealData = [{'sign', encrypt:rsa_public_key_encode(JsonData, env:get(path_2_props_trader_public_key))}],
    ?DEBUG("dataAfterRsaEncrypted: ~p", [RealData]),
    PayParam =
        case util_http:post(Url, json, RealData) of
            {ok, Result} ->
                Response = jsone:decode(util:to_binary(Result)),
                ?DEBUG("Response: ~p", [Response]),
                Code = maps:get(<<"code">>, Response),
                case Code of
                    200 ->
                        RespData = maps:get(<<"data">>, Response),
                        {
                            util:to_int(maps:get(<<"c_type">>, RespData)),
                            util:to_int(maps:get(<<"gold_num">>, RespData)),
                            util:to_list(maps:get(<<"platform">>, RespData)),
                            util:to_list(maps:get(<<"paytype">>, RespData)),
                            util:to_float(maps:get(<<"third_amount">>, RespData))
                        };
%%                    401 ->
%%                         token失效，调用登录接口，并再次调用获取支付参数接口
%%                        login(PlatformId),
%%                        getPayParam(Region, Amount, PlatformId);
%%                    9 ->
%%                         token失效，调用登录接口，并再次调用获取支付参数接口
%%                        login(PlatformId),
%%                        getPayParam(Region, Amount, PlatformId);
                    Other ->
                        ?ERROR("~p 接口调用失败: ~p", [Url, {Other, Data, Code, Response}]),
                        failure
                end;
            ErrorReason ->
                ?ERROR("支付失败==error:~p", [{Url, ErrorReason}]),
                failure
        end,
    ?ASSERT(is_atom(PayParam) =:= false, failure),
    PayParam.

%% 调用获取支付接口所需参数的接口
callPay(OrderId, CType, Platform, Num, RealThirdAmount, PayType, CustomerName, _PlatformId) ->
    Env = env:get(env),
    Url = ?PAY_HOST(Env) ++ ?PAY_PATH,
    NotifyUrl = ?NOTIFY_URL(Env) ++ ?NOTIFY_URL_PATH,
    %% NotifyUrl = ?NOTIFY_URL,
    Data = [
        {'uid', util:to_binary(?PROPS_TRADER_UID(Env))},            %% 装备交易平台玩家编号
        {'cgame_order', util:to_binary(OrderId)},                   %% 订单号
        {'cgame_return_url', util:to_binary(NotifyUrl)},            %% 异步回调地址
%%        {'cgame_return_url', util:to_binary("")},                   %% 异步回调地址
        {'c_type', CType},                                          %% 固定值：1
        {'platform', util:to_binary(Platform)},                     %% 货币单位：TWD(台湾)等
        {'gold_num', Num},                                          %% 要充值的装备交易平台平台币数量
        {'third_amount', util:to_binary(util:to_list(RealThirdAmount))}, %% 金额 该参数与gold_num参数，再合适的时候要去掉一个
        {'paytype', util:to_binary(PayType)},                       %% 充值类型
        {'customer_name', util:to_binary(CustomerName)}             %% 平台 区服 加密后的玩家编号
    ],
%%    Token = get_token(),
%%    case util_http:post(Url, json, Data, [{"Authorization", Token}], []) of
    JsonData = lib_json:encode(Data),
%%    RealData = [{'sign', encrypt:rsa_public_key_encode(jsone:encode(Data), env:get(path_2_props_trader_public_key))}],
    RealData = [{'sign', encrypt:rsa_public_key_encode(JsonData, env:get(path_2_props_trader_public_key))}],
    case util_http:post(Url, json, RealData) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            ?INFO("Response: ~p", [Response]),
            Code = maps:get(<<"code">>, Response),
            case Code of
                200 ->
                    RespData = maps:get(<<"data">>, Response),
                    PayInfo = lists:filtermap(
                        fun({Key, Value}) ->
                            List = [
                                <<"price">>,            %% 金额
                                <<"expire_date">>,       %% 缴款期限
                                <<"bankname">>,         %% 银行名称
                                <<"vatm_code">>,         %% 虚拟账号
                                <<"TradeDate">>,        %% 订单建立时间
                                <<"cvs_code">>,          %% 超商代码
                                <<"pay_info">>         %% 支付链接
%%                                <<"tx_orderno">>         %% 装备交易平台订单号
                            ],
                            case lists:member(Key, List) of
                                true ->
                                    {true, {util:to_list(Key), util:to_list(Value)}};
                                false ->
                                    false
                            end
                        end,
                        maps:to_list(RespData)
                    ),
                    ?INFO("PayInfo: ~p", [PayInfo]),
                    PayInfo;
%%                401 ->
                    %% token失效，调用登录接口，并再次调用支付接口
%%                    login(PlatformId),
%%                    callPay(OrderId, CType, Platform, Num, RealThirdAmount, PayType, CustomerName, PlatformId);
%%                9 ->
                    %% token失效，调用登录接口，并再次调用获取支付参数接口
%%                    login(Platform),
%%                    callPay(OrderId, CType, Platform, Num, RealThirdAmount, PayType, CustomerName, PlatformId);
                30048 ->
                    %% 装备交易平台限制x秒内不能充值超过1次
                    %% {'EXIT', ?ERROR_INTERFACE_CD_TIME}
                    ?ERROR_INTERFACE_CD_TIME;
                _ ->
%%                    ?ERROR("~p 接口调用失败: ~p", [Url, {Data, Token, Code, Response}]),
                    ?ERROR("~p 接口调用失败: ~p", [Url, {Data, Code, Response}]),
                    failure
            end;
        ErrorReason ->
            ?ERROR("支付失败==error:~p", [{Url, ErrorReason}]),
            failure
    end.

%%
callPay(PlayerId, OrderId, Amount, CustomerName, PlatformId) ->
    RealAmount = util:to_int(Amount),
    Env = env:get(env),
    ?INFO("Env: ~p ~p Amount: ~p ConvertMoney: ~p", [Env, OrderId, Amount, RealAmount]),
    #db_player{acc_id = AccId} = mod_player:get_player(PlayerId),
    Region =
        case mod_server_rpc:call_center(mod_global_account, get_my_region, [AccId, PlatformId]) of
            RegionFromCenter -> RegionFromCenter
        end,
    ?DEBUG("Region: ~p", [{AccId, Region}]),
    {CType, Num, Platform, PayType, ThirdAmount} = getPayParam(Region, Amount, PlatformId),
    ?DEBUG("platform: ~p", [{?PLATFORM_LOCAL, ?PLATFORM_LOCAL =:= PlatformId}]),
    PayInfo = callPay(OrderId, CType, Platform, Num, ThirdAmount, PayType, CustomerName, PlatformId),
    ?DEBUG("PayInfo: ~p", [PayInfo]),
    case PlatformId of
        %% 开发环境+内网100
%%        ?PLATFORM_LOCAL -> callNotify(OrderId, CustomerName, PlatformId);
        %% 测试服
%%        ?PLATFORM_TEST -> callNotify(OrderId, CustomerName, PlatformId);
        _ ->
            NotifyUrl = ?NOTIFY_URL(Env) ++ ?NOTIFY_URL_PATH,
            ?INFO("非开发环境或内网环境(~p)，等待三方返回异步回调 异步回调接收地址: ~p", [PlatformId, NotifyUrl])
    end,
    PayInfo.

%% 自己模拟第三方给自己的异步回调地址发数据
callNotify(OrderId, CustomerName) ->
    Env = env:get(env),
    NotifyUrl = ?NOTIFY_URL(Env) ++ ?NOTIFY_URL_PATH,
    ?INFO("callNotify: ~p", [{Env, NotifyUrl}]),
    NotifyData = [
        {'order_no', OrderId},                                      %% 订单号
        {'props_trader_order_no', "dddaaa"},                         %% 三方订单号
        {'status', 1},                                              %% 固定值：1
        {'customer_name', CustomerName}                             %% 加密后的玩家编号 平台 区服
    ],
    Params = jsone:encode([{util:to_atom(Key), ?IF(is_integer(Val), Val, util:to_binary(Val))} ||
        {Key, Val} <- NotifyData]),
    ?DEBUG("Params: ~p", [Params]),
    Sign = encrypt:md5(util:to_list(Params) ++ ?GM_SALT),
    ?DEBUG("Sign: ~p", [Sign]),
    Data = base64:encode(Params),
    Body = "sign=" ++ Sign ++ "&data=" ++ binary_to_list(Data),
    ?DEBUG("Body: ~p", [Body]),
    ?DEBUG("NotifyUrl: ~p", [NotifyUrl]),
    case util_http:post(NotifyUrl, form, Body) of
        {ok, Result} ->
            ?DEBUG("Result: ~p", [Result]);
        ErrorReason ->
            ?ERROR("支付失败==error:~p", [{NotifyUrl, ErrorReason}])
    end.


pay(PlayerId, ChargeType, ItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId) ->
    pay(PlayerId, ChargeType, ItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId, ?REGION_CURRENCY_TW).
pay(PlayerId, ChargeType, ItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId, Currency) ->
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
    {RealMoney, Usd, Rate} = ?IF(?IS_DEBUG =:= true, {Money, Money, 1.0}, mod_server_rpc:call_war(exchange_rate, convert, [Currency, Money])),
%%        if
%%            ?IS_DEBUG =:= true ->
%%                {Money, Money, 1.0};
%%            true ->
%%                mod_server_rpc:call_war(exchange_rate, convert, [Currency, Money])
%%        end,
    ?INFO("R1: ~p ~p ~p", [RealMoney, Usd, Rate]),
    Plat = lists:sublist(util:to_list(PlatformId), 5),
    OrderId = lists:flatten(io_lib:format("~2..0w~8..0w~13..0w~s", [ChargeType, PlayerId, util_time:milli_timestamp(), Plat])),
    ?DEBUG("OrderId: ~p", [OrderId]),
    MoneyFloat = util:to_float(Usd),
    Tran =
        fun() ->
            mod_charge:create_order(PlayerId, GameChargeId, ItemId, ChargeType, MoneyFloat, ChargeIngot,
                OrderId, Ip, "", Rate, ?SOURCE_CHARGE_FROM_PROPS_TRADER)
        %% 接口调用代码
        end,
    db:do(Tran),
    %% 使用美元进行支付
    Result = callPay(PlayerId, OrderId, MoneyFloat, mod_unique_invitation_code:encode(PlayerId) ++ " " ++ PlatformId ++ " " ++ ServerId, PlatformId),
    case Result of
        ?ERROR_INTERFACE_CD_TIME ->
            ?ERROR("平台限制单位时间交易次数"),
            exit(?ERROR_INTERFACE_CD_TIME);
        R when is_list(R) ->
            {ok, R};
        O -> ?DEBUG("Other: ~p", [O]),
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
refuse(OrderId, Customer, TxOrderId) ->
    case get_server_name(OrderId, Customer) of
        {_, PlatformId, ServerId, PlayerId} ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, change_charge_state,
                [OrderId, PlayerId, 4, TxOrderId]) of
                R when is_record(R, db_player_charge_record) ->
                    ?DEBUG("R: ~p", [R]),
                    ok;
                _ -> failure
            end
    end.
confirm(OrderId, Customer, TxOrderId) ->
    ?DEBUG("confirm: ~p", [{OrderId, Customer, TxOrderId}]),
    case get_server_name(OrderId, Customer) of
        {_, PlatformId, ServerId, PlayerId} ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, change_charge_state,
                [OrderId, PlayerId, TxOrderId, 9]) of
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
