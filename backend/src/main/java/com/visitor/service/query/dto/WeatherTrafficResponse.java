package com.visitor.service.query.dto;

public record WeatherTrafficResponse(
        String weather,
        String temperature,
        String traffic
) {
}
