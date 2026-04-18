package com.visitor.service.emergency;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.emergency.dto.EmergencyRequest;
import com.visitor.service.emergency.dto.EmergencyResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Emergency Information")
@RestController
@RequestMapping("/api/emergency")
public class EmergencyController {

    private final EmergencyService emergencyService;

    public EmergencyController(EmergencyService emergencyService) {
        this.emergencyService = emergencyService;
    }

    @Operation(summary = "List published emergency info for visitors")
    @GetMapping
    public ApiResponse<List<EmergencyResponse>> listPublished() {
        return ApiResponse.success(emergencyService.listPublished());
    }

    @Operation(summary = "List all emergency info for emergency writer, approver, admin or system admin")
    @GetMapping("/admin")
    @PreAuthorize("hasAnyRole('EMERGENCY_WRITER','APPROVER','ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<List<EmergencyResponse>> listAll() {
        return ApiResponse.success(emergencyService.listAll());
    }

    @Operation(summary = "Create emergency info draft (emergency writer)")
    @PostMapping("/admin")
    @PreAuthorize("hasRole('EMERGENCY_WRITER')")
    public ApiResponse<EmergencyResponse> create(@Valid @RequestBody EmergencyRequest request, Authentication authentication) {
        return ApiResponse.success(emergencyService.create(authentication.getName(), request));
    }

    @Operation(summary = "Update emergency info (emergency writer or admin)")
    @PutMapping("/admin/{id}")
    @PreAuthorize("hasAnyRole('EMERGENCY_WRITER','ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<EmergencyResponse> update(@PathVariable Long id, @Valid @RequestBody EmergencyRequest request) {
        return ApiResponse.success(emergencyService.update(id, request));
    }

    @Operation(summary = "Delete emergency info (admin or system admin)")
    @DeleteMapping("/admin/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        emergencyService.delete(id);
        return ApiResponse.successMessage("Deleted");
    }

    @Operation(summary = "Submit emergency info for approval (emergency writer)")
    @PostMapping("/admin/{id}/submit")
    @PreAuthorize("hasRole('EMERGENCY_WRITER')")
    public ApiResponse<EmergencyResponse> submit(@PathVariable Long id) {
        return ApiResponse.success(emergencyService.submitForApproval(id));
    }

    @Operation(summary = "Approve and publish emergency info (approver, admin or system admin)")
    @PostMapping("/admin/{id}/approve")
    @PreAuthorize("hasAnyRole('APPROVER','ADMIN','SYSTEM_ADMIN')")
    public ApiResponse<EmergencyResponse> approve(@PathVariable Long id, Authentication authentication) {
        return ApiResponse.success(emergencyService.approve(id, authentication.getName()));
    }
}
