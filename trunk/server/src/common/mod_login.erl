%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             登录模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:48
%%%-------------------------------------------------------------------
-module(mod_login).
-include("common.hrl").
-include("system.hrl").
-include("gen/db.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("gen/table_enum.hrl").
-include("client.hrl").
-export([login/6]).
-export([
    privilegeLogin/2,
    privilegeAwardGive/1
]).
-export([get_channel_by_account_platform/2]).
-export([
    chk_player_heartbeat_valid/4,
    get_player_heartbeat_code/3,
    player_kick_out/1
]).

-define(CLOSE_CHANNEL_LIST, []).

%% ----------------------------------
%% @doc 	测试服，特权账号新增指定物品
%% @throws 	none
%% @end
%% ----------------------------------
privilegeAwardGive(PlayerId) ->
    [AwardList, [task, TaskId]] = ?SD_GAO_JI_HAO,
    lists:foreach(
        fun([PropId, Num]) ->
            ?INFO("PremiumAccount: ~p", [{PlayerId, {PropId, Num},
                mod_award:give(PlayerId, [PropId, Num], ?LOG_TYPE_CESHI)}])
        end,
        AwardList
    ),
    mod_task:debug_set_task(PlayerId, TaskId).

%% ----------------------------------
%% @doc 	测试服，特权账号登录
%% @throws 	none
%% @end
%% ----------------------------------
privilegeLogin(PlatformId, AccId) ->
    ValidAccountList =
        case mod_server_rpc:call_center(ets, tab2list, [?ETS_TEST_ACCOUNT]) of
            L when is_list(L) ->
                lists:filtermap(
                    fun(TestAccountInCenterEts) ->
                        #ets_test_account{
                            account = AccountInEts,
                            privilege = IsPrivilege
                        } = TestAccountInCenterEts,
%%                        ?DEBUG("TestAccount: ~p", [{AccountInEts, AccId, AccountInEts =:= AccId}]),
                        ?IF(AccountInEts =:= AccId, {true, {AccId, util:to_int(IsPrivilege)}}, false)
                    end,
                    L
                );
            O -> ?ERROR("非预期情况: ~p", [O]), []
        end,
    ValidAccountInEtsLength = length(ValidAccountList),
    ?INFO("length(ValidAccountList): ~p", [{ValidAccountInEtsLength, ValidAccountList}]),
    ?INFO("Privilege?: ~p", [{ValidAccountInEtsLength =/= 0, ValidAccountInEtsLength > 0, ?IS_DEBUG =:= false, PlatformId, PlatformId =:= "test"}]),
    if
    %% 测试服，判断是否为测试账号
        PlatformId =:= "test" ->
            if
                ValidAccountInEtsLength > 0 ->
                    TmpAccIdList = ValidAccountList,
                    TmpAccIdList2 = [{"longge", 1}, {"wangy", 1}, {"zhengjh", 1}, {"qq01", 1}, {"huahua", 1}, {"daxiong", 1}],
                    TmpAccIdList3 = TmpAccIdList ++ TmpAccIdList2,
                    TmpAccIdList4 =
                        lists:filtermap(
                            fun(Ele) ->
                                {true, {"tingting" ++ util:to_list(Ele), 1}}
                            end,
                            lists:seq(1, 10)
                        ),
                    TmpAccIdList5 = TmpAccIdList3 ++ TmpAccIdList4,
                    Privilege =
                        lists:filtermap(
                            fun({MatchAccId, MatchIsPrivilege}) ->
                                if
                                    MatchAccId =:= AccId ->
                                        {true, {MatchAccId, MatchIsPrivilege}};
                                    true -> false
                                end
                            end,
                            TmpAccIdList5
                        ),
                    ?INFO("Privilege: ~p", [{Privilege, length(Privilege)}]),
                    P = length(Privilege),
                    if
                        P =:= 1 ->
                            {_, IsPrivilegeAccount} = hd(Privilege),
                            ?IF(IsPrivilegeAccount =:= 1, ?TRUE, ?FALSE);
                        true -> 2
                    end;
                true -> 2
            end;
        true -> ?FALSE
    end.

%% ----------------------------------
%% @doc 	登录
%% @throws 	none
%% @end
%% ----------------------------------
login(ServerId, AccId, Ticket, Time, State = #conn{ip = _Ip}, IsGmLogin) ->
    Now = util_time:timestamp(),
    ?ASSERT(length(AccId) > 0),

    PlatformId = mod_server_config:get_platform_id(),
    if IsGmLogin == false ->
        CheckLoginStatus =
            if
                PlatformId == ?PLATFORM_LOCAL orelse PlatformId == ?PLATFORM_TEST ->
                    %% 内网/测试
                    true;
                true ->
                    %% 其他走通用的登录(登录服生产登录密钥， 游戏服校验)
                    login_server:valid_login_ticket(AccId, Time, Ticket)
            end,

        %% 真实玩家与内部账号登陆时，新增服务器状态判断，
        %% 若服务器状态为“维护”，则不允许登录
        case mod_server_rpc:call_center(mod_server, chk_game_server_state, [PlatformId, ServerId]) of
            IsMaintenance when is_integer(IsMaintenance) ->
                ?ASSERT(IsMaintenance =/= 1, ?CSR_SYSTEM_MAINTENANCE)
        end,

        %% 校验登录态
        ?ASSERT(CheckLoginStatus, ?ERROR_VERIFY_FAIL);
        true ->
            noop
    end,

    %% check ip
    %% 暂时注释 防止外网无法登录 2020-12-26
%%    IsValidIp = mod_ip:is_valid_ip(Ip),
%%    if IsValidIp =:= logout
%%        ->
%%        exit(?ERROR_INVALID_IP);
%%        true ->
%%            ok
%%    end,

    %% 校验帐号封禁状态
    ?ASSERT(mod_global_account:is_can_login(PlatformId, AccId), ?ERROR_DISABLE_LOGIN),
    ?ASSERT(lists:member(get(?DICT_CHANNEL), ?CLOSE_CHANNEL_LIST) == false, ?ERROR_DISABLE_LOGIN),

    case mod_player:get_player_by_server_id_and_acc_id(ServerId, AccId) of
        null ->     %% 区服新玩家
            NewState =
                State#conn{
                    status = ?CLIENT_STATE_WAIT_CREATE_ROLE,
                    login_time = Now,
                    acc_id = AccId,
                    server_id = ServerId
                },
            hook:after_register(NewState),
            % 等待创建角色
            {
                NewState,
                ?P_NO_ROLE
            };
        Player ->
            %% 校验角色封禁状态
            ?ASSERT(mod_player:is_can_login(Player), ?ERROR_DISABLE_LOGIN),
            % 2秒内不能重复登录
            ?ASSERT(Now > Player#db_player.last_login_time + 2 orelse Player#db_player.last_login_time > Now, ?ERROR_LOGIN_FREQUENT),
            PlayerId = Player#db_player.id,

            NewState = State#conn{
                player_id = PlayerId,
                acc_id = AccId,
                status = ?CLIENT_STATE_WAIT_ENTER_GAME,
                login_time = Now,
                server_id = ServerId
            },
            hook:after_login(NewState),
            % 等待进入游戏
            {NewState, ?P_SUCCESS}
    end.

%% ----------------------------------
%% @doc 	玩家登录时，获取其所使用的包隶属于那个渠道 在中心服
%% @throws 	none
%% @end
%% ----------------------------------
get_channel_by_account_platform(PlatformId, AccId) ->
    %% 到登陆服，通过账号信息获取app_id
    LoginServerNode = mod_server_config:get_login_server_node(),
    RealAppId =
        if
            PlatformId =:= ?PLATFORM_LOCAL orelse PlatformId =:= ?PLATFORM_TEST ->
                "com.tb.custom.test";
            true ->
                {_Promote, AppId, _Region, _RegistrationId} = rpc:call(util:to_atom(LoginServerNode),
                    mod_global_account, get_login_cache_from_login_server, [AccId]),
                AppId
        end,
    ?DEBUG("AccId: ~p", [RealAppId]),
    %% 到中心服，通过app_id获取对应channel
    case mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, RealAppId]) of %% todo
        L when is_list(L) andalso length(L) =:= 1 ->
            #ets_erget_setting{channel = Channel} = hd(L),
            Channel;
        Err ->
            ?ERROR("通过app id获取指定渠道时失败: ~p", [Err]),
            exit(invalid_app_id)
    end.

get_player_heartbeat_code(PlatformId, ServerId, PlayerId) ->
    [StartTimestamp, _] = get_client_heartbeat_verify_data(PlatformId, ServerId),
    Current = util_time:timestamp(),
    Original = Current - StartTimestamp + PlayerId,
    Encode =
        try mod_unique_invitation_code:encode1(Original)
        catch
            _:_Reason_ ->
                ?ERROR(
                    "Try catch ->~n"
                    "     reason:~p~n"
                    " stacktrace:~p"
                    , [_Reason_, erlang:get_stacktrace()]),
                exit(invalid_code)
        end,
    ?DEBUG("Encode: ~p", [Encode]),
    base64:encode(Encode).

%% ----------------------------------
%% @doc 	把玩家踢下线
%% @throws 	none
%% @end
%% ----------------------------------
player_kick_out(PlayerId) ->
    case mod_obj_player:get_obj_player(PlayerId) of
        null ->
            noop;
        ObjPlayer ->
            #ets_obj_player{
                client_worker = ClientWorker
            } = ObjPlayer,
            client_worker:kill_async(ClientWorker, ?CSR_SYSTEM_MAINTENANCE)
    end.

%% ----------------------------------
%% @doc 	检查指定平台，指定区服，指定玩家的心跳协议上报加密字符串是否有效
%% @throws 	none
%% @end
%% ----------------------------------
chk_player_heartbeat_valid(PlatformId, ServerId, PlayerId, Code) ->
    State = mod_server:chk_game_server_state(PlatformId, ServerId),
    ?DEBUG("code： ~p", [State]),
    ?ASSERT(State =/= 1, invalid_game_server_state),
    ?ASSERT(Code =/= ?UNDEFINED, invalid_heartbeat_code),
    ?ASSERT(Code =/= [], empty_heartbeat_code),
    Decode =
        try mod_unique_invitation_code:decode1(util:to_list(base64:decode(Code)))
        catch
            _:_Reason_ ->
                ?ERROR(
                    "Try catch ->~n"
                    "     reason:~p~n"
                    " stacktrace:~p"
                    , [_Reason_, erlang:get_stacktrace()]),
                exit(invalid_code)
        end,
    CurrentTimestamp = util_time:timestamp(),

    [StartTimestamp, Expire] = get_client_heartbeat_verify_data(PlatformId, ServerId),
    R = Decode - PlayerId + StartTimestamp,
    ?DEBUG("R: ~p", [{R, Expire, CurrentTimestamp, CurrentTimestamp - R =< Expire}]),
    case CurrentTimestamp - R =< Expire of
        false -> 1;
        true -> State
    end.


get_client_heartbeat_verify_data(PlatformId, ServerId) ->
    case ets:lookup(?ETS_CLIENT_HEARTBEAT_VERIFY, {PlatformId, ServerId}) of
        [R] when is_record(R, ets_client_heartbeat_verify) ->
            [R#ets_client_heartbeat_verify.start_time, R#ets_client_heartbeat_verify.expire];
        O ->
            ?WARNING("中心服ets中没有客户端心跳验证数据: ~p", [O]),
            [util_time:datetime_to_timestamp([{2021, 9, 1}, {0, 0, 0}]), 100]
    end.

%% ----------------------------------
%% @doc 	验证密钥
%% @throws 	none
%% @end
%% ----------------------------------
%%-ifdef(debug).
%%verify_ticket(AccId, LoginType, ServerId, Ticket) ->
%%   ok.
%%-else.
%%verify_ticket(AccId, LoginType, ServerId, Ticket) -> noop.
%%    ?DEBUG("验证密钥:~p~n", [{AccId, LoginType, ServerId, Ticket}]),
%%    Result = rpc:call(mod_server_config:get_login_server_node(), login_server, login, [AccId, ServerId, Ticket]),
%%    if Result == true ->
%%        ok;
%%        true ->
%%            exit({login_fail, Result})
%%    end.
%%    Method = get,
%%    GameKey = ?GAME_KEY,
%%    Timestamp = util_time:timestamp(),
%%    Nonce = util_string:random_string(6),
%%    SignArgs = mod_signature:sign([
%%        {"game_key", GameKey},
%%        {"timestamp", Timestamp},
%%        {"nonce", Nonce},
%%        {"login_type", LoginType},
%%        {"login_ticket", Ticket}
%%    ], "signature"),
%%    URL = "https://gc.hgame.com/user/getticketuserinfo?" ++ SignArgs,
%%    Header = [
%%        {"accept", "application/json"}
%%    ],
%%    HTTPOptions = [],
%%    Options = [],
%%    ?DEBUG("URL:~p~n", [URL]),
%%    case httpc:request(Method, {URL, Header}, HTTPOptions, Options) of
%%        {error, Reason} ->
%%            io:format("error:~p", [Reason]),
%%            false;
%%        {ok, {_, _, Result}} ->
%%            io:format("Result:~p~n", [Result]),
%%            io:format("Json:~p~n", [jsone:decode(util:to_binary(Result))])
%%    end.
%%    Method = get,
%%    GameKey = ?GAME_KEY,
%%    Timestamp = util_time:timestamp(),
%%    Nonce = util_string:random_string(6),
%%    IdCard = "666",
%%    URL = "https://gc.hgame.com/user/getticketuserinfo?key=" ++ Key ++ "&realname=" ++ Name ++ "&idcard=" ++ IdCard,
%%    Header = [
%%        {"accept", "application/json"}
%%    ],
%%    HTTPOptions = [],
%%    Options = [],
%%    ?DEBUG("~p~n", [URL]),
%%    case httpc:request(Method, {URL, Header}, HTTPOptions, Options) of
%%        {error, Reason} ->
%%            io:format("error:~p", [Reason]),
%%            false;
%%        {ok, {_, _, Result}} ->
%%            io:format("Result:~p~n", [Result]),
%%            io:format("Json:~p~n", [jsone:decode(util:to_binary(Result))])
%%    end.
%%    DiffTime = abs(Now - Time),
%%    if
%%        DiffTime < 900 ->
%%            A =
%%                lists:append(
%%                    [
%%                            "partid=" ++ integer_to_list(PlatformId),
%%                            "&sid=" ++ ServerId,
%%                            "&uid=" ++ AccId,
%%                            "&ftime=" ++ integer_to_list(Time),
%%                            "&indulge=" ++ integer_to_list(IsPassedFcm),
%%                            "&client=" ++ integer_to_list(IsMicro)
%%                    ]
%%                ),
%%
%%            B = binary_to_list(base64:encode(A)) ++ ?LOGIN_KEY,
%%
%%            Sign = md5:make(B),
%%
%%            if Token == Sign ->
%%                ok;
%%                true ->
%%                    ?ERROR("verify_token:~p~n", [{Now, PlatformId, ServerId, AccId, Time, IsPassedFcm, IsMicro, Token, Sign, A}]),
%%                    exit(?ERROR_VERIFY_FAIL)
%%            end;
%%        true ->
%%            exit(?ERROR_TOKEN_EXPIRE)
%%    end.
%%-endif.
