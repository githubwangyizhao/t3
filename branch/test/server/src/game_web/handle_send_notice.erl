%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                发送公告
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_send_notice).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    HasBody = cowboy_req:has_body(Req0),
    Req =
        try handle(Method, HasBody, Req0)
        catch
            _:Reason ->
                ?ERROR("发送公告失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    JsonBody = jsone:decode(Data),
    ?DEBUG("发送公告:~p~n", [{cowboy_req:peer(Req), JsonBody}]),
    Content = util:to_list(maps:get(<<"content">>, JsonBody)),
%%    Result = api_chat:notice_system_message(Content),
    Result = api_player_chat:notice_system_message(Content),
    if Result == ok ->
        ?DEBUG("发送公告成功:~p", [{Content}]),
        web_server_util:output_text(
            Req,
            jsone:encode([{error_code, 0}])
        );
        true ->
            ?ERROR("发送公告失败:~p", [{Result}]),
            web_server_util:output_text(
                Req,
                jsone:encode([{error_code, 1}])
            )

    end;
%%    NodeList = maps:get(<<"nodeList">>, JsonBody),
%%    lists:foreach(
%%        fun(Node) ->
%%            Result = rpc:call(util:to_atom(Node),  api_chat, notice_system_message, [Content], 6000),
%%            if Result == ok ->
%%                ?INFO("发送公告成功:~p", [{Node}]);
%%                true ->
%%                    ?ERROR("发送公告失败:~p", [{Node, Result}])
%%            end
%%
%%        end,
%%        NodeList
%%    ),
%%    web_server_util:output_text(
%%        Req,
%%        jsone:encode([{error_code, 0}])
%%    );
handle(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
handle(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
