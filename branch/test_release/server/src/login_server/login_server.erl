-module(login_server).
-include("gen/db.hrl").
-include("common.hrl").
-include("system.hrl").
-include("error.hrl").
-include("gen/table_enum.hrl").
%% API
-export([
    is_domain/1,
%%    update_recent_server_list/3,
%%    get_recent_server_list/2,
%%    init/0,
%%    add_login_cache/2,
%%    login/2,
%%    login_with_salt/2,

%%    get_real_platform_id/1,
    get_new_server_id/1,
%%    get_old_server_id/1,
    pack_server_list/2,
    pack_server_list/3,
    get_all_server_list/2,          % 获取所有服务器列表
    get_all_server_list/3,          % 获取所有服务器列表
%%    set_account_type/3,
%%    is_inner_account/2,
    create_login_ticket/2,
    valid_login_ticket/3
]).

%%init() ->
%%    noop.

%%login(Account, LoginTicket) ->
%%    ?DEBUG("登录服验证密钥:~p~n", [{Account, LoginTicket, get_login_cache(Account)}]),
%%    case get_login_cache(Account) of
%%        null ->
%%            no_exists;
%%        R ->
%%            #ets_login_cache{
%%                ticket = Ticket
%%            } = R,
%%%%            LoginTicket_0 =  encrypt:md5(SessionKey ++ ?SERVER_SALT),
%%            if
%%                Ticket == LoginTicket ->
%%                    true;
%%                true ->
%%                    no_equal
%%            end
%%    end.

%%login_with_salt(Account, LoginTicket) ->
%%    ?DEBUG("登录服验证密钥:~p~n", [{Account, LoginTicket, get_login_cache(Account)}]),
%%    case get_login_cache(Account) of
%%        null ->
%%            no_exists;
%%        R ->
%%            #ets_login_cache{
%%                ticket = Ticket
%%            } = R,
%%            LoginTicket_0 = encrypt:md5(Ticket ++ ?SERVER_SALT),
%%            if
%%                Ticket == LoginTicket_0 ->
%%                    {ok, Ticket};
%%                true ->
%%                    no_equal
%%            end
%%    end.

%% ----------------------------------
%% @doc 	验证登录密钥
%% @throws 	none
%% @end
%% ----------------------------------
valid_login_ticket(AccId, Time, LoginTicket) ->
    Now = util_time:timestamp(),
    if Now - Time > ?HOUR_S * 12 ->
        %% 过期时间12小时
        %% 密钥过期
        exit(?ERROR_TOKEN_EXPIRE);
        true ->
            MakeLoginTicket = create_login_ticket(AccId, Time),
            if MakeLoginTicket == LoginTicket ->
                true;
                true ->
                    %% 验证失败
                    exit(?ERROR_VERIFY_FAIL)
            end
    end.

create_login_ticket(AccId, Time) ->
    encrypt:md5(AccId ++ erlang:integer_to_list(Time) ++ ?SERVER_SALT).


%%add_login_cache(Account, Ticket) ->
%%    ?DEBUG("记录登录密钥缓存: account=~p ticket=~p ~n", [Account, Ticket]),
%%    ets:insert(?ETS_LOGIN_CACHE, #ets_login_cache{
%%        account = Account,
%%        ticket = Ticket,
%%        time = util_time:timestamp()
%%    }).


%%get_login_cache(Account) ->
%%    case ets:lookup(?ETS_LOGIN_CACHE, Account) of
%%        [] ->
%%            null;
%%        [R] ->
%%            R
%%    end.


%% ----------------------------------
%% @doc 	更新最近登录服务器
%% @throws 	none
%% @end
%% ----------------------------------
%%update_recent_server_list(PlatformId, AccId, ServerId) ->
%%    ?ASSERT(mod_server:is_center_server()),
%%    OldList = get_recent_server_list(PlatformId, AccId),
%%    ?DEBUG("更新最近登录服务器:~p~n", [{PlatformId, AccId, ServerId, OldList}]),
%%    if OldList == [] orelse hd(OldList) =/= ServerId ->
%%        NewList = lists:sublist([ServerId | lists:delete(ServerId, OldList)], 3),
%%        Tran = fun() ->
%%            NewR =
%%                case get_global_account(PlatformId, AccId) of
%%                    null ->
%%                        #db_global_account{
%%                            platform_id = util:to_list(PlatformId),
%%                            account = AccId,
%%                            recent_server_list = util_string:term_to_string(NewList)
%%                        };
%%                    R ->
%%                        R#db_global_account{
%%                            recent_server_list = util_string:term_to_string(NewList)
%%                        }
%%                end,
%%            db:write(NewR)
%%               end,
%%        db:do(Tran);
%%        true ->
%%            noop
%%    end.

%% ----------------------------------
%% @doc 	设置帐号类型
%% @throws 	none
%% @end
%% ----------------------------------
%%set_account_type(PlatformId, AccId, Type) ->
%%    ?ASSERT(mod_server:is_center_server()),
%%    case get_global_account(PlatformId, AccId) of
%%        null ->
%%            exit({exit_no_exists, PlatformId, AccId, Type});
%%        R ->
%%            Tran = fun() ->
%%                db:write(R#db_global_account{
%%                    type = Type
%%                })
%%                   end,
%%            db:do(Tran)
%%    end.

%% ----------------------------------
%% @doc 	获取最近登录服务器列表
%% @throws 	none
%% @end
%% ----------------------------------
%%get_recent_server_list(PlatformId, AccId) ->
%%    case get_global_account(PlatformId, AccId) of
%%        null ->
%%            [];
%%        R ->
%%            #db_global_account{
%%                recent_server_list = RecentServerList
%%            } = R,
%%            util_string:string_to_list_term(RecentServerList)
%%    end.

%%get_global_account(PlatformId, AccId) ->
%%    db:read(#key_global_account{
%%        platform_id = util:to_list(PlatformId),
%%        account = AccId
%%    }).

%% ----------------------------------
%% @doc 	是否是内部帐号
%% @throws 	none
%% @end
%% ----------------------------------
%%is_inner_account(PlatformId, AccId) ->
%%    case get_global_account(PlatformId, AccId) of
%%        null ->
%%            false;
%%        R ->
%%            R#db_global_account.type == 1
%%    end.

%% ----------------------------------
%% @doc 	获取最新的服务器id
%% @throws 	none
%% @end
%% ----------------------------------
get_new_server_id(PlatformId) ->
    CacheKey = {?CACHE_MAX_SERVER_ID, PlatformId},
    case mod_cache:get(CacheKey) of
        null ->
            Now = util_time:timestamp(),
            L = mod_server:get_game_server_list(PlatformId),
            {L1, {_MaxSid, MaxGameServer}} =
                lists:foldl(
                    fun(GameServer, {Tmp, {MaxSid1, MaxGameServer1}}) ->
                        #db_c_game_server{
                            node = Node,
                            sid = Sid,
                            is_show = IsShow
                        } = GameServer,
                        if
                            IsShow == ?FALSE ->
                                {Tmp, {MaxSid1, MaxGameServer1}};
                            true ->
                                #db_c_server_node{
                                    open_time = OpenTime
                                } = mod_server:get_server_node(Node),
                                if Now >= OpenTime ->
                                    {[GameServer | Tmp], {MaxSid1, MaxGameServer1}};
                                    true ->
                                        CurrSid = mod_server:get_real_server_id(Sid),
                                        Tuple =
                                            if
                                                CurrSid > MaxSid1 ->
                                                    {CurrSid, GameServer};
                                                true ->
                                                    {MaxSid1, MaxGameServer1}
                                            end,
                                        {Tmp, Tuple}
                                end
                        end
                    end,
                    {[], {0, #db_c_game_server{sid = "s1"}}},
                    L
                ),
            L2 = ?IF(L1 == [], [MaxGameServer], L1),
            {_, R} = hd(util_list:rkeysort(1, [{mod_server:get_real_server_id(E#db_c_game_server.sid), E} || E <- L2])),
            mod_cache:update(CacheKey, R#db_c_game_server.sid, 5),
            R#db_c_game_server.sid;
        Sid ->
            Sid
    end.

%%get_real_server_id(Sid) ->
%%    Sid1 = string:sub_string(Sid, 2),
%%    util:to_int(Sid1).

%%get_old_server_id(PlatformId) ->
%%    L = mod_server:get_game_server_list(PlatformId),
%%    R = hd(lists:keysort(#db_c_game_server.sid, L)),
%%    R#db_c_game_server.sid.

%% ----------------------------------
%% @doc 	获取所有服务器列表
%% @throws 	none
%% @end
%% ----------------------------------
get_all_server_list(PlatformId, IsInnerAccount) ->
    get_all_server_list(PlatformId, "undefined", IsInnerAccount).
get_all_server_list(PlatformId, Channel, IsInnerAccount) ->
    F = fun() ->
        GameServerList = mod_server:get_game_server_list(PlatformId),
        ServerIdList = [E#db_c_game_server.sid || E <- GameServerList],
        Now = util_time:timestamp(),
        ServerIdList_1 =
            lists:foldl(
                fun(ServerId, Tmp) ->
                    #db_c_game_server{
                        node = Node,
                        is_show = IsShow
                    } = mod_server:get_game_server(PlatformId, ServerId),
                    if
                        IsInnerAccount -> %% 内部帐号不过滤
                            [ServerId | Tmp];
                        true ->
                            #db_c_server_node{
                                open_time = OpenTime
                            } = mod_server:get_server_node(Node),

%%                            ?DEBUG("node:~p", [{Node, State, OpenTime, Now}]),
                            if IsShow == 0 orelse OpenTime > Now ->
                                %% 过滤下线 和 未 开服的 区服
                                Tmp;
                                true ->
                                    [ServerId | Tmp]
                            end
                    end
                end,
                [],
                ServerIdList
            ),
        pack_server_list(PlatformId, Channel, lists:sort(ServerIdList_1))
        end,

    CacheKey = {?CACHE_ALL_SERVER_LIST, {PlatformId, IsInnerAccount}},
    case mod_cache:get(CacheKey) of
        null ->
            ServerList = F(),
            %% 缓存服务器列表，缓存10秒
            mod_cache:update(CacheKey, ServerList, 10),
            ServerList;
        ServerList ->
            ServerList
    end.
%%    case ets:lookup(?ETS_SERVER_LIST, {PlatformId, IsInnerAccount}) of
%%        [] ->
%%            ServerList = F(),
%%            ets:insert(?ETS_SERVER_LIST, #ets_server_list{
%%                platform_id = {PlatformId, IsInnerAccount},
%%                server_list = ServerList,
%%                update_time = util_time:timestamp()
%%            }),
%%            ServerList;
%%        [R] ->
%%            Now = util_time:timestamp(),
%%            if
%%                Now - R#ets_server_list.update_time > 30 -> %% 缓存 30秒
%%                    ServerList = F(),
%%                    ets:insert(?ETS_SERVER_LIST, R#ets_server_list{
%%                        server_list = ServerList,
%%                        update_time = util_time:timestamp()
%%                    }),
%%                    ServerList;
%%                true ->
%%                    ?DEBUG("读取缓存的服务器列表"),
%%                    R#ets_server_list.server_list
%%            end
%%    end.
pack_server_list(_PlatformId, ServerIdList) ->
    pack_server_list(_PlatformId, "undefined", ServerIdList).
pack_server_list(_PlatformId, _, []) ->
    [];
pack_server_list(PlatformId, _Channel, ServerIdList) ->
    CurrTime = util_time:timestamp(),
    AddPort =
        case PlatformId of
%%            ?PLATFORM_OPPO ->
%%                -10000;
            _ ->
                0
        end,
    lists:foldl(
        fun(ServerId, Tmp) ->
            change_server_list(PlatformId, ServerId, AddPort, CurrTime, Tmp)
%%            if
%%                PlatformId == ?PLATFORM_WX andalso Channel == ?CHANNEL_DXLL ->
%%                    CurrSid = mod_server:get_real_server_id(ServerId),
%%                    ChangeNum = 1600,
%%                    if
%%                        CurrSid > ChangeNum ->
%%                            ReplaceSidStr = util:to_list(CurrSid),
%%                            NewReplaceSidStr = util:to_list(CurrSid - ChangeNum),
%%                            change_server_list(PlatformId, ServerId, AddPort, CurrTime, Tmp, ReplaceSidStr, NewReplaceSidStr);
%%                        true ->
%%                            Tmp
%%                    end;
%%                true ->
%%            change_server_list(PlatformId, ServerId, AddPort, CurrTime, Tmp)
%%                    GameServer = mod_server:get_game_server(PlatformId, ServerId),
%%                    if
%%                        GameServer == null ->
%%                            ?DEBUG("区服不存在:~p~n", [{PlatformId, ServerId}]),
%%                            Tmp;
%%                        true ->
%%                            #db_c_game_server{
%%                                desc = Desc,
%%                                node = Node
%%                            } = GameServer,
%%                            ServerNode = mod_server:get_server_node(Node),
%%                            if
%%                                ServerNode == null ->
%%                                    ?DEBUG("节点不存在:~p~n", [{PlatformId, ServerId, Node}]),
%%                                    Tmp;
%%                                true ->
%%                                    #db_c_server_node{
%%                                        ip = Ip,
%%                                        port = Port,
%%                                        state = State,
%%                                        open_time = OpenTime
%%                                    } = ServerNode,
%%                                    [
%%                                        [
%%                                            {id, util:to_binary(ServerId)},
%%                                            {desc, util:to_binary(Desc)},
%%                                            {ip, util:to_binary(Ip)},
%%                                            {port, Port + AddPort},
%%%%                                    {is_new, 0},
%%                                            {state, ?IF(OpenTime > CurrTime, ?SERVER_STATE_MAINTENANCE, State)}
%%                                        ] | Tmp
%%                                    ]
%%                            end
%%                    end
%%            end
        end,
        [],
        lists:reverse(ServerIdList)
    ).
is_domain(Ip) ->
    case catch string:tokens(Ip, ".") of
        L ->
            Length =
                lists:filtermap(
                    fun (Ele) ->
                        try
                            list_to_integer(Ele),
                            {true, Ele}
                        catch
                            _:_Reason_ ->
                                false
                        end
                    end,
                    L
                ),
            Res = string:length(Length),
            ?DEBUG("Length: ~p ~p", [Length, Res]),
            if
                Res =:= 0 -> domain;
                true -> ip
            end;
        _ ->
            ip
    end.

%% @doc fun 转换区服数据
change_server_list(PlatformId, ServerId, AddPort, CurrTime, TempList) ->
    change_server_list(PlatformId, ServerId, AddPort, CurrTime, TempList, "", "").
change_server_list(PlatformId, ServerId, AddPort, CurrTime, TempList, ReplaceSidStr, NewReplaceSidStr) ->
    GameServer = mod_server:get_game_server(PlatformId, ServerId),
    if
        GameServer == null ->
            ?DEBUG("区服不存在:~p~n", [{PlatformId, ServerId}]),
            TempList;
        true ->
            #db_c_game_server{
                desc = Desc,
                node = Node
            } = GameServer,
            ServerNode = mod_server:get_server_node(Node),
            if
                ServerNode == null ->
                    ?DEBUG("节点不存在:~p~n", [{PlatformId, ServerId, Node}]),
                    TempList;
                true ->
                    #db_c_server_node{
                        ip = Ip,
                        port = Port1,
                        state = State,
                        open_time = OpenTime
                    } = ServerNode,
                    IsIp = is_domain(Ip),
                    Port = ?IF(IsIp =:= ip, Port1, 80),
                    ?DEBUG("IsIp: ~p Port: ~p", [IsIp, Port]),
                    {NewServerIdBin, NewDescBin} =
                        if
                            ReplaceSidStr == "" ->
                                {util:to_binary(ServerId), util:to_binary(Desc)};
                            true ->
                                {re:replace(ServerId, ReplaceSidStr, NewReplaceSidStr, [{return, binary}]), re:replace(Desc, ReplaceSidStr, NewReplaceSidStr, [{return, binary}])}
                        end,
                    [
                        [
                            {id, NewServerIdBin},
                            {desc, NewDescBin},
                            {ip, util:to_binary(Ip)},
                            {port, Port + AddPort},
%%                                    {is_new, 0},
                            {state, ?IF(OpenTime > CurrTime, ?SERVER_STATE_MAINTENANCE, State)}
                        ] | TempList
                    ]
            end
    end.

%%    [
%%        begin
%%            GameServer = mod_server:get_game_server(PlatformId, ServerId),
%%            if GameServer == null ->
%%                ?DEBUG("区服不存在:~p~n", [{PlatformId, ServerId}]);
%%                true ->
%%                    noop
%%            end,
%%            #db_c_game_server{
%%                desc = Desc,
%%                node = Node
%%            } = GameServer,
%%            ServerNode = mod_server:get_server_node(Node),
%%            if ServerNode == null ->
%%                ?DEBUG("节点不存在:~p~n", [{PlatformId, ServerId, Node}]);
%%                true ->
%%                    noop
%%            end,
%%            #db_c_server_node{
%%                ip = Ip,
%%                port = Port,
%%                state = State
%%            } = ServerNode,
%%            [
%%                {id, util:to_binary(ServerId)},
%%                {desc, util:to_binary(Desc)},
%%                {ip, util:to_binary(Ip)},
%%                {port, Port},
%%                {is_new, 0},
%%                {state, State}
%%            ]
%%        end
%%        || ServerId <- ServerIdList].


%%get_real_platform_id(PlatformId) ->
%%    if PlatformId == ?PLATFORM_FK ->
%%        %% 疯狂和爱微游同服, 并且用的的是爱微游的平台id
%%        ?PLATFORM_AWY;
%%        true ->
%%            PlatformId
%%    end.
