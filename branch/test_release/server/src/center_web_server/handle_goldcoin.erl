%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 4月 2021 下午 09:10:38
%%%-------------------------------------------------------------------
-module(handle_goldcoin).
-author("Administrator").

-include("system.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("server_data.hrl").
-include("error.hrl").
-include("db_config.hrl").

%% API
-export([init/2, after_withdraw/2]).

init(Req, Opts) ->
    NewReq = handle_request(Req, Opts),
    {ok, NewReq, Opts}.

%% @fun 根据请求 切换不同的操作
handle_request(Req, Opts) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"PUT">> ->
            handle_body(Req, Opts);
        <<"GET">> ->
            handle_body(Req, Opts);
        _ ->
            ?ERROR("错误handle_request Method: ~p ~n", [Method])
    end.
handle_body(Req, _Opts) ->
    Method = cowboy_req:method(Req),
    {IP, _} = cowboy_req:peer(Req),
    Ip = inet_parse:ntoa(IP),
    PathId = cowboy_req:binding(id, Req),
    if
        undefined == PathId ->
            Path = cowboy_req:path(Req);
        true ->
            Path =
                case re:run(binary_to_list(cowboy_req:path(Req)), cowboy_req:binding(id, Req)) of
                    nomatch -> cowboy_req:path(Req);
                    _ ->
                        [UrlPrefix, [] | UrlSuffix] = re:replace(binary_to_list(cowboy_req:path(Req)), "/" ++ binary_to_list(cowboy_req:binding(id, Req)), ""),
                        RealUrlPath = binary_to_list(UrlPrefix) ++ binary_to_list(UrlSuffix),
                        ?DEBUG("real url path: ~p", [list_to_binary(RealUrlPath)]),
                        list_to_binary(RealUrlPath)
                end
    end,
%%    Path = cowboy_req:path(Req),
    {ErrorCode, Error} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                {0, ok};
            {'EXIT', {param_type_error, _}} ->
                {param_type_error, 400};
            {'EXIT', invalid_operation} ->
                {invalid_operation, 422};
            {'EXIT', not_authority} ->
                {not_enough_gold, 422};
            {'EXIT', invalid_operation} ->
                {invalid_operation, 422};
            {'EXIT', log_error} ->
                {log_error, 422};
            {'EXIT', invalid_id_secret} ->
                {invalid_id_secret, 400};
            {'EXIT', file_not_found} ->
                {file_not_found, 404};
            {ok, MsgL} ->
                {ok, MsgL};
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
%%                logger2:write(game_charge_other_error, {{ip, IP}, R1}),
%%                ok = charge_handler:get_req_param_str(Req),
                {-3, R1}
        end,
    ?DEBUG("ErrorCode: ~p", [[ErrorCode, Error]]),
    if
        ErrorCode == ok orelse ErrorCode == access_denied orelse ErrorCode == file_not_found
            orelse ErrorCode == invalid_id_secret orelse ErrorCode == param_type_error
            orelse ErrorCode == unauthorized orelse ErrorCode == invalid_operation
            orelse ErrorCode == not_enough_gold ->
            Req2 = web_http_util:output_json(Req, Error);
        ErrorCode == redirect ->
            Req2 = web_http_util:output_json(Req, {Error});
        ErrorCode == html ->
            Req2 = web_http_util:output_html(Req, Error);
        ErrorCode == -3 ->
            Req2 = web_http_util:output_json(Req, 422);
        true ->
            Req2 = web_http_util:output_json(
                Req, [{'code', ErrorCode}, {'message', util:to_binary(util_string:to_utf8("abc"))}])
    end,
    Req2.

path_request(<<"/level/limitation">>, <<"GET">>, Ip, Req) ->
    ?DEBUG("Ip: ~p", [Ip]),
    R =
        lists:filtermap(
            fun (Ele) ->
                #t_vip_boon{
                    type = Type,
                    level = Level,
                    value = Value
                } = t_vip_boon:get(Ele),
                if
                    Type =:= 1 ->
                        {true, {Level, [
                            {'type', Type},
                            {'level', Level},
                            {'value', Value}
                        ]}};
                    true -> false
                end
            end,
            t_vip_boon:get_keys()
        ),
    ?DEBUG("R: ~p", [R]),
    {ok, [{error, 0}, {msg, "success"}, {result, R}]};
path_request(<<"/item/modify">>, <<"PUT">>, Ip, Req) -> % 给指定玩家增加/减少指定道具
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    ?DEBUG("ParamInfoList: ~p", [ParamInfoList]),
    OrderSn = util:to_list(charge_handler:get_list_value(<<"ordersn">>, ParamInfoList)),
    Platform = util:to_list(charge_handler:get_list_value(<<"platform">>, ParamInfoList)),
    Server = util:to_list(charge_handler:get_list_value(<<"server">>, ParamInfoList)),
    PlayerId = util:to_int(charge_handler:get_list_value(<<"player_id">>, ParamInfoList)),
    PropType = util:to_int(charge_handler:get_list_value(<<"prop_type">>, ParamInfoList)),
    Type = util:to_int(charge_handler:get_list_value(<<"type">>, ParamInfoList)),
    Num = util:to_int(charge_handler:get_list_value(<<"num">>, ParamInfoList)),
    Amount = util:to_float(charge_handler:get_list_value(<<"amount">>, ParamInfoList)),
    PropId = binary_to_integer(cowboy_req:binding(id, Req)),
    ?DEBUG("PlayerId: ~p Server: ~p PropType: ~p Type: ~p Num: ~p Platform: ~p", [PlayerId, Server, PropType, Type, Num, Platform]),
    ?DEBUG("ParamInfoList: ~p", [ParamInfoList]),

    %% 检查订单是否存在
    Fun =
        fun() ->
            case mod_server_rpc:call_game_server(Platform, Server, mod_player, get_player, [util:to_int(PlayerId)]) of
                {badrpc, Reason} ->
                    ?ERROR("badrpc: ~p", [Reason]),
                    exit(log_error);
                Result ->
                    #db_player{
                        type = PlayerType,
                        forbid_type = ForbidType
                    } = Result,

                    %% 非普通账号或被封禁账号，禁止发起装备回收 报错unavailable_account
                    ?ASSERT(PlayerType =:= 0 andalso ForbidType =/= 2, unavailable_account),
                    ?DEBUG("ddd: ~p ~p ~p", [PlayerId, ?FUNCTION_DRAW_MONEY, mod_function:is_open(util:to_int(PlayerId), ?FUNCTION_DRAW_MONEY)]),

                    ?ASSERT(mod_server_rpc:call_game_server(Platform, Server, mod_function, is_open, [util:to_int(PlayerId), ?FUNCTION_DRAW_MONEY]), vip_limit),
                    LeftTimes = mod_server_rpc:call_game_server(Platform, Server, mod_times, get_left_times, [util:to_int(PlayerId), ?TIMES_DRAW_MONEY]),
                    ?ASSERT(LeftTimes >= 0, ?ERROR_TIMES_LIMIT)
            end,
            {GoldNumber, NewStatusInDb} =
                case Type of
                    2 ->
                        ?DEBUG("type=2 表明订单不存在 是要创建订单，此时status为2"),
                        Status = 2,
                        db:write(#db_oauth_order_log{
                            order_id = OrderSn,
                            player_id = PlayerId,
                            prop_id = ?ITEM_GOLD,
                            amount = Amount,
                            ip = Ip,
                            change_type = 0,
                            status = Status,
                            change_num = Num,
                            create_time = util_time:timestamp()
                        }),

                        RealMoney =
                            case t_draw_money:get({PropId}) of
                                null ->
                                    exit(file_not_found);
                                R ->
                                    #t_draw_money{
                                        money = Money
                                    } = R,
                                    Money
                            end,
                        OldGold = mod_server_rpc:call_game_server(Platform, Server, mod_prop, get_player_prop_num, [util:to_int(PlayerId), ?ITEM_GOLD]),
                        GoldNum = RealMoney * ?SD_RECHARGE_RATIO * Num,
                        ?INFO("~p Num: ~p, RealMoney: ~p", [PlayerId, GoldNum, OldGold]),
                        ?DEBUG("F: ~p ~p ~p", [OldGold, RealMoney, OldGold >= GoldNum]),
                        ?ASSERT(OldGold >= GoldNum, not_authority),
                        {GoldNum, Status};
                    1 ->
                        ?DEBUG("订单已经存在 type=1表明要修改订单的status为0。"),
                        OldOrderInfo = db:read(#key_oauth_order_log{order_id = OrderSn}),
                        #db_oauth_order_log{
                            change_type = OldType,
                            status = OldStatusInDb
                        } = OldOrderInfo,
                        ?ASSERT(OldStatusInDb =:= 2, invalid_operation),
                        ?ASSERT(OldType =:= 0, invalid_operation),
                        NewStatusIntoDb = 0,
                        NewData = OldOrderInfo#db_oauth_order_log{
                            change_type = Type,
                            status = NewStatusIntoDb
                        },
                        ?DEBUG("NewData: ~p", [NewData]),
                        db:write(NewData),

                        RealMoney =
                            case t_draw_money:get({PropId}) of
                                null ->
                                    exit(file_not_found);
                                R ->
                                    #t_draw_money{
                                        money = Money
                                    } = R,
                                    Money
                            end,
                        GoldNum = RealMoney * ?SD_RECHARGE_RATIO * Num,
                        ?INFO("~p return money: ~p", [PlayerId, GoldNum]),
                        {GoldNum, NewStatusIntoDb};
                    0 ->
                        ?DEBUG("订单已经存在 type=0表明要修改订单的status为1。"),
                        OrderOrderInfo = db:read(#key_oauth_order_log{order_id = OrderSn}),
                        ?DEBUG("OrderOrderInfo: ~p", [OrderOrderInfo]),
                        #db_oauth_order_log{
                            change_type = OldType,
                            status = OldStatusInDb
                        } = OrderOrderInfo,
                        ?ASSERT(OldStatusInDb =:= 2, invalid_operation),
                        ?ASSERT(OldType =:= 0, invalid_operation),
                        NewStatusIntoDb = 1,
                        NewData = OrderOrderInfo#db_oauth_order_log{
                            change_type = Type,
                            status = NewStatusIntoDb
                        },
                        ?DEBUG("NewData: ~p", [NewData]),
                        db:write(NewData),
                        {0, NewStatusIntoDb}
                end,

            ?DEBUG("NewStatusInDb: ~p", [NewStatusInDb]),
            case NewStatusInDb of
                2 ->
                    ?INFO("222: ~p", [[PlayerId, [{ ?ITEM_GOLD, GoldNumber}], ?LOG_TYPE_TI_XIAN]]),
                    mod_server_rpc:call_game_server(Platform, Server, mod_prop, decrease_player_prop, [PlayerId, [{?ITEM_GOLD, GoldNumber}], ?LOG_TYPE_TI_XIAN]);
                0 ->
                    ?INFO("000: ~p", [[PlayerId, [{?ITEM_GOLD, GoldNumber}], ?LOG_TYPE_TI_XIAN]]),
                    mod_server_rpc:call_game_server(Platform, Server, mod_award, give, [PlayerId, [{?ITEM_GOLD, GoldNumber}], ?LOG_TYPE_TI_XIAN]);
                1 ->
                    mod_server_rpc:call_game_server(Platform, Server, handle_goldcoin, after_withdraw, [PlayerId, Amount]),
                    ?INFO("OrderSn: ~p SUCCESS", [OrderSn])
            end,
            mod_server_rpc:call_game_server(Platform, Server, api_shop, notice_player, [PlayerId, NewStatusInDb])
        end,
    Res = db:do(Fun),
    ?DEBUG("Res: ~p", [Res]),
    {ok, [{error, 0}, {msg, "success"}]}.

after_withdraw(PlayerId, Amount) ->
    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_WITHDRAWAL_MONEY, ?CONDITIONS_VALUE_ADD, util:to_int(Amount)}),
    PlayerStr = mod_player:get_player_name(PlayerId),
    NoticeId = ?NOTICE_CASH_WITHDRAWAL_NOTICE,
    mod_chat:notice_cash_withdrawal(NoticeId, PlayerStr, Amount).
