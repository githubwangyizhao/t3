%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                登录验证
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_login).

-export([init/2]).

-include("system.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-define(NO_ROLE, 0).
-define(HAS_ROLE, 1).

-define(GAME_CHARGE_TYPE_1, 1).     % 第一套充值方案(游戏内直充)
-define(GAME_CHARGE_TYPE_2, 2).     % 第二套充值方案(通过客服功能进入充值)

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                ?ERROR("获取区服列表失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

create_role(PlatformId, CreateRoleSid, AccId, Channel) ->
    case catch mod_server_rpc:call_game_server(PlatformId, CreateRoleSid, mod_player, auto_create_role, [CreateRoleSid, AccId, Channel]) of
        {'EXIT', Err} -> ?ERROR("auto_create_role: ~p", [Err]), noop;
        AutoCreateRoleRes -> ?INFO("auto_create_role: ~p", [AutoCreateRoleRes]), noop
    end.

handle(<<"GET">>, Req) ->
    ?DEBUG("env: ~p", [env:get(env, "develop")]),
    ?DEBUG("请求登录服:~p", [cowboy_req:uri(Req)]),
    Params = cowboy_req:parse_qs(Req),
    ?INFO("请求登录服时的参数:~p~n", [Params]),
    AppIdInQuery = util:to_list(proplists:get_value(<<"app_id">>, Params)),
    PlatformIdInQuery = util:to_list(proplists:get_value(<<"platform_id">>, Params)),
    ChannelInQuery = util:to_list(proplists:get_value(<<"channel">>, Params)),
    RegionInQuery = util:to_list(proplists:get_value(<<"region">>, Params)),
%%    Region = util:to_list(proplists:get_value(<<"region">>, Params)),
    {PlatformIdInEts, ChannelInEts, RegionInEts} =
        case catch mod_server_rpc:call_center(ets, lookup, [?ETS_ERGET_SETTING, AppIdInQuery]) of
            [EgretSetting] when is_record(EgretSetting, ets_erget_setting) ->
                {
                    EgretSetting#ets_erget_setting.platform,
                    EgretSetting#ets_erget_setting.channel,
                    EgretSetting#ets_erget_setting.region
                };
            O -> ?ERROR("读取中心服erget_setting失败: ~p", [{AppIdInQuery, O}]),
                {?FALSE, ?FALSE, ?FALSE}
        end,
    {PlatformId, Channel, Region} =
        if
            PlatformIdInEts =:= ?FALSE andalso ChannelInEts =:= ?FALSE andalso RegionInEts =:= ?FALSE ->
%%                PlatformIdInQuery = util:to_list(proplists:get_value(<<"platform_id">>, Params)),
                ?ASSERT(PlatformIdInQuery =/= "undefined", platform_undefined),
                ?ASSERT(PlatformIdInQuery =/= "", platform_undefined),
%%                ChannelInQuery = util:to_list(proplists:get_value(<<"channel">>, Params)),
%%                RegionInQuery = util:to_list(proplists:get_value(<<"region">>, Params)),
                {
                    PlatformIdInQuery,
                    ?IF(ChannelInQuery =:= "undefined", "local_test", ChannelInQuery),
                    ?IF(RegionInQuery =:= "undefined", "TWD", RegionInQuery)
                };
            true ->
                if
                    PlatformIdInEts =/= PlatformIdInQuery orelse ChannelInEts =/= ChannelInQuery ->
                        case catch mod_server_rpc:call_center(ets, select, [
                            ?ETS_TRACKER_TOKEN, [{
                                #ets_tracker_token{platform_id = PlatformIdInQuery, channel = ChannelInQuery, _ = '_'}, [], ['$_']
                            }]
                        ]) of
                            {error, Reason} ->
                                ?ERROR("读取ets_tracker_token failure: ~p", Reason),
                                {PlatformIdInEts, ChannelInEts, RegionInEts};
                            DataInTrackerToken ->
                                ?INFO("DataInTrackerToken: ~p", [DataInTrackerToken]),
                                {PlatformIdInQuery, ChannelInQuery, RegionInEts}
                        end;
                    true ->
                        {PlatformIdInEts, ChannelInEts, RegionInEts}
                end
        end,
    ?INFO("Channel: ~p", [Channel]),
    %% 内网, 测试
    AccId = util:to_list(proplists:get_value(<<"acc_id">>, Params)),
    _Password = util:to_list(proplists:get_value(<<"password">>, Params)),
    Promote = util:to_list(proplists:get_value(<<"promote">>, Params)),
    RegistrationId = util:to_list(proplists:get_value(<<"registration_id">>, Params)),
    OSPlatform = util:to_list(proplists:get_value(<<"OSPlatform">>, Params)),
    ?INFO("Region: ~p", [{Region, RegistrationId, OSPlatform}]),
%%    ets:insert(?ETS_LOGIN_CACHE, #ets_login_cache{account = AccId, promote = Promote}),
    Result = pack_common_result(PlatformId, AccId),

%%    ?DEBUG("it's ok?(~p)", [mod_global_account:get_facebook_app_id_from_center_node(FbAppIdFromClient, PlatformId)]),
    %% 通过包名，判断中心服ets中的ets_erget_setting中的state是否为0，
    %% 若为0表示这是一个审核包，进入审核服
    %% 返回的最近服务器列表为审核服，反之则返回正常情况下的游戏服
    IsReviewing =
        case mod_global_account:is_reviewing(AppIdInQuery) of
            [] -> ?FALSE;
            R -> R
        end,
    GlobalAccount = global_account_srv:get_global_account(PlatformId, AccId),
    #db_global_account{
        recent_server_list = RecentServerIdList
    } = GlobalAccount,
    ?INFO("GlobalAccount: ~p ~p", [GlobalAccount, RecentServerIdList]),
    {Result1, RealAccId} =
        case login_server:pack_server_list(PlatformId, mod_global_account:tran_recent_server_list(RecentServerIdList)) of
            [] ->
                %% 该acc_id不存在于global_account，此时根据facebook_app_id中的数据对数据库再次进行查找
                FbAppIdFromClient = util:to_list(proplists:get_value(<<"facebook_apps_id">>, Params)),
                {Result3, RealAccId2} =
                    case mod_server_rpc:call_center(mod_global_account, get_facebook_app_id_from_center_node, [FbAppIdFromClient, PlatformId]) of
                        noop ->
                            ?INFO("new player, FbAppIdFromClient has not found in Db"),
                            {Result, AccId};
                        failure ->
                            ?INFO("facebook app id from client is none"),
                            {Result, AccId};
                        RealAccIdFromCenter ->
                            ?INFO("RealAccId: ~p AccId: ~p", [RealAccIdFromCenter, AccId]),
                            {pack_common_result(PlatformId, RealAccIdFromCenter), RealAccIdFromCenter}
                    end,
                ?DEBUG("it's ok?(~p)", [Result3]),
                {lists:keyreplace(recent, 1, Result3, {recent, login_server:pack_server_list(PlatformId, ["s1"])}), RealAccId2};
            _ ->
                ?INFO("GlobalAccount: ~p ~p", [GlobalAccount, RecentServerIdList]),
                {Result, AccId}
        end,
    ?INFO("result1: ~p RealAccId: ~p", [Result1, RealAccId]),
    %% 进入正常服的玩家将修改其在global_account表的app_id字段
    ets:insert(?ETS_LOGIN_CACHE, #ets_login_cache{account = RealAccId, promote = Promote,
        app_id = AppIdInQuery, region = ?IF(Region =:= "undefined", "TWD", Region),
        registration_id = ?IF(RegistrationId =:= "undefined", "", RegistrationId), os_platform = OSPlatform}),

    %% 修改global_account表的app_id
%%    case mod_server_rpc:call_center(mod_global_account, update_app_id, [PlatformId, AccId, AppIdFromClient]) of
    case mod_server_rpc:call_center(mod_global_account, update_app_id, [PlatformId, RealAccId, AppIdInQuery]) of
        failure ->
            ?ERROR("Update app_id failure");
        ok ->
            ?INFO("Update app_id success")
    end,
%%    mod_global_account:update_app_id(PlatformId, AccId, AppIdFromClient),
%%            {IsOpen, AppId, Path, ExtraData, EnvVersion} = weixin:get_navigate_args(),
    {IsOpen, AppId, Path, ExtraData, EnvVersion} = {false, "", "", "", ""},
    VerFromClient = util:to_list(proplists:get_value(<<"version">>, Params)),

    Time = util_time:timestamp(),
    LoginTicket = login_server:create_login_ticket(RealAccId, Time),

    Result2 = [
        {time, Time},
        {login_ticket, util:to_binary(LoginTicket)},
        {openJump, IsOpen},
        {appId, util:to_binary(AppId)},
        {path, util:to_binary(Path)},
        {extraData, util:to_binary(ExtraData)},
        {envVersion, util:to_binary(EnvVersion)},
%%                {isChargeOpen, ?TRUE}
        {isReviewing, ?IF(IsReviewing =:= reviewing, 1, 0)},
        {isNativePay, ?IF(mod_global_account:is_native_pay(PlatformId, AppIdInQuery, RealAccId, VerFromClient) =:= true, ?TRUE, ?FALSE)},
%%        {isChargeOpen, ?IF(mod_global_account:is_can_charge(PlatformId, AppIdInQuery, RealAccId, VerFromClient) =:= true, ?TRUE, ?FALSE)}
        {isChargeOpen, ?TRUE}
        | Result1
    ],
    NewResult = Result2, %%lists:keyreplace(has_role, 1, Result2, {has_role, ?HAS_ROLE}),
    ?DEBUG("NewResult: ~p", [NewResult]),
    ?DEBUG("请求登录结果:~p~n~n~n", [{NewResult}]),
    %% 自动创角
    {has_role, HasRole} = lists:keyfind(has_role, 1, NewResult),
    ?DEBUG("HasRole: ~p", [HasRole]),
    Env = env:get(env, "production"),
    ReviewingSid = ?REVIEWING_SERVER(Env),
    %% 通过客户端版本对比，判断当前玩家是否进入审核服
    [V, _] = string:tokens(VerFromClient, "."),
    VersionInEts = mod_global_account:get_app_version(AppIdInQuery),
    {recent, RecentServerList} = lists:keyfind(recent, 1, NewResult),
    {ReviewingSidCreateRole, LatestSidCreateRole, FilterReviewingSid} =
        if
            ?IS_DEBUG ->
                {?FALSE, ?FALSE, ?FALSE};
            %% 当前玩家使用高版本客户端进入游戏（客户端版本大于后端保存的客户端版本），且没有创角
            V > VersionInEts andalso HasRole =:= 0 ->
                ?INFO("为玩家在审核的服务器创角~p: ", [{AccId, V, VersionInEts}]),
                {?TRUE, ?FALSE, ?FALSE};
            %% 当前玩家使用高版本客户端进入游戏（客户端版本大于后端保存的客户端版本），且有创角
            V > VersionInEts andalso HasRole =:= 1 ->
                ?INFO("为玩家从最近服务器列表中剔除掉审核服: ~p", [{AccId, V, VersionInEts}]),
                {?FALSE, ?FALSE, ?TRUE};
            %% 当前玩家使用低版本客户端进入游戏（客户端版本雄安与等于后端保存的客户端版本），且没有创角
            V =< VersionInEts andalso HasRole =:= 0 ->
                ?INFO("为玩家在最新的服务器创角: ~p", [{AccId, V, VersionInEts}]),
                {?FALSE, ?TRUE, ?FALSE};
            %% 当前玩家使用低版本客户端进入游戏（客户端版本小于等于后端保存的客户端版本），且有创角
            true ->
                ?INFO("玩家使用低版本客户端进入正式服: ~p", [{AccId, V, VersionInEts}]),
                {?FALSE, ?FALSE, ?FALSE}
        end,
    ResultAfReviewSidCreRole =
        if
            %% 进入审核服创角，并返回只有一个审核服的最近服务器列表
            ReviewingSidCreateRole =:= ?TRUE ->
                create_role(PlatformId, ReviewingSid, RealAccId, Channel),
                lists:keystore(recent, 1, NewResult, {recent, login_server:pack_server_list(PlatformId, [ReviewingSid])});
            true -> NewResult
        end,
    ResultLatestSidCreRole =
        if
            %% 到最新服务器创角，从全部服务器列表中排除掉审核服，并创角
            LatestSidCreateRole =:= ?TRUE ->
                CreateRoleSid = mod_server:get_game_server_list_without_reviewing(PlatformId, ?TRUE),
                create_role(PlatformId, CreateRoleSid, RealAccId, Channel),
                lists:keystore(recent, 1, ResultAfReviewSidCreRole, {recent, login_server:pack_server_list(PlatformId, [CreateRoleSid])});
            true -> ResultAfReviewSidCreRole
        end,
    NewResult1 =
        if
            %% 过滤最近登录服务器列表，从当前登录玩家的最近服务器列表中，去除掉审核服
            FilterReviewingSid =:= ?TRUE ->
                FilterNewResult =
                    lists:filtermap(
                        fun(Server) ->
                            {id, SidFromRecentServerList} = lists:keyfind(id, 1, Server),
                            FilterSidFromServerList = ?IF(is_binary(SidFromRecentServerList), util:to_list(SidFromRecentServerList), SidFromRecentServerList),
                            ?INFO("FilterSidFromServerList: ~p", [{FilterSidFromServerList, SidFromRecentServerList, ReviewingSid}]),
                            if
                                FilterSidFromServerList =:= ReviewingSid -> false;
                                true -> {true, Server}
                            end
                        end,
                        RecentServerList
                    ),
                if
                    %% 当前登录玩家只在审核服创过角，到最新服务器自动创角并返回
                    FilterNewResult =:= [] ->
                        ?INFO("玩家只在审核服创过角，因此只返回审核服: ~p", [{AccId, V, VersionInEts}]),
                        lists:keystore(recent, 1, ResultLatestSidCreRole, {recent, RecentServerList});
%%                        CreateRoleSid1 = mod_server:get_game_server_list_without_reviewing(PlatformId, ?TRUE),
%%                        create_role(PlatformId, CreateRoleSid1, RealAccId, Channel),
%%                        lists:keystore(recent, 1, ResultLatestSidCreRole, {recent, login_server:pack_server_list(PlatformId, [CreateRoleSid1])});
                    %% 将排除掉审核服后的最近登陆服务器列表返回回去
                    true ->
                        ?INFO("从玩家最近服务器列表中，剔除掉审核服: ~p", [{AccId, V, VersionInEts}]),
                        lists:keystore(recent, 1, ResultLatestSidCreRole, {recent, FilterNewResult})
                end;
            true -> ResultLatestSidCreRole
        end,
    ?DEBUG("请求登录结果:~p~n~n~n", [{NewResult1}]),
    NewResult2 = NewResult1,
%%    NewResult2 = lists:keystore(has_role, 1, NewResult1, {has_role, 1}),
    ?INFO("请求登录结果:~p~n~n~n", [{NewResult2}]),
    web_server_util:output_text(
        Req,
        jsone:encode(NewResult2)
    );
handle(_, Req) ->
%% Method not allowed.
    cowboy_req:reply(405, Req).

is_open_debug(AccId) ->
    EnableDebugAccIdList0 = env:get(enableDebugAccIdList, []),
    EnableDebugAccIdList =
        if is_list(EnableDebugAccIdList0) ->
            EnableDebugAccIdList0;
            true ->
                ?WARNING("enableDebugAccIdList not list:~p", [EnableDebugAccIdList0]),
                []
        end,
    IsEnableDebug = case lists:member(AccId, EnableDebugAccIdList) of
                        true ->
                            1;
                        false ->
                            0
                    end,
    IsEnableDebug.


%% ----------------------------------
%% @doc 	打包通用返回
%% @throws 	none
%% @end
%% ----------------------------------
pack_common_result(PlatformId, AccId) ->
    pack_common_result(PlatformId, AccId, AccId).
pack_common_result(PlatformId, AccId, OpenId) ->
    pack_common_result(PlatformId, AccId, OpenId, "").
pack_common_result(PlatformId, AccId, OpenId, Channel) ->
    GlobalAccount = global_account_srv:get_global_account(PlatformId, AccId),
    #db_global_account{
        recent_server_list = RecentServerIdList,
        type = Type
    } = GlobalAccount,
    RecentServerList = login_server:pack_server_list(PlatformId, mod_global_account:tran_recent_server_list(RecentServerIdList)),
    {HasRole, RealRecentServerList} =
        if RecentServerList == [] ->
            ServerId = login_server:get_new_server_id(PlatformId),
            GameServer = mod_server:get_game_server(PlatformId, ServerId),
            #db_c_server_node{
                state = State,
                open_time = OpenTime
            } = mod_server:get_server_node(GameServer#db_c_game_server.node),
            CurrTime = util_time:timestamp(),
            IsHas = ?IF(State == ?SERVER_STATE_MAINTENANCE orelse OpenTime > CurrTime, ?HAS_ROLE, ?NO_ROLE),  % 最新的区服在维护时处理
%%            {?NO_ROLE, login_server:pack_server_list(PlatformId, [login_server:get_new_server_id(PlatformId)])};
            {IsHas, login_server:pack_server_list(PlatformId, [ServerId])};
            true ->
                {?HAS_ROLE, RecentServerList}
        end,
%%    IsInnerAccount = mod_global_account:is_inner_account(PlatformId, AccId),
%%    Notice = util:to_binary(mod_server_data:get_str_data(?SERVER_DATA_LOGIN_NOTICE)),

    Notice =
        case Channel of
%%            ?CHANNEL_XINGQIU ->
%%                <<228, 184, 139, 230, 158, 182, 229, 133, 172, 229, 145, 138, 239, 188, 154, 10, 228, 186, 178,
%%                    231, 136, 177, 231, 154, 132, 229, 144, 132, 228, 189, 141, 231, 142, 169, 229, 174, 182, 239,
%%                    188, 154, 10, 227, 128, 138, 231, 131, 173, 232, 161, 128, 228, 191, 174, 228, 187, 153, 227,
%%                    128, 139, 230, 137, 139, 230, 184, 184, 232, 135, 170, 230, 173, 163, 229, 188, 143, 229, 188,
%%                    128, 230, 156, 141, 228, 187, 165, 230, 157, 165, 239, 188, 140, 229, 190, 151, 229, 136, 176,
%%                    228, 186, 134, 229, 185, 191, 229, 164, 167, 231, 142, 169, 229, 174, 182, 231, 154, 132, 229,
%%                    164, 167, 229, 138, 155, 230, 148, 175, 230, 140, 129, 239, 188, 140, 230, 136, 145, 228, 187,
%%                    172, 231, 148, 177, 232, 161, 183, 230, 132, 159, 232, 176, 162, 229, 144, 132, 228, 189, 141,
%%                    231, 142, 169, 229, 174, 182, 231, 154, 132, 229, 142, 154, 231, 136, 177, 239, 188, 129, 231,
%%                    148, 177, 228, 186, 142, 229, 144, 132, 230, 150, 185, 233, 157, 162, 231, 154, 132, 229, 142,
%%                    159, 229, 155, 160, 239, 188, 140, 230, 136, 145, 228, 187, 172, 229, 141, 179, 229, 176, 134,
%%                    229, 129, 156, 230, 173, 162, 229, 175, 185, 227, 128, 138, 231, 131, 173, 232, 161, 128, 228,
%%                    191, 174, 228, 187, 153, 227, 128, 139, 231, 154, 132, 229, 144, 142, 230, 156, 159, 232, 191,
%%                    144, 232, 144, 165, 239, 188, 140, 229, 175, 185, 230, 173, 164, 231, 187, 153, 230, 130, 168,
%%                    233, 128, 160, 230, 136, 144, 231, 154, 132, 228, 184, 141, 228, 190, 191, 239, 188, 140, 230,
%%                    136, 145, 228, 187, 172, 232, 161, 168, 231, 164, 186, 230, 183, 177, 230, 183, 177, 231, 154,
%%                    132, 230, 173, 137, 230, 132, 143, 33, 10, 229, 133, 183, 228, 189, 147, 229, 129, 156, 230,
%%                    156, 141, 228, 191, 161, 230, 129, 175, 229, 174, 137, 230, 142, 146, 229, 166, 130, 228, 184,
%%                    139, 239, 188, 154, 10, 49, 227, 128, 129, 230, 184, 184, 230, 136, 143, 229, 176, 134, 228,
%%                    186, 142, 50, 48, 50, 48, 229, 185, 180, 54, 230, 156, 136, 49, 50, 230, 151, 165, 49, 56, 239,
%%                    188, 154, 48, 48, 229, 133, 179, 233, 151, 173, 230, 184, 184, 230, 136, 143, 229, 134, 133,
%%                    230, 137, 128, 230, 156, 137, 230, 179, 168, 229, 134, 140, 227, 128, 129, 231, 153, 187, 233,
%%                    153, 134, 227, 128, 129, 229, 133, 133, 229, 128, 188, 229, 133, 165, 229, 143, 163, 239, 188,
%%                    140, 229, 177, 138, 230, 151, 182, 231, 142, 169, 229, 174, 182, 229, 176, 134, 230, 151, 160,
%%                    230, 179, 149, 229, 156, 168, 230, 184, 184, 230, 136, 143, 232, 191, 155, 232, 161, 140, 231,
%%                    153, 187, 233, 153, 134, 231, 155, 184, 229, 133, 179, 230, 147, 141, 228, 189, 156, 239, 188,
%%                    155, 10, 50, 227, 128, 129, 230, 184, 184, 230, 136, 143, 229, 176, 134, 228, 186, 142, 50, 48,
%%                    50, 48, 229, 185, 180, 54, 230, 156, 136, 51, 48, 230, 151, 165, 49, 48, 239, 188, 154, 48, 48,
%%                    230, 173, 163, 229, 188, 143, 229, 133, 179, 233, 151, 173, 227, 128, 138, 231, 131, 173, 232,
%%                    161, 128, 228, 191, 174, 228, 187, 153, 227, 128, 139, 230, 156, 141, 229, 138, 161, 229, 153,
%%                    168, 239, 188, 155, 10, 51, 239, 188, 140, 230, 184, 184, 230, 136, 143, 229, 176, 134, 228,
%%                    186, 142, 50, 48, 50, 48, 229, 185, 180, 54, 230, 156, 136, 51, 48, 230, 151, 165, 49, 48, 239,
%%                    188, 154, 48, 48, 230, 173, 163, 229, 188, 143, 229, 133, 179, 233, 151, 173, 227, 128, 138,
%%                    231, 131, 173, 232, 161, 128, 228, 191, 174, 228, 187, 153, 227, 128, 139, 231, 154, 132, 229,
%%                    174, 162, 230, 136, 183, 230, 156, 141, 229, 138, 161, 239, 188, 140, 229, 144, 140, 230, 151,
%%                    182, 229, 133, 179, 233, 151, 173, 229, 174, 152, 231, 189, 145, 227, 128, 129, 232, 174, 186,
%%                    229, 157, 155, 231, 173, 137, 239, 188, 140, 229, 166, 130, 230, 156, 137, 233, 151, 174, 233,
%%                    162, 152, 232, 175, 183, 229, 156, 168, 232, 175, 165, 230, 151, 182, 233, 151, 180, 229, 137,
%%                    141, 229, 144, 145, 229, 174, 162, 230, 156, 141, 230, 143, 144, 229, 135, 186, 227, 128, 130,
%%                    10, 50, 48, 50, 48, 229, 185, 180, 54, 230, 156, 136, 49, 50, 230, 151, 165>>;
            _ -> util:to_binary(mod_login_notice:get_login_notice(PlatformId, Channel))
        end,

%%    IpWhiteState =
%%        case get(ip) of
%%            ?UNDEFINED ->
%%                false;
%%            Ip1 ->
%%                WhiteIpList = env:get(white_ip_list, []),
%%                case string:tokens(Ip1, ".") of
%%                    [IpA, IpB, Ipc, IpD] ->
%%                        lists:foldl(
%%                            fun(WhiteIp, WhiteState1) ->
%%                                if
%%                                    WhiteState1 == true ->
%%                                        WhiteState1;
%%                                    true ->
%%                                        [White1, White2, White3, White4] = string:tokens(WhiteIp, "."),
%%                                        if
%%                                            [IpA, IpB, Ipc] == [White1, White2, White3] andalso (White4 == "*" orelse White4 == IpD) ->
%%                                                true;
%%                                            true ->
%%                                                WhiteState1
%%                                        end
%%                                end
%%                            end, false, WhiteIpList);
%%                    Err ->
%%                        ?ERROR("white_ip_list Err: ~p", [Err]),
%%                        Ip1
%%                end
%%        end,
%%    IsInner =
%%        if
%%            IpWhiteState == true ->
%%                1;
%%            true ->
%%                ?IF(Type >= 1, 1, 0)
%%        end,

    IsShowInvited =
        case mod_server_rpc:call_center(promote_srv_mod, get_db_promote, [PlatformId, AccId]) of
            null ->
                1;
            DbPromote ->
                #db_promote{
                    invite_player_id = InvitePlayerId
                } = DbPromote,
                ?IF(InvitePlayerId > 0, 0, 1)
        end,

    [
        {recent, RealRecentServerList},
        {has_role, HasRole},
        {is_inner, 0},
        {notice, Notice},
        {acc_id, util:to_binary(OpenId)},
        {is_show_invited, IsShowInvited},
        {is_gm, ?IF(Type >= 2, 1, 0)}
    ].


%%pack_wx_result(PlatformId, AccId, Ip) ->
%%    pack_wx_result(PlatformId, "", AccId, Ip).
%%pack_wx_result(PlatformId, Channel, AccId, Ip) ->
%%    GlobalAccount = global_account_srv:get_global_account(PlatformId, AccId),
%%    #db_global_account{
%%        recent_server_list = RecentServerIdList,
%%        type = Type
%%    } = GlobalAccount,
%%    RecentServerList = login_server:pack_server_list(PlatformId, mod_global_account:tran_recent_server_list(RecentServerIdList)),
%%    {HasRole, RealRecentServerList} =
%%        if RecentServerList == [] ->
%%            {?NO_ROLE, login_server:pack_server_list(PlatformId, [login_server:get_new_server_id(PlatformId)])};
%%            true ->
%%                {?HAS_ROLE, RecentServerList}
%%        end,
%%%%    IsInnerAccount = mod_global_account:is_inner_account(PlatformId, AccId),
%%%%    Notice = util:to_binary(mod_server_data:get_str_data(?SERVER_DATA_LOGIN_NOTICE)),
%%    Notice = util:to_binary(mod_login_notice:get_login_notice(PlatformId, Channel)),
%%    IsCharge = weixin:is_charge(AccId),
%%    [
%%        {recent, RealRecentServerList},
%%        {has_role, HasRole},
%%        {is_inner, ?IF(Type >= 1, 1, 0)},
%%        {notice, Notice},
%%        {acc_id, util:to_binary(AccId)},
%%        {openIosCharge, weixin:get_ios_charge_flag(Ip, AccId, ?IF(RecentServerList == [], true, false))},
%%        {isWhitePlayer, ?TRAN_BOOL_2_INT(IsCharge)},
%%        {is_gm, ?IF(Type >= 2, 1, 0)}
%%    ].



get_remote_ip(Req) ->
    case cowboy_req:header(<<"remote-host">>, Req) of
        undefined ->
            ?WARNING("get_remote_ip!!!"),
            "127.0.0.1";
        Ip ->
            util:to_list(Ip)
    end.
