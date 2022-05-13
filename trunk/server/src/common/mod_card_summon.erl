%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         图鉴召唤
%%% @end
%%% Created : 07. 五月 2021 下午 05:53:15
%%%-------------------------------------------------------------------
-module(mod_card_summon).
-author("yizhao.wang").

-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("error.hrl").
-include("client.hrl").

%% API
-export([
    do_summon/2
]).

-define(SUMMON_ONCE, 1).          %% 单抽
-define(SUMMON_TENTIMES, 2).      %% 十连抽

%% @doc 召唤
do_summon(PlayerId, Type) ->
    ?ASSERT(lists:member(Type, [1, 2]), ?ERROR_NOT_AUTHORITY),
    Rec = db_get(PlayerId),
    #db_player_card_summon{
        once_cnt = OriCnt1,
        ten_times_cnt = OriCnt2
    } = Rec,
    {NewCnt1, NewCnt2, AwardList, Cost} =
        case Type of
            ?SUMMON_ONCE ->
                FreeNum = mod_times:get_left_times(PlayerId, ?TIMES_CARD_SUMMON_TIMES),
                _Cost =
                    case FreeNum > 0 of
                        true ->
                            [];
                        false ->
                            mod_prop:assert_prop_num(PlayerId, ?SD_CARD_SUMMON_ONCE_COST_LIST),
                            ?SD_CARD_SUMMON_ONCE_COST_LIST
                    end,
                {Cnt, _AwardList} = adjust_foldl(fun do_summon_once/3, {OriCnt1, []}, [1], ?SD_CARD_SUMMON_ONCE_LIST),
                {Cnt, OriCnt2, _AwardList, _Cost};
            ?SUMMON_TENTIMES ->
                mod_prop:assert_prop_num(PlayerId, ?SD_CARD_SUMMON_TENTIMES_COST_LIST),
                {Cnt, _AwardList} = adjust_foldl(fun do_summon_once/3, {OriCnt2, []}, lists:seq(1, 10), ?SD_CARD_SUMMON_TENTIMES_LIST),
                {OriCnt1, Cnt, _AwardList, ?SD_CARD_SUMMON_TENTIMES_COST_LIST}
        end,
    Tran =
        fun() ->
            db:write(Rec#db_player_card_summon{player_id = PlayerId, once_cnt = NewCnt1, ten_times_cnt = NewCnt2}),
            if
                Cost =:= [] ->
                    mod_times:use_times(PlayerId, ?TIMES_CARD_SUMMON_TIMES);
                true ->
                    mod_prop:decrease_player_prop(PlayerId, Cost, ?LOG_TYPE_CARD_SUMMON_AWARD)
            end,
            mod_award:give(PlayerId, AwardList, ?LOG_TYPE_CARD_SUMMON_AWARD)
        end,
    db:do(Tran),
    {ok, AwardList}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
db_get(PlayerId) ->
    case db:read(#key_player_card_summon{player_id = PlayerId}) of
        Rec when is_record(Rec, db_player_card_summon) ->
            Rec;
        _ ->
            [_, _, MinCnt1, MaxCnt1] = ?SD_CARD_SUMMON_ONCE_LIST,
            [_, _, MinCnt2, MaxCnt2] = ?SD_CARD_SUMMON_TENTIMES_LIST,
            #db_player_card_summon{
                player_id = PlayerId,
                once_cnt = rand:uniform(MaxCnt1 - MaxCnt1 + 1) + MinCnt1 - 1,
                ten_times_cnt = rand:uniform(MaxCnt2 - MaxCnt2 + 1) + MinCnt2 - 1
            }
    end.

do_summon_once(_Times, {OriCnt, Acc}, [LowId, HighId, CntMin, CntMax]) ->
    {CardWeightList, NewCnt} =
        case OriCnt - 1 of
            N when N =< 0 ->
                %% 抽高级卡
                {logic_get_card_summon_list_by_type:assert_get(HighId), rand:uniform(CntMax - CntMin + 1) + CntMin - 1};
            N ->
                %% 抽低级卡
                {logic_get_card_summon_list_by_type:assert_get(LowId), N}
        end,
    AwardList = util_random:get_probability_item(CardWeightList),  %% 按权重随机奖励
    {NewCnt, AwardList ++ Acc}.

adjust_foldl(F, Accu, [Hd | Tail], Params) ->
    NewAccu = F(Hd, Accu, Params),
    adjust_foldl(F, NewAccu, Tail, Params);
adjust_foldl(F, Accu, [], _Params) when is_function(F, 3) -> Accu.
