package com.visitor.service.complaint;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ComplaintTimelineRepository extends JpaRepository<ComplaintTimeline, Long> {

    @EntityGraph(attributePaths = {"actor"})
    List<ComplaintTimeline> findByComplaintIdOrderByCreatedAtAsc(Long complaintId);
}
