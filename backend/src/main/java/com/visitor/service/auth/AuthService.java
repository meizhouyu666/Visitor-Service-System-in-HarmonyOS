package com.visitor.service.auth;

import com.visitor.service.auth.dto.CurrentUserResponse;
import com.visitor.service.auth.dto.LoginRequest;
import com.visitor.service.auth.dto.LoginResponse;
import com.visitor.service.auth.dto.RegisterRequest;
import com.visitor.service.auth.dto.RegisterResponse;
import com.visitor.service.auth.dto.RequestResetCodeRequest;
import com.visitor.service.auth.dto.RequestResetCodeResponse;
import com.visitor.service.auth.dto.ResetPasswordRequest;
import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.config.JwtTokenProvider;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.RoleAuthorities;
import com.visitor.service.user.UserRepository;
import com.visitor.service.user.UserRole;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;

@Service
public class AuthService {

    private static final int RESET_CODE_EXPIRE_SECONDS = 10 * 60;

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final PasswordResetCodeRepository passwordResetCodeRepository;
    private final SecureRandom secureRandom;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenProvider tokenProvider,
                       PasswordResetCodeRepository passwordResetCodeRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
        this.passwordResetCodeRepository = passwordResetCodeRepository;
        this.secureRandom = new SecureRandom();
    }

    @Transactional
    public LoginResponse login(LoginRequest request) {
        String username = request.username() == null ? "" : request.username().trim();
        String rawPassword = request.password() == null ? "" : request.password();

        UserAccount user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException(ErrorCode.UNAUTHORIZED, "用户名或密码错误"));

        if (!matchesPassword(rawPassword, user)) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "用户名或密码错误");
        }

        String token = tokenProvider.generateToken(user);
        return new LoginResponse(
                token,
                user.getUsername(),
                user.getDisplayName(),
                user.getRole(),
                RoleAuthorities.permissionsFor(user.getRole())
        );
    }

    @Transactional
    public RegisterResponse register(RegisterRequest request) {
        String username = request.username().trim();
        if (userRepository.findByUsername(username).isPresent()) {
            throw new BusinessException(ErrorCode.BUSINESS, "用户名已存在");
        }

        String displayName = request.displayName() == null || request.displayName().isBlank()
                ? username
                : request.displayName().trim();

        UserAccount user = new UserAccount();
        user.setUsername(username);
        user.setDisplayName(displayName);
        user.setRole(UserRole.VISITOR);
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        UserAccount saved = userRepository.save(user);

        return new RegisterResponse(saved.getUsername(), saved.getDisplayName(), saved.getRole());
    }

    @Transactional
    public RequestResetCodeResponse requestResetCode(RequestResetCodeRequest request) {
        UserAccount user = userRepository.findByUsername(request.username().trim())
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "用户不存在"));

        // 仅最新验证码有效：生成新码时，旧的未使用验证码立即失效。
        passwordResetCodeRepository.findTopByUserUsernameOrderByCreatedAtDesc(user.getUsername())
                .ifPresent(last -> {
                    if (!last.isUsed()) {
                        last.setUsed(true);
                        passwordResetCodeRepository.save(last);
                    }
                });

        String code = generateCode();
        PasswordResetCode resetCode = new PasswordResetCode();
        resetCode.setUser(user);
        resetCode.setCode(code);
        resetCode.setUsed(false);
        resetCode.setExpiresAt(Instant.now().plusSeconds(RESET_CODE_EXPIRE_SECONDS));
        PasswordResetCode saved = passwordResetCodeRepository.save(resetCode);

        return new RequestResetCodeResponse(user.getUsername(), saved.getCode(), saved.getExpiresAt());
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        UserAccount user = userRepository.findByUsername(request.username().trim())
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "用户不存在"));

        PasswordResetCode latestCode = passwordResetCodeRepository.findTopByUserUsernameOrderByCreatedAtDesc(user.getUsername())
                .orElseThrow(() -> new BusinessException(ErrorCode.BUSINESS, "未找到可用验证码"));

        if (latestCode.isUsed()) {
            throw new BusinessException(ErrorCode.BUSINESS, "验证码已使用");
        }
        if (latestCode.getExpiresAt().isBefore(Instant.now())) {
            throw new BusinessException(ErrorCode.BUSINESS, "验证码已过期");
        }
        if (!latestCode.getCode().equals(request.code().trim())) {
            throw new BusinessException(ErrorCode.BUSINESS, "验证码错误");
        }

        user.setPasswordHash(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);

        latestCode.setUsed(true);
        passwordResetCodeRepository.save(latestCode);
    }

    public CurrentUserResponse currentUser() {
        String username = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        UserAccount user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException(ErrorCode.UNAUTHORIZED, "用户不存在"));
        return new CurrentUserResponse(
                user.getUsername(),
                user.getDisplayName(),
                user.getRole(),
                RoleAuthorities.permissionsFor(user.getRole())
        );
    }

    private String generateCode() {
        int value = 100000 + secureRandom.nextInt(900000);
        return String.valueOf(value);
    }

    private boolean matchesPassword(String rawPassword, UserAccount user) {
        String stored = user.getPasswordHash();
        if (stored == null || stored.isBlank()) {
            return false;
        }

        if (isBcryptHash(stored)) {
            return passwordEncoder.matches(rawPassword, stored);
        }

        // 兼容历史明文存储：首次成功登录后自动迁移为 BCrypt。
        if (stored.equals(rawPassword)) {
            user.setPasswordHash(passwordEncoder.encode(rawPassword));
            userRepository.save(user);
            return true;
        }

        return false;
    }

    private boolean isBcryptHash(String value) {
        return value.startsWith("$2a$") || value.startsWith("$2b$") || value.startsWith("$2y$");
    }
}
