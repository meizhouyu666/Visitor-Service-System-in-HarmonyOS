package com.visitor.service.complaint.dto;

import jakarta.validation.constraints.NotBlank;

public record ComplaintActionRequest(
        @NotBlank String comment
) {
}
