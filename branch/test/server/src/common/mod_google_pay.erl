%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 5月 2021 下午 02:26:14
%%%-------------------------------------------------------------------
-module(mod_google_pay).
-author("Administrator").

%% API
-export([
    chk_google_order_specified_date/0,
    handle_google_order_refused/3,
    get_order_id_by_platform_order_id/1,
    chk_player_has_refused/3
]).

-include("common.hrl").
-include("gen/table_enum.hrl").
-include("gen/db.hrl").
-include("db_config.hrl").

%% 测试服
%%-define(CHK_GOOGLE_ORDER_URL(PlatformId), "http://47.101.164.86:8083").
%% 正式服
-define(CHK_GOOGLE_ORDER_URL(PlatformId), "http://admin.props-trader.com").
-define(CHK_GOOGLE_ORDER_PATH, "/google/query_order_list").
-define(KEY, "nSvc3mzG9UroVhTmc112p53U6A0UVJT6").
-define(REFUSED, "refused").
-define(FINISH, "DONE").

%% 游戏服 调用指定api获取google的退款订单
chk_google_order_specified_date() ->
    EndTime = util_time:timestamp(),
    StartTime = EndTime - ?GOOGLE_PAY_TIME_STEP,
%%    EndTime = 1620474733,
%%    StartTime = 1620469206,
    ParamList = [
        {"start_time", StartTime},
        {"end_time", EndTime}
    ],
    OriginalString =
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
            "",
            lists:sort(ParamList)
        ),
    ?DEBUG("StringSign: ~p", [OriginalString]),
    Signature = string:to_upper(encrypt:md5(lists:concat([OriginalString, "&key=", ?KEY]))),
    Url = ?CHK_GOOGLE_ORDER_URL(mod_server_config:get_platform_id()) ++ ?CHK_GOOGLE_ORDER_PATH ++
        "?" ++ util_list:change_list_url(ParamList) ++ "&sign=" ++ Signature,
    ?DEBUG("Url: ~p", [Url]),
    case util_http:get(Url) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Code = util:to_int(maps:get(<<"errcode">>, Response)),
            Msg = util:to_list(maps:get(<<"errmsg">>, Response)),
            if
                Code =:= 0 ->
                    Data = maps:get(<<"data">>, Response),
                    OrderIdVoidedTimeTupleList =
                        lists:filtermap(
                            fun({OrderId, Info}) -> {true, {binary_to_list(OrderId), maps:get(<<"voided_time">>, Info)}} end,
                            maps:to_list(Data)
                        ),
                    ?DEBUG("VersionList: ~p ~p", [Data, is_map(Data)]),
                    Fun =
                        fun() ->
                            case update_google_order_status(OrderIdVoidedTimeTupleList, ?REFUSED) of
                                error -> ?DEBUG("ddd");
                                failure -> ?ERROR("invalid operation");
                                zero -> ?INFO("没有要上报充值服处理的退款订单");
                                PlatformOrderIdList when is_list(PlatformOrderIdList) ->
                                    ?DEBUG("PlatformOrderIdList: ~p", [PlatformOrderIdList]),
                                    OrderIdList = get_order_id_by_platform_order_id(PlatformOrderIdList),
                                    PlatformId = mod_server_config:get_platform_id(),
                                    ServerId = hd(mod_server:get_server_id_list()),
                                    ?INFO("gameServer chk_google_order_specified_date ChargeNode: ~p PlatformId: ~p ServerId: ~p OrderIdList: ~p", [util:to_atom(mod_server_config:get_charge_node()), PlatformId, ServerId, OrderIdList]),
                                    case catch rpc:call(util:to_atom(mod_server_config:get_charge_node()), mod_google_pay, handle_google_order_refused, [PlatformId, ServerId, OrderIdList]) of
                                        {'EXIT', Err} ->
                                            ?ERROR("调用充值服查询订单时报错: ~p", [Err]);
                                        ok ->
                                            %% 修改charge_state=5的订单为charge_state=6
                                            update_google_order_status(OrderIdVoidedTimeTupleList, ?FINISH),
                                            ?DEBUG("finish")
                                    end
                            end
%%                            report_google_order_by_id(PlatformOrderIdList)
                        end,
                    db:do(Fun),
                    ok;
                true ->
                    ?ERROR("Code: ~p; Msg: ~p", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [Url, Reason]),
            false
    end,
    ?DEBUG("start to check google pay status. startTime: ~p, endTime: ~p", [StartTime, EndTime]).

%% 游戏服批量修改player_recharge_record表的指定记录
update_google_order_status(OrderIdVoidedTimeTupleList, Operation) ->
    ?INFO("updage_google_order_status: ~p ~p", [is_list(OrderIdVoidedTimeTupleList), OrderIdVoidedTimeTupleList]),
    SqlWhenThen =
        lists:foldl(
            fun({PlatformOrderId, VoidedTime}, Tmp) ->
                ["WHEN '" ++ PlatformOrderId ++ "' THEN '" ++ integer_to_list(VoidedTime) ++ "'" | Tmp]
            end,
            [],
            OrderIdVoidedTimeTupleList
        ),
    ?DEBUG("SqlWhenThen: ~p", [SqlWhenThen]),
    PlatformOrderIdList =
        lists:foldl(
            fun({PlatformOrderId, _}, Tmp) ->
                [PlatformOrderId | Tmp]
            end,
            [],
            OrderIdVoidedTimeTupleList
        ),
    ?DEBUG("PlatformOrderId: ~p", [PlatformOrderIdList]),
    {OldChargeState, NewChargeState} =
        case Operation of
            ?REFUSED -> {5, 9};
            ?FINISH -> {6, 5};
            Other -> ?ERROR("invalid Operation: ~p", [Other]), {0, 0}
        end,
    ?ASSERT(OldChargeState =/= 0 andalso NewChargeState =/= 0, failure),
    Sql = io_lib:format(
        "UPDATE player_charge_record SET charge_state = ~s, change_time = (CASE platform_order_id ~s END) " ++
        "WHERE charge_state = ~s and platform_order_id in (~s)",
        [integer_to_list(OldChargeState), lists:join(" ", SqlWhenThen), integer_to_list(NewChargeState), "'" ++ lists:join("', '", PlatformOrderIdList) ++ "'"]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {updated, {mysql_result, _, _,Num, _, _, _, _}} ->
            ?INFO("batch update player_charge_record num: ~p. total: ~p", [Num, PlatformOrderIdList]),
            ?IF(Num =/= 0, PlatformOrderIdList, zero)
    end.

%% 充值服 处理订单状态
handle_google_order_refused(PlatformId, ServerId, PlatformOrderIdList) ->
    case update_charge_info_record_google_refused(PlatformId, ServerId, PlatformOrderIdList) of
        error -> ?ERROR("update charge_info_record failure. please check db_error_log"), failure;
        zero -> ?ERROR("update charge_info_record return zero"), failure;
        ok ->
            ?INFO("update charge_info_record success"),
            case update_player_charge_info_record_google_refuse(PlatformId, ServerId, PlatformOrderIdList) of
                error -> ?ERROR("select charge_info_record failure. please check db_error_log"), failure;
                failure -> ?ERROR("there is not order matched"), failure;
                PlayerMoneyTupleList when is_list(PlayerMoneyTupleList) ->
                    case update_player_charge_info_record_google_refused(PlayerMoneyTupleList) of
                        error -> ?ERROR("batch update player_charge_info_record failure"), failure;
                        zero -> ?ERROR("batch update player_charge_info_record empty"), failure;
                        PlayerIdList when is_list(PlayerIdList) ->
                            %% 数据库里的数据导入dets
                            case batch_update_dets_player_charge_info_record(PlayerIdList) of
                                error -> ?ERROR("update player_charge_info_record dets failure. see db_error_log"), failure;
                                ok -> ?INFO("success"), ok
                            end
                    end
            end;
        R -> ?ERROR("update charge_info_record failure. reason: ~p", [R]), failure
    end.

batch_update_dets_player_charge_info_record(PlayerIdList) ->
    Sql = io_lib:format("SELECT * FROM player_charge_info_record WHERE player_id in (~s)", PlayerIdList),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {data, SelectRes} ->
            Fun = fun(R) ->
                R#db_player_charge_info_record{
                    row_key = {R#db_player_charge_info_record.player_id}
                }
                  end,
            L = lib_mysql:as_record(SelectRes, db_player_charge_info_record, record_info(fields, db_player_charge_info_record), Fun),
            ?DEBUG("L: ~p", [L]),
            lists:foreach(
                fun(PlayerChargeInfoRecord) ->
                    dets:insert(player_charge_info_record, [PlayerChargeInfoRecord])
                end,
                L
            ),
            ok
    end.

%% 充值服 查询指定平台、区服、玩家的退款总金额
chk_player_has_refused(PlatformId, ServerId, PlayerId) ->
    ?INFO("chk_player_has_refused: ~p ~p ~p", [PlatformId, ServerId, PlayerId]),
    Sql = io_lib:format("SELECT * FROM player_charge_info_record WHERE player_id = '~s' and part_id = '~s' and server_id = '~s' LIMIT 1", [util:to_list(PlayerId), PlatformId, ServerId]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {data, SelectRes} ->
            Fun = fun(R) ->
                R#db_player_charge_info_record{
                    row_key = {R#db_player_charge_info_record.player_id}
                }
                  end,
            L = lib_mysql:as_record(SelectRes, db_player_charge_info_record, record_info(fields, db_player_charge_info_record), Fun),
            ?DEBUG("L: ~p", [L]),
            case L of
                [] -> {PlayerId, 0.0};
                L ->
                    [#db_player_charge_info_record{
                        refused_money = RefusedMoney
                    }] = L,
                    {PlayerId, RefusedMoney}
            end
    end.

%% 充值服修改charge_info_record表的指定记录
update_charge_info_record_google_refused(PlatformId, ServerId, PlatformOrderIdList) ->
    ?DEBUG("ChargeServer: ~p ~p ~p", [PlatformId, ServerId, PlatformOrderIdList]),
    Sql = io_lib:format("UPDATE charge_info_record SET status = 0 WHERE part_id = '~s' and server_id = '~s' and order_id in (~s)",
        [PlatformId, ServerId, "'" ++ lists:join("', '", PlatformOrderIdList) ++ "'"]),
    ?INFO("update charge_info_record sql: ~p", [Sql]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {updated, {mysql_result, _, _,Num, _, _, _, _}} ->
            ?INFO("batch update charge_info_record num: ~p. total: ~p", [Num, PlatformOrderIdList]),
            if
                Num =:= 0 -> zero;
                true -> ok
            end
    end.

%% 充值服查询charge_info_record表的指定记录
update_player_charge_info_record_google_refuse(PlatformId, ServerId, PlatformOrderIdList) ->
    Sql = io_lib:format("SELECT * FROM charge_info_record WHERE status = 0 and part_id = '~s' and server_id = '~s' and order_id in (~s)", [PlatformId, ServerId, "'" ++ lists:join("', '", PlatformOrderIdList) ++ "'"]),
    ?INFO("select charge_info_record sql: ~p", [Sql]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {data, SelectRes} ->
            Fun = fun(R) ->
                R#db_charge_info_record{
                    row_key = {R#db_charge_info_record.order_id}
                }
                  end,
            L = lib_mysql:as_record(SelectRes, db_charge_info_record, record_info(fields, db_charge_info_record), Fun),
            ?DEBUG("L: ~p", [L]),
            if
                length(L) =:= 0 -> failure;
                true ->
                    PlayerMoneyTupleList =
                        lists:foldl(
                            fun(Ele, Tmp) ->
                                #db_charge_info_record{
                                    player_id = PlayerId,
                                    money = Money
                                } = Ele,
                                {RealMoney, RealChargeCount} =
                                    case lists:keytake(PlayerId, 1, Tmp) of
                                        false ->
                                            {Money, 1};
                                        {value,{_, MoneyInTmp, ChargeCountInTmp}, _} ->
                                            {MoneyInTmp + Money, ChargeCountInTmp + 1}
                                    end,
                                lists:keystore(PlayerId, 1, Tmp, {PlayerId, RealMoney, RealChargeCount})
                            end, [], L
                        ),
                    ?DEBUG("PlayerMoneyTupleList: ~p", [PlayerMoneyTupleList]),
                    PlayerMoneyTupleList
            end
    end.

%% 充值服修改player_charge_info_record
update_player_charge_info_record_google_refused(PlayerMoneyTupleList) ->
    %% [{player_id, money, count}, {player_id, money, count}, {...}, ...]
    %% update player_charge_info_record set
    %% charge_count = charge_count - (CASE player_id WHEN 11197 THEN a WHEN 11198 THEN b END),
    %% total_money = total_money - (CASE player_id WHEN 11197 THEN c WHEN 11198 THEN d END)
    %% WHERE player_id in (11197, 11198)
    UpdateColumnList = [{total_money, 1}, {charge_count, 1}, {refused_money, 1}],
    WhereColumnList = [{player_id, 1}],
    SqlWhenThen =
        lists:foldl(
            fun({PlayerId, Money, ChargeCount}, Tmp) ->
                PlayerIdSql = integer_to_list(PlayerId),
                RealPlayerId =
                    case lists:keytake(player_id, 1, Tmp) of
                        false -> PlayerIdSql;
                        {value,{_, PlayerIdInTmp}, _} -> PlayerIdInTmp ++ ", " ++ PlayerIdSql
                    end,
                Tmp1 = lists:keystore(player_id, 1, Tmp, {player_id, RealPlayerId}),

                MoneySql = "WHEN '" ++ integer_to_list(PlayerId) ++ "' THEN (total_money - " ++ util:to_list(Money) ++ ") ",
                RealMoneySql =
                    case lists:keytake(total_money, 1, Tmp) of
                        false -> MoneySql;
                        {value,{_, MoneySqlInTmp}, _} -> MoneySqlInTmp ++ MoneySql
                    end,
                Tmp2 = lists:keystore(total_money, 1, Tmp1, {total_money, RealMoneySql}),

                ChargeCountSql = "WHEN '" ++ integer_to_list(PlayerId)  ++ "' THEN (charge_count - " ++ integer_to_list(ChargeCount) ++ ") ",
                RealChargeCount =
                    case lists:keytake(charge_count, 1, Tmp) of
                        false -> ChargeCountSql;
                        {value,{_, ChargeCountInTmp}, _} -> ChargeCountInTmp ++ ChargeCountSql
                    end,
                Tmp3 = lists:keystore(charge_count, 1, Tmp2, {charge_count, RealChargeCount}),

                RefusedMoneySql = "WHEN '" ++ integer_to_list(PlayerId)  ++ "' THEN (refused_money + " ++ util:to_list(Money) ++ ") ",
                RealRefusedMoneySql =
                    case lists:keytake(refused_money, 1, Tmp) of
                        false -> RefusedMoneySql;
                        {value,{_, RefusedMoneySqlInTmp}, _} -> RefusedMoneySqlInTmp ++ RefusedMoneySql
                    end,
                Tmp4 = lists:keystore(refused_money, 1, Tmp3, {refused_money, RealRefusedMoneySql}),
                Tmp4
            end,
            [],
            PlayerMoneyTupleList
        ),
    ?INFO("MoneySqlWhenThen: ~p", [SqlWhenThen]),
    SqlList = lists:foldl(
        fun({ColumnName, Pos}, Tmp) ->
            case lists:keyfind(ColumnName, Pos, SqlWhenThen) of
                false -> "";
                {_, Sql} ->
                    [util:to_list(ColumnName) ++ " = " ++ " (CASE player_id " ++ Sql ++ "END) " | Tmp]
            end
        end,
        [],
        UpdateColumnList
    ),
    ConditionList = lists:foldl(
        fun({ColumnName, Pos}, Tmp) ->
            case lists:keyfind(ColumnName, Pos, SqlWhenThen) of
                false -> "";
                {_, Sql} ->
                    [Sql | Tmp]
            end
        end,
        [],
        WhereColumnList
    ),
    PlayerIdList = lists:join(",", ConditionList),
    Sql = io_lib:format("UPDATE player_charge_info_record SET ~s WHERE player_id in (~s)", [lists:join(",", SqlList), PlayerIdList]),
    ?INFO("update player_charge_info_record sql: ~ts", [Sql]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {updated, {mysql_result, _, _,Num, _, _, _, _}} ->
            ?INFO("batch update charge_info_record num: ~p. total: ~p", [Num, PlayerIdList]),
            if
                Num =:= 0 -> zero;
                true -> PlayerIdList
            end
    end.

%% 游戏服 查询player_recharge_record表的已经退款的记录
get_order_id_by_platform_order_id(PlatformOrderIdList) ->
    Sql = io_lib:format("SELECT * FROM player_charge_record WHERE charge_state = 5 and platform_order_id in (~s)", ["'" ++ lists:join("', '", PlatformOrderIdList) ++ "'"]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {data, SelectRes} ->
            Fun = fun(R) ->
                R#db_player_charge_record{
                    row_key = {R#db_player_charge_record.order_id}
                }
                  end,
            L = lib_mysql:as_record(SelectRes, db_player_charge_record, record_info(fields, db_player_charge_record), Fun),
            ?DEBUG("L: ~p", [L]),
            lists:foldl(
                fun(Ele, Tmp) ->
                    #db_player_charge_record{
                        order_id = OrderId
                    } = Ele,
                    [OrderId | Tmp]
                end, [], L
            )
    end.