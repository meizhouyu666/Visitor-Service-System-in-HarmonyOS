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
                    SELECT id, name, scenic_area, location, open_time, description, cover_image_url,
                           online_status, updated_by, updated_at
                    FROM query_scenic_spots
                    WHERE (? IS NULL OR LOWER(name) LIKE ? OR LOWER(location) LIKE ? OR LOWER(description) LIKE ?)
                    ORDER BY updated_at DESC, id ASC
                    """, scenicMapper(), likeKeyword, likeKeyword, likeKeyword, likeKeyword);
            case ROUTES -> jdbcTemplate.query("""
                    SELECT id, name, suitable_for, spots, detail, cover_image_url,
                           online_status, updated_by, updated_at, duration_hours
                    FROM query_routes
                    WHERE (? IS NULL OR LOWER(name) LIKE ? OR LOWER(spots) LIKE ? OR LOWER(detail) LIKE ?)
                    ORDER BY updated_at DESC, id ASC
                    """, routeMapper(), likeKeyword, likeKeyword, likeKeyword, likeKeyword);
            case DINING -> jdbcTemplate.query("""
                    SELECT id, name, type, address, business_hours, detail_desc, logo_url,
                           online_status, updated_by, updated_at
                    FROM query_dining
                    WHERE (? IS NULL OR LOWER(name) LIKE ? OR LOWER(address) LIKE ? OR LOWER(detail_desc) LIKE ?)
                    ORDER BY updated_at DESC, id ASC
                    """, diningMapper(), likeKeyword, likeKeyword, likeKeyword, likeKeyword);
            case PERFORMANCES -> jdbcTemplate.query("""
                    SELECT id, name, team, venue, show_time, detail, cover_image_url,
                           online_status, updated_by, updated_at
                    FROM query_performances
                    WHERE (? IS NULL OR LOWER(name) LIKE ? OR LOWER(venue) LIKE ? OR LOWER(detail) LIKE ?)
                    ORDER BY updated_at DESC, id ASC
                    """, performanceMapper(), likeKeyword, likeKeyword, likeKeyword, likeKeyword);
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
            case SCENIC_SPOTS -> jdbcTemplate.update("""
                    INSERT INTO query_scenic_spots(
                        id, name, scenic_area, location, open_time, ticket_price, level, type, is_free,
                        description, crowd_heat, cover_image_url, online_status, updated_by
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    id,
                    request.title().trim(),
                    normalizeOrDefault(request.subtitle(), "核心景区"),
                    request.location().trim(),
                    normalizeOrDefault(request.schedule(), "08:00-18:00"),
                    0,
                    "AAAA",
                    "景区景点",
                    true,
                    request.description().trim(),
                    50,
                    normalizeNullable(request.coverImageUrl()),
                    toOnlineStatus(online),
                    actorUsername
            );
            case ROUTES -> jdbcTemplate.update("""
                    INSERT INTO query_routes(
                        id, name, duration_hours, difficulty, suitable_for, spots, detail,
                        cover_image_url, online_status, updated_by
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    id,
                    request.title().trim(),
                    8,
                    "EASY",
                    normalizeOrDefault(request.subtitle(), "轻松游"),
                    request.location().trim(),
                    request.description().trim(),
                    normalizeNullable(request.coverImageUrl()),
                    toOnlineStatus(online),
                    actorUsername
            );
            case DINING -> jdbcTemplate.update("""
                    INSERT INTO query_dining(
                        id, name, type, avg_price, business_hours, address, recommend_food, detail_desc,
                        logo_url, distance_meters, is_open, nav_lat, nav_lng, online_status, updated_by
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    id,
                    request.title().trim(),
                    normalizeOrDefault(request.subtitle(), "餐饮娱乐"),
                    0,
                    normalizeOrDefault(request.schedule(), "10:00-22:00"),
                    request.location().trim(),
                    normalizeOrDefault(request.subtitle(), "推荐菜品"),
                    request.description().trim(),
                    normalizeNullable(request.coverImageUrl()),
                    500,
                    true,
                    null,
                    null,
                    toOnlineStatus(online),
                    actorUsername
            );
            case PERFORMANCES -> jdbcTemplate.update("""
                    INSERT INTO query_performances(
                        id, name, location, show_time, price, team, detail, venue, show_datetime,
                        remaining_tickets, ticket_status, distance_meters, nav_lat, nav_lng,
                        cover_image_url, online_status, updated_by
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    id,
                    request.title().trim(),
                    request.location().trim(),
                    normalizeOrDefault(request.schedule(), "19:30"),
                    0,
                    normalizeOrDefault(request.subtitle(), "景区演艺团"),
                    request.description().trim(),
                    request.location().trim(),
                    normalizeOrDefault(request.schedule(), "19:30"),
                    100,
                    "AVAILABLE",
                    800,
                    null,
                    null,
                    normalizeNullable(request.coverImageUrl()),
                    toOnlineStatus(online),
                    actorUsername
            );
        }
        auditLogService.record(actorUsername, "RESOURCE", "CREATE", category.name(), id, "新增资源");
        return detail(category, id);
    }

    public ResourceItemResponse update(ResourceCategory category, String id, ResourceItemRequest request, String actorUsername) {
        ensureResourceExists(category, id);
        boolean online = request.online() == null || request.online();
        int updated = switch (category) {
            case SCENIC_SPOTS -> jdbcTemplate.update("""
                    UPDATE query_scenic_spots
                    SET name = ?, scenic_area = ?, location = ?, open_time = ?, description = ?, cover_image_url = ?,
                        online_status = ?, updated_by = ?
                    WHERE id = ?
                    """,
                    request.title().trim(),
                    normalizeOrDefault(request.subtitle(), "核心景区"),
                    request.location().trim(),
                    normalizeOrDefault(request.schedule(), "08:00-18:00"),
                    request.description().trim(),
                    normalizeNullable(request.coverImageUrl()),
                    toOnlineStatus(online),
                    actorUsername,
                    id
            );
            case ROUTES -> jdbcTemplate.update("""
                    UPDATE query_routes
                    SET name = ?, suitable_for = ?, spots = ?, detail = ?, cover_image_url = ?,
                        online_status = ?, updated_by = ?
                    WHERE id = ?
                    """,
                    request.title().trim(),
                    normalizeOrDefault(request.subtitle(), "轻松游"),
                    request.location().trim(),
                    request.description().trim(),
                    normalizeNullable(request.coverImageUrl()),
                    toOnlineStatus(online),
                    actorUsername,
                    id
            );
            case DINING -> jdbcTemplate.update("""
                    UPDATE query_dining
                    SET name = ?, type = ?, business_hours = ?, address = ?, recommend_food = ?, detail_desc = ?,
                        logo_url = ?, online_status = ?, updated_by = ?
                    WHERE id = ?
                    """,
                    request.title().trim(),
                    normalizeOrDefault(request.subtitle(), "餐饮娱乐"),
                    normalizeOrDefault(request.schedule(), "10:00-22:00"),
                    request.location().trim(),
                    normalizeOrDefault(request.subtitle(), "推荐菜品"),
                    request.description().trim(),
                    normalizeNullable(request.coverImageUrl()),
                    toOnlineStatus(online),
                    actorUsername,
                    id
            );
            case PERFORMANCES -> jdbcTemplate.update("""
                    UPDATE query_performances
                    SET name = ?, location = ?, show_time = ?, team = ?, detail = ?, venue = ?, show_datetime = ?,
                        cover_image_url = ?, online_status = ?, updated_by = ?
                    WHERE id = ?
                    """,
                    request.title().trim(),
                    request.location().trim(),
                    normalizeOrDefault(request.schedule(), "19:30"),
                    normalizeOrDefault(request.subtitle(), "景区演艺团"),
                    request.description().trim(),
                    request.location().trim(),
                    normalizeOrDefault(request.schedule(), "19:30"),
                    normalizeNullable(request.coverImageUrl()),
                    toOnlineStatus(online),
                    actorUsername,
                    id
            );
        };
        if (updated == 0) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "资源不存在");
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
                    SELECT id, name, scenic_area, location, open_time, description, cover_image_url,
                           online_status, updated_by, updated_at
                    FROM query_scenic_spots
                    WHERE id = ?
                    """, scenicMapper(), id);
            case ROUTES -> jdbcTemplate.query("""
                    SELECT id, name, suitable_for, spots, detail, cover_image_url,
                           online_status, updated_by, updated_at, duration_hours
                    FROM query_routes
                    WHERE id = ?
                    """, routeMapper(), id);
            case DINING -> jdbcTemplate.query("""
                    SELECT id, name, type, address, business_hours, detail_desc, logo_url,
                           online_status, updated_by, updated_at
                    FROM query_dining
                    WHERE id = ?
                    """, diningMapper(), id);
            case PERFORMANCES -> jdbcTemplate.query("""
                    SELECT id, name, team, venue, show_time, detail, cover_image_url,
                           online_status, updated_by, updated_at
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
                toInstant(rs.getTimestamp("updated_at"))
        );
    }

    private RowMapper<ResourceItemResponse> routeMapper() {
        return (rs, rowNum) -> new ResourceItemResponse(
                rs.getString("id"),
                ResourceCategory.ROUTES.name(),
                rs.getString("name"),
                rs.getString("suitable_for"),
                rs.getString("spots"),
                rs.getInt("duration_hours") + "小时",
                rs.getString("detail"),
                rs.getString("cover_image_url"),
                isOnline(rs.getString("online_status")),
                rs.getString("updated_by"),
                toInstant(rs.getTimestamp("updated_at"))
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
                toInstant(rs.getTimestamp("updated_at"))
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
                toInstant(rs.getTimestamp("updated_at"))
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

    private String normalizeOrDefault(String value, String defaultValue) {
        String normalized = normalizeNullable(value);
        return normalized == null ? defaultValue : normalized;
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
}
