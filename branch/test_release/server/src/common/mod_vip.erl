%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 29. 三月 2018 16:37
%%%-------------------------------------------------------------------
-module(mod_vip).
-author("home").

%% API
-export([
    get_vip_info/1,
    get_vip_award/2
]).

-export([
    add_vip_exp/4,
    get_player_vip_init/1,
    get_player_vip_boon_value/2,
    get_vip_boon_value/2,
    test_fun_change/3,          %% 测试功能
    get_vip_level/1
]).

-export([
    repair_vip/1                % 修复玩家vip数据
]).

-include("msg.hrl").
-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("p_enum.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% @doc     获得vip信息
get_vip_info(PlayerId) ->
    #db_player_vip{
        level = VipLevel,
        exp = VipExp
    } = get_player_vip_init(PlayerId),
    AwardList =
        lists:foldl(
            fun({Level, _}, L) ->
                if
                    Level =< VipLevel ->
                        #db_player_vip_award{
                            state = State
                        } = get_player_vip_award_init(PlayerId, Level),
                        [{Level, max(State, ?AWARD_CAN)} | L];
                    true ->
                        L
                end
            end, [], logic_get_vip_level_exp()),
    {VipLevel, VipExp, AwardList}.

%% @doc     vip奖励领取
get_vip_award(PlayerId, VipLevel) ->
    CurrVipLevel = get_vip_level(PlayerId),
    ?ASSERT(VipLevel =< CurrVipLevel, ?ERROR_NOT_AUTHORITY),
    PlayerVipAwardInit = get_player_vip_award_init(PlayerId, VipLevel),
    ?ASSERT(PlayerVipAwardInit#db_player_vip_award.state =/= ?AWARD_ALREADY, ?ERROR_NOT_AUTHORITY),
    #t_vip_level{
        item_list = ItemList
    } = try_get_t_vip_level(VipLevel),
    mod_prop:assert_give(PlayerId, ItemList),
    Tran =
        fun() ->
            db:write(PlayerVipAwardInit#db_player_vip_award{state = ?AWARD_ALREADY, change_time = util_time:timestamp()}),
            mod_award:give(PlayerId, ItemList, ?LOG_TYPE_VIP_AWARD)
        end,
    db:do(Tran),
    ok.

%% @fun 加vip经验
add_vip_exp(PlayerId, Exp, CurrTime, LogType) ->
    PlayerVip = get_player_vip_init(PlayerId),
    #db_player_vip{
        exp = OldExp,
        level = OldLevel
    } = PlayerVip,
    NewExp = OldExp + Exp,
    NewLevel = calc_vip_level(NewExp),
    Tran =
        fun() ->
            db:write(PlayerVip#db_player_vip{level = NewLevel, exp = NewExp, change_time = CurrTime}),
            if
                NewLevel > OldLevel ->
                    PlayerData = mod_player:get_db_player_data(PlayerId),
                    db:write(PlayerData#db_player_data{vip_level = NewLevel}),
                    next_vip_level(PlayerId, OldLevel, NewLevel),
                    mod_times:try_update_times_after_vip_level_change(PlayerId, OldLevel, NewLevel),
                    mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_VIP_LEVEL, NewLevel}]);
                true ->
                    noop
            end,
            mod_log:write_player_vip_log(PlayerId, NewLevel, NewExp, Exp, LogType),
            db:tran_apply(fun() -> api_vip:notice_vip_data(PlayerId) end)
        end,
    db:do(Tran),
    ok.

%% @fun 获得vip 等级
get_vip_level(PlayerId) ->
    PlayerVip = get_player_vip_init(PlayerId),
    PlayerVip#db_player_vip.level.

%% @fun 获得vip 权限值
get_player_vip_boon_value(PlayerId, BoonType) ->
    VipLevel = get_vip_level(PlayerId),
    if
        VipLevel > 0 ->
            Table = try_get_t_vip_boon(BoonType, VipLevel),
            Table#t_vip_boon.value;
        true ->
            0
    end.

get_vip_boon_value(BoonType, VipLevel) ->
    if
        VipLevel > 0 ->
            Table = try_get_t_vip_boon(BoonType, VipLevel),
            Table#t_vip_boon.value;
        true ->
            0
    end.

%% @fun 升到下一级
next_vip_level(PlayerId, OldLevel, NewLevel) ->
    hook:after_vip_level_upgrade(PlayerId, NewLevel, OldLevel),
%%    mod_scene:push_player_data_2_scene(PlayerId, [{?MSG_SYNC_VIP_LEVEL, NewLevel}]),
    api_player:notice_player_attr_change(PlayerId, [{?P_VIP_LEVEL, NewLevel}]).

%% @fun 计算vip等级
calc_vip_level(Exp) ->
    calc_vip_level(logic_get_vip_level_exp(), Exp).
calc_vip_level([], _CurrExp) ->
    0;
calc_vip_level([{Level, LevelExp} | L], CurrExp) ->
    if
        LevelExp =< CurrExp ->
            Level;
        true ->
            calc_vip_level(L, CurrExp)
    end.


%% 测试功能
test_fun_change(PlayerId, Value, LogType) ->
    mod_apply:apply_to_online_player(PlayerId, ?MODULE, add_vip_exp, [PlayerId, Value, util_time:timestamp(), LogType], store).

%% ================================================ 修复操作 ================================================
%% @fun 修复玩家vip数据
repair_vip(PlayerId) ->
    #db_player_vip{
        exp = OldExp,
        level = OldLevel
    } = get_player_vip_init(PlayerId),
    CurrTime = util_time:timestamp(),
    ChargeIngot = mod_charge:get_charge_time_ingot(PlayerId, 0, CurrTime),
    CurrExp = erlang:floor(ChargeIngot * ?VIP_INGOT_EXP_RATE),
    if
        CurrExp > OldExp ->
            mod_vip:add_vip_exp(PlayerId, CurrExp - OldExp, CurrTime, ?LOG_TYPE_GM);
        CurrExp == OldExp ->
            NewLevel = calc_vip_level(CurrExp),
            if
                NewLevel > OldLevel ->
                    mod_vip:add_vip_exp(PlayerId, 0, CurrTime, ?LOG_TYPE_GM);
                true ->
                    noop
            end;
        true ->
            noop
    end.

%% ================================================ 数据操作 ================================================
%% @doc 获得玩家vip 数据
get_player_vip(PlayerId) ->
    case db:read(#key_player_vip{player_id = PlayerId}) of
        null ->
            null;
        DbPlayerVip ->
            #db_player_vip{
                exp = Exp,
                level = OldLevel
            } = DbPlayerVip,
            NewLevel = calc_vip_level(Exp),
            if
                NewLevel > OldLevel ->
                    Tran =
                        fun() ->
                            db:write(DbPlayerVip#db_player_vip{level = NewLevel, exp = Exp, change_time = util_time:timestamp()}),
                            PlayerData = mod_player:get_db_player_data(PlayerId),
                            db:write(PlayerData#db_player_data{vip_level = NewLevel}),
                            next_vip_level(PlayerId, OldLevel, NewLevel),
                            mod_times:try_update_times_after_vip_level_change(PlayerId, OldLevel, NewLevel),
                            mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_VIP_LEVEL, NewLevel}]),
                            mod_log:write_player_vip_log(PlayerId, NewLevel, Exp, 0, ?LOG_TYPE_SYSTEM_SEND),
                            db:tran_apply(fun() -> api_vip:notice_vip_data(PlayerId) end)
                        end,
                    db:do(Tran);
                true ->
                    DbPlayerVip
            end
    end.
%% @doc 获得玩家vip 数据  初始化
get_player_vip_init(PlayerId) ->
    case get_player_vip(PlayerId) of
        Vip when is_record(Vip, db_player_vip) ->
            Vip;
        _ ->
            #db_player_vip{player_id = PlayerId}
    end.

%% @doc 获得玩家vip奖励数据
get_player_vip_award(PlayerId, Level) ->
    db:read(#key_player_vip_award{player_id = PlayerId, level = Level}).
%% @doc 获得玩家vip奖励数据     并初始化
get_player_vip_award_init(PlayerId, Level) ->
    case get_player_vip_award(PlayerId, Level) of
        Award when is_record(Award, db_player_vip_award) ->
            Award;
        _ ->
            #db_player_vip_award{player_id = PlayerId, level = Level}
    end.


%% ================================================ 模板操作 ================================================
%% @fun 获得vip等级数据
try_get_t_vip_level(VipLevel) ->
    Table = t_vip_level:get({VipLevel}),
    ?IF(is_record(Table, t_vip_level), Table, exit({t_vip_level, {VipLevel}})).


%% @fun 获得vip权限的数据
try_get_t_vip_boon(BoonType, VipLevel) ->
    Table = t_vip_boon:get({BoonType, VipLevel}),
    ?IF(is_record(Table, t_vip_boon), Table, exit({t_vip_boon, {BoonType, VipLevel}})).


%% @fun vip等级经验
logic_get_vip_level_exp() ->
    logic_get_vip_level_exp:get(0).
