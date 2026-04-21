package com.visitor.service.complaint;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ComplaintRepository extends JpaRepository<Complaint, Long> {

    @EntityGraph(attributePaths = {"createdBy", "processedBy", "assignee"})
    List<Complaint> findByCreatedByUsernameOrderByCreatedAtDesc(String username);

    @EntityGraph(attributePaths = {"createdBy", "processedBy", "assignee"})
    List<Complaint> findAllByOrderByCreatedAtDesc();

    @Override
    @EntityGraph(attributePaths = {"createdBy", "processedBy", "assignee"})
    Optional<Complaint> findById(Long id);
}

