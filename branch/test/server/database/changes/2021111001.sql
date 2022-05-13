CREATE TABLE `laba_adjust` (
  `laba_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '拉霸机id',
  `cost_rate` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '消耗倍率',
  `pool` bigint(20) DEFAULT '0' COMMENT '奖池数',
  PRIMARY KEY (`laba_id`,`cost_rate`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='拉霸机修正池';