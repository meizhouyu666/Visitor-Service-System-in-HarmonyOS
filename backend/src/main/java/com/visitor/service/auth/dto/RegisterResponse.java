package com.visitor.service.auth.dto;

import com.visitor.service.user.UserRole;

public record RegisterResponse(
        String username,
        String displayName,
        UserRole role
) {
}

