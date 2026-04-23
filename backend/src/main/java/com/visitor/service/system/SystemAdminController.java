package com.visitor.service.system;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.system.dto.AuditLogPageResponse;
import com.visitor.service.system.dto.SystemSettingResponse;
import com.visitor.service.system.dto.SystemSettingUpdateRequest;
import com.visitor.service.system.dto.SystemUserCreateRequest;
import com.visitor.service.system.dto.SystemUserResetPasswordRequest;
import com.visitor.service.system.dto.SystemUserResponse;
import com.visitor.service.system.dto.SystemUserUpdateRequest;
import com.visitor.service.user.UserRole;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "系统管理")
@RestController
@RequestMapping("/api/system")
public class SystemAdminController {

    private final SystemAdminService systemAdminService;
    private final AuditLogService auditLogService;
    private final SystemSettingService systemSettingService;

    public SystemAdminController(SystemAdminService systemAdminService,
                                 AuditLogService auditLogService,
                                 SystemSettingService systemSettingService) {
        this.systemAdminService = systemAdminService;
        this.auditLogService = auditLogService;
        this.systemSettingService = systemSettingService;
    }

    @Operation(summary = "系统管理员查询账号列表")
    @GetMapping("/users")
    @PreAuthorize("hasAuthority('USER_MANAGE')")
    public ApiResponse<List<SystemUserResponse>> listUsers() {
        return ApiResponse.success(systemAdminService.listUsers());
    }

    @Operation(summary = "根据角色查询账号列表")
    @GetMapping("/users/by-role")
    @PreAuthorize("hasAuthority('USER_MANAGE') or hasAuthority('COMPLAINT_MANAGE')")
    public ApiResponse<List<SystemUserResponse>> listUsersByRole(@RequestParam UserRole role) {
        return ApiResponse.success(systemAdminService.listUsersByRole(role));
    }

    @Operation(summary = "系统管理员创建账号")
    @PostMapping("/users")
    @PreAuthorize("hasAuthority('USER_MANAGE')")
    public ApiResponse<SystemUserResponse> createUser(@Valid @RequestBody SystemUserCreateRequest request,
                                                      Authentication authentication) {
        return ApiResponse.success(systemAdminService.createUser(request, authentication.getName()));
    }

    @Operation(summary = "系统管理员更新账号")
    @PutMapping("/users/{id}")
    @PreAuthorize("hasAuthority('USER_MANAGE')")
    public ApiResponse<SystemUserResponse> updateUser(@PathVariable Long id,
                                                      @Valid @RequestBody SystemUserUpdateRequest request,
                                                      Authentication authentication) {
        return ApiResponse.success(systemAdminService.updateUser(id, request, authentication.getName()));
    }

    @Operation(summary = "系统管理员重置账号密码")
    @PostMapping("/users/{id}/reset-password")
    @PreAuthorize("hasAuthority('USER_MANAGE')")
    public ApiResponse<Void> resetPassword(@PathVariable Long id,
                                           @Valid @RequestBody SystemUserResetPasswordRequest request,
                                           Authentication authentication) {
        systemAdminService.resetPassword(id, request, authentication.getName());
        return ApiResponse.successMessage("密码已重置");
    }

    @Operation(summary = "启用账号")
    @PostMapping("/users/{id}/enable")
    @PreAuthorize("hasAuthority('USER_MANAGE')")
    public ApiResponse<SystemUserResponse> enableUser(@PathVariable Long id, Authentication authentication) {
        return ApiResponse.success(systemAdminService.setEnabled(id, true, authentication.getName()));
    }

    @Operation(summary = "停用账号")
    @PostMapping("/users/{id}/disable")
    @PreAuthorize("hasAuthority('USER_MANAGE')")
    public ApiResponse<SystemUserResponse> disableUser(@PathVariable Long id, Authentication authentication) {
        return ApiResponse.success(systemAdminService.setEnabled(id, false, authentication.getName()));
    }

    @Operation(summary = "系统管理员查询审计日志")
    @GetMapping("/audit-logs")
    @PreAuthorize("hasAuthority('AUDIT_LOG_VIEW')")
    public ApiResponse<AuditLogPageResponse> auditLogs(
            @RequestParam(required = false) String actor,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String action,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(auditLogService.query(actor, module, action, from, to, page, size));
    }

    @Operation(summary = "系统管理员查询系统参数")
    @GetMapping("/settings")
    @PreAuthorize("hasAuthority('SYSTEM_CONFIG_MANAGE')")
    public ApiResponse<List<SystemSettingResponse>> settings() {
        return ApiResponse.success(systemSettingService.list());
    }

    @Operation(summary = "系统管理员更新系统参数")
    @PutMapping("/settings/{key}")
    @PreAuthorize("hasAuthority('SYSTEM_CONFIG_MANAGE')")
    public ApiResponse<SystemSettingResponse> updateSetting(@PathVariable String key,
                                                            @Valid @RequestBody SystemSettingUpdateRequest request,
                                                            Authentication authentication) {
        return ApiResponse.success(systemSettingService.update(key, request, authentication.getName()));
    }
}
