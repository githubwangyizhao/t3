%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016, THYZ
%%% @doc            通用缓存(ets)
%%% @end
%%% Created : 26. 五月 2016 下午 1:51
%%%-------------------------------------------------------------------
-define(CACHE_ALL_ONLINE_PLAYER_ID, 1). %% 所有在线玩家id
-define(CACHE_JOIN_ZONE_NODE_LIST, 2). %% 加入跨服节点的节点列表
-define(CACHE_ALL_SERVER_LIST, 3). %% 所有打包的已开服列表
-define(CACHE_MAX_SERVER_ID, 4). %% 最大的区服id
-define(CACHE_LOGIN_NOTICE, 5). %% 登录公告
-define(CACHE_CROSS_EQUIP_BOSS_CACHE, 6). %% 跨服装备副本
-define(CACHE_MISSION_SHENG_SHOU_ID, 7). %% 当前圣兽副本id
-define(CACHE_WEB_SERVER_LIST, 8). %% 服务器列表
-define(CACHE_WEB_USER_LIST, 9). %% web user列表
-define(CACHE_QQ_VIA, 10). %% QQ_VIA
-define(CACHE_WEIXIN_NAVIGATE_DATA, 11). %%
-define(CACHE_OPPO_TOKEN, 12). %% oppo token / oppo马甲包 token
-define(CACHE_DOULUO_ZHI_FU, 13).   % 斗罗支付数据
