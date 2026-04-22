package com.visitor.service.query;

import com.visitor.service.query.dto.DiningResponse;
import com.visitor.service.query.dto.EntertainmentResponse;
import com.visitor.service.query.dto.HotelResponse;
import com.visitor.service.query.dto.PerformanceResponse;
import com.visitor.service.query.dto.ScenicSpotResponse;
import com.visitor.service.query.dto.SimpleItem;
import com.visitor.service.query.dto.TrafficResponse;
import com.visitor.service.query.dto.TravelRouteResponse;
import com.visitor.service.query.dto.WeatherResponse;
import com.visitor.service.query.dto.WeatherTrafficResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

@Service
public class QueryService {

    private final JdbcTemplate jdbcTemplate;

    public QueryService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<HotelResponse> hotels(String keyword, Integer minStar, String area, Integer minPrice, Integer maxPrice) {
        StringBuilder sql = new StringBuilder("""
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
                WHERE 1 = 1
                """);
        List<Object> args = new ArrayList<>();
        appendKeyword(sql, args, keyword, "qh.name", "qh.address", "qh.introduction");
        if (minStar != null) {
            sql.append(" AND qh.star >= ?");
            args.add(minStar);
        }
        appendArea(sql, args, area, "qh.address");
        appendPriceRange(sql, args, "qh.price", minPrice, maxPrice);
        sql.append(" ORDER BY qh.star DESC, qh.price ASC, qh.id ASC");

        RowMapper<HotelResponse> mapper = (rs, rowNum) -> new HotelResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("address"),
                rs.getInt("star"),
                rs.getInt("price"),
                rs.getString("phone"),
                rs.getDouble("score"),
                rs.getBoolean("has_breakfast"),
                rs.getString("facility"),
                rs.getString("introduction"),
                rs.getString("availability_status"),
                rs.getString("cover_image_url"),
                rs.getObject("total_rooms", Integer.class),
                rs.getObject("available_rooms", Integer.class),
                rs.getObject("marketing_recommended", Boolean.class),
                rs.getString("marketing_tag"),
                rs.getObject("marketing_priority", Integer.class),
                rs.getString("marketing_note")
        );
        return jdbcTemplate.query(sql.toString(), mapper, args.toArray());
    }

    public List<ScenicSpotResponse> scenicSpots(String keyword, String level, String area, Integer minPrice, Integer maxPrice) {
        StringBuilder sql = new StringBuilder("""
                SELECT id, name, scenic_area, location, open_time, ticket_price, level, type, is_free, description,
                       crowd_heat, cover_image_url
                FROM query_scenic_spots
                WHERE online_status = 'ONLINE'
                """);
        List<Object> args = new ArrayList<>();
        appendKeyword(sql, args, keyword, "name", "location", "description", "scenic_area");
        if (level != null && !level.isBlank()) {
            sql.append(" AND level = ?");
            args.add(level.trim().toUpperCase(Locale.ROOT));
        }
        appendArea(sql, args, area, "location", "scenic_area");
        appendPriceRange(sql, args, "ticket_price", minPrice, maxPrice);
        sql.append(" ORDER BY ticket_price ASC, id ASC");

        RowMapper<ScenicSpotResponse> mapper = (rs, rowNum) -> new ScenicSpotResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("scenic_area"),
                rs.getString("location"),
                rs.getString("open_time"),
                rs.getInt("ticket_price"),
                rs.getString("level"),
                rs.getString("type"),
                rs.getBoolean("is_free"),
                rs.getString("description"),
                rs.getObject("crowd_heat", Integer.class),
                rs.getString("cover_image_url")
        );
        return jdbcTemplate.query(sql.toString(), mapper, args.toArray());
    }

    public List<TravelRouteResponse> routes(String keyword) {
        StringBuilder sql = new StringBuilder("""
                SELECT id, name, duration_hours, difficulty, suitable_for, spots, detail
                FROM query_routes
                WHERE online_status = 'ONLINE'
                """);
        List<Object> args = new ArrayList<>();
        appendKeyword(sql, args, keyword, "name", "spots", "detail");
        sql.append(" ORDER BY id ASC");
        RowMapper<TravelRouteResponse> mapper = (rs, rowNum) -> new TravelRouteResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getInt("duration_hours"),
                rs.getString("difficulty"),
                rs.getString("suitable_for"),
                rs.getString("spots"),
                rs.getString("detail")
        );
        return jdbcTemplate.query(sql.toString(), mapper, args.toArray());
    }

    public List<DiningResponse> dining(String keyword,
                                       String area,
                                       Integer minPrice,
                                       Integer maxPrice,
                                       String sortBy,
                                       Integer limit) {
        StringBuilder sql = new StringBuilder("""
                SELECT id, name, type, avg_price, business_hours, address, recommend_food, detail_desc,
                       logo_url, distance_meters, is_open, nav_lat, nav_lng
                FROM query_dining
                WHERE online_status = 'ONLINE'
                """);
        List<Object> args = new ArrayList<>();
        appendKeyword(sql, args, keyword, "name", "type", "recommend_food", "address");
        appendArea(sql, args, area, "address");
        appendPriceRange(sql, args, "avg_price", minPrice, maxPrice);
        appendSortAndLimit(sql, args, sortBy, limit, "avg_price", "distance_meters");

        RowMapper<DiningResponse> mapper = (rs, rowNum) -> new DiningResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("type"),
                rs.getInt("avg_price"),
                rs.getString("business_hours"),
                rs.getString("address"),
                rs.getString("recommend_food"),
                rs.getString("detail_desc"),
                rs.getString("logo_url"),
                rs.getObject("distance_meters", Integer.class),
                rs.getObject("is_open", Boolean.class),
                rs.getObject("nav_lat", Double.class),
                rs.getObject("nav_lng", Double.class)
        );
        return jdbcTemplate.query(sql.toString(), mapper, args.toArray());
    }

    public List<EntertainmentResponse> entertainment(String keyword,
                                                     String area,
                                                     Integer minPrice,
                                                     Integer maxPrice,
                                                     String sortBy,
                                                     Integer limit) {
        StringBuilder sql = new StringBuilder("""
                SELECT id, name, type, location, open_time, price, description,
                       logo_url, distance_meters, is_open, nav_lat, nav_lng
                FROM query_entertainment
                WHERE 1 = 1
                """);
        List<Object> args = new ArrayList<>();
        appendKeyword(sql, args, keyword, "name", "type", "location", "description");
        appendArea(sql, args, area, "location");
        appendPriceRange(sql, args, "price", minPrice, maxPrice);
        appendSortAndLimit(sql, args, sortBy, limit, "price", "distance_meters");

        RowMapper<EntertainmentResponse> mapper = (rs, rowNum) -> new EntertainmentResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("type"),
                rs.getString("location"),
                rs.getString("open_time"),
                rs.getInt("price"),
                rs.getString("description"),
                rs.getString("logo_url"),
                rs.getObject("distance_meters", Integer.class),
                rs.getObject("is_open", Boolean.class),
                rs.getObject("nav_lat", Double.class),
                rs.getObject("nav_lng", Double.class)
        );
        return jdbcTemplate.query(sql.toString(), mapper, args.toArray());
    }

    public List<PerformanceResponse> performances(String keyword,
                                                  String area,
                                                  Integer minPrice,
                                                  Integer maxPrice,
                                                  String sortBy,
                                                  Integer limit) {
        StringBuilder sql = new StringBuilder("""
                SELECT id, name, location, show_time, price, team, detail,
                       venue, show_datetime, remaining_tickets, ticket_status, distance_meters, nav_lat, nav_lng
                FROM query_performances
                WHERE online_status = 'ONLINE'
                """);
        List<Object> args = new ArrayList<>();
        appendKeyword(sql, args, keyword, "name", "team", "location", "venue");
        appendArea(sql, args, area, "location", "venue");
        appendPriceRange(sql, args, "price", minPrice, maxPrice);
        appendPerformanceSortAndLimit(sql, args, sortBy, limit);

        RowMapper<PerformanceResponse> mapper = (rs, rowNum) -> new PerformanceResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("location"),
                rs.getString("show_time"),
                rs.getInt("price"),
                rs.getString("team"),
                rs.getString("detail"),
                rs.getString("venue"),
                rs.getString("show_datetime"),
                rs.getObject("remaining_tickets", Integer.class),
                rs.getString("ticket_status"),
                rs.getObject("distance_meters", Integer.class),
                rs.getObject("nav_lat", Double.class),
                rs.getObject("nav_lng", Double.class)
        );
        return jdbcTemplate.query(sql.toString(), mapper, args.toArray());
    }

    public List<WeatherResponse> weather() {
        String sql = """
                SELECT date_value, weather, temperature, wind, humidity, tip
                FROM query_weather
                ORDER BY sort_order ASC
                """;
        return jdbcTemplate.query(sql, (rs, rowNum) -> new WeatherResponse(
                rs.getString("date_value"),
                rs.getString("weather"),
                rs.getString("temperature"),
                rs.getString("wind"),
                rs.getInt("humidity"),
                rs.getString("tip")
        ));
    }

    public List<TrafficResponse> traffic() {
        String sql = """
                SELECT from_location, to_location, status, suggest_route, take_time, severity_level
                FROM query_traffic
                ORDER BY sort_order ASC
                """;
        return jdbcTemplate.query(sql, (rs, rowNum) -> new TrafficResponse(
                rs.getString("from_location"),
                rs.getString("to_location"),
                rs.getString("status"),
                rs.getString("suggest_route"),
                rs.getString("take_time"),
                rs.getString("severity_level")
        ));
    }

    // 兼容旧版前端调用的聚合接口。
    public List<SimpleItem> starHotels() {
        return hotels(null, null, null, null, null).stream()
                .filter(item -> item.star() >= 4)
                .map(item -> new SimpleItem(item.id(), item.name(), item.introduction()))
                .toList();
    }

    public List<SimpleItem> nonStarHotels() {
        return hotels(null, null, null, null, null).stream()
                .filter(item -> item.star() < 4)
                .map(item -> new SimpleItem(item.id(), item.name(), item.introduction()))
                .toList();
    }

    public List<SimpleItem> scenicSpots() {
        return scenicSpots(null, null, null, null, null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.description()))
                .toList();
    }

    public List<SimpleItem> routes() {
        return routes(null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.detail()))
                .toList();
    }

    public List<SimpleItem> diningAndEntertainment() {
        List<SimpleItem> merged = new ArrayList<>();
        merged.addAll(dining(null, null, null, null, null, null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.detailDesc()))
                .toList());
        merged.addAll(entertainment(null, null, null, null, null, null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.description()))
                .toList());
        return merged;
    }

    public List<SimpleItem> performances() {
        return performances(null, null, null, null, null, null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.detail()))
                .toList();
    }

    public WeatherTrafficResponse weatherTraffic() {
        List<WeatherResponse> weatherList = weather();
        List<TrafficResponse> trafficList = traffic();

        WeatherResponse current = weatherList.isEmpty()
                ? new WeatherResponse("-", "未知", "-", "-", 0, "暂无天气建议")
                : weatherList.get(0);
        TrafficResponse mainRoute = trafficList.isEmpty()
                ? new TrafficResponse("-", "-", "未知", "暂无路线", "-", "UNKNOWN")
                : trafficList.get(0);

        return new WeatherTrafficResponse(
                current.weather(),
                current.temperature(),
                mainRoute.status() + ", " + mainRoute.suggestRoute());
    }

    private void appendKeyword(StringBuilder sql, List<Object> args, String keyword, String... columns) {
        if (keyword == null || keyword.isBlank() || columns.length == 0) {
            return;
        }
        sql.append(" AND (");
        String normalized = "%" + keyword.trim().toLowerCase(Locale.ROOT) + "%";
        for (int index = 0; index < columns.length; index++) {
            if (index > 0) {
                sql.append(" OR ");
            }
            sql.append("LOWER(").append(columns[index]).append(") LIKE ?");
            args.add(normalized);
        }
        sql.append(')');
    }

    private void appendArea(StringBuilder sql, List<Object> args, String area, String... columns) {
        if (area == null || area.isBlank() || columns.length == 0) {
            return;
        }
        String normalized = "%" + area.trim().toLowerCase(Locale.ROOT) + "%";
        sql.append(" AND (");
        for (int index = 0; index < columns.length; index++) {
            if (index > 0) {
                sql.append(" OR ");
            }
            sql.append("LOWER(").append(columns[index]).append(") LIKE ?");
            args.add(normalized);
        }
        sql.append(')');
    }

    private void appendPriceRange(StringBuilder sql,
                                  List<Object> args,
                                  String column,
                                  Integer minPrice,
                                  Integer maxPrice) {
        if (minPrice != null) {
            sql.append(" AND ").append(column).append(" >= ?");
            args.add(minPrice);
        }
        if (maxPrice != null) {
            sql.append(" AND ").append(column).append(" <= ?");
            args.add(maxPrice);
        }
    }

    private void appendSortAndLimit(StringBuilder sql,
                                    List<Object> args,
                                    String sortBy,
                                    Integer limit,
                                    String priceColumn,
                                    String distanceColumn) {
        String normalizedSort = sortBy == null ? "" : sortBy.trim().toLowerCase(Locale.ROOT);
        if ("price_desc".equals(normalizedSort)) {
            sql.append(" ORDER BY ").append(priceColumn).append(" DESC, id ASC");
        } else if ("distance_asc".equals(normalizedSort)) {
            sql.append(" ORDER BY ").append(distanceColumn).append(" ASC, id ASC");
        } else if ("price_asc".equals(normalizedSort)) {
            sql.append(" ORDER BY ").append(priceColumn).append(" ASC, id ASC");
        } else {
            sql.append(" ORDER BY id ASC");
        }
        appendLimit(sql, args, limit);
    }

    private void appendPerformanceSortAndLimit(StringBuilder sql, List<Object> args, String sortBy, Integer limit) {
        String normalizedSort = sortBy == null ? "" : sortBy.trim().toLowerCase(Locale.ROOT);
        if ("price_desc".equals(normalizedSort)) {
            sql.append(" ORDER BY price DESC, id ASC");
        } else if ("distance_asc".equals(normalizedSort)) {
            sql.append(" ORDER BY distance_meters ASC, id ASC");
        } else if ("time_asc".equals(normalizedSort)) {
            sql.append(" ORDER BY show_datetime ASC, id ASC");
        } else {
            sql.append(" ORDER BY show_datetime ASC, id ASC");
        }
        appendLimit(sql, args, limit);
    }

    private void appendLimit(StringBuilder sql, List<Object> args, Integer limit) {
        if (limit == null) {
            return;
        }
        int safeLimit = Math.max(1, Math.min(limit, 50));
        sql.append(" LIMIT ?");
        args.add(safeLimit);
    }

    private <T> List<T> queryByKeyword(String baseSql,
                                       RowMapper<T> mapper,
                                       String keyword,
                                       String primaryColumn,
                                       String secondaryColumn,
                                       String tertiaryColumn) {
        if (keyword == null || keyword.isBlank()) {
            return jdbcTemplate.query(baseSql + " ORDER BY id", mapper);
        }

        String sql = baseSql + " WHERE LOWER(" + primaryColumn + ") LIKE ?"
                + " OR LOWER(" + secondaryColumn + ") LIKE ?"
                + " OR LOWER(" + tertiaryColumn + ") LIKE ?"
                + " ORDER BY id";

        String normalized = "%" + keyword.trim().toLowerCase() + "%";
        return jdbcTemplate.query(sql, mapper, normalized, normalized, normalized);
    }
}
