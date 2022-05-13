%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家进程消息处理
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(client_msg_handle).
%% API
-export([
    msg_timer/2,            %% 玩家定时器
    handle/2
]).

-export([
    send_msg_timer/3,         %% 玩家进程时间消息
    init_timer_type/1,        %% 玩家定时器
    init_timer_type/2,        %% 玩家定时器
    init_timer_type_player_work/2   %% 玩家进程定时器
]).

-include("msg.hrl").
-include("client.hrl").
-include("common.hrl").
-include("mission.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").
%% ----------------------------------
%% @doc 	进程msg处理
%% @throws 	none
%% @end
%% ----------------------------------
handle(MsgList, State) when is_list(MsgList) ->
    handle_msg_list(MsgList, State);
handle(Msg, State) ->
    handle_msg_list([Msg], State).

handle_msg_list([], _State) ->
    ok;
handle_msg_list([Msg | T], State = #conn{player_id = PlayerId, acc_id = AccId, server_id = ServerId}) ->
    case Msg of
        ?MSG_CLIENT_AFTER_ENTER_GAME ->
            hook:after_enter_game(PlayerId, AccId, ServerId);
        {?MSG_CLIENT_ATTACK_MONSTER, SceneId, MonsterId} ->
            hook:after_attack_monster(PlayerId, SceneId, MonsterId);
        {?MSG_CLIENT_KILL_MONSTER, SceneId, MonsterId, KillNum} ->
            hook:after_kill_monster(PlayerId, SceneId, MonsterId, KillNum);
        {?MSG_CLIENT_KILL_PLAYER, KillPlayerId, SceneId} ->
            hook:after_kill_player(PlayerId, KillPlayerId, SceneId);
        {?MSG_CLIENT_BE_KILLED, AttackObjType, AttackObjId, SceneId} ->
            hook:be_killed(PlayerId, AttackObjType, AttackObjId, SceneId);
        ?MSG_CLIENT_RETURN_WORLD_SCENE ->
            mod_scene:return_world_scene(PlayerId);
        {?MSG_CLIENT_RECOVER_TIMES, TimesId} ->
            mod_times_recover:handle_recover_times(PlayerId, TimesId);
        {?MSG_CLIENT_ENTER_SCENE, PlayerId, SceneId, ExtraDataList} ->
            mod_scene:player_enter_scene(PlayerId, SceneId, ExtraDataList);
        {?MSG_CLIENT_ENTER_SCENE, PlayerId, SceneId, X, Y, ExtraDataList, CallBackFun} ->
            mod_scene:player_enter_scene(PlayerId, SceneId, X, Y, ExtraDataList, CallBackFun);
        {?MSG_CLIENT_ENTER_SCENE, PlayerId, SceneId, X, Y} ->
            mod_scene:player_enter_scene(PlayerId, SceneId, X, Y);
        {?MSG_ASYNC_CHALLENGE_MISSION, PlayerId, MissionType, MissionId} ->
            mod_mission:challenge_mission(PlayerId, MissionType, MissionId, true);
        {?MSG_SCENE_PLAYER_TRANSMIT, PlayerId, RealGoX, RealGoY, CallBackFun, SceneWorker} ->
            erlang:send(SceneWorker, {?MSG_SCENE_PLAYER_DO_TRANSMIT, PlayerId, RealGoX, RealGoY, CallBackFun});
        {?MSG_PLAYER_FIGHT_MONSTER_LOG, MonsterObjId, MonsterId, Cost, Award} ->
            if
                Award =/= ?UNDEFINED andalso Award > 0 -> % 有奖励，表示怪物死亡
                    % 更新玩家杀怪数量
                    PlayerKillMonsterIdList = util:get_dict(player_kill_monster_id_list, []),
                    NewPlayerKillMonsterIdList =
                        case lists:keytake(MonsterId, 1, PlayerKillMonsterIdList) of
                            false ->
                                [{MonsterId, 1} | PlayerKillMonsterIdList];
                            {value, Tuple, List2} ->
                                {MonsterId, OldNum} = Tuple,
                                [{MonsterId, OldNum + 1} | List2]
                        end,
                    put(player_kill_monster_id_list, NewPlayerKillMonsterIdList),

                    % 打怪记录写入日志
                    PlayerHurtLogList = util:get_dict(monster_hurt_log_list, []),
                    LogList =
                        case lists:keytake(MonsterObjId, 1, PlayerHurtLogList) of
                            false ->
                                [
                                    {t, 2},
                                    {p, PlayerId},      %% 玩家id
                                    {m, MonsterId},     %% 怪物id
                                    {c, Cost},          %% 消耗
                                    {a, Award},          %% 奖励
                                    {be_atk_times, 1}     %% 被攻击次数
                                ];
                            {value, PlayerHurtLogTuple, PlayerHurtLogList2} ->
                                {MonsterObjId, OldMonsterId, OldCost, OldBeAtkTimes, _} = PlayerHurtLogTuple,
                                put(monster_hurt_log_list, PlayerHurtLogList2),
                                [
                                    {t, 2},
                                    {p, PlayerId},      %% 玩家id
                                    {m, OldMonsterId},     %% 怪物id
                                    {c, OldCost + Cost},%% 消耗
                                    {a, Award},          %% 奖励
                                    {be_atk_times, OldBeAtkTimes + 1} %% 被攻击次数
                                ]
                        end,
                    logger2:write(player_fight_log2, LogList);
                true -> % 怪物没死，统计打怪记录
                    Now = util_time:timestamp(),
                    PlayerHurtLogList = util:get_dict(monster_hurt_log_list, []),
                    NewPlayerHurtLogList =
                        case lists:keytake(MonsterObjId, 1, PlayerHurtLogList) of
                            false ->
                                [{MonsterObjId, MonsterId, Cost, 1, Now} | PlayerHurtLogList];
                            {value, PlayerHurtLogTuple, PlayerHurtLogList2} ->
                                {MonsterObjId, PlayerMonsterId, OldCost, OldBeAtkTimes, _} = PlayerHurtLogTuple,
                                if
                                    PlayerMonsterId == MonsterId ->
                                        [{MonsterObjId, MonsterId, OldCost + Cost, OldBeAtkTimes + 1, Now} | PlayerHurtLogList2];
                                    true ->
                                        [{MonsterObjId, MonsterId, Cost, 1, Now} | PlayerHurtLogList2]
                                end
                        end,
                    put(monster_hurt_log_list, NewPlayerHurtLogList)
            end;
        {hit_damage, HitDamage, SceneId} ->
            ?DEBUG("被怪物攻击扣金币：~p", [{HitDamage}]),
            PropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
            PlayerPropNum = mod_prop:get_player_prop_num(PlayerId, PropId),
            CostNum = min(PlayerPropNum, HitDamage),
            ?IF(CostNum > 0, mod_prop:decrease_player_prop(PlayerId, PropId, CostNum, ?LOG_TYPE_FIGHT), noop);
        {fanpai, AwardList} ->
            mod_scene:add_fight_fanpai(PlayerId, AwardList);
        Other ->
            ?ERROR("Unexpected msg:~p", [Other])
    end,
    handle_msg_list(T, State).

%% @fun 玩家定时器
msg_timer(Msg, #conn{player_id = PlayerId}) ->
    case Msg of
        ?MSG_CLIENT_PLAYER_MAIL ->
            ?TRY_CATCH(mod_mail:clear_mail_old_time(PlayerId)),
            init_timer_type(PlayerId, Msg);
        ?MSG_CLIENT_ONLINE_AWARD ->
            mod_online_award:notice_get_online_award(PlayerId),
            init_timer_type(PlayerId, Msg);
        Other ->
            ?ERROR("Unexpected msg_timer:~p", [Other])
    end.


%% @doc     玩家定时器
init_timer_type(PlayerId) ->
    init_timer_type(PlayerId, ?MSG_CLIENT_PLAYER_MAIL),
    init_timer_type(PlayerId, ?MSG_CLIENT_ONLINE_AWARD).
%% @fun 玩家定时器
init_timer_type(PlayerId, Type) ->
    Time =
        case Type of
            ?MSG_CLIENT_PLAYER_MAIL ->
                mod_mail:clear_mail_old_time(PlayerId);
            ?MSG_CLIENT_ONLINE_AWARD ->
                mod_online_award:init_time(PlayerId)
        end,
    if
        Time > 0 ->
            Ref = erlang:send_after(Time, self(), {msg_timer, Type}),
            % 需要记录计时器的类型
            if
                Type == ?MSG_CLIENT_PLAYER_MAIL
                    orelse Type == ?MSG_CLIENT_TIME_LIMIT_TASK
                    orelse Type == ?MSG_CLIENT_ONLINE_AWARD ->
                    util:update_timer_value(Type, Ref);
                true ->
                    noop
            end;
        true ->
            noop
    end.

%% @fun 玩家进程时间消息
send_msg_timer(Time, Worker, Msg) when is_pid(Worker) andalso Time > 0 ->
    erlang:send_after(Time, Worker, pack_msg_timer(Msg));
send_msg_timer(Time, _Worker, Msg) ->
    exit({send_msg_timer, Time, Msg}).

pack_msg_timer(Msg) ->
    {msg_timer, Msg}.

%% @fun 玩家进程定时器
init_timer_type_player_work(PlayerId, Type) ->
    case get(?DICT_PLAYER_ID) == PlayerId of
        true ->
            init_timer_type(PlayerId, Type);
        _ ->
            mod_apply:apply_to_online_player(PlayerId, ?MODULE, init_timer_type, [PlayerId, Type])
    end.

