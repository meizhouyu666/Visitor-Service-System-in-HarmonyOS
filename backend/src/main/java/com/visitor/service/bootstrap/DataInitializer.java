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
        createUserIfAbsent("visitor", "visitor123", "Visitor Demo", UserRole.VISITOR);
        createUserIfAbsent("admin", "admin123", "Admin Demo", UserRole.ADMIN);
        createUserIfAbsent("handler", "handler123", "Complaint Handler Demo", UserRole.COMPLAINT_HANDLER);
        createUserIfAbsent("writer", "writer123", "Emergency Writer Demo", UserRole.EMERGENCY_WRITER);
        createUserIfAbsent("approver", "approver123", "Approver Demo", UserRole.APPROVER);
        createUserIfAbsent("hoteladmin", "hotel123", "Hotel Manager Demo", UserRole.HOTEL_MANAGER);
        createUserIfAbsent("sysadmin", "sysadmin123", "System Admin Demo", UserRole.SYSTEM_ADMIN);
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
