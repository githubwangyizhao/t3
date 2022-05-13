%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         %% 越南
%%% @end
%%% Created : 06. 四月 2021 下午 04:33:40
%%%-------------------------------------------------------------------
-module(vietnam).
-author("Administrator").

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    pay/8,              %% 支付
    refuse/1,           %% 异步回调：用户拒绝支付
    confirm/1,          %% 异步回调：支付成功
    failure/1,          %% 异步回调：支付失败
    callPay/3
]).

-export([
    create_order_id/2
]).

-define(TEST_VERSION, true).

-define(VIETNAM_REQUEST_URL, ?IF(?IS_DEBUG, "http://192.168.31.100:9999/vietnam", ?IF(?TEST_VERSION, "http://47.101.164.86:9999/vietnam", "https://vietpaygate.com/Pay_Index.html"))).
-define(VIETNAM_NOTIFY_URL, ?IF(?IS_DEBUG, "http://192.168.31.100:9999/vietnam/notify", ?IF(?TEST_VERSION, "http://47.101.164.86:9999/vietnam/notify", "http://47.57.166.185:9999/vietnam/notify"))).
-define(VIETNAM_PAY_URL, ?IF(?IS_DEBUG, "http://192.168.31.100:6100/", ?IF(?TEST_VERSION, "http://47.101.164.86:7080/", "http://vietnam.bountymasters.com:7080/"))).

pay(PlayerId, ChargeType, ItemId, GameChargeId, Money, ChargeIngot, Ip, PlatformId) ->
    ?DEBUG("PlayerId: ~p", [PlayerId]),
    ?DEBUG("ChargeType: ~p", [ChargeType]),
    ?DEBUG("PlatformItemId: ~p", [ItemId]),
    ?DEBUG("GameChargeId: ~p", [GameChargeId]),
    ?DEBUG("Money: ~p", [Money]),
    ?DEBUG("ChargeIngot: ~p", [ChargeIngot]),
    ?DEBUG("PlatformId: ~p", [PlatformId]),
%%    Ip = "127.0.0.1",
    %% 根据platform与channel获取对应的费率
    {RealMoney, Usd, Rate} = mod_server_rpc:call_war(exchange_rate, convert, [?PLATFORM_VIETNAM, Money]),
    ?INFO("越南支付: ~p", [{PlatformId, Rate, Money, RealMoney}]),
    %% 越南支付订单号长度为20
    OrderId = create_order_id(PlatformId, PlayerId),
    ?DEBUG("OrderId: ~p", [OrderId]),
    MoneyFloat = util:to_float(Usd),
    Tran =
        fun() ->
            mod_charge:create_order(PlayerId, GameChargeId, ItemId, ChargeType, MoneyFloat, ChargeIngot, OrderId, Ip, "", Rate, 1)  %% todo
        end,
    db:do(Tran),
    %% 接口调用代码
    Result = callPay(PlayerId, OrderId, RealMoney),
    case Result of
        R when is_list(R) ->
            {ok, R};
        _ ->
            failure
    end.

callPay(PlayerId, OrderId, Amount) ->
%%    Url = ?VIETNAM_REQUEST_URL,
    Url = "https://vietpaygate.com/Pay_Index.html",
    ParamList = lists:sort([
        {"pay_memberid", ?VIETNAM_MEMBER_ID},            %% 商户号
        {"pay_orderid", OrderId},                        %% 订单号
        {"pay_applydate", util_time:format_datetime()},  %% 提交时间
        {"pay_bankcode", 976},                           %% 银行编码
        {"pay_notifyurl", ?VIETNAM_NOTIFY_URL},          %% 服务端通知
        {"pay_callbackurl", "a"},                        %% 页面跳转通知
        {"pay_amount", util:to_int(Amount)},             %% 金额
        {"pay_productname", "a"}                         %% 商品名称
    ]),
    ?DEBUG("ParamList: ~p", [ParamList]),
    StringSign =
        lists:foldl(
            fun(Param, Tmp) ->
                {Key, Value} = Param,
                IsCanSign = not lists:member(Key, ["pay_productname"]),
                if
                    IsCanSign andalso Value =/= "" ->
                        Tmp ++ (?IF(Tmp =/= "", "&", "")) ++ util:to_list(Key) ++ "=" ++ util:to_list(Value);
                    true ->
                        Tmp
                end
            end,
            "", ParamList
        ),
    ?DEBUG("StringSign: ~p", [StringSign]),
    Sign = string:to_upper(encrypt:md5(lists:concat([StringSign, "&key=", ?VIETNAM_API_KEY]))),
    ?DEBUG("Sign: ~p", [Sign]),
    Body = lists:concat([StringSign, "&pay_md5sign=", Sign]),
    case util_http:post(Url, form, Body) of
        {ok, Result} ->
            {{YY, MM, DD}, {_H, _M, _S}} = util_time:local_datetime(),
            case catch jsone:decode(util:to_binary(Result)) of
                {'EXIT', _} ->
                    DateDir = lists:concat([YY, "-", MM, "-", DD]),
                    FileDir = "/data/html/charge_html/" ++ DateDir ++ "/",
                    filelib:ensure_dir(FileDir),
                    FileName = FileDir ++ OrderId ++ ".html",
                    file:write_file(FileName, list_to_binary(util_string:replace(Result,"/assest","https://vipa.cashbox.world/assest"))),
                    PayInfo = ?VIETNAM_PAY_URL ++ "charge/html/" ++ DateDir ++ "/" ++ OrderId ++ ".html",
                    ?INFO("OrderSn: ~p PayInfo: ~p", [OrderId, PayInfo]),
%%                    [{"pay_info", PayInfo}, {"tx_orderno", OrderId}];
                    [{"pay_info", PayInfo}];
                Response ->
                    Msg = maps:get(<<"msg">>, Response),
                    ?ERROR("支付失败>>~p ", [Msg]),
                    failure
            end;
        ErrorReason ->
            ?ERROR("支付失败==error:~p", [{Url, ErrorReason}]),
            failure
    end.

callNotify(OrderId, Amount) ->
    if
        ?IS_DEBUG ->
            ?DEBUG("DEBUG环境 发起异步回调"),
            %% 内网环境，发送异步回调
            ParamList = lists:sort([
                {"memberid", ?VIETNAM_MEMBER_ID},           %% 商户编号
                {"orderid", OrderId},                       %% 订单号
                {"amount", Amount},                         %% 订单金额
                {"transaction_id", "aaa"},                  %% 交易流水号
                {"datetime", util_time:format_datetime()},  %% 交易时间
                {"returncode", "00"}                        %% 交易状态(00表示成功，其他表示失败)
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
            OriginalString = StringSign ++ "&key=" ++ ?VIETNAM_API_KEY,
            Sign = string:to_upper(encrypt:md5(OriginalString)),
            Body = StringSign ++ "&sign=" ++ Sign,
            case util_http:post(?VIETNAM_NOTIFY_URL, form, Body) of
                {ok, Result} ->
                    ?DEBUG("Result: ~p", [Result]);
                ErrorReason ->
                    ?ERROR("支付失败==error:~p", [{?VIETNAM_NOTIFY_URL, ErrorReason}])
            end,
            ok;
        true ->
            noop
    end.

failure(OrderId) ->
    case get_server_name(OrderId) of
        {_, PlatformId, ServerId, PlayerId} ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, change_charge_state, [OrderId, PlayerId, 3]) of
                R when is_record(R, db_player_charge_record) ->
                    ?DEBUG("R: ~p", [R]),
                    ok;
                _ -> failure
            end
    end.
refuse(OrderId) ->
    case get_server_name(OrderId) of
        {_, PlatformId, ServerId, PlayerId} ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, change_charge_state, [OrderId, PlayerId, 4]) of
                R when is_record(R, db_player_charge_record) ->
                    ?DEBUG("R: ~p", [R]),
                    ok;
                _ -> failure
            end
    end.

confirm(OrderId) ->
    case catch get_server_name(OrderId) of
        {_, PlatformId, ServerId, PlayerId} ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, mod_charge, change_charge_state, [OrderId, PlayerId, 9]) of
                ok ->
                    ok;
                _ -> failure
            end;
        {'EXIT', ERROR} ->
            ?ERROR("越南充值回调失败，原因 : ~p", [ERROR])
    end.

%% @doc 创建订单号
create_order_id(PlatformId, PlayerId) when is_list(PlatformId) andalso is_integer(PlayerId) ->
    lists:flatten(
        io_lib:format("~s~8..0s~7..0s~2..0w",
            [
                lists:sublist(util:to_list(PlatformId), 3),                     %% 3位
                mod_unique_invitation_code:encode(util_time:timestamp()),       %% 8位
                mod_unique_invitation_code:encode(PlayerId),                    %% 7位
                util_random:random_number(1, 99)                                %% 2位
            ]
        )
    ).

%% --------------------------------- 私有方法，不导出 --------------------------------- %%

%% 通过订单编号与Custormer(playerId-serverId-platformId)字符串到数据库中查找出对应的记录
%% 并通过中心服查找到对应的节点信息
%% 最后验证节点的ServerId是否正确
get_server_name(OrderId) ->
    ?DEBUG("OrderId: ~p", [OrderId]),
    PlayerStr = string:substr(OrderId, 12, 7),
%%    {PlatformId,Str1} = lists:split(3,OrderId),
%%    {_Timestamp,Str2} = lists:split(8,Str1),
%%    {PlayerStr,_RandomNum} = lists:split(7,Str2),
    PlayerId = mod_unique_invitation_code:decode(util_string:replace(PlayerStr, "0", "")),
    DbGlobalPlayer = mod_server_rpc:call_center(mod_global_player, get_global_player, [PlayerId]),
    ?DEBUG("DbGlobalPlayer: ~p", [DbGlobalPlayer]),
    #db_global_player{
        platform_id = PlatformId,
        server_id = ServerId
    } = DbGlobalPlayer,
    %% 通过Customer获取游戏节点信息
    {OrderId, PlatformId, ServerId, PlayerId}.


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
