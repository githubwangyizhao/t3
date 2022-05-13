%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            玩家进程主循环
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(client_worker_loop).
%% API
-export([
    main_loop/4
]).
-include("logger.hrl").
-include("record.hrl").

main_loop(Parent, State, Socket, SenderWorker) ->
    receive
        {tcp_passive, Socket} ->
            inet:setopts(Socket, [{active, 200}]),
            main_loop(Parent, State, Socket, SenderWorker);
        {tcp, Socket, Request} ->
%%            io:format("ffff~n"),
%%            ok = inet:setopts(Socket, [{active, once}]),
%%            Len = erlang:byte_size(Request),
%%            if
%%                Len > 100 ->
%%                    %% 模拟 半包
%%                    <<A:8/binary, B/binary>> = Request,
%%                    NewState =
%%                        lists:foldl(
%%                            fun(Bin, TmpState) ->
%%                                case TmpState of
%%                                    {stop, _, _} ->
%%                                        TmpState;
%%                                    _ ->
%%                                        client_socket_handle:handle_tcp_data(Bin, TmpState)
%%                                end
%%                            end,
%%                            State,
%%                            [A, B]
%%                        ),
%%                    case NewState of
%%                        {stop, Reason, _} ->
%%                            client_worker:clean_up(NewState, Reason);
%%                        _ ->
%%                            main_loop(NewState, Socket, SenderWorker)
%%                    end;
%%                true ->
            case client_socket_handle:handle_tcp_data(Request, State) of
                {stop, Reason, NewState} ->
                    client_worker:clean_up(NewState, Reason);
                NewState ->
                    main_loop(Parent, NewState, Socket, SenderWorker)
            end;
%%            end;
        {ssl, Socket, Request} ->
            ok = ssl:setopts(Socket, [{active, once}]),
%%            Len = erlang:byte_size(Request),
%%            if
%%                Len > 100 ->
%%                    %% 模拟 半包
%%                    <<A:8/binary, B/binary>> = Request,
%%                    NewState =
%%                        lists:foldl(
%%                            fun(Bin, TmpState) ->
%%                                case TmpState of
%%                                    {stop, _, _} ->
%%                                        TmpState;
%%                                    _ ->
%%                                        client_socket_handle:handle_tcp_data(Bin, TmpState)
%%                                end
%%                            end,
%%                            State,
%%                            [A, B]
%%                        ),
%%                    case NewState of
%%                        {stop, Reason, _} ->
%%                            client_worker:clean_up(NewState, Reason);
%%                        _ ->
%%                            main_loop(NewState, Socket, SenderWorker)
%%                    end;
%%                true ->
            case client_socket_handle:handle_tcp_data(Request, State) of
                {stop, Reason, NewState} ->
                    client_worker:clean_up(NewState, Reason);
                NewState ->
                    main_loop(Parent, NewState, Socket, SenderWorker)
            end;
%%            end;
        {msg, Msg} ->
            try client_msg_handle:handle(Msg, State)
            catch
                _:Reason ->
                    ?ERROR("handle msg error:~p~n msg:~p~n~p", [Reason, Msg, erlang:get_stacktrace()])
            end,
            main_loop(Parent, State, Socket, SenderWorker);
        {msg_timer, Msg} ->
            try client_msg_handle:msg_timer(Msg, State)
            catch
                _:Reason ->
                    ?ERROR("handle msg_timer error:~p~n msg_timer:~p~n~p", [Reason, Msg, erlang:get_stacktrace()])
            end,
            main_loop(Parent, State, Socket, SenderWorker);
        {timeout, TimerRef, {timeout, TimerId}} ->
            try client_worker_timer:handle_timeout(TimerRef, TimerId)
            catch
                _:Reason ->
                    ?ERROR("handle client_worker_timer error:~p~n timer_id:~p~n~p", [Reason, TimerId, erlang:get_stacktrace()])
            end,
            main_loop(Parent, State, Socket, SenderWorker);
        {timeout, TimerRef, {module_timer, {Mod, Info} = Msg}} ->
            try Mod:on_client_worker_info(Info, TimerRef, State) of
                _ -> ok
            catch
                T:E ->
                    ?ERROR("T:~p, E:~p, Stackrace:~p", [T, E, erlang:get_stacktrace()]),
                    ?ERROR("module_timer ===> PlayerId: ~p, Msg:~p, TimerRef:~p", [State#conn.player_id, Msg, TimerRef])
            end,
            main_loop(Parent, State, Socket, SenderWorker);
        {notify, {Mod, Info} = Msg} ->
            try Mod:on_client_worker_info(Info, State) of
                _ -> ok
            catch
                T:E ->
                    ?ERROR("T:~p, E:~p, Stackrace:~p", [T, E, erlang:get_stacktrace()]),
                    ?ERROR("notify ===> PlayerId: ~p, Msg:~p", [State#conn.player_id, Msg])
            end,
            main_loop(Parent, State, Socket, SenderWorker);
        {tcp_closed, Socket} ->
            client_worker:clean_up(State, tcp_closed);
        {ssl_closed, Socket} ->
            client_worker:clean_up(State, ssl_closed);
        {tcp_error, Socket, Reason} ->
            client_worker:clean_up(State, {tcp_error, Reason});
        {ssl_error, Socket, Reason} ->
            client_worker:clean_up(State, {ssl_error, Reason});
        heart_beat ->
            case client_worker:handle_heart_beat(State) of
                {stop, Reason, NewState} ->
                    client_worker:clean_up(NewState, Reason);
                NewState ->
                    main_loop(Parent, NewState, Socket, SenderWorker)
            end;
        {apply, M, F, A} ->
            %% 异步执行
%%            ?DEBUG("玩家进程调用 mod:~p， function:~p, args:~p", [M, F, A]),
            util:catch_apply(M, F, A),
            main_loop(Parent, State, Socket, SenderWorker);
        {kill, Reason, From, Ref} ->
            client_worker:clean_up(State, Reason),
            From ! {ok, Ref};
        {kill, Reason} ->
            client_worker:clean_up(State, Reason);
        {'EXIT', Parent, Reason} ->
            %% 系统关闭
            ?INFO("client woreker trap parent exit: ~p", [Reason]),
            client_worker:clean_up(State, {trap_parent_exit, Reason});
%%        {'DOWN', _Ref, process, SenderWorker, Reason} ->
%%            ?ERROR("sender exit reason: ~p", [Reason]),
%%            client_worker:clean_up(State, sender_exit);
        {'DOWN', _Ref, process, _, Reason} ->
            ?INFO("client worker trap down: ~p", [Reason]),
            client_worker:clean_up(State, Reason);
        Other ->
            ?ERROR("client_loop_unexpected_msg: ~p", [{Parent, Other}]),
            main_loop(Parent, State, Socket, SenderWorker)
    end.