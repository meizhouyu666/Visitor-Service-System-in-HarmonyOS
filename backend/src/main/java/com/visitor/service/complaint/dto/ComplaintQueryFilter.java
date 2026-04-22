package com.visitor.service.complaint.dto;

public record ComplaintQueryFilter(
        String status,
        String createdBy,
        String assignee,
        String keyword,
        String from,
        String to
) {
}

