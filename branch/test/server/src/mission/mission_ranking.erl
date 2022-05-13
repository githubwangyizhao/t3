%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            副本排行榜
%%% @end
%%% Created : 14. 六月 2016 下午 3:34
%%%-------------------------------------------------------------------
-module(mission_ranking).

%% API
-export([
    init/3,
    init/4,
    clean_ranking/3,            %% 清除副本类型、副本id、唯一id的所有排行数据
    remove_member_list/2,       %% 移除一个玩家
    clear_mission_rank/2,       %% 清除副本类型与副本id的所有排行数据
    notice_ranking/4,           %% 通知排行数据
    get_ranking_list/3,         %% 获得排名列表
    update_hurt/4,              %% 更新玩家伤害
    handle_refresh_ranking/3,
    is_next_click_refresh/4
]).

-export([
    init/0,
    init/1,
    clean_ranking/0,
    remove_member_list/1,
    notice_ranking/1,
    get_self_ranking_info/2,
    get_ranking_list/0,
    get_ranking_hurt_list/0,
    update_hurt/3,
    handle_refresh_ranking/0,
    is_next_click_refresh/1,
    get_db_mission_ranking_list/3
]).
-include("p_message.hrl").
-include("mission.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("scene.hrl").
-include("common.hrl").
-define(REFRESH_RANKING_MS, 1000).%% 排行榜刷新时间

%% 伤害数据
-record(hurt_data, {
    player_id,
    name,
    hurt,
    time
}).

init(MissionType, MissionId, Id) ->
    init(MissionType, MissionId, Id, true).
init(MissionType, MissionId, Id, IsNotice) ->
    is_next_click_refresh(MissionType, MissionId, Id, false),
    if IsNotice ->
        mod_mission:send_msg_delay({refresh_ranking, MissionType, MissionId, Id}, ?REFRESH_RANKING_MS);
        true ->
            noop
    end,
    put({MissionType, MissionId, Id}, 0),
    update_hurt_list(MissionType, MissionId, Id).

init() ->
    init(true).
init(IsNotice) ->
    is_next_click_refresh(false),
    if IsNotice ->
        mod_mission:send_msg_delay(refresh_ranking, ?REFRESH_RANKING_MS);
        true ->
            noop
    end,
    update_hurt_list([]).

%% ----------------------------------
%% @doc 	hurt list
%% @throws 	none
%% @end
%% ----------------------------------
clean_ranking(MissionType, MissionId, Id) ->
    DbRankL = get_db_mission_ranking_list(MissionType, MissionId, Id),
    ?INFO("清除副本排行榜数据：~p~n", [{MissionType, MissionId, DbRankL}]),
    Tran =
        fun() ->
            [db:delete(DbRank) || DbRank <- DbRankL]
        end,
    db:do(Tran).
%%    is_next_click_refresh(MissionType, MissionId, Id, true).

clean_ranking() ->
    put(hurt_list, []),
    is_next_click_refresh(true).

%% 获得伤害列表
get_hurt_list() ->
    get(hurt_list).

update_hurt_list(MissionType, MissionId, Id) ->
    is_next_click_refresh(MissionType, MissionId, Id, true).
update_hurt_list(HurtList) ->
    put(hurt_list, HurtList),
    is_next_click_refresh(true).
%% @fun 移除一个玩家
remove_member_list(PlayerId, Id) ->
    MissionType = get(?DICT_MISSION_TYPE),
    MissionId = get(?DICT_MISSION_ID),
    case get_db_mission_ranking(MissionType, MissionId, Id, PlayerId) of
        DbRank when is_record(DbRank, db_mission_ranking) ->
            Tran =
                fun() ->
                    db:delete(DbRank)
                end,
            db:do(Tran);
        _ ->
            noop
    end,
    anew_rank(MissionType, MissionId, Id),
    update_hurt_list(MissionType, MissionId, Id).

remove_member_list(PlayerId) ->
    HurtList = lists:keydelete(PlayerId, #hurt_data.player_id, get_hurt_list()),
    SortHurtList = util_list:rkeysort(#hurt_data.hurt, HurtList),
    update_hurt_list(SortHurtList).

%% 清除副本类型与副本id的所有排行数据
clear_mission_rank(MissionType, MissionId) ->
    Tran =
        fun() ->
            [db:delete(DbRank) || DbRank <- get_db_mission_ranking_by_mission_type_and_mission_id(MissionType, MissionId)]
        end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	设置下一个心跳是否刷新排行榜
%% @throws 	none
%% @end
%% ----------------------------------
is_next_click_refresh(MissionType, MissionId, Id, Bool) ->
    put({is_need_refresh, MissionType, MissionId, Id}, Bool).

is_need_refresh(MissionType, MissionId, Id) ->
    get({is_need_refresh, MissionType, MissionId, Id}).

is_next_click_refresh(Bool) ->
    put(is_need_refresh, Bool).

is_need_refresh() ->
    get(is_need_refresh).

%% ----------------------------------
%% @doc 	定时通知刷新排行榜
%% @throws 	none
%% @end
%% ----------------------------------
handle_refresh_ranking(MissionType, MissionId, Id) ->
    handle_refresh_ranking_1(MissionType, MissionId, Id),
    mod_mission:send_msg_delay({refresh_ranking, MissionType, MissionId, Id}, ?REFRESH_RANKING_MS).
handle_refresh_ranking_1(MissionType, MissionId, Id) ->
    case is_need_refresh(MissionType, MissionId, Id) of
        true ->
            mission_ranking:notice_ranking(mod_scene_player_manager:get_all_obj_scene_player_id(), MissionType, MissionId, Id),
            is_next_click_refresh(MissionType, MissionId, Id, false);
        false ->
            noop
    end.

handle_refresh_ranking() ->
    handle_refresh_ranking_1(),
    mod_mission:send_msg_delay(refresh_ranking, ?REFRESH_RANKING_MS).
handle_refresh_ranking_1() ->
    case is_need_refresh() of
        true ->
            mission_ranking:notice_ranking(mod_scene_player_manager:get_all_obj_scene_player_id()),
            is_next_click_refresh(false);
        false ->
            noop
    end.

%% ----------------------------------
%% @doc 	更新玩家伤害
%% @throws 	none
%% @end
%% ----------------------------------
%% Id是根据各个副本处理的唯一id
update_hurt(Id, PlayerId, Name, Hurt) ->
%%    ?DEBUG("更新玩家伤害~p~n", [{PlayerId, Name, Hurt}]),
    MissionType = get(?DICT_MISSION_TYPE),
    MissionId = get(?DICT_MISSION_ID),
    DbRank = get_db_mission_ranking_init(MissionType, MissionId, Id, PlayerId, util:to_list(Name)),
    #db_mission_ranking{
        hurt = OldHurt,
        rank_id = RankId
    } = DbRank,
    NewHurt = OldHurt + Hurt,
    NewRankId =
        if
            RankId == 0 ->
                get({MissionType, MissionId, Id}) + 1;
            true ->
                RankId
        end,
    Tran =
        fun() ->
            calc_rank(NewRankId, NewHurt, DbRank, MissionType, MissionId, Id),
            Leng = length(get_db_mission_ranking_list(MissionType, MissionId, Id)),
            put({MissionType, MissionId, Id}, Leng)
        end,
    db:do(Tran),
    update_hurt_list(MissionType, MissionId, Id).

calc_rank(Rank, Hurt, DbRank, MissionType, MissionId, Id) ->
    if
        Rank == 1 ->
            db:write(DbRank#db_mission_ranking{rank_id = Rank, hurt = Hurt, time = util_time:timestamp()});
        true ->
            LastRank = Rank - 1,
            case get_db_mission_ranking_by_rank_id(MissionType, MissionId, Id, LastRank) of
                [DbLastPlayer] ->
                    if
                        Hurt > DbLastPlayer#db_mission_ranking.hurt ->
                            db:write(DbLastPlayer#db_mission_ranking{rank_id = Rank}),
                            calc_rank(LastRank, Hurt, DbRank, MissionType, MissionId, Id);
                        true ->
                            db:write(DbRank#db_mission_ranking{rank_id = Rank, hurt = Hurt, time = util_time:timestamp()})
                    end;
                [] ->
                    db:write(DbRank#db_mission_ranking{hurt = Hurt, time = util_time:timestamp()}),
                    anew_rank(MissionType, MissionId, Id);
                R ->
                    ?ERROR("玩家数据进入副本排行榜数据错误 rank :~p  data ~p", [{MissionType, MissionId, Id}, R]),
                    db:write(DbRank#db_mission_ranking{hurt = Hurt, time = util_time:timestamp()}),
                    anew_rank(MissionType, MissionId, Id)
            end
    end.

%% 重新排名
anew_rank(MissionType, MissionId, Id) ->
    RankL = get_db_mission_ranking_list(MissionType, MissionId, Id),
    RankList = util_list:rSortKeyList([#db_mission_ranking.hurt, {false, #db_mission_ranking.time}], RankL),
    lists:foldl(
        fun(DbRank, RankId) ->
            db:write(DbRank#db_mission_ranking{rank_id = RankId}),
            RankId + 1
        end, 1, RankList
    ).

update_hurt(PlayerId, Name, Hurt) ->
%%    ?DEBUG("更新玩家伤害~p~n", [{PlayerId, Name, Hurt}]),
    HurtList = get_hurt_list(),
    NewHurtList =
        case lists:keytake(PlayerId, #hurt_data.player_id, HurtList) of
            {value, HurtData = #hurt_data{hurt = OldHurt}, Left} ->
                [HurtData#hurt_data{hurt = OldHurt + Hurt, time = util_time:milli_timestamp()} | Left];
            false ->
%%                Name =
%%                    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%                        ?UNDEFINED ->
%%                            "";
%%                        ObjScenePlayer ->
%%                            ObjScenePlayer#obj_scene_actor.nickname
%%                    end,
                [#hurt_data{player_id = PlayerId, name = Name, hurt = Hurt, time = util_time:milli_timestamp()} | HurtList]
        end,
    update_hurt_list(NewHurtList).

%% 通知排行数据
notice_ranking(PlayerIdList, MissionType, MissionId, Id) ->
    if
        PlayerIdList == [] ->
            noop;
        true ->
            RankingL = get_db_mission_ranking_list(MissionType, MissionId, Id),
            RankingList = util_list:rSortKeyList([{false, #db_mission_ranking.rank_id}], RankingL),
            FiveRankingL = lists:sublist(RankingList, 5),
            FiveRankingList = [#hurtranking{ranking = RankId, player_id = PlayerId1, player_name = list_to_binary(Name), hurt = Hurt} || #db_mission_ranking{rank_id = RankId, player_id = PlayerId1, nickname = Name, hurt = Hurt} <- FiveRankingL],
            lists:foreach(
                fun(PlayerId) ->
                    {SelfRanking, SelfHurt} =
                        case lists:keyfind(PlayerId, #db_mission_ranking.player_id, RankingList) of
                            R when is_record(R, db_mission_ranking) ->
                                {
                                    R#db_mission_ranking.rank_id,
                                    R#db_mission_ranking.hurt
                                };
                            _ ->
                                {0, 0}
                        end,
%%                    ?DEBUG("FiveRankingList:~p~n", [{FiveRankingList, SelfHurt}]),
                    Out = proto:encode(#m_mission_notice_mission_ranking_toc{
                        self_hurt = SelfHurt,
                        self_rank = SelfRanking,
                        hurt_ranking_list = FiveRankingList,
                        mission_type = get(?DICT_MISSION_TYPE)
                    }),
                    mod_socket:send(PlayerId, Out)
                end,
                PlayerIdList
            )
    end.

notice_ranking(PlayerIdList) ->
    if
        PlayerIdList == [] ->
            noop;
        true ->
            RankingList = get_ranking_list(),
            lists:foreach(
                fun(PlayerId) ->
                    {SelfRanking, SelfHurt} =
                        case lists:keyfind(PlayerId, #hurtranking.player_id, RankingList) of
                            false ->
                                {0, 0};
                            R ->
                                {
                                    R#hurtranking.ranking,
                                    R#hurtranking.hurt
                                }
                        end,
                    FiveRankingList = lists:sublist(RankingList, 5),
%%                    ?DEBUG("FiveRankingList:~p~n", [{FiveRankingList, SelfHurt}]),
                    Out = proto:encode(#m_mission_notice_mission_ranking_toc{
                        self_hurt = SelfHurt,
                        self_rank = SelfRanking,
                        hurt_ranking_list = FiveRankingList,
                        mission_type = get(?DICT_MISSION_TYPE)
                    }),
                    mod_socket:send(PlayerId, Out)
                end,
                PlayerIdList
            )
    end.

get_self_ranking_info(PlayerId, RankingList) ->
    case lists:keyfind(PlayerId, #hurtranking.player_id, RankingList) of
        false ->
            {999, 0};
        R ->
            {
                R#hurtranking.ranking,
                R#hurtranking.hurt
            }
    end.

%% @fun 伤害列表
get_ranking_hurt_list() ->
    [{HurtData#hurt_data.player_id, HurtData#hurt_data.hurt} || HurtData <- get_hurt_list()].

%% 获得排名列表
get_ranking_list(MissionType, MissionId, Id) ->
    HurtList = get_db_mission_ranking_list(MissionType, MissionId, Id),
    [#hurtranking{ranking = RankId, player_id = PlayerId, player_name = Name, hurt = Hurt} || #db_mission_ranking{rank_id = RankId, player_id = PlayerId, nickname = Name, hurt = Hurt} <- HurtList].

get_ranking_list() ->
    HurtList = get_hurt_list(),
    SortFun =
        fun(A, B) ->
            if
                A#hurt_data.hurt > B#hurt_data.hurt ->
                    true;
                A#hurt_data.hurt =:= B#hurt_data.hurt ->
                    if
                        A#hurt_data.time < B#hurt_data.time ->
                            true;
                        true ->
                            false
                    end;
                true ->
                    false
            end
        end,
    HurtList1 = lists:sort(SortFun, HurtList),
%%    util_list:rkeysort(#hurt_data.hurt, HurtList),
    {_, RankingList} =
        lists:foldl(
            fun(#hurt_data{player_id = ThisPlayerId, name = ThisName, hurt = ThisHurt}, {N, Tmp}) ->
                {
                    N + 1,
                    [
                        #hurtranking{
                            ranking = N,
                            player_id = ThisPlayerId,
                            player_name = list_to_binary(ThisName),
                            hurt = ThisHurt
                        }
                        |
                        Tmp
                    ]
                }
            end,
            {1, []},
            HurtList1
        ),
    lists:sort(RankingList).

%% ============================================================= 数据模板 ==========================================
%% 获得副本玩家伤害数据
get_db_mission_ranking(MissionType, MissionId, Id, PlayerId) ->
    db:read(#key_mission_ranking{mission_type = MissionType, mission_id = MissionId, id = Id, player_id = PlayerId}).

%% 获得副本玩家伤害数据   并初始化
get_db_mission_ranking_init(MissionType, MissionId, Id, PlayerId, Name) ->
    case get_db_mission_ranking(MissionType, MissionId, Id, PlayerId) of
        DbRank when is_record(DbRank, db_mission_ranking) ->
            DbRank;
        _ ->
            #db_mission_ranking{mission_type = MissionType, mission_id = MissionId, id = Id, player_id = PlayerId, nickname = Name}
    end.

get_db_mission_ranking_by_mission_type_and_mission_id(MissionType, MissionId) ->
    db:select(?MISSION_RANKING, [{#db_mission_ranking{mission_type = MissionType, mission_id = MissionId, _ = '_'}, [], ['$_']}]).
get_db_mission_ranking_list(MissionType, MissionId, Id) ->
    db_index:get_rows(#idx_mission_ranking_1{mission_type = MissionType, mission_id = MissionId, id = Id}).
get_db_mission_ranking_by_rank_id(MissionType, MissionId, Id, RankId) ->
    db_index:get_rows(#idx_mission_ranking_by_rank_id{mission_type = MissionType, mission_id = MissionId, id = Id, rank_id = RankId}).
