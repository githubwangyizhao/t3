DROP TABLE IF EXISTS `player_leichong`;
CREATE TABLE `player_leichong` (
  `player_id` int(11) NOT NULL COMMENT ' 玩家id',
  `activity_id` int(11) NOT NULL COMMENT ' 活动id',
  `task_id` int(11) NOT NULL COMMENT ' 任务id',
  `done` int(11) NOT NULL DEFAULT '0' COMMENT ' 完成数',
  `state` tinyint(1) NOT NULL DEFAULT '0' COMMENT ' 奖励状态 0-未完成 1-可领取 2-已领取',
  PRIMARY KEY (`player_id`,`activity_id`,`task_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;