CREATE TABLE `match_scene_data`(
    `id`            TINYINT  unsigned        NOT NULL COMMENT '匹配场id',
    `player_id`     INT                      NOT NULL DEFAULT 0 COMMENT '玩家id',
    `score`         BIGINT                   NOT NULL DEFAULT 0 COMMENT '积分',
    `award`         BIGINT                   NOT NULL DEFAULT 0 COMMENT '奖励',
    `last_time`     INT      unsigned        NOT NULL DEFAULT 0 COMMENT '上次结算时间',
    primary key (`id`)
)
    COMMENT = '匹配场'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';