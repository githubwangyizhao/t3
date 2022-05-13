%%%%%-------------------------------------------------------------------
%%%%% @author home
%%%%% @copyright (C) 2018, GAME BOY
%%%%% @doc
%%%%% Created : 07. 二月 2018 18:26
%%%%%-------------------------------------------------------------------
-module(robot_data).
%%-author("home").
%%
%%%% API
%%-export([
%%    try_t_robot/1
%%%%    create_robot_data_file/0       %% 生成机器人数据文件
%%%%    get_robot_sys_data_list/0       %% 获得机器人系统数据
%%]).
%%
%%-include("error.hrl").
%%-include("common.hrl").
%%-include("gen/db.hrl").
%%-include("gen/table_db.hrl").
%%-include("gen/table_enum.hrl").
%%
%%-define(CREATE_ROBOT_FILE_NAME, "robot_data_info").           % 生机器人数据的文件名
%%-define(CREATE_ROBOT_LOOP_LIMIT, 50).                          % 创建机器人循环次数上限
%%
%%-define(ATTR_ATTACK,1).
%%-define(ATTR_DEFENSE,2).
%%-define(ATTR_HP,3).
%%-define(ATTR_HIT,4).
%%-define(ATTR_DODGE,5).
%%-define(ATTR_CRIT,6).
%%-define(ATTR_RESIST_CRIT,99).
%%%%-define(ATTR_HP,3).
%%%%-define(ATTR_HP,3).
%%
%%%% @fun 系统数据列表  %%  增加系统时增加数据
%%-define(SYS_DATA_LIST, [
%%%%    {db_player_equip_pos, util_string:to_utf8("装备系统")},
%%    {db_player_vip, util_string:to_utf8("vip系统")},
%%%%    {db_player_magic_weapon_new, util_string:to_utf8("法宝系统")},
%%%%    {db_player_magic_weapon_pos, util_string:to_utf8("法宝装配数据")},
%%%%    {db_player_jade, util_string:to_utf8("玉佩数据")},
%%%%    {db_player_god_weapon, util_string:to_utf8("神兵系统")},
%%%%    {db_player_sys_common_data, util_string:to_utf8("妖灵系统")},
%%%%    {db_player_sys_common_data, util_string:to_utf8("坐骑系统")},
%%%%    {db_player_jing_jie, util_string:to_utf8("境界系统")},
%%%%    {db_player_active_skill, util_string:to_utf8("主动技能系统")},
%%%%    {db_player_sys_common_data, util_string:to_utf8("进阶公共系统")},
%%    {db_player_data, util_string:to_utf8("人物系统")}
%%]).
%%
%%-define(STATE_2, 2).    %已装备
%%-define(STATE_1, 1).    %获得
%%
%%%% @fun 获得机器人系统数据
%%%%get_robot_sys_data_list() ->
%%%%    CompileList = [
%%%%        "../src/common/mod_equip.erl",
%%%%        "../src/common/mod_attr.erl"
%%%%    ],
%%%%    lists:foreach(
%%%%        fun(FilePath) ->
%%%%            qmake:compilep(FilePath, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH)
%%%%        end, CompileList),
%%%%
%%%%    RobotAttrList =
%%%%        lists:foldl(
%%%%            fun(RobotAttrId, L) ->
%%%%                #t_robot{
%%%%                    level = Level,                          % 人物等级
%%%%                    equip_list = EquipList,                 % 装备列表
%%%%                    magic_weapon_list = MagicWeaponList,    % 法宝列表
%%%%                    god_weapon_list = GodWeaponList,        % 神兵列表
%%%%                    jade_list = JadeList,                   % 玉佩列表
%%%%                    pet_step = PetStep,                     % 仙宠阶级
%%%%                    god_ring_step = MagicRingStep,          % 法环阶级
%%%%                    wings_step = WingsStep,                 % 翅膀阶级
%%%%                    foot_step = FootLevel,                  % 神印等级
%%%%                    vip_level = VipLevel,                   % vip等级
%%%%                    state_level = JingJieId,                % 境界
%%%%                    skill_list = ActiveSkillList,           % 主动技能列表
%%%%                    attr_list = AddAttrList                 % 额外增加属性列表
%%%%                } = try_t_robot(RobotAttrId),
%%%%                Tuple = {[], []},
%%                %%  增加系统时增加数据
%%%%                CalcList =
%%%%                    [
%%%%                        mod_equip:robot_get_sys_attr_list(RobotAttrId, EquipList),
%%%%                        magic_weapon(RobotAttrId, MagicWeaponList, Tuple),
%%%%                        god_weapon(RobotAttrId, GodWeaponList, Tuple),
%%%%                        jade(RobotAttrId, JadeList, Tuple),
%%%%                        active_skill(RobotAttrId, ActiveSkillList, Tuple),
%%%%                        vip(RobotAttrId, VipLevel, Tuple)
%%%%                        jing_jie(RobotAttrId, JingJieId, Tuple),
%%%%                        sys_common(RobotAttrId, ?FUNCTION_GOD_BOW_SYS, PetStep, Tuple),
%%%%                        sys_common(RobotAttrId, ?FUNCTION_GOD_FOOTPRINTS_SYS, FootLevel, Tuple),
%%%%                        sys_common(RobotAttrId, ?FUNCTION_MAGIC_RING_SYS, MagicRingStep, Tuple),
%%%%                        sys_common(RobotAttrId, ?FUNCTION_WINGS_SYS, WingsStep, Tuple)
%%%%                    ],
%%%%                {AllDataList, AllAttrList} =
%%%%                    lists:foldl(
%%%%                        fun({DataList1, AttrList1}, {DataList, AttrList}) ->
%%%%                            {DataList1 ++ DataList, AttrList1 ++ AttrList}
%%%%                        end, {[], role_robot(Level)}, CalcList),
%%%%                BodyGodWeaponId =
%%%%                    lists:foldl(
%%%%                        fun([GodWeaponId1 | _], BodyGodWeaponId1) ->
%%%%                            if
%%%%                                BodyGodWeaponId1 > 0 ->
%%%%                                    BodyGodWeaponId1;
%%%%                                true ->
%%%%                                    GodWeaponId1
%%%%                            end
%%%%                        end, 0, GodWeaponList),
%%%%                RobotPlayerData = mod_attr:robot_get_sys_attr_list(RobotAttrId, {Level, 0}, AddAttrList ++ AllAttrList),
%%%%                AllDataList ++ [RobotPlayerData | L]
%%%%                AttrList = role_robot(Level) ++ EquipAttrList ++ MagicWeaponAttrList ++ GodWeaponAttrList ++ GhostAttrList ++ MountAttrList ++ WingsAttrList,
%%%%                RobotPlayerData = mod_attr:robot_get_sys_attr_list(RobotAttrId, {Level}, AttrList),
%%%%                SysDataList = lists:append([EquipDataList, MagicWeaponDataList, GodWeaponDataList, GhostDataList, MountDataList, WingsDataList]),
%%%%                SysDataList ++ [RobotPlayerData | L]
%%%%            end, [], logic_get_robot_attr_id_list()),
%%%%    lists:sort(RobotAttrList).
%%
%%%% @fun 人物等级
%%role_robot(0) ->
%%    [];
%%role_robot(_Level) ->
%%    [
%%        {?ATTR_HP, 100}, {?ATTR_ATTACK, 100}, {?ATTR_DEFENSE, 100},
%%        {?ATTR_HIT, 0}, {?ATTR_DODGE, 0}, {?ATTR_CRIT, 0}, {?ATTR_RESIST_CRIT, 0}
%%    ].
%%
%%%% @fun 神兵
%%%%god_weapon(RobotAttrId, List, {DataL, AttrL}) ->
%%%%    lists:foldl(
%%%%        fun([Id, Step, Level], {DataL1, AttrL1}) ->
%%%%            #t_god_weapon{
%%%%                property_list = StepProperty
%%%%            } = try_get_t_god_weapon(Id, Step),
%%%%            #t_god_weapon_level{
%%%%                property_list = StarProperty
%%%%            } = try_get_t_god_weapon_level(Id, Level),
%%%%            Data =
%%%%                #db_player_god_weapon{
%%%%                    row_key = {RobotAttrId, Id},
%%%%                    player_id = RobotAttrId,
%%%%                    id = Id,
%%%%                    step = Step,
%%%%                    level = Level,
%%%%                    state = ?STATE_2
%%%%                },
%%%%            {[Data | DataL1], StepProperty ++ StarProperty ++ AttrL1}
%%%%        end, {DataL, AttrL}, List).
%%
%%%% @fun 法宝
%%%%magic_weapon(_RobotAttrId, [], {DataL, AttrL}) ->
%%%%    {DataL, AttrL};
%%%%magic_weapon(RobotAttrId, [[Id, Level, PosId] | L], {DataL, AttrL}) ->
%%%%%%    #t_magic_weapon{
%%%%%%        property_list = StepProperty
%%%%%%    } = t_magic_weapon:get({Id, Step}),
%%%%    #t_magic_weapon_level_2{
%%%%        property_list = StarProperty,
%%%%        appear_property_list = AppearPropertyList1
%%%%    } = try_get_t_magic_weapon_new_level(Id, Level),
%%%%    SmeltAttrList =
%%%%        case logic_get_magic_weapon_smelt_attr_list:get({Id, Level}) of
%%%%            List when is_list(List) ->
%%%%                List;
%%%%            _ ->
%%%%                []
%%%%        end,
%%%%    Data =
%%%%        #db_player_magic_weapon_new{
%%%%            row_key = {RobotAttrId, Id},
%%%%            player_id = RobotAttrId,
%%%%            id = Id,
%%%%            level = Level
%%%%        },
%%%%%%    InitPosId = 1,
%%%%    {DataList, AppearPropertyList} =
%%%%        if
%%%%            PosId > 0 ->
%%%%                {[#db_player_magic_weapon_pos{
%%%%                    row_key = {RobotAttrId, PosId},
%%%%                    player_id = RobotAttrId,
%%%%                    pos_id = PosId,
%%%%                    id = Id
%%%%                }, Data], AppearPropertyList1};
%%%%            true ->
%%%%                {[Data], []}
%%%%        end,
%%%%    magic_weapon(RobotAttrId, L, {DataList ++ DataL, AppearPropertyList ++ StarProperty ++ SmeltAttrList ++ AttrL}).
%%
%%%%%% @fun 玉佩
%%%%jade(RobotAttrId, List, {DataL, AttrL}) ->
%%%%    {NewDataL, {AttrList, RateTuple}} =
%%%%        lists:foldl(
%%%%            fun([JadeId, Level, PosId], {DataL1, {AttrL1, RateTuple1}}) ->
%%%%                #t_jade2{
%%%%                    attr_list = AttrList1,
%%%%                    property_proportion = AddRate
%%%%                } = try_t_new_jade(JadeId, Level),
%%%%                AttrTuple =
%%%%                    if
%%%%                        PosId == 7 ->
%%%%                            {AttrL1, {?ATTR_ADD_RATIO, AddRate}};
%%%%                        true ->
%%%%                            {AttrList1 ++ AttrL1, RateTuple1}
%%%%                    end,
%%%%                {[#db_player_jade{
%%%%                    row_key = {RobotAttrId, PosId},
%%%%                    player_id = RobotAttrId,
%%%%                    pos_id = PosId,
%%%%                    jade_id = JadeId,
%%%%                    level = Level} | DataL1], AttrTuple}
%%%%            end, {DataL, {[], {}}}, List),
%%%%    NewAttrList =
%%%%        if
%%%%            RateTuple == {} ->
%%%%                AttrList;
%%%%            true ->
%%%%                [{AttrList, RateTuple}]
%%%%        end,
%%%%    {NewDataL, NewAttrList ++ AttrL}.
%%
%%%%%% @fun 统一系统
%%%%sys_common(_RobotAttrId, _FunId, 0, {DataL, AttrL}) ->
%%%%    {DataL, AttrL};
%%%%sys_common(RobotAttrId, FunId, StepLevel, {DataL, AttrL}) ->
%%%%    Data =
%%%%        #db_player_sys_common_data{
%%%%            row_key = {RobotAttrId, FunId},
%%%%            player_id = RobotAttrId,
%%%%            fun_id = FunId,
%%%%            step = StepLevel,
%%%%            body_step = StepLevel
%%%%        },
%%%%    #t_promote{
%%%%        property_list = PropertyList
%%%%    } = try_get_t_promote(FunId, StepLevel),
%%%%    {[Data | DataL], PropertyList ++ AttrL}.
%%
%%%% @fun vip等级
%%vip(RobotAttrId, VipLevel, {DataL, AttrL}) ->
%%    Data =
%%        #db_player_vip{
%%            row_key = {RobotAttrId},
%%            player_id = RobotAttrId,
%%            level = VipLevel
%%        },
%%    {[Data | DataL], AttrL}.
%%
%%%%%% @fun 境界
%%%%jing_jie(RobotAttrId, JingJieId, {DataL, AttrL}) ->
%%%%    Data =
%%%%        #db_player_jing_jie{
%%%%            row_key = {RobotAttrId},
%%%%            player_id = RobotAttrId,
%%%%            id = JingJieId
%%%%        },
%%%%    {[Data | DataL], AttrL}.
%%
%%%%%% @fun 主动技能
%%%%active_skill(RobotAttrId, List, {DataL, AttrL}) ->
%%%%    lists:foldl(
%%%%        fun([SkillId, Level], {DataL1, AttrL1}) ->
%%%%            Data =
%%%%                #db_player_active_skill{
%%%%                    row_key = {RobotAttrId, SkillId},
%%%%                    player_id = RobotAttrId,
%%%%                    skill_id = SkillId,
%%%%                    level = Level
%%%%                },
%%%%            #t_active_skill_level_map{
%%%%                attr_list = PropertyList
%%%%            } = try_get_t_active_skill_level_map(SkillId, Level),
%%%%            {[Data | DataL1], PropertyList ++ AttrL1}
%%%%        end, {DataL, AttrL}, List).
%%
%%%% ================================================ 生成机器人数据文件 ================================================
%%
%%%% @doc     生成机器人数据文件
%%create_robot_data_file() ->
%%    io:format("~nStarting build create_robot_file ...~n"),
%%    List = get_robot_sys_data_list(),
%%    Key = robot_data,
%%    {IoList, SysDataList} =
%%        lists:foldl(
%%            fun(Data, {L, SysDataL}) ->
%%                DataName = element(1, Data),
%%                DataKey = element(2, Data),
%%                KeyValue = get(Key),
%%                OldStr =
%%                    if
%%                        DataName =/= KeyValue andalso KeyValue =/= ?UNDEFINED ->
%%%%                            io_lib:format("~s(_) ->~n    #~p{}.~n~n", [KeyValue, KeyValue]);
%%                            io_lib:format("~s(_) ->#~p{}.~n~n", [KeyValue, KeyValue]);
%%%%                            io_lib:format("~s(_) ->~n    exit(null_~p).~n~n", [KeyValue, KeyValue]);
%%                        true ->
%%                            ""
%%                    end,
%%                put(Key, DataName),
%%                {[OldStr ++ io_lib:format("~s(~p) ->~w;~n", [DataName, DataKey, Data]) | L], lists:keydelete(DataName, 1, SysDataL)}
%%%%                {[OldStr ++ io_lib:format("~s(~p) ->~p;~n", [DataName, DataKey, Data]) | L], lists:keydelete(DataName, 1, SysDataL)}
%%            end, {[], ?SYS_DATA_LIST}, List),
%%    KeyValue1 = erase(Key),
%%    ExportStr = export_list(?SYS_DATA_LIST, []),
%%%%        lists:foldl(
%%%%            fun(ExportValue, ExportStr1) ->
%%%%                if
%%%%                    ExportStr1 == [] ->
%%%%                        [io_lib:format("        ~p/1", [ExportValue])];
%%%%                    true ->
%%%%                        [io_lib:format(",~n        ~p/1", [ExportValue]) | ExportStr1]
%%%%                end
%%%%            end, [], lists:sort([KeyValue1 | ExportList])),
%%
%%
%%%%    FinallyList = lists:reverse([io_lib:format("~s(_) ->~n    #~p{}.~n", [SysDataName, SysDataName]) || {SysDataName, _} <- [{KeyValue1, 1} | SysDataList]]) ++ IoList,
%%    FinallyList = lists:reverse([io_lib:format("~s(_) ->#~p{}.~n", [SysDataName, SysDataName]) || {SysDataName, _} <- [{KeyValue1, 1} | SysDataList]]) ++ IoList,
%%%%    FinallyList = [io_lib:format("~s(_) ->~n    #~p{}.~n", [KeyValue1, KeyValue1]) | IoList],
%%%%    FinallyList = [io_lib:format("~s(_) ->~n    exit(null_~p).~n", [KeyValue1, KeyValue1]) | IoList],
%%
%%    HeadStr =
%%        "-module(" ++ ?CREATE_ROBOT_FILE_NAME ++ ").\n"
%%    "-include(\"gen/db.hrl\").\n\n "
%%%%    "-compile(export_all).\n\n",
%%    "-export([\n" ++ ExportStr ++ "]).\n\n",
%%
%%    File = ?CODE_PATH ++ ?CREATE_ROBOT_FILE_NAME ++ ".erl",
%%    util_file:save(File, HeadStr ++ lists:reverse(FinallyList)),
%%    io:format("Create file ~s ~s", [?CREATE_ROBOT_FILE_NAME ++ ".erl", lists:duplicate(max(0, 45 - length(?CREATE_ROBOT_FILE_NAME ++ ".erl")), ".")]),
%%    io:format(" [ok]~n"),
%%    qmake:compilep(File, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH).
%%
%%export_list([], L) ->
%%    L;
%%export_list([{Export, TipStr} | ExportList], L) ->
%%%%    Comment = io_lib:format("~s%% ~s", [lists:duplicate(max(0, 43 - length(Export)), " "), TipStr]),
%%    if
%%        ExportList == [] ->
%%            L ++ [io_lib:format("        ~s/1~s%% ~s\n", [Export, lists:duplicate(max(0, 31 - length(util:to_list(Export))), " "), TipStr])];
%%        true ->
%%            NewL = L ++ [io_lib:format("        ~s/1,~s%% ~s\n", [Export, lists:duplicate(max(0, 30 - length(util:to_list(Export))), " "), TipStr])],
%%            export_list(ExportList, NewL)
%%    end.
%%
%%%% ================================================ 模板操作 ================================================
%%% 获得模板数据
%%try_t_robot(RobotAttrId) ->
%%    Table = t_robot:get({RobotAttrId}),
%%    ?IF(is_record(Table, t_robot), Table, exit({t_robot, {RobotAttrId}})).
%%
%%%% @fun 获得机器人属性列表
%%logic_get_robot_attr_id_list() ->
%%    logic_get_robot_attr_id_list:get(0).
%%
%%%%%%神兵升阶表
%%%%try_get_t_god_weapon(Id, Step) ->
%%%%    T_GodStep = t_god_weapon:get({Id, Step}),
%%%%    ?IF(is_record(T_GodStep, t_god_weapon), T_GodStep, exit({t_god_weapon, {Id, Step}})).
%%%%
%%%%%%神兵升级表
%%%%try_get_t_god_weapon_level(Id, Level) ->
%%%%    T_GodLevel = t_god_weapon_level:get({Id, Level}),
%%%%    ?IF(is_record(T_GodLevel, t_god_weapon_level), T_GodLevel, exit({t_god_weapon_level, {Id, Level}})).
%%
%%%%%% @fun 玩家等级属性
%%%%try_get_t_role_attr(Level) ->
%%%%    Table = t_role_attr:get({Level}),
%%%%    ?IF(is_record(Table, t_role_attr), Table, exit({t_role_attr, {Level}})).
%%
%%%% 法宝等级表
%%%%try_get_t_magic_weapon_new_level(Id, Level) ->
%%%%    Table = t_magic_weapon_level_2:get({Id, Level}),
%%%%    ?IF(is_record(Table, t_magic_weapon_level_2), Table, exit({t_magic_weapon_level_2, {Id, Level}})).
%%
%%%%%% @fun 获得新模板玉佩数据
%%%%try_t_new_jade(JadeId, Level) ->
%%%%    Table = t_jade2:get({JadeId, Level}),
%%%%    ?IF(is_record(Table, t_jade2), Table, exit({null_t_jade2, {JadeId, Level}})).
%%
%%%%%% @fun 功能进阶模板
%%%%try_get_t_promote(FunctionId, StepLevel) ->
%%%%    Table = t_promote:get({FunctionId, StepLevel}),
%%%%    ?IF(is_record(Table, t_promote), Table, exit({t_promote, {FunctionId, StepLevel}})).
%%
%%%%%% @fun 主动技能等级模板
%%%%try_get_t_active_skill_level_map(ActiveSkillId, Level) ->
%%%%    Table = t_active_skill_level_map:get({ActiveSkillId, Level}),
%%%%    ?IF(is_record(Table, t_active_skill_level_map), Table, exit({t_active_skill_level_map, {ActiveSkillId, Level}})).
