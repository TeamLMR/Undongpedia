package com.up.spring.coach.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Date;

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
    private Date applyDate;
    private Date approveDate;
    
    // Member 정보 추가
    private String memberName;
    private String memberId;
    private String memberNickname;
}