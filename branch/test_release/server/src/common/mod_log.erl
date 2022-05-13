%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            日志模块
%%% @end
%%% Created : 26. 十一月 2016 下午 2:10
%%%-------------------------------------------------------------------
-module(mod_log).
-include("gen/db.hrl").
-include("common.hrl").
-include("system.hrl").
-include("scene.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("player_game_data.hrl").
%% 玩家日志
-export([
%%    write_player_ingot_log/4,               %% 元宝日志
%%    write_player_coin_log/4,                %% 铜钱日志
%%    write_player_item_log/6,                %% 物品日志
    write_player_times_log/4,               %% 次数日志
    write_player_vip_log/5,                 %% VIP日志
    write_player_challenge_mission_log/7,   %% 玩家挑战副本日志
    write_special_prop_change_log/7,        %% 特殊道具日志
    write_player_login_fail_log/6,          %% 登录失败日志
    write_player_create_role_fail_log/6,    %% 创角失败日志
    write_player_login_log/3,               %% 登录日志
    write_player_online_log/5,              %% 在线日志
    write_player_send_proto_log/2,          %% 协议发送日志
    write_player_receive_proto_log/2,       %% 协议接收日志
    write_task_log/2,                       %% 任务日志
    write_player_fight_monster_log/1,       %% 玩家杀怪日志
    write_monster_cost_log/1,               %% 玩家怪物消耗日志
    write_player_prop_log/1,                %% 玩家道具日志(测试钻石数量变化)
    write_player_prop_log_2/1,              %% 玩家道具日志(测试钻石数量变化)
    write_all_monster_cost_log/1,           %% 全部怪物消耗日志

    db_write_player_mail_log/5,                %% 邮件日志带事务中
    write_player_mail_log/2,                %% 邮件日志
    write_player_gift_mail_log/5,           %% 礼物日志
    write_charge_log/6,                     %% 充值日志
    write_player_mail_error_log/4,            %% 邮件错误日志
    write_attr_log/6,                       %% 玩家属性日志
    write_activity_time_log/2,              %% 活动时间日志
    write_player_activity_time_log/6,       %% 玩家活动时间日志
    write_activity_log/6,
    write_activity_award_log/3,             %% 活动奖励日志
    write_player_client_log/2,              %% 玩家客户端打点日志
    write_monster_delete_log/3              %% 怪物对象销毁日志
]).

%% 系统日志
-export([
    write_system_monitor_log/0,             %% 系统监控
    write_online_statistics_log/0,          %% 在线分析
    write_process_monitor_log/0             %% 进程监控
%%    write_server_trace_daily_log/10         %% 服务器每日统计数据
]).


-export([
    add_game_award_log/2,
    add_game_cost_log/2,
    enter_game/2,
    leave_game/1
]).

-export([
    add_mission_award/2,
    add_mission_cost/2,
    enter_mission/1,
    leave_mission/1,
    balance_mission/3,
    write_player_game_log/7
]).

-export([
    write_prop_change_log/5
]).

-export([
    adjust_test_log/1
]).

adjust_test_log(PlayerId) ->
    #ets_obj_player{
        scene_worker = SceneWorker
    } = mod_obj_player:get_obj_player(PlayerId),
    SceneWorker = mod_obj_player:get_obj_player_scene_worker(PlayerId),
    AdjustReboundTotalCost =
        case scene_worker:get_dict(SceneWorker, {scene_adjust_rebound_total_cost, PlayerId}) of
            ?UNDEFINED ->
                0;
            Value1 ->
                Value1
        end,
    AdjustReboundTotalAward =
        case scene_worker:get_dict(SceneWorker, {scene_adjust_rebound_total_award, PlayerId}) of
            ?UNDEFINED ->
                0;
            Value2 ->
                Value2
        end,
    GoldNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_GOLD),
    RmbNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_RMB),
    logger2:write(player_adjust_test_log,
        [
            {p, PlayerId},
            {award, AdjustReboundTotalAward},
            {cost, AdjustReboundTotalCost},
            {gold, GoldNum},
            {rmb, RmbNum}
        ]
    ).

%%%===================================================================
%%%                          玩家日志
%%%===================================================================

add_game_award_log(_PlayerId, Award) ->
    ?TRY_CATCH2(put('game_award', Award ++ get('game_award'))).

add_game_cost_log(_PlayerId, Cost) ->
    ?TRY_CATCH2(put('game_cost', Cost ++ get('game_cost'))).

enter_game(PlayerId, SceneId) ->
    mod_service_player_log:add_log(PlayerId, {?SERVICE_LOG_PLAYER_ENTER_SCENE_COUNT, SceneId}),
    put('game_time', util_time:timestamp()),
    put('game_scene_id', SceneId),
    put('game_cost', []),
    put('game_award', []).

leave_game(PlayerId) ->
    SceneId = get('game_scene_id'),
%%    #t_scene{
%%        type = Type
%%    } = mod_scene:get_t_scene(SceneId),
%%    if
%%        Type =:= 1 ->
%%            T = get('game_time'),
%%            Now = util_time:timestamp(),
%%            CostList = get('game_cost'),
%%            AwardList = get('game_award'),
%%            mod_service_player_log:add_log(PlayerId, ?SERVICE_LOG_PLAYER_SCENE_TIME, Now - T),
%%            write_player_game_log(PlayerId, SceneId, T, Now, CostList, AwardList, 0);
%%        true ->
%%            noop
%%    end.
    T = get('game_time'),
    Now = util_time:timestamp(),
    CostList = get('game_cost'),
    AwardList = get('game_award'),
    mod_service_player_log:add_log(PlayerId, {?SERVICE_LOG_PLAYER_SCENE_TIME, SceneId}, Now - T),
    write_player_game_log(PlayerId, SceneId, T, Now, CostList, AwardList, 0).

encode(List) ->
    erlang:binary_to_list(
        util_json:encode(
            [
                case Prop of
                    [A, B] ->
                        [A, B];
                    {A, B} ->
                        [A, B]
                end
                || Prop <- List
            ])).

enter_mission(PlayerId) ->
    List = util:get_dict('enter_mission_player_list', []),
    NewList =
        case lists:keytake(PlayerId, 1, List) of
            false ->
                [{PlayerId, util_time:timestamp(), 0, 0, 0} | List];
            {value, {_, _, InMissionTime, Cost, Award}, List1} ->
                [{PlayerId, util_time:timestamp(), InMissionTime, Cost, Award} | List1]
        end,
    put('enter_mission_player_list', NewList).

leave_mission(PlayerId) ->
    List = util:get_dict('enter_mission_player_list', []),
    case lists:keytake(PlayerId, 1, List) of
        false ->
            noop;
        {value, {_, Time, InMissionTime, Cost, Award}, List1} ->
            Now = util_time:timestamp(),
            put('enter_mission_player_list', [{PlayerId, Now, Now - Time + InMissionTime, Cost, Award} | List1])
    end.

add_mission_cost(PlayerId, AddCost) ->
    List = util:get_dict('enter_mission_player_list', []),
    case lists:keytake(PlayerId, 1, List) of
        false ->
            noop;
        {value, {_, Time, InMissionTime, Cost, Award}, List1} ->
            put('enter_mission_player_list', [{PlayerId, Time, InMissionTime, Cost + AddCost, Award} | List1])
    end.

add_mission_award(PlayerId, AddAward) ->
    List = util:get_dict('enter_mission_player_list', []),
    case lists:keytake(PlayerId, 1, List) of
        false ->
            noop;
        {value, {_, Time, InMissionTime, Cost, Award}, List1} ->
            put('enter_mission_player_list', [{PlayerId, Time, InMissionTime, Cost, Award + AddAward} | List1])
    end.

balance_mission(MissionType, MissionId, LogType) ->
    SceneId = mod_mission:get_scene_id_by_mission(MissionType, MissionId),
    Now = util_time:timestamp(),
    List = util:get_dict('enter_mission_player_list', []),
    Fun =
        fun() ->
            lists:foreach(
                fun({PlayerId, Time, InMissionTime, Cost, Award}) ->
                    if
                        PlayerId >= 10000 ->
                            CostList =
                                if
                                    Cost > 0 ->
                                        [{?ITEM_GOLD, Cost}];
                                    true ->
                                        []
                                end,

                            AwardList =
                                if
                                    Award > 0 ->
                                        [{?ITEM_GOLD, Award}];
                                    true ->
                                        []
                                end,
                            Node = mod_player:get_game_node(PlayerId),
                            mod_apply:apply_to_online_player(Node, PlayerId, ?MODULE, write_player_game_log, [PlayerId, SceneId, Time, Now - InMissionTime, CostList, AwardList, LogType], game_worker);
                        true ->
                            noop
                    end
                end,
                List
            )
        end,
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_GAME ->
            Fun();
        _ ->
            spawn(
                Fun
            )
    end,
    PlayerIdList = mod_scene_player_manager:get_all_obj_scene_player_id(),
    NewList = [{PlayerId, Now, 0, 0, 0} || PlayerId <- PlayerIdList],
    put('enter_mission_player_list', NewList).

%% ----------------------------------
%% @doc 	玩家游戏场景日志
%% @throws 	none
%% @end
%%%% ----------------------------------
write_player_game_log(PlayerId, SceneId, EnterTime, Now, CostList, AwardList, _LogType) ->
    db:dirty_write(
        #db_player_game_log{
            player_id = PlayerId,
            scene_id = SceneId,
            time = EnterTime,
            cost_time = Now - EnterTime,
            cost_list = encode(mod_prop:merge_prop_list(CostList)),
            award_list = encode(mod_prop:merge_prop_list(AwardList))
        }
    ),
%%    SceneLog = get_db_scene_log(SceneId),
%%    #db_scene_log{
%%        cost_list = OldCostListStr,
%%        award_list = OldAwardListStr,
%%        cost_time = OldCostTime,
%%        times = OldTimes
%%    } = SceneLog,
%%    OldCostList = util_string:string_to_list_term(OldCostListStr),
%%    OldAwardList = util_string:string_to_list_term(OldAwardListStr),
%%    NewCostList = mod_prop:merge_prop_list(OldCostList ++ CostList),
%%    NewAwardList = mod_prop:merge_prop_list(OldAwardList ++ AwardList),
%%    Tran =
%%        fun() ->
%%            db:write(SceneLog#db_scene_log{cost_list = encode(NewCostList), award_list = encode(NewAwardList), cost_time = OldCostTime + Now - EnterTime, times = OldTimes + 1})
%%        end,
%%    db:do(Tran),
    ok.
get_db_scene_log(SceneId) ->
    case db:read(#key_scene_log{scene_id = SceneId}) of
        null ->
            #db_scene_log{
                scene_id = SceneId
            };
        R ->
            R
    end.

%%%% ----------------------------------
%%%% @doc 	元宝日志
%%%% @throws 	none
%%%% @end
%%%%%% ----------------------------------
%%%%write_player_ingot_log(PlayerId, Change, Now, LogType) ->
%%%%    db:dirty_write(
%%%%        #db_player_ingot_log{
%%%%            player_id = PlayerId,
%%%%            op_type = LogType,
%%%%            op_time = util_time:timestamp(),
%%%%            change_value = Change,
%%%%            new_value = Now
%%%%        }
%%%%    ).

%% ----------------------------------
%% @doc 	铜钱日志
%% @throws 	none
%% @end
%% ----------------------------------
%%write_player_coin_log(PlayerId, Change, Now, LogType) ->
%%    logger2:write(PlayerId, player_coin_log,
%%        [
%%            {pid, PlayerId},  %% 玩家id
%%            {change, Change}, %% 改变值
%%            {now, Now},       %% 当前值
%%            {log, LogType}    %% 操作类型
%%        ]
%%    ).

%% ----------------------------------
%% @doc 	次数日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_times_log(PlayerId, TimesId, Change, LeftTimes) ->
    logger2:write(player_times_log,
        [
            {p, PlayerId},  %% 玩家id
            {times, TimesId}, %% 次数id
            {c, Change},       %% 改变值
            {l, LeftTimes}    %% 剩余次数
        ]
    ).

%% ----------------------------------
%% @doc 	杀怪日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_fight_monster_log(PlayerId) ->
    case util:get_dict(player_kill_monster_id_list, []) of
        [] ->
            noop;
        List ->
            put(player_kill_monster_id_list, []),
            logger2:write(player_fight_log2,
                [
                    {t, 1},
                    {p, PlayerId},  %% 玩家id
                    {t, lists:sum([ThisNum || {_, ThisNum} <- List])},           %% 总计
                    {m, List}
                ]
            ),
            [
                logger2:write(player_fight_log2,
                    [
                        {t, 3},
                        {player_id, PlayerId},       %% 玩家id
                        {monster_id, MonsterId},     %% 怪物id
                        {be_kill_times, ThisNum}     %% 被杀次数
                    ]
                ) || {MonsterId, ThisNum} <- List]
    end.

%% ----------------------------------
%% @doc 	怪物消耗日志
%% @throws 	none
%% @end
%% ----------------------------------
write_monster_cost_log(PlayerId) ->
    List = util:get_dict(monster_hurt_log_list, []),
    Now = util_time:timestamp(),
    NewList = lists:foldl(
        fun(Data, TmpL) ->
            {_ObjId, MonsterId, Cost, BeAtkTimes, Time} = Data,
            if
                Now > Time + 600 ->
                    logger2:write(player_fight_log2,
                        [
                            {t, 2},
                            {p, PlayerId},      %% 玩家id
                            {m, MonsterId},     %% 怪物id
                            {c, Cost},          %% 消耗
                            {a, 0},             %% 奖励
                            {be_atk_times, BeAtkTimes},     %% 被攻击次数
                            {time, util_time:format_datetime(Time)}
                        ]
                    ),
                    TmpL;
                true ->
                    [Data | TmpL]
            end
        end,
        [],
        List
    ),
    put(monster_hurt_log_list, NewList).

write_player_prop_log(PlayerId) ->
    PlayerPropNum = mod_prop:get_player_prop_num(PlayerId, ?ITEM_RMB),
    logger2:write(player_test_prop_log,
        [
            {p, PlayerId},              %% 玩家id
            {num, PlayerPropNum}        %% 砖石数量
        ]
    ).

write_player_prop_log_2(_PlayerId) ->
    noop.

%% @doc 写入全部怪物消耗列表
write_all_monster_cost_log(PlayerId) ->
    lists:foreach(
        fun(Data) ->
            {_ObjId, MonsterId, Cost, Time} = Data,
            logger2:write(player_fight_log2,
                [
                    {t, 2},
                    {p, PlayerId},      %% 玩家id
                    {m, MonsterId},     %% 怪物id
                    {c, Cost},          %% 消耗
                    {a, 0},             %% 奖励
                    {time, util_time:format_datetime(Time)}
                ]
            )
        end,
        util:get_dict(monster_hurt_log_list, [])
    ).

%% ----------------------------------
%% @doc 	玩家客户端打点日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_client_log(PlayerId, LogId) ->
    db:dirty_write(#db_player_client_log{
        player_id = PlayerId,
        log_id = LogId,
        time = util_time:timestamp()
    }).

%% ----------------------------------
%% @doc 	VIP日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_vip_log(PlayerId, NowLevel, NowExp, Change, LogType) ->
    logger2:write(player_vip_log,
        [
            {pid, PlayerId},    %% 玩家id
            {nowL, NowLevel},   %% 当前vip等级
            {nowE, NowExp},     %% 当前vip经验
            {c, Change},        %% 改变值
            {lg, LogType}      %% 操作类型
        ]
    ).


%% 物品日志
%%write_player_item_log(PlayerId, GridId, ItemId, ChangeValue, CurrValue, LogType) ->
%%    logger2:write(PlayerId, player_item_log,
%%        [
%%            {pid, PlayerId},          %% 玩家id
%%            {gridId, GridId},         %% 格子id
%%            {itemId, ItemId},         %% 物品id
%%            {change, ChangeValue},    %% 改变数量
%%            {value, CurrValue},       %% 当前数量
%%            {log, LogType}            %% 操作类型
%%        ]
%%    ).

%% ----------------------------------
%% @doc 	账户登录失败日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_login_fail_log(ServerId, AccId, _LoginType, _Ticket, Ip, Reason) ->
    logger2:write(login_fail_log,
        [
            {sid, ServerId},
            {accId, AccId},
%%            {loginType, LoginType},
%%            {ticket, Ticket},
            {reason, Reason},
            {ip, Ip}
        ]
    ).

%% ----------------------------------
%% @doc 	创建角色失败日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_create_role_fail_log(ServerId, AccId, NickName, _Sex, Ip, Reason) ->
    logger2:write(create_role_fail_log,
        [
            {sid, ServerId},
            {accId, AccId},
            {name, NickName},
%%            {sex, Sex},
            {reason, Reason},
            {ip, Ip}
        ]
    ).

%% ----------------------------------
%% @doc 	登录日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_login_log(PlayerId, Ip, Timestamp) ->
    db:dirty_write(#db_player_login_log{
        player_id = PlayerId,
        ip = Ip,
        timestamp = Timestamp
    }).
%%    logger2:write(PlayerId, player_login_log,
%%        [
%%            {pid, PlayerId},      %% 玩家id
%%            {ip, Ip}              %% 登录ip
%%        ]
%%    ).

%% ----------------------------------
%% @doc 	在线日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_online_log(PlayerId, LoginTime, OfflineTime, OnlineTime, _Reason) ->
    db:dirty_write(#db_player_online_log{
        player_id = PlayerId,
        login_time = LoginTime,
        offline_time = OfflineTime,
        online_time = OnlineTime
    }).
%%    logger2:write(PlayerId, player_online_log,
%%        [
%%            {pid, PlayerId},            %% 玩家id
%%            {loginTime, LoginTime},     %% 登录时间
%%            {onlineTime, OnlineTime},   %% 在线时间
%%            {reason, Reason}            %% 离线原因
%%        ]
%%    ).

%% ----------------------------------
%% @doc 	挑战副本日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_challenge_mission_log(PlayerId, MissionType, MissionId, Result, _ChallengeTime, _UsedTime, AwardList) ->
    logger2:write(player_challenge_mission_log,
        [
            {pid, PlayerId},              %% 玩家id
            {mT, MissionType},   %% 副本类型
            {mI, MissionId},        %% 副本id
            {r, Result},
%%            {t, ChallengeTime},
%%            {ut, UsedTime},
            {award, AwardList}
        ]
    ).
%%    db:dirty_write(#db_player_challenge_mission_log{
%%        player_id = PlayerId,
%%        mission_type = MissionType,
%%        mission_id = MissionId,
%%        result = Result,
%%        time = ChallengeTime,
%%        used_time = UsedTime
%%    }).

%% ----------------------------------
%% @doc 	道具日志
%% @throws 	none
%% @end
%% ----------------------------------
write_prop_change_log(PlayerId, PropId, LogType, ChangeValue, NewValue) ->
    if
        PropId == ?ITEM_RMB ->
            %% 钻石写mysql
            db:dirty_write(#db_player_prop_log{
                player_id = PlayerId,
                prop_id = PropId,
                op_type = LogType,
                op_time = util_time:timestamp(),
                change_value = ChangeValue,
                new_value = NewValue
            });
        true ->
            noop
    end,
    db:tran_apply(fun() ->
        %% 其余的写文件
        logger2:write(player_prop_log,
            [
                {p, PlayerId},
                {pI, PropId},
                {l, LogType},
                {c, ChangeValue},
                {n, NewValue}
            ]
        ) end),
    Type = ?IF(ChangeValue > 0, 0, 1),
    #t_item{
        type = ItemType
    } = t_item:assert_get({PropId}),
    if
        PropId == ?ITEM_GOLD orelse
            PropId == ?ITEM_RMB orelse
            ItemType == ?IT_BULLION_FRAGMENTS orelse
            ItemType == ?IT_BULLION ->
            SceneId = mod_obj_player:get_obj_player_scene_id(PlayerId),
            %% 统计消费情况
            NewR =
                case db:read(#key_consume_statistics{player_id = PlayerId, scene_id = SceneId, prop_id = PropId, type = Type, log_type = LogType}) of
                    null ->
                        #db_consume_statistics{
                            player_id = PlayerId,
                            scene_id = SceneId,
                            prop_id = PropId,
                            type = Type,
                            log_type = LogType,
                            value = ChangeValue
                        };
                    R ->
                        R#db_consume_statistics{
                            value = ChangeValue + R#db_consume_statistics.value
                        }
                end,
            Tran = fun() ->
                db:write(NewR)
                   end,
            db:do(Tran);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	特殊道具日志
%% @throws 	none
%% @end
%% ----------------------------------
write_special_prop_change_log(_PlayerId, _PropType, _PropId, _PropLevel, _LogType, _ChangeValue, _NewValue) ->
%%    if PropType == ?PROP_TYPE_JADE ->
%%        logger2:write(player_special_prop_log,
%%            [
%%                {p, PlayerId},
%%                {pT, PropType},
%%                {pI, PropId},
%%                {pL, PropLevel},
%%                {l, LogType},
%%                {c, ChangeValue},
%%                {n, NewValue}
%%            ]
%%        );
%%        true ->
    %% 其余的写文件
    noop
%%    end
.


%% ----------------------------------
%% @doc 	追踪发送协议日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_send_proto_log(PlayerId, Data) ->
    case ?IS_TRACE_PROTO of
        true ->

            LogName = "proto" ++ "_" ++ util:to_list(PlayerId),
            {_MegaSecs, _Secs, MicroSecs} = os:timestamp(),
%%            {Msg, []} = websocket_util:parse_frames(Data),
%%            io:format("write_player_send_proto_log:~p~n", [Data]),
%%			<<_:16, Msg/binary>> = Data,
            RealMsg =
                case Data of
                    <<_:9, 126:7, _:16, Msg/binary>> ->
                        Msg;
                    <<_:9, 127:7, _:64, Msg/binary>> ->
                        Msg;
                    <<_:16, Msg/binary>> ->
                        Msg
                end,
%%			{<<>>, [Msg]} = util_websocket:parse_frames(Data),
%%            io:format("write_player_send_proto_log:~p~n", [{erlang:byte_size(Msg), proto:decode(Msg)}]),
%%            ?DEBUG("~p~n", [{Data}]),
            logger2:write(PlayerId, LogName, [MicroSecs div 1000, proto:decode(RealMsg)]);
        _ ->
            noop
    end.

%% ----------------------------------
%% @doc 	追踪接收协议日志
%% @throws 	none
%% @end
%% ----------------------------------
write_player_receive_proto_log(PlayerId, Msg) ->
    case ?IS_TRACE_PROTO of
        true ->
%%            io:format("write_player_receive_proto_log:~p~n", [{PlayerId, Msg}]),
            LogName = "proto" ++ "_" ++ util:to_list(PlayerId),
            {_MegaSecs, _Secs, MicroSecs} = os:timestamp(),
            logger2:write(PlayerId, LogName, [MicroSecs div 1000, Msg]);
        _ ->
            noop
    end.

%% ----------------------------------
%% @doc 	任务日志
%% @throws 	none
%% @end
%% ----------------------------------
write_task_log(PlayerId, TaskId) ->
    logger2:write(PlayerId, player_task_log,
        [
            {pid, PlayerId},  %% 玩家id
            {taskId, TaskId}  %% 任务id
        ]
    ).

%% @doc     邮件日志
db_write_player_mail_log(PlayerId, MailChargeType, LogType, ItemList, MailIdTuple) when is_tuple(MailIdTuple) ->
    db:tran_merge_apply({?MODULE, write_player_mail_log, {PlayerId, MailChargeType, LogType, ItemList}}, MailIdTuple).
write_player_mail_log({PlayerId, MailChargeType, LogType, ItemList}, MailIdList) ->
    logger2:write(player_mail_log,
        [
            {pid, PlayerId},            %% 玩家id
            {cT, MailChargeType},       %% 操作类型
            {log, LogType},             %% 日志类型
            {mailL, MailIdList},        %% 邮件id列表[{MailRealId, MailId}]
            {itemL, ItemList}            %% 奖励列表
        ]
    ).
%% @doc     邮件错误日志
write_player_mail_error_log(PlayerIdList, MailChargeType, MailIdList, ItemList) ->
    logger2:write(mail_error_log,
        [
            {pidL, PlayerIdList},        %% 玩家列表
            {cType, MailChargeType},    %% 操作类型
            {mailL, MailIdList},        %% 邮件id列表[{MailRealId, MailId}]
            {itemL, ItemList}            %% 奖励列表
        ]
    ).

%% @fun 玩家属性日志
write_attr_log(PlayerId, FunctionId, Power, ChangePower, Attack, Defense) ->
    db:tran_apply(fun() -> write_attr_log({PlayerId, FunctionId, Power, ChangePower, Attack, Defense}) end).
write_attr_log({PlayerId, FunctionId, Power, ChangePower, Attack, Defense}) ->
    logger2:write(player_attr_log,
        [
            {pid, PlayerId},    %% 玩家id
            {fid, FunctionId},  %% 功能id
            {p, Power},        %% 总战力
            {add, ChangePower}, %% 差量战力
            {at, Attack},       %% 攻击
            {de, Defense}       %% 防御
        ]
    ).

%% @doc 活动时间日志
write_activity_log(Action, ActivityId, ActionTime, State, {LastOpenTime, LastCloseTime}, {ConfigOpenTime, ConfigCloseTime}) ->
    logger2:write(activity,
        [
            ActivityId,
            {action, Action},
            {now, util_time:timestamp_to_datetime(ActionTime)},
            {state, State},
            {openTime, util_time:timestamp_to_datetime(ConfigOpenTime)},
            {closeTime, util_time:timestamp_to_datetime(ConfigCloseTime)},
            {lastOpenTime, util_time:timestamp_to_datetime(LastOpenTime)},
            {lastCloseTime, util_time:timestamp_to_datetime(LastCloseTime)}
        ]
    ).

%% @fun 活动时间日志
write_activity_time_log(Type, Data) ->
    logger2:write(activity_time_log,
        [
            {type, Type},           %% 类型
            {data, Data}            %% 数据内容
        ]
    ).
%% @fun 玩家活动时间日志
write_player_activity_time_log(PlayerId, Type, NoticeList, OpenList, CloseList, List) ->
    logger2:write(player_activity_time_log,
        [
            {p, PlayerId},           %% 玩家id
            {type, Type},           %% 类型
            {nL, NoticeList},       %% 通知活动
            {sL, OpenList},         %% 开始活动
            {cL, CloseList},        %% 关闭活动
            {oL, List}              %% 内容列表
        ]
    ).
%% @fun 活动奖励日志
write_activity_award_log(ActivityId, LogType, Data) ->
    logger2:write(activity_award_log,
        [
            {aId, ActivityId},      %% 类型
            {logT, LogType},        %% 日志
            {data, Data}            %% 数据内容
        ]
    ).
%% @fun 充值日志
write_charge_log(PlayerId, ChargeType, Money, ChargeIngot, OrderId, CurrTime) ->
    logger2:write(charge_log,
        [
            {pId, PlayerId},            %% 玩家id
            {type, ChargeType},         %% 充值类型
            {m, Money},                 %% 人民币
            {i, ChargeIngot},           %% 元宝
            {orderId, OrderId},         %% 类型
            {time, CurrTime}            %% 时间
        ]
    ).

write_monster_delete_log(?OBJ_TYPE_MONSTER, ObjId, true) ->
    #obj_scene_actor{
        base_id = MonsterId,
        grid_id = GridId,
        x = X,
        y = Y
    } = ?GET_OBJ_SCENE_MONSTER(ObjId),
    logger2:write(monster_delete_log,
        [
            {obj_id, ObjId},
            {monster_id, MonsterId},
            {scene_id, get(?DICT_SCENE_ID)},
            {grid_id, GridId},
            {pos, {X, Y}}
        ]
    );
write_monster_delete_log(_ObjType, _ObjId, _IsWrite) ->
    noop.

%%%===================================================================
%%%                            系统日志
%%%===================================================================

%% ----------------------------------
%% @doc 	系统监控日志
%% @throws 	none
%% @end
%% ----------------------------------
write_system_monitor_log() ->
    Memory = erlang:memory(),
    Total = trunc(util_list:opt(total, Memory) / 1024 / 1024),
    Processes = trunc(util_list:opt(processes, Memory) / 1024 / 1024),
    Code = trunc(util_list:opt(code, Memory) / 1024 / 1024),
    Ets = trunc(util_list:opt(ets, Memory) / 1024 / 1024),
    Binary = trunc(util_list:opt(binary, Memory) / 1024 / 1024 * 100) / 100,
    AtomUsed = trunc(util_list:opt(atom_used, Memory) / 1024 / 1024 * 100) / 100,
    logger2:write(system_monitor,
        [
            {total, Total},
            {processes, Processes},
            {code, Code},
            {ets, Ets},
            {binary, Binary},
            {atomUsed, AtomUsed},
            {process_count, erlang:system_info(process_count)},
            {atom_count, erlang:system_info(atom_count)},
            {port_count, erlang:system_info(port_count)},
            {ets_count, erlang:length(ets:all())},
            {online_count, mod_online:get_online_count()}
        ]
    ).

%% ----------------------------------
%% @doc 	在线分析
%% @throws 	none
%% @end
%% ----------------------------------
write_online_statistics_log() ->
    OnlineCount = mod_online:get_online_count(),
%%    CommonOnlineCount = mod_online:get_common_online_player_count(),
%%    RobotOnlineCount = robot_srv:get_robot_account(),
%%    AllObjPlayer = ets:tab2list(?OBJ_PLAYER),
%%    SceneDistribute =
%%        lists:foldl(
%%            fun(ObjPlayer, L) ->
%%                #obj_player{
%%                    scene_id = SceneId
%%                } = ObjPlayer,
%%                case util:opt(SceneId, L) of
%%                    undefined ->
%%                        [{SceneId, 1} | L];
%%                    N ->
%%                        [{SceneId, N + 1} | lists:keydelete(SceneId, 1, L)]
%%                end
%%            end,
%%            [],
%%            AllObjPlayer
%%        ),
%%    L = scene_master:get_all_scene_worker_map(),
%%    SceneWorkerMap =
%%        lists:foldl(
%%            fun(E, Tmp) ->
%%
%%                [{
%%                    E#ets_scene_worker_map.scene_id,
%%                    length(E#ets_scene_worker_map.scene_worker_info_list),
%%                    util:key_sum(#scene_worker_info.count, E#ets_scene_worker_map.scene_worker_info_list)
%%                }
%%                    | Tmp]
%%            end,
%%            [],
%%            lists:sort(L)
%%        ),
    SceneMap =
        lists:foldl(
            fun(ObjPlayer, Tmp) ->
                #ets_obj_player{
                    scene_id = SceneId
                } = ObjPlayer,
                case lists:keytake(SceneId, 1, Tmp) of
                    {value, {SceneId, Num}, Left} ->
                        [{SceneId, Num + 1} | Left];
                    false ->
                        [{SceneId, 1} | Tmp]
                end
            end,
            [],
            mod_obj_player:get_all_obj_player()
        ),
    logger2:write(online_statistics,
        [
            {online_count, OnlineCount},
%%            {common_count, CommonOnlineCount},
%%            {robot_count, RobotOnlineCount},
%%            {scene_worker_map, lists:sort(SceneWorkerMap)},
            {scene_map, SceneMap}
        ]).

%% @doc 	进程监控日志
%% @throws 	none
%% @end
%% ----------------------------------
write_process_monitor_log() ->
    Processes = erlang:processes(),
    ProcessMonitorRed = tool:processes_info([{sort, red}, {num, 10}], Processes),
    if ProcessMonitorRed =/= [] ->
        logger2:write(process_monitor_red, ProcessMonitorRed);
        true ->
            noop
    end,
    ProcessMonitorMem = tool:processes_info([{sort, mem}, {num, 10}], Processes),
    if ProcessMonitorMem =/= [] ->
        logger2:write(process_monitor_mem, ProcessMonitorMem);
        true ->
            noop
    end,
    ProcessMonitorMesLen = tool:processes_info([{sort, mes_len}, {num, 10}], Processes),
    if ProcessMonitorMesLen =/= [] ->
        logger2:write(process_monitor_mes_len, ProcessMonitorMesLen);
        true ->
            noop
    end.

%% @doc  礼物日志
write_player_gift_mail_log(PlayerId, Sender, MailChargeType, ItemList, MailIdTuple) when is_tuple(MailIdTuple) ->
    logger2:write(player_gift_mail_log,
        [
            {pid, PlayerId},            %% 玩家id
            {sender, Sender},           %% 发送者
            {cT, MailChargeType},       %% 操作类型
            {mail, MailIdTuple},        %% 邮件id列表[{MailRealId, MailId}]
            {itemL, ItemList}           %% 奖励列表
        ]
    ).

%%%% ----------------------------------
%%%% @doc 	服务器追踪数据每日日志
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
%%write_server_trace_daily_log(Node, Y, M, D, OneLevelCount, ValidCount, ConnectTimes, EnterCreateRole, LoginNum, TotalOnlineTIme) ->
%%    ?INFO("每日统计数据:~p", [util_time:timestamp()]),
%%    ?TRY_CATCH(db:dirty_write(
%%        #db_c_server_trace_daily_log{
%%            node = Node,
%%            year = Y,
%%            month = M,
%%            day = D,
%%            one_level_player = OneLevelCount,
%%            valid_player = ValidCount,
%%            connect_times = ConnectTimes,
%%            enter_create_role = EnterCreateRole,
%%            login_num = LoginNum,
%%            total_online_time = TotalOnlineTIme
%%        }
%%    )).
