%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 5月 2021 下午 12:07:29
%%%-------------------------------------------------------------------
-module(mod_bet_player_manager).
-author("Administrator").

-include("common.hrl").
-include("scene.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    add_bet_player_list/2,
    get_bet_player_list/1,
    get_single_player_bet/2,            %% 获取指定玩家的投注信息
    del_bet_player/2,
    del_bet_players_leave/1,

    add_bet_player_leave_list/2,
    get_bet_player_leave_list/1,
    del_bet_player_leave_list/2,
    del_bet_players/1,
    clear_players_bet/1
]).

%% --------------------------------------- 2021-05-27 进入投注页面的玩家 start -------------------------------------------

add_bet_player_leave_list(ObjType, ObjId) ->
    PlayerWhoLeaveBetList = get_bet_player_leave_list(ObjType),
    ?DEBUG("PlayerWhoLeaveBetList: ~p", [PlayerWhoLeaveBetList]),
    PlayerLeaveBetTupleList =
        case lists:member(ObjId, PlayerWhoLeaveBetList) of
            true ->
                PlayerWhoLeaveBetList;
            false ->
                {PlayerId} = ObjId,
                ?DEBUG("Player~p leave ~p", [PlayerId, get_bet_player_list(ObjType)]),
                case lists:keyfind(PlayerId, 1, get_bet_player_list(ObjType)) of
                    false -> exit(not_exists);
                    _ -> [ObjId | PlayerWhoLeaveBetList]
                end
        end,
    ?DEBUG("PlayerLeaveBetTupleList: ~p", [PlayerLeaveBetTupleList]),
    if
        PlayerLeaveBetTupleList =:= PlayerWhoLeaveBetList -> PlayerWhoLeaveBetList;
        true -> put({?MISSION_BET_PLAYER_LEAVE_LIST, ObjType}, PlayerLeaveBetTupleList)
    end.

get_bet_player_leave_list(ObjType) ->
    case get({?MISSION_BET_PLAYER_LEAVE_LIST, ObjType}) of
        ?UNDEFINED ->
            [];
        ok -> [];
        L ->
            L
    end.

del_bet_player_leave_list(ObjType, PlayerId) ->
    put({?MISSION_BET_PLAYER_LEAVE_LIST, ObjType}, lists:keydelete(PlayerId, 1, get_bet_player_leave_list(ObjType))).

del_bet_players_leave(ObjType) ->
    ?DEBUG("player leave: ~p", [get_bet_player_leave_list(ObjType)]),
    R = put({?MISSION_BET_PLAYER_LEAVE_LIST, ObjType}, []),
    ?DEBUG("after player leave: ~p", [get_bet_player_leave_list(ObjType)]),
    ?DEBUG("player in bet: ~p", [get_bet_player_list(ObjType)]),
    R.

get_bet_limitation_by_mission_type(MissionType) ->
    case MissionType of
        ?MISSION_TYPE_GUESS_BOSS -> ?SD_GUESS_MAX_LIMIT;
        ?MISSION_TYPE_MISSION_HERO_PK_BOSS -> ?SD_HERO_VS_BOSS_MISSION_MAX_LIMIT
    end.

add_bet_player_list(MissionType, ObjId) ->
    {PlayerId, BetTupleList} = ObjId,
    MaxBet = get_bet_limitation_by_mission_type(MissionType),
    PlayerList = get_bet_player_list(MissionType),
%%    ?DEBUG("ObjId: ~p ~p ~p", [ObjId, PlayerId, BetTupleList]),
    PlayerBetTupleList =
        case lists:keyfind(PlayerId, 1, PlayerList) of
            {_, OldBetTupleList} ->
                %% 当前玩家是否离开过下注界面
                case lists:member({PlayerId}, get_bet_player_leave_list(MissionType)) of
                    %% 当前玩家曾经离开过下注界面
                    true -> del_bet_player_leave_list(MissionType, PlayerId);
                    false -> noop %% ?DEBUG("~p has not leave the bet pipeline", [ObjId])
                end,
                NewBetTupleList =
                    lists:foldl(
                        fun({OldBossPos, OldBossBet}, Tmp) ->
                            NewBetTuple =
                                case lists:keyfind(OldBossPos, 1, BetTupleList) of
                                    false -> {OldBossPos, OldBossBet};
                                    {_, NewBet} ->
                                        NewBetData = NewBet + OldBossBet,
                                        {OldBossPos,
                                            ?IF(NewBetData > OldBossBet,
                                                ?IF(NewBetData >= MaxBet, MaxBet, NewBetData), OldBossBet)
                                        }
                                end,
                            [NewBetTuple | Tmp]
                        end,
                        [],
                        OldBetTupleList
                    ),
%%                ?DEBUG("NewBetTupleList: ~p", [NewBetTupleList]),
                lists:keyreplace(PlayerId, 1, PlayerList, {PlayerId, NewBetTupleList});
            false -> [ObjId | PlayerList]
        end,
%%    ?DEBUG("PlayerBetTupleList: ~p", [PlayerBetTupleList]),
    if
        PlayerBetTupleList =:= PlayerList -> PlayerList;
        true ->
            put({?MISSION_BET_PLAYER_LIST, MissionType}, PlayerBetTupleList)
    end.

get_single_player_bet(ObjType, PlayerId) ->
    case lists:keyfind(PlayerId, 1, get_bet_player_list(ObjType)) of
        false -> [];
        {_, BetTupleList} -> BetTupleList
    end.
get_bet_player_list(ObjType) ->
    case get({?MISSION_BET_PLAYER_LIST, ObjType}) of
        ok -> [];
        ?UNDEFINED ->
            [];
        L ->
            L
    end.

del_bet_player(ObjType, PlayerId) ->
%%    put({?MISSION_BET_PLAYER_LIST, ObjType}, lists:delete(ObjId, get_bet_player_list(ObjType))).
    put({?MISSION_BET_PLAYER_LIST, ObjType}, lists:keydelete(PlayerId, 1, get_bet_player_list(ObjType))).

clear_players_bet(ObjType) ->
    PlayerList = get_bet_player_list(ObjType),
    case ObjType of
        ?MISSION_TYPE_GUESS_BOSS ->
            ?DEBUG("重置以下玩家的投注列表，因为他们还在投注界面: ~p", [PlayerList]),
            ?DEBUG("离开投注界面玩家: ~p", [get_bet_player_leave_list(ObjType)]),
            NewPlayerBetList =
                lists:foldl(
                    fun({PlayerId, _OldBetTupleList}, Tmp) ->
                        case lists:member({PlayerId}, get_bet_player_leave_list(ObjType)) of
                            false ->
                                NewBetTupleList = [{Pos, 0} || [Pos, _BossList, _Rate] <- ?SD_GUESS_RATE_LIST],
                                [{PlayerId, NewBetTupleList} | Tmp];
                            true -> ?DEBUG("离开投注页面的玩家不需要重置投注信息，直接删除: ~p", [PlayerId]),Tmp
                        end
                    end,
                    [],
                    PlayerList
                ),
%%            ?DEBUG("player in bet before delete: ~p", [get_bet_player_list(ObjType)]),
            del_bet_players(ObjType),
            put({?MISSION_BET_PLAYER_LIST, ObjType}, NewPlayerBetList);
%%            ?DEBUG("player in bet after delete: ~p", [get_bet_player_list(ObjType)]);
        ?MISSION_TYPE_MISSION_HERO_PK_BOSS ->
            lists:foreach(
                fun({PlayerId, OldBetTupleList}) ->
                    del_bet_player(?MISSION_TYPE_MISSION_HERO_PK_BOSS, PlayerId),
                    case lists:member(PlayerId, mod_scene_player_manager:get_all_obj_scene_player_id()) of
                        %% 还在场景内的玩家，将其投注信息重置为0
                        true ->
                            ClearUpBetTupleList = [{Pos, 0} || {Pos, _} <- OldBetTupleList],
                            add_bet_player_list(?MISSION_TYPE_MISSION_HERO_PK_BOSS, {PlayerId, ClearUpBetTupleList});
                        false -> noop %% 已经离开场景的玩家，不重置
                    end
                end,
                get_bet_player_list(ObjType)
            ),
            ?DEBUG("cleanup: ~p", [get_bet_player_list(ObjType)])
    end.
%%    R.


del_bet_players(ObjType) ->
    put({?MISSION_BET_PLAYER_LIST, ObjType}, []).

%% ---------------------------------------- 2021-05-27 进入投注页面的玩家 end --------------------------------------------

