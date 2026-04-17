package com.visitor.service.query.dto;

import java.time.LocalDateTime;

public record PerformanceResponse(
        String id,
        String name,
        String location,
        LocalDateTime showTime,
        Integer price,
        String team,
        String detail
) {
}