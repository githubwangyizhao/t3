%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc        md5 key
%%% Created : 21. 三月 2018 20:54
%%%-------------------------------------------------------------------
-module(charge_handler_md5_key).
-author("home").


-export([
    init/2,
    terminate/2
]).
-include("charge.hrl").

init(Req, Opts) ->
    NewReq = handle(Req),
    {ok, NewReq, Opts}.

handle(Req) ->
    Path = cowboy_req:path(Req),
    Req2 = path_request(Path, Req),
%%    ParamList = cowboy_req:parse_qs(Req),
%%    ChargeType = util:to_int(get_list_value(<<"charge_type">>, ParamList)),        % 充值类型
%%    Md5Key =
%%        if
%%            ChargeType == ?GM_CHARGE_TYPE_I_INGOT orelse ChargeType == ?GM_CHARGE_TYPE_ALL orelse ChargeType == ?GM_TYPE_CHANGE_WHITE_IP orelse ChargeType == ?GM_CHARGE_TYPE_NOT_VIP ->
%%                ?GM_KEY;
%%            ChargeType == ?CHARGE_TYPE_GM_NORMAL orelse ChargeType == ?CHARGE_TYPE_NORMAL ->
%%                ?KEY;
%%            true ->
%%                ""
%%        end,
%%    Req2 = web_http_util:output_text(Req, Str),
    Req2.



%% @fun 地址请求
path_request(<<"/md5_key">>, Req) ->     % 平台返回游戏服充值
    ParamList = cowboy_req:parse_qs(Req),
    ChargeType = util:to_int(get_list_value(<<"charge_type">>, ParamList)),        % 充值类型
    Md5Key=
    if
        ChargeType == ?GM_CHARGE_TYPE_I_INGOT orelse ChargeType == ?GM_CHARGE_TYPE_ALL orelse ChargeType == ?GM_TYPE_CHANGE_WHITE_IP orelse ChargeType == ?GM_CHARGE_TYPE_NOT_VIP ->
            ?GM_KEY;
        ChargeType == ?CHARGE_TYPE_GM_NORMAL orelse ChargeType == ?CHARGE_TYPE_NORMAL ->
            ?KEY;
        true ->
            ""
    end,
    web_http_util:output_text(Req, Md5Key);
%% @fun 地址请求
path_request(<<"/http_list">>, Req) ->     % 平台返回游戏服充值
    List = mod_charge_server:http_list(),
    web_http_util:output_error_code(Req, List);
path_request(Path, _Req) ->
%%    ?("path_request Path: ~p ~n", [Path]),
    Path.

terminate(_Reason, _Req) ->
    ok.

get_list_value(Key, ParamList) ->
    Value = util_list:opt(Key, ParamList),
    case Value of
        undefined ->
            exit(util:to_atom(Key));
        _ ->
            Value
    end.