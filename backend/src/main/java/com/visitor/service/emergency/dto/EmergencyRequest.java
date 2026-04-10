package com.visitor.service.emergency.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

public record EmergencyRequest(
        @NotBlank @Size(max = 128) String title,
        @NotBlank String content,
        LocalDateTime validFrom,
        LocalDateTime validUntil
) {
}
