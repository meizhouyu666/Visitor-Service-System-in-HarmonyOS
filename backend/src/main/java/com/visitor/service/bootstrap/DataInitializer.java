package com.visitor.service.bootstrap;

import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import com.visitor.service.user.UserRole;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        createUserIfAbsent("visitor", "visitor123", "游客演示账号", UserRole.VISITOR);
        createUserIfAbsent("admin", "admin123", "平台管理员", UserRole.ADMIN);
        createUserIfAbsent("handler", "handler123", "投诉处理员", UserRole.COMPLAINT_HANDLER);
        createUserIfAbsent("writer", "writer123", "应急发布员", UserRole.EMERGENCY_WRITER);
        createUserIfAbsent("approver", "approver123", "审批员", UserRole.APPROVER);
        createUserIfAbsent("hoteladmin", "hoteladmin123", "酒店管理员", UserRole.HOTEL_MANAGER);
        createUserIfAbsent("sysadmin", "sysadmin123", "系统管理员", UserRole.SYSTEM_ADMIN);
    }

    private void createUserIfAbsent(String username, String rawPassword, String displayName, UserRole role) {
        if (userRepository.findByUsername(username).isPresent()) {
            return;
        }
        UserAccount user = new UserAccount();
        user.setUsername(username);
        user.setDisplayName(displayName);
        user.setRole(role);
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        userRepository.save(user);
    }
}
