%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            账号分享数据
%%% @end
%%% Created : 27. 十一月 2017 下午 9:01
%%%-------------------------------------------------------------------
-module(mod_account_share).
-include("common.hrl").
-include("gen/db.hrl").
%% API
-export([
    finish_share/2,
    do_finish_share/2,
    get_account_share_data/2,
    get_last_share_time/2
]).



finish_share(PlatformId, Account) ->
    mod_server_rpc:call_center(?MODULE, do_finish_share, [PlatformId, Account]).

do_finish_share(PlatformId, Account) ->
    ?ASSERT(mod_server:is_center_server()),
    Tran = fun() ->
        NewR =
            case get_account_share_data(PlatformId, Account) of
                null ->
                    #db_account_share_data{
                        platform_id = PlatformId,
                        account = Account,
                        finish_share_times = 1,
                        last_share_time = util_time:timestamp()
                    };
                R ->
                    R#db_account_share_data{
                        last_share_time = util_time:timestamp(),
                        finish_share_times = R#db_account_share_data.finish_share_times + 1
                    }
            end,
        db:write(NewR)
           end,
    db:do(Tran).


get_account_share_data(PlatformId, Account) ->
    ?ASSERT(mod_server:is_center_server()),
    db:read(#key_account_share_data{
        platform_id = PlatformId,
        account = Account
    }).

get_last_share_time(PlatformId, Account) ->
    R = mod_server_rpc:call_center(?MODULE, get_account_share_data, [PlatformId, Account]),
    if is_record(R, db_account_share_data) ->
        R#db_account_share_data.last_share_time;
        true ->
            if R == null ->
                noop;
                true ->
                    ?WARNING("get_last_share_time:~p", [{PlatformId, Account, R}])
            end,
            0
    end.