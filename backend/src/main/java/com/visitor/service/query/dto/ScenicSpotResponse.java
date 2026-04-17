package com.visitor.service.query.dto;

public record ScenicSpotResponse(
        String id,
        String name,
        String scenicArea,
        String location,
        String openTime,
        Integer ticketPrice,
        String level,      // 这里把原来的 AAAA 改成 level，或者直接写 "AAAA" 也行
        String type,
        Boolean isFree,    // 🔥 必须加上这个字段！否则报错！
        String description
) {
}