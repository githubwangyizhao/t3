-module(web_server_util).
-export([
    output_html/2,
    output_error_code/2,
    output_text/2,
    get_data_and_check_sign/1
]).

-export([
    output_text_utf8/2
]).

%% 接口信息统计
-export([
%%    init_ets/0,
%%    get_interface_info/2,
%%    get_interface_times/2,
%%    add_interface_times/2
]).


-include("common.hrl").
%%%% ----------------------------------
%%%% @doc     接口调用信息
%%%% @end
%%%% ----------------------------------
%%-define(ETS_INTERFACE_INFO, interface_info).
%%-record(interface_info, {
%%    key,
%%    times,
%%    update_time
%%}).

%%init_ets() ->
%%    ets:new(?ETS_INTERFACE_INFO, ?ETS_INIT_ARGS(#interface_info.key)),
%%    ok.


%%get_interface_times(Interface, Ip) ->
%%    R = get_interface_info(Interface, Ip),
%%    R#interface_info.times.

%%get_interface_info(Interface, Ip) ->
%%    case ets:lookup(?ETS_INTERFACE_INFO, {Interface, Ip}) of
%%        [] ->
%%            R = #interface_info{
%%                key = {Interface, Ip},
%%                times = 0,
%%                update_time = 0
%%            },
%%            ets:insert(?ETS_INTERFACE_INFO, R),
%%            R;
%%        [R] ->
%%            case util:is_today(R#interface_info.update_time) of
%%                true ->
%%                    R;
%%                false ->
%%                    NewR = R#interface_info{
%%                        times = 0,
%%                        update_time = util:timestamp()
%%                    },
%%                    ets:insert(?ETS_INTERFACE_INFO, NewR),
%%                    NewR
%%            end
%%    end.
%%
%%add_interface_times(Interface, Ip) ->
%%    R = get_interface_info(Interface, Ip),
%%    NewTimes = R#interface_info.times + 1,
%%    ets:insert(?ETS_INTERFACE_INFO,
%%        R#interface_info{
%%            times = NewTimes,
%%            update_time = util:timestamp()
%%        }).
%%
%%jump_official_website(Req) ->
%%    cowboy_req:reply(303, #{
%%        <<"location">> => <<?OFFICIAL_WEBSITE>>,
%%        <<"connection">> => <<"close">>
%%    }, Req).

output_html(Req, Body) ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/html">>},
        Body,
        Req
    ).

output_error_code(Req, ErrorCode) ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"text/plain">>, <<"connection">> => <<"close">>},
        jsone:encode([{'ErrorCode', ErrorCode}]),
        Req
    ).

output_text(Req, Text) ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"application/json">>, <<"access-control-allow-origin">> => <<"*">>},
        Text,
        Req
    ).

output_text_utf8(Req, Text) ->
    cowboy_req:reply(
        200,
        #{<<"content-type">> => <<"application/json;charset=utf-8">>, <<"access-control-allow-origin">> => <<"*">>},
        Text,
        Req
    ).
get_data_and_check_sign(Qs) ->
%%    StringQs = util:to_list(Qs),
%%    ?DEBUG("qs:~p", [Req]),
    Params = cow_qs:parse_qs(Qs),
%%    ?DEBUG("Params:~p", [Params]),
    Base64Data = util_list:opt(<<"data">>, Params),
%%    Data = base64:decode(Base64Data),

    Data = cow_base64url:decode(Base64Data),

    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, Params)),
%%    [StringArgs, _] = string:split(StringQs, "&sign="),
%%    ?DEBUG("Data:~p", [{Base64Data, Data, StringSign}]),
    DataMd5 = encrypt:md5(util:to_list(Data) ++ ?GM_SALT),
%%    ?DEBUG("~p~n", [{StringSign, DataMd5}]),
    ?ASSERT(StringSign == DataMd5, sign_error),
    Data.

chk_param_sign_oauth(ParamList, ClientSecret) ->
    ?DEBUG("chk_param_sign_oauth: ~p, secret: ~p", [ParamList, ClientSecret]),
    ok.
