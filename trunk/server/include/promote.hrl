%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 十二月 2020 下午 03:02:29
%%%-------------------------------------------------------------------
-author("Administrator").

%% rpc call function name
-define(PROMOTE_INIT_GET_PLAYER_PROMOTE_INFO, init_get_player_promote_info).        %% 初始化并获得玩家推广信息

%% gen server call
-define(PROMOTE_GET_AWARD, promote_get_award).                                      %% 回调函数命名:获得奖励
-define(PROMOTE_GET_RECORD_LIST, promote_get_record_list).                          %% 回调函数命名:获得记录列表

%% gen server cast
-define(PROMOTE_DO_DEAL_INVITE, promote_do_deal_invite).                            %% 回调函数命名:处理被分享加入游戏
-define(PROMOTE_CHARGE, promote_charge).                                            %% 回调函数命名:处理充值

%% Template
-define(PROMOTE_TEMPLATE_TYPE_1, 1).                                                %% Get new tier {} user {}
-define(PROMOTE_TEMPLATE_TYPE_2, 2).                                                %% Tier {} user {} has contributed {} mana and {} vip exp for you