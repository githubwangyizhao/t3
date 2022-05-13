%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            客户端版本
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_client_version).
-include("common.hrl").
-include("gen/db.hrl").

%% API
-export([get_client_version/1, update_client_version/2, is_release/1]).

is_release(Version) ->
    case get_client_version(Version) of
        null ->

            1;
        R ->
            R#db_client_versin.is_release
    end.

get_client_version(Version) ->
    db:read(#key_client_versin{version = Version}).

update_client_version(Version, IsRelease) ->
    ?ASSERT(IsRelease == 0 orelse IsRelease == 1),
    NewR =
        case get_client_version(Version) of
            null ->
                #db_client_versin{
                    version = Version,
                    is_release = IsRelease,
                    time = util_time:timestamp()
                };
            R ->
                R#db_client_versin{
                    is_release = IsRelease,
                    time = util_time:timestamp()
                }
        end,
    Tran = fun() ->
        db:write(NewR)
           end,
    db:do(Tran).
