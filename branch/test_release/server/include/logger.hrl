%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            日志接口
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------

-ifdef(debug).
-define(DEBUG(Format, Args), logger:debug("(~p:~p) " ++ logger:echo_player_id() ++ Format, [?MODULE, ?LINE] ++ Args)).
-define(DEBUG(String), logger:debug(io_lib:format("(~p:~p) "++ logger:echo_player_id(), [?MODULE, ?LINE]) ++ String)).
-else.
-define(DEBUG(Format, Args), ok).
-define(DEBUG(String), ok).
-endif.

-define(WARNING(Format, Args), logger:warning("(~p:~p) " ++ logger:echo_player_id() ++ Format, [?MODULE, ?LINE] ++ Args)).
-define(WARNING(String), logger:warning(io_lib:format("(~p:~p) "++ logger:echo_player_id(), [?MODULE, ?LINE]) ++ String)).
-define(INFO(Format, Args), logger:info("(~p:~p) " ++ logger:echo_player_id() ++ Format, [?MODULE, ?LINE] ++ Args)).
-define(INFO(String), logger:info(io_lib:format("(~p:~p) "++ logger:echo_player_id(), [?MODULE, ?LINE]) ++ String)).
-define(ERROR(Format, Args), logger:error("(~p:~p) " ++ logger:echo_player_id() ++ Format, [?MODULE, ?LINE] ++ Args)).
-define(ERROR(String), logger:error(io_lib:format("(~p:~p) "++ logger:echo_player_id(), [?MODULE, ?LINE]) ++ String)).
-define(FETAL_ERROR(Format, Args), logger:fatal_error("(~p:~p) " ++ logger:echo_player_id() ++ Format, [?MODULE, ?LINE] ++ Args)).
-define(FETAL_ERROR(String), logger:fatal_error(io_lib:format("(~p:~p) "++ logger:echo_player_id(), [?MODULE, ?LINE]) ++ String)).


-define(LOG_LEVEL_DEBUG,         0).    %% 日志等级 debug
-define(LOG_LEVEL_INFO,          1).    %% 日志等级 info
-define(LOG_LEVEL_WARNING,       2).    %% 日志等级 warning
-define(LOG_LEVEL_ERROR,         3).    %% 日志等级 error
-define(LOG_LEVEL_FETAL_ERROR,   4).    %% 日志等级 fetal_error

%% 日志等级
-define(LOG_LEVEL, env:get(log_level, ?LOG_LEVEL_DEBUG)).
%% 日志文件
-define(LOG_FILE_NAME, util:to_list(env:get(log_name, "server.log"))).
%% 日志路径
-define(LOG_DIR, util:to_list(env:get(log_dir, "../log/"))).

%%-record(state, {file, date}).
%%-define(SERVER, logger).

