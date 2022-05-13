-module(benchmark).

-compile(export_all).
-include("gen/db.hrl").
-include("benchmarks.hrl").
-include("common.hrl").

%% 10000 CPU: 0.59, Program :1.61 seconds
mysql_write(N) ->
    ?START_RECORD,
    Now = util_time:timestamp(),
    util:run(
        fun() ->
            Num = erlang:integer_to_binary(N + Now),
            Str = erlang:list_to_binary("123456"),
            SQL = <<
                "INSERT INTO `test` SET "
                " `num` = ", Num/binary,
                " ,`str` = ", Str/binary,
                ";\n"
            >>,
            {updated, _} = mysql:fetch(game_db, SQL)
        end,
        N
    ),
    ?STOP_RECORD,
    {data, Res} = mysql:fetch(game_db, "select count(1) from test;"),
    [[RowNum]] = lib_mysql:get_rows(Res),
    io:format("MYSQL Table rows:~p~n", [RowNum]).


%% 10000000  CPU: 9.922, Program :10.328 seconds
ets_write(N) ->
    L = lists:seq(1, N),
    Tid = ets:new(test, [set, public, {keypos, 1}]),
    ?START_RECORD,
    lists:foreach(
        fun(N1) ->
            ets:insert(Tid, {N1, "1234"})
        end,
        L
    ),
    ?STOP_RECORD.

%% CPU: 9.922, Program :10.328 seconds
%%game_db_dirty_write(N) ->
%%    ?START_RECORD,
%%    util:run(
%%        fun() ->
%%            game_db:dirty_write(
%%                #player_ingot_log{
%%                    player_id = 11111,
%%                    op_type = 11111,
%%                    op_time = 11111,
%%                    change_value = 11111,
%%                    new_value = 11111
%%                }
%%            )
%%        end,
%%        N
%%    ),
%%    ?STOP_RECORD.

game_db_tran_write(N) ->
    ?START_RECORD,
    util:run(
        fun() ->
            Tran =
                fun() ->
                    db:write(#db_test{
                        num = 9999,
                        str = "88888"
                    })
                end,
            db:do(Tran)
        end,
        N
    ),
    ?STOP_RECORD.
