CREATE TABLE `player_daily_points` (
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `bid` int(11) NOT NULL COMMENT '领取积分宝箱id',
  `create_time` int(11) NOT NULL COMMENT '领取时间',
  PRIMARY KEY (`player_id`,`bid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='每日积分宝箱领取记录';