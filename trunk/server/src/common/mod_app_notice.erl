%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 10月 2021 下午 12:35:48
%%%-------------------------------------------------------------------
-module(mod_app_notice).
-author("Administrator").

-include("common.hrl").

-define(APP_NOTICE_URL, ?IF(?IS_DEBUG, "http://127.0.0.1:7399/api/get_app_info_list", "http://127.0.0.1:7199/api/get_app_info_list")).
-define(DEFAULT_APP_NAME(Env),
    case Env of
        "develop" -> "com.tb.custom.test";
        "testing" -> "com.arsham.t3";
        "testing_oversea" -> "com.arsham.t3";
        _ -> "com.arsham.t3"
    end
).

%% API
-export([
    update_app_notice/5,
    delete_app_notice/3,
    get_app_notice/3,
    get_all_app_notice/3,
    get_app_notice/0
]).

get_app_notice() ->
    ?INFO("get app notice from admin: ~p", [?APP_NOTICE_URL]),
    ReqData = [{"offset", 0}, {"limit", 999999999}],
    case util_http:post(?APP_NOTICE_URL, json, ReqData) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            ?DEBUG("Code: ~p", [{Code, Msg}]),
            ?DEBUG("Data: ~p", [{is_list(Data), Data}]),
            Data2Ets =
                lists:filtermap(
                    fun(KeyValueMap) ->
                        Status = util:to_int(maps:get(<<"status">>, KeyValueMap)),
                        if
                            Status =:= 1 ->
                                AppId = util:to_list(maps:get(<<"app_name">>, KeyValueMap)),
                                Version = util:to_list(maps:get(<<"version">>, KeyValueMap)),
%%                                [V, _] = string:tokens(Version, "."),
                                Status = util:to_int(maps:get(<<"status">>, KeyValueMap)),
                                Type = util:to_list(maps:get(<<"type">>, KeyValueMap)),
                                Notice = util:to_list(maps:get(<<"notice">>, KeyValueMap)),
                                Repeated = util:to_int(maps:get(<<"repeated">>, KeyValueMap)),
                                UpdatedAt = util:to_int(maps:get(<<"updated_at">>, KeyValueMap)),
                                ?DEBUG("fff: ~p", [?IF(Repeated =:= 1, 1, 0)]),
%%                                {true, #ets_app_notice{row_key = {AppId, Type, V},
                                {
                                    true,
                                    #ets_app_notice{
                                        row_key = {AppId, Type, Version},
                                        version = Version,
                                        repeated = ?IF(Repeated =:= 1, 1, 0),
                                        notice = Notice,
                                        updated_at = UpdatedAt
                                    }
                                };
                            true -> false
                        end
                    end,
                    Data
                ),
            ?IF(Data2Ets =/= [], ets:insert_new(?ETS_APP_NOTICE, Data2Ets), ok);
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [?APP_NOTICE_URL, Reason]),
            false
    end.
get_app_notice(AppId, "undefined", Version) ->
    get_app_notice(AppId, "0", Version);
get_app_notice(AppId1, Type, Version) ->
    Env = env:get(env, "production"),
    AppId = ?IF(AppId1 =:= "-1", ?DEFAULT_APP_NAME(Env), AppId1),
    ?DEBUG("AppId app notice: ~p", [AppId]),
%%    [V, _] = string:tokens(Version, "."),
%%    RowKey = {AppId, Type, V},
    RowKey = {AppId, Type, Version},
    case ets:lookup(?ETS_APP_NOTICE, RowKey) of
        [AppNoticeInEts] when is_record(AppNoticeInEts, ets_app_notice) ->
            [
                {type, Type},
                {version, AppNoticeInEts#ets_app_notice.version},
                {notice, AppNoticeInEts#ets_app_notice.notice},
                {updated_at, AppNoticeInEts#ets_app_notice.updated_at},
                {repeated, AppNoticeInEts#ets_app_notice.repeated}
            ];
        [] ->
            get_all_app_notice(AppId, Type, Version)
    end.
get_all_app_notice(AppId1, Type, Version) ->
%%    [V, _] = string:tokens(Version, "."),
    Env = env:get(env, "production"),
    AppId = ?IF(AppId1 =:= "-1", ?DEFAULT_APP_NAME(Env), AppId1),
    Notice =
        case ets:tab2list(?ETS_APP_NOTICE) of
            AppNoticesInEts ->
                lists:filtermap(
                    fun(Ele) ->
                        {AppIdInEts, TypeInEts, VInEts} = Ele#ets_app_notice.row_key,
                        if
%%                            AppId =:= AppIdInEts andalso TypeInEts =:= Type andalso VInEts >= V->Version
                            AppId =:= AppIdInEts andalso TypeInEts =:= Type andalso VInEts >= Version ->
                                {true, {Ele#ets_app_notice.notice, Ele#ets_app_notice.repeated, Ele#ets_app_notice.updated_at}};
                            true -> false
                        end
                    end,
                    util_list:rkeysort(#ets_app_notice.version, AppNoticesInEts)
                )
%%            _ -> failure
        end,
    ?DEBUG("Notice: ~p", [Notice]),
    {RealNotice, Repeated, UpdatedBy} =
        case length(Notice) of
            Gt1 when Gt1 > 1 -> lists:last(Notice);
            1 -> Notice;
            _ -> {"", 0, 0}
        end,
%%    {RealNotice, Repeated, UpdatedBy} = ?IF(length(Notice) > 1, lists:last(Notice), Notice),
    [
        {type, Type},
        {version, Version},
        {notice, RealNotice},
        {updated_at, UpdatedBy},
        {repeated, Repeated}
    ].

delete_app_notice(AppId, Type, Version) ->
%%    [V, _] = string:tokens(Version, "."),
%%    RowKey = {AppId, Type, V},
    RowKey = {AppId, Type, Version},
    ets:delete(?ETS_APP_NOTICE, RowKey).

update_app_notice(AppId, Version, Type, Notice, Repeated) ->
%%    [V, _] = string:tokens(Version, "."),
    RowKey = {AppId, Type, Version},
    AppNotice =
        case ets:lookup(?ETS_APP_NOTICE, RowKey) of
            [AppNoticeInEts] when is_record(AppNoticeInEts, ets_app_notice) ->
                #ets_app_notice{notice = OldNotice, version = OldVersion, repeated = OldRepeated} = AppNoticeInEts,
                NewAppNotice = ?IF(OldNotice =:= Notice, AppNoticeInEts, AppNoticeInEts#ets_app_notice{notice = Notice}),
                NewAppNotice1 = ?IF(OldVersion =:= Version, NewAppNotice, NewAppNotice#ets_app_notice{version = Version}),
                NewAppNotice2 = ?IF(OldRepeated =:= Repeated, NewAppNotice1,
                    NewAppNotice1#ets_app_notice{repeated = ?IF(Repeated =:= 1, Repeated, 0)}),
                NewAppNotice3 = NewAppNotice2#ets_app_notice{updated_at = util_time:timestamp()},
                ets:delete(?ETS_APP_NOTICE, RowKey),
                NewAppNotice3;
            [] ->
                #ets_app_notice{row_key = RowKey, version = Version, notice = Notice,
                    repeated = Repeated, updated_at = util_time:timestamp()}
        end,
    ets:insert_new(?ETS_APP_NOTICE, AppNotice).




