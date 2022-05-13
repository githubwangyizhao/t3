%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(util).
-include("common.hrl").
-export([
    to_list/1,                      %% 转换list
    to_int/1,                       %% 转换int
    to_float/1,                     %% 转换float
    to_binary/1,                    %% 转换binary
    to_atom/1,                      %% 转换atom
    to_tuple/1,                     %% 转换tuple
    float_num/1,
    float_num/2,                    %% 保留float小数点后数量
    str_to_float/1,                 %% str转float类型
    is_pid_alive/1,                 %% 进程是否存活
    run/2,
    for/3,                          %% FOR 循环
    sleep/1,                        %% 睡眠
    sleep/2,
    rpc_call/5,                     %% rpc call
    rpc_call/4,
    catch_apply/3,                  %% apply catch
    catch_apply/2,
    try_catch/1,                    %%
    get_boot_value/1,               %% 获取启动参数
    get_ip_from/1,
%%    get_ip_from1/1,
    get_node_shot_name/0,
    is_linux/0,                     %% 是否是linux系统
    output_line_info/1,             %% 输出信息行
    output_line_info/2,
    output_line_info_2/1,
    finish_line_info/0,
    speed_point_2_speed/1,          %% 速度点数 => 速度 (格/秒)
    is_robot/1                      %% 是否是机器人
]).

-export([
    get_dict/1,                     %% 字典取值
    get_dict/2,                     %% 字典取值
    update_timer_value/1,           %% 进程字典更新计时器记录  不记录
    update_timer_value/2            %% 进程字典更新计时器记录   Ref：null不记录
]).

%% 字典操作
-export([
    get_mod_dict/3,
    set_mod_dict/3,
    incr_mod_dict/4,
    erase_mod_dict/2
]).


get_node_shot_name() ->
    [Name, _Ip] = string:tokens(util:to_list(node()), "@"),
    Name.

% -----------------------------------------------------------------
% 字典
% -----------------------------------------------------------------
get_mod_dict(Module, Key, Default) ->
    case get({Module, Key}) of
        undefined -> set_mod_dict(Module, Key, Default);
        Value -> Value
    end.

set_mod_dict(Module, Key, Value0) ->
    Value =
        case is_function(Value0) of
            true -> Value0();
            false -> Value0
        end,
    put({Module, Key}, Value),
    Value.

incr_mod_dict(Module, Key, N, Default) ->
    OriVal = get_mod_dict(Module, Key, Default),
    NewVal = OriVal + N,
    set_mod_dict(Module, Key, NewVal).

erase_mod_dict(Module, Key) ->
    erase({Module, Key}).

%% ----------------------------------
%% @doc 	to list
%% @throws 	none
%% @end
%% ----------------------------------
to_list(E) when is_binary(E) -> binary_to_list(E);
to_list(E) when is_atom(E) -> atom_to_list(E);
to_list(E) when is_float(E) -> util_string:term_to_string(E);% float_to_list(E);
to_list(E) when is_tuple(E) -> tuple_to_list(E);
to_list(E) when is_integer(E) -> integer_to_list(E);
to_list(E) when is_list(E) -> E.

%% ----------------------------------
%% @doc 	to int
%% @throws 	none
%% @end
%% ----------------------------------
to_int(E) when is_list(E) -> list_to_integer(E);
to_int(E) when is_binary(E) -> binary_to_integer(E);
to_int(E) when is_float(E) -> round(E);
to_int(E) when is_atom(E) -> list_to_integer(atom_to_list(E));
to_int(E) when is_integer(E) -> E.

%% ----------------------------------
%% @doc 	to float
%% @throws 	none
%% @end
%% ----------------------------------
to_float(E) when is_list(E) -> list_to_float(E);
to_float(E) when is_binary(E) -> binary_to_float(E);
to_float(E) when is_float(E) -> E;
to_float(E) when is_atom(E) -> list_to_float(atom_to_list(E));
to_float(E) when is_integer(E) -> E / 1.

%% ----------------------------------
%% @doc 	float保留几个小数
%% @throws 	none
%% @end
%% ----------------------------------
float_num(Number) ->
    float_num(Number, 2).
float_num(Number, N) ->
    Value = math:pow(10, N),
    round(Number * Value) / Value.

%% @fun str转float类型
str_to_float(E) ->
    Str = to_list(E),
    Index = string:str(Str, "."),
    if
        Index > 0 ->
            to_float(Str);
        true ->
            to_float(to_int(Str))
    end.

%% ----------------------------------
%% @doc 	to binary
%% @throws 	none
%% @end
%% ----------------------------------
to_binary(E) when is_binary(E) -> E;
to_binary(E) when is_atom(E) -> list_to_binary(atom_to_list(E));
to_binary(E) when is_list(E) -> list_to_binary(E);
to_binary(E) when is_integer(E) -> list_to_binary(integer_to_list(E));
to_binary(E) when is_float(E) -> E1 = to_list(E), list_to_binary(E1).

%% ----------------------------------
%% @doc 	to atom
%% @throws 	none
%% @end
%% ----------------------------------
to_atom(E) when is_atom(E) -> E;
to_atom(E) when is_integer(E) -> list_to_atom(integer_to_list(E));
to_atom(E) when is_binary(E) -> list_to_atom(binary_to_list(E));
to_atom(E) when is_list(E) -> list_to_atom(E).

%% @fun to tuple
to_tuple(E) when is_tuple(E) -> E;
to_tuple(E) -> E1 = to_list(E), list_to_tuple(E1).

%% ----------------------------------
%% @doc 	进程是否存活
%% @throws 	none
%% @end
%% ----------------------------------
is_pid_alive(RegName) when is_atom(RegName) ->
    erlang:whereis(RegName) =/= undefined;
is_pid_alive(Pid) when node(Pid) =:= node() ->
    erlang:is_process_alive(Pid);
is_pid_alive(Pid) when is_pid(Pid) ->
%%    case lists:member(node(Pid), nodes()) of
%%        false ->
%%            true;
%%        true ->
    case rpc:call(node(Pid), erlang, is_process_alive, [Pid], 500) of
        true ->
            true;
        false ->
            false;
        {badrpc, _Reason} ->
            false
    end.

%% @doc for(Min, Min <= Max, Min + 1)
for(Max, Max, Fun) -> Fun();
for(Min, Max, Fun) -> Fun(), for(Min + 1, Max, Fun).

run(_, 0) ->
    ok;
run(Fun, N) when is_function(Fun) ->
    Fun(),
    run(Fun, N - 1).

sleep(Ms) ->
    receive
    after Ms -> ok
    end.

sleep(Ms, F) when is_function(F) ->
    receive
    after Ms -> F()
    end.


catch_apply(M, F, A) ->
    case catch erlang:apply(M, F, A) of
        {'EXIT', Reason} ->
            logger:error(
                "apply:~n"
                "  {M, F, A} = {~p, ~p, ~p}~n"
                "  Reason    = ~p~n",
                [M, F, A, Reason]
            ),
            {error, Reason};
        Result ->
            Result
    end.
catch_apply(Fun, Args) when is_function(Fun) ->
    case catch erlang:apply(Fun, Args) of
        {'EXIT', Reason} ->
            logger:error(
                "apply:~n"
                "  {Fun, Args} = {~p, ~p}~n"
                "  Reason    = ~p~n",
                [Fun, Args, Reason]
            ),
            {error, Reason};
        Result ->
            Result
    end.

try_catch(Fun) when is_function(Fun) ->
    try Fun()
    catch
        _:Reason ->
            ?ERROR(
                "Try catch ->~n"
                "     reason:~p~n"
                " stacktrace:~p"
                , [Reason, erlang:get_stacktrace()])
    end.

get_boot_value(Args) ->
    {ok, [[Value]]} = init:get_argument(Args),
    Value.

speed_point_2_speed(SpeedPoint) ->
    SpeedPoint / 1000 * 5.

-spec is_robot(PlayerId) -> boolean() when
    PlayerId :: integer().

is_robot(PlayerId) ->
    PlayerId >= 10000.

-spec rpc_call(Node, M, F, A) -> term() when
    Node :: string(),
    M :: module(),
    F :: atom(),
    A :: [term()].

-spec rpc_call(Node, M, F, A, TimeOut) -> term() when
    Node :: string(),
    M :: module(),
    F :: atom(),
    A :: [term()],
    TimeOut :: integer().

rpc_call(Node, M, F, A) ->
    rpc_call(Node, M, F, A, infinity).
rpc_call(Node, M, F, A, TimeOut) ->
    case rpc:call(Node, M, F, A, TimeOut) of
        {badrpc, Reason} ->
            ?ERROR(
                "Rpc call fail=>~n"
                "    node:~p~n"
                "    reason:~p~n"
                "    args:~p~n",
                [Node, Reason, {M, F, A, TimeOut}]),
            {badrpc, Reason};
        Result ->
            Result
    end.


%% 进程字典更新计时器记录   Ref：null不记录
update_timer_value(DictType) ->
    update_timer_value(DictType, null).
update_timer_value(DictType, Ref) ->
    case erase(DictType) of
        undefined ->
            noop;
        TimerRef ->
            erlang:cancel_timer(TimerRef)
    end,
    case Ref of
        null ->
            ok;
        _ ->
            put(DictType, Ref)
    end.


%%get_ip_from(IP) ->
%%    URL = "http://api01.aliyun.venuscn.com/ip?ip=" ++ IP,
%%    Header = [
%%        {"accept", "application/json"},
%%        {"Authorization", "APPCODE c2e0cce458914f92acc90874e49bfc29"}
%%    ],
%%    HTTPOptions = [],
%%    Options = [],
%%    case httpc:request(get, {URL, Header}, HTTPOptions, Options) of
%%        {error, Reason} ->
%%            ?ERROR("获取ip地址错误:~p", [{URL, Reason}]),
%%            {"", "", ""};
%%        {ok, {_A, _B, Result}} ->
%%
%%            Response = jsone:decode(util:to_binary(Result)),
%%            ?DEBUG("~p", [{Response}]),
%%            Ret = maps:get(<<"ret">>, Response),
%%            if Ret == 200 ->
%%                Data = maps:get(<<"data">>, Response),
%%                Country = util:to_list(maps:get(<<"country">>, Data)),
%%                Region = util:to_list(maps:get(<<"region">>, Data)),
%%                City = util:to_list(maps:get(<<"city">>, Data)),
%%                {Country, Region, City};
%%                true ->
%%                    ?ERROR("获取ip地址失败:~p ~n", [Response]),
%%                    {"", "", ""}
%%            end
%%    end.

get_ip_from(IP) ->
    URL = "http://118.25.181.121:7060/ip?ip=" ++ IP,
    Header = [],
    HTTPOptions = [],
    Options = [],
    case httpc:request(get, {URL, Header}, HTTPOptions, Options) of
        {error, Reason} ->
            ?ERROR("获取ip地址错误:~p", [{URL, Reason}]),
            {"", "", ""};
        {ok, {_A, _B, Result}} ->

            Response = jsone:decode(util:to_binary(Result)),
            ?DEBUG("~p", [{Response}]),
            Ret = maps:get(<<"ret">>, Response),
            if Ret == 0 ->
                Data = maps:get(<<"data">>, Response),
                Country = util:to_list(maps:get(<<"country">>, Data)),
                Region = util:to_list(maps:get(<<"region">>, Data)),
                City = util:to_list(maps:get(<<"city">>, Data)),
                {Country, Region, City};
                true ->
                    ?ERROR("获取ip地址失败:~p ~n", [Response]),
                    {"", "", ""}
            end
    end.
%% ----------------------------------
%% @doc 	是否是linux系统
%% @throws 	none
%% @end
%% ----------------------------------
is_linux() ->
    os:type() == {unix, linux}.

finish_line_info() ->
    io:format(" [ok]\n").

%% @doc 	输出信息行
output_line_info(Msg) ->
    output_line_info(Msg, 60).
output_line_info(Msg, Len) ->
    io:format("~s ~s", [Msg, lists:duplicate(max(0, Len - length(Msg)), ".")]).

output_line_info_2(Msg) ->
    output_line_info_2(Msg, 60).
output_line_info_2(Msg, Len) ->
    io:format("~s ~s [ok]\n", [Msg, lists:duplicate(max(0, Len - length(Msg)), ".")]).


%% @doc 字典取值
get_dict(Key) ->
    get_dict(Key, undefined).
get_dict(Key, Default) ->
    case get(Key) of
        undefined ->
            Default;
        Value ->
            Value
    end.