ALTER TABLE `player_invest` ADD COLUMN `type` TINYINT UNSIGNED NOT NULL COMMENT '类型' AFTER `player_id`;
ALTER TABLE `player_invest` DROP PRIMARY KEY;
ALTER TABLE `player_invest` ADD PRIMARY KEY (`player_id`, `type`, `id`);

CREATE TABLE `player_invest_type`
(
    `player_id`   INT unsigned NOT NULL COMMENT '玩家id',
    `type`        TINYINT      NOT NULL COMMENT 'type',
    `is_buy`      TINYINT      NOT NULL DEFAULT '0' COMMENT '是否购买',
    `update_time` INT          NOT NULL DEFAULT '0' COMMENT '购买时间',
    PRIMARY KEY (`player_id`, `type`)
)
    COMMENT = '玩家投资返利类型'
    ENGINE = 'InnoDB'
    CHARACTER SET = 'utf8'
    COLLATE = 'utf8_general_ci';