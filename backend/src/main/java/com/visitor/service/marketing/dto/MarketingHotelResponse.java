package com.visitor.service.marketing.dto;

public record MarketingHotelResponse(
        String id,
        String name,
        String address,
        int star,
        int price,
        double score,
        boolean hasBreakfast,
        String facility,
        String introduction,
        String availabilityStatus,
        String coverImageUrl,
        Integer totalRooms,
        Integer availableRooms,
        boolean recommended,
        String marketingTag,
        int marketingPriority,
        String marketingNote,
        String areaLabel
) {
}
