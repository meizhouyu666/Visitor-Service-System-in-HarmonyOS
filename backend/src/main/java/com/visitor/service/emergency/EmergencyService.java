package com.visitor.service.emergency;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.emergency.dto.EmergencyRequest;
import com.visitor.service.emergency.dto.EmergencyResponse;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional
public class EmergencyService {

    private final EmergencyInfoRepository emergencyInfoRepository;
    private final UserRepository userRepository;

    public EmergencyService(EmergencyInfoRepository emergencyInfoRepository, UserRepository userRepository) {
        this.emergencyInfoRepository = emergencyInfoRepository;
        this.userRepository = userRepository;
    }

    public EmergencyResponse create(String username, EmergencyRequest request) {
        UserAccount user = findUser(username);
        EmergencyInfo info = new EmergencyInfo();
        info.setTitle(request.title());
        info.setContent(request.content());
        info.setValidFrom(request.validFrom());
        info.setValidUntil(request.validUntil());
        info.setAlertLevel(normalizeAlertLevel(request.alertLevel()));
        info.setAlertType(normalizeAlertType(request.alertType()));
        info.setStatus(EmergencyStatus.DRAFT);
        info.setCreatedBy(user);
        return EmergencyResponse.from(emergencyInfoRepository.save(info));
    }

    public EmergencyResponse update(Long id, EmergencyRequest request) {
        EmergencyInfo info = findEmergency(id);
        info.setTitle(request.title());
        info.setContent(request.content());
        info.setValidFrom(request.validFrom());
        info.setValidUntil(request.validUntil());
        info.setAlertLevel(resolveAlertLevel(request.alertLevel(), info.getAlertLevel()));
        info.setAlertType(resolveAlertType(request.alertType(), info.getAlertType()));
        return EmergencyResponse.from(emergencyInfoRepository.save(info));
    }

    public void delete(Long id) {
        EmergencyInfo info = findEmergency(id);
        emergencyInfoRepository.delete(info);
    }

    public EmergencyResponse submitForApproval(Long id) {
        EmergencyInfo info = findEmergency(id);
        info.setStatus(EmergencyStatus.PENDING_APPROVAL);
        return EmergencyResponse.from(emergencyInfoRepository.save(info));
    }

    public EmergencyResponse approve(Long id, String username) {
        EmergencyInfo info = findEmergency(id);
        info.setStatus(EmergencyStatus.PUBLISHED);
        info.setApprovedBy(findUser(username));
        return EmergencyResponse.from(emergencyInfoRepository.save(info));
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
        return emergencyInfoRepository.findAll().stream().map(EmergencyResponse::from).toList();
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
}
