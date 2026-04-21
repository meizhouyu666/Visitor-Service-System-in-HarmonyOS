package com.visitor.service.resource;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;

public enum ResourceCategory {
    SCENIC_SPOTS,
    ROUTES,
    DINING,
    PERFORMANCES;

    public static ResourceCategory fromPath(String rawValue) {
        if (rawValue == null || rawValue.isBlank()) {
            throw new BusinessException(ErrorCode.VALIDATION, "资源分类不能为空");
        }
        String normalized = rawValue.trim().toUpperCase().replace('-', '_');
        return switch (normalized) {
            case "SCENIC", "SCENIC_SPOT", "SCENIC_SPOTS" -> SCENIC_SPOTS;
            case "ROUTE", "ROUTES" -> ROUTES;
            case "DINING" -> DINING;
            case "PERFORMANCE", "PERFORMANCES" -> PERFORMANCES;
            default -> throw new BusinessException(ErrorCode.VALIDATION, "不支持的资源分类：" + rawValue);
        };
    }
}
