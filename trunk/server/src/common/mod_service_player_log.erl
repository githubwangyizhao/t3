%%%-------------------------------------------------------------------
%%% @author yizhao.wang
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%		服务端打点日志 (玩家游戏行为)
%%% @end
%%% Created : 01. 9月 2021 11:13
%%%-------------------------------------------------------------------
-module(mod_service_player_log).
-author("yizhao.wang").

%% API
-export([
	add_log/2,
	add_log/3,
	handle_add_log/2,
	write_log/1
	]).

-include("client.hrl").
-include("common.hrl").

-record(r_service_player_log, {
	key ::{integer(), integer()},	% {日志id, 参数}
	count ::integer()				% 记录次数
}).

-record(?MODULE, {
	logs = []		% 打点日志列表
}).

%% ----------------------------------
%% @doc 	添加打点记录
%% @throws 	none
%% @end
%% ----------------------------------
add_log(PlayerId, Param) -> add_log(PlayerId, Param, 1).
add_log(PlayerId, Param, AddCount) ->
	case get(?DICT_PLAYER_ID) == PlayerId of
		true ->
			handle_add_log(Param, AddCount);
		_ ->
			mod_apply:apply_to_online_player(PlayerId, ?MODULE, handle_add_log, [Param, AddCount])
	end.

%%% ----------------------------------
%% @doc     处理新打点记录
%% @throws 	none
%% @end
%% ----------------------------------
handle_add_log(Param, AddCount) ->
	{LogId, ParamType} = get_service_log_id(Param),

	OldLogs = ?getModDict(logs),
	case lists:keytake({LogId, ParamType}, #r_service_player_log.key, OldLogs) of
		false ->
			?setModDict(logs, [
				#r_service_player_log{
					key = {LogId, ParamType},
					count = AddCount
				} | OldLogs]
			);
		{value, #r_service_player_log{count = OldCount}, Rest} ->
			?setModDict(logs, [
				#r_service_player_log{
					key = {LogId, ParamType},
					count = OldCount + AddCount
				} | Rest]
			)
	end.

get_service_log_id(Param) when is_integer(Param) ->
	{Param, 0};
get_service_log_id({LogId, ParamType} = _Param) ->
	{LogId, ParamType}.

%% ----------------------------------
%% @doc 	打点日志写入文件
%% @throws 	none
%% @end
%% ----------------------------------
write_log(PlayerId) ->
	Logs = ?getModDict(logs),
	?setModDict(logs, []),
	NowSec = util_time:timestamp(),
	WriteLogFunc =
		fun(#r_service_player_log{key = {LogId, ParamType}, count = Count}) ->
			logger2:write(service_player_log,
				[
					{playerid, PlayerId},
					{logid, LogId},
					{type, ParamType},
					{count, Count},
					{time, NowSec}
				]
			)
		end,
	lists:foreach(WriteLogFunc, Logs).


