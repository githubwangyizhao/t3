%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%      小游戏拉霸
%%% @end
%%% Created : 25. 五月 2021 上午 11:20:42
%%%-------------------------------------------------------------------
-module(mod_laba).
-author("yizhao.wang").

-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("error.hrl").
-include("client.hrl").
-include("player_game_data.hrl").
-include("laba.hrl").

%% API
-export([
    laba_spin/3,

    get_column_by_grid_id/1,
    get_row_by_grid_id/1,
    get_same_column_grid_id_list/1,
    get_freegame_max_reward_num/0,

    init_laba_grids/1,
    adjust_Laba_pool/3,

    db_inc_player_laba_missed_times/3,
    db_clear_player_laba_missed_times/3
]).
-export([
    getLaBaState/2      %% todo hide ...
]).
-export([
    set_cur_laba_id/1,
    get_cur_laba_id/0,
    get_coins_bet/0,
    get_laba_state/0
]).

-record(?MODULE, {
    laba_id = 0,                        %% 拉霸机编号
    coins_bet = 0,                      %% 下注金额
    laba_state = 0,                     %% 当前大盘状态
    handle_laba_module = null
}).

set_cur_laba_id(LaBaId) -> ?setModDict(laba_id, LaBaId).
get_cur_laba_id() -> ?getModDict(laba_id).
get_coins_bet() -> ?getModDict(coins_bet).
get_laba_state() -> ?getModDict(laba_state).

%% ----------------------------------
%% @doc 	获取同一列的格子id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_same_column_grid_id_list(Col) ->
    lists:map(
        fun(I) ->
            Col + I * ?GET_GRID_COL
        end,
        lists:seq(0, ?GET_GRID_ROW - 1)
    ).

%% ----------------------------------
%% @doc 	获取格子所属列
%% @throws 	none
%% @end
%% ----------------------------------
get_column_by_grid_id(GridId) ->
    (GridId - 1) rem ?GET_GRID_COL + 1.

%% ----------------------------------
%% @doc 	获取格子所属行
%% @throws 	none
%% @end
%% ----------------------------------
get_row_by_grid_id(GridId) ->
    ceil(GridId / ?GET_GRID_COL).

%% ----------------------------------
%% @doc 	获取FreeGame模式中期望最大奖励数
%% @throws 	none
%% @end
%% ----------------------------------
get_freegame_max_reward_num() ->
    LaBaId = ?getModDict(laba_id),
    LaBaState = ?getModDict(laba_state),
    CoinsBet = ?getModDict(coins_bet),
    #t_laba{
        laba_freegamemultiplemax_list = RewardRateCfgList
    } = t_laba:assert_get({LaBaId}),

    RateRangeWeights = util_list:opt(LaBaState, RewardRateCfgList),
    RateRange = util_random:get_probability_item(RateRangeWeights),
    floor(util_random:random_number(RateRange) * CoinsBet / 10000).

%% ----------------------------------
%% @doc 	转动拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
laba_spin(PlayerId, LaBaId, Cost) ->
   #t_laba{
       consume_list = [CostType, CostList],
       judgedefault = IsDefaultLaBa,
       machinetype = LaBaType
    } = t_laba:assert_get({LaBaId}),

    ?ASSERT(IsDefaultLaBa == 1, ?ERROR_FAIL),
    ?ASSERT(lists:member(Cost, CostList), ?ERROR_FAIL),
    mod_prop:assert_prop_num(PlayerId, CostType, Cost),
    %% 加入拉霸机
    laba_srv:call({join, PlayerId, self(), LaBaId, Cost}),
    LaBaState = getLaBaState(LaBaId, Cost),

    ?setModDict(laba_id, LaBaId),
    ?setModDict(coins_bet, Cost),
    ?setModDict(laba_state, LaBaState),

    HandleMod =
        case LaBaType of
            ?TYPE_COMBO_LABA -> handle_combo_laba;
            ?TYPE_LINE_LABA -> handle_line_laba
        end,
    ?setModDict(handle_laba_module, HandleMod),
    %% 初始化拉霸机
    HandleMod:handle_laba_spin(PlayerId, LaBaId, Cost).

%%%% ----------------------------------
%%%% @doc 	初始拉霸机格子数据
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
init_laba_grids(PlayerId) ->
    LaBaId = ?getModDict(laba_id),
    CostRate = ?getModDict(coins_bet),
    #t_laba{
        laba_baodi_list = LaBaBaoDiList
    } = t_laba:assert_get({LaBaId}),

    HandleMod = ?getModDict(handle_laba_module),
    %% 判断是否触发保底规则
    MissedTimes = db_get_player_laba_missed_times(PlayerId, LaBaId, CostRate),
    case util_list:key_find(MissedTimes, 1, LaBaBaoDiList) of
        false ->
            %% 大盘输赢状态控制拉霸结果
            HandleMod:init_grids(getLaBaCtrlResult());
        [_, P, ProtectKinds] ->
            case util_random:p(P) of
                true ->
                    %% 连续未中，触发保底结果
                    HandleMod:set_protect_base_kind(util_random:get_list_random_member(ProtectKinds)),
                    HandleMod:init_grids(?LABA_RESULT_CTRL_4);
                false ->
                    HandleMod:init_grids(getLaBaCtrlResult())
            end
    end.

%% ----------------------------------
%% @doc 	db获取玩家连续未中奖次数数据
%% @throws 	none
%% @end
%% ----------------------------------
db_get_player_laba_missed_times(PlayerId, LaBaId, CostRate) ->
   R = db_get_player_laba_data_init(PlayerId, LaBaId, CostRate),
   R#db_player_laba_data.missed_times.

db_inc_player_laba_missed_times(PlayerId, LaBaId, CostRate) ->
    R = db_get_player_laba_data_init(PlayerId, LaBaId, CostRate),
    #db_player_laba_data{
        missed_times = OriMissedTimes
    } = R,
    db:do(fun() ->
        db:write(R#db_player_laba_data{missed_times = OriMissedTimes + 1})
    end).

db_clear_player_laba_missed_times(PlayerId, LaBaId, CostRate) ->
    R = db_get_player_laba_data_init(PlayerId, LaBaId, CostRate),
    db:do(fun() ->
        db:write(R#db_player_laba_data{missed_times = 0})
    end).

db_get_player_laba_data_init(PlayerId, LaBaId, CostRate) ->
    case db:read(#key_player_laba_data{player_id = PlayerId, laba_id = LaBaId, cost_rate = CostRate}) of
        null ->
            #db_player_laba_data{
                player_id = PlayerId,
                laba_id = LaBaId,
                cost_rate = CostRate
            };
        R ->
            R
    end.

%% ----------------------------------
%% @doc 	修正拉霸机奖池
%% @throws 	none
%% @end
%% ----------------------------------
adjust_Laba_pool(LaBaId, CostNum, RewardNum) ->
    %% 抽水
    #t_laba{
        draw_list = LaBaDrawList
    } = t_laba:assert_get({LaBaId}),
    DrawRate = util_list:opt(CostNum, LaBaDrawList) / 10000,
    PoolChangeVal = ceil(CostNum * DrawRate) - RewardNum,
    if
        PoolChangeVal == 0 -> ignore;
        true ->
            laba_srv:cast({update_pool, LaBaId, CostNum, PoolChangeVal})
    end.

%% ----------------------------------
%% @doc 	获取当前拉霸机大盘状态
%% @throws 	none
%% @end
%% ----------------------------------
getLaBaState(LaBaId, CostRate) ->
    #t_laba{
        pricejackpot_list = InitPoolList
    } = t_laba:assert_get({LaBaId}),

    %% 初始奖池值
    InitPool = util_list:opt(CostRate, InitPoolList),
    %% 当前拉霸机参与人数
    LaBaPlayerCount = laba_handle:get_laba_player_count(LaBaId, CostRate),
    %% 基础奖池数 = 初始奖池数 * (参数人数 + 1)
    BasePool = InitPool * (LaBaPlayerCount + 1),
    %% 当前奖池数 = 修正奖池数 + 初始奖池数 * (参数人数 + 1)
    CurrentPool = laba_handle:get_db_laba_pool(LaBaId, CostRate) + InitPool  * (LaBaPlayerCount + 1),
    %% 奖池状态值 = 当前奖池数 / 奖池基础值 * 10000
    PoolStateVal = floor(CurrentPool / BasePool * 10000),
    LaBaState = util_list:get_value_from_range_list(PoolStateVal, ?SD_LABA_STATE),
    ?t_assert(LaBaState /= undefined, {laba_state_none, PoolStateVal}),
    LaBaState.

%% ----------------------------------
%% @doc 	根据当前大盘状态获取输赢控制结果
%% @throws 	none
%% @end
%% ----------------------------------
getLaBaCtrlResult() ->
    LaBaId = ?getModDict(laba_id),
    #t_laba{
        laba_result_list = LaBaResults
    } = t_laba:assert_get({LaBaId}),

    LaBaState = ?getModDict(laba_state),
    Weights = util_list:opt(LaBaState, LaBaResults),
    util_random:get_rand_idx(Weights).