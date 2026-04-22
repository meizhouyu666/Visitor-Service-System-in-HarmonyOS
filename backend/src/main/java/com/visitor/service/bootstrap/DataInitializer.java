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
        deleteLegacyDemoUser("writer");
        upsertDemoUser("visitor", "visitor123", "Visitor Demo", UserRole.VISITOR);
        upsertDemoUser("admin", "admin123", "Admin Demo", UserRole.ADMIN);
        upsertDemoUser("handler", "handler123", "Complaint Handler Demo", UserRole.COMPLAINT_HANDLER);
        upsertDemoUser("approver", "approver123", "Emergency Approver Demo", UserRole.APPROVER);
        upsertDemoUser("hoteladmin", "hoteladmin123", "Hotel Admin Demo", UserRole.HOTEL_ADMIN, "h-1");
        upsertDemoUser("sysadmin", "sysadmin123", "System Admin Demo", UserRole.SYSTEM_ADMIN);
    }

    private void deleteLegacyDemoUser(String username) {
        userRepository.findByUsername(username).ifPresent(userRepository::delete);
    }

    private void upsertDemoUser(String username, String rawPassword, String displayName, UserRole role) {
        upsertDemoUser(username, rawPassword, displayName, role, null);
    }

    private void upsertDemoUser(String username, String rawPassword, String displayName, UserRole role, String managedHotelId) {
        UserAccount user = userRepository.findByUsername(username).orElseGet(UserAccount::new);
        user.setUsername(username);
        user.setDisplayName(displayName);
        user.setRole(role);
        user.setEnabled(true);
        user.setManagedHotelId(managedHotelId);
        user.setPasswordHash(passwordEncoder.encode(rawPassword));
        userRepository.save(user);
    }
}
