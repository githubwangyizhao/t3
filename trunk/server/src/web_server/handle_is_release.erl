%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                获取最近登录的列表
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_is_release).

-export([init/2]).

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").

init(Req0, Opts) ->
    Method = cowboy_req:method(Req0),
    Req =
        try handle(Method, Req0)
        catch
            _:Reason ->
                ?ERROR("获取所有区服失败:~p~n", [{cowboy_req:peer(Req0), Reason, cowboy_req:parse_qs(Req0)}])
        end,
    {ok, Req, Opts}.

handle(<<"GET">>, Req) ->
    Params = cowboy_req:parse_qs(Req),
    Version = util:to_list(proplists:get_value(<<"v">>, Params)),
    ?DEBUG("handle_is_release:~p", [Version]),
    Result = mod_client_version:is_release(util:to_list(Version)),

    web_server_util:output_text(
        Req,
        jsone:encode(Result)
    );
handle(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).
