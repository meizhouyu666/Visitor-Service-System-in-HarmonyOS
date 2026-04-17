package com.visitor.service.query.dto;

public record HotelResponse(
        String id,
        String name,
        String address,
        Integer star,
        Integer price,
        String phone,
        Double score,
        Boolean hasBreakfast,
        String facility,
        String introduction
) {
}