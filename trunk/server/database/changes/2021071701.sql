CREATE TABLE `server_player_fight_adjust`
(
    `player_id`         INT unsigned      NOT NULL COMMENT '玩家id',
    `prop_id`           INT unsigned      NOT NULL COMMENT '道具id',
    `id`                TINYINT unsigned  NOT NULL DEFAULT 0 COMMENT '修正id',
    `times`             INT unsigned      NOT NULL DEFAULT 0 COMMENT '修正次数',
    `bottom_times`      TINYINT           NOT NULL DEFAULT 0 COMMENT '触底反弹次数使用',
    `bottom_times_time` INT               NOT NULL DEFAULT 0 COMMENT '上一次触底反弹使用时间',
    primary key (`player_id`, `prop_id`)
)
    COMMENT = '服务器玩家战斗修正'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';

CREATE TABLE `server_fight_adjust`
(
   `prop_id`    INT unsigned       NOT NULL COMMENT '道具id',
   `pool_value` BIGINT             NOT NULL DEFAULT 0 COMMENT '池子值',
   `cost`       BIGINT unsigned    NOT NULL DEFAULT 0 COMMENT '总消耗',
   `award`      BIGINT unsigned    NOT NULL DEFAULT 0 COMMENT '总奖励',
   primary key (`prop_id`)
)
   COMMENT = '服务器战斗修正'
   ENGINE = 'InnoDB'
   CHARACTER SET = 'utf8'
   COLLATE = 'utf8_general_ci';