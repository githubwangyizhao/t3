%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc         数据库加载代理进程
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(db_load_proxy).
-include("db_config.hrl").
-include("logger.hrl").
-define(UNLOAD_TIMEOUT, 1000 * 60 * 6). %%6分钟
-export([
    load/1,
    unload/1
]).
-export([start_link/0, init/0]).

start_link() ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, []).

init() ->
    register(?GAME_DB_LOAD_PROXY, self()),
    proc_lib:init_ack({ok, self()}),
    loop().

%% ----------------------------------
%% @doc 	加载热数据
%% @throws 	none
%% @end
%% ----------------------------------
load(PlayerId) ->
    Ref = erlang:make_ref(),
    Self = self(),
    ?GAME_DB_LOAD_PROXY ! {load, PlayerId, Self, Ref},
    receive
        {reload, Ref} ->
            ?DEBUG("热数据重新加载"),
            db_load:load_hot_data(PlayerId), ok,
            set_loaded(PlayerId);
        {ready, Ref} ->
            ?DEBUG("热数据已经就绪"),
            ok
    after 10000 ->
        exit(load_time_out)
    end.

%% ----------------------------------
%% @doc 	卸载热数据
%% @throws 	none
%% @end
%% ----------------------------------
unload(PlayerId) ->
    Ref = erlang:make_ref(),
    Self = self(),
    ?GAME_DB_LOAD_PROXY ! {unload, PlayerId, Self, Ref}.

%% ----------------------------------
%% @doc 	设置热数据成功
%% @throws 	none
%% @end
%% ----------------------------------
set_loaded(PlayerId) ->
    ?GAME_DB_LOAD_PROXY ! {set_loaded, PlayerId}.
%%    receive
%%        {ok, Ref} ->
%%            ok
%%    after 6000 ->
%%        exit(unload_time_out)
%%    end.

loop() ->
    receive
        {set_loaded, PlayerId} ->
            case get({is_loaded, PlayerId}) of
                true ->
                    ?ERROR("Already loaded:~p", [PlayerId]);
                _ ->
                    noop
            end,
            put({is_loaded, PlayerId}, true);
        {load, PlayerId, From, Ref} ->
            case get({is_loaded, PlayerId}) of
                true ->
                    From ! {ready, Ref};
                _ ->
                    From ! {reload, Ref}
            end,
            case erlang:erase({unload_timer, PlayerId}) of
                undefined ->
                    noop;
                UnloadTimerRef ->
                    erlang:cancel_timer(UnloadTimerRef)
            end;
        {unload, PlayerId, _From, _Ref} ->
            case erlang:get({unload_timer, PlayerId}) of
                undefined ->
                    UnloadTimerRef = erlang:start_timer(?UNLOAD_TIMEOUT, self(), {do_unload, PlayerId}),
                    put({unload_timer, PlayerId}, UnloadTimerRef);
                UnloadTimerRef ->
                    erlang:cancel_timer(UnloadTimerRef),
                    NewUnloadTimerRef = erlang:start_timer(?UNLOAD_TIMEOUT, self(), {do_unload, PlayerId}),
                    put({unload_timer, PlayerId}, NewUnloadTimerRef)
            end;
%%            From ! {ok, Ref};
        {timeout, ThisUnloadTimerRef, {do_unload, PlayerId}} ->
            case erlang:get({unload_timer, PlayerId}) of
                undefined ->
                    ?WARNING("no unload_timer:~p", [PlayerId]);
                ThisUnloadTimerRef ->
                    case mod_online:is_online(PlayerId) of
                        true ->
                            noop;
                        _ ->
                            ?DEBUG("清理热数据:~p", [PlayerId]),
                            try db_load:unload_hot_data(PlayerId)
                            catch
                                _:Reason ->
                                    ?ERROR("unload_hot_data_error: ~p~n", [{Reason, erlang:get_stacktrace()}])
                            end,
                            erlang:erase({unload_timer, PlayerId}),
                            erlang:erase({is_loaded, PlayerId})
                    end;
                _O ->
                    ?DEBUG("收到其他消息:~p~n",[_O]),
                    noop
            end;
        Other ->
            ?WARNING("db_load_proxy_unexpected msg:~p", [Other])
    end,
    loop().
