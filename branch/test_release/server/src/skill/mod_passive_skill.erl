%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            被动技能模块
%%% @end
%%% Created : 27. 十一月 2017 上午 1:08
%%%-------------------------------------------------------------------
-module(mod_passive_skill).
-include("gen/db.hrl").
-include("msg.hrl").
-include("gen/table_enum.hrl").
-include("common.hrl").
-include("gen/table_db.hrl").
%% API
-export([
    set_passive_skill/4,
    drop_passive_skill/2,
    delete_passive_skill/2,
    get_all_player_passive_skill/1,
    delete_player_passive_skill_list/1
]).

-export([
    add_tmp_passive_skill/3,
    do_add_tmp_passive_skill/3,
    get_sys_attr_list/1
]).

%% ----------------------------------
%% @doc 	加临时被动技能
%% @throws 	none
%% @end
%% ----------------------------------
add_tmp_passive_skill(PlayerId, PassiveSkillId, Level) ->
    mod_apply:apply_to_online_player(PlayerId, ?MODULE, do_add_tmp_passive_skill, [PlayerId, PassiveSkillId, Level]).

do_add_tmp_passive_skill(PlayerId, PassiveSkillId, Level) ->
    mod_scene:push_player_data_2_scene(PlayerId, [{?MSG_SYNC_PASSIVE_SKILL, PassiveSkillId, Level}]).

%% ----------------------------------
%% @doc 	卸载被动技能
%% @throws 	none
%% @end
%% ----------------------------------
drop_passive_skill(PlayerId, PassiveSkillId) ->
    case get_player_passive_skill(PlayerId, PassiveSkillId) of
        null ->
            ?WARNING("卸载被动技能 技能不存在:~p", [{PassiveSkillId}]);
        PlayerPassiveSkill ->
%%            PlayerPassiveSkill = get_player_passive_skill(PlayerId, PassiveSkillId),
            Tran = fun() ->
                db:write(PlayerPassiveSkill#db_player_passive_skill{
                    is_equip = 0
                }),
                mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_PASSIVE_SKILL, PassiveSkillId, 0}]),
                mod_attr:refresh_player_sys_attr(PlayerId, ?FUNCTION_PASSIVE_SKILL_SYS)
                   end,
            db:do(Tran)
    end.

%% ----------------------------------
%% @doc 	删除被动技能
%% @throws 	none
%% @end
%% ----------------------------------
delete_passive_skill(PlayerId, PassiveSkillId) ->
    case get_player_passive_skill(PlayerId, PassiveSkillId) of
        null ->
            ?WARNING("卸载被动技能 技能不存在:~p", [{PassiveSkillId}]);
        PlayerPassiveSkill ->
%%            PlayerPassiveSkill = get_player_passive_skill(PlayerId, PassiveSkillId),
            Tran = fun() ->
                db:delete(PlayerPassiveSkill),
%%                db:write(PlayerPassiveSkill#db_player_passive_skill{
%%                    is_equip = 0
%%                }),
                mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_PASSIVE_SKILL, PassiveSkillId, 0}]),
                mod_attr:refresh_player_sys_attr(PlayerId, ?FUNCTION_PASSIVE_SKILL_SYS)
                   end,
            db:do(Tran)
    end.

delete_player_passive_skill_list(SkillIdList) ->
    Tran = fun() ->
        lists:foreach(
            fun(SkillId) ->
                db:select_delete(player_passive_skill, [{#db_player_passive_skill{passive_skill_id = SkillId, _ = '_'}, [], ['$_']}])
            end,
            SkillIdList
        )
           end,
    db:do(Tran).

%% ----------------------------------
%% @doc 	设置被动技能
%% @throws 	none
%% @end
%% ----------------------------------
set_passive_skill(PlayerId, PassiveSkillId, Level, _FunctionId) ->
    ?DEBUG("设置被动技能:~p~n", [{PlayerId, PassiveSkillId, Level}]),
    %% 升级被动技能
    PlayerPassiveSkill = try_get_player_passive_skill(PlayerId, PassiveSkillId),
    if PlayerPassiveSkill#db_player_passive_skill.level == Level ->
        noop;
        true ->
            Tran = fun() ->
                NewPlayerPassiveSkill = PlayerPassiveSkill#db_player_passive_skill{
                    level = Level,
                    is_equip = 1
                },
                db:write(NewPlayerPassiveSkill),
%%                if PlayerPassiveSkill#db_player_passive_skill.level == 0 ->
%%                    %% 激活被动技能
%%                    case FunctionId of
%%                        ?FUNCTION_GOD_WEAPON ->
%%                            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_GOD_WEAPON_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1});
%%                        ?FUNCTION_MAGIC_WEAPON ->
%%                            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_MAGIC_WEAPON_SKILL_COUNT, ?CONDITIONS_VALUE_ADD, 1});
%%                        _ ->
%%                            noop
%%                    end;
%%                    true ->
%%                        noop
%%                end,
                mod_scene:tran_push_player_data_2_scene(PlayerId, [{?MSG_SYNC_PASSIVE_SKILL, PassiveSkillId, Level}]),
                mod_attr:refresh_player_sys_attr(PlayerId, ?FUNCTION_PASSIVE_SKILL_SYS)
                   end,
            db:do(Tran)
    end.

try_get_player_passive_skill(PlayerId, ActiveSkillId) ->
    case get_player_passive_skill(PlayerId, ActiveSkillId) of
        null ->
            #db_player_passive_skill{
                player_id = PlayerId,
                passive_skill_id = ActiveSkillId,
                level = 0,
                last_time = 0
            };
        R ->
            R
    end.

%%get_all_player_passive_skill(PlayerId) ->
%%    db:select(?PLAYER_PASSIVE_SKILL, [{#db_player_passive_skill{player_id = PlayerId, _ = '_'}, [], ['$_']}]).

get_all_player_passive_skill(PlayerId) ->
    db_index:get_rows(#idx_player_passive_skill_1{player_id = PlayerId}).

get_player_passive_skill(PlayerId, PassiveSkillId) ->
    db:read(#key_player_passive_skill{player_id = PlayerId, passive_skill_id = PassiveSkillId}).


%% ----------------------------------
%% @doc 	获取技能系统属性列表
%% @throws 	none
%% @end
%% ----------------------------------
get_sys_attr_list(PlayerId) ->
    lists:foldl(
        fun(R, Tmp) ->
            #db_player_passive_skill{
                level = Level,
                passive_skill_id = SkillId
            } = R,
            if Level > 0 ->
                #t_buff{
                    arg_list = ArgList,
                    is_permanent_attr = IsPermanentAttr
                } = t_buff:assert_get({SkillId, Level}),
                if IsPermanentAttr == ?TRUE ->
                    lists:foldl(
                        fun(Arg, Tmp1) ->
                            case Arg of
                                [?EFFECT_TYPE_ATTR, AttrId, Value] ->
                                    [[AttrId, Value] | Tmp1];
                                _ ->
                                    ?WARNING("error permanent attr:~p", [Arg]),
                                    Tmp1
                            end
                        end,
                        [],
                        ArgList
                    ) ++ Tmp;
                    true ->
                        Tmp
                end;
                true ->
                    Tmp
            end
        end,
        [],
        get_all_player_passive_skill(PlayerId)
    ).
