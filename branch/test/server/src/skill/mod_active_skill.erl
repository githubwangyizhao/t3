%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc            主动技能模块
%%% @end
%%% Created : 27. 十一月 2017 上午 1:08
%%%-------------------------------------------------------------------
-module(mod_active_skill).

%% API
-export([
    get_t_active_skill/1,
    get_skill_shift_info/1,
    tran_r_active_skill/2,
    tran_r_active_skill/4,
    tran_r_active_skill_list/0,
    get_t_active_skill_level_map/2,
    clear_r_active_skill/1,
    decode_skill_continue_time/2,

    pack_all_equip_active_skill/1
]).
-include("common.hrl").
-include("skill.hrl").
-include("gen/table_db.hrl").
-include("gen/db.hrl").
-include("error.hrl").
-include("gen/table_enum.hrl").
-include("msg.hrl").
-include("scene.hrl").

%% 玩家普攻列表 {技能id， 技能等级， 技能上次使用时间}
-define(PLAYER_COMMON_SKILL_LIST, [
    {?ACTIVE_SKILL_901, 1, 0},
    {?ACTIVE_SKILL_902, 1, 0},
    {?ACTIVE_SKILL_903, 1, 0},
    {?ACTIVE_SKILL_4, 1, 0},
    {?ACTIVE_SKILL_5, 1, 0}
]).

%% ----------------------------------
%% @doc 	打包所有装备的主动技能(场景用)
%% @throws 	none
%% @end
%% ----------------------------------
pack_all_equip_active_skill(_PlayerId) ->
    ?PLAYER_COMMON_SKILL_LIST.

%% ----------------------------------
%% @doc 	清理主动技能cd
%% @throws 	none
%% @end
%% ----------------------------------
clear_r_active_skill(RActiveSkillList) ->
    [
        RActiveSkill#r_active_skill{
            last_time_ms = 0
        }
        || RActiveSkill <- RActiveSkillList
    ].

tran_r_active_skill_list() ->
    [tran_r_active_skill(SkillId, SkillLevel, LastUseTime, 0) || {SkillId, SkillLevel, LastUseTime} <- ?PLAYER_COMMON_SKILL_LIST].

tran_r_active_skill(SkillId, Level) ->
    tran_r_active_skill(SkillId, Level, 0, 0).
tran_r_active_skill(SkillId, Level, LastTime, Sex) ->
    #t_active_skill{
        is_common_skill = IsCommonSkill,
        skill_type = ActivitySkillType
    } = get_t_active_skill(SkillId),
    RealLevel =
        if
            Level =:= null -> 1;
            true ->
%%                SkillLevelMap = get_t_active_skill_level_map(SkillId, Level),
%%                ?t_assert(SkillLevelMap =/= null, {none_active_skill_level_map, SkillId, Level}),
                Level
        end,
    #r_active_skill{
        id = SkillId,
        level = RealLevel,
        is_common_skill = ?TRAN_INT_2_BOOL(IsCommonSkill),
        skill_type = ActivitySkillType,
        force_wait_time = get_skill_force_wait_time(SkillId, Sex),
        last_time_ms = LastTime
    }.

%% ----------------------------------
%% @doc 	获取主动技能硬直时间
%% @throws 	none
%% @end
%% ----------------------------------
get_skill_force_wait_time(SkillId, Sex) ->
    #t_active_skill{
        continue_time = ContinueTime,
        is_common_skill = IsCommSkill,
        force_wait_time = ForceWaitTime
    } = get_t_active_skill(SkillId),
    if IsCommSkill == ?TRUE ->
        decode_skill_continue_time(ContinueTime, Sex);
        true ->
            ForceWaitTime
    end.

decode_skill_continue_time(S, Sex) ->
    L = string:tokens(S, "|"),
    N = ?IF(Sex == 0, 1, 2),
%%    IsDouble = erlang:length(L) > 1,
    if erlang:length(L) > 1 ->
        S1 = lists:nth(N, L),
        util:to_int(S1);
        true ->
            S1 = lists:nth(1, L),
            util:to_int(S1)
    end.

%%get_t_slot(SlotId) ->
%%    t_skill_slot:get({SlotId}).

%%get_all_skill_slot_id() ->
%%    logic_get_all_skill_slot_id:get(0).

get_skill_shift_info(SkillId) ->
    #t_active_skill{
        skill_res = SkillRes
    } = get_t_active_skill(SkillId),
    case logic_get_skill_shift_info:get(util:to_int(SkillRes)) of
        null ->
            null;
        [] ->
            null;
        L ->
            L
    end.


get_t_active_skill(SkillId) ->
    case t_active_skill:get({SkillId}) of
        null ->
            ?ERROR("no active_skill:~p", [SkillId]),
            exit({no_active_skill, SkillId});
        R ->
            R
    end.

get_t_active_skill_level_map(ActiveSkillId, Level) ->
    case t_active_skill_level_map:get({ActiveSkillId, Level}) of
        null ->
            ?ERROR("no no_active_skill_level_map:~p", [{ActiveSkillId, Level}]),
            exit({no_active_skill_level_map, {ActiveSkillId, Level}});
        R ->
            R
    end.
