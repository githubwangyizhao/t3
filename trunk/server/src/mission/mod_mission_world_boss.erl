%%%%%-------------------------------------------------------------------
%%%%% @author
%%%%% @copyright (C) 2016, THYZ
%%%%% @doc            世界boss
%%%%% @end
%%%%% Created : 14. 六月 2016 下午 3:34
%%%%%-------------------------------------------------------------------
-module(mod_mission_world_boss).
%% API
%%-export([
%%    handle_enter_mission/2,
%%    handle_init_mission/3,
%%    handle_init_mission_monster/0,
%%    handle_balance/1
%%]).
%%
%%-export([
%%    init_activity_world_boss/0, % 初始活动时验证是否创建场景
%%%%    get_monster_attr_list/0,% 获得世界boss 的怪物属性
%%    open_action/1,          % 活动开始 创建boss
%%    close_action/1,         % 活动结束 调用boss结算
%%    is_enter_mission/2      % 是否能进入副本
%%]).
%%
%%-include("msg.hrl").
%%-include("error.hrl").
%%-include("scene.hrl").
%%-include("p_enum.hrl").
%%-include("common.hrl").
%%%%-include("gen/db.hrl").
%%-include("mission.hrl").
%%-include("p_message.hrl").
%%-include("server_data.hrl").
%%-include("gen/table_db.hrl").
%%-include("gen/table_enum.hrl").
%%
%%
%%%% @fun 初始活动时验证是否创建场景
%%init_activity_world_boss() ->
%%    lists:foldl(
%%        fun([ActivityId, MissionId | _], IsCreateBoss) ->
%%            {IsOpen, StartTime} = mod_activity:get_open_state_and_start_time(ActivityId),
%%            if
%%                IsCreateBoss == false andalso IsOpen == true ->
%%                    SceneId = get_world_boss_scene_id(MissionId),
%%                    scene_master:create_mulit_mission_worker(SceneId, [{mission_id, MissionId}, {?DICT_ACTIVITY_ID, ActivityId}, {?DICT_ACTIVITY_START_TIME, StartTime}]),
%%                    true;
%%                true ->
%%                    IsCreateBoss
%%            end
%%        end, false, ?SD_WORLD_BOSS),
%%    ok.
%%
%%%% @fun 活动开始 创建boss
%%open_action(Id) ->
%%    ?INFO("活动开始 创建boss ~p~n", [Id]),
%%    {MissionId, SceneId} = get_world_boss_scene_id_By_ActivityId(Id),
%%    scene_master:create_mulit_mission_worker(SceneId, [{mission_id, MissionId}, {?DICT_ACTIVITY_ID, Id}]).
%%
%%
%%%% @fun 活动结束 调用boss结算
%%close_action({ActivityId, _ActivityStartTime}) ->
%%    {_, SceneId} = get_world_boss_scene_id_By_ActivityId(ActivityId),
%%    case scene_master:get_scene_worker(SceneId) of
%%        {ok, SceneWorker} ->
%%            ?DEBUG("世界boss活动结束，结算副本~p", [{SceneWorker, ActivityId, SceneId}]),
%%            mod_mission:send_msg(SceneWorker, ?MSG_MISSION_BALANCE);
%%        _ ->
%%            noop
%%    end.
%%
%%
%%%% ----------------------------------
%%%% @doc 	初始化副本
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_init_mission(_ExtraDataList, MissionType, MissionId) ->
%%    mission_ranking:clean_ranking(MissionType, MissionId, 0),
%%    mission_ranking:init(MissionType, MissionId, 0).
%%
%%%% @fun 初始化副本boss
%%handle_init_mission_monster() ->
%%    MissionType = get(?DICT_MISSION_TYPE),
%%    MissionId = get(?DICT_MISSION_ID),
%%    ActivityId = util:get_dict(?DICT_ACTIVITY_ID, 0),
%%    #t_mission{
%%        boss_id = MonsterId
%%    } = mod_mission:get_t_mission(MissionType, MissionId),
%%    case util_list:key_find(ActivityId, 1, ?SD_WORLD_BOSS) of
%%        [ActivityId, _, X, Y, _] ->
%%            ?DEBUG("初始化世界boss怪物id ~p~n ", [{MonsterId, X, Y}]),
%%            self() ! {?MSG_SCENE_CREATE_MONSTER, MonsterId, X, Y};
%%        _ ->
%%            noop
%%    end.
%%
%%
%%%% ----------------------------------
%%%% @doc 	进入副本
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_enter_mission(PlayerId, #scene_state{mission_id = MissionId, mission_type = MissionType}) ->
%%    mission_ranking:notice_ranking([PlayerId], MissionType, MissionId, 0).
%%
%%%% ----------------------------------
%%%% @doc 	副本结算
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%handle_balance(_) ->
%%    MissionType = get(?DICT_MISSION_TYPE),
%%    MissionId = get(?DICT_MISSION_ID),
%%%%    ObjId = get(?DICT_KILL_DIE_LAST),
%%    ActivityId = get(?DICT_ACTIVITY_ID),
%%
%%    ?INFO("结算世界boss:~p    time:~p", [{ActivityId, MissionType, MissionId}, util_time:local_datetime()]),
%%
%%    #t_mission{
%%        boss_id = MonsterId
%%    } = mod_mission:get_t_mission(MissionType, MissionId),
%%
%%    mod_scene_monster_manager:destroy_all_monster(),    % 销毁所有怪物
%%    RankingList = mission_ranking:get_ranking_list(MissionType, MissionId, 0),
%%
%%    #t_monster{
%%        new_ling_li = ProbNum
%%    } = mod_scene_monster_manager:get_t_monster(MonsterId),
%%    {CalcRateList, RateTotalCunt} =
%%        lists:foldl(
%%            fun(#hurtranking{player_id = CurrPlayerId, hurt = CurrHurt}, {CalcRateList1, RateTotalCunt1}) ->
%%                {[{CurrPlayerId, CurrHurt} | CalcRateList1], CurrHurt + RateTotalCunt1}
%%            end, {[], 0}, RankingList),
%%    RateList =
%%        if
%%            RateTotalCunt >= ProbNum -> CalcRateList;
%%            true -> [{0, ProbNum - RateTotalCunt} | CalcRateList]
%%        end,
%%
%%%%    WinPlayerId = util_random:get_probability_item([{CurrPlayerId, CurrHurt} || #hurtranking{player_id = CurrPlayerId, hurt = CurrHurt} <- RankingList]),
%%    WinPlayerId = util_random:get_probability_item(RateList),
%%    {WinPlayerName, WinAwardList} =
%%        if
%%            WinPlayerId == 0 ->
%%                {"", []};
%%            true ->
%%                WinAwardList1 = [],
%%                #hurtranking{
%%                    player_name = WinPlayerName1
%%                } = lists:keyfind(WinPlayerId, #hurtranking.player_id, RankingList),
%%                {WinPlayerName1, WinAwardList1}
%%        end,
%%
%%    ActivityId = get(?DICT_ACTIVITY_ID),
%%    RankAwardList =
%%        case util_list:key_find(ActivityId, 1, ?SD_WORLD_BOSS) of
%%            [_, _, _, _, RankAwardL] -> RankAwardL;
%%            _ -> []
%%        end,
%%    RankMailId = ?MAIL_WORLD_BOSS_RANK,
%%    WinMailId = ?MAIL_WORLD_BOSS_KILL,
%%    balance_give_award_handle(1, RankingList, RankAwardList, RankMailId, {WinPlayerId, WinMailId, util:to_binary(WinPlayerName), WinAwardList}, []),
%%    activity_srv:cast({close, ActivityId, 30}),
%%%%    activity_srv_mod:gm_close_activity(ActivityId),
%%    ?DEBUG("准备关闭结算世界boss场景：~p~n", [{ActivityId, MonsterId, util_time:local_datetime()}]),
%%    scene_worker:stop(self(), ?SCENE_STOP_TIME).
%%
%%balance_give_award_handle(_Rank, _, [], _MailId, _WinTuple, _AwardList) -> noop;
%%balance_give_award_handle(_Rank, [], _, _MailId, _WinTuple, _AwardList) -> noop;
%%balance_give_award_handle(Rank, [#hurtranking{ranking = CurrRankId, player_id = PlayerId} | RankingList1] = RankingList, [[InitRank, EndRank, AwardId] | RankAwardL] = RankAwardList, MailId, {WinPlayerId, WinMailId, WinPlayerName, WinAwardList} = WinTuple, AwardList) ->
%%    if
%%        InitRank =< CurrRankId andalso CurrRankId =< EndRank ->
%%            NewAwardList =
%%                if
%%                    AwardList == [] ->
%%                        mod_prop:merge_prop_list(mod_award:decode_award(AwardId));
%%                    true ->
%%                        AwardList
%%                end,
%%            ShowWinAwardList =
%%                if
%%                    PlayerId == WinPlayerId ->
%%                        mod_mail:add_mail_item_list(PlayerId, WinMailId, WinAwardList, ?LOG_TYPE_MISSION_WORLD_BOSS),
%%                        WinAwardList;
%%                    true -> []
%%                end,
%%            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%                ?UNDEFINED ->
%%                    mod_mail:add_mail_param_item_list(PlayerId, MailId, NewAwardList, [CurrRankId], ?LOG_TYPE_MISSION_WORLD_BOSS),
%%                    noop;
%%                _ObjScenePlayer ->
%%                    mod_award:give(PlayerId, NewAwardList, ?LOG_TYPE_MISSION_WORLD_BOSS),
%%                    api_mission:notice_word_boss_settle(PlayerId, WinPlayerId, WinPlayerName, ShowWinAwardList, Rank, NewAwardList)
%%            end,
%%            balance_give_award_handle(Rank + 1, RankingList1, RankAwardList, MailId, WinTuple, NewAwardList);
%%        true ->
%%            balance_give_award_handle(Rank, RankingList, RankAwardL, MailId, WinTuple, [])
%%    end.
%%
%%%%%% @fun 副本结算 给奖励
%%%%balance_give_award([], _RankAwardList, _MailId, _ParticipateMailId, _MissTuple, _NewAwardList) ->
%%%%    ok;
%%%%balance_give_award([#hurtranking{player_id = PlayerId} | RankingList1], [], MailId, {ParticipateMailId, ParticipateAwardId} = ParticipateTuple, {ResultState, MissionType, MissionId} = MissTuple, AwardList) ->
%%%%    NewAwardList =
%%%%        if
%%%%            AwardList == [] ->
%%%%                mod_prop:merge_prop_list(mod_award:decode_award(ParticipateAwardId));
%%%%            true ->
%%%%                AwardList
%%%%        end,
%%%%    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%%%        ?UNDEFINED ->
%%%%            noop;
%%%%        _ObjScenePlayer ->
%%%%            api_mission:notice_mission_result(PlayerId, MissionType, MissionId, ResultState, NewAwardList)
%%%%    end,
%%%%    mod_mail:add_mail_award_id(PlayerId, ParticipateMailId, ParticipateAwardId, ?LOG_TYPE_MISSION_WORLD_BOSS),
%%%%    balance_give_award(RankingList1, [], MailId, ParticipateTuple, MissTuple, NewAwardList);
%%%%balance_give_award([#hurtranking{ranking = CurrRankId, player_id = PlayerId} | RankingList1] = RankingList, [[InitRank, EndRank, AwardId] | RankAwardList], MailId, {ParticipateMailId, ParticipateAwardId} = ParticipateTuple, {ResultState, MissionType, MissionId} = MissTuple, AwardList) ->
%%%%    if
%%%%        InitRank =< CurrRankId andalso CurrRankId =< EndRank ->
%%%%            NewAwardList =
%%%%                if
%%%%                    AwardList == [] ->
%%%%                        mod_prop:merge_prop_list(mod_award:decode_award(AwardId) ++ mod_award:decode_award(ParticipateAwardId));
%%%%                    true ->
%%%%                        AwardList
%%%%                end,
%%%%            mod_mail:add_mail_param_award_id(PlayerId, MailId, AwardId, [CurrRankId], ?LOG_TYPE_MISSION_WORLD_BOSS),
%%%%            mod_mail:add_mail_award_id(PlayerId, ParticipateMailId, ParticipateAwardId, ?LOG_TYPE_MISSION_WORLD_BOSS),
%%%%            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
%%%%                ?UNDEFINED ->
%%%%                    noop;
%%%%                _ObjScenePlayer ->
%%%%                    api_mission:notice_mission_result(PlayerId, MissionType, MissionId, ResultState, NewAwardList)
%%%%            end,
%%%%            balance_give_award(RankingList1, [[InitRank, EndRank, AwardId] | RankAwardList], MailId, ParticipateTuple, MissTuple, NewAwardList);
%%%%        true ->
%%%%            balance_give_award(RankingList, RankAwardList, MailId, ParticipateTuple, MissTuple, [])
%%%%    end.
%%
%%
%%%% @fun 获得世界boss 的场景id 和 副本id
%%get_world_boss_scene_id_By_ActivityId(ActivityId) ->
%%    [ActivityId, MissionId | _] = util_list:key_find(ActivityId, 1, ?SD_WORLD_BOSS),
%%    {MissionId, get_world_boss_scene_id(MissionId)}.
%%get_world_boss_scene_id(MissionId) ->
%%    SceneId = mod_mission:get_scene_id_by_mission(?MISSION_TYPE_WORLD_BOSS, MissionId),
%%    SceneId.
%%
%%%% @fun 是否能进入副本
%%is_enter_mission(PlayerId, MissionId) ->
%%    IsActivity = lists:any(fun([ActivityId | _]) ->
%%        mod_activity:is_open(PlayerId, ActivityId) end, ?SD_WORLD_BOSS),
%%    ?ASSERT(IsActivity, ?ERROR_ACTIVITY_NO_OPEN),
%%%%    mod_activity:try_is_open(PlayerId, ?ACT_WORLD_BOSS),
%%    SceneId = get_world_boss_scene_id(MissionId),
%%    case scene_master:get_scene_worker(SceneId) of
%%        {ok, SceneWorker} ->
%%            KeyValue = scene_worker:get_dict(SceneWorker, ?DICT_KILL_DIE_LAST),
%%            ?ASSERT(is_integer(KeyValue) == false, ?ERROR_NOT_ONLINE);
%%        _ ->
%%            exit(?ERROR_NOT_ONLINE)
%%    end.

%%%% @fun 获得世界boss 的怪物属性
%%get_monster_attr_list() ->
%%    MonsterAttrLevel = max(mod_server_data:get_int_data(?SERVER_DATA_WORLD_BOSS_LEVEL), 1),
%%    ?INFO("世界boss 的怪物属性等级:~p~n", [MonsterAttrLevel]),
%%%%    CurrTime = util_time:timestamp(),
%%%%    LastLoginTimeLimit = CurrTime - ?PLAYER_ONLINE_TIME_MONSTER_ATTR,
%%%%    {NewLevelCount, NewCountNum} =
%%%%        lists:foldl(
%%%%            fun(#db_player{id = PlayerId, last_login_time = LastLoginTime, last_offline_time = LastOfflineTime}, {LevelCount, CountNum}) ->
%%%%                NewPlayerId =
%%%%                    if
%%%%                        LastLoginTime > LastOfflineTime ->
%%%%                            PlayerId;
%%%%                        true ->
%%%%                            if
%%%%                                LastOfflineTime > LastLoginTimeLimit ->
%%%%                                    PlayerId;
%%%%                                true ->
%%%%                                    0
%%%%                            end
%%%%                    end,
%%%%                if
%%%%                    NewPlayerId > 0 ->
%%%%                        Level = mod_player:get_player_data(PlayerId, level),
%%%%                        {LevelCount + Level, CountNum + 1};
%%%%                    true ->
%%%%                        {LevelCount, CountNum}
%%%%                end
%%%%
%%%%            end, {0, 0}, mod_player:get_all_player()),
%%%%    MonsterAttrLevel = max(NewLevelCount div max(1, NewCountNum), 1),
%%    #t_world_boss{
%%        property_list = AttrList
%%    } = try_t_world_boss(MonsterAttrLevel),
%%    {MonsterAttrLevel, AttrList}.


%%================================================ 模板操作 ==================================================
%%%% @fun 获得世界boss 等级属性
%%try_t_world_boss(Level) ->
%%    Table = t_world_boss:get({Level}),
%%    ?IF(is_record(Table, t_world_boss), Table, exit({t_world_boss, {Level}})).


