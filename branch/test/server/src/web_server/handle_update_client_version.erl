%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                更新客户端版本
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_update_client_version).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").
-include("server_data.hrl").
init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),

    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                ?ERROR("设置客户端版本失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"GET">>, Req) ->
%%    QS = cowboy_req:qs(Req),
%%    Data = web_server_util:get_data_and_check_sign(QS),
%%    Params = cow_qs:parse_qs(Data),

    {Params, ParamStr} = get_req_param_str(Req),
    ?INFO("设置客户端版本:~p~n", [ParamStr]),
    PlatformId = util:to_list(get_list_value(<<"platform_id">>, Params)),
    ChannelId = util:to_list(get_list_value(<<"channel">>, Params)),
    Version = util:to_list(proplists:get_value(<<"version">>, Params)),
    {DataId, Key2} = handle_client_version:get_client_platform_version_key(PlatformId, ChannelId),
%%    mod_server_data:set_str_data(?SERVER_DATA_CLIENT_VERSION, Version),
    mod_server_data:set_str_data(DataId, Key2, Version),
    web_server_util:output_text(
        Req,
        jsone:encode([{error_code, 0}, {msg, util:to_binary(Version)}])
    );
handle(_, Req) ->
%% Method not allowed.
    cowboy_req:reply(405, Req).



%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).