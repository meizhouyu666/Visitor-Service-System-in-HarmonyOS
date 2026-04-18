package com.visitor.service.query.dto;

public record WeatherResponse(
        String date,
        String weather,
        String temperature,
        String wind,
        int humidity,
        String tip
) {
}

