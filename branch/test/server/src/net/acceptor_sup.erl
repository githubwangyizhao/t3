%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(acceptor_sup).

-behaviour(supervisor).
-include("logger.hrl").
-include("socket.hrl").
-include("gen/table_enum.hrl").
%% API
-export([
    start_link/0
]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).
init([]) ->
    TcpListenPort = mod_server_config:get_tcp_listen_port(),
    SockConfigList =
    case mod_server_config:get_platform_id() of
%%        ?PLATFORM_DJS ->
%%            [{ssl, TcpListenPort},{gen_tcp, TcpListenPort + 10000}];
%%        ?PLATFORM_OPPO ->
%%            [{gen_tcp, TcpListenPort}];
%%%%        ?PLATFORM_H56873 ->
%%%%            [{ssl, TcpListenPort}, {gen_tcp, TcpListenPort + 10000}];
%%        ?PLATFORM_LOCAL->
%%            [{ssl, TcpListenPort}, {gen_tcp, TcpListenPort + 10000}];
%%        ?PLATFORM_TEST->
%%            [{ssl, TcpListenPort}, {gen_tcp, TcpListenPort + 10000}];
%%        ?PLATFORM_VM->
%%            [{ssl, TcpListenPort}, {gen_tcp, TcpListenPort + 10000}];
%%        ?PLATFORM_QUICK->
%%            [{ssl, TcpListenPort}, {gen_tcp, TcpListenPort + 10000}];
%%        ?PLATFORM_GAT->
%%            [{ssl, TcpListenPort}, {gen_tcp, TcpListenPort + 10000}];
%%        ?PLATFORM_MOY->
%%            [{ssl, TcpListenPort}, {gen_tcp, TcpListenPort + 10000}];
        _ ->
            [{gen_tcp, TcpListenPort}, {ssl, TcpListenPort + 10000}]
    end,
    ?INFO("端口列表SockConfigList:~p~n", [SockConfigList]),
%%        lists:map(
%%            fun(Proto) ->
%%                case Proto of
%%                    ws ->
%%                        {gen_tcp, TcpListenPort};
%%                    wss ->
%%                        {ssl, TcpListenPort + 10000};
%%                    Other ->
%%                        ?ERROR("unknow_socket_proto:~p", [Other]),
%%                        exit({unknow_socket_proto, Other})
%%                end
%%            end,
%%            lists:usort(?SOCKET_PROTOS)
%%        ),
    try get_child_spec_list(SockConfigList, []) of
        {ok, ChildSpecList} ->
            SupFlags = {one_for_one, 10, 10},
            {ok, {SupFlags, ChildSpecList}}
    catch
        _:Reason ->
            ?ERROR(
                "listen_error: ~p~n"
                "    ~s", [{Reason, TcpListenPort}, inet:format_error(Reason)]),
            {stop, {listen_error, Reason}}
    end.

get_child_spec_list([], TmpChildSpecList) ->
    {ok, TmpChildSpecList};
get_child_spec_list([{SockMod, TcpListenPort} | Left], TmpChildSpecList) ->
    Options = case SockMod of
                  gen_tcp ->
                      ?LISTEN_TCP_OPTIONS;
                  ssl ->
                      ?LISTEN_SSL_OPTIONS
              end,
    case SockMod:listen(TcpListenPort, Options) of
        {ok, LSocket} ->
            ?INFO("监听端口:~p", [{SockMod, TcpListenPort}]),
            ChildSpecList =
                lists:foldl(
                    fun(Id, L) ->
                        Name = list_to_atom(lists:concat([SockMod, "_acceptor_", Id])),
                        T = {Name,
                            {acceptor, start_link, [SockMod, LSocket]},
                            permanent,
                            infinity,
                            worker,
                            [acceptor]},
                        [T | L]
                    end,
                    [],
                    lists:seq(1, ?TCP_ACCEPT_COUNT)
                ),
            get_child_spec_list(Left, ChildSpecList ++ TmpChildSpecList);
        {error, Reason} ->
            ?ERROR("监听端口失败:~p", [{SockMod, TcpListenPort, Reason}]),
            throw(Reason)
    end.
%%init([]) ->
%%    TcpListenPort = mod_server_config:get_tcp_listen_port(),
%%    Options = case ?SOCKET_MOD of
%%                  gen_tcp ->
%%                      ?LISTEN_TCP_OPTIONS;
%%                  ssl ->
%%                      ?LISTEN_SSL_OPTIONS
%%              end,
%%    PlatformId = mod_server_config:get_platform_id(),
%%    RealTcpListenPort = case ?SOCKET_MOD of
%%                            gen_tcp ->
%%                                %% 默认走wss， 如果走ws， 则端口+10000(wss 由程序实现， ws 由nginx 代理转发)
%%                                if PlatformId == ?PLATFORM_OPPO ->
%%                                    TcpListenPort;
%%                                    true ->
%%                                TcpListenPort + 10000
%%                                end;
%%                            ssl ->
%%                                TcpListenPort
%%                        end,
%%    case ?SOCKET_MOD:listen(RealTcpListenPort, Options) of
%%        {ok, LSocket} ->
%%            {LIPAddress, LPort} = util_socket:get_sock_info(SocketMod, LSocket),
%%            ?INFO("监听端口:~p", [{LIPAddress, LPort}]),
%%            SupFlags = {one_for_one, 10, 10},
%%            ChildSpecList =
%%                lists:foldl(
%%                    fun(Id, L) ->
%%                        Name = list_to_atom(lists:concat(["socket_acceptor_", Id])),
%%                        T = {Name,
%%                            {acceptor, start_link, [LSocket]},
%%                            permanent,
%%                            infinity,
%%                            worker,
%%                            [acceptor]},
%%                        [T | L]
%%                    end,
%%                    [],
%%                    lists:seq(1, ?TCP_ACCEPT_COUNT)
%%                ),
%%            {ok, {SupFlags, ChildSpecList}};
%%        {error, Reason} ->
%%            ?ERROR(
%%                "listen_error: ~p~n"
%%                "    ~s", [{Reason, TcpListenPort}, inet:format_error(Reason)]),
%%            {stop, {listen_error, Reason}}
%%    end.
%%
