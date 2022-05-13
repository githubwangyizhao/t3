CREATE TABLE `player_fight_adjust`
(
    `player_id`  INT unsigned     NOT NULL COMMENT '玩家id',
    `prop_id`    INT unsigned     NOT NULL COMMENT '道具id',
    `pool`       TINYINT unsigned NOT NULL DEFAULT 0 COMMENT '当前池子',
    `pool_times` INT unsigned     NOT NULL DEFAULT 0 COMMENT '当前池子次数',
    `rate`       INT unsigned     NOT NULL DEFAULT 0 COMMENT '当前倍率',
    `cost_rate`  INT unsigned     NOT NULL DEFAULT 0 COMMENT '当前消耗倍率',
    `cost_pool`  TINYINT unsigned NOT NULL DEFAULT 0 COMMENT '当前消耗池子',
    `pool_1`     INT unsigned     NOT NULL DEFAULT 0 COMMENT '池子1',
    `pool_2`     INT unsigned     NOT NULL DEFAULT 0 COMMENT '池子2',
    primary key (`player_id`, `prop_id`)
)
    COMMENT = '玩家个人战斗修正'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';
