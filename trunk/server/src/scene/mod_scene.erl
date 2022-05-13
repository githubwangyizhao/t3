%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            场景
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_scene).
-include("scene.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("msg.hrl").
-include("error.hrl").
-include("client.hrl").
-include("skill.hrl").
-include("player_game_data.hrl").
-include("p_enum.hrl").
-include("system.hrl").
-include("p_message.hrl").
%API
%%玩家场景接口
-export([

    add_fight_fanpai/2,
    get_fight_fanpai/1,
    deal_fight_fanpai/1,
    return_world_scene/1,                   %% 从副本返回到世界场景
    return_world_scene/2,
    return_world_scene/3,
    async_return_world_scene/1,
%%    player_rebirth/1,                       %% 玩家复活
    player_enter_scene_when_enter_game/1,   %% 玩家进入场景(登录时)
    player_transmit/4,                      %% 传送
    player_transmit/5,

    player_enter_world_scene/2,             %% 玩家进入世界场景
    player_enter_single_world_scene/2,      %% 玩家进入单人世界场景
    player_enter_scene/1,                   %% 玩家进入场景
    player_enter_scene/2,
    player_enter_scene/3,
    player_enter_scene/4,
%%    player_enter_scene/5,
    player_enter_scene/6,
%%    server_control_scene_id_list/0,
    player_prepare_enter_scene/7,
    is_server_control_scene/1,
    do_player_enter_scene/3,
    get_player_pos/1,                       %% 获取玩家位置
    get_player_pos/2,
    query_player_pos/1,                     %% 查询玩家位置
    get_scene_player_id_list/2,             %% 获取该玩家所在场景玩家id列表
    player_move/7,                          %% 玩家移动
    player_move_step/3,                     %% 玩家移动step
    player_stop_move/3,                     %% 玩家停止
%%    player_jump_step/3,                   %% 玩家跳跃step
    player_leave_scene/1,                   %% 玩家离开场景
    player_leave_scene/2,
    create_enter_scene_data/1,
%%    create_robot/2,
    get_random_pos/4,
    get_player_id_list_by_scene_id/1,       %% 获取该场景的所有玩家id
    player_join_monster_point/2,
    player_change_scene/5,                  %% 玩家改变场景
    challenge_boss/1,                       %% 挑战boss
    send_msg/3                              %% 发送消息
]).

-export([
    tran_push_player_data_2_scene/2,        %% 玩家数据 => 场景玩家数据 (事务)
    push_player_data_2_scene/2,             %% 玩家数据 => 场景玩家数据
    is_scene_worker/0,                      %% 是否场景进程
    pack_sync_player_data/2,
    pack_enter_scene_data/6,
    pack_enter_scene_data/7,
    get_r_scene_monster/1,
    get_scene_birth_pos/1,                  %% 获取场景复活点
    get_scene_server_type/1,
    assert_not_server_control/0,              %% 确保非竞技场
    is_world_scene/1,                       %% 是否世界场景
    get_scene_type/1,                       %% 获取场景类型
    is_mission_scene/1,                     %% 是否副本场景
    is_zone_scene/1,                       %% 是否跨服场景
    is_war_scene/1,                         %% 是否战区场景
    is_hook_scene/1,                        %% 是否挂机场景
    get_player_count/1,                     %% 获取场景人数
    deal_move/4,                            %% 处理移动
    save_player_scene_pos/2,                %% 保存玩家场景位置
    save_player_scene_pos/4,
    change_obj_scene_attr_attr/2,           %% 调整场景对象属性
    get_scene_name/1,                       %% 获取场景名字
%%    is_server_control_scene/0,                     %% 是否竞技场
    is_offline_reconnect_scene/3,           %% 该场景是否断线重连
    get_random_pix_pos/3,                   %% 获取随机范围内像素位置
    get_scene_npc_pos/2,
    get_scene_gather_list/1,
    broadcast_chat_msg/1,
%%    get_scene_max_player_count/1,           %% 获取场景容许最大玩家数量
    get_all_scene_id/0,                     %% 获取所有场景id
%%    get_all_battle_ground_scene_id/0,       %% 获取所有战场场景id
    get_all_world_scene_id_by_server_type/1,
    get_all_world_scene_id/0,                %% 获取所有世界场景id
    show_action/2
]).

-export([
    get_t_scene/1                           % 获取场景
%%    try_get_t_scene_select/1        % 选择场景数据
]).

-export([
    deal_move_step/3,
    update_move_speed/1,
    update_move_speed/2
]).

-export([
    get_scene_dict/2
]).

-export([
    write_scene_log/2
]).

get_scene_dict(PlayerId, DictKey) ->
    #ets_obj_player{
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    scene_worker:get_dict(SceneWorker, DictKey).

%% ----------------------------------
%% @doc 	是否是场景进程
%% @throws 	none
%% @end
%% ----------------------------------
is_scene_worker() ->
    ?PROCESS_TYPE == ?PROCESS_TYPE_SCENE_WORKER.

%% ----------------------------------
%% @doc 	推送玩家信息到场景
%% @throws 	none
%% @end
%% ----------------------------------
tran_push_player_data_2_scene(PlayerId, SyncDataList) ->
    F = fun() ->
        push_player_data_2_scene(PlayerId, SyncDataList)
        end,
    db:tran_apply(F).

push_player_data_2_scene(PlayerId, SyncDataList) ->
    case catch do_sync_player_data_2_scene(PlayerId, SyncDataList) of
        {'EXIT', Reason} ->
            %% 推送场景失败
            ?WARNING("push_player_data error:~p~n reason:~p", [SyncDataList, Reason]),
            false;
        _ ->
            true
    end.

do_sync_player_data_2_scene(PlayerId, SyncDataList) when is_integer(PlayerId) ->
    do_sync_player_data_2_scene(mod_obj_player:get_obj_player(PlayerId), SyncDataList);
do_sync_player_data_2_scene(ObjPlayer, SyncDataList) when is_record(ObjPlayer, ets_obj_player) ->
    #ets_obj_player{
        id = PlayerId,
        scene_worker = SceneWorker
    } = ObjPlayer,
    case util:is_pid_alive(SceneWorker) of
        true ->
            SceneWorker ! pack_sync_player_data(PlayerId, SyncDataList);
        false ->
            noop
    end;
do_sync_player_data_2_scene(null, _SyncDataList) ->
    noop.

pack_sync_player_data(PlayerId, SyncDataList) ->
    {?MSG_SCENE_SYNC_PLAYER_DATA, PlayerId, SyncDataList}.


%% ----------------------------------
%% @doc 	获取场景复活点
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_birth_pos(SceneId) when is_integer(SceneId) ->
    R = get_t_scene(SceneId),
    if R#t_scene.random_birth_list == [] ->
        {R#t_scene.birth_x, R#t_scene.birth_y};
        true ->
            case erlang:hd(util_list:shuffle(R#t_scene.random_birth_list)) of
                [BirthX, BirthY] ->
                    {BirthX, BirthY};
                {BirthX, BirthY} ->
                    {BirthX, BirthY}
            end
    end.

%%%% ----------------------------------
%%%% @doc 	确保场景可以进去
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
assert_enter_scene(PlayerId, EnterSceneId) ->
    ?ASSERT(is_can_enter_scene(PlayerId, EnterSceneId) == ?TRUE, ?ERROR_NEED_POWER).

is_can_enter_scene(PlayerId, EnterSceneId) ->
    #t_scene{
        enter_conditions_list = EnterConditionsList,
        mana_enter_list = EnterLingLingList,
        mana_attack_list = ManaAttackList
    } = get_t_scene(EnterSceneId),
    AssertPropId =
        case ManaAttackList of
            [] ->
                ?ITEM_GOLD;
            [AccertPropId1, _] ->
                AccertPropId1
        end,
%%    if NeedPower == 0 ->
%%        noop;
%%        true ->
%%            PlayerPower = mod_player:get_player_data(PlayerId, power),
%%            ?ASSERT(PlayerPower >= NeedPower, ?ERROR_NEED_POWER)
%%    end,
    if
        EnterConditionsList == [] -> noop;
        true -> ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, EnterConditionsList), ?ERROR_NOT_AUTHORITY)
    end,

    case EnterLingLingList of
        [] ->
            ?TRUE;
        [LingMin, LingMax] ->
            ManaNum = mod_prop:get_player_prop_num(PlayerId, AssertPropId),
%%            GoldNum = mod_prop:get_player_prop_num(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_GOLD),
%%            CurrNum = ManaNum + GoldNum,
            if LingMin =< ManaNum andalso (LingMax == 0 orelse ManaNum =< LingMax) -> ?TRUE;
                true -> exit(?ERROR_NO_ENOUGH_PROP)
            end;
        true -> ?TRUE
    end.

%% ----------------------------------
%% @doc 	玩家进入场景(登录时)
%% @throws 	none
%% @end
%% ----------------------------------
player_enter_scene_when_enter_game(PlayerId) ->
    put(is_enter_game_scene, true),
    case mod_scene_offline_cache:get_offline_player_scene_cache(PlayerId) of
        main_scene ->
            player_enter_world_scene(PlayerId, ?SD_MY_MAIN_SCENE);
        init ->
            player_enter_world_scene(PlayerId, ?SD_INIT_SCENE_ID);
        R ->
            #ets_offline_player_scene_cache{
                scene_id = SceneId,
                x = LastX,
                y = LastY,
                scene_worker = SceneWorker
            } = R,
            case get_t_scene(SceneId) of
                null ->
                    player_enter_world_scene(PlayerId, ?SD_MY_MAIN_SCENE);
                _T_Scene ->
                    {X, Y} = {LastX, LastY},
                    ?DEBUG("进入离线缓存的场景:~p", [{PlayerId, SceneWorker, SceneId, X, Y}]),
                    player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, [], null)
            end
    end.

%% ----------------------------------
%% @doc 	传送
%% @throws 	none
%% @end
%% ----------------------------------
player_transmit(PlayerId, GoSceneId, GoX, GoY) ->
    player_transmit(PlayerId, GoSceneId, GoX, GoY, null).
player_transmit(PlayerId, GoSceneId, GoX, GoY, CallBackFun) ->
%%    ?ASSERT(get_scene_type(GoSceneId) == ?SCENE_TYPE_WORLD_SCENE , {not_world_scene, GoSceneId}),
    #ets_obj_player{
        scene_id = SceneId,
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    {RealGoX, RealGoY} =
        if GoX == 0 orelse GoY == 0 ->
            get_scene_birth_pos(GoSceneId);
            true ->
                {GoX, GoY}
        end,
    api_scene:notice_prepare_transmit(PlayerId),
    if GoSceneId == SceneId ->
        client_worker:send_msg(self(), {?MSG_SCENE_PLAYER_TRANSMIT, PlayerId, RealGoX, RealGoY, CallBackFun, SceneWorker}, 1000);
%%        erlang:send_after(1000, SceneWorker, {?MSG_SCENE_PLAYER_TRANSMIT, PlayerId, RealGoX, RealGoY, CallBackFun});
%%        SceneWorker ! {?MSG_SCENE_PLAYER_TRANSMIT, PlayerId, RealGoX, RealGoY};
        true ->
%%            ?MSG_CLIENT_ENTER_SCENE
            client_worker:send_msg(self(), {?MSG_CLIENT_ENTER_SCENE, PlayerId, GoSceneId, RealGoX, RealGoY, [], CallBackFun}, 1000)
%%            erlang:send_after(5000, self(), {?MSG_CLIENT_ENTER_SCENE, PlayerId, GoSceneId, RealGoX, RealGoY})
%%            player_enter_scene(PlayerId, GoSceneId, RealGoX, RealGoY)
    end.

%% ----------------------------------
%% @doc 	玩家进入场景
%% @throws 	none
%% @end
%% ----------------------------------
player_enter_scene(PlayerId) ->
    PlayerData = mod_player:get_db_player_data(PlayerId),
    #db_player_data{
        last_world_scene_id = LastSceneId,
        x = LastX,
        y = LastY
    } = PlayerData,
    SceneId = LastSceneId,
    {X, Y} = {LastX, LastY},
    player_enter_scene(PlayerId, SceneId, X, Y, [], null).

%% 玩家进入世界场景
player_enter_world_scene(PlayerId, SceneId) ->
    %% 该接口只能进入 世界场景
    ?ASSERT(is_world_scene(SceneId)),
    assert_enter_scene(PlayerId, SceneId),
    player_enter_scene(PlayerId, SceneId).
player_enter_scene(PlayerId, SceneId) ->
    player_enter_scene(PlayerId, SceneId, []).

%% 玩家进入世界场景
player_enter_single_world_scene(PlayerId, SceneId) ->
    %% 该接口只能进入 世界场景
    ?ASSERT(is_world_scene(SceneId)),
    assert_enter_scene(PlayerId, SceneId),
    {BirthX, BirthY} = get_scene_birth_pos(SceneId),
    player_prepare_enter_scene(PlayerId, null, SceneId, BirthX, BirthY, [], null, true).

player_enter_scene(PlayerId, SceneId, ExtraDataList) ->
    {BirthX, BirthY} = get_scene_birth_pos(SceneId),
    player_enter_scene(PlayerId, SceneId, BirthX, BirthY, ExtraDataList, null).

player_enter_scene(PlayerId, SceneId, X, Y) ->
    player_enter_scene(PlayerId, SceneId, X, Y, [], null).
%%player_enter_scene(PlayerId, SceneId, X, Y, ExtraDataList) ->
%%    player_enter_scene(PlayerId, SceneId, X, Y, ExtraDataList, null).

player_enter_scene(PlayerId, SceneId, X, Y, ExtraDataList, CallBackFun) ->
%%    player_enter_scene(PlayerId, SceneId, X, Y, ExtraDataList, ?TRANSFER).
%%player_enter_scene(PlayerId, SceneId, X, Y, ExtraDataList, Type) ->
    SceneWorker =
        case lists:keyfind(tmp_scene_worker, 1, ExtraDataList) of
            {tmp_scene_worker, SceneWorker1} -> SceneWorker1;
            _ -> null
        end,
    player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, ExtraDataList, CallBackFun).

%% ----------------------------------
%% @doc 	准备进入场景
%% @throws 	none
%% @end
%% ----------------------------------
%%player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, ExtraDataList) ->
%%    player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, ExtraDataList, false).
player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, ExtraDataList, CallBackFun) ->
    player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, ExtraDataList, CallBackFun, false).
player_prepare_enter_scene(PlayerId, SceneWorker, SceneId, X, Y, ExtraDataList, CallBackFun, IsSingle) ->
%%    check_enter_scene(PlayerId, SceneId),
%%    ?DEBUG("玩家(~p)准备进入场景:~p~n", [PlayerId, {SceneId, X, Y, Type}]),
    ?t_assert(?PROCESS_TYPE == ?PROCESS_TYPE_CLIENT_WORKER, not_client_worker),
    case get(?DICT_DO_ENTER_SCENE_ARGS) of
        ?UNDEFINED ->
            noop;
        OldEnterSceneArgs ->
            Now = util_time:timestamp(),
            ?WARNING("already_wait_enter_scene:~p", [OldEnterSceneArgs]),
            ?ASSERT(Now > OldEnterSceneArgs#enter_scene_args.expire_time, already_wait_enter_scene)
    end,
%%    ?ASSERT(get(?DICT_DO_ENTER_SCENE_ARGS) == ?UNDEFINED, already_wait_enter_scene),
    case get(is_enter_game_scene) of
        true ->
            noop;
        _ ->
            assert_enter_scene(PlayerId, SceneId)
    end,
    erase(is_enter_game_scene),
    api_scene:notice_prepare_scene(PlayerId, SceneId),
    #t_scene{
        map_id = MapId
    } = get_t_scene(SceneId),
    {RealX, RealY} = case mod_map:can_walk_pix(MapId, X, Y) of
                         true ->
                             {X, Y};
                         false ->
                             ?WARNING("修正位置:~p", [{SceneId, X, Y}]),
                             get_scene_birth_pos(SceneId)
                     end,
    put(?DICT_DO_ENTER_SCENE_ARGS, #enter_scene_args{
        player_id = PlayerId,
        scene_id = SceneId,
        scene_worker = SceneWorker,
        x = RealX,
        y = RealY,
        extra_data_list = ExtraDataList,
        call_back_fun = CallBackFun,
        expire_time = util_time:timestamp() + 10,
        is_single = IsSingle
%%        is_reconnect = IsReconnect
    }).

%% ----------------------------------
%% @doc 	进入场景
%% @throws 	none
%% @end
%% ----------------------------------
do_player_enter_scene(PlayerId, ScreenW, ScreenH) ->
    EnterSceneArgs = erase(?DICT_DO_ENTER_SCENE_ARGS),
    ?ASSERT(EnterSceneArgs =/= ?UNDEFINED, no_enter_scene_args),
    #enter_scene_args{
        player_id = PlayerId,
        scene_id = ToSceneId,
        x = ToX,
        y = ToY,
        extra_data_list = ExtraDataList,
%%        type = Type,
        scene_worker = SceneWorker,
        call_back_fun = CallBackFun,
        is_single = IsSingle
    } = EnterSceneArgs,
    case is_pid(SceneWorker) of
        true ->
            do_player_enter_scene(PlayerId, ToSceneId, ToX, ToY, SceneWorker, ScreenW, ScreenH, CallBackFun);
        false ->
            if
                IsSingle ->
                    {ok, SingleSceneWorker} = scene_master:get_scene_worker(PlayerId, ToSceneId, ExtraDataList, true),
                    do_player_enter_scene(PlayerId, ToSceneId, ToX, ToY, SingleSceneWorker, ScreenW, ScreenH, CallBackFun);
                true ->
                    do_player_enter_scene(PlayerId, ToSceneId, ToX, ToY, ExtraDataList, ScreenW, ScreenH, CallBackFun)
            end
    end.

do_player_enter_scene(PlayerId, ToSceneId, ToX, ToY, ExtraDataList, ScreenW, ScreenH, CallBackFun) when is_list(ExtraDataList) ->
    SceneWorker = get_scene_worker(PlayerId, ToSceneId, ExtraDataList),
    do_player_enter_scene(PlayerId, ToSceneId, ToX, ToY, SceneWorker, ScreenW, ScreenH, CallBackFun);
do_player_enter_scene(PlayerId, ToSceneId, ToX, ToY, SceneWorker, ScreenW, ScreenH, CallBackFun) when is_pid(SceneWorker) ->
    ?t_assert(?PROCESS_TYPE == ?PROCESS_TYPE_CLIENT_WORKER, not_client_worker),
    ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
    #ets_obj_player{
        id = PlayerId,
        scene_id = OldSceneId
    } = ObjPlayer,
    hook:before_enter_scene(PlayerId, OldSceneId, ToSceneId),
    EnterSceneData = pack_enter_scene_data(PlayerId, ToSceneId, ToX, ToY, ScreenW, ScreenH),

    case catch gen_server:call(SceneWorker, {?MSG_SCENE_PLAYER_ENTER_SCENE, EnterSceneData}, 8000) of
        success ->
            NewObjPlayer =
                ObjPlayer#ets_obj_player{
                    scene_id = ToSceneId,
                    scene_worker = SceneWorker
                },
            mod_obj_player:update_obj_player(NewObjPlayer),
            hook:after_enter_scene(PlayerId, OldSceneId, ToSceneId, ToX, ToY, SceneWorker),
            if CallBackFun == null ->
                noop;
                true ->
                    %% 回调函数
                    ?TRY_CATCH2(CallBackFun())
            end;
        {error, Reason} ->
            return_last_scene(PlayerId, ToSceneId),
            exit(Reason);
        {'EXIT', {timeout, _}} ->
            ?ERROR("进入场景超时:~p~n", [{timeout, {PlayerId, ToSceneId, ToX, ToY, SceneWorker}}]),
            SceneWorker ! {?MSG_SCENE_PLAYER_LEAVE_ASYNC, PlayerId},
            return_last_scene(PlayerId, ToSceneId);
%%            exit(enter_scene_timeout);
        {'EXIT', {noproc, _}} ->
%%            SceneWorker ! {?MSG_PLAYER_LEAVE_ASYNC, PlayerId},
            ?ERROR("进入场景 进程:~p~n", [{noproc, {PlayerId, ToSceneId, ToX, ToY, SceneWorker}}]),
            return_last_scene(PlayerId, ToSceneId)
    end,
    ok.

%% ----------------------------------
%% @doc 	获取场景进程
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_worker(PlayerId, ToSceneId, ExtraDataList) ->
    {ok, SceneWorker} = scene_master:get_scene_worker(PlayerId, ToSceneId, ExtraDataList),
    SceneWorker.

%% ----------------------------------
%% @doc 	创建进场景的玩家数据
%% @throws 	none
%% @end
%% ----------------------------------
create_enter_scene_data(PlayerId) ->
    pack_enter_scene_data(PlayerId, 0, 0, 0, ?MAX_PW, ?MAX_PW, true).

%% ----------------------------------
%% @doc 	打包进入场景数据
%% @throws 	none
%% @end
%% ----------------------------------
pack_enter_scene_data(PlayerId, SceneId, X, Y, ScreenW, ScreenH) ->
    pack_enter_scene_data(PlayerId, SceneId, X, Y, ScreenW, ScreenH, false).
pack_enter_scene_data(PlayerId, _SceneId, X, Y, ScreenW, ScreenH, IsRobot) ->
    Player = mod_player:get_player(PlayerId),
    if
        Player == null ->
            null;
        true ->

            PlayerData = mod_player:get_db_player_data(PlayerId),

%%    %% 进入场景 方向
%%    if MissionType == ?MISSION_TYPE_JING_JI_CHANG ->
%%        Dir =
%%            if IsRobot ->
%%                ?DIR_LEFT_DOWN;
%%                true ->
%%                    ?DIR_RIGHT_UP
%%            end;
%%        true ->
%%            Dir = ?DIR_DOWN
%%    end,
            Dir = ?DIR_DOWN,
            RealScreenW = min(max(?MIN_PW, ScreenW), ?MAX_PW),
            RealScreenH = min(max(?MIN_PH, ScreenH), ?MAX_PH),
            ObjPlayer =
                if
                    IsRobot ->
                        #ets_obj_player{
                            id = PlayerId,
                            client_node = node(),
                            client_worker = null,
                            sender_worker = null
                        };
                    true ->
                        mod_obj_player:get_obj_player(PlayerId)
                end,

            DbPlayerHeroUse = mod_hero:get_db_player_hero_use(PlayerId),
            IsCanAddAnger = mod_hero:get_is_can_use_anger(DbPlayerHeroUse),

            #player_enter_scene_data{
                x = X,
                y = Y,
                player = Player,
                player_id = PlayerId,
                player_data = PlayerData,
                obj_player = ObjPlayer,
                player_name = mod_player:get_player_name(PlayerId),
                dir = Dir,
                active_skill_list = mod_active_skill:pack_all_equip_active_skill(PlayerId),
                passive_skill_list = mod_passive_skill:get_all_player_passive_skill(PlayerId),
                subscribe_list = mod_scene_grid_manager:get_subscribe_grid_id_list_by_px(RealScreenW, RealScreenH),
                magic_weapon_id = mod_sys_common:get_id_by_fun_state(PlayerId, ?FUNCTION_ROLE_MAGIC),
                is_robot = IsRobot,
                hero = DbPlayerHeroUse,
                is_use_anger = case erase(is_use_anger) of ?UNDEFINED -> false; R -> R end,
                is_can_add_anger = IsCanAddAnger
            }
    end.


%% ----------------------------------
%% @doc 	回到上个世界场景
%% @throws 	none
%% @end
%% ----------------------------------
return_last_scene(PlayerId, NowSceneId) ->
    PlayerData = mod_player:get_db_player_data(PlayerId),
    LastSceneId = PlayerData#db_player_data.last_world_scene_id,
    if
        NowSceneId == LastSceneId ->
            noop;
        true ->
            player_enter_scene(PlayerId)
    end.

add_fight_fanpai(PlayerId, Award) ->
    put(add_fight_fanpai, Award),
    ?INFO("add_fight_fanpai:~p", [{Award}]),
    Out = proto:encode(#m_scene_notice_show_fanpai_toc{
        id_list = lists:seq(1, length(?SD_MONSTER_EFFECT3_RATE_LIST))
    }),
%%    Out = proto:encode(#m_player_notice_server_time_toc{server_time = ServerTime}),
    mod_socket:send(PlayerId, Out).

get_fight_fanpai(PlayerId) ->
    Rate = util_random:get_probability_item([{A, B} || [A, B] <- ?SD_MONSTER_EFFECT3_RATE_LIST]),
    Award =
        lists:foldl(
            fun({PropId, Num}, TMpL) ->
                [{PropId, Num * Rate} | TMpL]
            end,
            [],
            get(add_fight_fanpai)
        ),
    put(add_fight_fanpai, []),
    ?INFO("get_fight_fanpai:~p", [{Award, Rate}]),
    mod_award:give(PlayerId, Award, ?LOG_TYPE_FIGHT).

deal_fight_fanpai(PlayerId) ->
    Award = get(add_fight_fanpai),
    if is_list(Award) ->
        ?INFO("deal_fight_fanpai:~p", [Award]),
        mod_award:give(PlayerId, Award, ?LOG_TYPE_FIGHT);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	玩家返回世界场景
%% @throws 	none
%% @end
%% ----------------------------------
return_world_scene(PlayerId) ->
    return_world_scene(PlayerId, false).
return_world_scene(PlayerId, IsForce) ->
    ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
    if IsForce ->
        ?CATCH(hook:after_leave_scene(PlayerId, ObjPlayer#ets_obj_player.scene_id)),
        mod_obj_player:update_obj_player(ObjPlayer#ets_obj_player{
            scene_id = 0,
            scene_worker = null
        });
        true ->
            ?ASSERT(is_world_scene(ObjPlayer#ets_obj_player.scene_id) == false, already_world_scene)
    end,
    player_enter_scene(PlayerId).
return_world_scene(PlayerId, IsForce, IsCheckCondition) ->
    %% 是否检查进入条件
    case IsCheckCondition of
        false ->
            put(is_enter_game_scene, true);
        true ->
            noop
    end,
    return_world_scene(PlayerId, IsForce).

async_return_world_scene(PlayerId) ->
    client_worker:send_msg(PlayerId, ?MSG_CLIENT_RETURN_WORLD_SCENE).


%% ----------------------------------
%% @doc 	玩家改变场景
%% @throws 	none
%% @end
%% ----------------------------------
player_change_scene(PlayerId, ToSceneId, ToX, ToY, _Type) ->
    ?ASSERT(is_world_scene(ToSceneId) == true, not_world_scene),
    player_enter_scene(PlayerId, ToSceneId, ToX, ToY).

challenge_boss(_PlayerId) ->
    noop.
%%    #ets_obj_player{
%%        scene_id = SceneId,
%%        scene_worker = SceneWorker
%%    } = mod_obj_player:get_obj_player(PlayerId),
%%    #t_scene{
%%        is_hook = IsHook,
%%        type = Type
%%    } = get_t_scene(SceneId),
%%    if
%%        IsHook == ?TRUE andalso Type == ?SCENE_TYPE_WORLD_SCENE ->
%%            erlang:send(SceneWorker, {?MSG_SCENE_CHALLENGE_BOSS, PlayerId});
%%        true ->
%%            noop
%%    end.

%% @doc 发送消息
send_msg(PlayerId, Type, Id) ->
    mod_interface_cd:assert({?MODULE, send_msg, PlayerId, Type}, 1000),
    #ets_obj_player{
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    IsSend =
        case Type of
            0 ->
                %% 文字聊天
                mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_CHAT_USE_COUNT),
                t_bubble:get({Id}) =/= null;
            1 ->
                %% 表情包
                mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_BIAOQING_USE_COUNT),
                #t_ge_xing_hua{
                    item_id = ItemId
                } = mod_player:get_t_ge_xing_hua(Id),
                #t_item{
                    type = ItemType
                } = mod_item:get_t_item(ItemId),
                mod_prop:get_player_prop_num(PlayerId, ItemId) > 0 andalso ItemType == ?IT_STICKER
        end,
    if
        IsSend ->
            erlang:send(SceneWorker, {?MSG_SCENE_SEND_MSG, PlayerId, Type, Id}),
            Tran =
                fun() ->
                    case Type of
                        0 ->
                            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_CHAT_COUNT, ?CONDITIONS_VALUE_ADD, 1});
                        1 ->
                            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_USE_STICKER, ?CONDITIONS_VALUE_ADD, 1})
                    end
                end,
            db:do(Tran),
            ok;
        true ->
            noop
    end.

is_save_pos_scene(SceneId) ->
    #t_scene{
        type = Type
    } = get_t_scene(SceneId),
    Type == ?SCENE_TYPE_WORLD_SCENE.

%% ----------------------------------
%% @doc 	离开场景保存玩家信息
%% @throws 	none
%% @end
%% ----------------------------------
save_data_after_leave_scene(_PlayerId, _SceneId, _SceneWorker, [], _IsChangeSceneType) ->
    noop;
save_data_after_leave_scene(PlayerId, SceneId, SceneWorker, SaveDataList, IsChangeSceneType) ->
    PlayerData = mod_player:get_db_player_data(PlayerId),
    IsWorldScene = is_world_scene(SceneId),
    Tran = fun() ->
        NewPlayerData =
            lists:foldl(
                fun(SaveData, TmpPlayerData) ->
                    case SaveData of
                        %% 位置
                        {pos, {X, Y}} ->
                            %% 尝试更新场景离线缓存
                            mod_scene_offline_cache:update_offline_player_scene_cache(PlayerId, SceneId, SceneWorker, X, Y),
                            case is_save_pos_scene(SceneId) of
                                true ->
                                    TmpPlayerData#db_player_data{last_world_scene_id = SceneId, x = X, y = Y};
                                false ->
                                    TmpPlayerData
                            end;
                        %% 血量
                        {hp, Hp} ->
                            if IsWorldScene == false orelse IsChangeSceneType ->
                                TmpPlayerData#db_player_data{hp = TmpPlayerData#db_player_data.max_hp};
                                true ->
                                    TmpPlayerData#db_player_data{hp = Hp}
                            end;
                        {anger, Anger} ->
                            TmpPlayerData#db_player_data{anger = Anger};
                        {obj_buff, ObjBuff} ->
                            put(?DICT_CACHE_OBJ_BUFF, ObjBuff),
                            TmpPlayerData;
                        {obj_passive_skill, ObjPassiveSkill} ->
                            put(?DICT_OBJ_PASSIVE_SKILL, ObjPassiveSkill),
                            TmpPlayerData;
                        %% 主动技能
                        {r_active_skill_list, RActiveSkillList} ->
                            if
                                IsChangeSceneType == false ->
                                    lists:foreach(
                                        fun(RActiveSkill) ->
                                            #r_active_skill{
                                                is_common_skill = IsCommonSkill
%%                                                id = SkillId,
%%                                                last_time_ms = LastTimeMs
                                            } = RActiveSkill,
                                            if
                                                IsCommonSkill == false ->
                                                    noop;
                                            %% 主动技能 记录使用时间
%%                                                    mod_active_skill:save_player_active_skill_last_time(PlayerId, SkillId, LastTimeMs div 1000);
                                                true ->
                                                    noop
                                            end
                                        end,
                                        RActiveSkillList
                                    );
                                true ->
                                    noop
                            %% 切换不同类型的场景后  清除cd时间
%%                                    mod_active_skill:clear_all_active_skill_cd(PlayerId),
%%                                    api_skill:notice_clear_active_skill_cd(PlayerId)
                            end,
                            TmpPlayerData
                    end
                end,
                PlayerData,
                SaveDataList
            ),
        db:write(NewPlayerData)
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	玩家离开场景
%% @throws 	none
%% @end
%% ----------------------------------
player_leave_scene(PlayerId) ->
    player_leave_scene(PlayerId, false).
player_leave_scene(PlayerId, IsChangeSceneType) ->
    ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
    #ets_obj_player{
        id = PlayerId,
        scene_worker = SceneWorker,
        scene_id = SceneId
    } = ObjPlayer,
    if
        SceneId > 0 ->
            case util:is_pid_alive(SceneWorker) of
                true ->
                    ?DEBUG("玩家(~p)离开场景:~p~n", [PlayerId, SceneId]),
                    DoLeaveFun =
                        fun() ->
                            case gen_server:call(SceneWorker, {?MSG_SCENE_PLAYER_LEAVE, PlayerId}) of
                                fail ->
                                    exit(player_leave_scene_fail);
                                SaveDataList ->
%%                                    ?DEBUG("离开场景:~p", [{SaveDataList}]),
                                    save_data_after_leave_scene(PlayerId, SceneId, SceneWorker, SaveDataList, IsChangeSceneType),
                                    mod_obj_player:update_obj_player(ObjPlayer#ets_obj_player{scene_id = 0, scene_worker = null}),
                                    hook:after_leave_scene(PlayerId, SceneId)
                            end
                        end,
                    DoLeaveFun();
                false ->
                    ?DEBUG("离开场景,场景不存在:~p~n", [{PlayerId, [{scene_id, SceneId}]}]),
                    mod_obj_player:update_obj_player(ObjPlayer#ets_obj_player{scene_id = 0, scene_worker = null})
            end;
        true ->
            noop
    end,
    ok.

%% ----------------------------------
%% @doc 	玩家复活
%% @throws 	none
%% @end
%% ----------------------------------
%%player_rebirth(PlayerId) ->
%%    ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
%%    #ets_obj_player{
%%        id = PlayerId,
%%        scene_worker = SceneWorker,
%%        scene_id = SceneId
%%    } = ObjPlayer,
%%%%    assert_no_jing_ji_chang(),
%%    Tran =
%%        fun() ->
%%            case is_cost_times(SceneId) of
%%                true ->
%%                    %% 消耗复活次数
%%                    mod_times:use_times(PlayerId, ?TIMES_REBIRTH_TIMES);
%%                false ->
%%                    noop
%%            end,
%%            case gen_server:call(SceneWorker, {?MSG_SCENE_PLAYER_REBIRTH, PlayerId, request}) of
%%                success ->
%%                    noop;
%%                {error, Reason} ->
%%                    exit(Reason)
%%            end
%%        end,
%%    db:do(Tran).

%% 是否消耗复活次数
%%is_cost_times(SceneId) ->
%%    #t_scene{
%%        rebirth_window = RebirthWindow
%%    } = get_t_scene(SceneId),
%%    RebirthWindow == 2.

%% 是否跨服场景
is_zone_scene(SceneId) ->
    #t_scene{
        server_type = SceneServerType
    } = get_t_scene(SceneId),
    SceneServerType == ?SERVER_TYPE_WAR_ZONE.

%% 获取场景服务器类型
get_scene_server_type(SceneId) ->
    #t_scene{
        server_type = SceneServerType
    } = get_t_scene(SceneId),
    SceneServerType.

%% 是否战区场景
is_war_scene(SceneId) ->
    #t_scene{
        server_type = SceneServerType
    } = get_t_scene(SceneId),
    SceneServerType == ?SERVER_TYPE_WAR_AREA.

is_server_control_scene(SceneId) ->
    #t_scene{
        is_server_control_player = IsServerControlPlayer
    } = get_t_scene(SceneId),
    ?TRAN_INT_2_BOOL(IsServerControlPlayer).

%%server_control_scene_id_list() ->
%%    [9999, 12001].

%% 确保非服务端控制
assert_not_server_control() ->
    case ?IS_DEBUG of
        true ->
            ?ASSERT(is_server_control_scene(get(?DICT_PLAYER_SCENE_ID)) == false, server_control_scene);
        _ ->
            noop
    end.

%% ----------------------------------
%% @doc 	玩家移动
%% @throws 	none
%% @end
%% ----------------------------------
player_move(PlayerId, GoX, GoY, MoveType, High, Time, ActionId) ->
    SceneWorker = get(?DICT_PLAYER_SCENE_WORKER),
    case is_server_control_scene(get(?DICT_PLAYER_SCENE_ID)) of
        true ->
            noop;
        _ ->
            case ?IS_DEBUG of
                true ->
                    SceneWorker ! {?MSG_SCENE_PLAYER_MOVE, PlayerId, GoX, GoY, MoveType, High, Time, ActionId};
                _ ->
                    if SceneWorker == null ->
                        noop;
                        true ->
                            SceneWorker ! {?MSG_SCENE_PLAYER_MOVE, PlayerId, GoX, GoY, MoveType, High, Time, ActionId}
                    end
            end
    end,
    ok.

player_move_step(PlayerId, X, Y) ->
    ?t_assert(X > 0 andalso Y > 0, {pos_error, {X, Y}}),
    SceneWorker = get(?DICT_PLAYER_SCENE_WORKER),

    case ?IS_DEBUG of
        true ->
            assert_not_server_control(),
            SceneWorker ! {?MSG_SCENE_PLAYER_MOVE_STEP, PlayerId, X, Y};
        _ ->
            if SceneWorker == null ->
                noop;
                true ->
                    SceneWorker ! {?MSG_SCENE_PLAYER_MOVE_STEP, PlayerId, X, Y}
            end
    end,
    ok.

player_stop_move(PlayerId, X, Y) ->
    SceneWorker = get(?DICT_PLAYER_SCENE_WORKER),

    case ?IS_DEBUG of
        true ->
            assert_not_server_control(),
            SceneWorker ! {?MSG_SCENE_PLAYER_STOP_MOVE, PlayerId, X, Y};
        _ ->
            if SceneWorker == null ->
                noop;
                true ->
                    SceneWorker ! {?MSG_SCENE_PLAYER_STOP_MOVE, PlayerId, X, Y}
            end
    end,
    ok.

player_join_monster_point(PlayerId, MonsterId) ->
    SceneWorker = get(?DICT_PLAYER_SCENE_WORKER),
    SceneWorker ! {?MSG_SCENE_PLAYER_JOINT_MONSTER_POINT, PlayerId, MonsterId},
    ok.

%% ----------------------------------
%% @doc 	获取该场景玩家数量
%% @throws 	none
%% @end
%% ----------------------------------
get_player_count(SceneWorker) ->
    gen_server:call(SceneWorker, ?MSG_SCENE_GET_PLAYER_COUNT).

%% ----------------------------------
%% @doc 	处理走路
%% @throws 	none
%% @end
%% ----------------------------------
deal_move(Time, MovePath, {X, Y}, MoveSpeed) when Time =< 0 orelse MoveSpeed =< 0 ->
    {MovePath, {X, Y}, 0};
deal_move(_, [], {X, Y}, _MoveSpeed) ->
    {[], {X, Y}, 0};
deal_move(Time, [{X, Y} | L], {X, Y}, MoveSpeed) ->
    deal_move(Time, L, {X, Y}, MoveSpeed);
deal_move(Time, [{X1, Y1} | L], {X, Y}, MoveSpeed) ->
    Len = math:sqrt((X - X1) * (X - X1) + (Y - Y1) * (Y - Y1)),
    case get({jump_p, ?PIX_2_TILE(X, Y), ?PIX_2_TILE(X1, Y1)}) of
        true ->
%%            ?DEBUG("跳:~p~n", [{{X, Y}, {X1, Y1}, ?PIX_2_TILE(X, Y), ?PIX_2_TILE(X1, Y1)}]),
            RealMoveSpeed =
                if Len > 315 ->
                    2.2222222;
                    true ->
                        Len / 700
                end,
            NeedTime = Len * RealMoveSpeed,
            if
                Time >= NeedTime ->
                    deal_move(Time - NeedTime, L, {X1, Y1}, MoveSpeed);
                true ->
                    {L, {X1, Y1}, max(0, NeedTime - Time)}
            end;
        _ ->
            NeedTime = Len * MoveSpeed,
            if
                Time >= NeedTime ->
                    deal_move(Time - NeedTime, L, {X1, Y1}, MoveSpeed);
                true ->
                    GoLen = erlang:ceil(Time / MoveSpeed),

                    Len1 = erlang:abs(X1 - X),
                    Len2 = erlang:abs(Y1 - Y),
                    Cos = Len1 / Len,
                    Sin = Len2 / Len,

                    {X3, Y3} =
                        {
                            round(?IF(X1 >= X, X + GoLen * Cos, X - GoLen * Cos)),
                            round(?IF(Y1 >= Y, Y + GoLen * Sin, Y - GoLen * Sin))
                        },
                    {X4, Y4} =
                        if erlang:abs(X1 - X3) < 2 andalso erlang:abs(Y1 - Y3) < 2 ->
                            {X1, Y1};
                            true ->
                                {X3, Y3}
                        end,
                    deal_move(0, [{X1, Y1} | L], {X4, Y4}, MoveSpeed)
            end
    end.

%% ----------------------------------
%% @doc 	是否挂机场景
%% @throws 	none
%% @end
%% ----------------------------------
is_hook_scene(SceneId) ->
    Scene = get_t_scene(SceneId),
    Scene#t_scene.is_hook == ?TRUE.

%% ----------------------------------
%% @doc 	是否世界场景
%% @throws 	none
%% @end
%% ----------------------------------
is_world_scene(SceneId) ->
    Scene = get_t_scene(SceneId),
    Scene#t_scene.type == ?SCENE_TYPE_WORLD_SCENE.

%% ----------------------------------
%% @doc 	是否副本场景
%% @throws 	none
%% @end
%% ----------------------------------
is_mission_scene(SceneId) ->
    Scene = get_t_scene(SceneId),
    Scene#t_scene.type == ?SCENE_TYPE_MISSION.


%%
%%get_scene_max_player_count(SceneId) ->
%%    (get_t_scene(SceneId))#t_scene.max_player.

get_scene_type(SceneId) ->
    (get_t_scene(SceneId))#t_scene.type.


%% ----------------------------------
%% @doc 	获取场景名字
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_name(SceneId) ->
    Scene = get_t_scene(SceneId),
    Scene#t_scene.name.

%% ----------------------------------
%% @doc 	获取所有场景id
%% @throws 	none
%% @end
%% ----------------------------------
get_all_scene_id() ->
    logic_get_all_scene_id:get(0).

%% ----------------------------------
%% @doc 	获取所有世界场景id
%% @throws 	none
%% @end
%% ----------------------------------
get_all_world_scene_id() ->
    logic_get_all_world_scene_id:get(0).

%% ----------------------------------
%% @doc 	获取所有世界场景id
%% @throws 	none
%% @end
%% ----------------------------------
get_all_world_scene_id_by_server_type(ServerType) ->
    logic_get_all_world_scene_id_by_server_type:get(ServerType).

%% ----------------------------------
%% @doc 	获取所有战场场景id
%% @throws 	none
%% @end
%% ----------------------------------
%%get_all_battle_ground_scene_id() ->
%%    logic_get_all_battle_ground_scene_id:get(0).

%% ----------------------------------
%% @doc 	获取随机范围内像素位置
%% @throws 	none
%% @end
%% ----------------------------------
get_random_pix_pos(MapId, {PixX, PixY}, Range) ->
    {TileX, TileY} = ?PIX_2_TILE(PixX, PixY),
    {TileX1, TileY1} = {TileX + util_random:random_number(-Range, Range), TileY + util_random:random_number(-Range, Range)},
    case mod_map:can_walk({MapId, {TileX1, TileY1}}) of
        true ->
            ?TILE_2_PIX(TileX1, TileY1);
        false ->
            {PixX, PixY}
    end.

%% ----------------------------------
%% @doc 	获取场景怪物配置信息
%% @throws 	none
%% @end
%% ----------------------------------
get_r_scene_monster({SceneId, SceneMonsterId}) ->
    case scene_data:get_scene_monster({SceneId, SceneMonsterId}) of
        null ->
            ?ERROR("SceneMonsterId not exists:~p~n", [{SceneId, SceneMonsterId}]),
            null;
        SceneMonster ->
            SceneMonster
    end.

%% ----------------------------------
%% @doc 	保存玩家场景位置
%% @throws 	none
%% @end
%% ----------------------------------
save_player_scene_pos(PlayerId, SceneId) ->
    {X, Y} = get_scene_birth_pos(SceneId),
    save_player_scene_pos(PlayerId, SceneId, X, Y).
save_player_scene_pos(PlayerId, SceneId, X, Y) ->
    ?ASSERT(is_save_pos_scene(SceneId)),
    PlayerData = mod_player:get_db_player_data(PlayerId),
    Tran = fun() ->
        db:write(PlayerData#db_player_data{
            last_world_scene_id = SceneId,
            x = X,
            y = Y
        })
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	获取该玩家所在场景玩家id列表
%% @throws 	none
%% @end
%% ----------------------------------
%% type => player:玩家 robot:机器人 all:所有
get_scene_player_id_list(PlayerId, Type) ->
    case mod_obj_player:get_obj_player(PlayerId) of
        null ->
            [];
        ObjPlayer ->
            #ets_obj_player{
                scene_worker = SceneWorker,
                scene_id = SceneId
            } = ObjPlayer,
            case catch gen_server:call(SceneWorker, {?MSG_SCENE_GET_SCENE_PLAYER_ID_LIST, Type, PlayerId}, 2000) of
                {ok, List} ->
                    List;
                Other ->
                    ?ERROR("获取场景玩家id列表失败:~p", [{PlayerId, SceneId, Other}]),
                    []
            end
    end.

%%%% ----------------------------------
%%%% @doc 	创建机器人
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%create_robot(PlayerId, RobotId) ->
%%    case mod_obj_player:get_obj_player(PlayerId) of
%%        null ->
%%            [];
%%        ObjPlayer ->
%%            #ets_obj_player{
%%                scene_worker = SceneWorker
%%            } = ObjPlayer,
%%            ?DEBUG("请求创建机器人:~p", [{PlayerId, RobotId}]),
%%            SceneWorker ! {?MSG_SCENE_CREATE_ROBOT, PlayerId, RobotId, 0, 600 * ?SECOND_MS, 0.8, mod_player:get_player_name(RobotId)}
%%    end.

%% ----------------------------------
%% @doc 	查询玩家位置
%% @throws 	none
%% @end
%% ----------------------------------
query_player_pos(QueryPlayerId) ->
    SceneWorker = get(?DICT_PLAYER_SCENE_WORKER),
    SceneId = get(?DICT_PLAYER_SCENE_ID),
    case catch gen_server:call(SceneWorker, {?MSG_SCENE_GET_PLAYER_POS, QueryPlayerId}, 2000) of
        {pos, {ThisSceneId, ThisX, ThisY}} ->
            {ThisSceneId, ThisX, ThisY};
        Other ->
            ?ERROR("查询玩家位置失败:~p", [{SceneId, Other}]),
            {0, 0, 0}
    end.

%% ----------------------------------
%% @doc 	获取玩家位置
%% @throws 	none
%% @end
%% ----------------------------------
get_player_pos(PlayerId) ->
    get_player_pos(PlayerId, true).
get_player_pos(PlayerId, IsForce) ->
    Result =
        case mod_obj_player:get_obj_player(PlayerId) of
            null ->
                ?WARNING("玩家不在线:~p", [PlayerId]),
                offline;
            ObjPlayer ->
                #ets_obj_player{
                    scene_id = ThisSceneId,
                    scene_worker = SceneWorker
                } = ObjPlayer,
                case catch gen_server:call(SceneWorker, {?MSG_SCENE_GET_PLAYER_POS, PlayerId}, 2000) of
                    {pos, {ThisSceneId, ThisX, ThisY}} ->
                        {ThisSceneId, ThisX, ThisY};
                    Other ->
                        ?ERROR("获取玩家位置失败:~p", [{ThisSceneId, Other}]),
                        fail
                end
        end,
    case Result of
        {SceneId, X, Y} ->
            {SceneId, X, Y};
        _ ->
            if IsForce ->
                %% 获取玩家当前位置失败， 获取玩家上次记录的位置
                #db_player_data{
                    last_world_scene_id = LastSceneId,
                    x = LastX,
                    y = LastY
                } = mod_player:get_db_player_data(PlayerId),
                {LastSceneId, LastX, LastY};
                true ->
                    Result
            end
    end.

%% ----------------------------------
%% @doc 	获取场景npc位置
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_npc_pos(SceneId, NpcId) ->
    SceneNpcList = scene_data:get_scene_npc_list(SceneId),
    case lists:keyfind(NpcId, #r_scene_npc.npc_id, SceneNpcList) of
        false ->
            io:format("场景找不到npc:~p", [{SceneId, NpcId}]),
            null;
        R ->
            #r_scene_npc{
                x = X,
                y = Y
            } = R,
            {X, Y}
    end.

%% ----------------------------------
%% @doc 	修改场景对象属性
%% @throws 	none
%% @end
%% ----------------------------------
change_obj_scene_attr_attr(ObjSceneActor, Rate) ->
    #obj_scene_actor{
        max_hp = MaxHp,
        hp = Hp,
        attack = Attack,
        defense = Defense,
        hit = Hit,
        dodge = Dodge,
        tenacity = Tenacity,
        critical = Critical,
        hurt_add = HurtAdd,
        hurt_reduce = HurtReduce,
        crit_hurt_add = CritHurtAdd,
        crit_hurt_reduce = CritHurtReduce,
        rate_resist_block = RateResistBlock,
        rate_block = RateBlock,
        power = Power
    } = ObjSceneActor,
    ObjSceneActor#obj_scene_actor{
        max_hp = trunc(MaxHp * Rate),
        hp = trunc(Hp * Rate),
        attack = trunc(Attack * Rate),
        defense = trunc(Defense * Rate),
        hit = trunc(Hit * Rate),
        dodge = trunc(Dodge * Rate),
        tenacity = trunc(Tenacity * Rate),
        critical = trunc(Critical * Rate),
        hurt_add = trunc(HurtAdd * Rate),
        hurt_reduce = trunc(HurtReduce * Rate),
        crit_hurt_add = trunc(CritHurtAdd * Rate),
        crit_hurt_reduce = trunc(CritHurtReduce * Rate),
        rate_resist_block = trunc(RateResistBlock * Rate),
        rate_block = trunc(RateBlock * Rate),
        power = trunc(Power * Rate)
    }.


%% ----------------------------------
%% @doc 	获取场景采集物列表
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_gather_list(SceneId) ->
    L = scene_data:get_scene_gather_id_list(SceneId),
    lists:foldl(
        fun(Id, Tmp) ->
            [scene_data:get_scene_gather({SceneId, Id}) | Tmp]
        end,
        [],
        L
    ).

%% ----------------------------------
%% @doc 	该场景是否断线重连
%% @throws 	none
%% @end
%% ----------------------------------
is_offline_reconnect_scene(PlayerId, SceneId, SceneWorker) ->
    #t_scene{
        type = SceneType,
        server_type = SceneServerType
    } = get_t_scene(SceneId),

    Result =
        if
            SceneType == ?SCENE_TYPE_WORLD_SCENE ->
                %% 根据玩家是否还驻留在场景进程内，判断是否需要进行场景重连
                SceneStayPlayerIdList =
                    if
                        SceneServerType =:= ?SERVER_TYPE_GAME ->
                            mod_cache:get({scene_worker_stay_player_list, SceneWorker});
                        SceneServerType =:= ?SERVER_TYPE_WAR_ZONE ->
                            mod_server_rpc:call_zone(mod_cache, get, [{scene_worker_stay_player_list, SceneWorker}]);
                        SceneServerType =:= ?SERVER_TYPE_WAR_AREA ->
                            mod_server_rpc:call_war(mod_cache, get, [{scene_worker_stay_player_list, SceneWorker}])
                    end,
                case SceneStayPlayerIdList of
                    null -> false;
                    _ when is_list(SceneStayPlayerIdList) ->
                        case lists:member(PlayerId, SceneStayPlayerIdList) of
                            true -> true;
                            false -> false
                        end
                end;
            true ->
                SceneType == ?SCENE_TYPE_MATCH_SCENE
        end,
    Result andalso util:is_pid_alive(SceneWorker).


%% ----------------------------------
%% @doc 	获取随机位置
%% @throws 	none
%% @end
%% ----------------------------------
get_random_pos(MapId, X, Y, PosRange) ->
    get_random_pos(MapId, X, Y, PosRange, 20).
get_random_pos(MapId, X, Y, PosRange, N) when N > 0 ->
    {RandomX, RandomY} = util_math:get_random_pos(X, Y, PosRange),
    case mod_map:can_walk(?PIX_2_MASK_ID(MapId, RandomX, RandomY)) of
        true ->
            {RandomX, RandomY};
        false ->
            get_random_pos(MapId, X, Y, PosRange, N - 1)
    end;
get_random_pos(_MapId, X, Y, _PosRange, _N) ->
    {X, Y}.


%% ----------------------------------
%% @doc 	处理对象移动
%% @throws 	none
%% @end
%% ----------------------------------
deal_move_step(ObjSceneActor = #obj_scene_actor{move_path = []}, _Now, _State) ->
    ObjSceneActor;
deal_move_step(ObjSceneActor = #obj_scene_actor{move_type = ?MOVE_TYPE_NORMAL, move_speed = 0}, _Now, _State) ->
    ObjSceneActor;
deal_move_step(
    ObjSceneActor = #obj_scene_actor{
        obj_type = ObjType,
        grid_id = OldGridId,
        x = X,
        y = Y,
        move_speed = MoveSpeed,
        move_path = MovePath,
        last_move_time = LastMoveTime,
        move_type = MoveType
    },
    Now,
    #scene_state{map_id = MapId}
) ->
    {LeftMovePath, {NewX, NewY}, ForbidTime} =
        if MoveType == ?MOVE_TYPE_NORMAL ->
            mod_scene:deal_move((Now - LastMoveTime), MovePath, {X, Y}, 1000 / (util:speed_point_2_speed(MoveSpeed) * ?TILE_LEN));
            MoveType == ?MOVE_TYPE_MOMENT ->
                mod_scene:deal_move((Now - LastMoveTime), MovePath, {X, Y}, 1000 / (util:speed_point_2_speed(MoveSpeed) * ?TILE_LEN));
            true ->
                mod_scene:deal_move((Now - LastMoveTime), MovePath, {X, Y}, 1000 / 700)
        end,

    if
        NewX =/= X orelse NewY =/= Y orelse LeftMovePath =/= MovePath ->
            case mod_map:can_walk({MapId, ?PIX_2_TILE(NewX, NewY)}) of
                false ->
                    ObjSceneActor;
                true ->
                    NewGridId = ?PIX_2_GRID_ID(NewX, NewY),
                    ObjSceneActor_1 =
                        if
                            ForbidTime == 0 ->
                                ObjSceneActor#obj_scene_actor{
                                    x = NewX,
                                    y = NewY,
                                    grid_id = NewGridId,
                                    move_path = LeftMovePath,
                                    last_move_time = Now
                                };
                            true ->
                                NextHeartBeatTime = Now + ForbidTime,
                                ObjSceneActor#obj_scene_actor{
                                    x = NewX,
                                    y = NewY,
                                    grid_id = NewGridId,
                                    move_path = LeftMovePath,
                                    last_move_time = NextHeartBeatTime,
                                    next_can_heart_time = NextHeartBeatTime
                                }
                        end,
                    if ObjType == ?OBJ_TYPE_PLAYER ->
                        mod_scene_grid_manager:handle_player_grid_change(ObjSceneActor_1, OldGridId, NewGridId, walk);
                        true ->
                            mod_scene_grid_manager:handle_monster_grid_change(ObjSceneActor_1, OldGridId, NewGridId)
                    end,
                    ObjSceneActor_1
            end;
        true ->
            ObjSceneActor
    end.

%% ----------------------------------
%% @doc 	更新速度
%% @throws 	none
%% @end
%% ----------------------------------
update_move_speed(ObjSceneActor) ->
    update_move_speed(ObjSceneActor, false).
update_move_speed(ObjSceneActor, _IsNotice) ->
    #obj_scene_actor{
%%        transport_goods_id = TransportGoodsId,
        init_move_speed = InitMoveSpeed,
        move_speed = _MoveSpeed,
        buff_list = _BuffList
    } = ObjSceneActor,
%%    InitSpeed = ?SD_INIT_SPEED,
%%    MoveSpeed_0 = MoveSpeed,
%%        if MountStep == 0 orelse MountStep == ?UNDEFINED ->
%%            InitSpeed;
%%            true ->
%%                #t_mount{
%%                    speed_add = SpeedAdd
%%                } = t_mount:get({MountStep}),
%%%%            ?DEBUG("InitSpeed + SpeedAdd:~p~n", [InitSpeed + SpeedAdd]),
%%                InitSpeed + SpeedAdd
%%        end,
    MoveSpeed_1 =
%%        if TransportGoodsId > 0 ->
%%            trunc(InitMoveSpeed * (10000 - ?SD_TRANSPORT_GOODS_RATE) / 10000);
%%            true ->
    InitMoveSpeed,
%%        end,
%%    if IsNotice ->
%%        #obj_scene_actor{
%%            obj_type = ObjType,
%%            obj_id = ObjId,
%%            grid_id = GridId
%%        } = ObjSceneActor,
%%        NoticePlayerIdList = mod_scene_grid_manager:get_subscribe_player_id_list(GridId),
%%        if ObjType == ?OBJ_TYPE_PLAYER ->
%%            api_scene:notice_player_attr_change(NoticePlayerIdList, ObjId, [{?P_MOVE_SPEED, MoveSpeed_1}]);
%%            true ->
%%                api_scene:api_notice_monster_attr_change(NoticePlayerIdList, ObjId, [{?P_MOVE_SPEED, MoveSpeed_1}])
%%        end;
%%        true ->
%%            noop
%%    end,
    ObjSceneActor#obj_scene_actor{
        move_speed = MoveSpeed_1
    }.

show_action(PlayerId, ActionId) ->
    SceneWork = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    ?ASSERT(SceneWork /= null, not_in_scene),
    true = mod_interface_cd:assert(show_action, 1 * 1000),
    gen_server:cast(SceneWork, {?MSG_SCENE_PLAYER_SHOW_ACTION, PlayerId, ActionId}),
    ok.

%% ----------------------------------
%% @doc 	获取该场景的所有玩家id
%% @throws 	none
%% @end
%% ----------------------------------
get_player_id_list_by_scene_id(SceneId) ->
    [E#ets_obj_player.id || E <- mod_obj_player:get_all_obj_player(), E#ets_obj_player.scene_id == SceneId].


%% ----------------------------------
%% @doc 	广播聊天消息
%% @throws 	none
%% @end
%% ----------------------------------
broadcast_chat_msg(Msg) ->
    lists:foreach(
        fun(E) ->
            #obj_scene_actor{
                client_worker = ClientWorker,
                is_robot = IsRobot
            } = E,
            if IsRobot == false ->
                client_worker:apply(ClientWorker, mod_socket, send, [Msg]);
                true ->
                    noop
            end
        end,
        mod_scene_player_manager:get_all_obj_scene_player()
    ).


%% ================================================ 模板操作 ================================================
%% 场景数据
get_t_scene(SceneId) ->
    case t_scene:get({SceneId}) of
        null ->
            ?ERROR("none scene:~p", [SceneId]),
            null;
        R -> R
    end.

%% 选择场景数据
%%try_get_t_scene_select(SceneId) ->
%%    Table = t_scene_select:get({SceneId}),
%%    ?IF(is_record(Table, t_scene_select), Table, exit({null_t_scene_select, {SceneId}})).

%% ----------------------------------
%% @doc 	场景日志写入
%%          2021-10-22 支持玩家进入场景的日志记录
%% @throws 	none
%% @end
%% ----------------------------------
%%write_scene_log(LoggerData, Kind) ->
%%    case Kind of
%%        enter_scene_log -> write_scene_log(LoggerData, enter_scene_log);
%%        _ -> noop
%%    end;
write_scene_log(LoggerData, enter_scene_log) ->
    {player_id, PlayerId} = lists:keyfind(player_id, 1, LoggerData),
    ?ASSERT(PlayerId =/= false, invalid_player),
    {level, Level} = lists:keyfind(level, 1, LoggerData),
    {vip_level, VipLevel} = lists:keyfind(vip_level, 1, LoggerData),
    {scene_id, SceneId} = lists:keyfind(scene_id, 1, LoggerData),
    {scene_type, SceneType} = lists:keyfind(scene_type, 1, LoggerData),
    {is_single, IsSingle} = lists:keyfind(is_single, 1, LoggerData),
    {mission_id, MissionId} = lists:keyfind(mission_id, 1, LoggerData),
    {mission_type, MissionType} = lists:keyfind(mission_type, 1, LoggerData),
    if
        (SceneId =:= false andalso SceneType =:= false) andalso (MissionId =:= false andalso MissionType =:= false) ->
            ?DEBUG("fff noop"),
            noop;
        true ->
            ?DEBUG("fff: ~p", [LoggerData]),
            Data = [
                {p, PlayerId},                  %% 玩家id
                {level, Level},                  %% 玩家id
                {vip_level, VipLevel},                  %% 玩家id
                {scene_id, ?IF(SceneId =:= false, 0, SceneId)},
                {scene_type, ?IF(SceneType =:= false, 0, SceneType)},
                {mission_id, ?IF(MissionId =:= false, 0, MissionId)},
                {mission_type, ?IF(MissionType =:= false, 0, MissionType)},
                {single, IsSingle}
            ],
%%            ?DEBUG("fff: ~p", [Data])
            logger2:write(enter_scene_log, Data)
    end.
