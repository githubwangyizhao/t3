%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(acceptor).

-include("logger.hrl").
-include("socket.hrl").
-export([
    start_link/2,
    init/2
]).

start_link(SockMod, LSocket) ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, [SockMod, LSocket]).

init(SockMod, LSocket) ->
    proc_lib:init_ack({ok, self()}),
    loop(SockMod, LSocket).

loop(SockMod, LSocket) ->
    F = case SockMod of
            gen_tcp ->
                SockMod:accept(LSocket);
            ssl ->
                ssl:transport_accept(LSocket)
        end,
    case F of
        {ok, Socket} ->
%%            {IP, _Port} = util_socket:get_peer_info(Socket),
%%            {IsGo, Reason} =
%%                case ?SOCKET_MOD of
%%                    gen_tcp ->
%%                        mod_server:check_socket_connect(IP);
%%                    ssl ->
%%                        case ssl:ssl_accept(Socket) of
%%                            ok ->
%%                                mod_server:check_socket_connect(IP);
%%                            Error ->
%%                                ?ERROR("ssl_accept_error:~p", [Error]),
%%                                {false, {ssl_accept_error, Error}}
%%                        end
%%                end,

%%            if IsGo ->
            case client_worker_sup:start_child(SockMod, Socket) of
                {ok, Child} ->
                    SockMod:controlling_process(Socket, Child),
                    Child ! {go, Socket};
                {error, max_conn} ->
                    {IP, _Port} = util_socket:get_peer_info(SockMod, Socket),
                    ?WARNING("Forbidden connect:~p, reason:~p.", [IP, max_conn]),
                    SockMod:close(Socket);
                {error, Reason} ->
                    ?ERROR("Start client process error, reason: ~p~n stacktrace:~p", [Reason, erlang:get_stacktrace()]),
                    SockMod:close(Socket)
            end,
%%                true ->
%%                    ?WARNING("Forbidden connect:~p, reason:~p.", [IP, Reason]),
%%                    ?SOCKET_MOD:close(Socket)
%%            end,
            loop(SockMod, LSocket);
        {error, emfile} ->
            ?ERROR("acceptor error:~p", [emfile]),
            receive after 300 -> ok end;
        {error, closed} ->
            ?ERROR("acceptor error closed."),
            exit({accept, error, closed});
        {error, _Other} ->
            ?ERROR("acceptor error:~p", [_Other]),
            loop(SockMod, LSocket)
    end.
