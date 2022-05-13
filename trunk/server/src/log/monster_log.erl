%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2021, <COMPANY>
%%% @doc
%%%         战斗功能怪日志
%%% @end
%%% Created : 28. 六月 2021 下午 06:28:12
%%%-------------------------------------------------------------------
-module(monster_log).
-author("Administrator").

-include("gen/table_db.hrl").
-include("scene.hrl").

%% API
-export([]).

-export([
    monster_log/5,

    close_all_monster_log/0
]).

-define(DICT_MONSTER_LOG_LIST, dict_monster_log_list).
-record(monster_log, {
    monster_obj_id,
    monster_id,
    cost,
    award,
    time = 0
}).
-define(LOG_FILE_NAME, fight_monster_log).

%% @doc  怪物日志
monster_log(balance, MonsterObjId, MonsterId, Cost, Award) ->
    #t_monster{
        effect_list = EffectList
    } = mod_scene_monster_manager:get_t_monster(MonsterId),
    Effect = case EffectList of
                 [] ->
                     0;
                 [ThisEffect] ->
                     ThisEffect;
                 [ThisEffect, _] ->
                     ThisEffect
             end,
    LogList =
        [
            {e, Effect},                        %% 怪物类型
            {m, MonsterId, MonsterObjId},       %% 怪物id
            {c, Cost},                          %% 消耗
            {a, Award}                          %% 奖励
        ],
    logger2:write(?LOG_FILE_NAME, LogList);
monster_log(add, MonsterObjId, MonsterId, Cost, Award) ->
    FightFunctionMonsterLogList = util:get_dict(?DICT_MONSTER_LOG_LIST, []),
    NewFightFunctionMonsterLogList =
        case lists:keytake(MonsterObjId, #monster_log.monster_obj_id, FightFunctionMonsterLogList) of
            false ->
                [
                    #monster_log{
                        monster_obj_id = MonsterObjId,
                        monster_id = MonsterId,
                        cost = Cost,
                        award = Award,
                        time = get(?DICT_NOW_MS)
                    }
                    | FightFunctionMonsterLogList];
            {value, OldFightFunctionMonsterLog = #monster_log{cost = OldCost, award = OldAward}, List2} ->
                [OldFightFunctionMonsterLog#monster_log{cost = OldCost + Cost, award = OldAward + Award, time = get(?DICT_NOW_MS)} | List2]
        end,
    put(?DICT_MONSTER_LOG_LIST, NewFightFunctionMonsterLogList);
monster_log(close, MonsterObjId, MonsterId, Cost, Award) ->
    FightFunctionMonsterLogList = util:get_dict(?DICT_MONSTER_LOG_LIST, []),
    case lists:keytake(MonsterObjId, #monster_log.monster_obj_id, FightFunctionMonsterLogList) of
        false ->
            {Cost, Award},
            if
                Cost == 0 andalso Award == 0 ->
                    noop;
                true ->
                    monster_log(balance, MonsterObjId, MonsterId, Cost, Award)
            end;
        {value, #monster_log{cost = OldCost, award = OldAward}, List2} ->
            put(?DICT_MONSTER_LOG_LIST, List2),
            {NewCost, NewAward} =
                {OldCost + Cost, OldAward + Award},
            monster_log(balance, MonsterObjId, MonsterId, NewCost, NewAward)
    end.

%% @doc 关闭所有战斗怪物日志
close_all_monster_log() ->
    FightFunctionMonsterLogList = util:get_dict(?DICT_MONSTER_LOG_LIST, []),
    Now = util_time:milli_timestamp(),
    List = lists:foldl(
        fun(#monster_log{monster_obj_id = MonsterObjId, cost = Cost, award = Award, monster_id = MonsterId, time = Time} = MonsterLog, TmpL) ->
            if
                Now > Time + 120000 ->
                    monster_log(balance, MonsterObjId, MonsterId, Cost, Award),
                    TmpL;
                true ->
                    [MonsterLog | TmpL]
            end
        end,
        [], FightFunctionMonsterLogList
    ),
    put(?DICT_MONSTER_LOG_LIST, List).