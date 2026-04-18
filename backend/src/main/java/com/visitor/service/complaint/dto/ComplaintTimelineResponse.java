package com.visitor.service.complaint.dto;

import com.visitor.service.complaint.ComplaintTimeline;

import java.time.Instant;

public record ComplaintTimelineResponse(
        Long id,
        String action,
        String comment,
        String actor,
        Instant createdAt
) {
    public static ComplaintTimelineResponse from(ComplaintTimeline timeline) {
        return new ComplaintTimelineResponse(
                timeline.getId(),
                timeline.getAction(),
                timeline.getComment(),
                timeline.getActor() == null ? null : timeline.getActor().getUsername(),
                timeline.getCreatedAt()
        );
    }
}
