package com.visitor.service.system;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.system.dto.SystemSettingResponse;
import com.visitor.service.system.dto.SystemSettingUpdateRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class SystemSettingService {

    private final SystemSettingRepository systemSettingRepository;
    private final AuditLogService auditLogService;

    public SystemSettingService(SystemSettingRepository systemSettingRepository, AuditLogService auditLogService) {
        this.systemSettingRepository = systemSettingRepository;
        this.auditLogService = auditLogService;
    }

    @Transactional(readOnly = true)
    public List<SystemSettingResponse> list() {
        return systemSettingRepository.findAll().stream()
                .sorted((left, right) -> left.getSettingKey().compareToIgnoreCase(right.getSettingKey()))
                .map(SystemSettingResponse::from)
                .toList();
    }

    public SystemSettingResponse update(String key, SystemSettingUpdateRequest request, String actorUsername) {
        SystemSetting setting = systemSettingRepository.findById(key)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "系统参数不存在"));
        setting.setSettingValue(request.value().trim());
        if (request.description() != null && !request.description().isBlank()) {
            setting.setDescriptionText(request.description().trim());
        }
        setting.setUpdatedBy(actorUsername);
        SystemSetting saved = systemSettingRepository.save(setting);
        auditLogService.record(actorUsername, "SYSTEM", "UPDATE_SETTING", "SYSTEM_SETTING", saved.getSettingKey(), "更新系统参数");
        return SystemSettingResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public int resolveInt(String key, int defaultValue) {
        return systemSettingRepository.findById(key)
                .map(SystemSetting::getSettingValue)
                .map(String::trim)
                .filter(value -> !value.isEmpty())
                .map(value -> {
                    try {
                        return Integer.parseInt(value);
                    } catch (NumberFormatException ex) {
                        return defaultValue;
                    }
                })
                .orElse(defaultValue);
    }
}
