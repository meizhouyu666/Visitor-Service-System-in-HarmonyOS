package com.visitor.service.resource.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ResourceItemRequest(
        @NotBlank(message = "标题不能为空")
        @Size(max = 128, message = "标题长度不能超过 128")
        String title,

        @Size(max = 128, message = "副标题长度不能超过 128")
        String subtitle,

        @NotBlank(message = "位置不能为空")
        @Size(max = 255, message = "位置长度不能超过 255")
        String location,

        @Size(max = 128, message = "时间信息长度不能超过 128")
        String schedule,

        @NotBlank(message = "描述不能为空")
        String description,

        String coverImageUrl,

        Boolean online
) {
}
