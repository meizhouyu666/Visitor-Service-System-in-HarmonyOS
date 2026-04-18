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

@Service
public class QueryService {

    private final JdbcTemplate jdbcTemplate;

    public QueryService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<HotelResponse> hotels(String keyword) {
        String sql = """
                SELECT id, name, address, star, price, phone, score, has_breakfast, facility, introduction
                FROM query_hotels
                """;
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
                rs.getString("introduction")
        );
        return queryByKeyword(sql, mapper, keyword, "name", "address", "introduction");
    }

    public List<ScenicSpotResponse> scenicSpots(String keyword) {
        String sql = """
                SELECT id, name, scenic_area, location, open_time, ticket_price, level, type, is_free, description
                FROM query_scenic_spots
                """;
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
                rs.getString("description")
        );
        return queryByKeyword(sql, mapper, keyword, "name", "location", "description");
    }

    public List<TravelRouteResponse> routes(String keyword) {
        String sql = """
                SELECT id, name, duration_hours, difficulty, suitable_for, spots, detail
                FROM query_routes
                """;
        RowMapper<TravelRouteResponse> mapper = (rs, rowNum) -> new TravelRouteResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getInt("duration_hours"),
                rs.getString("difficulty"),
                rs.getString("suitable_for"),
                rs.getString("spots"),
                rs.getString("detail")
        );
        return queryByKeyword(sql, mapper, keyword, "name", "spots", "detail");
    }

    public List<DiningResponse> dining(String keyword) {
        String sql = """
                SELECT id, name, type, avg_price, business_hours, address, recommend_food, detail_desc
                FROM query_dining
                """;
        RowMapper<DiningResponse> mapper = (rs, rowNum) -> new DiningResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("type"),
                rs.getInt("avg_price"),
                rs.getString("business_hours"),
                rs.getString("address"),
                rs.getString("recommend_food"),
                rs.getString("detail_desc")
        );
        return queryByKeyword(sql, mapper, keyword, "name", "type", "recommend_food");
    }

    public List<EntertainmentResponse> entertainment(String keyword) {
        String sql = """
                SELECT id, name, type, location, open_time, price, description
                FROM query_entertainment
                """;
        RowMapper<EntertainmentResponse> mapper = (rs, rowNum) -> new EntertainmentResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("type"),
                rs.getString("location"),
                rs.getString("open_time"),
                rs.getInt("price"),
                rs.getString("description")
        );
        return queryByKeyword(sql, mapper, keyword, "name", "type", "location");
    }

    public List<PerformanceResponse> performances(String keyword) {
        String sql = """
                SELECT id, name, location, show_time, price, team, detail
                FROM query_performances
                """;
        RowMapper<PerformanceResponse> mapper = (rs, rowNum) -> new PerformanceResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("location"),
                rs.getString("show_time"),
                rs.getInt("price"),
                rs.getString("team"),
                rs.getString("detail")
        );
        return queryByKeyword(sql, mapper, keyword, "name", "team", "location");
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
                SELECT from_location, to_location, status, suggest_route, take_time
                FROM query_traffic
                ORDER BY sort_order ASC
                """;
        return jdbcTemplate.query(sql, (rs, rowNum) -> new TrafficResponse(
                rs.getString("from_location"),
                rs.getString("to_location"),
                rs.getString("status"),
                rs.getString("suggest_route"),
                rs.getString("take_time")
        ));
    }

    // 兼容旧版前端调用的聚合接口。
    public List<SimpleItem> starHotels() {
        return hotels(null).stream()
                .filter(item -> item.star() >= 4)
                .map(item -> new SimpleItem(item.id(), item.name(), item.introduction()))
                .toList();
    }

    public List<SimpleItem> nonStarHotels() {
        return hotels(null).stream()
                .filter(item -> item.star() < 4)
                .map(item -> new SimpleItem(item.id(), item.name(), item.introduction()))
                .toList();
    }

    public List<SimpleItem> scenicSpots() {
        return scenicSpots(null).stream()
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
        merged.addAll(dining(null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.detailDesc()))
                .toList());
        merged.addAll(entertainment(null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.description()))
                .toList());
        return merged;
    }

    public List<SimpleItem> performances() {
        return performances(null).stream()
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
                ? new TrafficResponse("-", "-", "未知", "暂无路线", "-")
                : trafficList.get(0);

        return new WeatherTrafficResponse(
                current.weather(),
                current.temperature(),
                mainRoute.status() + ", " + mainRoute.suggestRoute());
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
