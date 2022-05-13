DROP TABLE IF EXISTS `player_bounty_task`;
CREATE TABLE `player_bounty_task`  (
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `id` int(11) NOT NULL DEFAULT 0 COMMENT 'id',
  `value` bigint(20) NOT NULL DEFAULT 0 COMMENT '值',
  `state` tinyint(4) NOT NULL DEFAULT 0 COMMENT '领取状态(0-未领取,1-可领取,2-已领取)',
  `change_time` int(11) NOT NULL DEFAULT 0 COMMENT '操作时间',
  PRIMARY KEY (`player_id`, `id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家赏金任务' ROW_FORMAT = Compact;