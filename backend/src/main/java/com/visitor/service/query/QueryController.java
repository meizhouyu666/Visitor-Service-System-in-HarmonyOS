package com.visitor.service.query;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.query.dto.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Tourism Query")
@RestController
@RequestMapping("/api/query")
public class QueryController {

    private final QueryService queryService;

    public QueryController(QueryService queryService) {
        this.queryService = queryService;
    }

    // ===================== 酒店 =====================
    @Operation(summary = "Query star hotel information")
    @GetMapping("/hotels/star")
    public ApiResponse<List<HotelResponse>> starHotels(
            @RequestParam(required = false) Integer star,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice,
            @RequestParam(required = false) Boolean hasBreakfast
    ) {
        return ApiResponse.success(queryService.starHotels(star, minPrice, maxPrice, hasBreakfast));
    }

    @Operation(summary = "Query non-star and rural hotel information")
    @GetMapping("/hotels/non-star")
    public ApiResponse<List<HotelResponse>> nonStarHotels(
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice
    ) {
        return ApiResponse.success(queryService.nonStarHotels(minPrice, maxPrice));
    }

    @Operation(summary = "Get hotel detail by ID")
    @GetMapping("/hotels/{id}")
    public ApiResponse<HotelResponse> hotelDetail(@PathVariable String id) {
        return ApiResponse.success(queryService.hotelDetail(id));
    }

    // ===================== 景点 =====================
    @Operation(summary = "Query scenic spots")
    @GetMapping("/scenic-spots")
    public ApiResponse<List<ScenicSpotResponse>> scenicSpots(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) Boolean isFree
    ) {
        return ApiResponse.success(queryService.scenicSpots(type, isFree));
    }

    @Operation(summary = "Get scenic spot detail")
    @GetMapping("/scenic-spots/{id}")
    public ApiResponse<ScenicSpotResponse> scenicSpotDetail(@PathVariable String id) {
        return ApiResponse.success(queryService.scenicSpotDetail(id));
    }

    // ===================== 旅游路线 =====================
    @Operation(summary = "Query travel routes")
    @GetMapping("/routes")
    public ApiResponse<List<TravelRouteResponse>> routes(
            @RequestParam(required = false) String difficulty
    ) {
        return ApiResponse.success(queryService.routes(difficulty));
    }

    @Operation(summary = "Get travel route detail")
    @GetMapping("/routes/{id}")
    public ApiResponse<TravelRouteResponse> routeDetail(@PathVariable String id) {
        return ApiResponse.success(queryService.routeDetail(id));
    }

    // ===================== 餐饮 =====================
    @Operation(summary = "Query dining")
    @GetMapping("/dining")
    public ApiResponse<List<DiningResponse>> dining(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice
    ) {
        return ApiResponse.success(queryService.dining(type, minPrice, maxPrice));
    }

    @Operation(summary = "Get dining detail")
    @GetMapping("/dining/{id}")
    public ApiResponse<DiningResponse> diningDetail(@PathVariable String id) {
        return ApiResponse.success(queryService.diningDetail(id));
    }

    // ===================== 娱乐项目 =====================
    @Operation(summary = "Query entertainment")
    @GetMapping("/entertainment")
    public ApiResponse<List<EntertainmentResponse>> entertainment() {
        return ApiResponse.success(queryService.entertainment());
    }

    @Operation(summary = "Get entertainment detail")
    @GetMapping("/entertainment/{id}")
    public ApiResponse<EntertainmentResponse> entertainmentDetail(@PathVariable String id) {
        return ApiResponse.success(queryService.entertainmentDetail(id));
    }

    // ===================== 演出 =====================
    @Operation(summary = "Query performances")
    @GetMapping("/performances")
    public ApiResponse<List<PerformanceResponse>> performances(
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice
    ) {
        return ApiResponse.success(queryService.performances(minPrice, maxPrice));
    }

    @Operation(summary = "Get performance detail")
    @GetMapping("/performances/{id}")
    public ApiResponse<PerformanceResponse> performanceDetail(@PathVariable String id) {
        return ApiResponse.success(queryService.performanceDetail(id));
    }

    // ===================== 天气 =====================
    @Operation(summary = "Query weather forecast")
    @GetMapping("/weather")
    public ApiResponse<List<WeatherResponse>> weather(
            @RequestParam(required = false) LocalDate date
    ) {
        return ApiResponse.success(queryService.weather(date));
    }

    // ===================== 交通 =====================
    @Operation(summary = "Query traffic to scenic area")
    @GetMapping("/traffic")
    public ApiResponse<TrafficResponse> traffic() {
        return ApiResponse.success(queryService.traffic());
    }
}