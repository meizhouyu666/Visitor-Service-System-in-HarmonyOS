package com.visitor.service.system.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SystemUserResetPasswordRequest(
        @NotBlank(message = "新密码不能为空")
        @Size(min = 6, max = 64, message = "密码长度需在 6 到 64 之间")
        String newPassword
) {
}
