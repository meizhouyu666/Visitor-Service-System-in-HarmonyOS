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
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class QueryService {

    public List<HotelResponse> hotels(String keyword) {
        List<HotelResponse> all = List.of(
                new HotelResponse("h-1", "Sunrise International Hotel", "No.18 Lake Road", 5, 699, "0596-111111", 4.8, true, "Pool,Gym,SPA", "Premium business and leisure hotel near old town"),
                new HotelResponse("h-2", "Mountain View Hotel", "No.28 Scenic Avenue", 4, 428, "0596-222222", 4.6, true, "Parking,Wifi,Restaurant", "Family-friendly hotel with scenic mountain view"),
                new HotelResponse("h-3", "Village Warm Inn", "No.8 Folk Street", 3, 238, "0596-333333", 4.4, false, "Wifi,Tea Room", "Affordable and local-style village hotel")
        );
        return filterByKeyword(all, keyword, item -> item.name() + " " + item.address() + " " + item.introduction());
    }

    public List<ScenicSpotResponse> scenicSpots(String keyword) {
        List<ScenicSpotResponse> all = List.of(
                new ScenicSpotResponse("s-1", "Cloud Peak", "North Scenic Area", "North Mountain", "08:00-17:30", 80, "AAAA", "Mountain", false, "Best choice for sunrise and forest walk"),
                new ScenicSpotResponse("s-2", "Ancient Town Street", "Central Scenic Area", "Old Town Center", "All Day", 0, "AAAA", "Historic", true, "Historic lane with food and culture activities")
        );
        return filterByKeyword(all, keyword, item -> item.name() + " " + item.location() + " " + item.description());
    }

    public List<TravelRouteResponse> routes(String keyword) {
        List<TravelRouteResponse> all = List.of(
                new TravelRouteResponse("r-1", "Family Day Route", 8, "Easy", "Family", "Ancient Town Street,Cloud Peak", "One-day route with culture and light hiking"),
                new TravelRouteResponse("r-2", "Adventure Route", 12, "Medium", "Young Travelers", "Cloud Peak,River Canyon", "Mountain trail and river canyon route")
        );
        return filterByKeyword(all, keyword, item -> item.name() + " " + item.spots() + " " + item.detail());
    }

    public List<DiningResponse> dining(String keyword) {
        List<DiningResponse> all = List.of(
                new DiningResponse("d-1", "River Taste Restaurant", "Local Cuisine", 88, "10:00-22:00", "No.6 Riverside", "Braised Fish,Herb Chicken", "Popular local cuisine restaurant for tourists"),
                new DiningResponse("d-2", "Mountain Noodle House", "Noodle", 35, "09:00-21:00", "No.3 Valley Road", "Handmade Noodle", "Quick and affordable dining with local flavor")
        );
        return filterByKeyword(all, keyword, item -> item.name() + " " + item.type() + " " + item.recommendFood());
    }

    public List<EntertainmentResponse> entertainment(String keyword) {
        List<EntertainmentResponse> all = List.of(
                new EntertainmentResponse("e-1", "Night Music Plaza", "Music Plaza", "Old Town East Gate", "19:00-23:00", 0, "Open-air music and local stalls"),
                new EntertainmentResponse("e-2", "River Light Park", "Night Tour", "Riverside Belt", "18:30-22:30", 30, "Night light show and interactive performance")
        );
        return filterByKeyword(all, keyword, item -> item.name() + " " + item.type() + " " + item.location());
    }

    public List<PerformanceResponse> performances(String keyword) {
        List<PerformanceResponse> all = List.of(
                new PerformanceResponse("p-1", "Folk Dance Show", "Culture Theater", "20:00", 68, "Folk Dance Group", "Traditional dance with interactive finale"),
                new PerformanceResponse("p-2", "Mountain Drama", "Old Stage Hall", "19:30", 88, "Mountain Drama Team", "Classic stage performance with local stories")
        );
        return filterByKeyword(all, keyword, item -> item.name() + " " + item.team() + " " + item.location());
    }

    public List<WeatherResponse> weather() {
        return List.of(
                new WeatherResponse("2026-04-17", "Sunny", "26C", "East Wind 2", 55, "Good day for outdoor travel"),
                new WeatherResponse("2026-04-18", "Cloudy", "24C", "North Wind 3", 62, "Carry a light jacket in the evening")
        );
    }

    public List<TrafficResponse> traffic() {
        return List.of(
                new TrafficResponse("City Center", "Cloud Peak", "Smooth", "Main Avenue -> Scenic Road", "45min"),
                new TrafficResponse("Railway Station", "Ancient Town Street", "Moderate", "Ring Road -> East Gate", "30min")
        );
    }

    // Backward-compatible endpoints for old frontend callers.
    public List<SimpleItem> starHotels() {
        return hotels(null).stream()
                .filter(item -> item.star() >= 4)
                .map(item -> new SimpleItem(item.id(), item.name(), item.introduction()))
                .collect(Collectors.toList());
    }

    public List<SimpleItem> nonStarHotels() {
        return hotels(null).stream()
                .filter(item -> item.star() < 4)
                .map(item -> new SimpleItem(item.id(), item.name(), item.introduction()))
                .collect(Collectors.toList());
    }

    public List<SimpleItem> scenicSpots() {
        return scenicSpots(null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.description()))
                .collect(Collectors.toList());
    }

    public List<SimpleItem> routes() {
        return routes(null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.detail()))
                .collect(Collectors.toList());
    }

    public List<SimpleItem> diningAndEntertainment() {
        List<SimpleItem> diningItems = dining(null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.detailDesc()))
                .collect(Collectors.toList());
        List<SimpleItem> entertainmentItems = entertainment(null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.description()))
                .collect(Collectors.toList());
        return List.of(diningItems, entertainmentItems).stream().flatMap(List::stream).collect(Collectors.toList());
    }

    public List<SimpleItem> performances() {
        return performances(null).stream()
                .map(item -> new SimpleItem(item.id(), item.name(), item.detail()))
                .collect(Collectors.toList());
    }

    public WeatherTrafficResponse weatherTraffic() {
        WeatherResponse current = weather().get(0);
        TrafficResponse mainRoute = traffic().get(0);
        return new WeatherTrafficResponse(
                current.weather(),
                current.temperature(),
                mainRoute.status() + ", " + mainRoute.suggestRoute());
    }

    private <T> List<T> filterByKeyword(List<T> all, String keyword, Function<T, String> textExtractor) {
        if (keyword == null || keyword.isBlank()) {
            return all;
        }
        String normalized = keyword.toLowerCase(Locale.ROOT);
        return all.stream()
                .filter(item -> textExtractor.apply(item).toLowerCase(Locale.ROOT).contains(normalized))
                .collect(Collectors.toList());
    }
}
