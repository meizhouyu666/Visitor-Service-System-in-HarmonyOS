package com.visitor.service.complaint;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.complaint.dto.ComplaintActionRequest;
import com.visitor.service.complaint.dto.ComplaintCreateRequest;
import com.visitor.service.complaint.dto.ComplaintRatingRequest;
import com.visitor.service.complaint.dto.ComplaintResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Complaints")
@RestController
@RequestMapping("/api/complaints")
public class ComplaintController {

    private final ComplaintService complaintService;

    public ComplaintController(ComplaintService complaintService) {
        this.complaintService = complaintService;
    }

    @Operation(summary = "Submit complaint as visitor")
    @PostMapping
    @PreAuthorize("hasAnyRole('VISITOR','ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<ComplaintResponse> create(@Valid @RequestBody ComplaintCreateRequest request,
                                                 Authentication authentication) {
        return ApiResponse.success(complaintService.create(authentication.getName(), request));
    }

    @Operation(summary = "List complaints for current user (admin gets all)")
    @GetMapping
    public ApiResponse<List<ComplaintResponse>> list(Authentication authentication) {
        boolean canReadAll = hasAnyRole(authentication,
                "ROLE_ADMIN", "ROLE_SYSTEM_ADMIN", "ROLE_COMPLAINT_HANDLER", "ROLE_APPROVER");
        return ApiResponse.success(complaintService.listForUser(authentication.getName(), canReadAll));
    }

    @Operation(summary = "Get complaint detail")
    @GetMapping("/{id}")
    public ApiResponse<ComplaintResponse> detail(@PathVariable Long id, Authentication authentication) {
        boolean canReadAll = hasAnyRole(authentication,
                "ROLE_ADMIN", "ROLE_SYSTEM_ADMIN", "ROLE_COMPLAINT_HANDLER", "ROLE_APPROVER");
        return ApiResponse.success(complaintService.detail(authentication.getName(), id, canReadAll));
    }

    @Operation(summary = "Rate complaint after closure")
    @PostMapping("/{id}/rating")
    @PreAuthorize("hasAnyRole('VISITOR','ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<ComplaintResponse> rate(@PathVariable Long id,
                                               @Valid @RequestBody ComplaintRatingRequest request,
                                               Authentication authentication) {
        return ApiResponse.success(complaintService.rate(authentication.getName(), id, request));
    }

    @Operation(summary = "Approve complaint (admin)")
    @PostMapping("/admin/{id}/approve")
    @PreAuthorize("hasAnyRole('APPROVER','ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<ComplaintResponse> approve(@PathVariable Long id,
                                                  @Valid @RequestBody ComplaintActionRequest request,
                                                  Authentication authentication) {
        return ApiResponse.success(complaintService.approve(authentication.getName(), id, request));
    }

    @Operation(summary = "Process complaint (admin)")
    @PostMapping("/admin/{id}/process")
    @PreAuthorize("hasAnyRole('COMPLAINT_HANDLER','ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<ComplaintResponse> process(@PathVariable Long id,
                                                  @Valid @RequestBody ComplaintActionRequest request,
                                                  Authentication authentication) {
        return ApiResponse.success(complaintService.process(authentication.getName(), id, request));
    }

    @Operation(summary = "Close complaint (admin)")
    @PostMapping("/admin/{id}/close")
    @PreAuthorize("hasAnyRole('COMPLAINT_HANDLER','ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<ComplaintResponse> close(@PathVariable Long id,
                                                @Valid @RequestBody ComplaintActionRequest request,
                                                Authentication authentication) {
        return ApiResponse.success(complaintService.close(authentication.getName(), id, request));
    }

    private boolean hasAnyRole(Authentication authentication, String... roleAuthorities) {
        for (String role : roleAuthorities) {
            boolean hit = authentication.getAuthorities().stream()
                    .anyMatch(authority -> authority.getAuthority().equals(role));
            if (hit) {
                return true;
            }
        }
        return false;
    }
}
