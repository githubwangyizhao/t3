%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         抽奖
%%% @end
%%% Created : 28. 五月 2021 下午 05:36:49
%%%-------------------------------------------------------------------
-module(mod_shen_long).
-author("Administrator").

-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("error.hrl").
-include("msg.hrl").
-include("scene.hrl").

%% API
-export([
    draw/1,

    handle_shen_long_draw/1,

    get_t_monster_function_shenlongzhufu/2
]).

%% @doc 抽奖
draw(PlayerId) ->
    #ets_obj_player{
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    CostList = ?SD_MONSTER_FUNCTION_SHENLONGZHUFU_COST_LIST,
    mod_prop:assert_prop_num(PlayerId, CostList),
    {ok, Type, Id} =
        case catch gen_server:call(SceneWorker, {?MSG_SCENE_SHEN_LONG_DRAW, PlayerId}) of
            {error, Reason} ->
                exit(Reason);
            Result ->
                Result
        end,
    #t_monster_function_shenlongzhufu{
        reward_item_list = RewardItemList,
        is_bless = IsBless
    } = get_t_monster_function_shenlongzhufu(Type, Id),
    if
        RewardItemList =:= [] ->
            noop;
        true ->
            Tran =
                fun() ->
                    mod_prop:decrease_player_prop(PlayerId, CostList, ?LOG_TYPE_SHEN_LONG),
                    mod_award:give(PlayerId, [RewardItemList], ?LOG_TYPE_SHEN_LONG),
                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_SHENLONG_COUNT, ?CONDITIONS_VALUE_ADD, 1}),
                    scene_notice:shen_long_draw_award(PlayerId, RewardItemList)
                end,
            db:do(Tran)
    end,
    ?IF(?TRAN_INT_2_BOOL(IsBless), scene_notice:get_shen_long_buff(PlayerId), noop),
    {ok, Type, Id}.

%% @doc 神龙抽奖
handle_shen_long_draw(PlayerId) ->
    {IsOpen, {SceneEventType, Arg, CloseTime}} = mod_scene_event_manager:get_scene_event_value(),
    ?ASSERT(IsOpen andalso SceneEventType =:= 16, ?ERROR_NOT_AUTHORITY),
    WeightList = logic_get_shenlongzhufu_weights_list:assert_get(Arg),
    Id = util_random:get_probability_item(WeightList),
    #t_monster_function_shenlongzhufu{
        is_bless = IsBless
%%        reward_item_list = RewardItemList
    } = mod_shen_long:get_t_monster_function_shenlongzhufu(Arg, Id),
    if
        IsBless =:= ?TRUE ->
            PlayerObjActor = ?GET_OBJ_SCENE_PLAYER(PlayerId),
            Now = util_time:milli_timestamp(),
            mod_scene_event_manager:set_scene_event_value({false, {SceneEventType, Arg, CloseTime}}),
            ?UPDATE_OBJ_SCENE_ACTOR(PlayerObjActor#obj_scene_actor{shen_long_time = Now + ?SD_MONSTER_FUNCTION_SHENLONGZHUFU_TIME}),
            api_shen_long:notice_scene_shen_long_state(mod_scene_player_manager:get_all_obj_scene_player_id(), ?FALSE, ?UNDEFINED, ?UNDEFINED, PlayerObjActor#obj_scene_actor.nickname, PlayerObjActor#obj_scene_actor.obj_id),
            lists:foreach(
                fun(ThisPlayerId) ->
                    Fun =
                        fun() ->
                            Num = mod_prop:get_player_prop_num(ThisPlayerId, ?ITEM_BLESS_COIN),
                            ?IF(Num > 0, mod_prop:decrease_player_prop(ThisPlayerId, [{?ITEM_BLESS_COIN, Num}], ?LOG_TYPE_SHEN_LONG), noop)
                        end,
                    mod_apply:apply_to_online_player(ThisPlayerId, util, run, [Fun, 1])
                end,
                mod_scene_player_manager:get_all_obj_scene_player_id()
            ),
            api_scene:notice_special_skill_change(mod_scene_player_manager:get_all_obj_scene_player_id(), PlayerId, 0, ?SD_MONSTER_FUNCTION_SHENLONGZHUFU_ID, round((Now + ?SD_MONSTER_FUNCTION_SHENLONGZHUFU_TIME) / 1000));
        true ->
            %% @todo 没加修正
            noop
%%            server_fight_adjust:add_award(RewardItemList)
    end,
    {ok, Arg, Id}.

get_t_monster_function_shenlongzhufu(Type, Id) ->
    t_monster_function_shenlongzhufu:assert_get({Type, Id}).
