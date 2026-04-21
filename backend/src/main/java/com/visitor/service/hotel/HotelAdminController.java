package com.visitor.service.hotel;

import com.visitor.service.common.ApiResponse;
import com.visitor.service.hotel.dto.HotelAdminRequest;
import com.visitor.service.query.dto.HotelResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
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

@Tag(name = "酒店管理")
@RestController
@RequestMapping("/api/hotels/admin")
@PreAuthorize("hasAuthority('HOTEL_ROOM_MANAGE')")
public class HotelAdminController {

    private final HotelAdminService hotelAdminService;

    public HotelAdminController(HotelAdminService hotelAdminService) {
        this.hotelAdminService = hotelAdminService;
    }

    @Operation(summary = "管理侧酒店列表")
    @GetMapping
    public ApiResponse<List<HotelResponse>> list(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer minStar,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) Integer minPrice,
            @RequestParam(required = false) Integer maxPrice) {
        return ApiResponse.success(hotelAdminService.list(keyword, minStar, area, minPrice, maxPrice));
    }

    @Operation(summary = "新增酒店")
    @PostMapping
    public ApiResponse<HotelResponse> create(@Valid @RequestBody HotelAdminRequest request) {
        return ApiResponse.success(hotelAdminService.create(request));
    }

    @Operation(summary = "编辑酒店")
    @PutMapping("/{id}")
    public ApiResponse<HotelResponse> update(@PathVariable String id, @Valid @RequestBody HotelAdminRequest request) {
        return ApiResponse.success(hotelAdminService.update(id, request));
    }

    @Operation(summary = "删除酒店")
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable String id) {
        hotelAdminService.delete(id);
        return ApiResponse.successMessage("删除成功");
    }
}
