package com.visitor.service.complaint;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.complaint.dto.ComplaintActionRequest;
import com.visitor.service.complaint.dto.ComplaintAssignRequest;
import com.visitor.service.complaint.dto.ComplaintCreateRequest;
import com.visitor.service.complaint.dto.ComplaintQueryFilter;
import com.visitor.service.complaint.dto.ComplaintRatingRequest;
import com.visitor.service.complaint.dto.ComplaintResponse;
import com.visitor.service.complaint.dto.ComplaintTimelineResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "投诉")
@RestController
@RequestMapping("/api/complaints")
public class ComplaintController {

    private final ComplaintService complaintService;

    public ComplaintController(ComplaintService complaintService) {
        this.complaintService = complaintService;
    }

    @Operation(summary = "游客提交投诉")
    @PostMapping
    @PreAuthorize("hasRole('VISITOR')")
    public ApiResponse<ComplaintResponse> create(@Valid @RequestBody ComplaintCreateRequest request,
                                                 Authentication authentication) {
        return ApiResponse.success(complaintService.create(authentication.getName(), request));
    }

    @Operation(summary = "投诉列表（支持筛选）")
    @GetMapping
    public ApiResponse<List<ComplaintResponse>> list(
            Authentication authentication,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String createdBy,
            @RequestParam(required = false) String assignee,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String from,
            @RequestParam(required = false) String to) {
        boolean canReadAll = hasAuthority(authentication, "COMPLAINT_MANAGE");
        boolean canReadAssigned = hasAuthority(authentication, "COMPLAINT_PROCESS");
        ComplaintQueryFilter filter = new ComplaintQueryFilter(status, createdBy, assignee, keyword, from, to);
        return ApiResponse.success(complaintService.listForUser(authentication.getName(), canReadAll, canReadAssigned, filter));
    }

    @Operation(summary = "投诉详情")
    @GetMapping("/{id}")
    public ApiResponse<ComplaintResponse> detail(@PathVariable Long id, Authentication authentication) {
        boolean canReadAll = hasAuthority(authentication, "COMPLAINT_MANAGE");
        boolean canReadAssigned = hasAuthority(authentication, "COMPLAINT_PROCESS");
        return ApiResponse.success(complaintService.detail(authentication.getName(), id, canReadAll, canReadAssigned));
    }

    @Operation(summary = "投诉时间线")
    @GetMapping("/{id}/timeline")
    public ApiResponse<List<ComplaintTimelineResponse>> timeline(@PathVariable Long id, Authentication authentication) {
        boolean canReadAll = hasAuthority(authentication, "COMPLAINT_MANAGE");
        boolean canReadAssigned = hasAuthority(authentication, "COMPLAINT_PROCESS");
        return ApiResponse.success(complaintService.timeline(authentication.getName(), id, canReadAll, canReadAssigned));
    }

    @Operation(summary = "结案后评价")
    @PostMapping("/{id}/rating")
    @PreAuthorize("hasRole('VISITOR')")
    public ApiResponse<ComplaintResponse> rate(@PathVariable Long id,
                                               @Valid @RequestBody ComplaintRatingRequest request,
                                               Authentication authentication) {
        return ApiResponse.success(complaintService.rate(authentication.getName(), id, request));
    }

    @Operation(summary = "审批通过")
    @PostMapping("/admin/{id}/approve")
    @PreAuthorize("hasAuthority('COMPLAINT_MANAGE')")
    public ApiResponse<ComplaintResponse> approve(@PathVariable Long id,
                                                  @Valid @RequestBody ComplaintActionRequest request,
                                                  Authentication authentication) {
        return ApiResponse.success(complaintService.approve(authentication.getName(), id, request));
    }

    @Operation(summary = "驳回投诉")
    @PostMapping("/admin/{id}/reject")
    @PreAuthorize("hasAuthority('COMPLAINT_MANAGE')")
    public ApiResponse<ComplaintResponse> reject(@PathVariable Long id,
                                                 @Valid @RequestBody ComplaintActionRequest request,
                                                 Authentication authentication) {
        return ApiResponse.success(complaintService.reject(authentication.getName(), id, request));
    }

    @Operation(summary = "分派投诉")
    @PostMapping("/admin/{id}/assign")
    @PreAuthorize("hasAuthority('COMPLAINT_MANAGE')")
    public ApiResponse<ComplaintResponse> assign(@PathVariable Long id,
                                                 @Valid @RequestBody ComplaintAssignRequest request,
                                                 Authentication authentication) {
        return ApiResponse.success(complaintService.assign(authentication.getName(), id, request));
    }

    @Operation(summary = "处理投诉")
    @PostMapping("/admin/{id}/process")
    @PreAuthorize("hasAuthority('COMPLAINT_PROCESS')")
    public ApiResponse<ComplaintResponse> process(@PathVariable Long id,
                                                  @Valid @RequestBody ComplaintActionRequest request,
                                                  Authentication authentication) {
        return ApiResponse.success(complaintService.process(authentication.getName(), id, request));
    }

    @Operation(summary = "结案投诉")
    @PostMapping("/admin/{id}/close")
    @PreAuthorize("hasAuthority('COMPLAINT_MANAGE')")
    public ApiResponse<ComplaintResponse> close(@PathVariable Long id,
                                                @Valid @RequestBody ComplaintActionRequest request,
                                                Authentication authentication) {
        return ApiResponse.success(complaintService.close(authentication.getName(), id, request));
    }

    private boolean hasAuthority(Authentication authentication, String authorityName) {
        return authentication.getAuthorities().stream()
                .map(authority -> authority.getAuthority())
                .anyMatch(authority -> authority.equals(authorityName));
    }
}
