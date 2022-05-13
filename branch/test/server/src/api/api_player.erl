%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc
%%% @end
%%% Created : 27. 五月 2016 下午 3:39
%%%-------------------------------------------------------------------
-module(api_player).
-include("common.hrl").
-include("p_message.hrl").
-include("gen/db.hrl").
-include("gen/table_db.hrl").
-include("gen/table_enum.hrl").
-include("p_enum.hrl").
-include("error.hrl").
-include("player_game_data.hrl").
-include("scene.hrl").

-export([
    test_visitor_binding/3,         %% 测试用，游客绑定第三方授权账号
    visitor_binding/2,              %% 游客绑定第三方授权账号
    customer_url/2,                 %% 获取客服链接
    adjust/2,                       %% adjust的统计数据
    change_pk_mode/2,               %% 修改pk模式
%%    get_fun_award/2,                %%领取功能奖励
    change_name/2,                  %% 改名
    change_sex/2,                   %% 改性别
    get_player_attr/2,              %% 获得玩家属性数据
    update_client_data/2,           %% 更新客户端数据
    delete_client_data/2,           %% 删除客户端数据
    get_server_time/2,              %% 获得服务器时间
    set_player_data/2,
    collect_delay_rewards/2,
    level_upgrade/2,                %% 升级
    get_level_award/2,              %% 获得等级奖励
    send_level_upgrade/5,
    update_player_signature/2,      %% 更新玩家签名
    get_player_info/2,               %% 获得玩家信息
    world_tree_award/2              %% 领取世界树奖励
]).
%% API
-export([
    pack_model_head_figure/1,       %% 玩家头像模型
    pack_model_head_figure/7,       %% 打包玩家头像模型
    pack_model_figure/1,            %% 打包模型外观
    pack_player_other_data/3,       %% 打包玩家其他数据
    pack_player_base_data/1,        %% 打包玩家基础信息数据
    init_player_data/1,             %% 通知玩家初始化数据
    notice_player_attr_change/2,    %% 通知属性变化(整形)
    notice_player_string_attr_change/2,%% 通知属性变化(字符串)
    notice_function_active/2,        %% 通知功能开启
%%    notice_offline_award/3          %% 处理离线奖励
    notice_server_time/2,           %% 通知服务器时间（毫秒）
    notice_player_xiu_zhen_value/2  %% 通知玩家修正值
]).

-export([
    tran_attr_change/1,
    tran_string_attr_change/1
]).

%%-export([
%%    notice_player_adjust_value/1
%%]).

-export([
    modify_nickname_gender/2        %% 自动创角的玩家修改昵称与性别
]).
-export([
    bind_mobile/2,
    test_bind_mobile/3
]).

-include("p_message.hrl").

%% ----------------------------------
%% @doc 	通知初始化数据
%% @throws 	none
%% @end
%% ----------------------------------
init_player_data(State = #conn{player_id = PlayerId, sender_worker = SenderWorker}) ->
%%    ?DEBUG("~p~n ", [mod_player:get_player(PlayerId)]),
    #db_player{
        nickname = Nickname,
        sex = Sex,
        server_id = ServerId,
        type = Type,
        acc_id = AccId
    } = mod_player:get_player(PlayerId),
    #db_player_data{
        level = Level,
        exp = Exp,
        fight_mode = PkMode,
%%        anger = Anger,
        head_id = HeadId,
        head_frame_id = HeadFrameId,
        chat_qi_pao_id = ChatQiPaoId
    } = mod_player:get_db_player_data(PlayerId),
    VipLevel = mod_vip:get_vip_level(PlayerId),
    RoleData = #roledata{
        player_id = PlayerId,
        nickname = list_to_binary(Nickname),
        sex = Sex,
        level = Level,
        exp = Exp,
        vip_level = VipLevel,
        server_id = ServerId,
        type = Type,
        player_other_data = pack_player_other_data(HeadId, HeadFrameId, ChatQiPaoId)
    },
    Mobile = mod_verify_code:get_mobile_from_center(AccId),
    {FunIdList, AwardFunList, RedList} = mod_function:get_init_function_data(PlayerId),
    Out =
        proto:encode(#m_player_init_player_data_toc{
            role_data = RoleData,
            server_time = util:to_list(util_time:milli_timestamp()),
            fun_id_list = FunIdList,
            prop_list = api_prop:pack_all_player_prop_list(PlayerId),
            times_list = api_times:pack_all_player_times_list(PlayerId),
            passed_mission_list = api_mission:pack_passed_mission_list(PlayerId),
            client_data_list = api_get_player_client_data_list(PlayerId),
            mail_real_id = mod_mail:get_player_mail_unread_list(PlayerId),
            sysCommonDataList = api_sys_common:init_player_sys_data(PlayerId),
            award_fun_id_list = AwardFunList,
            red_fun_id_list = RedList,
            activity_data = api_activity:pack_init_activity_info(PlayerId),
            achievement_data_list = api_achievement:api_get_achievement_data_list(PlayerId),
            first_charge_state = first_recharge:get_first_recharge_state(PlayerId),
            vip_data = api_vip:api_get_info(PlayerId),
            seven_login_data = api_seven_login:api_get_seven_login_data(PlayerId),
%%            online_award_data = api_activity:api_get_online_award_info(PlayerId),
            everyday_sign_data = api_everyday_sign:api_get_everyday_sign_info(PlayerId),
            open_server_time = mod_server_config:get_server_open_time(),
            collect_state = mod_platform_function:get_collect_game_state(PlayerId),
            share_count = mod_platform_function:get_share_count(PlayerId),
            share_friend_data = mod_platform_function:get_share_friend_list(PlayerId),
            charge_shop_data = api_charge:api_get_charge_shop_data(PlayerId),
            pk_mode = PkMode,
            anger = 0,
            platform_concern_state = mod_platform_function:get_concern_award_state(PlayerId),
            platform_certification_state = mod_platform_function:get_certification_award_state(PlayerId),
%%            daily_task_data_list = api_daily_task:api_get_daily_task_data_list(PlayerId),
            task_show = mod_daily_task:init_task_show(PlayerId),
            player_promote_data = api_promote:api_get_player_promote_data(PlayerId),
            task_info = api_task:pack_task_info(PlayerId),
%%            invitation_code = util:to_binary("https://play.google.com/store/apps/details?id=com.aaagame.sjlstw"),
            %% 通过adjust跳转至谷歌应用商店的链接 https://app.adjust.com/d5pb1ye?campaign=llnHM&adgroup=llnHM&creative=llnHM&redirect=https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dcom.ashram.t3
            invitation_code = util:to_binary("https://play.google.com/store/apps/details?id=com.ashram.t3"),
%%            invitation_code = util:to_binary("https://www.props-trader.com/share/index.html?invitation=" ++ util_unique_invitation_code:encode(PlayerId)),
            share_task_award_data_list = api_platform_function:api_get_share_task_info(PlayerId, 1),
            player_hero = api_hero:api_get_player_hero(PlayerId),
            card_book_list = api_card:api_get_card_book_list(PlayerId),
            %% 暂时写死，待配表
%%            seize_treasure_type_id = 1
            seize_treasure_type_id = mod_seize_treasure:seize_type(),
            seize_times = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_TIMES),
            seize_lucky_value = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_SEIZE_LUCK_VALUE),
            zhi_gou_completed = mod_charge:check_zhi_gou_completed(PlayerId),
            bind_mobile = ?IF(Mobile =:= "0" orelse Mobile =:= failure, "0", util:to_list(Mobile)),
            already_give_level = mod_player_game_data:get_int_data(PlayerId, ?PLAYER_GAME_DATA_LEVEL_AWARD_ALREADY),
            signature = util:to_binary(mod_player_game_data:get_str_data(PlayerId, ?PLAYER_GAME_DATA_SIGNATURE))
        }),
    ?DEBUG("Len:~p", [size(Out)]),
%%    ?DEBUG("初始化数据 : ~p",[Out]),
    client_sender_worker:send(SenderWorker, Out),
    State.

%% ----------------------------------
%% @doc 	修改pk模式
%% @throws 	none
%% @end
%% ----------------------------------
change_pk_mode(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_player_change_pk_mode_tos{pk_mode = PkMode} = Msg,
    Result =
        try mod_player:change_pk_mode(PlayerId, PkMode) of
            _ ->
                ?P_SUCCESS
        catch
            _:Reason ->
                ?ERROR("设置pk模式失败:~p", [Reason]),
                ?P_FAIL
        end,
    Out =
        proto:encode(#m_player_change_pk_mode_toc{
            pk_mode = PkMode,
            result = Result
        }),
    mod_socket:send(PlayerId, Out),
    State.

%% ----------------------------------
%% @doc 	玩家绑定手机号码
%% @throws 	none
%% @end
%% ----------------------------------
bind_mobile(
    #m_player_bind_mobile_tos{code = Code, mobile = Mobile},
    State = #conn{player_id = PlayerId}
) ->
    Out =
        case catch mod_verify_code:verify_code(Mobile, 1, Code) of
            {'EXIT', Err} ->
                ?ERROR("error: ~p", [Err]),
                case Err of
                    ?P_INVALID_MOBILE -> #m_player_bind_mobile_toc{result = ?P_INVALID_MOBILE};
                    ?P_INVALID_CODE -> #m_player_bind_mobile_toc{result = ?P_INVALID_CODE};
                    ?P_EXPIRE -> #m_player_bind_mobile_toc{result = ?P_EXPIRE};
                    _ -> #m_player_bind_mobile_toc{result = ?P_FAIL}
                end;
            ok ->
                #db_player{acc_id = AccId} = mod_player:get_player(PlayerId),
                PlatformId = mod_server_config:get_platform_id(),
                GiveAward =
                    case mod_server_rpc:call_center(mod_global_account, get_mobile, [PlatformId, AccId]) of
                        "0" -> true;
                        _ -> false
                    end,
                Tran =
                    fun() ->
                        %% 下发奖励
                        if
                            GiveAward =:= true ->
                                mod_award:give(PlayerId, ?SD_BIND_PHONE_REWARD_LIST, ?LOG_TYPE_BIND_MOBILE);
                            true -> false
                        end,
                        %% 修改中心服
                        case mod_server_rpc:call_center(mod_global_account, update_mobile, [PlatformId, AccId, util:to_list(Mobile)]) of
                            failure -> exit(failure);
                            ok -> ok
                        end
                    end,
                try
                    db:do(Tran),
                    #m_player_bind_mobile_toc{result = ?P_SUCCESS}
                catch
                    Err: Reason ->
                        ?ERROR("db:do failure: ~p", [{Err, Reason}]),
                        #m_player_bind_mobile_toc{result = ?P_FAIL}
                end
        end,
    ?DEBUG("Out: ~p", [Out]),
    mod_socket:send(proto:encode(Out)),
    State.

test_bind_mobile(PlayerId, Mobile, Code) ->
    Out =
        case catch mod_verify_code:verify_code(Mobile, 1, Code) of
            {'EXIT', Err} ->
                ?ERROR("error: ~p", [Err]),
                case Err of
                    ?P_INVALID_MOBILE -> #m_player_bind_mobile_toc{result = ?P_INVALID_MOBILE};
                    ?P_INVALID_CODE -> #m_player_bind_mobile_toc{result = ?P_INVALID_CODE};
                    ?P_EXPIRE -> #m_player_bind_mobile_toc{result = ?P_EXPIRE};
                    _ -> #m_player_bind_mobile_toc{result = ?P_FAIL}
                end;
            ok ->
                #db_player{acc_id = AccId} = mod_player:get_player(PlayerId),
                PlatformId = mod_server_config:get_platform_id(),
                case catch mod_server_rpc:call_center(mod_global_account, update_mobile, [PlatformId, AccId, Mobile]) of
                    failure -> #m_player_bind_mobile_toc{result = ?P_FAIL};
                    ok -> #m_player_bind_mobile_toc{result = ?P_SUCCESS}
                end
        end,
    ?DEBUG("Out: ~p", [Out]).

%% ----------------------------------
%% @doc 	自动创角玩家修改自己的昵称与性别
%% @throws 	none
%% @end
%% ----------------------------------
modify_nickname_gender(
    #m_player_modify_nickname_gender_tos{
        nickname = Nickname,
        gender = Gender
    },
    State = #conn{player_id = PlayerId}
) ->
    Result =
        case catch mod_player:modify_nickname_gender(PlayerId, util:to_list(Nickname), util:to_int(Gender)) of
            ok -> ?P_SUCCESS;
            {'EXIT', ?P_NOT_AUTHORITY} -> ?P_NOT_AUTHORITY;
            {'EXIT', ?ERROR_NAME_USED} -> ?P_USED;
            {'EXIT', ?ERROR_INVAILD_NAME} -> ?P_INVALID_STRING;
            {'EXIT', ?ERROR_NAME_TOO_LONG} -> ?P_TOO_LONG;
            {'EXIT', _} -> ?P_FAIL;
            Other -> ?ERROR("自动创角玩家第一次修改性别与昵称报错: ~p", [Other]), ?P_UNKNOWN
        end,
    Out = proto:encode(#m_player_modify_nickname_gender_toc{result = Result, gender = Gender, nickname = Nickname}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	改名
%% @throws 	none
%% @end
%% ----------------------------------
change_name(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_player_change_name_tos{name = Name} = Msg,
    Result =
        try mod_player:change_name(PlayerId, util:to_list(Name)) of
            _ ->
                ?P_SUCCESS
        catch
            _:?ERROR_NAME_USED ->
                ?P_USED;
            _:?ERROR_INVAILD_NAME ->
                ?P_INVALID_STRING;
            _:?ERROR_NAME_TOO_LONG ->
                ?P_TOO_LONG;
            _:?ERROR_NOT_ENOUGH_TIMES ->
                ?P_NOT_ENOUGH_TIMES;
            _:Other ->
                ?ERROR("change_name:~p", [{Other, erlang:get_stacktrace()}]),
                ?P_FAIL
        end,
    Out = proto:encode(#m_player_change_name_toc{result = Result, name = Name}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	改性别
%% @throws 	none
%% @end
%% ----------------------------------
change_sex(
    Msg,
    State = #conn{player_id = PlayerId}
) ->
    #m_player_change_sex_tos{sex = Sex} = Msg,
    Result =
        try mod_player:change_sex(PlayerId, Sex) of
            _ ->
                ?P_SUCCESS
        catch
            _:Other ->
                ?ERROR("change_sex:~p", [{Other, erlang:get_stacktrace()}]),
                ?P_FAIL
        end,
    Out = proto:encode(#m_player_change_sex_toc{result = Result, sex = Sex}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	领取世界树奖励
%% @throws 	none
%% @end
%% ----------------------------------
world_tree_award(
    #m_player_world_tree_award_tos{},
    State = #conn{player_id = PlayerId}
) ->
    {Result, AwardList} =
        case catch mod_player:world_tree_award(PlayerId) of
            {ok, AwardList0} ->
                {?P_SUCCESS, AwardList0};
            {'EXIT', R} ->
                {api_common:api_error_to_enum(R), []}
        end,
    Out = proto:encode(#m_player_world_tree_award_toc{result = Result, prop_list = api_prop:pack_prop_list(AwardList)}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	通知玩家属性变化(整形)
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_attr_change(_PlayerId, []) ->
    noop;
notice_player_attr_change(PlayerId, ChangeList) ->
%%    ?DEBUG("notice_player_attr_change:~p~n", [{PlayerId, ChangeList}]),
    Out =
        proto:encode(#m_player_notice_player_attr_change_toc{
            player_id = PlayerId,
            list = tran_attr_change(ChangeList)
        }),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	通知玩家属性变化(字符串)
%% @throws 	none
%% @end
%% ----------------------------------
notice_player_string_attr_change(_PlayerId, []) ->
    noop;
notice_player_string_attr_change(PlayerId, ChangeList) ->
%%    ?DEBUG("notice_player_attr_change:~p~n", [{PlayerId, ChangeList}]),
    Out =
        proto:encode(#m_player_notice_player_string_attr_change_toc{
            player_id = PlayerId,
            list = tran_string_attr_change(ChangeList)
        }),
    mod_socket:send(PlayerId, Out).

tran_attr_change(ChangeList) ->
    [#'m_player_notice_player_attr_change_toc.attr_change'{attr = Attr, value = Value} || {Attr, Value} <- ChangeList].

tran_string_attr_change(ChangeList) ->
    [#'m_player_notice_player_string_attr_change_toc.string_attr_change'{attr = Attr, value = Value} || {Attr, Value} <- ChangeList].

%% 通知各功能激活
notice_function_active(PlayerId, List) ->
    Out = proto:encode(#m_player_notice_fun_active_toc{fun_id_list = List}),
    mod_socket:send(PlayerId, Out).

%%%%领取功能奖励
%%get_fun_award(
%%    #m_player_get_fun_award_tos{fun_id = FunctionId},
%%    State = #conn{player_id = PlayerId}) ->
%%    ?REQUEST_INFO("领取功能奖励"),
%%    Result = api_common:api_result_to_enum(catch mod_function:get_fun_award(PlayerId, FunctionId)),
%%    Out = proto:encode(#m_player_get_fun_award_toc{result = Result, fun_id = FunctionId}),
%%    mod_socket:send(Out),
%%    State.

%% 通知服务器时间（毫秒）
notice_server_time(PlayerId, ServerTime) ->
    Out = proto:encode(#m_player_notice_server_time_toc{server_time = util:to_list(ServerTime)}),
%%    Out = proto:encode(#m_player_notice_server_time_toc{server_time = ServerTime}),
    mod_socket:send(PlayerId, Out).

%% ----------------------------------
%% @doc 	获得玩家属性数据
%% @throws 	none
%% @end
%% ----------------------------------

get_player_attr(#m_player_get_player_attr_tos{player_id = AimPlayerId},
    State = #conn{player_id = PlayerId}) ->
    ?REQUEST_INFO("获得玩家属性数据"),
    AttrList = [pack_player_attr(AttrId, AttrValue) || {AttrId, AttrValue} <- mod_attr:get_player_attr(PlayerId, AimPlayerId)],
    Out = proto:encode(#m_player_get_player_attr_toc{player_id = AimPlayerId, attr_data = AttrList}),
    mod_socket:send(Out),
    State.

%% ----------------------------------
%% @doc 	更新客户端数据
%% @throws 	none
%% @end
%% ----------------------------------
update_client_data(
    #m_player_update_client_data_tos{client_data_list = ClientDataList},
    State = #conn{player_id = PlayerId}
) ->
    List = [{Id, Value} || #clientdata{id = Id, value = Value} <- ClientDataList],
    mod_player:update_client_data(PlayerId, List),
    State.
%% ----------------------------------
%% @doc 	删除客户端数据
%% @throws 	none
%% @end
%% ----------------------------------
delete_client_data(
    #m_player_delete_client_data_tos{id_list = IdList},
    State = #conn{player_id = PlayerId}
) ->
    mod_player:delete_client_data(PlayerId, IdList),
    State.

%% @doc api 获得玩家客户端数据列表
api_get_player_client_data_list(PlayerId) ->
    DbPlayerClientDataList = mod_player:get_db_player_client_data_list(PlayerId),
    [#clientdata{id = util:to_binary(Id), value = util:to_binary(Value)} || #db_player_client_data{id = Id, value = Value} <- DbPlayerClientDataList].

%% @fun 打包模型外观
%%pack_model_figure({PlayerData, Sex, HeadId, ClotheId, TitleId, JingJieId, PetSteps, MagicWeaponId, GodWeaponId, WingsSteps, MagicRing}) ->
%%    #db_player_data{
%%        player_id = PlayerId,
%%        head_id = HeadId,
%%        title_id = TitleId,
%%        god_weapon_id = GodWeaponId
%%    } = PlayerData,
%%    #modelfigure{
%%        player_id = PlayerId,
%%        sex = Sex,
%%        head_id = HeadId,
%%        clothe_id = ClotheId,
%%        title_id = TitleId,
%%        jing_jie_id = JingJieId,
%%        pet_steps = PetSteps,
%%        magic_weapon_id = MagicWeaponId,
%%        god_weapon_id = GodWeaponId,
%%        wings_steps = WingsSteps,
%%        magic_ring = MagicRing
%%    };
pack_model_figure(ModelFigure) when is_record(ModelFigure, modelfigure) ->
    ModelFigure;
pack_model_figure(PlayerId) when is_integer(PlayerId) andalso PlayerId > 0 ->
    case mod_player:get_db_player_data(PlayerId) of
        #db_player_data{
            head_id = HeadId,
            title_id = TitleId
        } ->
            #db_player_hero_use{
                hero_id = HeroId,
                arms = ArmsId,
                ornaments = OrnamentsId
            } = mod_hero:get_db_player_hero_use(PlayerId),
            #modelfigure{
                player_id = PlayerId,
                sex = mod_player:get_player_data(PlayerId, sex),
                head_id = HeadId,
                title_id = TitleId,
                magic_weapon_id = mod_sys_common:get_id_by_fun_state(PlayerId, ?FUNCTION_ROLE_MAGIC),
                hero_id = HeroId,
                hero_arms_id = ArmsId,
                hero_ornaments_id = OrnamentsId
            };
        _ ->
            #modelfigure{
                player_id = PlayerId,
                sex = 0,
                head_id = 0,
                title_id = 0,
                magic_weapon_id = 0,
                hero_id = 0,
                hero_arms_id = 0,
                hero_ornaments_id = 0
            }
    end;
pack_model_figure(_) ->
    ?UNDEFINED.

%% @fun 玩家头像模型
pack_model_head_figure(PlayerId) when is_integer(PlayerId) andalso PlayerId > 0 ->
    case mod_player:get_db_player_data(PlayerId) of
        #db_player_data{
            head_id = HeadId,
            level = Level,
            vip_level = VipLevel,
            head_frame_id = HeadFrameId
        } ->
            #db_player{
                sex = Sex,
                server_id = ServerId,
                nickname = Nickname
            } = mod_player:get_player(PlayerId),
            PlayerNickname = mod_player:get_player_name(ServerId, Nickname),
            pack_model_head_figure(PlayerId, PlayerNickname, Sex, HeadId, VipLevel, Level, HeadFrameId);
        _ ->
            pack_model_head_figure(PlayerId, util:to_list(PlayerId), 0, 1, 0, 1, 0)
    end;
pack_model_head_figure(ModelHeadFigure) when is_record(ModelHeadFigure, modelheadfigure) ->
    ModelHeadFigure;
pack_model_head_figure(_) ->
    ?UNDEFINED.
pack_model_head_figure(PlayerId, Nickname, Sex, HeadId, VipLevel, Level, HeadFrameId) ->
    #modelheadfigure{
        player_id = PlayerId,
        nickname = util:to_binary(Nickname),
        sex = Sex,
        head_id = HeadId,
        vip_level = VipLevel,
        level = Level,
        head_frame_id = HeadFrameId
    }.

%% ----------------------------------
%% @doc 	打包玩家基础信息数据
%% @throws 	none
%% @end
%% ----------------------------------
pack_player_base_data(PlayerId) when is_integer(PlayerId) ->
    ProcessType = ?PROCESS_TYPE,
    ObjScenePlayer = ?GET_OBJ_SCENE_PLAYER(PlayerId),
    case PlayerId < 10000 of
        _ when ProcessType =:= ?PROCESS_TYPE_SCENE_WORKER, ObjScenePlayer /= ?UNDEFINED -> % 场景进程内正常玩家或机器人
            #obj_scene_actor{
                nickname = Nickname,
                surface = #surface{
                    head_id = HeadId,
                    head_frame_id = HeadFrameId
                }
            } = ObjScenePlayer;
        true -> % 不在场景进程内的机器人
            Nickname = util:to_list(PlayerId),
            HeadId = 1,
            HeadFrameId = 0;
        false -> % 其他
            #db_player{
                nickname = Nickname
            } = mod_player:get_player(PlayerId),
            #db_player_data{
                head_id = HeadId,
                head_frame_id = HeadFrameId
            } = mod_player:get_db_player_data(PlayerId)
    end,
    #playerbaseinfo{
        player_id = PlayerId,
        head_id = HeadId,
        head_frame_id = HeadFrameId,
        nickname = util:to_binary(Nickname)
    };
pack_player_base_data(R) when is_record(R, playerbaseinfo) -> R.

pack_player_other_data(HeadId, HeadFrameId, ChatQiPaoId) ->
    #playerotherdata{
        head_id = HeadId,
        head_frame_id = HeadFrameId,
        chat_qi_pao_id = ChatQiPaoId
    }.

pack_player_attr(AttrId, AttrValue) ->
    #attrdata{id = AttrId, value = AttrValue}.

adjust(
    #m_player_adjust_tos{
        list = List
    } = Msg,
    State = #conn{player_id = PlayerId}
) ->
    ?INFO("Msg: ~p", [Msg]),
    lists:foreach(
        fun(Ele) ->
            #'m_player_adjust_tos.attr_change'{attr = AttrFromProto, value = Value} = Ele,
            ?INFO("AttrFromProto: ~p, Value: ~p", [AttrFromProto, Value]),
            Attr = ?IF(is_binary(AttrFromProto), util:to_list(AttrFromProto), AttrFromProto),
            ?INFO("Attr: ~p, Value: ~p", [Attr, Value]),
            case Attr of
                "adgroup" ->
                    FriendCode = ?IF(is_binary(Value), util:to_list(Value), Value),
                    case length(FriendCode) of
                        %% 处理好友邀请
                        CodeLength when CodeLength > 0 ->
                            #db_player{
                                acc_id = AccId,
                                server_id = ServerId,
                                nickname = NickName
                            } = mod_player:get_player(PlayerId),
                            ?INFO("AccId: ~p, ServerId: ~p, Nickname: ~p", [AccId, ServerId, NickName]),
%%                            ?TRY_CATCH(mod_share:deal_invite(AccId, PlayerId, FriendCode, ServerId ++ "." ++ NickName));
                            case catch mod_share:deal_invite(AccId, PlayerId, FriendCode, ServerId ++ "." ++ NickName) of
                                {'EXIT', none} ->
                                    %% 处理地推或whatsapp推广
                                    AccId = mod_player:get_player_data(PlayerId, acc_id),
                                    {PlatformId, _} = mod_player:get_platform_id_and_server_id(PlayerId),
                                    case mod_server_rpc:call_center(mod_global_account, update_promote_by_game_server, [PlatformId, AccId, FriendCode]) of
                                        failure ->
                                            ?ERROR("Update promote failure");
                                        ok ->
                                            ?INFO("Update promote success")
                                    end;
                                _ ->
                                    ?INFO("玩家邀请玩家: ~p, Value: ~p", [Attr, Value])
                            end;
                        _ ->
                            noop
                    end;
                _R ->
                    ?DEBUG("ignore param: ~p ~p", [Attr, Value])
            end
        end,
        List
    ),
    Out =
        proto:encode(#m_player_adjust_toc{
            result = 1
        }),
    ?INFO("adjust Out: ~p", [Out]),
    mod_socket:send(PlayerId, Out),
    State.

-define(PsMsg(PlatformId),
    ?IF((PlatformId =:= ?PLATFORM_TAIWAN orelse PlatformId =:= ?PLATFORM_LOCAL), "PS:這段訊息非常重要，請發送給客服", "PS: This is very important information.Please send to me")).

%% 获取客服链接
customer_url(#m_player_customer_url_tos{},
    State = #conn{player_id = PlayerId}) ->
    ?INFO("获取客服链接: ~p", [PlayerId]),
    spawn(fun() ->
        Out = case mod_customer:get_player_customer_url(PlayerId) of
                  ?UNDEFINED ->
                      ?ERROR("UNDEFINED: ~p", [?UNDEFINED]),
                      proto:encode(#m_player_customer_url_toc{result = 2});
                  Url ->
                      ?INFO("Url: ~p", [Url]),
                      {PlatformId, ServerId} = mod_player:get_platform_id_and_server_id(PlayerId),
                      Tips = ?PsMsg(PlatformId),
%%                      ?DEBUG("Tips: ~p", [Tips]),
                      RealUrl = % "https://www.notion.so/530f686ef95b4036a695afa80bf86711",
                      case PlatformId of
                          ?PLATFORM_INDONESIA ->
                              CustomerName = mod_unique_invitation_code:encode(PlayerId) ++ " " ++ util:to_list(PlatformId) ++ " " ++ util:to_list(ServerId) ++ " " ++ Tips,
                              RealCustomerName = cow_qs:urlencode(util:to_binary(CustomerName)),
                              ?DEBUG("RealCustomerName: ~p ~p", [is_binary(RealCustomerName), RealCustomerName]),
                              Url ++ "?text=" ++ util:to_list(RealCustomerName);
                          ?PLATFORM_TAIWAN ->
                              %% https://line.me/R/oaMessage/@852axevw/?Hi%20there%21
                              CustomerName = mod_unique_invitation_code:encode(PlayerId) ++ " " ++ util:to_list(PlatformId) ++ " " ++ util:to_list(ServerId) ++ " " ++ util_string:to_utf8(Tips),
                              RealCustomerName = cow_qs:urlencode(util:to_binary(CustomerName)),
                              ?DEBUG("RealCustomerName: ~p ~p", [is_binary(RealCustomerName), RealCustomerName]),
                              Url ++ "?" ++ util:to_list(RealCustomerName);
                          ?PLATFORM_LOCAL ->
                              CustomerName = mod_unique_invitation_code:encode(PlayerId) ++ " " ++ util:to_list(PlatformId) ++ " " ++ util:to_list(ServerId) ++ " " ++ util_string:to_utf8(Tips),
                              RealCustomerName = cow_qs:urlencode(util:to_binary(CustomerName)),
                              Url ++ "?aaa=" ++ util:to_list(RealCustomerName);
                          _ ->
                              Url
                      end,
                      ?DEBUG("RealUrl: ~p ~p", [is_list(RealUrl), RealUrl]),
                      proto:encode(#m_player_customer_url_toc{
                          result = 1,
%%                          customer_url = [#'m_player_customer_url_toc.customer_url_data'{url = Url}]
                          customer_url = [#'m_player_customer_url_toc.customer_url_data'{url = RealUrl}]
                      })
              end,
%%        ?INFO("Out: ~p", [Out]),
        mod_socket:send(PlayerId, Out)
          end),
    State.

visitor_binding(
    #m_player_visitor_binding_tos{channel = Channel1, acc_id = AccId1},
    State = #conn{player_id = PlayerId}
) ->
    Channel = ?IF(is_list(Channel1), Channel1, util:to_list(Channel1)),
    AccId = ?IF(is_list(AccId1), AccId1, util:to_list(AccId1)),
    ?ASSERT(Channel =/= "visitor", not_a_visitor),

    PlayerData =
        case mod_player:get_player(PlayerId) of
            PlayerRecord when is_record(PlayerRecord, db_player) -> PlayerRecord;
            null ->
                ?ERROR("player data is null"),
                exit(player_not_exists);
            Other ->
                ?ERROR("invalid player data type: ~p", [Other]),
                exit(unknown)
        end,
    #db_player{
        acc_id = MatchAccId,
        channel = MatchChannel,
        server_id = ServerId
    } = PlayerData,
    ?INFO("MatchAccId: ~p AccId: ~p ~p", [MatchAccId, AccId, is_list(AccId)]),
    ?INFO("MatchChannel: ~p Channel: ~p", [MatchChannel, Channel]),

    ?ASSERT(Channel =/= MatchChannel, not_allowed_to_binding),
    ?ASSERT(MatchAccId =/= AccId, binding_same_acc_id),

    Tran =
        fun() ->
            %% 修改channel
%%            NewPlayerData = PlayerData#db_player{channel = Channel, acc_id = AccId},
            NewPlayerData = PlayerData#db_player{oauth_source = Channel, acc_id = AccId},
            db:write(NewPlayerData),

            PlatformId = mod_server_config:get_platform_id(),
            case mod_server_rpc:call_center(mod_global_account, is_acc_id_exists, [PlayerId, Channel, PlatformId, ServerId, AccId, MatchAccId]) of
                ok -> ok;
                acc_id_exists -> exit(binding_same_acc_id);
                _ -> exit(undefined_error)
            end
        end,

    Out =
        case catch db:do(Tran) of
            ok ->
                proto:encode(#m_player_visitor_binding_toc{
                    result = 1,
                    channel = Channel
                });
            {'EXIT', not_a_visitor} ->
                ?ERROR("当前账号不是一个游客(acc_id: ~p channel: ~p)", [AccId, Channel]),
                proto:encode(#m_player_visitor_binding_toc{
                    result = 2,
                    channel = Channel
                });
            {'EXIT', binding_same_acc_id} ->
                ?ERROR("重复绑定同一个账号(acc_id: ~p)", [AccId]),
                proto:encode(#m_player_visitor_binding_toc{
                    result = 3,
                    channel = Channel
                });
            {'EXIT', not_allowed_to_binding} ->
                ?ERROR("渠道相同，重复绑定(channel: ~p matchChannel: ~p)", [Channel]),
                proto:encode(#m_player_visitor_binding_toc{
                    result = 4,
                    channel = Channel
                });
            {'EXIT', player_not_exists} ->
                proto:encode(#m_player_visitor_binding_toc{
                    result = 5,
                    channel = Channel
                });
            {'EXIT', unknown} ->
                proto:encode(#m_player_visitor_binding_toc{
                    result = 6,
                    channel = Channel
                })
        end,
    mod_socket:send(PlayerId, Out),
    State.

test_visitor_binding(AccId, Channel, PlayerId) ->
    ?ASSERT(Channel =/= "visitor", not_a_visitor),

    PlayerData =
        case mod_player:get_player(PlayerId) of
            PlayerRecord when is_record(PlayerRecord, db_player) -> PlayerRecord;
            null ->
                ?ERROR("player data is null"),
                exit(player_not_exists);
            Other ->
                ?ERROR("invalid player data type: ~p", [Other]),
                exit(unknown)
        end,
    #db_player{
        acc_id = MatchAccId,
        channel = MatchChannel,
        server_id = ServerId
    } = PlayerData,
    ?INFO("MatchAccId: ~p", [MatchAccId]),
    ?INFO("MatchChannel: ~p", [MatchChannel]),

    ?ASSERT(Channel =/= MatchChannel, not_allowed_to_binding),
    ?ASSERT(MatchAccId =/= AccId, binding_same_acc_id),

    Tran =
        fun() ->
            %% 修改channel
            NewPlayerData = PlayerData#db_player{channel = Channel, acc_id = AccId},
            db:write(NewPlayerData),

            PlatformId = mod_server_config:get_platform_id(),
            case mod_server_rpc:call_center(mod_global_account, is_acc_id_exists, [PlayerId, Channel, PlatformId, ServerId, AccId, MatchAccId]) of
                ok -> ok;
                acc_id_exists -> exit(binding_same_acc_id);
                _ -> exit(undefined_error)
            end
        end,

    Out =
        case catch db:do(Tran) of
            ok ->
                proto:encode(#m_player_visitor_binding_toc{
                    result = 1,
                    channel = Channel
                });
            {'EXIT', not_a_visitor} ->
                ?ERROR("当前账号不是一个游客(acc_id: ~p channel: ~p)", [AccId, Channel]),
                proto:encode(#m_player_visitor_binding_toc{
                    result = 2,
                    channel = Channel
                });
            {'EXIT', binding_same_acc_id} ->
                ?ERROR("重复绑定同一个账号(acc_id: ~p)", [AccId]),
                proto:encode(#m_player_visitor_binding_toc{
                    result = 3,
                    channel = Channel
                });
            {'EXIT', not_allowed_to_binding} ->
                ?ERROR("渠道相同，重复绑定(channel: ~p matchChannel: ~p)", [Channel]),
                proto:encode(#m_player_visitor_binding_toc{
                    result = 4,
                    channel = Channel
                });
            {'EXIT', player_not_exists} ->
                proto:encode(#m_player_visitor_binding_toc{
                    result = 5,
                    channel = Channel
                });
            {'EXIT', unknown} ->
                proto:encode(#m_player_visitor_binding_toc{
                    result = 6,
                    channel = Channel
                })
        end,

    ?DEBUG("Out: ~p", [Out]).

%%notice_player_adjust_value(PlayerId) ->
%%    case ?IS_DEBUG of
%%        true ->
%%            Out =
%%                proto:encode(#m_player_notice_player_adjust_value_toc{
%%%%            value = server_adjust:get_player_server_adjust_rate(PlayerId)
%%                    value = mod_player:get_player_adjust_rate(PlayerId)
%%                }),
%%%%            ?INFO("adjust Out: ~p", [Out]),
%%            mod_socket:send(PlayerId, Out);
%%        false ->
%%            noop
%%    end.

%% @doc 获得服务器时间
get_server_time(
    #m_player_get_server_time_tos{},
    State
) ->
    Time = util:to_list(util_time:milli_timestamp()),
    Out = proto:encode(#m_player_get_server_time_toc{server_time = Time}),
    mod_socket:send(Out),
    State.

%% @doc 设置玩家数据
set_player_data(
    #m_player_set_player_data_tos{type = Type, id = Id},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_player:set_player_data(PlayerId, Type, Id)),
    Out = proto:encode(#m_player_set_player_data_toc{result = Result, type = Type, id = Id}),
    mod_socket:send(Out),
    State.

%% @doc 升级
level_upgrade(
    #m_player_level_upgrade_tos{},
    State = #conn{player_id = PlayerId}
) ->
%%    {Result, OldLevel, NewLevel, PropList} = api_common:api_result_to_enum_by_many(catch mod_player:level_upgrade(PlayerId), [0, 0, []]),
    {Result, OldLevel, NewLevel, PropList} =
        case catch mod_player:level_upgrade(PlayerId) of
            {ok, ThisOldLevel, ThisNewLevel, ThisPropList} ->
                {?P_SUCCESS, ThisOldLevel, ThisNewLevel, ThisPropList};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), 0, 0, []}
        end,
    send_level_upgrade(PlayerId, Result, OldLevel, NewLevel, PropList),
    State.
send_level_upgrade(PlayerId, Result, OldLevel, NewLevel, PropList) ->
    Out = proto:encode(#m_player_level_upgrade_toc{
        result = Result,
        old_level = OldLevel,
        new_level = NewLevel,
        prop_list = api_prop:pack_prop_list(PropList)}
    ),
    mod_socket:send(PlayerId, Out).

%% @doc 更新玩家签名
update_player_signature(
    #m_player_update_player_signature_tos{signature = Signature},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_player:update_player_signature(PlayerId, util:to_list(Signature))),
    Out = proto:encode(#m_player_update_player_signature_toc{result = Result, signature = Signature}),
    mod_socket:send(Out),
    State.

%% @doc 获得玩家信息
get_player_info(
    #m_player_get_player_info_tos{player_id = PlayerId},
    State = #conn{player_id = _PlayerId}
) ->
    {Result, Signature, ModelHeadFigure} =
        case catch mod_player:get_player_chat_info(PlayerId) of
            {ok, Signature1, ModelHeadFigure1} ->
                {?P_SUCCESS, util:to_binary(Signature1), ModelHeadFigure1};
            {'EXIT', ERROR} ->
                {api_common:api_error_to_enum(ERROR), ?UNDEFINED, ?UNDEFINED}
        end,
    Out = proto:encode(#m_player_get_player_info_toc{result = Result, signature = Signature, model_head_figure = ModelHeadFigure}),
    mod_socket:send(Out),
    State.


%% ----------------------------------
%% @doc 	领取玩家在场景内滞留的奖励
%% @throws 	none
%% @end
%% ----------------------------------
collect_delay_rewards(
    #m_player_collect_delay_rewards_tos{type = Type},
    State
) ->
    mod_player:give_player_scene_stay_rewards(Type),
    State.

%% @doc 升级
get_level_award(
    #m_player_get_level_award_tos{level = Level},
    State = #conn{player_id = PlayerId}
) ->
    Result = api_common:api_result_to_enum(catch mod_player:get_level_award(PlayerId, Level)),
    Out = proto:encode(#m_player_get_level_award_toc{
        result = Result,
        level = Level
    }),
    mod_socket:send(PlayerId, Out),
    State.

%% @doc 通知玩家修正值
%%notice_player_xiu_zhen_value(PlayerId, List) ->
%%    Out = proto:encode(#m_player_notice_player_xiu_zhen_value_toc{
%%        lists = [#'m_player_notice_player_xiu_zhen_value_toc.xiuzhendata'{id = Id, value = Value} || {Id, Value} <- List]
%%    }),
%%    mod_socket:send(PlayerId, Out).
%%notice_player_xiu_zhen_value(PlayerId, _List) ->
%%    noop.
notice_player_xiu_zhen_value(PlayerId, _List) ->
    case ?IS_DEBUG of
        true ->
            #ets_obj_player{
                scene_id = SceneId,
                scene_worker = SceneWorker
            } = mod_obj_player:get_obj_player(PlayerId),
            #t_scene{
                is_hook = IsHook,
                type = Type
            } = mod_scene:get_t_scene(SceneId),
            if
                IsHook == ?TRUE andalso Type == ?SCENE_TYPE_WORLD_SCENE ->
                    case scene_worker:get_dict(SceneWorker, {scene_adjust, dict_scene_worker_state, PlayerId}) of
                        ?UNDEFINED ->
                            noop;
                        {_PlayerState, PlayerRate} ->
                            ScenePoolValue = scene_adjust_srv:call({get_pool_value, SceneId}),
%%                            {RoomState, RoomRate} = scene_worker:get_dict(SceneWorker, {scene_adjust, dict_scene_worker_state}),
                            RoomValue = scene_worker:get_dict(SceneWorker, {scene_adjust, dict_scene_worker_pool_value}),
                            AdjustReboundTotalCost =
                                case scene_worker:get_dict(SceneWorker, {scene_adjust_rebound_total_cost, PlayerId}) of
                                    ?UNDEFINED ->
                                        0;
                                    Value1 ->
                                        Value1
                                end,
                            AdjustReboundTotalAward =
                                case scene_worker:get_dict(SceneWorker, {scene_adjust_rebound_total_award, PlayerId}) of
                                    ?UNDEFINED ->
                                        0;
                                    Value2 ->
                                        Value2
                                end,
                            ReboundAdjustValue =
                                case scene_worker:get_dict(SceneWorker, {scene_adjust_is_open_rebound, PlayerId}) of
                                    {true, _, ReboundAdjust, _} ->
                                        ReboundAdjust;
                                    _ ->
                                        0
                                end,
                            Time = scene_worker:get_dict(SceneWorker, timer_time_scene_adjust),
                            List =
                                [
                                    {1, ScenePoolValue},
                                    {2, (Time - util_time:milli_timestamp()) div 1000},
                                    {3, trunc(RoomValue)},
                                    {4, trunc(PlayerRate * 10000)},
                                    {5, AdjustReboundTotalCost},
                                    {6, AdjustReboundTotalAward},
                                    {7, ReboundAdjustValue},
                                    {8, handle_scene_adjust_srv:get_boss_adjust_value(SceneId)}
                                ],
%%                          ?DEBUG("通知adjust ~p ", [List]),
                            Out = proto:encode(#m_player_notice_player_xiu_zhen_value_toc{
                                lists = [#'m_player_notice_player_xiu_zhen_value_toc.xiuzhendata'{id = Id, value = Value} || {Id, Value} <- List]
                            }),
                            mod_socket:send(PlayerId, Out)
                    end;

%%            mod_obj_player:get_obj_player_scene_worker(PlayerId)
%%            #ets_obj_player{
%%                scene_id = SceneId
%%            } = mod_obj_player:get_obj_player(PlayerId),
%%            ScenePropId = api_fight:get_item_id(SceneId, ?ITEM_GOLD),
%%            PoolValue = server_fight_adjust:get_server_adjust_pool_value(ScenePropId),
%%            #db_server_player_fight_adjust{
%%                id = XiuZhengId,
%%                times = Times
%%            } = server_fight_adjust:get_db_server_player_fight_adjust_or_init(PlayerId, ScenePropId),
%%            #db_player_fight_adjust{
%%                pool_1 = Pool1,
%%                pool_2 = Pool2,
%%                id = PoolId,
%%                pool_times = PoolTimes
%%            } = mod_player_adjust:get_db_player_fight_adjust_or_init(PlayerId, ScenePropId),
                true ->
                    noop
            end;
        false ->
            noop
    end.