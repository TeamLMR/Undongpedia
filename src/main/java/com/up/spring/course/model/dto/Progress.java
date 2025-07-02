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
public class Progress {
    private long prgSeq;
    private int prgPlayTime;
    private int prgTotalTime;
    private String prgCompleteYn;
    private Timestamp prgLastViewTime;
    private Timestamp prgCreateTime;
    private Timestamp prgUpdateTime;
    private long memberSeq;
    private long courseSeq;
    private long sectionSeq;
    private long currSeq;
}
