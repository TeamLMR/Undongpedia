package com.up.spring.payment.model.dto;

import com.up.spring.course.model.dto.Course;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Cart {
    private int cartSeq;
    private Timestamp cartTimestamp;
    private long memberNo;
    private int courseSeq;
    private Course cartCourse;
}
