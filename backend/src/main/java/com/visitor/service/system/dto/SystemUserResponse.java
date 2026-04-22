package com.visitor.service.system.dto;

import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRole;

import java.time.Instant;

public record SystemUserResponse(
        Long id,
        String username,
        String displayName,
        UserRole role,
        boolean enabled,
        String managedHotelId,
        Instant createdAt,
        Instant updatedAt
) {
    public static SystemUserResponse from(UserAccount user) {
        return new SystemUserResponse(
                user.getId(),
                user.getUsername(),
                user.getDisplayName(),
                user.getRole(),
                user.isEnabled(),
                user.getManagedHotelId(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}
