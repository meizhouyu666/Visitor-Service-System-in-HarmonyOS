package com.visitor.service.common;

public final class ErrorCode {
    public static final int UNAUTHORIZED = 40101;
    public static final int FORBIDDEN = 40301;
    public static final int NOT_FOUND = 40401;
    public static final int VALIDATION = 40001;
    public static final int BUSINESS = 40002;
    public static final int INTERNAL = 50001;

    private ErrorCode() {
    }
}
