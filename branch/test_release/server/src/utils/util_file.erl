%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2018, THYZ
%%% @doc
%%% @end
%%% Created : 02. 一月 2018 下午 2:02
%%%-------------------------------------------------------------------
-module(util_file).

-include("common.hrl").
%% API
-export([
    save/2,
    write/2,        %% 文件写入
    load_term/1,
    save_term/2,
    ensure_dir/1,
    save_code/2,
    save_code/3
]).

%% ----------------------------------
%% @doc 	写文本到文件
%% @throws 	none
%% @end
%% ----------------------------------
save(File, Text) ->
    ensure_dir(File),
    {ok, Fp} = file:open(File, [write]),
    ok = file:write(Fp, Text),
    file:close(Fp).



%% ----------------------------------
%% @doc     从文件中加载erlang term
%% @throws 	none
%% @end
%% ----------------------------------
load_term(File) ->
    case file:consult(File) of
        {error, Reason} -> error({File, Reason});
        {ok, []} -> [];
        {ok, [Term]} -> Term
    end.

%% ----------------------------------
%% @doc 	将term写入文件
%% @throws 	none
%% @end
%% ----------------------------------
save_term(File, Term) ->
    case file:open(File, [write]) of
        {error, Reason} -> {error, Reason};
        {ok, F} ->
            io:format(F, "~p.", [Term]),
            file:close(F),
            ok
    end.

%% ----------------------------------
%% @doc 	确保目录存在
%% @throws 	none
%% @end
%% ----------------------------------
ensure_dir(Dir) ->
    filelib:ensure_dir(Dir).

%% 文件写入
write(File, Text) ->
    ok = file:write(File, Text).

%% ----------------------------------
%% @doc 	尝试保存code, 和编译
%% @throws 	none
%% @end
%% ----------------------------------
save_code(FileName, Out) ->
    save_code(FileName, Out, false).
save_code(FileName, Out, IsCompile) ->
    ensure_dir(FileName),
    F =
        fun() ->
            {ok, File} = file:open(FileName, [write]),
            ok = file:write(File, Out),
            file:close(File),
            if IsCompile ->
                qmake:compilep(FileName, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH);
                true ->
                    noop
            end,
            ok
        end,
    case file:read_file(FileName) of
        {ok, FileData} ->
            case string:equal(binary_to_list(FileData), Out) of
                %% code 没有变化
                true -> ignore;
                _ -> F()
            end;
        _ -> F()
    end.
