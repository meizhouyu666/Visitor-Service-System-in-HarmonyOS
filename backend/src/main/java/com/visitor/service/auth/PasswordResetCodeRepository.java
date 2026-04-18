package com.visitor.service.auth;

import com.visitor.service.user.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PasswordResetCodeRepository extends JpaRepository<PasswordResetCode, Long> {
    Optional<PasswordResetCode> findTopByUserUsernameOrderByCreatedAtDesc(String username);

    int countByUserAndUsedIsFalse(UserAccount user);
}

