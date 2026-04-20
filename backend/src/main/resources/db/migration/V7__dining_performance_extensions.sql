ALTER TABLE query_dining
    ADD COLUMN logo_url VARCHAR(255) NULL,
    ADD COLUMN distance_meters INT NOT NULL DEFAULT 800,
    ADD COLUMN is_open TINYINT(1) NOT NULL DEFAULT 1,
    ADD COLUMN nav_lat DECIMAL(10, 6) NULL,
    ADD COLUMN nav_lng DECIMAL(10, 6) NULL;

ALTER TABLE query_entertainment
    ADD COLUMN logo_url VARCHAR(255) NULL,
    ADD COLUMN distance_meters INT NOT NULL DEFAULT 900,
    ADD COLUMN is_open TINYINT(1) NOT NULL DEFAULT 1,
    ADD COLUMN nav_lat DECIMAL(10, 6) NULL,
    ADD COLUMN nav_lng DECIMAL(10, 6) NULL;

ALTER TABLE query_performances
    ADD COLUMN venue VARCHAR(255) NULL,
    ADD COLUMN show_datetime VARCHAR(64) NULL,
    ADD COLUMN remaining_tickets INT NOT NULL DEFAULT 0,
    ADD COLUMN ticket_status VARCHAR(32) NOT NULL DEFAULT 'AVAILABLE',
    ADD COLUMN distance_meters INT NOT NULL DEFAULT 1000,
    ADD COLUMN nav_lat DECIMAL(10, 6) NULL,
    ADD COLUMN nav_lng DECIMAL(10, 6) NULL;

UPDATE query_dining
SET logo_url = CASE id
        WHEN 'd-1' THEN 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=200&q=80'
        WHEN 'd-2' THEN 'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=200&q=80'
        ELSE NULL
    END,
    distance_meters = CASE id
        WHEN 'd-1' THEN 450
        WHEN 'd-2' THEN 780
        ELSE 900
    END,
    is_open = CASE id
        WHEN 'd-1' THEN 1
        WHEN 'd-2' THEN 1
        ELSE 0
    END,
    nav_lat = CASE id
        WHEN 'd-1' THEN 24.510800
        WHEN 'd-2' THEN 24.523100
        ELSE 24.500000
    END,
    nav_lng = CASE id
        WHEN 'd-1' THEN 117.652200
        WHEN 'd-2' THEN 117.661500
        ELSE 117.640000
    END;

UPDATE query_entertainment
SET logo_url = CASE id
        WHEN 'e-1' THEN 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=200&q=80'
        WHEN 'e-2' THEN 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=200&q=80'
        ELSE NULL
    END,
    distance_meters = CASE id
        WHEN 'e-1' THEN 620
        WHEN 'e-2' THEN 980
        ELSE 1200
    END,
    is_open = CASE id
        WHEN 'e-1' THEN 1
        WHEN 'e-2' THEN 1
        ELSE 0
    END,
    nav_lat = CASE id
        WHEN 'e-1' THEN 24.507600
        WHEN 'e-2' THEN 24.499100
        ELSE 24.500000
    END,
    nav_lng = CASE id
        WHEN 'e-1' THEN 117.640800
        WHEN 'e-2' THEN 117.629800
        ELSE 117.640000
    END;

UPDATE query_performances
SET venue = location,
    show_datetime = CASE id
        WHEN 'p-1' THEN '2026-04-21 20:00'
        WHEN 'p-2' THEN '2026-04-22 19:30'
        ELSE CONCAT('2026-04-23 ', show_time)
    END,
    remaining_tickets = CASE id
        WHEN 'p-1' THEN 128
        WHEN 'p-2' THEN 16
        ELSE 0
    END,
    ticket_status = CASE id
        WHEN 'p-1' THEN 'AVAILABLE'
        WHEN 'p-2' THEN 'LOW_STOCK'
        ELSE 'SOLD_OUT'
    END,
    distance_meters = CASE id
        WHEN 'p-1' THEN 730
        WHEN 'p-2' THEN 1150
        ELSE 1400
    END,
    nav_lat = CASE id
        WHEN 'p-1' THEN 24.516000
        WHEN 'p-2' THEN 24.503700
        ELSE 24.500000
    END,
    nav_lng = CASE id
        WHEN 'p-1' THEN 117.646500
        WHEN 'p-2' THEN 117.635000
        ELSE 117.640000
    END;

