%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家发送进程
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(client_sender_worker).
-include("logger.hrl").
-include("prof.hrl").
-include("socket.hrl").

%% API
-export([
    start/3,
    send/1,
    send/2,
    init_player_id/2
]).

send(Data) ->
    send(get(sender_worker), Data).

send(Pid, Data) ->
    Pid ! {send, Data}.

init_player_id(Pid, PlayerId) ->
    Pid ! {init_player_id, PlayerId}.

start(SocketMod, Socket, Master) ->
    erlang:monitor(process, Master),
%%    if
%%        ?IS_DEBUG ->
%%            %% 初始化 缓存
%%            init_buffer(),
%%            clock_flush_buffer();
%%        true ->
%%            noop
%%    end,
    loop(SocketMod, Socket, Master, undefined).

loop(SocketMod, Socket, Master, PlayerId) ->
    receive
        {send, Data} ->
%%            if
%%                ?IS_DEBUG ->
%%                    append_buffer(Data),
%%                    loop(Socket, Master, PlayerId);
%%                true ->
            case SocketMod:send(Socket, Data) of
                ok ->
                    try
                        mod_log:write_player_send_proto_log(PlayerId, Data)
                    catch
                        _:Reason ->
                            logger:error("write_player_send_proto_log:  ~p~n", [{Reason, erlang:get_stacktrace()}])
                    end;
                {error, Reason} ->
                    ?ERROR("(~p)socket send:~p~n", [PlayerId, {SocketMod, Reason}]),
                    exit(tcp_send_error)
            end,
            loop(SocketMod, Socket, Master, PlayerId);
%%            end;
%%        flush ->
%%            flush_buffer(PlayerId, Socket),
%%            clock_flush_buffer(),
%%            loop(Socket, Master, PlayerId);
        {init_player_id, InitPlayerId} ->
            loop(SocketMod, Socket, Master, InitPlayerId);
        {'DOWN', _Ref, process, Master, _Reason} ->
            stop;
        Other ->
            ?ERROR("sender_loop_unexpected_msg: ~p", [Other]),
            exit(sender_loop_unexpected_msg)
    end.
%%
%%init_buffer() ->
%%    put(buffer, []).
%%
%%clock_flush_buffer() ->
%%    erlang:send_after(env:get(proto_delay_send, 1), self(), flush).
%%
%%flush_buffer(PlayerId, Socket) ->
%%    Buffer = get(buffer),
%%    lists:foreach(
%%        fun(Data) ->
%%%%            ?START_PROF,
%%%%            <<_:8, Method:32/unsigned, _Packet/binary>> = Data,
%%            case ?SOCKET_MOD:send(Socket, Data) of
%%                ok ->
%%                    noop;
%%                {error, Reason} ->
%%                    ?ERROR("(~p)socket send:~p~n", [PlayerId, Reason]),
%%                    exit(tcp_send_error)
%%            end,
%%            try
%%                mod_log:write_player_send_proto_log(PlayerId, Data)
%%            catch
%%                _:Reason1 ->
%%                    logger:error("write_player_send_proto_log:~p~n", [{Reason1, erlang:get_stacktrace()}])
%%            end
%%%%            catch mod_log:write_player_send_proto_log(PlayerId, Data)
%%%%            ?STOP_PROF(?MODULE, proto_send, Method)
%%        end,
%%        lists:reverse(Buffer)
%%    ),
%%    put(buffer, []).
%%
%%append_buffer(Data) ->
%%    Buffer = get(buffer),
%%    put(buffer, [Data | Buffer]).
