package com.visitor.service.query.dto;

public record TrafficResponse(
        String fromLocation,
        String toLocation,
        String status,
        String suggestRoute,
        String takeTime
) {
}

