package com.up.spring.course.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.sql.Date;
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CourseSchedule {
    private Long scheduleId;
    private Long courseSeq;
    private Date courseDate;
    private String courseStartTime;
    private String courseEndTime;
    private String courseCapacity;
    private String courseLocation;
    private int bookedSeats;
    private String status;

}
