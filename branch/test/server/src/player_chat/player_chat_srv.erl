%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2021
%%% @doc       消息服务
%%% @end
%%% Created : 22. 十月 2021 下午 3:23
%%%-------------------------------------------------------------------
-module(player_chat_srv).

-behaviour(gen_server).

-include("common.hrl").
-include("gen/table_enum.hrl").
-include("system.hrl").
-include("player_game_data.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").

%% API
-export([
    start_link/0,

    send/1,
    chat_notice/2
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-export([
    handle_send_private/5
]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%% @doc 发送消息到war进程
send(Msg) ->
    RegNameTuple =
        case mod_server_config:get_server_type() of
            ?SERVER_TYPE_WAR_AREA ->
                ?MODULE;
            _ ->
                {?MODULE, mod_server_config:get_war_area_node()}
        end,
    erlang:send(RegNameTuple, Msg).

%% @doc 聊天通知
chat_notice(NoticeId, NoticeArgList) ->
    player_chat_srv:send({?CHAT_CHANNEL_SYSTEM, NoticeId, NoticeArgList}).

%% @doc 发送消息到游戏进程
%%send(Msg) ->
%%    erlang:send(?MODULE, Msg).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({?CHAT_CHANNEL_WORLD, AtomNode, Msg}, State) ->
    ?CATCH(handle_world_chat(AtomNode, Msg, State)),
    {noreply, State};
handle_info({?CHAT_CHANNEL_PRIVATE, Sender, Receiver, Msg, Data, HeadData}, State) ->
    Node = mod_player:get_game_node(Receiver),
    rpc:cast(Node, ?MODULE, handle_send_private, [Sender, Receiver, Msg, Data, HeadData]),
    {noreply, State};
handle_info({?CHAT_CHANNEL_SYSTEM, NoticeId, NoticeArgList}, State) ->
%%    Node = mod_player:get_game_node(Receiver),
%%    Fun = fun() -> mod_server:get_all_game_node() end,
    NodeList = war_srv:get_join_node_list(),
%%    NodeList = [node()],
    lists:foreach(
        fun(ThisNode) ->
            rpc:cast(ThisNode, mod_player_chat, send_system_template_message, [NoticeId, NoticeArgList])
        end,
        NodeList
    ),
    {noreply, State};
handle_info(_Info, State) ->
    ?WARNING("未知消息:~p", [_Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%% @doc 世界聊天
handle_world_chat(Node, MsgData, #state{}) ->
%%    Fun = fun() -> mod_server:get_all_game_node() end,
%%    NodeList = mod_cache:cache_data({?MODULE, chat_send_world}, Fun, 30),
    NodeList = war_srv:get_join_node_list(),
%%    NodeList = [node()],
    lists:foreach(
        fun(ThisNode) ->
            if ThisNode == Node ->
                noop;
                true ->
                    rpc:cast(ThisNode, mod_player_chat, broadcast_cross_chat, [MsgData])
            end
        end,
        NodeList
    ).

%% @doc 发送私信
handle_send_private(Sender, Receiver, Msg, Data, {PlayerNickname, Sex, Level, VipLevel, HeadId, HeadFrameId}) ->
    case mod_online:is_online(Receiver) of
        true ->
            mod_socket:send(Receiver, Data);
        false ->
            ChatId = mod_player_game_data:get_int_data(Receiver, ?PLAYER_GAME_DATA_CHAT_RECORD_ID) + 1,
            DbPlayerChatList = db_index:get_rows(#idx_player_chat_data_by_player{player_id = Receiver}),
            Length = length(DbPlayerChatList),
            #t_chat{
                record_num = RecordNum
            } = mod_player_chat:get_t_chat(?CHAT_CHANNEL_PRIVATE),
            Tran =
                fun() ->
                    mod_player_game_data:set_int_data(Receiver, ?PLAYER_GAME_DATA_CHAT_RECORD_ID, ChatId),
                    if
                        Length >= RecordNum ->
                            L = lists:sort(
                                fun(APlayerChat, BPlayerChat) ->
                                    APlayerChat#db_player_chat_data.send_time < BPlayerChat#db_player_chat_data.send_time
                                end,
                                DbPlayerChatList
                            ),
                            db:delete(hd(L));
                        true ->
                            noop
                    end,
                    db:write(#db_player_chat_data{
                        player_id = Receiver,
                        id = ChatId,
                        send_player_id = Sender,
                        chat_msg = Msg,
                        nickname = PlayerNickname,
                        sex = Sex,
                        level = Level,
                        vip_level = VipLevel,
                        head_frame_id = HeadFrameId,
                        head_id = HeadId,
                        send_time = util_time:timestamp()
                    })
                end,
            db:do(Tran)
    end.