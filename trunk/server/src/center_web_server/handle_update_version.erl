%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 3月 2021 下午 03:44:43
%%%-------------------------------------------------------------------
-module(handle_update_version).
-author("Administrator").

%% API
-export([init/2, getData/0, getPlayerPayTimesLimit/0, updateTestAccount/0, chk_sign/2, updateClientHeartbeatVerify/0]).
-export([
    get_app_info_from_ets/1,
    get_app_info_from_ets/2
]).

-include("system.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").

-define(ADMIN_URL, ?IF(?IS_DEBUG, "http://127.0.0.1:7399/tool/get_platform_client_info_all_list", "http://127.0.0.1:7199/tool/get_platform_client_info_all_list")).
-define(PLAYER_PAY_TIMES_LIMIT, ?IF(?IS_DEBUG, "http://127.0.0.1:7399/api/get_platform_info_list", "http://127.0.0.1:7199/api/get_platform_info_list")).
-define(TEST_ACCOUNT_FROM_ADMIN, ?IF(?IS_DEBUG, "http://127.0.0.1:7399/player/test_account_list", "http://127.0.0.1:7199/player/test_account_list")).
-define(CLIENT_HEARTBEAT_VERIFY, ?IF(?IS_DEBUG, "http://127.0.0.1:7399/api/get_client_verify", "http://127.0.0.1:7199/api/get_client_verify")).

updateClientHeartbeatVerify() ->
    ?INFO("get client heartbeat verify from admin: ~p", [{?CLIENT_HEARTBEAT_VERIFY, ?IS_DEBUG}]),
    ReqData = [{"status", 2}, {"limit", 999999999}],
    case util_http:post(?CLIENT_HEARTBEAT_VERIFY, json, ReqData) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
%%            ?DEBUG("Code: ~p", [Code]),
            if
                Code =:= 0 ->
%%                    ?DEBUG("Data: ~p", [{is_map(Data), is_list(Data), Data}]),
                    Data2Ets =
                        lists:filtermap(
                            fun(KeyValueMap) ->
%%                                ?DEBUG("KeyValueMap: ~p", [{is_map(KeyValueMap), KeyValueMap}]),
                                Status = util:to_int(maps:get(<<"status">>, KeyValueMap)),
                                if
                                    Status =:= 2 ->
                                        PlatformId = util:to_list(maps:get(<<"platform_id">>, KeyValueMap)),
                                        ServerId = util:to_list(maps:get(<<"server_id">>, KeyValueMap)),
                                        Expire = util:to_int(maps:get(<<"expire">>, KeyValueMap)),
                                        StartTimestamp = util:to_int(maps:get(<<"start_date">>, KeyValueMap)),
%%                                        StartDate = util:to_list(maps:get(<<"start_date">>, KeyValueMap)),
%%                                        StartTimestamp =
%%                                            case util_time:datetime_string_to_datetime(StartDate) of
%%                                                [Y, M, D, H, I, S] ->
%%                                                    util_time:datetime_to_timestamp({
%%                                                        [util:to_int(Y), util:to_int(M), util:to_int(D)],
%%                                                        [util:to_int(H), util:to_int(I), util:to_int(S)]
%%                                                    });
%%                                                Other -> ?WARNING("从后台获取时间格式字符串出错: ~p", [Other]),
%%                                                    util_time:timestamp()
%%                                            end,
                                        {true, #ets_client_heartbeat_verify{row_key = {PlatformId, ServerId},
                                            start_time = StartTimestamp, expire = Expire}};
                                    true -> false
                                end
                            end,
                            Data
                        ),
                    ets:insert_new(?ETS_CLIENT_HEARTBEAT_VERIFY, Data2Ets),
                    ok;
                true ->
                    ?ERROR("Code: ~p; Msg: ~p", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [?ADMIN_URL, Reason]),
            false
    end.

getPlayerPayTimesLimit() ->
    ?DEBUG("get player pay times limits from admin: ~p", [?PLAYER_PAY_TIMES_LIMIT]),
    ParamList = [
        {"platformId", "local"},
        {"serverId", "s153"}
    ],
    ParamStr = util_list:change_list_url(ParamList),
    ?DEBUG("info: ~p", [?PLAYER_PAY_TIMES_LIMIT ++ "?" ++ ParamStr]),
    case util_http:get(?PLAYER_PAY_TIMES_LIMIT ++ "?" ++ ParamStr) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            ?DEBUG("Code: ~p, data: ~p", [Code, is_list(Data)]),
            if
                Code =:= 0 ->
                    lists:foreach(
                        fun(Ele) ->
                            PlayerId = maps:get(<<"player_id">>, Ele),
                            PayTimes = maps:get(<<"pay_times">>, Ele),
                            mod_cache:update({player_pay_times, PlayerId}, PayTimes, 8640000000)
                        end,
                        Data
                    );
                true ->
                    ?ERROR("Code: ~p; Msg: ~p", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [?ADMIN_URL, Reason]),
            false
    end.

updateTestAccount() ->
    ?INFO("get test account data from admin: ~p", [{?TEST_ACCOUNT_FROM_ADMIN, ?IS_DEBUG}]),
%%    ?ASSERT(?IS_DEBUG, error),
    case util_http:get(?TEST_ACCOUNT_FROM_ADMIN) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            if
                Code =:= 0 ->
                    Data2Ets =
                        lists:filtermap(
                            fun(KeyValueMap) ->
                                {true, #ets_test_account{
                                    account = util:to_list(maps:get(<<"name">>, KeyValueMap)),
                                    privilege = util:to_int(maps:get(<<"privilege">>, KeyValueMap))
                                }}
                            end,
                            Data
                        ),
                    ets:insert_new(?ETS_TEST_ACCOUNT, Data2Ets),
                    ok;
                true ->
                    ?ERROR("Code: ~p; Msg: ~p", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [?ADMIN_URL, Reason]),
            false
    end.

getData() ->
    ?INFO("get client data from admin: ~p", [?ADMIN_URL]),
    case util_http:get(?ADMIN_URL) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
%%            ?DEBUG("Response: ~p", [Response]),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            if
                Code =:= 0 ->
%%                    VersionList = lists:filtermap(
                    lists:filtermap(
                        fun({Key, Value}) ->
                            case Key of
                                <<"rows">> ->
                                    R = lists:foldl(
                                        fun(Ele, _Tmp) ->
                                            Stats = util:to_int(maps:get(<<"stats">>, Ele)),
                                            NewVersionData = #ets_erget_setting{
                                                app_id = util:to_list(maps:get(<<"appId">>, Ele)),
                                                platform = util:to_list(maps:get(<<"platform">>, Ele)),
                                                versions = util:to_list(maps:get(<<"versions">>, Ele)),
                                                firstversions = util:to_list(maps:get(<<"firstVersions">>, Ele)),
                                                client_version = util:to_list(maps:get(<<"clientVersion">>, Ele)),
                                                is_close_charge = ?IF(maps:get(<<"isChargeOpen">>, Ele) =:= 1, 0, 1),
                                                ios_download_url = util:to_list(maps:get(<<"upgradeIosUrl">>, Ele)),
                                                android_download_url = util:to_list(maps:get(<<"upgradeAndroidUrl">>, Ele)),
                                                reload_url = util:to_list(maps:get(<<"reloadUrl">>, Ele)),
                                                status = Stats,
                                                is_native_pay = util:to_int(maps:get(<<"nativePay">>, Ele)),
                                                facebook_app_id = util:to_list(maps:get(<<"facebookAppId">>, Ele)),
                                                region = util:to_list(maps:get(<<"region">>, Ele)),
                                                channel = util:to_list(maps:get(<<"channel">>, Ele))
%%                                                channel = util:to_list(maps:get(<<"channel">>, Ele)),
%%                                                reviewing_versions = util:to_list(maps:get(<<"reviewingversions">>, Ele))
                                            },
%%                                            ?INFO("~p,~p,NewVersionData ~p", [?MODULE, util_time:timestamp(), NewVersionData]),
                                            ets:insert(?ETS_ERGET_SETTING, NewVersionData),
                                            NewPlatformData = #ets_platform_setting{
                                                platform = util:to_list(maps:get(<<"platform">>, Ele)),
                                                name = unicode:characters_to_binary(maps:get(<<"platformRemark">>, Ele))
                                            },
%%                                            ?INFO("~p,~p,NewPlatformData ~p", [?MODULE, util_time:timestamp(), NewPlatformData]),
                                            ets:insert(?ETS_PLATFORM_SETTING, NewPlatformData),
                                            %% 将指定app_id的reviewing_versions保存到ets中
                                            NewReviewingVersions = #ets_egret_reviewing_version{
                                                app_id = util:to_list(maps:get(<<"appId">>, Ele)),
                                                reviewing_versions = util:to_list(maps:get(<<"reviewingversions">>, Ele))
                                            },
                                            ets:insert(?ETS_EGRET_REVIEWING_VERSION, NewReviewingVersions),

                                            %% 更新中心服ets中的app_info
                                            update_app_info_in_ets(
                                                util:to_list(maps:get(<<"appId">>, Ele)),
                                                util:to_list(maps:get(<<"areaCode">>, Ele)),
                                                util:to_list(maps:get(<<"packageSize">>, Ele))
                                            ),

                                            %% 更新中心服ets中的domain
                                            mod_domain_filter:update_domain_in_ets(
                                                util:to_list(maps:get(<<"appId">>, Ele)),
                                                util:to_list(maps:get(<<"domain">>, Ele)),
                                                util:to_list(maps:get(<<"testDomain">>, Ele))
                                            ),

%%                                            ?DEBUG("payTimes: ~p", [util:to_int(maps:get(<<"payTimes">>, Ele))]),
                                            case util:to_int(maps:get(<<"payTimes">>, Ele)) of
                                                PayTimes when is_integer(PayTimes) ->
                                                    spawn(fun() -> mod_cache:update({platform_pay_times, list_to_atom(util:to_list(maps:get(<<"platform">>, Ele)))}, PayTimes, 8640000000) end);
                                                "undefined" -> ?INFO("there is no pay times send from admin")
                                            end
                                        end,
                                        [],
                                        Value
                                    ),
                                    {true, R};
                                _ ->
                                    false
                            end
                        end,
                        maps:to_list(Data)
                    ),
                    ok;
                true ->
                    ?ERROR("Code: ~p; Msg: ~p", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [?ADMIN_URL, Reason]),
            false
    end.

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    {IP, _} = cowboy_req:peer(Req0),
    Ip = inet_parse:ntoa(IP),
    PathId = cowboy_req:binding(id, Req0),
    if
        undefined == PathId ->
            Path = cowboy_req:path(Req0);
        true ->
            Path =
                case re:run(binary_to_list(cowboy_req:path(Req0)), cowboy_req:binding(id, Req0)) of
                    nomatch -> cowboy_req:path(Req0);
                    _ ->
                        [UrlPrefix, [] | UrlSuffix] = re:replace(binary_to_list(cowboy_req:path(Req0)), "/" ++ binary_to_list(cowboy_req:binding(id, Req0)), ""),
                        RealUrlPath = binary_to_list(UrlPrefix) ++ binary_to_list(UrlSuffix),
                        ?DEBUG("real url path: ~p", [list_to_binary(RealUrlPath)]),
                        list_to_binary(RealUrlPath)
                end
    end,
%%    Path = cowboy_req:path(Req),
    Req =
        try
            path_request(Path, Method, Ip, Req0)
        catch
            _:Reason ->
                ?ERROR("更新中心服ets数据的version和firstversion数据失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

chk_sign(Data, StringSign) ->
    DataMd5 = encrypt:md5(util:to_list(Data) ++ ?GM_SALT),
    ?DEBUG("~p~n", [{StringSign, DataMd5}]),
    ?ASSERT(StringSign == DataMd5, sign_error),
    ?DEBUG("StringSign: ~p", [StringSign]).

path_request(<<"/heartbeat_verify/setting">>, <<"POST">>, _Ip, Req) ->
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?DEBUG("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?INFO("Params: ~p", [ParamInfoList]),
    PlatformId = util:to_list(proplists:get_value(<<"platform_id">>, Params)),
    ServerId = util:to_list(proplists:get_value(<<"server_id">>, Params)),
    StartDateTimestamp = util:to_int(proplists:get_value(<<"start_date">>, Params)),
    Expire = util:to_int(proplists:get_value(<<"expire">>, Params)),
    Status = util:to_int(proplists:get_value(<<"status">>, Params)),
    ?DEBUG("heartbeat from admin: ~p", [{PlatformId, ServerId, StartDateTimestamp, Expire, Status}]),
    Resp =
        case Status of
            2 ->
                Data2Ets = #ets_client_heartbeat_verify{row_key = {PlatformId, ServerId}, expire = Expire,
                    start_time = StartDateTimestamp},
                ets:insert(?ETS_CLIENT_HEARTBEAT_VERIFY, Data2Ets),
                [{error_msg, 0}, {error_msg, "success"}];
            1 ->
                ets:delete(?ETS_CLIENT_HEARTBEAT_VERIFY, {PlatformId, ServerId}),
                [{error_msg, 0}, {error_msg, "success"}];
            Other ->
                ?ERROR("非法参数: ~p", [Other]),
                [{error_msg, "-1"}, {error_msg, "failure"}]
        end,
    web_server_util:output_text(
        Req,
        lib_json:encode(Resp)
    );
path_request(<<"/test_account/add">>, <<"POST">>, _Ip, Req) ->
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?DEBUG("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?INFO("Params: ~p", [ParamInfoList]),
    Account = util:to_list(proplists:get_value(<<"account">>, Params)),
    IsPrivilege = util:to_int(proplists:get_value(<<"privilege">>, Params)),
%%    Account = util:to_list(proplists:get_value(<<"account">>, ParamInfoList)),
    ?DEBUG("account from admin: ~p", [{Account, Account =:= "undefined"}]),
    Resp =
        if
            Account =:= "undefined" ->
                [{error_msg, "-2"}, {error_msg, "invalid parameters"}];
            true ->
                case mod_account:add_test_account(Account, IsPrivilege) of
                    true -> [{error_msg, "0"}, {error_msg, "scucess"}];
                    R -> ?ERROR("添加测试账号 非预期结果: ~p", [R]),
                        [{error_msg, "-1"}, {error_msg, "failure"}]
                end
        end,
    web_server_util:output_text(
        Req,
        lib_json:encode(Resp)
    );
path_request(<<"/customer_service/update_login_page_url">>, <<"POST">>, Ip, Req) ->
    ?INFO("ip: ~p", [Ip]),
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?DEBUG("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?INFO("Params: ~p", [Params]),
    _PlatformId = util:to_list(proplists:get_value(<<"platform">>, Params)),
%%    PlatformId = "local",
    mod_customer:updateCusSerData(),
    web_server_util:output_text(
        Req,
        lib_json:encode([{error_msg, "0"}, {error_msg, "scucess"}])
    );
path_request(<<"/update_version">>, <<"POST">>, Ip, Req) ->
    ?INFO("ip: ~p", [Ip]),
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?DEBUG("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?INFO("Params: ~p", [Params]),
    Version = util:to_list(proplists:get_value(<<"versions">>, Params)),
    FirstVersion = util:to_list(proplists:get_value(<<"firstVersions">>, Params)),
    Platform = util:to_list(proplists:get_value(<<"platform">>, Params)),
    Channel = util:to_list(proplists:get_value(<<"channel">>, Params)),
    IsCloseCharge = util:to_int(proplists:get_value(<<"isCloseCharge">>, Params)),
    ClientVersion = util:to_list(proplists:get_value(<<"clientVersion">>, Params)),
    PlatformName = proplists:get_value(<<"platformName">>, Params),
    AndroidDownloadUrl = util:to_list(proplists:get_value(<<"androidDownloadUrl">>, Params)),
    IOSDownloadUrl = util:to_list(proplists:get_value(<<"iOSDownloadUrl">>, Params)),
    IsNativePay = util:to_int(proplists:get_value(<<"nativePay">>, Params)),
    Stats = util:to_int(proplists:get_value(<<"stats">>, Params)),
    FacebookAppId = util:to_list(proplists:get_value(<<"facebookAppId">>, Params)),
    Region = util:to_list(proplists:get_value(<<"region">>, Params)),
    ReviewingVersions = util:to_list(proplists:get_value(<<"reviewingVersions">>, Params)),
    PackageSize = util:to_float(proplists:get_value(<<"packageSize">>, Params)),
    AreaCode = util:to_list(proplists:get_value(<<"areaCode">>, Params)),
    Domain = util:to_list(proplists:get_value(<<"domain">>, Params)),
    TestDomain = util:to_list(proplists:get_value(<<"testDomain">>, Params)),
    ?DEBUG("payTimes: ~p", [util:to_int(proplists:get_value(<<"payTimes">>, Params))]),
    case util:to_int(proplists:get_value(<<"payTimes">>, Params)) of
        PayTimes when is_integer(PayTimes) ->
            ?DEBUG("dddd"),
%%            Fun =
%%                fun() -> ?DEBUG("PayTimes: ~p", [PayTimes]), PayTimes end,
            spawn(fun() -> mod_cache:update({platform_pay_times, list_to_atom(Platform)}, PayTimes, 8640000000) end);
        "undefined" -> ?INFO("there is no pay times send from admin")
    end,
%%    Version = util:to_list(charge_handler:get_list_value(<<"versions">>, ParamInfoList)),
%%    FirstVersion = util:to_list(charge_handler:get_list_value(<<"firstversions">>, ParamInfoList)),
%%    Platform = util:to_list(charge_handler:get_list_value(<<"platform">>, ParamInfoList)),
    ?DEBUG("FirstVersion: ~p", [FirstVersion]),
    ?DEBUG("Version: ~p", [Version]),
    ?DEBUG("PlatformId: ~p", [Platform]),
    ?DEBUG("IsCloseCharge: ~p", [IsCloseCharge]),
    ?DEBUG("IsNativePay: ~p", [IsNativePay]),
    ?DEBUG("ClientVersion: ~p", [ClientVersion]),
    ?DEBUG("Stats: ~p", [Stats]),
    ReloadUrl =
        case proplists:get_value(<<"reloadUrl">>, Params) of
            "undefined" -> "https://debugapk.s3-ap-southeast-1.amazonaws.com/game.zip";
            ReloadUrl1 -> util:to_list(ReloadUrl1)
        end,
    ?DEBUG("ReloadUrl: ~p", [ReloadUrl]),
    AppId =
        case proplists:get_value(<<"appId">>, Params) of
            "undefined" -> "com.goldmaster.game";
            AppId1 -> util:to_list(AppId1)
        end,
    ?DEBUG("appId: ~p", [AppId]),
    ErgetSettingData =
        case ets:lookup(?ETS_ERGET_SETTING, AppId) of
            [R] when is_record(R, ets_erget_setting) ->
                #ets_erget_setting{app_id = OldAppId, versions = OldVersion, firstversions = OldFirstVersion,
                    is_close_charge = OldIsCloseCharge, client_version = OldClientVersion, reload_url = OldReloadUrl,
                    is_native_pay = OldIsNativePay, status = OldStats, android_download_url = OldAndroidDownloadUrl,
                    ios_download_url = OldIosDownloadUrl, facebook_app_id = OldFacebookAppId, region = OldRegion,
                    channel = OldChannel, platform = OldPlatformInEts %%, reviewing_versions = OldReviewingVersion
                } = R,
                ?DEBUG("OldVersion: ~p", [OldVersion]),
                ?DEBUG("OldFirstVersion: ~p", [OldFirstVersion]),
                R1 =
                    if
                        Version =/= OldVersion ->
                            R#ets_erget_setting{versions = Version};
                        true ->
                            R#ets_erget_setting{versions = OldVersion}
                    end,
                R2 =
                    if
                        FirstVersion =/= OldFirstVersion ->
                            R1#ets_erget_setting{firstversions = FirstVersion};
                        true ->
                            R1#ets_erget_setting{firstversions = OldFirstVersion}
                    end,
                R3 =
                    if
                        IsCloseCharge =/= OldIsCloseCharge ->
                            R2#ets_erget_setting{is_close_charge = IsCloseCharge};
                        true ->
                            R2#ets_erget_setting{is_close_charge = OldIsCloseCharge}
                    end,
                R4 =
                    if
                        ClientVersion =/= OldClientVersion ->
                            R3#ets_erget_setting{client_version = ClientVersion};
                        true ->
                            R3#ets_erget_setting{client_version = OldClientVersion}
                    end,
                ?DEBUG("OldAppId: ~p ~p", [OldAppId, OldAppId =/= AppId]),
                R5 =
                    if
                        AppId =/= OldAppId ->
                            R4#ets_erget_setting{app_id = AppId};
                        true ->
                            R4#ets_erget_setting{app_id = OldAppId}
                    end,
                R6 =
                    if
                        ReloadUrl =/= OldReloadUrl ->
                            R5#ets_erget_setting{reload_url = ReloadUrl};
                        true ->
                            R5#ets_erget_setting{reload_url = OldReloadUrl}
                    end,
                R7 =
                    if
                        IsNativePay =/= OldIsNativePay ->
                            R6#ets_erget_setting{is_native_pay = IsNativePay};
                        true ->
                            R6#ets_erget_setting{is_native_pay = OldIsNativePay}
                    end,
                R8 = ?IF(Stats =/= OldStats, R7#ets_erget_setting{status = Stats}, R7),
                R9 = ?IF(AndroidDownloadUrl =/= OldAndroidDownloadUrl,
                    R8#ets_erget_setting{android_download_url = AndroidDownloadUrl}, R8),
                R10 = ?IF(IOSDownloadUrl =/= OldIosDownloadUrl,
                    R9#ets_erget_setting{ios_download_url = IOSDownloadUrl}, R9),
                R11 = ?IF(FacebookAppId =/= OldFacebookAppId, R10#ets_erget_setting{facebook_app_id = FacebookAppId}, R10),
                R12 = ?IF(OldRegion =/= Region, R11#ets_erget_setting{region = Region}, R11),
                R13 = ?IF(OldChannel =/= Channel, R12#ets_erget_setting{channel = Channel}, R12),
                R14 = ?IF(OldPlatformInEts =/= Platform, R13#ets_erget_setting{platform = Platform}, R13),
                ets:delete(?ETS_ERGET_SETTING, AppId),
                R14;
%%                R15 = ?IF(OldReviewingVersion =/= ReviewingVersions, R14#ets_erget_setting{reviewing_versions = ReviewingVersions}, R14),
%%                ets:delete(?ETS_ERGET_SETTING, AppId),
%%                R15;
            [] ->
                #ets_erget_setting{
                    app_id = AppId,
                    platform = Platform,
                    versions = Version,
                    firstversions = FirstVersion,
%%                    reviewing_versions = ReviewingVersions,
                    is_close_charge = IsCloseCharge,
                    client_version = ClientVersion,
                    reload_url = ReloadUrl,
                    is_native_pay = IsNativePay,
                    status = Stats,
                    facebook_app_id = FacebookAppId,
                    ios_download_url = IOSDownloadUrl,
                    android_download_url = AndroidDownloadUrl,
                    region = Region,
                    channel = Channel
                }
        end,
    ?DEBUG("ErgetSettingData: ~p", [ErgetSettingData]),
    Res = ets:insert_new(?ETS_ERGET_SETTING, ErgetSettingData),
    ?DEBUG("Res: ~p", [Res]),
    PlatformData =
        case ets:lookup(?ETS_PLATFORM_SETTING, Platform) of
            [P] when is_record(P, ets_platform_setting) ->
                #ets_platform_setting{platform = OldPlatform, name = OldPlatformName} = P,
                ?DEBUG("OldPlatform: ~p", [OldPlatform]),
                ?DEBUG("OldPlatformName: ~p", [OldPlatformName]),
                P1 = ?IF(OldPlatform =:= Platform, P#ets_platform_setting{platform = OldPlatform},
                    P#ets_platform_setting{platform = Platform}),
                P2 = ?IF(OldPlatformName =:= PlatformName, P1#ets_platform_setting{name = OldPlatformName},
                    P1#ets_platform_setting{name = PlatformName}),
                ets:delete(?ETS_PLATFORM_SETTING, Platform),
                P2;
            [] ->
                #ets_platform_setting{
                    platform = Platform,
                    name = PlatformName
                }
        end,
    ?DEBUG("PlatformData: ~p", [PlatformData]),
    PlatformInfo = ets:insert_new(?ETS_PLATFORM_SETTING, PlatformData),
    %% 更新指定app_id的reviewing_versions数据到ets中
    EgretReviewingVerData =
        case ets:lookup(?ETS_EGRET_REVIEWING_VERSION, AppId) of
            [O] when is_record(O, ets_egret_reviewing_version) ->
                #ets_egret_reviewing_version{reviewing_versions = OldReviewingVer} = O,
                O1 = ?IF(OldReviewingVer =:= ReviewingVersions,
                    O#ets_egret_reviewing_version{reviewing_versions = OldReviewingVer},
                    O#ets_egret_reviewing_version{reviewing_versions = ReviewingVersions}),
                ets:delete(?ETS_EGRET_REVIEWING_VERSION, AppId),
                O1;
            _ ->
                #ets_egret_reviewing_version{app_id = AppId, reviewing_versions = ReviewingVersions}
        end,
    ?DEBUG("EgretReviewingVerData: ~p", [EgretReviewingVerData]),
    ReviewingRes = ets:insert_new(?ETS_EGRET_REVIEWING_VERSION, EgretReviewingVerData),
    ?DEBUG("ReviewingRes: ~p", [ReviewingRes]),
    %% 更新ets中的app_info数据，修改游戏前端资源包大小，与区号
    update_app_info_in_ets(AppId, AreaCode, PackageSize),
    %% 更新ets中的域名数据
    mod_domain_filter:update_domain_in_ets(AppId, Domain, TestDomain),
    web_server_util:output_text(
        Req,
        lib_json:encode([{msg, "Success"}, {version, Res}, {platform, PlatformInfo}])
    ).

%% ----------------------------------
%% @doc 	更新app信息到ets中，package_size和area_code
%% @end
%% ----------------------------------
update_app_info_in_ets(AppId, AreaCode, PackageSize) ->
    ?DEBUG("update_app_info_in_ets: ~p", [{PackageSize, is_list(PackageSize), is_float(PackageSize)}]),
    %% 更新指定app_id的reviewing_versions数据到ets中
    PackageInfo =
        case ets:lookup(?ETS_APP_INFO, AppId) of
            [O] when is_record(O, ets_app_info) ->
                #ets_app_info{package_size = OldPackageSize, area_code = OldAreaCode} = O,
                O1 = ?IF(OldPackageSize =:= PackageSize,
                    O#ets_app_info{package_size = OldPackageSize},
                    O#ets_app_info{package_size = PackageSize}),
                O2 = ?IF(OldAreaCode =:= AreaCode,
                    O1#ets_app_info{area_code = OldAreaCode},
                    O1#ets_app_info{area_code = AreaCode}),
                ets:delete(?ETS_APP_INFO, AppId),
                O2;
            _ ->
                #ets_app_info{app_id = AppId, package_size = PackageSize, area_code = AreaCode}
        end,
    ?DEBUG("PackageInfo: ~p", [PackageInfo]),
    Res = ets:insert_new(?ETS_APP_INFO, PackageInfo),
    ?DEBUG("UpdatePackageInfo: ~p", [Res]),
    ok.

%% ----------------------------------
%% @doc 	从ets中获取app信息，package_size和area_code
%% @end
%% ----------------------------------
get_app_info_from_ets(AppId, area_code) ->
    case get_app_info_from_ets(AppId) of
        R when is_record(R, ets_app_info) ->
            util:to_list(R#ets_app_info.area_code);
        null -> "886"
    end;
get_app_info_from_ets(AppId, package_size) ->
    case get_app_info_from_ets(AppId) of
        R when is_record(R, ets_app_info) ->
            util:to_float(R#ets_app_info.package_size);
        null -> 1401.11
    end.
%% ----------------------------------
%% @doc 	从ets中获取app信息，package_size和area_code
%% @end
%% ----------------------------------
get_app_info_from_ets(AppId) ->
    case ets:lookup(?ETS_APP_INFO, AppId) of
        [R] when is_record(R, ets_app_info) -> R;
        _ -> null
    end.