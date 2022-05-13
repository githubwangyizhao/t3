%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 六月 2021 下午 04:21:26
%%%-------------------------------------------------------------------
-module(api_skill).
-author("Administrator").

-include("p_enum.hrl").
-include("p_message.hrl").
-include("common.hrl").
-include("skill.hrl").

%% API
-export([
    use_skill/2,                            %% 使用技能
    notice_active_skill_change/2            %% 通知主动技能改变
]).

%% @doc 使用技能
use_skill(
    #m_skill_use_skill_tos{active_skill_id = ActiveSkillId, dir = Dir, params = Params},
    State = #conn{player_id = PlayerId}
) ->
    {Result, PbActiveSkill} =
        case catch mod_charge_skill:use_skill(PlayerId, ActiveSkillId, Dir, Params) of
            {ok, SkillData} ->
                {?P_SUCCESS, pack_skill_data(SkillData)};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), #activeskill{active_skill_id = 0, level = 0, times = 0, next_recover_time = 0, can_use_time = 0}}
        end,
    Out = proto:encode(#m_skill_use_skill_toc{result = Result, active_skill_id = ActiveSkillId, dir = Dir, active_skill = PbActiveSkill}),
    mod_socket:send(Out),
    State.

%% @doc 通知主动技能改变
notice_active_skill_change(PlayerId, ActiveSkillList) ->
    Out = proto:encode(#m_skill_notice_active_skill_change_toc{active_skill_list = [pack_skill_data(SkillData) || SkillData <- ActiveSkillList]}),
    mod_socket:send(PlayerId, Out).

%% @doc 打包技能数据
pack_skill_data(SkillData) ->
    #r_charge_skill{
        skill_id = SkillId,
        times = Times,
        next_recover_time = NextRecoverTime,
        next_use_time = CanUseTime
    } = SkillData,

    #activeskill{
        active_skill_id = SkillId,
        level = 1,
        times = Times,
        next_recover_time = round(NextRecoverTime / 1000),
        can_use_time = round(CanUseTime / 1000)
    }.
