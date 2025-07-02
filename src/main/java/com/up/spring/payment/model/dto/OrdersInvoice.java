package com.up.spring.payment.model.dto;

import com.up.spring.course.model.dto.Course;
import lombok.*;

import java.sql.Timestamp;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class OrdersInvoice {
    private int ordersSeq;
    private Integer ordersPrice;
    private String ordersStatus;
    private Timestamp ordersTimestamp;
    private long memberNo;
    private long courseSeq;

    //오프라인 관련 컬럼
    private Long scheduleId;
    private String tempReservationId;
    private String courseType;

    private List<Course> courses; //코스 리스트
    private OrderDetails detail; // 1:1 상세 정보 (nullable)
}
