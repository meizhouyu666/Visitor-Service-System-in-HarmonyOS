package com.visitor.service.complaint;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.complaint.dto.ComplaintActionRequest;
import com.visitor.service.complaint.dto.ComplaintAssignRequest;
import com.visitor.service.complaint.dto.ComplaintCreateRequest;
import com.visitor.service.complaint.dto.ComplaintRatingRequest;
import com.visitor.service.complaint.dto.ComplaintResponse;
import com.visitor.service.complaint.dto.ComplaintTimelineResponse;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ComplaintService {

    private final ComplaintRepository complaintRepository;
    private final ComplaintTimelineRepository complaintTimelineRepository;
    private final UserRepository userRepository;

    public ComplaintService(ComplaintRepository complaintRepository,
                            ComplaintTimelineRepository complaintTimelineRepository,
                            UserRepository userRepository) {
        this.complaintRepository = complaintRepository;
        this.complaintTimelineRepository = complaintTimelineRepository;
        this.userRepository = userRepository;
    }

    public ComplaintResponse create(String username, ComplaintCreateRequest request) {
        UserAccount creator = findUser(username);
        Complaint complaint = new Complaint();
        complaint.setTitle(request.title());
        complaint.setContent(request.content());
        complaint.setAttachmentUrls(request.attachmentUrls());
        complaint.setStatus(ComplaintStatus.SUBMITTED);
        complaint.setCreatedBy(creator);
        Complaint saved = complaintRepository.save(complaint);
        addTimeline(saved, "CREATE", creator, "投诉已提交");
        return ComplaintResponse.from(saved);
    }

    public List<ComplaintResponse> listForUser(String username, boolean canReadAll) {
        if (canReadAll) {
            return complaintRepository.findAll().stream()
                    .map(ComplaintResponse::from)
                    .toList();
        }
        return complaintRepository.findByCreatedByUsernameOrderByCreatedAtDesc(username).stream()
                .map(ComplaintResponse::from)
                .toList();
    }

    public ComplaintResponse detail(String username, Long id, boolean canReadAll) {
        Complaint complaint = findComplaint(id);
        if (!canReadAll && !complaint.getCreatedBy().getUsername().equals(username)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "No permission to read this complaint");
        }
        return ComplaintResponse.from(complaint);
    }

    public List<ComplaintTimelineResponse> timeline(String username, Long id, boolean canReadAll) {
        Complaint complaint = findComplaint(id);
        if (!canReadAll && !complaint.getCreatedBy().getUsername().equals(username)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "No permission to read this complaint timeline");
        }
        return complaintTimelineRepository.findByComplaintIdOrderByCreatedAtAsc(id).stream()
                .map(ComplaintTimelineResponse::from)
                .toList();
    }

    public ComplaintResponse approve(String approverUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        assertStatus(complaint, ComplaintStatus.SUBMITTED, "Only submitted complaint can be approved");
        UserAccount actor = findUser(approverUsername);

        complaint.setStatus(ComplaintStatus.APPROVED);
        complaint.setHandlerComment(request.comment());
        complaint.setProcessedBy(actor);
        complaint.setRejectionComment(null);
        Complaint saved = complaintRepository.save(complaint);

        addTimeline(saved, "APPROVE", actor, request.comment());
        return ComplaintResponse.from(saved);
    }

    public ComplaintResponse reject(String approverUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        assertStatus(complaint, ComplaintStatus.SUBMITTED, "Only submitted complaint can be rejected");
        UserAccount actor = findUser(approverUsername);

        complaint.setStatus(ComplaintStatus.REJECTED);
        complaint.setRejectionComment(request.comment());
        complaint.setProcessedBy(actor);
        Complaint saved = complaintRepository.save(complaint);

        addTimeline(saved, "REJECT", actor, request.comment());
        return ComplaintResponse.from(saved);
    }

    public ComplaintResponse assign(String assignerUsername, Long id, ComplaintAssignRequest request) {
        Complaint complaint = findComplaint(id);
        if (complaint.getStatus() != ComplaintStatus.APPROVED && complaint.getStatus() != ComplaintStatus.IN_PROGRESS) {
            throw new BusinessException(ErrorCode.BUSINESS, "Complaint can be assigned only after approval");
        }
        UserAccount actor = findUser(assignerUsername);
        UserAccount assignee = findUser(request.assigneeUsername());

        complaint.setAssignee(assignee);
        complaint.setProcessedBy(actor);
        Complaint saved = complaintRepository.save(complaint);

        String detail = request.comment() == null || request.comment().isBlank()
                ? "已分派给：" + assignee.getUsername()
                : request.comment();
        addTimeline(saved, "ASSIGN", actor, detail);
        return ComplaintResponse.from(saved);
    }

    public ComplaintResponse process(String handlerUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        assertStatus(complaint, ComplaintStatus.APPROVED, "Complaint must be approved before processing");
        UserAccount actor = findUser(handlerUsername);

        complaint.setStatus(ComplaintStatus.RESOLVED);
        complaint.setHandlerComment(request.comment());
        complaint.setProcessedBy(actor);
        Complaint saved = complaintRepository.save(complaint);

        addTimeline(saved, "PROCESS", actor, request.comment());
        return ComplaintResponse.from(saved);
    }

    public ComplaintResponse close(String handlerUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        assertStatus(complaint, ComplaintStatus.RESOLVED, "Only resolved complaint can be closed");
        UserAccount actor = findUser(handlerUsername);

        complaint.setStatus(ComplaintStatus.CLOSED);
        complaint.setClosureComment(request.comment());
        complaint.setProcessedBy(actor);
        Complaint saved = complaintRepository.save(complaint);

        addTimeline(saved, "CLOSE", actor, request.comment());
        return ComplaintResponse.from(saved);
    }

    public ComplaintResponse rate(String username, Long id, ComplaintRatingRequest request) {
        Complaint complaint = findComplaint(id);
        if (!complaint.getCreatedBy().getUsername().equals(username)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "No permission to rate this complaint");
        }
        if (complaint.getStatus() != ComplaintStatus.CLOSED) {
            throw new BusinessException(ErrorCode.BUSINESS, "Complaint must be closed before rating");
        }
        complaint.setRating(request.rating());
        Complaint saved = complaintRepository.save(complaint);

        addTimeline(saved, "RATE", findUser(username), "评分：" + request.rating());
        return ComplaintResponse.from(saved);
    }

    private void assertStatus(Complaint complaint, ComplaintStatus required, String message) {
        if (complaint.getStatus() != required) {
            throw new BusinessException(ErrorCode.BUSINESS, message);
        }
    }

    private void addTimeline(Complaint complaint, String action, UserAccount actor, String comment) {
        ComplaintTimeline timeline = new ComplaintTimeline();
        timeline.setComplaint(complaint);
        timeline.setAction(action);
        timeline.setActor(actor);
        timeline.setComment(comment);
        complaintTimelineRepository.save(timeline);
    }

    private Complaint findComplaint(Long id) {
        return complaintRepository.findById(id)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "Complaint not found"));
    }

    private UserAccount findUser(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "User not found"));
    }
}
