%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(game_app).
-behaviour(application).
%%-include("logger.hrl").
-include("system.hrl").
-include("common.hrl").
-include("server_data.hrl").
-include("socket.hrl").
-include("db_config.hrl").
-include("gen/table_enum.hrl").
-export([
    start/2,
    stop/1,
    profile_output/0
]).
%%%===================================================================
%%% Application callbacks
%%%===================================================================
start(_StartType, _StartArgs) ->
    ssl:start(),
    env:init(),
    inets:start(),
    consider_profiling(),
    {ok, SupPid} = game_sup:start_link(),
    %% 启动日志服务器
    ok = start_child(SupPid, logger),
    ok = start_child(SupPid, logger2),
    %% 初始化本地时间
    util_time:init_offset(),
    %% 性能监控
    ok = start_child(SupPid, prof_srv),

    ?INFO("启动服务器:\n"),

    case env:get(is_center, false) of
        true ->
            mod_server_config:init_server_type(?SERVER_TYPE_CENTER);
        _ ->
            noop
    end,

    IsCenter = mod_server:is_center_server(),
    case IsCenter of
        true ->
            init_db(SupPid),
            init_server(SupPid);
        _ ->
            PingResult = net_adm:ping(mod_server_config:get_center_node()),
            ?INFO("PING 中心服结果:~p~n", [PingResult]),
            init_server(SupPid),
            init_db(SupPid)
    end,

    %% 初始化应用程序
    init_program(SupPid),

    %% 尝试执行合服操作
    merge:action(),
    %% 清理离线操作过期数据
    mod_offline_apply:clean_time(),
    %% 执行版本更新脚本
    version:update(),

    %% 初始化网络
    init_net(SupPid),

    case IsCenter of
        true ->
            noop;
        _ ->
            mod_server:join_center()
    end,

    %% 记录服务器启动时间
    mod_server_data:set_int_data(?SERVER_DATA_SERVER_START_TIME, util_time:timestamp()),

    timer:sleep(1000),
    ?INFO("服务器启动成功!\n"),
    ?INFO(
        "\n[服务器信息]:\n"
        "  类型: ~ts\n"
        "  是否调试: ~p\n"
        "  原子数限制: ~p\n"
        "  进程数限制: ~p\n"
        "  ets限制: ~p\n"
        "  port限制: ~p\n"
        "  socket监听端口: ~p\n"
        "  http监听端口: ~p\n"
        "  数据库地址: ~p\n"
        "  数据库名: ~p\n"
        ,
        [
            mod_server:format_server_type(mod_server_config:get_server_type()),
            ?IS_DEBUG,
            erlang:system_info(atom_limit),
            erlang:system_info(process_limit),
            erlang:system_info(ets_limit),
            erlang:system_info(port_limit),
            mod_server_config:get_tcp_listen_port(),
            mod_server_config:get_web_tcp_listen_port(),
            ?MYSQL_HOST,
            ?MYSQL_DATABASE
        ]),
    tool:gc(1024),
    {ok, SupPid}.

stop(_State) ->
    ok.

consider_profiling() ->
    case env:get(is_profile, false) of
        true ->
            {ok, _Pid} = eprof:start(),
            eprof:start_profiling([self()]);
        false ->
            noop
    end.

profile_output() ->
    eprof:stop_profiling(),
    eprof:log("procs.profile"),
    eprof:analyze(procs),
    eprof:log("total.profile"),
    eprof:analyze(total).

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% ----------------------------------
%% @doc 	初始化数据库
%% @throws 	none
%% @end
%% ----------------------------------
init_db(SupPid) ->
    ?INFO("初始化数据库..."),
    ServerType = mod_server_config:get_server_type(),
    start_child_supervisor(SupPid, mysql_srv),
    ok = db_init:init(),
    ok = db_load:load_power_data(),
    start_child_supervisor(SupPid, db_sup),
    case ServerType of
        ?SERVER_TYPE_CENTER ->
            noop;
        _ ->
            %% 同步 c_game_server 到本服
            mod_server_sync:sync_c_game_server_list(),
            %% 同步 c_server_node 到本服
            mod_server_sync:sync_c_server_node_list()
    end,
    ?INFO("初始化数据库成功!").

%% ----------------------------------
%% @doc 	初始化服务器
%% @throws 	none
%% @end
%% ----------------------------------
init_server(_SupPid) ->
    ?INFO("初始化服务器..."),
    ok = mod_server:init(),
    ?INFO("初始化服务器成功!").

%% ----------------------------------
%% @doc 	初始化应用程序
%% @throws 	none
%% @end
%% ----------------------------------
init_program(SupPid) ->
    ?INFO("初始化应用程序..."),
%%    inets:start(),
    ServerType = mod_server_config:get_server_type(),
    ok = mod_ets:init(),
    ok = start_child(SupPid, server_state_srv),
    ok = start_child(SupPid, reloader),
    ok = start_child(SupPid, timer_srv),
    ok = start_child(SupPid, game_worker),
    ok = start_child(SupPid, server_node_slave),
%%    ok = null_worker(SupPid),
    case ServerType of
        %%中心节点
        ?SERVER_TYPE_CENTER ->
            {ok, _} = application:ensure_all_started(cowboy),
            ok = start_child(SupPid, server_node_master),
            ok = start_child(SupPid, global_account_srv),
            ok = start_child(SupPid, promote_srv),
            ok = start_child(SupPid, gift_code_srv),
            spawn(fun() -> ?INFO("get versions & firstversions from admin"), handle_update_version:getData() end),
            spawn(fun() -> ?INFO("get test account from admin"), handle_update_version:updateTestAccount() end),
            spawn(fun() -> ?INFO("get client verify from admin"),
                handle_update_version:updateClientHeartbeatVerify() end),
            spawn(fun() -> ?INFO("get static resource from admin"), handle_static_resource:getData() end),
            spawn(fun() -> ?INFO("get app notice from admin"), mod_app_notice:get_app_notice() end),
            spawn(fun() -> ?INFO("get tracker token from admin"), mod_adjust_info:get_all_tracker_token() end),
            spawn(fun() -> ?INFO("get area code from admin"), mod_area_info:get_area_code() end),
            ok = start_center_web_router(),
            spawn(fun() -> ?INFO("get customer service url from remote server"), mod_customer:updateCusSerData() end);
        %%登录服
        ?SERVER_TYPE_LOGIN_SERVER ->
            {ok, _} = application:ensure_all_started(cowboy),
            ok = start_login_web_router();
        %%web服
        ?SERVER_TYPE_WEB ->
            {ok, _} = application:ensure_all_started(cowboy),
            ok = start_child(SupPid, djs_data_srv),
            ok = start_web_router();
        %%游戏服
        ?SERVER_TYPE_GAME ->
            {ok, _} = application:ensure_all_started(cowboy),
            ok = mod_game:init(),
            ok = start_child(SupPid, scene_master),
            ok = start_child(SupPid, scene_adjust_srv),
            ok = start_child(SupPid, mail_srv),
            ok = start_child(SupPid, activity_srv),
            ok = start_child(SupPid, match_scene_srv),
            ok = start_child(SupPid, match_scene_room_srv),
            % 自动更新ip
%%            ok = ip_srv(SupPid),
%%            ok = mod_mission_world_boss:init_activity_world_boss(),
            spawn(fun() -> ?INFO("get player pay times limit from adming"),
                handle_update_version:getPlayerPayTimesLimit() end),
            ok = game_web_router(),
%%            spawn(fun() -> ?INFO("get props_trader token"), props_trader:login() end),
            ok = start_child(SupPid, laba_srv);
        %%跨服
        ?SERVER_TYPE_WAR_ZONE ->
            ok = start_child(SupPid, zone_srv),
            ok = start_child(SupPid, activity_srv),
            ok = start_child(SupPid, scene_master);
        %% 唯一id服务器
        ?SERVER_TYPE_UNIQUE_ID ->
            ok = start_child(SupPid, unique_id_srv);
        ?SERVER_TYPE_CHARGE ->      % 充值上报服
            {ok, _} = application:ensure_all_started(cowboy),
            ok = charge_web_router();
        ?SERVER_TYPE_WAR_AREA ->      % 战区服
            ok = start_child(SupPid, war_srv),
            ok = start_child(SupPid, activity_srv),
            ok = start_child(SupPid, scene_master),
%%            ok = activity_rank_srv(SupPid),
%%            ok = activity_turn_msg_srv(SupPid),
            ok = start_child(SupPid, many_people_boss_srv),
            ok = start_child(SupPid, chat_srv),
            ok = mod_mission_guess_boss:open_mission(),
            ok = mod_mission_shi_shi:open_mission(),
            ok = start_child(SupPid, shi_shi_room_srv),
            ok = start_child(SupPid, brave_one_srv),
            ok = start_child(SupPid, robot_srv),
            ok = start_child(SupPid, match_scene_srv),
            ok = start_child(SupPid, match_scene_room_srv),
            ok = start_child(SupPid, one_vs_one_srv),
            ok = start_child(SupPid, player_chat_srv),
            ok = start_child(SupPid, wheel_srv),
            ok = start_child(SupPid, room_manage_srv),
            ok = start_child_supervisor(SupPid, room_sup)
    end,
    ?INFO("初始化应用程序成功!"),
    ServerType.

%% ----------------------------------
%% @doc 	初始化网络
%% @throws 	none
%% @end
%% ----------------------------------
init_net(SupPid) ->
    ServerType = mod_server_config:get_server_type(),
    case ServerType of
        ?SERVER_TYPE_GAME ->             %%游戏节点
            ?INFO("初始化网络..."),
            start_child_supervisor(SupPid, client_worker_sup),
            start_child_supervisor(SupPid, acceptor_sup),
            ?INFO("初始化网络成功!");
        _ ->
            noop
    end.


-spec start_child_supervisor(SupPid, Child) -> term() when
    SupPid :: node(),
    Child :: module().

start_child_supervisor(SupPid, Child) ->
    ChildSpec = {
        Child,
        {Child, start_link, []},
        permanent,
        infinity,
        supervisor,
        [Child]
    },
    {ok, _} = supervisor:start_child(SupPid, ChildSpec),
    ok.


-spec start_child(SupPid, Child) -> term() when
    SupPid :: node(),
    Child :: module().

start_child(SupPid, Child) ->
    ChildSpec = {
        Child,
        {Child, start_link, []},
        permanent,
        6000,
        worker,
        [Child]
    },
    {ok, _} = supervisor:start_child(SupPid, ChildSpec),
    ok.

%%
%%%% ----------------------------------
%%%% @doc 	中心服 web 路由
%%%% @throws 	none
%%%% @end
%%%% ----------------------------------
start_center_web_router() ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/set_login_notice", handle_set_login_notice, []}, % 登录公告
            {"/set_disable", handle_set_disable, []},           % 封禁
            {"/version", handle_version, []},
            {"/update_version", handle_update_version, []},     % 后台更新中心服ets中的versions与firstversions数据用
            {"/test_account/add", handle_update_version, []},   % 后台添加测试账号用(横板测试服才有用)
            {"/upgrade", handle_upgrade, []},
            {"/static_resource", handle_static_resource, []},
            {"/update_static_resource", handle_static_resource, []},
            {"/oauth/platform", game_http_oauth_handler, []},
            {"/oauth/authorize", game_http_oauth_handler, []},
            {"/oauth/signin", game_http_oauth_handler, []},
            {"/oauth/token", game_http_oauth_handler, []},
            {"/player/characters", game_http_oauth_handler, []},
            {"/character/[:id]/items", game_http_oauth_handler, []},
%%            {"/item/[:id]/modify", game_http_oauth_handler, []}
            {"/item/[:id]/modify", game_http_oauth_handler, []},
            {"/level/limitation", game_http_oauth_handler, []},
            {"/game_server/list", handle_game_server_list, []},
            {"/customer_service/update_login_page_url", handle_update_version, []},
            {"/set_game_config", handle_game_config, []},
            %% 礼包码
            {"/add_gift_code", handle_http_gift_code, []},
            {"/append_gift_code", handle_http_gift_code, []},
            {"/delete_gift_code", handle_http_gift_code, []},
            {"/heartbeat_verify/setting", handle_update_version, []},
            %% app登录公告
            {"/set_app_notice", handle_app_notice, []},
            {"/app_notice", handle_app_notice, []},
            {"/domain", handle_filter, []},
            {"/set_platform_tracker_token", handle_platform_info, []},
            {"/set_area_code", handle_area_code, []}
        ]}
    ]),
    Result = cowboy:start_clear(http, [{port, env:get(center_web_port, ?CENTER_DEFAULT_HTTP_PORT)}], #{
        env => #{dispatch => Dispatch}
    }),
    case Result of
        {ok, _} ->
            ok;
        {error, {already_started, _}} ->
            ok;
        _ ->
            exit(Result)
    end,
    ok.

%% ----------------------------------
%% @doc 	登录 web 路由
%% @throws 	none
%% @end
%% ----------------------------------
start_login_web_router() ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/login", handle_login, []},
            {"/all", handle_all, []},
            {"/refresh", handle_refresh, []},
            {"/set_login_notice", handle_set_login_notice, []},
            {"/get_env", handle_login_server_env, []},
            {"/set_env", handle_login_server_env, []}
        ]}
    ]),
    Port = mod_server_config:get_web_tcp_listen_port(),
    ?ASSERT(Port > 0, web_port_no_config),
    Result =
        cowboy:start_clear(http, [
            {port, Port},
            {num_acceptors, 200},
            {backlog, 2048},
            {send_timeout, 15000}
        ], #{
            env => #{dispatch => Dispatch}
        }),
%%        if
%%            ?SOCKET_MOD == gen_tcp ->
%%                cowboy:start_clear(http, [
%%                    {port, Port},
%%                    {num_acceptors, 200},
%%                    {backlog, 2048},
%%                    {send_timeout, 15000}
%%                ], #{
%%                    env => #{dispatch => Dispatch}
%%                });
%%            true ->
%%                cowboy:start_tls(https, [
%%                    {port, Port},
%%                    {cacertfile, ?SSL_CACERTFILE},
%%                    {certfile, ?SSL_CERTFILE},
%%                    {keyfile, ?SSL_KEYFILE},
%%                    {num_acceptors, 200},
%%                    {backlog, 2048},
%%                    {send_timeout, 15000}
%%                ], #{
%%                    env => #{dispatch => Dispatch}
%%                })
%%        end,

    case Result of
        {ok, _} ->
            ok;
        {error, {already_started, _}} ->
            ok;
        _ ->
            exit(Result)
    end,
    ok.

%% 自动更新谷歌支付订单是否退款
%%google_order_srv(SupPid) ->
%%    ChildSpec = {
%%        chk_google_order_srv,
%%        {chk_google_order_srv, start_link, []},
%%        permanent,
%%        infinity,
%%        worker,
%%        [chk_google_order_srv]
%%    },
%%    {ok, _} = supervisor:start_child(SupPid, ChildSpec),
%%    ok.

%% @fun djs数据处理进程
djs_data_srv(SupPid) ->
    ChildSpec = {
        djs_data_srv,
        {djs_data_srv, start_link, []},
        permanent,
        infinity,
        worker,
        [djs_data_srv]
    },
    {ok, _} = supervisor:start_child(SupPid, ChildSpec),
    ok.

%% @fun 游戏服web 路由
game_web_router() ->
    Port = mod_server_config:get_web_tcp_listen_port(),
    ?ASSERT(Port > 0, web_port_no_config),
    Dispatch = cowboy_router:compile([{'_', [
        {'_', game_http_charge_handler, []}
    ]}]),
    Result = cowboy:start_clear(game_web_listener, [{port, Port}], #{
        env => #{dispatch => Dispatch}}),
    case Result of
        {ok, _} ->
            ok;
        {error, {already_started, _}} ->
            ok;
        _ ->
            exit(Result)
    end,
    ok.

%% @fun 充值服web 路由
charge_web_router() ->
    Port1 = mod_server_config:get_web_tcp_listen_port(),
    Port = ?IF(is_integer(Port1) andalso Port1 > 0, Port1, 9993),
    Dispatch = cowboy_router:compile([{'_', [
        {"/charge_props_trader", props_trader_handle, []},
        {'_', server_http_charge_handler, []}
    ]}]),
%%    Result = cowboy:start_clear(charge_listener, [{port, Port}, {max_connections, 1000}], #{
    Result = cowboy:start_clear(charge_listener, [{port, Port}], #{
        env => #{dispatch => Dispatch}}),
    case Result of
        {ok, _} ->
            ok;
        {error, {already_started, _}} ->
            ok;
        _ ->
            exit(Result)
    end,
    ok.


%% ----------------------------------
%% @doc 	web 路由
%% @throws 	none
%% @end
%% ----------------------------------
start_web_router() ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {'_', web_http_handler, []}
        ]}
    ]),
    Port = mod_server_config:get_web_tcp_listen_port(),
    ?ASSERT(Port > 0, web_port_no_config),
    Result =
        cowboy:start_clear(http, [
            {port, Port},
            {num_acceptors, 200},
            {backlog, 2048},
            {send_timeout, 15000}
        ], #{
            env => #{dispatch => Dispatch}
        }),

    case Result of
        {ok, _} ->
            ok;
        {error, {already_started, _}} ->
            ok;
        _ ->
            exit(Result)
    end,
    ok.

