%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            合服模块
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(merge).
-include("server_data.hrl").
-include("common.hrl").
%% API
-export([action/0]).

%% ----------------------------------
%% @doc 	合服脚本
%% @throws 	none
%% @end
%% ----------------------------------
action() ->
    case mod_server_data:get_int_data(?SERVER_DATA_IS_NEED_MERGE_ACTION) of
        ?FALSE ->
            noop;
        ?TRUE ->
            ?INFO("执行合服脚本(~p)....", [mod_server_data:get_int_data(?SERVER_DATA_SERVER_MERGE_TIME)]),
            Tran = fun() ->
                mod_server_data:set_int_data(?SERVER_DATA_IS_NEED_MERGE_ACTION, ?FALSE),
                %% 合服脚本 %%
                rank_srv_mod:merge_versions()

                   end,
            db:do(Tran),
            ?INFO("执行合服脚本成功!")
    end.
