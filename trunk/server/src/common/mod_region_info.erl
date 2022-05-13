%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 11月 2021 上午 10:24:48
%%%-------------------------------------------------------------------
-module(mod_region_info).
-author("Administrator").

%% API
-export([
    update_region/4,
    get_region_info/2,
    get_region_info/1
%%    get_region/0,
%%    get_region_by_tracker_token/1
]).

-include("common.hrl").
%% ----------------------------------
%% @doc 	通过货币单位查找, areaCode和region
%% @throws 	none
%% @end
%% ----------------------------------
get_region_info(Currency, AppIdInEts) ->
    {AreaCodeByCurrency, RegionByCurrency} = get_region_info(Currency),
    if
        AreaCodeByCurrency =:= noop andalso RegionByCurrency =:= noop ->
            case ets:lookup(?ETS_APP_INFO, AppIdInEts) of
                [AppInfoInEts] when is_record(AppInfoInEts, ets_app_info) ->
                    {logic_get_region_by_currency:get(Currency), AppInfoInEts#ets_app_info.area_code};
                [] -> {logic_get_region_by_currency:get("TWD"), "886"}
            end;
        true -> {AreaCodeByCurrency, RegionByCurrency}
    end.
get_region_info(Currency) when is_list(Currency) ->
    case ets:lookup(?ETS_AREA_INFO, Currency) of
        [AreaInfo] when is_record(AreaInfo, ets_area_info) ->
            {AreaInfo#ets_area_info.region, AreaInfo#ets_area_info.area_code};
        _ -> {noop, noop}
    end;
%%    case ets:select(?ETS_REGION_INFO, [{#ets_region_info{currency = Currency, area_code = '$1', region = '$2', _ = '_'}, [], ['$_']}]) of
%%        [RegionInfo] when is_record(RegionInfo, ets_region_info) ->
%%            {RegionInfo#ets_region_info.region, RegionInfo#ets_region_info.area_code};
%%        _ -> {noop, noop}
%%    end;
get_region_info(AreaCode) when is_integer(AreaCode) ->
    ?DEBUG("AreaCode: ~p", [AreaCode]),
    case ets:select(?ETS_AREA_INFO, [{#ets_area_info{area_code = util:to_list(AreaCode), currency = '$1', region = '$2', _ = '_'}, [], ['$_']}]) of
        [AreaInfo] when is_record(AreaInfo, ets_area_info) ->
            {AreaInfo#ets_area_info.region, AreaInfo#ets_area_info.currency};
        _ -> {noop, noop}
    end.
%%    case ets:select(?ETS_REGION_INFO, [{#ets_region_info{area_code = util:to_list(AreaCode), currency = '$1', region = '$2', _ = '_'}, [], ['$_']}]) of
%%        [RegionInfo] when is_record(RegionInfo, ets_region_info) ->
%%            {RegionInfo#ets_region_info.region, RegionInfo#ets_region_info.currency};
%%        _ -> {noop, noop}
%%    end.

%% ----------------------------------
%% @doc 	修改currency, region, areaCode与tracker_token的对应关系
%% @throws 	none
%% @end
%% ----------------------------------
update_region(TrackerToken, Region, AreaCode, Currency) ->
    TrackerInfo =
        case ets:lookup(?ETS_REGION_INFO, TrackerToken) of
            [TrackerInfoInEts] when is_record(TrackerInfoInEts, ets_region_info) ->
                NewTrackerInfo = ?IF(TrackerInfoInEts#ets_region_info.region =:= Region,
                    TrackerInfoInEts,
                    TrackerInfoInEts#ets_region_info{region = Region}
                ),
                NewTrackerInfo1 = ?IF(NewTrackerInfo#ets_region_info.area_code =:= AreaCode,
                    NewTrackerInfo,
                    NewTrackerInfo#ets_region_info{area_code = AreaCode}),
                NewTrackerInfo2 = ?IF(NewTrackerInfo1#ets_region_info.currency =:= Currency,
                    NewTrackerInfo1,
                    NewTrackerInfo1#ets_region_info{currency = Currency}),
                ets:delete(?ETS_REGION_INFO, TrackerToken),
                NewTrackerInfo2;
            [] ->
                #ets_region_info{tracker_token = TrackerToken, area_code = AreaCode, region = Region}
        end,
    ets:insert_new(?ETS_REGION_INFO, TrackerInfo),
    ok.
