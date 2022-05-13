%%%%%-------------------------------------------------------------------
%%%%% @author
%%%%% @copyright (C) 2016, THYZ
%%%%% @doc            大乱斗
%%%%% @end
%%%%% Created : 14. 六月 2016 下午 3:34
%%%%%-------------------------------------------------------------------
-module(mod_mission_da_luan_dou).
%%-include("common.hrl").
%%%%-include("gen/table_db.hrl").
%%-include("gen/table_enum.hrl").
%%-include("scene.hrl").
%%-include("p_message.hrl").
%%-include("p_enum.hrl").
%%-include("msg.hrl").
%%-include("mission.hrl").
%%
%%-define(IS_NEED_FRESH, is_need_fresh).
%%-define(MSG_REFRESH_DALUANDOU_RANKING, refresh_da_luan_dou_ranking).
%%
%%-define(MSG_RANDOM_ADD_BUFF, random_add_buff).
%%
%%-define(ETS_DA_LUAN_DOU_DATA, ets_da_luan_dou_data).
%%-define(DA_LUAN_DOU_DATA_TABLE, da_luan_dou_data_table).
%%
%%-record(ets_da_luan_dou_data, {
%%    player_id,             %% 玩家ID
%%    node,                  %% 节点
%%    name,                  %% 玩家昵称
%%    score = 0,             %% 积分
%%    kill_num = 0,          %% 击杀数量
%%    continue_kill = 0,     %% 连击数量
%%    is_finish_continue_kill = 0, %% 是否完成连击任务
%%    is_robot = false,
%%    gu_wu_times = 0,       %% 鼓舞数量
%%    time = 0
%%}).
%%
%%-define(DICT_ROBOT_NUM, dict_robot_num).
%%-define(MAX_NUM, 10).
%%
%%%% API
%%-export([
%%    gu_wu/1,
%%    handle_gu_wu/1,
%%    give_award/4,
%%    handle_enter_mission/2,
%%    handle_init_mission/1,
%%    handle_balance/1,
%%    handle_player_death/3,
%%    handle_refresh_ranking/0,
%%    init_player_da_luan_dou_data/1
%%]).
%%
%%gu_wu(PlayerId) ->
%%    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
%%    mod_prop:assert_prop_num(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_INGOT, ?SD_DLD_GU_WU_PAY),
%%    case gen_server:call(SceneWorker, {?MSG_SCENE_DA_LUANDOU_GUWU, PlayerId}) of
%%        {ok, NewTimes} ->
%%            Tran = fun() ->
%%                mod_prop:decrease_player_prop(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_INGOT, ?SD_DLD_GU_WU_PAY, ?LOG_TYPE_MISSION_DALUANDOU)
%%                   end,
%%            db:do(Tran),
%%            NewTimes;
%%        {error, Reason} ->
%%            exit(Reason)
%%    end.
%%
%%handle_gu_wu(PlayerId) ->
%%    R = get_player_da_luan_dou_data(PlayerId),
%%    #ets_da_luan_dou_data{
%%        gu_wu_times = GuWuTimes
%%    } = R,
%%    MaxGuWuTimes = ?SD_DLD_MAX_GU_WU_TIMES,
%%    NewGuWuTimes = GuWuTimes + 1,
%%    ?ASSERT(NewGuWuTimes =< MaxGuWuTimes),
%%    NewR = R#ets_da_luan_dou_data{
%%        gu_wu_times = GuWuTimes + 1
%%    },
%%    update_player_da_luan_dou_data(NewR),
%%    Rate = (10000 + ?SD_DLD_GU_WU_EFFECT * NewGuWuTimes) / 10000,
%%    ?DEBUG("鼓舞:~p", [{Rate, NewGuWuTimes}]),
%%    ObjScenePlayer = ?GET_OBJ_SCENE_PLAYER(PlayerId),
%%    #obj_scene_actor{
%%        max_hp = MaxHp,
%%        attack = Attack,
%%        defense = Defense,
%%        grid_id = GridId
%%    } = ObjScenePlayer,
%%    NewObjScenePlayer = ObjScenePlayer#obj_scene_actor{
%%        max_hp = trunc(MaxHp * Rate),
%%        attack = trunc(Attack * Rate),
%%        defense = trunc(Defense * Rate)
%%    },
%%    NoticePlayerIdList = mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
%%    api_scene:notice_player_attr_change(NoticePlayerIdList, PlayerId, [{?P_MAX_HP, NewObjScenePlayer#obj_scene_actor.max_hp}]),
%%    ?UPDATE_OBJ_SCENE_PLAYER(NewObjScenePlayer),
%%    GuWuTimes + 1.
%%
%%
%%%% ----------------------------------
%%%% @doc 	刷新排行榜
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_refresh_ranking() ->
%%    case get(?IS_NEED_FRESH) of
%%        true ->
%%            put(?IS_NEED_FRESH, false),
%%            notice_ranking_update();
%%        _ ->
%%            noop
%%    end,
%%    mod_mission:send_msg_delay(?MSG_REFRESH_DALUANDOU_RANKING, 1500).
%%
%%%% ----------------------------------
%%%% @doc 	玩家死亡
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_player_death(PlayerId, _AttObjType, AttackPlayerId) ->
%%    IsBalance = mod_mission:is_balance(),
%%    if IsBalance == true ->
%%        noop;
%%        true ->
%%            put(?IS_NEED_FRESH, true),
%%%%            NeedContinueKill = 10,
%%            [NeedContinueKill, _ContinueKillAwardId] = ?SD_DLD_CONTINUE_KILL,
%%            DefR = get_player_da_luan_dou_data(PlayerId),
%%            if
%%                DefR#ets_da_luan_dou_data.continue_kill == 0 ->
%%                    noop;
%%                true ->
%%                    NewDefR = DefR#ets_da_luan_dou_data{
%%                        continue_kill = 0
%%                    },
%%                    update_player_da_luan_dou_data(NewDefR)
%%%%                            notice_da_luan_dou_info(PlayerId, NewDefR)
%%            end,
%%            AttackR = get_player_da_luan_dou_data(AttackPlayerId),
%%            #ets_da_luan_dou_data{
%%                is_finish_continue_kill = IsFinishContinueKill,
%%                continue_kill = ContinueKill,
%%                score = Score,
%%                kill_num = KillNum
%%            } = AttackR,
%%            NewScore =
%%                if ContinueKill >= 2 ->
%%                    Score + (min(ContinueKill, 5) - 1) * 2 + 1;
%%                    true ->
%%                        Score + 1
%%                end,
%%%%    ?DEBUG("~p~n", [{AttackPlayerId, NewScore, Score, ContinueKill, (min(ContinueKill, 5) - 1) * 2 + 1}]),
%%            NewContinueKill = ContinueKill + 1,
%%            NewIsFinishContinueKill =
%%                if IsFinishContinueKill == ?TRUE ->
%%                    IsFinishContinueKill;
%%                    true ->
%%                        if NewContinueKill >= NeedContinueKill ->
%%                            ?TRUE;
%%                            true ->
%%                                ?FALSE
%%                        end
%%                end,
%%            NewAttackR = AttackR#ets_da_luan_dou_data{
%%                is_finish_continue_kill = NewIsFinishContinueKill,
%%                continue_kill = ContinueKill + 1,
%%                score = NewScore,
%%                kill_num = KillNum + 1
%%            },
%%            update_player_da_luan_dou_data(NewAttackR)
%%%%                    notice_da_luan_dou_info(AttackPlayerId, NewAttackR)
%%    end.
%%
%%%% ----------------------------------
%%%% @doc 	初始化副本
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_init_mission(_ExtraDataList) ->
%%    Table = ets:new(?ETS_DA_LUAN_DOU_DATA, [set, public, {keypos, #ets_da_luan_dou_data.player_id}]),
%%    put(?DA_LUAN_DOU_DATA_TABLE, Table),
%%    put(?DICT_ROBOT_NUM, 0),
%%    put(?IS_NEED_FRESH, false),
%%    mod_mission:send_msg_delay(?MSG_REFRESH_DALUANDOU_RANKING, 1500).
%%
%%get_robot_num() ->
%%    get(?DICT_ROBOT_NUM).
%%
%%add_robot_num(AddNum) ->
%%    put(?DICT_ROBOT_NUM, get_robot_num() + AddNum).
%%
%%%% ----------------------------------
%%%% @doc 	进入副本
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_enter_mission(PlayerId, #scene_state{mission_id = _MissionId, mission_type = _MissionType}) ->
%%    init_player_da_luan_dou_data(PlayerId),
%%    put(?IS_NEED_FRESH, true),
%%    notice_ranking_update([PlayerId]),
%%    BalanceTime = mod_mission:get_mission_balance_time_ms(),
%%    StartTime = mod_mission:get_mission_start_time_ms(),
%%    IsBalance = mod_mission:is_balance(),
%%    Now = util_time:milli_timestamp(),
%%    LiveTime = max(0, (BalanceTime - Now) + 10000),
%%    StartHeartTime = max(0, (StartTime - Now)),
%%    ?DEBUG("进入副本:~p~n", [{BalanceTime, StartTime, {LiveTime, StartHeartTime}}]),
%%    if IsBalance == false ->
%%        RobotNum = get_robot_num(),
%%        if RobotNum < ?MAX_NUM ->
%%            LeftNum = ?MAX_NUM - RobotNum,
%%%%            RandomAddNum = 1,
%%            RandomAddNum = util_random:random_number(1, min(4, LeftNum)),
%%            util:run(
%%                fun() ->
%%                    ?TRY_CATCH(mod_scene_robot_manager:create_robot(PlayerId, util_random:random_number(1, 9999), StartHeartTime, LiveTime, util_random:random_number(1,3) / 10, ""))
%%                end,
%%                RandomAddNum
%%            ),
%%            add_robot_num(RandomAddNum);
%%            true ->
%%                noop
%%        end;
%%        true ->
%%            noop
%%    end.
%%
%%%% ----------------------------------
%%%% @doc 	副本结算
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_balance(_) ->
%%    ?INFO("大乱斗结算"),
%%    TableName = get(?DA_LUAN_DOU_DATA_TABLE),
%%    L = ets:tab2list(TableName),
%%    RankingList = get_ranking_list(),
%%    AwardRangeList = ?SD_DLD_REWARD_RANGE,
%%    [NeedKillNum, KillAwardId] = ?SD_DLD_KILL_REWARD,
%%    [NeedScore, ScoreAwardId] = ?SD_DLD_SCORE_REWARD,
%%    [NeedContinueKill, ContinueKillAwardId] = ?SD_DLD_CONTINUE_KILL,
%%%%    #t_mission_da_luan_dou{
%%%%        award_range_list = AwardRangeList,
%%%%        kill_award_list = [NeedKillNum, KillAwardId],
%%%%        score_award_list = [NeedScore, ScoreAwardId],
%%%%        continue_kill_list = [NeedContinueKill, ContinueKillAwardId]
%%%%    } = get_t_mission(1),
%%    lists:foreach(
%%        fun(R) ->
%%            #ets_da_luan_dou_data{
%%                player_id = PlayerId,
%%                score = Score,
%%                continue_kill = IsFinishContinueKill,
%%                kill_num = KillNum,
%%                node = Node,
%%                is_robot = IsRobot
%%            } = R,
%%            if
%%                IsRobot == false ->
%%
%%                    SelfRanking = case lists:keyfind(PlayerId, #daluandouranking.player_id, RankingList) of
%%                                      false ->
%%                                          0;
%%                                      Rank ->
%%                                          Rank#daluandouranking.ranking
%%                                  end,
%%                    AwardId = case util_list:get_value_from_range_list(SelfRanking, AwardRangeList) of
%%                                  ?UNDEFINED ->
%%                                      0;
%%                                  AwardId_ ->
%%                                      AwardId_
%%                              end,
%%                    RealKillAwardId = ?IF(KillNum >= NeedKillNum, KillAwardId, 0),
%%                    RealScoreAwardId = ?IF(Score >= NeedScore, ScoreAwardId, 0),
%%                    RealContinueKillAwardId = ?IF(IsFinishContinueKill >= NeedContinueKill, ContinueKillAwardId, 0),
%%
%%                    RankingAwardItemList = mod_award:decode_award(AwardId),
%%                    LimitAwardItemList =
%%                        mod_award:decode_award(RealKillAwardId)
%%                        ++ mod_award:decode_award(RealScoreAwardId)
%%                        ++ mod_award:decode_award(RealContinueKillAwardId),
%%                    ?INFO("结算玩家：~p~n", [{PlayerId, SelfRanking, RankingAwardItemList, LimitAwardItemList}]),
%%                    rpc:cast(Node, ?MODULE, give_award, [PlayerId, SelfRanking, RankingAwardItemList, LimitAwardItemList]);
%%                true ->
%%                    noop
%%            end
%%        end,
%%        L
%%    ),
%%    scene_worker:stop(self(), 20 * ?SECOND_MS).
%%
%%%% ----------------------------------
%%%% @doc 	给奖励
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%give_award(PlayerId, SelfRanking, RankingAwardItemList, LimitAwardItemList) ->
%%    ?INFO("大乱斗给奖励:~p", [{PlayerId, SelfRanking, RankingAwardItemList, LimitAwardItemList}]),
%%    if RankingAwardItemList == [] ->
%%        noop;
%%        true ->
%%            mod_mail:add_mail_param_item_list(PlayerId, ?MAIL_DALUANDOU_RANKING, RankingAwardItemList, [SelfRanking], ?LOG_TYPE_MISSION_DALUANDOU)
%%    end,
%%    if LimitAwardItemList == [] ->
%%        noop;
%%        true ->
%%            mod_mail:add_mail_item_list(PlayerId, ?MAIL_DALUANDOU_LIMIT, LimitAwardItemList, ?LOG_TYPE_MISSION_DALUANDOU)
%%    end.
%%
%%%% ----------------------------------
%%%% @doc 	通知玩家大乱斗信息
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%notice_da_luan_dou_info(R) ->
%%    api_mission:notice_da_luan_dou_info(
%%        R#ets_da_luan_dou_data.player_id,
%%        R#ets_da_luan_dou_data.kill_num,
%%        R#ets_da_luan_dou_data.continue_kill,
%%        R#ets_da_luan_dou_data.is_finish_continue_kill,
%%        R#ets_da_luan_dou_data.gu_wu_times
%%    ).
%%
%%
%%%% ----------------------------------
%%%% @doc 	通知排行榜更新
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%notice_ranking_update() ->
%%    ObjScenePlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
%%    notice_ranking_update(ObjScenePlayerIdList).
%%notice_ranking_update(ObjScenePlayerIdList) ->
%%    RankingList = get_ranking_list(),
%%    lists:foreach(
%%        fun(PlayerId) ->
%%            EtsRankingData = get_player_da_luan_dou_data(PlayerId),
%%            #ets_da_luan_dou_data{
%%                score = Score
%%            } = EtsRankingData,
%%            SelfRanking = case lists:keyfind(PlayerId, #daluandouranking.player_id, RankingList) of
%%                              false ->
%%                                  0;
%%                              R ->
%%                                  R#daluandouranking.ranking
%%                          end,
%%            TenRankingList = lists:sublist(RankingList, 10),
%%%%            ?DEBUG("TenRankingList:~p", [TenRankingList]),
%%            Out = proto:encode(
%%                #m_mission_notice_da_luan_dou_ranking_toc{
%%                    self_ranking = SelfRanking,
%%                    self_value = Score,
%%                    ranking_list = TenRankingList
%%                }
%%            ),
%%            mod_socket:send(PlayerId, Out)
%%        end,
%%        ObjScenePlayerIdList
%%    ).
%%
%%get_ranking_list() ->
%%    TableName = get(?DA_LUAN_DOU_DATA_TABLE),
%%    L = ets:tab2list(TableName),
%%
%%    F = fun(A, B) ->
%%        if
%%            A#ets_da_luan_dou_data.score > B#ets_da_luan_dou_data.score ->
%%                true;
%%            A#ets_da_luan_dou_data.score == B#ets_da_luan_dou_data.score ->
%%                A#ets_da_luan_dou_data.time < B#ets_da_luan_dou_data.time;
%%            true ->
%%                false
%%        end
%%        end,
%%    L1 = lists:sort(F, L),
%%%%    L2 = lists:sublist(L1, 10),
%%%%    ?DEBUG("~p~n", [L2]),
%%    {_, RankingList} =
%%        lists:foldl(
%%            fun(E, {N, Tmp}) ->
%%                {
%%                    N + 1,
%%                    [
%%                        #daluandouranking{
%%                            ranking = N,
%%                            player_id = E#ets_da_luan_dou_data.player_id,
%%                            name = E#ets_da_luan_dou_data.name,
%%                            value = E#ets_da_luan_dou_data.score
%%                        }
%%%%                        {
%%%%                            N,
%%%%                            E#ets_da_luan_dou_data.player_id,
%%%%                            E#ets_da_luan_dou_data.name,
%%%%                            E#ets_da_luan_dou_data.score
%%%%                        }
%%                        |
%%                        Tmp
%%                    ]
%%                }
%%            end,
%%            {1, []},
%%            L1
%%        ),
%%    lists:sort(RankingList).
%%
%%
%%get_player_da_luan_dou_data(PlayerId) ->
%%    Table = get(?DA_LUAN_DOU_DATA_TABLE),
%%    case ets:lookup(Table, PlayerId) of
%%        [] ->
%%            null;
%%        [R] ->
%%            R
%%    end.
%%
%%update_player_da_luan_dou_data(R) ->
%%    Table = get(?DA_LUAN_DOU_DATA_TABLE),
%%    ets:insert(Table, R),
%%    notice_da_luan_dou_info(R).
%%
%%init_player_da_luan_dou_data(PlayerId) ->
%%    Table = get(?DA_LUAN_DOU_DATA_TABLE),
%%    ObjScenePlayer = ?GET_OBJ_SCENE_PLAYER(PlayerId),
%%    NewR =
%%        case ets:lookup(Table, PlayerId) of
%%            [] ->
%%                #ets_da_luan_dou_data{
%%                    player_id = PlayerId,
%%                    name = ObjScenePlayer#obj_scene_actor.nickname,
%%                    node = ObjScenePlayer#obj_scene_actor.client_node,
%%                    score = 0,
%%                    kill_num = 0,          %% 击杀数量
%%                    time = util_time:milli_timestamp(),
%%                    continue_kill = 0,     %% 连击数量
%%                    is_finish_continue_kill = ?FALSE,
%%                    is_robot = ObjScenePlayer#obj_scene_actor.is_robot,
%%                    gu_wu_times = 0        %% 鼓舞数量
%%                };
%%            [R] ->
%%                R#ets_da_luan_dou_data{
%%                    continue_kill = 0
%%                }
%%        end,
%%    ets:insert(Table, NewR),
%%    #ets_da_luan_dou_data{
%%        gu_wu_times = _GuWuTimes
%%    } = NewR,
%%    notice_da_luan_dou_info(NewR).
