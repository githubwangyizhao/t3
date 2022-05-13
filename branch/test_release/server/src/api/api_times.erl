%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(api_times).

-include("common.hrl").
-include("error.hrl").
-include("p_message.hrl").
-include("p_enum.hrl").
-include("gen/db.hrl").
%% API
-export([
    add_times/2,
    notice_times_change/2
]).

-export([
    pack_all_player_times_list/1
]).
%% ----------------------------------
%% @doc 	添加次数
%% @throws 	none
%% @end
%% ----------------------------------
add_times(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_times_add_times_tos{times_id = TimesId} = Msg,
    Result =
        try mod_times:buy_times(PlayerId, TimesId) of
            _ ->
                ?P_SUCCESS
        catch
            _:?ERROR_TIMES_LIMIT ->
                ?P_TIMES_LIMIT;
            _:?ERROR_NO_ENOUGH_PROP ->
                ?P_NO_ENOUGH_PROP;
            _:_Result ->
                ?DEBUG("add_times:~p~n", [{PlayerId, TimesId, _Result, erlang:get_stacktrace()}]),
                ?P_FAIL
        end,
    Out = proto:encode(#m_times_add_times_toc{result = Result, times_id = TimesId}),
    mod_socket:send(Out),
    State.

pack_all_player_times_list(PlayerId) ->
    pack_times_list(PlayerId, mod_times:get_all_player_times_info(PlayerId)).

%% ----------------------------------
%% @doc 	打包次数列表
%% @throws 	none
%% @end
%% ----------------------------------
pack_times_list(PlayerId, List) ->
    [
        begin
            if is_record(E, db_player_times_data) ->
                #db_player_times_data{
                    times_id = TimesId,
                    left_times = Value,
                    buy_times = BuyTimes,
                    use_times = UseTimes
                } = E;
                is_integer(E) ->
                    #db_player_times_data{
                        times_id = TimesId,
                        left_times = Value,
                        buy_times = BuyTimes,
                        use_times = UseTimes
                    } = mod_times:get_player_times_data(PlayerId, E)
            end,

            #times{
                times_id = TimesId,
                value = Value,
                buy_times = BuyTimes,
                recover_time = mod_times_recover:get_times_recover_time(TimesId),
                max_times = mod_times:get_init_free_times(PlayerId, TimesId),
                use_times = UseTimes,
                max_can_buy_times = mod_times:get_max_buy_times(PlayerId, TimesId)
            }
        end
        || E <- List].

%% ----------------------------------
%% @doc 	通知次数变化
%% @throws 	none
%% @end
%% ----------------------------------
notice_times_change(_PlayerId, []) ->
    noop;
notice_times_change(PlayerId, TimesList) ->
    Out = proto:encode(#m_times_notice_times_change_toc{times_list = pack_times_list(PlayerId, TimesList)}),
    mod_socket:send(PlayerId, Out).
