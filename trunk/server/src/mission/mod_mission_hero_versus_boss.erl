%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 7月 2021 下午 07:25:19
%%%-------------------------------------------------------------------
-module(mod_mission_hero_versus_boss).
-author("Administrator").

-include("hero_versus_boss.hrl").
-include("msg.hrl").
-include("error.hrl").
-include("scene.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("mission.hrl").
-include("p_message.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("guess_boss.hrl").
-include("scene_boss_pos.hrl").
-include("client.hrl").
-include("one_on_one.hrl").

%% API
-export([
    open_mission/0,

    create_scene_obj/1,

    handle_init_mission/1,

    handle_round/1,
    handle_player_enter_mission/1,
    handle_leave_mission/1,

    handle_monster_enter_scene/1,
    set_hero_versus_boss_pos/3,
    handle_hero_enter_mission/0,
    handle_monster_enter_mission/0
]).

open_mission() ->
    MissionType = ?MISSION_TYPE_MISSION_HERO_PK_BOSS,
    MissionId = 1,
    SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
    ?DEBUG("hero_versus_boss: ~p", [{SceneId, MissionType, MissionId}]),
    scene_master:create_mulit_mission_worker(SceneId, [{mission_id, MissionId}]),
    ok.

handle_player_enter_mission(PlayerId) ->
    _Now = util_time:milli_timestamp(),

    List = get_player_id_list(),
    case lists:member(PlayerId, List) of
        true ->
            noop;
        false ->
            put_player_id_list([PlayerId | List])
    end,

    %% 给玩家推送当前对战的两个hero的胜率
    mod_hero_versus_boss:get_against_record(PlayerId, ?GET_HERO_VERSUS_BOSS_WIN_RATE),
    mod_hero_versus_boss:handle_my_bet(PlayerId),
    PlayersInScene = [PlayerIdInScene || PlayerIdInScene <- get_player_id_list(), PlayerIdInScene >= 10000],
    TotalPlayers = length(PlayersInScene),
    {NowStatus, Time} = get(?HERO_VERSUS_BOSS_STATUS),
    Time1 = Time div ?SECOND_MS,
    ?DEBUG("NowStatus: ~p", [{NowStatus, NowStatus =:= 6}]),
    {NoticeHeroEnter, NoticeDelayHeroEnter, NoticeMonsterEnter, NoticeDelayMonsterEnter, NoticeOtherPlayersInScene} =
        if
        %% 正在下注
            NowStatus =:= 1 -> {?TRUE, ?FALSE, ?TRUE, ?FALSE, ?TRUE};
        %% 正在倒计时准备开打或正在互搂，下发英雄和怪物进场的通知
            NowStatus =:= 3 orelse NowStatus =:= 4 -> {?TRUE, ?FALSE, ?TRUE, ?FALSE, ?FALSE};
        %% 正在播放英雄和怪物的出场动画，延迟1秒英雄进场，怪物直接进场
            NowStatus =:= 5 -> {?FALSE, ?SECOND_MS, ?TRUE, ?FALSE, ?FALSE};
        %% 战斗已经结束，死掉的boss躺地上，等待结算，通知英雄进场，等待英雄销毁开始下一轮
            NowStatus =:= 6 -> {?TRUE, ?FALSE, ?FALSE, ?FALSE, ?FALSE};
        %% 已经结算了或正在等待下一轮开始，故下发英雄、怪物进场的通知
            true -> {?FALSE, ?FALSE, ?FALSE, ?FALSE, ?FALSE}
        end,
    ?IF(NoticeHeroEnter =/= ?FALSE, handle_hero_enter_mission(PlayerId), noop),
    ?IF(NoticeDelayHeroEnter =/= ?FALSE, delay_hero_enter_mission(NoticeDelayHeroEnter), noop),
    ?IF(NoticeMonsterEnter =/= ?FALSE, handle_monster_enter_mission(PlayerId), noop),
    ?IF(NoticeDelayMonsterEnter =/= ?FALSE, delay_monster_enter_mission(NoticeDelayMonsterEnter), noop),
    ?IF(NoticeOtherPlayersInScene =/= ?FALSE,
        lists:foreach(
            fun (PlayerInScene) ->
                if
                    PlayerInScene =/= PlayerId ->
                        ?DEBUG("enter_scene: ~p", [PlayersInScene]),
                        Node = mod_player:get_game_node(PlayerInScene),
                        mod_apply:apply_to_online_player(Node, PlayerInScene, api_mission, notice_hero_versus_boss,
                            [PlayerInScene, {TotalPlayers, Time1, NowStatus, Time1}], store);
                    true -> ok
                end
            end,
            PlayersInScene), noop),

    %% 通知当前进入场景的玩家，当前副本状态
    MyNode = mod_player:get_game_node(PlayerId),
    mod_apply:apply_to_online_player(MyNode, PlayerId, api_mission, notice_hero_versus_boss,
        [PlayerId, {TotalPlayers, Time1, NowStatus, Time1}], store),

    ?DEBUG("Winner: ~p", [{get(?HERO_VERSUS_BOSS_WINNER), NowStatus}]),
%%    delay_hero_enter_mission(),
    ok.

delay_monster_enter_mission(Delay) ->
    erlang:send_after(Delay, self(), {?MSG_MONSTER_ENTER_MISSION_DELAY}).

delay_hero_enter_mission(Delay) ->
    erlang:send_after(Delay, self(), {?MSG_HERO_ENTER_MISSION_DELAY}).

handle_monster_enter_mission() ->
    PlayerInScene = [Player || Player <- mod_scene_player_manager:get_all_obj_scene_player_id(), Player >= 10000],
    handle_monster_enter_mission(PlayerInScene).
handle_monster_enter_mission(Players) when is_list(Players) ->
    lists:foreach(
        fun(PlayerId) -> handle_monster_enter_scene(PlayerId) end,
        Players
    );
handle_monster_enter_mission(MyPlayerId) ->
    PlayerInScene = [Player || Player <- mod_scene_player_manager:get_all_obj_scene_player_id(),
        Player >= 10000 andalso MyPlayerId =:= Player],
    handle_monster_enter_mission(PlayerInScene).
handle_monster_enter_scene(PlayerId) ->
    MonsterEnterSceneOut =
        lists:foldl(
            fun(MonsterId, Tmp) ->
                TmpMonsterActor = mod_scene_monster_manager:get_obj_scene_monster(MonsterId),
                [api_scene:pack_scene_actor(TmpMonsterActor) | Tmp]
            end,
            [],
            mod_scene_monster_manager:get_all_obj_scene_monster_id()
        ),
    Out = #m_scene_notice_monster_enter_toc{scene_monster_list = MonsterEnterSceneOut},
    mod_socket:send(PlayerId, proto:encode(Out)).
%%    mod_socket:send(PlayerId, proto:encode(Out)),
%%    mod_hero_versus_boss:pack_robot_out().
%%    ?DEBUG("PlayerId: ~p Out：~p Res: ~p", [PlayerId, Out, mod_socket:send(PlayerId, proto:encode(Out))]).

handle_hero_enter_mission() ->
    mod_hero_versus_boss:pack_robot_out().
handle_hero_enter_mission(PlayerId) ->
    mod_hero_versus_boss:pack_robot_out(PlayerId).

handle_init_mission(_ExtraDataList) ->
    put(?HERO_VERSUS_BOSS_FIGHT_STATUS, ?FALSE),
%%    Time = ?SD_GUESS_MISSION_BET_TIME,
    Time = 3000,
    put(?HERO_VERSUS_BOSS_STATUS, {2, util_time:milli_timestamp() + Time}),
    put(?HERO_VERSUS_BOSS_LATEST_FIGHT, {2, util_time:milli_timestamp()}),
    ?DEBUG("TIME: ~p", [Time]),
    ?DEBUG("put: ~p", [get(?HERO_VERSUS_BOSS_STATUS)]),
    mod_mission:send_msg_delay(?MSG_HERO_VERSUS_BOSS_ROUND, Time).

handle_round(State) ->
    {GuessState, PreviousTime} = get(?HERO_VERSUS_BOSS_STATUS),
    ?DEBUG("hero versus boss fight status: ~p", [GuessState]),
    Time = util_time:milli_timestamp(),
    {NewState, NewTime} =
        case GuessState of
            ?TRUE ->
                Time1 = Time + ?SD_HERO_VS_BOSS_MISSION_OPENING_SHOW,
                ?INFO("下注结束，播放开场动画。~p开始互搂", [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
%%                handle_hero_enter_mission(),
%%                handle_monster_enter_mission(),
                {3, Time1};
            3 ->
                Time1 = Time + ?SD_HERO_VS_BOSS_MISSION_ROUND_TIME,
                ?INFO("开场动画播放结束，开始互搂。~p开始结算", [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
                handle_fight(State),
                {4, Time1};
            4 ->
                {4, Time};
            6 ->
                CelebrateTime = ?SD_HERO_VS_BOSS_MISSION_VICTORY_ANIMATION,
                Time1 = Time + CelebrateTime,
                ?INFO("战斗已经结束，胜利boss开始庆祝，~ps的~p开始结算(~p)",
                    [CelebrateTime, util_time:timestamp_to_datetime(Time1 div ?SECOND_MS), get(hero_versus_boss_winner)]),
                {2, Time1};
            2 ->
                Time1 = Time + ?SD_HERO_VS_BOSS_MISSION_STAND_TIME,
                ?INFO("boss互搂结束开始结算。~p开始新的一轮", [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
                handle_balance(State),
                {?FALSE, Time1};
            ?FALSE ->
                Time1 = Time + ?SD_HERO_VS_BOSS_MISSION_BIRTH_EFFECT,
                ?INFO("------------------------------------~n新的一轮开始,~p后boss出生动画结束",
                    [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
                handle_start(State),
                ?INFO("handle_start lineup: ~p", [get(?LINEUP_POS)]),
%%                delay_monster_enter_mission(?SECOND_MS),
%%                handle_monster_enter_mission(),
                delay_monster_enter_mission(500),
                delay_hero_enter_mission(?SD_HERO_VS_BOSS_MISSION_HERO_ENTER),
                {5, Time1};
            5 ->
                Time1 = Time + ?SD_HERO_VS_BOSS_MISSION_BET_TIME,
                ?INFO("boss出生动画播放结束，~p玩家下注结束", [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
%%                delay_hero_enter_mission(?SD_HERO_VS_BOSS_MISSION_BET_TIME - ?SECOND_MS),
                [mod_hero_versus_boss:get_against_record(PlayerInScene, ?GET_HERO_VERSUS_BOSS_WIN_RATE) ||
                    PlayerInScene <- get_player_id_list(), PlayerInScene >= 10000],
                {?TRUE, Time1}
        end,
%%    _EndFightingTime = get(hero_versus_boss_fighting),
    put(latest_status_time, {GuessState, PreviousTime}),
    PlayersInScene = [PlayerId || PlayerId <- mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId >= 10000],
%%    ?DEBUG("Status: ~p", [{NewState, get(hero_versus_boss_fighting)}]),
%%    put(hero_versus_boss_status, {NewState, NewTime}),
%%    mod_mission:send_msg_delay(?MSG_HERO_VERSUS_BOSS_ROUND, NewTime - Time),


    {RealState, RealTime, Out, Continue} =
        if
            GuessState =:= 3 andalso NewState =:= 4 ->
                {NewState, NewTime, ok, ?FALSE};
            GuessState =:= 4 andalso NewState =:= 4 ->
                {NewState, NewTime, ok, ?TRUE};
            NewState =:= 2 ->
                StatusOut = #m_mission_hero_versus_boss_status_toc{
                    state = NewState,  players = length(PlayersInScene), operation = 2,
                    timestamp = NewTime div ?SECOND_MS, previous_timestamp = PreviousTime div ?SECOND_MS,
                    winner_hero = ?IF(get(?HERO_VERSUS_BOSS_WINNER) =:= ?UNDEFINED, 0, get(hero_versus_boss_winner))
                },
                ?DEBUG("StatusOut: ~p", [{GuessState, NewState, NewTime - Time, StatusOut}]),
                {NewState, NewTime, StatusOut, ?TRUE};
            true ->
                StatusOut = #m_mission_hero_versus_boss_status_toc{
                        state = NewState,  players = length(PlayersInScene), operation = 2,
                        timestamp = NewTime div ?SECOND_MS, previous_timestamp = PreviousTime div ?SECOND_MS
                    },
                ?DEBUG("StatusOut: ~p", [{GuessState, NewState, NewTime - Time, StatusOut}]),
                {NewState, NewTime, StatusOut, ?TRUE}
        end,
%%    ?DEBUG("RealTime: ~p", [{GuessState, RealState, RealTime, Time, RealTime - Time}]),
    put(?HERO_VERSUS_BOSS_STATUS, {RealState, RealTime}),
    if
        RealTime > Time ->
            if
                Continue =:= ?TRUE ->
                    mod_mission:send_msg_delay(?MSG_HERO_VERSUS_BOSS_ROUND, RealTime - Time);
                true -> ok
            end;
        true -> ok
    end,

    lists:foreach(
        fun(PlayerId) ->
            case Out of
                ok -> true;
                RealOut when is_record(RealOut, m_mission_hero_versus_boss_status_toc) ->
                    mod_socket:send(PlayerId, proto:encode(RealOut));
                Other -> ?ERROR("非预期结果: ~p", [Other])
            end
        end,
        PlayersInScene
    ).

%% @doc 离开副本
handle_leave_mission(PlayerId) ->
    Players = get_player_id_list(),
    put_player_id_list(lists:delete(PlayerId, get_player_id_list())),
    {GuessState, Time} = get(?HERO_VERSUS_BOSS_STATUS),
    StatusTime = Time div ?SECOND_MS,
    lists:foreach(
        fun(PlayerInScene) ->
            if
                PlayerId =/= PlayerInScene andalso GuessState =:= ?TRUE ->
                    Node = mod_player:get_game_node(PlayerId),
                    mod_apply:apply_to_online_player(Node, PlayerId, api_mission, notice_hero_versus_boss,
                        [PlayerInScene, {length(Players) - 1, StatusTime, GuessState, StatusTime}], store);
                true -> true
            end
        end,
        Players
    ).

handle_balance(#scene_state{scene_id = SceneId, mission_type = MissionType } = State) ->
    Balance =
        case get(?LINEUP_POS) of
            ?UNDEFINED -> false;
            _ -> true
        end,
    {Winner, _Loser, HomeHeroId, AwayHeroId} =
        if
            Balance =:= true ->
                SideHeroTupleList = mod_hero_versus_boss:get_against(),
                Winner1 =
                    case lists:keyfind(get(winner_side), 1, SideHeroTupleList) of
                        false -> false;
                        {_, WinnerHeroId, _, _} -> WinnerHeroId
                    end,
                Loser1 =
                    case lists:keyfind(get(loser_side), 1, SideHeroTupleList) of
                        false -> false;
                        {_, LoserHeroId, _, _} -> LoserHeroId
                    end,
                [{_, HomeHeroId1, _, _}, {_, AwayHeroId1, _, _}] = SideHeroTupleList,
                {Winner1, Loser1, HomeHeroId1, AwayHeroId1};
            true -> {0, 0, 0, 0}
        end,
    PlayersInScene = [RealPlayer || RealPlayer <- get_player_id_list(), RealPlayer >= 10000],

    %% 没有投注玩家所显示的结算数据
%%    EmptyAwardTupleList = [{?ITEM_RMB, 0} || [_Pos, _] <- ?SD_HERO_VS_BOSS_MISSION_RATE_LIST],
    EmptyAwardTupleList = [{?ITEM_RMB, 0}],
    {TotalCost, TotalAward} =
        case mod_bet_player_manager:get_bet_player_list(MissionType) of
            [] ->
                %% 场景内玩家 结算通知
                lists:foreach(
                    fun(PlayerId) ->
                        Node = mod_player:get_game_node(PlayerId),
                        mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice,
                            [PlayerId, [Winner, EmptyAwardTupleList], ?MSG_NOTICE_PLAYER_IN_BET_RESULT], store)
                    end,
                    PlayersInScene
                ),
                {0, 0};
            PlayerBetTupleList ->
                [[RightSide, RightRate], [LeftSide, LeftRate]] = ?SD_HERO_VS_BOSS_MISSION_RATE_LIST,
                RealRightSide  = RightSide + 1,
                RealLeftSide  = LeftSide + 1,
                BetPos = get(winner_side) + 1,

                CostList =
                    lists:foldl(
                        fun({_, BetTupleList}, Tmp) ->
                            BetTupleList ++ Tmp
                        end,
                        [],
                        PlayerBetTupleList
                    ),
                TotalCostTupleList = mod_prop:merge_prop_list(CostList),
                TotalCost1 = ?IF(length(TotalCostTupleList) =:= 0, 0,
                    lists:sum([TotalBet || {_, TotalBet} <- TotalCostTupleList])),

                WinnerRewardTupleList =
                    lists:filtermap(
                        fun({BetPlayerId, BetTupleList}) ->
                            case lists:keyfind(BetPos, 1, BetTupleList) of
                                false -> false;
                                {BetPos, Bet} ->
                                    {RightReward, LeftReward} =
                                        if
                                            BetPos =:= RealRightSide andalso Bet > 0 ->
                                                {0, util:to_int(RightRate * Bet / 10000)};
                                            BetPos =:= RealLeftSide andalso Bet > 0 ->
                                                {util:to_int(LeftRate * Bet / 10000), 0};
                                            true -> {0, 0}
                                        end,
                                    %% 下发奖励
                                    RealReward = RightReward + LeftReward,
                                    Node = mod_player:get_game_node(BetPlayerId),
                                    if
                                        RealReward =/= 0 ->
                                            #t_hero{
                                                name = HeroName
                                            } = t_hero:get({Winner}),
                                            case lists:member(BetPlayerId, PlayersInScene) of
                                                false -> mod_apply:apply_to_online_player(
                                                    Node, BetPlayerId, mod_mail, add_mail_param_item_list,
                                                    [
                                                        BetPlayerId,
                                                        ?MAIL_GUESS_BOSS_BALANCE,
                                                        [{?ITEM_RMB, RealReward}],
                                                        [HeroName, RealReward],
                                                        ?LOG_TYPE_GUESS_BOSS
                                                    ], store);
                                                true -> mod_apply:apply_to_online_player(
                                                    Node, BetPlayerId, mod_award, give,
                                                    [BetPlayerId, [{?ITEM_RMB, RealReward}], ?LOG_TYPE_GUESS_BOSS],
                                                    store)
                                            end;
                                        true -> noop
                                    end,
                                    {true,
%%                                        {BetPlayerId, [{RealLeftSide - 1, RightReward}, {RealRightSide - 1, LeftReward}]}
                                        {BetPlayerId, [{?ITEM_RMB, RealReward}]}
                                    }
                            end
                        end,
                        PlayerBetTupleList
                    ),

                %% 结算
                TotalRewardList =
                    lists:foldl(
                        fun(PlayerId, Tmp) ->
                            ?INFO("balance: ~p", [PlayerId]),
                            Node = mod_player:get_game_node(PlayerId),
                            case lists:keyfind(PlayerId, 1, WinnerRewardTupleList) of
                                %% 没中奖
                                false ->
                                    ?INFO("balance: ~p", [{PlayerId, WinnerRewardTupleList}]),
                                    mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice,
                                        [PlayerId, [Winner, EmptyAwardTupleList],
                                            ?MSG_NOTICE_PLAYER_IN_BET_RESULT], store),
                                    Tmp;
                                {PlayerId, Reward} ->
                                    ?INFO("balance: ~p", [{PlayerId, WinnerRewardTupleList}]),
                                    %% 场景内玩家 结算通知
                                    mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice,
                                        [PlayerId, [Winner, Reward], ?MSG_NOTICE_PLAYER_IN_BET_RESULT], store),
                                    RealReward =
                                        lists:filtermap(
                                            fun({_Pos, Award}) ->
                                                if
                                                    Award > 0 -> {true, Award};
                                                    true -> false
                                                end
                                            end,
                                            Reward
                                        ),
                                    case length(RealReward) of
                                        1 -> [hd(RealReward) | Tmp];
                                        _ -> Tmp
                                    end
                            end
                        end,
                        [],
                        [PlayerInScene || PlayerInScene <- mod_scene_player_manager:get_all_obj_scene_player_id(),
                            PlayerInScene >= 10000]
                    ),
                TotalReward = lists:sum(TotalRewardList),
                {TotalCost1, TotalReward}
        end,
    if
        HomeHeroId =/= 0 andalso AwayHeroId =/= 0 ->
%%            MonsterIdList =
%%                lists:filtermap(
%%                    fun(M) ->
%%                        #obj_scene_actor{ base_id = MId } = ?GET_OBJ_SCENE_MONSTER(M),
%%                        {true, MId}
%%                    end,
%%                    mod_scene_monster_manager:get_all_obj_scene_monster_id()
%%                ),
%%            MonsterId = hd(MonsterIdList),
%%            MonsterId = get(?HERO_VERSUS_BOSS_BOSS_ID),
            MonsterId = mod_hero_versus_boss:get_boss_id(),
            ?DEBUG("monster: ~p", [{MonsterId, HomeHeroId, AwayHeroId, mod_scene_monster_manager:get_all_obj_scene_monster_id()}]),
            NewNumber = mod_server_data:get_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER) + 1,
            Record =
                #db_boss_one_on_one{
                    id = NewNumber,
                    home_boss = HomeHeroId,
                    away_boss = MonsterId,
%%                    away_boss = AwayHeroId,
                    winner = ?IF(HomeHeroId =:= Winner, 0, 1),
                    created_time = util_time:timestamp(),
                    player_total_award = TotalAward,
                    player_total_cost = TotalCost
                },
            NewNumber1 = NewNumber + 1,
            Record1 =
                #db_boss_one_on_one{
                    id = NewNumber1,
                    home_boss = MonsterId,
                    away_boss = AwayHeroId,
                    winner = ?IF(HomeHeroId =:= Winner, 0, 1),
                    created_time = util_time:timestamp(),
                    player_total_award = TotalAward,
                    player_total_cost = TotalCost
                },
            Tran =
                fun() ->
%%                    mod_server_data:set_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER, NewNumber),
                    mod_server_data:set_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER, NewNumber1),
                    db:write(Record),
                    db:write(Record1)
                end,
            db:do(Tran);
        true -> ok
    end,
    bet_handle:handle_destroy_player_list(State),
    destroy_scene_obj(SceneId),
    create_scene_obj(SceneId).

handle_fight(State) ->
    mod_hero_versus_boss:gen_skill_timestamp(),
    mod_hero_versus_boss:fight(State),
    EndTimeStamp = util_time:milli_timestamp(),
    put(hero_versus_boss_fighting, EndTimeStamp),
    ok.

handle_start(#scene_state{scene_id = _SceneId } = _State) ->
    put(?HERO_VERSUS_BOSS_WINNER, ?UNDEFINED),
    lists:foreach(
        fun(MonsterId) ->
            MonsterObj = mod_scene_monster_manager:get_obj_scene_monster(MonsterId),
            %% 调整boss朝向
            #obj_scene_actor{ x = MonsterX, y = MonsterY } = MonsterObj,
            Side = get({hero_versus_boss_pos, boss, MonsterX, MonsterY}),
%%            {MatchHeroPosX, MatchHeroPosY} = get({hero_versus_boss_pos, hero, Side}),
            MonsterObj1 = MonsterObj#obj_scene_actor{
                dir = ?DIR_DOWN
%%                dir = util_math:get_direction({MonsterX, MonsterY}, {MatchHeroPosX, MatchHeroPosY})
            },
            ?UPDATE_OBJ_SCENE_MONSTER(MonsterObj1),
            %% 将怪物唯一id加入line_up
            OldLineupPos = get(?LINEUP_POS),
            NewLineupPos =
                case lists:keyfind(Side, 1, OldLineupPos) of
                    {Side, HeroBossTupleList} ->
                        case lists:keyfind(boss, 1, HeroBossTupleList) of
                            {boss, OldBossTuple} ->
                                case OldBossTuple of
                                    {BossInfo, PosTuple} ->
                                        {BossInfo, PosTuple} = OldBossTuple,
                                        NewBossTuple = {BossInfo, PosTuple, MonsterId},
                                        NewHeroBossTupleList = lists:keyreplace(boss, 1, HeroBossTupleList, {boss, NewBossTuple}),
                                        lists:keyreplace(Side, 1, OldLineupPos, {Side, NewHeroBossTupleList});
                                    {BossInfoInData, _, MonsterIdInData} ->
                                        ?DEBUG("已经为lineup_pos生成好怪物唯一编号: ~p", [{BossInfoInData, MonsterIdInData}]),
                                        OldLineupPos
                                end
                        end
                end,
            put(?LINEUP_POS, NewLineupPos)
        end,
        mod_scene_monster_manager:get_all_obj_scene_monster_id()
    ),
    PosHeroIdTupleList =
        lists:foldl(
            fun(Ele, Tmp) ->
                {Side, HeroBossTupleList} = Ele,
                RealHeroId =
                    case lists:keyfind(hero, 1, HeroBossTupleList) of
                        false -> false;
                        {hero, {{HeroId1, _, _, _, _}, _, _}} -> HeroId1
                    end,
                [{Side, RealHeroId} | Tmp]
            end,
            [],
            get(?LINEUP_POS)
        ),
    SideHeroTupleList = lists:sort(PosHeroIdTupleList),
    ets:delete(?ETS_BOSS_ONE_ON_ONE_RECORD),
    ets:new(?ETS_BOSS_ONE_ON_ONE_RECORD, ?ETS_INIT_ARGS(#ets_boss_one_on_one_record.row_key)),
    [{Side, HomeHeroId}, {_, AwayHeroId}] = SideHeroTupleList,
    BossId =
        case lists:keyfind(Side, 1, get(?LINEUP_POS)) of
            false -> 0;
            {Side, HeroBossTupleList1} ->
                case lists:keyfind(boss, 1, HeroBossTupleList1) of
                    false -> 0;
                    {boss, {{BossId1, _}, _}} -> BossId1;
                    {boss, {{BossId2, _}, _, _}} -> BossId2
                end
        end,
    ?DEBUG("handle_start_hero_boss: ~p", [{{HomeHeroId, AwayHeroId}, BossId}]),
    mod_hero_versus_boss:set_against_data({HomeHeroId, AwayHeroId}, BossId).
    %% 给玩家推送当前对战的两个hero的胜率
%%    [mod_hero_versus_boss:get_against_record(PlayerInScene, ?GET_HERO_VERSUS_BOSS_WIN_RATE) ||
%%        PlayerInScene <- get_player_id_list(), PlayerInScene >= 10000].
%%    mod_hero_versus_boss:set_against_data(HomeHeroId, AwayHeroId)

%%    lists:foreach(
%%        fun(PlayerInScene) -> mod_hero_versus_boss:get_against_record(PlayerInScene, ?GET_HERO_VERSUS_BOSS_WIN_RATE) end,
%%        get_player_id_list()
%%    ).

destroy_scene_obj(_SceneId) ->
%%    RealPlayers = [PlayerId || PlayerId <- mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId >= 10000],
    Robots = [PlayerId || PlayerId <- mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId < 10000],
    PlayersInScene = [PlayerId || PlayerId <- mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId >= 10000],
    lists:foreach(
        fun(RobotId) ->
            mod_scene_robot_manager:handle_robot_death(RobotId)
        end,
        Robots
    ),
    lists:foreach(
        fun(MonsterId) ->
            ?DEBUG("delete monster: ~p", [MonsterId]),
            mod_scene_actor:delete_obj_scene_actor(?OBJ_TYPE_MONSTER, MonsterId),
%%            erlang:send(self(), {?MSG_NOTICE_MONSTER_LEAVE, MonsterId})
            api_scene:notice_monster_leave(PlayersInScene, MonsterId)
%%            erlang:send(self(), {?MSG_NOTICE_MONSTER_LEAVE, MonsterId})
        end,
        mod_scene_monster_manager:get_all_obj_scene_monster_id()
    ).
%%    mod_scene_monster_manager:destroy_all_monster().

create_scene_obj(SceneId) ->
    mod_hero_versus_boss:get_lineup(SceneId),
    mod_hero_versus_boss:create_hero(SceneId),
    mod_hero_versus_boss:create_monster().

get_player_id_list() ->
    case get(hero_versus_boss_player_id_list) of
        undefined ->
            [];
        _Value ->
            _Value
    end.
put_player_id_list(List) ->
    put(hero_versus_boss_player_id_list, List).

set_hero_versus_boss_pos(Type, Side, {X, Y}) ->
    put({hero_versus_boss_pos, Type, X, Y}, Side),
    put({hero_versus_boss_pos, Type, Side}, {X, Y}).