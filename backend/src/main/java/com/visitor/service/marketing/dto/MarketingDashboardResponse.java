package com.visitor.service.marketing.dto;

import java.util.List;

public record MarketingDashboardResponse(
        int currentVisitors,
        int eastHeatPercent,
        int westHeatPercent,
        String loadLabel,
        String suggestion,
        List<MarketingHotelResponse> hotels
) {
}
