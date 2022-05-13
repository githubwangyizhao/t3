%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc                获取最近登录的列表
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(handle_all).

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
    PlatformId = util:to_list(proplists:get_value(<<"platform_id">>, Params)),
    AppIdInQuery = util:to_list(proplists:get_value(<<"app_id">>, Params)),
    VersionInQuery = util:to_list(proplists:get_value(<<"version">>, Params)),
%%    ?ASSERT(mod_server:get_platform_record(PlatformId) =/= null, {t_platform, PlatformId}),
%%    PlatformId = login_server:get_real_platform_id(PlatformId_0),
    AccId =
        if
%%            PlatformId == ?PLATFORM_LOCAL orelse PlatformId == ?PLATFORM_TEST ->
%%                util:to_list(proplists:get_value(<<"acc_id">>, Params));
%%            PlatformId == ?PLATFORM_QQ ->
%%                OpenId = util:to_list(proplists:get_value(<<"open_id">>, Params)),
%%                Platform = util:to_int(proplists:get_value(<<"p">>, Params)),
%%                api_login:get_acc_id(PlatformId, OpenId, Platform);
            true ->
%%            PlatformId == ?PLATFORM_WX orelse PlatformId == ?PLATFORM_AWY ->
                util:to_list(proplists:get_value(<<"acc_id">>, Params))
        end,
    ?ASSERT(AccId =/= "undefined", accid_undefined),
%%    Channel = util:to_list(proplists:get_value(<<"channel">>, Params)),
    IsInnerAccount = mod_global_account:is_inner_account(PlatformId, AccId),
%%    Result = login_server:get_all_server_list(PlatformId, Channel, IsInnerAccount),
%%    Result = login_server:get_all_server_list(PlatformId, IsInnerAccount),

    VInQuery =
        case VersionInQuery of
            "undefined" -> 1;
            VerInQuery ->
                [VInQuery1, _] = string:tokens(VerInQuery, "."),
                VInQuery1
        end,
    Env = env:get(env, "production"),
    ReviewingSid = ?REVIEWING_SERVER(Env),
    {ReviewingSid1, IsReviewing} =
        case mod_global_account:get_app_info(AppIdInQuery) of
            null -> {ReviewingSid, []};
            R ->
                ?INFO("AppInfo: ~p", [{R, R#ets_erget_setting.status, R#ets_erget_setting.status =:= 1}]),
                [VersionInEts, _] = string:tokens(R#ets_erget_setting.client_version, "."),
                {?IF(VInQuery > VersionInEts, ReviewingSid, noop), ?IF(R#ets_erget_setting.status =:= 1, reviewing, [])}
        end,
%%    ReviewingSid1 =
%%        case mod_global_account:get_app_version(AppIdInQuery)  of
%%            {'EXIT', Err1} ->
%%                ?ERROR("get_app_version error: ~p", [Err1]),
%%                ReviewingSid;
%%            VersionInEts ->
%%                ?INFO("VersionInEts: ~p", [VersionInEts]),
%%                ?IF(VInQuery > VersionInEts, ReviewingSid, noop)
%%        end,
%%    IsReviewing = mod_global_account:is_reviewing(AppIdInQuery),
    ?INFO("VersionInQuery: ~p", [{VersionInQuery, VInQuery, ReviewingSid1, IsReviewing}]),
    Result =
        if
            %% 审核包，且客户端的版本号比ets中的client_version要大，此时为审核人员打开包，且客户端正在审核中，服务器列表只显示审核服
            ReviewingSid1 =/= noop andalso IsReviewing =:= reviewing ->
                login_server:pack_server_list(PlatformId, [ReviewingSid1]);
            %% 审核包，且客户端的版本号比ets中的client_version要小，此时为普通玩家打开包，且客户端正在审核中，
            %% 非审核包，且无论客户端的版本号与ets中的client_version的大小，此时为非审核包，所有人打开
            %% 因为是普通玩家打开包，因此要从服务器列表中去除掉审核服
            true ->
%%            ReviewingSid1 =:= noop andalso IsReviewing =:= reviewing ->
                %% 去除掉审核服
                AllSeverList = login_server:get_all_server_list(PlatformId, IsInnerAccount),
                lists:filtermap(
                    fun(SidInfo) ->
                        {id, SidFromServerList} = lists:keyfind(id, 1, SidInfo),
                        SidString = ?IF(is_binary(SidFromServerList), util:to_list(SidFromServerList), SidFromServerList),
                        if
                            SidString =:= ReviewingSid -> false;
                            true ->
                                {true, SidInfo}
                        end
                    end,
                    AllSeverList
                )
        end,

%%    Result =
%%        case mod_global_account:is_reviewing(AppIdInQuery) of
%%            {'EXIT', Err} ->
%%                ?ERROR("Err: ~p", [Err]),
%%                Sid = ?REVIEWING_SERVER(Env),
%%                login_server:pack_server_list(PlatformId, [ReviewingSid]);
%%                ReviewingSid;
%%            [] ->
%%                login_server:get_all_server_list(PlatformId, IsInnerAccount);
                %% 去除掉审核服
%%                ReviewingSid2 =
%%                    lists:filtermap(
%%                        fun(SidInfo) ->
%%                            {id, SidFromServerList} = lists:keyfind(id, 1, SidInfo),
%%                            if
%%                                SidFromServerList =:= ReviewingSid1 -> false;
%%                                true ->
%%                                    {true, SidInfo}
%%                            end
%%                        end,
%%                        ReviewingSid
%%                    ),
%%                ReviewingSid2;
%%                ReviewingSid;
%%            R ->
%%                ?INFO("is_reviewing: ~p", [R]),
%%                Sid = ?REVIEWING_SERVER(Env),
%%                login_server:pack_server_list(PlatformId, [Sid])
%%                ReviewingSid
%%        end,
    web_server_util:output_text(
        Req,
        jsone:encode(Result)
    );
handle(_, Req) ->
    %% Method not allowed.
    cowboy_req:reply(405, Req).


%%get_all() ->
%%    util_list:shuffle(lists:foldl(
%%        fun(Id, Tmp) ->
%%            [
%%                [
%%                    {id, util:to_binary(io_lib:format("s~p",[Id]))},
%%                    {d, util:to_binary(io_lib:format("s~p",[Id]))},
%%                    {ip, util:to_binary("192.168.31.100")},
%%                    {p, 6050},
%%%%                    {is_new, 0},
%%                    {s, 1}
%%                ]
%%             |Tmp
%%            ]
%%        end,
%%        [],
%%        lists:seq(1, 1499)
%%    )).
%%
