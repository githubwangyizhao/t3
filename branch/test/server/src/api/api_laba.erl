%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%      API 小游戏拉霸
%%% @end
%%% Created : 25. 五月 2021 上午 11:20:42
%%%-------------------------------------------------------------------
-module(api_laba).
-author("yizhao.wang").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("error.hrl").
-include("gen/table_db.hrl").

%% API
-export([
    spin/2,
    spin2/2,
    get_adjust_info/2
]).

%% ----------------------------------
%% @doc 	转动拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
spin(
    #m_laba_spin_tos{
        id = Id,
        num = CoinsBet
    },
    State = #conn{player_id = PlayerId}
) ->
    Out =
    case catch mod_laba:laba_spin(PlayerId, Id, CoinsBet) of
        {ok, GridLists, RewardNums, FreeGameResults, FreeGameRewardNumLists} ->
            proto:encode(#m_laba_spin_toc{
                id = Id,
                num = CoinsBet,
                result = ?P_SUCCESS,
                grids_list = pack_combo_laba_grids_list(GridLists),
                combos = RewardNums,
                freegame_results = [#'m_laba_spin_toc.freegameresult'{grids_list = pack_combo_laba_grids_list(FreeGameResult)} || FreeGameResult <- FreeGameResults],
                freegame_combos = [#'m_laba_spin_toc.freegamecombo'{combos = FreeGameRewardNumList} || FreeGameRewardNumList <-  FreeGameRewardNumLists]
            });
        {'EXIT', Error} ->
            proto:encode(#m_laba_spin_toc{
                result = api_common:api_error_to_enum(Error)
            })
    end,
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	转动拉霸机
%% @throws 	none
%% @end
%% ----------------------------------
spin2(
    #m_laba_spin2_tos{
        id = Id,
        num = CoinsBet
    },
    State = #conn{player_id = PlayerId}
) ->
    Out =
        case catch mod_laba:laba_spin(PlayerId, Id, CoinsBet) of
            {ok, GridList, SpecialGridList, RewardNum, FGGridLists, FGSpecialGridLists, FGRewardNumList} ->
                proto:encode(#m_laba_spin2_toc{
                    id = Id,
                    num = CoinsBet,
                    result = ?P_SUCCESS,
                    grid_list = #'m_laba_spin2_toc.grids'{list = GridList},
                    special_grid_list = #'m_laba_spin2_toc.grids'{list = SpecialGridList},
                    award_num = RewardNum,
                    fg_grid_lists = [#'m_laba_spin2_toc.grids'{list = FGGridList} || FGGridList <- FGGridLists],
                    fg_special_grid_lists = [#'m_laba_spin2_toc.grids'{list = FGGridList} || FGGridList <- FGSpecialGridLists],
                    fg_award_num_list = FGRewardNumList
                });
            {'EXIT', Error} ->
                proto:encode(#m_laba_spin_toc{
                    result = api_common:api_error_to_enum(Error)
                })
        end,
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	获取修正数据（debug）
%% @throws 	none
%% @end
%% ----------------------------------
get_adjust_info(
    #m_laba_get_adjust_info_tos{
        id = LaBaId,
        cost_rate = CostRate
    },
    State
) ->
    ?ASSERT(?IS_DEBUG, ?ERROR_NOT_AUTHORITY),
    #t_laba{
        pricejackpot_list = InitPoolList
    } = t_laba:assert_get({LaBaId}),
    InitPool = util_list:opt(CostRate, InitPoolList),
    LaBaPlayerCount = laba_handle:get_laba_player_count(LaBaId, CostRate),

    Out =
    proto:encode(#m_laba_get_adjust_info_toc{
        data_list = [
            laba_handle:get_db_laba_pool(LaBaId, CostRate) + InitPool * (LaBaPlayerCount + 1),
            mod_laba:getLaBaState(LaBaId, CostRate),
            LaBaPlayerCount
        ]
    }),
    mod_socket:send(Out),
    State.

%% ================================
%% 打包组合拉霸机结果
pack_combo_laba_grids_list(GridLists) ->
    [#'m_laba_spin_toc.grids'{list = GridList} || GridList <- GridLists].