package com.visitor.service.emergency;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EmergencyInfoRepository extends JpaRepository<EmergencyInfo, Long> {
    List<EmergencyInfo> findByStatusOrderByCreatedAtDesc(EmergencyStatus status);
}
