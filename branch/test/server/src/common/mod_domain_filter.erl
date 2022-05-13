%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. 11月 2021 上午 11:45:44
%%%-------------------------------------------------------------------
-module(mod_domain_filter).
-author("Administrator").

-include("common.hrl").

-define(APP_NOTICE_URL, ?IF(?IS_DEBUG, "http://127.0.0.1:7399/api/get_app_info_list", "http://127.0.0.1:7199/api/get_app_info_list")).
-define(DEFAULT_DOMAIN(Env),
    case Env of
        "develop" -> {"http://192.168.31.100:6663", "http://192.168.31.100:6666"};
        "testing" -> {"http://47.102.119.76：6663", "http://192.168.31.100:6666"};
        "testing_oversea" -> {"http://8.210.191.53：6663", "http://192.168.31.100:6666"};
        _ -> {"https://www.daggerofbonuses.com", "http://8.210.191.53:6666"}
    end
).

-export([
    update_domain_in_ets/3,
    get_domain/2
]).

%% ----------------------------------
%% @doc 	通过appId获取ets中的正式服域名和审核服域名
%% @end
%% ----------------------------------
get_domain(AppId, VersionList) ->
    Version = util:to_int(VersionList),
    {Domain, ReviewingDomain} =
        case ets:lookup(?ETS_DOMAIN, AppId) of
            [DomainInEts] when is_record(DomainInEts, ets_domain) ->
                {DomainInEts#ets_domain.domain, DomainInEts#ets_domain.test_domain};
            _ ->
                Env = env:get(env, "production"),
                ?DEFAULT_DOMAIN(Env)
        end,
    case ets:lookup(?ETS_ERGET_SETTING, AppId) of
        [O] when is_record(O, ets_erget_setting) ->
            #ets_erget_setting{
                status = Status, client_version = VersionInEts
            } = O,
            [V, _] = string:tokens(VersionInEts, "."),
            UpgradeVersion = util:to_int(V),
            ?DEBUG("fff: ~p", [{UpgradeVersion, Version, UpgradeVersion > Version, Status, Status =:= 1}]),
            ?IF(Status =:= 1 andalso Version > UpgradeVersion, ReviewingDomain, Domain);
        _ ->
            Domain
    end.

%% ----------------------------------
%% @doc 	更新app信息到ets中，domain和test_domain
%% @end
%% ----------------------------------
update_domain_in_ets(AppId, Domain, TestDomain) ->
    ?DEBUG("update_domain_in_ets: ~p", [{is_list(AppId), is_list(Domain), is_list(TestDomain)}]),
    %% 更新指定app_id的reviewing_versions数据到ets中
    Domain2Ets =
        case ets:lookup(?ETS_DOMAIN, AppId) of
            [O] when is_record(O, ets_domain) ->
                #ets_domain{domain = OldDomain, test_domain = OldTestDomain} = O,
                O1 = ?IF(OldDomain =:= Domain,
                    O#ets_domain{domain = OldDomain},
                    O#ets_domain{domain = Domain}),
                O2 = ?IF(OldTestDomain =:= TestDomain,
                    O1#ets_domain{test_domain = OldTestDomain},
                    O1#ets_domain{test_domain = TestDomain}),
                ets:delete(?ETS_DOMAIN, AppId),
                O2;
            _ ->
                #ets_domain{app_id = AppId, domain = Domain, test_domain = TestDomain}
        end,
    ?DEBUG("Domain2Ets: ~p", [Domain2Ets]),
    Res = ets:insert_new(?ETS_DOMAIN, Domain2Ets),
    ?DEBUG("UpdateDomain: ~p", [Res]),
    ok.
