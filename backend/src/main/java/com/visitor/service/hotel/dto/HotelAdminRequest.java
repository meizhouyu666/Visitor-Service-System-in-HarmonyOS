package com.visitor.service.hotel.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record HotelAdminRequest(
        @NotBlank(message = "酒店名称不能为空")
        String name,

        @NotBlank(message = "酒店地址不能为空")
        String address,

        @Min(value = 1, message = "星级最低为 1")
        @Max(value = 5, message = "星级最高为 5")
        int star,

        @Min(value = 0, message = "价格不能为负数")
        int price,

        @NotBlank(message = "联系电话不能为空")
        String phone,

        @DecimalMin(value = "0.0", message = "评分不能小于 0")
        @DecimalMax(value = "5.0", message = "评分不能大于 5")
        double score,

        boolean hasBreakfast,

        @NotBlank(message = "设施描述不能为空")
        String facility,

        @NotBlank(message = "酒店简介不能为空")
        String introduction,

        String availabilityStatus,

        String coverImageUrl
) {
}
