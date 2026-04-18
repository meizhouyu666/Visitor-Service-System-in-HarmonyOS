package com.visitor.service.complaint;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ComplaintRepository extends JpaRepository<Complaint, Long> {
    List<Complaint> findByCreatedByUsernameOrderByCreatedAtDesc(String username);

    List<Complaint> findAllByOrderByCreatedAtDesc();
}

