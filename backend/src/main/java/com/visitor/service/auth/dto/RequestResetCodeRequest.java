package com.visitor.service.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record RequestResetCodeRequest(
        @NotBlank String username
) {
}

