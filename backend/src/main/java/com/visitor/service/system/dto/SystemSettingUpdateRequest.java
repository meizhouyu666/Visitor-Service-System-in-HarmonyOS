package com.visitor.service.system.dto;

import jakarta.validation.constraints.NotBlank;

public record SystemSettingUpdateRequest(
        @NotBlank(message = "配置值不能为空")
        String value,

        String description
) {
}
