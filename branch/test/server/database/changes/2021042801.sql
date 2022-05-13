CREATE TABLE `player_online_log`
(
    `id`           INT unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `player_id`    INT unsigned NOT NULL COMMENT '玩家ID',
    `login_time`   INT          NOT NULL DEFAULT '0' COMMENT '登录时间',
    `offline_time` INT          NOT NULL DEFAULT '0' COMMENT '离线时间',
    `online_time`  INT          NOT NULL DEFAULT '0' COMMENT '在线时长',
    PRIMARY KEY (`id`),
    KEY `idx_player_online_log_1` (`player_id`, `login_time`),
    KEY `idx_player_online_log_2` (`login_time`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8 COMMENT ='玩家在线日志';

CREATE TABLE `player_login_log`
(
    `id`        INT unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `player_id` INT unsigned NOT NULL COMMENT '玩家ID',
    `ip`        VARCHAR(32)  NOT NULL COMMENT '登录ip',
    `timestamp` INT          NOT NULL DEFAULT '0' COMMENT '时间戳',
    PRIMARY KEY (`id`),
    KEY `idx_player_login_log_1` (`player_id`, `timestamp`),
    KEY `idx_player_login_log_2` (`timestamp`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8 COMMENT ='玩家登录日志';

CREATE TABLE `player`
(
    `id`                   int(10) unsigned NOT NULL COMMENT '玩家id',
    `acc_id`               varchar(64)      NOT NULL DEFAULT '' COMMENT '平台帐号',
    `server_id`            varchar(32)      NOT NULL COMMENT '服务器ID',
    `nickname`             varchar(64)      NOT NULL DEFAULT '' COMMENT '昵称',
    `sex`                  tinyint(4)       NOT NULL DEFAULT '0' COMMENT '性别, 0:男 1:女',
    `forbid_type`          tinyint(4)       NOT NULL DEFAULT '0' COMMENT '封禁类型[1:禁言 2:封号]',
    `forbid_time`          int(11)          NOT NULL DEFAULT '0' COMMENT '封禁时间',
    `reg_time`             int(10) unsigned NOT NULL DEFAULT '0' COMMENT '注册时间',
    `last_login_time`      int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后登陆时间',
    `last_offline_time`    int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后离线时间',
    `total_online_time`    int(10) unsigned NOT NULL DEFAULT '0' COMMENT '累计在线时间',
    `last_login_ip`        varchar(32)      NOT NULL DEFAULT '' COMMENT '最后登陆IP',
    `from`                 varchar(64)      NOT NULL DEFAULT '' COMMENT '来源',
    `login_times`          int(11)          NOT NULL DEFAULT '0' COMMENT '登录次数',
    `cumulative_day`       int(11)          NOT NULL DEFAULT '0' COMMENT '累计登录天数',
    `continuous_day`       int(11)          NOT NULL DEFAULT '0' COMMENT '连续登录天数',
    `total_recharge_ingot` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '充值总金额',
    `last_recharge_time`   int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后充值时间',
    `recharge_times`       int(10) unsigned NOT NULL DEFAULT '0' COMMENT '充值次数',
    `is_pass_fcm`          tinyint(4)       NOT NULL DEFAULT '0' COMMENT '是否通过防沉迷[0:否 1:是]',
    `type`                 tinyint(4)       NOT NULL DEFAULT '0' COMMENT '0:普通号 1:内部号',
    `is_online`            tinyint(4)       NOT NULL DEFAULT '0' COMMENT '是否在线0:否',
    `channel`              varchar(64)      NOT NULL DEFAULT '' COMMENT '渠道',
    `friend_code`          varchar(64)      NOT NULL DEFAULT '' COMMENT '分享码',
    PRIMARY KEY (`id`),
    KEY `idx_player_1` (`server_id`, `channel`),
    KEY `idx_player_2` (`last_login_time`),
    KEY `idx_player_3` (`reg_time`)
)
    COMMENT = '玩家'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_data`
(
    `player_id`           INT unsigned      NOT NULL COMMENT '玩家id',
    `exp`                 BIGINT unsigned   NOT NULL DEFAULT '0' COMMENT '经验',
    `level`               SMALLINT unsigned NOT NULL DEFAULT '0' COMMENT '等级',
    `vip_level`           TINYINT unsigned  NOT NULL DEFAULT '0' COMMENT 'vip等级',
    `title_id`            INT               NOT NULL DEFAULT '0' COMMENT '称号id',
    `honor_id`            INT               NOT NULL DEFAULT '0' COMMENT '头衔id',
    `head_id`             INT               NOT NULL DEFAULT '1' COMMENT '头像',
    `anger`               INT unsigned      NOT NULL DEFAULT '0' COMMENT '怒气值',
    `max_hp`              INT unsigned      NOT NULL DEFAULT '0' COMMENT '最大血量',
    `hp`                  INT unsigned      NOT NULL DEFAULT '0' COMMENT '血量',
    `attack`              INT unsigned      NOT NULL DEFAULT '0' COMMENT '攻击',
    `defense`             INT unsigned      NOT NULL DEFAULT '0' COMMENT '防御',
    `hit`                 INT unsigned      NOT NULL DEFAULT '0' COMMENT '命中',
    `dodge`               INT unsigned      NOT NULL DEFAULT '0' COMMENT '闪避',
    `tenacity`            INT unsigned      NOT NULL DEFAULT '0' COMMENT '韧性',
    `critical`            INT unsigned      NOT NULL DEFAULT '0' COMMENT '暴击',
    `rate_resist_block`   INTEGER           NOT NULL DEFAULT 0 COMMENT '破击',
    `rate_block`          INTEGER           NOT NULL DEFAULT 0 COMMENT '格挡',
    `power`               BIGINT unsigned   NOT NULL DEFAULT '0' COMMENT '战力',
    `speed`               INT unsigned      NOT NULL DEFAULT '0' COMMENT '速度',
    `crit_time`           INTEGER           NOT NULL DEFAULT 0 COMMENT '暴击时长',
    `hurt_add`            INTEGER           NOT NULL DEFAULT 0 COMMENT '造成伤害增加',
    `hurt_reduce`         INTEGER           NOT NULL DEFAULT 0 COMMENT '受到伤害减少',
    `crit_hurt_add`       INTEGER           NOT NULL DEFAULT 0 COMMENT '造成暴击伤害增加',
    `crit_hurt_reduce`    INTEGER           NOT NULL DEFAULT 0 COMMENT '受到暴击伤害减少',
    `hp_reflex`           INTEGER           NOT NULL DEFAULT 0 COMMENT '生命恢复',
    `pk`                  INT unsigned      NOT NULL DEFAULT '0' COMMENT 'pk值',
    `last_world_scene_id` INT               NOT NULL DEFAULT '0' COMMENT '上次世界场景ID',
    `x`                   INT               NOT NULL DEFAULT '0' COMMENT 'X',
    `y`                   INT               NOT NULL DEFAULT '0' COMMENT 'Y',
    `fight_mode`          TINYINT           NOT NULL DEFAULT '0' COMMENT '战斗模式',
    `mount_status`        TINYINT           NOT NULL DEFAULT '0' COMMENT '坐骑状态',
    `game_event_id`       INT               NOT NULL DEFAULT '0' COMMENT '事件id',
    PRIMARY KEY (`player_id`)
)
    COMMENT = '玩家数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';


CREATE TABLE `c_game_server`
(
    `platform_id` VARCHAR(64)  NOT NULL COMMENT '平台id',
    `sid`         VARCHAR(32)  NOT NULL COMMENT '区服ID',
    `desc`        VARCHAR(128) NOT NULL DEFAULT '' COMMENT '描述',
    `is_show`     INT          NOT NULL DEFAULT '0' COMMENT '是否显示',
    `node`        VARCHAR(64)  NOT NULL COMMENT '节点',
    PRIMARY KEY (`platform_id`, `sid`)
)
    COMMENT = '游戏服列表'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `c_server_node`
(
    `node`        VARCHAR(128) NOT NULL COMMENT '节点',
    `ip`          VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '外网IP地址',
    `port`        INT          NOT NULL DEFAULT '0' COMMENT 'socket端口',
    `web_port`    INT          NOT NULL DEFAULT '0' COMMENT 'http端口',
    `db_host`     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '数据库地址',
    `db_port`     INT          NOT NULL DEFAULT '3306' COMMENT '数据库端口',
    `db_name`     VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '数据库名',
    `type`        TINYINT      NOT NULL DEFAULT '1' COMMENT '类型[1:游戏服节点 2:跨服节点  4. 登录服 5.唯一id服务器 6.充值服]',
    `zone_node`   VARCHAR(128) NOT NULL DEFAULT '' COMMENT '跨服节点(游戏服有效)',
    `open_time`   INT          NOT NULL DEFAULT '0' COMMENT '开服时间(游戏服有效)',
    `state`       TINYINT      NOT NULL DEFAULT '0' COMMENT '状态[0:上线 1:维护]',
    `run_state`   TINYINT      NOT NULL DEFAULT '0' COMMENT '运行状态[0:断开 1:运行]',
    `platform_id` VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '平台id(游戏服有效)',
    PRIMARY KEY (`node`)
)
    COMMENT = '服务器节点'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `server_state`
(
    `time`           INT NOT NULL COMMENT '时间戳',
    `create_count`   INT NOT NULL DEFAULT '0' COMMENT '创建角色次数',
    `login_count`    INT NOT NULL DEFAULT '0' COMMENT '登录次数',
    `online_count`   INT NOT NULL DEFAULT '0' COMMENT '最高在线人数',
    `error_count`    INT NOT NULL DEFAULT '0' COMMENT '累计服务器错误数',
    `db_error_count` INT NOT NULL DEFAULT '0' COMMENT '累计数据库错误数',
    PRIMARY KEY (`time`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='服务器状态';

CREATE TABLE `player_passive_skill`
(
    `player_id`        INT unsigned NOT NULL COMMENT '玩家id',
    `passive_skill_id` INT          NOT NULL COMMENT '被动技能ID',
    `level`            SMALLINT     NOT NULL COMMENT '等级',
    `is_equip`         SMALLINT     NOT NULL COMMENT '是否装备',
    `last_time`        INT          NOT NULL DEFAULT '0' COMMENT '上次使用时间',
    PRIMARY KEY (`player_id`, `passive_skill_id`)
)
    COMMENT = '玩家被动技能'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_times_data`
(
    `player_id`         INT unsigned NOT NULL COMMENT '玩家id',
    `times_id`          SMALLINT     NOT NULL COMMENT '次数id',
    `use_times`         SMALLINT     NOT NULL COMMENT '今日使用次数',
    `left_times`        SMALLINT     NOT NULL DEFAULT '0' COMMENT '剩余次数',
    `buy_times`         SMALLINT     NOT NULL COMMENT '购买次数',
    `update_time`       INT          NOT NULL COMMENT '更新时间',
    `last_recover_time` INT          NOT NULL COMMENT '上次恢复时间',
    PRIMARY KEY (`player_id`, `times_id`)
)
    COMMENT = '玩家次数数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `timer_data`
(
    `timer_id`  INT NOT NULL COMMENT '定时器id',
    `last_time` INT NOT NULL COMMENT '最近执行时间',
    PRIMARY KEY (`timer_id`)
)
    COMMENT = '服务器定时器数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `test`
(
    `id`  INT unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `num` INT unsigned NOT NULL COMMENT 'num',
    `str` VARCHAR(128) NOT NULL COMMENT 'str',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8 COMMENT ='测试表';

CREATE TABLE `unique_id_data`
(
    `type` TINYINT unsigned NOT NULL COMMENT '唯一id类型',
    `id`   INT unsigned     NOT NULL COMMENT '数据',
    PRIMARY KEY (`type`)
)
    COMMENT = '唯一id数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `server_data`
(
    `id`          int(10) unsigned NOT NULL COMMENT 'id',
    `key2`        int(11)          NOT NULL DEFAULT '0' COMMENT '第二条件',
    `int_data`    int(10) unsigned NOT NULL DEFAULT '0' COMMENT '整型数据',
    `str_data`    varchar(128)     NOT NULL DEFAULT '' COMMENT '字符串数据',
    `change_time` int(11)          NOT NULL DEFAULT '0' COMMENT '操作时间',
    PRIMARY KEY (`id`, `key2`)
)
    COMMENT = '服务器数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_game_data`
(
    `player_id` int unsigned NOT NULL COMMENT 'player_id',
    `data_id`   int unsigned NOT NULL COMMENT '数据id',
    `int_data`  int unsigned NOT NULL DEFAULT 0 COMMENT '整型数据',
    `str_data`  VARCHAR(128) NOT NULL DEFAULT '' COMMENT '字符串数据',
    PRIMARY KEY (`player_id`, `data_id`)
)
    COMMENT = '玩家游戏数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_prop`
(
    `player_id`   INTEGER          NOT NULL DEFAULT 0 COMMENT '玩家id',
    `prop_id`     INTEGER          NOT NULL DEFAULT 0 COMMENT '道具id',
    `num`         BIGINT unsigned  NOT NULL DEFAULT 0 COMMENT '数量',
    `expire_time` int(10) unsigned NOT NULL COMMENT '过期时间',
    PRIMARY KEY (`player_id`, `prop_id`)
)
    COMMENT = '玩家道具'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_offline_apply`
(
    `id`        INT unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `player_id` INTEGER      NOT NULL DEFAULT 0 COMMENT '玩家id',
    `module`    VARCHAR(32)  NOT NULL COMMENT '模块名',
    `function`  VARCHAR(32)  NOT NULL COMMENT '函数名',
    `args`      VARCHAR(512) NOT NULL COMMENT '参数',
    `timestamp` INTEGER      NOT NULL DEFAULT 0 COMMENT '时间戳',
    PRIMARY KEY (`id`)
)
    COMMENT = '离线操作'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_mission_data`
(
    `player_id`    int(11)              NOT NULL COMMENT '玩家id',
    `mission_type` smallint(5) unsigned NOT NULL COMMENT '副本类型',
    `mission_id`   smallint(6)          NOT NULL DEFAULT '0' COMMENT '通关的副本id',
    `time`         int(11)              NOT NULL DEFAULT '0' COMMENT '通关时间',
    PRIMARY KEY (`player_id`, `mission_type`)
)
    COMMENT = '玩家副本数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `account`
(
    `acc_id`               varchar(64) NOT NULL COMMENT '平台账户id',
    `server_id`            varchar(24) NOT NULL COMMENT '平台账户id',
    `is_create_role`       tinyint(4)  NOT NULL COMMENT '是否创建角色',
    `player_id`            int(11)     NOT NULL COMMENT '玩家id',
    `is_enter_game`        tinyint(4)  NOT NULL COMMENT '是否进入游戏',
    `is_finish_first_task` tinyint(4)  NOT NULL COMMENT '是否完成第一个任务',
    `time`                 int(11)     NOT NULL COMMENT '注册时间',
    `channel`              varchar(64) NOT NULL DEFAULT '' COMMENT '渠道',
    PRIMARY KEY (`acc_id`, `server_id`),
    KEY `idx_account_1` (`server_id`, `channel`),
    KEY `idx_account_2` (`is_create_role`),
    KEY `idx_account_3` (`time`)
)
    COMMENT = '帐号'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_prop_log`
(
    `id`           int(10) unsigned    NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `player_id`    int(10) unsigned    NOT NULL COMMENT '玩家ID',
    `prop_id`      int(10) unsigned    NOT NULL COMMENT '道具Id',
    `op_type`      tinyint(4) unsigned NOT NULL DEFAULT '0' COMMENT '操作类型',
    `op_time`      int(11)             NOT NULL DEFAULT '0' COMMENT '操作时间',
    `change_value` int(11)             NOT NULL DEFAULT '0' COMMENT '变化值',
    `new_value`    int(10) unsigned    NOT NULL DEFAULT '0' COMMENT '新数值',
    PRIMARY KEY (`id`),
    KEY `idx_player_prop_log_1` (`player_id`),
    KEY `idx_player_prop_log_2` (`player_id`, `op_type`),
    KEY `idx_player_prop_log_3` (`player_id`, `prop_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8 COMMENT ='玩家道具日志';

CREATE TABLE `global_account`
(
    `platform_id`        varchar(64)  NOT NULL COMMENT '平台id',
    `account`            varchar(64)  NOT NULL COMMENT '帐号',
    `recent_server_list` varchar(256) NOT NULL COMMENT '最近登陆的服务器列表',
    `promote`            varchar(32)  NOT NULL DEFAULT '' COMMENT '推广员标识',
    `type`               tinyint(4)   NOT NULL DEFAULT '0' COMMENT '帐号类型0:普通 1:内部号',
    `forbid_type`        tinyint(4)   NOT NULL DEFAULT '0' COMMENT '封禁类型[0: 正常 1:禁言 2:封号]',
    `forbid_time`        int(11)      NOT NULL DEFAULT '0' COMMENT '封禁时间',
    `app_id`             varchar(50)  not null DEFAULT 'com.goldmaster.game',
    PRIMARY KEY (`platform_id`, `account`)
)
    COMMENT = '公共帐号'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `consume_statistics`
(
    `player_id` INT unsigned     NOT NULL COMMENT '玩家id',
    `prop_id`   INT unsigned     NOT NULL COMMENT '道具id',
    `type`      TINYINT unsigned NOT NULL COMMENT '0:获得 1:消费',
    `log_type`  INT              NOT NULL DEFAULT '0' COMMENT '日志类型',
    `value`     INT              NOT NULL DEFAULT '0' COMMENT '数量',
    PRIMARY KEY (`player_id`, `prop_id`, `type`, `log_type`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8 COMMENT ='消费统计';

CREATE TABLE `player_conditions_data`
(
    `player_id`       int(11)    NOT NULL COMMENT '玩家id',
    `conditions_id`   int(11)    NOT NULL DEFAULT '0' COMMENT '条件id',
    `type`            int(11)    NOT NULL,
    `conditions_type` int(11)    NOT NULL DEFAULT '0' COMMENT '条件记录类型',
    `count`           bigint(20) NOT NULL DEFAULT '0' COMMENT '次数计录',
    `change_time`     int(11)    NOT NULL DEFAULT '0' COMMENT '操作时间',
    PRIMARY KEY (`player_id`, `type`, `conditions_id`)
) COMMENT = '玩家条件数据记录'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_function`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `function_id` INTEGER NOT NULL DEFAULT 0 COMMENT '功能Id',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '状态1:开',
    `get_state`   TINYINT NOT NULL DEFAULT 0 COMMENT '状态2:已领取',
    `time`        INTEGER NOT NULL DEFAULT 0 COMMENT '时间戳',
    primary key (`player_id`, `function_id`)
)
    COMMENT = '玩家功能'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_mail`
(
    `player_id`    INTEGER      NOT NULL COMMENT '玩家id',
    `mail_real_id` INTEGER      NOT NULL DEFAULT 0 COMMENT '邮件实际id',
    `mail_id`      INTEGER      NOT NULL DEFAULT 0 COMMENT '邮件id',
    `state`        TINYINT      NOT NULL DEFAULT 0 COMMENT '状态1:已读,2:已取附件',
    `title_name`   VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '邮件标题',
    `content`      VARCHAR(512) NOT NULL DEFAULT '' COMMENT '邮件内容',
    `param`        VARCHAR(256) NOT NULL DEFAULT '' COMMENT '参数',
    `item_list`    VARCHAR(512) NOT NULL DEFAULT '' COMMENT '道具列表',
    `log_type`     INTEGER      NOT NULL DEFAULT 0 COMMENT '邮件来源日志',
    `valid_time`   INTEGER      NOT NULL DEFAULT 0 COMMENT '有效时间',
    `create_time`  INTEGER      NOT NULL DEFAULT 0 COMMENT '创建时间',
    primary key (`player_id`, `mail_real_id`)
)
    COMMENT = '玩家邮件'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_achievement`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `type`        INTEGER NOT NULL DEFAULT 0 COMMENT '成就类型',
    `id`          INTEGER NOT NULL DEFAULT 0 COMMENT '成就id',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '领取状态(0:未领取,1:可领取,2:已领取)',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `type`)
)
    COMMENT = '玩家成就'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_daily_task`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `id`          INTEGER NOT NULL DEFAULT 0 COMMENT 'id',
    `value`       BIGINT  NOT NULL DEFAULT 0 COMMENT '值',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '领取状态(0:未领取,1:可领取,2:已领取)',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `id`)
)
    COMMENT = '玩家每日任务'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `rank_info`
(
    `rank_id`     int(11)          NOT NULL COMMENT '排行id',
    `player_id`   int(11)          NOT NULL COMMENT '玩家id',
    `rank`        int(11)          NOT NULL DEFAULT '0' COMMENT '排名',
    `old_rank`    int(11)          NOT NULL DEFAULT '0' COMMENT '上一次排名',
    `value`       int(10) unsigned NOT NULL DEFAULT '0' COMMENT '战力',
    `old_value`   int(10) unsigned NOT NULL DEFAULT '0' COMMENT '上一次战力',
    `change_time` int(11)          NOT NULL DEFAULT '0' COMMENT '创建时间',
    PRIMARY KEY (`rank_id`, `player_id`)
)
    COMMENT = '排行信息'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `robot_player_data`
(
    `player_id` INTEGER     NOT NULL COMMENT '玩家id',
    `nickname`  VARCHAR(64) NOT NULL DEFAULT '' COMMENT '名字',
    `server_id` VARCHAR(32) NOT NULL COMMENT '服务器ID',
    `sex`       TINYINT     NOT NULL DEFAULT 0 COMMENT '性别, 0:男 1:女',
    primary key (`player_id`)
)
    COMMENT = '机器人数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `activity_data_info`
(
    `activity_id`  INTEGER NOT NULL COMMENT '活动id',
    `init_time`    INTEGER NOT NULL DEFAULT 0 COMMENT '初始时间',
    `init_flag`    TINYINT NOT NULL DEFAULT 0 COMMENT '初始标识:1 已初始',
    `is_close`     TINYINT NOT NULL DEFAULT 0 COMMENT '是否关闭1:关闭',
    `option_state` TINYINT NOT NULL DEFAULT 0 COMMENT '是否过滤,0:不过滤,1:过滤',
    `start_time`   INTEGER NOT NULL DEFAULT 0 COMMENT '开启活动时间',
    `change_time`  INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`activity_id`)
)
    COMMENT = '活动时间信息'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_activity`
(
    `player_id`           int(11)    NOT NULL COMMENT '玩家id',
    `activity_id`         int(11)    NOT NULL DEFAULT '0' COMMENT '活动Id',
    `activity_start_time` int(11)    NOT NULL DEFAULT '0' COMMENT '活动开启时间',
    `option_state`        tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否过滤,0:不过滤,1:过滤',
    `init_flag`           int(11)    NOT NULL DEFAULT '0' COMMENT '初始标识:1 已初始',
    `init_time`           int(11)    NOT NULL DEFAULT '0' COMMENT '初始时间',
    `is_close`            tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否关闭1:关闭',
    `join_state`          tinyint(4) NOT NULL DEFAULT '0' COMMENT '当前参加活动状态1:参加',
    `change_time`         int(11)    NOT NULL DEFAULT '0' COMMENT '操作时间',
    PRIMARY KEY (`player_id`, `activity_id`)
)
    COMMENT = '玩家活动时间数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_sys_attr`
(
    `player_id`         int(11)          NOT NULL COMMENT '玩家id',
    `fun_id`            int(11)          NOT NULL DEFAULT '0' COMMENT '功能系统',
    `power`             int(10) unsigned NOT NULL DEFAULT '0' COMMENT '当前系统总战力',
    `hp`                int(10) unsigned NOT NULL DEFAULT '0' COMMENT '系统血量',
    `attack`            int(11)          NOT NULL DEFAULT '0' COMMENT '攻击',
    `defense`           int(11)          NOT NULL DEFAULT '0' COMMENT '防御',
    `hit`               int(11)          NOT NULL DEFAULT '0' COMMENT '命中',
    `dodge`             int(11)          NOT NULL DEFAULT '0' COMMENT '闪避',
    `critical`          int(11)          NOT NULL DEFAULT '0' COMMENT '暴击',
    `tenacity`          int(11)          NOT NULL DEFAULT '0' COMMENT '韧性',
    `speed`             int(11)          NOT NULL DEFAULT '0' COMMENT '速度',
    `crit_time`         int(11)          NOT NULL DEFAULT '0' COMMENT '暴击时长',
    `hurt_add`          int(11)          NOT NULL DEFAULT '0' COMMENT '造成伤害增加',
    `hurt_reduce`       int(11)          NOT NULL DEFAULT '0' COMMENT '受到伤害减少',
    `crit_hurt_add`     int(11)          NOT NULL DEFAULT '0' COMMENT '造成暴击伤害增加',
    `crit_hurt_reduce`  int(11)          NOT NULL DEFAULT '0' COMMENT '受到暴击伤害减少',
    `hp_reflex`         int(11)          NOT NULL DEFAULT '0' COMMENT '生命恢复',
    `rate_resist_block` int(11)          NOT NULL DEFAULT '0' COMMENT '破击',
    `rate_block`        int(11)          NOT NULL DEFAULT '0' COMMENT '格挡',
    `change_time`       int(11)          NOT NULL DEFAULT '0' COMMENT '操作时间',
    PRIMARY KEY (`player_id`, `fun_id`)
)
    COMMENT = '玩家各系统属性'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_charge_record`
(
    `order_id`          VARCHAR(64) NOT NULL DEFAULT '' COMMENT '订单号',
    `platform_order_id` varchar(50) not null DEFAULT '0',
    `player_id`         INTEGER     NOT NULL COMMENT '玩家id',
    `type`              TINYINT     NOT NULL DEFAULT 0 COMMENT '充值类型,0:gm,99:正常充值',
    `game_charge_id`    SMALLINT    NOT NULL DEFAULT 0 COMMENT '充值活动id,0:无活动',
    `charge_item_id`    INTEGER     NOT NULL DEFAULT 0 COMMENT '充值道具id',
    `ip`                VARCHAR(16)          DEFAULT '' COMMENT '充值时ip',
    `value`             INTEGER     NOT NULL DEFAULT 0 COMMENT '充值游戏币数量',
    `money`             FLOAT       NOT NULL DEFAULT 0.0 COMMENT '充值人民币/元',
    `charge_state`      TINYINT     NOT NULL DEFAULT 0 COMMENT '充值订单状态1:创建2:上报9:完成',
    `rate`              FLOAT       NOT NULL DEFAULT 0.0 COMMENT '费率,1美元兑换多少当地货币',
    `change_time`       INTEGER              DEFAULT 0 COMMENT '操作时间',
    `create_time`       INTEGER     NOT NULL DEFAULT 0 COMMENT '创建时间',
    primary key (`order_id`)
)
    COMMENT = '玩家充值记录'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_vip`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `level`       TINYINT NOT NULL DEFAULT 0 COMMENT '等级',
    `exp`         INTEGER NOT NULL DEFAULT 0 COMMENT '当前经验',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`)
)
    COMMENT = '玩家vip'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_vip_award`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `level`       TINYINT NOT NULL DEFAULT 0 COMMENT '等级',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '领取状态',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `level`)
)
    COMMENT = '玩家vip奖励'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_prerogative_card`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `type`        TINYINT NOT NULL DEFAULT 0 COMMENT '特权卡类型',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '领取状态',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `type`)
)
    COMMENT = '玩家特权卡'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_charge_activity`
(
    `player_id`   INTEGER  NOT NULL COMMENT '玩家id',
    `type`        SMALLINT NOT NULL DEFAULT 0 COMMENT '充值活动类型',
    `id`          INTEGER  NOT NULL DEFAULT 0 COMMENT '充值活动id',
    `start_time`  INTEGER  NOT NULL DEFAULT 0 COMMENT '活动开始时间',
    `value`       INTEGER  NOT NULL DEFAULT 0 COMMENT '充值数据（各活动自己使用方式）',
    `state`       TINYINT  NOT NULL DEFAULT 0 COMMENT '领取状态',
    `change_time` INTEGER  NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `type`, `id`)
)
    COMMENT = '玩家充值活动'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_activity_game`
(
    `player_id`           INTEGER NOT NULL COMMENT '玩家id',
    `activity_id`         INTEGER NOT NULL DEFAULT 0 COMMENT '活动id',
    `activity_start_time` INTEGER NOT NULL DEFAULT 0 COMMENT '活动开始时间',
    `value`               INTEGER NOT NULL DEFAULT 0 COMMENT '值',
    `change_time`         INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `activity_id`)
)
    COMMENT = '活动游戏数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_activity_game_info`
(
    `player_id`           INTEGER NOT NULL COMMENT '玩家id',
    `activity_id`         INTEGER NOT NULL DEFAULT 0 COMMENT '活动id',
    `game_id`             INTEGER NOT NULL DEFAULT 0 COMMENT '档次id',
    `activity_start_time` INTEGER NOT NULL DEFAULT 0 COMMENT '活动开始时间',
    `state`               TINYINT NOT NULL DEFAULT 0 COMMENT '状态',
    `times`               INTEGER NOT NULL DEFAULT 0 COMMENT '次数',
    `change_time`         INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `activity_id`, `game_id`)
)
    COMMENT = '活动游戏信息数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `activity_award`
(
    `activity_id` INTEGER NOT NULL DEFAULT 0 COMMENT '活动id',
    `start_time`  INTEGER NOT NULL DEFAULT 0 COMMENT '活动开始时间',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '状态(2:已发)',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '创建时间',
    primary key (`activity_id`)
)
    COMMENT = '活动奖励信息'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `charge_info_record`
(
    `order_id`       varchar(64) NOT NULL COMMENT '订单ID',
    `charge_type`    tinyint(4)  NOT NULL DEFAULT '0' COMMENT '首充类型0:gm充值, 1:正常充值',
    `ip`             varchar(16) NOT NULL COMMENT '充值时的ip',
    `part_id`        varchar(32) NOT NULL COMMENT '平台id',
    `server_id`      varchar(32) NOT NULL COMMENT '服务器id',
    `node`           varchar(32) NOT NULL COMMENT '节点',
    `game_charge_id` int(11)     NOT NULL COMMENT '游戏功能充值id',
    `charge_item_id` int(11)     NOT NULL DEFAULT '0' COMMENT '充值道具id',
    `acc_id`         varchar(64) NOT NULL COMMENT '账号 id',
    `player_id`      int(11)     NOT NULL COMMENT '玩家id',
    `is_first`       tinyint(4)  NOT NULL DEFAULT '0' COMMENT '是否首充1:是',
    `curr_level`     smallint(6) NOT NULL DEFAULT '0' COMMENT '当前等级',
    `curr_task_id`   int(11)     NOT NULL DEFAULT '0' COMMENT '当前任务id',
    `reg_time`       int(11)     NOT NULL DEFAULT '0' COMMENT '玩家注册时间',
    `first_time`     int(11)     NOT NULL DEFAULT '0' COMMENT '玩家首充时间',
    `curr_power`     BIGINT      NOT NULL DEFAULT '0' COMMENT '当前战力',
    `money`          float       NOT NULL COMMENT '充值人民币 /元',
    `ingot`          int(11)     NOT NULL COMMENT '充值元宝',
    `record_time`    int(11)     NOT NULL DEFAULT '0' COMMENT '记录时间',
    `channel`        varchar(64) NOT NULL DEFAULT '' COMMENT '渠道',
    PRIMARY KEY (`order_id`),
    KEY `idx_charge_info_record_1` (`part_id`, `server_id`, `channel`, `record_time`)
)
    COMMENT = '充值服订单详细记录',
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_charge_info_record`
(
    `player_id`             int(11)      NOT NULL COMMENT '玩家id',
    `part_id`               varchar(32)  NOT NULL COMMENT '平台id',
    `server_id`             varchar(32)  NOT NULL COMMENT '服务器id',
    `total_money`           float(20, 2) NOT NULL DEFAULT '0.00' COMMENT '总充值人民币/元',
    `charge_count`          int(11)      NOT NULL DEFAULT '0' COMMENT '平台正式充值总次数',
    `charge_test_count`     int(11)      NOT NULL DEFAULT '0' COMMENT '平台测试充值总次数',
    `gm_ingot_count`        int(11)      NOT NULL DEFAULT '0' COMMENT '后台元宝充值总次数',
    `gm_charge_count`       int(11)      NOT NULL DEFAULT '0' COMMENT '后台正式充值总次数',
    `gm_charge_novip_count` int(11)      NOT NULL DEFAULT '0' COMMENT '后台正式充值总次数(无vip经验)',
    `max_money`             float        NOT NULL DEFAULT '0' COMMENT '单笔最高充值人民币',
    `min_money`             float        NOT NULL DEFAULT '0' COMMENT '单笔最低充值人民币',
    `last_time`             int(11)      NOT NULL DEFAULT '0' COMMENT '玩家最后充值时间',
    `first_time`            int(11)      NOT NULL DEFAULT '0' COMMENT '玩家首充时间',
    `record_time`           int(11)      NOT NULL DEFAULT '0' COMMENT '记录时间',
    `channel`               varchar(64)  NOT NULL DEFAULT '' COMMENT '渠道',
    `is_share`              tinyint(4)   NOT NULL DEFAULT '0' COMMENT '是否分享',
    PRIMARY KEY (`player_id`),
    KEY `idx_player_charge_info_record_1` (`part_id`, `server_id`)
)
    COMMENT = '充值服玩家充值记录',
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';


CREATE TABLE `charge_ip_white_record`
(
    `ip`          VARCHAR(64) NOT NULL COMMENT 'ip',
    `name`        VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'ip服务器名字',
    `state`       TINYINT     NOT NULL DEFAULT 0 COMMENT '是否可以使用1:是',
    `record_time` INTEGER     NOT NULL DEFAULT 0 COMMENT '记录时间',
    PRIMARY KEY (`ip`)
)
    COMMENT = '充值白名单ip',
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';


DROP TABLE IF EXISTS `player_charge_shop`;
CREATE TABLE `player_charge_shop`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `id`          INTEGER NOT NULL DEFAULT 0 COMMENT '编号id',
    `count`       INTEGER NOT NULL DEFAULT 0 COMMENT '购买次数',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `id`)
)
    COMMENT = '玩家充值商店'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';


CREATE TABLE `player_share`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `count`       INTEGER NOT NULL DEFAULT 0 COMMENT '分享数据',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`)
)
    COMMENT = '玩家分享次数'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_share_friend`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `id`          INTEGER NOT NULL DEFAULT 0 COMMENT '编号id',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '状态1:可领取,2:已领取',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `id`)
)
    COMMENT = '玩家分享好友'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_platform_award`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `id`          INTEGER NOT NULL DEFAULT 0 COMMENT '礼包id',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '状态',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `id`)
)
    COMMENT = '平台礼包'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_send_gamebar_msg`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `msg_type`    INTEGER NOT NULL COMMENT '消息类型',
    `msg_id`      INTEGER NOT NULL COMMENT '消息id',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',

    PRIMARY KEY (`player_id`, `msg_type`)
)
    COMMENT = '玩家平台上报消息'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_activity_task`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `activity_id` INTEGER NOT NULL COMMENT '活动id',
    `task_type`   INTEGER NOT NULL COMMENT '任务类型',
    `value`       INTEGER NOT NULL DEFAULT 0 COMMENT '完成数量',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',

    PRIMARY KEY (`player_id`, `activity_id`, `task_type`)
)
    COMMENT = '玩家活动任务'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `login_notice`
(
    `platform_id` varchar(64)   NOT NULL DEFAULT '' COMMENT '平台id',
    `channel_id`  varchar(64)   NOT NULL DEFAULT '' COMMENT '渠道',
    `content`     varchar(2048) NOT NULL DEFAULT '' COMMENT '公告内容',
    PRIMARY KEY (`platform_id`, `channel_id`) USING BTREE
)
    COMMENT = '登录公告'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_gift_code`
(
    `player_id`    INTEGER     NOT NULL COMMENT '玩家id',
    `gift_code_id` VARCHAR(32) NOT NULL COMMENT '礼包码id',
    `state`        INTEGER     NOT NULL DEFAULT 0 COMMENT '状态（0：未领取，1：已领取）',
    `change_time`  INTEGER     NOT NULL DEFAULT 0 COMMENT '操作时间',

    PRIMARY KEY (`player_id`, `gift_code_id`)
)
    COMMENT = '兑换码数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_share_task`
(
    `player_id` INTEGER NOT NULL COMMENT '玩家id',
    `task_type` INTEGER NOT NULL DEFAULT 0 COMMENT '任务类型id',
    `value`     INTEGER NOT NULL DEFAULT 0 COMMENT '任务完成值',
    `state`     TINYINT NOT NULL DEFAULT 0 COMMENT '完成状态（0：未完成，1：已完成）',
    PRIMARY KEY (`player_id`, `task_type`)
)
    COMMENT = '玩家分享任务数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_share_task_award`
(
    `player_id` INTEGER NOT NULL COMMENT '玩家id',
    `task_type` INTEGER NOT NULL DEFAULT 0 COMMENT '任务类型id',
    `task_id`   INTEGER NOT NULL DEFAULT 0 COMMENT '任务id',
    `state`     TINYINT NOT NULL DEFAULT 0 COMMENT '完成状态（0：不可领，1：可领取，2：已领取）',
    PRIMARY KEY (`player_id`, `task_type`, `task_id`)
)
    COMMENT = '玩家领取分享任务奖励数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_invite_friend`
(
    `acc_id`    varchar(64) NOT NULL DEFAULT '' COMMENT '平台帐号',
    `player_id` int(11)     NOT NULL COMMENT '玩家id',
    PRIMARY KEY (`acc_id`, `player_id`)
)
    COMMENT = '玩家邀请好友数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_finish_share_task`
(
    `acc_id`    varchar(64) NOT NULL DEFAULT '' COMMENT '平台帐号',
    `task_type` int(11)     NOT NULL DEFAULT '0' COMMENT '任务类型id',
    `player_id` int(11)     NOT NULL DEFAULT '0' COMMENT '玩家id',
    `state`     tinyint(4)  NOT NULL DEFAULT '0' COMMENT '完成状态（0：未完成，1：已完成）',
    PRIMARY KEY (`acc_id`, `player_id`, `task_type`)
)
    COMMENT = '玩家完成分享任务数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `gift_code`
(
    `id`        VARCHAR(64) NOT NULL COMMENT '礼包码id',
    `timestamp` INT         NOT NULL DEFAULT '0' COMMENT '时间戳',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8 COMMENT ='礼包码';

CREATE TABLE `global_player`
(
    `id`          int(10) unsigned NOT NULL COMMENT '玩家ID',
    `account`     varchar(64)      NOT NULL DEFAULT '' COMMENT '帐号',
    `create_time` int(11)          NOT NULL DEFAULT '0' COMMENT '创建时间',
    `platform_id` varchar(64)      NOT NULL DEFAULT '' COMMENT '平台id',
    `server_id`   varchar(64)      NOT NULL DEFAULT '' COMMENT '服务器id',
    `channel`     varchar(64)      NOT NULL DEFAULT '' COMMENT '渠道',
    `nickanme`    varchar(64)      NOT NULL DEFAULT '' COMMENT '玩家昵称',
    PRIMARY KEY (`id`),
    KEY `idx_global_player_1` (`platform_id`, `account`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8 COMMENT ='全局玩家';

CREATE TABLE `player_invite_friend_log`
(
    `player_id`       INTEGER     NOT NULL COMMENT '玩家id',
    `acc_id`          VARCHAR(64) NOT NULL DEFAULT '' COMMENT '被邀请玩家平台帐号',
    `type`            INTEGER     NOT NULL COMMENT '进入链接分享类型',
    `server_id`       VARCHAR(32) NOT NULL COMMENT '被邀请玩家服务器ID',
    `share_player_id` INTEGER     NOT NULL COMMENT '被邀请玩家id',
    `change_time`     INTEGER     NOT NULL DEFAULT 0 COMMENT '操作时间',
    PRIMARY KEY (`player_id`, `acc_id`)
)
    COMMENT = '玩家邀请好友日志数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_server_data`
(
    `player_id`   INTEGER     NOT NULL COMMENT '玩家id',
    `platform_id` VARCHAR(32) NOT NULL COMMENT '平台id',
    `server_id`   VARCHAR(32) NOT NULL COMMENT '区服ID',
    primary key (`player_id`)
)
    COMMENT = '玩家服务器数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_activity_condition`
(
    `player_id`     INTEGER NOT NULL COMMENT '玩家id',
    `activity_id`   INTEGER NOT NULL DEFAULT 0 COMMENT '活动id',
    `condition_id`  INTEGER NOT NULL DEFAULT 0 COMMENT '条件id',
    `value`         BIGINT  NOT NULL DEFAULT 0 COMMENT '条件值',
    `activity_time` INTEGER NOT NULL DEFAULT 0 COMMENT '活动开始时间',
    PRIMARY KEY (`player_id`, `activity_id`, `condition_id`)
)
    COMMENT = '玩家活动条件数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `account_share_data`
(
    `platform_id`        VARCHAR(64) NOT NULL DEFAULT '' COMMENT '平台',
    `account`            VARCHAR(64) NOT NULL DEFAULT '' COMMENT '账号',
    `last_share_time`    INTEGER     NOT NULL DEFAULT 0 COMMENT '上次分享时间',
    `finish_share_times` INTEGER     NOT NULL DEFAULT 0 COMMENT '完成分享的次数',
    PRIMARY KEY (`platform_id`, `account`)
)
    COMMENT = '账号分享数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `account_charge_white`
(
    `platform_id` VARCHAR(64) NOT NULL DEFAULT '' COMMENT '平台',
    `account`     VARCHAR(64) NOT NULL DEFAULT '' COMMENT '账号',
    `is_white`    INTEGER     NOT NULL DEFAULT 0 COMMENT '上次分享时间',
    PRIMARY KEY (`platform_id`, `account`)
)
    COMMENT = '账号充值白名单'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `client_versin`
(
    `version`    VARCHAR(64) NOT NULL DEFAULT '' COMMENT '版本号',
    `is_release` INTEGER     NOT NULL DEFAULT 0 COMMENT '是否正式服',
    `time`       INTEGER     NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`version`)
)
    COMMENT = '客户端版本控制'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_condition_activity`
(
    `player_id`     int(11) NOT NULL COMMENT '玩家id',
    `activity_id`   int(11) NOT NULL COMMENT '活动id',
    `activity_time` int(11) NOT NULL DEFAULT '0' COMMENT '活动时间',
    `change_time`   int(11) NOT NULL DEFAULT '0' COMMENT '操作时间',
    PRIMARY KEY (`player_id`, `activity_id`)
)
    COMMENT = '玩家条件活动数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

ALTER TABLE `player_mail`
    ADD COLUMN `weight_value` INTEGER NOT NULL DEFAULT 0 COMMENT '邮件重要值' AFTER `mail_id`;

CREATE TABLE `player_task_share_award`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `task_id`     INTEGER NOT NULL DEFAULT 0 COMMENT '任务id',
    `type`        TINYINT NOT NULL DEFAULT 0 COMMENT '领取类型',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '领取时间',
    PRIMARY KEY (`player_id`, `task_id`)
)
    COMMENT = '玩家完成任务时分享奖励'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `charge_order_request_record`
(
    `order_id`    VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '订单号',
    `param_str`   VARCHAR(128) NOT NULL DEFAULT '' COMMENT '订单参数',
    `change_time` INTEGER      NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`order_id`)
)
    COMMENT = '充值订单请求'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_title`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `title_id`    INTEGER NOT NULL DEFAULT 0 COMMENT '称号id',
    `title_level` INTEGER NOT NULL DEFAULT 0 COMMENT '等级',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '状态 1:已获得,2:已佩带',
    `create_time` INTEGER NOT NULL DEFAULT 0 COMMENT '创建时间',

    PRIMARY KEY (`player_id`, `title_id`)
)
    COMMENT = '玩家称号数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_shop`
(
    `player_id`   int(11)    NOT NULL COMMENT '玩家id',
    `id`          int(11)    NOT NULL DEFAULT '0' COMMENT '编号id',
    `limit_type`  tinyint(4) NOT NULL DEFAULT '0' COMMENT '限购类型[-1:终身，0:不限购，1:每天，2:每周]',
    `buy_count`   int(11)    NOT NULL DEFAULT '0' COMMENT '购买数量',
    `award_state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '领取状态',
    `change_time` int(11)    NOT NULL DEFAULT '0' COMMENT '操作时间',
    PRIMARY KEY (`player_id`, `id`)
)
    COMMENT = '商店购买'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_everyday_sign`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `today`       INTEGER NOT NULL DEFAULT 0 COMMENT '第几天',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '状态[0:未签到，1:已签到]',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `today`)
)
    COMMENT = '玩家每日签到'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_seven_login`
(
    `player_id`        INTEGER NOT NULL COMMENT '玩家id',
    `give_award_value` INTEGER NOT NULL DEFAULT 0 COMMENT '二进制记录奖励领取值',
    primary key (`player_id`)
)
    COMMENT = '玩家七天登入'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_online_award`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `id`          INTEGER NOT NULL DEFAULT 0 COMMENT '档次id',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '状态[0:未领取，1:可领取，2:已领取]',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`, `id`)
)
    COMMENT = '玩家在线奖励'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_online_info`
(
    `player_id`                INTEGER NOT NULL COMMENT '玩家id',
    `total_hours_online_today` INTEGER NOT NULL DEFAULT 0 COMMENT '今天在线总时长',
    `record_online_timestamps` INTEGER NOT NULL DEFAULT 0 COMMENT '记录在线时间戳',
    primary key (`player_id`)
)
    COMMENT = '玩家在线信息'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_everyday_charge`
(
    `player_id`   INTEGER NOT NULL COMMENT '玩家id',
    `id`          INTEGER NOT NULL DEFAULT 0 COMMENT 'id',
    `state`       TINYINT NOT NULL DEFAULT 0 COMMENT '状态[0:未领取，1:可领取，2:已领取]',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`)
)
    COMMENT = '玩家每日充值'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_sys_common`
(
    `player_id` INTEGER NOT NULL COMMENT '玩家id',
    `id`        INTEGER NOT NULL DEFAULT 0 COMMENT 'id',
    `state`     TINYINT NOT NULL DEFAULT 0 COMMENT '状态',
    primary key (`player_id`, `id`)
)
    COMMENT = '玩家公共系统'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `promote`
(
    `platform_id`      varchar(64) NOT NULL DEFAULT '' COMMENT '平台id',
    `acc_id`           varchar(64) NOT NULL DEFAULT '' COMMENT '平台帐号',
    `invite_player_id` INTEGER     NOT NULL DEFAULT 0 COMMENT '邀请人玩家id',
    `use_times`        TINYINT     NOT NULL DEFAULT 0 COMMENT '已领取次数',
    `times_time`       INTEGER     NOT NULL DEFAULT 0 COMMENT '改变次数的时间',
    `is_red`           TINYINT     NOT NULL DEFAULT 0 COMMENT '是否显示红点',
    primary key (`platform_id`, `acc_id`)
)
    COMMENT = '推广'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `promote_info`
(
    `platform_id` varchar(64) NOT NULL DEFAULT '' COMMENT '平台id',
    `acc_id`      varchar(64) NOT NULL DEFAULT '' COMMENT '平台帐号',
    `level`       TINYINT     NOT NULL DEFAULT 0 COMMENT '推广等级',
    `number`      INTEGER     NOT NULL DEFAULT 0 COMMENT '推广人数',
    `mana`        INTEGER     NOT NULL DEFAULT 0 COMMENT '灵力奖励',
    `vip_exp`     INTEGER     NOT NULL DEFAULT 0 COMMENT 'VIP经验奖励',
    `time`        INTEGER     NOT NULL DEFAULT 0 COMMENT '修改时间',
    primary key (`platform_id`, `acc_id`, `level`)
)
    COMMENT = '推广信息'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `promote_record`
(
    `real_id`     INTEGER      NOT NULL DEFAULT 0 COMMENT '实际id',
    `platform_id` varchar(64)  NOT NULL DEFAULT '' COMMENT '平台id',
    `acc_id`      varchar(64)  NOT NULL DEFAULT '' COMMENT '平台帐号',
    `id`          TINYINT      NOT NULL DEFAULT 0 COMMENT '模板id',
    `param`       VARCHAR(256) NOT NULL DEFAULT '' COMMENT '参数',
    `time`        INTEGER      NOT NULL DEFAULT 0 COMMENT '创建时间',
    primary key (`real_id`)
)
    COMMENT = '推广记录'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

create TABLE `mission_guess_boss`
(
    `id`                 INTEGER NOT NULL COMMENT '猜BOSS副本期数id',
    `boss_id`            INTEGER NOT NULL DEFAULT 0 COMMENT 'BossId',
    `player_total_cost`  BIGINT  NOT NULL DEFAULT 0 COMMENT '玩家全部消耗',
    `player_total_award` BIGINT  NOT NULL DEFAULT 0 COMMENT '玩家全部奖励',
    `time`               INTEGER NOT NULL DEFAULT 0 COMMENT '时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '猜BOSS副本';

create TABLE `player_client_data`
(
    `player_id` int(11)     NOT NULL COMMENT '玩家id',
    `id`        varchar(20) NOT NULL DEFAULT '' COMMENT 'id',
    `value`     varchar(20) NOT NULL DEFAULT '' COMMENT '数据',
    `time`      int(11)     NOT NULL DEFAULT 0 COMMENT '时间',
    PRIMARY KEY (`player_id`, `id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '玩家客户端数据';

CREATE TABLE `player_task`
(
    `player_id`   INT unsigned NOT NULL COMMENT '玩家id',
    `task_id`     INT          NOT NULL COMMENT '任务id',
    `status`      TINYINT      NOT NULL COMMENT '任务状态[0:未完成 1:可领取 2:已领取,等待交接]',
    `num`         INT          NOT NULL DEFAULT '0' COMMENT '数量',
    `update_time` INT          NOT NULL DEFAULT '0' COMMENT '更新时间',
    PRIMARY KEY (`player_id`)
)
    COMMENT = '玩家任务'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_shen_long`
(
    `player_id` INT NOT NULL COMMENT '玩家id',
    `type`      INT NOT NULL DEFAULT 0 COMMENT '神龙类型',
    `time`      INT NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`player_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='玩家神龙数据';

CREATE TABLE `robot_player_scene_cache`
(
    `id`              INT         NOT NULL COMMENT 'id',
    `player_id`       INT         NOT NULL DEFAULT 0 COMMENT '玩家id',
    `server_id`       varchar(32) NOT NULL COMMENT '服务器ID',
    `level`           INT         NOT NULL DEFAULT 0 COMMENT '等级',
    `clothe_id`       INT         NOT NULL DEFAULT 0 COMMENT '时装id',
    `title_id`        INT         NOT NULL DEFAULT 0 COMMENT '称号id',
    `magic_weapon_id` INT         NOT NULL DEFAULT 0 COMMENT '法宝id',
    `weapon_id`       INT         NOT NULL DEFAULT 0 COMMENT '武器id',
    `wings_id`        INT         NOT NULL DEFAULT 0 COMMENT '翅膀id',
    `shen_long_type`  INT         NOT NULL DEFAULT 0 COMMENT '神龙类型',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='机器人玩家场景缓存数据';

CREATE TABLE `mission_ranking`
(
    `mission_type` smallint(5) unsigned NOT NULL COMMENT '副本类型',
    `mission_id`   smallint(6)          NOT NULL DEFAULT '0' COMMENT '通关的副本id',
    `id`           INT unsigned         NOT NULL DEFAULT '0' COMMENT '通关的副本id',
    `player_id`    INT                  NOT NULL COMMENT '玩家id',
    `rank_id`      INT                  NOT NULL DEFAULT 0 COMMENT '排名id',
    `nickname`     varchar(64)          NOT NULL DEFAULT '' COMMENT '昵称',
    `hurt`         BIGINT               NOT NULL DEFAULT 0 COMMENT '伤害值',
    `time`         INT                  NOT NULL DEFAULT 0 COMMENT '更新时间',
    PRIMARY KEY (`mission_type`, `mission_id`, `id`, `player_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='副本玩家伤害数据';

CREATE TABLE `oauth_order_log`
(
    `order_id`    varchar(32)    NOT NULL COMMENT '订单编号',
    `player_id`   INT            NOT NULL COMMENT '玩家id',
    `prop_id`     INT            NOT NULL COMMENT '道具id',
    `change_type` TINYINT        NOT NULL COMMENT '改变类型 0:减少 1:增加',
    `change_num`  INT            NOT NULL COMMENT '改变数量',
    `status`      tinyint(1)     NOT NULL DEFAULT 1 COMMENT '订单状态(0为失败,1为成功,默认1)',
    `amount`      decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '支付数额',
    `ip`          varchar(32)    NOT NULL DEFAULT '0' COMMENT 'IP地址',
    `create_time` INT            NOT NULL COMMENT '创建时间',
    `update_time` INT            NOT NULL DEFAULT 0 COMMENT '最后一次编辑时间',
    PRIMARY KEY (`order_id`),
    KEY `idx_oauth_order_log_1` (`player_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='oauth订单';

CREATE TABLE `player_invest`
(
    `player_id`   INT unsigned NOT NULL COMMENT '玩家id',
    `id`          TINYINT      NOT NULL COMMENT 'id',
    `value`       INT          NOT NULL DEFAULT '0' COMMENT '值',
    `status`      TINYINT      NOT NULL COMMENT '状态[0:未完成 1:可领取 2:已领取]',
    `update_time` INT          NOT NULL DEFAULT '0' COMMENT '领取时间',
    PRIMARY KEY (`player_id`, `id`)
)
    COMMENT = '玩家投资返利'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `brave_one`
(
    `player_id`       INTEGER NOT NULL DEFAULT 0 COMMENT '玩家id',
    `id`              INTEGER NOT NULL DEFAULT 0 COMMENT '房间id',
    `pos_id`          TINYINT NOT NULL DEFAULT 0 COMMENT '位置',
    `brave_type`      INT     NOT NULL DEFAULT 0 COMMENT '房间类型',
    `start_time`      INT     NOT NULL DEFAULT 0 COMMENT '开始时间',
    `fight_player_id` INTEGER NOT NULL DEFAULT 0 COMMENT '对手玩家id',
    `change_time`     INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`player_id`)
)
    COMMENT = '勇敢者（1v1）'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `red_packet_condition`
(
    `id`          INTEGER NOT NULL DEFAULT 0 COMMENT '红包条件id',
    `value`       INTEGER NOT NULL DEFAULT 0 COMMENT '值',
    `change_time` INTEGER NOT NULL DEFAULT 0 COMMENT '操作时间',
    primary key (`id`)
)
    COMMENT = '红包条件数据'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_game_log`
(
    `id`         INT unsigned  NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `player_id`  INT unsigned  NOT NULL COMMENT '玩家ID',
    `scene_id`   INT           NOT NULL DEFAULT 0 COMMENT '場景id',
    `cost_list`  varchar(1024) NOT NULL DEFAULT '' COMMENT '消耗列表',
    `award_list` varchar(2048) NOT NULL DEFAULT '' COMMENT '獎勵列表',
    `time`       INT           NOT NULL DEFAULT 0 COMMENT '進入時間',
    `cost_time`  INT           NOT NULL DEFAULT 0 COMMENT '消耗時間',
    primary key (`id`),
    KEY `idx_player_game_log_1` (`player_id`, `scene_id`),
    KEY `idx_player_game_log_2` (`scene_id`)
)
    COMMENT = '玩家游戲日志'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `scene_log`
(
    `scene_id`   INT           NOT NULL DEFAULT 0 COMMENT '場景id',
    `cost_list`  varchar(1024) NOT NULL DEFAULT '' COMMENT '消耗列表',
    `award_list` varchar(2048) NOT NULL DEFAULT '' COMMENT '獎勵列表',
    `times`      INT           NOT NULL DEFAULT '0' COMMENT '次数',
    `cost_time`  INT           NOT NULL DEFAULT 0 COMMENT '消耗時間',
    primary key (`scene_id`)
)
    COMMENT = '场景日志'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_client_log`
(
    `id`        INT unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `player_id` INT          NOT NULL COMMENT '玩家id',
    `log_id`    INT          NOT NULL DEFAULT 0 COMMENT '日志id',
    `time`      INT          NOT NULL DEFAULT 0 COMMENT '時間',
    primary key (`id`),
    KEY `idx_client_log_1` (`player_id`),
    KEY `idx_client_log_2` (`log_id`)
)
    COMMENT = '客户端日志'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_hero_use`
(
    `player_id` INT unsigned      NOT NULL COMMENT '玩家id',
    `hero_id`   SMALLINT unsigned NOT NULL COMMENT '英雄ID',
    `arms`      SMALLINT unsigned NOT NULL DEFAULT 0 COMMENT '武器',
    `ornaments` SMALLINT unsigned NOT NULL DEFAULT 0 COMMENT '饰品',
    primary key (`player_id`)
)
    COMMENT = '玩家装备英雄'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_hero`
(
    `player_id` INT unsigned      NOT NULL COMMENT '玩家id',
    `hero_id`   SMALLINT unsigned NOT NULL COMMENT '英雄ID',
    `star`      TINYINT unsigned  NOT NULL DEFAULT 0 COMMENT '星级',
    primary key (`player_id`, `hero_id`)
)
    COMMENT = '玩家英雄'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_hero_parts`
(
    `player_id` INT unsigned      NOT NULL COMMENT '玩家id',
    `parts_id`  SMALLINT unsigned NOT NULL COMMENT '部件ID',
    primary key (`player_id`, `parts_id`)
)
    COMMENT = '玩家英雄部件'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_card_book`
(
    `player_id`    INT unsigned      NOT NULL COMMENT '玩家id',
    `card_book_id` SMALLINT unsigned NOT NULL COMMENT '卡牌图鉴id',
    primary key (`player_id`, `card_book_id`)
)
    COMMENT = '玩家卡牌图鉴'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_card_title`
(
    `player_id`     INT unsigned NOT NULL COMMENT '玩家id',
    `card_title_id` INT unsigned NOT NULL COMMENT '卡牌标题id',
    primary key (`player_id`, `card_title_id`)
)
    COMMENT = '玩家卡牌标题'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `player_card`
(
    `player_id` INT unsigned     NOT NULL COMMENT '玩家id',
    `card_id`   INT unsigned     NOT NULL COMMENT '卡牌id',
    `state`     TINYINT unsigned NOT NULL DEFAULT 0 COMMENT '0:未领取,2:已领取',
    `num`       INT unsigned     NOT NULL DEFAULT 0 COMMENT '数量',
    primary key (`player_id`, `card_id`)
)
    COMMENT = '玩家卡牌'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';
