DROP TABLE IF EXISTS `player_laba_data`;
CREATE TABLE `player_laba_data`  (
  `player_id` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '玩家id',
  `laba_id` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '拉霸id',
  `cost_rate` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '消耗倍率',
  `missed_times` int(11) UNSIGNED NULL DEFAULT 0 COMMENT '连续未中奖次数',
  PRIMARY KEY (`player_id`, `laba_id`, `cost_rate`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '玩家拉霸未中奖次数记录' ROW_FORMAT = Compact;