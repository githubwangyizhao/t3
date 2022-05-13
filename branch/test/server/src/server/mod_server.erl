%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器模块
%%% @end
%%% Created : 13. 六月 2016 下午 2:38
%%%-------------------------------------------------------------------
-module(mod_server).

-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
-include("version.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
%%节点管理
-export([
    join_zone/0,                        %% 加入跨服
    join_war/0,                         %% 加入战区
    join_center/0,                      %% 加入中心服
    handle_join_center/1
]).

-export([
%%    get_server_list/1,
    init/0,                             %% 服务器初始化
    is_center_server/0,                 %% 是否中心服
    is_game_server/0,                   %% 是否游戏服
    is_zone_server/0,                   %% 是否战区服
    is_war_server/0,                    %% 是否战区
    get_node_name/0,                    %% 获取节点名
    get_platform_record/1,              %% 获取平台记录
    get_node_ip/0,                      %% 获取节点ip
    assert_node_key/1,                  %% 校验节点秘钥
    is_forbid_socket/0,                 %% 是否禁止socket
    set_is_forbid_socket/1,             %% socket禁止
    check_socket_connect/1,
    get_server_open_day_number/0,       %% 获得开服几天了
    get_server_merge_day_number/0,      %% 获得合服几天了
    get_server_open_day_timestamp/1,    %% 获取开服第几天0点时间戳
    get_server_merge_day_timestamp/1,   %% 获取合服第几天0点时间戳
    is_server_open_time/0,              %% 是否已经开服
    get_white_ip_list/0,                %% 白名单ip列表
    get_black_ip_list/0,                %%
    get_channel_list_by_platform_id/1,  %% 获取该平台下的所有渠道
    get_platform_by_channel/1,              %% 通过渠道获得平台id
    format_server_type/1,
    get_code_version/0,
    get_zone_id/3,                      %% 获取跨服区id
    get_real_server_id/1,               %% 读取区服的int内容
    get_node_server_id/1,
    is_white_ip/1,                      %% 是否白名单
    is_black_ip/1                       %%
]).
%% server_node
-export([
    get_game_server/2,                  %% 获取c_game_server
    get_game_server_list/0,             %% 获取c_game_server列表
    get_game_server_list/1,

    get_game_server_list_by_node/1,     %% 获取该节点c_game_server列表

    get_server_node/1,                  %% 获取服务器节点
    get_server_node_list/0,             %% 获取节点列表
    get_server_node_list/1,
    get_server_node_list/2,
    get_server_node_list_by_zone/1,
    get_server_node_by_ip_port/2,
    get_server_node_by_platform_id_and_server_id/2,

    get_unique_id_server_node/0,
    get_charge_server_node/0,
    get_war_area_server_node/1,
    get_login_server_node/0,

    get_open_server_id_list/0,          %% 获取已经开服的服务器id列表
    get_server_id/0,                    %% 获取服务端id
    get_server_id_list/0,               %% 获取服务器id列表
    get_game_node/2,                    %% 获取游戏服节点
    get_all_game_node/0
]).

-export([
    chk_game_server_state/2
]).

-export([
    get_game_server_list_without_reviewing/1,
    get_game_server_list_without_reviewing/2
]).

%% ----------------------------------
%% @doc 	检查指定platform,指定serverId的节点状态
%% @throws 	none
%% @end
%% ----------------------------------
chk_game_server_state(PlatformId, ServerId) ->
    Node =
        case get_game_server(PlatformId, ServerId) of
            R when is_record(R, db_c_game_server) ->
                #db_c_game_server{node = N} = R,
                N
        end,
    case get_server_node(Node) of
        S when is_record(S, db_c_server_node) ->
            #db_c_server_node{state = State} = S,
            State
    end.

%% ----------------------------------
%% @doc 	初始化服务器节点
%% @throws 	none
%% @end
%% ----------------------------------
init() ->
    case is_center_server() of
        true ->
            {DbHost, DbPort, DbName} = mysql_srv:get_db_configs(),
            mod_server_mgr:add_server_node(
                util:to_list(node()),
                get_node_ip(),
                0,
                ?CENTER_DEFAULT_HTTP_PORT,
                ?SERVER_TYPE_CENTER,
                "",
                DbHost,
                DbPort,
                DbName
            );
        _ ->
            %% 向中心服下拉配置数据
            mod_server_sync:pull()
    end,
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_GAME ->
            %% 游戏节点 加入战区服务器
            join_war();
        _ ->
            noop
    end,
    ok.

%% ----------------------------------
%% @doc 	加入跨服
%% @throws 	none
%% @end
%% ----------------------------------
join_zone() ->
    Node = node(),
    Result = mod_server_rpc:call_zone(zone_srv, join, [Node]),
    if Result == ok ->
        ?INFO("加入跨服服务器成功:~p", [mod_server_config:get_zone_node()]);
        true ->
            ?ERROR("加入跨服服务器失败:~p", [mod_server_config:get_zone_node()])
    end.

%% ----------------------------------
%% @doc 	加入战区
%% @throws 	none
%% @end
%% ----------------------------------
join_war() ->
    Node = node(),
    Result = mod_server_rpc:call_war(war_srv, join, [Node]),
    if Result == ok ->
        ?INFO("加入战区服务器成功:~p", [mod_server_config:get_war_area_node()]);
        true ->
            ?ERROR("加入战区服务器失败:~p", [mod_server_config:get_war_area_node()])
    end.

%% ----------------------------------
%% @doc 	加入中心服
%% @throws 	none
%% @end
%% ----------------------------------
join_center() ->
    case mod_server_rpc:call_center(?MODULE, handle_join_center, [node()]) of
        ok ->
            ?INFO("Connect center node(~p) succeed", [mod_server_config:get_center_node()]);
        Other ->
            ?ERROR("Connect center node(~p) failed:~p", [mod_server_config:get_center_node(), Other]),
            exit({join_center_server_fail, Other})
    end.

%% CALLBACK 中心服回调
handle_join_center(Node) ->
    case get_server_node(Node) of
        null ->
            ?ERROR("Node(~p) join error: not find!", [Node]),
            exit(node_not_find);
        _ServerNode ->
            server_node_master:join(Node),
            ok
    end.

%% ----------------------------------
%% @doc     获取指定平台下，除了审核服外的所有服务器列表
%% @throws
%% @end
%% ----------------------------------
get_game_server_list_without_reviewing(PlatformId) ->
    get_game_server_list_without_reviewing(PlatformId, ?FALSE).
get_game_server_list_without_reviewing(PlatformId, ReturnOne) ->
    Env = env:get(env, "production"),
    ReviewingSid = ?REVIEWING_SERVER(Env),
    ?INFO("获取环境~p下平台~p的所有服务器列表(除~p外)", [Env, PlatformId, ReviewingSid]),
    ServerList = mod_server:get_game_server_list(PlatformId),
    ?DEBUG("ServerList: ~p", [ServerList]),
    ServerListLength = length(ServerList),
    RealServerList =
        lists:foldl(
            fun(RealSid, Tmp) ->
                if
                    ServerListLength > 1 andalso RealSid =:= ReviewingSid ->
                        Tmp;
                    ServerListLength > 1 andalso RealSid =/= ReviewingSid ->
                        [RealSid | Tmp];
                    true ->
                        [RealSid | Tmp]
                end
            end,
            [],
            [?IF(is_binary(RealSid), util:to_list(RealSid), RealSid) || #db_c_game_server{sid = RealSid} <- ServerList]
        ),
    ?INFO("valid server list: ~p", [RealServerList]),
    RealServerListAfterSort = lists:sort(fun(A, B) -> A > B end, RealServerList),
    ?IF(ReturnOne =:= ?TRUE, hd(RealServerListAfterSort), RealServerListAfterSort).

%% ----------------------------------
%% @doc     获取game_server
%% @throws
%% @end
%% ----------------------------------
get_game_server(PlatformId, ServerId) when is_list(PlatformId) andalso is_list(ServerId) ->
    db:read(#key_c_game_server{platform_id = PlatformId, sid = ServerId}).

get_game_server_list() ->
    get_game_server_list("").

get_game_server_list(PlatformId) when is_list(PlatformId) ->
    if PlatformId =/= "" ->
        db:select(c_game_server, [{#db_c_game_server{platform_id = PlatformId, _ = '_'}, [], ['$_']}]);
        true ->
            ets:tab2list(c_game_server)
    end.

get_game_server_list_by_node(Node) ->
    db:select(c_game_server, [{#db_c_game_server{node = util:to_list(Node), _ = '_'}, [], ['$_']}]).

get_server_node(Node) ->
    db:read(#key_c_server_node{node = util:to_list(Node)}).

get_server_node_by_ip_port(Ip, Port) ->
    case db:select(c_server_node,
        [{#db_c_server_node{ip = util:to_list(Ip), port = Port, _ = '_'}, [], ['$_']}])
    of
        [] ->
            null;
        [R] ->
            R
    end.

get_server_node_by_platform_id_and_server_id(PlatformId, ServerId) ->
    #db_c_game_server{
        node = Node
    } = mod_server:get_game_server(PlatformId, ServerId),
    mod_server:get_server_node(Node).

get_server_node_list_by_zone(ZoneNode) ->
    db:select(c_server_node, [{#db_c_server_node{zone_node = util:to_list(ZoneNode), type = ?SERVER_TYPE_GAME, _ = '_'}, [], ['$_']}]).
%%    game_db:select(c_zone, [{#c_zone{zone_node = util:to_list(ZoneNode), game_node = '$1', _ = '_'}, [], ['$1']}]).


get_unique_id_server_node() ->
    case db:select(c_server_node, [{#db_c_server_node{type = ?SERVER_TYPE_UNIQUE_ID, _ = '_'}, [], ['$_']}]) of
        [] ->
            null;
        [R] ->
            R
    end.

get_charge_server_node() ->
    case db:select(c_server_node, [{#db_c_server_node{type = ?SERVER_TYPE_CHARGE, _ = '_'}, [], ['$_']}]) of
        [] ->
            null;
        [R] ->
            R
    end.

get_war_area_server_node(PlatformId) ->
    case db:select(c_server_node, [{#db_c_server_node{type = ?SERVER_TYPE_WAR_AREA, platform_id = PlatformId, _ = '_'}, [], ['$_']}]) of
        [] ->
            null;
        [R] ->
            R
    end.

get_login_server_node() ->
    case db:select(c_server_node, [{#db_c_server_node{type = ?SERVER_TYPE_LOGIN_SERVER, _ = '_'}, [], ['$_']}]) of
        [] ->
            null;
        [R] ->
            R
    end.

get_server_node_list() ->
    ets:tab2list(c_server_node).

%% 获取所有游戏节点
get_server_node_list(Type) ->
    get_server_node_list("", Type).
get_server_node_list(PlatformId, Type) when is_list(PlatformId) ->
    %% 平台id 只支持游戏服
    ?ASSERT(PlatformId == "" orelse Type == ?SERVER_TYPE_GAME, no_support_platform_id),
    lists:filter(
        fun(ServerNode) ->
            #db_c_server_node{
                platform_id = ThisPlatformId,
                type = ThisType

            } = ServerNode,
            if
                PlatformId == "" ->
                    ThisType == Type;
                true ->
                    ThisType == Type andalso ThisPlatformId == PlatformId
            end
        end,
        get_server_node_list()
    ).

%% 获取游戏服节点
get_game_node(_PlatformId, ?UNDEFINED) ->
    null;
get_game_node(?UNDEFINED, _ServerId) ->
    null;
get_game_node(PlatformId, ServerId) ->
    case get_game_server(PlatformId, ServerId) of
        null ->
            ?ERROR("not found game_server_node:~p", [{PlatformId, ServerId}]),
            null;
        R ->
            util:to_atom(R#db_c_game_server.node)
    end.


%% ----------------------------------
%% @doc     获取该所有游戏节点
%% @throws
%% @end
%% ----------------------------------
get_all_game_node() ->
    GameServerList = get_game_server_list(),
    NodeList = lists:foldl(
        fun(GameServer, L) ->
            #db_c_game_server{
                node = StrNode
            } = GameServer,
            AtomNode = util:to_atom(StrNode),
            [AtomNode | L]
        end,
        [],
        GameServerList
    ),
    lists:usort(NodeList).

%% ----------------------------------
%% @doc  获取服务器id
%% @throws 	none
%% @end
%% ----------------------------------
get_server_id() ->
    hd([
        begin
            E#db_c_game_server.sid
        end
        ||
        E <- get_game_server_list()
    ]).

%% ----------------------------------
%% @doc  获取服务器id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_server_id_list() ->
    [
        begin
            E#db_c_game_server.sid
        end
        ||
        E <- get_game_server_list()
    ].

%% ----------------------------------
%% @doc 	获取已经开服的服务器id列表
%% @throws 	none
%% @end
%% ----------------------------------
get_open_server_id_list() ->
    Now = util_time:timestamp(),
    lists:foldl(
        fun(CGameServer, Tmp) ->
            #db_c_game_server{
                sid = Sid,
                node = Node
            } = CGameServer,
            #db_c_server_node{
                open_time = OpenTime
            } = get_server_node(Node),
            if Now > OpenTime ->
                [Sid | Tmp];
                true ->
                    Tmp
            end
        end,
        [],
        get_game_server_list()
    ).

%% ----------------------------------
%% @doc 	是否中心服
%% @throws 	none
%% @end
%% ----------------------------------
is_center_server() ->
    mod_server_config:get_server_type() == ?SERVER_TYPE_CENTER.

%% ----------------------------------
%% @doc 	是否游戏服
%% @throws 	none
%% @end
%% ----------------------------------
is_game_server() ->
    mod_server_config:get_server_type() == ?SERVER_TYPE_GAME.

%% ----------------------------------
%% @doc 	是否跨服
%% @throws 	none
%% @end
%% ----------------------------------
is_zone_server() ->
    mod_server_config:get_server_type() == ?SERVER_TYPE_WAR_ZONE.

%% @fun 是否战区
is_war_server() ->
    mod_server_config:get_server_type() == ?SERVER_TYPE_WAR_AREA.

%% 获得开服几天了
get_server_open_day_number() ->
    OpenTime = mod_server_config:get_server_open_time(),
    util_time:get_interval_day_add_1(OpenTime).

%% 获得合服几天了
get_server_merge_day_number() ->
    MergeTime = mod_server_config:get_server_merge_time(),
    if MergeTime == 0 ->
        0;
        true ->
            util_time:get_interval_day_add_1(MergeTime)
    end.

%% @doc 获取开服第几天0点时间戳
get_server_open_day_timestamp(Day) when Day >= 1 ->
    OpenTime = mod_server_config:get_server_open_time(),
    ZeroOpenTime = util_time:get_today_zero_timestamp(OpenTime),
    ZeroOpenTime + (Day - 1) * 86400.

%% @doc 获取合服第几天0点时间戳
get_server_merge_day_timestamp(Day) when Day >= 1 ->
    MergeTime = mod_server_config:get_server_merge_time(),
    ZeroMergeTime = util_time:get_today_zero_timestamp(MergeTime),
    ZeroMergeTime + (Day - 1) * 86400.

%% ----------------------------------
%% @doc 	获取跨服区id
%% @throws 	none
%% @end
%% ----------------------------------
get_zone_id(PlatformId, ServerId, Len) when is_list(ServerId) andalso is_list(PlatformId) andalso is_integer(Len) ->
    GameServerList = mod_server:get_game_server_list(PlatformId),
    ?ASSERT(mod_server:get_game_server(PlatformId, ServerId) =/= null, {get_zone_id, PlatformId, ServerId, Len}),
    GameServerList_2 =
        lists:foldl(
            fun(GameServer, Tmp) ->
                #db_c_game_server{
                    sid = Sid,
                    node = Node
                } = GameServer,

                case lists:keytake(Node, 2, Tmp) of
                    {value, {NodeSid, Node, SidList}, Left} ->
                        [{NodeSid, Node, [Sid | SidList]} | Left];
                    _ ->
                        NodeSid = get_node_server_id(Node),
                        [{NodeSid, Node, [Sid]} | Tmp]
                end
            end,
            [],
            GameServerList
        ),
    GameServerList_3 = lists:keysort(1, GameServerList_2),
    ?INFO("GameServerList:~p~n", [GameServerList]),
    ?INFO("GameServerList_3:~p~n", [GameServerList]),
    {ZoneId, _} = lists:foldl(
        fun({_NodeSid, _Node, SidList}, {MatchZoneId, TmpNum}) ->
            if MatchZoneId == -1 ->
                case lists:member(ServerId, SidList) of
                    true ->

                        {erlang:ceil(TmpNum / Len), TmpNum + 1};
                    false ->
                        {MatchZoneId, TmpNum + 1}
                end;
                true ->
                    {MatchZoneId, TmpNum + 1}
            end
        end,
        {-1, 1},
        GameServerList_3
    ),
    ZoneId.

%% ----------------------------------
%% @doc 	获取节点名字
%% @throws 	none
%% @end
%% ----------------------------------
get_node_name() ->
    [ServerName, _Ip] = string:tokens(util:to_list(node()), "@"),
    ServerName.

%% ----------------------------------
%% @doc 	获取节点ip
%% @throws 	none
%% @end
%% ----------------------------------
get_node_ip() ->
    [_ServerName, Ip] = string:tokens(util:to_list(node()), "@"),
    Ip.

%% ----------------------------------
%% @doc 	白名单
%% @throws 	none
%% @end
%% ----------------------------------
get_white_ip_list() ->
    [].

%% ----------------------------------
%% @doc 	黑名单
%% @throws 	none
%% @end
%% ----------------------------------
get_black_ip_list() ->
    [].


is_black_ip(Ip) when is_list(Ip) ->
    lists:member(Ip, get_black_ip_list()).

is_white_ip(Ip) when is_list(Ip) ->
    lists:member(Ip, get_white_ip_list()).


%% ----------------------------------
%% @doc 	Socket 进程启动检查
%% @throws 	none
%% @end
%% ----------------------------------
check_socket_connect(IP) ->
    IsGameServer = is_game_server(),
    if IsGameServer ->
        IsForbidSocket = is_forbid_socket(),
        if IsForbidSocket ->
            IsWhiteIp = is_white_ip(IP),
            if
                IsWhiteIp ->
                    {true, white_ip};
                true ->
                    {false, socket_forbid}
            end;
            true ->
                IsBlackIp = is_black_ip(IP),
                if
                    IsBlackIp ->
                        {false, black_ip};
                    true ->
                        {true, null}
                end
        end;
        true ->
            {true, null}
    end.

%% ----------------------------------
%% @doc 	是否开服时间
%% @throws 	none
%% @end
%% ----------------------------------
is_server_open_time() ->
    util_time:timestamp() >= mod_server_config:get_server_open_time().

%% @doc fun 读取区服的int内容
get_real_server_id(Sid) ->
    Sid1 = string:sub_string(Sid, 2),
    util:to_int(Sid1).

get_node_server_id(Node) ->
    ?DEBUG("Node:~p", [Node]),
    [NodeName, _] = string:split(Node, "@"),
    IsMatch = string:str(NodeName, "_"),
    if IsMatch > 0 ->
        [_, Sid] = string:split(NodeName, "_"),
        get_real_server_id(Sid);
        true ->
            get_real_server_id(NodeName)
    end.

%% ----------------------------------
%% @doc 	Socket 禁止
%% @throws 	none
%% @end
%% ----------------------------------
is_forbid_socket() ->
    case mod_server_data:get_server_data(?SERVER_DATA_IS_SOCKET_FORBID) of
        null ->
            false;
        R ->
            R#db_server_data.int_data == ?TRUE
    end.

set_is_forbid_socket(Data) ->
    ?ASSERT(Data == ?TRUE orelse Data == ?FALSE),
    mod_server_data:set_int_data(?SERVER_DATA_IS_SOCKET_FORBID, Data).


format_server_type(ServerType) ->
    case ServerType of
        ?SERVER_TYPE_CENTER ->
            "中心节点";
        ?SERVER_TYPE_GAME ->
            "游戏服";
        ?SERVER_TYPE_WAR_ZONE ->
            "跨服";
        ?SERVER_TYPE_LOGIN_SERVER ->
            "登录服";
        ?SERVER_TYPE_WEB ->
            "web服";
        ?SERVER_TYPE_UNIQUE_ID ->
            "唯一id服";
        ?SERVER_TYPE_CHARGE ->
            "充值服";
        ?SERVER_TYPE_WAR_AREA ->
            "战区服";
        _ ->
            "未知"
    end.

%% ----------------------------------
%% @doc 	校验节点秘钥
%% @throws 	none
%% @end
%% ----------------------------------
assert_node_key(NodeKey) ->
    ?ASSERT(NodeKey == ?NODE_KEY).


%% ----------------------------------
%% @doc 	获取该平台下的所有渠道
%% @throws 	none
%% @end
%% ----------------------------------
get_channel_list_by_platform_id(PlatformId) when is_list(PlatformId) ->
    case logic_get_channel_list_by_platform_id:get(PlatformId) of
        null ->
            ?WARNING("平台渠道配置错误:~p", [{PlatformId}]),
            [];
        List ->
            List
    end.

%% ----------------------------------
%% @doc 	获取服务器版本
%% @throws 	none
%% @end
%% ----------------------------------
get_code_version() ->
    ?SERVER_CODE_VERSION.

% 得到平台数据
get_platform_record(PlatformId) ->
    t_platform:get({PlatformId}).

%% 获取所有平台id
%%get_all_platform_id() ->
%%    logic_get_all_platform_id:get(0).

%% ----------------------------------
%% @doc 	通过渠道获得平台id
%% @throws 	none
%% @end
%% ----------------------------------
get_platform_by_channel(Channel) ->
    %% #t_channel{
    %%     platform_id = PlatformId
    %% } = t_channel:get(Channel),
    %% PlatformId.
    logic_get_platform_id_by_channel:get(Channel).
