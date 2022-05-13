%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%         推广
%%% @end
%%% Created : 09. 十二月 2020 下午 12:12:19
%%%-------------------------------------------------------------------
-module(api_promote).
-author("Administrator").

-include("common.hrl").
-include("p_enum.hrl").
-include("p_message.hrl").
-include("gen/db.hrl").

%% API
-export([
    api_get_player_promote_data/1,

    get_promote_record/2,
    get_award/2,
    invitation_code/2,

    notice_player_promote_data/2,
    notice_promote_times/1
]).

%% @doc 获得玩家推广数据
api_get_player_promote_data(PlayerId) ->
    pack_player_promote_data(mod_promote:get_player_promote_data(PlayerId)).

%% @doc 获得推广记录
get_promote_record(
    #m_promote_get_promote_record_tos{},
    #conn{player_id = PlayerId} = State) ->
    DbPromoteRecordList = mod_promote:get_promote_record_list(PlayerId),
    Out = proto:encode(#m_promote_get_promote_record_toc{promote_record_list = pack_promote_record_list(DbPromoteRecordList)}),
    mod_socket:send(Out),
    State.

%% @doc  获得推广奖励
get_award(
    #m_promote_get_award_tos{},
    #conn{player_id = PlayerId} = State) ->
    {Result, Mana, VipExp} =
        case catch mod_promote:get_award(PlayerId) of
            {ok, Mana1, VipExp1} ->
                {?P_SUCCESS, Mana1, VipExp1};
            R ->
                R1 = api_common:api_result_to_enum(R),
                {R1, 0, 0}
        end,
    Out = proto:encode(#m_promote_get_award_toc{result = Result, mana = Mana, vip_exp = VipExp}),
    mod_socket:send(Out),
    State.

%% @doc 邀请码
invitation_code(
    #m_promote_invitation_code_tos{invitation_code = InvitationCode},
    #conn{player_id = PlayerId} = State) ->
    Result = api_common:api_result_to_enum(catch mod_promote:invitation_code(PlayerId, util:to_list(InvitationCode))),
    Out = proto:encode(#m_promote_invitation_code_toc{result = Result}),
    mod_socket:send(Out),
    State.

%% @doc 通知玩家推广数据
notice_player_promote_data(PlayerId, Tuple) ->
    Out = proto:encode(#m_promote_notice_player_promote_data_toc{player_promote_info_data = pack_player_promote_data(Tuple)}),
    mod_socket:send(PlayerId, Out).

%% @doc 通知重置推广次数
notice_promote_times(PlayerId) ->
    Out = proto:encode(#m_promote_notice_promote_times_toc{}),
    mod_socket:send(PlayerId, Out).

%% @doc 封装玩家推广数据
pack_player_promote_data({Times, IsRed, DbPromoteInfoList}) ->
    #playerpromotedata{
        times = Times,
        record_red = IsRed,
        promote_info_list = pack_promote_info_list(DbPromoteInfoList)
    }.

%% @doc 封装推广信息
pack_promote_info_list(DbPromoteInfoList) ->
    [pack_promote_info(DbPromoteInfo) || DbPromoteInfo <- DbPromoteInfoList].
pack_promote_info(DbPromoteInfo) ->
    #db_promote_info{
        level = Level,
        number = Number,
        mana = Mana,
        vip_exp = VipExp
    } = DbPromoteInfo,
    #promoteinfo{
        tier_id = Level,
        number = Number,
        mana = Mana,
        vip_exp = VipExp
    }.

%% @doc 封装推广记录
pack_promote_record_list(DbPromoteRecordList) ->
    [pack_promote_record(DbPromoteRecord) || DbPromoteRecord <- DbPromoteRecordList].
pack_promote_record(DbPromoteRecord) ->
    #db_promote_record{
        real_id = RealId,
        id = Id,
        param = ParamList,
        time = Time
    } = DbPromoteRecord,
    #promoterecord{
        real_id = RealId,
        id = Id,
        param_list = [util:to_binary(Param) || Param <- util_string:string_to_list_term(ParamList)],
        time = Time
    }.