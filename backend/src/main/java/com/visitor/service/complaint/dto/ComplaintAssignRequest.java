package com.visitor.service.complaint.dto;

import jakarta.validation.constraints.NotBlank;

public record ComplaintAssignRequest(
        @NotBlank String assigneeUsername,
        String comment
) {
}
