package com.up.spring.reservation.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReservationRequestDto {
    private String userId;
    private String seatId;
    private LocalDateTime reservationTime;
    private Integer duration; // 예약 시간 (분 단위)
} 