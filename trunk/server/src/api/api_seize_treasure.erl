%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 5月 2021 下午 05:57:34
%%%-------------------------------------------------------------------
-module(api_seize_treasure).
-author("Administrator").

%% API
-export([
    get_treasure/2,
    get_extra_award/2,
    get_extra_award_status/2
]).

-export([
    test_get_seize_treasure/2,
    test_get_extra_award/0,
    test_get_extra_award_status/0
]).

%%-include("record.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
-include("p_message.hrl").
-include("gen/db.hrl").
-include("player_game_data.hrl").

get_treasure(
    #m_seize_treasure_get_treasure_tos{type = Type},
    State = #conn{player_id = PlayerId}
) ->
    %% 静态表配置的今日夺宝类型编号
    TreasureHuntTypeId = mod_seize_treasure:seize_type(),
    Out =
        case catch mod_seize_treasure:seize(PlayerId, TreasureHuntTypeId, Type) of
            {PropList, Seize, LuckyValue, _PosList} ->
                #m_seize_treasure_get_treasure_toc{result = 1, prop_list = PropList, times = Seize,
                    value = LuckyValue}; %% , idx = PosList };
            {'EXIT', no_enough_prop} ->
                #m_seize_treasure_get_treasure_toc{ result = 2 };
            {'EXIT', invalid_platform} ->
                #m_seize_treasure_get_treasure_toc{ result = 3 };
            {'EXIT', invalid_seize_treasure_data} ->
                #m_seize_treasure_get_treasure_toc{ result = 4 };
            {'EXIT', unknown} ->
                #m_seize_treasure_get_treasure_toc{ result = 5 };
            {'EXIT', R} ->
                #m_seize_treasure_get_treasure_toc{ result = 5 };
            _ ->
                ?ERROR("真unknown"),
                #m_seize_treasure_get_treasure_toc{ result = 5 }
        end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(proto:encode(Out)),
    %% 2021-06-05 注释，客户端要求不要主动推
%%    ExtraAwardOut =
%%        case catch mod_seize_treasure:get_seize_extra_award_status(PlayerId) of
%%            Res when is_list(Res) ->
%%                ?INFO("Res: ~p", [Res]),
%%                #m_seize_treasure_get_extra_award_status_toc{result = 1, status = lists:join(",", Res)};
%%            {'EXIT', not_exists} ->
%%                ?DEBUG("Error: not_exists"),
%%                #m_seize_treasure_get_extra_award_status_toc{ result = 2 };
%%            {'EXIT', unknown} ->
%%                #m_seize_treasure_get_extra_award_status_toc{ result = 3 }
%%        end,
%%    ?DEBUG("ExtraAwardOut: ~p", [ExtraAwardOut]),
%%    mod_socket:send(proto:encode(ExtraAwardOut)),
    State.

get_extra_award(
    #m_seize_treasure_get_extra_award_tos{idx = Pos},
    State = #conn{player_id = PlayerId}
) ->
    Out =
        case catch mod_seize_treasure:extra_award(PlayerId, Pos) of
            {SeizeTimes, R} ->
                ?INFO("SeizeTimes: ~p, R: ~p", [SeizeTimes, R]),
                proto:encode(#m_seize_treasure_get_extra_award_toc{result = 1, times = SeizeTimes, prop_list = R});
            {'EXIT', no_enough_seize_times} ->
                ?DEBUG("Error: no_enough_seize_times"),
                proto:encode(#m_seize_treasure_get_extra_award_toc{result = 2});
            {'EXIT', no_achievement_list} ->
                ?DEBUG("Error: no_achievement_list"),
                proto:encode(#m_seize_treasure_get_extra_award_toc{result = 3});
            {'EXIT', no_achievement_wait_4_get} ->
                ?DEBUG("Error: no_achievement_wait_4_get"),
                proto:encode(#m_seize_treasure_get_extra_award_toc{result = 4})
        end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(Out),
    State.

get_extra_award_status(
    #m_seize_treasure_get_extra_award_status_tos{},
    State = #conn{player_id = PlayerId}
) ->
    Out =
    case catch mod_seize_treasure:get_seize_extra_award_status(PlayerId) of
        R when is_list(R) ->
            ?INFO("R: ~p", [R]),
            proto:encode(#m_seize_treasure_get_extra_award_status_toc{result = 1, status = lists:join(",", R)});
        {'EXIT', not_exists} ->
            ?DEBUG("Error: not_exists"),
            proto:encode(#m_seize_treasure_get_extra_award_status_toc{ result = 2 });
        {'EXIT', unknown} ->
            proto:encode(#m_seize_treasure_get_extra_award_status_toc{ result = 3 })
    end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(Out),
    State.

%% --------------------------------------------------- 测试 -------------------------------------------------------------
test_get_seize_treasure(Type, PlayerId) ->
    %% 客户端上报的协议中的type的值
%%    Type = 1,
    %% 玩家编号
%%    PlayerId = 10312,
    %% 静态表配置的今日夺宝类型编号
    TreasureHuntTypeId = mod_seize_treasure:seize_type(),
    case catch mod_seize_treasure:seize(PlayerId, TreasureHuntTypeId, Type) of
        {PropList, Seize, LuckyValue, PosList} ->
            ?DEBUG("toc: ~p", [#m_seize_treasure_get_treasure_toc{
                result = 1, prop_list = PropList, times = Seize, value = LuckyValue, idx = PosList
            }]),
            {ok, {PropList, Seize, LuckyValue, PosList}};
        {'EXIT', R} ->
            ?DEBUG("Error: ~p", [R]),
            ok
    end.

test_get_extra_award_status() ->
    PlayerId = 10058,
    Out =
        case catch mod_seize_treasure:get_seize_extra_award_status(PlayerId) of
            R when is_list(R) ->
                ?INFO("R: ~p", [R]),
                proto:encode(#m_seize_treasure_get_extra_award_status_toc{result = 1, status = lists:join(",", R)});
            {'EXIT', not_exists} ->
                ?DEBUG("Error: not_exists"),
                proto:encode(#m_seize_treasure_get_extra_award_status_toc{ result = 2 });
            {'EXIT', unknown} ->
                proto:encode(#m_seize_treasure_get_extra_award_status_toc{ result = 3 })
        end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(Out),
    ok.

test_get_extra_award() ->
    %% 玩家编号
    PlayerId = 10285,
    Pos = 0,
    Out =
        case catch mod_seize_treasure:extra_award(PlayerId, Pos) of
            {'EXIT', no_enough_seize_times} ->
                ?DEBUG("Error: no_enough_seize_times"),
                proto:encode(#m_seize_treasure_get_extra_award_toc{result = 2});
            {'EXIT', no_achievement_list} ->
                ?DEBUG("Error: no_achievement_list"),
                proto:encode(#m_seize_treasure_get_extra_award_toc{result = 3});
            {'EXIT', no_achievement_wait_4_get} ->
                ?DEBUG("Error: no_achievement_wait_4_get"),
                proto:encode(#m_seize_treasure_get_extra_award_toc{result = 4});
            R ->
                ?INFO("R: ~p", [R]),
                proto:encode(
                    #m_seize_treasure_get_extra_award_toc{
                        result = 1,
                        times = 0,
                        prop_list = [#prop{prop_id = 1, num = 1}]
                    }
                )
        end,
    ?DEBUG("Out: ~p", [Out]).