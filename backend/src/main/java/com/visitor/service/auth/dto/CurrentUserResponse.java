package com.visitor.service.auth.dto;

import com.visitor.service.user.UserRole;

public record CurrentUserResponse(
        String username,
        String displayName,
        UserRole role
) {
}
