package com.visitor.service.query.dto;

public record EntertainmentResponse(
        String id,
        String name,
        String type,
        String location,
        String openTime,
        int price,
        String description,
        String logoUrl,
        Integer distanceMeters,
        Boolean isOpen,
        Double navLat,
        Double navLng
) {
}

