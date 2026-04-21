package com.visitor.service.user;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

import java.util.Locale;

@Converter
public class UserRoleConverter implements AttributeConverter<UserRole, String> {

    @Override
    public String convertToDatabaseColumn(UserRole attribute) {
        return attribute == null ? UserRole.VISITOR.name() : attribute.name();
    }

    @Override
    public UserRole convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isBlank()) {
            return UserRole.VISITOR;
        }

        String normalized = dbData.trim().toUpperCase(Locale.ROOT);
        if (normalized.equals("EMERGENCY_WRITER") || normalized.equals("APPROVER")) {
            return UserRole.ADMIN;
        }
        if (normalized.equals("HOTEL_MANAGER") || normalized.equals("HOTELADMIN")) {
            return UserRole.HOTEL_ADMIN;
        }
        if (normalized.equals("SYSTEM_ADMIN")) {
            return UserRole.SYSTEM_ADMIN;
        }

        try {
            return UserRole.valueOf(normalized);
        } catch (IllegalArgumentException ignored) {
            return UserRole.VISITOR;
        }
    }
}
