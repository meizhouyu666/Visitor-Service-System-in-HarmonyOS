package com.visitor.service.system.dto;

import com.visitor.service.system.SystemSetting;

import java.time.Instant;

public record SystemSettingResponse(
        String key,
        String value,
        String description,
        String updatedBy,
        Instant updatedAt
) {
    public static SystemSettingResponse from(SystemSetting setting) {
        return new SystemSettingResponse(
                setting.getSettingKey(),
                setting.getSettingValue(),
                setting.getDescriptionText(),
                setting.getUpdatedBy(),
                setting.getUpdatedAt()
        );
    }
}
