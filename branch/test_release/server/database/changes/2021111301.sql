CREATE TABLE `wheel_player_bet_record_today`  (
  `player_id`   int(11)    NOT NULL COMMENT '玩家id',
  `type`        tinyint(4) NOT NULL COMMENT '类型',
  `id`          int(11)    NOT NULL COMMENT '玩家自增长id',
  `bet_num`     int(11)    NOT NULL DEFAULT 0 COMMENT '投注数量',
  `award_num`   int(11)    NOT NULL DEFAULT 0 COMMENT '投注奖励数量',
  `time`        int(11)    NOT NULL DEFAULT 0 COMMENT '时间',
  PRIMARY KEY (`player_id`, `type`, `id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家当天无尽对决投注记录' ROW_FORMAT = Compact;

CREATE TABLE `wheel_player_bet_record`  (
  `player_id`   int(11)    NOT NULL COMMENT '玩家id',
  `type`        tinyint(4) NOT NULL COMMENT '类型',
  `id`          int(11)    NOT NULL COMMENT 'wheel_id',
  `bet_num`     int(11)    NOT NULL DEFAULT 0 COMMENT '投注数量',
  `award_num`   int(11)    NOT NULL DEFAULT 0 COMMENT '投注奖励数量',
  `time`        int(11)    NOT NULL DEFAULT 0 COMMENT '时间',
  PRIMARY KEY (`player_id`, `type`, `id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家近二十局无尽对决投注记录' ROW_FORMAT = Compact;

CREATE TABLE `wheel_result_record`  (
  `type`        tinyint(4)  NOT NULL COMMENT '类型',
  `id`          int(11)     NOT NULL COMMENT 'id',
  `result_id`   tinyint(4)  NOT NULL DEFAULT 0 COMMENT '结果id',
  `time`        int(11)     NOT NULL DEFAULT 0 COMMENT '时间',
  PRIMARY KEY (`type`, `id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '无尽对决结果记录' ROW_FORMAT = Compact;