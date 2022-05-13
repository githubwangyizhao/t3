%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 3月 2021 下午 02:01:52
%%%-------------------------------------------------------------------
-module(handle_upgrade).
-author("Administrator").

-include("system.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").

%% API
-export([init/2]).

-define(TSL, 3).
-define(VER, 14).
%%-define(ANDROID_DOWNLOAD_URL, "https://goldenmaster1.s3-ap-southeast-1.amazonaws.com/").
%%-define(IOD_DOWNLOAD_URL, "https://iosdownloads.site/install/3dvhvzpa1gcd-goldmaster-292").
-define(ALI_IP138_TOKEN, "APPCODE 59815c4fcc8a4366b2645c3ae17d5e64").
-define(IP_138_TOKEN, "3d454d67330cfcd3ea792fcc4660016a").
-define(CountrySignTupleList, [{indonesia, "印度尼西亚"}, {thailand, "泰国"}]).

-define(RELOAD_URL, "https://debugapk.s3-ap-southeast-1.amazonaws.com/game.zip").
-define(ANDROID_DOWNLOAD_URL, "https://goldenmaster1.s3-ap-southeast-1.amazonaws.com/goldenmaster.apk").
-define(IOD_DOWNLOAD_URL, "").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try
            case Method of
                <<"POST">> -> upgrade(Method, Req0);
                <<"GET">> -> handle(Method, Req0)
            end
        catch
            _:Reason ->
                ?ERROR("获取版本更新信息失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

getCountyByIpFromAli(Req) ->
    ?INFO("ddd: ~p", [cowboy_req:parse_header(<<"x-forwarded-for">>, Req)]),
    {IP, _} = cowboy_req:peer(Req),
    Ip = cowboy_req:parse_header(<<"x-forwarded-for">>, Req),
%%        if
%%            ?IS_DEBUG =:= true ->
                % 测试用 泰国ip
%%                "195.190.133.255";
        % 测试用 印尼ip
%%                "129.227.33.150";
        % 测试用 香港ip
%%                "43.225.47.95";
%%            true ->
%%                cowboy_req:parse_header(<<"x-forwarded-for">>, Req)
%%                inet_parse:ntoa(IP)
%%        end,
    Url = "http://ali.ip138.com/ip/?datatype=jsonp&ip=" ++ Ip,
    ?INFO("ip: ~p Url: ~p", [Ip, Url]),
    ?DEBUG("length: ~p, Ip: ~p", [length(Ip), Ip]),
    RealIp =
        if
            length(Ip) > 1 ->
                hd(Ip);
            true ->
                Ip
        end,
    ?DEBUG("RealIp: ~p", [RealIp]),
    case httpc:request(get, {Url, [{"Authorization", ?ALI_IP138_TOKEN}]}, [], []) of
        {ok, {{_, RespCode, _}, _, HtmlResultJson}} ->
            if
                RespCode =/= 200 ->
                    ?ERROR("ip138 response faliure: ~p", [RespCode]),
                    failure;
                true ->
                    Response = jsone:decode(util:to_binary(HtmlResultJson)),
                    ?DEBUG("Response: ~p", [Response]),
                    Ret = util:to_atom(maps:get(<<"ret">>, Response)),
                    RetIp = maps:get(<<"ip">>, Response),
                    Data = maps:get(<<"data">>, Response),
                    ?INFO("Ret: ~p RetIp: ~p", [Ret, RetIp]),
                    ?DEBUG("Code: ~p", [Ret]),
                    ?DEBUG("Data: ~p", [Data]),
                    if
                        Ret == ok ->
                            Country = hd(Data),
                            MatchRes =
                                lists:filtermap(
                                    fun (S) ->
                                        #ets_platform_setting{
                                            platform = Sign,
                                            name = CountryName
                                        } = S,
                                        MatchCountry = unicode:characters_to_binary(CountryName),
                                        if
                                            Country =:= MatchCountry -> {true, Sign};
                                            true -> false
                                        end
                                    end,
                                    ets:tab2list(?ETS_PLATFORM_SETTING)
                                ),
                            ?IF(length(MatchRes) =:= 1, hd(MatchRes), failure);
                        true ->
                            ?ERROR("ip api return failure == ret: ~p", [{Url, Ret}]),
                            failure
                    end
            end;
        ErrorReason ->
            ?ERROR("ip api failure==error:~p", [{Url, ErrorReason}]),
            failure
    end.

getCountryByIpFromIp138(Req) ->
    ?INFO("ddd: ~p", [cowboy_req:parse_header(<<"x-forwarded-for">>, Req)]),
    {IP, _} = cowboy_req:peer(Req),
    Ip =
        if
            ?IS_DEBUG =:= true ->
                % 测试用 泰国ip
%%                "195.190.133.255";
                % 测试用 印尼ip
                "129.227.33.150";
                % 测试用 香港ip
%%                "43.225.47.95";
            true ->
                cowboy_req:parse_header(<<"x-forwarded-for">>, Req)
%%                inet_parse:ntoa(IP)
        end,
    ?INFO("ip: ~p", [Ip]),
    Url = "http://api.ip138.com/ip/?ip=" ++ Ip ++ "&datetype=jsonp&token=" ++ ?IP_138_TOKEN,
    case util_http:get(Url) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Ret = util:to_atom(maps:get(<<"ret">>, Response)),
            RetIp = maps:get(<<"ip">>, Response),
            Data = maps:get(<<"data">>, Response),
            ?INFO("Ret: ~p RetIp: ~p", [Ret, RetIp]),
            ?DEBUG("Code: ~p", [Ret]),
            ?DEBUG("Data: ~p", [Data]),
            if
                Ret == ok ->
                    Country = hd(Data),
                    MatchRes =
                        lists:filtermap(
                            fun ({Sign, Ele}) ->
                                MatchCountry = unicode:characters_to_binary(Ele),
                                if
                                    Country =:= MatchCountry -> {true, Sign};
                                    true -> false
                                end
                            end,
                            ?CountrySignTupleList
                        ),
                    ?IF(length(MatchRes) =:= 1, hd(MatchRes), failure);
                true ->
                    ?ERROR("ip api return failure == ret: ~p", [{Url, Ret}]),
                    failure
            end;
        ErrorReason ->
            ?ERROR("ip api failure==error:~p", [{Url, ErrorReason}]),
            failure
    end.

getClientVersionFromEts(AppId) ->
    AppIdString = ?IF(is_list(AppId), AppId, ?IF(is_atom(AppId), atom_to_list(AppId), "")),
    ?DEBUG("lookup: ~p appId: ~p type: ~p", [ets:lookup(?ETS_ERGET_SETTING, AppIdString), AppIdString, is_list(AppIdString)]),
    case ets:lookup(?ETS_ERGET_SETTING, AppIdString) of
        [R] when is_record(R, ets_erget_setting) ->
            #ets_erget_setting{client_version = OldClientVersion, ios_download_url = IosDownloadUrl,
                android_download_url = AndroidDownloadUrl, reload_url = ReloadUrl, platform = Platform, region = Region} = R,
            [TSL, VER] = string:tokens(OldClientVersion, "."),
            {util:to_int(TSL), util:to_int(VER), OldClientVersion, Platform, IosDownloadUrl, AndroidDownloadUrl, ReloadUrl, Region};
        [] ->
            {util:to_int(?TSL), util:to_int(?VER), util:to_list(?TSL) ++ "." ++ util:to_list(?VER), "invalid appId", "", "", ""}
    end.
%%getClientVersionFromEts(Platform) ->
%%    ?INFO("lookup: ~p platform: ~p type: ~p", [ets:lookup(?ETS_ERGET_SETTING, Platform), Platform, is_list(Platform)]),
%%    PlatformString = ?IF(is_list(Platform), Platform, ?IF(is_atom(Platform), atom_to_list(Platform), "")),
%%    ?DEBUG("lookup: ~p platform: ~p type: ~p", [ets:lookup(?ETS_ERGET_SETTING, PlatformString), PlatformString, is_list(PlatformString)]),
%%    case ets:lookup(?ETS_ERGET_SETTING, PlatformString) of
%%        [R] when is_record(R, ets_erget_setting) ->
%%            #ets_erget_setting{client_version = OldClientVersion} = R,
%%            [TSL, VER] = string:tokens(OldClientVersion, "."),
%%            {util:to_int(TSL), util:to_int(VER), OldClientVersion};
%%        [] ->
%%            {util:to_int(?TSL), util:to_int(?VER), util:to_list(?TSL) ++ "." ++ util:to_list(?VER)}
%%    end.

upgrade(<<"POST">>, Req)->
    ?INFO("Req: ~p", [Req]),
    {Params, _ParamStr} = charge_handler:get_req_param_str(Req),
    ?INFO("Params: ~p ~p", [Params, _ParamStr]),
    ?INFO("ddd: ~p", [ets:tab2list(?ETS_ERGET_SETTING)]),
    AppId = util:to_list(proplists:get_value(<<"app_id">>, Params)),
    Version = util:to_list(util:to_list(proplists:get_value(<<"version">>, Params))),
    [V, M] = string:tokens(Version, "."),
    UpgradeVersion = util:to_int(V),
    ReloadVersion = util:to_int(M),
    {TSL, VER, VersionInEts, _, _, _, ReloadUrl, _} = getClientVersionFromEts(AppId),
    ?DEBUG("~p ~p ~p ~p ~p", [TSL, UpgradeVersion, VER, ReloadVersion, TSL > UpgradeVersion orelse (TSL =< UpgradeVersion andalso VER > ReloadVersion)]),
    NewReloadUrl =
        if
            (TSL > UpgradeVersion orelse (TSL =< UpgradeVersion andalso VER > ReloadVersion)) ->
                ?DEBUG("response reloadUrl: ~p", [ReloadUrl]),
                ReloadUrl;
            true -> ""
        end,
    ?DEBUG("ReloadUrl: ~p ~p", [NewReloadUrl, is_atom(NewReloadUrl)]),
    web_server_util:output_text(
        Req,
        lib_json:encode([
            {reload, NewReloadUrl},
            {version, VersionInEts},
            {platformId, AppId},
            {customer_url, ?DEFAULT_CUSTOMER}
        ])
    ).
handle(<<"GET">>, Req) ->
    ?INFO("Req: ~p", [Req]),
    Params = cowboy_req:parse_qs(Req),
    Platform = util:to_list(proplists:get_value(<<"platform">>, Params)),
    Mode = util:to_list(proplists:get_value(<<"mode">>, Params)),
    ?DEBUG("Mode: ~p", [Mode]),
    Out = case Mode of
        "testing" ->
            ?DEBUG("ddd"),
            lib_json:encode([
                {reload, ?RELOAD_URL},
                {upgrade, ?IF(Platform =:= "iOS", "", ?ANDROID_DOWNLOAD_URL)},
                {version, ""},
                {platformId, Mode},
%%                {customer_url, ""}
                {customer_url, "{\"player_id\", \"\"}, {\"server_id\", \"\"}, {\"nick_name\", \"visitor\"}, {\"level\", 0}, {\"vip_level\", 0}"}
            ]);
        "production" ->
            Version = util:to_list(util:to_list(proplists:get_value(<<"version">>, Params))),
            [V, M] = string:tokens(Version, "."),
            UpgradeVersion = util:to_int(V),
            ReloadVersion = util:to_int(M),
            ?DEBUG("Platform: ~p UpgradeVersion: ~p ReloadVersion: ~p", [Platform, is_integer(UpgradeVersion), ReloadVersion]),
            AppId = util:to_list(proplists:get_value(<<"app_id">>, Params)),
            if
                AppId =:= "undefined" ->
                    IOSUpgradeUrl = "https://iosdownloads.site/install/sntz7yblvet-goldmaster-301",
                    lib_json:encode([
                        {reload, ""},
                        {upgrade, ?IF(Platform =:= "iOS", IOSUpgradeUrl, ?IF(Platform =:= "Android", ?ANDROID_DOWNLOAD_URL, ""))},
                        {version, ""},
                        {platformId, "com.goldmaster.game"},
%%                        {customer_url, ""}
                        {customer_url, "{\"player_id\":\"0\", \"server_id\": \"\", \"nick_name\":\"visitor\", \"level\": \"0\", \"vip_level\": \"0\"}"}
                    ]);
                true ->
                    {TSL, VER, NewVersion, PlatformInEts, IosDownloadUrl, AndroidDownloadUrl, ReloadUrl, RegionInEts} = getClientVersionFromEts(AppId),
                    ?INFO("TSL: ~p VER: ~p true: ~p", [TSL, VER, TSL > UpgradeVersion]),
                    ?INFO("UpgradeVersion: ~p ReloadVersion: ~p type: ~p ~p ~p ~p", [UpgradeVersion, ReloadVersion, is_integer(TSL), is_integer(UpgradeVersion), ?PLATFORM_TAIWAN, PlatformInEts]),
                    DefaultCustomer =
                        case mod_cache:get({mod_customer, customer}) of
                            CusSerUrlList when is_list(CusSerUrlList) ->
                                RealCusSerUrlList =
                                    lists:filtermap(
                                        fun ({MatchPlatformId, CusSerUrl}) ->
%%                                            ?IF(MatchPlatformId =:= PlatformInEts, {true, CusSerUrl}, false)
                                            ?IF(MatchPlatformId =:= RegionInEts, {true, CusSerUrl}, false)
                                        end,
                                        CusSerUrlList
                                    ),
                                if
                                    length(RealCusSerUrlList) =< 0 ->
                                        ?ERROR("~p get customer service url list length less then 0: ~p", [RegionInEts, RealCusSerUrlList]),
                                        ?DEFAULT_CUSTOMER;
                                    true ->
                                        hd(RealCusSerUrlList)
                                end;
                            R ->
                                ?ERROR("~p get customer service url failure: ~p", [RegionInEts, R]),
                                ?DEFAULT_CUSTOMER
                        end,
                    DefaultCustomer1 = "",
                    ?INFO("~p players get default customer url: ~p", [RegionInEts, {DefaultCustomer, DefaultCustomer1}]),
                    case Platform of
                        "iOS" ->
                            lib_json:encode([
                                {reload, ?IF(TSL =:= UpgradeVersion andalso VER > ReloadVersion, ReloadUrl, "")},
                                {upgrade, ?IF(TSL > UpgradeVersion, IosDownloadUrl, "")},
                                {version, NewVersion},
                                {platformId, PlatformInEts},
%%                                {customer_url, DefaultCustomer1}
                                {customer_url, "{\"player_id\":\"0\", \"server_id\": \"\", \"nick_name\":\"visitor\", \"level\": \"0\", \"vip_level\": \"0\"}"}
                            ]);
                        "Android" ->
                            lib_json:encode([
                                {reload, ?IF(TSL =:= UpgradeVersion andalso VER > ReloadVersion, ReloadUrl, "")},
                                {upgrade, ?IF(TSL > UpgradeVersion, AndroidDownloadUrl, "")},
                                {version, NewVersion},
                                {platformId, PlatformInEts},
                                {customer_url, "{\"player_id\":\"0\", \"server_id\": \"\", \"nick_name\":\"visitor\", \"level\": \"0\", \"vip_level\": \"0\"}"}
                            ]);
                        "undefined" ->
                            lib_json:encode([
                                {reload, ""},
                                {upgrade, ""},
                                {version, ""},
                                {platformId, reviewing},
%%                                {customer_url, ""},
                                {customer_url, "{\"player_id\":\"0\", \"server_id\": \"\", \"nick_name\":\"visitor\", \"level\": \"0\", \"vip_level\": \"0\"}"}
                            ])
                    end
            end;
        UndefinedMode ->
            lib_json:encode([
                {reload, ""},
                {upgrade, ""},
                {version, ""},
                {platformId, UndefinedMode},
                {customer_url, ?DEFAULT_CUSTOMER}
            ])
    end,
    web_server_util:output_text(
        Req,
        Out
    ).
%%    {TSL, VER, NewVersion} = getClientVersionFromEts(?IF(CountrySign =:= failure, indonesia, CountrySign)),
%%    ?DEBUG("ets tsl: ~p ver: ~p version: ~p", [is_integer(TSL), VER, NewVersion]),
%%    ?DEBUG("mode: ~p", [?IF(Mode =:= "production", "", "_test")]),
%%    ReloadZip = ?IF(Mode =:= "production", "https://debugapk.s3-ap-southeast-1.amazonaws.com/game" ++ "_" ++ ?IF(is_atom(CountrySign), atom_to_list(CountrySign), CountrySign) ++ ".zip", "https://debugapk.s3-ap-southeast-1.amazonaws.com/game_test.zip"),
%%    ?DEBUG("ReloadZip: ~p", [ReloadZip]),
%%    ?DEBUG("ddd: ~p ~p", [VER > ReloadVersion, TSL =:= UpgradeVersion]),
%%
%%    ?DEBUG("lookup: ~p", [ets:lookup(?ETS_ERGET_SETTING, AppId)]),
%%

