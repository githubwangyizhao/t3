%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 10月 2021 上午 11:59:01
%%%-------------------------------------------------------------------
-module(mod_adjust_info).
-author("Administrator").

%% API
-export([
    update_tracker_token/3,
    get_all_tracker_token/0,
    get_platform_by_tracker_token/1
]).

-include("common.hrl").

-define(APP_NOTICE_URL, ?IF(?IS_DEBUG, "http://127.0.0.1:7399/api/get_all_tracker_info", "http://127.0.0.1:7199/api/get_all_tracker_info")).
-define(DEFAULT_APP_NAME(Env),
    case Env of
        "develop" -> "com.tb.custom.test";
        "testing" -> "com.arsham.t3";
        "testing_oversea" -> "com.arsham.t3";
        _ -> "com.arsham.t3"
    end
).

%% ----------------------------------
%% @doc 	从后台获取platformId与tracker_token的对应关系
%% @throws 	none
%% @end
%% ----------------------------------
get_all_tracker_token() ->
    ?INFO("get tracker token from admin: ~p", [?APP_NOTICE_URL]),
    ReqData = [{"platformIdList", "[]"}],
    case util_http:post(?APP_NOTICE_URL, json, ReqData) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            ?DEBUG("Code: ~p", [{Code, Msg}]),
            ?DEBUG("Data: ~p", [{is_list(Data), Data}]),
            Data2Ets =
                lists:foldl(
                    fun(KeyValueMap, Tmp) ->
%%                        PlatformId = util:to_list(maps:get(<<"id">>, KeyValueMap)),
                        PlatformId = util:to_list(maps:get(<<"platformId">>, KeyValueMap)),
                        TrackerToken = util:to_list(maps:get(<<"trackerToken">>, KeyValueMap)),
                        Channel = util:to_list(maps:get(<<"channel">>, KeyValueMap)),
                        Region = util:to_list(maps:get(<<"region">>, KeyValueMap)),
                        AreaCode = util:to_list(maps:get(<<"areaCode">>, KeyValueMap)),
                        Currency = util:to_list(maps:get(<<"currency">>, KeyValueMap)),
                        Tmp1 =
                            case lists:keyfind(tracker_info, 1, Tmp) of
                                {tracker_info, TrackerInfoData} ->
                                    ?DEBUG("TrackerInfoData: ~p", [TrackerInfoData]),
                                    NewTrackerInfoData = [#ets_tracker_token{
                                        tracker_token = TrackerToken, platform_id = PlatformId, channel = Channel
                                    } | TrackerInfoData],
                                    ?DEBUG("NewTrackerInfoData: ~p", [NewTrackerInfoData]),
                                    lists:keyreplace(tracker_info, 1, Tmp, {tracker_info, NewTrackerInfoData});
                                _ ->
                                    [{tracker_info, [#ets_tracker_token{tracker_token = TrackerToken, platform_id = PlatformId, channel = Channel}]} | Tmp]
                            end,
                        case lists:keyfind(region_info, 1, Tmp1) of
                            {region_info, RegionInfo} ->
                                ?DEBUG("RegionInfo: ~p", [RegionInfo]),
                                NewRegionInfo = [#ets_region_info{
                                    tracker_token = TrackerToken, region = Region, area_code = AreaCode, currency = Currency
                                } | RegionInfo],
                                lists:keyreplace(region_info, 1, Tmp1, {region_info, NewRegionInfo});
                            _ ->
                                [{region_info, [#ets_region_info{tracker_token = TrackerToken, region = Region, area_code = AreaCode}]} | Tmp1]
                        end
%%                        [#ets_tracker_token{tracker_token = TrackerToken, platform_id = PlatformId, channel = Channel} |
%%                            Tmp]
                    end,
                    [],
                    Data
                ),
            ?DEBUG("fff: ~p", [Data2Ets]),
            case lists:keyfind(tracker_info, 1, Data2Ets) of
                {tracker_info, TrackerDataList} ->
                    lists:foreach(
                        fun(TrackerData) ->
                            ?IF(TrackerData =/= [], ets:insert_new(?ETS_TRACKER_TOKEN, TrackerData), ok)
                        end,
                        TrackerDataList
                    );
                _ ->
                    noop
            end,
            case lists:keyfind(region_info, 1, Data2Ets) of
                {region_info, RegionDataList} ->
                    lists:foreach(
                        fun(RegionData) ->
                            if
                                RegionData =/= [] ->
                                    ets:insert_new(?ETS_REGION_INFO, RegionData),
                                    ets:insert_new(?ETS_AREA_INFO,
                                        #ets_area_info{
                                            currency = RegionData#ets_region_info.currency,
                                            region = RegionData#ets_region_info.region,
                                            area_code = RegionData#ets_region_info.area_code
                                        }
                                    );
                                true -> ok
                            end
                        end,
                        RegionDataList
                    );
                _ ->
                    noop
            end;
%%            ?IF(Data2Ets =/= [], ets:insert_new(?ETS_TRACKER_TOKEN, Data2Ets), ok);
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [?APP_NOTICE_URL, Reason]),
            false
    end.

%% ----------------------------------
%% @doc 	修改platformId与tracker_token的对应关系
%% @throws 	none
%% @end
%% ----------------------------------
update_tracker_token(PlatformId, TrackerToken, Channel) ->
    TrackerInfo =
        case ets:lookup(?ETS_TRACKER_TOKEN, TrackerToken) of
            [TrackerInfoInEts] when is_record(TrackerInfoInEts, ets_tracker_token) ->
                NewTrackerInfo = ?IF(TrackerInfoInEts#ets_tracker_token.platform_id =:= PlatformId,
                    TrackerInfoInEts,
                    TrackerInfoInEts#ets_tracker_token{platform_id = PlatformId}
                ),
                NewTrackerInfo1 = ?IF(NewTrackerInfo#ets_tracker_token.channel =:= Channel,
                    NewTrackerInfo,
                    NewTrackerInfo#ets_tracker_token{channel = Channel}),
                ets:delete(?ETS_TRACKER_TOKEN, TrackerToken),
                NewTrackerInfo1;
            [] ->
                #ets_tracker_token{platform_id = PlatformId, tracker_token = TrackerToken, channel = Channel}
        end,
    ets:insert_new(?ETS_TRACKER_TOKEN, TrackerInfo).

%% ----------------------------------
%% @doc 	通过tracker_token获取对应的platform
%% @throws 	none
%% @end
%% ----------------------------------
get_platform_by_tracker_token(TrackerToken) ->
    PlatformList =
        case ets:lookup(?ETS_TRACKER_TOKEN, TrackerToken) of
            [InfoInEts] when is_record(InfoInEts, ets_tracker_token) ->
                [{InfoInEts#ets_tracker_token.platform_id, InfoInEts#ets_tracker_token.channel}];
            [] -> []
        end,
    ?DEBUG("PlatformList: ~p", [{PlatformList, length(PlatformList)}]),
    Env = env:get(env, "develop"),
    case length(PlatformList) of
        0 -> {null, null};
        1 -> hd(PlatformList);
        N ->
            ?INFO("~p下有~p个平台: ~p", [TrackerToken, N, PlatformList]),
            {?DEFAULT_PLATFORM(Env), ?DEFAULT_CHANNEL(Env)}
    end.