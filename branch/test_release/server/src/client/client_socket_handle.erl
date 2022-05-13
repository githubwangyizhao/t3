%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家进程socket处理
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(client_socket_handle).

-include("common.hrl").
-include("socket.hrl").
%% API
-export([
    handle_ws_handshake/3,
    handle_tcp_data/2
]).


%% ----------------------------------
%% @doc 	处理ws握手
%% @throws 	none
%% @end
%% ----------------------------------
handle_ws_handshake(SocketMod, Socket, IP) ->
    handle_ws_handshake(SocketMod, Socket, IP, [], 2).
handle_ws_handshake(SocketMod, Socket, IP, Cache, 0) ->
    ?ERROR("handle_ws_handshake:~p", [{IP, Cache}]),
    SocketMod:close(Socket),
    exit(normal);
handle_ws_handshake(SocketMod, Socket, IP, Cache, Num) ->
%%    receive
%%        R ->
%%            io:format("RRR:~p~n", [R])
%%    end,
    case SocketMod:recv(Socket, 0, 3000) of
        {ok, Bin} ->
            Request = Cache ++ erlang:binary_to_list(Bin),
            try pack_handshake(Request) of
                false ->
                    ?WARNING("Cache ws handshake:~p", [{IP, Request, Num}]),
                    handle_ws_handshake(SocketMod, Socket, IP, Request, Num - 1);
                {ok, Response} ->
                    ok = SocketMod:send(Socket, Response)
            catch
                _:_Reason ->
                    ?ERROR("pack_handshake error:~p~n", [{IP, Request, erlang:get_stacktrace()}]),
                    SocketMod:close(Socket),
                    exit(pack_handshake_error)
            end;
        {error, Reason} ->
            ?ERROR("handle_ws_handshake:~p", [{IP, Reason, Cache, Num}]),
            SocketMod:close(Socket),
            exit(normal)
    end.

%% ----------------------------------
%% @doc 	打包握手消息
%% @throws 	none
%% @end
%% ----------------------------------
pack_handshake(Request) ->
    Segment = lists:filter(
        fun(S) ->
            lists:prefix("Sec-WebSocket-Key:", S)
        end,
        string:tokens(Request, "\r\n")
    ),
    if Segment == [] ->
        false;
        true ->
            Key =
                list_to_binary(
                    lists:last(
                        string:tokens(
                            hd(Segment
                            ),
                            ": "
                        )
                    )
                ),
            Accept = base64:encode(crypto:hash(sha, <<Key/binary, "258EAFA5-E914-47DA-95CA-C5AB0DC85B11">>)),
            {
                ok,
                [
                    "HTTP/1.1 101 Switching Protocols\r\n",
                    "connection: Upgrade\r\n",
                    "upgrade: websocket\r\n",
                    "sec-websocket-accept: ", Accept, "\r\n",
                    "\r\n"
                ]
            }
    end.

%% ----------------------------------
%% @doc 	处理socket 消息
%% @throws 	none
%% @end
%% ----------------------------------
handle_tcp_data(Request, State = #conn{player_id = PlayerId, recv_count = RecvCount, error_count = ErrorCount, buff = Buff, status = Status}) ->
%%    ?DEBUG("收到socket:~p", [Request]),
%%    ?DEBUG("收到协议2:~p", [websocket_util:parse_frames(Request)]),
%%    Packet = websocket_util:get_packet_data(Request),

%%    ?DEBUG("收到协议1:~p", [Packet]),
    case util_websocket:parse_frames(<<Buff/binary, Request/binary>>) of
        close ->
            ?DEBUG("收到关闭协议:~p", [close]),
            {stop, ws_close, State};
        {error, Reason} ->
            ?ERROR("parse_frames:~p", [{Reason, erlang:get_stacktrace()}]),
            {stop, Reason, State};
%%        {Rest, <<>>} ->
        {Rest, DataList} ->
            State1 = State#conn{
                buff = Rest
            },
            RestLen = erlang:byte_size(Rest),
            if RestLen > 300 ->
                {stop, {rest_size, RestLen}, State};
                true ->
%%                    ?DEBUG("数据:~p", [{{rest, Rest}, {data_list, DataList}}]),
                    lists:foldl(fun(Data, TmpSate) ->
                        case TmpSate of
                            {stop, _, _} ->
                                TmpSate;
                            _ ->
                                try socket_router:handle(Data, TmpSate) of
                                    NewState when is_record(NewState, conn) ->
                                        NewState#conn{recv_count = RecvCount + 1};
                                    {stop, Reason} ->
                                        {stop, Reason, TmpSate};
                                    _ ->
                                        TmpSate#conn{recv_count = RecvCount + 1}
                                catch
                                    _ : {unexpected_proto_num, MsgNum, _Status} ->
                                        ?ERROR(
                                            "~n"
                                            "Router request error :~n"
                                            "         player : ~p~n"
                                            "         reason : ~p~n",
                                            [PlayerId, {unexpected_proto_num, MsgNum, _Status}]),
                                        TmpSate#conn{recv_count = RecvCount + 1, error_count = ErrorCount + 1};
                                    _ : Reason ->
                                        ?ERROR(
                                            "~n"
                                            "Router request error1 :~n"
                                            "         player : ~p~n"
                                            "         status : ~p~n"
                                            "        request : ~p~n"
                                            "         reason : ~p~n"
                                            "     stacktrace : ~p~n",
                                            [PlayerId, Status, Request, Reason, erlang:get_stacktrace()]),
                                        TmpSate#conn{recv_count = RecvCount + 1, error_count = ErrorCount + 1}

                                end
                        end
                                end,
                        State1,
                        DataList
                    )
            end
    end.
