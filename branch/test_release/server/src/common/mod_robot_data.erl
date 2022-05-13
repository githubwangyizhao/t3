%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc
%%% Created : 07. 二月 2018 16:29
%%%-------------------------------------------------------------------
-module(mod_robot_data).
-author("home").

%%%% API
%%-export([
%%    try_get_robot_sys_data_attr_id/1,   %% 获得机器人属性id
%%    get_robot_player_data/1,            %% 获得机器人玩家数据
%%    get_robot_active_skill_list/1,      %% 获得机器人主动技能列表
%%    logic_get_robot_id_list/0,          %% 获得机器人id 列表
%%    create_robot_player/0,              %% 创建机器人玩家
%%    clear_all_robot_player/0            %% 清空全部机器人数据
%%%%    create_robot_data_file/0,       %% 生成机器人数据文件
%%%%    get_robot_sys_data_list/0       %% 获得机器人系统数据
%%]).
%%
%%-include("error.hrl").
%%-include("common.hrl").
%%-include("gen/db.hrl").
%%-include("server_data.hrl").
%%-include("gen/table_db.hrl").
%%
%%-define(CREATE_ROBOT_FILE_NAME, "robot_data_info").           % 生机器人数据的文件名
%%-define(CREATE_ROBOT_LOOP_LIMIT, 50).                          % 创建机器人循环次数上限
%%
%%%% @fun 获得机器人属性id
%%try_get_robot_sys_data_attr_id(PlayerId) ->
%%    Table = t_arena:get({PlayerId}),
%%    ?ASSERT(is_record(Table, t_arena), ?ERROR_NOT_EXISTS),
%%%%    RobotPlayer = get_robot_player_data(PlayerId),
%%%%    ?ASSERT(is_record(RobotPlayer, db_robot_player_data), ?ERROR_NOT_EXISTS),
%%    Table#t_arena.robot_attr_id.
%%
%%%% @fun 获得机器人主动技能列表
%%get_robot_active_skill_list(PlayerId) ->
%%    RobotAttrId = try_get_robot_sys_data_attr_id(PlayerId),
%%    #t_robot{
%%        skill_list = ActiveSkillList
%%    } = robot_data:try_t_robot(RobotAttrId),
%%    [ActiveSkillId || [ActiveSkillId, _] <- ActiveSkillList].
%%
%%%% @fun 创建机器人玩家
%%create_robot_player() ->
%%    List = logic_get_robot_id_list(),
%%    ServerId = hd(mod_server:get_server_id_list()),
%%    Tran =
%%        fun() ->
%%            CreatePlayerIdList = create_robot_player(List, ServerId, []),
%%            CreatePlayerIdList
%%        end,
%%    db:do(Tran).
%%create_robot_player([], _ServerId, CreateList) ->
%%    CreateList;
%%create_robot_player([PlayerId | List], ServerId, CreateList1) ->
%%    CreateList = create_robot_player1(PlayerId, ServerId, ?CREATE_ROBOT_LOOP_LIMIT),
%%    create_robot_player(List, ServerId, CreateList ++ CreateList1).
%%%% 创建机器人玩家   PlayerId:名次和玩家id 一致
%%create_robot_player1(_PlayerId, _ServerId, 0) ->
%%    [];
%%create_robot_player1(PlayerId, ServerId, Count) ->
%%    case get_robot_player_data(PlayerId) of
%%        RobotPlayer when is_record(RobotPlayer, db_robot_player_data) ->
%%%%            ?DEBUG("已存在机器人:~p",[PlayerId]),
%%            [];
%%        _ ->
%%            {Sex, NickName} = random_name:get_name(),
%%            case mod_player:get_player_list_by_nickname(NickName) of
%%                [] ->
%%%%                    #t_arena{
%%%%                        arena_rank = ArenaRank,
%%%%                        heart_mission_id = _HeartMissionId
%%%%                    } = try_get_t_arena(PlayerId),
%%                    db:write(#db_robot_player_data{player_id = PlayerId, nickname = NickName, sex = Sex, server_id = ServerId}),
%%%%                    NewArenaRank = ?IF(mod_arena:get_index_player_arena_1(ArenaRank) == [], ArenaRank, 0),
%%%%                    if
%%%%                        ArenaRank > 0 andalso NewArenaRank > 0 ->
%%%%                            PlayerArenaInit = mod_arena:get_player_arena_init(PlayerId),
%%%%                            db:write(PlayerArenaInit#db_player_arena{rank = NewArenaRank});
%%%%                        true ->
%%%%                            noop
%%%%                    end
%%%%                    ,
%%%%                    if
%%%%                        HeartMissionId > 0 ->
%%%%                            mod_heart:enter_heart_rank(PlayerId, HeartMissionId);
%%%%                        true ->
%%%%                            noop
%%%%                    end,
%%                    [PlayerId];
%%                _ ->
%%                    create_robot_player1(PlayerId, ServerId, Count - 1)
%%            end
%%    end.
%%
%%%% @fun 清空全部机器人数据
%%clear_all_robot_player() ->
%%    Tran =
%%        fun() ->
%%            db:delete_all(robot_player_data),
%%            io:format("清空全部机器人数据:~p~n",[ets:tab2list(robot_player_data)]),
%%            create_robot_player()
%%        end,
%%    db:do(Tran).
%%
%%
%%
%%%%%% @fun 获得机器人系统数据
%%%%get_robot_sys_data_list() ->
%%%%    RobotAttrList =
%%%%        lists:foldl(
%%%%            fun(RobotAttrId, L) ->
%%%%                #t_robot{
%%%%                    level = Level,                          % 人物等级
%%%%                    equip_list = EquipList,                 % 装备列表
%%%%                    magic_weapon_list = MagicWeaponList,    % 法宝列表
%%%%                    god_weapon_list = GodWeaponList,        % 神兵列表
%%%%                    ghost_step = GhostStep,                 % 妖灵阶级
%%%%                    mount_step = MountStep                  % 坐骑阶级
%%%%                } = try_t_robot(RobotAttrId),
%%%%                {EquipDataList, EquipAttrList} = mod_equip:robot_get_sys_attr_list(RobotAttrId, EquipList),
%%%%                {MagicWeaponDataList, MagicWeaponAttrList} = mod_magic_weapon:robot_get_sys_attr_list(RobotAttrId, MagicWeaponList),
%%%%                {GodWeaponDataList, GodWeaponAttrList} = mod_god_weapon:robot_get_sys_attr_list(RobotAttrId, GodWeaponList),
%%%%                {GhostDataList, GhostAttrList} = mod_ghost:robot_get_sys_attr_list(RobotAttrId, GhostStep),
%%%%                {MountDataList, MountAttrList} = mod_mount:robot_get_sys_attr_list(RobotAttrId, MountStep),
%%%%                AttrList = mod_player:robot_get_sys_attr_list(Level) ++ EquipAttrList ++ MagicWeaponAttrList ++ GodWeaponAttrList ++ GhostAttrList ++ MountAttrList,
%%%%                RobotPlayerData = mod_attr:robot_get_sys_attr_list(RobotAttrId, {Level}, AttrList),
%%%%                SysDataList = lists:append([EquipDataList, MagicWeaponDataList, GodWeaponDataList, GhostDataList, MountDataList]),
%%%%                SysDataList ++ [RobotPlayerData | L]
%%%%            end, [], logic_get_robot_attr_id_list()),
%%%%    lists:sort(RobotAttrList).
%%%%
%%%%%% @doc     生成机器人数据文件
%%%%create_robot_data_file() ->
%%%%    List = get_robot_sys_data_list(),
%%%%    HeadStr =
%%%%        "-module(" ++ ?CREATE_ROBOT_FILE_NAME ++ ").\n"
%%%%    "-include(\"gen/db.hrl\").\n\n "
%%%%    "-compile(export_all).\n\n",
%%%%    Key = robot_data,
%%%%    IoList =
%%%%        lists:foldl(
%%%%            fun(Data, L) ->
%%%%                DataName = element(1, Data),
%%%%                DataKey = element(2, Data),
%%%%                KeyValue = get(Key),
%%%%                OldStr =
%%%%                    if
%%%%                        DataName =/= KeyValue andalso KeyValue =/= ?UNDEFINED ->
%%%%                            io_lib:format("~s(_) ->~n    #~p{}.~n~n", [KeyValue, KeyValue]);
%%%%                        true ->
%%%%                            ""
%%%%                    end,
%%%%                put(Key, DataName),
%%%%                [OldStr ++ io_lib:format("~s(~p) ->~n    ~p;~n", [DataName, DataKey, Data]) | L]
%%%%            end, [], List),
%%%%    KeyValue1 = erase(Key),
%%%%    FinallyList = [io_lib:format("~s(_) ->~n    #~p{}.~n", [KeyValue1, KeyValue1]) | IoList],
%%%%    File = ?CODE_PATH ++ ?CREATE_ROBOT_FILE_NAME ++ ".erl",
%%%%    util_file:save(File, HeadStr ++ lists:reverse(FinallyList)),
%%%%    qmake:compilep(File, ?COMPILE_INCLUDE_PATH, ?COMPILE_OUT_PATH).
%%
%%
%%%% ================================================ 数据操作 ================================================
%%%% @fun 获得机器人玩家数据
%%get_robot_player_data(PlayerId) ->
%%    db:read(#key_robot_player_data{player_id = PlayerId}).
%%
%%
%%%% ================================================ 模板操作 ================================================
%%%% @fun 获得机器人id 数据
%%try_get_t_arena(RobotId) ->
%%    Table = t_arena:get({RobotId}),
%%    ?IF(is_record(Table, t_arena), Table, exit({t_arena, {RobotId}})).
%%
%%%% @fun 获得机器人id列表
%%logic_get_robot_id_list() ->
%%    logic_get_arena_rank_list:get(0).
