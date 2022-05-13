%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. 9月 2021 下午 05:24:14
%%%-------------------------------------------------------------------
-module(match_scene).
-author("Administrator").

-include("scene.hrl").
-include("common.hrl").
-include("msg.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("match_scene.hrl").

%% API
-export([
    init/1,

    create_scene/2,
    enter_scene/5,

    get_t_mate/1
]).

-export([
    handle_msg/2,
    handle_player_enter/1,
    handle_player_leave/0,
    handle_use_skill/2
]).

-export([
    get_player_prop_num/1
]).

%% ============================================= FUNCTION END =======================================================

%% @doc 初始化
init(ExtraDataList) ->
    MatchSceneType = util_list:opt(match_scene_type, ExtraDataList),
    {player_id_list, PlayerIdList} = lists:keyfind(player_id_list, 1, ExtraDataList),
    {GameTime, StartCountDown, StartNum} =
        if
            MatchSceneType == match_scene_room ->
                [GameTime1, StartCountDown1, _, StartNum1, _, _SceneId] = ?SD_CUSTONMIZE_PARAMETER,
                {GameTime1, StartCountDown1, StartNum1};
            MatchSceneType == one_vs_one ->
                #t_bettle{
                    game_time = GameTime1,
                    start_countdown = StartCountDown1,
                    start = StartNum1,
                    skill_list = SkillList
                } = one_vs_one_srv_mod:get_t_bettle(util_list:opt(id, ExtraDataList)),
                lists:foreach(
                    fun(PlayerId) ->
                        put({one_vs_one_init_skill_list, PlayerId}, SkillList)
                    end,
                    PlayerIdList
                ),
                {GameTime1, StartCountDown1, StartNum1};
            true ->
                #t_mate{
                    game_time = GameTime1,
                    start_countdown = StartCountDown1,
                    start_list = StartNum1
                } = get_t_mate(util_list:opt(id, ExtraDataList)),
                {GameTime1, StartCountDown1, StartNum1}
        end,
    RankTime =
        case MatchSceneType of
            one_vs_one ->
                500;
            _ ->
                3 * ?SECOND_MS
        end,
    Now = util_time:milli_timestamp(),
    put(?DICT_MATCH_SCENE_TIME_CONFIG, {(Now + StartCountDown) div ?SECOND_MS, (Now + GameTime + StartCountDown) div ?SECOND_MS}),
    send_msg(GameTime + StartCountDown, ?MSG_MATCH_SCENE_BALANCE),
    init_rank(PlayerIdList, RankTime, StartNum).

%% @doc 初始化排行榜
init_rank(PlayerIdList, RankTime, StartNum) ->
    send_msg(RankTime, ?MSG_MATCH_SCENE_RANK),
    {_, List} = lists:foldl(
        fun(PlayerId, {TmpRank, TmpL}) ->
            Node = mod_player:get_game_node(PlayerId),
            {TmpRank + 1, [{TmpRank, PlayerId, 0, StartNum,
                case util:rpc_call(Node, api_player, pack_model_head_figure, [PlayerId], infinity) of
                    {'EXIT', _Error} ->
                        api_player:pack_model_head_figure(PlayerId, util:to_list(PlayerId), 0, 1, 0, 1, 0);
                    {badrpc, _Reason} ->
                        api_player:pack_model_head_figure(PlayerId, util:to_list(PlayerId), 0, 1, 0, 1, 0);
                    Data ->
                        Data
                end} | TmpL]}
        end,
        {1, []}, PlayerIdList
    ),
    put(?DICT_MATCH_SCENE_SCORE_RANK, lists:reverse(List)).

%% @doc 创建匹配场
create_scene(Id, PlayerIdList) ->
    #t_mate{
        scene = SceneId,
        cost_list = CostList,
        start_list = StartNum
    } = get_t_mate(Id),
    #t_scene{
        mana_attack_list = [ScenePropId, _]
    } = mod_scene:get_t_scene(SceneId),
    %% 启动场景进程
    {ok, SceneWorker} = scene_worker:start(SceneId, self(), [{id, Id}, {player_id_list, PlayerIdList}, {match_scene_type, match_scene}]),
%%    erlang:monitor(process, SceneWorker),
    lists:foreach(
        fun(PlayerId) ->
            Node = mod_player:get_game_node(PlayerId),
            mod_apply:apply_to_online_player(Node, PlayerId, ?MODULE, enter_scene, [PlayerId, SceneWorker, SceneId, [{ScenePropId, StartNum}], CostList], normal)
        end,
        PlayerIdList
    ).
%% @doc 控制进入匹配场
enter_scene(PlayerId, SceneWorker, SceneId, AddPropList, CostPropList) ->
    mod_match_scene:reset_match_data(),
    Tran =
        fun() ->
            lists:foreach(
                fun(PropId) ->
                    PropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
                    if
                        PropNum > 0 ->
                            mod_prop:decrease_player_prop(PlayerId, [PropId, PropNum], ?LOG_TYPE_MATCH_SCENE);
                        true ->
                            noop
                    end
                end,
                [?ITEM_ZIDAN, ?ITEM_JIFEN]
            ),
            mod_prop:decrease_player_prop(PlayerId, CostPropList, ?LOG_TYPE_MATCH_SCENE),
            mod_award:give(PlayerId, AddPropList, ?LOG_TYPE_MATCH_SCENE),
            {X, Y} = mod_scene:get_scene_birth_pos(SceneId),
            mod_scene:player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, [], null)
        end,
    db:do(Tran),
    ok.

%% ============================================= FUNCTION END =======================================================

%% =============================================== MSG START =======================================================
%% @doc 打包消息
pack_msg(Msg) ->
    {?MSG_SCENE_MATCH_SCENE, Msg}.

send_msg(DelayTime, Msg) ->
    erlang:send_after(DelayTime, self(), pack_msg(Msg)).

%% @doc 消息回调
handle_msg(Msg, SceneState) ->
    case Msg of
        ?MSG_MATCH_SCENE_RANK ->
            send_msg(3 * ?SECOND_MS, ?MSG_MATCH_SCENE_RANK),
            handle_rank();
        ?MSG_MATCH_SCENE_BALANCE ->
            handle_balance(SceneState);
        _ ->
            ?ERROR("~p 有消息不匹配 ： ~p", [?MODULE, Msg])
    end.

%% ============================================= MSG END =======================================================

%% ========================================== HANDLE_MSG START =======================================================

%% @doc 通知排行榜
handle_rank() ->
    List = lists:map(
        fun({_OldRank, PlayerId, OldScore, OldZiDan, ModelHeadFigure}) ->
            case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                ?UNDEFINED ->
                    {PlayerId, OldScore, OldZiDan, ModelHeadFigure};
                ObjScenePlayer ->
                    #obj_scene_actor{
                        sex = Sex,
                        nickname = Name,
                        level = Level,
                        vip_level = VipLevel,
                        surface = #surface{
                            head_id = HeadId,
                            head_frame_id = HeadFrameId
                        }
                    } = ObjScenePlayer,
                    NewModelHeadFigure = api_player:pack_model_head_figure(PlayerId, Name, Sex, HeadId, VipLevel, Level, HeadFrameId),
                    Node = mod_player:get_game_node(PlayerId),
                    {Score, ZiDan} = util:rpc_call(Node, ?MODULE, get_player_prop_num, [PlayerId], infinity),
                    {PlayerId, Score, ZiDan, NewModelHeadFigure}
            end
        end,
        get(?DICT_MATCH_SCENE_SCORE_RANK)
    ),
    SortList =
        lists:sort(
            fun({_, A_Score, A_ZiDan, _}, {_, B_Score, B_ZiDan, _}) ->
                if
                    A_Score > B_Score ->
                        true;
                    A_Score == B_Score ->
                        A_ZiDan >= B_ZiDan;
                    A_Score < B_Score ->
                        false
                end
            end,
            List
        ),
    {_, L} = lists:foldl(
        fun({PlayerId, Score, ZiDan, ModelHeadFigure}, {TmpRank, TmpList}) ->
            {TmpRank + 1, [{TmpRank, PlayerId, Score, ZiDan, ModelHeadFigure} | TmpList]}
        end,
        {1, []}, SortList
    ),
    NewL = lists:reverse(L),
    put(?DICT_MATCH_SCENE_SCORE_RANK, NewL),
    api_match_scene:notice_rank(mod_scene_player_manager:get_all_obj_scene_player_id(), api_match_scene:pack_rank_out(NewL)).

get_player_prop_num(PlayerId) ->
    {
        mod_prop:get_player_prop_num(PlayerId, ?ITEM_JIFEN),
        mod_prop:get_player_prop_num(PlayerId, ?ITEM_ZIDAN)
    }.

%% @doc 结算
handle_balance(#scene_state{scene_id = SceneId}) ->
    handle_rank(),
    ExtraDataList = get(?DICT_EXTRA_DATA),
    MatchSceneType = util_list:opt(match_scene_type, ExtraDataList),
    Id = util_list:opt(id, ExtraDataList),
    NewList = balance(SceneId, MatchSceneType, Id, ExtraDataList),
    api_match_scene:notice_result(mod_scene_player_manager:get_all_obj_scene_player_id(), NewList),
    mod_scene_monster_manager:destroy_all_monster(),
    scene_worker:stop(self(), ?SD_SETTLE_SECEDE).
balance(_SceneId, one_vs_one, Id, ExtraDataList) ->
    List = get(?DICT_MATCH_SCENE_SCORE_RANK),
    #t_bettle{
        rank_list = RankAwardList,
        mail_id = MailId,
        draw_id = DrawId
    } = one_vs_one_srv_mod:get_t_bettle(Id),
    [{_ARank, _APlayerId, AScore, _AZiDan, _AModelHeadFigure}, {_BRank, _BPlayerId, BScore, _BZiDan, _BModelHeadFigure}] = List,
    NewList =
        if
            AScore == BScore ->
                PropList1 =
                    mod_prop:merge_prop_list(lists:foldl(
                        fun([_Rank, RewardId], TmpL) ->
                            mod_award:decode_award(RewardId) ++ TmpL
                        end,
                        [], RankAwardList
                    )),
                PropList = mod_prop:rate_prop(PropList1, 0.5),
                Rank = 0,
                lists:map(
                    fun({_Rank, PlayerId, _Score, _ZiDan, ModelHeadFigure}) ->
                        if
                            PropList == [] ->
                                noop;
                            true ->
                                Node = mod_player:get_game_node(PlayerId),
                                case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                                    ?UNDEFINED ->
                                        PropNum = case lists:keyfind(?ITEM_RUCHANGJUAN, 1, PropList) of
                                                      false ->
                                                          0;
                                                      {?ITEM_RUCHANGJUAN, PropNum1} ->
                                                          PropNum1;
                                                      _ ->
                                                          0
                                                  end,
                                        mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, DrawId, PropList, [PropNum], ?LOG_TYPE_MATCH_SCENE], game_worker);
                                    _ ->
                                        mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give, [PlayerId, PropList, ?LOG_TYPE_MATCH_SCENE], game_worker)
                                end
                        end,
                        {Rank, PropList, ModelHeadFigure}
                    end,
                    List
                );
            true ->
                lists:map(
                    fun({Rank, PlayerId, _Score, _ZiDan, ModelHeadFigure}) ->
                        PropList =
                            case util_list:opt(Rank, RankAwardList) of
                                ?UNDEFINED ->
                                    [];
                                0 ->
                                    [];
                                AwardId ->
                                    mod_award:decode_award(AwardId)
                            end,
                        if
                            PropList == [] ->
                                noop;
                            true ->
                                Node = mod_player:get_game_node(PlayerId),
                                case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                                    ?UNDEFINED ->
                                        PropNum = case lists:keyfind(?ITEM_RUCHANGJUAN, 1, PropList) of
                                                      false ->
                                                          0;
                                                      {?ITEM_RUCHANGJUAN, PropNum1} ->
                                                          PropNum1;
                                                      _ ->
                                                          0
                                                  end,
                                        mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, MailId, PropList, [Rank, PropNum], ?LOG_TYPE_MATCH_SCENE], game_worker);
                                    _ ->
                                        mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give, [PlayerId, PropList, ?LOG_TYPE_MATCH_SCENE], game_worker)
                                end
                        end,
                        {Rank, PropList, ModelHeadFigure}
                    end,
                    List
                )
        end,
    one_vs_one_srv:cast({balance, Id, util_list:opt(room_id, ExtraDataList), [{Rank, PlayerId, Score} || {Rank, PlayerId, Score, _ZiDan, _ModelHeadFigure} <- List]}),
    NewList;
balance(SceneId, match_scene_room, _, ExtraDataList) ->
    List = get(?DICT_MATCH_SCENE_SCORE_RANK),
    ExtraDataList = get(?DICT_EXTRA_DATA),
    {cost, Cost} = lists:keyfind(cost, 1, ExtraDataList),
    lists:map(
        fun({Rank, PlayerId, _Score, _ZiDan, ModelHeadFigure}) ->
            PropList =
                case lists:nth(Rank, ?SD_CUSTONMIZE_REWARD) of
                    ?UNDEFINED ->
                        [];
                    0 ->
                        [];
                    Rate ->
                        [{?ITEM_RUCHANGJUAN, Cost * 4 * Rate div 100}]
                end,
            if
                PropList == [] ->
                    noop;
                true ->
                    Node = mod_player:get_game_node(PlayerId),
                    case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                        ?UNDEFINED ->
                            PropNum = case lists:keyfind(?ITEM_RUCHANGJUAN, 1, PropList) of
                                          false ->
                                              0;
                                          {?ITEM_RUCHANGJUAN, PropNum1} when PropNum1 > 0 ->
                                              PropNum1;
                                          _ ->
                                              0
                                      end,
                            mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, ?MAIL_SINGLE_AWARD, PropList, [SceneId, Rank, PropNum], ?LOG_TYPE_MATCH_SCENE], game_worker);
                        _ ->
                            mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give, [PlayerId, PropList, ?LOG_TYPE_MATCH_SCENE], game_worker)
%%                            mod_award:give()
                    end
            end,
            {Rank, PropList, ModelHeadFigure}
        end,
        List
    );
balance(SceneId, match_scene, Id, _ExtraDataList) ->
    List = get(?DICT_MATCH_SCENE_SCORE_RANK),
    #t_mate{
        rank_list = RankAwardList
    } = get_t_mate(Id),
    NewList =
        lists:map(
            fun({Rank, PlayerId, _Score, _ZiDan, ModelHeadFigure}) ->
                PropList =
                    case util_list:opt(Rank, RankAwardList) of
                        ?UNDEFINED ->
                            [];
                        0 ->
                            [];
                        AwardId ->
                            mod_award:decode_award(AwardId)
                    end,
                if
                    PropList == [] ->
                        noop;
                    true ->
                        Node = mod_player:get_game_node(PlayerId),
                        case ?GET_OBJ_SCENE_PLAYER(PlayerId) of
                            ?UNDEFINED ->
                                PropNum = case lists:keyfind(?ITEM_RUCHANGJUAN, 1, PropList) of
                                              false ->
                                                  0;
                                              {?ITEM_RUCHANGJUAN, PropNum1} ->
                                                  PropNum1;
                                              _ ->
                                                  0
                                          end,
                                mod_apply:apply_to_online_player(Node, PlayerId, mod_mail, add_mail_param_item_list, [PlayerId, ?MAIL_SINGLE_AWARD, PropList, [SceneId, Rank, PropNum], ?LOG_TYPE_MATCH_SCENE], game_worker);
                            _ ->
                                mod_apply:apply_to_online_player(Node, PlayerId, mod_award, give, [PlayerId, PropList, ?LOG_TYPE_MATCH_SCENE], game_worker)
                        end
                end,
                {Rank, PropList, ModelHeadFigure}
            end,
            List
        ),
    gen_server:cast(match_scene_srv, {balance, Id, lists:keyfind(1, 1, List)}),
    NewList.

%% @doc 玩家进入场景
handle_player_enter(PlayerId) ->
    api_match_scene:notice_rank(PlayerId, api_match_scene:pack_rank_out(get(?DICT_MATCH_SCENE_SCORE_RANK))),
    {StartTime, EndTime} = get(?DICT_MATCH_SCENE_TIME_CONFIG),
    case get({one_vs_one_init_skill_list, PlayerId}) of
        ?UNDEFINED ->
            noop;
        SkillList ->
            api_one_vs_one:notice_scene_skill_limit(PlayerId, SkillList)
    end,
    api_match_scene:notice_time(PlayerId, StartTime, EndTime).

%% @doc 玩家离开场景
handle_player_leave() ->
    handle_rank().

%% @doc 玩家使用技能
handle_use_skill(PlayerId, SkillId) ->
    case get({one_vs_one_init_skill_list, PlayerId}) of
        ?UNDEFINED ->
            noop;
        SkillList ->
            case util_list:key_take(SkillId, 1, SkillList) of
                false ->
                    noop;
                {value, [SkillId, Times], List1} ->
                    if
                        Times > 0 ->
                            put({one_vs_one_init_skill_list, PlayerId}, [[SkillId, Times - 1] | List1]);
                        true ->
                            exit(fail)
                    end
            end
%%            api_one_vs_one:notice_scene_skill_limit(PlayerId, SkillList)
    end.

%% ========================================== HANDLE_MSG END =======================================================

%% ================================================ 模板操作 ================================================
%% @doc 匹配场数据
get_t_mate(Id) ->
    t_mate:assert_get({Id}).