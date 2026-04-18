ALTER TABLE query_hotels
    ADD COLUMN availability_status VARCHAR(32) NOT NULL DEFAULT 'AVAILABLE',
    ADD COLUMN cover_image_url VARCHAR(255) NULL;

ALTER TABLE query_scenic_spots
    ADD COLUMN crowd_heat INT NOT NULL DEFAULT 45,
    ADD COLUMN cover_image_url VARCHAR(255) NULL;

ALTER TABLE query_traffic
    ADD COLUMN severity_level VARCHAR(32) NOT NULL DEFAULT 'MEDIUM';

ALTER TABLE emergency_infos
    ADD COLUMN alert_level VARCHAR(32) NOT NULL DEFAULT 'MEDIUM',
    ADD COLUMN alert_type VARCHAR(64) NOT NULL DEFAULT 'GENERAL';

UPDATE query_hotels
SET availability_status = CASE id
    WHEN 'h-1' THEN 'BUSY'
    WHEN 'h-2' THEN 'AVAILABLE'
    ELSE 'LIMITED'
END,
cover_image_url = CASE id
    WHEN 'h-1' THEN 'hotel_cover_a'
    WHEN 'h-2' THEN 'hotel_cover_b'
    ELSE 'hotel_cover_a'
END;

UPDATE query_scenic_spots
SET crowd_heat = CASE id
    WHEN 's-1' THEN 72
    WHEN 's-2' THEN 38
    ELSE 50
END,
cover_image_url = CASE id
    WHEN 's-1' THEN 'scenic_cover_a'
    WHEN 's-2' THEN 'scenic_cover_b'
    ELSE 'scenic_cover_a'
END;

UPDATE query_traffic
SET severity_level = CASE id
    WHEN 't-1' THEN 'LOW'
    WHEN 't-2' THEN 'MEDIUM'
    ELSE 'MEDIUM'
END;
