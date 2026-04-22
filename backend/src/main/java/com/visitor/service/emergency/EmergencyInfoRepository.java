package com.visitor.service.emergency;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface EmergencyInfoRepository extends JpaRepository<EmergencyInfo, Long> {

    @EntityGraph(attributePaths = {"createdBy", "approvedBy"})
    List<EmergencyInfo> findByStatusOrderByCreatedAtDesc(EmergencyStatus status);

    @Override
    @EntityGraph(attributePaths = {"createdBy", "approvedBy"})
    List<EmergencyInfo> findAll();

    @Override
    @EntityGraph(attributePaths = {"createdBy", "approvedBy"})
    Optional<EmergencyInfo> findById(Long id);
}
