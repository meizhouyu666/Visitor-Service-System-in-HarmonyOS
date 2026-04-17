package com.visitor.service.query;

import com.visitor.service.common.ApiResponse;
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
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Tourism Query")
@RestController
@RequestMapping("/api/query")
public class QueryController {

    private final QueryService queryService;

    public QueryController(QueryService queryService) {
        this.queryService = queryService;
    }

    @Operation(summary = "Query hotels")
    @GetMapping("/hotels")
    public ApiResponse<List<HotelResponse>> hotels(@RequestParam(required = false) String keyword) {
        return ApiResponse.success(queryService.hotels(keyword));
    }

    @Operation(summary = "Query star hotel information")
    @GetMapping("/hotels/star")
    public ApiResponse<List<SimpleItem>> starHotels() {
        return ApiResponse.success(queryService.starHotels());
    }

    @Operation(summary = "Query non-star and rural hotel information")
    @GetMapping("/hotels/non-star")
    public ApiResponse<List<SimpleItem>> nonStarHotels() {
        return ApiResponse.success(queryService.nonStarHotels());
    }

    @Operation(summary = "Query scenic spots")
    @GetMapping("/scenic-spots")
    public ApiResponse<List<ScenicSpotResponse>> scenicSpots(@RequestParam(required = false) String keyword) {
        return ApiResponse.success(queryService.scenicSpots(keyword));
    }

    @Operation(summary = "Query travel routes")
    @GetMapping("/routes")
    public ApiResponse<List<TravelRouteResponse>> routes(@RequestParam(required = false) String keyword) {
        return ApiResponse.success(queryService.routes(keyword));
    }

    @Operation(summary = "Query dining")
    @GetMapping("/dining")
    public ApiResponse<List<DiningResponse>> dining(@RequestParam(required = false) String keyword) {
        return ApiResponse.success(queryService.dining(keyword));
    }

    @Operation(summary = "Query entertainment")
    @GetMapping("/entertainment")
    public ApiResponse<List<EntertainmentResponse>> entertainment(@RequestParam(required = false) String keyword) {
        return ApiResponse.success(queryService.entertainment(keyword));
    }

    @Operation(summary = "Query dining and entertainment")
    @GetMapping("/dining-entertainment")
    public ApiResponse<List<SimpleItem>> diningEntertainment() {
        return ApiResponse.success(queryService.diningAndEntertainment());
    }

    @Operation(summary = "Query performance groups")
    @GetMapping("/performances")
    public ApiResponse<List<PerformanceResponse>> performances(@RequestParam(required = false) String keyword) {
        return ApiResponse.success(queryService.performances(keyword));
    }

    @Operation(summary = "Query weather")
    @GetMapping("/weather")
    public ApiResponse<List<WeatherResponse>> weather() {
        return ApiResponse.success(queryService.weather());
    }

    @Operation(summary = "Query traffic")
    @GetMapping("/traffic")
    public ApiResponse<List<TrafficResponse>> traffic() {
        return ApiResponse.success(queryService.traffic());
    }

    @Operation(summary = "Query weather and traffic")
    @GetMapping("/weather-traffic")
    public ApiResponse<WeatherTrafficResponse> weatherTraffic() {
        return ApiResponse.success(queryService.weatherTraffic());
    }
}
