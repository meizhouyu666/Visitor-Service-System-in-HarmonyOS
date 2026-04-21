package com.visitor.service.hotel;

import com.visitor.service.common.BusinessException;
import com.visitor.service.common.ErrorCode;
import com.visitor.service.hotel.dto.HotelAdminRequest;
import com.visitor.service.query.QueryService;
import com.visitor.service.query.dto.HotelResponse;
import com.visitor.service.system.AuditLogService;
import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
@Transactional
public class HotelAdminService {

    private static final Set<String> ALLOWED_AVAILABILITY = Set.of("AVAILABLE", "LIMITED", "BUSY", "FULL");

    private final JdbcTemplate jdbcTemplate;
    private final QueryService queryService;
    private final UserRepository userRepository;
    private final AuditLogService auditLogService;

    public HotelAdminService(JdbcTemplate jdbcTemplate,
                             QueryService queryService,
                             UserRepository userRepository,
                             AuditLogService auditLogService) {
        this.jdbcTemplate = jdbcTemplate;
        this.queryService = queryService;
        this.userRepository = userRepository;
        this.auditLogService = auditLogService;
    }

    @Transactional(readOnly = true)
    public List<HotelResponse> list(Authentication authentication,
                                    String keyword,
                                    Integer minStar,
                                    String area,
                                    Integer minPrice,
                                    Integer maxPrice) {
        if (hasAuthority(authentication, "USER_MANAGE")) {
            return queryService.hotels(keyword, minStar, area, minPrice, maxPrice);
        }

        UserAccount user = findUser(authentication.getName());
        String managedHotelId = user.getManagedHotelId();
        if (managedHotelId == null || managedHotelId.isBlank()) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "当前酒店管理员未绑定酒店");
        }
        return List.of(findById(managedHotelId));
    }

    public HotelResponse create(HotelAdminRequest request, String actorUsername) {
        String id = generateHotelId();
        String availabilityStatus = normalizeAvailabilityStatus(request.availabilityStatus());
        String coverImageUrl = normalizeOptionalText(request.coverImageUrl());

        jdbcTemplate.update("""
                INSERT INTO query_hotels(
                    id, name, address, star, price, phone, score, has_breakfast, facility, introduction,
                    availability_status, cover_image_url
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                id,
                request.name().trim(),
                request.address().trim(),
                request.star(),
                request.price(),
                request.phone().trim(),
                request.score(),
                request.hasBreakfast(),
                request.facility().trim(),
                request.introduction().trim(),
                availabilityStatus,
                coverImageUrl
        );

        auditLogService.record(actorUsername, "HOTEL", "CREATE", "HOTEL", id, "系统管理员新增酒店");
        return findById(id);
    }

    public HotelResponse update(Authentication authentication, String id, HotelAdminRequest request) {
        validateWriteAccess(authentication, id);
        String availabilityStatus = normalizeAvailabilityStatus(request.availabilityStatus());
        String coverImageUrl = normalizeOptionalText(request.coverImageUrl());

        int updated = jdbcTemplate.update("""
                UPDATE query_hotels
                SET name = ?,
                    address = ?,
                    star = ?,
                    price = ?,
                    phone = ?,
                    score = ?,
                    has_breakfast = ?,
                    facility = ?,
                    introduction = ?,
                    availability_status = ?,
                    cover_image_url = ?
                WHERE id = ?
                """,
                request.name().trim(),
                request.address().trim(),
                request.star(),
                request.price(),
                request.phone().trim(),
                request.score(),
                request.hasBreakfast(),
                request.facility().trim(),
                request.introduction().trim(),
                availabilityStatus,
                coverImageUrl,
                id
        );

        if (updated == 0) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "酒店不存在");
        }

        auditLogService.record(authentication.getName(), "HOTEL", "UPDATE", "HOTEL", id, "更新酒店信息或房态");
        return findById(id);
    }

    public void delete(String id, String actorUsername) {
        int deleted = jdbcTemplate.update("DELETE FROM query_hotels WHERE id = ?", id);
        if (deleted == 0) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "酒店不存在");
        }
        auditLogService.record(actorUsername, "HOTEL", "DELETE", "HOTEL", id, "系统管理员删除酒店");
    }

    @Transactional(readOnly = true)
    public HotelResponse findById(String id) {
        List<HotelResponse> list = jdbcTemplate.query("""
                SELECT id, name, address, star, price, phone, score, has_breakfast, facility, introduction,
                       availability_status, cover_image_url
                FROM query_hotels
                WHERE id = ?
                """, hotelRowMapper(), id);
        if (list.isEmpty()) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "酒店不存在");
        }
        return list.get(0);
    }

    private void validateWriteAccess(Authentication authentication, String hotelId) {
        if (hasAuthority(authentication, "USER_MANAGE")) {
            return;
        }
        UserAccount user = findUser(authentication.getName());
        if (user.getManagedHotelId() == null || !user.getManagedHotelId().equals(hotelId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN, "酒店管理员只能维护自己绑定的酒店");
        }
    }

    private boolean hasAuthority(Authentication authentication, String authority) {
        return authentication.getAuthorities().stream()
                .anyMatch(item -> authority.equals(item.getAuthority()));
    }

    private UserAccount findUser(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "用户不存在"));
    }

    private RowMapper<HotelResponse> hotelRowMapper() {
        return (rs, rowNum) -> new HotelResponse(
                rs.getString("id"),
                rs.getString("name"),
                rs.getString("address"),
                rs.getInt("star"),
                rs.getInt("price"),
                rs.getString("phone"),
                rs.getDouble("score"),
                rs.getBoolean("has_breakfast"),
                rs.getString("facility"),
                rs.getString("introduction"),
                rs.getString("availability_status"),
                rs.getString("cover_image_url")
        );
    }

    private String normalizeAvailabilityStatus(String status) {
        if (status == null || status.isBlank()) {
            return "AVAILABLE";
        }
        String normalized = status.trim().toUpperCase(Locale.ROOT);
        if (!ALLOWED_AVAILABILITY.contains(normalized)) {
            throw new BusinessException(ErrorCode.VALIDATION, "房态仅支持 AVAILABLE/LIMITED/BUSY/FULL");
        }
        return normalized;
    }

    private String normalizeOptionalText(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String generateHotelId() {
        return "h-" + UUID.randomUUID().toString().replace("-", "").substring(0, 8);
    }
}
