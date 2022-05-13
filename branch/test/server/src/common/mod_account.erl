%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            帐号模块
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(mod_account).
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").

%% API
-export([
    try_init_account/2,
    get_account/2,
    try_record_enter_game/2,
    try_record_create_role/3,
    try_record_finish_firsh_task/2
]).
-export([
    add_test_account/2          %% 添加测试账号至中心服ets(ets_test_account)
]).
-export([
    is_valid_account/1
]).

add_test_account(Account, IsPrivilege) ->
    ets:insert(?ETS_TEST_ACCOUNT, #ets_test_account{account = Account, privilege = IsPrivilege}).

get_account(AccId, Sid) ->
    db:read(#key_account{acc_id = AccId, server_id = Sid}).

%% ----------------------------------
%% @doc 	初始化帐号
%% @throws 	none
%% @end
%% ----------------------------------
try_init_account(AccId, Sid) ->
    case get_account(AccId, Sid) of
        null ->
            Tran = fun() ->
                db:write(#db_account{
                    acc_id = AccId,
                    server_id = Sid,
                    is_create_role = ?FALSE,
                    is_enter_game = ?FALSE,
                    is_finish_first_task = ?FALSE,
                    time = util_time:timestamp(),
                    player_id = 0,
                    channel = mod_player:'_get_player_channel'()
                })
                   end,
            db:do(Tran);
        _ ->
            noop
    end.

%% ----------------------------------
%% @doc 	记录帐号进入游戏
%% @throws 	none
%% @end
%% ----------------------------------
try_record_enter_game(AccId, Sid) ->
    Account = get_account(AccId, Sid),
    if Account#db_account.is_enter_game == ?FALSE ->
        Tran = fun() ->
            db:write(Account#db_account{
                is_enter_game = ?TRUE
            })
               end,
        db:do(Tran);
        true ->
            noop
    end.
%% ----------------------------------
%% @doc 	记录帐号创角
%% @throws 	none
%% @end
%% ----------------------------------
try_record_create_role(AccId, Sid, PlayerId) ->
    Account = get_account(AccId, Sid),
    if Account#db_account.is_create_role == ?FALSE ->
        Tran = fun() ->
            db:write(Account#db_account{
                is_create_role = ?TRUE,
                player_id = PlayerId
            })
               end,
        db:do(Tran);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	记录帐号完成第一个任务
%% @throws 	none
%% @end
%% ----------------------------------
try_record_finish_firsh_task(AccId, Sid) ->
    Account = get_account(AccId, Sid),
    if Account#db_account.is_finish_first_task == ?FALSE ->
        Tran = fun() ->
            db:write(Account#db_account{
                is_finish_first_task = ?TRUE
            })
               end,
        db:do(Tran);
        true ->
            noop
    end.

%% ----------------------------------
%% @doc 	记录账号为一个有效玩家
%% @throws 	none
%% @end
%% ----------------------------------
is_valid_account(PlayerId) ->
    Now = util_time:timestamp(),
    CostList = get('game_cost'),
    #db_player{
        acc_id = AccId,
        server_id = Sid,
        last_login_time = LastLoginTime
    } = mod_player:get_player(PlayerId),
    ConditionTupleList = [{online_time, 5 * 60}, {cost_gold, 6000}],
    CondList =
        lists:filtermap(
            fun({Type, Value}) ->
                case Type of
                    online_time -> ?IF(Now - LastLoginTime >= Value, {true, Type}, false);
                    cost_gold ->
                        TotalCost = lists:sum([?IF(Type =:= ?ITEM_GOLD, Val, 0) || [Type, Val] <- CostList]),
                        ?IF(TotalCost >= Value, {true, Type}, false)
                end
            end,
            ConditionTupleList
        ),
    CondListAfterSort = lists:sort(CondList),
    MatchListAfterSort = lists:sort([CondAtom || {CondAtom, _} <- ConditionTupleList]),
    Account = get_account(AccId, Sid),
    if Account#db_account.is_finish_first_task == ?FALSE andalso CondListAfterSort =:= MatchListAfterSort ->
        Tran = fun() ->
            db:write(Account#db_account{
                is_finish_first_task = ?TRUE
            })
               end,
        db:do(Tran);
        true ->
            noop
    end.

