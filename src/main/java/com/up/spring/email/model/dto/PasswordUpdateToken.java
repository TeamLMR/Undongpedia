package com.up.spring.email.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;


// LocalDateTime 대신 Date 사용

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasswordUpdateToken {
    private Long tokenNo;
    private Long memberNo;
    private String token;
    private Date expiryDate;        // LocalDateTime → Date
    private String used;
    private Date createdAt;         // LocalDateTime → Date
}