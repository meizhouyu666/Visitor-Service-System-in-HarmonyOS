package com.visitor.service.hotel.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record HotelRoomItemRequest(
        @NotBlank(message = "房型编号不能为空")
        String id,

        @NotBlank(message = "房型名称不能为空")
        String name,

        @Min(value = 0, message = "总房量不能小于 0")
        int totalRooms,

        @Min(value = 0, message = "剩余房量不能小于 0")
        int availableRooms,

        @Min(value = 0, message = "房型价格不能小于 0")
        int price,

        String imageUrl
) {
}
