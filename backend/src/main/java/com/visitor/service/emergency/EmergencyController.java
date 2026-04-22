package com.visitor.service.emergency;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.emergency.dto.EmergencyRequest;
import com.visitor.service.emergency.dto.EmergencyResponse;
import com.visitor.service.emergency.dto.EmergencyReviewRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "应急信息")
@RestController
@RequestMapping("/api/emergency")
public class EmergencyController {

    private final EmergencyService emergencyService;

    public EmergencyController(EmergencyService emergencyService) {
        this.emergencyService = emergencyService;
    }

    @Operation(summary = "游客侧应急列表（仅返回有效期内已发布数据）")
    @GetMapping
    public ApiResponse<List<EmergencyResponse>> listPublished() {
        return ApiResponse.success(emergencyService.listPublished());
    }

    @Operation(summary = "平台端应急列表")
    @GetMapping("/admin")
    @PreAuthorize("hasAnyAuthority('EMERGENCY_VIEW','EMERGENCY_WRITE','EMERGENCY_APPROVE')")
    public ApiResponse<List<EmergencyResponse>> listAll() {
        return ApiResponse.success(emergencyService.listAll());
    }

    @Operation(summary = "创建应急草稿")
    @PostMapping("/admin")
    @PreAuthorize("hasAuthority('EMERGENCY_WRITE')")
    public ApiResponse<EmergencyResponse> create(@Valid @RequestBody EmergencyRequest request, Authentication authentication) {
        return ApiResponse.success(emergencyService.create(authentication.getName(), request));
    }

    @Operation(summary = "更新应急草稿")
    @PutMapping("/admin/{id}")
    @PreAuthorize("hasAuthority('EMERGENCY_WRITE')")
    public ApiResponse<EmergencyResponse> update(@PathVariable Long id,
                                                 @Valid @RequestBody EmergencyRequest request,
                                                 Authentication authentication) {
        return ApiResponse.success(emergencyService.update(id, request, authentication.getName()));
    }

    @Operation(summary = "删除应急信息")
    @DeleteMapping("/admin/{id}")
    @PreAuthorize("hasAuthority('EMERGENCY_WRITE')")
    public ApiResponse<Void> delete(@PathVariable Long id, Authentication authentication) {
        emergencyService.delete(id, authentication.getName());
        return ApiResponse.successMessage("删除成功");
    }

    @Operation(summary = "提交应急信息等待审批")
    @PostMapping("/admin/{id}/submit")
    @PreAuthorize("hasAuthority('EMERGENCY_WRITE')")
    public ApiResponse<EmergencyResponse> submit(@PathVariable Long id, Authentication authentication) {
        return ApiResponse.success(emergencyService.submitForApproval(id, authentication.getName()));
    }

    @Operation(summary = "审批并发布应急信息")
    @PostMapping("/admin/{id}/approve")
    @PreAuthorize("hasAuthority('EMERGENCY_APPROVE')")
    public ApiResponse<EmergencyResponse> approve(@PathVariable Long id, Authentication authentication) {
        return ApiResponse.success(emergencyService.approve(id, authentication.getName()));
    }

    @Operation(summary = "驳回应急信息")
    @PostMapping("/admin/{id}/reject")
    @PreAuthorize("hasAuthority('EMERGENCY_APPROVE')")
    public ApiResponse<EmergencyResponse> reject(@PathVariable Long id,
                                                 @RequestBody(required = false) EmergencyReviewRequest request,
                                                 Authentication authentication) {
        return ApiResponse.success(emergencyService.reject(id, request, authentication.getName()));
    }
}
