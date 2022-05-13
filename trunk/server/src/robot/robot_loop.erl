-module(robot_loop).

-compile(export_all).

%% API
-export([loop/2]).

-include("robot.hrl").
-include("common.hrl").

loop(Socket, State) ->
    receive
        {send, Data} ->
            robot_socket:do_send(Socket, Data),
            loop(Socket, State);
        {tcp_passive, Socket} ->
            inet:setopts(Socket, [{active, 200}]),
            loop(Socket, State);
%%        {simulation_tcp, Data1} ->
%%            try robot_socket:handle_tcp_data(<<Buff/binary,Data1/binary>>) of
%%                _ ->
%%                    loop(Socket, State)
%%            catch
%%                _:R ->
%%                    gen_tcp:close(Socket),
%%                    io:format("[ERROR] handle_simulation_tcp error:~p~n", [{get(player_id), R, erlang:get_stacktrace()}])
%%            end;
        {tcp, Socket, Data1} ->
            case handle_tcp_data(Data1, State) of
                {stop, _Reason, _NewState} ->
                    stop;
                NewState when is_record(NewState, state) ->
                    loop(Socket, NewState)
            end;
%%            Buff = get(buff),
%%            case parse_frames(<<Buff/binary,Data1/binary>>) of
%%                close ->
%%                    ?DEBUG("收到关闭协议:~p", [close]),
%%                    {stop, ws_close, State};
%%                {error, Reason} ->
%%                    ?ERROR("parse_frames:~p", [{Reason, erlang:get_stacktrace()}]),
%%                    {stop, Reason, State};
%%                {Rest, <<>>} ->
%%                    {Rest, DataList}
%%            end,
%%            parse_frames(Data1),
%%            try robot_socket:handle_tcp_data(Data1) of
%%                _ ->
%%                    loop(Socket, State)
%%            catch
%%                _:R ->
%%                    gen_tcp:close(Socket),
%%                    io:format("[ERROR] handle_tcp_data error:~p~n", [{get(player_id), R, erlang:get_stacktrace()}])
%%            end;
        {tcp_closed, Socket} ->
            stop;
        gc ->
            erlang:send_after(3 * 60 * 1000, self(), gc),
            erlang:garbage_collect(self()),
            loop(Socket, State);
        socket_heart_beat ->
            robot_socket:socket_heart_beat(),
            loop(Socket, State);
        {heart_beat, PlayerId} ->
%%            ?DEBUG("压测 : 心跳  ~p", [PlayerId]),
            try robot:handle_heart_beat(PlayerId) of
                _ ->
                    Time = get(?ROBOT_DICT_NEXT_HEART_BEAT),
                    if Time > 5 * 60 * 1000 ->
                        io:format("robot_dict_next_heart_beat error:~p~n~n~n", [Time]);
                        true ->
                            noop
                    end,
%%                    ?DEBUG("心跳时间 ： ~p",[Time]),
                    erlang:send_after(Time, self(), {heart_beat, PlayerId}),
                    loop(Socket, State)
            catch
                _:leave ->
                    gen_tcp:close(Socket),
                    leave;
                _:R ->
                    gen_tcp:close(Socket),
                    io:format("[ERROR] handle_heart_beat error:~p~n", [{PlayerId, R, erlang:get_stacktrace()}])
            end;
        stop ->
            gen_tcp:close(Socket),
            ok;
        {timeout, _TimerRef, stop} ->
            gen_tcp:close(Socket),
            ok;
        {check_close, PlayerId} ->
            robot:handle_check_close(PlayerId),
            loop(Socket, State);
        {reset_stop_timer, LiveTime} ->
            robot:reset_stop_timer(LiveTime),
            loop(Socket, State);
        Other ->
            ?DEBUG("robot receive Other: ~w~n", [{get(player_id), Other}]),
            loop(Socket, State)
    end.

%% ----------------------------------
%% @doc 	处理socket 消息
%% @throws 	none
%% @end
%% ----------------------------------
handle_tcp_data(Request, State = #state{buff = Buff, recv_count = RecvCount, error_count = ErrorCount, status = Status}) ->
%%    ?DEBUG("一条消息 ： ~p", [{Buff, Request, RecvCount}]),
    if
        RecvCount == 0 ->
            State#state{recv_count = 1};
        true ->
            case parse_frames(<<Buff/binary, Request/binary>>) of
                close ->
                    ?DEBUG("收到关闭协议:~p", [close]),
                    {stop, ws_close, State};
                {error, Reason} ->
                    ?ERROR("parse_frames:~p", [{Reason, erlang:get_stacktrace()}]),
                    {stop, Reason, State};
                {Rest, DataList} ->
                    State1 = State#state{
                        buff = Rest
                    },
                    RestLen = erlang:byte_size(Rest),
                    if
                        RestLen > 20000 ->
                            ?ERROR("RestLen : ~p", [RestLen]),
                            {stop, {rest_size, RestLen}, State};
                        true ->
                            lists:foldl(
                                fun(Data, TmpSate) ->
                                    case TmpSate of
                                        {stop, _, _} ->
                                            TmpSate;
                                        _ ->
                                            %% ?DEBUG("客户端数据 ： ~p",[Data]),
                                            try robot_socket:handle_tcp_data(Data) of
                                                ok ->
                                                    TmpSate#state{recv_count = RecvCount + 1};
                                                NewState when is_record(NewState, state) ->
                                                    NewState#state{recv_count = RecvCount + 1};
                                                {stop, Reason} ->
                                                    {stop, Reason, TmpSate};
                                                _ ->
                                                    TmpSate#state{recv_count = RecvCount + 1}
                                            catch
                                                _ : {unexpected_proto_num, MsgNum, _Status} ->
                                                    ?ERROR(
                                                        "~n"
                                                        "Router request error :~n"
                                                        "         player : ~p~n"
                                                        "         reason : ~p~n",
                                                        [get(player_id), {unexpected_proto_num, MsgNum, _Status}]),
                                                    TmpSate#state{recv_count = RecvCount + 1, error_count = ErrorCount + 1};
                                                _ : Reason ->
                                                    ?ERROR(
                                                        "~n"
                                                        "Router request error1 :~n"
                                                        "         player : ~p~n"
                                                        "         status : ~p~n"
                                                        "        request : ~p~n"
                                                        "         reason : ~p~n"
                                                        "     stacktrace : ~p~n",
                                                        [get(player_id), Status, Request, Reason, erlang:get_stacktrace()]),
                                                    TmpSate#state{recv_count = RecvCount + 1, error_count = ErrorCount + 1}

                                            end
                                    end
                                end,
                                State1,
                                DataList
                            )
                    end
            end
    end.

parse_frames(Frames) ->
    try parse_frames(Frames, []) of
        {Rest, Parsed} ->
            process_frames_2(Rest, Parsed, [])
    catch
        _:Reason ->
            {error, Reason}
    end.
%%
%% Websockets internal functions for RFC6455 and hybi draft
%%
process_frames_2(Rest, [], Acc) ->
    {Rest, lists:reverse(Acc)};
process_frames_2(Rest, [{Opcode, Payload} | T], Acc) ->
    process_frames_2(Rest, T, [Payload | Acc]).

parse_frames(<<>>, Acc) ->
    {<<>>, lists:reverse(Acc)};
parse_frames(<<_Fin:1,
    _Rsv:3,
    Opcode:4,
    0:1,
    PayloadLen:7,
    Payload:PayloadLen/binary-unit:8,
    Rest/binary>>,
    Acc) when PayloadLen < 126 ->
    parse_frames(Rest, [{Opcode, Payload} | Acc]);
parse_frames(<<_Fin:1,
    _Rsv:3,
    Opcode:4,
    0:1,
    126:7,
    PayloadLen:16,
    Payload:PayloadLen/binary-unit:8,
    Rest/binary>>,
    Acc) ->
    parse_frames(Rest, [{Opcode, Payload} | Acc]);
parse_frames(<<_Fin:1,
    _Rsv:3,
    Opcode:4,
    0:1,
    127:7,
    0:1,
    PayloadLen:63,
    Payload:PayloadLen/binary-unit:8,
    Rest/binary>>,
    Acc) ->
    parse_frames(Rest, [{Opcode, Payload} | Acc]);
parse_frames(Rest, Acc) ->
    {Rest, lists:reverse(Acc)}.