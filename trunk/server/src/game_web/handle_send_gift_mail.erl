%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 10月 2021 下午 03:01:33
%%%-------------------------------------------------------------------
-module(handle_send_gift_mail).

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
                ?ERROR("发送邮件失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0), erlang:get_stacktrace()}])
        end,
    {ok, Req, Opts}.

handle(<<"POST">>, true, Req0) ->
    {ok, Body, Req} = cowboy_req:read_body(Req0, #{length => 64000, period => 5000}),
    Data = web_server_util:get_data_and_check_sign(Body),
    JsonBody = jsone:decode(Data),
    ?INFO("发送邮件:~p~n", [{cowboy_req:peer(Req), JsonBody}]),
    Title = util:to_list(maps:get(<<"title">>, JsonBody)),
    Content = util:to_list(maps:get(<<"content">>, JsonBody)),
    PlayerIdList = maps:get(<<"playerIdList">>, JsonBody),
    MailItemList_0 = maps:get(<<"mailItemList">>, JsonBody),
    {ConditionsId, ConditionsValue} =
        case catch maps:get(<<"conditionsId">>, JsonBody) of
                  ConditionsId1 when is_integer(ConditionsId1) ->
                      {ConditionsId1, maps:get(<<"conditionsValue">>, JsonBody)};
                  _ ->
                      {0, ""}
              end,

    MailItemList = lists:foldl(
        fun(E, Tmp) ->
            [
                {
                    maps:get(<<"propId">>, E),
                    maps:get(<<"propNum">>, E)
                }
                | Tmp]
        end,
        [],
        MailItemList_0
    ),

    try gift_mail:gm_add_mail(PlayerIdList, Title, Content, MailItemList, ConditionsId, ConditionsValue) of
        _ ->
            ?INFO("发送邮件成功:~p", [{PlayerIdList, Title, Content, MailItemList}]),
            web_server_util:output_text(
                Req,
                jsone:encode([{error_code, 0}])
            )
    catch
        _:Reason ->
            ?ERROR("发送邮件失败:~p", [{Reason, {PlayerIdList, Title, Content, MailItemList, ConditionsId, ConditionsValue}, erlang:get_stacktrace()}]),
            web_server_util:output_text(
                Req,
                jsone:encode([{error_code, 1}])
            )
    end;
handle(<<"POST">>, false, Req) ->
    cowboy_req:reply(400, [], <<"Missing body.">>, Req);
handle(_, _, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).

