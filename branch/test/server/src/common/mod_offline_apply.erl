%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            离线操作模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_offline_apply).

-include("common.hrl").
-include("gen/db.hrl").
-export([
    recovery/1,
    store/4,
    clean_time/0,       % 清理离线操作过期数据
    clean/2
]).

clean(M, F) ->
    Tran1 = fun() ->
        lists:foreach(
            fun(PlayerOfflineApply) ->
                Mode = PlayerOfflineApply#db_player_offline_apply.module,
                Fun = PlayerOfflineApply#db_player_offline_apply.function,
                if Mode == M andalso  Fun == F ->
                    db:delete(PlayerOfflineApply);
                    true ->
                        noop
                end
            end,
            get_all_list()
        )
            end,
    db:do(Tran1).

%% @doc fun 清理离线操作过期数据
clean_time() ->
    DelTime = util_time:get_today_zero_timestamp() - ?DAY_S * 30,
    lists:foreach(
        fun(PlayerOfflineApply) ->
            PlayerId = PlayerOfflineApply#db_player_offline_apply.player_id,
            ChangeTime = PlayerOfflineApply#db_player_offline_apply.timestamp,
            case db:read(#key_player_data{player_id = PlayerId}) of
                #db_player_data{vip_level = _VipLevel} ->
                    if
                        ChangeTime < DelTime ->
                            Tran =
                                fun() ->
                                    db:delete(PlayerOfflineApply)
                                end,
                            db:do(Tran),
                            ?INFO("删除没用的离线数据-长期没在线玩家:~p~n", [PlayerOfflineApply]);
                        true ->
                            noop
                    end;
                _ ->
                    Tran =
                        fun() ->
                            db:delete(PlayerOfflineApply)
                        end,
                    db:do(Tran),
                    ?INFO("删除没用的离线数据-不存在玩家:~p~n", [PlayerOfflineApply])
            end
        end, get_all_list()).

%% ----------------------------------
%% @doc 	恢复apply
%% @throws 	none
%% @end
%% ----------------------------------
recovery(PlayerId) ->
    lists:foreach(
        fun(R) ->
            #db_player_offline_apply{
                module = ModuleString,
                function = FunString,
                args = ArgString
            } = R,
%%            ?DEBUG("~p~n", [R]),
            Tran = fun() ->
                db:delete(R)
                   end,
            db:do(Tran),
            Module = erlang:list_to_atom(ModuleString),
            Fun = erlang:list_to_atom(FunString),
            Arg = util_string:string_to_term(ArgString),
            try erlang:apply(Module, Fun, Arg) of
                Result ->
                    ?INFO("恢复操作成功:~p", [{PlayerId, Module, Fun, Arg, Result}])
            catch
                T:Reason ->
                    ?ERROR("恢复操作失败:~p", [{Reason, Module, Fun, Arg, T}])
            end
        end,
        lists:sort(get_all_player_offline_apply(PlayerId))
    ).

%% ----------------------------------
%% @doc 	记录apply
%% @throws 	none
%% @end
%% ----------------------------------
store(PlayerId, M, F, A) ->
    PlayerOfflineApply = #db_player_offline_apply{
        player_id = PlayerId,
        module = erlang:atom_to_list(M),
        function = erlang:atom_to_list(F),
        args = util_string:term_to_string(A),
        timestamp = util_time:timestamp()
    },
    Tran = fun() ->
        db:write(PlayerOfflineApply)
           end,
    db:do(Tran).



get_all_list() ->
%% 	ets:tab2list(player_fairyland)),
    dets:select(player_offline_apply, [{#db_player_offline_apply{_ = '_'}, [], ['$_']}]).

get_all_player_offline_apply(PlayerId) ->
    db_index:get_rows(#idx_player_offline_apply_1{player_id = PlayerId}).
