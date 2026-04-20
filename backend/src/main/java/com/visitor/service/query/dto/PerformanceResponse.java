package com.visitor.service.query.dto;

public record PerformanceResponse(
        String id,
        String name,
        String location,
        String showTime,
        int price,
        String team,
        String detail,
        String venue,
        String showDateTime,
        Integer remainingTickets,
        String ticketStatus,
        Integer distanceMeters,
        Double navLat,
        Double navLng
) {
}

