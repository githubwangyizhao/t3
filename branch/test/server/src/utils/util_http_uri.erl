%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 13. 八月 2018 12:32
%%%-------------------------------------------------------------------
-module(util_http_uri).
-author("home").

-export([parse/1, parse/2,
    scheme_defaults/0,
    encode/1, decode/1]).

-export_type([scheme/0, default_scheme_port_number/0]).


%%%=========================================================================
%%%  API
%%%=========================================================================

-type scheme() :: atom().
-type default_scheme_port_number() :: pos_integer().

-spec scheme_defaults() ->
    [{scheme(), default_scheme_port_number()}].

scheme_defaults() ->
    [{http,  80},
        {https, 443},
        {ftp,   21},
        {ssh,   22},
        {sftp,  22},
        {tftp,  69}].

parse(AbsURI) ->
    parse(AbsURI, []).

parse(AbsURI, Opts) ->
    case parse_scheme(AbsURI, Opts) of
        {error, Reason} ->
            {error, Reason};
        {Scheme, DefaultPort, Rest} ->
            case (catch parse_uri_rest(Scheme, DefaultPort, Rest, Opts)) of
                {ok, Result} ->
                    {ok, Result};
                {error, Reason} ->
                    {error, {Reason, Scheme, AbsURI}};
                _  ->
                    {error, {malformed_url, Scheme, AbsURI}}
            end
    end.

reserved() ->
    sets:from_list([$:, $@, $&, $=, $+, $,, $/, $?,
        $#, $[, $], $<, $>, $\", ${, $}, $|, %"
        $\\, $', $^]).

encode(URI) when is_list(URI) ->
    Reserved = reserved(),
    lists:append([uri_encode(Char, Reserved) || Char <- URI]);
encode(URI) when is_binary(URI) ->
    Reserved = reserved(),
    << <<(uri_encode_binary(Char, Reserved))/binary>> || <<Char>> <= URI >>.

decode(String) when is_list(String) ->
    do_decode(String);
decode(String) when is_binary(String) ->
    do_decode_binary(String).

do_decode([$%,Hex1,Hex2|Rest]) ->
    [hex2dec(Hex1)*16+hex2dec(Hex2)|do_decode(Rest)];
do_decode([First|Rest]) ->
    [First|do_decode(Rest)];
do_decode([]) ->
    [].

do_decode_binary(<<$%, Hex:2/binary, Rest/bits>>) ->
    <<(binary_to_integer(Hex, 16)), (do_decode_binary(Rest))/binary>>;
do_decode_binary(<<First:1/binary, Rest/bits>>) ->
    <<First/binary, (do_decode_binary(Rest))/binary>>;
do_decode_binary(<<>>) ->
    <<>>.

%%%========================================================================
%%% Internal functions
%%%========================================================================

which_scheme_defaults(Opts) ->
    Key = scheme_defaults,
    case lists:keysearch(Key, 1, Opts) of
        {value, {Key, SchemeDefaults}} ->
            SchemeDefaults;
        false ->
            scheme_defaults()
    end.

parse_scheme(AbsURI, Opts) ->
    case split_uri(AbsURI, ":", {error, no_scheme}, 1, 1) of
        {error, no_scheme} ->
            {error, no_scheme};
        {SchemeStr, Rest} ->
            case extract_scheme(SchemeStr, Opts) of
                {error, Error} ->
                    {error, Error};
                {ok, Scheme} ->
                    SchemeDefaults = which_scheme_defaults(Opts),
                    case lists:keysearch(Scheme, 1, SchemeDefaults) of
                        {value, {Scheme, DefaultPort}} ->
                            {Scheme, DefaultPort, Rest};
                        false ->
                            {Scheme, no_default_port, Rest}
                    end
            end
    end.

extract_scheme(Str, Opts) ->
    case lists:keysearch(scheme_validation_fun, 1, Opts) of
        {value, {scheme_validation_fun, Fun}} when is_function(Fun) ->
            case Fun(Str) of
                valid ->
                    {ok, list_to_atom(http_util:to_lower(Str))};
                {error, Error} ->
                    {error, Error}
            end;
        _ ->
            {ok, to_atom(http_util:to_lower(Str))}
    end.

to_atom(S) when is_list(S) ->
    list_to_atom(S);
to_atom(S) when is_binary(S) ->
    binary_to_atom(S, unicode).

parse_uri_rest(Scheme, DefaultPort, <<"//", URIPart/binary>>, Opts) ->
    {Authority, PathQueryFragment} =
        split_uri(URIPart, "[/?#]", {URIPart, <<"">>}, 1, 0),
    {RawPath, QueryFragment} =
        split_uri(PathQueryFragment, "[?#]", {PathQueryFragment, <<"">>}, 1, 0),
    {Query, Fragment} =
        split_uri(QueryFragment, "#", {QueryFragment, <<"">>}, 1, 0),
    {UserInfo, HostPort} = split_uri(Authority, "@", {<<"">>, Authority}, 1, 1),
    {Host, Port}         = parse_host_port(Scheme, DefaultPort, HostPort, Opts),
    Path                 = path(RawPath),
    case lists:keyfind(fragment, 1, Opts) of
        {fragment, true} ->
            {ok, {Scheme, UserInfo, Host, Port, Path, Query, Fragment}};
        _ ->
            {ok, {Scheme, UserInfo, Host, Port, Path, Query}}
    end;
parse_uri_rest(Scheme, DefaultPort, "//" ++ URIPart, Opts) ->
    {Authority, PathQueryFragment} =
        split_uri(URIPart, "[/?#]", {URIPart, ""}, 1, 0),
    {RawPath, QueryFragment} =
        split_uri(PathQueryFragment, "[?#]", {PathQueryFragment, ""}, 1, 0),
    {Query, Fragment} =
        split_uri(QueryFragment, "#", {QueryFragment, ""}, 1, 0),
    {UserInfo, HostPort} = split_uri(Authority, "@", {"", Authority}, 1, 1),
    {Host, Port}         = parse_host_port(Scheme, DefaultPort, HostPort, Opts),
    Path                 = path(RawPath),
    case lists:keyfind(fragment, 1, Opts) of
        {fragment, true} ->
            {ok, {Scheme, UserInfo, Host, Port, Path, Query, Fragment}};
        _ ->
            {ok, {Scheme, UserInfo, Host, Port, Path, Query}}
    end.


%% In this version of the function, we no longer need
%% the Scheme argument, but just in case...
parse_host_port(_Scheme, DefaultPort, <<"[", HostPort/binary>>, Opts) -> %ipv6
    {Host, ColonPort} = split_uri(HostPort, "\\]", {HostPort, <<"">>}, 1, 1),
    Host2 = maybe_ipv6_host_with_brackets(Host, Opts),
    {_, Port} = split_uri(ColonPort, ":", {<<"">>, DefaultPort}, 0, 1),
    {Host2, int_port(Port)};
parse_host_port(_Scheme, DefaultPort, "[" ++ HostPort, Opts) -> %ipv6
    {Host, ColonPort} = split_uri(HostPort, "\\]", {HostPort, ""}, 1, 1),
    Host2 = maybe_ipv6_host_with_brackets(Host, Opts),
    {_, Port} = split_uri(ColonPort, ":", {"", DefaultPort}, 0, 1),
    {Host2, int_port(Port)};

parse_host_port(_Scheme, DefaultPort, HostPort, _Opts) ->
    {Host, Port} = split_uri(HostPort, ":", {HostPort, DefaultPort}, 1, 1),
    {Host, int_port(Port)}.

split_uri(UriPart, SplitChar, NoMatchResult, SkipLeft, SkipRight) ->
    case re:run(UriPart, SplitChar, [{capture, first}]) of
        {match, [{Match, _}]} ->
            {string:slice(UriPart, 0, Match + 1 - SkipLeft),
                string:slice(UriPart, Match + SkipRight, string:length(UriPart))};
        nomatch ->
            NoMatchResult
    end.

maybe_ipv6_host_with_brackets(Host, Opts) when is_binary(Host) ->
    case lists:keysearch(ipv6_host_with_brackets, 1, Opts) of
        {value, {ipv6_host_with_brackets, true}} ->
            <<"[", Host/binary, "]">>;
        _ ->
            Host
    end;
maybe_ipv6_host_with_brackets(Host, Opts) ->
    case lists:keysearch(ipv6_host_with_brackets, 1, Opts) of
        {value, {ipv6_host_with_brackets, true}} ->
            "[" ++ Host ++ "]";
        _ ->
            Host
    end.

int_port(Port) when is_integer(Port) ->
    Port;
int_port(Port) when is_binary(Port) ->
    binary_to_integer(Port);
int_port(Port) when is_list(Port) ->
    list_to_integer(Port);
%% This is the case where no port was found and there was no default port
int_port(no_default_port) ->
    throw({error, no_default_port}).

path(<<"">>) ->
    <<"/">>;
path("") ->
    "/";
path(Path) ->
    Path.

uri_encode(Char, Reserved) ->
    case sets:is_element(Char, Reserved) of
        true ->
            [ $% | http_util:integer_to_hexlist(Char)];
        false ->
            [Char]
    end.

uri_encode_binary(Char, Reserved) ->
    case sets:is_element(Char, Reserved) of
        true ->
            << $%, (integer_to_binary(Char, 16))/binary >>;
        false ->
            <<Char>>
    end.

hex2dec(X) when (X>=$0) andalso (X=<$9) -> X-$0;
hex2dec(X) when (X>=$A) andalso (X=<$F) -> X-$A+10;
hex2dec(X) when (X>=$a) andalso (X=<$f) -> X-$a+10.
