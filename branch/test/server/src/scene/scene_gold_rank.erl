%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         金币排行榜
%%% @end
%%% Created : 07. 8月 2021 上午 09:47:58
%%%-------------------------------------------------------------------
-module(scene_gold_rank).
-author("Administrator").

-include("scene.hrl").
-include("gen/table_enum.hrl").
-include("p_message.hrl").
-include("gen/table_db.hrl").

%% API
-export([
    handle_notice_gold_rank/0
]).

%%-define(SCENE_GOLD_RANK_NOTICE,scene_gold_rank_notice).

%% @doc 通知金币排行榜
handle_notice_gold_rank() ->
    PlayerAwardPropId = get(?DICT_SCENE_AWARD_PROP_ID),
%%    #t_scene{
%%        mana_attack_list = [PropId, _]
%%    } = mod_scene:get_t_scene(get(?DICT_SCENE_ID)),
    {{_PlayerNum, PlayerIdList}, {_RobotNum, RobotIdList}} = mod_scene_player_manager:get_player_info(),
    if
        PlayerIdList =:= [] ->
            noop;
        true ->
            PlayerList = lists:map(
                fun(PlayerId) ->
%%                    GoldNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_GOLD),
%%                    MoneyNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_RMB),
                    PropNum = mod_prop:get_player_prop_num(PlayerId, PlayerAwardPropId),
                    #obj_scene_actor{
                        sex = Sex,
                        nickname = Name,
                        gold_rank_event_list = GoldRankEventList,
                        level = Level,
                        vip_level = VipLevel,
                        surface = #surface{
                            head_id = HeadId,
                            head_frame_id = HeadFrameId
                        }
                    } = ?GET_OBJ_SCENE_PLAYER(PlayerId),

                    {PropNum, {PlayerId, Sex, Name, HeadId, VipLevel, Level, HeadFrameId}, GoldRankEventList}
                end, PlayerIdList
            ),
            RobotList =
                lists:map(
                    fun(RobotId) ->
                        #obj_scene_actor{
                            sex = Sex,
                            nickname = Name,
                            gold_rank_event_list = GoldRankEventList,
                            level = Level,
                            vip_level = VipLevel,
                            surface = #surface{
                                head_id = HeadId,
                                head_frame_id = HeadFrameId
                            },
                            robot_data = #robot_data{
                                robot_item_list = ItemList
                            }
                        } = ?GET_OBJ_SCENE_PLAYER(RobotId),
                        PropNum = util_list:opt(PlayerAwardPropId, ItemList, 0),
%%                        MoneyNum = util_list:opt(?ITEM_RMB,ItemList,0),
                        {PropNum, {RobotId, Sex, Name, HeadId, VipLevel, Level, HeadFrameId}, GoldRankEventList}
                    end, RobotIdList
                ),
            List = PlayerList ++ RobotList,
            SortList =
                lists:sort(
                    fun(A, B) ->
%%                        {AGoldNum, AMoneyNum, _, _} = A,
%%                        {BGoldNum, BMoneyNum, _, _} = B,
                        {APropNum, _, _} = A,
                        {BPropNum, _, _} = B,
                        GoldSortFun =
                            fun() ->
                                if
                                    APropNum > BPropNum ->
                                        true;
                                    APropNum == BPropNum ->
                                        if
                                            APropNum >= BPropNum ->
                                                true;
                                            true ->
                                                false
                                        end;
                                    true ->
                                        false
                                end
                            end,
%%                        MoneySortFun =
%%                            fun() ->
%%                                if
%%                                    AMoneyNum > BMoneyNum ->
%%                                        true;
%%                                    AMoneyNum == BMoneyNum ->
%%                                        if
%%                                            AGoldNum >= BGoldNum ->
%%                                                true;
%%                                            true ->
%%                                                false
%%                                        end;
%%                                    true ->
%%                                        false
%%                                end
%%                            end,
%%                        case PropId of
%%                            ?ITEM_GOLD ->
                        GoldSortFun()
%%                            ?ITEM_RMB ->
%%                                MoneySortFun()
%%                        end
                    end, List
                ),
            {_, L} = lists:foldl(
                fun({PropNum, {PlayerId, Sex, Name, HeadId, VipLevel, Level, HeadFrameId}, GoldRankEventList}, {TmpRank, TmpList}) ->
                    {TmpRank + 1, [{TmpRank, PropNum, PlayerId, Sex, Name, HeadId, VipLevel, Level, HeadFrameId, GoldRankEventList} | TmpList]}
                end,
                {1, []}, SortList
            ),
            PbList = [
                #goldranking{
                    ranking = Rank,
                    gold_value = PropNum,
                    money_value = 0,
                    model_head_figure = #modelheadfigure{
                        player_id = PlayerId,
                        sex = Sex,
                        nickname = Name,
                        head_id = HeadId,
                        vip_level = VipLevel,
                        level = Level,
                        head_frame_id = HeadFrameId
                    },
                    event_list = [#'goldranking.goldrankingevent'{event_id = EventId, time = EventTime} || {EventId, EventTime} <- GoldRankEventList]
                }
                || {Rank, PropNum, PlayerId, Sex, Name, HeadId, VipLevel, Level, HeadFrameId, GoldRankEventList} <- lists:keysort(4, L)
            ],
            Out = proto:encode(#m_scene_get_gold_ranking_toc{gold_ranking_list = PbList}),
            mod_socket:send_to_player_list(PlayerIdList, Out)
    end.