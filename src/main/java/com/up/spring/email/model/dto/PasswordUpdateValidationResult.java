package com.up.spring.email.model.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class PasswordUpdateValidationResult {
    private boolean valid;
    private Long memberNo;
    private String errorMessage;
} 