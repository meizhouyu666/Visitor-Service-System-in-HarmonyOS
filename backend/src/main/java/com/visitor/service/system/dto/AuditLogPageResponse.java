package com.visitor.service.system.dto;

import java.util.List;

public record AuditLogPageResponse(
        List<AuditLogResponse> items,
        long total,
        int page,
        int size
) {
}
