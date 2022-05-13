%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc        系统公共模块
%%% Created : 17. 四月 2018 19:59
%%%-------------------------------------------------------------------
-module(mod_sys_common).
-author("home").

%% API
-export([
    init_player_sys_data/1,     %% 获得系统信息
    change_state/2             %% 替换装备

]).

-export([
    activate_sys_common/2,      %% 激活公共系統
    get_sys_attr_list/2,
    get_id_by_fun_state/2,       %% 获得对应功能已装备id
    get_player_sys_common/2
]).

-include("msg.hrl").
-include("error.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").

%% 初始时获得系统信息
init_player_sys_data(PlayerId) ->
    [{Id, State} || #db_player_sys_common{id = Id, state = State} <- get_db_player_sys_common_by_player(PlayerId)].

%% 替换装备
change_state(PlayerId, Id) ->
    DbSys = get_player_sys_common_init(PlayerId, Id),
    ?ASSERT(is_record(DbSys, db_player_sys_common), ?ERROR_NONE),
    ?ASSERT(DbSys#db_player_sys_common.state == ?FALSE, ?ERROR_ALREADY_HAVE),
    #t_sys_common{
        func_id = FunId
    } = get_t_sys_common(Id),
    DbOldSys = get_sys_common_fun_and_state(get_db_player_sys_common_by_state(PlayerId), FunId),
    Msg =
        case FunId of
            ?FUNCTION_ROLE_CLOTHES ->
                ?MSG_SYNC_CLOTH_ID;
            ?FUNCTION_ROLE_MAGIC ->
                ?MSG_SYNC_MAGIC_WEAPON_ID;
            ?FUNCTION_ROLE_WING ->
                ?MSG_SYNC_WINGS_ID
        end,
    Tran =
        fun() ->
            db:write(DbOldSys#db_player_sys_common{state = ?FALSE}),
            db:write(DbSys#db_player_sys_common{state = ?TRUE}),
            case FunId of
                ?FUNCTION_ROLE_WEAPON ->
                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_WEAPON_REPLACE, ?CONDITIONS_VALUE_SET, 1});
                _ ->
                    noop
            end,
            calc_attr(PlayerId, FunId),
            mod_scene:tran_push_player_data_2_scene(PlayerId, [{Msg, Id}])
%%            api_sys_common:notice_sys_common(PlayerId, [{ApiOld#db_player_sys_common.id, ApiOld#db_player_sys_common.state}, {Id, ?TRUE}])
        end,
    db:do(Tran),
    ok.

%% 激活公共系統
activate_sys_common(PlayerId, Id) ->
    DbSys = get_player_sys_common(PlayerId, Id),
    if
        is_record(DbSys, db_player_sys_common) ->
            ?INFO("物品已激活：~p~n", [{PlayerId, Id}]),
            noop;
        true ->
            #t_sys_common{
                func_id = FunId
            } = get_t_sys_common(Id),
            DbOldSys = get_sys_common_fun_and_state(get_db_player_sys_common_by_state(PlayerId), FunId),
            State =
                if
                    DbOldSys == null ->
                        ?TRUE;
                    true ->
                        ?FALSE
                end,
            NewDbSys = get_player_sys_common_init(PlayerId, Id),
            Msg =
                case FunId of
                    ?FUNCTION_ROLE_CLOTHES ->
                        ?MSG_SYNC_CLOTH_ID;
                    ?FUNCTION_ROLE_MAGIC ->
                        ?MSG_SYNC_MAGIC_WEAPON_ID;
                    ?FUNCTION_ROLE_WING ->
                        ?MSG_SYNC_WINGS_ID
                end,
            Tran =
                fun() ->
                    db:write(NewDbSys#db_player_sys_common{state = State}),
                    if
                        State == ?TRUE ->
                            mod_scene:tran_push_player_data_2_scene(PlayerId, [{Msg, Id}]);
                        true ->
                            noop
                    end,
                    mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_SYS_COMMON_FUN_COUNT, FunId}, ?CONDITIONS_VALUE_ADD, 1}),
                    calc_attr(PlayerId, FunId),
                    api_sys_common:notice_sys_common(PlayerId, [{Id, State}])
                end,
            db:do(Tran)
    end.

%%check_weapon(PlayerId, Id) ->
%%    MinMana = logic_get_mana_weapon_min_mana(Id),
%%    if
%%        MinMana == null ->
%%            false;
%%        true ->
%%            #t_mana_weapon{
%%                level_limit = LevelLimit
%%            } = t_mana_weapon:assert_get({MinMana}),
%%            mod_player:get_player_data(PlayerId, level) >= LevelLimit
%%    end.

%% 获得公共系统功能相同并且已装备的数据
get_sys_common_fun_and_state([], _FunId) ->
    null;
get_sys_common_fun_and_state([DbSys | SysDataList], FunId) ->
    Id = DbSys#db_player_sys_common.id,
    #t_sys_common{
        func_id = FunId1
    } = get_t_sys_common(Id),
    if
        FunId =:= FunId1 ->
            DbSys;
        true ->
            get_sys_common_fun_and_state(SysDataList, FunId)
    end.

get_id_by_fun_state(PlayerId, FunId) ->
    DbSys = get_sys_common_fun_and_state(get_db_player_sys_common_by_state(PlayerId), FunId),
    if
        DbSys == null ->
            0;
        true ->
            DbSys#db_player_sys_common.id
    end.

calc_attr(PlayerId, FunctionId) ->
    mod_attr:refresh_player_sys_attr(PlayerId, FunctionId).

get_sys_attr_list(PlayerId, FunctionId) ->
    lists:foldl(
        fun(#db_player_sys_common{id = Id}, L) ->
            #t_sys_common{
                pram_list = AttrL,
                func_id = FuncId
            } = get_t_sys_common(Id),
            if
                FuncId == FunctionId andalso AttrL =/= [] ->
                    [AttrL | L];
                true ->
                    L
            end
        end, [], get_db_player_sys_common_by_state(PlayerId)
    ).

%% ================================================ 数据操作 ================================================
%% @fun 获得系统数据
get_player_sys_common(PlayerId, Id) ->
    db:read(#key_player_sys_common{player_id = PlayerId, id = Id}).
%% @fun 获得系统数据      并初始化
get_player_sys_common_init(PlayerId, Id) ->
    case get_player_sys_common(PlayerId, Id) of
        PlayerSys when is_record(PlayerSys, db_player_sys_common) ->
            PlayerSys;
        _ ->
            #db_player_sys_common{player_id = PlayerId, id = Id}
    end.

%% 获得玩家公共系统
get_db_player_sys_common_by_player(PlayerId) ->
    db_index:get_rows(#idx_player_sys_common_by_player{player_id = PlayerId}).

%% 获得公共系统已装备
get_db_player_sys_common_by_state(PlayerId) ->
    db_index:get_rows(#idx_player_sys_common_by_state{player_id = PlayerId, state = ?TRUE}).

%% ================================================ 模板操作 ================================================
%% 获得公共系统模板
get_t_sys_common(Id) ->
    t_sys_common:assert_get({Id}).
