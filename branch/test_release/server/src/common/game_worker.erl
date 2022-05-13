%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc             通用进程
%%% @end
%%% Created : 27. 六月 2016 上午 11:48
%%%-------------------------------------------------------------------
-module(game_worker).
-include("logger.hrl").
-define(SERVER, ?MODULE).
%% API
-export([
    start_link/0,
    apply/3,
    apply/2
]).
-export([init/0]).
start_link() ->
    {ok, _Pid} = proc_lib:start_link(?MODULE, init, []).

apply(Fun, Args) when is_function(Fun) ->
    ?SERVER ! {apply, Fun, Args}.
apply(M, F, A) ->
    ?SERVER ! {apply, M, F, A}.

init() ->
    proc_lib:init_ack({ok, self()}),
    register(?SERVER, self()),
    loop().

loop() ->
    handle_msg(lists:reverse(drain([]))).
handle_msg([]) ->
    handle_msg(
        receive
            Msg ->
                lists:reverse(drain([Msg]))
        end
    );
handle_msg([Msg | T]) ->
    case Msg of
        {apply, Fun, Args} ->
            util:catch_apply(Fun, Args),
            handle_msg(T);
        {apply, M, F, A} ->
            util:catch_apply(M, F, A),
            handle_msg(T);
        Other ->
            ?FETAL_ERROR("game_worker unexpected msg:~p", [Other]),
            stop
    end.

drain(Msg) ->
    receive
        Input -> drain([Input | Msg])
    after 0 ->
        Msg
    end.

