package com.visitor.service.query.dto;

public record EntertainmentResponse(
        String id,
        String name,
        String type,
        String location,
        String openTime,
        double price,
        String description
) {
}
