package com.visitor.service.auth.dto;

import com.visitor.service.user.UserRole;

import java.util.List;

public record CurrentUserResponse(
        String username,
        String displayName,
        UserRole role,
        List<String> permissions
) {
}
