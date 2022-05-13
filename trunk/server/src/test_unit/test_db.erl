-module(test_db).

-compile(export_all).
-include("gen/db.hrl").
-define(DB_TEST, test).
all() ->
    delete_all(),
    test_delete_all(),
    test_delete_all_rollback(),
    test_write(),
    test_write_rollback(),
    test_update(),
    test_update_rollback(),
    test_delete(),
    test_delete_rollback(),
    test_select_delete(),
    test_select_delete_rollback(),
    test_select().

delete_all() ->
    Tran = fun() ->
        db:delete_all(?DB_TEST)
           end,
    db:do(Tran),
    Length = get_count(),
    if Length == 0 ->
        io:format("delete_all success ~n");
        true ->
            io:format("delete_all fail ~n"),
            exit(delete_all_fail)
    end.

test_delete_all() ->
    test_write(),
    test_write(),
    test_write(),
    Tran = fun() ->
        db:delete_all(?DB_TEST)
           end,
    db:do(Tran),
    Length = get_count(),
    if Length == 0 ->
        io:format("test_delete_all success ~n");
        true ->
            io:format("test_delete_all fail ~n"),
            exit(test_delete_all_fail)
    end.

get_count() ->
    length(db:select(?DB_TEST, [{#db_test{_ = '_'}, [], ['$_']}])).

test_delete_all_rollback() ->
    delete_all(),
    test_write(),
    test_write(),
    test_write(),
    3 = get_count(),
    Tran = fun() ->
        db:delete_all(?DB_TEST),
        exit(1)
           end,
    catch db:do(Tran),
    Length = get_count(),
    if Length == 3 ->
        io:format("test_delete_all_rollback success ~n");
        true ->
            io:format("test_delete_all_rollback fail ~n"),
            exit(test_delete_all_rollback_fail)
    end.

test_write() ->
    Num = util_time:timestamp(),
    Str = "test",
    Tran = fun() ->
        db:write(#db_test{num = Num, str = Str})
           end,
    R =  db:do(Tran),
    case db:read(#key_test{id = R#db_test.id}) of
        null ->
            io:format("test_write fail ~n"),
            exit(test_write_fail);
        _ ->
            io:format("test_write success ~n")
    end,
    R.

test_write_rollback() ->
    Num = util_time:timestamp(),
    Str = "test",
    Tran = fun() ->
        R0 = db:write(#db_test{num = Num, str = Str}),
        put(test_write_rollback, R0),
        exit(1)
           end,
    catch db:do(Tran),
    R = get(test_write_rollback),
    case db:read(#key_test{id = R#db_test.id}) of
        null ->
            io:format("test_write_rollback success ~n");
        _ ->
            io:format("test_write_rollback fail ~n"),
            exit(test_write_rollback_fail)
    end,
    R.


test_update() ->
    R0 = test_write(),
    Num = util_time:timestamp(),
    Str = "test1",
    Tran = fun() ->
        db:write(R0#db_test{num = Num, str = Str})
           end,
    R =  db:do(Tran),
    case db:read(#key_test{id = R#db_test.id}) of
        #db_test{num = Num, str = Str} ->
            io:format("test_update success ~n");
        _ ->
            io:format("test_update fail ~n"),
            exit(test_update_fail)
    end.

test_update_rollback() ->
    R0 = test_write(),
    Num = util_time:timestamp(),
    Str = "test1",
    Tran = fun() ->
        db:write(R0#db_test{num = Num, str = Str}),
        exit(1)
           end,
    catch db:do(Tran),
    case db:read(#key_test{id = R0#db_test.id}) of
        R0 ->
            io:format("test_update_rollback success ~n");
        _ ->
            io:format("test_update_rollback fail ~n"),
            exit(test_update_rollback_fail)
    end.

test_delete() ->
    R = test_write(),
    Tran = fun() ->
        db:delete(R)
           end,
    db:do(Tran),
    case db:read(#key_test{id = R#db_test.id}) of
        null ->
            io:format("test_delete success ~n");
        _ ->
            io:format("test_delete fail ~n"),
            exit(test_delete_fail)
    end.

test_delete_rollback() ->
    R = test_write(),
    Tran = fun() ->
        db:delete(R),
        exit(1)
           end,
    catch db:do(Tran),
    case db:read(#key_test{id = R#db_test.id}) of
        null ->
            io:format("test_delete_rollback fail ~n"),
            exit(test_delete_rollback_fail);
        _ ->
            io:format("test_delete_rollback success ~n")
    end.

test_select_delete() ->
    R = test_write(),
    Tran = fun() ->
        db:select_delete(?DB_TEST, [{#db_test{id = R#db_test.id, _ = '_'}, [], ['$_']}])
           end,
    db:do(Tran),
    case db:read(#key_test{id = R#db_test.id}) of
        null ->
            io:format("test_select_delete success ~n");
        _ ->
            io:format("test_select_delete fail ~n"),
            exit(test_select_delete_fail)
    end.

test_select_delete_rollback() ->
    R = test_write(),
    Tran = fun() ->
        db:select_delete(?DB_TEST, [{#db_test{id = R#db_test.id, _ = '_'}, [], ['$_']}]),
        exit(1)
           end,
    catch db:do(Tran),
    case db:read(#key_test{id = R#db_test.id}) of
        null ->
            io:format("test_select_delete_rollback fail ~n"),
            exit(test_select_delete_rollback_fail);
        _ ->
            io:format("test_select_delete_rollback success ~n")
    end.

test_select() ->
    R = test_write(),
    Tran = fun() ->
        db:select(?DB_TEST, [{#db_test{id = R#db_test.id, _ = '_'}, [], ['$_']}])
           end,
    [R1] = db:do(Tran),
%%    io:format("~p~n", [{R, R1}]),
    if R =/=R1 ->
            io:format("test_select fail ~n"),
            exit(test_select_fail);
        true ->
            io:format("test_select success ~n")
    end.
