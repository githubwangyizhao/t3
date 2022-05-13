CREATE TABLE `one_vs_one_rank_data`(
    `type`          TINYINT  unsigned        NOT NULL COMMENT '类型',
    `player_id`     INT                      NOT NULL DEFAULT 0 COMMENT '玩家id',
    `score`         BIGINT                   NOT NULL DEFAULT 0 COMMENT '积分',
    `time`          INT                      NOT NULL DEFAULT 0 COMMENT '时间',
    primary key (`type`, `player_id`)
)
    COMMENT = '匹配场'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';