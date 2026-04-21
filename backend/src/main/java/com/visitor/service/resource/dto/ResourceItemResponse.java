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
        Instant updatedAt
) {
}
