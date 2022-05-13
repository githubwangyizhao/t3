CREATE TABLE `wheel_pool`  (
  `type`        tinyint(4)  NOT NULL COMMENT '类型',
  `value`       int(11)     NOT NULL COMMENT '池子值',
  PRIMARY KEY (`type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '无尽对决池子' ROW_FORMAT = Compact;