%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2019, GAME BOY
%%% @doc        游戏服http充值
%%% Created : 29. 十月 2019 11:43
%%%-------------------------------------------------------------------
-module(game_http_charge_handler).
-author("home").

%% API
-export([init/2]).

-include("common.hrl").

init(Req, Opts) ->
    Path = cowboy_req:path(Req),
    ?DEBUG("游戏服http self:~p~n",[self()]),

    if
        Path == <<"/send_mail">> orelse Path == <<"/send_notice">> orelse Path == <<"/set_account_type">>orelse Path == <<"/game_rpc">> ->
            request_router(Path, Req, Opts);
        true ->
            case request_router(Path, Req, Opts) of
                noop -> noop;  % 不是充值或之前的充值
                ok ->   % 最新的充值
                    {_, ParamStr} = get_req_param_data(Req),
                    logger2:write(game_charge_info, {Path, ParamStr});
                {'EXIT', Exit} ->
                    {_, ParamStr} = get_req_param_data(Req),
                    ?ERROR("充值EXIT: ~p ~n ", [Exit]),
                    logger2:write(game_charge_error, {Path, ParamStr, Exit});
                Result ->
                    {_, ParamStr} = get_req_param_data(Req),
                    ?ERROR("充值未知错误: ~p ~n ", [Result]),
                    logger2:write(game_charge_other_error, {Path, ParamStr, Result})
            end
    end,
    {ok, Req, Opts}.

request_router(<<"/hd_game_charge">>, Req, Opts) -> hudie_charge_handler:init(Req, Opts), noop;
request_router(<<"/game_charge_xingqiu">>, Req, Opts) -> charge_handler_xingqiu:init(Req, Opts), noop;
request_router(<<"/hd_game_charge_request">>, Req, Opts) -> hudie_charge_handler:init(Req, Opts), noop;
request_router(<<"/gm_activity">>, Req, Opts) -> gm_charge_handler:init(Req, Opts), noop;    % 后台活动操作
request_router(<<"/gm_charge">>, Req, Opts) -> gm_charge_handler:init(Req, Opts), noop;      % gm游戏服充值
request_router(<<"/send_gamebar_msg">>, Req, Opts) -> local_handler:init(Req, Opts), noop;   % 平台条件数据上报
request_router(<<"/jump_game_charge">>, Req, Opts) -> jump_game_handler:init(Req, Opts), noop;   % 跳转到游戏服充值
request_router(<<"/get_pf_access_token">>, Req, Opts) -> access_token_handler:init(Req, Opts), noop;
request_router(<<"/get_server_time">>, Req, Opts) -> handler_game_time:init(Req, Opts), noop;
request_router(<<"/set_server_time">>, Req, Opts) -> handler_game_time:init(Req, Opts), noop;
request_router(<<"/game_rpc">>, Req, Opts) -> game_rpc_handler:init(Req, Opts), noop;   % game rpc操作
request_router(<<"/send_mail">>, Req, Opts) -> handle_send_mail:init(Req, Opts), noop;       % 后台邮件
request_router(<<"/send_gift_mail">>, Req, Opts) -> handle_send_gift_mail:init(Req, Opts), noop;    % 后台邮件
request_router(<<"/send_notice">>, Req, Opts) -> handle_send_notice:init(Req, Opts), noop;   % 发送公告
request_router(<<"/set_account_type">>, Req, Opts) -> handle_set_account_type:init(Req, Opts), noop;
request_router(<<"/set_game_server_config">>, Req, Opts) -> handle_set_game_server_config:init(Req, Opts), noop;
request_router(<<"/delete_game_server_config">>, Req, Opts) -> handle_set_game_server_config:init(Req, Opts), noop;
request_router(Path, Req, Opts) ->
    ?WARNING("path_request Path:~p;ip: ~p ;opts:~p~n", [Path, server_http_charge_handler:get_ip(Req), Opts]),
    web_http_util:output_text(Req, "null_path"),
    noop.

get_req_param_data(Req) -> server_http_charge_handler:get_req_param_data(Req).
