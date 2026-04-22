package com.visitor.service.hotel.dto;

public record HotelRoomItemResponse(
        String id,
        String name,
        int totalRooms,
        int availableRooms,
        int price,
        String imageUrl
) {
}
