%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            日志配置
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------

%%-define(LOG_LEVEL_DEBUG,         0).    %% 日志等级 debug
%%-define(LOG_LEVEL_INFO,          1).    %% 日志等级 info
%%-define(LOG_LEVEL_WARNING,       2).    %% 日志等级 warning
%%-define(LOG_LEVEL_ERROR,         3).    %% 日志等级 error
%%-define(LOG_LEVEL_FETAL_ERROR,   4).    %% 日志等级 fetal_error
%%
%%%% 日志等级
%%-define(LOG_LEVEL, env:get(log_level, ?LOG_LEVEL_DEBUG)).
%%%% 日志文件
%%-define(LOG_FILE_NAME, util:to_list(env:get(log_name, "server.log"))).
%%%% 日志路径
%%-define(LOG_DIR, util:to_list(env:get(log_dir, "../log/"))).
%%
%%-record(state, {file, date}).
%%-define(SERVER, logger).
