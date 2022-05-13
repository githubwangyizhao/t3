%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(util_socket).
-include("common.hrl").
-include("socket.hrl").
%% API
-export([send/2, get_peer_info/2, get_sock_info/2]).

send(S, Packet) ->
    case gen_tcp:send(S, Packet) of
        ok ->
            ok;
        {error, Reason} ->
            exit({tcp_send_error, Reason})
    end.

get_peer_info(SocketMod, Socket) ->
    R =
        case SocketMod of
            gen_tcp ->
                inet:peername(Socket);
            ssl ->
                ssl:peername(Socket)
        end,
    case R of
        {ok, {PeerAddress, PeerPort}} ->
            {inet_parse:ntoa(PeerAddress), PeerPort};
        {error, Reason} ->
            ?ERROR("获取不到客户端ip:~p", [{Reason, Socket}]),
            {"0.0.0.0", 0}
    end.

get_sock_info(SocketMod, Socket) ->
    {ok, {PeerAddress, PeerPort}} =
        case SocketMod of
            gen_tcp ->
                inet:sockname(Socket);
            ssl ->
                ssl:sockname(Socket)
        end,
    {inet_parse:ntoa(PeerAddress), PeerPort}.


