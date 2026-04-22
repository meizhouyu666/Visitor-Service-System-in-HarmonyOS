package com.visitor.service.query.dto;

public record HotelResponse(
        String id,
        String name,
        String address,
        int star,
        int price,
        String phone,
        double score,
        boolean hasBreakfast,
        String facility,
        String introduction,
        String availabilityStatus,
        String coverImageUrl,
        Integer totalRooms,
        Integer availableRooms,
        Boolean marketingRecommended,
        String marketingTag,
        Integer marketingPriority,
        String marketingNote
) {
}
