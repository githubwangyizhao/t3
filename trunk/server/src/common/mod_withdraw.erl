%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 4月 2021 下午 05:37:17
%%%-------------------------------------------------------------------
-module(mod_withdraw).
-author("Administrator").

%% API
-export([
    player_withdraw/2,
    is_num_of_order_ge_one/6
]).

-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("p_message.hrl").
-include("db_config.hrl").

-define(AVATAR_ICON_URL, "http://www.bountymasters.com:7080/resource/assets/icon/head/").
%%-define(PROPS_TRADER_URL(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, ?IF(?IS_DEBUG, "http://192.168.10.129:8081/", "https://test.props-trader.com/"), "https://test.props-trader.com/")).
-define(PROPS_TRADER_URL(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, ?IF(?IS_DEBUG, "http://192.168.31.113:8081/", "http://47.101.164.86:8081/"), "https://test.props-trader.com/")).
-define(GAME_NAME, "an execllent game").
-define(GAME_ICON, "123").


player_withdraw(PlayerId, ItemId) ->
    ?DEBUG("PlayerId: ~p", [PlayerId]),
    #db_player{
        server_id = ServerId,
        type = Type,
        forbid_type = ForbidType
    } = mod_player:get_player(PlayerId),
    ?DEBUG("ItemId: ~p", [ItemId]),
    %% 非普通账号或被封禁账号，禁止发起装备回收 报错unavailable_account
    ?ASSERT(Type =:= 0 andalso ForbidType =/= 2, unavailable_account),
    PlatformId = mod_server_config:get_platform_id(),
    PlayerRefusedMoney =
        case catch rpc:call(util:to_atom(mod_server_config:get_charge_node()), mod_google_pay, chk_player_has_refused, [PlatformId, ServerId, PlayerId]) of
            {MatchPlayerId, RefusedMoney} when is_integer(MatchPlayerId) andalso MatchPlayerId =:= PlayerId ->
                RefusedMoney;
            {MatchPlayerId, RefusedMoney} when is_integer(MatchPlayerId) ->
                ?ERROR("PlayerId not match: ~p ~p", [MatchPlayerId, PlayerId]), 100;
            {'EXIT', Other} -> ?ERROR("call charge_server mod_google_pay:chk_player_has_refused failure: ~", [Other]),
                100;
            {_, Other1} -> ?ERROR("undefined error: ~p", [Other1]), 100
        end,
    ?INFO("withdraw PlayerRefusedMoney: ~p", [PlayerRefusedMoney]),
    if
        PlayerRefusedMoney > 0 ->
            mod_mail:add_mail_id([PlayerId], ?MAIL_TRADE_AFTER_REFUSED, ?LOG_TYPE_SYSTEM_SEND),
            exit(fuck_u_bitch);
        true -> ?INFO("no refused")
    end,
    ?ASSERT(mod_function:is_open(PlayerId, ?FUNCTION_DRAW_MONEY), vip_limit),
    LeftTimes = mod_times:get_left_times(PlayerId, ?TIMES_DRAW_MONEY),
%%    ?ASSERT(LeftTimes >= 0, ?ERROR_TIMES_LIMIT),
    ?ASSERT(LeftTimes > 0, ?ERROR_TIMES_LIMIT),

%%    Num = mod_prop:get_player_prop_num(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_GOLD),
%%    if
%%        ItemId =:= 0 ->
%%            ?INFO("~p player wants to sell: ~p, RES_GOLD: ~p", [PlayerId, ?PROP_TYPE_RESOURCES, ?RES_GOLD]);
%%        true ->
%%            #t_draw_money{
%%                money = Money,
%%                is_show = Unique
%%            } = t_draw_money:get({ItemId}),
%%
%%            ?INFO("~p PROP_TYPE_RESOURCES: ~p, RES_GOLD: ~p, Unique: ~p", [PlayerId, ?PROP_TYPE_RESOURCES, ?RES_GOLD, Unique]),
%%            RealMoney = Money * ?SD_RECHARGE_RATIO,
%%            ?INFO("~p Num: ~p, RealMoney: ~p", [PlayerId, Num, RealMoney]),
%%            ?DEBUG("F: ~p ~p ~p", [Num, RealMoney, Num >= RealMoney]),
%%            ?ASSERT(Num >= RealMoney, not_authority),
%%
%%            Fun =
%%                fun() ->
%%                    ?DEBUG("is unique: ~p", [Unique]),
%%                    if
%%                     物品为非显示状态时，需要判断玩家是不是第一次回收该装备，若是则通过，反之则false
%%                        Unique =:= 0 ->
%%                            R = mod_server_rpc:call_center(mod_withdraw, is_num_of_order_ge_one, ["", PlayerId, ?PROP_TYPE_RESOURCES, ?RES_GOLD, Money, true]),
%%                            ?DEBUG("R: ~p", [R]),
%%                            R;
%%                        true -> true
%%                    end
%%                end,
%%            ?ASSERT(Fun(), not_authority)
%%        end,
%%    ParamList1 = [{"coin", Num / ?SD_RECHARGE_RATIO}, {"itemId", ItemId}],
%%
    %% 调用接口php的登录接口 把AccId、platform、serverId、playerId、nickname、
%%    Avatar = ?AVATAR_ICON_URL ++ "man_1.png",
%%    PlatformId = mod_server_config:get_platform_id(),
%%
%%    #db_player_data{
%%        vip_level = VipLevel
%%    } = mod_player:get_player_data(PlayerId),


%%    ParamList = lists:sort([
%%        {"acc", AccId},
%%        {"platform", PlatformId},
%%        {"game", ?GAME_NAME},
%%        {"avatar", Avatar},
%%        {"nickname", Nickname},
%%        {"character", PlayerId},
%%        {"sex", Sex},
%%        {"server", ServerId},
%%        {"time", RegTime},
%%        {"icon", ?GAME_ICON},
%%        {"times", LeftTimes},
%%        {"level", VipLevel},
%%        {"lang", PlatformId}
%%        | ParamList1
%%    ]),
%%    ?DEBUG("ParamList: ~p", [ParamList]),
%%    StringSign =
%%        lists:foldl(
%%            fun(Param, Tmp) ->
%%                {Key, Value} = Param,
%%                if
%%                    Value =/= "" ->
%%                        RealValue =
%%                            case Key of
%%                                "game" -> binary_to_list(cow_qs:urlencode(util:to_binary(Value)));
%%                                "avatar" -> binary_to_list(cow_qs:urlencode(util:to_binary(Value)));
%%                                "nickname" -> binary_to_list(cow_qs:urlencode(util:to_binary(Value)));
%%                                R -> util:to_list(Value)
%%                            end,
%%                        ?DEBUG("RealValue: ~p", [RealValue]),
%%                        Tmp ++ (?IF(Tmp =/= "", "&", "")) ++ util:to_list(Key) ++ "=" ++ RealValue;
%%                    true ->
%%                        Tmp
%%                end
%%            end,
%%            "", ParamList
%%        ),
%%    ?DEBUG("StringSign: ~p", [lists:concat([StringSign, "&key=", ?WITHDRAW_KEY])]),
%%    Sign = string:to_upper(encrypt:md5(lists:concat([StringSign, "&key=", ?WITHDRAW_KEY]))),
%%    Body = ?PROPS_TRADER_URL(PlatformId) ++ "?" ++ lists:concat([StringSign, "&sign=", Sign]),
    Body = "test",
    ?INFO("Url: ~p", [Body]),
    Body.

is_num_of_order_ge_one(OrderSn, PlayerId, PropType, PropId, Amount, ResGeOne) ->
    case catch get_oauth_order_info(OrderSn, PlayerId, PropType, PropId, Amount) of
        {'EXIT', not_exists} ->
            ?DEBUG("order exists allow to exchange"),
            true;
        R ->
            ?INFO("order is existsed: ~p ~p", [R, ResGeOne =:= true]),
            if
                ResGeOne =:= true ->
                    ?IF(is_list(R) andalso length(R) >= 1, false, true);
                true ->
                    R
            end
    end.

get_oauth_order_info(OrderSn, PlayerId, PropType, PropId, Amount) ->
    OrderInfo = null,
%%    OrderInfo =
%%        case OrderSn of
%%            R when is_list(R) ->
%%                db:read(#key_oauth_order_log{ order_id = OrderSn});
%%            null ->
%%                exit(not_exists);
%%            "" ->
%%                null
%%        end,
    OrderInfo1 =
        if
            OrderInfo =:= null ->
                ?INFO("SELECT * from `oauth_order_log` WHERE player_id = '~s' and prop_type = '~s' and prop_id = '~s' and amount = '~s' and status != 0", [util:to_list(PlayerId), util:to_list(PropType), util:to_list(PropId), util:to_list(Amount)]),
                Sql = io_lib:format("SELECT * from `oauth_order_log` WHERE player_id = '~s' and prop_type = '~s' and prop_id = '~s' and amount = '~s' and status != 0", [util:to_list(PlayerId), util:to_list(PropType), util:to_list(PropId), util:to_list(Amount)]),
                case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
                    {error, Msg} ->
                        ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
                        exit(not_exists);
                    {data, SelectRes} ->
                        ?DEBUG("SelectRes: ~p", [SelectRes]),
                        Fun =
                            fun(R) ->
                                R#db_oauth_order_log{
                                    row_key = R#db_oauth_order_log.order_id
                                }
                            end,
                        RealOrderInfoList = lib_mysql:as_record(SelectRes, db_oauth_order_log, record_info(fields, db_oauth_order_log), Fun),
                        case RealOrderInfoList of
                            [] ->
                                exit(not_exists);
                            MultiRealOrderInfo ->
                                MultiRealOrderInfo
                        end
                end;
            true ->
                OrderInfo
        end,
    OrderInfo1.
