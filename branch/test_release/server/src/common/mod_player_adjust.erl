%%%%%-------------------------------------------------------------------
%%%%% @author Administrator
%%%%% @copyright (C) 2021, <COMPANY>
%%%%% @doc
%%%%%         玩家个人修正
%%%%% @end
%%%%% Created : 17. 六月 2021 下午 05:05:20
%%%%%-------------------------------------------------------------------
-module(mod_player_adjust).
%%-author("Administrator").
%%
%%-include("player_game_data.hrl").
%%-include("gen/table_enum.hrl").
%%-include("gen/table_db.hrl").
%%-include("gen/db.hrl").
%%-include("common.hrl").
%%%%-include("gen/table_db.hrl").
%%
%%%% API
%%-export([
%%    change_adjust_value/5,              %% 改变玩家修正
%%    get_adjust_value/5                  %% 获得玩家修正
%%]).
%%
%%-export([
%%    get_player_fight_adjust/3,
%%    get_novice_player_adjust/3
%%]).
%%
%%-export([
%%    get_id/2
%%]).
%%
%%-export([
%%    get_is_newbee_adjust/1,
%%    is_can_add_adjust_value/1
%%]).
%%
%%-export([change_player_fight_adjust/5]).
%%
%%-export([get_db_player_fight_adjust_or_init/2]).
%%
%%%%get_pool_value(PlayerId, PropId, PoolType) ->
%%%%    mod_player_game_data:get_int_data(PlayerId, get_player_game_data_id(PropId, PoolType)).
%%%%add_pool_value(PlayerId, PropId, PoolType, AddValue) ->
%%%%    PlayerDataId = get_player_game_data_id(PropId, PoolType),
%%%%    Value = mod_player_game_data:get_int_data(PlayerId, PlayerDataId),
%%%%    add_pool_value(PlayerId, PropId, PoolType, AddValue, Value, PlayerDataId).
%%%%add_pool_value(PlayerId, PropId, PoolType, AddValue, Value, PlayerDataId) ->
%%%%    mod_player_game_data:set_int_data(PlayerId, PlayerDataId, AddValue + Value).
%%%%
%%%%get_player_game_data_id(PropId, PoolType) ->
%%%%    case {PropId, PoolType} of
%%%%        {?ITEM_GOLD, 1} ->
%%%%            ?PLAYER_GAME_DATA_GOLD_ADJUST_POOL_1;
%%%%        {?ITEM_GOLD, 2} ->
%%%%            ?PLAYER_GAME_DATA_GOLD_ADJUST_POOL_2;
%%%%        {?ITEM_RMB, 1} ->
%%%%            ?PLAYER_GAME_DATA_RMB_ADJUST_POOL_1;
%%%%        {?ITEM_RMB, 2} ->
%%%%            ?PLAYER_GAME_DATA_RMB_ADJUST_POOL_2
%%%%    end.
%%
%%get_adjust_value(PlayerId, _SceneId, MonsterId, PropId, ServerAdjust) ->
%%    case get_is_newbee_adjust(PlayerId) of
%%        true ->
%%            get_novice_player_adjust(PlayerId, MonsterId, PropId);
%%        false ->
%%            get_player_fight_adjust(PlayerId, MonsterId, PropId) * ServerAdjust / 10000
%%    end.
%%
%%change_adjust_value(PlayerId, SceneId, PropId, MonsterId, Cost) ->
%%%%    SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
%%    case is_can_add_adjust_value(SceneId) of
%%        true ->
%%            case get_is_newbee_adjust(PlayerId) of
%%                true ->
%%                    %% 改变新手玩家adjust
%%                    change_novice_player_adjust_value(PlayerId, PropId, MonsterId, Cost);
%%                false ->
%%                    %% 改变个人玩家adjust
%%                    charge_player_fight_adjust(PlayerId, PropId, MonsterId, Cost)
%%                %% 改变服务器adjust
%%%%                    server_adjust:add_server_adjust_cost(Cost)
%%            end;
%%        false ->
%%            noop
%%    end.
%%
%%%% ----------------------------------
%%%% @doc 获得是否使用新手修正
%%%% ----------------------------------
%%get_is_newbee_adjust(PlayerId) ->
%%    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST),
%%    ?TRAN_INT_2_BOOL(Value).
%%
%%%% @doc 是否可以增加adjust
%%is_can_add_adjust_value(SceneId) ->
%%    mod_scene:is_world_scene(SceneId).
%%
%%%% @doc 改变玩家个人adjust
%%charge_player_fight_adjust(PlayerId, PropId, MonsterId, Cost) ->
%%    ?ASSERT(lists:member(PropId, [?ITEM_GOLD, ?ITEM_RMB])),
%%    DbPlayerFightAdjust = get_db_player_fight_adjust_or_init(PlayerId, PropId),
%%    #db_player_fight_adjust{
%%        fight_type = FightType,
%%        pool_times = PoolTimes,
%%%%        cost_rate = CostRate,
%%%%        cost_pool = CostPool,
%%        pool_1 = Pool1,
%%        pool_2 = Pool2,
%%        bottom_times = BottomUseTimes,
%%        bottom_times_time = LastBottomUseTime,
%%        is_bottom = IsBottom,
%%        id = Id
%%    } = DbPlayerFightAdjust,
%%    #t_monster{
%%        xiuzheng_list = XiuzhenList
%%    } = mod_scene_monster_manager:get_t_monster(MonsterId),
%%    [Id, _Rate, CostPool, CostRate] = util_list:key_find(Id, 1, XiuzhenList),
%%    NewBottomUseTimes = ?IF(util_time:is_today(LastBottomUseTime), BottomUseTimes, 0),
%%    %% 是否可以使用触底反弹
%%    IsCanUseBottom =
%%        case IsBottom of
%%            ?FALSE ->
%%                NewBottomUseTimes < ?IF(PropId =:= ?ITEM_GOLD, ?SD_COIN_PERSONAL_BACK_TIMES, ?SD_DIAMOND_PERSONAL_BACK_TIMES);
%%            ?TRUE ->
%%                false
%%        end,
%%    IsUseBottom =
%%        if
%%            IsCanUseBottom ->
%%                LeftPropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
%%                case LeftPropNum < Cost * ?IF(PropId =:= ?ITEM_GOLD, ?SD_COIN_PERSONAL_BACK_NEED_TIMES, ?SD_DIAMOND_PERSONAL_BACK_NEED_TIMES) of
%%                    true ->
%%                        util_random:p(?IF(PropId =:= ?ITEM_GOLD, ?SD_COIN_PERSONAL_BACK_PER, ?SD_DIAMOND_PERSONAL_BACK_PER));
%%                    false ->
%%                        false
%%                end;
%%            true ->
%%                false
%%        end,
%%    NewPoolTimes = PoolTimes - 1,
%%    NewCost = Cost * CostRate,
%%    AddRate = case PropId of ?ITEM_GOLD -> ?SD_COIN_PERSONAL_ADD_TIMES;?ITEM_RMB -> ?SD_DIAMOND_PERSONAL_ADD_TIMES end,
%%    NewDbPlayerFightAdjust1 =
%%        case CostPool of
%%            1 ->
%%                if
%%                    Pool1 >= NewCost ->
%%                        DbPlayerFightAdjust#db_player_fight_adjust{pool_1 = Pool1 - NewCost};
%%                    true ->
%%                        DbPlayerFightAdjust#db_player_fight_adjust{pool_1 = Pool1 + max((Cost * AddRate) - NewCost, 0), pool_2 = Pool2 + (Cost * AddRate)}
%%                end;
%%            2 ->
%%                if
%%                    Pool2 >= NewCost ->
%%                        DbPlayerFightAdjust#db_player_fight_adjust{pool_2 = Pool2 - NewCost};
%%                    true ->
%%                        DbPlayerFightAdjust#db_player_fight_adjust{pool_1 = Pool1 + (Cost * AddRate), pool_2 = Pool2 + max((Cost * AddRate) - NewCost, 0)}
%%                end
%%        end,
%%%%    NewDbPlayerFightAdjust = NewDbPlayerFightAdjust1#db_player_fight_adjust{pool_times = NewPoolTimes},
%%    Tran =
%%        fun() ->
%%            if
%%                IsUseBottom ->
%%                    [MinPoolTimes, MaxPoolTimes, NewId] = ?IF(PropId =:= ?ITEM_GOLD,
%%                        case FightType of 0 -> ?SD_COIN_PERSONAL_BACK_LIST; 1 ->
%%                            ?SD_HP_MODE_COIN_PERSONAL_BACK_LIST end,
%%                        case FightType of 0 -> ?SD_DIAMOND_PERSONAL_BACK_LIST; 1 ->
%%                            ?SD_HP_MODE_DIAMOND_PERSONAL_BACK_LIST end
%%                    ),
%%                    db:write(NewDbPlayerFightAdjust1#db_player_fight_adjust{
%%                        pool = 1,
%%                        pool_times = util_random:random_number(MinPoolTimes, MaxPoolTimes),
%%                        is_bottom = ?TRUE,
%%                        bottom_times = NewBottomUseTimes + 1,
%%                        bottom_times_time = util_time:timestamp(),
%%                        id = NewId
%%                    });
%%%%                    api_player:notice_player_xiu_zhen_value(PlayerId, [{2, server_adjust:get_player_server_adjust_rate(PlayerId)}, {3, NewId}]);
%%                true ->
%%                    db:write(NewDbPlayerFightAdjust1#db_player_fight_adjust{
%%                        pool_times = NewPoolTimes,
%%                        is_bottom = ?IF(IsBottom =:= ?TRUE andalso NewPoolTimes =:= 0, ?FALSE, IsBottom)
%%                    })
%%            end,
%%            api_player:notice_player_xiu_zhen_value(PlayerId, [])
%%        end,
%%    db:do(Tran),
%%    ok.
%%
%%get_player_fight_adjust(PlayerId, MonsterId, PropId) ->
%%    DbPlayerFightAdjust = get_db_player_fight_adjust_or_init(PlayerId, PropId),
%%    #db_player_fight_adjust{
%%        id = Id
%%%%        rate = Rate
%%    } = DbPlayerFightAdjust,
%%    #t_monster{
%%        xiuzheng_list = XiuzhenList
%%    } = mod_scene_monster_manager:get_t_monster(MonsterId),
%%    [Id, Rate, _CostPool, _CostRate] = util_list:key_find(Id, 1, XiuzhenList),
%%    Rate.
%%
%%get_db_player_fight_adjust(PlayerId, PropId, FightType) ->
%%    db:read(#key_player_fight_adjust{player_id = PlayerId, prop_id = PropId, fight_type = FightType}).
%%get_db_player_fight_adjust_or_init(PlayerId, PropId) ->
%%    #ets_obj_player{
%%        scene_id = SceneId
%%    } = mod_obj_player:get_obj_player(PlayerId),
%%    #t_scene{
%%        battle_type = FightType
%%    } = mod_scene:get_t_scene(SceneId),
%%    DbPlayerFightAdjust =
%%        case get_db_player_fight_adjust(PlayerId, PropId, FightType) of
%%            null ->
%%                #db_player_fight_adjust{
%%                    player_id = PlayerId,
%%                    prop_id = PropId,
%%                    fight_type = FightType
%%                };
%%            DbPlayerFightAdjust1 ->
%%                DbPlayerFightAdjust1
%%        end,
%%    #db_player_fight_adjust{
%%        pool_times = PoolTimes,
%%        pool_1 = Pool1,
%%        pool_2 = Pool2
%%    } = DbPlayerFightAdjust,
%%    if
%%        PoolTimes =< 0 ->
%%            Pool = util_random:get_probability_item([{1, Pool1 + 1}, {2, Pool2 + 1}]),
%%            {RateList, PoolTimesList} =
%%                case PropId of
%%                    ?ITEM_GOLD ->
%%                        {
%%                            ?SD_COIN_PERSONAL_XIUZHENG_LIST,
%%                            case FightType of
%%                                0 ->
%%                                    ?SD_COIN_PERSONAL_XIUZHENG_COUNT_LIST;
%%                                1 ->
%%                                    ?SD_HP_MODE_COIN_PERSONAL_XIUZHENG_COUNT_LIST
%%                            end
%%                        };
%%                    ?ITEM_RMB ->
%%                        {
%%                            ?SD_DIAMOND_PERSONAL_XIUZHENG_LIST,
%%                            case FightType of
%%                                0 ->
%%                                    ?SD_DIAMOND_PERSONAL_XIUZHENG_COUNT_LIST;
%%                                1 ->
%%                                    ?SD_HP_MODE_DIAMOND_PERSONAL_XIUZHENG_COUNT_LIST
%%                            end
%%                        }
%%                end,
%%            Id = util_random:get_probability_item(util_list:opt(Pool, RateList)),
%%            [Id, PoolTimesMin, PoolTimesMax] = util_list:key_find(Id, 1, PoolTimesList),
%%            NewPoolTimes = util_random:random_number([PoolTimesMin, PoolTimesMax]),
%%            NewDbPlayerFightAdjust =
%%                DbPlayerFightAdjust#db_player_fight_adjust{
%%                    pool = Pool,
%%                    pool_times = NewPoolTimes,
%%                    id = Id
%%%%                    rate = Rate,
%%%%                    cost_rate = CostRate,
%%%%                    cost_pool = CostPool
%%                },
%%            Tran =
%%                fun() ->
%%                    db:write(NewDbPlayerFightAdjust)
%%%%                    api_player:notice_player_xiu_zhen_value(PlayerId, [{2, server_adjust:get_player_server_adjust_rate(PlayerId)}, {3, Id}])
%%                end,
%%            db:do(Tran),
%%            NewDbPlayerFightAdjust;
%%        true ->
%%            DbPlayerFightAdjust
%%    end.
%%
%%%% @doc 获得新手玩家修正
%%get_novice_player_adjust(PlayerId, MonsterId, PropId) ->
%%    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_ADJUST_TOTAL_VALUE),
%%    case util_list:get_value_from_range_list(Value, get_novice_player_random_adjust_list(PlayerId)) of
%%        undefined ->
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?FALSE),
%%            get_player_fight_adjust(PlayerId, MonsterId, PropId);
%%        Rate ->
%%            Rate
%%    end.
%%
%%%% @doc 获得新手玩家随机修正列表
%%get_novice_player_random_adjust_list(PlayerId) ->
%%    Length = length(?SD_NEWBEE_XIUZHENG),
%%    case mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_NOVICE_RANDOM_LIST) of
%%        0 ->
%%            RandomNum = util_random:random_number(Length),
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_NOVICE_RANDOM_LIST, RandomNum),
%%            lists:nth(RandomNum, ?SD_NEWBEE_XIUZHENG);
%%        Num ->
%%            if
%%                Length >= Num ->
%%                    lists:nth(Num, ?SD_NEWBEE_XIUZHENG);
%%                true ->
%%                    RandomNum = util_random:random_number(Length),
%%                    mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_PLAYER_NOVICE_RANDOM_LIST, RandomNum),
%%                    lists:nth(RandomNum, ?SD_NEWBEE_XIUZHENG)
%%            end
%%    end.
%%
%%%% @doc 改变新手玩家修正值
%%change_novice_player_adjust_value(PlayerId, PropId, MonsterId, Cost) ->
%%    Value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_ADJUST_TOTAL_VALUE),
%%    case util_list:get_value_from_range_list(Value, get_novice_player_random_adjust_list(PlayerId)) of
%%        undefined ->
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_IS_OPEN_NOVICE_ADJUST, ?FALSE),
%%            charge_player_fight_adjust(PlayerId, PropId, MonsterId, Cost);
%%        _Rate ->
%%            mod_player_game_data:set_int_data(PlayerId, ?PLAYER_GAME_DATA_ADJUST_TOTAL_VALUE, Value + Cost)
%%    end.
%%
%%get_id(PlayerId, PropId) ->
%%    DbPlayerFightAdjust = get_db_player_fight_adjust_or_init(PlayerId, PropId),
%%    #db_player_fight_adjust{
%%        id = Id
%%%%        rate = Rate
%%    } = DbPlayerFightAdjust,
%%    Id.
%%
%%change_player_fight_adjust(PlayerId, PropId, CostPool, CostPoolValue, Cost) ->
%%    ?ASSERT(lists:member(PropId, [?ITEM_GOLD, ?ITEM_RMB])),
%%    DbPlayerFightAdjust = get_db_player_fight_adjust_or_init(PlayerId, PropId),
%%    #db_player_fight_adjust{
%%        fight_type = FightType,
%%        pool_times = PoolTimes,
%%%%        cost_rate = CostRate,
%%%%        cost_pool = CostPool,
%%        pool_1 = Pool1,
%%        pool_2 = Pool2,
%%        bottom_times = BottomUseTimes,
%%        bottom_times_time = LastBottomUseTime,
%%        is_bottom = IsBottom
%%    } = DbPlayerFightAdjust,
%%    NewBottomUseTimes = ?IF(util_time:is_today(LastBottomUseTime), BottomUseTimes, 0),
%%    %% 是否可以使用触底反弹
%%    IsCanUseBottom =
%%        case IsBottom of
%%            ?FALSE ->
%%                NewBottomUseTimes < ?IF(PropId =:= ?ITEM_GOLD, ?SD_COIN_PERSONAL_BACK_TIMES, ?SD_DIAMOND_PERSONAL_BACK_TIMES);
%%            ?TRUE ->
%%                false
%%        end,
%%    IsUseBottom =
%%        if
%%            IsCanUseBottom ->
%%                LeftPropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
%%                case LeftPropNum < Cost * ?IF(PropId =:= ?ITEM_GOLD, ?SD_COIN_PERSONAL_BACK_NEED_TIMES, ?SD_DIAMOND_PERSONAL_BACK_NEED_TIMES) of
%%                    true ->
%%                        util_random:p(?IF(PropId =:= ?ITEM_GOLD, ?SD_COIN_PERSONAL_BACK_PER, ?SD_DIAMOND_PERSONAL_BACK_PER));
%%                    false ->
%%                        false
%%                end;
%%            true ->
%%                false
%%        end,
%%    NewPoolTimes = PoolTimes - 1,
%%    AddRate = case PropId of ?ITEM_GOLD -> ?SD_COIN_PERSONAL_ADD_TIMES;?ITEM_RMB -> ?SD_DIAMOND_PERSONAL_ADD_TIMES end,
%%    NewDbPlayerFightAdjust1 =
%%        case CostPool of
%%            1 ->
%%                if
%%                    Pool1 >= CostPoolValue ->
%%                        DbPlayerFightAdjust#db_player_fight_adjust{pool_1 = Pool1 - CostPoolValue};
%%                    true ->
%%                        DbPlayerFightAdjust#db_player_fight_adjust{pool_1 = Pool1 + max((Cost * AddRate) - CostPoolValue, 0), pool_2 = Pool2 + (Cost * AddRate)}
%%                end;
%%            2 ->
%%                if
%%                    Pool2 >= CostPoolValue ->
%%                        DbPlayerFightAdjust#db_player_fight_adjust{pool_2 = Pool2 - CostPoolValue};
%%                    true ->
%%                        DbPlayerFightAdjust#db_player_fight_adjust{pool_1 = Pool1 + (Cost * AddRate), pool_2 = Pool2 + max((Cost * AddRate), 0) - CostPoolValue}
%%                end
%%        end,
%%%%    NewDbPlayerFightAdjust = NewDbPlayerFightAdjust1#db_player_fight_adjust{pool_times = NewPoolTimes},
%%    Tran =
%%        fun() ->
%%            if
%%                IsUseBottom ->
%%                    [MinPoolTimes, MaxPoolTimes, NewId] = ?IF(PropId =:= ?ITEM_GOLD,
%%                        case FightType of 0 -> ?SD_COIN_PERSONAL_BACK_LIST; 1 ->
%%                            ?SD_HP_MODE_COIN_PERSONAL_BACK_LIST end,
%%                        case FightType of 0 -> ?SD_DIAMOND_PERSONAL_BACK_LIST; 1 ->
%%                            ?SD_HP_MODE_DIAMOND_PERSONAL_BACK_LIST end
%%                    ),
%%%%                    [MinPoolTimes, MaxPoolTimes, NewId] = ?IF(PropId =:= ?ITEM_GOLD, ?SD_COIN_PERSONAL_BACK_LIST, ?SD_DIAMOND_PERSONAL_BACK_LIST),
%%                    db:write(NewDbPlayerFightAdjust1#db_player_fight_adjust{
%%                        pool = 1,
%%                        pool_times = util_random:random_number(MinPoolTimes, MaxPoolTimes),
%%                        is_bottom = ?TRUE,
%%                        bottom_times = NewBottomUseTimes + 1,
%%                        bottom_times_time = util_time:timestamp(),
%%                        id = NewId
%%                    });
%%                true ->
%%                    db:write(NewDbPlayerFightAdjust1#db_player_fight_adjust{
%%                        pool_times = NewPoolTimes,
%%                        is_bottom = ?IF(IsBottom =:= ?TRUE andalso NewPoolTimes =:= 0, ?FALSE, IsBottom)
%%                    })
%%            end
%%%%            api_player:notice_player_xiu_zhen_value(PlayerId, [{2, server_adjust:get_player_server_adjust_rate(PlayerId)}, {3, NewId}])
%%        end,
%%    db:do(Tran),
%%    api_player:notice_player_xiu_zhen_value(PlayerId, []),
%%    ok.
