package com.visitor.service.complaint;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.complaint.dto.ComplaintActionRequest;
import com.visitor.service.complaint.dto.ComplaintAssignRequest;
import com.visitor.service.complaint.dto.ComplaintCreateRequest;
import com.visitor.service.complaint.dto.ComplaintQueryFilter;
import com.visitor.service.complaint.dto.ComplaintRatingRequest;
import com.visitor.service.complaint.dto.ComplaintResponse;
import com.visitor.service.complaint.dto.ComplaintTimelineResponse;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import com.visitor.service.user.UserRole;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Locale;

@Service
@Transactional
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

    @Transactional(readOnly = true)
    public List<ComplaintResponse> listForUser(String username, boolean canReadAll, boolean canReadAssigned, ComplaintQueryFilter filter) {
        List<Complaint> source = canReadAll || canReadAssigned
                ? complaintRepository.findAllByOrderByCreatedAtDesc()
                : complaintRepository.findByCreatedByUsernameOrderByCreatedAtDesc(username);

        ComplaintStatus statusFilter = parseStatus(filter.status());
        Instant from = parseDateTime(filter.from(), "from");
        Instant to = parseDateTime(filter.to(), "to");
        if (from != null && to != null && from.isAfter(to)) {
            throw new BusinessException(ErrorCode.VALIDATION, "开始时间不能晚于结束时间");
        }

        String createdByFilter = normalize(filter.createdBy());
        String assigneeFilter = normalize(filter.assignee());
        String keywordFilter = normalize(filter.keyword());

        return source.stream()
                .filter(item -> canReadAll
                        || !canReadAssigned
                        || (item.getAssignee() != null && item.getAssignee().getUsername().equals(username)))
                .filter(item -> statusFilter == null || item.getStatus() == statusFilter)
                .filter(item -> createdByFilter == null || containsIgnoreCase(item.getCreatedBy().getUsername(), createdByFilter))
                .filter(item -> assigneeFilter == null || (item.getAssignee() != null && containsIgnoreCase(item.getAssignee().getUsername(), assigneeFilter)))
                .filter(item -> keywordFilter == null
                        || containsIgnoreCase(item.getTitle(), keywordFilter)
                        || containsIgnoreCase(item.getContent(), keywordFilter))
                .filter(item -> from == null || !item.getCreatedAt().isBefore(from))
                .filter(item -> to == null || !item.getCreatedAt().isAfter(to))
                .map(ComplaintResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public ComplaintResponse detail(String username, Long id, boolean canReadAll, boolean canReadAssigned) {
        Complaint complaint = findComplaint(id);
        if (!canReadAll && !isOwnComplaint(complaint, username) && !(canReadAssigned && isAssignedTo(complaint, username))) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "无权查看该投诉");
        }
        return ComplaintResponse.from(complaint);
    }

    @Transactional(readOnly = true)
    public List<ComplaintTimelineResponse> timeline(String username, Long id, boolean canReadAll, boolean canReadAssigned) {
        Complaint complaint = findComplaint(id);
        if (!canReadAll && !isOwnComplaint(complaint, username) && !(canReadAssigned && isAssignedTo(complaint, username))) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "无权查看该投诉时间线");
        }
        return complaintTimelineRepository.findByComplaintIdOrderByCreatedAtAsc(id).stream()
                .map(ComplaintTimelineResponse::from)
                .toList();
    }

    public ComplaintResponse approve(String approverUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        assertStatus(complaint, ComplaintStatus.SUBMITTED, "只有待审批投诉可以审批通过");
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
        assertStatus(complaint, ComplaintStatus.SUBMITTED, "只有待审批投诉可以驳回");
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
            throw new BusinessException(ErrorCode.BUSINESS, "仅审批通过后的投诉可分派");
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
        assertStatus(complaint, ComplaintStatus.APPROVED, "投诉需先审批通过后才能处理");
        UserAccount actor = findUser(handlerUsername);
        if (actor.getRole() == UserRole.COMPLAINT_HANDLER && !isAssignedTo(complaint, handlerUsername)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "只能处理分派给自己的投诉");
        }

        complaint.setStatus(ComplaintStatus.RESOLVED);
        complaint.setHandlerComment(request.comment());
        complaint.setProcessedBy(actor);
        Complaint saved = complaintRepository.save(complaint);

        addTimeline(saved, "PROCESS", actor, request.comment());
        return ComplaintResponse.from(saved);
    }

    public ComplaintResponse close(String handlerUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        assertStatus(complaint, ComplaintStatus.RESOLVED, "仅已处理投诉可以结案");
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
            throw new BusinessException(ErrorCode.FORBIDDEN, "无权评价该投诉");
        }
        if (complaint.getStatus() != ComplaintStatus.CLOSED) {
            throw new BusinessException(ErrorCode.BUSINESS, "仅已结案投诉可评价");
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
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "投诉不存在"));
    }

    private UserAccount findUser(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "用户不存在"));
    }

    private boolean isOwnComplaint(Complaint complaint, String username) {
        return complaint.getCreatedBy().getUsername().equals(username);
    }

    private boolean isAssignedTo(Complaint complaint, String username) {
        return complaint.getAssignee() != null && complaint.getAssignee().getUsername().equals(username);
    }

    private ComplaintStatus parseStatus(String rawStatus) {
        String normalized = normalize(rawStatus);
        if (normalized == null) {
            return null;
        }
        try {
            return ComplaintStatus.valueOf(normalized.toUpperCase(Locale.ROOT));
        } catch (IllegalArgumentException ex) {
            throw new BusinessException(ErrorCode.VALIDATION, "状态值无效：" + rawStatus);
        }
    }

    private Instant parseDateTime(String value, String fieldName) {
        String normalized = normalize(value);
        if (normalized == null) {
            return null;
        }
        try {
            return Instant.parse(normalized);
        } catch (DateTimeParseException ignore) {
            try {
                return LocalDateTime.parse(normalized)
                        .atZone(ZoneId.systemDefault())
                        .toInstant();
            } catch (DateTimeParseException ex) {
                throw new BusinessException(ErrorCode.VALIDATION, "时间格式无效：" + fieldName);
            }
        }
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private boolean containsIgnoreCase(String source, String keyword) {
        return source.toLowerCase(Locale.ROOT).contains(keyword.toLowerCase(Locale.ROOT));
    }
}
