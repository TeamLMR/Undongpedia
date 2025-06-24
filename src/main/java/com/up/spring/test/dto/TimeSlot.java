package com.up.spring.test.dto;

import lombok.Data;

@Data
public class TimeSlot {
    private int timeSlotId;
    private String startTime;
    private String endTime;
    private boolean available;
    private int maxCapacity;
    private int currentBookings;
} 