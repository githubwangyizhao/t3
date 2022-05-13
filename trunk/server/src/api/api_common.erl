%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(api_common).

-include("error.hrl").
-include("common.hrl").
-include("p_enum.hrl").

-export([
    api_result_to_enum/1,   %% 返回值转成枚举
    api_result_to_enum_2/1, %% 返回值转成枚举  2返回全转换
    api_error_to_enum/1,    %% 常用error转成enum
    api_error_to_enum/2,
    api_result_to_enum_by_many/2        %% 返回值转成枚举 多返回值时
]).

%% %% 返回值转成枚举 多返回值时
api_result_to_enum_by_many(Result, List) ->
    case Result of
        {'EXIT', Type} ->
            list_to_tuple([api_error_to_enum(Type) | List]);
        _ ->
            case erlang:element(1, Result) of
                ok ->
                    erlang:setelement(1, Result, ?P_SUCCESS);
                R ->
                    ?ERROR("~p__~n", [{R, erlang:get_stacktrace()}]),
                    list_to_tuple([?P_FAIL | List])
            end
    end.

%% 返回值转成枚举
api_result_to_enum(Result) ->
    case Result of
        ok ->
            ?P_SUCCESS;
        {'EXIT', Type} ->
            api_error_to_enum(Type);
        R ->
            ?ERROR("~p__~n", [{R, erlang:get_stacktrace()}]),
            ?P_FAIL
    end.

%% 返回值转成枚举  2返回全转换
api_result_to_enum_2(Result) ->
    case Result of
        ok ->
            ?P_SUCCESS;
        {'EXIT', Type} ->
            api_error_to_enum(Type);
        R ->
            api_error_to_enum(R)
    end.

%% 常用error转成enum
api_error_to_enum(ErrorType) -> api_error_to_enum(ErrorType, true).
api_error_to_enum(ErrorType, IsLog) ->
    case ErrorType of
        ok ->
            ?P_SUCCESS;
        ?ERROR_VERIFY_FAIL ->                   %% 验证失败
            ?P_VERIFY_FAIL;
        ?ERROR_TOKEN_EXPIRE ->                  %% token过期
            ?P_TOKEN_EXPIRE;
%%        ?ERROR_DISABLE_LOGIN ->                 %% 禁止登入
%%            ?P_DISABLE_LOGIN;
        ?ERROR_ALREADY_CREATE_ROLE ->           %% 已经创建角色
            ?P_ALREADY_CREATE_ROLE;
        ?ERROR_NAME_USED ->                     %% 名字已经使用
            ?P_USED;
        ?ERROR_INVAILD_NAME ->                  %% 非法名字
            ?P_INVALID_STRING;
        ?ERROR_NAME_TOO_LONG ->                 %% 名字过长
            ?P_TOO_LONG;
        ?ERROR_FAIL ->                          %% 失败
            ?P_FAIL;
        ?CSR_MAX_PACK ->                        %% 发包太快
            ?P_CHEAT;
        ?CSR_GM_KILL ->                         %% 管理员踢出
            ?P_GM_KILL;
        ?CSR_LOGIN_IN_OTHER ->                  %% 在别处登录
            ?P_LOGIN_IN_OTHER;
        ?CSR_SYSTEM_MAINTENANCE ->              %% 系统维护
            ?P_SYSTEM_MAINTENANCE;
        ?CSR_DISABLE_LOGIN ->                   %% 封号
            ?P_DISABLE_LOGIN;
        ?ERROR_NOT_AUTHORITY ->                 %% 没有权力 (不满足条件)
            ?P_NOT_AUTHORITY;
        ?ERROR_NEED_LEVEL ->                    %% 等级限制
            ?P_NEED_LEVEL;
        ?ERROR_NO_ENOUGH_PROP ->                %% 道具不足
            ?P_NO_ENOUGH_PROP;
        ?ERROR_NOT_ENOUGH_GRID ->               %% 没有空格子(格子不足)
            ?P_NOT_ENOUGH_GRID;
        ?ERROR_FUNCTION_NO_OPEN ->              %% 功能未开启
            ?P_FUNCTION_NO_OPEN;
        ?ERROR_LEVEL_TEMPLATE_LIMIT ->          %% 模板等级上限
            ?P_LEVEL_LIMIT;
        ?ERROR_ALREADY_HAVE ->                  %% 已经存在
            ?P_ALREADY_HAVE;
        ?ERROR_OLD_ITEM_TIME ->                 %% 物品过期
            ?P_OLD_ITEM_TIME;
        ?ERROR_TIMES_LIMIT ->                   %% 次数上限
            ?P_TIMES_LIMIT;
        ?ERROR_NONE ->                          %% 无
            ?P_NONE;
        ?ERROR_ACTIVITY_NO_OPEN ->              %% 活动未开启
            ?P_ACTIVITY_NO_OPEN;
        ?ERROR_NOT_ONLINE ->                    %% 不在线
            ?P_NOT_ONLINE;
        ?ERROR_TIME_LIMIT ->                    %% 时间限制
            ?P_TIME_LIMIT;
        ?ERROR_NEED_POWER ->                    %% 战力限制
            ?P_NEED_POWER;
        ?ERROR_NOT_ENOUGH_NUMBER ->             %% 数量不足
            ?P_NOT_ENOUGH_NUMBER;
        ?ERROR_NO_CONDITION ->
            ?P_NO_CONDITION;                    %% 条件不足
        ?ERROR_ALREADY_JOIN_ROOM ->
            ?P_ALREADY_JOIN_ROOM;               %% 已经加入房间
        ?ERROR_NOT_ENOUGH_MANA ->
            ?P_NOT_ENOUGH_MANA;                 %% 灵力值不足
        ?ERROR_ERROR_PASSWORD ->
            ?P_ERROR_PASSWORD;                  %% 密码错误
        ?ERROR_ALREADY_GET ->
            ?P_ALREADY_GET;
        ?ERROR_INTERFACE_CD_TIME ->             %% 接口cd时间
            ?P_INTERFACE_CD_TIME;
        ?ERROR_NOT_ENOUGH_TIMES ->              %% 次数不足
            ?P_NOT_ENOUGH_TIMES;
        ?ERROR_EXPIRE ->                        %% 过期
            ?P_EXPIRE;
        ?ERROR_NOT_ACTION_TIME ->               %% 非行动时间
            ErrorType;
        _ ->
            if
                IsLog ->
                    ?ERROR("错误枚举未配置~p__~n", [{ErrorType, erlang:get_stacktrace()}]);
                true ->
                    noop
            end,
            ?P_FAIL
    end.
