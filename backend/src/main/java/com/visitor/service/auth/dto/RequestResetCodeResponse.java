package com.visitor.service.auth.dto;

import java.time.Instant;

public record RequestResetCodeResponse(
        String username,
        String debugCode,
        Instant expiresAt
) {
}

