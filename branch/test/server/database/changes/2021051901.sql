DROP TABLE IF EXISTS `phone_unique_id`;
CREATE TABLE `phone_unique_id`  (
  `platform_id` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '平台id',
  `phone_unique_id` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '设备唯一标识码',
  `created_time` int(11) NOT NULL DEFAULT 0 COMMENT '创建时间',
  PRIMARY KEY (`platform_id`, `phone_unique_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '账号设备唯一标识码' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;