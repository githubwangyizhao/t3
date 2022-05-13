%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 1月 2021 下午 03:25:10
%%%-------------------------------------------------------------------
-module(handle_login_oauth).
-author("Administrator").

-include("system.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-include("error.hrl").
-include("db_config.hrl").

%% API
-export([init/2]).

-define(KEY, "abc").
-define(JWT_EXPIRE, 24 * 60 * 60 * 30).

-define(ITEM_ICON_URL(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, ?IF(?IS_DEBUG, "http://192.168.31.100:7080", "http://47.101.164.86:7080"), "http://www.bountymasters.com:7080") ++ "/resource/assets/icon/item/").
-define(AVATAR_ICON_URL(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, ?IF(?IS_DEBUG, "http://192.168.31.100:7080", "http://47.101.164.86:7080"), "http://www.bountymasters.com:7080") ++ "/resource/assets/icon/head/").
%%-define(ITEM_ICON_URL(PlatformId), "http://www.bountymasters.com:7080/resource/assets/icon/item/").
%%-define(AVATAR_ICON_URL, "http://www.bountymasters.com:7080/resource/assets/icon/head/").
%%-define(ITEM_ICON_URL, "http://192.168.31.100:6100/resource/assets/icon/item/").
%%-define(AVATAR_ICON_URL, "http://192.168.31.100:6100/resource/assets/icon/head/").
-define(GAME_NAME, "an execllent game").
-define(GAME_ICON, "123").

init(Req, Opts) ->
    NewReq = handle_request(Req, Opts),
    {ok, NewReq, Opts}.

%% @fun 根据请求 切换不同的操作
handle_request(Req, Opts) ->
    Method = cowboy_req:method(Req),
    case Method of
        <<"GET">> ->
            handle_body(Req, Opts);
        <<"POST">> ->
            handle_body(Req, Opts);
        <<"PUT">> ->
            handle_body(Req, Opts);
        _ ->
            ?ERROR("错误handle_request Method: ~p ~n", [Method])
    end.
handle_body(Req, _Opts) ->
    Method = cowboy_req:method(Req),
    {IP, _} = cowboy_req:peer(Req),
    Ip = inet_parse:ntoa(IP),
    PathId = cowboy_req:binding(id, Req),
    if
        undefined == PathId ->
            Path = cowboy_req:path(Req);
        true ->
            Path =
                case re:run(binary_to_list(cowboy_req:path(Req)), cowboy_req:binding(id, Req)) of
                    nomatch -> cowboy_req:path(Req);
                    _ ->
                        [UrlPrefix, [] | UrlSuffix] = re:replace(binary_to_list(cowboy_req:path(Req)), "/" ++ binary_to_list(cowboy_req:binding(id, Req)), ""),
                        RealUrlPath = binary_to_list(UrlPrefix) ++ binary_to_list(UrlSuffix),
                        ?DEBUG("real url path: ~p", [list_to_binary(RealUrlPath)]),
                        list_to_binary(RealUrlPath)
                end
    end,
%%    Path = cowboy_req:path(Req),
    {ErrorCode, Error} =
        case catch path_request(Path, Method, Ip, Req) of
            ok ->
                {0, ok};
            {'EXIT', fail} ->
                {fail, 422};
            {'EXIT', invalid_buyer_player} ->
                {invalid_buyer_player, 422};
            {'EXIT', ?ERROR_NOT_ONLINE} ->
                {?ERROR_NOT_ONLINE, 403};
            {'EXIT', ?ERROR_NO_ROLE} ->
                {?ERROR_NO_ROLE, 404};
            {'EXIT', unauthorized} ->
                {unauthorized, 401};
            {'EXIT', {param_type_error, _}} ->
                {param_type_error, 400};
            {'EXIT', invalid_operation} ->
                {invalid_operation, 422};
            {'EXIT', log_error} ->
                {log_error, 422};
            {'EXIT', invalid_id_secret} ->
                {invalid_id_secret, 400};
            {'EXIT', access_denied} ->
                {access_denied, 403};
            {'EXIT', file_not_found} ->
                {file_not_found, 404};
            access_denied ->
                {access_denied, 403};
            {html, Html} ->
                {html, Html};
            {ok, MsgMap} when is_map(MsgMap) ->
                ?DEBUG("MsgMap: ~p ~p", [MsgMap, is_map(MsgMap)]),
                {ok, MsgMap};
            {ok, MsgL} ->
                {ok, MsgL};
            {redirect, Url} ->
                {redirect, Url};
%%            {invalid_token, }
            R1 ->
                ?ERROR("未知错误: ~p ~n ", [R1]),
%%                {_, ParamStr} = get_req_param_str(Req),
                logger2:write(game_charge_other_error, {{ip, IP}, R1}),
                ok = get_req_param_str(Req),
                {-3, R1}
        end,
    ?DEBUG("ErrorCode: ~p", [[ErrorCode, Error]]),
    if
        ErrorCode == ok orelse ErrorCode == access_denied orelse ErrorCode == file_not_found
            orelse ErrorCode == invalid_id_secret orelse ErrorCode == param_type_error
            orelse ErrorCode == unauthorized orelse ErrorCode == invalid_operation
            orelse ErrorCode == fail orelse ErrorCode == invalid_buyer_player ->
            Req2 = web_http_util:output_json(Req, Error);
        ErrorCode == redirect ->
            Req2 = web_http_util:output_json(Req, {Error});
        ErrorCode == html ->
            Req2 = web_http_util:output_html(Req, Error);
        ErrorCode == -3 ->
            Req2 = web_http_util:output_json(Req, 405);
        true ->
            Req2 = web_http_util:output_json(
                Req, [{'code', ErrorCode}, {'message', util:to_binary(util_string:to_utf8("abc"))}])
    end,
    Req2.

path_request(<<"/oauth/platform">>, <<"GET">>, Ip, Req) -> % 获取游戏平台
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    % 校验client_id与client_secret是否有效
    Client_id = util:to_list(charge_handler:get_list_value(<<"client_id">>, ParamInfoList)),
    Client_secret = util:to_list(charge_handler:get_list_value(<<"client_secret">>, ParamInfoList)),
    % 判断第三方授权登录的clientIdSecret.yaml文件是否存在 若不存在直接抛错
    [{_, ClientId}, {_, ClientSecret}, {_, ClientIp}] = [{yaml:key(Ele), string:strip(yaml:value(Ele), both)} || Ele <- get_yaml_file(?OAUTH_CLIENT_INFO)],
    if
        ClientId =/= Client_id andalso ClientSecret =/= Client_secret ->
            ?DEBUG("Client_id ~p", [[Client_id, Client_secret, ClientIp, Ip]]),
            exit(invalid_id_secret);
        true ->
            case ets:tab2list(?C_GAME_SERVER) of
                GameServerList ->
                    PlatformIdList =
                        if
                            GameServerList =/= [] ->
                                lists:usort(lists:map(
                                    fun (Ele) ->
                                        #db_c_game_server{
                                            platform_id = PlatformId
                                        } = Ele,
                                        PlatformId
                                    end,
                                    GameServerList
                                ));
                            true ->
                                exit(file_not_found)
                        end,
                    ?DEBUG("rrr: ~p", [PlatformIdList]),
                    Res =
                        lists:foldl(
                            fun (Ele, Tmp) ->
%%                                [{0, [{'id', Ele}, {'name', Ele}]} | Tmp]
                                [#{id => list_to_binary(Ele), name => list_to_binary(Ele)} | Tmp]
                            end,
                            [],
                            PlatformIdList
                        ),
%%                    {ok, [{error, 0}, {msg, ""}, {result, Res}]}
                    {ok, #{error => 0, msg => 'success', result => Res}}
            end
    end;
%% @fun 地址请求
path_request(<<"/oauth/authorize">>, <<"GET">>, _Ip, Req) ->     %  oauth授权登录
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    % 校验client_id与client_secret是否有效
    Client_id = util:to_list(charge_handler:get_list_value(<<"client_id">>, ParamInfoList)),
    Client_secret = util:to_list(charge_handler:get_list_value(<<"client_secret">>, ParamInfoList)),
    State = util:to_list(charge_handler:get_list_value(<<"state">>, ParamInfoList)),
    % 判断第三方授权登录的clientIdSecret.yaml文件是否存在 若不存在直接抛错
    [{_, ClientId}, {_, ClientSecret}, {_, _ClientIp}] = [{yaml:key(Ele), string:strip(yaml:value(Ele), both)} || Ele <- get_yaml_file(?OAUTH_CLIENT_INFO)],
    if ClientId =/= Client_id andalso ClientSecret =/= Client_secret
        ->
        ?DEBUG("Client_id ~p", [[Client_id, Client_secret, State]]),
        exit(invalid_id_secret);
        true ->
%%            Redirect_uri = util:to_list(charge_handler:get_list_value(<<"redirect_uri">>, ParamInfoList)),
            Options = ["<option value='" ++ E ++ "'>" ++ E ++ "</option>" || {E} <- t_platform:get_keys()],
            Title = "<title>title123</title>",
            {html, "<!DOCTYPE html><html lang='en'><head><meta charset='UTF-8'>" ++ Title ++ "</head><body><form method='POST' action='/oauth/signin'><label name='username'>username:</label><input name='username' value='' type='text' /><label name='password'>platform:</label><select name='platform'>" ++ Options ++ "</select><input name='redirect_uri' value='' type='hidden' /><input name='state' value='' type='hidden' /><input type='submit' value='submit'></form></body><script>function GetRequest() {var url = location.search; var theRequest = new Object();  if (url.indexOf('?') != -1) { var str = url.substr(1); strs = str.split('&'); for(var i = 0; i < strs.length; i ++) {theRequest[strs[i].split('=')[0]] = unescape(strs[i].split('=')[1]);} } return theRequest;}document.getElementsByName('redirect_uri')[0].value = GetRequest().redirect_uri;document.getElementsByName('state')[0].value = GetRequest().state;</script></html>"}
    end;
path_request(<<"/oauth/signin">>, <<"POST">>, _Ip, Req) -> % oauth跳转的登录页面
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    ?DEBUG("Req ~p", [_ParamStr]),
    Redirect_uri = util:to_list(charge_handler:get_list_value(<<"redirect">>, ParamInfoList)),      % 登陆成功callback_url
    ?DEBUG("Redirect_uri ~p", [Redirect_uri]),
    State = util:to_list(charge_handler:get_list_value(<<"state">>, ParamInfoList)),      % 登陆成功callback_url
    ?DEBUG("State ~p", [State]),
    AccId = util:to_list(charge_handler:get_list_value(<<"username">>, ParamInfoList)),
    Platform = util:to_list(charge_handler:get_list_value(<<"platform">>, ParamInfoList)),
    #db_global_account{
        platform_id = Platform,
        account = AccId,
        recent_server_list = ServerList,
        type = Type,
        forbid_type = _ForbidType,                %% int 封禁类型[0: 正常 1:禁言 2:封号]
        forbid_time = _ForbidTime                %% int 封禁时间
    } = global_account_srv:get_global_account(Platform, api_login:get_acc_id(AccId, Platform)),
    ?ASSERT(?IS_DEBUG =:= true orelse Type =:= 0, access_denied),
    RecentServerList = mod_global_account:tran_recent_server_list(ServerList),
    ?ASSERT(is_list(RecentServerList) andalso length(RecentServerList) >= 1, file_not_found),
    Chaim = [
        {<<"iss">>, "gasdasda"},
        {<<"platform_id">>, list_to_binary(Platform)},
        {<<"acc_id">>, list_to_binary(AccId)}
    ],
    Token = util_token:get_token(<<"HS256">>, Chaim, list_to_binary(?KEY), ?JWT_EXPIRE),
    Code = encrypt:md5(Platform ++ AccId),
    OauthRecord = #ets_oauth_state_jwt{
        code = Code,
        platformId = Platform,
        accId = AccId,
        jwt = binary_to_list(Token),
        recentServerList = RecentServerList
    },
    ets:insert_new(?ETS_OAUTH_STATE_JWT, OauthRecord),
    Redirect_url = Redirect_uri ++ "?state=" ++ State ++ "&code=" ++ Code,
    ?DEBUG("Redirect_uri ~p", [Redirect_url]),
    {redirect, Redirect_url};
%%    mod_player:get_player_by_server_id_and_acc_id(ServerId, AccId),
path_request(<<"/oauth/token">>, <<"GET">>, _Ip, Req) -> % oauth获取token 刷新token
    % 参数列表: code(oauth获取token时必须), token(刷新token时必须)
    ?DEBUG("(~p) /oauth/token"),
    {ParamInfoList, _} = charge_handler:get_req_param_str(Req),
    case catch util:to_list(charge_handler:get_list_value(<<"code">>, ParamInfoList)) of
        % url path中不存在code
        {'EXIT', {param_type_error, _}} ->
            case catch util:to_list(charge_handler:get_list_value(<<"token">>, ParamInfoList)) of
                % url path中不存在token
                {'EXIT', {param_type_error, _}} ->
                    % /oauth/token的url path中既不存在code也不存在token 返回参数出错
                    exit({param_type_error, wrong_param});
                OldToken ->
                    %% 刷新token
                    case util_token:chk_token(list_to_binary(OldToken), list_to_binary(?KEY)) of
                        {ok, _MapData} ->
                            {ok, [{'token', OldToken}]};
                        invalid_signature ->
                            ?ERROR("jwt invalid_signature"),
                            exit(unauthorized);
                        expired ->
                            ?ERROR("jwt expired"),
                            Res = ets:tab2list(?ETS_OAUTH_STATE_JWT),
                            ?ERROR("Res: ~p", [Res]),
                            tailRecursiveTokenList(OldToken, Res)
                    end
            end;
        % url path中存在code
        Code ->
            Res = ?TRY_CATCH(ets:lookup_element(?ETS_OAUTH_STATE_JWT, Code, #ets_oauth_state_jwt.jwt)),
            if
                is_list(Res) ->
                    [Token] = Res,
                    ?DEBUG("code: ~p, Token: ~p", [Code, Token]),
                    {ok, [{'token', Token}]};
                true ->
                    exit(unauthorized)
            end
    end;
path_request(<<"/player/characters">>, <<"GET">>, _Ip, Req) -> % 获取指定账号下的角色列表
    % 校验token
    ?DEBUG("Req: ~p", [Req]),
    case chk_token(Req) of
        {'exit', unauthorized} ->
            exit(unauthorized);
        {'exit', access_denied} ->
            exit(access_denied);
        MapData ->
            MapDataList = maps:to_list(MapData),
            Platform = case lists:keysearch(<<"platform_id">>, 1, MapDataList) of
                           false ->
                               exit(file_not_found);
                           {value, {_, BinaryPlatformName}} ->
                               erlang:binary_to_list(BinaryPlatformName)
                       end,
            AccId = case lists:keysearch(<<"acc_id">>, 1, MapDataList) of
                        false ->
                            exit(file_not_found);
                        {value, {_, BinaryAccId}} ->
                            erlang:binary_to_list(BinaryAccId)
                    end,
            Code = encrypt:md5(Platform ++ AccId),
            RecentServerList = ets:lookup_element(?ETS_OAUTH_STATE_JWT, Code, #ets_oauth_state_jwt.recentServerList),
            ?DEBUG("RecentServerList: ~p", [RecentServerList]),
            [ServerList] = RecentServerList,
            Characters = lists:filtermap(
                fun(ServerId) ->
                    %% 检查玩家账号
                    case mod_server_rpc:call_game_server(
                        Platform, ServerId, mod_player, get_player_by_server_id_and_acc_id, [ServerId, AccId], 5000) of
                        {badrpc, nodedown} ->
                            false;
                        null ->
                            false;
                        R ->
                            #db_player{
                                id = PlayerId,                        %% int 玩家id
                                acc_id = _DataAccId,                  %% string 平台帐号
                                server_id = DataServerId,             %% string 服务器ID
                                nickname = Nickname,                  %% string 昵称
                                sex = Sex,                            %% int 性别, 0:男 1:女
                                forbid_type = Status,                 %% int 封禁类型[1:禁言 2:封号]
                                reg_time = RegTime                   %% int 注册时间
                            } = R,
                            Icon = ?AVATAR_ICON_URL(Platform) ++ ?IF(Sex == 0, "", "wo") ++ "man_1.png",
                            {true, #{game => list_to_binary(?GAME_NAME), game_icon => util:to_atom(?GAME_ICON),
                                icon => util:to_atom(Icon), name => list_to_binary(Nickname),
                                character => PlayerId, sex => Sex,
                                server => list_to_binary(DataServerId), time => RegTime,
                                status => Status, region => list_to_binary("taiwan")}
                            }
                    end
                end,
                ServerList
            ),
            {ok, #{error => 0, msg => 'success', result => Characters}}
    end;
% 返回
path_request(<<"/character/items">>, <<"GET">>, _Ip, Req) -> % 获取指定角色下的物品
    % 校验token
    case chk_token(Req) of
        {'exit', unauthorized} ->
            exit(unauthorized);
        {'exit', access_denied} ->
            exit(access_denied);
        MapData ->
            MapDataList = maps:to_list(MapData),
            Platform =
                case lists:keysearch(<<"platform_id">>, 1, MapDataList) of
                    false ->
                        exit(file_not_found);
                    {value, {_, BinaryPlatformName}} ->
                        erlang:binary_to_list(BinaryPlatformName)
                end,
            AccId = case lists:keysearch(<<"acc_id">>, 1, MapDataList) of
                        false ->
                            exit(file_not_found);
                        {value, {_, BinaryAccId}} ->
                            erlang:binary_to_list(BinaryAccId)
                    end,
            PlayerId = erlang:binary_to_integer(cowboy_req:binding(id, Req)),
            {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
            Server = util:to_list(charge_handler:get_list_value(<<"server">>, ParamInfoList)),
            %% 检查玩家账号
            PlayerInfo = mod_server_rpc:call_game_server(Platform, Server, mod_player, get_player_by_server_id_and_acc_id, [Server, AccId], 5000),
            ?ASSERT(is_record(PlayerInfo, db_player), ?ERROR_NO_ROLE),
            #db_player{
                id = MatchPlayerId
            } = PlayerInfo,
            ?DEBUG("PlayerId: ~p", [[PlayerId, MatchPlayerId, MatchPlayerId =:= PlayerId]]),
            ?ASSERT(MatchPlayerId =:= PlayerId, invalid_operation),
            PropIdIconListTuple = lists:sort([{PropId, Icon, PropType, Name} || {PropId, {_, PropType, Icon, Name}} <- logic_get_can_be_traded_items:get(?TRUE)]),
            ?DEBUG("PropIdIconListTuple: ~p", [PropIdIconListTuple]),
            ?ASSERT(length(PropIdIconListTuple) > 0, file_not_found),
            Items = lists:filtermap(
                fun(PropElement) ->
                    {PropId, Icon, _, Name} = PropElement,
                    PlayerProps = mod_server_rpc:call_game_server(Platform, Server, mod_prop, get_player_prop, [PlayerId, PropId]),
                    #db_player_prop{
                        num = PlayerPropNum,
                        expire_time = ExpireTime
                    } = PlayerProps,
                    ?DEBUG("PlayerProps: ~p", [PlayerProps]),
                    if
                        ExpireTime == 0 andalso PlayerPropNum > 0 ->
                            ItemIcon = ?ITEM_ICON_URL(Platform) ++ integer_to_list(Icon) ++ ".png",
%%                            {true, {PropId, [
%%                                {'id', PropId},  %% 物品id
%%                                {'icon', ItemIcon},    %% 物品icon
%%                                {'name', Name},        %% 物品名称
%%                                {'num', PlayerPropNum} %% 物品数量
%%                            ]}};
                            {true, #{id => PropId, icon => util:to_atom(ItemIcon),
                                name => list_to_binary(Name), num => PlayerPropNum}};
                        true ->
                            false
                    end
                end,
                PropIdIconListTuple
            ),
            {ok, #{error => 0, msg => 'success', result => Items}}
%%            {ok, [{error, 0}, {msg, ""}, {result, Items}]}
    end;
path_request(<<"/item/modify">>, <<"PUT">>, Ip, Req) -> % 给指定玩家增加/减少指定道具
    % 校验token
    case chk_token(Req) of
        {'exit', unauthorized} ->
            exit(unauthorized);
        {'exit', access_denied} ->
            exit(access_denied);
        MapData ->
            PropId = binary_to_integer(cowboy_req:binding(id, Req)),
            ?DEBUG("PropId: ~p", [PropId]),
            {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
            ?DEBUG("ParamInfoList: ~p", [ParamInfoList]),
            % {ok, tuple_list}
            MapDataList = maps:to_list(MapData),
            %% amount ordersn(primary key) playerid created_at ip
            Platform = case lists:keysearch(<<"platform_id">>, 1, MapDataList) of
                           false ->
                               exit(file_not_found);
                           {value, {_, BinaryPlatformName}} ->
                               binary_to_list(BinaryPlatformName)
                       end,
            PlayerId = util:to_int(charge_handler:get_list_value(<<"player_id">>, ParamInfoList)),
            Server = util:to_list(charge_handler:get_list_value(<<"server">>, ParamInfoList)),
%%            PropType = util:to_int(charge_handler:get_list_value(<<"prop_type">>, ParamInfoList)),
%%            PropId = util:to_int(charge_handler:get_list_value(<<"id">>, ParamInfoList)),
            Type = util:to_int(charge_handler:get_list_value(<<"type">>, ParamInfoList)),
            Num = util:to_int(charge_handler:get_list_value(<<"num">>, ParamInfoList)),
            Amount = util:to_float(charge_handler:get_list_value(<<"amount">>, ParamInfoList)),

%%            IsRobot = mod_server_rpc:call_game_server(Platform, Server, mod_player, is_robot_player_id, [PlayerId]),
            ?ASSERT(PlayerId > 10000, invalid_operation),
            %% 检查玩家是否在线
            IsOnline = mod_server_rpc:call_game_server(Platform, Server, mod_online, is_online, [PlayerId]),
            ?ASSERT(IsOnline =:= false, ?ERROR_FAIL),

            Vip = mod_server_rpc:call_game_server(Platform, Server, mod_vip, get_vip_level, [PlayerId]),
            ?ASSERT(Vip >= 0, invalid_operation),
            %% 校验玩家是否持有该物品
            PlayerPropInfo = mod_server_rpc:call_game_server(Platform, Server, mod_prop, get_player_prop, [PlayerId, PropId]),
            ?ASSERT(is_record(PlayerPropInfo, db_player_prop), invalid_operation),
            #db_player_prop{
                num = PropNum
            } = PlayerPropInfo,
            OrderId = util:to_list(charge_handler:get_list_value(<<"order_sn">>, ParamInfoList)),
            ?DEBUG("orderId: ~p ~p", [OrderId, PlayerPropInfo]),
            if
                PropNum < Num andalso Type == 0 ->
                    ?DEBUG("数量不足以扣除: ~p ~p", [PropNum, Num]),
                    exit(invalid_operation);
                true ->
                    %% 检查订单是否存在
                    Fun =
                        fun() ->
                            case mod_server_rpc:call_game_server(Platform, Server, mod_player, get_player, [util:to_int(PlayerId)]) of
                                {badrpc, Reason} ->
                                    ?ERROR("badrpc: ~p", [Reason]),
                                    exit(log_error);
                                Result ->
                                    #db_player{
                                        type = PlayerType,
                                        forbid_type = ForbidType
                                    } = Result,

                                    %% 非普通账号或被封禁账号，禁止发起装备回收 报错unavailable_account
                                    ?ASSERT(?IS_DEBUG =:= true orelse (PlayerType =:= 0 andalso ForbidType =/= 2), unavailable_account),
                                    ?DEBUG("ddd: ~p ~p ~p", [PlayerId, ?FUNCTION_DRAW_MONEY, mod_function:is_open(util:to_int(PlayerId), ?FUNCTION_DRAW_MONEY)]),

                                    ?ASSERT(mod_server_rpc:call_game_server(Platform, Server, mod_function, is_open, [util:to_int(PlayerId), ?FUNCTION_DRAW_MONEY]), vip_limit),
                                    LeftTimes = mod_server_rpc:call_game_server(Platform, Server, mod_times, get_left_times, [util:to_int(PlayerId), ?TIMES_DRAW_MONEY]),
                                    ?ASSERT(LeftTimes >= 0, ?ERROR_TIMES_LIMIT)
                            end,
                            {GoldNumber, NewStatusInDb, BuyerPlayerId} =
                                case Type of
                                    2 ->
                                        ?DEBUG("type=2 表明订单不存在 是要创建订单，此时status为2"),
                                        Status = 2,
                                        db:write(#db_oauth_order_log{
                                            order_id = OrderId,
                                            player_id = PlayerId,
                                            prop_id = PropId,
                                            amount = Amount,
                                            ip = Ip,
                                            change_type = 0,
                                            status = Status,
                                            change_num = Num,
                                            create_time = util_time:timestamp()
                                        }),
                                        {Num, Status, 0};
                                    1 ->
                                        ?DEBUG("订单已经存在 type=1表明要修改订单的status为0。"),
                                        OldOrderInfo = db:read(#key_oauth_order_log{order_id = OrderId}),
                                        #db_oauth_order_log{
                                            change_type = OldType,
                                            status = OldStatusInDb,
                                            change_num = ReturnNum,
                                            buyer_player_id = OldBuyerPlayerId
                                        } = OldOrderInfo,
                                        ?ASSERT(OldStatusInDb =:= 2, invalid_operation),
                                        ?ASSERT(OldType =:= 0, invalid_operation),
                                        NewStatusIntoDb = 0,
                                        NewData = OldOrderInfo#db_oauth_order_log{
                                            change_type = Type,
                                            status = NewStatusIntoDb
                                        },
                                        ?DEBUG("NewData: ~p", [NewData]),
                                        db:write(NewData),

                                        ?INFO("~p return money: ~p", [PlayerId, Num]),
                                        {ReturnNum, NewStatusIntoDb, ?IF(OldBuyerPlayerId =:= 0, 0, OldBuyerPlayerId)};
                                    0 ->
                                        BuyerPlayerIdInQuery = util:to_int(charge_handler:get_list_value(<<"buyer_id">>, ParamInfoList)),
                                        ?DEBUG("订单已经存在 type=0表明要修改订单的status为1。此时买家卖家分别为~p和~p", [PlayerId, BuyerPlayerIdInQuery]),
                                        OrderOrderInfo = db:read(#key_oauth_order_log{order_id = OrderId}),
                                        ?DEBUG("OrderOrderInfo: ~p", [OrderOrderInfo]),
                                        #db_oauth_order_log{
                                            change_type = OldType,
                                            status = OldStatusInDb,
                                            buyer_player_id = OldBuyerPlayerId
                                        } = OrderOrderInfo,
                                        ?ASSERT(OldStatusInDb =:= 2, invalid_operation),
                                        ?ASSERT(OldType =:= 0, invalid_operation),
                                        ?ASSERT(OldBuyerPlayerId =:= 0, invalid_buyer_player),
                                        NewStatusIntoDb = 1,
                                        NewData = OrderOrderInfo#db_oauth_order_log{
                                            change_type = Type,
                                            status = NewStatusIntoDb,
                                            buyer_player_id = BuyerPlayerIdInQuery
                                        },
                                        ?DEBUG("NewData: ~p", [NewData]),
                                        db:write(NewData),
                                        {Num, NewStatusIntoDb, BuyerPlayerIdInQuery}
                                end,

                            ?DEBUG("NewStatusInDb: ~p ~p)", [NewStatusInDb, {PlayerId, BuyerPlayerId}]),
                            case NewStatusInDb of
                                2 ->
                                    ?INFO("222: ~p", [[PlayerId, [{PropId, GoldNumber}], ?LOG_TYPE_TI_XIAN]]),
                                    case mod_server_rpc:call_game_server(Platform, Server, mod_prop, decrease_player_prop, [PlayerId, [PropId, GoldNumber], ?LOG_TYPE_TI_XIAN]) of
                                        {badrpc, Err} -> {'EXIT', _} = Err, exit(invalid_operation);
                                        F -> ?DEBUG("Type: ~p SUCCESS: ~p", [NewStatusInDb, F])
                                    end;
                                0 ->
                                    ?INFO("000: ~p", [[PlayerId, [{PropId, GoldNumber}], ?LOG_TYPE_TI_XIAN]]),
                                    case mod_server_rpc:call_game_server(Platform, Server, mod_award, give, [PlayerId, [PropId, GoldNumber], ?LOG_TYPE_TI_XIAN]) of
                                        {badrpc, Err} -> {'EXIT', _} = Err, exit(invalid_operation);
                                        Res4Give -> ?DEBUG("Type: ~p SUCCESS: ~p", [NewStatusInDb, Res4Give])
                                    end;
                                1 ->
                                    case mod_server_rpc:call_game_server(Platform, Server, handle_goldcoin, after_withdraw, [PlayerId, Amount]) of
                                        {badrpc, Err} -> {'EXIT', _} = Err, exit(invalid_operation);
                                        Res4AfterWithdraw -> ?DEBUG("Type: ~p SUCCESS: ~p", [NewStatusInDb, Res4AfterWithdraw])
                                    end,
                                    case mod_server_rpc:call_game_server(Platform, Server, mod_award, give, [BuyerPlayerId, [PropId, GoldNumber], ?LOG_TYPE_TI_XIAN]) of
                                        {badrpc, Err2} -> {'EXIT', _} = Err2, exit(invalid_operation);
                                        Res4Give -> ?DEBUG("Type: ~p SUCCESS: ~p", [NewStatusInDb, Res4Give])
                                    end,
                                    ?INFO("OrderSn: ~p SUCCESS", [OrderId])
                            end,
                            mod_server_rpc:call_game_server(Platform, Server, api_shop, notice_player, [PlayerId, NewStatusInDb])
                        end,
                    Res = db:do(Fun),
                    ?DEBUG("Res: ~p", [Res])
            end,
            {ok, [{error, 0}, {msg, "success"}]}
    end.

get_yaml_file(_FileName) ->
    Res = case filelib:is_file(?OAUTH_CLIENT_INFO) of
              false ->
                  ?ERROR("读取第三方授权登录的client_id和client_secret文件时报错: 文件不存在"),
                  exit(file_not_found);
              true ->
                  FileSize = filelib:file_size(?OAUTH_CLIENT_INFO),
                  if
                      FileSize > 0 ->
                          {ok, File} = file:open(?OAUTH_CLIENT_INFO, [raw, binary]),
                          case file:read(File, filelib:file_size(?OAUTH_CLIENT_INFO)) of
                              {ok, _} -> yaml:parse_file(?OAUTH_CLIENT_INFO);
                              {Other} ->
                                  ?ERROR("读取第三方授权登录的client_id和client_secret文件时报错: ~p", [Other]),
                                  exit(file_not_found)
                          end;
                      true ->
                          ?ERROR("读取第三方授权登录的client_id和client_secret文件时报错: 文件大小小于等于0"),
                          exit(file_not_found)
                  end
          end,
    Res.

%%gen_token(ParamList) ->
%%    ?DEBUG("(~p) gen Token ParamList", [ParamList]),
%%    util_token:get_token(ParamList).
chk_token(Req) ->
    Headers = cowboy_req:headers(Req),
    % 此处需要校验Token的有效性
    ?DEBUG("(~p) check Token ~p", [cowboy_req:path(Req), Headers]),
    Token = ?IF(maps:is_key(list_to_binary("authorization"), Headers),
        maps:get(list_to_binary("authorization"), Headers),
        access_denied),
    ?DEBUG("Token: ~p", [util_token:chk_token(Token, ?KEY)]),
    if
        Token == access_denied ->
            exit(access_denied);
        true ->
            case util_token:chk_token(Token, ?KEY) of
                {ok, MapData} ->
                    % token 验证成功
                    ?DEBUG("valid token: ~p", [[is_map(MapData), maps:to_list(MapData)]]),
                    MapData;
                invalid_signature ->
                    ?ERROR("jwt invalid_signature"),
                    exit(unauthorized);
                expired ->
                    ?ERROR("jwt expired"),
                    exit(unauthorized)
            end
    end.

get_req_param_str(_Req) ->
    ok.

tailRecursiveTokenList(_OldToken, []) ->
    exit(file_not_found);
tailRecursiveTokenList(OldToken, [Ele | List]) ->
    #ets_oauth_state_jwt{
        code = Code,
        platformId = Platform,
        accId = AccId,
        jwt = Token,
        recentServerList = _RecentServerList
    } = Ele,
    ?INFO("ets token: ~p client token: ~p is equal: ~p code: ~p", [Token, OldToken, Token =:= OldToken, Code]),
    if
        Token =:= OldToken ->
            % 重新生成token
            Chaim = [
                {<<"iss">>, "gasdasda"},
                {<<"platform_id">>, list_to_binary(Platform)},
                {<<"acc_id">>, list_to_binary(AccId)}
            ],
            NewToken = util_token:get_token(<<"HS256">>, Chaim, list_to_binary(?KEY), ?JWT_EXPIRE),
            % 删除掉旧的ets数据
            ets:delete(?ETS_OAUTH_STATE_JWT, Code),
            % 重新插入ets数据
            NewEle = Ele#ets_oauth_state_jwt{jwt = binary_to_list(NewToken)},
            ets:insert_new(?ETS_OAUTH_STATE_JWT, NewEle),
            ?INFO("Element: ~p", [ets:lookup_element(?ETS_OAUTH_STATE_JWT, Code, #ets_oauth_state_jwt.jwt)]),
            ?INFO("new Token: ~p", [binary_to_list(NewToken)]),
            {ok, [{'token', binary_to_list(NewToken)}]};
        true ->
            ?ERROR("Token =/= ClientToken"),
            tailRecursiveTokenList(OldToken, List)
    end.
