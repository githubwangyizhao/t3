%%%-------------------------------------------------------------------
%%% @author     home
%%% @copyright (C) 2017, GAME_HOME
%%% @doc        邮件进程
%%% @end
%%% Created : 23. 九月 2017 10:08
%%%-------------------------------------------------------------------
-module(mail_srv).

%% API
-export([
    start_link/0,
    init/1,
    handle_call/3,
    handle_cast/2,
    handle_info/2,
    terminate/2
]).

-export([
    call/1,
    cast/1,
    cast/2
]).

-include("common.hrl").

-record(state, {}).

-define(RANK_REFRESH_TIME, {3, 0, 0}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_) ->
    CurrTime = util_time:timestamp(),
    CalcTime = util_time:get_today_timestamp(?RANK_REFRESH_TIME),
    RefreshTime =
        if
            CurrTime > CalcTime ->
                CurrTime - CalcTime;
            true ->
                CalcTime + ?DAY_S - CurrTime
        end,
    erlang:send_after(RefreshTime * ?SECOND_MS, self(), rank_refresh_time),
    {ok, #state{}}.

call(Request) ->
    gen_server:call(?MODULE, Request).

cast(Request) ->
    gen_server:cast(?MODULE, Request).
cast(Node, Request) ->
    rpc:cast(Node, gen_server, cast, [?MODULE, Request]).
%%    gen_server:cast({?MODULE, Node}, Request).

handle_call(_, _From, State) ->
    {reply, State, State}.

% 增加邮件
handle_cast({srv_add_mail, Param}, State) ->
    ?TRY_CATCH(mail_srv_mod:srv_add_mail(Param)),
    {noreply, State};
handle_cast({srv_add_gift_mail, Param}, State) ->
    ?TRY_CATCH(gift_mail:srv_add_mail(Param)),
    {noreply, State};
handle_cast(_Request, State) ->
    {noreply, State}.

handle_info(rank_refresh_time, State) ->
    ?INFO("定时清除邮件 ~p~n", [util_time:local_datetime()]),
    ?TRY_CATCH(mail_srv_mod:srv_clear_old_mail()),
    erlang:send_after(?DAY_MS, self(), rank_refresh_time),
    {noreply, State};
handle_info(_, State) ->
    {noreply, State}.

terminate(_, State) ->
    State.
