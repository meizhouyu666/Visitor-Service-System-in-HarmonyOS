package com.visitor.service.query.dto;

public record DiningResponse(
        String id,
        String name,
        String type,
        int avgPrice,
        String businessHours,
        String address,
        String recommendFood,
        String detailDesc
) {
}

