DROP TABLE IF EXISTS `gift_code_type`;
CREATE TABLE `gift_code_type`  (
  `type` int(11) NOT NULL AUTO_INCREMENT COMMENT '礼包码type',
  `name` varchar(128) NOT NULL DEFAULT '' COMMENT '名称',
  `platform_id` varchar(128) NOT NULL DEFAULT '' COMMENT '限制平台',
  `channel_list` varchar(1024) NOT NULL DEFAULT '' COMMENT '限制渠道',
  `award_list` varchar(512) NOT NULL DEFAULT '' COMMENT '奖励列表',
  `user_id` int(11) NOT NULL DEFAULT 0 COMMENT '用户id',
  `kind` int(11) NOT NULL DEFAULT 0 COMMENT '礼包类别：0:通码(一码通用) 1:多码',
  `num` int(11) NOT NULL DEFAULT 0 COMMENT '申请数量',
  `allow_role_repeated_get` int(11) NOT NULL DEFAULT 0 COMMENT '单角色是否可以多次领取(多码有效)',
  `vip_limit` int(11) NOT NULL DEFAULT 0 COMMENT 'vip限制',
  `level_limit` int(11) NOT NULL DEFAULT 0 COMMENT 'level限制',
  `expire_time` int(11) NOT NULL DEFAULT 0 COMMENT '过期时间',
  `update_time` int(11) NOT NULL DEFAULT 0 COMMENT '更新时间',
  PRIMARY KEY (`type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '礼包码类型' ;

DROP TABLE IF EXISTS `gift_code`;
CREATE TABLE `gift_code`  (
  `gift_code` varchar(36) NOT NULL COMMENT '礼包码',
  `gift_code_type` int(11) NOT NULL DEFAULT 0 COMMENT '礼包码类型',
  PRIMARY KEY (`gift_code`) USING BTREE,
  INDEX `idx_gift_code_1`(`gift_code_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '礼包码' ;

DROP TABLE IF EXISTS `player_gift_code`;
CREATE TABLE `player_gift_code`  (
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `gift_code_type` int(11)  NOT NULL  COMMENT '礼包码类型',
  `times`int(11)  NOT NULL DEFAULT 0 COMMENT '领取次数',
  `change_time` int(11) NOT NULL DEFAULT 0 COMMENT '时间',
  PRIMARY KEY (`player_id`, `gift_code_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家兑换码领取数据' ;