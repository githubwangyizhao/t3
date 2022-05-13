%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            接口cd模块
%%% @end
%%% Created : 13. 十一月 2017 下午 2:42
%%%-------------------------------------------------------------------
-module(mod_interface_cd).

-include("common.hrl").
-include("error.hrl").
%% API
-export([
    assert/2,

    check/2
]).

%% ----------------------------------
%% @doc 	检查接口cd
%% @throws 	none
%% @end
%% ----------------------------------
assert(InterfaceType, CdTime) ->
    check(InterfaceType, CdTime, true).
check(InterfaceType, CdTime) ->
    check(InterfaceType, CdTime, false).
check(InterfaceType, CdTime, IsThrow) ->
    Now = util_time:milli_timestamp(),
    LastTime = get_last_interface_time(InterfaceType),
    if
        Now >= LastTime + CdTime ->
            update_interface_time(InterfaceType, Now),
            true;
        true ->
            if IsThrow ->
                ?WARNING("接口cd:~p~n", [{InterfaceType, CdTime}]),
                exit(?ERROR_INTERFACE_CD_TIME);
                true ->
%%                    ?DEBUG("接口cd:~p~n", [{InterfaceType, CdTime}]),
                    false
            end
    end.

%% ----------------------------------
%% @doc 	获取上次接口调用时间
%% @throws 	none
%% @end
%% ----------------------------------
get_last_interface_time(InterfaceType) ->
    case get({interface_time, InterfaceType}) of
        ?UNDEFINED ->
            0;
        Time ->
            Time
    end.

%% ----------------------------------
%% @doc 	更新接口调用时间
%% @throws 	none
%% @end
%% ----------------------------------
update_interface_time(InterfaceType, Now) ->
    put({interface_time, InterfaceType}, Now).

