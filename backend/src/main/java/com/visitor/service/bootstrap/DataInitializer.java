package com.visitor.service.bootstrap;

import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import com.visitor.service.user.UserRole;
import com.visitor.service.complaint.Complaint;
import com.visitor.service.complaint.ComplaintRepository;
import com.visitor.service.complaint.ComplaintStatus;
import com.visitor.service.emergency.EmergencyInfo;
import com.visitor.service.emergency.EmergencyInfoRepository;
import com.visitor.service.emergency.EmergencyStatus;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ComplaintRepository complaintRepository;
    private final EmergencyInfoRepository emergencyInfoRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(UserRepository userRepository,
                          ComplaintRepository complaintRepository,
                          EmergencyInfoRepository emergencyInfoRepository,
                          PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.complaintRepository = complaintRepository;
        this.emergencyInfoRepository = emergencyInfoRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        // 创建初始用户
        createUserIfAbsent("visitor", "visitor123", "Visitor Demo", UserRole.VISITOR);
        createUserIfAbsent("admin", "admin123", "Admin Demo", UserRole.ADMIN);
        createUserIfAbsent("writer", "writer123", "Emergency Writer Demo", UserRole.EMERGENCY_WRITER);
    }

    private UserAccount createUserIfAbsent(String username, String rawPassword, String displayName, UserRole role) {
        return userRepository.findByUsername(username)
                .orElseGet(() -> {
                    UserAccount user = new UserAccount();
                    user.setUsername(username);
                    user.setDisplayName(displayName);
                    user.setRole(role);
                    user.setPasswordHash(passwordEncoder.encode(rawPassword));
                    return userRepository.save(user);
                });
    }


}
