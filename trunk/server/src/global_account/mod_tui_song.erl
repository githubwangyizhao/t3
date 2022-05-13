%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. 9月 2021 下午 03:08:36
%%%-------------------------------------------------------------------
-module(mod_tui_song).
-author("Administrator").

-include("common.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    modify_push_list/4,
    set_no_push_account/2,
    get_list/0
]).

-export([
    test/0
]).

%%-define(HTTP_GET_URL(PlatformId),
%%    if
%%        PlatformId =:= ?PLATFORM_LOCAL ->
%%            "http://192.168.31.100:7399";
%%        PlatformId =:= ?PLATFORM_TEST ->
%%            "http://127.0.0.1:7399";
%%        true ->
%%            "http://127.0.0.1:7399"
%%    end).
-define(HTTP_HOST(Env),
    if
        Env =:= "develop" ->
            "http://192.168.31.100:7399";
        Env =:= "testing" ->
            "http://127.0.0.1:7199";
        Env =:= "testing_oversea" ->
            "http://127.0.0.1:7199";
        true ->
            "http://127.0.0.1:7199"
    end).

test() ->
    ParamList = lists:sort([
        {"platform", "local"},
        {"account", "l84"},
        {"registration_id", ""},
        {"sid", "160"}
    ]),
%%    Data0 = util_json:encode([{util:to_binary(Key), util:to_binary(Value)} || {Key, Value} <- ParamList]),
%%    ?DEBUG("Data0 : ~p", [Data0]),
    Data = util_cowboy:encode_data(ParamList),
    ?DEBUG("Data : ~p", [Data]),
%%    DecodeData = util_cowboy:decode_data(Data),
%%    ?DEBUG("DecodeData : ~p", [DecodeData]),
    ok.

modify_push_list(PlatformId, Account, RegistrationId, ServerId) ->
    ParamList = lists:sort([
        {"platform", PlatformId},
        {"account", Account},
        {"registration_id", RegistrationId},
        {"sid", ServerId}
    ]),
    ?DEBUG("数据 ： ~p", [ParamList]),
%%    Url = ?HTTP_GET_URL(PlatformId) ++ "/tool/modify_push_list",
    Env = env:get(env, "develop"),
    Url = ?HTTP_HOST(Env) ++ "/tool/modify_push_list",
    case util_http:post(Url, json, util_cowboy:encode_data(ParamList)) of
        {ok, Result} ->
            ?DEBUG("post 请求结果 ： ~p", [Result]),
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            ?DEBUG("Code: ~p, data: ~ts", [Code, Data]),
            if
                Code =:= 0 ->
                    noop;
                true ->
                    ?ERROR("Code: ~p; Msg: ~ts", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [Url, Reason]),
            false
    end.

set_no_push_account(PlatformId, Account) ->
    ParamList = lists:sort([
        {"platform", PlatformId},
        {"account", Account}
    ]),
    ?DEBUG("数据 ： ~p", [ParamList]),
%%    Url = ?HTTP_GET_URL(PlatformId) ++ "/tool/set_nopush_account",
    Env = env:get(env, "develop"),
    Url = ?HTTP_HOST(Env) ++ "/tool/set_nopush_account",
    case util_http:post(Url, json, util_cowboy:encode_data(ParamList)) of
        {ok, Result} ->
            ?DEBUG("post 请求结果 ： ~p", [Result]),
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            ?DEBUG("Code: ~p, data: ~ts", [Code, Data]),
            if
                Code =:= 0 ->
                    noop;
                true ->
                    ?ERROR("Code: ~p; Msg: ~ts", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [Url, Reason]),
            false
    end.

get_list() ->
    ParamList = lists:sort([
        {"platform", "local"}
    ]),
    ?DEBUG("数据 ： ~p", [ParamList]),
%%    Url = ?HTTP_GET_URL("local") ++ "/tool/push_list",
    Env = env:get(env, "develop"),
    Url = ?HTTP_HOST(Env) ++ "/tool/push_list",
    case util_http:post(Url, json, util_cowboy:encode_data(ParamList)) of
        {ok, Result} ->
            ?DEBUG("post 请求结果 ： ~p", [Result]),
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Code = util:to_int(maps:get(<<"code">>, Response)),
            Msg = util:to_list(maps:get(<<"msg">>, Response)),
            Data = maps:get(<<"data">>, Response),
            ?DEBUG("Code: ~p, data: ~ts", [Code, Data]),
            if
                Code =:= 0 ->
                    noop;
                true ->
                    ?ERROR("Code: ~p; Msg: ~ts", [Code, Msg]),
                    false
            end;
        {error, Reason} ->
            ?ERROR("\n fail2=>\n"
            "  url: ~ts\n"
            "  reason: ~p\n",
                [Url, Reason]),
            false
    end.