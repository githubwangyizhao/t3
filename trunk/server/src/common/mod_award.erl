
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            奖励模块
%%% @end
%%% Created : 27. 五月 2016 下午 3:33
%%%-------------------------------------------------------------------
-module(mod_award).

-include("error.hrl").
-include("client.hrl").
-include("common.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").


-export([
    give/3,
    give/4,
    give_item/6,
    give_apply/3,           %% 进入玩家进程给物品
    give_mail/4,            %% 当背包不足时会发 MailId邮件
    give_no_mail/3,         %% 发奖励不发邮件
    give_ignore/3,          %% 发奖励，背包已满，只给邮件
    decode_award/1,
    decode_award_2/2,
    get_real_num_by_options/3,
    calc_drop_item/2
]).

%% 道具id
-type prop_id() :: integer().
%% 道具
-type prop() :: {prop_id(), integer()}.

%% @doc     当背包不足时会发 MailId邮件
give_mail(PlayerId, MailId, AwardId, LogType) ->
    give_mail(PlayerId, MailId, AwardId, LogType, []).
give_mail(PlayerId, MailId, AwardId, LogType, OptionList) ->
    case get(?DICT_PLAYER_ID) == PlayerId of
        true ->
            give_item(PlayerId, MailId, AwardId, LogType, OptionList, true);
        _ ->
            mod_apply:apply_to_online_player(PlayerId, mod_award, give_item, [PlayerId, MailId, AwardId, LogType, OptionList, true], store)
    end.

give_item(PlayerId, MailId, AwardId, LogType, OptionList, IsMail) when is_integer(AwardId) ->
    give_item(PlayerId, MailId, decode_award(AwardId), LogType, OptionList, IsMail);
give_item(_PlayerId, _MailId, [], _LogType, _OptionList, _IsMail) ->
    noop;
give_item(PlayerId, MailId, ItemList, LogType, OptionList, IsMail) ->
    case mod_prop:check_give(PlayerId, ItemList) of
        true ->
            handle_give(PlayerId, ItemList, LogType, OptionList);
        false ->
            if
                IsMail == true ->
                    mod_mail:add_mail_item_list(PlayerId, MailId, ItemList, LogType);
                IsMail == ignore ->
                    %% 背包已满， 只给资源
                    RealItemList =
                        lists:foldl(
                            fun(Prop, TmpList) ->
                                {ThisPropId, ThisNum} = mod_prop:tran_prop(Prop),
                                #t_item{
                                    type = Type
                                } = mod_item:get_t_item(ThisPropId),
                                if Type == ?IT_RESOURCE ->
                                    [{ThisPropId, ThisNum} | TmpList];
                                    true ->
                                        TmpList
                                end
                            end,
                            [],
                            ItemList
                        ),
                    if RealItemList =/= [] ->
                        handle_give(PlayerId, RealItemList, LogType, OptionList);
%%                                mod_mail:add_mail_item_list(PlayerId, MailId, RealItemList, LogType);
                        true ->
                            noop
                    end;
                true ->
                    exit(?ERROR_NOT_ENOUGH_GRID)
            end
    end.

%% @fun 进入玩家进程给物品
give_apply(PlayerId, AwardId, LogType) ->
    ?ASSERT(is_integer(AwardId) orelse is_list(AwardId), ?ERROR_NOT_EXISTS),
    case get(?DICT_PLAYER_ID) == PlayerId of
        true ->
            give(PlayerId, AwardId, LogType);
        _ ->
            mod_apply:apply_to_online_player(PlayerId, ?MODULE, give, [PlayerId, AwardId, LogType], store)
    end.

%% ----------------------------------
%% @doc 	给奖励
%% @throws 	none
%% @end
%% ----------------------------------
-spec give(PlayerId, AwardId, LogType) -> Prop when
    PlayerId :: integer(),
    AwardId :: list(prop()) | integer() | [integer()],
    LogType :: integer(),
    Prop :: list(prop()).

give(PlayerId, [PropId, PropNum], LogType) when is_integer(PropId) andalso is_integer(PropNum) ->
    give(PlayerId, [{PropId, PropNum}], LogType);
give(PlayerId, AwardId, LogType) ->
    give(PlayerId, AwardId, LogType, []).

give(PlayerId, AwardId, LogType, OptionList) ->
    give_mail(PlayerId, ?MAIL_BAG_FILL, AwardId, LogType, OptionList).

%% ----------------------------------
%% @doc 	给奖励不发邮件
%% @throws 	none
%% @end
%% ----------------------------------
give_no_mail(PlayerId, AwardId, LogType) ->
    give_no_mail(PlayerId, AwardId, LogType, []).
give_no_mail(PlayerId, AwardId, LogType, OptionList) ->
    give_item(PlayerId, ?MAIL_BAG_FILL, AwardId, LogType, OptionList, false),
    ok.

%% ----------------------------------
%% @doc 	给奖励背包满 只给资源
%% @throws 	none
%% @end
%% ----------------------------------
give_ignore(PlayerId, AwardId, LogType) ->
    give_ignore(PlayerId, AwardId, LogType, []).
give_ignore(PlayerId, AwardId, LogType, OptionList) ->
    give_item(PlayerId, ?MAIL_BAG_FILL, AwardId, LogType, OptionList, ignore),
    ok.

handle_give(PlayerId, AwardId, LogType, OptionList) when is_integer(AwardId) ->
    handle_give(PlayerId, decode_award(AwardId), LogType, OptionList);
handle_give(_PlayerId, [], _LogType, _OptionList) -> {[], [], []};
handle_give(PlayerId, PropList, LogType, OptionList) when is_list(PropList) ->
    mod_prop:try_t_log_type(LogType),
    ExpectProps = mod_prop:merge_prop_list(PropList),
    {RealGiveProps, _SrcTransProps, _DestTransProps} = adjust_foldl(fun do_give/3, {[], [], []}, ExpectProps, {PlayerId, LogType, OptionList, false, 2}),
    mod_prop:add_player_prop(PlayerId, RealGiveProps, LogType),
    log_game_award(PlayerId, LogType, RealGiveProps),
%%     ?DEBUG("give item ===> ExpectProps ~w, RealGiveProps ~w , SrcTransProps ~w , DestTransProps ~w ", [ExpectProps, RealGiveProps, _SrcTransProps, _DestTransProps]),
    mod_prop:merge_prop_list(RealGiveProps).

log_game_award(PlayerId, LogType, PropList) ->
    SkipLogTypes = [
        ?LOG_TYPE_CHARGE_GET,
        ?LOG_TYPE_CHARGE_SEND,
        ?LOG_TYPE_SYSTEM_SEND,
        ?LOG_TYPE_COMPOUND_PROP,
        ?LOG_TYPE_SHISHI_BOSS,
        ?LOG_TYPE_GUESS_BOSS,
        ?LOG_TYPE_MANY_PEOPLE_SHISHI
    ],
    case lists:member(LogType, SkipLogTypes) of
        true -> skip;
        false ->
            ?TRY_CATCH(mod_log:add_game_award_log(PlayerId, mod_prop:merge_prop_list(PropList)))
    end.

%% ----------------------------------
%% @doc 	通过option获取最终奖励数量
%% @throws 	none
%% @end
%% ----------------------------------
get_real_num_by_options(_PropId, Num, []) ->
    Num;
get_real_num_by_options(PropId, Num, OptionList) ->
    case util_list:key_find([add_rate, PropId], 1, OptionList) of
        false ->
            Num;
        [_, AddRate] ->
            %% 加倍率
            erlang:trunc(Num * (AddRate + 10000) / 10000)
    end.

do_give(_, {OldGiveList, OldSrcList, DestList}, {_PlayerId, _LogType, _OptionList, _OldIsOverflow, Cnt}) when Cnt < 0 ->      %% 避免道具无限溢出的情况发生
    {OldGiveList, OldSrcList, DestList};
do_give({PropId, Num0}, {OldGiveList, OldSrcList, OldDestList}, {PlayerId, LogType, OptionList, OldIsOverflow, OldCnt}) ->
    Num = get_real_num_by_options(PropId, Num0, OptionList),
    {OverNum, AwardProps, ExtraProps} = do_give_once(PlayerId, PropId, Num, LogType),
    NewGiveProps = OldGiveList ++ AwardProps,
    NewSrcList =
        case OverNum > 0 of     %% 道具溢出
            true -> [{PropId, OverNum} | OldSrcList];
            false -> OldSrcList
        end,
    NewDestList =
        case OldIsOverflow of   %% 由其他道具溢出转化得来
            true -> OldDestList ++ AwardProps;
            false -> OldDestList
        end,
    case ExtraProps of
        [] ->
            {NewGiveProps, NewSrcList, NewDestList};
        _ ->
            NewCnt = ?IF(OverNum > 0, OldCnt - 1, OldCnt),
            NewIsOverflow = OldIsOverflow orelse OverNum > 0,
            adjust_foldl(fun do_give/3, {NewGiveProps, NewSrcList, NewDestList}, ExtraProps, {PlayerId, LogType, OptionList, NewIsOverflow, NewCnt})
    end.

do_give_once(PlayerId, PropId, Num, LogType) ->
    #t_item{
        type = ItemType,
        effect = Parameter,
        special_effect_list = SpecialEffectList
    } = mod_item:get_t_item(PropId),
    case ItemType of
        %% 资源
        ?IT_RESOURCE ->
            case PropId of
                %% 经验
                ?ITEM_EXP ->
                    mod_player:add_exp(PlayerId, Num, LogType),
                    {0, [], []};
                %% VIP经验
                ?ITEM_VIP_EXP ->
                    mod_vip:add_vip_exp(PlayerId, Num, util_time:timestamp(), LogType),
                    {0, [], []};
                %% 金币
                ?ITEM_GOLD ->
                    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_GET_GOLD, ?CONDITIONS_VALUE_ADD, Num}),
                    if
                        LogType == ?LOG_TYPE_FIGHT orelse LogType == ?LOG_TYPE_FUNCTION_MONSTER_FANPAI orelse
                            LogType == ?LOG_TYPE_FUNCTION_MONSTER_LABA orelse LogType == ?LOG_TYPE_FUNCTION_MONSTER_ZHADAN
                            orelse LogType == ?LOG_TYPE_FUNCTION_MONSTER_ZHUANPAN ->
                            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_KILL_GET_GOLD, ?CONDITIONS_VALUE_ADD, Num});
                        true ->
                            noop
                    end,
                    {0, [{PropId, Num}], []};
                %% 钻石
                ?ITEM_RMB ->
                    ServerId = mod_server:get_server_id(),
                    if
                        (ServerId == "s2" orelse ServerId == "s160") andalso ?IS_DEBUG ->
                            case mod_obj_player:get_obj_player(PlayerId) of
                                #ets_obj_player{scene_id = 1006} ->
                                    {0, [{?ITEM_GOLD, Num}], []};
                                _ ->
                                    {0, [{PropId, Num}], []}
                            end;
                        true ->
                            {0, [{PropId, Num}], []}
                    end;
                _ ->
                    {0, [{PropId, Num}], []}
            end;
        %% 物品
        ?IT_ITEM ->
            case PropId of
                ?ITEM_EXP ->
                    mod_player:add_exp(PlayerId, Num, LogType),
                    {0, [], []};
                ?ITEM_ZIDAN ->
                    NewPropId =
                        case mod_obj_player:get_obj_player(PlayerId) of
                            #ets_obj_player{scene_id = SceneId} ->
                                #t_scene{
                                    type = SceneType
                                } = mod_scene:get_t_scene(SceneId),
                                if
                                    SceneType == ?SCENE_TYPE_MATCH_SCENE ->
                                        ?ITEM_JIFEN;
                                    true ->
                                        PropId
                                end;
                            _ ->
                                PropId
                        end,
                    {0, [{NewPropId, Num}], []};
                _ ->
                    {0, [{PropId, Num}], []}
            end;
        ?IT_SYS_COMMON ->
            mod_sys_common:activate_sys_common(PlayerId, PropId),
            {0, [], []};
        %% 英雄部件
        ?IT_HERO_PARTS ->
            mod_hero:unlock_parts(PlayerId, Parameter),
            {0, [], []};
        %% 英雄
        ?IT_HERO ->
            mod_hero:item_unlock_hero(PlayerId, Parameter),
            {0, [], []};
        %% 卡牌图鉴
        ?IT_CARD ->
            {AwardNum, OverNum, AwardProps, ExtraProps} = deal_item_overflow(PlayerId, PropId, Num, Parameter, SpecialEffectList),
            if
                AwardNum > 0 ->
                    mod_card:add_card(PlayerId, PropId, AwardNum);
                true ->
                    skip
            end,
            {OverNum, AwardProps, ExtraProps};
        %% 英雄碎片
        ?IT_HERO_CHIP ->
            {_AwardNum, OverNum, AwardProps, ExtraProps} = deal_item_overflow(PlayerId, PropId, Num, Parameter, SpecialEffectList),
            {OverNum, AwardProps, ExtraProps};
        %% 通行证经验
        ?IT_TONGXINGZHENG_EXP ->
            mod_tongxingzheng:upgrade_level(add_exp, PlayerId, Num),
            {0, [], []};
        %% 自动打开礼包
        ?IT_GIFT_PACKAGE_AUTO ->
            {0, [], mod_award:decode_award(Parameter)};
        %% 时空道具
        ?IT_TIME_ITEM ->
            mod_special_prop:award_special_prop(PlayerId, PropId, Num, LogType),
            {0, [], []};
        _ ->
            {0, [{PropId, Num}], []}
    end.

%% @doc 计算掉落道具
calc_drop_item(_PlayerId, []) ->
    [];
calc_drop_item(PlayerId, PropList) when PlayerId < 10000 ->
    PropList;
calc_drop_item(PlayerId, PropList) ->
    NewPropList = mod_prop:merge_prop_list(PropList),
    Length = length(NewPropList),
    calc_drop_item(PlayerId, [], NewPropList, Length + 300, []).
calc_drop_item(PlayerId, NewPropList, PropList, 0, ConditionList) ->
    exit({prop_error, PlayerId, NewPropList, PropList, ConditionList});
calc_drop_item(_PlayerId, NewPropList, [], _Times, _ConditionList) ->
    mod_prop:merge_prop_list(NewPropList);
calc_drop_item(PlayerId, NewPropList, [{_PropId, 0} | PropList], Times, ConditionList) ->
    calc_drop_item(PlayerId, NewPropList, PropList, Times, ConditionList);
calc_drop_item(PlayerId, NewPropList, [{PropId, PropNum} | PropList], Times, ConditionList) ->
    {AwardProps, ExtraProps, NewConditionList} = do_calc_drop_item(PlayerId, PropId, PropNum, ConditionList),
    calc_drop_item(PlayerId, AwardProps ++ NewPropList, ExtraProps ++ PropList, Times - 1, NewConditionList).
do_calc_drop_item(PlayerId, PropId, PropNum, ConditionList) ->
    #t_item{
        type = ItemType,
        effect = Parameter,
        special_effect_list = SpecialEffectList
    } = mod_item:get_t_item(PropId),
    case ItemType of
        %% 卡牌图鉴
        ?IT_CARD ->
            {AwardProps, ExtraProps, NewConditionList} = do_calc_drop_item_overflow(PlayerId, PropId, PropNum, Parameter, SpecialEffectList, ConditionList),
            {AwardProps, ExtraProps, NewConditionList};
        %% 英雄碎片
%%        ?IT_HERO_CHIP ->
%%            {_AwardNum, _OverNum, AwardProps, ExtraProps} = deal_item_overflow(PlayerId, PropId, PropNum, Parameter, SpecialEffectList),
%%            {AwardProps, ExtraProps};
        _ ->
            {[{PropId, PropNum}], [], ConditionList}
    end.
do_calc_drop_item_overflow(PlayerId, PropId, AddNum, LimitNum, TransAwardList, ConditionList) ->
    {OldTotalNum, ConditionList1} =
        case lists:keyfind(PropId, 1, ConditionList) of
            false ->
                OriTotalNum = mod_conditions:get_player_conditions_data_number(PlayerId, {?CON_ENUM_CUMULATIVE_PROP_NUM, PropId}),  %% 累计获得道具数量
                {OriTotalNum, [{PropId, OriTotalNum} | ConditionList]};
            {_, ConditionNum} ->
                {ConditionNum, ConditionList}
        end,

    NewTotalNum = OldTotalNum + AddNum,

    {AwardNum, OverNum} =
        if
            NewTotalNum > LimitNum ->
                {LimitNum - OldTotalNum, NewTotalNum - LimitNum};
            true ->
                {AddNum, 0}
        end,

    case AwardNum > 0 of
        false ->
            {[], mod_prop:rate_prop(TransAwardList, OverNum), ConditionList1};
        true when OverNum > 0 ->
            {[{PropId, AwardNum}], mod_prop:rate_prop(TransAwardList, OverNum), lists:keyreplace(PropId, 1, ConditionList1, {PropId, OldTotalNum + AwardNum})};
        true ->
            {[{PropId, AddNum}], [], lists:keyreplace(PropId, 1, ConditionList1, {PropId, OldTotalNum + AwardNum})}
    end.

%% ----------------------------------
%% @doc 	处理道具溢出
%% @throws 	none
%% @end
%% ----------------------------------
deal_item_overflow(PlayerId, PropId, AddNum, LimitNum, TransAwardList) ->
    OriTotalNum = mod_conditions:get_player_conditions_data_number(PlayerId, {?CON_ENUM_CUMULATIVE_PROP_NUM, PropId}),  %% 累计获得道具数量
    NewTotalNum = OriTotalNum + AddNum,
    Func =
        fun(N, {TempAwardNum, TempOverNum}) ->
            case N =< LimitNum of
                true -> {TempAwardNum + 1, TempOverNum};
                false -> {TempAwardNum, TempOverNum + 1}
            end
        end,
    {AwardNum, OverNum} = lists:foldl(Func, {0, 0}, lists:seq(OriTotalNum + 1, NewTotalNum)),
    case AwardNum > 0 of
        false -> skip;
        true ->
            mod_conditions:add_conditions(PlayerId, {{?CON_ENUM_CUMULATIVE_PROP_NUM, PropId}, ?CONDITIONS_VALUE_ADD, AwardNum})
    end,
    case OverNum > 0 of
        true when AwardNum > 0 ->   %% 道具溢出
            {AwardNum, OverNum, [{PropId, AwardNum}], mod_prop:rate_prop(TransAwardList, OverNum)};
        true ->
            {AwardNum, OverNum, [], mod_prop:rate_prop(TransAwardList, OverNum)};
        false ->
            {AwardNum, 0, [{PropId, AddNum}], []}
    end.

%% ----------------------------------
%% @doc 	解析奖励组 (多次)
%% @throws 	none
%% @end
%% ----------------------------------
decode_award_2(AwardId, Times) ->
    decode_award_2(AwardId, Times, []).
decode_award_2(_AwardId, Times, PropList) when Times =< 0 ->
    mod_prop:merge_prop_list(PropList);
decode_award_2(AwardId, Times, PropList) ->
    decode_award_2(AwardId, Times - 1, decode_award(AwardId) ++ PropList).

%% ----------------------------------
%% @doc 	解析奖励组
%% @throws 	none
%% @end
%% ----------------------------------
-spec decode_award(integer()) -> list(prop()).
decode_award(0) ->
    [];
decode_award(AwardId) ->
    #t_reward{
        random_reward_list = RandomAwardList,
        weights_reward_list = WeightAwardList
    } = get_t_award(AwardId),
    %% 权重奖励
    if WeightAwardList == [] ->
        [];
        true ->
            [[P], [Min, Max], IsUnique, List] = WeightAwardList,
            case util_random:p(P) of
                true ->
                    %% 随机数量
                    ElementNum = util_random:random_number(Min, Max),
                    get_probability_item_2(List, ?TRAN_INT_2_BOOL(IsUnique), ElementNum);
                false ->
                    []
            end
    end ++
    %% 非权重奖励
    lists:foldl(
        fun([PropId, Num, P], Tmp) ->
            case util_random:p(P) of
                true ->
                    [{PropId, Num} | Tmp];
                false ->
                    Tmp
            end
        end,
        [],
        RandomAwardList
    ).

%% 去重
get_probability_item_2(List, true, ElementNum) when ElementNum > 0 ->
    List_1 = [{PropId, Num, rand:uniform(Rate)} || [PropId, Num, Rate] <- List],
    List_2 = util_list:rkeysort(3, List_1),
    List_3 = lists:sublist(List_2, ElementNum),
    [{PropId, Num} || {PropId, Num, _} <- List_3];
%% 非去重
get_probability_item_2(List, false, ElementNum) when ElementNum > 0 ->
    TotalRate = lists:sum([N || [_, _, N] <- List]),
    ?t_assert(TotalRate > 1, {get_probability_item_2, List, TotalRate}),
    get_probability_item_3(ElementNum, TotalRate, List, []);
get_probability_item_2(_, _, _) ->
    [].


get_probability_item_3(LeftNum, _TotalRate, _List, ResultList) when LeftNum =< 0 ->
    ResultList;
get_probability_item_3(LeftNum, TotalRate, List, ResultList) ->
    RandomRate = rand:uniform(TotalRate),
    {_, Result} = lists:foldl(
        fun([PropId, Num, Rate], {LastRate, E}) ->
            if
                E == null ->
                    ThisRate = LastRate + Rate,
                    if ThisRate >= RandomRate ->
                        {ThisRate, {PropId, Num}};
                        true ->
                            {ThisRate, null}
                    end;
                true ->
                    {LastRate, E}
            end
        end,
        {0, null},
        List
    ),
    get_probability_item_3(LeftNum - 1, TotalRate, List, [Result | ResultList]).

get_t_award(AwardId) ->
    R = t_reward:get({AwardId}),
    ?t_assert(R =/= null, {no_t_award, AwardId}),
    R.

%%%===================================================================
%%% Internal functions
%%%===================================================================
adjust_foldl(F, Acc, [Hd | Tail], Params) ->
    NewAcc = F(Hd, Acc, Params),
    adjust_foldl(F, NewAcc, Tail, Params);
adjust_foldl(F, Acc, [], _Params) when is_function(F, 3) -> Acc.