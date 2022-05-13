%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            全局帐号
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(global_account_srv).

-behaviour(gen_server).
-include("common.hrl").
-include("gen/db.hrl").
-include("system.hrl").
%% API
-export([
    start_link/0,
    get_global_account/2,
    local_get_global_account/2
]).

%% gen_server callbacks
-export([init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

get_global_account(PlatformId, AccId) when is_list(PlatformId) andalso is_list(AccId)->
    case mod_server_config:get_server_type() of
        ?SERVER_TYPE_CENTER ->
            local_get_global_account_init(PlatformId, AccId);
        _ ->
            Self = self(),
            Ref = erlang:make_ref(),
            erlang:send({?MODULE, mod_server_config:get_center_node()}, {get_global_account, Self, Ref, PlatformId, AccId}),
            GlobalAccount =
                receive
                    {ok, Ref, _GlobalAccount} ->
                        _GlobalAccount
                after
                    2500 ->
                        ?WARNING("获取 global_account 超时:~p", [{PlatformId, AccId}]),
                        #db_global_account{
                            platform_id = PlatformId,
                            account = AccId,
                            recent_server_list = [],
                            type = 0
                        }
                end,
            GlobalAccount
    end.


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({get_global_account, From, Ref, PlatformId, AccId}, State) ->
    From ! {ok, Ref, local_get_global_account_init(PlatformId, AccId)},
    {noreply, State};
handle_info(_Info, State) ->
    ?WARNING("未知消息:~p", [_Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

local_get_global_account_init(PlatformId, AccId) ->
    case local_get_global_account(PlatformId, AccId) of
        null ->
            #db_global_account{
                platform_id = PlatformId,
                account = AccId,
                recent_server_list = [],
                type = 0
            };
        GlobalAccount ->
            GlobalAccount
    end.

local_get_global_account(PlatformId, AccId) ->
    ?ASSERT(mod_server:is_center_server()),
    Sql = io_lib:format("SELECT * from `global_account` WHERE platform_id = '~s' and account = '~s' ", [PlatformId, AccId]),
    {data, Res1} = mysql:fetch(game_db, list_to_binary(Sql), 2000),
    Fun = fun(R) ->
        R#db_global_account{
            row_key = {R#db_global_account.platform_id,R#db_global_account.account }
        }
          end,
    L = lib_mysql:as_record(Res1, db_global_account, record_info(fields, db_global_account), Fun),
    if L == [] ->
        null;
        true ->
            hd(L)
    end.
%%    db:read(#key_global_account{
%%        platform_id = util:to_list(PlatformId),
%%        account = AccId
%%    }).
