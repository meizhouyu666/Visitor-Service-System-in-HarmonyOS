package com.visitor.service.resource;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.resource.dto.ResourceItemRequest;
import com.visitor.service.resource.dto.ResourceItemResponse;
import com.visitor.service.system.AuditLogService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@Transactional
public class ResourceLibraryService {

    private final JdbcTemplate jdbcTemplate;
    private final AuditLogService auditLogService;

    public ResourceLibraryService(JdbcTemplate jdbcTemplate, AuditLogService auditLogService) {
        this.jdbcTemplate = jdbcTemplate;
        this.auditLogService = auditLogService;
    }

    @Transactional(readOnly = true)
    public List<ResourceItemResponse> list(ResourceCategory category, String keyword) {
        String likeKeyword = normalizeLikeKeyword(keyword);
        return switch (category) {
            case SCENIC_SPOTS -> jdbcTemplate.query("""
                    SELECT id, name, scenic_area, location, open_time, ticket_price, level, type, is_free,
                           description, crowd_heat, cover_image_url, online_status, updated_by, updated_at
                    FROM query_scenic_spots
                    WHERE (? IS NULL OR LOWER(name) LIKE ? OR LOWER(location) LIKE ? OR LOWER(description) LIKE ? OR LOWER(scenic_area) LIKE ?)
                    ORDER BY updated_at DESC, id ASC
                    """, scenicMapper(), likeKeyword, likeKeyword, likeKeyword, likeKeyword, likeKeyword);
            case ROUTES -> jdbcTemplate.query("""
                    SELECT id, name, duration_hours, difficulty, suitable_for, spots, detail,
                           cover_image_url, online_status, updated_by, updated_at
                    FROM query_routes
                    WHERE (? IS NULL OR LOWER(name) LIKE ? OR LOWER(spots) LIKE ? OR LOWER(detail) LIKE ? OR LOWER(suitable_for) LIKE ?)
                    ORDER BY updated_at DESC, id ASC
                    """, routeMapper(), likeKeyword, likeKeyword, likeKeyword, likeKeyword, likeKeyword);
            case DINING -> jdbcTemplate.query("""
                    SELECT id, name, type, avg_price, business_hours, address, recommend_food, detail_desc,
                           logo_url, distance_meters, is_open, nav_lat, nav_lng, online_status, updated_by, updated_at
                    FROM query_dining
                    WHERE (? IS NULL OR LOWER(name) LIKE ? OR LOWER(address) LIKE ? OR LOWER(detail_desc) LIKE ? OR LOWER(type) LIKE ?)
                    ORDER BY updated_at DESC, id ASC
                    """, diningMapper(), likeKeyword, likeKeyword, likeKeyword, likeKeyword, likeKeyword);
            case PERFORMANCES -> jdbcTemplate.query("""
                    SELECT id, name, location, show_time, price, team, detail, venue, show_datetime,
                           remaining_tickets, ticket_status, distance_meters, nav_lat, nav_lng,
                           cover_image_url, online_status, updated_by, updated_at
                    FROM query_performances
                    WHERE (? IS NULL OR LOWER(name) LIKE ? OR LOWER(venue) LIKE ? OR LOWER(detail) LIKE ? OR LOWER(team) LIKE ?)
                    ORDER BY updated_at DESC, id ASC
                    """, performanceMapper(), likeKeyword, likeKeyword, likeKeyword, likeKeyword, likeKeyword);
        };
    }

    @Transactional(readOnly = true)
    public ResourceItemResponse detail(ResourceCategory category, String id) {
        List<ResourceItemResponse> items = listById(category, id);
        if (items.isEmpty()) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "资源不存在");
        }
        return items.get(0);
    }

    public ResourceItemResponse create(ResourceCategory category, ResourceItemRequest request, String actorUsername) {
        String id = generateId(category);
        boolean online = request.online() == null || request.online();
        switch (category) {
            case SCENIC_SPOTS -> createScenic(id, request, actorUsername, online);
            case ROUTES -> createRoute(id, request, actorUsername, online);
            case DINING -> createDining(id, request, actorUsername, online);
            case PERFORMANCES -> createPerformance(id, request, actorUsername, online);
        }
        auditLogService.record(actorUsername, "RESOURCE", "CREATE", category.name(), id, "新增资源");
        return detail(category, id);
    }

    public ResourceItemResponse update(ResourceCategory category, String id, ResourceItemRequest request, String actorUsername) {
        ResourceItemResponse current = detail(category, id);
        switch (category) {
            case SCENIC_SPOTS -> updateScenic(id, request, current, actorUsername);
            case ROUTES -> updateRoute(id, request, current, actorUsername);
            case DINING -> updateDining(id, request, current, actorUsername);
            case PERFORMANCES -> updatePerformance(id, request, current, actorUsername);
        }
        auditLogService.record(actorUsername, "RESOURCE", "UPDATE", category.name(), id, "更新资源");
        return detail(category, id);
    }

    public ResourceItemResponse setOnline(ResourceCategory category, String id, boolean online, String actorUsername) {
        ensureResourceExists(category, id);
        String table = tableName(category);
        String sql = "UPDATE " + table + " SET online_status = ?, updated_by = ? WHERE id = ?";
        jdbcTemplate.update(sql, toOnlineStatus(online), actorUsername, id);
        auditLogService.record(actorUsername, "RESOURCE", online ? "ONLINE" : "OFFLINE", category.name(), id, online ? "资源上架" : "资源下架");
        return detail(category, id);
    }

    public void delete(ResourceCategory category, String id, String actorUsername) {
        String sql = "DELETE FROM " + tableName(category) + " WHERE id = ?";
        int deleted = jdbcTemplate.update(sql, id);
        if (deleted == 0) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "资源不存在");
        }
        auditLogService.record(actorUsername, "RESOURCE", "DELETE", category.name(), id, "删除资源");
    }

    private void createScenic(String id, ResourceItemRequest request, String actorUsername, boolean online) {
        String title = requiredText(request.title(), "景点标题");
        String scenicArea = requiredText(firstNonBlank(request.scenicArea(), request.subtitle()), "景区分区");
        String location = requiredText(request.location(), "景点位置");
        String openTime = requiredText(firstNonBlank(request.openTime(), request.schedule()), "开放时间");
        Integer ticketPrice = requiredInteger(firstNonNull(request.ticketPrice(), request.price(), request.avgPrice()), "票价");
        String level = requiredText(request.level(), "景区等级");
        String type = requiredText(firstNonBlank(request.type(), request.subtitle()), "景点类型");
        boolean isFree = firstNonNull(request.isFree(), ticketPrice == 0);
        Integer crowdHeat = firstNonNull(request.crowdHeat(), 0);
        String description = requiredText(request.description(), "景点简介");

        jdbcTemplate.update("""
                INSERT INTO query_scenic_spots(
                    id, name, scenic_area, location, open_time, ticket_price, level, type, is_free,
                    description, crowd_heat, cover_image_url, online_status, updated_by
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                id,
                title,
                scenicArea,
                location,
                openTime,
                ticketPrice,
                level,
                type,
                isFree,
                description,
                crowdHeat,
                normalizeNullable(request.coverImageUrl()),
                toOnlineStatus(online),
                actorUsername
        );
    }

    private void createRoute(String id, ResourceItemRequest request, String actorUsername, boolean online) {
        String title = requiredText(request.title(), "线路标题");
        Integer durationHours = requiredInteger(request.durationHours(), "建议时长");
        String difficulty = requiredText(request.difficulty(), "难度等级");
        String suitableFor = requiredText(firstNonBlank(request.suitableFor(), request.subtitle()), "适宜人群");
        String spots = requiredText(firstNonBlank(request.spots(), request.location()), "线路内容");
        String detail = requiredText(request.description(), "线路简介");

        jdbcTemplate.update("""
                INSERT INTO query_routes(
                    id, name, duration_hours, difficulty, suitable_for, spots, detail,
                    cover_image_url, online_status, updated_by
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                id,
                title,
                durationHours,
                difficulty,
                suitableFor,
                spots,
                detail,
                normalizeNullable(request.coverImageUrl()),
                toOnlineStatus(online),
                actorUsername
        );
    }

    private void createDining(String id, ResourceItemRequest request, String actorUsername, boolean online) {
        String title = requiredText(request.title(), "餐饮名称");
        String type = requiredText(firstNonBlank(request.type(), request.subtitle()), "餐饮分类");
        Integer avgPrice = requiredInteger(firstNonNull(request.avgPrice(), request.price()), "人均价格");
        String businessHours = requiredText(firstNonBlank(request.businessHours(), request.schedule()), "营业时间");
        String address = requiredText(firstNonBlank(request.address(), request.location()), "店铺位置");
        String recommendFood = normalizeNullable(firstNonBlank(request.recommendFood(), request.subtitle()));
        String detailDesc = requiredText(request.description(), "餐饮简介");
        Integer distanceMeters = firstNonNull(request.distanceMeters(), 0);
        boolean isOpen = firstNonNull(request.isOpen(), false);

        jdbcTemplate.update("""
                INSERT INTO query_dining(
                    id, name, type, avg_price, business_hours, address, recommend_food, detail_desc,
                    logo_url, distance_meters, is_open, nav_lat, nav_lng, online_status, updated_by
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                id,
                title,
                type,
                avgPrice,
                businessHours,
                address,
                recommendFood == null ? "" : recommendFood,
                detailDesc,
                normalizeNullable(request.coverImageUrl()),
                distanceMeters,
                isOpen,
                request.navLat(),
                request.navLng(),
                toOnlineStatus(online),
                actorUsername
        );
    }

    private void createPerformance(String id, ResourceItemRequest request, String actorUsername, boolean online) {
        String title = requiredText(request.title(), "演出名称");
        String location = requiredText(firstNonBlank(request.location(), request.venue()), "演出位置");
        String showTime = requiredText(firstNonBlank(request.showTime(), request.schedule()), "演出时间");
        Integer price = requiredInteger(request.price(), "票价");
        String team = requiredText(firstNonBlank(request.team(), request.subtitle()), "演出团队");
        String detail = requiredText(request.description(), "演出简介");
        String venue = requiredText(firstNonBlank(request.venue(), request.location()), "演出场地");
        String showDateTime = normalizeNullable(firstNonBlank(request.showDateTime(), request.schedule(), showTime));
        Integer remainingTickets = firstNonNull(request.remainingTickets(), 0);
        String ticketStatus = normalizeTicketStatus(request.ticketStatus(), remainingTickets);
        Integer distanceMeters = firstNonNull(request.distanceMeters(), 0);

        jdbcTemplate.update("""
                INSERT INTO query_performances(
                    id, name, location, show_time, price, team, detail, venue, show_datetime,
                    remaining_tickets, ticket_status, distance_meters, nav_lat, nav_lng,
                    cover_image_url, online_status, updated_by
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                id,
                title,
                location,
                showTime,
                price,
                team,
                detail,
                venue,
                showDateTime,
                remainingTickets,
                ticketStatus,
                distanceMeters,
                request.navLat(),
                request.navLng(),
                normalizeNullable(request.coverImageUrl()),
                toOnlineStatus(online),
                actorUsername
        );
    }

    private void updateScenic(String id, ResourceItemRequest request, ResourceItemResponse current, String actorUsername) {
        String title = firstNonBlank(request.title(), current.title());
        String scenicArea = firstNonBlank(request.scenicArea(), request.subtitle(), current.scenicArea(), current.subtitle());
        String location = firstNonBlank(request.location(), current.location());
        String openTime = firstNonBlank(request.openTime(), request.schedule(), current.openTime(), current.schedule());
        Integer ticketPrice = firstNonNull(request.ticketPrice(), request.price(), request.avgPrice(), current.ticketPrice());
        String level = firstNonBlank(request.level(), current.level());
        String type = firstNonBlank(request.type(), request.subtitle(), current.type(), current.subtitle());
        Boolean isFree = firstNonNull(request.isFree(), current.isFree(), ticketPrice != null && ticketPrice == 0);
        Integer crowdHeat = firstNonNull(request.crowdHeat(), current.crowdHeat(), 0);
        String description = firstNonBlank(request.description(), current.description());
        String coverImageUrl = firstNonBlank(request.coverImageUrl(), current.coverImageUrl());
        boolean online = request.online() == null ? current.online() : request.online();

        jdbcTemplate.update("""
                UPDATE query_scenic_spots
                SET name = ?, scenic_area = ?, location = ?, open_time = ?, ticket_price = ?, level = ?, type = ?,
                    is_free = ?, description = ?, crowd_heat = ?, cover_image_url = ?, online_status = ?, updated_by = ?
                WHERE id = ?
                """,
                requiredText(title, "景点标题"),
                requiredText(scenicArea, "景区分区"),
                requiredText(location, "景点位置"),
                requiredText(openTime, "开放时间"),
                requiredInteger(ticketPrice, "票价"),
                requiredText(level, "景区等级"),
                requiredText(type, "景点类型"),
                firstNonNull(isFree, false),
                requiredText(description, "景点简介"),
                firstNonNull(crowdHeat, 0),
                normalizeNullable(coverImageUrl),
                toOnlineStatus(online),
                actorUsername,
                id
        );
    }

    private void updateRoute(String id, ResourceItemRequest request, ResourceItemResponse current, String actorUsername) {
        String title = firstNonBlank(request.title(), current.title());
        Integer durationHours = firstNonNull(request.durationHours(), current.durationHours());
        String difficulty = firstNonBlank(request.difficulty(), current.difficulty());
        String suitableFor = firstNonBlank(request.suitableFor(), request.subtitle(), current.suitableFor(), current.subtitle());
        String spots = firstNonBlank(request.spots(), request.location(), current.spots(), current.location());
        String detail = firstNonBlank(request.description(), current.description());
        String coverImageUrl = firstNonBlank(request.coverImageUrl(), current.coverImageUrl());
        boolean online = request.online() == null ? current.online() : request.online();

        jdbcTemplate.update("""
                UPDATE query_routes
                SET name = ?, duration_hours = ?, difficulty = ?, suitable_for = ?, spots = ?, detail = ?,
                    cover_image_url = ?, online_status = ?, updated_by = ?
                WHERE id = ?
                """,
                requiredText(title, "线路标题"),
                requiredInteger(durationHours, "建议时长"),
                requiredText(difficulty, "难度等级"),
                requiredText(suitableFor, "适宜人群"),
                requiredText(spots, "线路内容"),
                requiredText(detail, "线路简介"),
                normalizeNullable(coverImageUrl),
                toOnlineStatus(online),
                actorUsername,
                id
        );
    }

    private void updateDining(String id, ResourceItemRequest request, ResourceItemResponse current, String actorUsername) {
        String title = firstNonBlank(request.title(), current.title());
        String type = firstNonBlank(request.type(), request.subtitle(), current.type(), current.subtitle());
        Integer avgPrice = firstNonNull(request.avgPrice(), request.price(), current.avgPrice());
        String businessHours = firstNonBlank(request.businessHours(), request.schedule(), current.businessHours(), current.schedule());
        String address = firstNonBlank(request.address(), request.location(), current.address(), current.location());
        String recommendFood = firstNonBlank(request.recommendFood(), request.subtitle(), current.recommendFood(), current.subtitle());
        String detailDesc = firstNonBlank(request.description(), current.description());
        String coverImageUrl = firstNonBlank(request.coverImageUrl(), current.coverImageUrl());
        Integer distanceMeters = firstNonNull(request.distanceMeters(), current.distanceMeters(), 0);
        Boolean isOpen = firstNonNull(request.isOpen(), current.isOpen(), false);
        Double navLat = firstNonNull(request.navLat(), current.navLat());
        Double navLng = firstNonNull(request.navLng(), current.navLng());
        boolean online = request.online() == null ? current.online() : request.online();

        jdbcTemplate.update("""
                UPDATE query_dining
                SET name = ?, type = ?, avg_price = ?, business_hours = ?, address = ?, recommend_food = ?, detail_desc = ?,
                    logo_url = ?, distance_meters = ?, is_open = ?, nav_lat = ?, nav_lng = ?, online_status = ?, updated_by = ?
                WHERE id = ?
                """,
                requiredText(title, "餐饮名称"),
                requiredText(type, "餐饮分类"),
                requiredInteger(avgPrice, "人均价格"),
                requiredText(businessHours, "营业时间"),
                requiredText(address, "店铺位置"),
                normalizeNullable(recommendFood) == null ? "" : normalizeNullable(recommendFood),
                requiredText(detailDesc, "餐饮简介"),
                normalizeNullable(coverImageUrl),
                distanceMeters,
                isOpen,
                navLat,
                navLng,
                toOnlineStatus(online),
                actorUsername,
                id
        );
    }

    private void updatePerformance(String id, ResourceItemRequest request, ResourceItemResponse current, String actorUsername) {
        String title = firstNonBlank(request.title(), current.title());
        String location = firstNonBlank(request.location(), request.venue(), current.location(), current.venue());
        String showTime = firstNonBlank(request.showTime(), request.schedule(), current.showTime(), current.schedule());
        Integer price = firstNonNull(request.price(), current.price());
        String team = firstNonBlank(request.team(), request.subtitle(), current.team(), current.subtitle());
        String detail = firstNonBlank(request.description(), current.description());
        String venue = firstNonBlank(request.venue(), request.location(), current.venue(), current.location());
        String showDateTime = firstNonBlank(request.showDateTime(), request.schedule(), current.showDateTime(), current.schedule(), current.showTime());
        Integer remainingTickets = firstNonNull(request.remainingTickets(), current.remainingTickets(), 0);
        String ticketStatus = normalizeTicketStatus(firstNonBlank(request.ticketStatus(), current.ticketStatus()), remainingTickets);
        Integer distanceMeters = firstNonNull(request.distanceMeters(), current.distanceMeters(), 0);
        Double navLat = firstNonNull(request.navLat(), current.navLat());
        Double navLng = firstNonNull(request.navLng(), current.navLng());
        String coverImageUrl = firstNonBlank(request.coverImageUrl(), current.coverImageUrl());
        boolean online = request.online() == null ? current.online() : request.online();

        jdbcTemplate.update("""
                UPDATE query_performances
                SET name = ?, location = ?, show_time = ?, price = ?, team = ?, detail = ?, venue = ?, show_datetime = ?,
                    remaining_tickets = ?, ticket_status = ?, distance_meters = ?, nav_lat = ?, nav_lng = ?,
                    cover_image_url = ?, online_status = ?, updated_by = ?
                WHERE id = ?
                """,
                requiredText(title, "演出名称"),
                requiredText(location, "演出位置"),
                requiredText(showTime, "演出时间"),
                requiredInteger(price, "票价"),
                requiredText(team, "演出团队"),
                requiredText(detail, "演出简介"),
                requiredText(venue, "演出场地"),
                requiredText(showDateTime, "场次时间"),
                remainingTickets,
                ticketStatus,
                distanceMeters,
                navLat,
                navLng,
                normalizeNullable(coverImageUrl),
                toOnlineStatus(online),
                actorUsername,
                id
        );
    }

    private void ensureResourceExists(ResourceCategory category, String id) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM " + tableName(category) + " WHERE id = ?",
                Integer.class,
                id
        );
        if (count == null || count == 0) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "资源不存在");
        }
    }

    private List<ResourceItemResponse> listById(ResourceCategory category, String id) {
        return switch (category) {
            case SCENIC_SPOTS -> jdbcTemplate.query("""
                    SELECT id, name, scenic_area, location, open_time, ticket_price, level, type, is_free,
                           description, crowd_heat, cover_image_url, online_status, updated_by, updated_at
                    FROM query_scenic_spots
                    WHERE id = ?
                    """, scenicMapper(), id);
            case ROUTES -> jdbcTemplate.query("""
                    SELECT id, name, duration_hours, difficulty, suitable_for, spots, detail,
                           cover_image_url, online_status, updated_by, updated_at
                    FROM query_routes
                    WHERE id = ?
                    """, routeMapper(), id);
            case DINING -> jdbcTemplate.query("""
                    SELECT id, name, type, avg_price, business_hours, address, recommend_food, detail_desc,
                           logo_url, distance_meters, is_open, nav_lat, nav_lng, online_status, updated_by, updated_at
                    FROM query_dining
                    WHERE id = ?
                    """, diningMapper(), id);
            case PERFORMANCES -> jdbcTemplate.query("""
                    SELECT id, name, location, show_time, price, team, detail, venue, show_datetime,
                           remaining_tickets, ticket_status, distance_meters, nav_lat, nav_lng,
                           cover_image_url, online_status, updated_by, updated_at
                    FROM query_performances
                    WHERE id = ?
                    """, performanceMapper(), id);
        };
    }

    private RowMapper<ResourceItemResponse> scenicMapper() {
        return (rs, rowNum) -> new ResourceItemResponse(
                rs.getString("id"),
                ResourceCategory.SCENIC_SPOTS.name(),
                rs.getString("name"),
                rs.getString("scenic_area"),
                rs.getString("location"),
                rs.getString("open_time"),
                rs.getString("description"),
                rs.getString("cover_image_url"),
                isOnline(rs.getString("online_status")),
                rs.getString("updated_by"),
                toInstant(rs.getTimestamp("updated_at")),
                rs.getString("scenic_area"),
                rs.getString("open_time"),
                rs.getObject("ticket_price", Integer.class),
                rs.getString("level"),
                rs.getString("type"),
                rs.getObject("is_free", Boolean.class),
                rs.getObject("crowd_heat", Integer.class),
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
    }

    private RowMapper<ResourceItemResponse> routeMapper() {
        return (rs, rowNum) -> new ResourceItemResponse(
                rs.getString("id"),
                ResourceCategory.ROUTES.name(),
                rs.getString("name"),
                rs.getString("suitable_for"),
                rs.getString("spots"),
                rs.getObject("duration_hours", Integer.class) + "小时",
                rs.getString("detail"),
                rs.getString("cover_image_url"),
                isOnline(rs.getString("online_status")),
                rs.getString("updated_by"),
                toInstant(rs.getTimestamp("updated_at")),
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                rs.getObject("duration_hours", Integer.class),
                rs.getString("difficulty"),
                rs.getString("suitable_for"),
                rs.getString("spots"),
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
    }

    private RowMapper<ResourceItemResponse> diningMapper() {
        return (rs, rowNum) -> new ResourceItemResponse(
                rs.getString("id"),
                ResourceCategory.DINING.name(),
                rs.getString("name"),
                rs.getString("type"),
                rs.getString("address"),
                rs.getString("business_hours"),
                rs.getString("detail_desc"),
                rs.getString("logo_url"),
                isOnline(rs.getString("online_status")),
                rs.getString("updated_by"),
                toInstant(rs.getTimestamp("updated_at")),
                null,
                null,
                null,
                null,
                rs.getString("type"),
                null,
                null,
                null,
                null,
                null,
                null,
                rs.getObject("avg_price", Integer.class),
                rs.getString("business_hours"),
                rs.getString("address"),
                rs.getString("recommend_food"),
                rs.getObject("distance_meters", Integer.class),
                rs.getObject("is_open", Boolean.class),
                rs.getObject("nav_lat", Double.class),
                rs.getObject("nav_lng", Double.class),
                null,
                null,
                null,
                null,
                null,
                null,
                null
        );
    }

    private RowMapper<ResourceItemResponse> performanceMapper() {
        return (rs, rowNum) -> new ResourceItemResponse(
                rs.getString("id"),
                ResourceCategory.PERFORMANCES.name(),
                rs.getString("name"),
                rs.getString("team"),
                rs.getString("venue"),
                rs.getString("show_time"),
                rs.getString("detail"),
                rs.getString("cover_image_url"),
                isOnline(rs.getString("online_status")),
                rs.getString("updated_by"),
                toInstant(rs.getTimestamp("updated_at")),
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                rs.getObject("distance_meters", Integer.class),
                null,
                rs.getObject("nav_lat", Double.class),
                rs.getObject("nav_lng", Double.class),
                rs.getString("show_time"),
                rs.getObject("price", Integer.class),
                rs.getString("team"),
                rs.getString("venue"),
                rs.getString("show_datetime"),
                rs.getObject("remaining_tickets", Integer.class),
                rs.getString("ticket_status")
        );
    }

    private String tableName(ResourceCategory category) {
        return switch (category) {
            case SCENIC_SPOTS -> "query_scenic_spots";
            case ROUTES -> "query_routes";
            case DINING -> "query_dining";
            case PERFORMANCES -> "query_performances";
        };
    }

    private String generateId(ResourceCategory category) {
        String prefix = switch (category) {
            case SCENIC_SPOTS -> "s-";
            case ROUTES -> "r-";
            case DINING -> "d-";
            case PERFORMANCES -> "p-";
        };
        return prefix + UUID.randomUUID().toString().replace("-", "").substring(0, 8);
    }

    private String normalizeLikeKeyword(String keyword) {
        if (keyword == null || keyword.isBlank()) {
            return null;
        }
        return "%" + keyword.trim().toLowerCase(Locale.ROOT) + "%";
    }

    private String normalizeNullable(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String requiredText(String value, String fieldLabel) {
        String normalized = normalizeNullable(value);
        if (normalized == null) {
            throw new BusinessException(ErrorCode.VALIDATION, fieldLabel + "不能为空");
        }
        return normalized;
    }

    private Integer requiredInteger(Integer value, String fieldLabel) {
        if (value == null) {
            throw new BusinessException(ErrorCode.VALIDATION, fieldLabel + "不能为空");
        }
        return value;
    }

    private String firstNonBlank(String... values) {
        for (String value : values) {
            String normalized = normalizeNullable(value);
            if (normalized != null) {
                return normalized;
            }
        }
        return null;
    }

    private Integer firstNonNull(Integer... values) {
        for (Integer value : values) {
            if (value != null) {
                return value;
            }
        }
        return null;
    }

    private Boolean firstNonNull(Boolean... values) {
        for (Boolean value : values) {
            if (value != null) {
                return value;
            }
        }
        return null;
    }

    private Double firstNonNull(Double... values) {
        for (Double value : values) {
            if (value != null) {
                return value;
            }
        }
        return null;
    }

    private String toOnlineStatus(boolean online) {
        return online ? "ONLINE" : "OFFLINE";
    }

    private boolean isOnline(String onlineStatus) {
        return "ONLINE".equalsIgnoreCase(onlineStatus);
    }

    private Instant toInstant(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toInstant();
    }

    private String normalizeTicketStatus(String ticketStatus, Integer remainingTickets) {
        String normalized = normalizeNullable(ticketStatus);
        if (normalized != null) {
            return normalized.toUpperCase(Locale.ROOT);
        }
        return remainingTickets != null && remainingTickets > 0 ? "AVAILABLE" : "SOLD_OUT";
    }
}
