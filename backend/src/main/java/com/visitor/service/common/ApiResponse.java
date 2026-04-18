package com.visitor.service.common;

import java.time.Instant;

public record ApiResponse<T>(
        int code,
        String message,
        T data,
        Instant timestamp
) {
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(0, "成功", data, Instant.now());
    }

    public static ApiResponse<Void> successMessage(String message) {
        return new ApiResponse<>(0, message, null, Instant.now());
    }

    public static ApiResponse<Void> failure(int code, String message) {
        return new ApiResponse<>(code, message, null, Instant.now());
    }
}
