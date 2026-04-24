package com.visitor.service.marketing;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.marketing.dto.MarketingDashboardResponse;
import com.visitor.service.marketing.dto.MarketingHotelResponse;
import com.visitor.service.marketing.dto.MarketingHotelUpdateRequest;
import com.visitor.service.system.AuditLogService;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
@Transactional
public class MarketingService {

    private final JdbcTemplate jdbcTemplate;
    private final AuditLogService auditLogService;

    public MarketingService(JdbcTemplate jdbcTemplate, AuditLogService auditLogService) {
        this.jdbcTemplate = jdbcTemplate;
        this.auditLogService = auditLogService;
    }

    @Transactional(readOnly = true)
    public MarketingDashboardResponse dashboard() {
        List<MarketingHotelResponse> hotels = jdbcTemplate.query("""
                SELECT qh.id, qh.name, qh.address, qh.star, qh.price, qh.phone, qh.score, qh.has_breakfast, qh.facility, qh.introduction,
                       qh.availability_status, qh.cover_image_url,
                       COALESCE(room_stats.total_rooms, 0) AS total_rooms,
                       COALESCE(room_stats.available_rooms, 0) AS available_rooms,
                       qh.marketing_recommended, qh.marketing_tag,
                       qh.marketing_priority, qh.marketing_note
                FROM query_hotels qh
                LEFT JOIN (
                    SELECT hotel_id, SUM(total_rooms) AS total_rooms, SUM(available_rooms) AS available_rooms
                    FROM hotel_room_types
                    GROUP BY hotel_id
                ) room_stats ON room_stats.hotel_id = qh.id
                ORDER BY qh.marketing_recommended DESC, qh.marketing_priority DESC, qh.score DESC, qh.price ASC, qh.id ASC
                """, this::mapHotel);

        AreaStats eastStats = buildAreaStats(hotels, "EAST");
        AreaStats westStats = buildAreaStats(hotels, "WEST");
        int currentVisitors = calculateCurrentVisitors(hotels);
        String loadLabel = resolveLoadLabel(eastStats, westStats);
        String suggestion = resolveSuggestion(eastStats, westStats);

        return new MarketingDashboardResponse(
                currentVisitors,
                eastStats.percent(),
                westStats.percent(),
                loadLabel,
                suggestion,
                hotels
        );
    }

public MarketingHotelResponse updateHotel(String id, MarketingHotelUpdateRequest request, String actorUsername) {
    ensureHotelExists(id);
    String marketingTag = normalizeText(request.marketingTag());
    Integer marketingPriority = request.marketingPriority() == null ? 0 : request.marketingPriority();
    String marketingNote = normalizeText(request.marketingNote());

    // 更新营销配置（这部分完全正确）
    jdbcTemplate.update("""
            UPDATE query_hotels
            SET marketing_recommended = ?,
                marketing_tag = ?,
                marketing_priority = ?,
                marketing_note = ?,
                marketing_updated_by = ?,
                marketing_updated_at = ?
            WHERE id = ?
            """,
            request.recommended(),
            marketingTag,
            marketingPriority,
            marketingNote,
            actorUsername,
            LocalDateTime.now(),
            id
    );

    auditLogService.record(actorUsername, "MARKETING", "UPDATE", "HOTEL", id, "更新酒店导流推荐配置");

    // ====================== 修复在这里 ======================
    // 原来的 detail(id) 查询缺少 total_rooms，直接替换为正确查询
    return jdbcTemplate.queryForObject("""
            SELECT 
                qh.id, 
                qh.name, 
                qh.address, 
                qh.star, 
                qh.price, 
                qh.phone, 
                qh.score, 
                qh.has_breakfast, 
                qh.facility, 
                qh.introduction,
                qh.availability_status, 
                qh.cover_image_url,
                qh.marketing_recommended, 
                qh.marketing_tag,
                qh.marketing_priority, 
                qh.marketing_note,
                COALESCE(SUM(hrt.total_rooms), 0) AS total_rooms,
                COALESCE(SUM(hrt.available_rooms), 0) AS available_rooms
            FROM query_hotels qh
            LEFT JOIN hotel_room_types hrt ON hrt.hotel_id = qh.id
            WHERE qh.id = ?
            GROUP BY qh.id
            """, this::mapHotel, id);
}

    @Transactional(readOnly = true)
    public MarketingHotelResponse detail(String id) {
        List<MarketingHotelResponse> items = jdbcTemplate.query("""
                SELECT id, name, address, star, price, phone, score, has_breakfast, facility, introduction,
                       availability_status, cover_image_url, marketing_recommended, marketing_tag,
                       marketing_priority, marketing_note
                FROM query_hotels
                WHERE id = ?
                """, this::mapHotel, id);
        if (items.isEmpty()) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "酒店不存在");
        }
        return items.get(0);
    }

    private MarketingHotelResponse mapHotel(ResultSet rs, int rowNum) throws SQLException {
        String address = rs.getString("address");
        return new MarketingHotelResponse(
                rs.getString("id"),
                rs.getString("name"),
                address,
                rs.getInt("star"),
                rs.getInt("price"),
                rs.getDouble("score"),
                rs.getBoolean("has_breakfast"),
                rs.getString("facility"),
                rs.getString("introduction"),
                rs.getString("availability_status"),
                rs.getString("cover_image_url"),
                rs.getObject("total_rooms", Integer.class),
                rs.getObject("available_rooms", Integer.class),
                rs.getBoolean("marketing_recommended"),
                rs.getString("marketing_tag"),
                rs.getInt("marketing_priority"),
                rs.getString("marketing_note"),
                resolveAreaLabel(address)
        );
    }

    private AreaStats buildAreaStats(List<MarketingHotelResponse> hotels, String area) {
        List<Integer> scores = new ArrayList<>();
        hotels.forEach((item) -> {
            if (area.equals(item.areaLabel())) {
                scores.add(availabilityHeat(item.availabilityStatus()));
            }
        });
        if (scores.isEmpty()) {
            return new AreaStats(30, 0);
        }
        int total = scores.stream().mapToInt(Integer::intValue).sum();
        int average = total / scores.size();
        return new AreaStats(Math.max(18, Math.min(95, average)), scores.size());
    }

    private int calculateCurrentVisitors(List<MarketingHotelResponse> hotels) {
        if (hotels.isEmpty()) {
            return 0;
        }
        int totalOccupiedRooms = hotels.stream()
                .mapToInt((item) -> Math.max(0, (item.totalRooms() == null ? 0 : item.totalRooms()) - (item.availableRooms() == null ? 0 : item.availableRooms())))
                .sum();
        int totalHeat = hotels.stream().mapToInt((item) -> availabilityHeat(item.availabilityStatus())).sum();
        int base = totalOccupiedRooms * 22 + totalHeat * 16;
        int recommendedBonus = (int) hotels.stream().filter(MarketingHotelResponse::recommended).count() * 260;
        return base + recommendedBonus;
    }

    private String resolveLoadLabel(AreaStats eastStats, AreaStats westStats) {
        int overall = (eastStats.percent() + westStats.percent()) / 2;
        if (overall >= 80) {
            return "高峰";
        }
        if (overall >= 60) {
            return "较高";
        }
        if (overall >= 40) {
            return "平稳";
        }
        return "舒适";
    }

    private String resolveSuggestion(AreaStats eastStats, AreaStats westStats) {
        if (eastStats.percent() >= westStats.percent() + 12) {
            return "东区当前接待压力较高，建议减少东区酒店推荐，优先引导游客前往西区乡村住宿。";
        }
        if (westStats.percent() >= eastStats.percent() + 12) {
            return "西区接待压力上升较快，建议补充东区星级酒店推荐，平衡核心景区住宿承载。";
        }
        return "两侧接待压力相对平衡，可维持当前推荐组合，并持续观察房态与评分变化。";
    }

    private int availabilityHeat(String status) {
        if (status == null) {
            return 50;
        }
        return switch (status.toUpperCase(Locale.ROOT)) {
            case "FULL" -> 95;
            case "BUSY" -> 82;
            case "LIMITED" -> 64;
            default -> 32;
        };
    }

    private String resolveAreaLabel(String address) {
        if (address == null) {
            return "CENTER";
        }
        String safe = address.toUpperCase(Locale.ROOT);
        if (safe.contains("东") || safe.contains("湖") || safe.contains("滨")) {
            return "EAST";
        }
        if (safe.contains("西") || safe.contains("乡") || safe.contains("民俗") || safe.contains("古镇")) {
            return "WEST";
        }
        return "CENTER";
    }

    private String normalizeText(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void ensureHotelExists(String id) {
        Integer count = jdbcTemplate.queryForObject("SELECT COUNT(1) FROM query_hotels WHERE id = ?", Integer.class, id);
        if (count == null || count == 0) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "酒店不存在");
        }
    }

    private record AreaStats(int percent, int hotelCount) {
    }
}
