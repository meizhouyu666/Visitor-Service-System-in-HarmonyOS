package com.visitor.service.query.dto;

import java.time.LocalDate;

public record WeatherResponse(
        LocalDate date,
        String weather,
        String temperature,
        String wind,
        Integer humidity,
        String tip
) {
}