%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 11月 2021 下午 12:19:40
%%%-------------------------------------------------------------------
-module(api_wheel).
-author("Administrator").

-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    join_wheel/2,
    bet/2,
    get_bet_record/2,
    get_player_list/2,
    get_record/2,
    exit_wheel/2,
    use_last_bet/2,

    notice_bet/6,
    notice_balance/6
]).

%% @doc 加入无尽对决
join_wheel(
    #m_wheel_join_wheel_tos{type = Type},
    State = #conn{player_id = PlayerId}
) ->
    {Result, BetList, TimeMs, LeftRankInfo, RightRankInfo, MyBetList, DbWheelResultRecordList} =
        case catch mod_wheel:join_wheel(PlayerId, Type) of
            {ok, BetList1, TimeMs1, LeftRankInfo1, RightRankInfo1, MyBetList1, DbWheelResultRecordList1} ->
                put(wheel_type, Type),
                {?P_SUCCESS, BetList1, TimeMs1, LeftRankInfo1, RightRankInfo1, MyBetList1, DbWheelResultRecordList1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), [], 0, [], [], []}
        end,
    Out = proto:encode(#m_wheel_join_wheel_toc{
        result = Result,
        type = Type,
        bet_list = pack_pb_wheel_common_list(BetList),
        time_ms = TimeMs * ?SECOND_MS,
        left_rank_info = pack_pb_wheel_rank_list(LeftRankInfo),
        right_rank_info = pack_pb_wheel_rank_list(RightRankInfo),
        my_bet_list = pack_pb_wheel_common_list(MyBetList),
        record_list = pack_pb_wheel_common_list(DbWheelResultRecordList)
    }),
    mod_socket:send(Out),
    State.

%% @doc 投注
bet(
    #m_wheel_bet_tos{bet_id = BetId, num = Num},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_wheel:bet(PlayerId, BetId, Num)),
    Out = proto:encode(#m_wheel_bet_toc{
        result = Result,
        bet_id = BetId,
        num = Num
    }),
    mod_socket:send(Out),
    State.
%% @doc 通知有人投注
notice_bet([], _BetPlayerId, _BetId, _Num, _TotalNum, _PlayerBetLists) ->
    noop;
notice_bet([PlayerId | PlayerIdList], BetPlayerId, BetId, Num, TotalNum, PlayerBetLists) ->
    PlayerTotalNum =
        case lists:keyfind(PlayerId, 1, PlayerBetLists) of
            false ->
                0;
            {PlayerId, BetIdList} ->
                case lists:keyfind(BetId, 1, BetIdList) of
                    false ->
                        0;
                    {BetId, Value} ->
                        Value
                end
        end,
    Out = proto:encode(#m_wheel_notice_bet_toc{
        player_id = BetPlayerId,
        bet_id = BetId,
        num = Num,
        total_num = TotalNum,
        my_total_num = PlayerTotalNum
    }),
    mod_socket:send(PlayerId, Out),
    notice_bet(PlayerIdList, BetPlayerId, BetId, Num, TotalNum, PlayerBetLists).

%% @doc 获得走势图记录
get_record(
    #m_wheel_get_record_tos{type = RecordType},
    State = #conn{player_id = _PlayerId}
) ->
    RecordList =
        case catch mod_wheel:get_record(RecordType) of
            {ok, RecordList1} ->
                RecordList1;
            {'EXIT', _ERROR} ->
                []
        end,
    Out = proto:encode(#m_wheel_get_record_toc{
        type = RecordType,
        record_list = pack_pb_wheel_record_list(RecordList)
    }),
    mod_socket:send(Out),
    State.

%% @doc 获得玩家投注记录
get_bet_record(
    #m_wheel_get_bet_record_tos{},
    State = #conn{player_id = PlayerId}
) ->
    RecordList =
        case catch mod_wheel:get_bet_record(PlayerId) of
            {ok, RecordList1} ->
                RecordList1;
            {'EXIT', _ERROR} ->
                []
        end,
    Out = proto:encode(#m_wheel_get_bet_record_toc{
        record_list = pack_pb_player_bet_record_today_list(RecordList)
    }),
    mod_socket:send(Out),
    State.

%% @doc 获得玩家列表
get_player_list(
    #m_wheel_get_player_list_tos{},
    State = #conn{player_id = _PlayerId}
) ->
    PlayerList =
        case catch mod_wheel:get_player_list() of
            {ok, PlayerList1} ->
                PlayerList1;
            {'EXIT', _ERROR} ->
                []
        end,
    Out = proto:encode(#m_wheel_get_player_list_toc{
        player_list = pack_pb_wheel_player_rank_info_list(PlayerList)
    }),
    mod_socket:send(Out),
    State.

%% @doc 退出房间列表
exit_wheel(
    #m_wheel_exit_wheel_tos{},
    State = #conn{player_id = PlayerId}
) ->
    catch mod_wheel:exit_wheel(PlayerId),
    State.

%% @doc 延续上把
use_last_bet(
    #m_wheel_use_last_bet_tos{},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_wheel:use_last_bet(PlayerId)),
    Out = proto:encode(#m_wheel_use_last_bet_toc{
        result = Result
    }),
    mod_socket:send(Out),
    State.

%% @doc 通知结算
notice_balance(PlayerId, Type, AwardList, TimeMs, LeftRankInfo, RightRankInfo) ->
    Out = proto:encode(#m_wheel_balance_toc{
        type = Type,
        award_list = [pack_pb_wheel_common(PropId, PropNum) || {PropId, PropNum} <- AwardList],
        time_ms = TimeMs,
        left_rank_info = pack_pb_wheel_rank_list(LeftRankInfo),
        right_rank_info = pack_pb_wheel_rank_list(RightRankInfo)
    }),
    mod_socket:send(PlayerId, Out).

%% ================================================ 结构化操作 ================================================

pack_pb_wheel_common_list(List) ->
    [pack_pb_wheel_common(Key, Value) || {Key, Value} <- List].
pack_pb_wheel_record_list(List) ->
    [
        #wheelrecord{
            u_id = Time,
            result_id = ResultId,
            wheel_id_record_list = [#'wheelrecord.wheelidrecord'{id = Id, value = Value} || {Id, Value} <- List1]
        } || {{Time, ResultId}, List1} <- List
    ].

pack_pb_wheel_common(Id, Value) ->
    #wheelcommon{
        id = Id,
        value = Value
    }.

pack_pb_wheel_rank_list(List) ->
%%    ?DEBUG("List : ~p", [List]),
    [pack_pb_wheel_rank(Rank, ModelHeadFigure) || {Rank, ModelHeadFigure} <- List].
pack_pb_wheel_rank(Rank, ModelHeadFigure) ->
    #wheelrankinfo{
        rank = Rank,
        model_head_figure = ModelHeadFigure
    }.

pack_pb_player_bet_record_today_list(List) ->
    [pack_pb_player_bet_record_today(DbWheelPlayerBetRecordToday) || DbWheelPlayerBetRecordToday <- List].
pack_pb_player_bet_record_today(DbWheelPlayerBetRecord) ->
    #db_wheel_player_bet_record_today{
        time = Time,
        type = Type,
        bet_num = BetNum,
        award_num = AwardNum
    } = DbWheelPlayerBetRecord,
    #wheelplayerbetrecord{
        time = Time,
        type = Type,
        bet_num = BetNum,
        award_num = AwardNum
    }.

pack_pb_wheel_player_rank_info_list(List) ->
    [pack_pb_wheel_player_rank_info(Rank, ModelHeadFigure, Value, WinNum) || {Rank, ModelHeadFigure, Value, WinNum} <- List].
pack_pb_wheel_player_rank_info(Rank, ModelHeadFigure, Value, WinNum) ->
    #wheelplayerrankinfo{
        rank = Rank,
        model_head_figure = ModelHeadFigure,
        num = Value,
        win_num = WinNum
    }.
