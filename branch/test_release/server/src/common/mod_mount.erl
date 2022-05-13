%%%-------------------------------------------------------------------
%%% @author home
%%% @copyright (C) 2018, GAME BOY
%%% @doc		坐骑
%%% Created : 27. 一月 2018 15:49
%%%-------------------------------------------------------------------
-module(mod_mount).
-author("home").
%%
%%%% API
%%-export([
%%    get_info/1,                    %% 获得信息
%%    upgrade_step/2,                %% 升阶
%%    change_body/2                  %% 幻化形象
%%]).
%%
%%-export([
%%    upgrade_promote_diathesis/2,   %% 升阶资质
%%    promote_upgrade_steps/2,       %% 直接升阶
%%    clear_wish_num/1,              %% 清除祝福值
%%    get_scene_data/1,              %% 给场景数据
%%    activate_fun/2,                %% 激活功能初始数据
%%    test_fun_change/2,             %% 测试功能
%%    get_sys_attr_list/2            %%  获取系统属性列表
%%]).
%%
%%-include("msg.hrl").
%%-include("error.hrl").
%%-include("common.hrl").
%%-include("gen/db.hrl").
%%-include("gen/table_db.hrl").
%%-include("gen/table_enum.hrl").
%%
%%-define(WISH_CLEAR_TIME, {5, 0, 0}).        % 祝福值清除时间
%%
%%%% @doc     获得信息
%%get_info(PlayerId) ->
%%    case mod_function:is_open(PlayerId, ?FUNCTION_MOUNT_SYS) of
%%        true ->
%%            get_player_mount_init(PlayerId);
%%        _ ->
%%            ?UNDEFINED
%%    end.
%%
%%%% @doc     升阶
%%upgrade_step(PlayerId, IsAuto) ->
%%    mod_function:assert_open(PlayerId, ?FUNCTION_MOUNT_SYS),
%%    PlayerMount = get_player_mount_init(PlayerId),
%%    #db_player_mount{
%%        body_step = OldBodyStep,
%%        step = CurrStepLevel,
%%        wish_num = CurrWishNum,
%%        click_num = CurrClickNum,
%%        wish_clear_time = OldWishClearTime
%%    } = PlayerMount,
%%    #t_mount{
%%        next_level = NextStepLevel,
%%        stone_num_list = ItemList,
%%        success_rate_list = RateList,
%%        wish_value_list = [_, InitWishNum, TopWishNum],
%%        is_reset = IsReset
%%    } = try_get_t_mount(CurrStepLevel),
%%    ?ASSERT(NextStepLevel > 0, ?ERROR_LEVEL_TEMPLATE_LIMIT),
%%    {CalcGiveItemList, CalcItemList, CalcDataF} =
%%        if
%%            IsAuto == ?TRUE ->
%%                mod_shop:calc_auto_buy_item(PlayerId, ItemList);
%%            true ->
%%                mod_prop:assert_prop_num(PlayerId, ItemList),
%%                {[], ItemList, null}
%%        end,
%%    NewClickNum = CurrClickNum + 1,
%%    {NewStepLevel, ClickNum, WishNum, WishClearTime} =
%%        case util_random:p(util_random:get_rate_list_rateNum(RateList, NewClickNum)) of
%%            true ->
%%                {NextStepLevel, 0, 0, 0};
%%            _ ->
%%                AddWishNum = util_random:random_number(InitWishNum, TopWishNum),
%%                WishClearTime1 =
%%                    if
%%                        CurrWishNum == 0 andalso IsReset == ?TRUE ->
%%                            util_time:get_end_date_timestamp(?WISH_CLEAR_TIME);
%%                        true ->
%%                            OldWishClearTime
%%                    end,
%%                {CurrStepLevel, CurrClickNum + 1, CurrWishNum + AddWishNum, WishClearTime1}
%%        end,
%%    Tran =
%%        fun() ->
%%            mod_prop:change_player_prop_decrease(PlayerId, CalcItemList, ?LOG_TYPE_MOUNT_STEP),
%%            mod_prop:add_player_prop(PlayerId, CalcGiveItemList, ?LOG_TYPE_MOUNT_STEP),
%%            NewPlayerMount = db:write(PlayerMount#db_player_mount{step = NewStepLevel, body_step = ?IF(NewStepLevel > CurrStepLevel, NewStepLevel, OldBodyStep), click_num = ClickNum, wish_num = WishNum, wish_clear_time = WishClearTime}),
%%            mod_conditions:add_conditions(PlayerId, {?CON_ENUM_MOUNT_STEP_COUNT, ?CONDITIONS_VALUE_ADD, 1}),
%%            ?IF(CalcDataF == null, noop, CalcDataF()),
%%            if
%%                NewStepLevel > CurrStepLevel ->
%%                    next_step(PlayerId, NewStepLevel);
%%                true ->
%%                    calc_fight(PlayerId)
%%            end,
%%            mod_log:write_wish_log(?FUNCTION_MOUNT_SYS, PlayerId, ClickNum, WishNum - CurrWishNum, WishNum),
%%            {ok, NewPlayerMount}
%%        end,
%%    db:do(Tran).
%%
%%%% @fun 进阶后的操作
%%next_step(PlayerId, NewStepLevel) ->
%%    mod_conditions:add_conditions(PlayerId, {?CON_ENUM_MOUNT_STEP, ?CONDITIONS_VALUE_SET_MAX, NewStepLevel}),
%%    mod_scene:push_player_data_2_scene(PlayerId, [{?MSG_SYNC_MOUNT_STEPS, NewStepLevel}]),
%%    calc_fight(PlayerId).
%%
%%%% @doc     幻化形象
%%change_body(PlayerId, BodyStep) ->
%%    mod_function:assert_open(PlayerId, ?FUNCTION_MOUNT_SYS),
%%    PlayerMount = get_player_mount(PlayerId),
%%    #db_player_mount{
%%        step = CurrStepLevel,
%%        body_step = CurrBodyStepLevel
%%    } = PlayerMount,
%%    ?ASSERT(BodyStep =/= CurrBodyStepLevel, ?ERROR_ALREADY_HAVE),
%%    ?ASSERT(BodyStep =< CurrStepLevel, ?ERROR_LEVEL_TEMPLATE_LIMIT),
%%    Tran =
%%        fun() ->
%%            db:write(PlayerMount#db_player_mount{body_step = BodyStep}),
%%            mod_scene:push_player_data_2_scene(PlayerId, [{?MSG_SYNC_MOUNT_STEPS, BodyStep}])
%%        end,
%%    db:do(Tran),
%%    ok.
%%
%%%% @fun 直接升阶
%%promote_upgrade_steps(PlayerId, FunctionId) ->
%%    PlayerMount = get_player_mount(PlayerId),
%%    ?ASSERT(is_record(PlayerMount, db_player_mount), ?ERROR_NOT_EXISTS),
%%    #db_player_mount{
%%        step = CurrStepLevel,
%%        wish_num = CurrWishNum
%%    } = PlayerMount,
%%    #t_mount{
%%        next_level = NextStepLevel
%%    } = try_get_t_mount(CurrStepLevel),
%%    ?ASSERT(NextStepLevel > 0, ?ERROR_LEVEL_TEMPLATE_LIMIT),
%%%%    #t_promote_upgrade{
%%%%        item_list = UpgradeItemList1,
%%%%        change_item_list = UpgradeChangeItemList1,
%%%%        limit_steps_id = LimitSteps,
%%%%        log_type = LogType
%%%%    } = mod_sys_common:try_get_t_promote_upgrade(FunctionId),
%%%%    UpgradeItemList = [UpgradeItemList1],
%%%%    UpgradeChangeItemList =
%%%%        if
%%%%            LimitSteps >= CurrStepLevel ->
%%%%                [];
%%%%            true ->
%%%%                [UpgradeChangeItemList1]
%%%%        end,
%%%%    mod_prop:assert_prop_num(PlayerId, UpgradeItemList),
%%%%    mod_prop:assert_give(PlayerId, UpgradeChangeItemList),
%%    {UpgradeItemList, UpgradeChangeItemList, LogType} = mod_sys_common:common_promote_upgrade_steps(PlayerId, FunctionId, CurrStepLevel),
%%
%%    Tran =
%%        fun() ->
%%            mod_prop:change_player_prop_decrease(PlayerId, UpgradeItemList, LogType),
%%            mod_award:give(PlayerId, UpgradeChangeItemList, LogType),
%%            if
%%                UpgradeChangeItemList == [] ->
%%                    db:write(PlayerMount#db_player_mount{step = NextStepLevel, body_step = NextStepLevel, click_num = 0, wish_num = 0, wish_clear_time = 0}),
%%                    mod_log:write_wish_log(FunctionId, PlayerId, 0, - CurrWishNum, 0),
%%                    next_step(PlayerId, NextStepLevel),
%%                    {ok, NextStepLevel};
%%                true ->
%%                    ok
%%            end
%%        end,
%%    db:do(Tran).
%%
%%%% @fun 升阶资质
%%upgrade_promote_diathesis(PlayerId, FunctionId) ->
%%    PlayerMount = get_player_mount(PlayerId),
%%    ?ASSERT(is_record(PlayerMount, db_player_mount), ?ERROR_NOT_EXISTS),
%%%%    DiathesisLevel = PlayerMount#db_player_mount.diathesis_level,
%%%%    #t_promote_diathesis{
%%%%        item_list = ItemList1,
%%%%        steps_id = Steps
%%%%    } = mod_sys_common:try_get_t_promote_diathesis(FunctionId, DiathesisLevel),
%%%%    ?ASSERT(Steps >= 0, ?ERROR_LEVEL_TEMPLATE_LIMIT),   % 最后一级
%%%%    ?ASSERT(PlayerMount#db_player_mount.step >= Steps, ?ERROR_NEED_LEVEL),  % 不能超过当前系统阶数
%%%%    ItemList = [ItemList1],
%%%%    mod_prop:assert_prop_num(PlayerId, ItemList),
%%%%    NewDiathesisLevel = DiathesisLevel + 1,
%%    {NewDiathesisLevel, ItemList} =
%%        mod_sys_common:common_upgrade_promote_diathesis(PlayerId, FunctionId, PlayerMount#db_player_mount.diathesis_level, PlayerMount#db_player_mount.step),
%%
%%    Tran =
%%        fun() ->
%%            mod_prop:change_player_prop_decrease(PlayerId, ItemList, ?LOG_TYPE_MOUNT_UPGRADE_DIATHESIS),
%%            db:write(PlayerMount#db_player_mount{diathesis_level = NewDiathesisLevel}),
%%            calc_fight(PlayerId),
%%            {ok, NewDiathesisLevel}
%%        end,
%%    db:do(Tran).
%%
%%%% @fun 清除祝福值
%%clear_wish_num(PlayerId) ->
%%    case get_player_mount(PlayerId) of
%%        #db_player_mount{wish_num = WishNum} ->
%%            if
%%                WishNum > 0 ->
%%                    PlayerMountInit = get_player_mount_init(PlayerId),
%%                    if
%%                        WishNum =/= PlayerMountInit#db_player_mount.wish_num ->
%%                            Tran =
%%                                fun() ->
%%                                    db:write(PlayerMountInit),
%%                                    calc_fight(PlayerId)
%%                                end,
%%                            db:do(Tran);
%%                        true ->
%%                            noop
%%                    end;
%%                true ->
%%                    noop
%%            end;
%%        _ ->
%%            noop
%%    end.
%%
%%
%%%% @fun 激活功能初始数据
%%activate_fun(PlayerId, _) ->
%%    PlayerMountInit = get_player_mount_init(PlayerId),
%%    NewStepLevel = PlayerMountInit#db_player_mount.step,
%%    if
%%        PlayerMountInit#db_player_mount.body_step == 0 ->
%%            Tran =
%%                fun() ->
%%                    db:write(PlayerMountInit#db_player_mount{step = NewStepLevel, body_step = NewStepLevel}),
%%                    next_step(PlayerId, NewStepLevel)
%%                end,
%%            db:do(Tran);
%%        true ->
%%            noop
%%    end.
%%
%%%% @fun 给场景数据
%%get_scene_data(PlayerId) ->
%%    PlayerMountInit = get_player_mount_init(PlayerId),
%%    PlayerMountInit#db_player_mount.body_step.
%%
%%%% @fun 计算战力
%%calc_fight(PlayerId) ->
%%    mod_attr:refresh_player_sys_attr(PlayerId, ?FUNCTION_MOUNT_SYS).
%%
%%%% @fun 获取系统属性列表
%%get_sys_attr_list(PlayerId, FunctionId) ->
%%    #db_player_mount{
%%        step = StepLevel,
%%        wish_num = WishNum,
%%        diathesis_level = DiathesisLevel
%%    } = get_player_mount(PlayerId),
%%    #t_mount{
%%        property_list = PropertyList,
%%        next_level = NextStepsLevel,
%%        wish_value_list = [LimitWishNum | _]
%%    } = try_get_t_mount(StepLevel),
%%    WishAttrList =
%%        if
%%            WishNum > 0 ->
%%                #t_mount{
%%                    property_list = NextPropertyList
%%                } = try_get_t_mount(NextStepsLevel),
%%                mod_sys_common:calc_wish_num_attr(NextPropertyList, PropertyList, WishNum, LimitWishNum);
%%            true ->
%%                []
%%        end,
%%    AddSystemRatio = mod_sys_common:get_promote_diathesis_value(FunctionId, DiathesisLevel),
%%    [{PropertyList, {?ATTR_ADD_RATIO, AddSystemRatio}}] ++ WishAttrList.
%%
%%%% 测试功能
%%test_fun_change(PlayerId, Value) ->
%%    PlayerMount = get_player_mount_init(PlayerId),
%%    OldStep = PlayerMount#db_player_mount.step,
%%    try_get_t_mount(Value),
%%    if
%%        OldStep < Value ->
%%            Tran =
%%                fun() ->
%%                    db:write(PlayerMount#db_player_mount{step = Value}),
%%                    next_step(PlayerId, Value)
%%                end,
%%            db:do(Tran);
%%        true ->
%%            noop
%%    end.
%%
%%%% ================================================ 数据操作 ================================================
%%%% @fun 获得玩家坐骑数据
%%get_player_mount(PlayerId) ->
%%    case mod_player:is_robot_player_id(PlayerId) of
%%        true ->
%%            RobotAttrId = mod_robot_data:try_get_robot_sys_data_attr_id(PlayerId),
%%            robot_data_info:db_player_mount({RobotAttrId});
%%        _ ->
%%            db:read(#key_player_mount{player_id = PlayerId})
%%    end.
%%%% @fun 获得玩家坐骑数据	并初始化
%%get_player_mount_init(PlayerId) ->
%%    case get_player_mount(PlayerId) of
%%        PlayerMount when is_record(PlayerMount, db_player_mount) ->
%%            ClearTime = PlayerMount#db_player_mount.wish_clear_time,
%%            CurrTime = util_time:timestamp(),
%%            if
%%                ClearTime > 0 andalso ClearTime =< CurrTime ->
%%                    PlayerMount#db_player_mount{wish_num = 0, click_num = 0};
%%                true ->
%%                    PlayerMount
%%            end;
%%        _ ->
%%            #db_player_mount{player_id = PlayerId, step = 1}
%%    end.
%%
%%%% ================================================ 模板操作 ================================================
%%%% @fun 获得模板阶数数据
%%try_get_t_mount(StepLevel) ->
%%    Table = t_mount:get({StepLevel}),
%%    ?IF(is_record(Table, t_mount), Table, exit({t_mount, {StepLevel}})).

