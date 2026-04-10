package com.visitor.service.complaint.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ComplaintCreateRequest(
        @NotBlank @Size(max = 128) String title,
        @NotBlank String content,
        String attachmentUrls
) {
}
