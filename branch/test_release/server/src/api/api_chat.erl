%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            聊天
%%% @end
%%% Created : 07. 十二月 2017 下午 3:50
%%%-------------------------------------------------------------------
-module(api_chat).

-include("common.hrl").
-include("p_enum.hrl").
-include("gen/db.hrl").
-include("error.hrl").
-include("p_message.hrl").
-include("chat.hrl").
-export([
    channel_chat/2,
    notice_system_message/1,
    notice_system_message/2,
    notice_system_template_message/3,
    notice_system_template_message/4,
    notice_system_message_by_channel/2,
    run_panda/0,
    do_notice/0
]).
-export([
    pack_broadcast_channel_msg/3,
    pack_msg_data/3,
    broadcast_channel_msg_list/1,
    pack_chat_broadcast_channel_msg_list/1
]).
channel_chat(
    Args,
    #conn{player_id = PlayerId}
) ->
    #m_chat_channel_chat_tos{channel = Channel, msg = Msg} = Args,
    ?DEBUG("channel_chat:~w~s~n", [Msg, Msg]),
    try mod_chat:channel_chat(PlayerId, Channel, util:to_list(Msg))
    catch
        _:Reason ->
            Code = case Reason of
                       ?ERROR_NEED_LEVEL ->
                           ?P_NEED_LEVEL;
                       ?ERROR_INTERFACE_CD_TIME ->
                           ?P_TOO_QUICK;
                       ?ERROR_MSG_TOO_LONG ->
                           ?P_TOO_LONG;
                       _ ->
                           ?P_FAIL
                   end,
            ?ERROR("channel_chat:~p", [{Reason, erlang:get_stacktrace()}]),
            Data = proto:encode(#m_chat_channel_chat_toc{fail_reason = Code}),
            mod_socket:send(Data)
    end.

pack_broadcast_channel_msg(PlayerId, Channel, Msg) ->
    #db_player_data{
        head_id = HeadId
    } = mod_player:get_db_player_data(PlayerId),
    Player = mod_player:get_player(PlayerId),
    #db_player{
        sex = Sex,
        server_id = ServerId
    } = Player,
    NickName = mod_player:get_player_name(Player),
    proto:encode(
        #m_chat_broadcast_channel_msg_toc{
            player_id = PlayerId,
            nickname = erlang:list_to_binary(NickName),
            head_id = HeadId,
            serverId = list_to_binary(ServerId),
            vip_level = mod_vip:get_vip_level(PlayerId),
            channel = Channel,
            msg = list_to_binary(Msg),
            sex = Sex,
            loop_num = 0,
            template_id = 0,
            arsg_list = []
        }
    ).

run_panda() ->
    spawn(fun() -> do_run_panda() end).

do_run_panda() ->
    erlang:send_after(60 * 1000, self(), notice),
    loop().
loop() ->
    receive
        notice ->
            erlang:send_after(60 * 1000, self(), notice),
            api_chat:do_notice(),
            loop()
    end.

do_notice() ->
    Msg = <<231, 148, 177, 228, 186, 142, 231, 134, 138, 231, 140, 171, 116, 118, 232, 191, 144, 232, 144, 165, 232, 176, 131, 230, 149, 180, 239, 188, 140, 232, 175, 183, 229, 138, 160, 229, 133, 165, 81, 81, 231, 190, 164, 58, 55, 50, 53, 54, 50, 57, 51, 55, 55, 32, 231, 148, 179, 232, 175, 183, 232, 167, 146, 232, 137, 178, 232, 189, 172, 231, 167, 187, 239, 188, 140, 229, 144, 166, 229, 136, 153, 229, 190, 133, 231, 134, 138, 231, 140, 171, 116, 118, 229, 133, 179, 233, 151, 173, 229, 144, 142, 239, 188, 140, 229, 176, 134, 230, 151, 160, 230, 179, 149, 232, 191, 155, 229, 133, 165, 230, 184, 184, 230, 136, 143, 239, 188, 140, 232, 175, 183, 229, 144, 132, 228, 189, 141, 228, 187, 153, 229, 143, 139, 228, 187, 172, 230, 143, 144, 229, 137, 141, 228, 191, 157, 229, 173, 152, 232, 167, 146, 232, 137, 178, 231, 155, 184, 229, 133, 179, 230, 136, 170, 229, 155, 190, 239, 188, 140, 228, 187, 165, 228, 190, 191, 232, 186, 171, 228, 187, 189, 230, 160, 184, 229, 174, 158, 239, 188, 140, 230, 149, 172, 232, 175, 183, 232, 167, 129, 232, 176, 133, 239, 188, 129>>,
    notice_system_message_by_channel(Msg, ["2RQNiC492", "local_test"]).
%% ----------------------------------
%% @doc 	通知系统消息
%% @throws 	none
%% @end
%% ----------------------------------
notice_system_message_by_channel(Msg, ChannelList) ->
    BinMsg = case is_binary(Msg) of
                 true ->
                     Msg;
                 false ->
                     list_to_binary(Msg)
             end,
%%    Out = proto:encode(#m_chat_notice_system_message_toc{msg = BinMsg, loop_num = LoopNum}),
    Out = proto:encode(
        #m_chat_broadcast_channel_msg_toc{
            player_id = 0,
%%            nickname = <<231, 179, 187, 231, 187, 159, 229, 133, 172, 229, 145, 138>>,
            nickname = mod_chat:get_chat_name_binary(?CHANNEL_SYSTEM),
            head_id = 0,
            serverId = "",
            vip_level = 0,
            channel = ?CHANNEL_SYSTEM,
            msg = BinMsg,
            sex = 0,
            loop_num = 10,
            template_id = 0,
            arsg_list = []
        }
    ),
    PlayerIdList = mod_player:get_player_id_list_by_channel(ChannelList),
    mod_socket:send_to_player_list(PlayerIdList, Out),
    ok.

notice_system_message(Msg) ->
    notice_system_message(Msg, 10).
notice_system_message(Msg, LoopNum) ->
%%    ?DEBUG("通知系统消息:~p", [{Msg, LoopNum}]),
    BinMsg = case is_binary(Msg) of
                 true ->
                     Msg;
                 false ->
                     list_to_binary(Msg)
             end,
%%    Out = proto:encode(#m_chat_notice_system_message_toc{msg = BinMsg, loop_num = LoopNum}),
    Out = proto:encode(
        #m_chat_broadcast_channel_msg_toc{
            player_id = 0,
%%            nickname = <<231, 179, 187, 231, 187, 159, 229, 133, 172, 229, 145, 138>>,
            nickname = mod_chat:get_chat_name_binary(?CHANNEL_SYSTEM),
            head_id = 0,
            serverId = "",
            vip_level = 0,
            channel = ?CHANNEL_SYSTEM,
            msg = BinMsg,
            sex = 0,
            loop_num = LoopNum,
            template_id = 0,
            arsg_list = []
        }
    ),
    mod_socket:send_to_all_online_player(Out),
    ok.

%% ----------------------------------
%% @doc 	通知系统模版消息
%% @throws 	none
%% @end
%% ----------------------------------
notice_system_template_message(TemplateId, ArgsList, Channel) when is_integer(TemplateId) ->
    notice_system_template_message(TemplateId, ArgsList, Channel, fun mod_socket:send_to_all_online_player/1).
notice_system_template_message(TemplateId, ArgsList, Channel, Fun) ->
    %%    ?DEBUG("通知系统模版消息:~p", [{TemplateId, ArgsList, Channel}]),
%%    Out = proto:encode(#m_chat_notice_system_template_message_toc{template_id = TemplateId, arsg_list = ArgsList}),
    Out = proto:encode(
        #m_chat_broadcast_channel_msg_toc{
            player_id = 0,
%%            nickname = <<231, 179, 187, 231, 187, 159, 229, 133, 172, 229, 145, 138>>,
            nickname = mod_chat:get_chat_name_binary(?CHANNEL_SYSTEM),
            head_id = 0,
            serverId = "",
            vip_level = 0,
            channel = Channel,
            msg = "",
            sex = 0,
            loop_num = 0,
            template_id = TemplateId,
            arsg_list = ArgsList
        }
    ),

    %% 1. 广播给本服玩家
    Fun(Out).

broadcast_channel_msg_list(Out) ->
    mod_socket:send_to_all_online_player(Out).

pack_chat_broadcast_channel_msg_list(List) ->
    proto:encode(#m_chat_broadcast_channel_msg_list_toc{
        msg_data_list = List
    }).

%% @doc  打包消息数据
pack_msg_data(Channel, TemplateId, ArgsList) ->
    pack_msg_data(0, ?CHANNEL_SYSTEM, 0, "", 0, Channel, "", 0, 0, TemplateId, ArgsList).
pack_msg_data(PlayerId, Nickname, HeadId, ServerId, VipLevel, Channel, Msg, Sex, LoopNum, TemplateId, ArgsList) ->
    #msgdata{
        player_id = PlayerId,
        nickname = mod_chat:get_chat_name_binary(Nickname),
        head_id = HeadId,
        serverId = ServerId,
        vip_level = VipLevel,
        channel = Channel,
        msg = Msg,
        sex = Sex,
        loop_num = LoopNum,
        template_id = TemplateId,
        arsg_list = ArgsList
    }.
