package com.visitor.service.auth;

import com.visitor.service.auth.dto.CurrentUserResponse;
import com.visitor.service.auth.dto.LoginRequest;
import com.visitor.service.auth.dto.LoginResponse;
import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.config.JwtTokenProvider;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtTokenProvider tokenProvider) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
    }

    public LoginResponse login(LoginRequest request) {
        UserAccount user = userRepository.findByUsername(request.username())
                .orElseThrow(() -> new BusinessException(ErrorCode.UNAUTHORIZED, "Invalid username or password"));
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "Invalid username or password");
        }
        String token = tokenProvider.generateToken(user);
        return new LoginResponse(token, user.getUsername(), user.getDisplayName(), user.getRole());
    }

    public CurrentUserResponse currentUser() {
        String username = (String) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        UserAccount user = userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException(ErrorCode.UNAUTHORIZED, "User not found"));
        return new CurrentUserResponse(user.getUsername(), user.getDisplayName(), user.getRole());
    }
}
