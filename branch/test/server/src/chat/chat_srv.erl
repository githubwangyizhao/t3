%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            消息服务
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(chat_srv).

-behaviour(gen_server).
-include("common.hrl").
-include("gen/db.hrl").
%% API
-export([
    start_link/0,
    send_msg/1,
    get_chat_zone_list/1,
    send_war_msg/1,
    leave_war_channel/1,
    join_war_channel/1
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).
-define(CHAT_ZONE_NUM, 9).%% 跨服聊天的节点数量
%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


send_msg(Data) ->
    ?ASSERT(mod_server:is_game_server()),
    mod_server_rpc:send_war(chat_srv, Data).

send_war_msg(Data) ->
    ?ASSERT(mod_server:is_game_server()),
    mod_server_rpc:send_war(chat_srv, {send_war_msg, Data}).

leave_war_channel(ClientWorker) ->
    ?ASSERT(mod_server:is_game_server()),
    mod_server_rpc:send_war(chat_srv, {leave_war_channel, ClientWorker}).

join_war_channel(ClientWorker) ->
    ?ASSERT(mod_server:is_game_server()),
    mod_server_rpc:send_war(chat_srv, {join_war_channel, ClientWorker}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.
%%
%%handle_info({chat, AtomNode, Msg}, State) ->
%%    ?TRY_CATCH2(handle_chat(AtomNode, Msg, State)),
%%    {noreply, State};
handle_info({join_war_channel, ClientWorker}, State) ->
    ?TRY_CATCH2(handle_join_war_channel(ClientWorker)),
    {noreply, State};
handle_info({leave_war_channel, ClientWorker}, State) ->
    ?TRY_CATCH2(delete_war_channel_list(ClientWorker)),
    {noreply, State};
handle_info({send_war_msg, Msg}, State) ->
    ?TRY_CATCH2(handle_send_war_msg(Msg)),
    {noreply, State};
handle_info({chat, AtomNode, Msg, Channel}, State) ->
    ?TRY_CATCH2(handle_chat(AtomNode, Msg, Channel, State)),
    {noreply, State};
handle_info({'DOWN', _Ref, process, ClientWorker, _Reason}, State) ->
    ?TRY_CATCH2(delete_war_channel_list(ClientWorker)),
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
%%handle_chat(Node, MsgData, #state{}) ->
%%    NodeList = zone_srv:get_join_node_list(),
%%%%    ?DEBUG("发送消息:~p", [Node]),
%%    lists:foreach(
%%        fun(ThisNode) ->
%%            if ThisNode == Node ->
%%                noop;
%%                true ->
%%                    rpc:cast(ThisNode, mod_chat, broadcast_cross_chat, [MsgData])
%%            end
%%        end,
%%        NodeList
%%    ).

get_war_channel_list() ->
    case get(war_channel_list) of
        ?UNDEFINED ->
            [];
        L ->
            L
    end.

delete_war_channel_list(E) ->
    ?DEBUG("移除玩家进程:~p", [E]),
    Ref = erase({ref, E}),
    erlang:demonitor(Ref),
    L = get_war_channel_list(),
    L1 = lists:delete(E, L),
    update_war_channel_list(L1).

add_war_channel_list(E) ->
    ?DEBUG("添加玩家进程:~p", [E]),
    L = get_war_channel_list(),
    case lists:member(E, L) of
        false ->
            Ref = erlang:monitor(process, E),
            put({ref, E}, Ref),
            put(war_channel_list, [E | L]);
        true ->
            ?DEBUG("重复添加玩家进程:~p", [E])
    end.

update_war_channel_list(L) ->
    put(war_channel_list, L).

handle_join_war_channel(ClientWorker) ->
    add_war_channel_list(ClientWorker).

handle_send_war_msg(Msg) ->
    ?DEBUG("广播仙界消息:~p", [{get_war_channel_list(), Msg}]),
    lists:foreach(
        fun(ClientWorker) ->
            client_worker:apply(ClientWorker, mod_socket, send, [Msg])
        end,
        get_war_channel_list()
    ).


handle_chat(Node, MsgData, Channel, #state{}) ->
    NodeList = get_chat_zone_list(Node),
    ?DEBUG("发送消息:~p", [Node]),
    lists:foreach(
        fun(ThisNode) ->
            if ThisNode == Node ->
                noop;
                true ->
                    rpc:cast(ThisNode, mod_chat, broadcast_cross_chat, [Channel, MsgData])
            end
        end,
        NodeList
    ).

get_chat_zone_list(Node) ->
    case mod_cache:get({?MODULE, chat_zone_list_3, Node}) of
        null ->

%            L = lists:keysort(#db_c_game_server.sid, mod_server:get_game_server_list()),
%            L2 = [util:to_atom(E#db_c_game_server.node) ||E <-L],
%            Sid = mod_server:get_node_server_id(GameServer#db_c_game_server.node),
%            LSrot1 = [{mod_server:get_real_server_id(E#db_c_game_server.sid), util:to_atom(E#db_c_game_server.node)} ||E <- mod_server:get_game_server_list()],
%%            LSrot1 = [{mod_server:get_node_server_id(E#db_c_game_server.node), util:to_atom(E#db_c_game_server.node)} ||E <- mod_server:get_game_server_list()],
%%            L2 = lists:usort(LSrot1 ),
%%            NewChatZoneList = do_get_chat_zone_list(L2, Node),
            NewChatZoneList = do_get_chat_node_list(Node),
            mod_cache:update({?MODULE, chat_zone_list_3, Node}, NewChatZoneList, 60 * 5),
            NewChatZoneList;
        ChatZoneList ->
            ChatZoneList
    end.

%%do_get_chat_zone_list([], _Node) ->
%%    [];
%%do_get_chat_zone_list(NodeList, Node) ->
%%    {H, L} =
%%        if length(NodeList) >= ?CHAT_ZONE_NUM ->
%%            lists:split(?CHAT_ZONE_NUM, NodeList);
%%            true ->
%%                {NodeList, []}
%%        end,
%%    case lists:keymember(Node, 2, H) of
%%        true ->
%%            [ CalcNode || {_, CalcNode} <- H];
%%        false ->
%%            do_get_chat_zone_list(L, Node)
%%    end.




do_get_chat_node_list(Node) ->
    LSrot1 = [{mod_server:get_node_server_id(E#db_c_game_server.node), util:to_atom(E#db_c_game_server.node)} || E <- mod_server:get_game_server_list()],
    NodeList = lists:usort(LSrot1),

    L1 = [
        begin
            #db_c_server_node{
                zone_node = ZoneNode
            } = mod_server:get_server_node(Node),
            {{get_zone_id(ZoneNode), ZoneNode}, Node}
        end
        || {_, Node} <- NodeList
    ],
    L2 = lists:sort(lists:foldl(
        fun({ZoneNode, Node}, TempList) ->
            util_list:key_insert({ZoneNode, Node}, TempList)
        end,
        [],
        lists:reverse(L1)
    )),
    L3 = do_split(L2, []),
    find_chat_node_list(L3, Node).

find_chat_node_list([], _Node) ->
    [];
find_chat_node_list([H | L], Node) ->
    case lists:member(Node, H) of
        true ->
            H;
        false ->
            find_chat_node_list(L, Node)
    end.
do_split([], Tmp) ->
    Tmp;
do_split([{_, A}], Tmp) ->
    [A | Tmp];
do_split([{_, A}, {_, B}], Tmp) ->
    [A ++ B | Tmp];
do_split([{_, A}, {_, B}, {_, C} | Left], Tmp) ->
    do_split(Left, [A ++ B ++ C | Tmp]).

get_zone_id(Node) ->
    [NodeName, _] = string:split(Node, "@"),
    IsMatch = string:str(NodeName, "_"),
    if IsMatch > 0 ->
        [_, Sid] = string:split(NodeName, "_"),
        mod_server:get_real_server_id(Sid);
        true ->
            mod_server:get_real_server_id(NodeName)
    end.
