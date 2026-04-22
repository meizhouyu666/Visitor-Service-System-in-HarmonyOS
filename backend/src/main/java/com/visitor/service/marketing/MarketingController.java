package com.visitor.service.marketing;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.marketing.dto.MarketingDashboardResponse;
import com.visitor.service.marketing.dto.MarketingHotelResponse;
import com.visitor.service.marketing.dto.MarketingHotelUpdateRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "导流营销")
@RestController
@RequestMapping("/api/marketing/hotels")
@PreAuthorize("hasAuthority('MARKETING_MANAGE')")
public class MarketingController {

    private final MarketingService marketingService;

    public MarketingController(MarketingService marketingService) {
        this.marketingService = marketingService;
    }

    @Operation(summary = "平台管理端导流营销看板")
    @GetMapping
    public ApiResponse<MarketingDashboardResponse> dashboard() {
        return ApiResponse.success(marketingService.dashboard());
    }

    @Operation(summary = "更新酒店导流推荐配置")
    @PutMapping("/{id}")
    public ApiResponse<MarketingHotelResponse> update(@PathVariable String id,
                                                      @Valid @RequestBody MarketingHotelUpdateRequest request,
                                                      Authentication authentication) {
        return ApiResponse.success(marketingService.updateHotel(id, request, authentication.getName()));
    }
}
