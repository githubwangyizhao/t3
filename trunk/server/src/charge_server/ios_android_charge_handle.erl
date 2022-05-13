%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 4月 2021 下午 07:19:18
%%%-------------------------------------------------------------------
-module(ios_android_charge_handle).
-author("yizhao.wang").

-include("common.hrl").
-include("charge.hrl").
-include("client.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    pay/9,                          %% 支付
    change_order_state/5            %% 更新订单状态
]).
%% API
-export([
    init/2,
    terminate/2
]).

init(Req, Opts) ->
    NewReq = handle_request(Req, Opts),
    {ok, NewReq, Opts}.
terminate(_Reason, _Req) ->
    ok.

%% @fun 根据请求 切换不同的操作
handle_request(Req, Opts) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"GET">> ->
            handle_body(Req, Opts);
        <<"POST">> ->
            handle_body(Req, Opts);
        _ ->
            ?ERROR("handle request error, Method: ~p ~n", [Method])
    end.

handle_body(Req, _Opts) ->
    Method = cowboy_req:method(Req),
    {IP, _} = cowboy_req:peer(Req),
    Ip = inet_parse:ntoa(IP),
    Path = cowboy_req:path(Req),
    {_, ParamStr} = get_req_param_str(Req),
    {Code, Msg} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                {0, ok};
            {ok, MsgL} ->
                {json, MsgL};
            {'EXIT', R} ->
                ?ERROR("handle body error, Path ~p, R ~p ~n ", [Path, R]),
                Result = result_code(R),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_error, {Result, {ip, IP}, util:to_list(ParamStr), R}),
                {Result, R};
            R1 ->
                ?ERROR("handle body unkown error, Path ~p, R ~p ~n ", [Path, R1]),
                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_other_error, {{ip, IP}, util:to_list(ParamStr), R1}),
                {-200, R1}
        end,
   reply(Req, Code, Msg).

%% ----------------------------------
%% @doc 	回复
%% @throws 	none
%% @end
%% ----------------------------------
reply(Req, json, Msg) -> web_http_util:output_error_code(Req, Msg);
reply(Req, Code, Msg) ->
    Reply = [{code, Code}, {message, util:to_binary(util_string:to_utf8(result_msg(Msg)))}],
    web_http_util:output_error_code(Req, Reply).

%% ----------------------------------
%% @doc  安卓充值回调接口
%% @throws 	none
%% @end
%% ----------------------------------
path_request(<<"/google/pay_validation">>, <<"POST">>, _Ip, Req) ->
    {ParamList, _ParamStr} = get_req_param_str(Req),

    % RC4解密
%%    Secret = util:to_list((util_list:opt(<<"secret">>, ParamList))),
%%    DataList  = flash:rc4_decode(Secret),
%%    ?ASSERT(DataList /= [], error_rc4),

    %% 获取参数
%%    Customer = util:to_list(util_list:opt("customer", DataList)),
%%    OrderSn = util:to_list(util_list:opt("orderSn", DataList)),
%%    OrderId = util:to_list(util_list:opt("orderId", DataList)),
%%    State0 = util_list:opt("result", DataList, undefined),
    Customer = util:to_list((util_list:opt(<<"customer">>, ParamList))),
    OrderSn = util:to_list((util_list:opt(<<"orderSn">>, ParamList))),
    OrderId = util:to_list((util_list:opt(<<"orderId">>, ParamList))),
    State0 = ?IF(util_list:opt(<<"result">>, ParamList, undefined) == undefined, undefined, util:to_int(util_list:opt(<<"result">>, ParamList, undefined))),
    ?INFO("State0: ~p", [{State0, State0 == undefined orelse State0 =:= 1}]),
    ?ASSERT(State0 == undefined orelse State0 =:= 1, error_state),

    State =
        case State0 of
            undefined -> ?CHARGE_STATE_2;
            _ -> ?CHARGE_STATE_9
        end,
    update_order_state(OrderSn, Customer, OrderId, ?SOURCE_CHARGE_FROM_GOOGLE, State),
    ok;
%% ----------------------------------
%% @doc 	苹果充值回调接口
%% @throws 	none
%% @end
%% ----------------------------------
path_request(<<"/apple/pay_validation">>, <<"POST">>, _Ip, Req) ->
    {ParamList, _ParamStr} = get_req_param_str(Req),

    % RC4解密
    Secret = util:to_list((util_list:opt(<<"secret">>, ParamList))),
    DataList  = flash:rc4_decode(Secret),
    ?ASSERT(DataList /= [], error_rc4),

    %% 获取参数
    Customer = util:to_list(get_list_value("customer", DataList)),
    OrderSn = util:to_list(get_list_value("orderSn", DataList)),
    OrderId = util:to_list(get_list_value("orderId", DataList)),

    update_order_state(OrderSn, Customer, OrderId, ?SOURCE_CHARGE_FROM_APP_STORE),
    ok;
path_request(Path, Method, _Ip, Req) ->
    ?ERROR("unknow Path::~p, Method:~p, Req:~p", [Path, Method, Req]),
    exit(unkown_path).

%% ----------------------------------
%% @doc 	生成订单编号
%% @throws 	none
%% @end
%% ----------------------------------
gen_order_id(ChargeType, PlayerId, PlatformId) ->
    Plat = lists:sublist(util:to_list(PlatformId), 5),
    lists:flatten(io_lib:format("~2..0w~8..0w~13..0w~s", [ChargeType, PlayerId, util_time:milli_timestamp(), Plat])).

%% ----------------------------------
%% @doc 	安卓、IOS支付申请
%% @throws 	none
%% @end
%% ----------------------------------
pay(PlayerId, ChargeType, ItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId, Source) ->
    ?DEBUG("PlayerId ~p, ChargeType ~p, ItemId ~p, GameChargeId ~p, Money ~p, ChargeIngot ~p, PlatformId ~p, ServerId ~p", [PlayerId, ChargeType, ItemId, GameChargeId, Money, ChargeIngot, PlatformId, ServerId]),
    Rate = 1.0,      %% todo
    RealMoney =
        case Rate of
            0.0 ->
                util:to_float(Money);
            _ ->
                util:to_float(Money * Rate)
        end,
    OrderSn = gen_order_id(ChargeType, PlayerId, PlatformId),
    Tran =
        fun() ->
            %% 创建支付订单
            mod_charge:create_order(PlayerId, GameChargeId, ItemId, ChargeType, RealMoney, ChargeIngot, OrderSn, get(?DICT_PLAYER_LOGIN_IP), "", Rate, Source)
        end,
    case db:do(Tran) of
        R when is_atom(R) andalso R =:= ok ->
            OrderInfo = lib_json:encode([
                {itemId, ItemId},
                {orderSn, OrderSn},
                {customer, encode_customer(PlayerId, PlatformId, ServerId)}
            ]),
            {ok, [{json, OrderInfo}]};
        _ ->
            failure
    end.

%% ----------------------------------
%% @doc 	加解密用户信息
%% @throws 	none
%% @end
%% ----------------------------------
encode_customer(PlayerId, PlatformId, ServerId) ->
    lists:flatten(lists:join(" ", [util_unique_invitation_code:encode(PlayerId), util:to_list(PlatformId), util:to_list(ServerId)])).

decode_customer(Customer) ->
    [PlayerInvitationCode, PlatformId, ServerId] = string:split(Customer, " ", all),
    PlayerId = util_unique_invitation_code:decode(PlayerInvitationCode),
    [PlayerId, PlatformId, ServerId].

%% ----------------------------------
%% @doc 	更新充值订单状态
%% @throws 	none
%% @end
%% ----------------------------------
update_order_state(OrderSn, Customer, OrderId, Source) -> update_order_state(OrderSn, Customer, OrderId, Source, 0).
update_order_state(OrderSn, Customer, OrderId, Source, OrderState) ->
    case decode_customer(Customer) of
        [PlayerId, PlatformId, ServerId] ->
            case catch mod_server_rpc:call_game_server(PlatformId, ServerId, ?MODULE, change_order_state, [OrderSn, PlayerId, OrderState, OrderId, Source], 3000) of
                {badrpc, {'EXIT', Reason}} ->
                    exit(Reason);
                Res ->
                    Res
            end;
        _ ->    %% customer参数解析失败
            exit(null_player_id)
    end.

%% ----------------------------------
%% @doc 	更新订单
%% @throws 	none
%% @end
%% ----------------------------------
change_order_state(OrderSn, PlayerId, OrderState, OrderId, Source = ?SOURCE_CHARGE_FROM_GOOGLE) ->
    mod_charge:change_ios_android_charge_state(OrderSn, PlayerId, OrderState, OrderId, Source);
change_order_state(OrderSn, PlayerId, _, OrderId, Source = ?SOURCE_CHARGE_FROM_APP_STORE) ->
    case mod_charge:change_ios_android_charge_state(OrderSn, PlayerId, ?CHARGE_STATE_2, OrderId, Source) of
        ok ->
            mod_charge:change_ios_android_charge_state(OrderSn, PlayerId, ?CHARGE_STATE_9, OrderId, Source)
    end.

%% ----------------------------------
%% @doc 	参数解析
%% @throws 	none
%% @end
%% ----------------------------------
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% ----------------------------------
%% @doc 	获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
%% @throws 	none
%% @end
%% ----------------------------------
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).

%% ----------------------------------
%% @doc 	返回内容转换
%% @throws 	none
%% @end
%% ----------------------------------
result_code(Result) ->
    case Result of
        ok ->
            0;
        none ->
            -1;
        error_state ->
            -2;
        invalid_order_id ->
            -2;
        not_ip ->
            -3;
        error_rc4 ->
            -4;
        order_completed ->
            -5;
        Result ->
            -200
    end.

result_msg(Result) ->
    case Result of
        ok ->
            "游戏支付成功";
        error_sha ->
            "校验码错误";
        order_none ->
            "订单不存在";
        invalid_order_id ->
            "无效订单";
        null_player_id ->
            "无效玩家账号";
        not_ip ->
            "ip 不合法";
        error_rc4 ->
            "校验码错误";
        order_completed ->
            "订单已处理";
        _ ->
            ?ERROR("result_msg errror: ~p~n", [Result]),
            "其他错误"
    end.
