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
    public ApiResponse<ComplaintResponse> create(@Valid @RequestBody ComplaintCreateRequest request,
                                                 Authentication authentication) {
        return ApiResponse.success(complaintService.create(authentication.getName(), request));
    }

    @Operation(summary = "List complaints for current user (admin gets all)")
    @GetMapping
    public ApiResponse<List<ComplaintResponse>> list(Authentication authentication) {
        boolean isAdmin = authentication.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("ROLE_ADMIN"));
        return ApiResponse.success(complaintService.listForUser(authentication.getName(), isAdmin));
    }

    @Operation(summary = "Get complaint detail")
    @GetMapping("/{id}")
    public ApiResponse<ComplaintResponse> detail(@PathVariable Long id, Authentication authentication) {
        boolean isAdmin = authentication.getAuthorities().stream()
                .anyMatch(authority -> authority.getAuthority().equals("ROLE_ADMIN"));
        return ApiResponse.success(complaintService.detail(authentication.getName(), id, isAdmin));
    }

    @Operation(summary = "Rate complaint after closure")
    @PostMapping("/{id}/rating")
    public ApiResponse<ComplaintResponse> rate(@PathVariable Long id,
                                               @Valid @RequestBody ComplaintRatingRequest request,
                                               Authentication authentication) {
        return ApiResponse.success(complaintService.rate(authentication.getName(), id, request));
    }

    @Operation(summary = "Approve complaint (admin)")
    @PostMapping("/admin/{id}/approve")
    public ApiResponse<ComplaintResponse> approve(@PathVariable Long id,
                                                  @Valid @RequestBody ComplaintActionRequest request,
                                                  Authentication authentication) {
        return ApiResponse.success(complaintService.approve(authentication.getName(), id, request));
    }

    @Operation(summary = "Process complaint (admin)")
    @PostMapping("/admin/{id}/process")
    public ApiResponse<ComplaintResponse> process(@PathVariable Long id,
                                                  @Valid @RequestBody ComplaintActionRequest request,
                                                  Authentication authentication) {
        return ApiResponse.success(complaintService.process(authentication.getName(), id, request));
    }

    @Operation(summary = "Close complaint (admin)")
    @PostMapping("/admin/{id}/close")
    public ApiResponse<ComplaintResponse> close(@PathVariable Long id,
                                                @Valid @RequestBody ComplaintActionRequest request,
                                                Authentication authentication) {
        return ApiResponse.success(complaintService.close(authentication.getName(), id, request));
    }
}
