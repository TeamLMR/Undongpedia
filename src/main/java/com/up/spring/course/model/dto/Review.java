package com.up.spring.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Review {
    private int reviewSeq;
    private int memberSeq;
    private long courseSeq;
    private String reviewTitle;
    private String reviewContent;
    private int reviewRate;
    private Timestamp reviewCreateDate;
    private Timestamp reviewDeleteDate;
    private String memberNickname;

}
