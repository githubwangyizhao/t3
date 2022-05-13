%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 7月 2021 上午 10:33:48
%%%-------------------------------------------------------------------
-module(handle_game_server_list).
-author("Administrator").

-author("Administrator").

-include("system.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("server_data.hrl").
-include("gen/table_db.hrl").

%% API
-export([init/2]).

-define(TSL, 3).
-define(VER, 14).
%%-define(ANDROID_DOWNLOAD_URL, "https://goldenmaster1.s3-ap-southeast-1.amazonaws.com/").
%%-define(IOD_DOWNLOAD_URL, "https://iosdownloads.site/install/3dvhvzpa1gcd-goldmaster-292").
-define(ALI_IP138_TOKEN, "APPCODE 59815c4fcc8a4366b2645c3ae17d5e64").
-define(IP_138_TOKEN, "3d454d67330cfcd3ea792fcc4660016a").
-define(CountrySignTupleList, [{indonesia, "印度尼西亚"}, {thailand, "泰国"}]).

-define(RELOAD_URL, "https://debugapk.s3-ap-southeast-1.amazonaws.com/game.zip").
-define(ANDROID_DOWNLOAD_URL, "https://goldenmaster1.s3-ap-southeast-1.amazonaws.com/goldenmaster.apk").
-define(IOD_DOWNLOAD_URL, "").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try
            case Method of
                <<"POST">> -> handle(Method, Req0)
            end
        catch
            _:Reason ->
                ?ERROR("获取版本更新信息失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

getCountyByIpFromAli(Req) ->
    ?INFO("ddd: ~p", [cowboy_req:parse_header(<<"x-forwarded-for">>, Req)]),
    {_IP, _} = cowboy_req:peer(Req),
    Ip = cowboy_req:parse_header(<<"x-forwarded-for">>, Req),
%%        if
%%            ?IS_DEBUG =:= true ->
    % 测试用 泰国ip
%%                "195.190.133.255";
    % 测试用 印尼ip
%%                "129.227.33.150";
    % 测试用 香港ip
%%                "43.225.47.95";
%%            true ->
%%                cowboy_req:parse_header(<<"x-forwarded-for">>, Req)
%%                inet_parse:ntoa(IP)
%%        end,
    Url = "http://ali.ip138.com/ip/?datatype=jsonp&ip=" ++ Ip,
    ?INFO("ip: ~p Url: ~p", [Ip, Url]),
    ?DEBUG("length: ~p, Ip: ~p", [length(Ip), Ip]),
    RealIp =
        if
            length(Ip) > 1 ->
                hd(Ip);
            true ->
                Ip
        end,
    ?DEBUG("RealIp: ~p", [RealIp]),
    case httpc:request(get, {Url, [{"Authorization", ?ALI_IP138_TOKEN}]}, [], []) of
        {ok, {{_, RespCode, _}, _, HtmlResultJson}} ->
            if
                RespCode =/= 200 ->
                    ?ERROR("ip138 response faliure: ~p", [RespCode]),
                    failure;
                true ->
                    Response = jsone:decode(util:to_binary(HtmlResultJson)),
                    ?DEBUG("Response: ~p", [Response]),
                    Ret = util:to_atom(maps:get(<<"ret">>, Response)),
                    RetIp = maps:get(<<"ip">>, Response),
                    Data = maps:get(<<"data">>, Response),
                    ?INFO("Ret: ~p RetIp: ~p", [Ret, RetIp]),
                    ?DEBUG("Code: ~p", [Ret]),
                    ?DEBUG("Data: ~p", [Data]),
                    if
                        Ret == ok ->
                            Country = hd(Data),
                            MatchRes =
                                lists:filtermap(
                                    fun (S) ->
                                        #ets_platform_setting{
                                            platform = Sign,
                                            name = CountryName
                                        } = S,
                                        MatchCountry = unicode:characters_to_binary(CountryName),
                                        if
                                            Country =:= MatchCountry -> {true, Sign};
                                            true -> false
                                        end
                                    end,
                                    ets:tab2list(?ETS_PLATFORM_SETTING)
                                ),
                            ?IF(length(MatchRes) =:= 1, hd(MatchRes), failure);
                        true ->
                            ?ERROR("ip api return failure == ret: ~p", [{Url, Ret}]),
                            failure
                    end
            end;
        ErrorReason ->
            ?ERROR("ip api failure==error:~p", [{Url, ErrorReason}]),
            failure
    end.

getCountryByIpFromIp138(Req) ->
    ?INFO("ddd: ~p", [cowboy_req:parse_header(<<"x-forwarded-for">>, Req)]),
    {_IP, _} = cowboy_req:peer(Req),
    Ip =
        if
            ?IS_DEBUG =:= true ->
                % 测试用 泰国ip
%%                "195.190.133.255";
                % 测试用 印尼ip
                "129.227.33.150";
        % 测试用 香港ip
%%                "43.225.47.95";
            true ->
                cowboy_req:parse_header(<<"x-forwarded-for">>, Req)
%%                inet_parse:ntoa(IP)
        end,
    ?INFO("ip: ~p", [Ip]),
    Url = "http://api.ip138.com/ip/?ip=" ++ Ip ++ "&datetype=jsonp&token=" ++ ?IP_138_TOKEN,
    case util_http:get(Url) of
        {ok, Result} ->
            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("Response: ~p", [Response]),
            Ret = util:to_atom(maps:get(<<"ret">>, Response)),
            RetIp = maps:get(<<"ip">>, Response),
            Data = maps:get(<<"data">>, Response),
            ?INFO("Ret: ~p RetIp: ~p", [Ret, RetIp]),
            ?DEBUG("Code: ~p", [Ret]),
            ?DEBUG("Data: ~p", [Data]),
            if
                Ret == ok ->
                    Country = hd(Data),
                    MatchRes =
                        lists:filtermap(
                            fun ({Sign, Ele}) ->
                                MatchCountry = unicode:characters_to_binary(Ele),
                                if
                                    Country =:= MatchCountry -> {true, Sign};
                                    true -> false
                                end
                            end,
                            ?CountrySignTupleList
                        ),
                    ?IF(length(MatchRes) =:= 1, hd(MatchRes), failure);
                true ->
                    ?ERROR("ip api return failure == ret: ~p", [{Url, Ret}]),
                    failure
            end;
        ErrorReason ->
            ?ERROR("ip api failure==error:~p", [{Url, ErrorReason}]),
            failure
    end.

handle(<<"POST">>, Req)->
    ?INFO("Req: ~p", [Req]),
    {ParamInfoList, _ParamStr} = charge_handler:get_req_param_str(Req),
    Base64Data = util_list:opt(<<"data">>, ParamInfoList),
    StringSign = erlang:binary_to_list(util_list:opt(<<"sign">>, ParamInfoList)),
    Data = cow_base64url:decode(Base64Data),
    ?DEBUG("Data: ~p", [Data]),
    chk_sign(Data, StringSign),
    Params = jsone:decode(Data, [{object_format, proplist}]),
    ?INFO("Params: ~p", [ParamInfoList]),
    PlatformId = util:to_list(proplists:get_value(<<"platform">>, Params)),
    Server = util:to_list(proplists:get_value(<<"server">>, Params)),
    ?DEBUG("Data from admin: ~p", [{PlatformId, Server}]),
    GameServerList =
        case mod_charge_server:http_list() of
            [] -> noop;
            ServerList -> ServerList
        end,
    ?DEBUG("fff: ~p", [GameServerList]),
    Resp =
        if
            GameServerList =:= [] -> [{error_code, -3}, {error_msg, "not found"}];
            true ->
                case mod_server:get_game_server(PlatformId, Server) of
                    R when is_record(R, db_c_game_server) ->
                        #db_c_game_server{node = Node} = R,
                        [NodeName, _] = string:tokens(Node, "@"),
                        case lists:keyfind(util:to_atom(NodeName), 1, GameServerList) of
                            false -> [{error_code, -2}, {error_msg, "not found"}];
                            {_, UrlBinary} -> [{error_code, 0}, {error_msg, util:to_list(UrlBinary)}]
                        end;
                    E -> ?ERROR("非预期错误: ~p", [E]), [{error_code, -1}, {error_msg, "not found"}]
                end
        end,
    web_http_util:output_json(Req, Resp).

chk_sign(Data, StringSign) ->
    DataMd5 = encrypt:md5(util:to_list(Data) ++ ?GM_SALT),
    ?DEBUG("~p~n", [{StringSign, DataMd5}]),
    ?ASSERT(StringSign == DataMd5, sign_error),
    ?DEBUG("StringSign: ~p", [StringSign]).
