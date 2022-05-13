%%反编译
-module(decompile).

%% API
-export([
    start/1
]).

start(Module) when is_atom(Module)->
	start(Module, erlang:atom_to_list(Module) ++ ".erl").
start(Module, ToFile) when is_atom(Module)->
	case beam_lib:chunks(code:which(Module), [abstract_code]) of
    	{ok,{_,[{abstract_code,{_,Data}}]}} ->
    		SourceCode = erl_prettypr:format(erl_syntax:form_list(Data)),
    		file:write_file(ToFile, SourceCode),
    		io:format("Decompile successed ~n  =>~p~n", [ToFile]);
    	{ok,{_,[{abstract_code,no_abstract_code}]}} ->
    		io:format("Decompile failed!!!~n");
    	{error,beam_lib,{file_error,"non_existing.beam",enoent}} ->
    		io:format("File no existed!!!~n")
    end.


