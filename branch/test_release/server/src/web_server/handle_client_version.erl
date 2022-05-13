%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                获取客户端版本
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_client_version).

-export([
    get_client_platform_version_key/1,  % 获得客户端平台版本Key
    get_client_platform_version_key/2,
    init/2
]).

-include("common.hrl").
-include("gen/db.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                ?ERROR("获取所有区服失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0)}])
        end,
    {ok, Req, Opts}.

handle(<<"GET">>, Req) ->
    {Params, ParamStr} = get_req_param_str(Req),
    ?INFO("获得客户端版本:~p~n", [ParamStr]),
    {PlatformId, ChannelId} =
        case catch get_list_value(<<"platform_id">>, Params) of
%%              @TODO
%%            {'EXIT', _R} ->
%%                {?PLATFORM_BAIDU, ?PLATFORM_BAIDU};
            PlatformId1 ->
                PlatformIdStr = util:to_list(PlatformId1),
                ChannelStr =
                    case catch util:to_list(get_list_value(<<"channel">>, Params)) of
                        {'EXIT', _R} ->
                            PlatformIdStr;
                        ChannelStr1 ->
                            ChannelStr1
                    end,
                {PlatformIdStr, ChannelStr}
        end,
    {DataId, Key2} = get_client_platform_version_key(PlatformId, ChannelId),
    VersionStr = mod_server_data:get_str_data(DataId, Key2),
    Version = ?IF(VersionStr == "", "0.0.0", VersionStr),
%%    Version = mod_server_data:get_str_data(27),
    Result = util:to_binary(Version),
    ?INFO("get_client_version~p:~p", [{PlatformId, ChannelId}, Version]),
    web_server_util:output_text(
        Req,
        Result
    );
handle(_, Req) ->
%% Method not allowed.
    cowboy_req:reply(405, Req).

%% @doc fun 获得客户端平台版本Key
get_client_platform_version_key(PlatformId) ->
    get_client_platform_version_key(PlatformId, PlatformId).
get_client_platform_version_key(PlatformId, Channel) ->
    case PlatformId of
%%        ?PLATFORM_BAIDU ->
%%            {27, 0};
%%        ?PLATFORM_OPPO ->
%%            {100, 0};
        _ ->
            #t_channel{
                id = Id
            } = try_get_t_channel(PlatformId, Channel),
            ?ASSERT(Id > 0, {t_channel, id, 0}),
            {?SERVER_DATA_CLIENT_PLATFORM_VERSION, Id}
%%        ?PLATFORM_VM ->
%%            case Channel of
%%                ?CHANNEL_VIVO ->
%%                    {?SERVER_DATA_CLIENT_PLATFORM_VERSION, Id};
%%                ?CHANNEL_MEIZU ->
%%                    {?SERVER_DATA_CLIENT_PLATFORM_VERSION, 11}
%%            end
    end.


%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).


%% ================================================ 模板操作 ================================================
%% @doc fun 获得渠道模板
try_get_t_channel(PlatformId, Channel) ->
    t_channel:assert_get({PlatformId, Channel}).