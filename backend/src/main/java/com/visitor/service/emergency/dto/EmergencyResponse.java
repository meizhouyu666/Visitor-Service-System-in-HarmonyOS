package com.visitor.service.emergency.dto;

import com.visitor.service.emergency.EmergencyInfo;
import com.visitor.service.emergency.EmergencyStatus;

import java.time.Instant;
import java.time.LocalDateTime;

public record EmergencyResponse(
        Long id,
        String title,
        String content,
        EmergencyStatus status,
        LocalDateTime validFrom,
        LocalDateTime validUntil,
        String alertLevel,
        String alertType,
        String createdBy,
        String approvedBy,
        Instant createdAt,
        Instant updatedAt
) {
    public static EmergencyResponse from(EmergencyInfo info) {
        return new EmergencyResponse(
                info.getId(),
                info.getTitle(),
                info.getContent(),
                info.getStatus(),
                info.getValidFrom(),
                info.getValidUntil(),
                info.getAlertLevel(),
                info.getAlertType(),
                info.getCreatedBy().getUsername(),
                info.getApprovedBy() == null ? null : info.getApprovedBy().getUsername(),
                info.getCreatedAt(),
                info.getUpdatedAt()
        );
    }
}
