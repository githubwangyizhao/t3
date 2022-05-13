
-define(KEY, "a96c1c6ac254de7e7d104b7672a6f852").        % 正常充值key
-define(GM_KEY, "fa9274fd68cf8991953b186507840e5e").    % gm充值key

-define(GM_CHARGE_TYPE_I_INGOT, 0).     % 后台充值  只给元宝
-define(GM_CHARGE_TYPE_ALL, 1).         % 后台充值  给正常充值权限
-define(GM_CHARGE_TYPE_NOT_VIP, 2).     % 后台充值  给正常充值权限 不给vip经验
-define(GM_CHARGE_TYPE_REPAIR, 3).      % 后台失败补充充值
-define(CHARGE_TYPE_GM_NORMAL, 98).     % 平台gm充值
-define(CHARGE_TYPE_NORMAL, 99).        % 平台正常充值

-define(GM_TYPE_CHANGE_WHITE_IP, 88).   % 操作白名单ip

-define(TIME_INTERVAL, 900).        % 比较时间间隙 s

-define(SOURCE_CHARGE_FROM_GOOGLE, 1).              % 谷歌充值
-define(SOURCE_CHARGE_FROM_APP_STORE, 2).           % app store充值
-define(SOURCE_CHARGE_FROM_PROPS_TRADER, 3).        % 装备交易平台充值

-define(REGION_CURRENCY_TW, "TWD").                 % 台湾地区的货币缩写
-define(REGION_CURRENCY_INDONESIA, "INR").          %% 印尼的货币缩写

%% 充值订单状态
-define(CHARGE_STATE_0, 0).     % 0:空闲状态
-define(CHARGE_STATE_1, 1).     % 1:创建状态
-define(CHARGE_STATE_2, 2).     % 2:上报状态
-define(CHARGE_STATE_3, 3).     % 3:支付失败状态
-define(CHARGE_STATE_4, 4).     % 2:用户取消支付状态
-define(CHARGE_STATE_9, 9).     % 9:完成状态