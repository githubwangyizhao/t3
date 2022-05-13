%%%%%-------------------------------------------------------------------
%%%%% @author Administrator
%%%%% @copyright (C) 2021, <COMPANY>
%%%%% @doc
%%%%%
%%%%% @end
%%%%% Created : 17. 7月 2021 下午 12:25:54
%%%%%-------------------------------------------------------------------
-module(server_fight_adjust).
%%-author("Administrator").
%%
%%-include("gen/db.hrl").
%%-include("gen/table_enum.hrl").
%%-include("gen/table_db.hrl").
%%-include("common.hrl").
%%-include("scene.hrl").
%%-include("fight.hrl").
%%
%%%% API
%%-export([
%%    add_cost/2,
%%    handle_add_cost/2,
%%
%%    add_award/1,
%%    add_award/2,
%%    add_award/3,
%%    handle_add_award/2,
%%
%%    get_xiu_zheng_id/2,
%%
%%    cost_player_adjust_times/4,
%%
%%%%    get_player_fight_adjust/3,
%%
%%    get_db_server_player_fight_adjust_or_init/2,
%%    get_server_adjust_pool_value/1
%%]).
%%
%%add_cost(PropId, Num) when (PropId == ?ITEM_RMB orelse PropId == ?ITEM_GOLD) andalso Num > 0 ->
%%    IsHookScene = get(?DICT_IS_HOOK_SCENE),
%%    MissionType = get(?DICT_MISSION_TYPE),
%%    case (IsHookScene orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT) of
%%        true ->
%%            server_fight_adjust_srv:cast({add_cost, PropId, Num});
%%        false ->
%%            noop
%%    end;
%%add_cost(_PropId, _Num) ->
%%    noop.
%%
%%handle_add_cost(PropId, Num) ->
%%    DbServerFightAdjust = get_db_server_fight_adjust_or_init(PropId),
%%    #db_server_fight_adjust{
%%        pool_value = PoolValue,
%%        cost = Cost
%%    } = DbServerFightAdjust,
%%    Tran =
%%        fun() ->
%%            db:write(DbServerFightAdjust#db_server_fight_adjust{pool_value = PoolValue + trunc(Num * ?SD_COIN_XIUZHENG_RATE / 10000), cost = Cost + Num})
%%        end,
%%    db:do(Tran),
%%    ok.
%%
%%add_award([PropId, Num]) -> add_award(PropId, Num, true).
%%add_award(PropId, Num) -> add_award(PropId, Num, true).
%%add_award(PropId, Num, IsCheck) when (PropId == ?ITEM_RMB orelse PropId == ?ITEM_GOLD) andalso Num > 0 ->
%%    IsHookScene = get(?DICT_IS_HOOK_SCENE),
%%    MissionType = get(?DICT_MISSION_TYPE),
%%    case (not IsCheck
%%        orelse IsHookScene
%%        orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION
%%        orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT)
%%    of
%%        true ->
%%            server_fight_adjust_srv:cast({add_award, PropId, Num});
%%        false ->
%%            noop
%%    end;
%%add_award(_PropId, _Num, _IsCheck) ->
%%    noop.
%%
%%handle_add_award(PropId, Num) ->
%%    DbServerFightAdjust = get_db_server_fight_adjust_or_init(PropId),
%%    #db_server_fight_adjust{
%%        pool_value = PoolValue,
%%        award = Award
%%    } = DbServerFightAdjust,
%%    Tran =
%%        fun() ->
%%            db:write(DbServerFightAdjust#db_server_fight_adjust{pool_value = PoolValue - Num, award = Award + Num})
%%        end,
%%    db:do(Tran),
%%    ok.
%%
%%get_xiu_zheng_id(PlayerId, PropId) ->
%%    DbServerPlayerFightAdjust = get_db_server_player_fight_adjust_or_init(PlayerId, PropId),
%%    #db_server_player_fight_adjust{
%%        id = Id
%%    } = DbServerPlayerFightAdjust,
%%    ?IF(Id == 0, 1, Id).        %% todo
%%
%%cost_player_adjust_times(PlayerId, PropId, Cost, Now) ->
%%    DbServerPlayerFightAdjust = get_db_server_player_fight_adjust_or_init(PlayerId, PropId),
%%    #db_server_player_fight_adjust{
%%        times = Times,
%%        bottom_times = BottomUseTimes,
%%        bottom_times_time = LastBottomUseTime
%%    } = DbServerPlayerFightAdjust,
%%    NewTimes = Times - Cost,
%%    NewDbServerPlayerFightAdjust =
%%        if
%%            NewTimes =< 0 ->
%%                LeftPropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
%%                {BackNeedTimes, BackTimes, BackPer} =
%%                    case PropId of
%%                        ?ITEM_GOLD ->
%%                            {?SD_COIN_BACK_NEED_TIMES, ?SD_COIN_BACK_TIMES, ?SD_COIN_BACK_PER};
%%                        ?ITEM_RMB ->
%%                            {?SD_DIAMOND_BACK_NEED_TIMES, ?SD_DIAMOND_BACK_TIMES, ?SD_DIAMOND_BACK_PER}
%%                    end,
%%                IsUseBottom =
%%                    if
%%                        LeftPropNum < Cost * BackNeedTimes ->
%%                            NewBottomUseTimes = ?IF(util_time:is_today(LastBottomUseTime, Now), BottomUseTimes, 0),
%%                            if
%%                                NewBottomUseTimes =< BackTimes ->
%%                                    true;
%%                                true ->
%%                                    util_random:p(BackPer)
%%                            end;
%%                        true ->
%%                            false
%%                    end,
%%                if
%%                    IsUseBottom ->
%%                        [Min, Max, NewXiuZhengId] =
%%                            case PropId of
%%                                ?ITEM_GOLD ->
%%                                    case get(?DICT_SCENE_FIGHT_TYPE) of
%%                                        ?FIGHT_TYPE_ODDS ->
%%                                            ?SD_COIN_BACK_LIST;
%%                                        ?FIGHT_TYPE_HP ->
%%                                            ?SD_DIAMOND_BACK_LIST
%%                                    end;
%%                                ?ITEM_RMB ->
%%                                    case get(?DICT_SCENE_FIGHT_TYPE) of
%%                                        ?FIGHT_TYPE_ODDS ->
%%                                            ?SD_HP_MODE_COIN_BACK_LIST;
%%                                        ?FIGHT_TYPE_HP ->
%%                                            ?SD_HP_MODE_DIAMOND_BACK_LIST
%%                                    end
%%                            end,
%%                        NewTimes2 = util_random:random_number(Min, Max),
%%                        DbServerPlayerFightAdjust#db_server_player_fight_adjust{times = (NewTimes2 - 1) * Times, id = NewXiuZhengId, bottom_times = BottomUseTimes + 1, bottom_times_time = Now};
%%                    true ->
%%                        PoolValue = get_server_adjust_pool_value(PropId),
%%                        {XiuZhengList, XiuZhengCountList} =
%%                            case PropId of
%%                                ?ITEM_GOLD ->
%%                                    {?SD_COIN_XIUZHENG_LIST, ?SD_COIN_XIUZHENG_COUNT_LIST};
%%                                ?ITEM_RMB ->
%%                                    {?SD_DIAMOND_XIUZHENG_LIST, ?SD_DIAMOND_XIUZHENG_COUNT_LIST}
%%                            end,
%%                        XiuZhengId =
%%                            case get_element_from_range_list(PoolValue, XiuZhengList) of
%%                                ?UNDEFINED ->
%%                                    if
%%                                        PoolValue >= 0 ->
%%                                            2;
%%                                        true ->
%%                                            3
%%                                    end;
%%                                [_, _, ValueList] ->
%%                                    util_random:get_list_random_member(ValueList)
%%                            end,
%%                        [XiuZhengId, TimesMin, TimesMax] = util_list:key_find(XiuZhengId, 1, XiuZhengCountList),
%%                        NewTimes2 = util_random:random_number(TimesMin, TimesMax),
%%                        DbServerPlayerFightAdjust#db_server_player_fight_adjust{
%%                            id = XiuZhengId,
%%                            times = (NewTimes2 - 1) * Cost
%%                        }
%%                end;
%%            true ->
%%                DbServerPlayerFightAdjust#db_server_player_fight_adjust{times = NewTimes}
%%        end,
%%    Tran =
%%        fun() ->
%%            db:write(NewDbServerPlayerFightAdjust),
%%            api_player:notice_player_xiu_zhen_value(PlayerId, [])
%%        end,
%%    db:do(Tran),
%%    NewDbServerPlayerFightAdjust#db_server_player_fight_adjust.id.
%%
%%%%get_player_fight_adjust(PlayerId, MonsterId, PropId) ->
%%%%    DbServerPlayerFightAdjust = get_db_server_player_fight_adjust_or_init(PlayerId, PropId),
%%%%    #db_server_player_fight_adjust{
%%%%        id = Id
%%%%    } = DbServerPlayerFightAdjust,
%%%%    #t_monster{
%%%%        xiuzheng_list = XiuzhenList
%%%%    } = mod_scene_monster_manager:get_t_monster(MonsterId),
%%%%    [Id, Rate, _CostPool, _CostRate] = util_list:key_find(Id, 1, XiuzhenList),
%%%%    Rate.
%%
%%%% ================================================ 数据操作 ================================================
%%
%%%% @doc DB 获得服务器修正值
%%get_db_server_fight_adjust(PropId) ->
%%    db:read(#key_server_fight_adjust{prop_id = PropId}).
%%get_db_server_fight_adjust_or_init(PropId) ->
%%    case get_db_server_fight_adjust(PropId) of
%%        null ->
%%            #db_server_fight_adjust{
%%                prop_id = PropId
%%            };
%%        DbServerFightAdjust ->
%%            DbServerFightAdjust
%%    end.
%%get_server_adjust_pool_value(PropId) ->
%%    #db_server_fight_adjust{
%%        pool_value = PoolValue
%%    } = get_db_server_fight_adjust_or_init(PropId),
%%    PoolValue.
%%
%%%% @doc DB 获得服务器玩家修正
%%get_db_server_player_fight_adjust(PlayerId, PropId) ->
%%    db:read(#key_server_player_fight_adjust{player_id = PlayerId, prop_id = PropId}).
%%get_db_server_player_fight_adjust_or_init(PlayerId, PropId) ->
%%    case get_db_server_player_fight_adjust(PlayerId, PropId) of
%%        null ->
%%            #db_server_player_fight_adjust{
%%                player_id = PlayerId,
%%                prop_id = PropId
%%            };
%%        R ->
%%            R
%%    end.
%%%%get_db_server_player_fight_adjust_or_init(PlayerId, PropId) ->
%%%%    DbServerPlayerFightAdjust =
%%%%        case get_db_server_player_fight_adjust(PlayerId, PropId) of
%%%%            null ->
%%%%                #db_server_player_fight_adjust{
%%%%                    player_id = PlayerId,
%%%%                    prop_id = PropId
%%%%                };
%%%%            R ->
%%%%                R
%%%%        end,
%%%%    #db_server_player_fight_adjust{
%%%%        times = Times
%%%%    } = DbServerPlayerFightAdjust,
%%%%    if
%%%%        Times =< 0 ->
%%%%            PoolValue = get_server_adjust_pool_value(PropId),
%%%%            {XiuZhengList, XiuZhengCountList} =
%%%%                case PropId of
%%%%                    ?ITEM_GOLD ->
%%%%                        {?SD_COIN_XIUZHENG_LIST, ?SD_COIN_XIUZHENG_COUNT_LIST};
%%%%                    ?ITEM_RMB ->
%%%%                        {?SD_DIAMOND_XIUZHENG_LIST, ?SD_DIAMOND_XIUZHENG_COUNT_LIST}
%%%%                end,
%%%%            XiuZhengId =
%%%%                case get_element_from_range_list(PoolValue, XiuZhengList) of
%%%%                    ?UNDEFINED ->
%%%%                        if
%%%%                            PoolValue >= 0 ->
%%%%                                2;
%%%%                            true ->
%%%%                                3
%%%%                        end;
%%%%                    [_, _, ValueList] ->
%%%%                        util_random:get_list_random_member(ValueList)
%%%%                end,
%%%%            [XiuZhengId, TimesMin, TimesMax] = util_list:key_find(XiuZhengId, 1, XiuZhengCountList),
%%%%            NewTimes = util_random:random_number([TimesMin, TimesMax]),
%%%%            NewDbPlayerFightAdjust =
%%%%                DbServerPlayerFightAdjust#db_server_player_fight_adjust{
%%%%                    id = XiuZhengId,
%%%%                    times = NewTimes
%%%%                },
%%%%            Tran =
%%%%                fun() ->
%%%%                    db:write(NewDbPlayerFightAdjust)
%%%%                end,
%%%%            db:do(Tran),
%%%%            NewDbPlayerFightAdjust;
%%%%        true ->
%%%%            DbServerPlayerFightAdjust
%%%%    end.
%%
%%get_element_from_range_list(_I, []) ->
%%    undefined;
%%get_element_from_range_list(I, [Element | RangList]) ->
%%    [Min, Max | _] = Element,
%%    if I >= Min andalso I =< Max ->
%%        Element;
%%        true ->
%%            get_element_from_range_list(I, RangList)
%%    end.