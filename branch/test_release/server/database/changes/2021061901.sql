CREATE TABLE `tongxingzheng_daily_task` (
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `task_list` varchar(1024) NOT NULL COMMENT '任务列表[{任务id,完成数,奖励领取状态}|...]',
  PRIMARY KEY (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tongxingzheng_month_task` (
  `player_id` int(11) NOT NULL COMMENT '玩家id',
  `task_list` varchar(2048) NOT NULL COMMENT '任务列表[{任务id,完成数,奖励领取状态}|...]',
  PRIMARY KEY (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
