CREATE TABLE `player_first_charge` (
  `player_id`   INT     NOT NULL            COMMENT '玩家id',
  `type`        TINYINT NOT NULL            COMMENT '类型',
  `recharge_id` INT     NOT NULL            COMMENT '充值id',
  `login_day`   INT     NOT NULL DEFAULT 1  COMMENT '登录天数',
  `time`        INT     NOT NULL DEFAULT 0  COMMENT '时间',
  PRIMARY KEY (`player_id`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家首充';

CREATE TABLE `player_first_charge_day` (
  `player_id`   INT     NOT NULL            COMMENT '玩家id',
  `type`        TINYINT NOT NULL            COMMENT '类型',
  `day`         TINYINT NOT NULL            COMMENT '天数',
  `time`        INT     NOT NULL            COMMENT '领取时间',
  PRIMARY KEY (`player_id`,`type`,`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='玩家首充天数';