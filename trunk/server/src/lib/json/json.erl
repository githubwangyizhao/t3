%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(json).
%% API
-export([
	encode/1,
	decode/1
]).

encode(R) ->
	rfc4627:encode(R).
decode(R) ->
	rfc4627:decode(R).
