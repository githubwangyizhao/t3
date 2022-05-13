%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc
%%% @end
%%% Created : 27. 十一月 2017 上午 1:12
%%%-------------------------------------------------------------------

-record(r_active_skill, {
    id = 0,                         %% 主动技能id
    level = 0,                      %% 主动技能等级
    is_common_skill = false,        %% 是否普攻 [0:否 1:是]
    skill_type = 1,                 %% 技能类型
    force_wait_time = 0,            %% 硬直时间
    last_time_ms = 0                %% 上次使用时间(ms)
}).

%% 技能结算类型
-define(BALANCE_TYPE_DIS, 0).       %% 单段结算(由距离来判断)
-define(BALANCE_TYPE_GRID, 1).      %% 多段结算(由格子来判断)
-define(BALANCE_TYPE_GRID2, 2).     %% 【指定】目标多段结算(由格子来判断)
-define(BALANCE_TYPE_GRID3, 3).     %% 【随机】目标多段结算(由格子来判断)
-define(BALANCE_TYPE_GRID4, 4).     %% 【固定偏移】目标多段结算(由格子来判断)
-define(BALANCE_TYPE_GRID5, 5).     %% 【指定+随机】目标多段结算(由格子来判断)

% 技能类型
-define(SKILL_TYPE_ROLE, 1). %% 主角技能

%% 充能技能
-record(r_charge_skill, {
    skill_id,                   %% 技能id
    timer_ref,                  %% 定时器引用
    times = 0,                    %% 当前累计次数
    max_times = 0,                %% 最大累计次数
    recover_cd_time = 0,        %% 技能恢复时间间隔
    use_cd_time = 0,            %% 使用技能时间间隔
    next_recover_time = 0,      %% 下一次技能恢复时间戳
    next_use_time = 0           %% 可以使用技能时间
}).
