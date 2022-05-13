%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            功能模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_function).

-include("common.hrl").
-include("gen/db.hrl").
-include("client.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("error.hrl").
-export([
    is_open/2,                          %% 功能是否开启
    assert_open/2,                      %% 校验功能是否开启
    active_function/2,                  %% 激活功能
    get_init_function_data/1,           %% 获取初始时 功能数据
    init_active_function/1              %% 初始玩家时激活功能
%%    get_fun_award/2                     %% 领取功能奖励
]).

-export([
    test_fun_change/2,                  %% 测试功能
    test_change_fun/4,                  %% 界面测试功能使用
    repair_check_function_list/0,       %% 修改时检查功能开启列表
    repair_all_function/1,              %% 修复所有功能
    logic_get_function_id_list/0,
    logic_get_function_id_module/1,     %% 获取功能对应模块
    gm_del_fun/2,
    update_fun_data/2,
    get_function_name/1                 %% 获得功能名
]).

-export([
    version_repair/2
]).

-define(GM_FUN_ID_ALL_OPEN, [999]).

%% 微信平台过滤功能id列表 20180822
%%-define(WS_IGNORE_FUN_ID_LIST, [20701, 20702, 20703, 20704, 20705, 20706]).

%%%% 领取功能奖励
%%get_fun_award(PlayerId, FunId) ->
%%    ?ASSERT(is_open(PlayerId, FunId), ?ERROR_NOT_EXISTS),
%%    PlayerFun = get_player_function(PlayerId, FunId),
%%    State = PlayerFun#db_player_function.get_state,
%%    ?ASSERT(State =/= ?AWARD_ALREADY, ?ERROR_ALREADY_HAVE),
%%    AwardId = logic_get_fun_id_award(FunId),
%%    PropList = mod_award:decode_award(AwardId),
%%    ?ASSERT(PropList =/= [], ?ERROR_FAIL),
%%    mod_prop:assert_give(PlayerId, PropList),
%%    Tran =
%%        fun() ->
%%            mod_award:give(PlayerId, PropList, ?LOG_TYPE_FUNCTION_GET_AWARD),
%%            db:write(PlayerFun#db_player_function{get_state = ?AWARD_ALREADY})
%%        end,
%%    db:do(Tran),
%%    ok.

%% ----------------------------------
%% @doc 	功能是否开启
%% @throws 	none
%% @end
%% ----------------------------------
is_open(_PlayerId, 0) ->
    true;
is_open(PlayerId, FunctionId) ->
    HaveFunIdValue = logic_get_function_have_fun_id_list:get(FunctionId),
    HaveFunIdState =
        if
            HaveFunIdValue == null ->
                false;
            true ->
                case is_integer(HaveFunIdValue) of
                    true ->
                        true;
                    _ ->
                        case is_list(HaveFunIdValue) of
                            true ->
                                PfIdAtom = util:to_atom(mod_server_config:get_platform_id()),
                                case lists:member(PfIdAtom, HaveFunIdValue) of
                                    true ->
                                        true;
                                    _ ->
                                        SonHavePf = mod_player:get_atom_platform_and_pf(PlayerId),
                                        case lists:member(SonHavePf, HaveFunIdValue) of
                                            true ->
                                                true;
                                            _ ->
                                                false
                                        end
                                end;
                            _ ->
                                false
                        end
                end
        end,
    if
        HaveFunIdState == true ->
            true;
        true ->
            case get_player_function(PlayerId, FunctionId) of
                PlayerFunction when is_record(PlayerFunction, db_player_function) ->
                    PlayerFunction#db_player_function.state == ?TRUE;
                _ ->
                    false
            end
    end.

%% ----------------------------------
%% @doc 	校验功能是否开启
%% @throws 	none
%% @end
%% ----------------------------------
assert_open(PlayerId, FunctionId) ->
    case is_open(PlayerId, FunctionId) of
        true ->
            ok;
        false ->
            ?DEBUG("功能未开启: ~p", [{PlayerId, FunctionId}]),
            exit(?ERROR_FUNCTION_NO_OPEN)
    end.
%%    ?ASSERT(is_open(PlayerId, FunctionId), ?ERROR_FUNCTION_NO_OPEN).

%% ----------------------------------
%% @doc 	检查功能是否可以激活
%% @throws 	none
%% @end
%% ----------------------------------
check_function_can_active(PlayerId, FunctionId) ->
    #t_function{
        activate_condition_list = ActivateConditionList,
        not_have_pf_list = NotHavePfList,
        activate_type = ActivateType
    } = get_t_function(FunctionId),
    case ActivateConditionList of
        [] ->
            false;
        _ ->
            PfIdStr = mod_server_config:get_platform_id(),
            PfIdAtom = util:to_atom(PfIdStr),
            SonHavePf = mod_player:get_atom_platform_and_pf(PlayerId),
            IsNotFunState =
                lists:foldl(
                    fun(NotHavePf, IsNot) ->
                        if
                            IsNot == true ->
                                IsNot;
                            true ->
                                if
                                    NotHavePf == PfIdAtom orelse NotHavePf == SonHavePf ->
                                        true;
                                    true ->
                                        IsNot
                                end
                        end
                    end, false, NotHavePfList),
            IsHaveFunState =
                if
                    IsNotFunState == true ->
                        false;
                    true ->
                        is_have_fun(FunctionId, PfIdAtom, SonHavePf)
%%                        case get_function_have_fun_id_list(FunctionId) of
%%                            [] ->
%%                                true;
%%                            PfList ->
%%                                case lists:member(PfIdAtom, PfList) of
%%                                    true ->
%%                                        true;
%%                                    _ ->
%%                                        case lists:member(SonHavePf, PfList) of
%%                                            true ->
%%                                                true;
%%                                            _ ->
%%                                                false
%%                                        end
%%                                end
%%                        end
                end,
            if
%%                IsNotFunState == true ->
%%                    false;
                IsHaveFunState == false ->
                    false;
                true ->
                    case ActivateType of
                        0 -> %或
                            lists:any(
                                fun(Condition) ->
                                    mod_conditions:is_player_conditions_state(PlayerId, Condition)
                                end,
                                ActivateConditionList
                            );
                        1 -> %与
                            lists:all(
                                fun(Condition) ->
                                    mod_conditions:is_player_conditions_state(PlayerId, Condition)
                                end,
                                ActivateConditionList
                            )
                    end
            end
    end.

%% @doc     激活功能
active_function(PlayerId, FunctionId) when is_integer(FunctionId) ->
    active_function(PlayerId, [FunctionId]);
active_function(_PlayerId, []) ->
    ok;
active_function(PlayerId, List) ->
    Tran =
        fun() ->
            List1 =
                lists:foldl(
                    fun(FunctionId, L1) ->
                        case update_fun_data(PlayerId, FunctionId) of
                            true ->
                                [FunctionId | L1];
                            _ ->
                                L1
                        end
                    end, [], List),
            List1
        end,
    db:do(Tran).

%% @fun 激活功能
update_fun_data(PlayerId, FunctionId) ->
    case get_player_function(PlayerId, FunctionId) of
        null ->
            case check_function_can_active(PlayerId, FunctionId) of
                true ->
                    do_player_function(PlayerId, FunctionId),
                    true;
                false ->
                    false
            end;
        _ ->
%%			?WARNING("功能已经激活:~p", [{PlayerId, FunctionId}]),
            already
    end.

%% 是否过滤该功能
%%is_ignore_function(FunctionId) ->
%%    PlatformId = mod_server_config:get_platform_id(),
%%    if PlatformId == ?PLATFORM_WX ->
%%        lists:member(FunctionId, ?WS_IGNORE_FUN_ID_LIST);
%%        true ->
%%            false
%%    end.

%% @fun 处理功能数据
do_player_function(PlayerId, FunctionId) ->
    #t_function{
        module_tuple = Module,
        function_tuple = Function,
        arg_list = ArgList
    } = get_t_function(FunctionId),
    db:write(#db_player_function{
        player_id = PlayerId,
        function_id = FunctionId,
        state = ?TRUE,
        time = util_time:timestamp()
    }),
    if
        ArgList == ?GM_FUN_ID_ALL_OPEN orelse Module =/= {} andalso Function =/= {} ->
            try Module:Function(PlayerId, ArgList)
            catch
                _:Reason ->
                    ?ERROR("处理功能数据失败:~p", [{Module, Function, [PlayerId | ArgList], Reason, erlang:get_stacktrace()}])
            end;
        true ->
            noop
    end,
    db:tran_merge_apply({hook, after_active_function, PlayerId}, FunctionId).

%% @fun 初始玩家时生成的功能
init_active_function(PlayerId) ->
    PfIdStr = mod_server_config:get_platform_id(),
    PfIdAtom = util:to_atom(PfIdStr),
    SonHavePf = mod_player:get_atom_platform_and_pf(PlayerId),
    NotHaveFunIdList = logic_get_function_not_have_fun_id_list(SonHavePf) ++ logic_get_function_not_have_fun_id_list(PfIdAtom),
    FunInitList =
        lists:foldl(
            fun(CheckFunId, CheckFunL) ->
                case is_have_fun(CheckFunId, PfIdAtom, SonHavePf) of
                    true ->
                        [CheckFunId | CheckFunL];
                    _ ->
                        CheckFunL
                end
%%                case get_function_have_fun_id_list(CheckFunId) of
%%                    [] ->
%%                        [CheckFunId | CheckFunL];
%%                    PfList ->
%%                        case lists:member(PfIdAtom, PfList) of
%%                            true ->
%%                                [CheckFunId | CheckFunL];
%%                            _ ->
%%                                case lists:member(SonHavePf, PfList) of
%%                                    true ->
%%                                        [CheckFunId | CheckFunL];
%%                                    _ ->
%%                                        CheckFunL
%%                                end
%%                        end
%%                end
            end, [], logic_get_function_have_init_list()),
    Tran =
        fun() ->
            lists:foldl(
                fun(FunctionId, L) ->
                    #t_function{
                        activate_condition_list = ActivateConditionList,
                        activate_type = ActivateType,
                        module_tuple = Module,
                        function_tuple = Function,
                        arg_list = ArgList
                    } = get_t_function(FunctionId),
                    CheckState =
                        case ActivateConditionList of
                            [] ->
                                true;
                            _ ->
                                case ActivateType of
                                    0 -> %或
                                        lists:any(
                                            fun(Condition) ->
                                                mod_conditions:is_player_conditions_state(PlayerId, Condition)
                                            end,
                                            ActivateConditionList
                                        );
                                    1 -> %与
                                        lists:all(
                                            fun(Condition) ->
                                                mod_conditions:is_player_conditions_state(PlayerId, Condition)
                                            end,
                                            ActivateConditionList
                                        )
                                end
                        end,
                    if
                        CheckState == true ->
                            if
                                ArgList == ?GM_FUN_ID_ALL_OPEN orelse Module =/= {} andalso Function =/= {} ->
                                    try Module:Function(PlayerId, ArgList)
                                    catch
                                        _:Reason ->
                                            ?ERROR("初始化功能失败:~p", [{Module, Function, [PlayerId | ArgList], Reason, erlang:get_stacktrace()}])
                                    end;
                                true ->
                                    noop
                            end,
                            db:tran_merge_apply({hook, after_active_function, PlayerId}, FunctionId),
                            [FunctionId | L];
                        true ->
                            L
                    end
                end, [], FunInitList -- NotHaveFunIdList)
        end,
    db:do(Tran).


%% 界面测试功能使用
test_change_fun(PlayerId, TempFunId, TempPram, Value) ->
    ?IF(0 =< Value orelse Value =< 999999999, noop, exit(?ERROR_NUM_0)),
%%    mod_log:write_test_change_fun_log(PlayerId, TempFunId, TempPram, Value, IsTest),
    Tran =
        fun() ->
            FunId1 =
                if
                    TempFunId == ?FUNCTION_ROLE_SYS andalso TempPram == 2 ->      %% exp
                        mod_player:add_exp(PlayerId, Value, ?LOG_TYPE_GM),
                        TempFunId;
                    TempFunId == ?FUNCTION_ROLE_SYS ->      %% 人物属性
                        PlayerData = mod_player:get_db_player_data(PlayerId),
                        NewPlayerData = db:write(PlayerData#db_player_data{attack = Value}),
                        mod_attr:sync_player_data(PlayerData, NewPlayerData),
                        TempFunId;
                    TempFunId == ?FUNCTION_VIP_SYS ->       %% vip
                        mod_vip:test_fun_change(PlayerId, Value, ?LOG_TYPE_GM),
                        TempFunId;
                    TempFunId == ?FUNCTION_MAIL_SYS ->      %% 邮件
                        mod_mail:add_mail_id(PlayerId, Value, ?LOG_TYPE_GM),
                        TempFunId;
                    TempFunId == ?FUNCTION_ROLE_ENT ->      %% 进入场景
                        SceneId = Value,
                        case client_worker:get_player_id() == PlayerId of
                            true ->
                                mod_scene:player_enter_scene(PlayerId, SceneId);
                            _ ->
                                mod_apply:apply_to_online_player(PlayerId, mod_scene, player_enter_scene, [PlayerId, SceneId])
                        end,
                        TempFunId;
                    true ->
                        ?DEBUG("~p___~n", [TempFunId]),
                        exit(not_check_sys_fun)
                end,

            case get_player_function(PlayerId, FunId1) of
                F when is_record(F, db_player_function) ->
                    ok;
                _ ->
                    do_player_function(PlayerId, FunId1)
            end
        end,
    db:do(Tran),
    ok.

%% @fun 获取初始时 功能数据
get_init_function_data(PlayerId) ->
    {NewList, NewAwardList} =
        lists:foldl(
            fun(R, {List, AwardList}) ->
                FunId = R#db_player_function.function_id,
                AwardList1 =
                    if
                        R#db_player_function.get_state == ?AWARD_ALREADY ->
                            [FunId | AwardList];
                        true ->
                            AwardList
                    end,
                {[FunId | List], AwardList1}
            end,
            {[], []},
            get_all_player_function(PlayerId)
        ),
    PfIdStr = mod_server_config:get_platform_id(),
    PfIdAtom = util:to_atom(PfIdStr),
    SonHavePf = mod_player:get_atom_platform_and_pf(PlayerId),
%%        case get(?DICT_QQ_PF) of
%%            SubPf when is_list(SubPf) andalso SubPf =/= "" ->
%%                util:to_atom(PfIdStr ++ "_" ++ SubPf);
%%            _ ->
%%                PfIdAtom
%%        end,

    NotHaveFunIdList = logic_get_function_not_have_fun_id_list(SonHavePf) ++ logic_get_function_not_have_fun_id_list(PfIdAtom),
    FunInitList =
        lists:foldl(
            fun(CheckFunId, CheckFunL) ->
                case is_have_fun(CheckFunId, PfIdAtom, SonHavePf) of
                    true ->
                        [CheckFunId | CheckFunL];
                    _ ->
                        CheckFunL
                end
%%                    PfList ->
%%                        case lists:member(PfIdAtom, PfList) of
%%                            true ->
%%                                [CheckFunId | CheckFunL];
%%                            _ ->
%%                                case lists:member(SonHavePf, PfList) of
%%                                    true ->
%%                                        [CheckFunId | CheckFunL];
%%                                    _ ->
%%                                        CheckFunL
%%                                end
%%                        end
%%                end
            end, [], logic_get_function_have_init_list() ++ NewList),
%%    RedF =
%%        fun(RedFunctionId) ->
%%            Table = get_t_function(RedFunctionId),
%%            Module = Table#t_function.module_tuple,
%%            if
%%                Module =/= {} ->
%%                    catch Module:get_init_red(PlayerId);
%%                true ->
%%                    ?ERROR("获取初始时 Module为空 :~p", [{RedFunctionId, Module}]),
%%                    false
%%            end
%%        end,
%%    RedList = lists:filter(RedF, logic_get_function_red_list()),
    %%   ?INFO("~p~n", [{PfIdStr, NotHavePf, FunInitList, NotHaveFunIdList}]),
    {lists:usort(FunInitList) -- NotHaveFunIdList, NewAwardList, []}.

%% @fun 是否存在功能
is_have_fun(CheckFunId, PfIdAtom, SonHavePf) ->
    IsHaveShare =
        case env:get(remove_fun_list) of
            [] ->
                true;
            List when is_list(List) ->
                lists:member(CheckFunId, List) == false;
            _ ->
%%                @TODO 屏蔽
%%                case env:get(is_have_share) of
%%                    false when CheckFunId == ?FUNCTION_SHARE_SYS orelse CheckFunId == ?FUNCTION_NATIONAL_DAY_SHARE -> %% 关闭分享
%%                        false;
%%                    _ ->
                true
%%                end
        end,
    if
        IsHaveShare ->
            case get_function_have_fun_id_list(CheckFunId) of
                [] ->
                    true;
                PfList ->
                    case lists:member(PfIdAtom, PfList) of
                        true ->
                            true;
                        _ ->
                            case lists:member(SonHavePf, PfList) of
                                true ->
                                    true;
                                _ ->
                                    false
                            end
                    end
            end;
        true ->
            false
    end.

%% @fun 测试功能
test_fun_change(PlayerId, FunId) ->
    Tran =
        fun() ->
            do_player_function(PlayerId, FunId)
        end,
    db:do(Tran).

%% @fun 修改时检查功能开启列表
repair_check_function_list() ->
    lists:foldl(
        fun(PlayerId, L) ->
            case catch active_function(PlayerId, logic_get_function_id_list()) of
                List when is_list(List) ->
                    [PlayerId | L];
                _ ->
                    L
            end
        end, [], mod_player:get_all_player_id()).

%% 修复所有功能
repair_all_function(PlayerId) ->
    active_function(PlayerId, logic_get_function_id_list()).

%% 获得功能名
get_function_name(FunctionId) ->
    #t_function{
        name = FunctionName
    } = get_t_function(FunctionId),
    FunctionName.

%% @fun gm删除功能
gm_del_fun(PlayerId, FunId) ->
    Tran =
        fun() ->
            case get_player_function(PlayerId, FunId) of
                PlayerFun when is_record(PlayerFun, db_player_function) ->
                    db:delete(PlayerFun);
                _ ->
                    noop
            end
        end,
    db:do(Tran).

version_repair(PlayerId, 2021102601) ->
    Tran =
        fun() ->
            lists:foreach(
                fun(DbFunction) ->
                    case check_function_can_active(PlayerId, DbFunction#db_player_function.function_id) of
                        true ->
                            noop;
                        false ->
                            db:delete(DbFunction)
                    end
                end,
                get_all_player_function(PlayerId)
            )
        end,
    db:do(Tran),
    ok.

%% ================================================================== 数据操作 =============================================
%% @fun 获得玩家功能数据
get_player_function(PlayerId, FunctionId) ->
    db:read(#key_player_function{player_id = PlayerId, function_id = FunctionId}).


get_all_player_function(PlayerId) ->
    db_index:get_rows(#idx_player_function_1{player_id = PlayerId}).


%% ================================================================== 模板操作 =============================================
%% @fun 获得功能模板数据
get_t_function(FunctionId) ->
    Table = t_function:get({FunctionId}),
    ?IF(is_record(Table, t_function), Table, exit({null_t_function, {FunctionId}})).

%%%% 获得功能奖励列表
%%logic_get_fun_id_award(FunId) ->
%%    AwardId = logic_get_fun_award_id:get(FunId),
%%    ?IF(is_integer(AwardId), AwardId, exit({logic_get_fun_id_award, {FunId}})).

%% @fun 初始时的功能可存在列表
logic_get_function_have_init_list() ->
    logic_get_function_have_init_list:get(0).

%% @fun 获得存在功能的平台列表
get_function_have_fun_id_list(FunId) ->
    case logic_get_function_have_fun_id_list:get(FunId) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.
%% @fun 获得不存在功能的平台列表
logic_get_function_not_have_fun_id_list(NotHavePf) ->
    case logic_get_function_not_have_fun_id_list:get(NotHavePf) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.

%% @fun 获取功能对应模块
logic_get_function_id_module(FunctionId) ->
    case logic_get_function_id_module:get(FunctionId) of
        {ok, Mod} ->
            Mod;
        _ ->
            exit(?ERROR_TABLE_DATA)
    end.

%% @fun 获得激活功能的列表
logic_get_function_id_list() ->
    case logic_get_function_id_list:get(0) of
        List when is_list(List) ->
            List;
        _ ->
            []
    end.
