package com.visitor.service.query.dto;

public record ScenicSpotResponse(
        String id,
        String name,
        String scenicArea,
        String location,
        String openTime,
        int ticketPrice,
        String level,
        String type,
        boolean isFree,
        String description
) {
}

