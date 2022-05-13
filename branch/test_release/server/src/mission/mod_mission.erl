%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            副本
%%% @end
%%% Created : 20. 六月 2016 下午 1:46
%%%-------------------------------------------------------------------
-module(mod_mission).
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("common.hrl").
-include("gen/table_enum.hrl").
-include("scene.hrl").
-include("error.hrl").
-include("mission.hrl").
-include("msg.hrl").
-include("p_enum.hrl").
-include("client.hrl").

%% API
-export([
    exit_mission/1,                         %% 退出副本
    challenge_mission/3,                    %% 挑战副本
    challenge_mission/4,
    cache_mission_award/3,                  %% 副本缓存奖励
    get_cache_mission_award/2,              %% 领取副本缓存奖励
    get_player_mission_data/2,              %% 获取玩家副本数据
    async_challenge_mission/3,              %% 异步挑战副本
    boss_rebirth/3,                         %% boss 复活
    get_all_player_mission_data/1,
    get_max_mission_id/1,
    is_cross_mission/2,                     %% 是否跨服副本
    get_mission_monster_total_num/2,        %% 获取该副本怪物总数量
    get_scene_id_by_mission/2,              %% 获取副本对应的场景id
    active_balance/1,                       %% 主动结算副本
    is_passed_mission/3,                    %% 是否已经通关副本
    get_player_passed_mission_id/2,         %% 获取玩家副本通关id
    try_update_player_passed_mission_id/3,  %% 更新玩家副本通关id
    get_player_zhu_xian_id/1,               %% 获得完成的主线副本id
    get_log_type_by_mission_type/1,         %% 通过副本类型获取日志类型
    try_del_times/4                        %% 扣除副本次数
%%    auto_sweep_mission/2                    %% 一键扫荡
]).

%% 副本消息
-export([
    send_msg/1,                             %% 发送副本消息
    send_msg/2,
    send_msg_delay/2,
    send_msg_delay/3,
    call/2,                                 %% call 副本
    pack_mission_msg/1
]).
-export([
    direct_finish/3,                        %% 直接完成副本
    is_balance/0,                           %% 是否已经结算
    set_is_balance/1,
    is_start/0,                             %% 是否已经启动
    set_is_start/1,
    assert_mission_start/0,
    get_mission_result/0,                   %% 副本结果
    set_mission_result/1,
    get_mission_balance_time_ms/0,          %% 副本结算时间
    set_mission_balance_time_ms/1,
    get_mission_start_time_ms/0,            %% 获取副本启动时间
    set_mission_start_time_ms/1,
    is_notice_round/1,                      %% 是否通知波次
    get_notice_round_type/1,
    is_round_award/1,                       %% 是否每波奖励
%%    get_mission_module/1,                   %% 获取副本模块
    get_t_mission_type/1,
    get_t_mission/2,                        %% 获取副本
    get_all_mission_id_by_mission_type/1,
%%    get_mission_round_award/3,
    get_function_id_by_mission_type/1,
    get_mission_kind/1                      %% 获取副本类别
]).

%% ----------------------------------
%% @doc 	获取玩家副本数据
%% @throws 	none
%% @end
%% ----------------------------------
get_player_mission_data(PlayerId, MissionType) ->
    db:read(#key_player_mission_data{
        player_id = PlayerId,
        mission_type = MissionType
    }).


get_all_player_mission_data(PlayerId) ->
    db:select(player_mission_data, [{#db_player_mission_data{player_id = PlayerId, _ = '_'}, [], ['$_']}]).


%% ----------------------------------
%% @doc 	是否已经通关副本
%% @throws 	none
%% @end
%% ----------------------------------
is_passed_mission(PlayerId, MissionType, MissionId) ->
    PassedMissionId = get_player_passed_mission_id(PlayerId, MissionType),
    PassedMissionId >= MissionId.

%% ----------------------------------
%% @doc 	获取玩家副本已通关id
%% @throws 	none
%% @end
%% ----------------------------------
get_player_passed_mission_id(PlayerId, MissionType) ->
    case get_player_mission_data(PlayerId, MissionType) of
        null ->
            0;
        R ->
            R#db_player_mission_data.mission_id
    end.

%% @fun 获得完成的主线副本id
get_player_zhu_xian_id(PlayerId) ->
    get_player_passed_mission_id(PlayerId, ?MISSION_TYPE_ZHU_XIAN).


%% ----------------------------------
%% @doc 	boss 复活
%% @throws 	none
%% @end
%% ----------------------------------
boss_rebirth(PlayerId, MissionType, MissionId) ->
    ?INFO("boss复活:~p", [{PlayerId, MissionType, MissionId}]),
    VipLevel = mod_vip:get_vip_level(PlayerId),
    ?ASSERT(VipLevel >= 3, vip_limit),
%%    ?ASSERT(MissionType == ?MISSION_TYPE_ZHUANG_BEI orelse MissionType == ?MISSION_TYPE_HUNTING_BOSS orelse MissionType == ?MISSION_TYPE_DREAMLAND_BOSS orelse MissionType == ?MISSION_TYPE_MING_YU),
    #t_mission{
        scene_id = SceneId,
        boss_rebirth_list = [PropId, Num],
        boss_id = BossId
    } = get_t_mission(MissionType, MissionId),
    mod_prop:assert_prop_num(PlayerId, PropId, Num),
    {ok, SceneWorker} = scene_master:get_scene_worker(SceneId),
    case gen_server:call(SceneWorker, {?MSG_SCENE_REBIRTH_MONSTER, BossId}) of
        {error, Reason} ->
            exit(Reason);
        Result ->
            Result
    end,
    Tran = fun() ->
        mod_prop:decrease_player_prop(PlayerId, PropId, Num, ?LOG_TYPE_BOSS_REBIRTH)
           end,
    db:do(Tran).


%% ----------------------------------
%% @doc 	更新玩家副本通关id
%% @throws 	none
%% @end
%% ----------------------------------
try_update_player_passed_mission_id(PlayerId, MissionType, MissionId) ->
    #t_mission_type{
        is_record_passed = IsRecordPassed
    } = get_t_mission_type(MissionType),
    if IsRecordPassed == ?TRUE ->
        case get_player_mission_data(PlayerId, MissionType) of
            null ->
                Tran = fun() ->
                    db:write(#db_player_mission_data{
                        player_id = PlayerId,
                        mission_type = MissionType,
                        mission_id = MissionId,
                        time = util_time:timestamp()
                    })
                       end,
                db:do(Tran);
            R ->
                if R#db_player_mission_data.mission_id >= MissionId ->
                    noop;
                    true ->
                        Tran = fun() ->
                            db:write(R#db_player_mission_data{
                                mission_id = MissionId,
                                time = util_time:timestamp()
                            })
                               end,
                        db:do(Tran)
                end
        end,
        api_mission:notice_passed_mission(PlayerId, MissionType, MissionId);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	发送副本消息
%% @throws 	none
%% @end
%% ----------------------------------
send_msg(Msg) ->
    send_msg(self(), Msg).

send_msg(PlayerId, Msg) when is_integer(PlayerId) ->
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    send_msg(SceneWorker, Msg);
send_msg(SceneWorker, Msg) when is_pid(SceneWorker) ->
    SceneWorker ! pack_mission_msg(Msg).

send_msg_delay(Msg, Delay) ->
    send_msg_delay(self(), Msg, Delay).

send_msg_delay(SceneWorker, Msg, Delay) ->
    if
        Delay =< 0 ->
            SceneWorker ! pack_mission_msg(Msg);
        true ->
            erlang:send_after(Delay, SceneWorker, pack_mission_msg(Msg))
    end.

%% ----------------------------------
%% @doc 	call
%% @throws 	none
%% @end
%% ----------------------------------
%% return : exit(Reason) | reply
call(PlayerId, Msg) when is_integer(PlayerId) ->
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    call(SceneWorker, Msg);
call(SceneWorker, Msg) when is_pid(SceneWorker) ->
    case gen_server:call(SceneWorker, pack_mission_msg(Msg)) of
        {error, Reason} ->
            exit(Reason);
        Result ->
            Result
    end.

%% ----------------------------------
%% @doc 	打包消息
%% @throws 	none
%% @end
%% ----------------------------------
pack_mission_msg(Msg) ->
    {?MSG_MISSION_MSG, Msg}.

%% ----------------------------------
%% @doc 	挑战副本(异步)
%% @throws 	none
%% @end
%% ----------------------------------
async_challenge_mission(PlayerId, MissionType, MissionId) ->
    client_worker:send_msg(self(), {?MSG_ASYNC_CHALLENGE_MISSION, PlayerId, MissionType, MissionId}).

%%handle_async_challenge_mission(PlayerId, MissionType, MissionId) ->
%%    challenge_mission(PlayerId, MissionType, MissionId, true).


%% ----------------------------------
%% @doc 	挑战副本
%% @throws 	none
%% @end
%% ----------------------------------
challenge_mission(PlayerId, MissionType, MissionId) ->
    challenge_mission(PlayerId, MissionType, MissionId, false).
challenge_mission(PlayerId, MissionType, MissionId, IsNotice) ->
    %% 确保可以挑战副本
    ?DEBUG("玩家挑战副本:~p", [{PlayerId, MissionType, MissionId, IsNotice}]),
    assert_challenge_mission(PlayerId, MissionType, MissionId),
    #t_mission{
        scene_id = SceneId,
        jump_scene_list = JumpSceneList
    } = get_t_mission(MissionType, MissionId),

    RealJumpSceneList =
        if JumpSceneList == [] ->
            case get(?DICT_PLAYER_SCENE_ID) of
                ?UNDEFINED ->
                    [];
                0 ->
                    [];
                _NowSceneId ->
                    []
            end;
            true ->
                JumpSceneList
        end,
    put(?DICT_EXIT_MISSION_JUMP_SCENE, RealJumpSceneList),      %% 缓存退出场景后跳转的场景信息

    AddExtraDataList =
        if
            MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS ->   %% 勇敢者
                [{tmp_scene_worker, mod_mission_brave_one:get_mission_scene_worker(PlayerId)}];
            MissionType =:= ?MISSION_TYPE_GUESS_BOSS -> [];
            true ->
                []
        end,
    mod_scene:player_enter_scene(PlayerId, SceneId, [{mission_id, MissionId}] ++ AddExtraDataList),      %% 进入副本场景
%%    mod_log:write_player_challenge_mission_log(PlayerId, MissionType, MissionId),
    if IsNotice ->
        api_mission:notice_challenge_mission(PlayerId, MissionType, MissionId);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	校验是否可以挑战副本
%% @throws 	none
%% @end
%% ----------------------------------
assert_challenge_mission(PlayerId, MissionType, MissionId) ->
    mod_interface_cd:assert(challenge_mission, 1000),
    #t_mission_type{
        times_id = TimesId_1,
        function_id = FunctionId,
        is_repeat_challenge = IsCanRepeatChallenge,
        is_must_passed_last = IsMustPassedLast,
        is_record_passed = IsRecordPassed,
        is_can_sweep = IsCanSweep
    } = get_t_mission_type(MissionType),
    % 功能限制
    if FunctionId > 0 ->
        mod_function:assert_open(PlayerId, FunctionId);
        true ->
            noop
    end,
    #t_mission{
        times_id = TimesId_2,
        enter_conditions_list = EnterConditionsList,
%%        round = MainMissionNeedRound,
%%        need_power_list = NeedPowerList,
        mana_enter_list = EnterLingLingList
    } = get_t_mission(MissionType, MissionId),
    RealTimesId =
        if TimesId_1 > 0 ->
            TimesId_1;
            true ->
                TimesId_2
        end,

    if
        EnterConditionsList == [] -> noop;
        true -> ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, EnterConditionsList), ?ERROR_NOT_AUTHORITY)
    end,

    case EnterLingLingList of
        [LingMin, LingMax] ->
            PropId = ?ITEM_GOLD,
            CurrNum = mod_prop:get_player_prop_num(PlayerId, PropId),
            if LingMin =< CurrNum andalso (LingMax == 0 orelse CurrNum =< CurrNum) -> noop;
                true -> exit(?ERROR_NO_ENOUGH_PROP)
            end;
        true -> noop
    end,
%%    lists:foreach(
%%        fun(ConditionsL) ->
%%            ?ASSERT(mod_conditions:is_player_conditions_state(PlayerId, ConditionsL) == true, ?ERROR_NOT_AUTHORITY)
%%        end, EnterConditionsList),

    %% 战力限制
%%    case NeedPowerList of
%%        [NeedMin, NeedMax] ->
%%            Power = mod_player:get_player_data(PlayerId, power),
%%            ?ASSERT(Power >= NeedMin, {?ERROR_NO_ENOUGH_POWER, Power, [NeedMin, NeedMax]});
%%        _ ->
%%            noop
%%    end,
    % 次数限制
    if RealTimesId > 0 andalso IsCanSweep == ?FALSE ->
%%        IsCheckTimes =
%%            if MissionType == ?MISSION_TYPE_ZHUANG_BEI
%%                orelse MissionType == ?MISSION_TYPE_HUNTING_BOSS
%%                orelse MissionType == ?MISSION_TYPE_DREAMLAND_BOSS
%%                orelse MissionType == ?MISSION_TYPE_MING_YU ->
%%                %% 装备副本参与中 不需要再扣次数
%%                mod_mission_equip:is_join(PlayerId, MissionType, MissionId) == false;
%%                true ->
%%        true,
%%            end,

%%        if
%%            IsCheckTimes ->
%%                IsDoCheck = true,
%%                IsDoCheck =
%%                    if
%%                    @TODO  副本屏蔽
%%                    MissionType == ?MISSION_TYPE_ZHUANG_BEI ->
%%                        mod_prop:check_prop_num(PlayerId, ?PROP_TYPE_ITEM, ?ITEM_SIEGE_TOKEN, 1) == false;
%%                    MissionType == ?MISSION_TYPE_HUNTING_BOSS ->
%%                        mod_prop:check_prop_num(PlayerId, ?PROP_TYPE_ITEM, ?ITEM_HUNTING_TOKEN, 1) == false;
%%                    MissionType == ?MISSION_TYPE_DREAMLAND_BOSS ->
%%                        mod_prop:check_prop_num(PlayerId, ?PROP_TYPE_ITEM, ?ITEM_TAIXUHUANJING_TOKEN, 1) == false;
%%                    MissionType == ?MISSION_TYPE_MING_YU ->
%%                        mod_prop:check_prop_num(PlayerId, ?PROP_TYPE_ITEM, ?ITEM_MINTGYU_TOKEN, 1) == false;
%%                        true ->
%%                            true
%%                    end,
%%                if IsDoCheck ->
        mod_times:assert_times(PlayerId, RealTimesId);
%%                    true ->
%%                        noop
%%                end;
%%            true ->
%%                noop
%%        end;
        true ->
            noop
    end,
    %% 副本类型验证条件
    if
        MissionType == ?MISSION_TYPE_MANY_PEOPLE_BOSS ->
            exit(?ERROR_FAIL);
        MissionType == ?MISSION_TYPE_GUESS_BOSS ->
            mod_mission_guess_boss:is_enter_mission(PlayerId, MissionId);
        MissionType == ?MISSION_TYPE_SHISHI_BOSS ->
            mod_mission_shi_shi:is_enter_mission(PlayerId, MissionId);
        MissionType == ?MISSION_TYPE_BRAVE_ONE_SYS ->   %% 勇敢者
            mod_mission_brave_one:is_enter_mission(PlayerId);
        MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_LOCATION orelse MissionType == ?MISSION_TYPE_MISSION_SCENE_BOSS_TIME_AND_COUNT
            ->   %% 场景boss
            exit(?ERROR_NOT_AUTHORITY);
        MissionType == ?MISSION_TYPE_MANY_PEOPLE_SHISHI ->
            %% 多人时时彩
            exit(?ERROR_NOT_AUTHORITY);
        true ->
            true
    end,
%%    ?DEBUG("~p~n", [{MissionType, MissionId, IsRecordPassed}]),
    if IsRecordPassed == ?FALSE ->
        noop;
        true ->
            PlayerMissionData = get_player_mission_data(PlayerId, MissionType),

            if PlayerMissionData == null ->
                if MissionId > 1 ->
                    ?WARNING("玩家副本数据未初始化:~p~n", [{MissionType, MissionId}]);
                    true ->
                        noop
                end;
                true ->
                    #db_player_mission_data{
                        mission_id = PassedMissionId
                    } = PlayerMissionData,

                    % 是否可以重复挑战
                    if IsCanRepeatChallenge == ?TRUE ->
                        noop;
                        true ->
                            ?ASSERT(MissionId > PassedMissionId, already_passed)
                    end,
%%            ?DEBUG("是否必须通关上一关:~p~n", [{MissionType, MissionId, IsMustPassedLast}]),
                    % 是否必须通关上一关
                    if IsMustPassedLast == ?TRUE ->
                        ?ASSERT(MissionId =< PassedMissionId + 1, last_no_passed);
                        true ->
                            noop
                    end
            end
    end.

%% ----------------------------------
%% @doc 	扣除副本次数
%% @throws 	none
%% @end
%% ----------------------------------
try_del_times(PlayerId, MissionType, MissionId, Node) ->
    #t_mission_type{
        times_id = TimesId_1,
        del_times_node = DelTimesNode
    } = get_t_mission_type(MissionType),
    RealTimesId =
        if TimesId_1 > 0 ->
            TimesId_1;
            true ->
                #t_mission{
                    times_id = TimesId_2
                } = get_t_mission(MissionType, MissionId),
                TimesId_2
        end,
    if RealTimesId > 0 ->
        if (DelTimesNode == 0 andalso Node == enter_mission)
            orelse (DelTimesNode == 1 andalso Node == finish_mission)
            orelse (DelTimesNode == 2 andalso Node == special) ->
            _LogType = get_log_type_by_mission_type(MissionType),
%%            IsDelTimes =
%%                if
%%                    true ->
%%                        true
%%                end,
%%            if IsDelTimes ->
            mod_times:use_times(PlayerId, RealTimesId);
%%                true ->
%%                    noop
%%            end;
            true ->
                noop
        end;
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	获取副本
%% @throws 	none
%% @end
%% ----------------------------------
get_t_mission(MissionType, MissionId) ->
    t_mission:get({MissionType, MissionId}).

%% ----------------------------------
%% @doc 	通过副本类型获取功能id
%% @throws 	none
%% @end
%% ----------------------------------
get_function_id_by_mission_type(MissionType) ->
    #t_mission_type{
        function_id = FunctionId
    } = get_t_mission_type(MissionType),
    FunctionId.

%% ----------------------------------
%% @doc 	直接完成副本
%% @throws 	none
%% @end
%% ----------------------------------
direct_finish(PlayerId, MissionType, MissionId) ->
    PlayerMissionData = get_player_mission_data(PlayerId, MissionType),
    Tran = fun() ->
        db:write(PlayerMissionData#db_player_mission_data{
            mission_id = MissionId
        }),
        hook:do_after_mission_balance(PlayerId, MissionType, MissionId, success, [])
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	是否已经结算
%% @throws 	none
%% @end
%% ----------------------------------
is_balance() ->
    get(?DICT_MISSION_IS_BALANCE).

set_is_balance(Bool) ->
    put(?DICT_MISSION_IS_BALANCE, Bool).

get_notice_round_type(MissionType) ->
    #t_mission_type{
        is_notice_round = IsNoticeRound
    } = get_t_mission_type(MissionType),
    IsNoticeRound.


%% ----------------------------------
%% @doc 	是否跨服副本
%% @throws 	none
%% @end
%% ----------------------------------
is_cross_mission(MissionType, MissionId) ->
    #t_mission{
        scene_id = SceneId
    } = mod_mission:get_t_mission(MissionType, MissionId),
    mod_scene:is_zone_scene(SceneId).

%% ----------------------------------
%% @doc 	是否通知波次
%% @throws 	none
%% @end
%% ----------------------------------
is_notice_round(MissionType) ->
    #t_mission_type{
        is_notice_round = IsNoticeRound
    } = get_t_mission_type(MissionType),
    ?TRAN_INT_2_BOOL(IsNoticeRound).

%% ----------------------------------
%% @doc 	是否每波奖励
%% @throws 	none
%% @end
%% ----------------------------------
is_round_award(MissionType) ->
    #t_mission_type{
        is_round_award = IsRoundAward
    } = get_t_mission_type(MissionType),
    ?TRAN_INT_2_BOOL(IsRoundAward).


%% ----------------------------------
%% @doc 	副本是否已经开始
%% @throws 	none
%% @end
%% ----------------------------------
is_start() ->
    get(?DICT_MISSION_IS_START).

%% ----------------------------------
%% @doc 	标记副本是否启动
%% @throws 	none
%% @end
%% ----------------------------------
set_is_start(Bool) ->
%%    ?DEBUG("副本启动"),
    put(?DICT_MISSION_IS_START, Bool).

assert_mission_start() ->
    ?ASSERT(is_start(), ?ERROR_MISSION_NO_START).

%% ----------------------------------
%% @doc 	获取副本结果
%% @throws 	none
%% @end
%% ----------------------------------
get_mission_result() ->
    get(?DICT_MISSION_RESULT).

%% ----------------------------------
%% @doc 	设置副本结果
%% @throws 	none
%% @end
%% ----------------------------------
set_mission_result(Result) ->
    put(?DICT_MISSION_RESULT, Result).

%% ----------------------------------
%% @doc 	获取副本启动时间
%% @throws 	none
%% @end
%% ----------------------------------
get_mission_start_time_ms() ->
    get(?DICT_MISSION_START_TIME_MS).

%% ----------------------------------
%% @doc 	设置副本启动时间
%% @throws 	none
%% @end
%% ----------------------------------
set_mission_start_time_ms(Time) ->
    put(?DICT_MISSION_START_TIME_MS, Time).

%% ----------------------------------
%% @doc 	获取副本结算时间
%% @throws 	none
%% @end
%% ----------------------------------
get_mission_balance_time_ms() ->
    get(?DICT_MISSION_BALANCE_MS).

%% ----------------------------------
%% @doc 	设置副本结算时间
%% @throws 	none
%% @end
%% ----------------------------------
set_mission_balance_time_ms(Time) ->
    put(?DICT_MISSION_BALANCE_MS, Time).

%% ----------------------------------
%% @doc 	获取副本类型
%% @throws 	none
%% @end
%% ----------------------------------
get_t_mission_type(MissionTypeId) ->
    t_mission_type:get({MissionTypeId}).

%%%% ----------------------------------
%%%% @doc 	获取副本模块
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_mission_module(MissionTypeId) ->
%%    MissionType = get_t_mission_type(MissionTypeId),
%%    util:to_atom(MissionType#t_mission_type.module).

%% ----------------------------------
%% @doc 	缓存副本奖励
%% @throws 	none
%% @end
%% ----------------------------------
cache_mission_award(MissionType, MissionId, TotalAwardList) ->
    put(?DICT_CACHE_MISSION_AWARD, {MissionType, MissionId, TotalAwardList}).

%% ----------------------------------
%% @doc 	领取副本缓存奖励
%% @throws 	none
%% @end
%% ----------------------------------
get_cache_mission_award(_PlayerId, Rate) ->
    case erase(?DICT_CACHE_MISSION_AWARD) of
        ?UNDEFINED ->
            noop;
        {MissionType, MissionId, TotalAwardList} ->
            ?DEBUG("领取副本缓存奖励:~p", [{Rate, MissionType, MissionId, TotalAwardList}])
%%            if MissionType == ?MISSION_TYPE_JING_YAN orelse MissionType == ?MISSION_TYPE_JIN_BI ->
%%                ?ASSERT(lists:member(Rate, [1, 3, 5])),
%%                LogType = get_log_type_by_mission_type(MissionType),
%%                {NeedIngot, RealTotalAwardList} =
%%                    if Rate == 1 ->
%%                        {0, TotalAwardList};
%%                        true ->
%%                            {util_list:opt(Rate, ?SD_RESOURCES_MISSION_AWARD_PARAM), mod_prop:rate_prop(TotalAwardList, Rate)}
%%                    end,
%%                if
%%%%                    NeedIngot > 0 ->
%%%%                    mod_prop:assert_prop_num(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_INGOT, NeedIngot);
%%                    true ->
%%                        noop
%%                end,
%%                Tran = fun() ->
%%                    %% @TODO 副本屏蔽
%%%%                    mod_prop:decrease_player_prop(PlayerId, ?PROP_TYPE_RESOURCES, ?RES_INGOT, NeedIngot, ?LOG_TYPE_GET_MISSION_RATE_AWARD),
%%                    mod_award:give(PlayerId, RealTotalAwardList, LogType)
%%                       end,
%%                db:do(Tran);
%%                true ->
%%                    noop
%%            end
    end.

%% ----------------------------------
%% @doc 	退出副本
%% @throws 	none
%% @end
%% ----------------------------------
exit_mission(PlayerId) ->
    ObjPlayer = mod_obj_player:get_obj_player(PlayerId),
    #ets_obj_player{
        scene_id = SceneId
    } = ObjPlayer,
    case mod_scene:is_mission_scene(SceneId) of
        true ->
            PlayerData = mod_player:get_db_player_data(PlayerId),
            LastSceneId = PlayerData#db_player_data.last_world_scene_id,
            put(is_enter_game_scene, true),
            case get(?DICT_EXIT_MISSION_JUMP_SCENE) of
                0 ->
                    mod_scene:return_world_scene(PlayerId);
                1 ->
                    JumpSceneId = mod_task:get_player_task_scene_id(PlayerId),
                    mod_scene:player_enter_scene(PlayerId, JumpSceneId);
                [JumpSceneId] ->
                    ?DEBUG("跳转场景~p~n", [JumpSceneId]),
                    if LastSceneId =/= JumpSceneId ->
                        mod_scene:player_enter_scene(PlayerId, JumpSceneId);
                        true ->
                            mod_scene:return_world_scene(PlayerId)
                    end;
                [JumpSceneId, JumpX, JumpY] ->
                    ?DEBUG("跳转场景~p~n", [{JumpSceneId, JumpX, JumpY}]),
                    if LastSceneId =/= JumpSceneId ->
                        mod_scene:player_enter_scene(PlayerId, JumpSceneId, JumpX, JumpY);
                        true ->
                            mod_scene:return_world_scene(PlayerId)
                    end;
                [] ->
                    mod_scene:return_world_scene(PlayerId);
                Other ->
                    ?DEBUG("exit_mission:~p~n", [{Other, SceneId}]),
                    mod_scene:return_world_scene(PlayerId)
            end;
        _ ->
            noop
    end.
%%    ?ASSERT(mod_scene:is_mission_scene(SceneId) == true, {already_in_world_scene, SceneId}),
%%    mod_scene:return_world_scene(PlayerId).

%% ----------------------------------
%% @doc 	主动结算副本
%% @throws 	none
%% @end
%% ----------------------------------
active_balance(PlayerId) ->
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    send_msg(SceneWorker, {?MSG_REQUEST_BALANCE_MISSION, PlayerId}).


%% ----------------------------------
%% @doc 	获取副本对应的场景id
%% @throws 	none
%% @end
%% ----------------------------------
get_scene_id_by_mission(MissionType, MissionId) ->
    #t_mission{
        scene_id = SceneId
    } = get_t_mission(MissionType, MissionId),
    SceneId.

%% ----------------------------------
%% @doc 	获取该副本怪物总数量
%% @throws 	none
%% @end
%% ----------------------------------
get_mission_monster_total_num(MissionType, MissionId) ->
    logic_get_mission_total_monster_num:get({MissionType, MissionId}).

%% ----------------------------------
%% @doc 	获取副本类别
%% @throws 	none
%% @end
%% ----------------------------------
get_mission_kind(MissionType) ->
    R = get_t_mission_type(MissionType),
    R#t_mission_type.kind.

%%%% ----------------------------------
%%%% @doc 	获取副本回合波次奖励
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%get_mission_round_award(MissionType, MissionId, Round) ->
%%    t_mission_award:get({MissionType, MissionId, Round}).

%% ----------------------------------
%% @doc     通过副本类型 获取副本id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_all_mission_id_by_mission_type(MissionType) ->
    logic_get_all_mission_id_by_mission_type:get(MissionType).


%% ----------------------------------
%% @doc 	通过副本类型获取日志类型
%% @throws 	none
%% @end
%% ----------------------------------
get_log_type_by_mission_type(MissionType) ->
    #t_mission_type{
        log_type = LogType
    } = get_t_mission_type(MissionType),
    LogType.


%% ----------------------------------
%% @doc 	获取最大的副本id
%% @throws 	none
%% @end
%% ----------------------------------
get_max_mission_id(MissionType) ->
    MaxMissionId = logic_get_max_mission_id_by_mission_type:get(MissionType),
    ?ASSERT(is_integer(MaxMissionId), {no_max_mission_id, MissionType}),
    MaxMissionId.
