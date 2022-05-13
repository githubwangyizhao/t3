%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            登录公告
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_login_notice).
-include("common.hrl").
-include("server_data.hrl").
-include("gen/db.hrl").
%% API
-export([
    update_login_notice/3,
    get_login_notice/1,
    get_login_notice/2
]).


%% ----------------------------------
%% @doc 	更新登录公告
%% @throws 	none
%% @end
%% ----------------------------------
update_login_notice(PlatformId, ChannelId, Content) ->
    ?ASSERT(mod_server:is_center_server() == true),
    Len = erlang:length(Content),
    if Len > 2000 ->
        exit({len_limit, 2000});
        true ->
            noop
    end,
    Tran = fun() ->
        NoticeInit = get_db_login_notice_or_init(PlatformId, ChannelId),
%%        NewR =
%%            case db:read(#key_login_notice{platform_id = PlatformId}) of
%%                null ->
%%                    #db_login_notice{
%%                        platform_id = PlatformId,
%%                        content = Content
%%                    };
%%                R ->
%%                    R#db_login_notice{
%%                        content = Content
%%                    }
%%            end,
%%        db:write(NewR)
        db:write(NoticeInit#db_login_notice{content = Content})
           end,
    db:do(Tran),
%%    mod_server_data:set_str_data(?SERVER_DATA_LOGIN_NOTICE, Content),
    ok.

%% ----------------------------------
%% @doc 	获取登录公告
%% @throws 	none
%% @end
%% ----------------------------------
get_login_notice(PlatformId) -> % 兼容平台没有web旧的
    get_login_notice(PlatformId, "").
get_login_notice(PlatformId, Channel) ->
    case mod_server:is_center_server() of
        true ->
            case get_db_login_notice(PlatformId, Channel) of
                Db when is_record(Db, db_login_notice) ->
                    Db#db_login_notice.content;
                _ ->
                    NoticeInit = get_db_login_notice_or_init(PlatformId, ""),
                    NoticeInit#db_login_notice.content
            end;
%%            case db:read(#key_login_notice{platform_id = PlatformId}) of
%%                null ->
%%                    "";
%%                R ->
%%                    R#db_login_notice.content
%%            end;
        false ->
            Key = {?CACHE_LOGIN_NOTICE, PlatformId, Channel},
            case mod_cache:get(Key) of
                null ->
                    CenterNode = mod_server_config:get_center_node(),
                    Content =
                        case rpc:call(CenterNode, ?MODULE, get_login_notice, [PlatformId, Channel], 1000) of
                            {badrpc, Reason} ->
                                ?WARNING("获取登录公告失败:~p", [{CenterNode, Reason}]),
                                "";
                            RpcContent ->
                                RpcContent
                        end,
                    mod_cache:update(Key, Content, ?MINUTE_S * 1),
                    Content;
                Content ->
                    Content
            end
    end.




%% ================================================ 数据操作 ================================================
%% @doc db   获得登录公告
get_db_login_notice(PlatformId, ChannelId) ->
    db:read(#key_login_notice{platform_id = PlatformId, channel_id = ChannelId}).
%% @doc db   获得登录公告并初始
get_db_login_notice_or_init(PlatformId, ChannelId) ->
    case get_db_login_notice(PlatformId, ChannelId) of
        null ->
            #db_login_notice{platform_id = PlatformId, channel_id = ChannelId};
        Db -> Db
    end.