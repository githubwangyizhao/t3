%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2020, GAME BOY
%%% @doc        web http
%%% Created : 17. 二月 2020 13:51
%%%-------------------------------------------------------------------
-module(web_http_handler).
-author("home").

%% API
-export([
    init/2,
    terminate/2
]).

-include("common.hrl").

init(Req, Opts) ->
    Path = cowboy_req:path(Req),
    NewReq =
        case (catch request_router(Path, Req, Opts)) of
            {ok, Req1, _Opts} -> Req1;
            {'EXIT', Exit} ->
                ?ERROR("web_htpp EXIT: ~p ~n ", [Exit]),
                Req;
            Result ->
                ?ERROR("web_htpp ERROR: ~p ~n ", [Result]),
                Req
        end,
    {ok, NewReq, Opts}.

terminate(_Reason, _Req) ->
    ok.

request_router(<<"/user_list">>, Req, Opts) -> handle_user_list:init(Req, Opts);
request_router(<<"/server_list">>, Req, Opts) -> handle_server_list:init(Req, Opts);
request_router(<<"/is_release">>, Req, Opts) -> handle_is_release:init(Req, Opts);
request_router(<<"/get_pf_access_token">>, Req, Opts) -> access_token_handler:init(Req, Opts);
request_router(<<"/client_version">>, Req, Opts) -> handle_client_version:init(Req, Opts);
request_router(<<"/update_client_version">>, Req, Opts) -> handle_update_client_version:init(Req, Opts);

request_router(Path, Req, Opts) ->
    ?WARNING("path_request Path:~p ;ip: ~p ;opts:~p~n", [Path, server_http_charge_handler:get_ip(Req), Opts]),
    web_http_util:output_text(Req, "null_path"),
    exit(not_find_path).

