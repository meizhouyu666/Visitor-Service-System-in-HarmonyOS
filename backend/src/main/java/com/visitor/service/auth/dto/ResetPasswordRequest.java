package com.visitor.service.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(
        @NotBlank String username,
        @NotBlank @Size(min = 6, max = 6) String code,
        @NotBlank @Size(min = 6, max = 64) String newPassword
) {
}

