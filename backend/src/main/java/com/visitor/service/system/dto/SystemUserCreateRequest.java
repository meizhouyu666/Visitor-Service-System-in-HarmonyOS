package com.visitor.service.system.dto;

import com.visitor.service.user.UserRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SystemUserCreateRequest(
        @NotBlank(message = "用户名不能为空")
        @Size(max = 64, message = "用户名长度不能超过 64")
        String username,

        @NotBlank(message = "显示名不能为空")
        @Size(max = 128, message = "显示名长度不能超过 128")
        String displayName,

        @NotNull(message = "角色不能为空")
        UserRole role,

        @NotBlank(message = "初始密码不能为空")
        @Size(min = 6, max = 64, message = "密码长度需在 6 到 64 之间")
        String password,

        String managedHotelId
) {
}
