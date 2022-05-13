CREATE TABLE `scene_boss_adjust`(
    `scene_id`         INT      unsigned        NOT NULL COMMENT '场景id',
    `pool_value`       BIGINT                   NOT NULL DEFAULT 0 COMMENT '场景boss修正池',
    primary key (`scene_id`)
)
    COMMENT = '场景boss修正'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';