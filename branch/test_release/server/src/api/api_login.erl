%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(api_login).

-include("common.hrl").
-include("p_message.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("socket.hrl").
-include("client.hrl").
-include("gen/table_enum.hrl").
-include("player_game_data.hrl").
-include("gen/db.hrl").
%% API
-export([
    login/2,
    create_role/2,
    enter_game/2,
    heart_beat/2,
    get_random_name_list/2
]).

-export([
    notice_logout/2,
    get_platform_open_id/2, % 获得平台的openId
    get_acc_id/2,
    get_acc_id/3
]).

get_acc_id(OpenId, Platform) ->
    PlatformId = mod_server_config:get_platform_id(),
    get_acc_id(PlatformId, OpenId, Platform).

get_acc_id(_PlatformId, OpenId, _Platform) ->
    if
%%        PlatformId == ?PLATFORM_QQ  ->
%%        %% 玩吧平台 安卓 ios 数据不互通
%%        if Platform == 1 ->
%%            "android_" ++ OpenId;
%%            Platform == 2 ->
%%                "ios_" ++ OpenId;
%%            true ->
%%                exit({platform_error, Platform})
%%        end;
        true ->
            OpenId
    end.

%% @doc fun 获得平台的openId
get_platform_open_id(_PlatformId, AccId) ->
    if
%%        PlatformId == ?PLATFORM_QQ ->
%%            lists:foldl(
%%                fun({Platform, Len}, OpenId1) ->
%%                    case string:str(OpenId1, Platform) of
%%                        1 ->
%%                            string:substr(OpenId1, Len + 1);
%%                        _ ->
%%                            OpenId1
%%                    end
%%                end, AccId, [{"android_", 8}, {"ios_", 4}]);
        true ->
            AccId
    end.


%% ----------------------------------
%% @doc 	登录
%% @throws 	none
%% @end
%% ----------------------------------
login(
    Msg,
    State = #conn{ip = Ip, socket = Socket, socket_mod = SocketMod, status = Status}
) ->
    ?DEBUG("ip: ~p Enter Game Socket: ~p ~p", [Ip, Socket, Status]),
    ?DEBUG("SocketMod: ~p", [SocketMod]),
    ?DEBUG("Msg: ~p", [Msg]),
    #m_login_login_tos{
        acc_id = OpenId0,
        server_id = ServerId,
        login_type = LoginType,
        ticket = Ticket,
        pf = Pf,
        platform = Platform,
        entry = Entry,
        qua = Qua,
        time = Time,
        platform_id = P,
        via = Via,
%%        is_gm_login = IsGmLogin,
        gm_account = GmAccount
    } = Msg,
    IsGmLogin = GmAccount =/= <<>>,
%%    ?INFO("(~p)登录:~p,~p", [Ip, Msg, IsGmLogin]),
    PlatformId = mod_server_config:get_platform_id(),

    {AccId, OpenId} =
        if IsGmLogin ->
            %% gm 登录
            ?INFO("判断是否为gm账号:~p~n", [global_account_srv:get_global_account(PlatformId, get_acc_id(util:to_list(OpenId0), Platform))]),
            ?ASSERT(mod_global_account:is_gm_account(PlatformId, get_acc_id(util:to_list(OpenId0), Platform))),
            {util:to_list(GmAccount), GmAccount};
            true ->
                {get_acc_id(util:to_list(OpenId0), Platform), OpenId0}
        end,
    %% 判断是否为gm账号
    IsGmLogin1 = mod_global_account:is_gm_account(PlatformId, get_acc_id(util:to_list(OpenId0), Platform)),
    ?DEBUG("判断是否为gm账号: ~p", [IsGmLogin1]),

    IsPrivilegeAccount = mod_login:privilegeLogin(PlatformId, AccId),
    ?INFO("IsPrivilegeAccount: ~p", [{IsPrivilegeAccount, IsPrivilegeAccount =/= 2}]),
    ?ASSERT(IsPrivilegeAccount =/= 2, ?ERROR_DISABLE_LOGIN),

    %% 平台相关信息
    put(?DICT_PLATFORM_OPEN_ID, util:to_list(OpenId)),
    put(?DICT_PLATFORM_TICKET, util:to_list(Ticket)),
    put(?DICT_PLATFORM_ENTRY, Entry),
    put(?DICT_PLATFORM_PLATFORM_ID, util:to_list(P)),
    Channel = mod_login:get_channel_by_account_platform(PlatformId, AccId),
%%    Channel = "test",
    ?INFO("Channel: ~p", [{Channel, Pf}]),
    put(?DICT_CHANNEL, util:to_list(Channel)),
    put(?DICT_ACCOUNT_SOURCE, util:to_list(Pf)),
    put(?DICT_EQUIP_ID, util:to_list(Qua)),

    %% qq 平台相关信息
    put(?DICT_QQ_PLATFORM, Platform),
    put(?DICT_QQ_VIA, util:to_list(Via)),


    if
%%        PlatformId == ?PLATFORM_QQ ->
%%        ?INFO("via:~p", [{AccId, util:to_list(Via)}]),
%%            mod_cache:update({?CACHE_QQ_VIA, AccId}, util:to_list(Via));
%%        PlatformId == ?PLATFORM_DOULUO orelse PlatformId == ?PLATFORM_SJB ->
%%            PayType = ?IF(PlatformId == ?PLATFORM_DOULUO, max(LoginType, 1), LoginType),
%%            put(?PLAYER_GAME_DATA_DOULUO_PAY_TYPE, PayType),
%%            DouluoOpenId = util:to_list(Via),
%%            put(?PLAYER_GAME_DATA_DOULUO_OPEN_ID, DouluoOpenId),
%%            DouluoQua = util:to_list(Qua),
%%            DouLuoAppId =
%%                case string:tokens(DouluoQua, "^^") of
%%                    [DouLuoAppId1, GameName1] ->
%%                        douluo:update_zhi_fu_cache(GameName1, DouluoOpenId, PayType),
%%                        DouLuoAppId1;
%%                    _ ->
%%                        DouluoQua
%%                end,
%%            put(?PLAYER_GAME_DATA_DOULUO_APP_ID, DouLuoAppId);
%%        PlatformId == ?PLATFORM_OPPO ->
%%            put(oppo_token, util:to_list(Ticket));
%%%%        PlatformId == ?PLATFORM_QUICK andalso Pf == ?CHANNEL_OPPO_MJB  ->
%%        PlatformId == ?PLATFORM_QUICK ->
%%            put(oppo_token, util:to_list(Via));
%%        PlatformId == ?PLATFORM_MJB ->
%%            mod_cache:update({?CACHE_QQ_VIA, AccId}, util:to_list(Via));
        true ->
            noop
    end,

    GetProSettingFun =
        fun(PlayerId) ->
            case mod_player:get_db_player_client_data(PlayerId, util:to_list(?SD_INIT_PRO_SETING)) of
                DbPlayerClientData when is_record(DbPlayerClientData,db_player_client_data)->
                    util:to_binary(#db_player_client_data.value);
                _ ->
                    ?UNDEFINED
            end
        end,

    try mod_login:login(util:to_list(ServerId), AccId, util:to_list(Ticket), Time, State, IsGmLogin1) of
        {NewState, Result} ->
            {Out, AutoCreateRole} =
                if
                % 登录成功
                    Result == ?P_SUCCESS ->
                        ?DEBUG("登录成功:~p", [AccId]),
%%                        PlayerLevel = mod_player:get_player_data(NewState#conn.player_id, level),
%%                        IsOpenIosCharge = ?IF(PlayerLevel >= 50, ?TRUE, ?FALSE),
                        IsOpenIosCharge = mod_charge:get_is_open_charge(NewState#conn.player_id),
                        IsAutoCreateRole = mod_player:is_player_auto_create(NewState#conn.player_id),
                        RandomWomenName = ?IF(IsAutoCreateRole =:= true, get_random_name_list(?SEX_WOMEN, 15), []),
                        RandomMenName = ?IF(IsAutoCreateRole =:= true, get_random_name_list(?SEX_MAN, 15), []),
%%                        ?DEBUG("IsAutoCreateRole: ~p Women: ~p Men: ~p", [IsAutoCreateRole, RandomWomenName, RandomMenName]),
                        Out2 = #m_login_login_toc{
                            result = Result,
                            random_women_name = RandomWomenName,
                            random_man_name = RandomMenName,
                            player_id = NewState#conn.player_id,
                            is_open_ios_charge = ?IF(IsOpenIosCharge, ?TRUE, ?FALSE),
                            pro_setting = GetProSettingFun(NewState#conn.player_id)
                            },
                        {proto:encode(Out2), ?FALSE};
                % 等待创建角色
                    true ->
                        case mod_player:auto_create_role(util:to_list(ServerId), AccId, Channel) of
                            ok ->
                                ?INFO("自动创角成功"),
                                #db_player{
                                    id = PlayerId                        %% int 玩家id
                                } = mod_player:get_player_by_server_id_and_acc_id(util:to_list(ServerId), AccId),
                                NewState1 = NewState#conn{status = ?CLIENT_STATE_WAIT_ENTER_GAME, player_id = PlayerId},
                                hook:after_login(NewState1),
                                RandomWomenName = get_random_name_list(?SEX_WOMEN, 15),
                                RandomMenName = get_random_name_list(?SEX_MAN, 15),
                                IsOpenIosCharge = mod_charge:get_is_open_charge(PlayerId),
                                Out2 = #m_login_login_toc{
                                    result = ?P_SUCCESS,
                                    random_women_name = RandomWomenName,
                                    random_man_name = RandomMenName,
                                    player_id = PlayerId,
                                    is_open_ios_charge = ?IF(IsOpenIosCharge, ?TRUE, ?FALSE)
                                },
                                %% 判断是否为高级号，若是则添加指定物品
                                if
                                    IsPrivilegeAccount =:= ?TRUE -> mod_login:privilegeAwardGive(PlayerId);
                                    true -> noop
                                end,
                                {proto:encode(Out2), PlayerId};
                            _ ->
                                {proto:encode(#m_login_login_toc{
                                    result = Result,
                                    random_man_name = get_random_name_list(?SEX_MAN, 10),
                                    random_women_name = get_random_name_list(?SEX_WOMEN, 10),
                                    player_id = 0,
                                    is_open_ios_charge = ?FALSE
                                }), ?FALSE}
                        end
                end,
            ok = SocketMod:send(Socket, Out),
            if
                AutoCreateRole =/= ?FALSE ->
                    NewState#conn{player_id = AutoCreateRole, status = ?CLIENT_STATE_WAIT_ENTER_GAME};
                true -> NewState
            end
    catch
        _:Reason ->
            FailReason = case Reason of
                             ?ERROR_VERIFY_FAIL ->
                                 ?P_VERIFY_FAIL;
                             ?ERROR_TOKEN_EXPIRE ->
                                 ?P_TOKEN_EXPIRE;
                             ?ERROR_DISABLE_LOGIN ->
                                 ?P_DISABLE_LOGIN;
                             ?ERROR_LOGIN_FREQUENT ->
                                 ?P_LOGIN_FREQUENT;
                             ?CSR_SYSTEM_MAINTENANCE ->
                                 ?CSR_SYSTEM_MAINTENANCE;
                             _R ->
                                 ?P_UNKNOW
                         end,
            mod_log:write_player_login_fail_log(ServerId, AccId, LoginType, Ticket, Ip, Reason),
            ?ERROR("登录失败:~p", [{Reason, Msg, erlang:get_stacktrace()}]),
            client_worker:kill_async(self(), login_fail),
            Out = proto:encode(#m_login_login_toc{
                result = FailReason,
                player_id = 0,
                is_open_ios_charge = ?FALSE
            }),
            ok = SocketMod:send(Socket, Out),
%%            client_worker:send_socket(State, Out, ?SYNC),
            State#conn{acc_id = AccId}
    end.

%% ----------------------------------
%% @doc 	下发给客户端的随机名字
%% @throws 	none
%% @end
%% ----------------------------------
get_random_name_list(Sex, Num) ->
    try get_random_name_list(Sex, Num, [])
    catch
        _:Reason ->
            ?ERROR("get_random_name:~p~n", [{Reason}]),
            []
    end.

get_random_name_list(_Sex, Num, L) when Num =< 0 ->
    L;
get_random_name_list(Sex, Num, L) ->
    {_, RandomName} = random_name:get_name(Sex),
%%    case util_string:is_match(RandomName) of
%%        true ->
%%            get_random_name_list(Sex, Num - 1, L);
%%        false ->
    get_random_name_list(Sex, Num - 1, [erlang:list_to_binary(RandomName) | L]).
%%    end.


%% ----------------------------------
%% @doc 	创建角色
%% @throws 	none
%% @end
%% ----------------------------------
create_role(
    Msg,
    State = #conn{ip = Ip, socket = Socket, status = ?CLIENT_STATE_WAIT_CREATE_ROLE, acc_id = AccId, socket_mod = SocketMod}
) ->
    ?ASSERT(mod_server:is_game_server() == true, not_game_server),
    #m_login_create_role_tos{server_id = ServerId, nickname = Nickname, sex = Sex, from = From, extra = Extra, friend_code = FriendCode} = Msg,
    ?INFO("(~p)创建角色:~p", [Ip, Msg]),
%%    RealFriendCode =
%%        case mod_share:is_valid_friend_code(util:to_list(FriendCode)) of
%%            true ->
%%                FriendCode;
%%            _ ->
%%                ""
%%        end,
    {NewState, Out} =
        try mod_player:create_role(util:to_list(ServerId), util:to_list(AccId), util:to_list(Nickname), Sex, util:to_list(From), util:to_list(Extra), util:to_list(FriendCode), ?FALSE) of
            PlayerId ->
                ?INFO("创角成功:~p", [AccId]),
                _NewState = State#conn{
                    player_id = PlayerId,
                    status = ?CLIENT_STATE_WAIT_ENTER_GAME
                },
                hook:after_login(_NewState),
                {
                    _NewState,
%%                    State#conn{
%%                        player_id = PlayerId,
%%                        status = ?CLIENT_STATE_WAIT_ENTER_GAME
%%%%                        server_id = ServerId
%%%%                        status = ?CLIENT_STATE_WAIT_ENTER_GAME
%%                    },
                    proto:encode(#m_login_create_role_toc{result = ?P_SUCCESS, player_id = PlayerId})
                }
        catch
            _:Reason ->
                Result =
                    case Reason of
                        ?ERROR_ALREADY_CREATE_ROLE ->
                            ?P_ALREADY_CREATE_ROLE;
                        ?ERROR_NAME_USED ->
                            ?P_USED;
                        ?ERROR_INVAILD_NAME ->
                            ?P_INVALID_STRING;
                        ?ERROR_NAME_TOO_LONG ->
                            ?P_TOO_LONG;
                        _ ->
                            ?ERROR("创角失败:~p", [{ServerId, AccId, Nickname, Sex, Reason, erlang:get_stacktrace()}]),
                            ?P_UNKNOW
                    end,
                mod_log:write_player_create_role_fail_log(ServerId, AccId, Nickname, Sex, Ip, Reason),
                {
                    State,
                    proto:encode(#m_login_create_role_toc{result = Result, player_id = 0})
                }
        end,
    ok = SocketMod:send(Socket, Out),
%%    client_worker:send_socket(State, Out, ?SYNC),
%%    util:send(State, Out, ?SYNC),
    NewState.

%% ----------------------------------
%% @doc 	进入游戏
%% @throws 	none
%% @end
%% ----------------------------------
enter_game(
    Msg,
    State = #conn{player_id = PlayerId, status = ?CLIENT_STATE_WAIT_ENTER_GAME}
) ->
    #m_login_enter_game_tos{} = Msg,
    ?DEBUG("玩家(~p)开始进入游戏...", [PlayerId]),
    NewState = mod_game:enter_game(State),
    NewState.

heart_beat(
    #m_login_heart_beat_tos{heartbeat_code = _HeartbeatCode} = _Msg,
    State = #conn{player_id = _PlayerId, socket = _Socket, socket_mod = _SocketMod}
) ->
    {PlatformId, ServerId} = mod_player:get_platform_id_and_server_id(_PlayerId),
    %% 真实玩家与内部账号登陆时，新增服务器状态判断，
    %% 若服务器状态为“维护”，则不允许登录
    %% 测试用

    %%% @todo 心跳协议code验证，2021-09-04 暂时注释，待跟客户端确认清除掉线重连流程后再说
%%    ?DEBUG("HeartbeatCode: ~p", [{util:to_list(HeartbeatCode), HeartbeatCode =:= ?UNDEFINED, get(?DICT_PLAYER_LOGIN_TIME), _PlayerId}]),
%%    case get(?DICT_PLAYER_LOGIN_TIME) of
%%        ?UNDEFINED ->
%%            mod_login:player_kick_out(_PlayerId),
%%            noop;
%%        T ->
%%            ?DEBUG("~p于~p登录游戏，并于~p上报心跳协议，此时的hearbeatCode为: ~p",
%%                [_PlayerId, util_time:timestamp_to_datetime(T),
%%                    util_time:timestamp_to_datetime(util_time:timestamp()), HeartbeatCode]),
%%            case catch mod_server_rpc:call_center(mod_login, chk_player_heartbeat_valid,
%%                [PlatformId, ServerId, _PlayerId, util:to_list(HeartbeatCode)]) of
%%                {badrpc, {'EXIT', empty_heartbeat_code}} ->
%%                     成功登录的玩家，但心跳协议发送的code为空，此时为他分配一个code
%%                    case catch mod_server_rpc:call_center(mod_login, get_player_heartbeat_code, [PlatformId, ServerId, _PlayerId]) of
%%                        {'EXIT', Err} ->
%%                            ?WARNING("初始化玩家数据时，无法生成heartbeat_code: ~p", [Err]),
%%                            mod_login:player_kick_out(_PlayerId);
%%                        Code ->
%%                            Out = #m_login_heart_beat_toc{ heartbeat_code = Code},
%%                            SocketMod:send(Socket, proto:encode(Out))
%%                    end;
%%                {badrpc, {'EXIT', invalid_heartbeat_code}} ->
%%                    ?ERROR("无效HeartbeatCode: ~p", [HeartbeatCode]),
%%                    mod_login:player_kick_out(_PlayerId);
%%                {badrpc, {'EXIT', Err}} ->
%%                    ?ERROR("Err: ~p", [Err]),
%%                    mod_login:player_kick_out(_PlayerId);
%%                IsMaintenance when is_integer(IsMaintenance) ->
%%                    if
    %% 服务器维护，玩家踢下线
%%                        IsMaintenance =:= 1 -> mod_login:player_kick_out(_PlayerId);
%%                        true ->
%%                            case catch mod_server_rpc:call_center(mod_login, get_player_heartbeat_code, [PlatformId, ServerId, _PlayerId]) of
%%                                {'EXIT', Err} -> ?WARNING("初始化玩家数据时，无法生成heartbeat_code: ~p", [Err]), noop;
%%                                Code ->
%%                                    Out = #m_login_heart_beat_toc{ heartbeat_code = Code},
%%                                    SocketMod:send(Socket, proto:encode(Out))
%%                            end
%%                    end
%%            end
%%    end,
%%    ?DEBUG("testing：~p", [_PlayerId]),
%%    R = 1,
%%    case R of
    case mod_server_rpc:call_center(mod_server, chk_game_server_state, [PlatformId, ServerId]) of
        IsMaintenance when is_integer(IsMaintenance) ->
%%            ?DEBUG("IsMaintenance: ~p", [IsMaintenance]),
            if
                IsMaintenance =:= 1 ->
                    case mod_obj_player:get_obj_player(_PlayerId) of
                        null ->
                            noop;
                        ObjPlayer ->
                            %% 判断是否为gm号，若不是踢下线，反之则继续让他在游戏里
                            PlayerInfo = mod_player:get_player(_PlayerId),
                            case mod_global_account:is_gm_account(PlatformId, get_acc_id(util:to_list(PlayerInfo#db_player.acc_id), PlatformId)) of
                                %% gm号
                                true -> ok;
                                false ->
                                    %% 下线
                                    #ets_obj_player{
                                        client_worker = ClientWorker
                                    } = ObjPlayer,
                                    client_worker:kill_async(ClientWorker, ?CSR_SYSTEM_MAINTENANCE)
                            end
                    end;
                true ->
                    noop
            end
    end,
    State.

%% ----------------------------------
%% @doc 	通知登出
%% @throws 	none
%% @end
%% ----------------------------------
notice_logout(
    #conn{socket = Socket, socket_mod = SocketMod},
    Reason
) ->
    ReasonEnum =
        case Reason of
            ?CSR_LOGIN_IN_OTHER ->
                ?P_LOGIN_IN_OTHER;
            ?CSR_SYSTEM_MAINTENANCE ->
                ?P_SYSTEM_MAINTENANCE;
            ?CSR_DISABLE_LOGIN ->
                ?P_DISABLE_LOGIN;
%%        ?CSR_MAX_ERROR ->
%%            ?CHEAT;
            ?CSR_MAX_PACK ->
                ?P_CHEAT;
            ?CSR_GM_KILL ->
                ?P_GM_KILL;
            ?CSR_BLACK_IP_LIST ->
                ?P_BLACK_IP_LIST;
            R ->
                ?DEBUG("notice_logout other:~p~n", [R]),
                ?P_SYSTEM_MAINTENANCE
        end,
    Out = proto:encode(#m_login_notice_logout_toc{reason = ReasonEnum}),
    ?INFO("Reason: ~p", [Reason]),
    ?INFO("Out: ~p", [Out]),
    ok = SocketMod:send(Socket, Out).
%%    client_worker:send_socket(State, Out, ?SYNC).
