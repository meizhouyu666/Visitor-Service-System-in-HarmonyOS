package com.visitor.service.query.dto;

public record TravelRouteResponse(
        String id,
        String name,
        Integer durationHours,
        String difficulty,
        String suitableFor,
        String spots,
        String detail
) {
}