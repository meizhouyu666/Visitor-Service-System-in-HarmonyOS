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
        upsertDemoUser("visitor", "visitor123", "Visitor Demo", UserRole.VISITOR);
        upsertDemoUser("admin", "admin123", "Admin Demo", UserRole.ADMIN);
        upsertDemoUser("handler", "handler123", "Complaint Handler Demo", UserRole.COMPLAINT_HANDLER);
        upsertDemoUser("writer", "writer123", "Platform Admin Demo", UserRole.ADMIN);
        upsertDemoUser("approver", "approver123", "Platform Admin Demo", UserRole.ADMIN);
        upsertDemoUser("hoteladmin", "hoteladmin123", "Hotel Admin Demo", UserRole.HOTEL_ADMIN);
        upsertDemoUser("sysadmin", "sysadmin123", "System Admin Demo", UserRole.SYSTEM_ADMIN);
    }

    private void upsertDemoUser(String username, String rawPassword, String displayName, UserRole role) {
        UserAccount user = userRepository.findByUsername(username).orElseGet(UserAccount::new);
        user.setUsername(username);
        user.setDisplayName(displayName);
        user.setRole(role);
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        userRepository.save(user);
    }
}
