package com.visitor.service.auth;

import com.visitor.service.auth.dto.CurrentUserResponse;
import com.visitor.service.auth.dto.LoginRequest;
import com.visitor.service.auth.dto.LoginResponse;
import com.visitor.service.auth.dto.RegisterRequest;
import com.visitor.service.auth.dto.RegisterResponse;
import com.visitor.service.auth.dto.RequestResetCodeRequest;
import com.visitor.service.auth.dto.RequestResetCodeResponse;
import com.visitor.service.auth.dto.ResetPasswordRequest;
import com.visitor.service.common.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "认证")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "登录并获取 JWT")
    @PostMapping("/login")
    public ApiResponse<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResponse.success(authService.login(request));
    }

    @Operation(summary = "注册游客账号")
    @PostMapping("/register")
    public ApiResponse<RegisterResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.success(authService.register(request));
    }

    @Operation(summary = "申请找回密码验证码")
    @PostMapping("/forgot-password/request-code")
    public ApiResponse<RequestResetCodeResponse> requestResetCode(@Valid @RequestBody RequestResetCodeRequest request) {
        return ApiResponse.success(authService.requestResetCode(request));
    }

    @Operation(summary = "使用验证码重置密码")
    @PostMapping("/forgot-password/reset")
    public ApiResponse<Void> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        return ApiResponse.successMessage("密码重置成功");
    }

    @Operation(summary = "获取当前登录用户")
    @GetMapping("/me")
    public ApiResponse<CurrentUserResponse> me() {
        return ApiResponse.success(authService.currentUser());
    }
}
