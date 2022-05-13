%%%%%-------------------------------------------------------------------
%%%%% @author
%%%%% @copyright (C) 2017, THYZ
%%%%% @doc                离线奖励
%%%%% @end
%%%%% Created : 20. 十二月 2017 上午 11:30
%%%%%-------------------------------------------------------------------
-module(mod_offline_award).
%%
%%-include("common.hrl").
%%-include("gen/table_enum.hrl").
%%-include("gen/table_db.hrl").
%%-include("client.hrl").
%%-include("p_message.hrl").
%%-include("player_game_data.hrl").
%%%% API
%%-export([
%%    get_cache_offline_award/0,
%%    get_offline_award/1,        %% 领取离线奖励
%%    deal_offline_award/1        %% 处理离线奖励
%%]).
%%
%%
%%
%%get_cache_offline_award() ->
%%    get(?DICT_OFFLINE_AWARD).
%%
%%%% ----------------------------------
%%%% @doc 	处理离线奖励
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%deal_offline_award(PlayerId) ->
%%    Now = util_time:timestamp(),
%%    LastOfflineTime = mod_player:get_player_data(PlayerId, last_offline_time),
%%    OfflineAward =
%%        if
%%            LastOfflineTime =< 0 ->
%%%%            ?WARNING("last offline time zero"),
%%                ?UNDEFINED;
%%            true ->
%%%%                TotalOfflineTime = 300 * ?MINUTE_S,
%%                TotalOfflineTime = Now - LastOfflineTime,
%%                CalcTotalOfflineTime = min(TotalOfflineTime, 2 * ?DAY_S),
%%                % 10分钟 不算离线
%%                if
%%                    CalcTotalOfflineTime < ?SD_OFFLINE_TIME * ?MINUTE_S ->
%%                        ?UNDEFINED;
%%                    true ->
%%                        Chapter = mod_mission:get_player_zhu_xian_id(PlayerId),
%%%%                        ?DEBUG("Chapter:~p~n", [Chapter]),
%%                        OldLevel = mod_player:get_player_data(PlayerId, level),
%%                        #t_chapter{
%%                            offline_coin = OfflineCoin,
%%                            offline_exp = OfflineExp,
%%                            offline_reward = OfflineAwardId
%%                        } = mod_task:get_t_chapter(Chapter),
%%                        ResourceRate = erlang:trunc(CalcTotalOfflineTime / (?SD_OFFLINE_EXP_CYCLE * ?MINUTE_S)),
%%                        RandomEquipTimes = erlang:trunc(CalcTotalOfflineTime / (?SD_OFFLINE_AWARD_CYCLE * ?MINUTE_S)),
%%                        EquipPropList = mod_award:decode_award_2(OfflineAwardId, RandomEquipTimes),
%%
%%
%%                        PropList = [
%%                            {?PROP_TYPE_RESOURCES, ?RES_COIN, ResourceRate * OfflineCoin},
%%                            {?PROP_TYPE_RESOURCES, ?RES_EXP, ResourceRate * OfflineExp}
%%                        ] ++ EquipPropList,
%%
%%                        MergePropList = mod_prop:merge_prop_list(PropList),
%%                        % 离线奖励缓存起来, 等待客户端领取
%%%%                    put(?DICT_OFFLINE_AWARD, MergePropList),
%%%%                    ?DEBUG("OFFLINE_AWARD:~p~n", [MergePropList]),
%%
%%                        Tran = fun() ->
%%                            {MeltingList, NewAwardList} =
%%                                lists:foldl(
%%                                    fun(Prop, {TmpMeltingList, TmpAwardList}) ->
%%                                        case Prop of
%%%%                                            {?PROP_TYPE_EQUIP, EquipId, Num} ->
%%%%                                                NewTmpMeltingList = [#prop{prop_type = ?PROP_TYPE_EQUIP, prop_id = EquipId, num = Num} | TmpMeltingList],
%%%%                                                {NewTmpMeltingList, TmpAwardList};
%%                                            _ ->
%%                                                {TmpMeltingList, [Prop | TmpAwardList]}
%%                                        end
%%
%%                                    end,
%%                                    {[], []},
%%                                    MergePropList
%%                                ),
%%%%                            {MeltingList, NewAwardList, _} =
%%%%                                lists:foldl(
%%%%                                    fun(Prop, {TmpMeltingList, TmpAwardList, LeftNum}) ->
%%%%                                        case Prop of
%%%%                                            {?PROP_TYPE_EQUIP, EquipId, Num} ->
%%%%                                                RealNum =
%%%%                                                    if Num > LeftNum ->
%%%%                                                        LeftNum;
%%%%                                                        true ->
%%%%                                                            Num
%%%%                                                    end,
%%%%
%%%%                                                NewTmpAwardList =
%%%%                                                    if RealNum > 0 ->
%%%%                                                        [{?PROP_TYPE_EQUIP, EquipId, RealNum} | TmpAwardList];
%%%%                                                        true ->
%%%%                                                            TmpAwardList
%%%%                                                    end,
%%%%                                                MeltingNum = Num - RealNum,
%%%%                                                NewTmpMeltingList =
%%%%                                                    if MeltingNum > 0 ->
%%%%                                                        [#prop{prop_type = ?PROP_TYPE_EQUIP, prop_id = EquipId, num = MeltingNum} | TmpMeltingList];
%%%%                                                        true ->
%%%%                                                            TmpMeltingList
%%%%                                                    end,
%%%%                                                NewLeftNum = LeftNum - RealNum,
%%%%                                                {NewTmpMeltingList, NewTmpAwardList, NewLeftNum};
%%%%                                            _ ->
%%%%                                                {TmpMeltingList, [Prop | TmpAwardList], LeftNum}
%%%%                                        end
%%%%
%%%%                                    end,
%%%%                                    {[], [], mod_prop:get_empty_equip_grid_num(PlayerId)},
%%%%                                    MergePropList
%%%%                                ),
%%                            mod_award:give(PlayerId, NewAwardList, ?LOG_TYPE_OFFLINE_AWARD),
%%%%                            MeltingAwardList =
%%%%                                if MeltingList =/= [] ->
%%                                    %% 装不下的装备进行熔炼
%%%%                                    ?DEBUG("离线奖励熔炼:~p", [MeltingList]),
%%%%                                    mod_equip:melting(PlayerId, MeltingList, false);
%%%%                                    true ->
%%%%                                        [],
%%%%                                end,
%%%%                            ?DEBUG("MeltingAwardList:~p~n", [mod_prop:merge_prop_list(MeltingAwardList)]),
%%%%                            [{E#prop.prop_type, E#prop.prop_id, E#prop.num} || E <- MeltingList] ++ NewAwardList ++ MeltingAwardList
%%                            NewAwardList
%%%%                            ++ MeltingAwardList
%%                               end,
%%                        RealAwardList = db:do(Tran),
%%                        NewLevel = mod_player:get_player_data(PlayerId, level),
%%
%%%%                        ?DEBUG("RealAwardList:~p~n", [mod_prop:merge_prop_list(RealAwardList)]),
%%                        #offlineaward{
%%                            offline_time = TotalOfflineTime,
%%                            award_list = api_prop:pack_prop_list(mod_prop:merge_prop_list(RealAwardList)),
%%%%                        melting_list = api_prop:pack_prop_list(MeltingList),
%%                            old_level = OldLevel,
%%                            new_level = NewLevel
%%                        }
%%%%                    api_player:notice_offline_award(PlayerId, TotalOfflineTime, mod_prop:merge_prop_list(PropList))
%%                end
%%        end,
%%    put(?DICT_OFFLINE_AWARD, OfflineAward).
%%
%%%% ----------------------------------
%%%% @doc 	领取离线奖励
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_offline_award(_PlayerId) ->
%%    noop.
%%%%    AwardList = erase(?DICT_OFFLINE_AWARD),
%%%%    OfflineTime = mod_player:get_player_data(PlayerId, last_offline_time),
%%%%
%%%%    case is_list(AwardList) of
%%%%        true ->
%%%%            ?DEBUG("领取离线奖励"),
%%%%            LastAwardOfflineTime = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_LAST_OFFLINE_AWARD_TIME),
%%%%            ?ASSERT(LastAwardOfflineTime =/= OfflineTime, {get_offline_award_time_error, OfflineTime}),
%%%%            Tran = fun() ->
%%%%
%%%%%%                MaxGridNum = mod_prop:get_max_grid_num(PlayerId, ?PROP_TYPE_EQUIP),
%%%%
%%%%                {MeltingList, NewAwardList, _} =
%%%%                    lists:foldl(
%%%%                        fun(Prop, {TmpMeltingList, TmpAwardList, LeftNum}) ->
%%%%                            case Prop of
%%%%                                {?PROP_TYPE_EQUIP, EquipId, Num} ->
%%%%                                    RealNum =
%%%%                                        if Num > LeftNum ->
%%%%                                            LeftNum;
%%%%                                            true ->
%%%%                                                Num
%%%%                                        end,
%%%%
%%%%                                    NewTmpAwardList =
%%%%                                        if RealNum > 0 ->
%%%%                                            [{?PROP_TYPE_EQUIP, EquipId, RealNum} | TmpAwardList];
%%%%                                            true ->
%%%%                                                TmpAwardList
%%%%                                        end,
%%%%                                    MeltingNum = Num - RealNum,
%%%%                                    NewTmpMeltingList =
%%%%                                        if MeltingNum > 0 ->
%%%%                                            [#prop{prop_type = ?PROP_TYPE_EQUIP, prop_id = EquipId, num = MeltingNum} | TmpMeltingList];
%%%%                                            true ->
%%%%                                                TmpMeltingList
%%%%                                        end,
%%%%                                    NewLeftNum = LeftNum - RealNum,
%%%%                                    {NewTmpMeltingList, NewTmpAwardList, NewLeftNum};
%%%%                                _ ->
%%%%                                    {TmpMeltingList, [Prop | TmpAwardList], LeftNum}
%%%%                            end
%%%%
%%%%                        end,
%%%%                        {[], [], mod_prop:get_empty_equip_grid_num(PlayerId)},
%%%%                        AwardList
%%%%                    ),
%%%%%%                ?DEBUG("AwardList:~p", [AwardList]),
%%%%%%                ?DEBUG("NewAwardList:~p", [NewAwardList]),
%%%%%%                ?DEBUG("info:~p", [{mod_prop:get_empty_equip_grid_num(PlayerId)}]),
%%%%%%                ?DEBUG("离线奖励熔炼:~p", [MeltingList]),
%%%%                mod_award:give(PlayerId, NewAwardList, ?LOG_TYPE_OFFLINE_AWARD),
%%%%                if MeltingList =/= [] ->
%%%%                    %% 装不下的装备进行熔炼
%%%%                    ?DEBUG("离线奖励熔炼:~p", [MeltingList]),
%%%%                    mod_equip:melting(PlayerId, MeltingList, false);
%%%%                    true ->
%%%%                        noop
%%%%                end,
%%%%
%%%%                mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_LAST_OFFLINE_AWARD_TIME, OfflineTime)
%%%%                   end,
%%%%            db:do(Tran);
%%%%        _ ->
%%%%            noop
%%%%    end.
