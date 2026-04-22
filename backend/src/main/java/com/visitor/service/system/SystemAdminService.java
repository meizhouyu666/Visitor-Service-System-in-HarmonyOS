package com.visitor.service.system;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.system.dto.SystemUserCreateRequest;
import com.visitor.service.system.dto.SystemUserResetPasswordRequest;
import com.visitor.service.system.dto.SystemUserResponse;
import com.visitor.service.system.dto.SystemUserUpdateRequest;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import com.visitor.service.user.UserRole;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.EnumSet;
import java.util.List;
import java.util.Set;

@Service
@Transactional
public class SystemAdminService {

    private static final Set<UserRole> MANAGED_ROLES = EnumSet.of(
            UserRole.ADMIN,
            UserRole.APPROVER,
            UserRole.COMPLAINT_HANDLER,
            UserRole.HOTEL_ADMIN,
            UserRole.SYSTEM_ADMIN
    );

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JdbcTemplate jdbcTemplate;
    private final AuditLogService auditLogService;

    public SystemAdminService(UserRepository userRepository,
                              PasswordEncoder passwordEncoder,
                              JdbcTemplate jdbcTemplate,
                              AuditLogService auditLogService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jdbcTemplate = jdbcTemplate;
        this.auditLogService = auditLogService;
    }

    @Transactional(readOnly = true)
    public List<SystemUserResponse> listUsers() {
        return userRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(SystemUserResponse::from)
                .toList();
    }

    public SystemUserResponse createUser(SystemUserCreateRequest request, String actorUsername) {
        String username = request.username().trim();
        if (userRepository.findByUsername(username).isPresent()) {
            throw new BusinessException(ErrorCode.BUSINESS, "用户名已存在");
        }
        validateManagedRole(request.role());
        validateManagedHotel(request.role(), request.managedHotelId());

        UserAccount user = new UserAccount();
        user.setUsername(username);
        user.setDisplayName(request.displayName().trim());
        user.setRole(request.role());
        user.setEnabled(true);
        user.setManagedHotelId(normalizeHotelId(request.managedHotelId()));
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        UserAccount saved = userRepository.save(user);
        auditLogService.record(actorUsername, "SYSTEM", "CREATE_USER", "USER", saved.getId(), "创建系统账号 " + saved.getUsername());
        return SystemUserResponse.from(saved);
    }

    public SystemUserResponse updateUser(Long id, SystemUserUpdateRequest request, String actorUsername) {
        UserAccount user = findUser(id);
        validateManagedRole(request.role());
        validateManagedHotel(request.role(), request.managedHotelId());

        user.setDisplayName(request.displayName().trim());
        user.setRole(request.role());
        user.setManagedHotelId(normalizeHotelId(request.managedHotelId()));
        UserAccount saved = userRepository.save(user);
        auditLogService.record(actorUsername, "SYSTEM", "UPDATE_USER", "USER", saved.getId(), "更新账号信息 " + saved.getUsername());
        return SystemUserResponse.from(saved);
    }

    public void resetPassword(Long id, SystemUserResetPasswordRequest request, String actorUsername) {
        UserAccount user = findUser(id);
        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);
        auditLogService.record(actorUsername, "SYSTEM", "RESET_PASSWORD", "USER", user.getId(), "重置账号密码 " + user.getUsername());
    }

    public SystemUserResponse setEnabled(Long id, boolean enabled, String actorUsername) {
        UserAccount user = findUser(id);
        if (!enabled && user.getUsername().equals(actorUsername)) {
            throw new BusinessException(ErrorCode.BUSINESS, "不能停用当前登录账号");
        }
        user.setEnabled(enabled);
        UserAccount saved = userRepository.save(user);
        auditLogService.record(actorUsername, "SYSTEM", enabled ? "ENABLE_USER" : "DISABLE_USER", "USER", saved.getId(), (enabled ? "启用账号 " : "停用账号 ") + saved.getUsername());
        return SystemUserResponse.from(saved);
    }

    private UserAccount findUser(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "账号不存在"));
    }

    private void validateManagedRole(UserRole role) {
        if (!MANAGED_ROLES.contains(role)) {
            throw new BusinessException(ErrorCode.VALIDATION, "系统管理仅支持创建或维护内部账号角色");
        }
    }

    private void validateManagedHotel(UserRole role, String managedHotelId) {
        String normalizedHotelId = normalizeHotelId(managedHotelId);
        if (role == UserRole.HOTEL_ADMIN) {
            if (normalizedHotelId == null) {
                throw new BusinessException(ErrorCode.VALIDATION, "酒店管理员必须绑定酒店");
            }
            Integer count = jdbcTemplate.queryForObject(
                    "SELECT COUNT(*) FROM query_hotels WHERE id = ?",
                    Integer.class,
                    normalizedHotelId
            );
            if (count == null || count == 0) {
                throw new BusinessException(ErrorCode.NOT_FOUND, "绑定酒店不存在");
            }
            return;
        }
        if (normalizedHotelId != null) {
            throw new BusinessException(ErrorCode.VALIDATION, "只有酒店管理员可以绑定酒店");
        }
    }

    private String normalizeHotelId(String managedHotelId) {
        if (managedHotelId == null) {
            return null;
        }
        String trimmed = managedHotelId.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
