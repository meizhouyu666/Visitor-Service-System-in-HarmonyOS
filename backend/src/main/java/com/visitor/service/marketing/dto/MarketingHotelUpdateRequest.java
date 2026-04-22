package com.visitor.service.marketing.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record MarketingHotelUpdateRequest(
        @NotNull Boolean recommended,
        @Size(max = 64) String marketingTag,
        Integer marketingPriority,
        @Size(max = 255) String marketingNote
) {
}
