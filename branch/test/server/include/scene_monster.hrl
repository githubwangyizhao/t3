%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2017, THYZ
%%% @doc
%%% @end
%%% Created : 22. 十一月 2017 下午 10:36
%%%-------------------------------------------------------------------
-define(MONSTER_STATUS_SLEEP, 0).               %%怪物状态 -睡眠
-define(MONSTER_STATUS_PATROL, 1).              %%怪物状态 -巡逻
-define(MONSTER_STATUS_TRACK, 2).               %%怪物状态 -追踪
-define(MONSTER_STATUS_ATTACK, 3).              %%怪物状态 -攻击
-define(MONSTER_STATUS_BACK, 4).                %%怪物状态 -回退
-define(MONSTER_STATUS_TARGET_PLACE, 5).        %%怪物状态 -去某个地点
%%-define(MONSTER_STATUS_FOLLOW, 6).              %%怪物状态 -跟随
%%-define(MONSTER_STATUS_FIGHT_MONSTER, 7).       %%怪物状态 -攻击怪物
%%-define(MONSTER_STATUS_WAITING, 8).             %%怪物状态 -等待
%%-define(MONSTER_STATUS_HUN_LUAN, 9).            %%怪物状态 -混乱
%%-define(MONSTER_STATUS_RECOVER, 10).            %%怪物状态 -回血

%%-define(WOOD_ATTACKED_RECOVER_HP_RATE, 0.02).   %%木桩战斗状态下回血比例
%%-define(MONSTER_FIRST_RECOVER_HP_TIME, 2000).   %%怪物失去仇恨首次回血时间
%%-define(HEART_BEAT_TIME, 500).                %%怪物进程心跳

-define(LOW_MONSTER_DEFAULT_HEART_TIME, {600, 400}).          %%低级怪默认心跳
-define(HIGH_LEVEL_MONSTER_DEFAULT_HEART_TIME, {300, 200}).   %%高级怪默认心跳
%%-define(BOSS_DEFAULT_HEART_TIME, {600, 300}).                  %%boss默认心跳

%% 怪物类型
-define(MONSTER_TYPE_ACTIVE, 1).                %% 主动怪
-define(MONSTER_TYPE_PASSIVE, 2).               %% 被动怪
-define(MONSTER_TYPE_WOOD, 3).                  %% 木桩
-define(MONSTER_TYPE_FIY, 4).                   %% 飞天怪
-define(MONSTER_TYPE_HD, 5).                    %% 混沌怪
-define(MONSTER_TYPE_ATTACK_PLAYER, 6).                    %% 混沌怪
-define(MONSTER_ACTIVE_ATTACK_MONSTER, 7).      %% 刺客

-define(MT_ACTIVE, 1).                          %% 主动怪
-define(MT_PASSIVE, 2).                         %% 被动怪
-define(MT_WOOD, 3).                            %% 木桩
-define(MT_FIY, 4).                             %% 飞行怪
-define(MT_HD, 5).           			        %% 混沌怪
-define(MT_ASSASSIN, 6).						%% 刺客
-define(MT_BOSS_1, 9).							%% BOSS1

%% 怪物效果
-define(MONSTER_EFFECT_0, 0). 			%% 无效果
-define(MONSTER_EFFECT_1, 1). 			%% 召唤怪
-define(MONSTER_EFFECT_2, 2).	 		%% 金币怪
-define(MONSTER_EFFECT_3, 3). 			%% 翻牌(旧)
-define(MONSTER_EFFECT_4, 4). 			%% 双倍
-define(MONSTER_EFFECT_5, 5). 			%% 闪电链
-define(MONSTER_EFFECT_6, 6). 			%% 分裂弹
-define(MONSTER_EFFECT_7, 7). 			%% 猜位置
-define(MONSTER_EFFECT_8, 8). 			%% 猜刀秒
-define(MONSTER_EFFECT_9, 9). 			%% 翻牌（翻牌类型）
-define(MONSTER_EFFECT_10, 10). 		%% 拉霸（拉霸类型）
-define(MONSTER_EFFECT_11, 11). 		%% 转盘（转盘类型
-define(MONSTER_EFFECT_12, 12). 		%% 炸弹怪
-define(MONSTER_EFFECT_13, 13). 		%% 火球怪
-define(MONSTER_EFFECT_14, 14). 		%% 地震怪
-define(MONSTER_EFFECT_15, 15). 		%% 金币小妖
-define(MONSTER_EFFECT_16, 16). 		%% 神龙祝福
-define(MONSTER_EFFECT_17, 17). 		%% 黄金怪
-define(MONSTER_EFFECT_20, 20).         %% 宝箱
-define(MONSTER_EFFECT_21, 21). 		%% 陨石怪(炸弹)
-define(MONSTER_EFFECT_22, 22). 		%% 火环怪(地震) 改为奥术怪
-define(MONSTER_EFFECT_23, 23). 		%% 龙卷风
-define(MONSTER_EFFECT_24, 24). 		%% 鬼火怪
-define(MONSTER_EFFECT_25, 25). 		%% 彩球

%%%% 追踪对象信息
%%-record(track_info,{
%%    obj_type = 0,
%%    obj_id = 0,
%%    x = 0,
%%    y = 0
%%}).
