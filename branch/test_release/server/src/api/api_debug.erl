%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            debug调试
%%% @end
%%% Created : 07. 十二月 2017 下午 3:50
%%%-------------------------------------------------------------------
-module(api_debug).
-include("p_message.hrl").
-include("common.hrl").
-include("gen/table_enum.hrl").
-include("p_enum.hrl").
-include("gen/db.hrl").
-include("msg.hrl").
-include("scene.hrl").
-include("gen/table_db.hrl").
%% API
-export([
    debug/2
]).

-export([
    create_monster/2
]).

debug(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_debug_debug_tos{type = Type, param_list = ParamList} = Msg,
    ?DEBUG("debug调试:~p~n", [{Type, ParamList}]),
    ?ASSERT(?IS_DEBUG),
    Result =
        try
            case Type of
                1 ->
                    % 给道具
%%                ?DEBUG_GIVE_PROP ->
                    [PropId, Num] = ParamList,
                    ?ASSERT(t_item:get({PropId}) =/= null, item_found),
%%                    mod_prop:check_valid(PropId),
                    mod_award:give(PlayerId, [{PropId, Num}], ?LOG_TYPE_GM);
                2 ->
                    % 调任务
                    [TaskId] = ParamList,
                    mod_task:debug_set_task(PlayerId, TaskId);
                3 ->
                    % 调等级
                    [Level] = ParamList,
                    mod_player:add_level(PlayerId, Level, ?LOG_TYPE_GM);
                4 ->
                    % 增加vip经验
                    [VipExp] = ParamList,
                    mod_player:add_vip_exp(PlayerId, VipExp, ?LOG_TYPE_GM);
                5 ->
                    % 进入场景
                    [SceneId] = ParamList,
                    mod_scene:player_enter_scene(PlayerId, SceneId);
                6 ->
                    % 调副本
                    [MissionType, MissionId] = ParamList,
                    mod_mission:direct_finish(PlayerId, MissionType, MissionId);
                7 ->
                    %% 调邀请
                    [InvitePlayerId] = ParamList,
                    #db_player{
                        acc_id = AccId,
                        server_id = ServerId,
                        nickname = Nickname
                    } = mod_player:get_player(PlayerId),
                    %% 10279
                    FriendCode = mod_unique_invitation_code:encode(InvitePlayerId),
                    mod_share:deal_invite(AccId, PlayerId, FriendCode, ServerId ++ "." ++ Nickname);
                8 ->
                    case ParamList of
                        [PropId, Num] ->
                            mod_prop:assert_prop_num(PlayerId, [{PropId, Num}]),
                            mod_prop:decrease_player_prop(PlayerId, [{PropId, Num}], 1);
                        [PropId] ->
                            PropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
                            if
                                PropNum > 0 ->
                                    mod_prop:decrease_player_prop(PlayerId, [{PropId, PropNum}], 1);
                                true ->
                                    noop
                            end
                    end;
                10 ->
                    case ParamList of
                        [1, SummonType, Times] ->
                            %% 模拟抽卡多少次
%%                            ?DEBUG("最后的结果~p, 参数 ~p", [ItemList, {PlayerId, ParamList}]),
                            ItemList = lists:foldl(
                                fun(_ThisTimes, TmpList) ->
                                    {ok, AwardList} = mod_card_summon:do_summon(PlayerId, SummonType),
                                    mod_prop:merge_prop_list(AwardList ++ TmpList)
                                end,
                                [], lists:seq(1, Times)
                            ),
                            FileName = "/opt/doc/test.log",
                            util_file:save_term(FileName, {ParamList, ItemList});
                        [2, SeizeType, Times] ->
                            TreasureHuntTypeId = mod_seize_treasure:seize_type(),
                            ItemList =
                                lists:foldl(
                                    fun(_SingleTimes, Tmp) ->
                                        Res =
                                            case catch mod_seize_treasure:seize(PlayerId, TreasureHuntTypeId, SeizeType) of
                                                {PropList, Seize, LuckyValue, _PosList} ->
                                                    {PropList, Seize, LuckyValue};
                                                {'EXIT', R} -> R
                                            end,
                                        [Res | Tmp]
                                    end,
                                    [], lists:seq(1, ?IF(SeizeType =:= 0, Times, Times / 5))
                                ),
                            FileName = "F:/projects/t3_server/doc/test.log",
%%                            ?DEBUG("ItemList: ~p", [ItemList]),
%%                            FileName = "/opt/doc/test.log",
                            util_file:save_term(FileName, {ParamList, ItemList});
                        [3, LaBaId, Cost, Times] ->
                            File = "/opt/doc/test.log",
                            filelib:ensure_dir(File),
                            {ok, Fp} = file:open(File, [write]),
                            LaBaCfgInfo = lists:keysort(1, [{Id, RateList, Weight} || #t_laba_icon{id = Id, data_list = RateList, data = Weight} <- t_laba_icon@group:get(LaBaId)]),
                            io:format(Fp, " config: ~p~n", [LaBaCfgInfo]),
                            io:format(Fp, " =============", []),
                            lists:foldl(
                                fun(_, N) ->
                                    case mod_laba:laba_spin(PlayerId, LaBaId, Cost) of
                                        %% 百搭拉霸机
                                        {ok, GridLists, RewardNums, FreeGameResults, FreeGameRewardNumLists} ->
                                            io:format(Fp,
                                                "~n"
                                                "   times: ~p~n"
                                                "   grids_list: ~p~n"
                                                "   combos: ~w~n"
                                                "   freegame_results: ~p~n"
                                                "   freegame_combos: ~w~n"
                                                "------------------------------",
                                                [N, GridLists, RewardNums, FreeGameResults, FreeGameRewardNumLists]
                                            );
                                        %% 连线拉霸机
                                        {ok, GridList, SpecialGridList, RewardNum, FGGridLists, FGSpecialGridLists, FGRewardNumList} ->
                                            io:format(Fp,
                                                "~n"
                                                "   times: ~p~n"
                                                "   grid_list: ~w~n"
                                                "   special_grid_list: ~w~n"
                                                "   rewardnum: ~p~n"
                                                "   fg_grid_lists: ~w~n"
                                                "   fg_special_grid_lists: ~w~n"
                                                "   fg_rewardnum_list: ~w~n"
                                                "------------------------------",
                                                [N, GridList, SpecialGridList, RewardNum, FGGridLists, FGSpecialGridLists, FGRewardNumList]
                                            );
                                        _ ->
                                            io:format(Fp, "~p~n", [{unhandlelaba, LaBaId, Cost}])
                                    end,
                                    N + 1
                                end,
                                1,
                                lists:seq(1, Times)
                            ),
                            file:close(Fp);
                        _ ->
                            noop
                    end;
                11 ->
                    [MonsterId] = ParamList,
                    #ets_obj_player{
                        scene_id = SceneId,
                        scene_worker = SceneWorker
                    } = mod_obj_player:get_obj_player(PlayerId),
                    #t_scene{
                        type = SceneType
                    } = mod_scene:get_t_scene(SceneId),
                    ?ASSERT(SceneType == ?SCENE_TYPE_WORLD_SCENE),
                    erlang:send(SceneWorker, {apply, ?MODULE, create_monster, [PlayerId, MonsterId]});
                12 ->
                    #ets_obj_player{
                        scene_worker = SceneWorker
                    } = mod_obj_player:get_obj_player(PlayerId),
                    ?DEBUG("SceneWorker: ~p", [SceneWorker]),
                    ?DEBUG("fff: ~p", [SceneWorker ! ?MSG_SCENE_ASYNC_INIT]);
                13 ->
                    mod_player:add_level(PlayerId, 99, ?LOG_TYPE_GM),
                    mod_player:add_vip_exp(PlayerId, 500000, ?LOG_TYPE_GM),
                    PropNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_GOLD),
                    if
                        PropNum > 0 ->
                            mod_prop:decrease_player_prop(PlayerId, [{?ITEM_GOLD, PropNum}], 1);
                        true ->
                            noop
                    end,
                    mod_award:give(PlayerId, [{?ITEM_RMB, 1000000}], ?LOG_TYPE_GM);
                14 ->
                    [Id] = ParamList,
                    match_scene:create_scene(Id, [PlayerId]);
                _ ->
                    exit(unknow_debug),
                    ?ERROR("Unknow debug:~p", [{Msg}])
            end of
            _ ->
                ?P_SUCCESS
        catch
            _:Reason ->
                ?ERROR("debug fail:~p~n", [{Msg, Reason}]),
                ?P_FAIL
        end,
    Out = proto:encode(#m_debug_debug_toc{result = Result, type = Type}),
    mod_socket:send(Out),
    State.

create_monster(PlayerId, MonsterId) ->
    #obj_scene_actor{
        x = X,
        y = Y
    } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    CreateMonsterArgs = #create_monster_args{
        monster_id = MonsterId,
        birth_x = X,
        birth_y = Y,
        is_notice = true
    },
    erlang:send(self(), {?MSG_SCENE_CREATE_MONSTER_BY_ARGS, CreateMonsterArgs}).
