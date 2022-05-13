CREATE TABLE `wheel_result_record_accumulate`  (
  `type`        tinyint(4)  NOT NULL COMMENT '类型',
  `u_id`        int(11)     NOT NULL COMMENT 'u_id期数',
  `record_type` tinyint(4)  NOT NULL COMMENT '记录类型(1:类型2:单体)',
  `id`          tinyint(4)  NOT NULL COMMENT 'id',
  `num`         int(11)     NOT NULL DEFAULT 0 COMMENT '数量',
  `time`        int(11)     NOT NULL DEFAULT 0 COMMENT '时间',
  PRIMARY KEY (`type`, `u_id`, `record_type`, `id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '无尽对决结果记录累计数量' ROW_FORMAT = Compact;