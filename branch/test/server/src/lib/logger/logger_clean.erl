%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-module(logger_clean).
-include("logger.hrl").

%% API
-export([clean_expire_log/0]).


clean_expire_log() ->
    ?INFO("清理过期日志" ),
    Now = util_time:timestamp(),
    ExpireDay = 180,
%%    if ExpireDay > 0 ->
    case ExpireDay > 0 of
        true ->
        lists:foreach(
            fun(Dir) ->
                BaseDir = filename:basename(Dir),
                case string:split(BaseDir, "_", all) of
                    [SY, SM, SD] ->
                        Y = erlang:list_to_integer(SY),
                        M = erlang:list_to_integer(SM),
                        D = erlang:list_to_integer(SD),
                        CreateTime = util_time:datetime_to_timestamp({{Y, M, D}, {0, 0, 0}}),
                        if Now - CreateTime > ExpireDay * 86400 ->
                            clean_dir_log(Dir);
                            true ->
                                noop
                        end;
                    _ ->
                        noop
                end
            end,
            filelib:wildcard(filename:join(?LOG_DIR, "*"))
        );
        _ ->
            noop
    end.

clean_dir_log(Dir) ->
    lists:foreach(
        fun(File) ->
            case file:delete(File) of
                ok ->
                    noop;
                {error, Reason} ->
                    ?ERROR("delete file:~p", [{File, Reason}])
            end
        end,
        filelib:wildcard(filename:join(Dir, "*.log"))
    ),
    lists:foreach(
        fun(File) ->
            case file:delete(File) of
                ok ->
                    noop;
                {error, Reason} ->
                    ?ERROR("delete file:~p", [{File, Reason}])
            end
        end,
        filelib:wildcard(filename:join(Dir, "*/*.log"))
    ),
    lists:foreach(
        fun(SubDir) ->
            case file:del_dir(SubDir) of
                ok ->
                    ?INFO("clean_sub_dir_log:~p", [SubDir]);
                {error, Reason} ->
                    ?ERROR("delete sub dir:~p", [{SubDir, Reason}])
            end
        end,
        filelib:wildcard(filename:join(Dir, "*"))
    ),
    case file:del_dir(Dir) of
        ok ->
            ?INFO("clean_dir_log:~p", [Dir]);
        {error, Reason} ->
            ?ERROR("delete dir:~p", [{Dir, Reason}])
    end.
