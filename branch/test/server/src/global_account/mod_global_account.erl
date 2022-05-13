%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                全服帐号
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_global_account).

-include("gen/db.hrl").
-include("common.hrl").
-include("db_config.hrl").

%% API
-export([
    update_recent_server_list/4,
    is_can_login/2,
    is_can_chat/2,
    is_inner_account/2,
    is_gm_account/2,
    set_account_type/3,
    tran_recent_server_list/1,
    set_forbid/4,
    get_login_cache_from_login_server/1
]).
-export([
    update_promote_by_game_server/3,
    is_reviewing/1,
    update_app_id/3,
%%    update_equip_id/3,
    is_can_charge/4,
    is_native_pay/4,
    get_global_account_by_acc_id_platform/2,
    is_acc_id_exists/6,
    get_facebook_app_id_from_center_node/2,
    get_global_account_info_from_login/2,
    get_app_version/1
]).

-export([list_to_bin/1]).
-export([get_my_region/2]).
-export([
    get_app_info/1,
    get_app_info/2
]).
-export([
    get_mobile/2,
    update_mobile/3
]).


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

tran_recent_server_list([]) ->
    [];
tran_recent_server_list(RecentServerList) ->
    util_string:string_to_list_term(RecentServerList).


%%get_global_account(PlatformId, AccId) ->
%%    case db:read(#key_global_account{
%%        platform_id = PlatformId,
%%        account = AccId
%%    }) of
%%        null ->
%%            #db_global_account{
%%                platform_id = PlatformId,
%%                account = AccId,
%%                recent_server_list = [],
%%                type = 0
%%            };
%%        GlobalAccount ->
%%            GlobalAccount
%%    end.

%% ----------------------------------
%% @doc 	是否是内部帐号
%% @throws 	none
%% @end
%% ----------------------------------
is_inner_account(PlatformId, AccId) ->
    case global_account_srv:get_global_account(PlatformId, AccId) of
        null ->
            false;
        R ->
            R#db_global_account.type >= 1
    end.

%% ----------------------------------
%% @doc 	是否是GM帐号
%% @throws 	none
%% @end
%% ----------------------------------
is_gm_account(PlatformId, AccId) ->
    case global_account_srv:get_global_account(PlatformId, AccId) of
        null ->
            false;
        R ->
            R#db_global_account.type =:= ?ACCOUNT_TYPE_GM
    end.

set_forbid(PlatformId, AccId, ForbidType, Time) ->
    ?ASSERT(mod_server:is_center_server()),
    ?ASSERT(lists:member(ForbidType, [?FORBID_TYPE_NONE, ?FORBID_TYPE_DISABLE_CHAT, ?FORBID_TYPE_DISABLE_LOGIN]), {forbid_type_error, ForbidType}),
    case global_account_srv:local_get_global_account(PlatformId, AccId) of
        null ->
            fail;
        R ->
            PlatformId1 = list_to_bin(PlatformId),
            AccId1 = list_to_bin(AccId),
            ForbidType1 = int_to_bin(ForbidType),
            Time1 = int_to_bin(Time),
            Sql = <<
                "UPDATE `global_account` SET "
                " `forbid_type` = ", ForbidType1/binary,
                " ,`forbid_time` = ",  Time1/binary,
                " where `platform_id` = ", PlatformId1/binary,
                " and `account` = ", AccId1/binary,
                ";\n"
            >>,
            db_proxy:fetch(Sql),
            Tran = fun() ->
                db:dirty_write(R#db_global_account{
                    forbid_type = ForbidType,
                    forbid_time = Time
                })
                   end,
            db:do(Tran),
            ok
    end.

get_global_account_info_from_login(AccIdFromClient, PlatformIdFromClient) ->
    Sql = io_lib:format("SELECT * from `global_account` WHERE account = '~s' and platform_id = '~s' LIMIT 1; ", [AccIdFromClient, PlatformIdFromClient]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {data, SelectRes} ->
            Fun = fun(R) ->
                R#db_global_account{
                    row_key = {R#db_global_account.platform_id, R#db_global_account.account}
                }
                  end,
            L = lib_mysql:as_record(SelectRes, db_global_account, record_info(fields, db_global_account), Fun),
            L
    end.

%% ----------------------------------
%% @doc 	通过客户端上报的facebook_app_id与中心服ets中的ets_erget_setting里的facebook_app_id进行比较
%% @throws 	none
%% @end
%% ----------------------------------
get_facebook_app_id_from_center_node(FbAppIdFromClient, PlatformIdFromClient) ->
    case FbAppIdFromClient of
        "undefined" ->
            ?INFO("there's not facebook_app_id"),
            failure;
        "[facebook_app_id]" ->
            ?INFO("not facebook login"),
            failure;
        R ->
            Result = jsone:decode(util:to_binary(R)),
            ?INFO("json_decode facebookAppIdFromClient: ~p ~p", [Result, is_list(Result)]),

            if
                length(Result) =:= 0 -> ?INFO("facebook_app_id from client is empty"), failure;
                true ->
                    %% 从中心服ets中取出platform=PlatformIdFromClient的ets_erget_setting的数据，
                    %% 并将结果集中所有facebook_app_id通过半角逗号合并成一个字符串
                    %% 最后按照半角逗号将其拆分为一个列表
                    ErgetSettingInEts = ets:select(?ETS_ERGET_SETTING, [{#ets_erget_setting{platform = PlatformIdFromClient, _ = '_'}, [], ['$_']}]),
                    FacebookAppIdList = [FacebookAppId ++ "," || #ets_erget_setting{facebook_app_id = FacebookAppId} <- ErgetSettingInEts],
                    FacebookAppIdListInEts = string:tokens(lists:flatten(FacebookAppIdList), ","),

                    %% 遍历FbAppIdFromClient的结果集，并将单个FbAppId的app_id取出来与FacebookAppIdListInEts这个列表做是否存在的判断
                    %% 若存在，则表示该app_id是一个合法有效的app_id，最后将与之对应的acc_id放入AccIdList中
                    %% 反之则跳过
                    AccIdList =
                        lists:filtermap(
                            fun (Ele) ->
                                FbAppIdInEle = util:to_list(maps:get(<<"app_id">>, Ele)),
                                ValidFbAppId = lists:member(FbAppIdInEle, FacebookAppIdListInEts),
                                ?IF(ValidFbAppId =:= false, false, {true, util:to_list(maps:get(<<"acc_id">>, Ele))})
                            end,
                            Result
                        ),

                    %% 将AppIdList列表中的每个元素用"', '"分割生成为一个字符串AppIdStr
                    %% 并用该字符串生成sql。sql: select * from `global_account` where `platform_id` = 'PlatformIdFromClient' and `acc_id` in ('AppIdStr')
                    AppIdStr = string:join(AccIdList, "', '"),
                    ?INFO("get_global_account_sql: ~p", ["SELECT g.* from `global_account` AS g LEFT JOIN `global_player` AS gp ON g.`account` = gp.`account` WHERE g.`platform_id` = '" ++ PlatformIdFromClient ++ "' and g.`account` in ('" ++  AppIdStr ++ "') ORDER BY gp.`id` DESC LIMIT 1; "]),
                    Sql = io_lib:format("SELECT g.* from `global_account` AS g LEFT JOIN `global_player` AS gp ON g.`account` = gp.`account` WHERE g.`platform_id` = '~s' and g.`account` in ('~s') ORDER BY gp.`id` DESC LIMIT 1; ", [PlatformIdFromClient, list_to_binary(AppIdStr)]),
                    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
                        {error, Msg} ->
                            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
                            error;
                        {data, SelectRes} ->
                            Fun = fun(R1) ->
                                R1#db_global_account{
                                    row_key = {R1#db_global_account.platform_id, R1#db_global_account.account}
                                }
                                  end,
                            L = lib_mysql:as_record(SelectRes, db_global_account, record_info(fields, db_global_account), Fun),
                            ?INFO("RealGlobalAccount: ~p", [L]),
                            if
                                length(L) =:= 0 -> noop;
                                true ->
                                    [#db_global_account{
                                        account = RealAccId
                                    }] = L,
                                    RealAccId
                            end
                    end
            end
    end.

%% ----------------------------------
%% @doc 	通过包名(app_id)从ets中获取数据
%% @throws 	none
%% @end
%% ----------------------------------
get_app_info(AppId, is_native_pay) ->
    case get_app_info(AppId) of
        null -> false;
        Info -> ?IF(Info#ets_erget_setting.is_native_pay =:= 1, true, false)
    end;
get_app_info(AppId, is_reviewing) ->
    IsReviewing =
        case get_app_info(AppId) of
            null -> 0;
            Info -> Info#ets_erget_setting.status
        end,
    if
        IsReviewing =:= 1 -> reviewing;
        true -> []
    end;
get_app_info(AppId, version) ->
    case get_app_info(AppId) of
        null -> 0;
        Info ->
            #ets_erget_setting{client_version = Version} = Info,
            [V, _] = string:tokens(Version, "."),
            V
    end;
get_app_info(AppId, is_can_charge) ->
    case get_app_info(AppId) of
        null -> true;
        Info -> ?IF(Info#ets_erget_setting.is_close_charge =:= 1, false, true)
    end.
get_app_info(AppId) ->
    case mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, AppId]) of
        [R] when is_record(R, ets_erget_setting) -> R;
        [] -> null
    end.

%% ----------------------------------
%% @doc 	通过包名(app_id)从ets中获取数据，返回ets中的客户端的大版本号
%% @throws 	none
%% @end
%% ----------------------------------
get_app_version(AppId) ->
    case mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, AppId]) of
        [R] when is_record(R, ets_erget_setting) ->
            #ets_erget_setting{
                client_version = Version
            } = R,
            [V, _] = string:tokens(Version, "."),
            V;
        [] -> 0
    end.

%% ----------------------------------
%% @doc 	通过包名(app_id)从ets中获取数据，判断该包登录的玩家是否进入审核服
%% @throws 	none
%% @end
%% ----------------------------------
is_reviewing(AppId) ->
    IsReviewing =
        case mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, AppId]) of
            [R] when is_record(R, ets_erget_setting) ->
                #ets_erget_setting{
                    status = Status
                } = R,
                Status;
            [] -> 0
        end,
    if
        IsReviewing =:= 1 -> reviewing;
        true -> []
    end.

%% ----------------------------------
%% @doc 	通过app_id判断的当前玩家所使用的包是否允许使用手机系统的商店支付
%% @throws 	none
%% @end
%% ----------------------------------
is_native_pay(_PlatformId, AppId, _AccId, _VersionFromClient) ->
    case mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, AppId]) of
        [R] when is_record(R, ets_erget_setting) ->
            #ets_erget_setting{
                is_native_pay = IsNativePay
            } = R,
            ?IF(IsNativePay =:= 1, true, false);
        [] ->
            false
    end.


%% ----------------------------------
%% @doc 	判断当前登录账号是否显示充值按钮
%% @throws 	none
%% @end
%% ----------------------------------
is_can_charge(PlatformId, AppId, AccId, _VersionFromClient) ->
    AccType =
        case global_account_srv:get_global_account(PlatformId, AccId) of
            null ->
                ?ACCOUNT_TYPE_COMMON;
            G ->
                #db_global_account{
                    type = Type
                } = G,
                Type
        end,
    ?DEBUG("AccType: ~p", [AccType]),
    if
    % 登录玩家账号类型不是“任何情况下都能显示充值的号”时，继续判断后台设置好的是否关闭充值
        AccType =/= ?ACCOUNT_TYPE_CHARGE_ALWAYS_OPEN ->
            %% 获取当前平台的后台设置数据
            get_app_info(AppId, is_can_charge);
        %% 当前登录玩家的账号类型为后台设置的“任何情况下都能显示充值的号”时,直接允许充值
        true ->
            true
    end.

is_can_login(PlatformId, AccId) ->
    case global_account_srv:get_global_account(PlatformId, AccId) of
        null ->
            true;
        R ->
            #db_global_account{
                forbid_time = ForbidTime,
                forbid_type = ForbidType
            } = R,
            ForbidType =/= ?FORBID_TYPE_DISABLE_LOGIN orelse util_time:timestamp() > ForbidTime
    end.

is_can_chat(PlatformId, AccId) ->
    case global_account_srv:get_global_account(PlatformId, AccId) of
        null ->
            true;
        R ->
            #db_global_account{
                forbid_time = ForbidTime,
                forbid_type = ForbidType
            } = R,
%%            R#db_global_account.type == ?FORBID_TYPE_NONE
            ForbidType == ?FORBID_TYPE_NONE orelse util_time:timestamp() > ForbidTime
%%            ForbidType == ?FORBID_TYPE_NONE orelse ForbidType == ?FORBID_TYPE_DISABLE_CHAT andalso  ForbidTime > 0 andalso ForbidTime < util_time:timestamp()
    end.


%% ----------------------------------
%% @doc 	设置帐号类型
%% @throws 	none
%% @end
%% ----------------------------------
set_account_type(PlatformId, AccId, Type) ->
    ?ASSERT(mod_server:is_center_server()),
    case global_account_srv:get_global_account(PlatformId, AccId) of
        null ->
            exit({exit_no_exists, PlatformId, AccId, Type});
        _R ->
            PlatformId1 = list_to_bin(PlatformId),
            AccId1 = list_to_bin(AccId),
            Type1 = int_to_bin(Type),
            Sql = <<
                "UPDATE `global_account` SET "
                " `type` = ", Type1/binary,
                " where `platform_id` = ", PlatformId1/binary,
                " and `account` = ", AccId1/binary,
                ";\n"
            >>,
            db_proxy:fetch(Sql),
%%            Tran = fun() ->
%%                db:dirty_write(R#db_global_account{
%%                    type = Type
%%                })
%%                   end,
%%            db:do(Tran),
            ok
    end.

int_to_bin(undefined) ->
    <<"NULL">>;
int_to_bin(Value) ->
    list_to_binary(integer_to_list(Value)).
%%float_to_bin(undefined) ->
%%    <<"NULL">>;
%%float_to_bin(Value) ->
%%    list_to_binary(float_to_list(Value)).
list_to_bin(undefined) ->
    <<"NULL">>;
list_to_bin(List) ->
    List2 = escape_str(List, []),
    Bin = list_to_binary(List2),
    <<"'", Bin/binary, "'">>.
escape_str([], Result) ->
    lists:reverse(Result);
escape_str([$' | String], Result) ->
    escape_str(String, [$' | [$\\ | Result]]);
escape_str([$" | String], Result) ->
    escape_str(String, [$" | [$\\ | Result]]);
escape_str([$\\ | String], Result) ->
    escape_str(String, [$\\ | [$\\ | Result]]);
escape_str([Char | String], Result) ->
    escape_str(String, [Char | Result]).


%% ----------------------------------
%% @doc 	中心服到登录服获取ets_login_cache数据中的promote
%% @throws 	none
%% @end
%% ----------------------------------
get_login_cache_from_login_server(Account) ->
    case ets:lookup(?ETS_LOGIN_CACHE, Account) of
        [] ->
            {"undefined", "com.aaagame.sjlstw", "TWD", ""};
        [R] ->
%%            #ets_login_cache{
%%                promote = PromoteInCache,
%%                app_id = AppId,
%%                region = Region
%%            } = R,
            {R#ets_login_cache.promote, R#ets_login_cache.app_id, R#ets_login_cache.region,
                R#ets_login_cache.registration_id}
    end.


%% ----------------------------------
%% @doc 	更新最近登录服务器
%% @throws 	none
%% @end
%% ----------------------------------
update_recent_server_list(PlatformId, AccId, ServerId, IsAuto) ->
    ?ASSERT(mod_server:is_center_server()),
    GlobalAccount = global_account_srv:get_global_account(PlatformId, AccId),
    #db_global_account{
        registration_id = OldRegistrationId,
        recent_server_list = OldRecentServerIdList
    } = GlobalAccount,
    OldList = tran_recent_server_list(OldRecentServerIdList),
%%    OldList = get_recent_server_list(PlatformId, AccId),
%%    ?INFO("更新最近登录服务器:~p~n", [{PlatformId, AccId, ServerId, OldList}]),
    NewList = lists:sublist([ServerId | lists:delete(ServerId, OldList)], 5),
%%        Sql = io_lib:format("update  `global_account` set recent_server_list = '~s' ", [util_string:term_to_string(NewList)]),
    RecentServerList = list_to_bin(util_string:term_to_string(NewList)),
    PlatformId1 = list_to_bin(PlatformId),
    AccId1 = list_to_bin(AccId),
    #db_c_server_node{node = Node1} = mod_server:get_login_server_node(),
    Node = util:to_atom(Node1),
%%        {Promote, AppId} = rpc:call(Node, mod_global_account, get_login_cache_from_login_server, [AccId]),
    {Promote, AppId, Region, RegistrationId} = rpc:call(Node, mod_global_account, get_login_cache_from_login_server, [AccId]),
    ?INFO("Promote: ~p ~p ~p ~p", [Promote, AppId, Region, RegistrationId]),
    Promote2Bin = list_to_bin(Promote),
    AppId2Bin = list_to_bin(AppId),
    Region2Bin = list_to_bin(Region),
    RegistrationId2Bin = list_to_bin(RegistrationId),
    Type = list_to_bin(integer_to_list(?IF(IsAuto =:= ?TRUE, ?ACCOUNT_TYPE_AUTO_CREATE_ROLE, ?ACCOUNT_TYPE_COMMON))),
    ?DEBUG("Promote: ~p ~p ~p ~p ~p ~p", [is_binary(Promote2Bin), AccId, Promote, Promote2Bin, Type, RegistrationId2Bin]),
    Sql =
        case global_account_srv:local_get_global_account(PlatformId, AccId) of
            null ->
                spawn(fun() -> mod_tui_song:modify_push_list(PlatformId, AccId, RegistrationId, ServerId) end),
                <<
                    "INSERT INTO `global_account` (`recent_server_list`, `platform_id`, `account`, `promote`, `app_id`, `type`, `region`, `registration_id`) VALUES "
                    " ( ", RecentServerList/binary,
                    ",  ", PlatformId1/binary,
                    ",  ", AccId1/binary,
                    ",  ", Promote2Bin/binary,
                    ",  ", AppId2Bin/binary,
                    ",  ", Type/binary,
                    ",  ", Region2Bin/binary,
                    ",  ", RegistrationId2Bin/binary,
                    ");\n"
                >>;
            _ ->
                case lists:member(ServerId, OldList) of
                    true ->
                        if
                            OldRegistrationId =/= RegistrationId ->
                                spawn(fun() -> mod_tui_song:modify_push_list(PlatformId, AccId, RegistrationId, "") end);
                            true ->
                                noop
                        end;
                    false ->
                        spawn(fun() -> mod_tui_song:modify_push_list(PlatformId, AccId, RegistrationId, ServerId) end)
                end,
                <<
                    "UPDATE `global_account` SET "
                    " `recent_server_list` = ", RecentServerList/binary,
                    ", `registration_id` = ", RegistrationId2Bin/binary,
                    ", `region` = ", Region2Bin/binary,
                    " where `platform_id` = ", PlatformId1/binary,
                    " and `account` = ", AccId1/binary,
                    ";\n"
                >>
        end,
    ?DEBUG("Sql: ~p", [Sql]),
    db_proxy:fetch(Sql).
%%        R = mysql:fetch(game_db, Sql, 2000),
%%        ?INFO("sql:~s ", [Sql]);

%% ----------------------------------
%% @doc 	通过platformId，accId修改global_account表中指定记录的promote的值
%% @throws 	none
%% @end
%% ----------------------------------
update_promote_by_game_server(PlatformId, AccId, Promote) ->
    ?DEBUG("Platform: ~p AccId: ~p Promote: ~p", [PlatformId, AccId, Promote]),
    case global_account_srv:local_get_global_account(PlatformId, AccId) of
        null ->
            ?ERROR("AccId: ~p PlatformId: ~p global_account NOT EXISTS", [PlatformId, AccId]),
            failure;
        _ ->
            ?DEBUG("Promote: ~p ~p", [is_binary(Promote), Promote]),
            Promote1 = ?IF(is_binary(Promote), Promote, list_to_bin(Promote)),
            PlatformId1 = list_to_bin(PlatformId),
            Account = list_to_bin(AccId),
            OldPromote = list_to_bin("undefined"),
            EmptyPromote = list_to_bin(""),
            Sql =
                <<
                    "UPDATE `global_account` SET "
                    " `promote` = ", Promote1/binary,
                    " where `platform_id` = ", PlatformId1/binary,
                    " and `account` = ", Account/binary,
                    " and (`promote` = ", OldPromote/binary,
                    " or `promote` = ", EmptyPromote/binary,
                    " or `promote` = ", Account/binary,
                    ");\n"
                >>,
            ?INFO("update promote sql: ~p", [Sql]),
            db_proxy:fetch(Sql),
            ok
    end.

%% ----------------------------------
%% @doc 	通过platformId，accId修改global_account表中指定记录的app_id的值
%% @throws 	none
%% @end
%% ----------------------------------
update_app_id(PlatformId, AccId, AppId) ->
    ?DEBUG("Platform: ~p AccId: ~p AppId: ~p", [PlatformId, AccId, AppId]),
    case global_account_srv:local_get_global_account(PlatformId, AccId) of
        null ->
            ?ERROR("AccId: ~p PlatformId: ~p global_account NOT EXISTS", [PlatformId, AccId]),
            failure;
        R when is_record(R, db_global_account) ->
            #db_global_account{
                app_id = OldAppId
            } = R,
            if
                OldAppId =/= AppId ->
                    AppId2Bin = list_to_bin(AppId),
                    PlatformId2Bin = list_to_bin(PlatformId),
                    Account2Bin = list_to_bin(AccId),
                    Sql =
                        <<
                            "UPDATE `global_account` SET "
                            " `app_id` = ", AppId2Bin/binary,
                            " where `platform_id` = ", PlatformId2Bin/binary,
                            " and `account` = ", Account2Bin/binary,
                            ";\n"
                        >>,
                    ?INFO("update app_id sql: ~p", [Sql]),
                    db_proxy:fetch(Sql),
                    ok;
                true ->
                    ?INFO("no update oldAppId: ~p, AppId: ~p", [OldAppId, AppId]),
                    failure
            end
    end.

%% ----------------------------------
%% @doc 	通过platformId，accId和equipId 修改global_account表中指定记录的equipId的值
%% @throws 	none
%% @end
%% ----------------------------------
%%update_equip_id(PlatformId, AccId, EquipId) ->
%%    ?DEBUG("Platform: ~p AccId: ~p EquipId: ~p", [PlatformId, AccId, EquipId]),
%%    case global_account_srv:local_get_global_account(PlatformId, AccId) of
%%        null ->
            %% accId与platformId在数据库中找不到，暨当前accId尚未在当前platformId登录过
%%            ?ERROR("AccId: ~p PlatformId: ~p global_account NOT EXISTS", [PlatformId, AccId]),
%%            failure;
%%        R ->
%%            #db_global_account{
%%                equip_id = OldEquipId
%%            } = R,
            %% 新旧两个设备码不相同，暨同一个账号在不同设备登录
%%            if
%%                OldEquipId =/= EquipId ->
%%                    EquipId1 = list_to_bin(EquipId),
%%                    PlatformId1 = list_to_bin(PlatformId),
%%                    Account = list_to_bin(AccId),
%%                    OldEquipId2Bin = list_to_bin("0"),
%%                    Sql =
%%                        <<
%%                            "UPDATE `global_account` SET "
%%                            " `equip_id` = ", EquipId1/binary,
%%                            " where `platform_id` = ", PlatformId1/binary,
%%                            " and `account` = ", Account/binary,
%%                            " and `equip_id` = ", OldEquipId2Bin/binary,
%%                            ";\n"
%%                        >>,
%%                    ?INFO("update equip_id sql: ~p", [Sql]),
%%                    db_proxy:fetch(Sql),
%%                    ok;
%%                true ->
%%                    ?INFO("no update. OldEquipId is equal EquipId ~p =:= ~p", [OldEquipId, EquipId]),
%%                    failure
%%            end
%%    end.


%% ----------------------------------
%% @doc 	通过platformId，accId查找global_account表中指定记录的所有字段的值
%% @throws 	none
%% @end
%% ----------------------------------
get_global_account_by_acc_id_platform(PlatformId, AccId) ->
    ?DEBUG("SELECT * from `global_account` WHERE account = '~s' and platform_id = '~s' LIMIT 1", [AccId, PlatformId]),
%%    #db_c_server_node{node = Node1} = mod_server_rpc:call_center(mod_server, get_login_server_node, []),
    #db_c_server_node{node = Node1} = mod_server:get_login_server_node(),
    ?INFO("Node: ~p", [Node1]),
    Node = util:to_atom(Node1),
    ?INFO("Node: ~p", [Node]),
%%    {Promote, AppId} = rpc:call(Node, ets, lookup, [AccId]),
    AppIdInEts1 =
        case rpc:call(Node,ets, lookup, [?ETS_LOGIN_CACHE, AccId]) of
            [SettingInEts] when is_record(SettingInEts, ets_login_cache) ->
                #ets_login_cache{
                    app_id = AppIdInEts
                } = SettingInEts,
                AppIdInEts;
            [] -> "com.aaagame.sjlstw"
        end,
    ?INFO("AppIdInEts: ~p, AccId: ~p", [AppIdInEts1, AccId]),
    AppIdInEts1.
%%    Sql = io_lib:format("SELECT * from `global_account` WHERE account = '~s' and platform_id = '~s' LIMIT 1; ", [AccId, PlatformId]),
%%    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
%%        {error, Msg} ->
%%            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
%%            error;
%%        {data, SelectRes} ->
%%            Fun = fun(R) ->
%%                R#db_global_account{
%%                    row_key = {R#db_global_account.platform_id, R#db_global_account.account}
%%                }
%%                  end,
%%            L = lib_mysql:as_record(SelectRes, db_global_account, record_info(fields, db_global_account), Fun),
%%            [#db_global_account{
%%                app_id = AppIdInDb
%%            }] = L,
%%            AppIdInDb
%%    end.
% fb visitor
is_acc_id_exists(PlayerId, Channel, PlatformId, ServerId, AccId, OldAccId) ->
    ?DEBUG("SELECT * from `global_account` WHERE account = '~s' and platform_id = '~s' LIMIT 1", [AccId, PlatformId]),
    Sql = io_lib:format("SELECT * from `global_account` WHERE account = '~s' and platform_id = '~s' LIMIT 1; ", [AccId, PlatformId]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, Sql]),
            error;
        {data, SelectRes} ->
            Fun = fun(R) ->
                R#db_global_account{
                    row_key = {R#db_global_account.platform_id, R#db_global_account.account}
                }
                  end,
            L = lib_mysql:as_record(SelectRes, db_global_account, record_info(fields, db_global_account), Fun),
            case L of
                [R] when is_record(R, db_global_account) ->
                    ?ERROR("AccId is Exists.AccId: ~p Platform: ~p", [AccId, PlatformId]),
                    acc_id_exists;
                [L] when is_list(L) ->
                    ?ERROR("!!AccId is Exists.AccId: ~p Platform: ~p", [AccId, PlatformId]),
                    acc_id_exists;
                [] ->
                    PlatformId2Bin = ?IF(is_binary(PlatformId), PlatformId, list_to_bin(PlatformId)),
                    Account2Bin = ?IF(is_binary(AccId), AccId, list_to_bin(AccId)),
                    OldAccId2Bin = ?IF(is_binary(OldAccId), OldAccId, list_to_bin(OldAccId)),
                    Channel2Bin = ?IF(is_binary(Channel), Channel, list_to_bin(Channel)),
                    PlayerId2Bin = ?IF(is_binary(PlayerId), PlayerId, integer_to_binary(PlayerId)),
                    ServerId2Bin = ?IF(is_binary(ServerId), ServerId, list_to_binary(ServerId)),
                    UpdateSql = <<
                        "UPDATE `global_account` SET "
                        " `account` = ", Account2Bin/binary,
                        " where `platform_id` = ", PlatformId2Bin/binary,
                        " and `account` = ", OldAccId2Bin/binary,
                        ";\n"
                    >>,
                    ?INFO("UpdateGlobalAccoutSql: ~p", [binary_to_list(UpdateSql)]),
                    db_proxy:fetch(UpdateSql),
                    UpdateGlobalPlayerSql = <<
                        "UPDATE `global_player` SET "
                        " `account` = ", Account2Bin/binary,
                        " ,`channel` = ", Channel2Bin/binary,
                        " where `platform_id` = ", PlatformId2Bin/binary,
                        " and `account` = ", OldAccId2Bin/binary,
                        " and `server_id` = '", ServerId2Bin/binary,
                        "' and `id` = ", PlayerId2Bin/binary,
                        ";\n"
                    >>,
                    ?INFO("UpdateGlobalAccoutSql: ~p", [binary_to_list(UpdateGlobalPlayerSql)]),
                    db_proxy:fetch(UpdateGlobalPlayerSql),
                    ok
            end
    end.

get_my_region(AccId, PlatformId) ->
    ?INFO("get_global_account_sql: ~p", ["SELECT g.* from `global_account` AS g WHERE g.`platform_id` = '" ++ PlatformId ++ "' and g.`account` = '" ++  AccId ++ "' LIMIT 1; "]),
    Sql = io_lib:format("SELECT g.* from `global_account` AS g WHERE g.`platform_id` = '~s' and g.`account` = '~s' LIMIT 1; ", [PlatformId, list_to_binary(AccId)]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {data, SelectRes} ->
            Fun = fun(R) ->
                R#db_global_account{
                    row_key = {R#db_global_account.platform_id, R#db_global_account.account}
                }
                  end,
            L = lib_mysql:as_record(SelectRes, db_global_account, record_info(fields, db_global_account), Fun),
            ?INFO("RealGlobalAccount: ~p", [L]),
            if
                length(L) =:= 0 -> noop;
                true ->
                    [#db_global_account{
                        region = Region
                    }] = L,
                    Region
            end
    end.

%% ----------------------------------
%% @doc 	通过platformId，accId查找global_account表中指定记录的所有字段的值
%% @throws 	none
%% @end
%% ----------------------------------
get_mobile(PlatformId, AccId) ->
    ?INFO("get_global_account_sql: ~p", ["SELECT g.* from `global_account` AS g WHERE g.`platform_id` = '" ++ PlatformId ++ "' and g.`account` = '" ++  AccId ++ "' LIMIT 1; "]),
    Sql = io_lib:format("SELECT g.* from `global_account` AS g WHERE g.`platform_id` = '~s' and g.`account` = '~s' LIMIT 1; ", [PlatformId, list_to_binary(AccId)]),
    case mysql:fetch(game_db, list_to_binary(Sql), 2000) of
        {error, Msg} ->
            ?DB_ERROR("reason:~p, sql:~p}", [Msg, {Sql, erlang:get_stacktrace()}]),
            error;
        {data, SelectRes} ->
            Fun = fun(R) ->
                R#db_global_account{
                    row_key = {R#db_global_account.platform_id, R#db_global_account.account}
                }
                  end,
            L = lib_mysql:as_record(SelectRes, db_global_account, record_info(fields, db_global_account), Fun),
%%            ?INFO("RealGlobalAccount: ~p", [L]),
            if
                length(L) =:= 0 -> noop;
                true ->
                    [#db_global_account{mobile = Mobile}] = L,
                    Mobile
            end
    end.

%% ----------------------------------
%% @doc 	通过platformId，accId修改global_account表中指定记录的mobile的值
%% @throws 	none
%% @end
%% ----------------------------------
update_mobile(PlatformId, AccId, Mobile) ->
    ?DEBUG("Platform: ~p AccId: ~p Mobile: ~p", [PlatformId, AccId, Mobile]),
    case global_account_srv:local_get_global_account(PlatformId, AccId) of
        null ->
            ?ERROR("AccId: ~p PlatformId: ~p global_account NOT EXISTS", [PlatformId, AccId]),
            failure;
        R when is_record(R, db_global_account) ->
            #db_global_account{mobile = OldMobile} = R,
            if
                OldMobile =/= Mobile ->
                    Mobile2Bin = list_to_bin(Mobile),
                    PlatformId2Bin = list_to_bin(PlatformId),
                    Account2Bin = list_to_bin(AccId),
                    Sql =
                        <<
                            "UPDATE `global_account` SET "
                            " `mobile` = ", Mobile2Bin/binary,
                            " where `platform_id` = ", PlatformId2Bin/binary,
                            " and `account` = ", Account2Bin/binary,
                            ";\n"
                        >>,
                    ?INFO("update app_id sql: ~p", [Sql]),
                    db_proxy:fetch(Sql),
                    ok;
                true ->
                    ?INFO("no update oldAppId: ~p, AppId: ~p", [OldMobile, Mobile]),
                    failure
            end
    end.
