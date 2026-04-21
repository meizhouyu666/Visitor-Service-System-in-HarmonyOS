package com.visitor.service.system;

import com.visitor.service.system.dto.AuditLogPageResponse;
import com.visitor.service.system.dto.AuditLogResponse;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Locale;

@Service
@Transactional
public class AuditLogService {

    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    public AuditLogService(AuditLogRepository auditLogRepository, UserRepository userRepository) {
        this.auditLogRepository = auditLogRepository;
        this.userRepository = userRepository;
    }

    public void record(String actorUsername,
                       String module,
                       String action,
                       String targetType,
                       Object targetId,
                       String detail) {
        AuditLog log = new AuditLog();
        log.setActorUsername(actorUsername);
        log.setActorRole(resolveActorRole(actorUsername));
        log.setModuleName(module);
        log.setActionName(action);
        log.setTargetType(targetType);
        log.setTargetId(targetId == null ? null : String.valueOf(targetId));
        log.setDetailText(detail);
        auditLogRepository.save(log);
    }

    @Transactional(readOnly = true)
    public AuditLogPageResponse query(String actor,
                                      String module,
                                      String action,
                                      String from,
                                      String to,
                                      int page,
                                      int size) {
        int safePage = Math.max(page, 0);
        int safeSize = Math.max(1, Math.min(size, 100));
        Instant fromInstant = parseInstant(from);
        Instant toInstant = parseInstant(to);

        List<AuditLogResponse> filtered = auditLogRepository.findAll().stream()
                .filter(item -> actor == null || actor.isBlank() || contains(item.getActorUsername(), actor))
                .filter(item -> module == null || module.isBlank() || contains(item.getModuleName(), module))
                .filter(item -> action == null || action.isBlank() || contains(item.getActionName(), action))
                .filter(item -> fromInstant == null || !item.getCreatedAt().isBefore(fromInstant))
                .filter(item -> toInstant == null || !item.getCreatedAt().isAfter(toInstant))
                .sorted((left, right) -> right.getCreatedAt().compareTo(left.getCreatedAt()))
                .map(AuditLogResponse::from)
                .toList();

        int start = Math.min(safePage * safeSize, filtered.size());
        int end = Math.min(start + safeSize, filtered.size());
        return new AuditLogPageResponse(filtered.subList(start, end), filtered.size(), safePage, safeSize);
    }

    private String resolveActorRole(String actorUsername) {
        if (actorUsername == null || actorUsername.isBlank()) {
            return null;
        }
        return userRepository.findByUsername(actorUsername)
                .map(UserAccount::getRole)
                .map(Enum::name)
                .orElse(null);
    }

    private Instant parseInstant(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Instant.parse(value.trim());
        } catch (DateTimeParseException ex) {
            return null;
        }
    }

    private boolean contains(String source, String keyword) {
        if (source == null) {
            return false;
        }
        return source.toLowerCase(Locale.ROOT).contains(keyword.trim().toLowerCase(Locale.ROOT));
    }
}
