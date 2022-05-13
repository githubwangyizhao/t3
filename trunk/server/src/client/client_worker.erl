%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(client_worker).
-include("common.hrl").
-include("system.hrl").
-include("socket.hrl").
-include("client.hrl").

%% API
-export([
    start_link/2,
    get_player_id/0,        %% 获取玩家id
    apply/4,                %% 玩家进程执行
    apply/5,
    send_msg/2,             %% 发送消息给玩家进程
    send_msg/3,
    is_client_worker/0,
    kill_sync/3,            %% 同步杀死玩家进程
    kill_async/2,            %% 异步杀死玩家进程
    notify_to_client_worker/2   %% 推送消息给玩家进程
]).

%% CALLBACK
-export([
    init/2,                 %%
    handle_heart_beat/1,    %% 处理心跳
    clean_up/1,
    clean_up/2              %% 清理数据
]).

%%%===================================================================
%%% API
%%%===================================================================
start_link(SocketMod, Socket) ->
    proc_lib:start_link(?MODULE, init, [SocketMod, Socket]).

init(SocketMod, Socket) ->
    ?INFO("玩家进程启动:~p", [{SocketMod, self()}]),
    proc_lib:init_ack({ok, self()}),
    receive
        {go, Socket} ->
            noop
    end,
    case SocketMod of
        gen_tcp ->
            noop;
%%            mod_server:check_socket_connect(IP);
        ssl ->
            case ssl:ssl_accept(Socket, 10000) of
                ok ->
                    noop;
%%                    mod_server:check_socket_connect(IP);
                Error ->
                    ?ERROR("ssl_accept_error:~p", [Error]),
                    ssl:close(Socket),
                    exit({ssl_accept_error, Error})
            end
    end,
    ?INIT_PROCESS_TYPE(?PROCESS_TYPE_CLIENT_WORKER),
    case ?IS_DEBUG of
        true ->
        register(util:to_atom("client_" ++ erlang:ref_to_list(erlang:make_ref())), self());
        _ ->
            noop
    end,
%%    register(util:to_atom("client_" ++ erlang:ref_to_list(erlang:make_ref())), self()),

    Self = self(),
    SenderWorker = spawn(fun() -> client_sender_worker:start(SocketMod, Socket, Self) end),
    erlang:monitor(process, SenderWorker),

    {IP, _Port} = util_socket:get_peer_info(SocketMod, Socket),
    put(sender_worker, SenderWorker),
    put(?DICT_PLAYER_LOGIN_IP, IP),

    State = #conn{
        ip = IP,
        socket = Socket,
        sender_worker = SenderWorker,
        status = ?CLIENT_STATE_WAIT_AUTH,
        create_time = util_time:timestamp(),
        socket_mod = SocketMod
    },

%%    receive
%%        {go, Socket} ->
    client_socket_handle:handle_ws_handshake(SocketMod, Socket, IP),
    case SocketMod of
        gen_tcp ->
            inet:setopts(Socket, ?TCP_OPTIONS);
        ssl ->
            ssl:setopts(Socket, ?SSL_TCP_OPTIONS)
    end,
%%    end,
    trigger_heart_beat(),
    ?INFO("(~p)玩家进程(~p)启动成功", [{IP, SocketMod}, self()]),
    Parent = whereis(client_worker_sup),
    process_flag(trap_exit, true),
    client_worker_loop:main_loop(Parent, State, Socket, SenderWorker).


%% ----------------------------------
%% @doc 	是否玩家进程
%% @throws 	none
%% @end
%% ----------------------------------
is_client_worker() ->
    ?PROCESS_TYPE == ?PROCESS_TYPE_CLIENT_WORKER.


%% ----------------------------------
%% @doc 	apply
%% @throws 	none
%% @end
%% ----------------------------------
-spec apply(Worker, M, F, A) -> term() when
    Worker :: pid(),
    M :: module(),
    F :: atom(),
    A :: [term()].

apply(null, _M, _F, _A) ->
    noop;
apply(Worker, M, F, A) when is_pid(Worker) ->
    Worker ! {apply, M, F, A}.

-spec apply(Worker, M, F, A, Delay) -> term() when
    Worker :: pid(),
    M :: module(),
    F :: atom(),
    A :: [term()],
    Delay :: integer().

apply(null, _, _, _, _) ->
    noop;
apply(Worker, M, F, A, 0) when is_pid(Worker) ->
    Worker ! {apply, M, F, A};
apply(Worker, M, F, A, Delay) when is_pid(Worker) ->
    erlang:send_after(Delay, Worker, {apply, M, F, A}).


%% ----------------------------------
%% @doc 	发送消息到玩家进程
%% @throws 	none
%% @end
%% ----------------------------------
send_msg(PlayerId, Msg) when is_integer(PlayerId) ->
    case mod_obj_player:get_obj_player(PlayerId) of
        null ->
            noop;
        R ->
            R#ets_obj_player.client_worker ! pack_msg(Msg)
    end;
send_msg(null, _Msg) ->
    noop;
send_msg(Worker, Msg) ->
    Worker ! pack_msg(Msg).

send_msg(null, _Msg, _) ->
    noop;
send_msg(Worker, Msg, 0) when is_pid(Worker) ->
    Worker ! pack_msg(Msg);
send_msg(Worker, Msg, Time) when is_pid(Worker) andalso Time > 0 ->
    erlang:send_after(Time, Worker, pack_msg(Msg)).

pack_msg(Msg) ->
    {msg, Msg}.

notify_to_client_worker(ClientWorker, {_Mod, _Info} = Request) when is_pid(ClientWorker) ->
    ClientWorker ! {notify, Request}.

%% ----------------------------------
%% @doc 	kill 玩家进程
%% @throws 	none
%% @end
%% ----------------------------------
kill_sync(ClientWorker, TimeOut, Reason) ->
    Ref = make_ref(),
    ClientWorker ! {kill, Reason, self(), Ref},
    receive
        {ok, Ref} ->
            ok
    after TimeOut ->
        ?ERROR("kill玩家进程超时:~p,~p,~p", [node(), util_time:local_date(),{ ClientWorker, TimeOut, Reason,erlang:process_info(ClientWorker)}]),
        timeout
    end.

kill_async(ClientWorker, Reason) ->
    ClientWorker ! {kill, Reason}.


%% ----------------------------------
%% @doc 	清理
%% @throws 	none
%% @end
%% ----------------------------------
clean_up(Conn) ->
    clean_up(Conn, ?CSR_SYSTEM_MAINTENANCE).
clean_up(#conn{socket = Socket, status = ?CLIENT_STATE_ENTER_GAME, sender_worker = SenderWorker, socket_mod = SocketMod} = State, Reason) ->
    ?INFO("clean_up(~p): ~p", [self(), [{reason, Reason}]]),
%%    timer:sleep(10000),
    ?TRY_CATCH(mod_game:leave_game(State, Reason)),
    SocketMod:close(Socket),
    erlang:exit(SenderWorker, kill),
    ok;
clean_up(#conn{socket = Socket, sender_worker = SenderWorker, player_id = PlayerId, status = Status, socket_mod = SocketMod}, Reason) ->
    ?INFO("clean_up_2(~p):~p", [self(), [{reason, Reason,Status}]]),
    if erlang:is_integer(PlayerId) andalso PlayerId > 0 ->
        %% 释放数据库数据
        ?TRY_CATCH(db_load:safe_unload_hot_data(PlayerId));
        true ->
            noop
    end,
    SocketMod:close(Socket),
    erlang:exit(SenderWorker, kill),
    ok.

get_player_id() ->
    get(?DICT_PLAYER_ID).

%% ----------------------------------
%% @doc 	心跳处理
%% @throws 	none
%% @end
%% ----------------------------------
trigger_heart_beat() ->
    erlang:send_after(?HEART_BEAT_TIME, self(), heart_beat).

handle_heart_beat(#conn{recv_count = RecvCount, error_count = _ErrorCount, status = Status} = State) ->
%%    ?DEBUG("heart beat:~p", [{ErrorCount, RecvCount, ?MAX_PACK}]),
    if
        ?CLIENT_STATE_WAIT_AUTH == Status ->
            %% 还未验证则关闭进程
            {stop, ?CSR_AUTH_TIME_OUT, State};
        true ->
            if
%%                ErrorCount >= ?MAX_ERROR_PACK ->
%%                    ?INFO("Max error pack:~p", [State]),
%%                    {stop, ?CSR_MAX_ERROR, State};
                RecvCount == 0 ->
                    %% 超时
                    ?ERROR("Time out:~p", [State]),
                    {stop, ?CSR_HEART_BEAT_TIME_OUT, State};
                RecvCount >= ?MAX_PACK ->
                    %% 发包过多
                    ?ERROR("Max pack:~p", [State]),
                    {stop, ?CSR_MAX_PACK, State};
                true ->
                    if RecvCount > 200 ->
                        ?INFO("RecvCount:~p", [RecvCount]);
                    true->
                        noop
                    end,
                    trigger_heart_beat(),
                    State#conn{recv_count = 0}
            end
    end.
