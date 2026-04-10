package com.visitor.service.complaint.dto;

import com.visitor.service.complaint.Complaint;
import com.visitor.service.complaint.ComplaintStatus;

import java.time.Instant;

public record ComplaintResponse(
        Long id,
        String title,
        String content,
        String attachmentUrls,
        ComplaintStatus status,
        String handlerComment,
        String closureComment,
        Integer rating,
        String createdBy,
        String processedBy,
        Instant createdAt,
        Instant updatedAt
) {
    public static ComplaintResponse from(Complaint complaint) {
        return new ComplaintResponse(
                complaint.getId(),
                complaint.getTitle(),
                complaint.getContent(),
                complaint.getAttachmentUrls(),
                complaint.getStatus(),
                complaint.getHandlerComment(),
                complaint.getClosureComment(),
                complaint.getRating(),
                complaint.getCreatedBy().getUsername(),
                complaint.getProcessedBy() == null ? null : complaint.getProcessedBy().getUsername(),
                complaint.getCreatedAt(),
                complaint.getUpdatedAt()
        );
    }
}
