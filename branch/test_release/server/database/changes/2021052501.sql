CREATE TABLE `player_card_summon` (
  `player_id` int(10) NOT NULL COMMENT '玩家id',
  `once_cnt` int(10) NOT NULL COMMENT '单抽还剩几次抽高级卡池',
  `ten_times_cnt` int(10) NOT NULL COMMENT '十连抽还剩几次抽高级卡池',
  PRIMARY KEY (`player_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;
SET FOREIGN_KEY_CHECKS = 1;