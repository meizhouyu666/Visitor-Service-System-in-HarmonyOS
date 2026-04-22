CREATE TABLE IF NOT EXISTS hotel_room_types (
    id VARCHAR(32) PRIMARY KEY,
    hotel_id VARCHAR(32) NOT NULL,
    name VARCHAR(128) NOT NULL,
    total_rooms INT NOT NULL,
    available_rooms INT NOT NULL,
    price INT NOT NULL,
    image_url VARCHAR(255) NULL,
    sort_order INT NOT NULL DEFAULT 0,
    updated_by VARCHAR(64) NULL,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hotel_room_types_hotel FOREIGN KEY (hotel_id) REFERENCES query_hotels(id) ON DELETE CASCADE
);

CREATE INDEX idx_hotel_room_types_hotel_id ON hotel_room_types(hotel_id, sort_order, id);

INSERT INTO hotel_room_types (id, hotel_id, name, total_rooms, available_rooms, price, image_url, sort_order)
VALUES
('rt-h1-1', 'h-1', '豪华大床房', 50, 12, 599, 'https://images.unsplash.com/photo-1590490359683-658d3d23f972?auto=format&fit=crop&w=400&q=80', 1),
('rt-h1-2', 'h-1', '双人标准间', 80, 5, 450, 'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=400&q=80', 2),
('rt-h1-3', 'h-1', '全景家庭套房', 15, 0, 1299, 'https://images.unsplash.com/photo-1591088398332-8a7791972843?auto=format&fit=crop&w=400&q=80', 3),
('rt-h2-1', 'h-2', '山景双床房', 36, 9, 428, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=400&q=80', 1),
('rt-h2-2', 'h-2', '亲子家庭房', 18, 4, 588, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=400&q=80', 2),
('rt-h3-1', 'h-3', '乡野庭院大床房', 20, 6, 238, 'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?auto=format&fit=crop&w=400&q=80', 1),
('rt-h3-2', 'h-3', '木屋亲子套房', 8, 2, 318, 'https://images.unsplash.com/photo-1449158743715-0a90ebb6d2d8?auto=format&fit=crop&w=400&q=80', 2)
ON DUPLICATE KEY UPDATE
    hotel_id = VALUES(hotel_id),
    name = VALUES(name),
    total_rooms = VALUES(total_rooms),
    available_rooms = VALUES(available_rooms),
    price = VALUES(price),
    image_url = VALUES(image_url),
    sort_order = VALUES(sort_order);
