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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "旅游查询")
@RestController
@RequestMapping("/api/query")
public class QueryController {

    private final QueryService queryService;

    public QueryController(QueryService queryService) {
        this.queryService = queryService;
    }

    @Operation(summary = "酒店查询")
    @GetMapping("/hotels")
    public ApiResponse<List<HotelResponse>> hotels(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer minStar,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice) {
        return ApiResponse.success(queryService.hotels(keyword, minStar, area, minPrice, maxPrice));
    }

    @Operation(summary = "星级酒店查询（兼容）")
    @GetMapping("/hotels/star")
    public ApiResponse<List<SimpleItem>> starHotels() {
        return ApiResponse.success(queryService.starHotels());
    }

    @Operation(summary = "非星级/乡村酒店查询（兼容）")
    @GetMapping("/hotels/non-star")
    public ApiResponse<List<SimpleItem>> nonStarHotels() {
        return ApiResponse.success(queryService.nonStarHotels());
    }

    @Operation(summary = "景区查询")
    @GetMapping("/scenic-spots")
    public ApiResponse<List<ScenicSpotResponse>> scenicSpots(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String level,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice) {
        return ApiResponse.success(queryService.scenicSpots(keyword, level, area, minPrice, maxPrice));
    }

    @Operation(summary = "线路查询")
    @GetMapping("/routes")
    public ApiResponse<List<TravelRouteResponse>> routes(@RequestParam(required = false) String keyword) {
        return ApiResponse.success(queryService.routes(keyword));
    }

    @Operation(summary = "餐饮查询")
    @GetMapping("/dining")
    public ApiResponse<List<DiningResponse>> dining(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice,
            @RequestParam(required = false) String sortBy,
            @RequestParam(required = false) Integer limit) {
        return ApiResponse.success(queryService.dining(keyword, area, minPrice, maxPrice, sortBy, limit));
    }

    @Operation(summary = "娱乐查询")
    @GetMapping("/entertainment")
    public ApiResponse<List<EntertainmentResponse>> entertainment(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice,
            @RequestParam(required = false) String sortBy,
            @RequestParam(required = false) Integer limit) {
        return ApiResponse.success(queryService.entertainment(keyword, area, minPrice, maxPrice, sortBy, limit));
    }

    @Operation(summary = "餐饮娱乐综合查询（兼容）")
    @GetMapping("/dining-entertainment")
    public ApiResponse<List<SimpleItem>> diningEntertainment() {
        return ApiResponse.success(queryService.diningAndEntertainment());
    }

    @Operation(summary = "演出查询")
    @GetMapping("/performances")
    public ApiResponse<List<PerformanceResponse>> performances(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice,
            @RequestParam(required = false) String sortBy,
            @RequestParam(required = false) Integer limit) {
        return ApiResponse.success(queryService.performances(keyword, area, minPrice, maxPrice, sortBy, limit));
    }

    @Operation(summary = "天气查询")
    @GetMapping("/weather")
    public ApiResponse<List<WeatherResponse>> weather() {
        return ApiResponse.success(queryService.weather());
    }

    @Operation(summary = "路况查询")
    @GetMapping("/traffic")
    public ApiResponse<List<TrafficResponse>> traffic() {
        return ApiResponse.success(queryService.traffic());
    }

    @Operation(summary = "天气路况综合查询（兼容）")
    @GetMapping("/weather-traffic")
    public ApiResponse<WeatherTrafficResponse> weatherTraffic() {
        return ApiResponse.success(queryService.weatherTraffic());
    }
}
