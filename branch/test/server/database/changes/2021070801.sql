DROP TABLE IF EXISTS `boss_one_on_one`;
CREATE TABLE `boss_one_on_one`  (
  `id` int(11) NOT NULL COMMENT '主键',
  `home_boss` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '左侧boss id',
  `away_boss` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '右侧boss id',
  `player_total_cost` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '总投注',
  `player_total_award` bigint(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT '总奖励',
  `winner` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT '获胜boss(0为home,1为away,默认为0)',
  `created_time` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '对局开始时间戳',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;