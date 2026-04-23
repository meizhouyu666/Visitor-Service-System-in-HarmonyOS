package com.visitor.service.emergency;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.emergency.dto.EmergencyRequest;
import com.visitor.service.emergency.dto.EmergencyResponse;
import com.visitor.service.emergency.dto.EmergencyReviewRequest;
import com.visitor.service.system.AuditLogService;
import com.visitor.service.system.SystemSettingService;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Service
@Transactional
public class EmergencyService {

    private final EmergencyInfoRepository emergencyInfoRepository;
    private final UserRepository userRepository;
    private final SystemSettingService systemSettingService;
    private final AuditLogService auditLogService;

    public EmergencyService(EmergencyInfoRepository emergencyInfoRepository,
                            UserRepository userRepository,
                            SystemSettingService systemSettingService,
                            AuditLogService auditLogService) {
        this.emergencyInfoRepository = emergencyInfoRepository;
        this.userRepository = userRepository;
        this.systemSettingService = systemSettingService;
        this.auditLogService = auditLogService;
    }

    public EmergencyResponse create(String username, EmergencyRequest request) {
        UserAccount user = findUser(username);
        EmergencyInfo info = new EmergencyInfo();
        info.setTitle(request.title());
        info.setContent(request.content());
        info.setValidFrom(request.validFrom());
        info.setValidUntil(resolveValidUntil(request.validFrom(), request.validUntil()));
        info.setAlertLevel(normalizeAlertLevel(request.alertLevel()));
        info.setAlertType(normalizeAlertType(request.alertType()));
        info.setStatus(EmergencyStatus.DRAFT);
        info.setCreatedBy(user);
        EmergencyInfo saved = emergencyInfoRepository.save(info);
        auditLogService.record(username, "EMERGENCY", "CREATE", "EMERGENCY", saved.getId(), "创建应急草稿");
        return EmergencyResponse.from(saved);
    }

public EmergencyResponse update(Long id, EmergencyRequest request, String username) {
    EmergencyInfo info = findEmergency(id);
    
    // 1. 状态检查：允许修改的状态
    Set<EmergencyStatus> allowedStatuses = Set.of(
        EmergencyStatus.DRAFT,
        EmergencyStatus.REJECTED,
        EmergencyStatus.PUBLISHED
    );
    if (!allowedStatuses.contains(info.getStatus())) {
        throw new BusinessException(ErrorCode.BUSINESS, "只有草稿、驳回或已发布的应急信息可以修改");
    }
    
    // 2. 更新基本信息
    info.setTitle(request.title());
    info.setContent(request.content());
    info.setValidFrom(request.validFrom());
    info.setValidUntil(resolveValidUntil(request.validFrom(), request.validUntil()));
    info.setAlertLevel(resolveAlertLevel(request.alertLevel(), info.getAlertLevel()));
    info.setAlertType(resolveAlertType(request.alertType(), info.getAlertType()));
    
    // 3. 状态处理：如果原来是已发布，改为待审批；否则保留原状态
    if (info.getStatus() == EmergencyStatus.PUBLISHED) {
        info.setStatus(EmergencyStatus.PENDING_APPROVAL);
    }
    // 草稿和驳回状态：不做改变，保持原状（如果希望驳回后改为草稿，可以加额外逻辑）
    
    EmergencyInfo saved = emergencyInfoRepository.save(info);
    auditLogService.record(username, "EMERGENCY", "UPDATE", "EMERGENCY", saved.getId(), "更新应急信息");
    return EmergencyResponse.from(saved);
}

    public void delete(Long id, String username) {
        EmergencyInfo info = findEmergency(id);
        emergencyInfoRepository.delete(info);
        auditLogService.record(username, "EMERGENCY", "DELETE", "EMERGENCY", id, "删除应急信息");
    }

    public EmergencyResponse submitForApproval(Long id, String username) {
        EmergencyInfo info = findEmergency(id);
        if (info.getStatus() != EmergencyStatus.DRAFT && info.getStatus() != EmergencyStatus.REJECTED) {
            throw new BusinessException(ErrorCode.BUSINESS, "只有草稿或驳回状态的应急信息可以提交审批");
        }
        info.setStatus(EmergencyStatus.PENDING_APPROVAL);
        EmergencyInfo saved = emergencyInfoRepository.save(info);
        auditLogService.record(username, "EMERGENCY", "SUBMIT", "EMERGENCY", saved.getId(), "提交应急信息审批");
        return EmergencyResponse.from(saved);
    }

    public EmergencyResponse approve(Long id, String username) {
        EmergencyInfo info = findEmergency(id);
        if (info.getStatus() != EmergencyStatus.PENDING_APPROVAL) {
            throw new BusinessException(ErrorCode.BUSINESS, "只有待审批状态的应急信息可以发布");
        }
        info.setStatus(EmergencyStatus.PUBLISHED);
        info.setApprovedBy(findUser(username));
        EmergencyInfo saved = emergencyInfoRepository.save(info);
        auditLogService.record(username, "EMERGENCY", "APPROVE", "EMERGENCY", saved.getId(), "审批并发布应急信息");
        return EmergencyResponse.from(saved);
    }

    public EmergencyResponse reject(Long id, EmergencyReviewRequest request, String username) {
        EmergencyInfo info = findEmergency(id);
        if (info.getStatus() != EmergencyStatus.PENDING_APPROVAL) {
            throw new BusinessException(ErrorCode.BUSINESS, "只有待审批状态的应急信息可以驳回");
        }
        info.setStatus(EmergencyStatus.DRAFT);
        info.setApprovedBy(null);
        EmergencyInfo saved = emergencyInfoRepository.save(info);
        String detail = request == null || request.comment() == null || request.comment().isBlank()
                ? "驳回应急信息，等待修改后重新提交"
                : request.comment().trim();
        auditLogService.record(username, "EMERGENCY", "REJECT", "EMERGENCY", saved.getId(), detail);
        return EmergencyResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public List<EmergencyResponse> listPublished() {
        LocalDateTime now = LocalDateTime.now();
        return emergencyInfoRepository.findByStatusOrderByCreatedAtDesc(EmergencyStatus.PUBLISHED)
                .stream()
                .filter(item -> (item.getValidFrom() == null || !item.getValidFrom().isAfter(now))
                        && (item.getValidUntil() == null || !item.getValidUntil().isBefore(now)))
                .map(EmergencyResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<EmergencyResponse> listAll() {
        return emergencyInfoRepository.findAll().stream()
                .sorted((left, right) -> right.getCreatedAt().compareTo(left.getCreatedAt()))
                .map(EmergencyResponse::from)
                .toList();
    }

    private EmergencyInfo findEmergency(Long id) {
        return emergencyInfoRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "应急信息不存在"));
    }

    private UserAccount findUser(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "用户不存在"));
    }

    private String normalizeAlertLevel(String alertLevel) {
        if (alertLevel == null || alertLevel.isBlank()) {
            return "MEDIUM";
        }
        String normalized = alertLevel.trim().toUpperCase();
        if (normalized.equals("HIGH") || normalized.equals("MEDIUM") || normalized.equals("LOW")) {
            return normalized;
        }
        return "MEDIUM";
    }

    private String normalizeAlertType(String alertType) {
        if (alertType == null || alertType.isBlank()) {
            return "GENERAL";
        }
        return alertType.trim().toUpperCase();
    }

    private String resolveAlertLevel(String requestLevel, String fallback) {
        if (requestLevel == null || requestLevel.isBlank()) {
            return fallback == null || fallback.isBlank() ? "MEDIUM" : normalizeAlertLevel(fallback);
        }
        return normalizeAlertLevel(requestLevel);
    }

    private String resolveAlertType(String requestType, String fallback) {
        if (requestType == null || requestType.isBlank()) {
            return fallback == null || fallback.isBlank() ? "GENERAL" : normalizeAlertType(fallback);
        }
        return normalizeAlertType(requestType);
    }

    private LocalDateTime resolveValidUntil(LocalDateTime validFrom, LocalDateTime validUntil) {
        if (validUntil != null) {
            return validUntil;
        }
        LocalDateTime base = validFrom == null ? LocalDateTime.now() : validFrom;
        int hours = systemSettingService.resolveInt("EMERGENCY_DEFAULT_VALID_HOURS", 24);
        return base.plusHours(Math.max(1, hours));
    }
}
