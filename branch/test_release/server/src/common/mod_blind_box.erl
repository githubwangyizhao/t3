%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 8月 2021 下午 05:57:17
%%%-------------------------------------------------------------------
-module(mod_blind_box).
-author("Administrator").

-include("msg.hrl").
-include("scene.hrl").
-include("error.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("p_message.hrl").
-include("gen/table_db.hrl").

%% API
-export([
    handle_start/1,             %% 盲盒开始
    handle_fight/4,             %% 打死盲盒后的奖励
    handle_notice_reward/0     %% 通知结算
]).

-record(?MODULE, {
    boxes_num = 0,                 %% 剩余盲盒数量
    record_rewards = []            %% 盲盒期间玩家的奖励记录
}).

%% 通知箱子结算
handle_notice_reward() ->
    AllRewardOut =
        lists:foldl(
            fun(Data, Tmp) ->
                {PlayerId, RewardList, ModelHeadFigureOut} =
                    case Data of
                        {PlayerId1, RewardList1} ->
                            {PlayerId1, RewardList1, api_player:pack_model_head_figure(PlayerId1)};
                        {PlayerId1, RewardList1, ModelHeadFigureOut1} ->
                            {PlayerId1, RewardList1, ModelHeadFigureOut1}
                    end,
                [#'m_fight_blind_box_reward_toc.blindboxreward'{
                    player_id = PlayerId,
                    model_head = ModelHeadFigureOut,
                    grand_price = 0,
                    award_list = [#prop{prop_id = PropId, num = Num} || {PropId, Num} <- RewardList]
                }] ++ Tmp
            end,
            [],
            ?getModDict(record_rewards)
        ),
    mod_socket:send_to_player_list(
        mod_scene_player_manager:get_all_obj_scene_player_id(),
        proto:encode(
            #m_fight_blind_box_reward_toc{
                blind_box_reward = AllRewardOut
            }
        )
    ).

set_player_blind_box_award(_PlayerId, _PropId, -1) -> noop;
set_player_blind_box_award(PlayerId, PropId, Num) ->
    OldRecords = ?getModDict(record_rewards),
    NewBlindBoxReward =
        case lists:keytake(PlayerId, 1, OldRecords) of
            false ->
                if
                    PlayerId < 10000 ->
                        #obj_scene_actor{
                            nickname = Nickname,
                            sex = Sex,
                            level = Level,
                            vip_level = VipLevel,
                            surface = #surface{
                                head_id = HeadId,
                                head_frame_id = HeadFrameId
                            }
                        } = ?GET_OBJ_SCENE_PLAYER(PlayerId),
                        [{PlayerId, [{PropId, Num}], api_player:pack_model_head_figure(PlayerId, Nickname, Sex, HeadId, VipLevel, Level, HeadFrameId)} | OldRecords];
                    true ->
                        [{PlayerId, [{PropId, Num}]} | OldRecords]
                end;
            {value, {PlayerId, OldRewardList}, RestRecords} ->
                NewRewardList = mod_prop:merge_prop_list([{PropId, Num} | OldRewardList]),
                [{PlayerId, NewRewardList} | RestRecords];
            {value, {PlayerId, OldRewardList, HeadFigure}, RestRecords} ->
                NewRewardList = mod_prop:merge_prop_list([{PropId, Num} | OldRewardList]),
                [{PlayerId, NewRewardList, HeadFigure} | RestRecords]
        end,
    ?setModDict(record_rewards, NewBlindBoxReward).

%% 处理盲盒被打消失
handle_fight(SceneId, AttObjSceneActor, DefObjSceneActor, Cost) ->
    #obj_scene_actor{
        obj_id = PlayerId
    } = AttObjSceneActor,

    #obj_scene_actor{
        obj_id = DefObjId,
        x = DefX,
        y = DefY,
        effect = EffectList
    } = DefObjSceneActor,

    ScenePropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
    [_, EffectType1] = EffectList,
    BlindBoxAwardList = logic_get_function_monster_blind_box_weights_list:assert_get(EffectType1),
    SceneAdjustValue = scene_adjust:get_scene_adjust_rate_value(SceneId),
    [_Id, RewardPer, AwardList1] = mod_scene_event:get_rand_result(BlindBoxAwardList, SceneAdjustValue),
    ManoAward =
        if
        %% 没奖励的
            AwardList1 =:= []; AwardList1 =:= [[]] ->
                ManoAward0 = ?IF(RewardPer =/= 0, util:to_int(round(Cost * RewardPer / 10000)), -1),
                set_player_blind_box_award(PlayerId, ScenePropId, ManoAward0),
                ManoAward0;
            true ->
                ManoAwardList =
                    lists:filtermap(
                        fun([PropId1, Num1]) ->
                            RealNum = ?IF(RewardPer =/= 0, round(Cost * RewardPer / 10000) + Num1, Num1),
                            set_player_blind_box_award(PlayerId, PropId1, RealNum),
                            if
                                PropId1 =:= ?ITEM_GOLD ->
                                    {true, util:to_list(Num1)};
                                true -> %% 宝箱怪被打死位置掉落奖励
                                    mod_scene_item_manager:drop_item_list(DefObjId, PlayerId, [{PropId1, RealNum}], DefX, DefY),
                                    false
                            end
                        end,
                        AwardList1
                    ),
                ?IF(length(ManoAwardList) =:= 0, 0, util:to_int(hd(ManoAwardList)))
        end,
    mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_BOX_PLAYER_OPEN_COUNT),
    case ?incrModDict(boxes_num, - 1) =< 0 of
        true -> %% 箱子打完了
            mod_scene_event_manager:send_msg(?MSG_SCENE_LOOP_BOX_FINISHED);
        false ->
            skip
    end,
    ManoAward.

%% 处理开启盲盒
handle_start(_SceneState = #scene_state{scene_id = SceneId}) ->
    PlayerCounter = mod_scene_player_manager:get_obj_scene_player_count(),
    BlindBoxNum = proplists:get_value(PlayerCounter, ?SD_MONSTER_FUNCTION_BAOXIANG_COUNT_LIST, 30),
    ?DEBUG("===> 初始盲盒个数 ~p", [BlindBoxNum]),
    ?setModDict(boxes_num, BlindBoxNum),        %% 初始盲盒个数
    ?setModDict(record_rewards, []),            %% 初始奖励信息
    #t_scene{
        new_monster_x_y_list = NewMonsterXYList
    } = mod_scene:get_t_scene(SceneId),
    [_,_,_,XyList] = util_list:key_find(?SD_MONSTER_FUNCTION_BAOXIANG_X_Y_GROUP, 1, NewMonsterXYList),
    Length = length(XyList),
    List1 = lists:merge(lists:duplicate(BlindBoxNum div Length, XyList)),
    List2 = lists:sublist(util_list:shuffle(XyList), BlindBoxNum rem Length),
    NewList = util_list:shuffle(List2 ++ List1),
    put({?MODULE, build_box_pos_list}, NewList),
    util:run(
        fun() ->
%%            [X2, Y2] = mod_scene_event_manager:get_random_pos_1(),
%%            [X3, Y3] = [X2 + util_random:random_number(-400, 400), Y2 + util_random:random_number(-400, 400)],
%%            [X4, Y4] =
%%                case mod_map:can_walk_pix(get(?DICT_MAP_ID), X3, Y3) of
%%                    true ->
%%                        [X3, Y3];
%%                    _ ->
%%                        [X2, Y2]
%%                end,
            List = get({?MODULE, build_box_pos_list}),
            [[X, Y] | PosList] = List,
            put({?MODULE, build_box_pos_list}, PosList),
            {SceneId, WeightList1, WeightList2} = lists:keyfind(SceneId, 1, ?SD_MONSTER_FUNCTION_BAOXIANG_MONSTER_LIST),
            SceneAdjustValue = scene_adjust:get_scene_adjust_rate_value(SceneId),
            RndResult = util_random:p(30000 - 5 * SceneAdjustValue / 2),
            MonsterId =
                case RndResult of
                    true ->
                        util_random:get_probability_item(WeightList1);
                    false ->
                        util_random:get_probability_item(WeightList2)
                end,
            mod_scene_event_manager:send_msg({?MSG_SCENE_LOOP_CREATE_MONSTER_GUAJI, mod_scene_event_manager:get_state(), MonsterId, X, Y})
        end,
        BlindBoxNum
    ),
    ok.
