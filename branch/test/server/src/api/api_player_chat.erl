%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2021
%%% @doc            聊天
%%% @end
%%% Created : 23. 十一月 2021 下午 3:50
%%%-------------------------------------------------------------------
-module(api_player_chat).

-include("common.hrl").
-include("p_enum.hrl").
-include("gen/db.hrl").
-include("error.hrl").
-include("p_message.hrl").
-include("chat.hrl").
-include("gen/table_enum.hrl").

-export([
    channel_chat/2,                                 %% 频道聊天
    get_player_chat_info/2,                         %% 聊天 获得玩家信息
    get_player_list_online_status/2,                %% 获得玩家列表在线状态
    notice_msg_list/2,                              %% 通知消息列表

    notice_system_message/1,
    pack_system_template_message/3
%%    do_notice/0
]).
-export([
    pack_broadcast_channel_msg/4,
    pack_broadcast_channel_msg/5,
    broadcast_channel_msg_list/1,
    pack_chat_broadcast_channel_msg_list/1
]).

%% @doc 频道聊天
channel_chat(
    Args,
    #conn{player_id = PlayerId}
) ->
    #m_player_chat_channel_chat_tos{channel = Channel, id = Id, msg_data = Msg} = Args,
    ?DEBUG("channel_chat:~w~n", [Msg]),
    ReasonResult =
        try mod_player_chat:channel_chat(PlayerId, Channel, Id, util:to_list(Msg)) of
            _ ->
                ?P_SUCCESS
        catch
            _:Reason ->
                Code = case Reason of
                           ?ERROR_NEED_LEVEL ->
                               ?P_LEVEL_LIMIT;
                           ?ERROR_INTERFACE_CD_TIME ->
                               ?P_TOO_QUICK;
                           ?ERROR_MSG_TOO_LONG ->
                               ?P_TOO_LONG;
                           ?ERROR_NOT_ENOUGH_VIP_LEVEL ->
                               ?P_NOT_ENOUGH_VIP_LEVEL;
                           ?ERROR_NOT_AUTHORITY ->
                               ?P_NOT_AUTHORITY;
                           _ ->
                               ?P_FAIL
                       end,
                ?ERROR("channel_chat:~p", [{Reason, erlang:get_stacktrace()}]),
                Code
        end,
    Data = proto:encode(#m_player_chat_channel_chat_toc{reason = ReasonResult, channel = Channel, id = Id, msg_data = Msg}),
    mod_socket:send(Data).

%% @doc 获得玩家聊天信息
get_player_chat_info(
    #m_player_chat_get_player_chat_info_tos{nickname = Nickname},
    #conn{player_id = PlayerId}
) ->
    {Result, Signature, ModelHeadFigure} =
        case catch mod_player_chat:get_player_chat_info(util:to_list(Nickname)) of
            {ok, Signature1, ModelHeadFigure1} ->
                {?P_SUCCESS, Signature1, ModelHeadFigure1};
            {'EXIT', Reason} ->
                {api_common:api_error_to_enum(Reason), ?UNDEFINED, ?UNDEFINED}
        end,
    Out = proto:encode(#m_player_chat_get_player_chat_info_toc{
        result = Result,
        signature = Signature,
        model_head_figure = ModelHeadFigure
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 获得玩家列表在线状态
get_player_list_online_status(
    #m_player_chat_get_player_list_online_status_tos{player_id_list = PlayerIdList},
    #conn{player_id = PlayerId}
) ->
    List =
        case catch mod_player_chat:get_player_list_online_status(PlayerIdList) of
            {ok, List1} ->
                List1;
            {'EXIT', _Reason} ->
                []
        end,
    Out = proto:encode(#m_player_chat_get_player_list_online_status_toc{
        player_online_state = pack_player_online_state_list(List)
    }),
    mod_socket:send(PlayerId, Out).

pack_player_online_state_list(List) ->
    [#chatplayeronline{player_id = PlayerId, state = State} || {PlayerId, State} <- List].

%% @doc 通知消息列表
notice_msg_list(_PlayerId, []) ->
    noop;
notice_msg_list(PlayerId, List) ->
    Out = proto:encode(#m_player_chat_broadcast_channel_msg_list_toc{
        chat_data_list = pack_pb_chat_data_list(List)
    }),
    mod_socket:send(PlayerId, Out).

%% @doc 通知系统消息
notice_system_message(Msg) ->
    notice_system_message(Msg, 1).
notice_system_message(Msg, LoopNum) ->
    ?DEBUG("通知系统消息:~p", [{Msg, LoopNum}]),
    BinMsg = case is_binary(Msg) of
                 true ->
                     Msg;
                 false ->
                     list_to_binary(Msg)
             end,
    List = [{?CHAT_CHANNEL_SYSTEM, [{BinMsg, util_time:timestamp(), LoopNum}]}],
    Out = proto:encode(#m_player_chat_broadcast_channel_msg_list_toc{
        chat_data_list = pack_pb_chat_data_list(List)
    }),
    mod_socket:send_to_all_online_player(Out),
    ok.

%% @doc 通知系统模板消息
pack_system_template_message(NoticeId, ArgList, NoticeType) ->
    List = [{NoticeType, [{chat_notice, util_time:timestamp(), NoticeId, ArgList}]}],
    proto:encode(#m_player_chat_broadcast_channel_msg_list_toc{
        chat_data_list = pack_pb_chat_data_list(List)
    }).

%% ================================================ 结构化操作 ================================================

pack_broadcast_channel_msg(PlayerId, Channel, Msg, Time) ->
    ModelHeadFigure = api_player:pack_model_head_figure(PlayerId),
    proto:encode(
        #m_player_chat_broadcast_channel_msg_list_toc{
            chat_data_list = pack_pb_chat_data_list([{Channel, [{ModelHeadFigure, Msg, Time}]}])
        }
    ).
pack_broadcast_channel_msg(PlayerId, Channel, Id, Msg, Time) ->
    ModelHeadFigure = api_player:pack_model_head_figure(PlayerId),
    proto:encode(
        #m_player_chat_broadcast_channel_msg_list_toc{
            chat_data_list = pack_pb_chat_data_list([{Channel, Id, [{ModelHeadFigure, Msg, Time}]}])
        }
    ).

pack_pb_chat_data_list(ChatDataList) ->
    [pack_pb_chat_data(ChatData) || ChatData <- ChatDataList].
pack_pb_chat_data({Channel, MsgDataList}) ->
    #chatinfo{
        channel = Channel,
        msg_data_list = pack_pb_msg_data_list(MsgDataList)
    };
pack_pb_chat_data({Channel, Id, MsgDataList}) ->
    #chatinfo{
        channel = Channel,
        id = Id,
        msg_data_list = pack_pb_msg_data_list(MsgDataList)
    }.

pack_pb_msg_data_list(MsgDataList) ->
    [pack_pb_msg_data(MsgData) || MsgData <- MsgDataList].
pack_pb_msg_data({chat_notice, Time, TemplateId, ArgList}) ->
    #msginfo{
        msg_data = <<>>,
        template_id = TemplateId,
        arg_list = ArgList,
        loop_num = 1,
        time = Time
    };
pack_pb_msg_data({ModelHeadFigure, MsgData, Time}) when is_record(ModelHeadFigure, modelheadfigure) ->
    #msginfo{
        model_head_figure = ModelHeadFigure,
        msg_data = util:to_binary(MsgData),
        template_id = 0,
        time = Time
    };
pack_pb_msg_data({MsgData, Time, LoopNum}) ->
    #msginfo{
        msg_data = util:to_binary(MsgData),
        template_id = 0,
        time = Time,
        loop_num = LoopNum
    };
pack_pb_msg_data({ModelHeadFigure, MsgData, Time, TemplateId, ArgList, LoogNum}) ->
    #msginfo{
        model_head_figure = ModelHeadFigure,
        msg_data = MsgData,
        template_id = TemplateId,
        arg_list = ArgList,
        loop_num = LoogNum,
        time = Time
    }.

%% @doc 广播频道消息列表
broadcast_channel_msg_list(Out) ->
    mod_socket:send_to_all_online_player(Out).

pack_chat_broadcast_channel_msg_list(List) ->
    proto:encode(#m_chat_broadcast_channel_msg_list_toc{
        msg_data_list = List
    }).