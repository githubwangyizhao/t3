%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 7月 2021 上午 10:33:48
%%%-------------------------------------------------------------------
-module(handle_static_resource).
-author("Administrator").

-include("system.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").

%% API
-export([init/2, getData/0]).

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

-define(STATIC_RESOURCE_URL, "http://127.0.0.1").
-define(STATIC_RESOURCE_PORT, ?IF(?IS_DEBUG =:= true, "7499", "7199")).
-define(STATIC_RESOURCE_PATH, "/tool/statistic_res_opt").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try
            case Method of
                <<"GET">> -> static_resource(Method, Req0);
                <<"POST">> -> handle(Method, Req0)
            end
        catch
            _:Reason ->
                ?ERROR("获取版本更新信息失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

getData() ->
    Url = ?STATIC_RESOURCE_URL ++ ?IF(?STATIC_RESOURCE_PORT =:= "", "", (":" ++ ?STATIC_RESOURCE_PORT)) ++ ?STATIC_RESOURCE_PATH,
    ?INFO("IS_DEBUG: ~p get static resource from admin: ~p", [?IS_DEBUG, Url]),
    ReqData = [{"offset", 0}, {"limit", 999999999}],
    case util_http:post(Url, json, ReqData) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            if
                Code =:= 0 ->
                    MatchData =
                        lists:filtermap(
                            fun({Key, Value}) -> ?IF(Key =:= <<"rows">>, {true, Value}, false) end,
                            maps:to_list(Data)
                        ),
                    Data2Ets =
                        lists:foldl(
                            fun(Ele, Tmp) ->
                                AppId = util:to_list(maps:get(<<"app_id">>, Ele)),
                                Version = util:to_int(maps:get(<<"version">>, Ele)),
                                [#ets_client_static_resource_record{
                                    row_key = {AppId, Version}, app_id = AppId, version = Version,
                                    download = util:to_list(maps:get(<<"url">>, Ele))
                                } | Tmp]
                            end,
                            [],
                            hd(MatchData)
                        ),
                    ets:insert(?ETS_CLIENT_STATIC_RESOURCE_RECORD, Data2Ets),
                    ok;
                true ->
                    ?ERROR("ErrorMsg: ~p", [Msg]), false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [Url, Reason]),
            false
    end.
handle(<<"POST">>, Req) ->
    ?INFO("Req: ~p", [Req]),
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?DEBUG("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?INFO("Params: ~p", [ParamInfoList]),
    AppId = util:to_list(proplists:get_value(<<"app_id">>, Params)),
    Url = util:to_list(proplists:get_value(<<"url">>, Params)),
    Version = util:to_int(proplists:get_value(<<"version">>, Params)),
%%    Account = util:to_list(proplists:get_value(<<"account">>, ParamInfoList)),
    ?DEBUG("Data from admin: ~p", [{AppId, Url, Version}]),
    Resp =
        case catch update_data_2_ets(AppId, Url) of
            {'EXIT', _} -> [{error_code, 400}, {error_msg, "failure"}];
            ok -> [{error_code, 0}, {error_msg, "success"}]
        end,
    web_http_util:output_json(Req, Resp).
static_resource(<<"GET">>, Req) ->
    ?INFO("Req: ~p", [Req]),
    {Params, _ParamStr} = charge_handler:get_req_param_str(Req),
    ?INFO("Params: ~p ~p", [Params, _ParamStr]),
    AppId = util:to_list(proplists:get_value(<<"app_id">>, Params)),
    Version = util:to_list(util:to_list(proplists:get_value(<<"version">>, Params))),
%%    [_, M, _] = string:tokens(Version, "."),
    StaticResourceVersion = util:to_int(Version),
    ?DEBUG("~p", [StaticResourceVersion]),
%%    LatestStaticResourceVersion = 3,
    DownloadUrlTupleList = get_data_from_ets(AppId, StaticResourceVersion),
    LatestStaticResourceVersion = ?IF([VersionInEts || {VersionInEts, _} <- DownloadUrlTupleList] =/= [],
        lists:max([VersionInEts || {VersionInEts, _} <- DownloadUrlTupleList]), util:to_int(Version)),
    DownloadUrlTupleList1 = lists:sort(DownloadUrlTupleList),
    DownloadUrlList = [DownloadUrl || {_, DownloadUrl} <- DownloadUrlTupleList1],
    web_server_util:output_text(
        Req,
        jsone:encode([
            {static_version, LatestStaticResourceVersion},
            {download, DownloadUrlList},
            {app_id, util:to_binary(AppId)}
        ])
    ).

get_data_from_ets(AppId, CurrentVersion) ->
    case ets:select(?ETS_CLIENT_STATIC_RESOURCE_RECORD, [{
        #ets_client_static_resource_record{app_id = AppId, _ = '_'}, [], ['$_']
    }]) of
        [] -> ?ERROR("查无结果: ~p", [AppId]), exit(not_found);
        R ->
            lists:filtermap(
                fun(Record) ->
                    if
                        is_record(Record, ets_client_static_resource_record) ->
                            #ets_client_static_resource_record{
                                version = Version1, download = Download
                            } = Record,
                            Version = util:to_int(Version1),
                            ?DEBUG("Version: ~p", [{Version, CurrentVersion, Version > CurrentVersion, Download}]),
                            ?IF(Version > CurrentVersion, {true, {Version, util:to_binary(Download)}}, false);
                        true -> false
                    end
                end,
                R
            )
    end.

update_data_2_ets(AppId, Data) ->
    case Data of
        RealData when is_list(RealData) ->
            Data2Ets =
                lists:foldl(
                    fun(VerDownloadTupleList, Tmp) ->
                        Data2Map = maps:from_list(VerDownloadTupleList),
                        Version = util:to_list(maps:get(<<"version">>, Data2Map)),
                        Download = util:to_list(maps:get(<<"download">>, Data2Map)),
                        Tmp ++ [#ets_client_static_resource_record{
                            row_key = {AppId, Version}, app_id = AppId, version = Version, download = Download
                        }]
                    end,
                    [],
                    Data
                ),
            ?DEBUG("Data2Ets: ~p", [Data2Ets =:= []]),
            if
                Data2Ets =:= [] -> exit(empty);
                true ->
                    List = ets:select(?ETS_CLIENT_STATIC_RESOURCE_RECORD, [{
                        #ets_client_static_resource_record{app_id = AppId, _ = '_'}, [], ['$_']
                    }]),
                    RowKeyList = [RowKey || #ets_client_static_resource_record{row_key = RowKey} <- Data2Ets],
                    lists:foreach(
                        fun(EtsData) ->
                            #ets_client_static_resource_record{
                                row_key = RowKey
                            } = EtsData,
                            case lists:member(RowKey, RowKeyList) of
                                true ->
                                    noop;
                                false ->
                                    ?INFO("Delete static resource record : ~p", [EtsData]),
                                    ets:delete_object(?ETS_CLIENT_STATIC_RESOURCE_RECORD, EtsData)
                            end
                        end,
                        List
                    ),
                    ?DEBUG("Data2Ets: ~p", [Data2Ets]),
                    Data2EtsAfterSort = util_list:rkeysort(#ets_client_static_resource_record.version, Data2Ets),
                    ?DEBUG("Data2EtsAfterSort: ~p", [Data2EtsAfterSort]),
                    ets:insert(?ETS_CLIENT_STATIC_RESOURCE_RECORD, Data2EtsAfterSort),
                    ok
            end;
        O -> ?ERROR("非预期情况：~p", [O]), exit(unexpection)
    end.

chk_sign(Data, StringSign) ->
    DataMd5 = encrypt:md5(util:to_list(Data) ++ ?GM_SALT),
    ?DEBUG("~p~n", [{StringSign, DataMd5}]),
    ?ASSERT(StringSign == DataMd5, sign_error),
    ?DEBUG("StringSign: ~p", [StringSign]).
