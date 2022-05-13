ALTER TABLE `player_data` ADD COLUMN `head_frame_id` INT not null DEFAULT '0' COMMENT '头像框' AFTER `head_id`;
ALTER TABLE `player_data` ADD COLUMN `chat_qi_pao_id` INT not null DEFAULT '0' COMMENT '聊天气泡id' AFTER `head_frame_id`;
