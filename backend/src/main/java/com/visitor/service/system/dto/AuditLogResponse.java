package com.visitor.service.system.dto;

import com.visitor.service.system.AuditLog;

import java.time.Instant;

public record AuditLogResponse(
        Long id,
        String actorUsername,
        String actorRole,
        String module,
        String action,
        String targetType,
        String targetId,
        String detail,
        Instant createdAt
) {
    public static AuditLogResponse from(AuditLog log) {
        return new AuditLogResponse(
                log.getId(),
                log.getActorUsername(),
                log.getActorRole(),
                log.getModuleName(),
                log.getActionName(),
                log.getTargetType(),
                log.getTargetId(),
                log.getDetailText(),
                log.getCreatedAt()
        );
    }
}
