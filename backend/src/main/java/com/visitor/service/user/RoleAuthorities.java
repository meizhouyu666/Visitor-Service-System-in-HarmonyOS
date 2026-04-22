package com.visitor.service.user;

import org.springframework.security.core.authority.SimpleGrantedAuthority;

import java.util.ArrayList;
import java.util.List;

public final class RoleAuthorities {

    public static final String COMPLAINT_MANAGE = "COMPLAINT_MANAGE";
    public static final String COMPLAINT_PROCESS = "COMPLAINT_PROCESS";
    public static final String EMERGENCY_VIEW = "EMERGENCY_VIEW";
    public static final String EMERGENCY_WRITE = "EMERGENCY_WRITE";
    public static final String EMERGENCY_APPROVE = "EMERGENCY_APPROVE";
    public static final String MARKETING_MANAGE = "MARKETING_MANAGE";
    public static final String RESOURCE_MANAGE = "RESOURCE_MANAGE";
    public static final String HOTEL_ROOM_MANAGE = "HOTEL_ROOM_MANAGE";
    public static final String USER_MANAGE = "USER_MANAGE";
    public static final String SYSTEM_CONFIG_MANAGE = "SYSTEM_CONFIG_MANAGE";
    public static final String AUDIT_LOG_VIEW = "AUDIT_LOG_VIEW";

    private RoleAuthorities() {
    }

    public static List<String> permissionsFor(UserRole role) {
        return switch (role) {
            case ADMIN -> List.of(
                    COMPLAINT_MANAGE,
                    COMPLAINT_PROCESS,
                    EMERGENCY_VIEW,
                    EMERGENCY_WRITE,
                    MARKETING_MANAGE,
                    RESOURCE_MANAGE
            );
            case APPROVER -> List.of(EMERGENCY_VIEW, EMERGENCY_APPROVE);
            case COMPLAINT_HANDLER -> List.of(COMPLAINT_PROCESS);
            case HOTEL_ADMIN -> List.of(HOTEL_ROOM_MANAGE);
            case SYSTEM_ADMIN -> List.of(USER_MANAGE, SYSTEM_CONFIG_MANAGE, AUDIT_LOG_VIEW);
            case VISITOR -> List.of();
        };
    }

    public static List<SimpleGrantedAuthority> authoritiesFor(UserRole role) {
        List<SimpleGrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_" + role.name()));
        permissionsFor(role).forEach(permission -> authorities.add(new SimpleGrantedAuthority(permission)));
        return authorities;
    }
}
