%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            唯一id模块
%%% @end
%%% Created : 29. 十一月 2016 上午 11:45
%%%-------------------------------------------------------------------
-module(unique_id).
-include("gen/db.hrl").
-include("unique_id.hrl").
-include("common.hrl").
%% API
%% 游戏服调用 %%
-export([
    get_unique_id/1,
    get_unique_player_id/0     %% 玩家唯一id
]).

%% 唯一id服务器调用 %%
-export([
    dirty_get_unique_id/1,
    get_next_unique_id/1
]).


%% ----------------------------------
%% @doc 	玩家唯一id
%% @throws 	none
%% @end
%% ----------------------------------
get_unique_player_id() ->
    get_unique_id(?UNIQUE_ID_PLAYER_ID).

%% ----------------------------------
%% @doc 	帮派唯一id
%% @throws 	none
%% @end
%% ----------------------------------
%%get_unique_faction_id() ->
%%    get_unique_id(?UNIQUE_ID_FACTION_ID).

%% ----------------------------------
%% @doc 	获取唯一id
%% @throws 	none
%% @end
%% ----------------------------------
get_unique_id(UniqueIdType) ->
    case rpc:call(mod_server_config:get_unique_id_node(), unique_id_srv, get_unique_id, [UniqueIdType]) of
        {ok, UniqueId} ->
            UniqueId;
        Other ->
            ?ERROR("get_unique_id:~p", [{UniqueIdType, Other}]),
            exit(get_unique_id)
    end.


dirty_get_unique_id(Type) ->
    db:read(#key_unique_id_data{type = Type}).

%% ----------------------------------
%% @doc 	获取唯一id
%% @throws 	none
%% @end
%% ----------------------------------
get_next_unique_id(Type) ->
    case db:read(#key_unique_id_data{type = Type}) of
        null ->
            InitId = 10000,
            Tran = fun() ->
                db:write(#db_unique_id_data{type = Type, id = InitId})
                   end,
            db:do(Tran),
            InitId;
        R ->
            #db_unique_id_data{
                id = OldId
            } = R,
            NewId = OldId + 1,
            Tran = fun() ->
                db:write(R#db_unique_id_data{id = NewId})
                   end,
            db:do(Tran),
            NewId
    end.


