%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 9月 2021 上午 11:42:23
%%%-------------------------------------------------------------------
-module(api_match_scene).
-author("Administrator").

-include("p_message.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("gen/db.hrl").

%% API
-export([
    get_info/2,                             %% 获得信息
    match/2,
    cancel_match/2
]).

-export([
    notice_rank/2,
    notice_match_team_change/3,
    notice_match_fail/2,
    notice_time/3,
    notice_result/2,
    pack_rank_out/1
]).

%% @doc 获得信息
get_info(
    #m_match_scene_get_info_tos{},
    #conn{player_id = PlayerId}
) ->
    DbList = mod_match_scene:get_info(),
    Out = proto:encode(#m_match_scene_get_info_toc{
        info_list = pack_pb_match_scene_info_list(DbList)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 匹配
match(
    #m_match_scene_match_tos{id = Id},
    #conn{player_id = PlayerId}
) ->
    Out =
        case catch mod_match_scene:match(PlayerId, Id) of
            {ok, TeamPlayerCount} ->
                proto:encode(#m_match_scene_match_toc{
                    result = ?P_SUCCESS,
                    id = Id,
                    num = TeamPlayerCount
                });
            {'EXIT', Err} ->
                proto:encode(#m_match_scene_match_toc{
                    result = api_common:api_error_to_enum(Err)
                })
        end,
    mod_socket:send(PlayerId, Out).

%% @doc 取消匹配
cancel_match(
    #m_match_scene_cancel_match_tos{},
    #conn{player_id = PlayerId}
) ->
    Out = proto:encode(#m_match_scene_cancel_match_toc{
        result = api_common:api_error_to_enum(catch mod_match_scene:cancel_match(PlayerId))
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 匹配队伍变更通知
notice_match_team_change(PlayerId, MatchId, PlayerCount) ->
    Out = proto:encode(#m_match_scene_notice_match_num_change_toc{
        id = MatchId,
        num = PlayerCount
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 匹配失败
notice_match_fail(PlayerId, MatchId) ->
    Out = proto:encode(#m_match_scene_notice_match_fail_toc{
        id = MatchId
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知排行榜
notice_rank(PlayerId, Out) when is_integer(PlayerId) ->
    mod_socket:send(PlayerId, Out);
notice_rank(PlayerIdList, Out) ->
    mod_socket:send_to_player_list(PlayerIdList, Out).

pack_rank_out(List) ->
    RankList = [#matchscenerank{rank = Rank, score = Score, zi_dan = ZiDan, model_head_figure = ModelHeadFigure} || {Rank, _PlayerId, Score, ZiDan, ModelHeadFigure} <- List],
    proto:encode(#m_match_scene_notice_rank_toc{rank_list = RankList}).

%% @doc 通知时间
notice_time(PlayerId, StartTime, EndTime) ->
    Out = proto:encode(#m_match_scene_notice_time_toc{
        start_time = StartTime,
        end_time = EndTime
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知结果
notice_result(PlayerIdList, List) ->
    Out = proto:encode(#m_match_scene_notice_result_toc{
        result_list = pack_pb_result_list(List)
    }),
    mod_socket:send_to_player_list(PlayerIdList, Out).

pack_pb_result_list(List) ->
    [pack_pb_result(Data) || Data <- List].
pack_pb_result(Data) ->
    {Rank, PropList, ModelHeadFigure} = Data,
    #'m_match_scene_notice_result_toc.result'{rank = Rank, prop_list = api_prop:pack_prop_list(PropList), model_head_figure = ModelHeadFigure}.

pack_pb_match_scene_info_list(DbList) ->
    [
        begin
            case Data of
                {DbMatchScene,Nickname} ->
                    #db_match_scene_data{
                        id = Id,
                        player_id = PlayerId,
                        score = Score,
                        award = Award
                    } = DbMatchScene,
                    if
                        PlayerId > 0 ->
                            #'m_match_scene_get_info_toc.info'{
                                id = Id,
                                award = Award,
                                name = util:to_binary(Nickname),
                                score = Score
                            };
                        true ->
                            #'m_match_scene_get_info_toc.info'{
                                id = Id,
                                award = Award
                            }
                    end;
                DbMatchScene ->
                    #db_match_scene_data{
                        id = Id,
                        player_id = PlayerId,
                        score = Score,
                        award = Award
                    } = DbMatchScene,
                    if
                        PlayerId > 0 ->
                            #db_player{
                                nickname = Nickname
                            } = mod_player:get_player(PlayerId),
                            #'m_match_scene_get_info_toc.info'{
                                id = Id,
                                award = Award,
                                name = util:to_binary(Nickname),
                                score = Score
                            };
                        true ->
                            #'m_match_scene_get_info_toc.info'{
                                id = Id,
                                award = Award
                            }
                    end
            end
        end
        || Data <- DbList
    ].