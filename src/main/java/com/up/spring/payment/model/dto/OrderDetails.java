package com.up.spring.payment.model.dto;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class OrderDetails {
    private int ordersSeq;
    private String ordersBank;
    private String ordersAccountNo;
    private String ordersCardCorp;
    private String ordersCardNo;
    private String ordersPaymentId;
    private String ordersPayhistId;
}
