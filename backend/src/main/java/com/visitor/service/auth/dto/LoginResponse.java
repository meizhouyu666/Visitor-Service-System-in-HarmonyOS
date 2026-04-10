package com.visitor.service.auth.dto;

import com.visitor.service.user.UserRole;

public record LoginResponse(
        String token,
        String username,
        String displayName,
        UserRole role
) {
}
