package com.visitor.service.system.dto;

import com.visitor.service.user.UserRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SystemUserUpdateRequest(
        @NotBlank(message = "显示名不能为空")
        @Size(max = 128, message = "显示名长度不能超过 128")
        String displayName,

        @NotNull(message = "角色不能为空")
        UserRole role,

        String managedHotelId
) {
}
