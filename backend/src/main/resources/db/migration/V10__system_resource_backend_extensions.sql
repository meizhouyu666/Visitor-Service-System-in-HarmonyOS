ALTER TABLE users
    ADD COLUMN managed_hotel_id VARCHAR(32) NULL,
    ADD COLUMN enabled TINYINT(1) NOT NULL DEFAULT 1;

ALTER TABLE query_scenic_spots
    ADD COLUMN online_status VARCHAR(16) NOT NULL DEFAULT 'ONLINE',
    ADD COLUMN updated_by VARCHAR(64) NOT NULL DEFAULT 'system',
    ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE query_routes
    ADD COLUMN cover_image_url VARCHAR(255) NULL,
    ADD COLUMN online_status VARCHAR(16) NOT NULL DEFAULT 'ONLINE',
    ADD COLUMN updated_by VARCHAR(64) NOT NULL DEFAULT 'system',
    ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE query_dining
    ADD COLUMN online_status VARCHAR(16) NOT NULL DEFAULT 'ONLINE',
    ADD COLUMN updated_by VARCHAR(64) NOT NULL DEFAULT 'system',
    ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

ALTER TABLE query_performances
    ADD COLUMN cover_image_url VARCHAR(255) NULL,
    ADD COLUMN online_status VARCHAR(16) NOT NULL DEFAULT 'ONLINE',
    ADD COLUMN updated_by VARCHAR(64) NOT NULL DEFAULT 'system',
    ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    actor_username VARCHAR(64) NULL,
    actor_role VARCHAR(32) NULL,
    module_name VARCHAR(64) NOT NULL,
    action_name VARCHAR(64) NOT NULL,
    target_type VARCHAR(64) NULL,
    target_id VARCHAR(64) NULL,
    detail_text TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS system_settings (
    setting_key VARCHAR(64) PRIMARY KEY,
    setting_value VARCHAR(255) NOT NULL,
    description_text VARCHAR(255) NOT NULL,
    updated_by VARCHAR(64) NOT NULL DEFAULT 'system',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

UPDATE users
SET managed_hotel_id = CASE
    WHEN username = 'hoteladmin' THEN 'h-1'
    ELSE managed_hotel_id
END,
enabled = 1;

UPDATE query_scenic_spots
SET online_status = 'ONLINE',
    updated_by = 'system';

UPDATE query_routes
SET cover_image_url = CASE id
        WHEN 'r-1' THEN 'route_cover_a'
        WHEN 'r-2' THEN 'route_cover_b'
        ELSE 'route_cover_a'
    END,
    online_status = 'ONLINE',
    updated_by = 'system';

UPDATE query_dining
SET online_status = 'ONLINE',
    updated_by = 'system';

UPDATE query_performances
SET cover_image_url = CASE id
        WHEN 'p-1' THEN 'performance_cover_a'
        WHEN 'p-2' THEN 'performance_cover_b'
        ELSE 'performance_cover_a'
    END,
    online_status = 'ONLINE',
    updated_by = 'system';

INSERT INTO system_settings (setting_key, setting_value, description_text, updated_by) VALUES
('PASSWORD_RESET_CODE_EXPIRE_SECONDS', '600', '找回密码验证码有效期（秒）', 'system'),
('COMPLAINT_TIMEOUT_MINUTES', '120', '投诉超时提醒阈值（分钟）', 'system'),
('EMERGENCY_DEFAULT_VALID_HOURS', '24', '应急信息默认有效时长（小时）', 'system'),
('TOURIST_RESOURCE_CACHE_SECONDS', '300', '游客端资源缓存时间（秒）', 'system')
ON DUPLICATE KEY UPDATE
    setting_value = VALUES(setting_value),
    description_text = VALUES(description_text),
    updated_by = VALUES(updated_by);
