%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            聊天模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_chat).

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("chat.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("msg.hrl").
-export([
    channel_chat/3,    %%聊天

    clear_ets_player_chat_msg/1     %% 删除玩家聊天信息
]).

-export([
    send_recent_chat_cache/1,
    add_chat_cache/2,
    broadcast_cross_chat/1,
    broadcast_cross_chat/2,
    get_chat_name/1,                                % 获得频道名字
    get_chat_name_binary/1,                         % 获得频道名字 二进制

    active_notice/2,                                %% 活动通知
    recharge_notice/3,                              %% 充值通知

    player_acquire_item_notice/3,                   %% 玩家获得道具通知
%%    player_acquire_resources_notice/3,              %% 玩家获得资源通知
    player_kill_player_notice/3,                    %% 玩家斩杀玩家通知
    player_kill_num_notice/3,                       %% 玩家杀死数量通知
    notice_a_on_b_operation/3,                      %% 玩家A对玩家B操作的通知

    player_acquire_item_in_function_notice/4,       %% 玩家在功能中获得物品通知
    player_acquire_item_in_activity_notice/4,       %% 玩家在活动中获得物品通知
%%    player_acquire_equip_in_scene_notice/4,         %% 玩家在场景中获得物品通知
    player_kill_boss_in_scene_notice/4,             %% 玩家在地图中斩杀Boss通知
    player_use_item_and_acquire_item_notice/4,      %% 玩家使用物品并且获得物品通知
    player_kill_num_in_scene_notice/4,              %% 玩家在地图中杀死玩家数量通知
    notice_a_and_b/4,                               %% 玩家A和玩家B外加数量的通知

    send_system_template_message/2
%%    do_send_marry_msg/2,
%%    do_send_marry_msg_2/2
]).

-define(CHAT_MSG_NUM, 5).       %% 聊天信息缓存数量限制
-define(CHAT_VIP_LEVEL, 4).     %% 聊天vip等级限制

%%init() ->
%%    Node = node(),
%%    Result = mod_server_rpc:call_zone(zone_srv, join, [Node], 6000),
%%    if Result == ok ->
%%        ?INFO("加入跨服服务器成功:~p", [mod_server_config:get_zone_node()]);
%%        true ->
%%            ?ERROR("加入跨服服务器失败:~p", [mod_server_config:get_zone_node()])
%%    end,
%%    ok.

%% ----------------------------------
%% @doc 	频道聊天
%% @throws 	none
%% @end
%% ----------------------------------
channel_chat(PlayerId, Channel, Msg_0) when is_integer(PlayerId) ->
    PlayerLevel = mod_player:get_player_data(PlayerId, level),
    %% 设置成不能聊天的状态
    ?ASSERT(lists:member(Channel, [])),
    ?ASSERT(PlayerLevel >= ?SD_CHAT_NEED_LEVEL, ?ERROR_NEED_LEVEL),
    ?ASSERT(util_string:string_length(Msg_0) =< ?SD_CHAT_MAX_LEN, ?ERROR_MSG_TOO_LONG),
    mod_interface_cd:assert(chat, ?SD_CHAT_CD * 1000),

    Msg = util_string:replace(Msg_0, " ", ""),
    RightMsg = mod_server_rpc:call_war(util_string, filter, [Msg]),
    Ets = get_ets_player_chat_msg(PlayerId),
    MsgList = Ets#ets_player_chat_msg.msg,
    Data = api_chat:pack_broadcast_channel_msg(PlayerId, Channel, RightMsg),

    case lists:member(Msg, MsgList) of
        true ->
            mod_socket:send(PlayerId, Data);
        false ->
            PlatformId = mod_server_config:get_platform_id(),
            #db_player{
                acc_id = AccId
            } = mod_player:get_player(PlayerId),
            VipLevel = mod_vip:get_vip_level(PlayerId),
            CurrTime = util_time:timestamp(),
            if
                1585929600 =< CurrTime andalso CurrTime =< 1586016000 ->
                    noop;
%%                (PlatformId == ?PLATFORM_AF andalso (VipLevel < ?CHAT_VIP_LEVEL andalso PlayerLevel < 200)) orelse
%%                    (
%%                PlatformId =/= ?PLATFORM_GAT andalso
%%                            PlatformId =/= ?PLATFORM_AF andalso PlatformId =/= ?PLATFORM_WX andalso
                (VipLevel < 3 andalso PlayerLevel < 200) ->
                    %% 爱疯平台 : vip等级 >= 4 或者等级 >= 200级才能聊天
                    mod_socket:send(PlayerId, Data);
                true ->
                    %% 聊天封禁状态
                    IsCanChat = mod_player:is_can_chat(PlayerId) andalso mod_global_account:is_can_chat(PlatformId, AccId),
%%                        if PlatformId == ?PLATFORM_AF ->
%%                            mod_global_account:is_can_chat(PlatformId, AccId);
%%                            true ->
%%                                mod_player:is_forbid_chat(PlayerId) == false
%%                        end,
                    case IsCanChat of
                        true ->
%%                            if
%%                            %% 仙盟聊天
%%                                Channel == ?CHANNEL_FACTION ->
%%                                    FactionId = mod_faction:get_faction_id(PlayerId),
%%                                    ?ASSERT(FactionId > 0, ?ERROR_NO_FACTION),
%%                                    FactionPlayerIdList = mod_faction:get_faction_member_player_id_list(FactionId),
%%                                    mod_socket:send_to_player_list(FactionPlayerIdList, Data),
%%                                    add_chat_cache({?MODULE, ?CHANNEL_FACTION, FactionId}, Data);
%%                            %% 世界聊天
%%                                Channel == ?CHANNEL_WORLD ->
%%                                    mod_socket:send_to_all_online_player(Data),
%%                                    Node = node(),
%%                                    ?TRY_CATCH(chat_srv:send_msg({chat, Node, Data, ?CHANNEL_WORLD})),
%%%%                                    ?TRY_CATCH(mod_server_rpc:send_zone(chat_srv, {chat, Node, Data, ?CHANNEL_WORLD})),
%%                                    add_chat_cache({?MODULE, ?CHANNEL_WORLD}, Data);
%%                            %% 结婚
%%                                Channel == ?CHANNEL_MARRY ->
%%                                    MarryId = mod_marry:get_player_marry_id(PlayerId),
%%                                    ?ASSERT(MarryId > 0),
%%                                    send_marry_msg(MarryId, Data);
                            %% 仙界
%%                                Channel == ?CHANNEL_XIANJIE ->
%%                                    #ets_obj_player{
%%                                        scene_id = SceneId
%%%%                                        scene_worker = SceneWorker
%%                                    } = mod_obj_player:get_obj_player(PlayerId),
%%%%                                    ?ASSERT(SceneId == ?SD_SCENE_XIANJIE),
%%%%                                    ?ASSERT(mod_scene:get_scene_server_type(SceneId) == ?SERVER_TYPE_WAR_AREA),
%%                                    ?ASSERT(lists:member(SceneId, ?SD_SHOW_XIANJIE_CHAT_LIST), {scene_limit, SceneId}),
%%                                    chat_srv:send_war_msg(Data)
%%%%                                    mod_server_rpc:cast_war(scene_master, send_msg, {SceneId, {?MSG_SCENE_BROADCAST_CHAT_MSG, Data}})
%%%%                                    SceneWorker ! {?MSG_SCENE_BROADCAST_CHAT_MSG, Data}
%%                            end,
%%                            if PlatformId == ?PLATFORM_AF ->
%%                                ChatType =
%%                                    if Channel == ?CHANNEL_FACTION ->
%%                                        5;
%%                                        true ->
%%                                            3
%%                                    end,
%%                                %% 爱微游聊天上报
%%                                ?TRY_CATCH(awy:report_chat(PlayerId, ChatType, Msg));
%%                                true ->
                            noop;
%%                            end;
                        false ->
                            %% 禁言
                            mod_socket:send(PlayerId, Data)
                    end
            end
    end,
    ChatMsgSum = erlang:length(MsgList),
    if
        ChatMsgSum < ?CHAT_MSG_NUM ->
            insert_ets_player_chat_msg(Ets#ets_player_chat_msg{msg = [Msg | MsgList]});
        true ->
            NewMsgList = lists:droplast(MsgList),
            insert_ets_player_chat_msg(Ets#ets_player_chat_msg{msg = [Msg | NewMsgList]})
    end.

%% ----------------------------------
%% @doc 	广播跨服聊天消息
%% @throws 	none
%% @end
%% ----------------------------------
broadcast_cross_chat(Data) ->
    mod_socket:send_to_all_online_player(Data),
    add_chat_cache({?MODULE, ?CHANNEL_WORLD}, Data).

%% ----------------------------------
%% @doc 	广播跨服聊天消息
%% @throws 	none
%% @end
%% ----------------------------------
broadcast_cross_chat(Channel, Data) ->
    mod_socket:send_to_all_online_player(Data),
    add_chat_cache({?MODULE, Channel}, Data).

%% ----------------------------------
%% @doc 	添加聊天缓存
%% @throws 	none
%% @end
%% ----------------------------------
add_chat_cache(Channel, Data) ->
    QueueCache = mod_cache:get(Channel, []),
    MaxLen =
        if Channel == {?MODULE, ?CHANNEL_SYSTEM} ->
            2;
            true ->
                5
        end,
    mod_cache:update(Channel, lists:sublist([Data | QueueCache], MaxLen)).

%%    if
%%        Len < MaxLen ->
%%            lists:sublist([Data | QueueCache], 2),
%%            mod_cache:update(Channel, lists:sublist([Data | QueueCache], 2));
%%        true ->
%%            NewQueueCache = [Data | lists:droplast(QueueCache)],
%%            mod_cache:update(Channel, NewQueueCache)
%%    end.

%% ----------------------------------
%% @doc 	发送最近的聊天缓存
%% @throws 	none
%% @end
%% ----------------------------------
send_recent_chat_cache(PlayerId) ->
    %% 系统频道
    lists:foreach(
        fun(Data) ->
            mod_socket:send(PlayerId, Data)
        end,
        lists:reverse(mod_cache:get({?MODULE, ?CHANNEL_SYSTEM}, []))
    ).

%%    %% 世界频道
%%    lists:foreach(
%%        fun(Data) ->
%%            mod_socket:send(PlayerId, Data)
%%        end,
%%        lists:reverse(mod_cache:get({?MODULE, ?CHANNEL_WORLD}, []))
%%    ),

%%    %% 仙盟频道
%%    FactionId = mod_faction:get_faction_id(PlayerId),
%%    if FactionId > 0 ->
%%        lists:foreach(
%%            fun(Data) ->
%%                mod_socket:send(PlayerId, Data)
%%            end,
%%            lists:reverse(mod_cache:get({?MODULE, ?CHANNEL_FACTION, FactionId}, []))
%%        );
%%        true ->
%%            noop
%%    end,
%% 结婚频道
%%    lists:foreach(
%%        fun(Data) ->
%%            mod_socket:send(PlayerId, Data)
%%        end,
%%        lists:reverse(mod_cache:get({?MODULE, ?CHANNEL_MARRY, PlayerId}, []))
%%    ).


%%send_marry_msg(MarryId, Data) ->
%%    mod_server_rpc:cast_war(mod_chat, do_send_marry_msg, [MarryId, Data]).
%%
%%do_send_marry_msg(MarryId, Data) ->
%%    PlatformId = mod_server_config:get_platform_id(),
%%    lists:foreach(
%%        fun({NoticePlayerId, ServerId}) ->
%%            mod_server_rpc:cast_game_server(PlatformId, ServerId, mod_chat, do_send_marry_msg_2, [NoticePlayerId, Data])
%%        end,
%%        marry_srv_mod:get_marry_data_player_list(MarryId)
%%    ).
%%
%%do_send_marry_msg_2(PlayerId, Data) ->
%%    mod_socket:send(PlayerId, Data),
%%    add_chat_cache({?MODULE, ?CHANNEL_MARRY, PlayerId}, Data).

%% @doc fun 获得频道名字
get_chat_name(ChatId) ->
    "".
%%    #t_chat{
%%        desc = Desc
%%    } = try_t_chat(ChatId),
%%    Desc.
%% @doc fun 获得频道名字 二进制
get_chat_name_binary(ChatId) ->
    util:to_binary(get_chat_name(ChatId)).

%% ------------------------------------------------------- 系统公告

%% ----------------------------------------- 一个参数公告
%% 活动通知
active_notice(NoticeId, ActivityId) ->
    NoticeList = [mod_activity:get_activity_name(ActivityId)],
    send_system_template_message(NoticeId, NoticeList).

%% 充值通知
recharge_notice(NoticeId, PlayerId, Money) ->
    NoticeList = [mod_player:get_player_name(PlayerId), util:to_int(Money)],
    send_system_template_message(NoticeId, NoticeList).

%% ----------------------------------------- 两个参数公告
%% 玩家获得道具通知
player_acquire_item_notice(NoticeId, PlayerId, ItemId) ->
    PlayerNameList = mod_player:get_player_name(PlayerId),
    ItemList = mod_item:get_item_name(ItemId),
    NoticeList = [PlayerNameList, ItemList],
    send_system_template_message(NoticeId, NoticeList).

%% 玩家斩杀玩家通知
player_kill_player_notice(NoticeId, PlayerId, KillPlayerId) ->
    PlayerNameList = mod_player:get_player_name(PlayerId),
    KillPlayerNameList = mod_player:get_player_name(KillPlayerId),
    NoticeList = [PlayerNameList, KillPlayerNameList],
    send_system_template_message(NoticeId, NoticeList).

%% 玩家杀死数量通知
player_kill_num_notice(NoticeId, PlayerId, Num) ->
    PlayerNameList = mod_player:get_player_name(PlayerId),
    NoticeList = [PlayerNameList, Num],
    send_system_template_message(NoticeId, NoticeList).

%% 玩家A对玩家B操作的通知
notice_a_on_b_operation(NoticeId, PlayerAStr, PlayerBStr) ->
    NoticeList = [PlayerAStr, PlayerBStr],
    send_system_template_message(NoticeId, NoticeList).

%% ----------------------------------------- 三个参数公告
%% 玩家在功能中获得物品通知
player_acquire_item_in_function_notice(NoticeId, PlayerId, FunctionId, ItemId) ->
    PlayerNameList = mod_player:get_player_name(PlayerId),
    FunctionList = mod_function:get_function_name(FunctionId),
    ItemList = mod_item:get_item_name(ItemId),
    NoticeList = [PlayerNameList, FunctionList, ItemList],
    send_system_template_message(NoticeId, NoticeList).

%% 玩家在活动中获得物品通知
player_acquire_item_in_activity_notice(NoticeId, PlayerId, ActivityId, ItemId) ->
    PlayerNameList = mod_player:get_player_name(PlayerId),
    FunctionList = mod_activity:get_activity_name(ActivityId),
    ItemList = mod_item:get_item_name(ItemId),
    NoticeList = [PlayerNameList, FunctionList, ItemList],
    send_system_template_message(NoticeId, NoticeList).

%% 玩家在场景中获得物品通知
%%player_acquire_equip_in_scene_notice(NoticeId, PlayerId, SceneId, EquipId) ->
%%    ?DEBUG("玩家在场景中获得物品通知:~p", [{NoticeId, PlayerId, SceneId, EquipId}]),
%%    PlayerNameList = mod_player:get_player_name(PlayerId),
%%    SceneList = mod_scene:get_scene_name(SceneId),
%%    #t_equip{
%%        name = EquipName
%%    } = t_equip:get({EquipId}),
%%    NoticeList = [PlayerNameList, SceneList, EquipName],
%%
%%    send_system_template_message(NoticeId, NoticeList).

%% 玩家在地图中斩杀Boss通知
player_kill_boss_in_scene_notice(NoticeId, PlayerId, SceneId, BossId) ->
    PlayerNameList = mod_player:get_player_name(PlayerId),
    SceneList = mod_scene:get_scene_name(SceneId),
    BossList = mod_scene_monster_manager:get_monster_name(BossId),
    NoticeList = [PlayerNameList, SceneList, BossList],
    send_system_template_message(NoticeId, NoticeList).

%% 玩家使用物品并且获得物品通知
player_use_item_and_acquire_item_notice(NoticeId, PlayerId, ItemId1, ItemId2) ->
    PlayerNameList = mod_player:get_player_name(PlayerId),
    Item1List = mod_item:get_item_name(ItemId1),
    Item2List = mod_item:get_item_name(ItemId2),
    NoticeList = [PlayerNameList, Item1List, Item2List],
    send_system_template_message(NoticeId, NoticeList).

%% 玩家在地图中杀死玩家数量通知
player_kill_num_in_scene_notice(NoticeId, PlayerId, SceneId, Num) ->
    PlayerNameList = mod_player:get_player_name(PlayerId),
    SceneList = mod_scene:get_scene_name(SceneId),
    NoticeList = [PlayerNameList, SceneList, Num],
    send_system_template_message(NoticeId, NoticeList).

%% 玩家A和玩家B外加内容的通知
notice_a_and_b(NoticeId, PlayerAStr, PlayerBStr, Msg) ->
    NoticeList = [PlayerAStr, PlayerBStr, Msg],
    send_system_template_message(NoticeId, NoticeList).

%% ----------------------------------------- 系统公告
%% 系统公告
send_system_template_message(NoticeId, List) ->
    #t_notice{
        notice_type = NoticeType
    } = try_t_notice(NoticeId),
    NewList = [util:to_binary(NoticeContent) || NoticeContent <- List],
    api_chat:notice_system_template_message(NoticeId, NewList, NoticeType).

%% ================================================ ets 数据操作 ================================================
%% 获得玩家聊天信息数据
get_ets_player_chat_msg(PlayerId) ->
    case ets:lookup(?ETS_PLAYER_CHAT_MSG, PlayerId) of
        [ETS] ->
            ETS;
        _ ->
            #ets_player_chat_msg{player_id = PlayerId}
    end.

%% 插入玩家聊天信息
insert_ets_player_chat_msg(Ets) ->
    ets:insert(ets_player_chat_msg, Ets).

%% 删除玩家聊天信息
clear_ets_player_chat_msg(PlayerId) ->
    Ets = get_ets_player_chat_msg(PlayerId),
    insert_ets_player_chat_msg(Ets#ets_player_chat_msg{msg = []}).

%% ================================================ 模板操作 ================================================
%% 获得通知模板数据
try_t_notice(NoticeId) ->
    T_Notice = t_notice:get({NoticeId}),
    ?IF(is_record(T_Notice, t_notice), T_Notice, exit({null_t_notice, {NoticeId}})).

%% @doc fun 获得聊天频道模板
try_t_chat(ChatId) ->
    t_chat:assert_get({ChatId}).