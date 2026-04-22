ALTER TABLE query_hotels
    ADD COLUMN marketing_recommended TINYINT(1) NOT NULL DEFAULT 0,
    ADD COLUMN marketing_tag VARCHAR(64) NULL,
    ADD COLUMN marketing_priority INT NOT NULL DEFAULT 0,
    ADD COLUMN marketing_note VARCHAR(255) NULL,
    ADD COLUMN marketing_updated_by VARCHAR(64) NULL,
    ADD COLUMN marketing_updated_at DATETIME NULL;

UPDATE query_hotels
SET marketing_recommended = CASE id
        WHEN 'h-1' THEN 1
        WHEN 'h-3' THEN 1
        ELSE 0
    END,
    marketing_tag = CASE id
        WHEN 'h-1' THEN '官方力推'
        WHEN 'h-3' THEN '乡村优选'
        ELSE NULL
    END,
    marketing_priority = CASE id
        WHEN 'h-1' THEN 100
        WHEN 'h-3' THEN 80
        ELSE 0
    END,
    marketing_note = CASE id
        WHEN 'h-1' THEN '优先承接湖畔景区住宿流量'
        WHEN 'h-3' THEN '重点承接西区乡村休闲游客'
        ELSE NULL
    END,
    marketing_updated_by = 'system',
    marketing_updated_at = NOW();
