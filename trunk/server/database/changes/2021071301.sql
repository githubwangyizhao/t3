DROP TABLE IF EXISTS `activity_data_info`;
DROP TABLE IF EXISTS `player_activity`;
create TABLE `activity_info`  (
  `activity_id` int(11) NOT NULL COMMENT '活动id',
  `state` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0: 关闭 1:准备 2: 启动',
  `last_open_time` int(11) NOT NULL DEFAULT 0 COMMENT '上次开始时间',
  `last_close_time` int(11) NOT NULL DEFAULT 0 COMMENT '上次结束时间',
  `config_open_time` int(11) NOT NULL DEFAULT 0 COMMENT '活动配置开始时间',
  `config_close_time` int(11) NOT NULL DEFAULT 0 COMMENT '活动配置结束时间',
  PRIMARY KEY (`activity_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '活动时间信息' ROW_FORMAT = Compact;

create TABLE `player_activity_info`
(
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `activity_id` int(11) NOT NULL COMMENT '活动id',
  `state` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0: 关闭 1:准备 2: 启动',
  `last_open_time` int(11) NOT NULL DEFAULT 0 COMMENT '上次开始时间',
  `last_close_time` int(11) NOT NULL DEFAULT 0 COMMENT '上次结束时间',
  `config_open_time` int(11) NOT NULL DEFAULT 0 COMMENT '活动配置开始时间',
  `config_close_time` int(11) NOT NULL DEFAULT 0 COMMENT '活动配置结束时间',
  PRIMARY KEY (`player_id`, `activity_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家活动时间信息' ;