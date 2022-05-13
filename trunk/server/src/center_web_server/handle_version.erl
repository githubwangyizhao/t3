%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. 2月 2021 上午 11:15:56
%%%-------------------------------------------------------------------
-module(handle_version).
-author("Administrator").

-export([init/2]).

-include("system.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").
-include("charge.hrl").

-define(TSL, 2).
%%-define(SETTING_URL, "http://47.101.164.86:7080/game").
%%-define(SETTING_URL, "http://www.bountymasters.com:7080/game").
%%-define(SETTING_URL, "http://47.102.119.76:7080/game").
-define(SETTING_URL(Env),
    case Env of
        "develop" -> "";
        "testing" -> "http://47.102.119.76:7080/game";
        "testing_oversea" -> "http://8.210.191.53:7080/game";
        "reviewing" -> "http://8.218.105.9:7080/game";
        _ -> "https://www.daggerofbonuses.com:7080/game"
    end
).
-define(SETTING_JSON, "/resource/setting.json").

%%-define(CDN_PORT(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL,
%%    "", ?IF(PlatformId =:= ?PLATFORM_TEST, ":7080", ":7080"))).
-define(CDN_PORT(Env),
    ?IF(Env =:= "develop",
        "",
        ?IF(Env =:= "testing",
            ":7080",
            ?IF(Env =:= "testing_oversea",
                ":7080",
                ":7080"
            )
        )
    )
).
%%-define(LOGIN_PORT, ?IF(?IS_DEBUG =:= true, ":7001", "")).
-define(LOGIN_PORT, "").
%%-define(CENTER_PORT, ?IF(?IS_DEBUG =:= true, "", "")).
-define(CENTER_PORT, "").

%% 前端资源
%% CDN_HOST ++ CDN_PORT ++ CDN ++ CDN_PATh
%% 例: http://47.102.119.76:7080/game/resource
%%     http://47.102.119.76:7080/indonesia/game/resource
%%     http://www.bountymasters.com:7080/indonesia/game/resource
%%-define(CDN_HOST, ?IF(?IS_DEBUG =:= true, "http://47.102.119.76", "http://www.bountymasters.com")).
-define(CDN_HOST(Env),
    case Env of
        "develop" -> "http://192.168.31.100/t3";
        "testing" -> "http://47.102.119.76";
        "testing_oversea" -> "http://8.210.191.53";
        "reviewing" -> "http://8.218.105.9";
        _ -> "https://www.daggerofbonuses.com"
    end
).
%% hk测试服
%%    ?IF(PlatformId =:= ?PLATFORM_TEST, "http://8.210.191.53", "http://www.bountymasters.com"))).
%%-define(CDN_HOST(PlatformId), ?IF(
%%    PlatformId =:= ?PLATFORM_LOCAL, "http://192.168.31.100/t3",
    %% 国内阿里云测试服
%%    ?IF(PlatformId =:= ?PLATFORM_TEST, "http://47.102.119.76", "http://www.bountymasters.com"))).
    %% hk测试服
%%    ?IF(PlatformId =:= ?PLATFORM_TEST, "http://8.210.191.53", "http://www.bountymasters.com"))).
-define(CDN_PATH, "/game/resource/").

%% 获取最近服务器列表
%% LOGIN_HOST ++ LOGIN_PATH ++ PlatformId ++ Login_QUERY
%% 例：http://47.102.119.76:7001/login?platform_id=aurora&acc_id=[acc_id]&password=[password]&...OSPlatform=[OSPlatform]
%%-define(LOGIN_HOST, ?IF(?IS_DEBUG =:= true, "http://47.102.119.76", "http://login.bountymasters.com")).
%%-define(LOGIN_HOST(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, "http://192.168.31.100:13004",
    %% 国内阿里云测试服
%%    ?IF(PlatformId =:= ?PLATFORM_TEST, "http://47.102.119.76:7001", "http://login.bountymasters.com"))).
    %% hk测试服
%%    ?IF(PlatformId =:= ?PLATFORM_TEST, "http://8.210.191.53:7001", "http://login.bountymasters.com"))).
-define(LOGIN_HOST(Env),
    case Env of
        "develop" -> "http://192.168.31.100:13004";
        "testing" -> "http://47.102.119.76:7001";
        "testing_oversea" -> "http://8.210.191.53:7001";
        "reviewing" -> "http://8.218.105.9:7001";
        _ -> "http://login.daggerofbonuses.com"
    end
).
-define(LOGIN_PATH, "/login?platform_id=").
-define(LOGIN_CHANNEL_PATH, "&channel=").
-define(LOGIN_QUERY, "&acc_id=[acc_id]&password=[password]&promote=[promote]&version=[version]&app_id=[app_id]&facebook_apps_id=[facebook_apps_id]&region=[region]&registration_id=[registration_id]&OSPlatform=[OSPlatform]").

%% 获取全部服务器列表
%% LOGIN_HOST ++ LOGIN_ALL_PATh ++ LOGIN_ALL_QUERY
%% 例: http://47.102.119.76:7001/all?platform_id=aurora&acc_id=[acc_id]&password=[password]&channel=[channel]
-define(LOGIN_ALL_PATH, "/all?platform_id=").
-define(LOGIN_ALL_CHANNEL_PATH, "&channel=").
-define(LOGIN_ALL_QUERY, "&acc_id=[acc_id]&password=[password]&app_id=[app_id]&version=[version]").

%% 获取setting配置
%% VERSION_HOST ++ CENTER_PORT ++ VERSION_PATH ++ VERSION_QUERY
%% 例: http://47.102.119.76:6663/upgrade?app_id=[app_id]&version=[version]&platform=[platform]&mode=production
%%     http://version.bountymasters.com/upgrade?app_id=[app_id]&version=[version]&platform=[platform]&mode=production
%%-define(VERSION_HOST, ?IF(?IS_DEBUG =:= true, "http://47.102.119.76", "http://version.bountymasters.com")).
%%-define(VERSION_HOST(PlatformId), ?IF(PlatformId =:= ?PLATFORM_LOCAL, "http://192.168.31.100",
    %% 国内阿里云测试服
%%    ?IF(PlatformId =:= ?PLATFORM_TEST, "http://47.102.119.76:6663", "http://version.bountymasters.com"))).
    %% hk测试服
%%    ?IF(PlatformId =:= ?PLATFORM_TEST, "http://8.210.191.53:6663", "http://version.bountymasters.com"))).
-define(VERSION_HOST(Env),
    case Env of
        "develop" -> "http://192.168.31.100:6663";
        "testing" -> "http://47.102.119.76:6663";
        "testing_oversea" -> "http://8.210.191.53:6663";
        "reviewing" -> "http://8.218.105.9:6663";
        _ -> "https://version.daggerofbonuses.com"
    end
).
%% hk测试服
%%    ?IF(PlatformId =:= ?PLATFORM_TEST, "http://8.210.191.53:6663", "http://version.bountymasters.com"))).
-define(VERSION_PATH, "/upgrade").
-define(VERSION_QUERY, "?app_id=[app_id]&version=[version]&platform=[platform]&mode=production").

%% 客户端获取静态资源包下载地址接口
%% VERSION_HOST ++ CENTER_PORT ++ STATIC_RESOURCE_PATH ++ STATIC_RESOURCE_QUERY
%% 例: http://47.102.119.76:6663/static_resource?platform_id=aurora&acc_id=[acc_id]&password=[password]&channel=[channel]
-define(STATIC_RESOURCE_PATH, "/static_resource").
-define(STATIC_RESOURCE_QUERY, "?app_id=[app_id]&version=[version]").

%% 谷歌支付回调地址
%% GOOGLE_PAY_HOST ++ CHARGE_PORT ++ GOOGLE_PAY_VALIDATION_PATH
%% 例: http://47.102.119.76:9993/google/pay_validation
%%     http://googlepay.bountymasters.com/google/pay_validation
%%-define(GOOGLE_PAY_HOST, ?IF(?IS_DEBUG =:= true, "http://47.102.119.76", "http://googlepay.bountymasters.com")).
-define(PAY_VALIDATION_HOST(Env),
    case Env of
        "develop" -> "http://192.168.31.100";
        "testing" -> "https://pay.daggerofbonuses.com";
        "testing_oversea" -> "https://pay.daggerofbonuses.com";
        "reviewing" -> "https://pay.daggerofbonuses.com";
        _ -> "https://pay.daggerofbonuses.com"
    end
).
%%-define(CHARGE_PORT, ?IF(?IS_DEBUG =:= true, ":9993", "")).
%%-define(GOOGLE_PAY_VALIDATION_PATH, "/google/pay_validation").
%%-define(APPLE_PAY_VALIDATION_PATH, "/apple/pay_validation").
-define(GOOGLE_PAY_VALIDATION_PATH(Env),
    case Env of
        "reviewing" -> "/google/pay_validation_reviewing";
        _ -> "/google/pay_validation"
    end).
-define(APPLE_PAY_VALIDATION_PATH(Env),
    case Env of
        "reviewing" -> "/apple/pay_validation_reviewing";
        _ -> "/apple/pay_validation"
    end).

-define(APP_NOTICE_PATH, "/app_notice").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                ?ERROR("获取区服列表失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"GET">>, Req) ->
    Params = cowboy_req:parse_qs(Req),
    Env = env:get(env, "production"),
    ?INFO("Env: ~p", [{Env, env:get(env)}]),
    ?DEBUG("map: ~p", [Params]),
    OSPlatform =
        case proplists:get_value(<<"os_platform">>, Params) of
            ?UNDEFINED -> "Android";
            OSPlatformInQuery -> util:to_list(OSPlatformInQuery)
        end,
    ?INFO("OSPlatforml: ~p", [{OSPlatform, is_list(OSPlatform)}]),
%%    OSPlatform = ?IF(util:to_int(OSPlatform1) =:= 1, "iOS", "Android"),
%%    ?INFO("OSPlatforml: ~p", [{OSPlatform1, OSPlatform}]),
    AppId = util:to_list(proplists:get_value(<<"app_id">>, Params)),
    Version = util:to_int(util:to_list(proplists:get_value(<<"version">>, Params))),
%%    PlatformId = ?IF(util:to_list(proplists:get_value(<<"platform_id">>, Params)) =:= "undefined", "local",
%%        util:to_list(proplists:get_value(<<"platform_id">>, Params))),
    TrackerToken = util:to_list(proplists:get_value(<<"tracker_token">>, Params)),
    {PlatformId, Channel} = mod_adjust_info:get_platform_by_tracker_token(TrackerToken),
    ?INFO("TrackerToken: ~p", [{TrackerToken, PlatformId, Channel}]),
    Setting = case proplists:get_value(<<"setting">>, Params) of
                  undefined -> 0;
                  S -> util:to_int(S)
              end,
    ?DEBUG("Setting: ~p, ~p", [Setting, Setting =/= 1]),
    ?DEBUG("dd: ~p", [Version >= ?TSL]),
    if
        Setting =/= 1 ->
            if
                Version > ?TSL ->
                    web_server_util:output_text(
                        Req,
                        lib_json:encode([{version, ?SD_IOS_VERSION}, {setting, ?SETTING_URL(Env) ++ ?SETTING_JSON}])
                    );
                true ->
                    [PlatformName] =
                        lists:filtermap(
                            fun ({Platform}) ->
                                if
                                    Platform =:= PlatformId -> {true, Platform};
                                    true -> false
                                end
                            end,
                            t_platform:get_keys()
                        ),
                    ?DEBUG("PlatformName: ~p", [PlatformName]),
                    web_server_util:output_text(
                        Req,
                        lib_json:encode([{version, ?SD_IOS_VERSION},
                            {setting, ?SETTING_URL(Env) ++ "/" ++ PlatformName ++ ?SETTING_JSON}])
                    )
            end;
        true ->
%%            PlatformIdList = getAppIdByPlatform(PlatformId),
            PlatformIdList = getVersionByApp(AppId),
            ?INFO("platform_id_list: ~p ~p", [length(PlatformIdList), PlatformIdList]),
            {VersionsInEts, FirstVersionsInEts, IsChargeCloseInEts, Region, ChannelInEts, ReviewingVersionsInEts, VersionInEts, StatusInEts, PlatformInEts} =
                if
                    length(PlatformIdList) >= 1 ->
                        ?DEBUG("dd: ~p", [hd(PlatformIdList)]),
                        hd(PlatformIdList);
                    true -> {"2021032002", "2021030601", 0, "TWD", false, "2021030601", Version, 0, ?DEFAULT_PLATFORM(Env)}
                end,
            ?INFO("VersionInEts: ~p FirstVersionsInEts: ~p Others: ~p",
                [VersionsInEts, FirstVersionsInEts, {IsChargeCloseInEts, Region, VersionInEts, ReviewingVersionsInEts}]),
            RealPlatformId = ?IF(PlatformId =:= null, PlatformInEts, PlatformId),
            RealChannel = ?IF(Channel =:= null, ChannelInEts, Channel),
            RealRegion =
                case ets:lookup(?ETS_REGION_INFO, TrackerToken) of
                    [Res] when is_record(Res, ets_region_info) ->
                        Res#ets_region_info.currency;
                    _ -> Region
                end,

            %% 当包处于审核状态(ets中status=1)的时候，判断客户端上报的version与ets中的client_version的大小
            %% 若version > client_version，表明当前打开包的人是审核人员，此时的versions必须是ets中的reviewing_versions的值
            %% 若version <= client_version，表明当前打开包的，是老玩家，此时的version必须是ets中的versions的值
            %% 注：当某个包正在审核时，必须保证后台apk/ipa管理下的这个包的“客户端版本号”小于包里的版本号，
            %% 这样才能既保证老玩家正常登录游戏，又保证审核人员的包里可以用最新的js资源
            RealVersions =
                if
                    StatusInEts =:= 1 ->
                        [V, M] = string:tokens(VersionInEts, "."),
                        UpgradeVersion = util:to_int(V),
                        ReloadVersion = util:to_int(M),
                        ?INFO("match version: ~p", [{VersionInEts, UpgradeVersion, ReloadVersion, Version, Version >= UpgradeVersion}]),
                        ?IF(Version > UpgradeVersion, ReviewingVersionsInEts, VersionsInEts);
                    true -> VersionsInEts
                end,
            ?INFO("RealVersions: ~p", [RealVersions]),

            Cdn =
                case Region of
                    ?REGION_CURRENCY_TW ->
                        "";
                    _ ->
                        ""
                end,
            RealCdn =
                case OSPlatform of
                    "iOS" -> Cdn ++ "/iOS";
                    _ -> Cdn
                end,
            ?INFO("RealCdn: ~p Cdn: ~p IsChargeCloseInEts: ~p", [RealCdn, Cdn, IsChargeCloseInEts]),
            Response = [
                {cdn, ?CDN_HOST(Env) ++ ?CDN_PORT(Env) ++ RealCdn ++ ?CDN_PATH},
%%                {cdn, ?CDN_HOST(PlatformId) ++ ?CDN_PORT(PlatformId) ++ Cdn ++ ?CDN_PATH},
                {server_list_url_recent, ?LOGIN_HOST(Env) ++ ?LOGIN_PORT ++ ?LOGIN_PATH ++ RealPlatformId ++
                    ?LOGIN_CHANNEL_PATH ++ RealChannel ++ ?LOGIN_QUERY},
                {server_list_url_all, ?LOGIN_HOST(Env) ++ ?LOGIN_PORT ++ ?LOGIN_ALL_PATH ++ RealPlatformId ++
                    ?LOGIN_ALL_CHANNEL_PATH ++ RealChannel ++ ?LOGIN_ALL_QUERY},
                {upgrade, ?VERSION_HOST(Env) ++ ?CENTER_PORT ++ ?VERSION_PATH ++ ?VERSION_QUERY},
                {static_resource, ?VERSION_HOST(Env) ++ ?CENTER_PORT ++ ?STATIC_RESOURCE_PATH ++ ?STATIC_RESOURCE_QUERY},
%%                {google_pay_validation, ?PAY_VALIDATION_HOST(Env) ++ ?CHARGE_PORT ++ ?GOOGLE_PAY_VALIDATION_PATH},
%%                {apple_pay_validation, ?PAY_VALIDATION_HOST(Env) ++ ?CHARGE_PORT ++ ?APPLE_PAY_VALIDATION_PATH},
                {google_pay_validation, ?PAY_VALIDATION_HOST(Env) ++ ?GOOGLE_PAY_VALIDATION_PATH(Env)},
                {apple_pay_validation, ?PAY_VALIDATION_HOST(Env) ++ ?APPLE_PAY_VALIDATION_PATH(Env)},
                {app_notice, ?VERSION_HOST(Env) ++ ?APP_NOTICE_PATH ++ ?STATIC_RESOURCE_QUERY},
                {versions, RealVersions},
                {firstversions, FirstVersionsInEts},
                {isdebug, 0},
%%                {platform_id, PlatformId},
                {platform_id , RealPlatformId},
                {channel, RealChannel},
                {region, RealRegion},
                {server_list_group_num, 100},
                {is_product, ?CDN_HOST(Env) ++ ?CENTER_PORT ++ "/version"},
                {is_open, ?IF(IsChargeCloseInEts =:= 1, 0, 1)},
                {package_size, handle_update_version:get_app_info_from_ets(AppId, package_size)}
            ],
            ?DEBUG("versionResponse: ~p", [Response]),
            web_server_util:output_text(
                Req,
                lib_json:encode(Response)
            )
    end.

getVersionByApp(AppId) ->
    ?DEBUG("dddd: ~p", [ets:lookup(?ETS_ERGET_SETTING, AppId)]),
    case ets:lookup(?ETS_ERGET_SETTING, AppId) of
        DataInEts when is_list(DataInEts) ->
            case length(DataInEts) of
                0 -> ?ERROR("version接口通过app_id获取erget_setting数据非预期结果: ~p", [AppId]),
                    Env = env:get(env, "production"),
                    [{"2021062101", "2021062101", 1, "TWD", "local_test", "2021062101", "1.2", 1, ?DEFAULT_PLATFORM(Env)}];
                Len ->
                    [#ets_erget_setting{
                        platform = PlatformInEts,
                        versions = VersionsInEts,
                        firstversions = FirstVersionsInEts,
                        is_close_charge = IsCloseChargeInEts,
                        region = RegionInEts,
                        channel = ChannelInEts,
                        client_version = ClientVersion,
                        status = Status
                    }] = DataInEts,
                    ?INFO("~p region ~p", [AppId, {RegionInEts, Len}]),
                    ReviewingVer =
                        case ets:lookup(?ETS_EGRET_REVIEWING_VERSION, AppId) of
                            [R] when is_record(R, ets_egret_reviewing_version) ->
                                R#ets_egret_reviewing_version.reviewing_versions;
                            Other ->
                                ?ERROR("~p在获取审核期间前端资源版本号时出错, Reason: ~p", [AppId, Other]),
                                "2021100601"
                        end,
                    [{VersionsInEts, FirstVersionsInEts, IsCloseChargeInEts, RegionInEts, ChannelInEts, ReviewingVer, ClientVersion, Status, PlatformInEts}]
            end;
        Other ->
            ?ERROR("version接口通过app_id获取erget_setting数据非预期结果: ~p", [{AppId, Other}]),
            Env = env:get(env, "production"),
            [{"2021062101", "2021062101", 1, "TWD", "local_test", "2021062101", "1.2", 1, ?DEFAULT_PLATFORM(Env)}]
    end.

%%getAppIdByPlatform(Platform) ->
%%    ?DEBUG("Ets: ~p", [ets:tab2list(?ETS_ERGET_SETTING)]),
%%    lists:filtermap(
%%        fun (Ele) ->
%%            #ets_erget_setting{
%%                platform = PlatformInEts,
%%                versions = VersionsInEts,
%%                firstversions = FirstVersionsInEts,
%%                is_close_charge = IsCloseChargeInEts
%%            } = Ele,
%%            ?DEBUG("PlatformInEts: ~p Platform: ~p", [PlatformInEts, Platform]),
%%            if
%%                PlatformInEts =:= Platform -> {true, {VersionsInEts, FirstVersionsInEts, IsCloseChargeInEts}};
%%                true -> false
%%            end
%%        end,
%%        ets:select(?ETS_ERGET_SETTING, [{#ets_erget_setting{platform = Platform, _ = '_'}, [], ['$_']}])
%%        ets:tab2list(?ETS_ERGET_SETTING)
%%    ).