package com.up.spring.payment.model.dto;

import lombok.*;

import java.sql.Timestamp;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class Orders {
    private int ordersSeq;
    private Integer ordersPrice;
    private String ordersPrimaryPay;
    private String ordersStatus;
    private Timestamp ordersTimestamp;
    private Long memberNo;
    private int courseSeq;
    private String cancelYn;
    private Timestamp cancelTimestamp;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String courseTitle;

    private OrderDetails detail; // 1:1 상세 정보 (nullable)
}


