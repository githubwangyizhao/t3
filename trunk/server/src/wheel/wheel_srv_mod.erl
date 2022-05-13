%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         无尽对决
%%% @end
%%% Created : 03. 11月 2021 下午 03:56:04
%%%-------------------------------------------------------------------
-module(wheel_srv_mod).
-author("Administrator").

-include("common.hrl").
-include("gen/table_enum.hrl").
-include("gen/db.hrl").
-include("server_data.hrl").
-include("wheel.hrl").
-include("player_game_data.hrl").
-include("gen/table_db.hrl").
-include("error.hrl").

%% API
-export([
    init/0,

    handle_join_wheel/5,
    handle_bet/3,
    handle_balance/1,
    handle_get_record/2,
    handle_get_bet_record/2,
    handle_exit_wheel/1,
    handle_get_player_list/1,
    handle_clear_record/0,
    get_last_bet_list/1,
    use_last_bet_list/2,

    start_wheel_balance_timer/2
]).

-export([
    get_t_big_wheel/1,
    get_t_big_wheel_icon/2
]).

-export([
    dict_write_data/3
]).

-export([
%%    get_player_prop_num_list/2,
    notice_balance/6
]).

init() ->
    Now = util_time:timestamp(),
    lists:foreach(
        fun({WheelType}) ->
            #t_big_wheel{
                time = TimerTime
            } = get_t_big_wheel(WheelType),
            start_wheel_balance_timer(WheelType, TimerTime),
            dict_write_data(?WHEEL_DATA, WheelType, #wheel_data{
                time = Now + TimerTime
            })
        end,
        t_big_wheel:get_keys()
    ).

start_wheel_balance_timer(WheelType, TimerTime) ->
    erlang:send_after(TimerTime * ?SECOND_MS, self(), {?WHEEL_MSG_BALANCE, WheelType}).

%% 玩家进入的话，列表要实时变化
handle_join_wheel(PlayerId, Type, PlatformId, ServerId, ModelHeadFigure) ->
    WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),

    MyBetList =
        case WheelPlayerData of
            null ->
                List = dict_select_default(?SERVER_PLAYER_LIST, Type, []),

                NewList =
                    case lists:keytake({PlatformId, ServerId}, 1, List) of
                        false ->
                            [{{PlatformId, ServerId}, [PlayerId]} | List];
                        {value, {{PlatformId, ServerId}, OldPlayerIdList}, List1} ->
                            NewPlayerIdList =
                                case lists:member(PlayerId, OldPlayerIdList) of
                                    true ->
                                        OldPlayerIdList;
                                    false ->
                                        [PlayerId | OldPlayerIdList]
                                end,
                            [{{PlatformId, ServerId}, NewPlayerIdList} | List1]
                    end,
                dict_write_data(?SERVER_PLAYER_LIST, Type, NewList),

                NewWheelPlayerData = #wheel_player_data{
                    player_id = PlayerId,
                    platform_id = PlatformId,
                    server_id = ServerId,
                    type = Type,
                    bet_list = [],
                    model_head_figure = ModelHeadFigure
                },
                dict_write_data(?WHEEL_PLAYER_DATA, PlayerId, NewWheelPlayerData),
                [];
            _ ->
                #wheel_player_data{
                    bet_list = PlayerBetList
                } = WheelPlayerData,
                PlayerBetList
        end,
    WheelData = dict_select(?WHEEL_DATA, Type),
%%    ?DEBUG("WheelData ： ~p", [WheelData]),
    #wheel_data{
        bet_list = BetList,
        time = TimeMs,
        left_rank_list = LeftRankList,
        right_rank_list = RightRankList
    } = WheelData,
    RecordList =
        [
            {Time, ResultId}
            || #db_wheel_result_record{time = Time, result_id = ResultId} <- get_db_wheel_result_record_list(Type)
        ],
    RecordSortList =
        lists:sublist(lists:sort(
            fun({ATime, _}, {BTime, _}) ->
                ATime > BTime
            end,
            RecordList
        ), 15),
    {ok, BetList, TimeMs, LeftRankList, RightRankList, MyBetList, RecordSortList}.

handle_bet(PlayerId, BetId, Num) ->
    WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),
    ?ASSERT(WheelPlayerData =/= null),

    #wheel_player_data{
        bet_list = BetList,
        type = Type
    } = WheelPlayerData,

    NewBetList =
        case lists:keytake(BetId, 1, BetList) of
            false ->
                [{BetId, Num} | BetList];
            {value, {BetId, OldNum}, BetList1} ->
                [{BetId, OldNum + Num} | BetList1]
        end,

    dict_write_data(?WHEEL_PLAYER_DATA, PlayerId, WheelPlayerData#wheel_player_data{bet_list = NewBetList}),

    WheelData = dict_select(?WHEEL_DATA, Type),

    #wheel_data{
        bet_list = TypeBetList,
        player_bet_lists = PlayerBetLists
    } = WheelData,

    {NewTypeBetList, TotalNum} =
        case lists:keytake(BetId, 1, TypeBetList) of
            false ->
                {[{BetId, Num} | TypeBetList], Num};
            {value, {BetId, TypeOldNum}, TypeBetList1} ->
                {[{BetId, TypeOldNum + Num} | TypeBetList1], TypeOldNum + Num}
        end,

    NewPlayerBetLists =
        case lists:keytake(PlayerId, 1, PlayerBetLists) of
            false ->
                [{PlayerId, [{BetId, Num}]} | PlayerBetLists];
            {value, {PlayerId, OldPlayerBetList}, BetList2} ->
                NewPlayerBetList =
                    case lists:keytake(BetId, 1, OldPlayerBetList) of
                        false ->
                            [{BetId, Num} | OldPlayerBetList];
                        {value, {BetId, OldBetNum}, OldPlayerBetList1} ->
                            [{BetId, OldBetNum + Num} | OldPlayerBetList1]
                    end,
                [{PlayerId, NewPlayerBetList} | BetList2]
        end,

    dict_write_data(?WHEEL_DATA, Type, WheelData#wheel_data{bet_list = NewTypeBetList, player_bet_lists = NewPlayerBetLists}),

    ServerPlayerList = dict_select_default(?SERVER_PLAYER_LIST, Type, []),
%%    ?DEBUG("ServerPlayerList : ~p", [ServerPlayerList]),
    lists:foreach(
        fun({{PlatformId, ServerId}, PlayerIdList}) ->
            mod_server_rpc:cast_game_server(PlatformId, ServerId, api_wheel, notice_bet, [PlayerIdList, PlayerId, BetId, Num, TotalNum, NewPlayerBetLists])
        end,
        ServerPlayerList
    ),
    ok.

get_last_bet_list(PlayerId) ->
    WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),
    ?ASSERT(WheelPlayerData =/= null),

    #wheel_player_data{
        type = Type,
        last_bet_list = LastBetList
    } = WheelPlayerData,

    {ok, Type, LastBetList}.

use_last_bet_list(PlayerId, LastBetList) ->
    WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),
    ?ASSERT(WheelPlayerData =/= null),

    #wheel_player_data{
        last_bet_list = PlayerLastBetList
    } = WheelPlayerData,
    ?ASSERT(LastBetList == PlayerLastBetList, ?ERROR_NOT_AUTHORITY),

    lists:foreach(
        fun({BetId, Num}) ->
            handle_bet(PlayerId, BetId, Num)
        end,
        LastBetList
    ),
    ok.

handle_balance(WheelType) ->
    #t_big_wheel{
        time = WheelTimerTime,
        betting_list = [PropId, _],
        mail_id = Mail
    } = get_t_big_wheel(WheelType),
    start_wheel_balance_timer(WheelType, WheelTimerTime),
    Now = util_time:timestamp(),
    DbWheelPool = get_db_wheel_pool(WheelType),
    #db_wheel_pool{
        id = OldWheelId,
        value = PoolValue
    } = DbWheelPool,
    Id =
        if
            OldWheelId >= 50 ->
                1;
            true ->
                OldWheelId + 1
        end,
    Tran =
        fun() ->
            delete_all_player_bet_record(WheelType, Id),
            mod_cache:delete({?MODULE, handle_get_player_list, WheelType}),
            WheelData =
                case dict_select(?WHEEL_DATA, WheelType) of
                    null ->
                        #wheel_data{
                        };
                    R ->
                        R
                end,

            #wheel_data{
                bet_list = WheelBetList,
                player_bet_lists = PlayerBetLists
            } = WheelData,

            WeightList = get_weight_list(WheelType, WheelBetList, PoolValue),

            {ResultId, TypeResultId} = util_random:get_probability_item(WeightList),

            #t_big_wheel_icon{
                leixing = LeiXing
            } = get_t_big_wheel_icon(WheelType, ResultId),

            BetAwardList = logic_get_big_wheel_bet_list:assert_get({WheelType, TypeResultId}),

            WheelTotalBetNum = lists:sum([BetNum || {_, BetNum} <- WheelBetList]),

            WheelTotalAwardNum = lists:foldl(
                fun({BetId, Rate}, TmpAwardNum) ->
                    case lists:keyfind(BetId, 1, WheelBetList) of
                        false ->
                            TmpAwardNum;
                        {BetId, PlayerBetNum} ->
                            TmpAwardNum + trunc(PlayerBetNum * Rate / 10000)
                    end
                end,
                0, BetAwardList
            ),

            NewPoolValue = PoolValue + trunc(WheelTotalBetNum * get_chou_shui_value(WheelType) / 10000) - WheelTotalAwardNum,

            logger2:write(wheel_log,
                [
                    WheelType,
                    PoolValue,
                    NewPoolValue,
                    WeightList
                ]
            ),

            db:write(DbWheelPool#db_wheel_pool{value = NewPoolValue, id = Id}),

            DbWheelResultRecord = get_db_wheel_result_record_init(WheelType, Id),
            db:write(DbWheelResultRecord#db_wheel_result_record{
                result_id = TypeResultId,
                time = Now
            }),
            lists:foreach(
                fun(TypeId) ->
                    DbWheelResultRecordAccumulateInit = get_db_wheel_result_record_accumulate_init(WheelType, OldWheelId, 1, TypeId),
                    DbWheelResultRecordAccumulateInit1 = get_db_wheel_result_record_accumulate_init(WheelType, Id, 1, TypeId),
                    #db_wheel_result_record_accumulate{
                        num = Num
                    } = DbWheelResultRecordAccumulateInit,
                    NewNum =
                        if
                            TypeId == LeiXing ->
                                0;
                            true ->
                                Num + 1
                        end,
                    db:write(DbWheelResultRecordAccumulateInit1#db_wheel_result_record_accumulate{time = Now, num = NewNum})
                end,
                util_list:opt(WheelType, logic_get_wheel_type_or_unique_id_list:assert_get(type_list))
            ),
            mod_cache:delete({?MODULE, WheelType, 1}),
            lists:foreach(
                fun(TypeId) ->
                    DbWheelResultRecordAccumulateInit = get_db_wheel_result_record_accumulate_init(WheelType, OldWheelId, 2, TypeId),
                    DbWheelResultRecordAccumulateInit1 = get_db_wheel_result_record_accumulate_init(WheelType, Id, 2, TypeId),
                    #db_wheel_result_record_accumulate{
                        num = Num
                    } = DbWheelResultRecordAccumulateInit,
                    NewNum =
                        if
                            TypeId == TypeResultId ->
                                0;
                            true ->
                                Num + 1
                        end,
                    db:write(DbWheelResultRecordAccumulateInit1#db_wheel_result_record_accumulate{time = Now, num = NewNum})
                end,
                util_list:opt(WheelType, logic_get_wheel_type_or_unique_id_list:assert_get(id_list))
            ),
            mod_cache:delete({?MODULE, WheelType, 2}),

%%                    ?DEBUG("Data : ~p", [PlayerBetLists]),
            NextTime = Now + ?SD_BIG_WHEEL_TIME,
            NextTimeMs = NextTime * ?SECOND_MS,

            put(player_bet_result_list, []),

            lists:foreach(
                fun({PlayerId, BetList}) ->
                    PropNum =
                        lists:foldl(
                            fun({BetId, Rate}, TmpPropNum) ->
                                case lists:keyfind(BetId, 1, BetList) of
                                    false ->
                                        TmpPropNum;
                                    {BetId, PlayerBetNum} ->
                                        AddNum = trunc(PlayerBetNum * Rate / 10000),
                                        if
                                            WheelType == 1 ->
                                                chat_notice:wheel_gold_big_rate(PlayerId, Rate, AddNum);
                                            WheelType == 2 ->
                                                chat_notice:wheel_red_gem_big_rate(PlayerId, Rate, AddNum);
                                            true ->
                                                noop
                                        end,
                                        TmpPropNum + AddNum
                                end
                            end,
                            0, BetAwardList
                        ),

                    if
                        WheelType == 1 ->
                            chat_notice:wheel_gold(PlayerId, PropNum);
                        WheelType == 2 ->
                            chat_notice:wheel_red_gem(PlayerId, PropNum);
                        true ->
                            noop
                    end,

                    PlayerTotalBetNum = lists:sum([BetNum || {_, BetNum} <- BetList]),

                    logger2:write(wheel_player_log,
                        [
%%                                    LocalDateTime,
                            PlayerId,
                            PlayerTotalBetNum,
                            PropNum
                        ]
                    ),

                    if
                        PropNum > 0 ->
                            put(player_bet_result_list, [{PlayerId, PropNum} | get(player_bet_result_list)]);
                        true ->
                            put(player_bet_result_list, [{PlayerId, PropNum - PlayerTotalBetNum} | get(player_bet_result_list)])
                    end,

                    PropList =
                        if
                            PropNum == 0 ->
                                [];
                            true ->
                                [{PropId, PropNum}]
                        end,

                    write_player_bet_record(WheelType, PlayerId, Id, PlayerTotalBetNum, PropNum, Now),

                    Node = mod_player:get_game_node(PlayerId),
                    WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),

                    if
                        WheelPlayerData == null ->
                            mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, Mail, PropList, [PropNum], ?LOG_TYPE_BIG_WHEEL], game_worker);
                        true ->
                            #wheel_player_data{
                                total_award_num = TotalAwardNum
                            } = WheelPlayerData,
                            NewTotalAwardNum = TotalAwardNum + PropNum,
                            dict_write_data(?WHEEL_PLAYER_DATA, PlayerId, WheelPlayerData#wheel_player_data{total_award_num = NewTotalAwardNum, award = PropNum}),
                            mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give, [PlayerId, PropList, ?LOG_TYPE_BIG_WHEEL], game_worker)
                    end
                end,
                PlayerBetLists
            ),
            ServerPlayerList = dict_select_default(?SERVER_PLAYER_LIST, WheelType, []),
            LeftRankList = get_left_rank_list(WheelType),
            RightRankList = get_right_rank_list(WheelType),
            lists:foreach(
                fun({{PlatformId, ServerId}, PlayerIdList}) ->
                    PlayerPropList =
                        lists:map(
                            fun(PlayerId) ->
                                WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),
                                #wheel_player_data{
                                    award = AwardNum,
                                    bet_list = BetList,
                                    last_bet_list = LastBetList
                                } = WheelPlayerData,
                                NewLastBetList =
                                    if
                                        BetList == [] ->
                                            LastBetList;
                                        true ->
                                            BetList
                                    end,
                                dict_write_data(?WHEEL_PLAYER_DATA, PlayerId, WheelPlayerData#wheel_player_data{award = 0, bet_list = [], last_bet_list = NewLastBetList}),
                                {PlayerId, AwardNum}
                            end,
                            PlayerIdList
                        ),
                    Node = mod_server:get_game_node(PlatformId, ServerId),
                    rpc:cast(Node, ?MODULE, notice_balance, [PlayerPropList, get(player_bet_result_list), ResultId, NextTimeMs, LeftRankList, RightRankList])
                end,
                ServerPlayerList
            ),
            NewWheelData =
                WheelData#wheel_data{
                    bet_list = [],
                    player_bet_lists = [],
                    time = NextTime,
                    left_rank_list = LeftRankList,
                    right_rank_list = RightRankList
                },
            dict_write_data(?WHEEL_DATA, WheelType, NewWheelData)
        end,
    db:do(Tran).
get_left_rank_list(WheelType) ->
    ServerPlayerList = dict_select_default(?SERVER_PLAYER_LIST, WheelType, []),
    PlayerRankList =
        lists:foldl(
            fun({_, PlayerIdList}, TmpL) ->
%%                Node = mod_server:get_game_node(PlatformId, ServerId),
                List = lists:map(
                    fun(PlayerId) ->
                        DbWheelPlayerBetRecordList = get_db_wheel_player_bet_record_list_by_type_and_player(WheelType, PlayerId),
                        TotalBetNum = lists:sum([BetNum || #db_wheel_player_bet_record{bet_num = BetNum} <- DbWheelPlayerBetRecordList]),
                        {PlayerId, TotalBetNum}
                    end,
                    PlayerIdList
                ),
%%                List =
%%                    case util:rpc_call(Node, ?MODULE, get_player_prop_num_list, [PlayerIdList, PropId], infinity) of
%%                        {badrpc, nodedown} ->
%%                            [];
%%                        Data ->
%%                            Data
%%                    end,

                List ++ TmpL
            end,
            [], ServerPlayerList
        ),
    RankList = lists:sort(
        fun({_, AValue}, {_, BValue}) ->
            AValue > BValue
        end,
        PlayerRankList
    ),
%%    RankList = lists:ukeysort(2, PlayerRankList),
    List = lists:sublist(RankList, 3),
    {_Rank, NewRankList} = lists:foldl(
        fun({PlayerId, _Value}, {TmpRank, TmpL}) ->
            WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),
            #wheel_player_data{
                model_head_figure = ModelHeadFigure
            } = WheelPlayerData,
            {TmpRank + 1, [{TmpRank, ModelHeadFigure} | TmpL]}
        end,
        {1, []}, List
    ),
    NewRankList.
get_right_rank_list(WheelType) ->
    ServerPlayerList = dict_select_default(?SERVER_PLAYER_LIST, WheelType, []),
%%    ?DEBUG("ServerPlayerList : ~p", [ServerPlayerList]),
    RankList0 =
        lists:foldl(
            fun({_, PlayerIdList}, TmpL) ->
                List = lists:map(
                    fun(PlayerId) ->
                        DbWheelPlayerBetRecordList = get_db_wheel_player_bet_record_list_by_type_and_player(WheelType, PlayerId),
                        TotalWinNum = lists:sum([1 || #db_wheel_player_bet_record{bet_num = BetNum, award_num = AwardNum} <- DbWheelPlayerBetRecordList, AwardNum > BetNum]),
                        {PlayerId, TotalWinNum}
%%                        WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),
%%                        #wheel_player_data{
%%                            total_award_num = TotalAwardNum
%%                        } = WheelPlayerData,
%%                        [{PlayerId, TotalAwardNum} | TmpList]
                    end,
                    PlayerIdList
                ),
                List ++ TmpL
            end,
            [], ServerPlayerList
        ),
    RankList = lists:sort(
        fun({_, AValue}, {_, BValue}) ->
            AValue > BValue
        end,
        RankList0
    ),
    List = lists:sublist(RankList, 3),
    {_Rank, NewRankList} = lists:foldl(
        fun({PlayerId, _Value}, {TmpRank, TmpL}) ->
            WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),
            #wheel_player_data{
                model_head_figure = ModelHeadFigure
            } = WheelPlayerData,
            {TmpRank + 1, [{TmpRank, ModelHeadFigure} | TmpL]}
        end,
        {1, []}, List
    ),
    NewRankList.
%%get_player_prop_num_list(PlayerIdList, PropId) ->
%%    lists:map(
%%        fun(PlayerId) ->
%%            PropNum = mod_prop:get_player_prop_num(PlayerIdList, PropId),
%%            {PlayerId, PropNum}
%%        end,
%%        PlayerIdList
%%    ).

notice_balance(PlayerPropList, PropList, ResultId, TimesMs, LeftRankList, RightRankList) ->
    lists:foreach(
        fun({PlayerId, _PropNum}) ->
            api_wheel:notice_balance(PlayerId, ResultId, PropList, TimesMs, LeftRankList, RightRankList)
        end,
        PlayerPropList
    ).

handle_get_record(Type, RecordType) ->
    Fun =
        fun() ->
            DbWheelResultRecordList = get_db_wheel_result_record_list(Type),
            NewList = lists:foldl(
                fun(DbWheelResultRecord, TmpL) ->
                    #db_wheel_result_record{
                        id = Id,
                        time = Time
                    } = DbWheelResultRecord,
                    List = get_db_wheel_result_record_accumulate_list(Type, Id, RecordType),
                    if
                        List == [] ->
                            TmpL;
                        true ->
                            #db_wheel_result_record{
                                result_id = ResultId
                            } = get_db_wheel_result_record(Type, Id),
                            [{
                                {Time, ResultId},
                                [{ThisId, Num} || #db_wheel_result_record_accumulate{id = ThisId, num = Num} <- List]} | TmpL
                            ]
                    end
                end,
                [], DbWheelResultRecordList
            ),
            {ok, NewList}
        end,
    mod_cache:cache_data({?MODULE, Type, RecordType}, Fun, 0).

handle_get_bet_record(PlayerId, WheelType) ->
    List = get_db_wheel_player_bet_record_today_list_by_player(WheelType, PlayerId),
%%    DbWheelPlayerBetList = get_db_wheel_player_bet_record_list_by_player(PlayerId),
%%    LocalData = util_time:local_date(),
%%    List = [DbWheelPlayerBet || DbWheelPlayerBet = #db_wheel_player_bet_record{time = Time} <- DbWheelPlayerBetList, util_time:is_today(Time, LocalData)],
    {ok, List}.

handle_clear_record() ->
    DbWheelPlayerBetRecordTodayList = ets:tab2list(wheel_player_bet_record_today),
    Tran =
        fun() ->
            lists:foreach(
                fun(DbWheelPlayerBetRecordToday) ->
                    db:delete(DbWheelPlayerBetRecordToday)
                end,
                DbWheelPlayerBetRecordTodayList
            )
        end,
    db:do(Tran),
    ok.

handle_exit_wheel(PlayerId) ->
    WheelPlayerData = dict_select(?WHEEL_PLAYER_DATA, PlayerId),

    if
        WheelPlayerData == null ->
            noop;
        true ->
            #wheel_player_data{
                platform_id = PlatformId,
                server_id = ServerId,
                type = Type
            } = WheelPlayerData,
            List = dict_select_default(?SERVER_PLAYER_LIST, Type, []),

            NewList =
                case lists:keytake({PlatformId, ServerId}, 1, List) of
                    false ->
                        List;
                    {value, {{PlatformId, ServerId}, OldPlayerIdList}, List1} ->
                        NewPlayerIdList = lists:delete(PlayerId, OldPlayerIdList),
                        if
                            NewPlayerIdList == [] ->
                                List1;
                            true ->
                                [{{PlatformId, ServerId}, NewPlayerIdList} | List1]
                        end
                end,
            dict_write_data(?SERVER_PLAYER_LIST, Type, NewList),

            dict_delete(?WHEEL_PLAYER_DATA, PlayerId)
    end,
    ok.

write_player_bet_record(WheelType, PlayerId, Id, PlayerTotalBetNum, PropNum, Time) ->

    DbWheelPlayerBetRecord = get_db_wheel_player_bet_record(PlayerId, WheelType, Id),
    if
        DbWheelPlayerBetRecord == null ->
            noop;
        true ->
            db:delete(DbWheelPlayerBetRecord)
    end,
    db:write(#db_wheel_player_bet_record{
        type = WheelType,
        player_id = PlayerId,
        id = Id,
        bet_num = PlayerTotalBetNum,
        award_num = PropNum,
        time = Time
    }),

    PlayerWheelRecordId = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_WHEEL_RECORD_ID),
    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_WHEEL_RECORD_ID, PlayerWheelRecordId + 1),

%%    DbWheelPlayerBetList = get_db_wheel_player_bet_record_list_by_player(PlayerId),
%%    DbWheelPlayerBetListLength = length(DbWheelPlayerBetList),
%%    if
%%        DbWheelPlayerBetListLength >= 20 ->
%%            SortList = lists:sort(
%%                fun(DbWheelPlayerBetA, DbWheelPlayerBetB) ->
%%                    DbWheelPlayerBetA#db_wheel_player_bet_record.time < DbWheelPlayerBetB#db_wheel_player_bet_record.time
%%                end,
%%                DbWheelPlayerBetList
%%            ),
%%            db:delete(hd(SortList));
%%        true ->
%%            noop
%%    end,

    db:write(#db_wheel_player_bet_record_today{
        type = WheelType,
        player_id = PlayerId,
        id = PlayerWheelRecordId,
        bet_num = PlayerTotalBetNum,
        award_num = PropNum,
        time = Time
    }).

delete_all_player_bet_record(WheelType, Id) ->
    DeleteId =
        if
            Id =< 20 ->
                Id + 30;
            true ->
                Id - 20
        end,
    DbWheelPlayerBetRecordList = get_db_wheel_player_bet_record_list_by_id(WheelType, DeleteId),
    lists:foreach(
        fun(DbWheelPlayerBetRecord) ->
            db:delete(DbWheelPlayerBetRecord)
        end,
        DbWheelPlayerBetRecordList
    ).

handle_get_player_list(WheelType) ->
    CacheFun =
        fun() ->
            ServerPlayerList = dict_select_default(?SERVER_PLAYER_LIST, WheelType, []),
            List = lists:foldl(
                fun({_, PlayerIdList}, TmpL) ->
                    lists:foldl(
                        fun(PlayerId, TmpList) ->
                            DbWheelPlayerBetRecordList = get_db_wheel_player_bet_record_list_by_type_and_player(WheelType, PlayerId),
                            {TotalBetNum, TotalWinNum} = lists:foldl(
                                fun(DbWheelPlayerBetRecord, {TmpBetNum, TmpWinNum}) ->
                                    #db_wheel_player_bet_record{
                                        player_id = PlayerId,
                                        award_num = AwardNum,
                                        bet_num = BetNum
                                    } = DbWheelPlayerBetRecord,
                                    AddWinNum =
                                        if
                                            AwardNum > BetNum ->
                                                1;
                                            true ->
                                                0
                                        end,
                                    {TmpBetNum + BetNum, AddWinNum + TmpWinNum}
                                end,
                                {0, 0}, DbWheelPlayerBetRecordList
                            ),
                            [{PlayerId, TotalBetNum, TotalWinNum} | TmpList]
                        end,
                        TmpL, PlayerIdList
                    )
                end,
                [], ServerPlayerList
            ),
            if
                List == [] ->
                    {ok, []};
                true ->
                    [WinFirst | LeftList] =
                        lists:sort(
                            fun({_APlayerId, AValue, AWinNum}, {_BPlayerId, BValue, BWinNum}) ->
                                if
                                    AWinNum > BWinNum ->
                                        true;
                                    AWinNum == BWinNum ->
                                        if
                                            AValue >= BValue ->
                                                true;
                                            true ->
                                                false
                                        end;
                                    true ->
                                        false
                                end
                            end,
                            List
                        ),

                    BetNumSortList =
                        lists:sort(
                            fun({_APlayerId, AValue, AWinNum}, {_BPlayerId, BValue, BWinNum}) ->
                                if
                                    AValue > BValue ->
                                        true;
                                    AValue == BValue ->
                                        if
                                            AWinNum >= BWinNum ->
                                                true;
                                            true ->
                                                false
                                        end;
                                    true ->
                                        false
                                end
                            end,
                            LeftList
                        ),
                    HeadCacheFun =
                        fun(PlayerId) ->
                            WarConditionValueFun =
                                fun() ->
                                    try rpc:call(mod_player:get_game_node(PlayerId), api_player, pack_model_head_figure, [PlayerId])
                                    catch
                                        _:_Reason ->
                                            api_player:pack_model_head_figure(PlayerId, util:to_list(PlayerId), 0, 1, 0, 1, 0)
                                    end
                                end,
                            mod_cache:cache_data({?MODULE, pack_model_head_figure, PlayerId}, WarConditionValueFun, 30 * ?MINUTE_S)
                        end,
                    {_, L} = lists:foldl(
                        fun({PlayerId, Value, WinNum}, {TmpRank, TmpL}) ->
                            {TmpRank + 1, [{TmpRank, HeadCacheFun(PlayerId), Value, WinNum} | TmpL]}
                        end,
                        {1, []}, [WinFirst | BetNumSortList]
                    ),
                    {ok, lists:sublist(lists:reverse(L), 99)}
            end
        end,
    mod_cache:cache_data({?MODULE, handle_get_player_list, WheelType}, CacheFun, 0).

get_chou_shui_value(WheelType) ->
    #t_big_wheel{
        choushui = ChouShuiValue
    } = get_t_big_wheel(WheelType),
    ChouShuiValue.

get_big_xiu_zheng_list(WheelType, PoolValue) ->
    #t_big_wheel{
        xiuzheng_list = XiuZhengList
    } = get_t_big_wheel(WheelType),
    get_big_xiu_zheng_value(XiuZhengList, PoolValue).
get_big_xiu_zheng_value([], _PoolValue) ->
    ?UNDEFINED;
get_big_xiu_zheng_value([[Min, Max, PositiveXiuZheng, NegativeXiuZheng] | XiuZhengList], PoolValue) ->
    if
        (PoolValue >= Min orelse Min == min) andalso (PoolValue =< Max orelse Max == max) ->
            {PositiveXiuZheng, NegativeXiuZheng};
        true ->
            get_big_xiu_zheng_value(XiuZhengList, PoolValue)
    end.

get_weight_list(WheelType, WheelBetList, PoolValue) ->
    WeightList = logic_get_big_wheel_icon_weight_list:assert_get(WheelType),

    {PositiveXiuZheng, NegativeXiuZheng} =
        case get_big_xiu_zheng_list(WheelType, PoolValue) of
            ?UNDEFINED ->
                {10000, 10000};
            Data ->
                Data
        end,

    TotalBetNum = lists:sum([Num || {_BetId, Num} <- WheelBetList]),

    #t_big_wheel{
        baodi_list = [ChouShuiMin, ChouShuiMax]
    } = get_t_big_wheel(WheelType),

    NewWeightList =
        lists:map(
            fun({{ThisResultId, ThisTypeResultId}, ThisWeight}) ->
                BetAwardList = logic_get_big_wheel_bet_list:assert_get({WheelType, ThisTypeResultId}),

                TotalAwardNum = lists:foldl(
                    fun({BetId, Rate}, TmpAwardNum) ->
                        case lists:keyfind(BetId, 1, WheelBetList) of
                            false ->
                                TmpAwardNum;
                            {BetId, PlayerBetNum} ->
                                TmpAwardNum + trunc(PlayerBetNum * Rate / 10000)
                        end
                    end,
                    0, BetAwardList
                ),
                Value = trunc(TotalBetNum * get_chou_shui_value(WheelType) / 10000) - TotalAwardNum,
                Weight1 =
                    if
                        Value > 0 ->
                            trunc(ThisWeight * PositiveXiuZheng / 10000);
                        Value == 0 ->
                            ThisWeight;
                        true ->
                            trunc(ThisWeight * NegativeXiuZheng / 10000)
                    end,
                NewWeight =
                    case (ChouShuiMin =< PoolValue + Value orelse ChouShuiMin == min) andalso (ChouShuiMax >= PoolValue + Value orelse ChouShuiMax == max) of
                        true ->
                            Weight1;
                        false ->
                            0
                    end,
                {{ThisResultId, ThisTypeResultId}, NewWeight}
            end,
            WeightList
        ),
    IsUseWeightList =
        lists:any(
            fun({_Key, Value}) ->
                Value =/= 0
            end,
            NewWeightList
        ),
    if
        IsUseWeightList ->
            NewWeightList;
        true ->
            {_, List} =
                lists:foldl(
                    fun({{ThisResultId, ThisTypeResultId}, ThisWeight}, {TmpResult, TmpResultList}) ->
                        BetAwardList = logic_get_big_wheel_bet_list:assert_get({WheelType, ThisTypeResultId}),

                        TotalAwardNum = lists:foldl(
                            fun({BetId, Rate}, TmpAwardNum) ->
                                case lists:keyfind(BetId, 1, WheelBetList) of
                                    false ->
                                        TmpAwardNum;
                                    {BetId, PlayerBetNum} ->
                                        TmpAwardNum + trunc(PlayerBetNum * Rate / 10000)
                                end
                            end,
                            0, BetAwardList
                        ),
                        Value = trunc(TotalBetNum * get_chou_shui_value(WheelType) / 10000) - TotalAwardNum,
                        if
                            Value > TmpResult ->
                                {Value, [{{ThisResultId, ThisTypeResultId}, ThisWeight}]};
                            Value == TmpResult ->
                                {TmpResult, [{{ThisResultId, ThisTypeResultId}, ThisWeight} | TmpResultList]};
                            true ->
                                {TmpResult, TmpResultList}
                        end
                    end,
                    {0, []}, WeightList
                ),
            List
    end.

%% ---------------------- 进程中操作  dict(不写入数据库，只是内存操作，操作的时候尽量放在事务的后面)------------------------

%% @doc DICT 查询数据
dict_select(DictKey, DictKeyValue) ->
    dict_select_default(DictKey, DictKeyValue, null).
dict_select(Key) ->
    get(Key).
dict_select_default(DictKey, Default) ->
    case dict_select(DictKey) of
        ?UNDEFINED ->
            Default;
        R ->
            R
    end.
dict_select_default(DictKey, DictKeyValue, Default) ->
    dict_select_default({DictKey, DictKeyValue}, Default).

%% @doc DICT 写入数据
dict_write_data(DictKey, DictKeyValue, DictData) ->
    dict_write_data({DictKey, DictKeyValue}, DictData).
dict_write_data(Key, Value) ->
    put(Key, Value).

%% @doc DICT 删除数据
dict_delete(DictKey, DictKeyValue) ->
    dict_delete({DictKey, DictKeyValue}).
dict_delete(Key) ->
    erase(Key).

%% ================================================ 配置表操作 ================================================

%% @doc 获得无尽对决类型表
get_t_big_wheel(WheelType) ->
    t_big_wheel:assert_get({WheelType}).

%% @doc 获得无尽对决表
get_t_big_wheel_icon(WheelType, Id) ->
    t_big_wheel_icon:assert_get({WheelType, Id}).

%% @doc DB 获得玩家无尽对决投注记录
get_db_wheel_player_bet_record(PlayerId, Type, Id) ->
    db:read(#key_wheel_player_bet_record{player_id = PlayerId, type = Type, id = Id}).
get_db_wheel_player_bet_record_init(PlayerId, Type, Id) ->
    case get_db_wheel_player_bet_record(Type, PlayerId, Id) of
        null ->
            #db_wheel_player_bet_record{
                player_id = PlayerId,
                type = Type,
                id = Id,
                time = 0
            };
        Db ->
            Db
    end.

%% @doc DB 获得无尽对决结果记录
get_db_wheel_result_record(Type, Id) ->
    db:read(#key_wheel_result_record{type = Type, id = Id}).
get_db_wheel_result_record_init(Type, Id) ->
    case get_db_wheel_result_record(Type, Id) of
        null ->
            #db_wheel_result_record{
                type = Type,
                id = Id,
                time = 0
            };
        Db ->
            Db
    end.

%% @doc DB 获得无尽对决结果记录
get_db_wheel_result_record_accumulate(Type, UId, RecordType, Id) ->
    db:read(#key_wheel_result_record_accumulate{type = Type, u_id = UId, record_type = RecordType, id = Id}).
get_db_wheel_result_record_accumulate_init(Type, UId, RecordType, Id) ->
    case get_db_wheel_result_record_accumulate(Type, UId, RecordType, Id) of
        null ->
            #db_wheel_result_record_accumulate{
                type = Type,
                u_id = UId,
                record_type = RecordType,
                id = Id
            };
        Db ->
            Db
    end.
get_db_wheel_result_record_accumulate_list(Type, UId, RecordType) ->
    db_index:get_rows(#idx_wheel_result_record_accumulate_1{type = Type, u_id = UId, record_type = RecordType}).

get_db_wheel_pool(Type) ->
    case db:read(#key_wheel_pool{type = Type}) of
        null ->
            #db_wheel_pool{
                type = Type,
                value = 0
            };
        Db ->
            Db
    end.

%% @doc DB 获得玩家投注记录列表 根据类型
%%get_db_wheel_player_bet_record_list_by_type(Type) ->
%%    db_index:get_rows(#idx_wheel_player_bet_record_by_type{type = Type}).
get_db_wheel_player_bet_record_list_by_type_and_player(Type, PlayerId) ->
    db_index:get_rows(#idx_wheel_player_bet_record_by_type_and_player{type = Type, player_id = PlayerId}).

%% @doc DB 获得玩家投注记录列表 根据类型
get_db_wheel_player_bet_record_list_by_id(Type, Id) ->
    db_index:get_rows(#idx_wheel_player_bet_record_by_id{type = Type, id = Id}).

%% @doc DB 获得玩家投注记录列表 根据玩家id
get_db_wheel_player_bet_record_today_list_by_player(WheelType, PlayerId) ->
    db_index:get_rows(#idx_wheel_player_bet_record_today_by_player{type = WheelType, player_id = PlayerId}).

%% @doc DB 获得走势图记录列表 根据类型
get_db_wheel_result_record_list(Type) ->
    db_index:get_rows(#idx_wheel_result_record_by_type{type = Type}).