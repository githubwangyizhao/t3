%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 一月 2021 下午 03:34:28
%%%-------------------------------------------------------------------
-module(mod_robot_player_scene_cache).
-author("Administrator").

-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_enum.hrl").
-include("gen/table_db.hrl").
-include("error.hrl").
-include("p_enum.hrl").
-include("scene.hrl").
-include("server_data.hrl").


%% API
-export([
    update/1,
    handle_update/1,

    get_robot_obj/1
]).

update(ObjActor) ->
    scene_robot_srv:cast({update, ObjActor}).
handle_update(ObjActor) ->
    #obj_scene_actor{
        obj_id = ObjId,
        server_id = ServerId,
        level = Level,
        surface = Surface
    } = ObjActor,
    DbRobotPlayerSceneCache =
        case get_db_robot_player_scene_cache_by_player_id(ObjId) of
            [] ->
                Id = mod_server_data:get_int_data(?SERVER_DATA_ROBOT_PLAYER_SCENE_CACHE_ID),
                NewId = if
                            Id >= 100 ->
                                1;
                            true ->
                                Id + 1
                        end,
                mod_server_data:set_int_data(?SERVER_DATA_ROBOT_PLAYER_SCENE_CACHE_ID, NewId),
                (get_db_robot_player_scene_cache(NewId));
            [DbRobotPlayerSceneCache1] ->
                DbRobotPlayerSceneCache1
        end,
    #surface{
        title_id = TitleId,
        magic_weapon_id = MagicWeaponId
    } = Surface,
    Tran =
        fun() ->
            db:write(DbRobotPlayerSceneCache#db_robot_player_scene_cache{
                player_id = ObjId,
                server_id = ServerId,
                level = Level,
                title_id = TitleId,
                magic_weapon_id = MagicWeaponId
            })
        end,
    db:do(Tran),
    ok.

get_robot_obj(_SceneId) ->
    null.
%%    case random_get() of
%%        null ->
%%            null;
%%        DbRobotPlayerSceneCache ->
%%            #db_robot_player_scene_cache{
%%                id = RobotId,
%%                server_id = ServerId,
%%                level = Level,
%%                clothe_id = ClotheId,
%%                title_id = TitleId,
%%                magic_weapon_id = MagicWeaponId,
%%%%        weapon_id = _WeaponId,
%%                wings_id = WingsId,
%%                shen_long_type = ShenLongType
%%            } = DbRobotPlayerSceneCache,
%%            {Sex, RandomName} = random_name:get_name(),
%%            {BirthX, BirthY} = mod_scene:get_scene_birth_pos(SceneId),
%%            NickName = ServerId ++ "." ++ RandomName,
%%            Length = length(?SD_SHISHI_ROBOT_MANA_WEAPON),
%%            RandomCostMana = lists:nth(util_random:random_number(Length), ?SD_SHISHI_ROBOT_MANA_WEAPON),
%%
%%            #t_mana_weapon{
%%                weapon_id = WeaponId
%%            } = t_mana_weapon:assert_get({RandomCostMana}),
%%
%%            Surface = #surface{
%%                clothe_id = ClotheId,
%%                title_id = TitleId,
%%                magic_weapon_id = MagicWeaponId,
%%                weapon_id = WeaponId,
%%                wings_id = WingsId,
%%                shen_long_type = ShenLongType
%%            },
%%            #obj_scene_actor{
%%                key = {?OBJ_TYPE_PLAYER, RobotId},
%%                obj_type = ?OBJ_TYPE_PLAYER,
%%                obj_id = RobotId,
%%                client_worker = null,
%%                level = Level,
%%
%%                r_active_skill_list = lists:map(
%%                    fun({SkillId, SkillLevel, _}) ->
%%                        mod_active_skill:tran_r_active_skill(SkillId, SkillLevel, 0, Sex)
%%                    end,
%%                    [{901, 1, 0}, {902, 1, 0}, {903, 1, 0}, {4, 1, 0}]
%%                ),
%%                move_path = [],
%%                nickname = list_to_binary(NickName),
%%                is_robot = true,
%%                x = BirthX,
%%                y = BirthY,
%%                sex = Sex,
%%                grid_id = ?PIX_2_GRID_ID(BirthX, BirthY),
%%                dir = 4,
%%                max_hp = 100,
%%                hp = 100,
%%                surface = Surface,
%%                init_move_speed = ?SD_INIT_SPEED,
%%                move_speed = ?SD_INIT_SPEED,
%%                track_info = #track_info{},
%%                subscribe_list = mod_scene_grid_manager:get_subscribe_grid_id_list_by_px(600, 600),
%%                robot_data = #robot_data{
%%                    robot_fight_cost_mana = RandomCostMana
%%                }
%%            }
%%    end.
%%random_get() ->
%%    DbRobotPlayerSceneCacheList = get_db_robot_player_scene_cache_list(),
%%    if
%%        DbRobotPlayerSceneCacheList =:= [] ->
%%            null;
%%        true ->
%%            List = lists:sort(
%%                fun(A, B) ->
%%                    #db_robot_player_scene_cache{
%%                        level = LevelA
%%                    } = A,
%%                    #db_robot_player_scene_cache{
%%                        level = LevelB
%%                    } = B,
%%                    LevelA > LevelB
%%                end,
%%                DbRobotPlayerSceneCacheList
%%            ),
%%            Length = length(List),
%%            if
%%                Length >= 100 ->
%%                    lists:nth(util_random:random_number(1, 80), lists:nthtail(20, DbRobotPlayerSceneCacheList));
%%                true ->
%%                    lists:nth(util_random:random_number(1, Length), DbRobotPlayerSceneCacheList)
%%            end
%%    end.

%% ================================================ 数据操作 ================================================

get_db_robot_player_scene_cache(Id) ->
    case db:read(#key_robot_player_scene_cache{id = Id}) of
        null ->
            #db_robot_player_scene_cache{
                id = Id
            };
        R ->
            R
    end.

%%get_db_robot_player_scene_cache_list() ->
%%    ets:tab2list(robot_player_scene_cache).

get_db_robot_player_scene_cache_by_player_id(PlayerId) ->
    db_index:get_rows(#idx_robot_player_scene_cache_1{player_id = PlayerId}).
