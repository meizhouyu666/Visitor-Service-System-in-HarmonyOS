package com.visitor.service.complaint;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.complaint.dto.ComplaintActionRequest;
import com.visitor.service.complaint.dto.ComplaintCreateRequest;
import com.visitor.service.complaint.dto.ComplaintRatingRequest;
import com.visitor.service.complaint.dto.ComplaintResponse;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ComplaintService {

    private final ComplaintRepository complaintRepository;
    private final UserRepository userRepository;

    public ComplaintService(ComplaintRepository complaintRepository, UserRepository userRepository) {
        this.complaintRepository = complaintRepository;
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
        return ComplaintResponse.from(complaintRepository.save(complaint));
    }

    public List<ComplaintResponse> listForUser(String username, boolean isAdmin) {
        if (isAdmin) {
            return complaintRepository.findAll().stream()
                    .map(ComplaintResponse::from)
                    .toList();
        }
        return complaintRepository.findByCreatedByUsernameOrderByCreatedAtDesc(username).stream()
                .map(ComplaintResponse::from)
                .toList();
    }

    public ComplaintResponse detail(String username, Long id, boolean isAdmin) {
        Complaint complaint = findComplaint(id);
        if (!isAdmin && !complaint.getCreatedBy().getUsername().equals(username)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "No permission to read this complaint");
        }
        return ComplaintResponse.from(complaint);
    }

    public ComplaintResponse approve(String adminUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        complaint.setStatus(ComplaintStatus.APPROVED);
        complaint.setHandlerComment(request.comment());
        complaint.setProcessedBy(findUser(adminUsername));
        return ComplaintResponse.from(complaintRepository.save(complaint));
    }

    public ComplaintResponse process(String adminUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        complaint.setStatus(ComplaintStatus.RESOLVED);
        complaint.setHandlerComment(request.comment());
        complaint.setProcessedBy(findUser(adminUsername));
        return ComplaintResponse.from(complaintRepository.save(complaint));
    }

    public ComplaintResponse close(String adminUsername, Long id, ComplaintActionRequest request) {
        Complaint complaint = findComplaint(id);
        complaint.setStatus(ComplaintStatus.CLOSED);
        complaint.setClosureComment(request.comment());
        complaint.setProcessedBy(findUser(adminUsername));
        return ComplaintResponse.from(complaintRepository.save(complaint));
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
        return ComplaintResponse.from(complaintRepository.save(complaint));
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
