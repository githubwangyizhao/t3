%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 7月 2021 下午 03:57:53
%%%-------------------------------------------------------------------
-module(mod_mission_one_on_one).
-author("Administrator").

-include("one_on_one.hrl").
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

%% API
-export([
    handle_init_mission/1,
    handle_round/1,
    handle_enter_mission/1,
    handle_leave_mission/1,
    get_against/0,

    handle_notice_monster_leave/1,

    handle_monster_enter/0
]).


%% @doc 处理初始化副本
handle_init_mission(_ExtraDataList) ->
%%    Time = ?SD_GUESS_MISSION_TIME - ?SD_GUESS_MISSION_ROUND_TIME,
%%    Time = ?SD_GUESS_MISSION_ROUND_TIME,
    put(one_on_one_fighting, ?FALSE),
    Time = ?SD_GUESS_MISSION_BET_TIME,
%%    Time = 3000,
    put(?MISSION_STATE, {?TRUE, util_time:milli_timestamp() + Time}),
    put(latest_status_time, {?FALSE, util_time:milli_timestamp()}),
    ?DEBUG("TIME: ~p", [Time]),
    ?DEBUG("put: ~p", [get(?MISSION_STATE)]),
    mod_mission:send_msg_delay(?MSG_ONE_ON_ONE_ROUND_BALANCE, Time).

handle_round(State) ->
%%    {_StartTime, EndTime} = get(?GUESS_MISSION_ACTIVITY_TIME),
    {GuessState, _Time} = get(?MISSION_STATE),
    ?DEBUG("handle_round one on one: ~p", [GuessState]),
    Time = util_time:milli_timestamp(),
%%    ?DEBUG("查看时间1~p", [{Time, util_time:milli_timestamp()}]),
    {NewState, NewTime} =
        case GuessState of
            ?TRUE ->
                mod_mission_one_on_one:handle_monster_enter(),
                ?DEBUG("?TRUE: ~p", [get(one_on_one)]),
                Time1 = Time + ?SD_GUESS_MISSION_OPENING_SHOW,
                ?INFO("下注结束，播放开场动画。~p开始互搂", [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
                handle_fight(State),
                {3, Time1};
            3 ->
                Time1 = Time + ?SD_GUESS_MISSION_ROUND_TIME,
                ?INFO("开场动画播放结束，开始互搂。~p开始结算", [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
                {4, Time1};
            4 ->
                {4, Time};
            6 ->
                CelebrateTime = 3,
                ?INFO("战斗已经结束，胜利boss开始庆祝，~p后开始结算", [CelebrateTime]),
                {2, Time + CelebrateTime * ?SECOND_MS};
            2 ->
                Time1 =
                    if
                        _Time >= Time -> Time + ?SD_GUESS_MISSION_STAND_TIME;
                        true -> Time + ?SD_GUESS_MISSION_STAND_TIME
                    end,
                ?INFO("boss互搂结束开始结算。~p开始新的一轮", [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
                handle_balance(State),
                {?FALSE, Time1};
            ?FALSE ->
                Time1 = Time + ?SD_GUESS_MISSION_BIRTH_EFFECT,
                ?INFO("------------------------------------~n新的一轮开始,~p后boss出生动画结束",
                    [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
                handle_start(State),
%%                {?TRUE, Time1}
                {5, Time1};
            5 ->
                Time1 = Time + (?SD_GUESS_MISSION_BET_TIME),
                ?INFO("boss出生动画播放结束，~p玩家下注结束", [util_time:timestamp_to_datetime(Time1 div ?SECOND_MS)]),
                {?TRUE, Time1}
        end,
    EndFightingTime = get(one_on_one_fighting),
    put(latest_status_time, {GuessState, _Time}),
    PlayersInScene = mod_scene_player_manager:get_all_obj_scene_player_id(),
    {RealNewState, RealTime, Out} =
        if
            NewState =:= 4 andalso GuessState =:= 4 ->
                if
                    EndFightingTime =< Time ->
                        ?INFO("战斗结束，胜利boss开始嗷嗷嗷 ~p", [util_time:timestamp_to_datetime(Time div ?SECOND_MS)]),
%%                        WinnerObjId = get(winner),
                        LucyBossStatusOut = #m_mission_lucky_boss_status_toc{
                            state = NewState,  players = length(PlayersInScene), operation = 2,
                            timestamp = NewTime div ?SECOND_MS
                        },
                        put(balance, ?TRUE),
                        {6, Time, LucyBossStatusOut};
                    true ->
                        ?INFO("延迟到 ~p结束战斗", [
                            util_time:timestamp_to_datetime((_Time + ?SD_GUESS_MISSION_OPENING_SHOW) div ?SECOND_MS)]),
                        {NewState, _Time + ?SD_GUESS_MISSION_OPENING_SHOW, ok}
                end;
            true ->
                LucyBossStatusOut = #m_mission_lucky_boss_status_toc{
                    state = NewState,  players = length(PlayersInScene), operation = 2,
                    timestamp = NewTime div ?SECOND_MS
                },
                {NewState, NewTime, LucyBossStatusOut}
        end,
    ?DEBUG("Status: ~p", [{RealNewState, get(one_on_one_fighting)}]),
    put(?MISSION_STATE, {RealNewState, RealTime}),
    mod_mission:send_msg_delay(?MSG_ONE_ON_ONE_ROUND_BALANCE, RealTime - Time),
    lists:foreach(
        fun(PlayerId) ->
            ?DEBUG("~p in scene ~p", [PlayerId, {
                RealNewState, NewTime, util_time:timestamp_to_datetime(NewTime div ?SECOND_MS)}]),
            if
                GuessState =:= ?FALSE ->
                    Res = mod_boss_one_on_one:get_against_record(PlayerId, ""),
                    {{HomeBossId, HomeRate}, {AwayBossId, AwayRate}, _Records} = Res,
                    RateOut = #m_mission_notice_one_on_one_rate_toc{
                        winne_rate = [#winnerrate{boss_id = BossId, rate = util:to_int(Rate * 100)} ||
                            {BossId, Rate} <- [{HomeBossId, HomeRate}, {AwayBossId, AwayRate}]]
                    },
                    mod_socket:send(PlayerId, proto:encode(RateOut));
                true -> false
            end,
            case Out of
                ok -> true;
                RealOut when is_record(RealOut, m_mission_lucky_boss_status_toc) ->
                    mod_socket:send(PlayerId, proto:encode(RealOut));
                Other -> ?ERROR("非预期结果: ~p", [Other])
            end
        end,
        PlayersInScene
    ).

get_player_id_list() ->
    case get(one_on_one_player_id_list) of
        undefined ->
            [];
        _Value ->
            _Value
    end.
put_player_id_list(List) ->
    put(one_on_one_player_id_list, List).

handle_enter_mission(PlayerId) ->
    List = get_player_id_list(),
    case lists:member(PlayerId, List) of
        true ->
            noop;
        false ->
            put_player_id_list([PlayerId | List])
    end,
    case get(one_on_one) of
        [] ->
            put(one_on_one, mod_scene_monster_manager:get_all_obj_scene_monster_id()),
            MonsterTupleList =
                lists:filtermap(
                    fun(MonsterId) ->
                        case mod_scene_monster_manager:get_obj_scene_monster(MonsterId) of
                            ?UNDEFINED -> false;
                            MonsterObjActor ->
                                #obj_scene_actor{
                                    base_id = BaseId,
                                    x = _X, y = _Y
                                } = MonsterObjActor,
                                {true, {MonsterId, BaseId}}
                        end
                    end,
                    mod_scene_monster_manager:get_all_obj_scene_monster_id()
                ),
            put(one_on_one_boss_dict, MonsterTupleList),
            ?DEBUG("get(one_on_one_boss_dict): ~p", [get(one_on_one_boss_dict)]),
            %% 判断当前对战的两个boss的对战记录是否存在，若不存在则生成
            case mod_boss_one_on_one:get_against_record(PlayerId, "") of
                {{Home, _}, {Away, _}, Record} ->
                    if
                        Record =:= [] ->
                            [HomeBossId, AwayBossId] = [BossId || {_, BossId} <- MonsterTupleList],
                            R = mod_boss_one_on_one:set_against_data(HomeBossId, AwayBossId),
                            ?DEBUG("HomeBossId: ~p, AwayBossId: ~p ~p", [HomeBossId, AwayBossId, R]);
                        true -> ?DEBUG("Record: ~p ~p ~p", [Home, Away, Record])
                    end;
                Other -> ?ERROR("Other: ~p", [Other])
            end;
        Other -> ?DEBUG("monsters are exsits: ~p", [Other])
    end,

    {NowStatus, _} = get(?MISSION_STATE),
    handle_notice_mission_status(PlayerId),
    if
        NowStatus =:= 4 orelse NowStatus =:= 3 ->
            Now = util_time:milli_timestamp(),
            MonsterFightInfo =
                lists:filtermap(
                    fun(Monster) ->
                        FightingStatus = get(one_on_one_fighting_status),
                        case lists:keyfind(Monster, 1, FightingStatus) of
                            false -> ?ERROR("没有获取到boss的战斗日志"), false;
                            {_, TimeActionTupleList} ->
                                ?DEBUG("TimeActionTupleList: ~p", [lists:sort(TimeActionTupleList)]),
                                FightOut =
                                    lists:filtermap(
                                        fun({Timestamp, BossTuple}) ->
                                            ?IF(Timestamp =< Now, {true, {Timestamp, BossTuple}}, false)
                                        end,
                                        TimeActionTupleList
                                    ),
                                ?IF(hd(FightOut) >= 1, {true, hd(FightOut)}, false)
                        end
                    end,
                    get(one_on_one)
                ),
            if
                MonsterFightInfo =/= [] -> handle_notice_boss_pos(MonsterFightInfo, PlayerId);
                true -> ok
            end;
        true -> ok
    end,

    ?DEBUG("handle_player_into_scene: ~p", [PlayerId]),
    {GuessState, Time} = get(?MISSION_STATE),
    PlayersInScene = mod_scene_player_manager:get_all_obj_scene_player_id(),
    ?DEBUG("handle_enter_mision PlayersInScene: ~p", [PlayersInScene]),

    %% 给玩家推送当前对战的两个boss的对战记录
    mod_boss_one_on_one:get_against_record(PlayerId, ?GET_ONE_ON_ONE_WIN_RATE),

    %% 通知其他玩家有玩家进入副本
    lists:foreach(
        fun (PlayerInScene) ->
            TotalPlayers = length(PlayersInScene),
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerInScene, api_mission, notice_one_on_one,
                [PlayerInScene, TotalPlayers, Time div ?SECOND_MS, GuessState], store)
%%            ?DEBUG("notify to players who in scene: ~p(~p)", [
%%                mod_apply:apply_to_online_player(Node, PlayerInScene, api_mission, notice_one_on_one,
%%                    [PlayerInScene, TotalPlayers, Time div ?SECOND_MS, GuessState], store),
%%                Node])
        end,
        PlayersInScene
    ),
    ok.

handle_notice_mission_status(PlayerId) ->
    ?DEBUG("monster: ~p", [{get(one_on_one), get(winner)}]),
    {NowStatus, Timestamp} = get(?MISSION_STATE),
    {PreviousStatus, PreviousTimestamp} = get(latest_status_time),
    ?DEBUG("latest status: ~p", [{{NowStatus, Timestamp}, {PreviousStatus, PreviousTimestamp},
        util_time:milli_timestamp(), PlayerId}]),
    Out = #m_mission_lucky_boss_status_toc{
        state = NowStatus, timestamp = Timestamp div ?SECOND_MS,
        players = length(mod_scene_player_manager:get_all_obj_scene_player_id()),
        operation = 2, previous_timestamp = PreviousTimestamp div ?SECOND_MS
    },
    ?DEBUG("PlayerId: ~p, Out: ~p Res: ~p", [PlayerId, Out, mod_socket:send(PlayerId, proto:encode(Out))]).

handle_notice_boss_pos(MonstersFightList, PlayerId) ->
    FightOut =
        lists:foldl(
            fun(MonsterTuple, Tmp) ->
                {_Timestamp, {BossId, MonsterId, Hp, X, Y, Dir, MaxHp, MovePath}} = MonsterTuple,
                TmpMonsterActor = #obj_scene_actor{
                    obj_type = ?OBJ_TYPE_MONSTER, obj_id = MonsterId, base_id = BossId, x = X, y = Y, dir = Dir,
                    hp = Hp, max_hp = MaxHp, move_path = MovePath, move_speed = 600
                },
                [api_scene:pack_scene_actor(TmpMonsterActor) | Tmp]
            end,
            [],
            MonstersFightList
        ),
    ?DEBUG("handle_notice_boss_pos: ~p", [FightOut]),
    Out = #m_scene_notice_monster_enter_toc{scene_monster_list = FightOut},
    ?DEBUG("PlayerId: ~p Out：~p Res: ~p", [PlayerId, Out, mod_socket:send(PlayerId, proto:encode(Out))]).

handle_leave_mission(PlayerId) ->
%%    mod_scene_player_manager:delete_obj_scene_player(PlayerId),
    Players = mod_scene_player_manager:get_all_obj_scene_player_id(),
    {GuessState, Time} = get(?MISSION_STATE),
    lists:foreach(
        fun(PlayerInScene) ->
            if
                PlayerId =/= PlayerInScene ->
                    Node = mod_player:get_game_node(PlayerId),
                    ?DEBUG("notify to players there is a player leave: ~p(~p)", [
                        mod_apply:apply_to_online_player(Node, PlayerId, api_mission, notice_one_on_one,
                            [PlayerInScene, length(Players) - 1, Time div ?SECOND_MS, GuessState], store),
                        Node]);
                true -> true
            end
        end,
        Players
    ).

handle_fight(State) ->
    ?DEBUG("handle_fight：~p", [State]),
    case get(one_on_one) of
        [] ->
            put(one_on_one, mod_scene_monster_manager:get_all_obj_scene_monster_id()),
            MonsterTupleList =
                lists:filtermap(
                    fun(MonsterId) ->
                        case mod_scene_monster_manager:get_obj_scene_monster(MonsterId) of
                            ?UNDEFINED -> false;
                            MonsterObjActor -> #obj_scene_actor{ base_id = BaseId } = MonsterObjActor,
                                {true, {MonsterId, BaseId}}
                        end
                    end,
                    mod_scene_monster_manager:get_all_obj_scene_monster_id()
                ),
            put(one_on_one_boss_dict, MonsterTupleList),
            ?DEBUG("get(one_on_one_boss_dict): ~p", [get(one_on_one_boss_dict)]);
        Other1 -> ?DEBUG("monsters are exsits: ~p", [Other1])
    end,
    case catch mod_boss_one_on_one:handle_robot_fight_each_other_new(State) of
        {'EXIT', {empty, {EndTimeStamp, WinnerObjId}}} ->
%%            Winner = mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER),
            put(one_on_one_fighting, EndTimeStamp),
            put(winner, WinnerObjId),
            ?DEBUG("出结果了: ~p", [{WinnerObjId, EndTimeStamp}]);
        Other -> ?DEBUG("非预期结果： ~p", [Other])
    end.

handle_balance(_State) ->
    put(one_on_one_fighting, ?FALSE),
%%    Winner = hd(mod_scene_actor:get_actor_id_list(?OBJ_TYPE_MONSTER)),
    Winner = get(winner),
    RealWinnerPos =
        case util_list:get_element_index(Winner, get(one_on_one)) of
            {index, WinnerPos1} -> WinnerPos1 - 1;
            none -> -1
        end,
    ?DEBUG("Winner: ~p", [{Winner, RealWinnerPos, get(one_on_one)}]),
    #obj_scene_actor{
        base_id = WinnerBossId
    } = mod_scene_monster_manager:get_obj_scene_monster(Winner),
    PlayersHasBet = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, Winner, players}, []),
    PlayersInScene = mod_scene_player_manager:get_all_obj_scene_player_id(),
    ?INFO("PlayersInScene: ~p", [PlayersInScene]),
    if
        PlayersInScene =/= [] ->
            lists:foreach(
                fun(PlayerInScene) ->
                    Bet = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, Winner, PlayerInScene}, 0),
                    NoticeTupleList =
                        lists:filtermap(
                            fun([Pos, Rate]) ->
                                if
                                    RealWinnerPos =:= Pos -> {true, {?ITEM_RMB, util:to_int(Rate * Bet / 10000)}};
                                    true -> false
                                end
                            end,
                            ?SD_GUESS_RATE_LIST
                        ),
                    Node = mod_player:get_game_node(PlayerInScene),
                    ?INFO("notify to players the result who in scene: ~p(~p)", [
                        mod_apply:apply_to_online_player(Node, PlayerInScene, mod_bet, handle_notice,
                            [PlayerInScene, [WinnerBossId, NoticeTupleList], ?MSG_NOTICE_PLAYER_IN_BET_RESULT], store),
                        Node])
                end,
                PlayersInScene
            );
        true -> ?DEBUG("nobody in scene")
    end,
    TotalAward =
        if
            PlayersHasBet =/= [] ->
                AwardList =
                    lists:foldl(
                        fun(PlayerId, Tmp) ->
                            Bet = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, Winner, PlayerId}, 0),
                            NoticeTupleList =
                                lists:filtermap(
                                    fun([Pos, Rate]) ->
                                        if
                                            RealWinnerPos =:= Pos -> {true, {?ITEM_RMB, util:to_int(Rate * Bet / 10000)}};
                                            true -> false
                                        end
                                    end,
                                    ?SD_GUESS_RATE_LIST
                                ),
                            ?DEBUG("Win: ~p", [{PlayerId, NoticeTupleList}]),
                            {Type, Num} = hd(NoticeTupleList),
                            Node = mod_player:get_game_node(PlayerId),
                            case lists:member(PlayerId, PlayersInScene) of
                                false -> mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list,
                                    [PlayerId, ?MAIL_GUESS_BOSS_BALANCE, [{Type, Num}], [WinnerBossId, Type], ?LOG_TYPE_GUESS_BOSS], store);
                                true -> mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give,
                                    [PlayerId, [{Type, Num}], ?LOG_TYPE_GUESS_BOSS], store)
                            end,
                            [Num | Tmp]
                        end,
                        [],
                        PlayersHasBet
                    ),
                ?DEBUG("AwardList: ~p", [AwardList]),
                lists:sum(AwardList);
            true -> ?DEBUG("nobody bet"), 0
        end,

    {HomeBossId, AwayBossId} =
        if
            RealWinnerPos =:= 0 ->
                AwayBossId1 =
                    case lists:keyfind(lists:nth(2, get(one_on_one)), 1, get(one_on_one_boss_dict)) of
                        false -> -1;
                        {_MatchHomeMonsterId, AwayBossId2} -> AwayBossId2
                    end,
                {WinnerBossId, AwayBossId1};
            true ->
                HomeBossId1 =
                    case lists:keyfind(lists:nth(1, get(one_on_one)), 1, get(one_on_one_boss_dict)) of
                        false -> -1;
                        {_MatchHomeMonsterId, HomeBossId2} -> HomeBossId2
                    end,
                {HomeBossId1, WinnerBossId}
        end,
    ?DEBUG("Home: ~p Away: ~p, ~p", [HomeBossId, AwayBossId, {WinnerBossId, Winner, get(one_on_one_boss_dict), get(one_on_one)}]),
    TotalCost = lists:sum([util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, M}, 0) || M <- get(one_on_one)]),
    ?DEBUG("R: ~p", [{TotalCost, TotalAward}]),
    NewNumber = mod_server_data:get_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER) + 1,
    put(temp_record, mod_boss_one_on_one:get_against_record()),
    Record =
        #db_boss_one_on_one{
            id = NewNumber,
            home_boss = HomeBossId,
            away_boss = AwayBossId,
            winner = RealWinnerPos,
            created_time = util_time:timestamp(),
            player_total_award = TotalAward,
            player_total_cost = TotalCost
        },
    Tran =
        fun() ->
            mod_server_data:set_int_data(?SERVER_DATA_WAR_GUESS_BOSS_ACTIVITY_NUMBER, NewNumber),
            db:write(Record)
        end,
    db:do(Tran),
    %% 延迟n秒后通知客户端清除怪物
    lists:foreach(
        fun(MonsterInScene) ->
            mod_scene_actor:delete_obj_scene_actor(?OBJ_TYPE_MONSTER, MonsterInScene),
            if
                MonsterInScene =:= Winner ->
                    erlang:send_after(?SD_GUESS_MISSION_VICTORY_ANIMATION, self(), {?MSG_NOTICE_MONSTER_LEAVE, MonsterInScene});
                true -> erlang:send(self(), {?MSG_NOTICE_MONSTER_LEAVE, MonsterInScene})
            end
%%            api_scene:notice_monster_leave(mod_scene_player_manager:get_all_obj_scene_player_id(), MonsterInScene)
        end,
        get(one_on_one)
%%        mod_scene_monster_manager:get_all_obj_scene_monster_id()
    ).

handle_start(State) ->
%%    Winner = get(winner),
    put(one_on_one, []),
    put(temp_record, []),
    put(one_on_one_fighting_status, []),
    put(winner, ?UNDEFINED),
    SceneMonsterIdList = ?SD_GUESS_MISSION_BOSS_LIST,
    case get(guess_boss_notice_chat) of
        ?UNDEFINED ->
            noop;
        {ArgList, NoticeType} ->
            api_chat:notice_system_template_message(?NOTICE_GUESS_MISSION_RESULT_NOTICE, ArgList, NoticeType)
    end,

    BossListWithWeight = [{Boss, 1} || Boss <- util_list:shuffle(SceneMonsterIdList)],
    BossList = util_random:get_probability_item_count(BossListWithWeight, 2),
    mod_scene_monster_manager:create_monster_list(BossList, State),
%%    mod_scene_monster_manager:create_monster_list(lists:sort(BossList), State),
    put(one_on_one, mod_scene_monster_manager:get_all_obj_scene_monster_id()),
    MonsterTupleList =
        lists:filtermap(
            fun(MonsterId) ->
                case mod_scene_monster_manager:get_obj_scene_monster(MonsterId) of
                    ?UNDEFINED -> false;
                    MonsterObjActor ->
                        #obj_scene_actor{
                            base_id = BaseId
                        } = MonsterObjActor,
                        {true, {MonsterId, BaseId}}
                end
            end,
            mod_scene_monster_manager:get_all_obj_scene_monster_id()
        ),
    put(one_on_one_boss_dict, MonsterTupleList),
    [HomeBossId, AwayBossId] = [BossId || {_, BossId} <- MonsterTupleList],
    ?DEBUG("delete&create ets: ~p", [{
        ets:delete(?ETS_BOSS_ONE_ON_ONE_RECORD),
        ets:new(?ETS_BOSS_ONE_ON_ONE_RECORD, ?ETS_INIT_ARGS(#ets_boss_one_on_one_record.row_key))
    }]),
    R = mod_boss_one_on_one:set_against_data(HomeBossId, AwayBossId),
    ?DEBUG("HomeBossId: ~p, AwayBossId: ~p ~p", [HomeBossId, AwayBossId, {R, length(ets:tab2list(?ETS_BOSS_ONE_ON_ONE_RECORD))}]).

get_against() ->
    get(one_on_one_boss_dict).

handle_notice_monster_leave(Winner) ->
    put(balance, ?UNDEFINED),
    PlayersInScene = [PlayerId || PlayerId <- mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId >= 10000],
    ?INFO("销毁怪物推送：~p", [{Winner,
        api_scene:notice_monster_leave(PlayersInScene, Winner)}]).
handle_monster_enter() ->
    MonsterObjIdList = mod_scene_monster_manager:get_all_obj_scene_monster_id(),
    MonsterList =
        lists:foldl(
            fun(Monster, MonsterTmpList) ->
                MonsterObj = mod_scene_monster_manager:get_obj_scene_monster(Monster),
                #obj_scene_actor{ x = X, y = Y, hp = Hp, base_id = BossId, max_hp = MaxHp } = MonsterObj,
                DefenderList =
                    lists:filtermap(
                        fun(Enemy) ->
                            if
                                Enemy =/= Monster ->
                                    #obj_scene_actor{
                                        x = DefenderX, y = DefenderY
                                    } = mod_scene_monster_manager:get_obj_scene_monster(Enemy),
                                    {true, {DefenderX, DefenderY}};
                                true -> false
                            end
                        end,
                        MonsterObjIdList
                    ),
                {EnemyX, EnemyY} = hd(DefenderList),
                %% 调整两个boss朝向
                NewDir = util_math:get_direction({X, Y}, {EnemyX, EnemyY}),
                NewMonsterObj = MonsterObj#obj_scene_actor{ dir = NewDir },
                ?UPDATE_OBJ_SCENE_MONSTER(NewMonsterObj),
                ?DEBUG("motify dir：~p", [{Monster}]),
                [{Monster, [{util_time:milli_timestamp(), {BossId, Monster, Hp, X, Y, NewDir, MaxHp, []}}]} | MonsterTmpList]
            end,
            [],
            MonsterObjIdList
        ),
    ?DEBUG("create monster success: ~p", [{get(one_on_one), MonsterObjIdList, MonsterList}]),
    put(one_on_one_fighting_status, MonsterList).
%%    lists:foreach(
%%        fun(PlayerInScene) ->
%%            Out = #m_scene_notice_monster_enter_toc{scene_monster_list = [
%%                api_scene:pack_scene_actor(
%%                    mod_scene_monster_manager:get_obj_scene_monster(MonsterId)) || MonsterId <- MonsterObjIdList
%%            ]},
%%            ?DEBUG("PlayerInScene: ~p Out：~p", [PlayerInScene, Out])
%%        end,
%%        mod_scene_player_manager:get_all_obj_scene_player_id()
%%    ).

handle_notice_monster_dead(Attacker, Defender) ->
    Time = util_time:milli_timestamp(),
    #obj_scene_actor{
        x = AttackerX, y = AttackerY, dir = AttackerDir
    } = mod_scene_monster_manager:get_obj_scene_monster(Attacker),
    OneOnOneDefenderResult = [#oneononedefenderresult{
        defender_id = Defender, defender_type = ?OBJ_TYPE_MONSTER,
        hp = 0, hurt = 0, type = normal, x = 0, y = 0,
        buff_list = [], effect_list = [],  hurt_section_list = [],
        total_mano = 0, all_total_mano = 0, beat_times = 1, mano_award = 0,
        exp = 0, special_event = 0, dizzy_close_time = 0, award_player_id = 0,
        timestamp = Time
    }],
    FightOut =
        #m_mission_notice_lucky_boss_fight_toc{
            attacker_id = Attacker, attacker_type = ?OBJ_TYPE_MONSTER,
            x = AttackerX, y = AttackerY, dir = AttackerDir,
            target_id = Defender, target_type = ?OBJ_TYPE_MONSTER,
            skill_id = 0, skill_level = 1, anger = 0,
            timestamp = Time,
            defender_result_list = OneOnOneDefenderResult
        },
    case mod_scene_player_manager:get_all_obj_scene_player_id() of
        [] -> ?DEBUG("no players in scene");
        PlayersInScene ->
            ?INFO("通知: ~p", [PlayersInScene]),
            mod_socket:send_to_player_list(PlayersInScene, proto:encode(FightOut))
    end.
