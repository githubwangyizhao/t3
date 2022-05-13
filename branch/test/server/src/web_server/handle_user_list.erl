%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                user列表
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_user_list).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                {_ParamList, ParamStr} = get_req_param_str(Req0),
                ?ERROR("获取user列表失败:~p~n", [{cowboy_req:peer(Req0), Reason, ParamStr}]),
                cowboy_req:reply(405, Req0)
        end,
    {ok, Req, Opts}.

handle(<<"POST">>, Req) ->
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("获取user列表:~p", [ParamStr]),
    djs:check_web_sign(ParamList),
%%    ?INFO("获取服务器列表:~p", [cowboy_req:uri(Req)]),
    Channel = util:to_list(get_list_value(<<"c">>, ParamList)),           % 渠道标识
    Uid = util:to_list(get_list_value(<<"uid">>, ParamList)),           % 渠道标识
%%    Params = cowboy_req:parse_qs(Req),
%%    ?INFO("获取user列表:~p", [cowboy_req:uri(Req)]),
%%    Channel = util:to_list(proplists:get_value(<<"c">>, Params)),
%%    Uid = util:to_list(proplists:get_value(<<"uid">>, Params)),
    PlatformId = mod_server:get_platform_by_channel(Channel),
    if PlatformId == null ->
        ?WARNING("Channel no config:~p~n", [{Channel}]);
        true ->
            noop
    end,
    Result = get_user_list(PlatformId, Uid, Channel),
    web_server_util:output_text(
        Req,
        jsone:encode(Result)
    );
handle(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

get_user_list(PlatformId, AccId, Channel) ->
    Key = {?CACHE_WEB_USER_LIST, AccId, Channel},
    case mod_cache:get(Key) of
        null ->
            UserList = mod_server_rpc:call_center(mod_global_player, get_user_list, [PlatformId, AccId, Channel], 2000),
            mod_cache:update(Key, UserList, ?MINUTE_S * 3),
            UserList;
        ServerList ->
            ServerList
    end.


%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_json(Req).
