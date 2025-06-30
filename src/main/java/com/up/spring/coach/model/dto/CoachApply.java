package com.up.spring.coach.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CoachApply {
    private Long coaSeq;
    private String coaBank;
    private String coaBankNum;
    private String coaBankName;
    private String coaIntro;
    private String coaYn;
    private Long memberNo;
}