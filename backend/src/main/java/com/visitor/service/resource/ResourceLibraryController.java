package com.visitor.service.resource;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.resource.dto.ResourceItemRequest;
import com.visitor.service.resource.dto.ResourceItemResponse;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "旅游资源库")
@RestController
@RequestMapping("/api/resources")
@PreAuthorize("hasAuthority('RESOURCE_MANAGE')")
public class ResourceLibraryController {

    private final ResourceLibraryService resourceLibraryService;

    public ResourceLibraryController(ResourceLibraryService resourceLibraryService) {
        this.resourceLibraryService = resourceLibraryService;
    }

    @Operation(summary = "平台管理员查询资源列表")
    @GetMapping("/{category}")
    public ApiResponse<List<ResourceItemResponse>> list(@PathVariable String category,
                                                        @RequestParam(required = false) String keyword) {
        return ApiResponse.success(resourceLibraryService.list(ResourceCategory.fromPath(category), keyword));
    }

    @Operation(summary = "平台管理员查询资源详情")
    @GetMapping("/{category}/{id}")
    public ApiResponse<ResourceItemResponse> detail(@PathVariable String category, @PathVariable String id) {
        return ApiResponse.success(resourceLibraryService.detail(ResourceCategory.fromPath(category), id));
    }

    @Operation(summary = "平台管理员新增资源")
    @PostMapping("/{category}")
    public ApiResponse<ResourceItemResponse> create(@PathVariable String category,
                                                    @Valid @RequestBody ResourceItemRequest request,
                                                    Authentication authentication) {
        return ApiResponse.success(resourceLibraryService.create(ResourceCategory.fromPath(category), request, authentication.getName()));
    }

    @Operation(summary = "平台管理员编辑资源")
    @PutMapping("/{category}/{id}")
    public ApiResponse<ResourceItemResponse> update(@PathVariable String category,
                                                    @PathVariable String id,
                                                    @Valid @RequestBody ResourceItemRequest request,
                                                    Authentication authentication) {
        return ApiResponse.success(resourceLibraryService.update(ResourceCategory.fromPath(category), id, request, authentication.getName()));
    }

    @Operation(summary = "资源上架")
    @PostMapping("/{category}/{id}/online")
    public ApiResponse<ResourceItemResponse> online(@PathVariable String category,
                                                    @PathVariable String id,
                                                    Authentication authentication) {
        return ApiResponse.success(resourceLibraryService.setOnline(ResourceCategory.fromPath(category), id, true, authentication.getName()));
    }

    @Operation(summary = "资源下架")
    @PostMapping("/{category}/{id}/offline")
    public ApiResponse<ResourceItemResponse> offline(@PathVariable String category,
                                                     @PathVariable String id,
                                                     Authentication authentication) {
        return ApiResponse.success(resourceLibraryService.setOnline(ResourceCategory.fromPath(category), id, false, authentication.getName()));
    }

    @Operation(summary = "资源删除")
    @DeleteMapping("/{category}/{id}")
    public ApiResponse<Void> delete(@PathVariable String category,
                                    @PathVariable String id,
                                    Authentication authentication) {
        resourceLibraryService.delete(ResourceCategory.fromPath(category), id, authentication.getName());
        return ApiResponse.successMessage("删除成功");
    }
}
