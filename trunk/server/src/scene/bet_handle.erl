%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. 5月 2021 下午 02:20:55
%%%-------------------------------------------------------------------
-module(bet_handle).
-author("Administrator").

-include("scene.hrl").
-include("common.hrl").
-include("p_enum.hrl").
-include("scene_monster.hrl").
-include("mission.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("msg.hrl").
-include("guess_boss.hrl").
-include("p_message.hrl").
-include("error.hrl").
-include("one_on_one.hrl").
-include("scene_boss_pos.hrl").
-include("hero_versus_boss.hrl").

%% API
-export([
    handle_player_bet/2,
    handle_player_leave_bet/2,
    handle_single_player_bet/2,
    handle_destroy_player_list/1,
    handle_player_reset_bet/2,
    handle_notice_player_mission_status/2,

    handle_player_bet_in_scene/2,

    handle_player_reset_bet_one_on_one/2
]).

-export([
    handle_player_bet_reset/2
]).

handle_notice_player_mission_status({Status, Time, Msg}, State) ->
    #scene_state{
        mission_type = MissionType
    } = State,
    BetPlayers = mod_bet_player_manager:get_bet_player_list(MissionType),
    if
        BetPlayers =/= [] ->
            ?DEBUG("Status: ~p Time: ~p Msg: ~p MissionType: ~p Players: ~p", [Status, Time, Msg, MissionType, BetPlayers]),
            lists:foreach(
                fun({PlayerId, _}) ->
                    ?INFO("PlayerId: ~p", [{PlayerId, Status, Time, Msg}]),
                    %% MissionType, PlayerId, Msg, GuessStatus, Time, State
                    handle_notice_player(MissionType, PlayerId, Msg, Status, Time, State)
                end,
                mod_bet_player_manager:get_bet_player_list(MissionType)
            );
        true -> ?INFO("all players are leave bet page"), ok
    end.

handle_player_bet_in_scene({PlayerId, BetTupleList, _Msg},  State) ->
    PlayersInScene = [RealPlayer || RealPlayer <- mod_scene_player_manager:get_all_obj_scene_player_id(), RealPlayer >= 10000],
    ?ASSERT(lists:member(PlayerId, PlayersInScene), ?ERROR_NO_OBJ_SCENE_PLAYER),
%%    ?DEBUG("BetTupleList: ~p", [BetTupleList]),
    #scene_state{
        mission_type = MissionType
    } = State,
    {GuessStatus, _Time, Type} =
        case MissionType of
            ?MISSION_TYPE_GUESS_BOSS ->
                {GuessBossStatus, Time} = get(?GUESS_MISSION_STATE),
                {GuessBossStatus, Time, ?GUESS_MISSION_STATE};
            ?MISSION_TYPE_MISSION_HERO_PK_BOSS ->
                {HeroVersusBossStatus, Time} = get(?HERO_VERSUS_BOSS_STATUS),
                {HeroVersusBossStatus, Time, ?HERO_VERSUS_BOSS_STATUS};
            _ -> {?FALSE, 0, noop}
        end,
    ?INFO("player_bet: ~p", [{GuessStatus, _Time, Type}]),
    NoticeOtherPlayers =
        if
            Type =:= ?GUESS_MISSION_STATE andalso GuessStatus =:= ?TRUE ->
                MyBetTupleList =
                    lists:filtermap(
                        fun({Pos, Bet}) ->
                            MonsterId = lists:nth(Pos + 1, mod_scene_monster_manager:get_all_obj_scene_monster_id()),
                            if
                                Bet > 0 ->
                                    mod_mission_scene_boss:handle_scene_boss_bet(
                                        PlayerId, ?BET_TYPE_ONE_ON_ONE, MonsterId, Bet, #scene_state{mission_type = MissionType}),
                                    MyBet = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId, PlayerId}, 0),
                                    {true, {Pos, MyBet}};
                                true ->
                                    {true, {Pos, util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId, PlayerId}, 0)}}
                            end
                        end,
                        BetTupleList
                    ),
                PlayerHasBet = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, players}, []),
                NewPlayerHasBet = ?IF(lists:member(PlayerId, PlayerHasBet) =:= false, [PlayerId] ++ PlayerHasBet, PlayerHasBet),
                put({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, players}, NewPlayerHasBet),

                %% 给投注玩家下发自己的投注信息
                BetPlayerNode = mod_player:get_game_node(PlayerId),
                MyBetOut = #m_mission_lucky_boss_bet_info_toc{
                    bet_modification = [#betmodification{pos = P, bet = B} || {P, B} <- MyBetTupleList]
                },
                ?DEBUG("MyBetOut: ~p", [{MyBetOut}]),
                ?DEBUG("notify the bet player info: ~p(~p)", [
                    mod_apply:apply_to_online_player(BetPlayerNode, PlayerId, mod_bet, handle_notice,
                        [PlayerId, MyBetOut, ?MSG_PLAYER_BET], store),
                    BetPlayerNode
                ]),
                ?TRUE;
            Type =:= ?HERO_VERSUS_BOSS_STATUS andalso GuessStatus =:= ?TRUE ->
                mod_hero_versus_boss:handle_player_bet(PlayerId, BetTupleList);
            true -> ?FALSE
        end,
%%    ?DEBUG("NoticeOtherPlayers: ~p", [{NoticeOtherPlayers, mod_scene_player_manager:get_all_obj_scene_player_id()}]),
    if
        NoticeOtherPlayers =:= ?TRUE andalso Type =:= ?GUESS_MISSION_STATE->
            lists:foreach(
                fun(PlayerInScene) ->
                    if
                        PlayerInScene =/= PlayerId ->
                            Node = mod_player:get_game_node(PlayerInScene),
                            BetTupleList4Notice =
                                lists:filtermap(
                                    fun(Monster) ->
                                        MonsterPos =
                                            case util_list:get_element_index(Monster, get(one_on_one)) of
                                                {index, WinnerPos1} -> WinnerPos1 - 1;
                                                none -> -1
                                            end,
                                        ?DEBUG("MonsterPos: ~p", [{MonsterPos, Monster, get(one_on_one)}]),
                                        All = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, Monster}, 0),
                                        MyBet = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, Monster, PlayerInScene}, 0),
                                        ?DEBUG("All: ~p MyBet: ~p", [All, MyBet]),
                                        ?IF(MonsterPos =:= -1, false, {true, {MonsterPos, All - MyBet}})
                                    end,
                                    mod_scene_monster_manager:get_all_obj_scene_monster_id()
                                ),
                            ?DEBUG("BetTupleList4Notice: ~p", [BetTupleList4Notice]),
                            BetModification = [#betmodification{pos = Pos, bet = Bet} || {Pos, Bet} <- BetTupleList4Notice],
                            Out = #m_mission_lucky_boss_bet_modification_toc{bet_modification = BetModification},

                            ?DEBUG("notify to players who in scene: ~p(~p)<~p>", [
                                mod_apply:apply_to_online_player(Node, PlayerInScene, mod_bet, handle_notice,
                                    [PlayerInScene, Out, ?MSG_PLAYER_BET], store),
                                Node, Out
                            ]),
                            ?DEBUG("adfadf: ~p", [{BetTupleList}]);
                        true -> true %% ?DEBUG("不给自己推送投注信息变化记录~p", [PlayerInScene])
                    end
                end,
                mod_scene_player_manager:get_all_obj_scene_player_id()
            );
        NoticeOtherPlayers =:= ?TRUE andalso Type =:= ?HERO_VERSUS_BOSS_STATUS ->
            mod_hero_versus_boss:handle_notice_player_bet(PlayerId);
        true -> false
    end,
%%    put({?SCENE_BOSS_BET, Type, Id, PlayerId}, NewPlayerBetValue),
    ok.

handle_player_bet({PlayerId, BetTupleList, Msg}, State) ->
    {GuessStatus, Time} = get(?GUESS_MISSION_STATE),
    ?DEBUG("GuessStatus, handle_player_bet: ~p", [GuessStatus]),
    if
%%        GuessStatus =:= ?FALSE -> {[], [], GuessStatus, Time};

        %% GuessStatus为0时，表示正在等待下一轮下注开始，
        %% 将此时进入投注界面的玩家,加入到投注队列中
        GuessStatus =:= ?FALSE ->
            #scene_state{
                mission_type = MissionType
            } = State,
            mod_bet_player_manager:add_bet_player_list(MissionType, {PlayerId, BetTupleList}),
            {[], [], GuessStatus, Time};
        %% GuessStatus不为1时，表示boss在战斗，或是正在结算
        GuessStatus =/= ?TRUE -> {[], [], ?FALSE, Time};
        %% 当GuessStatus为1时有两种情况，1是boss正在战斗，或是投注时间还没结束
        true ->
            %%
            #scene_state{
                mission_type = MissionType
            } = State,
            BossFighting = get(fighting),
            %% 判断boss是否在战斗
            {ReturnGuessStatus, ReturnTime} =
                if
                    BossFighting =:= ?TRUE ->
                        {2, Time + ?SD_GUESS_MISSION_ROUND_TIME};
                    true ->
                        {GuessStatus, Time}
                end,
            ?INFO("MissionType: ~p GuessStatus: ~p Time: ~p fighting: ~p Msg: ~p",
                [MissionType, GuessStatus, Time, BossFighting, Msg]),

            mod_bet_player_manager:add_bet_player_list(MissionType, {PlayerId, BetTupleList}),
            ?DEBUG("before player into: ~p", [mod_bet_player_manager:get_bet_player_list(MissionType)]),
            BetPlayersList = mod_bet_player_manager:get_bet_player_list(MissionType),
            ?DEBUG("after player into: ~p", [mod_bet_player_manager:get_bet_player_list(MissionType)]),
            %% 推送消息给其他打开投注页面的玩家
            case Msg of
                %% 有玩家进入投注界面
                ?MSG_PLAYER_INTO_GUESS_MISSION_BET ->
                    LeavePlayersList = mod_bet_player_manager:get_bet_player_leave_list(MissionType),
                    handle_notice_player(MissionType, PlayerId, ?MSG_PLAYER_INTO_GUESS_MISSION_BET, ReturnGuessStatus,
                        ReturnTime, State, BetPlayersList, LeavePlayersList);
                %% 有玩家进行投注
                ?MSG_PLAYER_BET ->
                    LeavePlayersList = mod_bet_player_manager:get_bet_player_leave_list(MissionType),
                    handle_notice_player(MissionType, PlayerId, ?MSG_PLAYER_BET, ReturnGuessStatus, ReturnTime,
                        State, BetPlayersList, LeavePlayersList),
                    lists:foreach(
                        fun({PlayerIdInBet, _}) ->
                            if
                                PlayerIdInBet =/= PlayerId ->
                                    handle_single_player_bet(PlayerIdInBet, BetPlayersList);
                                true -> ?DEBUG("不给自己推送投注信息变化记录~p(~p)", [PlayerId, PlayerIdInBet])
                            end
                        end,
                        BetPlayersList
                    )
            end,
            {
                BetPlayersList,
                mod_bet_player_manager:get_bet_player_leave_list(MissionType),
                ReturnGuessStatus, ReturnTime
            }
    end.

handle_player_leave_bet(PlayerId, State) ->
    ?DEBUG("player leave bet page"),
    #scene_state{
        mission_type = MissionType,
        mission_id = _MissionId
    } = State,
    case catch mod_bet_player_manager:add_bet_player_leave_list(MissionType, {PlayerId}) of
        {'EXIT', not_exits} ->
            exit(not_exists);
        _R ->
            {GuessStatus, Time} = get(?GUESS_MISSION_STATE),
            RealGuessStatus = ?IF(GuessStatus =:= ?TRUE andalso get(fighting) =:= ?TRUE, 2, GuessStatus),
            handle_notice_player(MissionType, PlayerId, ?MSG_PLAYER_LEAVE_GUESS_MISSION_BET, RealGuessStatus, Time, State),
            {
                mod_bet_player_manager:get_bet_player_list(MissionType),
                mod_bet_player_manager:get_bet_player_leave_list(MissionType),
                GuessStatus, Time
            }
    end.

handle_destroy_player_list(State) ->
    #scene_state{
        mission_type = MissionType
    } = State,
%%    mod_bet_player_manager:del_bet_players(MissionType),
    mod_bet_player_manager:clear_players_bet(MissionType),
    case MissionType of
        ?MISSION_TYPE_GUESS_BOSS -> mod_bet_player_manager:del_bet_players_leave(MissionType);
        ?MISSION_TYPE_MISSION_HERO_PK_BOSS -> noop
    end.

handle_player_bet_reset(PlayerId, State) ->
    #scene_state{
        mission_type = MissionType
    } = State,
    {GuessStatus, _Time} =
        case MissionType of
            ?MISSION_TYPE_GUESS_BOSS -> get(?GUESS_MISSION_STATE);
            ?MISSION_TYPE_MISSION_HERO_PK_BOSS -> get(?HERO_VERSUS_BOSS_STATUS);
            _ -> {?FALSE, 0}
        end,
    ?INFO("player_reset_bet: ~p", [{GuessStatus, _Time}]),
    case GuessStatus of
        ?TRUE ->
            OldBetPlayerList = mod_bet_player_manager:get_bet_player_list(MissionType),
            ?DEBUG("OldBetPlayerList: ~p", [OldBetPlayerList]),
            lists:foreach(
                fun({PlayerInBet, _BetTupleList}) ->
                    ?DEBUG("PlayerInBet: ~p", [PlayerInBet]),
                    if
                        PlayerInBet =:= PlayerId ->
                            {_, MyBetsList} = lists:keyfind(PlayerId, 1, OldBetPlayerList),
                            MyTotalBets = lists:sum([Bet || {_, Bet} <- MyBetsList]),
                            Node = mod_player:get_game_node(PlayerId),
                            mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give,
                                [PlayerId, [{?ITEM_RMB, MyTotalBets}], ?LOG_TYPE_GUESS_BOSS], store),
                            case catch mod_bet_player_manager:del_bet_player(MissionType, PlayerId) of
                                {'EXIT', not_exits} ->
                                    exit(not_exists);
                                _R ->
                                    BetTupleListAfterReset = [{Pos, 0} || {Pos, _} <- MyBetsList],
                                    mod_bet_player_manager:add_bet_player_list(MissionType, {PlayerId, BetTupleListAfterReset}),
                                    BetPlayersList = mod_bet_player_manager:get_bet_player_list(MissionType),
                                    ?DEBUG("BetPlayersList: ~p", [BetPlayersList]),
                                    %% 给其他玩家推送投注变化情况
                                    mod_hero_versus_boss:handle_notice_player_bet(PlayerId)
                            end;
                        true -> false
                    end
                end,
                OldBetPlayerList
            );
        _ -> ?FALSE
    end.

handle_player_reset_bet_one_on_one(PlayerId, State) ->
    ?DEBUG("player reset bet in one_on_one"),
    #scene_state{
        mission_type = MissionType
    } = State,
    {GuessStatus, _Time} = get(?GUESS_MISSION_STATE),
    NoticeOtherPlayers =
        case GuessStatus of
            ?TRUE ->
                #scene_state{
                    mission_type = MissionType
                } = State,
%%                BetPlayerNode = mod_player:get_game_node(PlayerId),
                BetTupleListAfterReset =
                    lists:filtermap(
                        fun([Pos, _Rate]) ->
                            MonsterId = lists:nth(Pos + 1, mod_scene_monster_manager:get_all_obj_scene_monster_id()),

                            PlayerBetValue = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId, PlayerId}, 0),
                            OldTotalBetValue = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId}, 0),
                            ?DEBUG("~p Bet: ~p Total: ~p", [PlayerId, PlayerBetValue, OldTotalBetValue]),
                            NewTotalBetValue = OldTotalBetValue - PlayerBetValue,
                            put({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId}, NewTotalBetValue),
                            put({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId, PlayerId}, 0),
                            ?DEBUG("after reset: ~p ~p ~p", [get({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId}),
                                get({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId, PlayerId}), NewTotalBetValue]),

%%                            ?DEBUG("~p give ~p ~p: ~p(~p)", [
%%                                PlayerId, ?ITEM_RMB, PlayerBetValue,
%%                                mod_apply:apply_to_online_player(BetPlayerNode, PlayerId, mod_award, give,
%%                                    [PlayerId, [{?ITEM_RMB, PlayerBetValue}], ?LOG_TYPE_GUESS_BOSS], store),
%%                                BetPlayerNode
%%                            ]),
                            {true, {Pos, NewTotalBetValue}}
                        end,
                        ?SD_GUESS_RATE_LIST
                    ),

                PlayerHasBet = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, players}, []),
                NewPlayerHasBet = ?IF(lists:member(PlayerId, PlayerHasBet) =:= false, PlayerHasBet, lists:delete(PlayerId, PlayerHasBet)),
                put({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, players}, NewPlayerHasBet),
                ?DEBUG("PlayerHasBet: ~p ~p", [PlayerHasBet, NewPlayerHasBet]),

                ?DEBUG("BetTupleListAfterReset: ~p", [BetTupleListAfterReset]),
%%                MyBetOut = #m_mission_lucky_boss_bet_info_toc{
%%                    bet_modification = [#betmodification{pos = Pos, bet = Bet} || {Pos, Bet} <- BetTupleListAfterReset]
%%                },
%%                ?DEBUG("MyBetOut: ~p", [MyBetOut]),
%%                ?DEBUG("notify the reset player: ~p(~p)", [
%%                    mod_apply:apply_to_online_player(BetPlayerNode, PlayerId, mod_bet, handle_notice,
%%                        [PlayerId, MyBetOut, ?MSG_PLAYER_RESET_BET], store),
%%                    BetPlayerNode
%%                ]),
                BetTupleListAfterReset;
%%                ?TRUE;
            ?FALSE -> ?DEBUG("ready"), ?FALSE;
            2 -> ?DEBUG("fighting"), ?FALSE;
            3 -> ?DEBUG("animatation"), ?FALSE;
            Other -> ?ERROR("unexpect: ~p", [Other]), ?FALSE
        end,
    ?DEBUG("NoticeOtherPlayers: ~p", [NoticeOtherPlayers]),
    case NoticeOtherPlayers of
        BetTupleList when is_list(BetTupleList) ->
            lists:foreach(
                fun(PlayerInScene) ->
                    if
                        PlayerInScene =/= PlayerId ->
                            BetModificationList =
                                lists:filtermap(
                                    fun({MonsterPos, NewBet}) ->
                                        if
                                            PlayerInScene =/= PlayerId ->
                                                MonsterId = lists:nth(MonsterPos + 1, mod_scene_monster_manager:get_all_obj_scene_monster_id()),
                                                MyBet = util:get_dict({?SCENE_BOSS_BET, ?BET_TYPE_ONE_ON_ONE, MonsterId, PlayerInScene}, 0),
                                                ?DEBUG("MyBet: ~p", [{MonsterId, PlayerInScene, MyBet, NewBet}]),
                                                {true, {MonsterPos, NewBet - MyBet}};
                                            true -> false
                                        end
                                    end,
                                    BetTupleList
                                ),
                            ?DEBUG("BetModificationList: ~p", [BetModificationList]),
%%                            NoticeBetOut = #m_mission_lucky_boss_bet_modification_toc{bet_modification = BetModificationList},
                            NoticeBetOut = #m_mission_lucky_boss_bet_modification_toc{
                                bet_modification = [
                                    #betmodification{pos = Mp, bet = Nb} || {Mp, Nb} <- BetModificationList]
                            },
%%                            NoticeBetOut = #m_mission_lucky_boss_bet_modification_toc{
%%                                bet_modification = [
%%                                    #betmodification{pos = MonsterPos, bet = NewBet} || {MonsterPos, NewBet} <- BetTupleList]
%%                            },
                            ?DEBUG("NoticeBetOut: ~p", [NoticeBetOut]),
                            PlayerNode = mod_player:get_game_node(PlayerInScene),
                            ?DEBUG("~p notify ~p rest bet: ~p(~p)<~p>", [
                                PlayerId, PlayerInScene,
                                mod_apply:apply_to_online_player(PlayerNode, PlayerInScene, mod_bet, handle_notice,
                                    [PlayerInScene, NoticeBetOut, ?MSG_PLAYER_RESET_BET], store),
                                PlayerNode, NoticeBetOut
                            ]);
                        true -> true
                    end

                end,
                mod_scene_player_manager:get_all_obj_scene_player_id()
            );
        ?FALSE -> exit(unknown)
    end.
%% 清空玩家的下注记录
handle_player_reset_bet(PlayerId, State) ->
    ?DEBUG("player reset bet"),
    #scene_state{
        mission_type = MissionType
    } = State,
    {GuessStatus, Time} = get(?GUESS_MISSION_STATE),
    if
        GuessStatus =:= 0 -> ?DEBUG("fighting"), {[], [], GuessStatus, Time};
        true ->
            OldBetPlayerList = mod_bet_player_manager:get_bet_player_list(MissionType),
            ?DEBUG("OldBetPlayerList: ~p", [OldBetPlayerList]),
            {_, MyBetsList} = lists:keyfind(PlayerId, 1, OldBetPlayerList),
            MyTotalBets = lists:sum([Bet || {_, Bet} <- MyBetsList]),
            ?DEBUG("MyBetList: ~p", [MyTotalBets]),
            Node = mod_player:get_game_node(PlayerId),
            ?DEBUG("Node: ~p", [Node]),
%%            mod_apply:apply_to_online_player(PlayerId, mod_award, give_item, [PlayerId, MailId, AwardId, LogType, OptionList, true], store)
            mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give, [PlayerId, [{?ITEM_RMB, MyTotalBets}], ?LOG_TYPE_GUESS_BOSS], store),
            case catch mod_bet_player_manager:del_bet_player(MissionType, PlayerId) of
                {'EXIT', not_exits} ->
                    exit(not_exists);
                _R ->
                    BetTupleList = [ {Pos, 0} || [Pos, _, _] <- ?SD_GUESS_RATE_LIST],
                    mod_bet_player_manager:add_bet_player_list(MissionType, {PlayerId, BetTupleList}),
                    BetPlayersList = mod_bet_player_manager:get_bet_player_list(MissionType),
                    ?DEBUG("BetPlayersList: ~p", [BetPlayersList]),
                    %% 给指定玩家（PlayerId）推送自己投注情况的协议，与投注页面其他玩家的投注情况的协议
                    lists:foreach(
                        fun ({OtherPlayerId, _}) ->
                            ?DEBUG("BetTupleList: ~p", [BetTupleList]),
                            handle_single_player_bet(OtherPlayerId, BetPlayersList)
                        end,
                        BetPlayersList
                    ),
                    {GuessStatus, Time} = get(?GUESS_MISSION_STATE),
                    {
                        mod_bet_player_manager:get_bet_player_list(MissionType),
                        mod_bet_player_manager:get_bet_player_leave_list(MissionType),
                        GuessStatus, Time
                    }
            end
    end.

%% 返回指定玩家的下注记录，及其他玩家的下注记录
handle_single_player_bet(PlayerId, BetPlayersList) ->
    %% [A, B, C] A [B, C]
%%    ?DEBUG("PlayerId BetPlayersList: ~p", [{PlayerId, BetPlayersList}]),
    OwnBetList = lists:keyfind(PlayerId, 1, BetPlayersList),
%%    OtherPlayersBetList = lists:keydelete(PlayerId, 1, BetPlayersList),
    Others =
        lists:foldl(
            fun ({MatchPlayer, BetList}, Tmp) ->
                if
                    MatchPlayer =/= PlayerId ->
                        lists:merge(BetList, Tmp);
                    true -> Tmp
                end
            end,
            [],
            BetPlayersList
        ),
    OtherPlayersBetList = mod_prop:merge_prop_list(Others),
%%    ?DEBUG("Others: ~p OtherPlayersBetList: ~p", [Others, OtherPlayersBetList]),
    {_, OwnBetInfoList} = OwnBetList,
    OwnBetModification = [#betmodification{pos = Pos, bet = Bet} || {Pos, Bet} <- OwnBetInfoList],
    Out = #m_mission_lucky_boss_bet_info_toc{bet_modification = OwnBetModification},
%%    ?DEBUG("给~p推送自己的下注情况数据: ~p(~p)", [PlayerId, OwnBetInfoList, Out]),
    Node = mod_player:get_game_node(PlayerId),
    mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice, [PlayerId, Out, ?MSG_PLAYER_BET], store),
    if
        OtherPlayersBetList =/= [] ->
            OtherBetModification =
                lists:foldl(
                    fun({MatchPos, ZeroBet}, Tmp) ->
                        BetInfo =
                            case lists:keyfind(MatchPos, 1, OtherPlayersBetList) of
                                false -> #betmodification{pos = MatchPos, bet = ZeroBet};
                                {BetPos, Bet} -> #betmodification{pos = BetPos, bet = Bet}
                            end,
                        [BetInfo | Tmp]
                    end,
                    [],
                    [{Pos, 0} || [Pos, _, _] <- ?SD_GUESS_RATE_LIST]
                ),
            ?DEBUG("通知~p其他玩家的投注总信息: ~p", [PlayerId, OtherBetModification]),
%%            OtherBetModification = [#betmodification{pos = Pos, bet = Bet} || {Pos, Bet} <- OtherPlayersBetList],
            Out2 = #m_mission_lucky_boss_bet_modification_toc{bet_modification = OtherBetModification},
            mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice,
                [PlayerId, Out2, ?MSG_PLAYER_BET], store);
%%            lists:foreach(
%%                fun({Player, _}) ->
%%                    if
%%                        Player =/= PlayerId ->
%%                            ?DEBUG("接收推送消息的玩家: ~p Player: ~p Bet: ~p", [PlayerId, Player, OtherPlayersBetList]),
%%                            OtherBetModification = [#betmodification{pos = Pos, bet = Bet} || {Pos, Bet} <- OtherPlayersBetList],
%%                            Out2 = #m_mission_lucky_boss_bet_modification_toc{
%%                                bet_modification = OtherBetModification
%%                            },
%%                            mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice,
%%                                [PlayerId, Out2, ?MSG_PLAYER_BET], store);
%%                        true -> ?DEBUG("不给~p推送非~p之外的总下注数据", [Player, PlayerId])
%%                    end
%%                end,
%%                BetPlayersList
%%            );
        true -> ?DEBUG("只有一个玩家在投注页面~p", [PlayerId])
    end.

%% 通知玩家相关数据(玩家进入投注界面，玩家离开投注界面，玩家投注)
handle_notice_player(MissionType, PlayerId, Msg, GuessStatus, Time, State) ->
    ?DEBUG("handle_notice_player: ~p", [{MissionType, PlayerId, Msg, GuessStatus, Time, State}]),
    BetPlayersList = mod_bet_player_manager:get_bet_player_list(MissionType),
    LeavePlayersList = mod_bet_player_manager:get_bet_player_leave_list(MissionType),
    case Msg of
        ?MSG_NOTICE_PLAYER_IN_BET ->
            Node = mod_player:get_game_node(PlayerId),
            ?DEBUG("PlayerId: ~p ~p", [PlayerId, Node]),
            {Mod, Func} = ?IF(MissionType =:= 2, {mod_bet, handle_notice}, {mod_bet, handle_notice}),
            mod_apply:apply_to_online_player(Node, PlayerId, Mod, Func,
                [PlayerId, [BetPlayersList, LeavePlayersList, GuessStatus, Time], Msg], store);
        _ ->
            handle_notice_player(MissionType, PlayerId, Msg, GuessStatus, Time, State, BetPlayersList, LeavePlayersList)
    end.
handle_notice_player(_MissionType, PlayerId, Msg, GuessStatus, Time, _State, BetPlayersList, LeavePlayersList) ->
    lists:foreach(
        fun ({OtherPlayerId, _}) ->
            ?DEBUG("OtherPlayerId: ~p", [OtherPlayerId]),
%%                    ?DEBUG("BetTupleList: ~p", [BetTupleList]),
            if
                OtherPlayerId =/= PlayerId ->
                    Node = mod_player:get_game_node(PlayerId),
%%                    {Mod, Func} = ?IF(MissionType =:= 2, {mod_bet, handle_notice}, {mod_bet, handle_notice}),
                    Res =
                        case Msg of
                            ?MSG_PLAYER_INTO_GUESS_MISSION_BET ->
                                ?DEBUG("玩家进入: ~p", [{PlayerId, Msg}]),
                                mod_apply:apply_to_online_player(Node, OtherPlayerId, mod_bet, handle_notice,
                                    [OtherPlayerId, [BetPlayersList, LeavePlayersList, GuessStatus, Time], Msg], store);
                            ?MSG_PLAYER_LEAVE_GUESS_MISSION_BET ->
                                RealTime =
                                    if
                                        GuessStatus =:= 2 -> Time + ?SD_GUESS_MISSION_ROUND_TIME;
                                        true -> Time
                                    end,
                                ?DEBUG("MSG_PLAYER_LEAVE_GUESS_MISSION_BET: ~p", [{OtherPlayerId, GuessStatus, util_time:timestamp_to_datetime(RealTime div ?SECOND_MS)}]),
                                mod_apply:apply_to_online_player(Node, OtherPlayerId, mod_bet, handle_notice,
                                    [OtherPlayerId, [BetPlayersList, LeavePlayersList, GuessStatus, RealTime], Msg], store);
                            ?MSG_PLAYER_BET ->
                                handle_single_player_bet(OtherPlayerId, BetPlayersList);
                            _ -> ?DEBUG("MSG: ~p", [Msg])
                        end,
                    ?DEBUG("apply_to_online_player: ~p ~p ~p", [OtherPlayerId, Res, Msg]);

%%                    notice_player({OtherPlayerId,
%%                        {Msg, [LeavePlayersList, BetPlayersList, GuessStatus, Time]}}, State);
                true ->
                    case Msg of
                        ?MSG_PLAYER_INTO_GUESS_MISSION_BET ->
                            handle_single_player_bet(OtherPlayerId, BetPlayersList);
                        ?MSG_PLAYER_BET ->
                            handle_single_player_bet(OtherPlayerId, BetPlayersList);
                        _ -> true
                    end
            end
        end,
        BetPlayersList
    ),
    ok.

%%notice_player({PlayerId, BetStatus}, State) ->
%%    mod_apply:apply_to_online_player(Node, PlayerId, mod_bet, handle_notice, [PlayerId, BetStatus, bet_status], store),
%%    ok.