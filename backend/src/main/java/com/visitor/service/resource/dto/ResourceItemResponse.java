package com.visitor.service.resource.dto;

import java.time.Instant;

public record ResourceItemResponse(
        String id,
        String category,
        String title,
        String subtitle,
        String location,
        String schedule,
        String description,
        String coverImageUrl,
        boolean online,
        String updatedBy,
        Instant updatedAt,

        String scenicArea,
        String openTime,
        Integer ticketPrice,
        String level,
        String type,
        Boolean isFree,
        Integer crowdHeat,

        Integer durationHours,
        String difficulty,
        String suitableFor,
        String spots,

        Integer avgPrice,
        String businessHours,
        String address,
        String recommendFood,
        Integer distanceMeters,
        Boolean isOpen,
        Double navLat,
        Double navLng,

        String showTime,
        Integer price,
        String team,
        String venue,
        String showDateTime,
        Integer remainingTickets,
        String ticketStatus
) {
}
