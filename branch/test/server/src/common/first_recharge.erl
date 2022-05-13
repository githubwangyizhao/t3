%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2019
%%% @doc
%%% @end
%%% Created : 20. 十一月 2019 14:19
%%%-------------------------------------------------------------------
-module(first_recharge).

-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").

%% API
-export([
    get_first_recharge_state/1,                     %% 获得首充状态
    assert_first_recharge/2,                        %% 校验首充
    deal_charge/2                                   %% 充值后的操作
]).

get_first_recharge_state(PlayerId) ->
    FirstChargeId = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_FIRST_CHARGE_ID),
    ?IF(FirstChargeId > 0, ?TRUE, ?FALSE).

%% @doc 校验首充
assert_first_recharge(PlayerId, RechargeId) ->
    #t_recharge{
        recharge_type = RechargeType
    } = mod_charge:try_get_t_recharge(RechargeId),
    case RechargeType of
        ?CHARGE_GAME_FIRST_CHARGE ->
            ?ASSERT(?FALSE == get_first_recharge_state(PlayerId));
        _ ->
            noop
    end.

%%%% @doc 领取首充奖励
%%get_new_first_recharge_award(PlayerId, Id) ->
%%    DbPlayerNewFirstRecharge = get_db_player_new_first_recharge_or_init(PlayerId),
%%    #db_player_new_first_recharge{
%%        id = Id,
%%        state = State
%%    } = DbPlayerNewFirstRecharge,
%%    case State of
%%        ?AWARD_NONE ->
%%            exit(?ERROR_NO_CONDITION);
%%        ?AWARD_ALREADY ->
%%            exit(?ERROR_ALREADY_HAVE);
%%        ?AWARD_CAN ->
%%            noop
%%    end,
%%    ItemList = ?SD_NEW_FIRST_RECHARGE_REWARD,
%%    [_, Value] = util_list:get(Id, ?SD_NEW_FIRST_RECHARGE_COUNT),
%%    NewItemList = [[?PROP_TYPE_RESOURCES, ?RES_DIAMOND, Value] | ItemList],
%%    mod_prop:assert_give(PlayerId, NewItemList),
%%    Tran =
%%        fun() ->
%%            mod_award:give(PlayerId, NewItemList, ?LOG_TYPE_CHARGE_FIRST_GET),
%%            db:write(DbPlayerNewFirstRecharge#db_player_new_first_recharge{state = ?AWARD_ALREADY})
%%        end,
%%    db:do(Tran),
%%    ok.

%% @doc 充值后的操作
deal_charge(PlayerId, RechargeId) ->
    #t_recharge{
        recharge_type = RechargeType
    } = mod_charge:try_get_t_recharge(RechargeId),
    if
        ?CHARGE_GAME_FIRST_CHARGE =:= RechargeType ->
            case get_first_recharge_state(PlayerId) of
                ?FALSE ->
%%                    T_FirstRecharge = t_first_recharge:get({RechargeId}),
%%                    if
%%                        T_FirstRecharge =:= null ->
%%                            ?ERROR("首充表配置错误");
%%                        true ->
%%                            #t_first_recharge{
%%                                value = Value,
%%                                item_list = ItemList
%%                            } = T_FirstRecharge,
%%                            NewItemList = [[?ITEM_GOLD, Value] | ItemList],
                    Tran =
                        fun() ->
                            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_FIRST_CHARGE_ID, RechargeId)
%%                                    mod_award:give(PlayerId, NewItemList, ?LOG_TYPE_FIRST_CHARGE)
                        end,
                    db:do(Tran),
                    ok;
%%                    end;
                _ ->
                    noop
            end;
        true ->
            noop
    end.
