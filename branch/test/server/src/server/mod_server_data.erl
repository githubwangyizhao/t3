%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            服务器数据
%%% @end
%%% Created : 13. 六月 2016 下午 2:38
%%%-------------------------------------------------------------------
-module(mod_server_data).

-include("gen/db.hrl").
-include("server_data.hrl").
-export([
    get_int_data/1,
    get_int_data/2,
    get_str_data/1,
    get_str_data/2,
    set_int_data/2,
    set_int_data/3,
    set_str_data/2,
    set_str_data/3,
    get_server_data/1,
    get_server_data_init/1,
    get_server_data_init/2,
    clear_data/1,
    clear_data/2
]).

get_int_data(DataId) ->
    get_int_data(DataId, 0).
get_int_data(DataId, Key2) ->
    ServerDataInit = get_server_data_init(DataId, Key2),
    ServerDataInit#db_server_data.int_data.

get_str_data(DataId) ->
    get_str_data(DataId, 0).
get_str_data(DataId, Key2) ->
    ServerDataInit = get_server_data_init(DataId, Key2),
    ServerDataInit#db_server_data.str_data.

set_int_data(DataId, IntData) when is_integer(IntData) ->
    set_int_data(DataId, 0, IntData).
set_int_data(DataId, Key2, IntData) when is_integer(IntData) ->
    Tran =
        fun() ->
            ServerDataInit = get_server_data_init(DataId, Key2),
            db:write(ServerDataInit#db_server_data{int_data = IntData, change_time = util_time:timestamp()})
        end,
    db:do(Tran).

set_str_data(DataId, StrData) when is_list(StrData) ->
    set_str_data(DataId, 0, StrData).
set_str_data(DataId, Key2, StrData) when is_list(StrData) ->
    Tran =
        fun() ->
            ServerDataInit = get_server_data_init(DataId, Key2),
            db:write(ServerDataInit#db_server_data{str_data = StrData, change_time = util_time:timestamp()})
        end,
    db:do(Tran).

%% @fun 清除数据
clear_data(DataId) ->
    clear_data(DataId, 0).
clear_data(DataId, Key2) ->
    case get_server_data(DataId, Key2) of
        ServerData when is_record(ServerData, db_server_data) ->
            NewServerData = ServerData#db_server_data{int_data = 0, str_data = ""},
            if
                NewServerData =/= ServerData ->
                    Tran =
                        fun() ->
                            db:write(NewServerData#db_server_data{change_time = util_time:timestamp()})
                        end,
                    db:do(Tran);
                true ->
                    noop
            end;
        _ ->
            noop
    end.

%% ================================================ 数据操作 ================================================
%% @fun 获得服务器数据
get_server_data(DataId) ->
    get_server_data(DataId, 0).
get_server_data(DataId, Key2) ->
    db:read(#key_server_data{id = DataId, key2 = Key2}).
%% @fun 获得服务器数据 并初始化
get_server_data_init(DataId) ->
    get_server_data_init(DataId, 0).
get_server_data_init(DataId, Key2) ->
    case get_server_data(DataId, Key2) of
        ServerData when is_record(ServerData, db_server_data) ->
            ServerData;
        _ ->
            #db_server_data{id = DataId, key2 = Key2}
    end.
