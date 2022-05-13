%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 1月 2021 上午 10:14:21
%%%-------------------------------------------------------------------
-module(game_http_oauth_handler).
-author("Administrator").

%% API
-export([init/2]).

-include("common.hrl").

init(Req, Opts) ->
    Path = cowboy_req:path(Req),
    ?DEBUG("第三方授权登录、获取账号信息及指定账号下的物品web http self:~p",[self()]),

    case request_router(Path, Req, Opts) of
        noop -> noop;  % 不是充值或之前的充值
        ok ->   % 最新的充值
            {_, ParamStr} = get_req_param_data(Req),
            logger2:write(game_charge_info, {Path, ParamStr});
        {'EXIT', Exit} ->
            {_, ParamStr} = get_req_param_data(Req),
            ?ERROR("第三方授权登录、获取账号信息及指定账号下的物品。EXIT: ~p", [Exit]),
            logger2:write(game_charge_error, {Path, ParamStr, Exit});
        Result ->
            {_, ParamStr} = get_req_param_data(Req),
            ?ERROR("第三方授权登录、获取账号信息及指定账号下的物品未知错误: ~p", [Result]),
            logger2:write(game_charge_other_error, {Path, ParamStr, Result})
    end,
    {ok, Req, Opts}.

%% oauth
request_router(<<"/oauth/authorize">>, Req, _Opts) -> handle_login_oauth:init(Req, _Opts), noop;
request_router(<<"/oauth/platform">>, Req, _Opts) -> handle_login_oauth:init(Req, _Opts), noop;
%%request_router(<<"/oauth/login">>, Req, _Opts) -> handle_login_oauth:init(Req, _Opts), noop;
request_router(<<"/oauth/signin">>, Req, _Opts) -> handle_login_oauth:init(Req, _Opts), noop;
request_router(<<"/oauth/token">>, Req, _Opts) -> handle_login_oauth:init(Req, _Opts), noop;
request_router(<<"/player/characters">>, Req, _Opts) -> handle_login_oauth:init(Req, _Opts), noop;
request_router(<<"/character/items">>, Req, _Opts) -> handle_login_oauth:init(Req, _Opts), noop;
request_router(<<"/item/modify">>, Req, _Opts) -> handle_login_oauth:init(Req, _Opts), noop;
%%request_router(<<"/item/modify">>, Req, _Opts) -> handle_goldcoin:init(Req, _Opts), noop;
request_router(<<"/level/limitation">>, Req, _Opts) -> handle_goldcoin:init(Req, _Opts), noop;

request_router(Path, Req, Opts) ->
    case re:run(binary_to_list(cowboy_req:path(Req)), cowboy_req:binding(id, Req)) of
        nomatch ->
            ?WARNING("path_request Path:~p ;ip: ~p ;opts:~p", [Path, server_http_charge_handler:get_ip(Req), Opts]),
            web_http_util:output_json(Req, 404),
            noop;
        _ ->
            [UrlPrefix, []| UrlSuffix] = re:replace(binary_to_list(cowboy_req:path(Req)), "/" ++ binary_to_list(cowboy_req:binding(id, Req)), ""),
            RealUrlPath = binary_to_list(UrlPrefix) ++ binary_to_list(UrlSuffix),
            ?DEBUG("real url path: ~p", [list_to_binary(RealUrlPath)]),
            request_router(list_to_binary(RealUrlPath), Req, Opts)
%%            request_router(list_to_binary(RealUrlPath), Req, Opts, list_to_binary(RealUrlPath))
    end.
%%request_router(<<"/player/info">>, Req, _Opts, Path) -> handle_login_oauth:init(Req, _Opts, Path), noop;
%%request_router(<<"/player/items">>, Req, _Opts, Path) -> handle_login_oauth:init(Req, _Opts, Path), noop.

get_req_param_data(Req) -> server_http_charge_handler:get_req_param_data(Req).
