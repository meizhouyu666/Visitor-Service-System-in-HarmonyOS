CREATE TABLE IF NOT EXISTS query_hotels (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    address VARCHAR(255) NOT NULL,
    star INT NOT NULL,
    price INT NOT NULL,
    phone VARCHAR(64) NOT NULL,
    score DECIMAL(3,1) NOT NULL,
    has_breakfast TINYINT(1) NOT NULL,
    facility VARCHAR(255) NOT NULL,
    introduction TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS query_scenic_spots (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    scenic_area VARCHAR(128) NOT NULL,
    location VARCHAR(255) NOT NULL,
    open_time VARCHAR(64) NOT NULL,
    ticket_price INT NOT NULL,
    level VARCHAR(16) NOT NULL,
    type VARCHAR(64) NOT NULL,
    is_free TINYINT(1) NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS query_routes (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    duration_hours INT NOT NULL,
    difficulty VARCHAR(32) NOT NULL,
    suitable_for VARCHAR(64) NOT NULL,
    spots VARCHAR(255) NOT NULL,
    detail TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS query_dining (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    type VARCHAR(64) NOT NULL,
    avg_price INT NOT NULL,
    business_hours VARCHAR(64) NOT NULL,
    address VARCHAR(255) NOT NULL,
    recommend_food VARCHAR(255) NOT NULL,
    detail_desc TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS query_entertainment (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    type VARCHAR(64) NOT NULL,
    location VARCHAR(255) NOT NULL,
    open_time VARCHAR(64) NOT NULL,
    price INT NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS query_performances (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(128) NOT NULL,
    location VARCHAR(255) NOT NULL,
    show_time VARCHAR(64) NOT NULL,
    price INT NOT NULL,
    team VARCHAR(128) NOT NULL,
    detail TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS query_weather (
    id VARCHAR(32) PRIMARY KEY,
    date_value VARCHAR(32) NOT NULL,
    weather VARCHAR(64) NOT NULL,
    temperature VARCHAR(64) NOT NULL,
    wind VARCHAR(64) NOT NULL,
    humidity INT NOT NULL,
    tip VARCHAR(255) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS query_traffic (
    id VARCHAR(32) PRIMARY KEY,
    from_location VARCHAR(128) NOT NULL,
    to_location VARCHAR(128) NOT NULL,
    status VARCHAR(64) NOT NULL,
    suggest_route VARCHAR(255) NOT NULL,
    take_time VARCHAR(64) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

INSERT INTO query_hotels (id, name, address, star, price, phone, score, has_breakfast, facility, introduction) VALUES
('h-1', '晨曦国际酒店', '湖滨路18号', 5, 699, '0596-111111', 4.8, 1, '泳池,健身房,SPA', '位于古城核心区域的高品质商务休闲酒店'),
('h-2', '山景假日酒店', '景观大道28号', 4, 428, '0596-222222', 4.6, 1, '停车场,Wifi,餐厅', '适合家庭出游的山景酒店'),
('h-3', '乡野暖居客栈', '民俗街8号', 3, 238, '0596-333333', 4.4, 0, 'Wifi,茶室', '性价比高的本地风格客栈')
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO query_scenic_spots (id, name, scenic_area, location, open_time, ticket_price, level, type, is_free, description) VALUES
('s-1', '云峰景区', '北部景区', '北山景区', '08:00-17:30', 80, 'AAAA', '山岳', 0, '适合看日出和森林徒步'),
('s-2', '古镇老街', '中心景区', '古城中心', '全天开放', 0, 'AAAA', '人文', 1, '历史街巷与美食文化聚集地')
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO query_routes (id, name, duration_hours, difficulty, suitable_for, spots, detail) VALUES
('r-1', '亲子一日游', 8, '简单', '亲子家庭', '古镇老街,云峰景区', '以文化体验和轻徒步为主的一日路线'),
('r-2', '山野探索线', 12, '中等', '青年游客', '云峰景区,河谷栈道', '覆盖山地与河谷的进阶路线')
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO query_dining (id, name, type, avg_price, business_hours, address, recommend_food, detail_desc) VALUES
('d-1', '江畔食府', '本地菜', 88, '10:00-22:00', '滨江路6号', '红烧鱼,香草鸡', '游客口碑较高的本地菜馆'),
('d-2', '山城面馆', '面食', 35, '09:00-21:00', '山谷路3号', '手工面', '出餐快、口味稳定')
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO query_entertainment (id, name, type, location, open_time, price, description) VALUES
('e-1', '夜色音乐广场', '音乐广场', '古城东门', '19:00-23:00', 0, '露天音乐与夜市互动活动'),
('e-2', '江岸光影园', '夜游', '滨江景观带', '18:30-22:30', 30, '夜间灯光秀与互动演艺')
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO query_performances (id, name, location, show_time, price, team, detail) VALUES
('p-1', '民俗歌舞秀', '文化剧场', '20:00', 68, '民俗演艺团', '传统歌舞与游客互动环节'),
('p-2', '山城实景剧', '古戏台', '19:30', 88, '山城剧团', '结合地方故事的沉浸式舞台演出')
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO query_weather (id, date_value, weather, temperature, wind, humidity, tip, sort_order) VALUES
('w-1', '2026-04-17', '晴', '26°C', '东风2级', 55, '适合户外出行', 1),
('w-2', '2026-04-18', '多云', '24°C', '北风3级', 62, '早晚温差较大，建议备薄外套', 2)
ON DUPLICATE KEY UPDATE id = VALUES(id);

INSERT INTO query_traffic (id, from_location, to_location, status, suggest_route, take_time, sort_order) VALUES
('t-1', '市中心', '云峰景区', '畅通', '主干道 -> 景区大道', '45分钟', 1),
('t-2', '高铁站', '古镇老街', '缓行', '环城路 -> 东门入口', '30分钟', 2)
ON DUPLICATE KEY UPDATE id = VALUES(id);
