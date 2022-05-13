%%% 运行时 请勿修改 ！！！！！


%%-define(SOCKET_MOD, env:get(tcp_mode, gen_tcp)). %% gen_tcp  ssl
-define(TCP_ACCEPT_COUNT, util:to_int(env:get(tcp_accept_count))).
%%-define(TCP_LISTEN_PORT, util:to_int(env:get(tcp_listen_port))).
-define(MAX_CLIENT_COUNT, util:to_int(env:get(max_client_count, 10000))).
-define(ACTIVE_COUNT, 300).

%%-ifdef(debug).
%%-define(SOCKET_MOD, gen_tcp). %% gen_tcp  ssl
%%-else.
%%-define(SOCKET_MOD, ssl). %% gen_tcp  ssl
%%-endif.
%%-define(SOCKET_MOD, env:get(tcp_mode, ssl)). %% gen_tcp  ssl
%%-define(SOCKET_MOD, case get(tcp_mode) of undefined -> _TCP_MODE_ = env:get(tcp_mode, ssl), put(tcp_mode, _TCP_MODE_), _TCP_MODE_; _TCP_MODE_ -> _TCP_MODE_ end). %% gen_tcp  ssl


-define(LISTEN_TCP_OPTIONS,
    [
        binary,
        {packet, 0},
        {reuseaddr, true},
        {backlog, 1024},
        {active, false}
    ]
).

%% ssl 证书
-define(SSL_CACERTFILE, env:get(cacertfile, "cacert.pem")).
-define(SSL_CERTFILE, env:get(certfile, "cert.pem")).
-define(SSL_KEYFILE, env:get(keyfile, "key.pem")).

-define(LISTEN_SSL_OPTIONS,
    [
        binary,
        {packet, 0},
        {reuseaddr, true},
        {backlog, 1024},
        {active, false},
        {certfile, ?SSL_CERTFILE},
        {keyfile, ?SSL_KEYFILE},
        {cacertfile, ?SSL_CACERTFILE}
    ]
).



-define(SSL_TCP_OPTIONS,
    [
        binary,
        {packet, 0},
        {packet_size, 1024},
        {active, once},
        {nodelay, false}, %% 关闭nagle算法
        {send_timeout, 3000},
        {send_timeout_close, true},
%%        {exit_on_close, true},
        {delay_send, true}
%%        {sndbuf, 16 * 1024},
%%        {recbuf, 16 * 1024},
%%        {high_watermark, 128 * 1024},
%%        {low_watermark, 64 * 1024}
    ]
).
-define(TCP_OPTIONS,
    [
        binary,
        {packet, 0},
        {packet_size, 1024},
        {active, 200},
        {nodelay, false}, %% 关闭nagle算法
        {send_timeout, 3000},
        {send_timeout_close, true},
%%        {exit_on_close, true},
        {delay_send, true}
%%        {sndbuf, 16 * 1024},
%%        {recbuf, 16 * 1024},
%%        {high_watermark, 128 * 1024},
%%        {low_watermark, 64 * 1024}
    ]
).
