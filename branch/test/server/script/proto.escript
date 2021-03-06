%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(proto).

%% API
-export([main/1]).
main(Argv) ->
    setup_code_path(),
    case gpb_compile:parse_opts_and_args(Argv) of
        {ok, {Opts, Files}} ->
            gpb_compile:c(Opts, Files); %% will halt
        {error, Reason} ->
            io:format("Error: ~s.~n", [Reason]),
            show_usage(),
            halt(1)
    end.

setup_code_path() ->
    ScriptName = escript:script_name(),
    %% check symbolic link
    RawFile = find_raw_file(ScriptName),

    BinDir = filename:dirname(RawFile),
    EBinDir = filename:join([BinDir, "..", "ebin"]),
    %% add the gpb ebin path to we can have access to gpb_compile
    true = code:add_pathz(EBinDir).

find_raw_file(Name) ->
    find_raw_file(Name, file:read_link(Name)).

find_raw_file(Name, {error, _}) ->
    Name;

find_raw_file(Name, {ok, Name1}) ->
    %% for relative symbolic link
    %% if Name1 is absolute, then AbsoluteName is Name1
    DirName = filename:dirname(Name),
    AbsoluteName = filename:join(DirName, Name1),
    find_raw_file(AbsoluteName, file:read_link(AbsoluteName)).

show_usage() ->
    io:format("usage: ~s [options] X.proto [...]~n",
              [filename:basename(escript:script_name())]),
    gpb_compile:show_args().
