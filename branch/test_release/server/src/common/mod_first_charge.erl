%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         首充
%%% @end
%%% Created : 27. 9月 2021 下午 12:18:37
%%%-------------------------------------------------------------------
-module(mod_first_charge).
-author("Administrator").

-include("gen/db.hrl").
-include("common.hrl").
-include("error.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("p_message.hrl").

%% API
-export([
    get_award/3,

    deal_charge/2,
    add_login_day/2,
    add_login_day/3,

    get_data_list/1,
    get_data/2
]).

%%%% @doc 领取首充奖励
get_award(PlayerId, Type, Day) ->
    DbPlayerFirstCharge = get_db_player_first_charge(PlayerId, Type),
    ?ASSERT(is_record(DbPlayerFirstCharge, db_player_first_charge), ?ERROR_NOT_AUTHORITY),
    #db_player_first_charge{
        login_day = LoginDay,
        recharge_id = RechargeId
    } = DbPlayerFirstCharge,
    DbPlayerFirstChargeDay = get_db_player_first_charge_day(PlayerId, Type, Day),
    ?ASSERT(DbPlayerFirstChargeDay == null, ?ERROR_ALREADY_GET),
    ?ASSERT(LoginDay >= Day, ?ERROR_NO_CONDITION),
    #t_first_recharge{
        item_list = ItemLists
    } = get_t_first_recharge(RechargeId),
    ItemList = lists:nth(Day, ItemLists),
    mod_prop:assert_give(PlayerId, ItemList),
    Tran =
        fun() ->
            mod_award:give(PlayerId, ItemList, ?LOG_TYPE_FIRST_CHARGE),
            db:write(#db_player_first_charge_day{player_id = PlayerId, type = Type, day = Day, time = util_time:timestamp()})
        end,
    db:do(Tran),
    ok.

%% @doc 充值后的操作
deal_charge(PlayerId, RechargeId) ->
    #t_recharge{
        recharge_type = RechargeType
    } = mod_charge:try_get_t_recharge(RechargeId),
    T_FirstCharge = t_first_recharge:get({RechargeId}),
    if
        RechargeType == ?CHARGE_GAME_FIRST_CHARGE andalso T_FirstCharge =/= null ->
            Type =
                if
                    RechargeId == 21 orelse RechargeId == 40211 orelse RechargeId == 201 ->
                        1;
                    RechargeId == 22 orelse RechargeId == 40221 orelse RechargeId == 202 ->
                        2;
                    true ->
                        exit({first_charge_error, PlayerId, RechargeId})
                end,
            DbPlayerFirstCharge = get_db_player_first_charge(PlayerId, Type),
            ?ASSERT(DbPlayerFirstCharge == null),
            #t_first_recharge{
                item_list = ItemLists
            } = T_FirstCharge,
            Day = 1,
            ItemList = lists:nth(Day, ItemLists),
            Time = util_time:timestamp(),
            Tran =
                fun() ->
                    mod_award:give(PlayerId, ItemList, ?LOG_TYPE_FIRST_CHARGE),
                    db:write(#db_player_first_charge{player_id = PlayerId, type = Type, recharge_id = RechargeId, login_day = Day, time = Time}),
                    db:write(#db_player_first_charge_day{player_id = PlayerId, type = Type, day = Day, time = Time}),
                    db:tran_apply(
                        fun() ->
                            api_first_charge:notice_update_data(PlayerId, Type),
                            api_first_charge:send_get_award_result(PlayerId, 'success', Type, Day)
                        end
                    )
                end,
            db:do(Tran),
            ok;
        true ->
            noop
    end.

%% @doc 增加登录天数
add_login_day(PlayerId, LastLoginIsToday, LastOfflineIsToday) ->
    if
        LastLoginIsToday == false andalso LastOfflineIsToday == false ->
            add_login_day(PlayerId, false);
        true ->
            noop
    end.
add_login_day(PlayerId, IsNotice) ->
    Tran =
        fun() ->
            lists:foreach(
                fun(Type) ->
                    case get_db_player_first_charge(PlayerId, Type) of
                        null ->
                            noop;
                        DbPlayerFirstCharge ->
                            #db_player_first_charge{
                                login_day = OldLoginDay,
                                recharge_id = RechargeId
                            } = DbPlayerFirstCharge,
                            #t_first_recharge{
                                item_list = ItemLists
                            } = get_t_first_recharge(RechargeId),
                            Len = length(ItemLists),
                            if
                                OldLoginDay >= Len ->
                                    noop;
                                true ->
                                    db:write(DbPlayerFirstCharge#db_player_first_charge{login_day = OldLoginDay + 1}),
                                    if
                                        IsNotice ->
                                            db:tran_apply(
                                                fun() ->
                                                    api_first_charge:notice_update_data(PlayerId, Type)
                                                end
                                            );
                                        true ->
                                            noop
                                    end
                            end
                    end
                end,
                [1, 2]
            )
        end,
    db:do(Tran),
    ok.

get_data_list(PlayerId) ->
    lists:map(
        fun(Type) ->
            get_data(PlayerId, Type)
        end,
        [1, 2]
    ).
get_data(PlayerId, Type) ->
    DbPlayerFirstCharge = get_db_player_first_charge(PlayerId, Type),
    IsBuy = DbPlayerFirstCharge =/= null,
    List =
        if
            IsBuy ->
                #db_player_first_charge{
                    login_day = LoginDay,
                    recharge_id = RechargeId
                } = DbPlayerFirstCharge,
                #t_first_recharge{
                    item_list = ItemLists
                } = get_t_first_recharge(RechargeId),
                Len = length(ItemLists),
                lists:map(
                    fun(Day) ->
                        case get_db_player_first_charge_day(PlayerId, Type, Day) of
                            null ->
                                #firstchargedata{
                                    day = Day,
                                    state = ?IF(LoginDay >= Day, ?AWARD_CAN, ?AWARD_NONE)
                                };
                            _ ->
                                #firstchargedata{
                                    day = Day,
                                    state = ?AWARD_ALREADY
                                }
                        end
                    end,
                    lists:seq(1, Len)
                );
            true ->
                []
        end,
    #firstcharge{
        type = Type,
        is_buy = ?TRAN_BOOL_2_INT(IsBuy),
        list = List
    }.

%% ================================================ 数据操作 ================================================

%% @doc DB 获得玩家首充
get_db_player_first_charge(PlayerId, Type) ->
    db:read(#key_player_first_charge{player_id = PlayerId, type = Type}).

%% @doc DB 获得玩家首充天数
get_db_player_first_charge_day(PlayerId, Type, Day) ->
    db:read(#key_player_first_charge_day{player_id = PlayerId, type = Type, day = Day}).

%% ================================================ 配置表操作 ================================================

%% @doc 获得首充表
get_t_first_recharge(Id) ->
    t_first_recharge:assert_get({Id}).