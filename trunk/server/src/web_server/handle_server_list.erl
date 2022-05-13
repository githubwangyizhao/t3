%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                服务器列表
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_server_list).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                {_ParamList, ParamStr} = get_req_param_str(Req0),
                ?ERROR("获取服务器列表失败:~p~n", [{cowboy_req:peer(Req0), Reason, ParamStr}]),
                cowboy_req:reply(405, Req0)
        end,
    {ok, Req, Opts}.

handle(<<"POST">>, Req) ->
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("获取服务器列表:~p", [ParamStr]),
    djs:check_web_sign(ParamList),
    Channel = util:to_list(get_list_value(<<"c">>, ParamList)),           % 渠道标识
%%    ?INFO("获取服务器列表:~p", [cowboy_req:uri(Req)]),
%%    Params = cowboy_req:parse_qs(Req),
%%    Channel = util:to_list(proplists:get_value(<<"c">>, Params)),
    PlatformId = mod_server:get_platform_by_channel(Channel),
    Result = get_server_list(PlatformId),
    web_server_util:output_text(
        Req,
        jsone:encode(Result)
    );
handle(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

get_server_list(PlatformId) ->
    case mod_cache:get(?CACHE_WEB_SERVER_LIST) of
        null ->
            GameServerList = mod_server:get_game_server_list(PlatformId),
            ServerList = [
                begin
                    #db_c_game_server{
                        sid = ServerId,
                        desc = ServerName
                    } = E,
                    [
                        {serverid, ServerId},
                        {servername, util:to_binary(ServerName)}
                    ]
                end
                || E <- GameServerList

            ],
            mod_cache:update(?CACHE_WEB_SERVER_LIST, ServerList, ?MINUTE_S * 1),
            ServerList;
        ServerList ->
            ServerList
    end.

%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_json(Req).

