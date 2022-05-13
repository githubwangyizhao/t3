%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            日志服务
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(logger_loop).

%% API
-export([
    loop/0
]).
-record(state, {file, date}).

loop() ->
    {{Year, Month, Day}, _} = erlang:localtime(),
    {ok, File} = logger:open_log_file({Year, Month, Day}),
    proc_lib:init_ack({ok, self()}),
    handle_msg(#state{file = File, date = {Year, Month, Day}}, lists:reverse(drain([]))).

handle_msg(State, []) ->
    handle_msg(
        State,
        receive
            Msg ->
                lists:reverse(drain([Msg]))
        end
    );
handle_msg(#state{file = File, date = Date} = State, [Msg | T]) ->
    case Msg of
        {write, Data} ->
            {{YY, MM, DD}, {H, M, S}} = erlang:localtime(),
            if
                {YY, MM, DD} > Date ->
                    file:close(File),
                    {ok, NewFile} = logger:open_log_file({YY, MM, DD}),
                    logger:do_write(NewFile, Data, {{YY, MM, DD}, {H, M, S}}),
                    handle_msg(State#state{date = {YY, MM, DD}, file = NewFile}, T);
                true ->
                    logger:do_write(File, Data, {{YY, MM, DD}, {H, M, S}}),
                    handle_msg(State, T)
            end;
        clean_expire_log ->
            logger:handle_clean_expire_log(),
            handle_msg(State, T);
        {'EXIT', _, Reason} ->
            file:close(File),
            exit(Reason);
        Other ->
            io:format("~p unexpected msg:~p", [?MODULE, Other]),
            handle_msg(State, T)
    end.

drain(Msg) ->
    receive
        Input -> drain([Input | Msg])
    after 0 ->
        Msg
    end.
