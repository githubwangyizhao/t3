%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2021
%%% @doc       聊天模块
%%% @end
%%% Created : 22. 十一月 2021 下午 3:23
%%%-------------------------------------------------------------------
-module(mod_player_chat).

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("error.hrl").
-include("player_game_data.hrl").
-include("global_data.hrl").

-export([
    init/1,

    channel_chat/4    %%聊天
]).

-export([
    broadcast_cross_chat/1,

    send_system_template_message/2,
    send_system_template_message/3
]).

-export([
    get_player_chat_info/1,
    get_chat_info_by_sid_and_nickname_war/2,
    get_chat_info_by_sid_and_nickname_game/2,

    get_player_list_online_status/1,
    get_player_list_online_status_war/1,

    get_t_chat/1
]).

%% @doc 初始化发送私聊缓存
init(PlayerId) ->
    DbPlayerChatList = db_index:get_rows(#idx_player_chat_data_by_player{player_id = PlayerId}),
    Tran =
        fun() ->
            lists:foldl(
                fun(DbPlayerChat, TmpL) ->
                    #db_player_chat_data{
                        send_player_id = SendPlayerId,
                        chat_msg = ChatMsg,
                        nickname = Nickname,
                        sex = Sex,
                        level = Level,
                        vip_level = VipLevel,
                        head_id = HeadId,
                        head_frame_id = HeadFrameId,
                        send_time = SendTime
                    } = DbPlayerChat,
                    db:delete(DbPlayerChat),
                    Data = {api_player:pack_model_head_figure(SendPlayerId, Nickname, Sex, HeadId, VipLevel, Level, HeadFrameId), ChatMsg, SendTime},
                    util_list:key_insert({SendPlayerId, Data}, TmpL)
                end,
                [], DbPlayerChatList
            )
        end,
    List = db:do(Tran),
    NewList = [{?CHAT_CHANNEL_PRIVATE, ThisPlayerId, DataList} || {ThisPlayerId, DataList} <- List],
    api_player_chat:notice_msg_list(PlayerId, NewList).
%%    #db_player{
%%        last_offline_time = LastOfflineTime
%%    } = mod_player:get_player(PlayerId),
%%    lists:foreach(
%%        fun({Data, Time}) ->
%%            if
%%                Time > LastOfflineTime ->
%%                    mod_socket:send(PlayerId, Data);
%%                true ->
%%                    noop
%%            end
%%        end,
%%        mod_cache:get({?MODULE, ?CHAT_CHANNEL_WORLD}, [])
%%    ),
%%    lists:foreach(
%%        fun({Data, Time}) ->
%%            if
%%                Time > LastOfflineTime ->
%%                    mod_socket:send(PlayerId, Data);
%%                true ->
%%                    noop
%%            end
%%        end,
%%        mod_cache:get({?MODULE, ?CHAT_CHANNEL_SYSTEM}, [])
%%    ).

%% ----------------------------------
%% @doc 	频道聊天
%% @throws 	none
%% @end
%% ----------------------------------
channel_chat(PlayerId, Channel, Id, Msg_0) when is_integer(PlayerId) ->
    #t_chat{
        is_send = IsSend,
        send_cd_time = SendCdTime,
        send_limit = SendLimit,
        broadcast_need_level = BroadcastNeedLevel,
        broadcast_need_vip_level = BroadcastNeedVipLevel
    } = get_t_chat(Channel),
    ?ASSERT(IsSend == ?TRUE),
    ?ASSERT(util_string:string_length(Msg_0) =< SendLimit, ?ERROR_MSG_TOO_LONG),
    PlayerLevel = mod_player:get_player_data(PlayerId, level),
    ?ASSERT(PlayerLevel >= BroadcastNeedLevel, ?ERROR_NEED_LEVEL),
    PlayerVipLevel = mod_player:get_player_data(PlayerId, vip_level),
    ?ASSERT(PlayerVipLevel >= BroadcastNeedVipLevel, ?ERROR_NOT_ENOUGH_VIP_LEVEL),
    PlatformId = mod_server_config:get_platform_id(),
    #db_player{
        acc_id = AccId,
        sex = Sex,
        server_id = ServerId,
        nickname = Nickname
    } = mod_player:get_player(PlayerId),
    ?ASSERT(mod_player:is_can_chat(PlayerId) andalso mod_global_account:is_can_chat(PlatformId, AccId), ?ERROR_NOT_AUTHORITY),

%%    Msg = util_string:replace(Msg_0, " ", ""),
    Msg = Msg_0,
    RightMsg = util_string:filter(Msg),
    CurrTime = util_time:timestamp(),

    %% 世界聊天
    if
        Channel == ?CHAT_CHANNEL_WORLD ->
            mod_interface_cd:assert(player_chat, SendCdTime * 1000),
            Data = api_player_chat:pack_broadcast_channel_msg(PlayerId, Channel, RightMsg, CurrTime),
            mod_socket:send_to_all_online_player_by_filter(Data, fun(ThisPlayerId) -> ThisPlayerId =/= PlayerId end),
            Node = node(),
            ?TRY_CATCH(player_chat_srv:send({?CHAT_CHANNEL_WORLD, Node, Data}));
        Channel == ?CHAT_CHANNEL_PRIVATE ->
            mod_interface_cd:assert({player_chat, Id}, SendCdTime * 1000),
            #db_player_data{
                head_id = HeadId,
                level = Level,
                vip_level = VipLevel,
                head_frame_id = HeadFrameId
            } = mod_player:get_db_player_data(PlayerId),
            PlayerNickname = mod_player:get_player_name(ServerId, Nickname),
            Data = api_player_chat:pack_broadcast_channel_msg(PlayerId, Channel, PlayerId, RightMsg, CurrTime),
            ?TRY_CATCH(player_chat_srv:send(
                {
                    ?CHAT_CHANNEL_PRIVATE,
                    PlayerId,
                    Id,
                    RightMsg,
                    Data,
                    {PlayerNickname, Sex, Level, VipLevel, HeadId, HeadFrameId}
                }
            ));
        true ->
            exit(?ERROR_FAIL)
    end,
    ok.

%% @doc 获得玩家聊天信息
get_player_chat_info(Nickname) ->
    {PlayerServerId, PlayerName} =
        case string:tokens(Nickname, ".") of
            [ServerId, Name] ->
                {ServerId, Name};
            List when is_list(List) ->
                Length = length(List),
                ?ASSERT(Length >= 2, ?ERROR_NONE),
                [ServerId | NewList] = List,
                Name = lists:append(NewList),
                {ServerId, Name};
            _ ->
                exit(?ERROR_NONE)
        end,
    ThisServerId = mod_server:get_server_id(),

    if
        PlayerServerId == ThisServerId ->
            get_chat_info_by_sid_and_nickname_game(PlayerServerId, PlayerName);
        true ->
            case mod_server_rpc:call_war(?MODULE, get_chat_info_by_sid_and_nickname_war, [PlayerServerId, PlayerName]) of
                {badrpc, {'EXIT', Reason}} ->
                    exit(Reason);
                Result ->
                    Result
            end
    end.
get_chat_info_by_sid_and_nickname_war(ServerId, Nickname) ->
    PlatformId = mod_server_config:get_platform_id(),
    Fun =
        fun() ->
            case mod_server_rpc:call_game_server(PlatformId, ServerId, ?MODULE, get_chat_info_by_sid_and_nickname_game, [ServerId, Nickname]) of
                {badrpc, {'EXIT', Reason}} ->
                    exit(Reason);
                {badrpc, _Reason} ->
                    exit(?ERROR_NONE);
                Result ->
                    Result
            end
        end,
    case mod_cache:cache_data({?MODULE, get_chat_info_by_sid_and_nickname_war, ServerId, Nickname}, Fun, 10 * ?MINUTE_S) of
        null ->
            exit(?ERROR_NONE);
        Result ->
            Result
    end.
get_chat_info_by_sid_and_nickname_game(ServerId, Nickname) ->
    ?DEBUG("根据服务器和名字查找玩家 : ~p", [{node(), ServerId, Nickname}]),
    DbPlayer = mod_player:get_player_by_sid_and_nickname(ServerId, Nickname),
    ?ASSERT(DbPlayer =/= null, ?ERROR_NONE),
    #db_player{
        id = PlayerId,
        sex = Sex
    } = DbPlayer,
    #db_player_data{
        level = Level,
        vip_level = VipLevel,
        head_id = HeadId,
        head_frame_id = HeadFrameId
    } = mod_player:get_db_player_data(PlayerId),
    ModelHeadFigure = api_player:pack_model_head_figure(PlayerId, mod_player:get_player_name(ServerId, Nickname), Sex, HeadId, VipLevel, Level, HeadFrameId),
    Signature = mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_SIGNATURE),
    {ok, Signature, ModelHeadFigure}.

get_player_list_online_status(PlayerIdList) ->
    mod_server_rpc:call_war(?MODULE, get_player_list_online_status_war, [PlayerIdList]).
get_player_list_online_status_war(PlayerIdList) ->
    {ok, lists:map(
        fun(PlayerId) ->
            Fun =
                fun() ->
                    {PlatformId, ServerId} = mod_player:get_platform_id_and_server_id(PlayerId),
                    mod_server_rpc:call_game_server(PlatformId, ServerId, mod_online, is_online, [PlayerId])
                end,
            IsOnline = mod_cache:cache_data({get_is_online_status, PlayerId}, Fun, 30),
            {PlayerId, ?TRAN_BOOL_2_INT(IsOnline)}
        end,
        PlayerIdList
    )}.


%% ----------------------------------
%% @doc 	广播跨服聊天消息
%% @throws 	none
%% @end
%% ----------------------------------
broadcast_cross_chat(Data) ->
    mod_socket:send_to_all_online_player(Data).
%%    add_chat_cache({?MODULE, ?CHAT_CHANNEL_WORLD}, Data).

%% @doc 	添加聊天缓存
add_chat_cache(ChatIdKey, Data) ->
    add_chat_cache(ChatIdKey, Data, ?TRUE).
add_chat_cache(_ChatIdKey, _Data, ?FALSE) -> noop;
add_chat_cache(ChatIdKey, Data, _IsCache) ->
    QueueCache = mod_cache:get(ChatIdKey, []),
    {?MODULE, Channel} = ChatIdKey,
    #t_chat{
        record_num = RecordNum
    } = get_t_chat(Channel),
    mod_cache:update(ChatIdKey, lists:sublist([{Data, util_time:timestamp()} | QueueCache], RecordNum)).

%% ----------------------------------------- 系统公告
%% 系统公告
send_system_template_message(NoticeId, List) ->
    #t_chat_notice{
        notice_type = NoticeType
    } = get_t_chat_notice(NoticeId),
    NewList = [util:to_binary(NoticeContent) || NoticeContent <- List],
    Out = api_player_chat:pack_system_template_message(NoticeId, NewList, NoticeType),
    mod_socket:send_to_all_online_player(Out).
%%    add_chat_cache({?MODULE, ?CHAT_CHANNEL_SYSTEM}, Out).
send_system_template_message(PlayerId, NoticeId, List) ->
    #t_chat_notice{
        notice_type = NoticeType
    } = get_t_chat_notice(NoticeId),
    NewList = [util:to_binary(NoticeContent) || NoticeContent <- List],
    Out = api_player_chat:pack_system_template_message(NoticeId, NewList, NoticeType),
    mod_socket:send(PlayerId, Out).

%% ================================================ 模板操作 ================================================

%% @doc fun 获得聊天频道模板
get_t_chat(ChatId) ->
    t_chat:assert_get({ChatId}).

%% @doc 获得通知模板数据
get_t_chat_notice(NoticeId) ->
    t_chat_notice:assert_get({NoticeId}).