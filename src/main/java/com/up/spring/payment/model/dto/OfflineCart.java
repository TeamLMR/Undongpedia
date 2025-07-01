package com.up.spring.payment.model.dto;

import com.up.spring.course.model.dto.Course;
import com.up.spring.course.model.dto.CourseSchedule;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Timestamp;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OfflineCart {
    private int cartSeq;
    private long memberNo;
    private String tempReservationId;
    private Timestamp cartTimeStamp;

    private Course cartCourse;
    private CourseSchedule cartCourseSchedule;
}
