package com.visitor.service.query.dto;

public record PerformanceResponse(
        String id,
        String name,
        String location,
        String showTime,
        int price,
        String team,
        String detail
) {
}

