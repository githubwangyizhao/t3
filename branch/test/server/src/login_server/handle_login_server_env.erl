%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2020, GAME BOY
%%% @doc    登录服的env
%%% Created : 31. 三月 2020 21:22
%%%-------------------------------------------------------------------
-module(handle_login_server_env).
-author("home").


-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").


init(Req0, Opts) ->
    Path = cowboy_req:path(Req0),
    Req =
        try handle(Path, Req0)
        catch
            _:Reason ->
                ?ERROR("设置客户端版本失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}]),
                Req0
        end,
    {ok, Req, Opts}.

%% @doc fun 获得登录服的env
handle(<<"/get_env">>, Req) ->
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("获得登录服的env:~p~n", [ParamStr]),
    EnvKey = util:to_atom(get_list_value(<<"env_key">>, ParamList)),
%%    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),                     % 数据的校验码
%%    Str =
%%        case string:split(util:to_list(ParamStr), "&sign") of
%%            [Str1, _] ->
%%                Str1;
%%            _ ->
%%                exit(not_sign)
%%        end,
%%    mod_charge_server:check_gm_hash(Str, Hash),
    EnvValue = env:get(EnvKey),
    web_server_util:output_text(Req, util:to_binary(EnvValue));
handle(<<"/set_env">>, Req) ->
    {ParamList, ParamStr} = get_req_param_str(Req),
    ?INFO("设置登录服的env:~p~n", [ParamStr]),
%%    Hash = util:to_list(get_list_value(<<"sign">>, ParamList)),                     % 数据的校验码
%%    Str =
%%        case string:split(util:to_list(ParamStr), "&sign") of
%%            [Str1, _] ->
%%                Str1;
%%            _ ->
%%                exit(not_sign)
%%        end,
%%    mod_charge_server:check_gm_hash(Str, Hash),
    EnvKey = util:to_atom(get_list_value(<<"env_key">>, ParamList)),
    EnvValueStr = util:to_list(get_list_value(<<"env_value_str">>, ParamList)),
    EnvValue =
        if
            EnvValueStr == "_" ->
                util:to_int(get_list_value(<<"env_value">>, ParamList));
            true ->
                EnvValueStr
        end,
    OldEnvValue = env:get(EnvKey),
    if
        EnvValue == OldEnvValue -> noop;
        true -> env:set(EnvKey, EnvValue)
    end,
    web_server_util:output_text(Req, util:to_binary(EnvValue));
handle(_, Req) ->
%% Method not allowed.
    cowboy_req:reply(405, Req).



%% @fun 参数解析
get_list_value(Key, ParamList) ->
    charge_handler:get_list_value(Key, ParamList).

%% @fun 获得参数字符串  {[{<<"key">>, <<"value">>...], "key=value&..."}
get_req_param_str(Req) ->
    charge_handler:get_req_param_str(Req).