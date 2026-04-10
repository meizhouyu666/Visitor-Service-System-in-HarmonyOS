package com.visitor.service.query;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.query.dto.SimpleItem;
import com.visitor.service.query.dto.WeatherTrafficResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
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
    public ApiResponse<List<SimpleItem>> scenicSpots() {
        return ApiResponse.success(queryService.scenicSpots());
    }

    @Operation(summary = "Query travel routes")
    @GetMapping("/routes")
    public ApiResponse<List<SimpleItem>> routes() {
        return ApiResponse.success(queryService.routes());
    }

    @Operation(summary = "Query dining and entertainment")
    @GetMapping("/dining-entertainment")
    public ApiResponse<List<SimpleItem>> diningEntertainment() {
        return ApiResponse.success(queryService.diningAndEntertainment());
    }

    @Operation(summary = "Query performance groups")
    @GetMapping("/performances")
    public ApiResponse<List<SimpleItem>> performances() {
        return ApiResponse.success(queryService.performances());
    }

    @Operation(summary = "Query weather and traffic")
    @GetMapping("/weather-traffic")
    public ApiResponse<WeatherTrafficResponse> weatherTraffic() {
        return ApiResponse.success(queryService.weatherTraffic());
    }
}
