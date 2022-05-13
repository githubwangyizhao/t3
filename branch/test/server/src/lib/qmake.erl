%% The MIT License (MIT)
%%
%% Copyright (c) 2016
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in all
%% copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%% SOFTWARE.

%% An Erlang Multi-process compile tool
%% Based on make.erl and mmake.erl
%% Node: The thread number of CPU maybe the best worker num
-module(qmake).
-export([main/1, all/0,all/1, all/2, files/2, files/3, compilep/3]).

-include_lib("kernel/include/file.hrl").

-define(MakeOpts,[noexec,load,netload,noload]).

main(_) ->
    all().
all() ->
    Worker = erlang:system_info(schedulers),
    all(Worker).
all(Worker) when is_integer(Worker) ->
    all(Worker, []).

all(Worker, Options) when is_integer(Worker) ->
    {MakeOpts, CompileOpts} = sort_options(Options,[],[]),
    case read_emakefile('Emakefile', CompileOpts) of
        Files when is_list(Files) ->
            do_make_files(Worker, Files, MakeOpts);
        error ->
            error
    end.

files(Worker, Fs) ->
    files(Worker, Fs, []).

files(Worker, Fs0, Options) ->
    Fs = [filename:rootname(F,".erl") || F <- Fs0],
    {MakeOpts,CompileOpts} = sort_options(Options,[],[]),
    case get_opts_from_emakefile(Fs,'Emakefile',CompileOpts) of
	Files when is_list(Files) ->
	    do_make_files(Worker, Files,MakeOpts);
	error -> error
    end.

do_make_files(Worker, Fs, Opts) ->
    process(Fs, Worker, lists:member(noexec, Opts), load_opt(Opts)).

sort_options([H|T],Make,Comp) ->
    case lists:member(H,?MakeOpts) of
	true ->
	    sort_options(T,[H|Make],Comp);
	false ->
	    sort_options(T,Make,[H|Comp])
    end;
sort_options([],Make,Comp) ->
    {Make,lists:reverse(Comp)}.

%%% Reads the given Emakefile and returns a list of tuples: {Mods,Opts}
%%% Mods is a list of module names (strings)
%%% Opts is a list of options to be used when compiling Mods
%%%
%%% Emakefile can contain elements like this:
%%% Mod.
%%% {Mod,Opts}.
%%% Mod is a module name which might include '*' as wildcard
%%% or a list of such module names
%%%
%%% These elements are converted to [{ModList,OptList},...]
%%% ModList is a list of modulenames (strings)
read_emakefile(Emakefile,Opts) ->
    case file:consult(Emakefile) of
	{ok, Emake} ->
	    transform(Emake,Opts,[],[]);
	{error,enoent} ->
	    %% No Emakefile found - return all modules in current
	    %% directory and the options given at command line
	    Mods = [filename:rootname(F) ||  F <- filelib:wildcard("*.erl")],
	    [{Mods, Opts}];
	{error,Other} ->
	    io:format("make: Trouble reading 'Emakefile':~n~p~n",[Other]),
	    error
    end.

transform([{Mod,ModOpts}|Emake],Opts,Files,Already) ->
    case expand(Mod,Already) of
	[] ->
	    transform(Emake,Opts,Files,Already);
	Mods ->
	    transform(Emake,Opts,[{Mods,ModOpts++Opts}|Files],Mods++Already)
    end;
transform([Mod|Emake],Opts,Files,Already) ->
    case expand(Mod,Already) of
	[] ->
	    transform(Emake,Opts,Files,Already);
	Mods ->
	    transform(Emake,Opts,[{Mods,Opts}|Files],Mods++Already)
    end;
transform([],_Opts,Files,_Already) ->
    lists:reverse(Files).

expand(Mod,Already) when is_atom(Mod) ->
    expand(atom_to_list(Mod),Already);
expand(Mods,Already) when is_list(Mods), not is_integer(hd(Mods)) ->
    lists:concat([expand(Mod,Already) || Mod <- Mods]);
expand(Mod,Already) ->
    case lists:member($*,Mod) of
	true ->
	    Fun = fun(F,Acc) ->
			  M = filename:rootname(F),
			  case lists:member(M,Already) of
			      true -> Acc;
			      false -> [M|Acc]
			  end
		  end,
	    lists:foldl(Fun, [], filelib:wildcard(Mod++".erl"));
	false ->
	    Mod2 = filename:rootname(Mod, ".erl"),
	    case lists:member(Mod2,Already) of
		true -> [];
		false -> [Mod2]
	    end
    end.

%%% Reads the given Emakefile to see if there are any specific compile
%%% options given for the modules.
get_opts_from_emakefile(Mods,Emakefile,Opts) ->
    case file:consult(Emakefile) of
	{ok,Emake} ->
	    Modsandopts = transform(Emake,Opts,[],[]),
	    ModStrings = [coerce_2_list(M) || M <- Mods],
	    get_opts_from_emakefile2(Modsandopts,ModStrings,Opts,[]);
	{error,enoent} ->
	    [{Mods, Opts}];
	{error,Other} ->
	    io:format("make: Trouble reading 'Emakefile':~n~p~n",[Other]),
	    error
    end.

get_opts_from_emakefile2([{MakefileMods,O}|Rest],Mods,Opts,Result) ->
    case members(Mods,MakefileMods,[],Mods) of
	{[],_} ->
	    get_opts_from_emakefile2(Rest,Mods,Opts,Result);
	{I,RestOfMods} ->
	    get_opts_from_emakefile2(Rest,RestOfMods,Opts,[{I,O}|Result])
    end;
get_opts_from_emakefile2([],[],_Opts,Result) ->
    Result;
get_opts_from_emakefile2([],RestOfMods,Opts,Result) ->
    [{RestOfMods,Opts}|Result].

members([H|T],MakefileMods,I,Rest) ->
    case lists:member(H,MakefileMods) of
	true ->
	    members(T,MakefileMods,[H|I],lists:delete(H,Rest));
	false ->
	    members(T,MakefileMods,I,Rest)
    end;
members([],_MakefileMods,I,Rest) ->
    {I,Rest}.


%% Any flags that are not recognixed as make flags are passed directly
%% to the compiler.
%% So for example make:all([load,debug_info]) will make everything
%% with the debug_info flag and load it.
load_opt(Opts) ->
    case lists:member(netload,Opts) of
	true ->
	    netload;
	false ->
	    case lists:member(load,Opts) of
		true ->
		    load;
		_ ->
		    noload
	    end
    end.

process([{[], _Opts}|Rest], Worker, NoExec, Load) ->
    process(Rest, Worker, NoExec, Load);
process([{Fs, Opts}|Rest], Worker, NoExec, Load) ->
    Len = length(Fs),
    Worker2 = erlang:min(Len, Worker),
    case catch do_worker(Fs, Opts, NoExec, Load, Worker2) of
        error ->
            error;
        ok ->
            process(Rest, Worker, NoExec, Load)
    end;
process([], _Worker, _NoExec, _Load) ->
    up_to_date.

do_worker(L, Opts, NoExec, Load, Worker) ->
    Ref = make_ref(),
    Self = self(),
    Pids = [
        spawn_link(fun() -> worker_proc(Opts, NoExec, Load, Self, Ref) end)
        || _N <- lists:seq(1, Worker)],
    io:format("Starting bulid ~p files...~n", [length(L)]),
    {_, S, _} = os:timestamp(),
    put(start_second, S),
    put(file_num, length(L)),
    L1 = init_start(L, Pids),
    worker_mamager(L1, Worker, Ref).

init_start(Fs, []) ->
    Fs;
init_start([F|Fs], [P|Ps]) ->
    P ! {do_compile, F},
    init_start(Fs, Ps).

handle_error(File) ->
    FileName = filename:basename(File),
    io:format(
        "~n~n"
        "*************************************************************~n~n"
        "                 Error in file: ~s                        ~n~n"
        "*************************************************************~n~n",
        [FileName]).

worker_mamager([], 0, _Ref) ->
    {_, S, _} = os:timestamp(),
    S1 = S - get(start_second),
    io:format(
        "~n~n"
        "*************************************************************~n~n"
        "                        All finished                          ~n"
        "           Built ~p files, used ~p minute, ~p second         ~n~n"
        "*************************************************************~n~n",
        [get(file_num), S1 div 60, S1 rem 60]
    );
worker_mamager([], N, Ref) ->
    receive
        {do_finish, P, Ref} ->
            P ! all_finish,
            worker_mamager([], N, Ref);
        {error,File, Ref} ->
            handle_error(File),
            halt(1);
        {'EXIT', _P, normal} ->
            worker_mamager([], N - 1, Ref);
        _Other ->
            io:format("receive unknown msg:~p~n", [_Other]),
            halt(1)
    end;
worker_mamager([H|T], N, Ref) ->
    receive
        {do_finish, Pid, Ref} ->
            Pid ! {do_compile, H},
            worker_mamager(T, N, Ref);
        {error, File, Ref} ->
            handle_error(File),
            halt(1);
        _Other ->
            io:format("receive unknown msg:~p~n", [_Other]),
            halt(1)
    end.

worker_proc(Opts, NoExec, Load, Parent, Ref) ->
    receive
        {do_compile, File} ->
            case recompilep(coerce_2_list(File), NoExec, Load, Opts) of
                error ->
                    Parent ! {error,File,Ref},
                    exit(error);
                _ ->
                    Parent ! {do_finish, self(), Ref},
                    worker_proc(Opts, NoExec, Load, Parent, Ref)
            end;
        all_finish ->
            ok;
        _Other ->
            io:format("receive unknown msg:~p~n", [_Other]),
            throw(error)
    end.

%% Compile when last
-ifdef(debug).
compilep(File, IncludePath, OutDir) ->
    case recompilep(File, false, noload, [{i, IncludePath}, {outdir, OutDir}, {d, debug}] ) of
        error ->
            io:format("~n[ERROR] Compile fail:~p  !!!!!!!!!!!!!!!!!!~n~n", [File]),
            halt(1);
        _ ->
            noop
    end.
-else.
compilep(File, IncludePath, OutDir) ->
    case recompilep(File, false, noload, [{i, IncludePath}, {outdir, OutDir}] ) of
        error ->
            io:format("~n[ERROR] Compile fail:~p  !!!!!!!!!!!!!!!!!!~n~n", [File]),
            halt(1);
        _ ->
            noop
    end.
-endif.



recompilep(FileTemp, NoExec, Load, Opts) ->
    File = filename:rootname(FileTemp, ".erl"),
    ObjName = lists:append(filename:basename(File),
        code:objfile_extension()),
    ObjFile = case lists:keysearch(outdir, 1, Opts) of
                  {value, {outdir, OutDir}} ->
                      filename:join(coerce_2_list(OutDir), ObjName);
                  false ->
		      ObjName
	      end,
    case file:read_file_info(ObjFile) of
        {ok, Obj} ->
            recompilep1(File, NoExec, Load, Opts, Obj);
        _ ->
            recompile(File, NoExec, Load, Opts)
    end.

recompilep1(File, NoExec, Load, Opts, Obj) ->
    {ok, Erl} = file:read_file_info(lists:append(File, ".erl")),
	 recompilep1(Erl, Obj, File, NoExec, Load, Opts).
recompilep1(#file_info{mtime=Te},
	    #file_info{mtime=To}, File, NoExec, Load, Opts) when Te>To ->
    recompile(File, NoExec, Load, Opts);
recompilep1(_Erl, #file_info{mtime=To}, File, NoExec, Load, Opts) ->
    recompile2(To, File, NoExec, Load, Opts).

%% recompile2(ObjMTime, File, NoExec, Load, Opts)
%% Check if file is of a later date than include files.
recompile2(ObjMTime, File, NoExec, Load, Opts) ->
    IncludePath = include_opt(Opts),
    case check_includes(lists:append(File, ".erl"), IncludePath, ObjMTime) of
	true ->
	    recompile(File, NoExec, Load, Opts);
	false ->
	    false
    end.

include_opt([{i,Path}|Rest]) ->
    [Path|include_opt(Rest)];
include_opt([_First|Rest]) ->
    include_opt(Rest);
include_opt([]) ->
    [].

%% recompile(File, NoExec, Load, Opts)
%% Actually recompile and load the file, depending on the flags.
%% Where load can be netload | load | noload

recompile(File, true, _Load, _Opts) ->
    io:format("Out of date: ~ts\n",[File]);
recompile(File, false, noload, Opts) ->
    io:format("Recompile: ~ts\n",[File]),
    compile:file(File, [report_errors, report_warnings, error_summary |Opts]);
recompile(File, false, load, Opts) ->
    io:format("Recompile: ~ts\n",[File]),
    c:c(File, Opts);
recompile(File, false, netload, Opts) ->
    io:format("Recompile: ~ts\n",[File]),
    c:nc(File, Opts).

coerce_2_list(X) when is_atom(X) ->
    atom_to_list(X);
coerce_2_list(X) ->
    X.

%%% If you an include file is found with a modification
%%% time larger than the modification time of the object
%%% file, return true. Otherwise return false.
check_includes(File, IncludePath, ObjMTime) ->
    Path = [filename:dirname(File)|IncludePath],
    case epp:open(File, Path, []) of
	{ok, Epp} ->
	    check_includes2(Epp, File, ObjMTime);
	_Error ->
	    false
    end.

get_incfile_info(IncFile) ->
    case get({incfile, IncFile}) of
        undefined ->
            FileInfo = file:read_file_info(IncFile),
            put({incfile, IncFile}, FileInfo),
            FileInfo;
        FileInfo ->
            FileInfo
    end.

check_includes2(Epp, File, ObjMTime) ->
    case epp:parse_erl_form(Epp) of
	{ok, {attribute, 1, file, {File, 1}}} ->
	    check_includes2(Epp, File, ObjMTime);
	{ok, {attribute, 1, file, {IncFile, 1}}} ->
	    case get_incfile_info(IncFile) of
		{ok, #file_info{mtime=MTime}} when MTime>ObjMTime ->
		    epp:close(Epp),
		    true;
		_ ->
		    check_includes2(Epp, File, ObjMTime)
	    end;
	{ok, _} ->
	    check_includes2(Epp, File, ObjMTime);
	{eof, _} ->
	    epp:close(Epp),
	    false;
	{error, _Error} ->
	    check_includes2(Epp, File, ObjMTime)
    end.
