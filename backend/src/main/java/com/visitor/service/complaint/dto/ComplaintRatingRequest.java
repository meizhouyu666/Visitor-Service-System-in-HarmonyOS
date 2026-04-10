package com.visitor.service.complaint.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record ComplaintRatingRequest(
        @Min(1) @Max(5) int rating
) {
}
